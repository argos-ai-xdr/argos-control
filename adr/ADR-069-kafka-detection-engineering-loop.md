# ADR-069: Kafka Event Streaming Plane & Autonomous Detection Engineering Loop

**Estado**: RESUELTO PARA BASELINE — alcance explícitamente acotado a la investigación global y la ingeniería de reglas Wazuh; no sustituye a NATS JetStream para el resto del sistema.

**Fecha**: 2026-08-18. **Fase**: N (posterior a Fase M/Chaos, ADR-068). Decisión del usuario, con desviación explícita de `ADR-002` reconocida y justificada aquí, no ocultada.

## Contexto

Wazuh, hasta ahora, era solo una fuente de `SecurityEvent v1` hacia `normalizer`. El usuario propone ampliar su rol a punto de partida de un **bucle cerrado de ingeniería de detección**: señales débiles (severidad baja pero contexto sospechoso) disparan una investigación global (IA + Semantic Graph + Mission + CTI + histórico), el SOC decide, y si confirma una amenaza real, se genera —de forma gobernada, nunca directa— una nueva regla Wazuh, que se prueba, se hace backtesting contra histórico y se despliega vía GitOps tras aprobación humana.

## Decisión 1: Kafka como bus paralelo — desviación explícita de ADR-002

`ADR-002` (RESUELTO PARA BASELINE MVP) fijó NATS JetStream **citando explícitamente que evita "la complejidad operativa de un stack tipo Kafka"** — no fue una omisión, fue un rechazo razonado. Introducir Kafka aquí es una desviación real de ese rationale, y se documenta como tal en vez de tratarse como un detalle de implementación:

* **Qué NO cambia**: `ADR-002` sigue vigente para el resto del sistema — `SecurityEvent`/`Incident`/`Recommendation`/`Approval`/`ActionResult` y el resto del pipeline productivo de respuesta siguen sobre NATS JetStream. Ningún consumidor existente migra a Kafka.
* **Qué SÍ cambia**: el nuevo plano de streaming de eventos/alertas Wazuh (`archives.json`/`alerts.json`) y el bucle de investigación/ingeniería de reglas usa Kafka, en paralelo, sin sustituir el flujo soportado `Wazuh Manager → Filebeat → Wazuh Indexer/OpenSearch`.
* **Por qué no NATS JetStream para esto en concreto**: decisión del usuario, no una limitación técnica real de NATS (NATS JetStream ya ofrece consumidores durables, retry, DLQ y deduplicación por `event_id` — las mismas propiedades citadas para Kafka). Se documenta aquí para que quede trazable que la elección fue explícita, no por desconocimiento de la alternativa ya aprobada.
* **Consecuencia operativa**: un stack Kafka nuevo en `argos-platform` (namespace propio, RBAC, NetworkPolicy) — mismo criterio de aislamiento que el resto de `platform/*`.

## Decisión 2: `AI_DIRECT_RULE_DEPLOYMENT = DENY` (invariante no negociable)

Ningún LLM escribe ni despliega XML de Wazuh directamente. La cadena es siempre:

```text
AI RuleCandidate → WazuhRuleSpec v1 (schema)
        → compilador determinista (Python, sin LLM) → Wazuh XML
        → wazuh-logtest (sintaxis)
        → backtest contra OpenSearch histórico (FP/FN estimado)
        → SOC Approval (humano)
        → GitOps
        → Wazuh (canary → activo)
```

Mismo principio que gobierna el resto de ARGOS: **la IA interpreta; las políticas y las personas autorizan** (ver `ADR-011`, `ADR-053`). El compilador determinista (`argos-core/services/rule_engineering/compiler.py`) es la SafetyKernel-equivalente de este flujo: nunca genera XML él mismo desde lenguaje natural, solo desde un `WazuhRuleSpec` ya validado contra schema.

### Gating explícito por `CH-07` (ADR-068)

`CH-07` (replay de `Approval` tras reinicio del gateway) se confirmó `KNOWN_FAILING` en `ADR-068` (`ARG-020` sin cerrar: `ApprovalStore` en memoria de proceso). **Actualización 2026-08-18**: `ARG-020` tiene ahora un núcleo real — `argos-cyber-tools/policies/approval/durable_store.DurableApprovalStore` (SQLite) implementa `consume(approval_id, nonce, action_binding, expires_at)` como transición atómica `NOT_CONSUMED → CONSUMED` (probado con 5 consumidores concurrentes: exactamente 1 éxito), sobrevive a un reinicio de proceso (`CH-07` = `PASS_LOCALLY`), y falla cerrado si el propio almacén no responde (nunca cae a memoria como resguardo). **Pero esto NO cambia el gating aquí**: `Gateway()` sigue sin usar `DurableApprovalStore` por defecto (ningún despliegue real existe todavía que lo necesite), y `services/rule_engineering.RuleDeploymentGate.authorize_deployment` sigue recibiendo `durable_approval_available=False` en cualquier llamada real — la razón cambió (de "no existe implementación durable" a "existe pero no está desplegada/conectada"), la conclusión no: **mientras no exista un despliegue real que use el almacén durable end-to-end, ninguna aprobación SOC de una `RuleCandidate` puede desencadenar despliegue AUTOMÁTICO a Wazuh** — generar, validar, backtestear y presentar al SOC sí; aplicar tras la aprobación, no. `RuleDeploymentGate` implementa este bloqueo como código real, no como nota de prosa.

