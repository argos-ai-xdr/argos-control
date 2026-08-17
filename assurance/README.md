# assurance/

Ledger de Deep Assurance (ADR-051, Fase A del prompt maestro de
arquitectura objetivo): cadena Requirement→Claim→Argument→Control→Test→
Metric→Run→Evidence→Residual Risk→Gate sobre el MVP real.

No es un motor de software (eso sería "Deep Assurance Architecture",
Fase J, no construida) — es el documento que un motor así consumiría o
generaría, mantenido a mano por ahora, con el mismo rigor: ningún claim
`SUPPORTED`/`PARTIALLY_SUPPORTED` puede carecer de `controls`/
`run_evidence` verificables (`scripts/test.sh` lo exige).

Ver [`argos-assurance.yaml`](argos-assurance.yaml). 8 claims sobre
capacidades reales (AC01/AC03/AC08/AC09/AC10/AC12/AC13, ARG-010,
separación agente/ejecución), 2 claims `NOT_SUPPORTED` sobre lo que el
gap matrix (`../architecture/v0.6.25-gap-matrix.md`) ya identificó como
inexistente (Safety Kernel, Transparency Log) — el ledger no oculta
huecos, los registra en el mismo formato que los aciertos.
