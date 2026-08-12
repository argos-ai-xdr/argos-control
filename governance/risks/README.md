# Risk register

`risk-register.yaml` se siembra con las 10 dependencias críticas (DEP-01..10) del documento maestro v0.5. No es una lista cerrada: todo riesgo nuevo se abre con el issue template `risk.yaml` y, una vez ratificado en el Security & Change Board semanal, se añade aquí con `id`, `deadline`, `fallback` e `impact_if_unmitigated`.

Un riesgo `on_critical_path: true` bloquea directamente la cadena `ARG-001/003/004 -> ARG-015/016/017 -> ARG-019/020/021 -> ARG-023 -> ARG-027/028`; su seguimiento es semanal obligatorio, no solo por excepción.
