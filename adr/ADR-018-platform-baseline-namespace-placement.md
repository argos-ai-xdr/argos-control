# ADR-018: Ubicación de namespace para SPIRE y OpenBao (Fase B, ADR-017)

* **Estado**: RESUELTO PARA BASELINE
* **Fecha**: 2026-08-17
* **Decisores**: Platform/SRE (siguiendo el criterio ya fijado por ADR-017: resolver solo lo que sea real y verificable, sin ampliar el modelo ratificado si no hace falta)
* **Historia relacionada**: ARG-002, ARG-003

## Contexto

ADR-004 decide QUÉ herramienta usa cada tipo de identidad (Keycloak/
usuarios, SPIRE/workloads, OpenBao/secretos), pero deja explícitamente
abierto DÓNDE se despliega cada una. Ese hueco quedó documentado como
"Pendiente" en los README reales de los tres componentes
(`argos-platform/platform/{keycloak,spire,openbao}/README.md`):

* Keycloak: namespace `argos-smartops` — **ya resuelto**, sin ambigüedad.
* SPIRE: *"server en `argos-observability` o namespace dedicado
  `spire-system` (a decidir en S1)"*.
* OpenBao: *"dedicado, `argos-secrets` (a confirmar en S1) o
  `argos-observability`"*.

El modelo de 6 planos/10 namespaces (`architecture/logical/planos.md`)
es una decisión ya ratificada, con validador real en
`argos-platform/scripts/test.sh` (`expected_namespaces`, 10 entradas
fijas). Crear `spire-system` o `argos-secrets` como namespaces nuevos
ampliaría ese conjunto cerrado — el mismo tipo de tensión, a menor
escala, que la pregunta de los 32 contratos nuevos resuelta en ADR-017.

## Decisión

**No se crea ningún namespace nuevo.** SPIRE Server y OpenBao se
despliegan en `argos-observability` (P6, plano ya existente), tal como
ambos README ya proponían como una de sus dos opciones — esta decisión
solo elige entre opciones ya sobre la mesa, no introduce una tercera.

Keycloak permanece en `argos-smartops`, sin cambio.

## Consecuencia

* El conjunto de 10 namespaces ratificado en `planos.md` y verificado
  en `scripts/test.sh` **no cambia** — ningún ARG-029+ ni cambio de
  validador hace falta por esta decisión.
* `argos-observability` pasa a alojar infraestructura transversal
  (identidad de workload, secretos de corta duración) además de su
  responsabilidad original de trazas/métricas — es una cuestión de
  namespace, no de responsabilidad de plano: SPIRE/OpenBao sirven a los
  seis planos por igual, ninguno "pertenece" a P6. `planos.md` se
  actualiza para reflejarlo sin reescribir la responsabilidad de P6.
* Esta decisión **no despliega nada real todavía**: sigue sin existir
  chart, versión, digest, política OpenBao por servicio, ni topología
  HA de SPIRE — todo eso permanece "Pendiente" exactamente donde ya lo
  estaba (ARG-002/ARG-003), esta ADR resuelve solo la pregunta de
  ubicación, no el resto de las decisiones de despliegue.

## Impacto sobre AC01-AC14

No aplica — decisión de topología de plataforma, ningún AC01-AC14 se ve
afectado (nada de esto está desplegado ni forma parte de un flujo
probado hoy).

## Fuentes

`argos-control/adr/ADR-004-identity-separation.md`,
`argos-control/architecture/logical/planos.md`,
`argos-platform/platform/spire/README.md`,
`argos-platform/platform/openbao/README.md`,
`argos-platform/scripts/test.sh`,
`architecture/v0.6.25-gap-matrix.md` (identifica este hueco, §2-4).
