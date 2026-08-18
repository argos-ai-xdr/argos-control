# ADR-070: Reconciliación del Intelligent Detection Loop (Statistical Detector + Global Investigator + Wazuh Sidecar + SOC Feedback)

**Estado**: RESUELTO PARA BASELINE — alcance explícitamente acotado; reconcilia la salida de una reunión externa (change control, no declaración de implementación) con `ADR-069` sin abrir una segunda taxonomía de fases.

**Fecha**: 2026-08-18. **Fase**: N (extiende `ADR-069`, no la sustituye). Decisión del usuario, punto por punto, sobre el acta de una reunión con GMV.

## Contexto

Una reunión externa propuso un laboratorio de detección inteligente (OpenNebula/RKE2, Wazuh, Kafka/OpenSearch, IA estadística + LangGraph, sidecar de escritura, feedback SOC). El acta se declara explícitamente "plan sujeto a change control, no declaración de implementación". Varias partes ya estaban superadas por `ADR-069` (Kafka/NATS, `SOCDecision v1`); otras introducen decisiones nuevas que sí conviene fijar. Este ADR reconcilia ambas cosas -- no crea una segunda taxonomía de fases ("Fases 1-8" del acta se renombran `IDLAB-01..08`, un workstream experimental de `ADR-069`, no un roadmap paralelo a A→L).

## Decisiones

### 1. Statistical Detector y Global Investigator son componentes DISTINTOS

El score de anomalía nunca lo calcula un LLM (`DE-21`). Dos componentes separados:

```text
ARGOS Statistical Detection Engine (IF/OCSVM/LOF/streaming OSS)
        │ numerical anomaly score
        ▼
     WeakSignal v1
        │
        ▼
ARGOS Global Investigator (LangGraph, ya real -- argos-core/services/investigator)
```

`services/investigator` YA es el segundo componente (ADR-069) -- este ADR formaliza que el PRIMERO (el detector estadístico en sí, con modelo real entrenado) es una pieza nueva y separada, hoy sin implementación de modelo real (`BLOCKED_EXTERNAL` -- requeriría datos de entrenamiento reales y una librería ML real, ninguno disponible en este entorno). Lo que SÍ se fija aquí es su contrato de gobernanza: `DetectionModelManifest v1`.

### 2. Kafka/NATS -- confirmado, no reabierto

`ADR-069` ya resolvió esto: NATS para control/orquestación interna de ARGOS, Kafka para telemetría de alto volumen + disparo de investigación. El acta lo dejaba como punto abierto; aquí se cierra formalmente citando `ADR-069`, no se reabre.

### 3. OpenSearch es historia operacional consultable, NUNCA autoridad de evidencia

Corrección explícita al acta (que lo llama "fuente de verdad reconciliable"): en ARGOS la autoridad de auditoría sigue siendo `EvidenceManifest → EvidenceRoot → Transparency Log → TransparencyReceipt` (Fase J). OpenSearch es contexto histórico consultado por el Investigator (`L1-L4`), no un sustituto de esa cadena.

### 4. Wazuh sidecar: solo `CANDIDATE`, nunca despliegue de reglas

```text
AI -> Wazuh Agent sidecar real (grupo dedicado, módulos innecesarios
      desactivados) -> localfile -> Wazuh Manager, source_mode=CANDIDATE
```

Descartados explícitamente: escritura directa al Wazuh Indexer (`DE-25=0`) y reimplementación del protocolo interno agent-manager. El sidecar publica `CandidateFinding`, nunca aplica reglas (`DE-26=0`) -- el único camino de despliegue de reglas sigue siendo `WazuhRuleSpec → compilador → wazuh-logtest → backtest → SOC → RuleDeploymentGate → GitOps` (`ADR-069`, sin cambios). No implementado como código real todavía -- requiere un agente Wazuh real (`BLOCKED_EXTERNAL`).

### 5. Protección estructural contra bucle recursivo (`DE-19`)

Sin esta protección, un `CandidateFinding` generado por ARGOS podría re-entrar por Kafka y disparar una nueva investigación indefinidamente (`AI Candidate → Kafka → AI Candidate → ...`). Regla fija:

```text
source_mode == "CANDIDATE" AND origin_system == "argos-ai"
        → NO dispara automáticamente una nueva GlobalInvestigationRequest
```

El candidato sigue visible/almacenado -- solo no se realimenta automáticamente. Implementado como código real y probado: `investigator.should_trigger_new_investigation` (`argos-core`).

### 6. Provenance obligatorio: `source_mode` de tres valores, sin transición silenciosa

`WeakSignal v1` (`ADR-069`) gana campos: `source_mode` (`REAL | SYNTHETIC | CANDIDATE`), `origin_system`, `candidate_id`, `parent_event_refs`, `generation_depth`. Un generador sintético (`IDLAB-05/06`) declara `SYNTHETIC` desde el origen -- nunca se mezcla con telemetría real ni cambia de valor tras creado (`DE-20`, `DE-29`).

### 7. `Classification v1` no compite con `SOCDecision v1` -- lo referencia

`SOCDecision v1` (`ADR-069`) sigue siendo el acto humano autoritativo. `Classification v1` (nuevo, este ADR) es un artefacto de feedback DERIVADO e inmutable que referencia un `SOCDecision` ya emitido -- nunca lo sustituye ni compite por ser "la decisión del SOC":

```text
ThreatAssessment → SOCDecision → Classification → feedback/model/rules
```

### 8. `DetectionTombstone v1` -- supresión acotada, nunca global ni destructiva

