# ADR-019: ToolManifest v1 — side_effect_class, rate_limit y Version Downgrade (Fase G, SECURE TOOL LIFECYCLE)

* **Estado**: RESUELTO PARA BASELINE
* **Fecha**: 2026-08-17
* **Decisores**: Platform/SRE, Cyber-Range (siguiendo el criterio de ADR-017: construir solo lo real y verificable, contrato por contrato cuando una fase lo necesite de verdad)
* **Historia relacionada**: identificado en `architecture/v0.6.25-gap-matrix.md` §15-16

## Contexto

El prompt maestro (sección "SECURE TOOL LIFECYCLE", ADR-029 en su propia
numeración) exige un `ToolManifest v1` con `side_effect_class` (5
categorías exactas) y `rate_limit`, además de detección activa de 7
clases de ataque: Tool Poisoning, Tool Shadowing, Version Downgrade,
Schema Mutation, Description Mutation, Capability Escalation, Token
Passthrough.

El gap matrix confirmó que `tool_catalog/schemas/tool-definition.schema.json`
(`argos-cyber-tools`) ya cubre bien MCP security (`mcp_gateway.Gateway.
authorize()`, flujo Identity→Capability→Schema→OPA→Allowlist real,
Token Passthrough y Schema/Description Mutation ya detectados vía hash
de `tool_catalog/signatures/`) pero le faltaban explícitamente
`side_effect_class`/`rate_limit`, y ni Tool Shadowing ni Version
Downgrade tenían ningún mecanismo de detección.

**A diferencia de los ~32 contratos v1 nuevos de la sección 5 del
prompt** (diferidos en ADR-017, conjunto cerrado de 10 contratos
cross-repo en `argos-contracts-scenarios`), `tool-definition.schema.json`
es un schema interno de `argos-cyber-tools` — nunca cruza como mensaje
entre repos, no toca el conjunto cerrado. Extenderlo no reabre esa
tensión y no requiere el proceso de evaluación contrato-por-contrato que
ADR-017 reserva para los 10 contratos cerrados.

## Decisión

1. `side_effect_class` (enum `READ_ONLY | DRY_RUN | REVERSIBLE_WRITE |
   IRREVERSIBLE | DESTRUCTIVE`) y `rate_limit.calls_per_minute` pasan a
   ser campos obligatorios de `tool-definition.schema.json`. Los 5 tools
   reales se clasifican por su acción `execute` (peor caso, mismo
   criterio que `risk_level`): las 2 herramientas de solo lectura son
   `READ_ONLY`; las 3 con `execute` (`isolate_kubernetes_workload`,
   `scale_to_zero`, `increase_monitoring`) son `REVERSIBLE_WRITE` —
   ninguna es hoy `IRREVERSIBLE`/`DESTRUCTIVE`, consistente con
   `rollback_supported: true` en las tres.
2. `mcp_gateway.Gateway.authorize()` deniega incondicionalmente
   cualquier tool `IRREVERSIBLE`/`DESTRUCTIVE`, sin importar
   scope/target/approval — el catálogo puede declarar uno (el schema no
   lo prohíbe, son categorías válidas), pero nunca se autoriza en el P0
   actual.
3. `mcp_gateway.RateLimiter` (ventana deslizante de 60s, en memoria)
   cuenta TODO intento de llamada — autorizado o no — contra
   `rate_limit.calls_per_minute` del tool.
4. `tool_catalog/version_ledger.py`: ledger append-only (versión más
   alta vista por `tool_id`) que detecta Version Downgrade incluso
   cuando el hash de integridad de `signatures/` es válido (el caso que
   ese mecanismo NO cubre: sustituir el archivo por una versión antigua
   Y regenerar el manifiesto). Explícitamente NO se invoca desde
   `load_catalog()` por defecto — es una comprobación de CI/despliegue
   (`python -m tool_catalog.version_ledger check --ledger <path>`), no
   un efecto colateral silencioso de cargar el catálogo en cada test.

## Consecuencia

* Cambio de schema con campos nuevos `required`: toda definición futura
  de tool debe declarar `side_effect_class`/`rate_limit` — los 5
  archivos YAML existentes y `catalog.manifest.json` (regenerado) ya se
  actualizaron en el mismo cambio.
* **Huecos explícitamente NO resueltos por esta ADR**: Tool Poisoning ya
  lo cubre `signatures/` (hash); Tool Shadowing (un tool nuevo que
  suplanta la identidad de uno existente) y Capability Escalation (un
  tool que excede en runtime el `capabilities` que declaró) siguen sin
  ningún mecanismo real — no se construyen aquí para no fabricar
  detección donde no hay todavía ni un campo `capabilities` declarado
  formalmente ni un caso de uso real que lo ejercite.
* No se despliega Shuffle real ni existe Agentic RAG/LangGraph — esta
  ADR no depende de ninguno de los dos y no los destraba.

## Impacto sobre AC01-AC14

No aplica directamente — endurece MCP security (§15-16 del prompt), que
sustenta indirectamente AC09/AC10 (segregación aprobar/ejecutar), sin
introducir un AC nuevo.

## Fuentes

`argos-cyber-tools/tool_catalog/schemas/tool-definition.schema.json`,
`argos-cyber-tools/mcp_gateway/__init__.py`,
`argos-cyber-tools/tool_catalog/version_ledger.py`,
`architecture/v0.6.25-gap-matrix.md` §15-16, `adr/ADR-003-mcp-security.md`,
`adr/ADR-017-incremental-v0625-roadmap-adoption.md`.
