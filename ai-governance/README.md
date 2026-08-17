# ai-governance/

Gobierno de componentes de IA (ADR-017, Fase A del prompt maestro de
arquitectura objetivo, §35).

Ver [`ai-component-registry.yaml`](ai-component-registry.yaml): 2
entradas reales — `deterministic-fallback-engine` (`ACTIVE`, el motor de
recomendación real hoy, no generativo) y `langgraph-engine` (`DRAFT`,
interfaz sin implementar, `NotImplementedError` explícito, bloqueado en
DEP-06/ARG-019). Regla dura: ningún componente más allá de `DRAFT` puede
carecer de `evaluation_evidence` (`scripts/test.sh` lo exige).

Alcance deliberadamente estrecho — no se duplican registros que ya
existen y son más específicos: tools reales en
`argos-cyber-tools/tool_catalog/`, evaluadores en
`argos-validation/evaluators/README.md`. Si Fase G (Agentic RAG) añade
agent graphs/embeddings/corpus reales, se registran aquí cuando existan
de verdad — no antes.
