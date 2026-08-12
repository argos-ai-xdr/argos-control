# Excepciones

Toda excepción a una regla, política o gate se solicita con el issue template `exception.yaml` (`.github/ISSUE_TEMPLATE/exception.yaml`). Reglas:

* Caducidad obligatoria — no existen excepciones indefinidas.
* El aprobador debe ser un rol distinto al solicitante y al ejecutor (segregación de funciones, `../policies/segregation-of-duties.md`).
* Ninguna excepción puede cubrir: acciones inseguras, ejecución sin aprobación, CVE inventadas, violación de allowlist, fallo de rollback o fuga de datos (regla de decisión de AC01-AC14, sin waiver posible).
* Toda excepción que afecte a un control crítico se escala al Security & Change Board semanal.

Una vez aprobada, registrar la excepción en `log.yaml` de esta carpeta (crear el archivo con la primera excepción real; no se siembra con datos ficticios).