## Decisión 3: Contratos nuevos (DERIVADOS, no proceden del docx v0.5)

Declarados en `argos-contracts-scenarios` con el mismo patrón que `safety-envelope`/`approval` — `additionalProperties: true`, sin tocar los 10 contratos originales:

* `WeakSignal v1` — señal de severidad baja con contexto suficiente para justificar escalado (nunca "cualquier evento").
* `GlobalInvestigationRequest v1` — expansión progresiva de contexto declarada (L0..L5), nunca "consultar todo" implícito.
* `ThreatAssessment v1` — conclusión de la investigación: `BENIGN | SUSPICIOUS | LIKELY_THREAT | CONFIRMED_PATTERN | INSUFFICIENT_EVIDENCE | CONFLICTING_EVIDENCE`, con `evidence_refs` obligatorio; mantiene el vocabulario ya existente en el proyecto (`FACT`/`RETRIEVED_CONTEXT`/`INFERENCE`/`HYPOTHESIS`/`UNKNOWN`).
* `WazuhRuleSpec v1` — la única entrada aceptada por el compilador determinista; el LLM produce esto, nunca XML.
* `SOCDecision v1` — `BENIGN | FALSE_POSITIVE | MONITOR | SUSPICIOUS | CONFIRMED_THREAT | NEEDS_MORE_DATA`. `NEEDS_MORE_DATA` se conecta con `increase_monitoring` (ya real, `ADR-056`) — la IA nunca fuerza una decisión prematura entre amenaza/benigno.

## Investigación global: expansión progresiva de contexto (L0-L5)

`services/investigator` decide DETERMINÍSTICAMENTE qué nivel de contexto expandir a continuación (nunca "consultar todo en cada alerta"):

```text
L0 evento actual (±minutos) → L1 mismo asset/usuario/IP/proceso/correlation_key
→ L2 ±30-60min identidades/network flows/process tree/RBAC/vulnerabilities
→ L3 Attack Graph/Semantic Graph/Mission dependencies/crown jewels
→ L4 24h/7d histórico OpenSearch, incidentes similares, ATT&CK/IOC
→ L5 entorno completo, SOLO si la hipótesis lo justifica explícitamente
```

El investigador tiene acceso de solo lectura (`READ` Kafka/OpenSearch/Semantic Graph/MissionContext/CTI, `WRITE` únicamente `InvestigationRecord`) — nunca escribe reglas, nunca modifica OpenSearch, nunca aprueba, nunca ejecuta (mismo principio de separación que `mcp_gateway`: quien investiga/recomienda nunca es quien autoriza ni ejecuta).

## Backtesting antes de activar cualquier regla

Antes de que una `RuleCandidate` llegue al SOC para aprobación, se calcula contra histórico: `events matched`, `unique assets`, `unique users`, `incidents affected`, `estimated FP rate`, `alerts/day`, `max alerts/hour`. Ninguna regla generada por IA se activa sin esta evidencia — evita el escenario "10 events/día esperados → 50.000 alertas/hora reales".

## Chaos Engineering — extensión (ADR-068)

Doce escenarios nuevos, `CHAOS-21..32` (Kafka, OpenSearch, Investigator, RuleSpec, backtest, despliegue de reglas, feedback loop) — ver `argos-validation/chaos/scenarios/catalog.yaml`. Dos invariantes explícitos: `CHAOS-22` (entrega duplicada de Kafka con el mismo `event_id` → 1 sola investigación, no N) y `CHAOS-24`/`CHAOS-29` (OpenSearch/backtest no disponible → `INSUFFICIENT_EVIDENCE`, nunca promoción/generación automática de regla).

## Consecuencias

* No reabre `G0`/`v0.6.26` — evidencia técnica adicional para una versión posterior de diseño/implementación (`v0.6.25.7`, decisión de versionado del usuario, no de este ADR).
* `governance/backlog` gana epic `E11` (Detection Engineering Loop), ver `project/backlog/backlog.yaml`.
* Nada de lo construido en esta fase afirma clúster Kafka/OpenSearch real desplegado — `IMPLEMENTED_LOCALLY_AND_TESTED` para el código puro (compilador, gate, investigador determinista), `BLOCKED_EXTERNAL` para Kafka/OpenSearch/wazuh-logtest reales (mismo bloqueo que Chaos Mesh/Shuffle: sin clúster real disponible en este entorno).
