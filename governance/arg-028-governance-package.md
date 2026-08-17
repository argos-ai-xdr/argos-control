# Paquete Gobierno (ARG-028)

ARG-028 (S8, propuesta v0.6.25.4 §16.7) define el paquete **"Gobierno:
Release/gates, defectos, waivers, riesgos, licencias, retención, change
control y PI3"**, validado por "Owner/sign-off nominal". A diferencia de
los paquetes anteriores (Cyber-range, HITL/SOAR, SOC handover, Operación
XDR, Release/restore), este NO consiste mayoritariamente en código nuevo
— consolida procesos y artefactos de gobierno que en su mayoría ya
existen, dispersos, y señala con precisión cuáles se han EJERCITADO de
verdad frente a cuáles solo están definidos.

## Release / gates

`governance/gates/gates.md` — G0-G7, uno por sprint (S1-S8), con
criterios BLOCKED explícitos por gate y autoridad de bloqueo
("QA/Security Observer puede bloquear cualquier gate; ningún rol puede
autoaprobar una excepción de la que sea ejecutor"). Estado real de cada
gate: ver `argos-validation/traceability.yaml` (fuente autoritativa del
estado VERIFICADO, no aspiracional — G0 `PARTIAL`, G1-G5 `PASS`, G6
`PARTIAL`, G7 `BLOCKED`).

## Defectos

**No existe un registro de defectos formal.** Ninguna plantilla de issue
en `.github/ISSUE_TEMPLATE/` cubre "defecto" (solo `story`,
`architecture-decision`, `risk`, `exception`). Verificado contra la API
de GitHub: **0 issues filed en `argos-control`** — ni un defecto, ni una
excepción, ni un riesgo se ha registrado formalmente todavía por esa vía,
pese a que el proceso está diseñado para ello.

## Waivers

`templates`/`.github/ISSUE_TEMPLATE/exception.yaml` — mecanismo real y
completo: caducidad obligatoria (sin excepciones indefinidas),
solicitante/aprobador estructuralmente distintos, controles
compensatorios obligatorios, y un campo explícito "¿afecta a un control
crítico de AC01-AC14?" que enlaza directamente a la lista
`no_waiver_for` de `project/acceptance/acceptance-criteria.yaml`
(acciones inseguras, ejecución sin aprobación, CVE inventadas, violación
de allowlist, fallo de rollback, fuga de datos — ninguna admite waiver).
**Nunca se ha usado**: `governance/exceptions/log.yaml` no existe —
`governance/exceptions/README.md` lo dice explícitamente por diseño:
"crear el archivo con la primera excepción real; no se siembra con datos
ficticios". Consistente con el hallazgo de "Defectos": 0 issues filed.

## Riesgos

`governance/risks/risk-register.yaml` — real y sustancial: 10 riesgos
(`DEP-01`..`DEP-10`) con descripción, fecha límite, fallback concreto,
impacto si no se mitiga, y si está en la ruta crítica
(`DEP-01/DEP-02 → ARG-001/003/004 → ARG-015/016/017 → ARG-019/020/021 →
ARG-023 → ARG-027/028`). Ninguna fecha límite ha vencido todavía en
términos de calendario — `S1` empieza 01-sep-2026 (ver
`project/sprint-definitions/S1.md`), y hoy es 17-ago-2026 — **pero el
propio calendario de sprints ya quedó desalineado con el estado real**:
hay código funcional y probado correspondiente a S1 hasta S8 (ver
`releases/0.1.0-dev/as-built.md`), construido fuera de ese orden
calendario, mientras el registro de riesgos sigue anclado a fechas de
sprint que darían la falsa impresión de que nada ha empezado. Ningún
riesgo del registro se ha marcado mitigado ni actualizado desde su
"semilla inicial".

## Licencias

`compatibility/oss-admission-registry.yaml` (OSS-QUAL-01) — real,
completo para los 10 componentes que enumera el documento maestro:
SPDX ID, obligaciones de distribución/red evaluadas caso por caso (p. ej.
por qué AGPL-3.0 de Shuffle/MISP no activa su obligación de red bajo uso
interno self-hosted), gate `ADMIT`/`ADMIT_WITH_OBLIGATIONS`/`REJECT` por
componente. `ADR-013` fija la política general (solo dependencias
self-hosting con SBOM, digest, scanner, owner y sustituto). Ver también
el gap real ya documentado ahí: Kyverno sin ADR de convivencia/
sustitución con Gatekeeper.

## Retención

`ADR-016` (qué puede/no puede vivir en Git — evidencia real, logs
completos, PCAP, snapshots CTI completos y secretos SIEMPRE fuera de
Git) + el campo `retention` real de `EvidenceManifest`
(`argos-core/services/evidence_writer.RetentionPolicy`, ver
`argos-core/docs/operations-package.md`). Lo que falta: una política de
**clasificación** con plazos de retención concretos por clase de dato —
`DEP-08` del registro de riesgos ("Clasificación/retención/RPO-RTO sin
decidir") lo declara explícitamente como pendiente, con fallback
("política conservadora local sin exportación") ya vigente por defecto.

## Change control

Rama `main` protegida, PR obligatorio, sin push directo/force-push
(ADR-015, regla común de la organización). `CODEOWNERS` de cada repo
existe y estructura la revisión por área — pero en `argos-control` los
owners son **roles genéricos sin mapear a cuentas reales de GitHub**
(`@poa-architecture`, `@delivery-lead`, etc., con nota explícita: "Sustituir
por handles de GitHub durante S1, DEP-01"). Mientras no se mapeen, la
protección de rama no puede exigir la revisión de una persona concreta —
es una intención de control, no un control activo todavía.

## PI3

Mencionado en `governance/gates/gates.md` (hito M8: "archivo,
transferencia y cierre → baseline PI3 y lecciones aprendidas") y en
`compatibility/components.yaml` (`optional_pi3`: OpenCTI Community,
evaluable en PI3, no P0). No es una fase que pueda iniciarse — depende de
que M8 (31-dic-2026) se alcance primero.

## Lectura honesta del criterio de validación ("Owner/sign-off nominal")

Los ARTEFACTOS de gobierno (gates, riesgos, waivers, licencias) están
completos y bien diseñados — mejor que "nominal", en el sentido de que no
son plantillas vacías, tienen contenido real (10 riesgos reales, 10
componentes OSS evaluados). Lo que falta para un sign-off real: (1)
CODEOWNERS con personas reales, no roles; (2) al menos un ejercicio real
del proceso de excepción/riesgo vía issue (hoy: cero); (3) reconciliar el
registro de riesgos con el estado real de avance, que ya adelantó al
calendario de sprints. El paquete queda `NOT EVALUATED` honestamente por
esas tres razones concretas, no por falta de diseño.
