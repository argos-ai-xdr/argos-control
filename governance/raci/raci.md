# RACI operativo

Fuente: documento maestro v0.5, sección 7.6. Abreviaturas de rol:

| Sigla | Rol | FTE recomendado |
| --- | --- | --- |
| POA | Product Owner / Arquitectura | 0,5 |
| DL | Delivery Lead | 0,5 |
| PSE | Platform / GitOps / SRE | 1,0 |
| XDR | XDR / Data Engineer | 1,0 |
| CYB | Cyber-range Engineer | 1,0 |
| AIE | AI / Evaluation Engineer | 1,0 |
| SME | SOAR / MCP Engineer | 1,0 |
| UI | SmartOps / Full-stack | 0,5 |
| SOC | SOC Analyst / Approver | 0,5 |
| QSO | QA / Security Observer | 0,5 |

Baseline de dotación: **7,5 FTE**. Los roles pueden combinarse si se preserva la separación de funciones: quien genera una recomendación o ejecuta un playbook no puede autoaprobarla; QA/observador puede bloquear un gate. Cada dominio tiene un owner y un backup identificados en S1 (ver `repository.yaml` de cada repositorio).

## Matriz

| Actividad | A (Accountable) | R (Responsible) | C (Consulted) | I (Informed) |
| --- | --- | --- | --- | --- |
| Alcance, prioridad y aceptación | POA | DL | SOC, QSO, leads técnicos | Equipo/stakeholders |
| Arquitectura, ADR y contratos | POA | PSE/XDR/SME | CYB, AIE, UI, QSO | DL/SOC |
| Plataforma, supply chain y release | PSE | PSE | QSO, SME, XDR | POA/DL |
| C-06 y C-08 | XDR | XDR | CYB, AIE, SOC, QSO | POA/DL |
| C-07 y cyber-range | CYB | CYB | PSE, SME, QSO | POA/SOC |
| Recomendación, policy y SOAR | SME | AIE/SME | SOC, CYB, QSO, UI | POA/DL |
| Aprobación de remediación | SOC | SOC | QSO, POA | DL/equipo |
| Quality gate y evidence pack | QSO | AIE/QSO | Todos los owners | POA/DL/SOC |
| Demo y handover | DL | DL/UI/QSO | POA, SOC, owners | Stakeholders |

## Regla de segregación de funciones

Ningún rol puede autoaprobar una excepción de la que sea ejecutor. Ver `../policies/segregation-of-duties.md`.

## Cadencia de gobierno

| Ceremonia/control | Cadencia | Participantes | Salida obligatoria |
| --- | --- | --- | --- |
| Sprint planning | Día 1, 90 min | Equipo completo | Objetivo, P0, capacidad, DoR y riesgos |
| Daily | Diaria, 15 min | Equipo delivery | Bloqueos, WIP y necesidad de escalado |
| Sync técnico | 2/semana, 30 min | Owners/arquitectura | Contratos, integración y ADR pendientes |
| Security & Change Board | Semanal, 45 min | POA, CYB, SOC, QSO, PSE | Excepciones, cambios de policy y risk log |
| Refinement | Semanal, 60 min | POA, DL y owners | DoR de las próximas dos semanas |
