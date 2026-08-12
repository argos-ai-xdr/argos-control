# Sprints S1-S8

Fuente: documento maestro v0.5, sección 7. Horizonte: 01 sep - 31 dic 2026, ocho sprints de 14 días naturales + una ventana de contingencia (22-31 dic).

Fuente del calendario: Resolución de 17 de octubre de 2025 de la Dirección General de Trabajo (BOE-A-2025-21667). Es una hipótesis de propuesta, no sustituye el calendario laboral de cada centro — los festivos autonómicos/locales, vacaciones y guardias se cargan en S1.

| Sprint | Fechas | P0 (SP) | Objetivo | Gate |
| --- | --- | --- | --- | --- |
| [S1](S1.md) | 01-14 sep | 21 | Scope Gate | G0 |
| [S2](S2.md) | 15-28 sep | 21 | Data & Contract Gate | G1 |
| [S3](S3.md) | 29 sep-12 oct | 21 | C-06 | G2 |
| [S4](S4.md) | 13-26 oct | 24 | C-07 | G3 |
| [S5](S5.md) | 27 oct-09 nov | 24 | C-08 detección | G4 |
| [S6](S6.md) | 10-23 nov | 24 | HITL Response | G5 |
| [S7](S7.md) | 24 nov-07 dic | 29 | Release Candidate | G6 |
| [S8](S8.md) | 08-21 dic | 16 | Acceptance Gate | G7 |

Total P0: 180 SP. P1 (31 SP) solo entra por la regla de pull (ver `../../governance/gates/gates.md`).

## Dotación y escenarios de capacidad

Baseline recomendada: **7,5 FTE**, forecast 168-200 SP en 8 sprints.

| Escenario | Dotación | Forecast | Alcance defendible |
| --- | --- | --- | --- |
| Mínimo | 5,0 FTE | 112-144 SP | C-06 + detección + recomendación/dry-run; integraciones externas emuladas |
| Baseline recomendado | 7,5 FTE | 168-200 SP | P0 completo si S1-S2 confirman ≥ 22,5 SP/sprint de media |
| Reforzado | 9,0 FTE | 216-248 SP | P0 + P1 seleccionado; no aumenta WIP ni elimina gates |

Los story points no se convierten a horas ni se comparan entre equipos: S1 y S2 calibran throughput, cycle time, defectos y capacidad no planificada.
