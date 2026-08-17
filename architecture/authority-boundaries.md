# Authority boundaries

ADR-017, Fase A. Consolida quién/qué tiene autoridad real para decidir o
actuar en el sistema — no describe un subsistema nuevo, solo reúne en un
solo lugar hechos ya verdaderos y dispersos entre código, ADR y tests.
Cada afirmación cita el punto exacto de aplicación real; ninguna es
aspiracional.

## Regla general

```
AI RECOMMENDS
PDP DECIDES POLICY
HUMAN AUTHORIZES
EXECUTOR EXECUTES
EVIDENCE RECORDS
```

Estas cinco responsabilidades nunca se fusionan en el mismo componente.
Hoy el sistema real cubre las cinco (ver tabla), aunque "PDP" es una
reimplementación en Python de la regla real (`InMemoryPolicyDecisionPoint`),
no un servidor OPA desplegado, y "EVIDENCE RECORDS" no incluye todavía un
Transparency Log (ver `../assurance/argos-assurance.yaml`, CLAIM-010).

## Quién decide qué, con el punto de aplicación real

| Responsabilidad | Quién/qué | Aplicación real | Puede saltarse |
| --- | --- | --- | --- |
| Proponer una recomendación | `DeterministicFallbackEngine` (o, cuando exista, `LangGraphEngine`) | `argos-core/services/recommendation/__init__.py` | Nunca decide autorización — verificado por inspección de imports: ningún `RecommendationEngine` importa un ejecutor (`CLAIM-005`, `../assurance/argos-assurance.yaml`) |
| Decidir política (ALLOW_DRY_RUN / APPROVAL_REQUIRED / DENY) | `InMemoryPolicyDecisionPoint` | `argos-core/services/policy_adapter/__init__.py` | No — regla F07 evaluada en cada llamada, sin excepción por caller |
| Autorizar `execute` | Operador humano con rol `soc-approver` | `argos-smartops/api/approvals.py::create_approval` (`Depends(require_role("soc-approver"))`) — el ÚNICO endpoint de todo `argos-smartops` con rol específico; el resto (`handover`, `incidents.status`) solo exige *algún* operador autenticado, no un rol concreto | No — `require_role` rechaza con 403 cualquier otro rol |
| Aplicar la decisión de autorización antes de ejecutar | `mcp_gateway.Gateway.authorize()` | `argos-cyber-tools/mcp_gateway/__init__.py` | No — único punto de entrada real entre `argos-core`/agente y `executors`; sin credential passthrough (`TokenPassthroughError` si la credencial efímera coincidiera con la del llamante) |
| Ejecutar la acción aprobada | `KubernetesExecutor` / `ScaleToZeroExecutor` | `argos-cyber-tools/executors/` | No decide nada — solo aplica lo que ya pasó por Gateway+Approval, con idempotencia real (`IdempotencyStore`) |
| Verificar el resultado | `rollback/verification.py` | Recomputa el estado real, no confía en el campo `verification` del propio `ActionResult` | — |
| Bloquear cualquier gate | Security Observer (QSO) | `governance/policies/segregation-of-duties.md`: "QA/Security Observer puede bloquear cualquier gate" — sin aplicación en código todavía (es un rol de proceso G0-G7, no un endpoint) | — |
| Autoaprobar una excepción propia | Nadie, ningún rol | `governance/policies/segregation-of-duties.md` ("ningún rol puede aprobar su propia excepción de seguridad"); en código: `create_approval` rechaza con 403 si `operator.subject == REQUESTER_SYSTEM_ID`, y `ApprovalStore.validate_and_consume` rechaza si `approver_id == requester_id` **o** `== executor_id` (dos reglas de segregación distintas, ambas reales) | Nunca |
| Cortar egress/escalar a cero en emergencia | Cualquier rol (kill switch) | `argos-platform/cyber-range/kill-switch/kill-switch.sh` — deliberadamente sin restricción de rol, distinto de la contención ordinaria (que sí exige Approval); no otorga permiso de ejecución nuevo, solo revoca | — |

## Lo que NO tiene autoridad hoy, explícitamente

* **El LLM/agente**: no tiene credenciales de ejecución, no decide
  política, no aprueba. Cuando `LangGraphEngine` exista (Fase G), esta
  fila no cambia — el invariante está fijado en ADR-008 antes de que el
  componente exista.
* **Milvus / cualquier fuente de conocimiento recuperado**: no existe
  todavía (`../assurance/argos-assurance.yaml`), por lo que no tiene
  autoridad porque no hay nada que autorizar — cuando exista, el
  documento maestro ya fija que "no debe representarse como source of
  truth operacional".
* **Un Safety Kernel**: no existe. Hoy no hay ninguna validación
  determinista de límites entre `Recommendation` y `PolicyDecision` —
  ver `CLAIM-009` (`NOT_SUPPORTED`). Es el hueco de autoridad más
  importante identificado en `../architecture/v0.6.25-gap-matrix.md`.

## Fuentes

`governance/policies/segregation-of-duties.md`, `adr/ADR-003-mcp-security.md`,
`adr/ADR-005-opa-policy-decision-point.md`, `adr/ADR-008-vllm-fallback.md`,
`adr/ADR-011-autonomy-level.md`, `assurance/argos-assurance.yaml`,
`architecture/v0.6.25-gap-matrix.md`.