Invariante: `Tombstone ≠ delete event`, `≠ modify historical evidence`, `≠ global suppression`. Acotado por `entity_refs` + `signal_signature`, con `valid_until` -- al caducar, la señal vuelve a ser visible. El evento original nunca se borra ni modifica (`DE-23`). Implementado como código real y probado: `investigator.is_signal_tombstoned`.

### 9. `WazuhDecoderSpec v1` -- gap real, no forzado dentro de `WazuhRuleSpec`

Regla y decoder de Wazuh son artefactos distintos; el acta los mezcla, este ADR no. `WazuhRuleSpec v1` (`ADR-069`) sigue siendo solo para reglas. `WazuhDecoderSpec v1` (schema declarado aquí) queda `SPECIFIED / NOT_IMPLEMENTED` -- el compilador (`services/rule_engineering.compile_decoder_spec_to_xml`) lanza `NotImplementedError` explícito citando este ADR, mismo patrón honesto que `LangGraphEngine`/conectores.

### 10. `DetectionModelManifest v1` -- gobernanza del detector estadístico

Ningún `anomaly_score` se interpreta sin poder responder: ¿con qué modelo, features, baseline, threshold, versión `ACTIVE` en ese momento? El feedback del SOC NUNCA cambia pesos de modelo en caliente (`DE-28=0`) -- pasa por el mismo ciclo Shadow→Evaluation→Promotion→Drift→Rollback que ya gobierna el resto de componentes de IA (`ai-component-registry.yaml`, `argos-control`).

### 11. Datasets de ground truth: separación por tiempo/escenario/host, no por fila aleatoria

Un split aleatorio por fila puede dejar el mismo ataque sobre el mismo host repartido entre training y test, inflando artificialmente las métricas. `DE-27` (`argos-validation`) prueba estructuralmente que ningún `(scenario_id, host_id)` aparece a la vez en ambos conjuntos. **Andamiaje IDLAB-05/06 (2026-08-18)**: `argos-validation/harness/loaders/detection_ground_truth.py` + `ground-truth/schemas/{nominal-baseline,detection-ground-truth}-manifest.schema.json` definen el formato real de captura de baseline nominal (IDLAB-05, `known_attacks_present` fijado a `false` por schema) y ground truth etiquetado con `split` train/test explícito por registro (IDLAB-06) — probado end-to-end contra `DE-27` (un manifiesto de ejemplo sin fuga produce `0.0`, uno deliberadamente filtrado produce `1.0`). Los manifiestos de ejemplo demuestran el formato, no son telemetría real — sigue `BLOCKED_EXTERNAL` sin laboratorio real.

### 12. Laboratorio OpenNebula: límite explícito, no oculto

Un RKE2 single-node **no valida HA real de control-plane** (failover, quorum multi-nodo, recuperación). Se documenta como límite conocido del cyber-range, no como capacidad demostrada. Dos perfiles de laboratorio, sin mezclar en el primer MVP: `LAB-K8S` (Chaos Mesh real) y `LAB-VM` (mecanismo de caos de infraestructura sin decidir, `TBD`).

### 13. Nomenclatura del acta → `IDLAB-01..08`

Las "Fases 1-8" del acta (cyber-range, Wazuh SIEM, sensores, inyección de ataques/caos, baseline nominal, ground truth, detección inteligente, feedback SOC) se renombran `IDLAB-01..08` -- workstream experimental de `ADR-069`, no una tercera taxonomía de fases paralela a A→L/M/N.

## Quality gates nuevos -- familia `DE-*`

| ID | Umbral | Crítico |
| --- | --- | --- |
| DE-19 | Investigaciones recursivas disparadas por un candidato de IA = 0 | sí |
| DE-20 | Completitud de `source_mode` en el linaje de provenance = 1.00 | sí |
| DE-21 | Anomaly scores generados por LLM = 0 | sí |
| DE-22 | Recuperación no acotada de OpenSearch en investigación crítica = 0 | no |
| DE-23 | Tombstone que produce supresión amplia/permanente = 0 | sí |
| DE-24 | Completitud del linaje de feedback SOC = 1.00 | no |
| DE-25 | Escrituras directas de IA al Wazuh Indexer = 0 | sí |
| DE-26 | Sidecar capaz de desplegar reglas = 0 | sí |
| DE-27 | Fuga de escenario/host entre conjuntos train/test = 0 | sí |
| DE-28 | Promoción automática de modelo desde feedback SOC = 0 | sí |
| DE-29 | Telemetría sintética aceptada como REAL = 0 | sí |
| DE-30 | Regla generada para un patrón multivariante no reducible = 0 | no |

**Estado real, no fabricado**: `DE-19`, `DE-23`, `DE-27` tienen código real y tests (`argos-core`/`argos-validation`, ver commits). `DE-20`/`DE-29` se imponen por schema (`source_mode` obligatorio y cerrado en `WeakSignal v1`) más una prueba de que no cambia tras creado. `DE-21`/`DE-25`/`DE-26`/`DE-28`/`DE-30` son invariantes de diseño sin componente real todavía que pudiera violarlos (`NOT_EVALUATED`, no `PASS` fabricado). `DE-22`/`DE-24` dependen de OpenSearch/Kafka reales (`BLOCKED_EXTERNAL`).

## Consecuencias

* No reabre `G0`/`v0.6.26`. Es la base técnica para una futura `v0.6.25.8` del documento maestro (decisión de versionado del usuario, no de este ADR).
* `governance/backlog` gana epic `E12` (`IDLAB-01..08`), ver `project/backlog/backlog.yaml`.
* Nada de lo construido en esta fase afirma detector estadístico entrenado, sidecar Wazuh real, ni laboratorio OpenNebula desplegado -- todo eso es `BLOCKED_EXTERNAL`.
