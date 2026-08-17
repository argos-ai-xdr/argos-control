# ADR-056: Executor real para increase_monitoring (Fase I)

* **Estado**: RESUELTO PARA BASELINE
* **Fecha**: 2026-08-17
* **Decisores**: Platform/SRE, Cyber-Range
* **Historia relacionada**: hueco documentado en `argos-cyber-tools/executors/README.md` ("Sin executor todavía... no documentado en ningún otro sitio, a diferencia del resto de piezas pendientes de este repo")

## Contexto

`tool_catalog/definitions/increase_monitoring.yaml` declara la
herramienta (`mode: [dry-run, execute]`, `approval_required: false`,
`side_effect_class: REVERSIBLE_WRITE` desde ADR-053) y
`mcp_gateway.Gateway.authorize()` ya la autorizaría hoy — pero no existía
ningún código en `argos-cyber-tools` que la ejecutara de verdad. El
propio README del módulo señalaba el bloqueo explícito: "falta decidir
contra qué API se 'eleva la verbosidad de logging/telemetría' (Falco,
Wazuh, el futuro OTel collector de argos-platform) antes de poder
escribirlo".

## Decisión

Backend elegido: **Wazuh**. Es la única fuente de telemetría con
adapter real ya integrado en `argos-core` (`normalizer`/`correlator`
consumen sus eventos hoy; Falco/Hubble/K8s Audit no tienen ese mismo
nivel de integración real, y el OTel collector de `argos-platform` es
interfaz, no despliegue real). "Elevar verbosidad" se modela como subir
el nivel de log del agente Wazuh del target de `normal` a `verbose`.

Implementación con el mismo nivel de fidelidad que los otros dos
executors de escritura (`isolate_kubernetes_workload`,
`scale_to_zero`): `FakeMonitoringState` en memoria (sin agente Wazuh
real desplegado, ARG-003), pero un estado que cambia de verdad y que
`rollback/` revierte y verifica de verdad — no un mock que finge.
`rollback_increase_monitoring` sigue el mismo principio ya corregido
para `scale_to_zero` esta sesión: solo reporta `changed_resources` si
de verdad había algo que revertir.

## Consecuencia

* Las 3 acciones `execute` del catálogo (`isolate_kubernetes_workload`,
  `scale_to_zero`, `increase_monitoring`) tienen ahora executor +
  rollback + verificación reales — ninguna queda "autorizable pero sin
  código que la ejecute".
* Sigue sin existir un cliente HTTP real hacia Wazuh (ni hacia ningún
  backend real) — la brecha entre "lógica real" y "cluster/agente real
  desplegado" es la misma que para `isolate_kubernetes_workload`/
  `scale_to_zero` desde el principio del proyecto (ARG-003), no una
  brecha nueva.
* No se crea ARG-029+: es cerrar un hueco ya identificado dentro del
  alcance existente de `argos-cyber-tools`, no una capacidad nueva del
  prompt maestro de arquitectura objetivo.

## Impacto sobre AC01-AC14

Sustenta AC11-AC13 (idempotency key, changed_resources, verification)
para `increase_monitoring`, que antes no tenía cobertura real posible al
no existir el executor.

## Fuentes

`argos-cyber-tools/executors/increase_monitoring.py`,
`argos-cyber-tools/rollback/strategies.py`,
`argos-cyber-tools/rollback/verification.py`,
`argos-cyber-tools/tests/rollback/test_rollback_cycle.py`,
`argos-cyber-tools/tool_catalog/definitions/increase_monitoring.yaml`.
