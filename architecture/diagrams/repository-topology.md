# Diagrama — topología de repositorios

Ver también `../../docs/architecture.md` (misma vista, contexto de `argos-control`) y ADR-014.

```mermaid
flowchart TD
    C["argos-control<br/>(gobierno)"]
    P["argos-platform<br/>(infra declarativa)"]
    S["argos-contracts-scenarios<br/>(contratos + fixtures)"]
    X["argos-core<br/>(lógica XDR)"]
    T["argos-cyber-tools<br/>(MCP, SOAR, sandbox)"]
    V["argos-validation<br/>(evaluación independiente)"]
    U["argos-smartops<br/>(API + UI)"]

    C -->|workflows reutilizables| P
    C -->|workflows reutilizables| V
    S -->|contratos v1| X
    S -->|contratos v1| T
    S -->|contratos v1| U
    S -->|contratos v1| V
    X -->|Incident, Recommendation| U
    T -->|ActionResult| U
    X -->|eventos, harness| V
    T -->|tool catalog, evidencia| V
    P -->|namespaces, identidad| X
    P -->|namespaces, cyber-range| T
    P -->|despliegue| U
```

Orden de construcción: `argos-control` → `argos-platform` → `argos-contracts-scenarios` → `argos-validation` → `argos-core` → `argos-cyber-tools` → `argos-smartops`.
