# Política de licencias de dependencias open source

Ver ADR-013 (decisión completa) y ADR-007 (fuentes CTI). Resumen operativo:

## Condición de admisión

Toda dependencia nueva, en cualquiera de los 7 repositorios, debe declarar:

1. Código y licencia verificables (licencia OSI-aprobada o equivalente compatible con self-hosting).
2. Capacidad de self-hosting — sin dependencia obligatoria de un SaaS de terceros.
3. SBOM generado (CycloneDX o SPDX) y referenciado por digest.
4. Scanner de vulnerabilidades activo (p. ej. Trivy) y sin CVEs críticos sin excepción.
5. Owner y backup asignados (persona o rol, ver `../raci/raci.md`).
6. Alternativa de sustitución identificada — ninguna dependencia comercial puede ser crítica para la aceptación.

## Explícitamente excluido

* **IBM X-Force** — excluido del diseño (ADR-007).
* Cualquier servicio que exija egress a Internet durante la ejecución de aceptación (AC01-AC14 se ejecutan offline).
* Cualquier dependencia sin sustituto autogestionable identificado.

## Proceso

1. La dependencia se propone como parte de una historia `ARG-###`, cumpliendo el checklist de Definition of Ready (`../../.github/ISSUE_TEMPLATE/story.yaml`).
2. QA/Security Observer revisa licencia y SBOM antes de que la historia se considere Ready.
3. Si la dependencia no cumple el checklist pero es necesaria temporalmente, se tramita como excepción con caducidad (`../exceptions/`).
