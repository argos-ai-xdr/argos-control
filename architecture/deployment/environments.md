# Entornos de despliegue

Tres entornos, todos desplegados de forma declarativa desde `argos-platform` (OpenTofu + Argo CD), sin comandos manuales contra el clúster (ADR-015):

| Entorno | Propósito | Notas |
| --- | --- | --- |
| `local` | Desarrollo individual y CI ligera; equivalente reducido de `laboratory` | Debe poder reconstruirse desde cero con `make bootstrap` / pipeline de `argos-platform` |
| `laboratory` | Cyber-range y validación de escenarios (ARGOS-CYB-01), reseteable | Namespace `argos-cyber-range` aislado, egress denegado salvo repositorios y endpoints sinkhole aprobados (kill switch, ARG-003) |
| `osc` | Entorno objetivo del cliente (Órgano/Centro de referencia del documento maestro) | Sujeto a DEP-02 (OSC, registry, DNS, certificados y namespaces, fecha límite: semana 1 de S1). Fallback si no está listo a tiempo: Kubernetes local equivalente y manifests portables — la demo sigue siendo local. |

## Regla de fallback (DEP-02)

Si `osc` no está disponible a tiempo, el `laboratory`/`local` equivalente sostiene toda la cadena de aceptación (AC01-AC14); la integración con OSC se desplaza sin bloquear la demo. Cualquier capacidad que solo pueda demostrarse en `osc` debe declararse explícitamente `PLANNED`, nunca `REAL`, en `argos-validation` hasta que se ejecute allí.

## Reset y recuperación

* Reset del cyber-range: reproducible, documentado en `argos-platform/cyber-range/reset/`.
* Kill switch: corta ejecución y egress no autorizado; documentado en `argos-platform/cyber-range/kill-switch/`.
* Backup/restore: probado con evidencia (ver ARG-025), namespace/versión de aplicación con rollback verificado (ver `governance/gates/gates.md`, G6-G7).
