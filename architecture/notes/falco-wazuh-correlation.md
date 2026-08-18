# Correlación Falco → Wazuh → SecurityEvent/Incident

**Origen**: correo real del equipo XDR/Wazuh (Georgi, 2026-08-18) explicando qué capacidades de correlación/priorización/contextualización ofrece Wazuh como componente central del stack XDR sobre el Open Sovereign Cloud (OSC). No introduce arquitectura nueva — aterriza a nivel de implementación una parte que hasta ahora solo estaba descrita a nivel de flujo (`data-flows/end-to-end-flow.md`, paso 1: "Los sensores publican `SecurityEvent v1`... el normalizador valida schema, deduplica..."). Mapeado a `ARG-015` (ingesta), `ARG-016` (correlación/Incident) y `ARG-017` (triaje/ATT&CK) — no se abre una ARG nueva.

## El problema real que describe el correo

Falco dispara una alerta por cada subproceso Linux de una misma actividad de ataque. Sin agregación, esto produce N alertas Wazuh para una sola actividad real, y el mapeo ingenuo:

```text
1 alerta Falco = 1 alerta Wazuh = 1 Incident ARGOS
```

convertiría un solo ataque en decenas de `Incident` independientes. Wazuh ofrece varios mecanismos reales para evitar esto ANTES de que el evento llegue al `correlator` de ARGOS:

* **Severity mapping**: `falco-rules.xml` mapea la `priority` de cada regla Falco a un nivel de severidad Wazuh; `overwrite` permite rebajar la prioridad de eventos conocidos como falsos positivos.
* **Grouping temático** (`<group>`, `if_matched_group`/`if_group`) y **por tiempo** (`frequency`+`timeframe`+`if_matched_sid`) y **por actividad** (`same_source_ip`, `same_user`, etc.).
* **Jerarquía** (`if_sid`): relación padre/hijo entre reglas, con ventana temporal opcional.
* **Tags MITRE ATT&CK** (`rule.mitre.id`) para filtrar el forwarding por táctica/nivel.
* **CDB lookups**: comparación contra listas de IP reputation, hashes/IoC.

## Principio adoptado

No tratar cada evento Wazuh/Falco como un hecho aislado ni fusionar por defecto. `SecurityEvent v1` (`argos-contracts-scenarios/schemas/security-event/v1.schema.json`) gana campos opcionales (2026-08-18, DERIVADO — no proceden del docx v0.5) para conservar la agregación de primer nivel de Wazuh SIN perder procedencia:

```text
Raw Falco event (source_priority, subprocess, rule, native payload)
        │
        ▼
     Wazuh (severity mapping, group, correlation, MITRE, CDB)
        │
        ▼
   SecurityEvent v1
        ├── source_priority           (Falco, conservado tal cual)
        ├── detection.{wazuh_rule_id, wazuh_level, groups,
        │              parent_rule_id, mitre_ids}
        ├── correlation.{correlation_key, aggregation_method,
        │                timeframe_seconds, occurrence_count,
        │                first_seen, last_seen, related_event_refs}
        ├── enrichment.{cdb_matches, threat_intel_refs}
        └── provenance.{falco_rule_version, wazuh_ruleset_version,
                         custom_rule_version, configuration_hash}
        │
        ▼
   correlator.dedupe_by_correlation_key()   [argos-core/services/correlator]
        │  colapsa eventos con el MISMO correlation_key en un único
        │  evento representativo (occurrence_count, related_event_refs) —
        │  nunca fusiona correlation_key distintos, nunca inventa uno.
        ▼
   correlator.group_by_asset_and_window()
        │
        ▼
      Incident v1
```

`source_priority` (Falco) y `severity_native`/`severity_normalized` (ya existentes, del lado Wazuh) se conservan AMBOS — no se sustituye uno por otro, por la misma razón que el proyecto nunca colapsa hecho e inferencia en un solo campo.

## Qué NO se hace todavía

* `correlation_key` es un **hecho suministrado por quien produce/normaliza el evento** (típicamente el adaptador Wazuh) — este contrato y `dedupe_by_correlation_key` no prescriben ni inventan la regla de qué cuenta como "la misma actividad"; eso vive en la configuración real de Wazuh (`frequency`/`timeframe`/`same_source_ip`/etc.), que todavía no tenemos.
* `rule.overwrite` (rebajar severidad) debe quedar versionado, revisado y trazable — pendiente de que exista una configuración real que gobernar; no se implementa un mecanismo de override en ARGOS por adelantado.
* El *alert forwarding* filtrado por MITRE+nivel es una decisión de qué se reenvía a consumidores externos, no de qué se conserva — el evento completo debe seguir disponible en ARGOS aunque el forwarding filtre. No se ha implementado forwarding todavía (no existe consumidor externo real).

## Pendiente real de Georgi antes de `VALIDATED_IN_TARGET`

Este documento describe capacidad y diseño, no configuración real de OSC. Sigue vigente la distinción ya aplicada en el proyecto:

```text
Wazuh supports capability
        ≠
Capability configured in OSC
        ≠
Capability tested by ARGOS
        ≠
Capability validated in target
```

Pendiente de recibir para avanzar de "descrito" a "probado con datos reales": `falco-rules.xml` real de OSC, tabla Falco priority → Wazuh level actualmente configurada, custom rules/overrides activos, ejemplos raw Falco + su Wazuh alert correspondiente (idealmente con un caso de subproceso múltiple real), grupos/mapeo MITRE usados para forwarding, y las CDB lists en uso.

## Implementado ya (2026-08-18)

* `SecurityEvent v1`: campos opcionales `source_priority`/`detection`/`correlation`/`enrichment`/`provenance` (`argos-contracts-scenarios`), fixture de ejemplo `fixtures/smoke/security-event/falco-wazuh-correlated-001.json`.
* `argos-core/services/correlator.dedupe_by_correlation_key`: colapsa eventos que comparten `correlation_key` antes de `group_by_asset_and_window`, preservando `related_event_refs`. Probado con el caso real del correo (50 eventos Falco de subproceso → 1 evento agregado → 1 `Incident`) y con el caso contrario (dos ataques distintos con `correlation_key` distinta nunca se fusionan), `tests/unit/test_correlator.py`.
