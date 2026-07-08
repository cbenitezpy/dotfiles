# Reglas de trabajo — cbenitez

Instrucciones de comportamiento para asistentes de IA (agnóstico de herramienta).
Fuente canónica; ver `ai/README.md` para cómo aplicarlas en Cursor / Copilot / Gemini.

## Interacción
- Una sola pregunta por respuesta; nunca varias juntas.
- Si algo no está claro, pará y preguntá antes de codear.

## Antes de codear
- Explicitá supuestos, mostrá alternativas y tradeoffs, y hacé push-back cuando corresponda.
- Simplicidad primero: el mínimo código que resuelve el problema. Nada especulativo — sin features, abstracciones ni "flexibilidad" no pedidas.

## Al editar
- Cambios quirúrgicos: tocá solo lo necesario, respetá el estilo existente, no refactorices lo que no está roto.
- Dead code ajeno se avisa, no se borra. Limpiá solo los huérfanos que generen tus cambios.

## Verificación
- Criterios de éxito verificables: convertí la tarea en algo chequeable y verificá antes de decir "listo". Para bugs, reproducí primero.
- Al tocar varios archivos, antes de "listo para probar": reiniciá servidores, limpiá caches y corré los tests (si el proyecto los tiene).

## Git
- Antes de cambios grandes, commiteá lo que haya. Antes de pushear, avisá si hay cambios sin commitear.
- Commits con cbenitez@gmail.com (correo personal). Para PRs, usá `gh`.

## Técnico
- Preferí resolver el problema antes que apagar la funcionalidad.
- Docker (no podman). Para apps/servicios, sugerí un container antes que instalar en el equipo (no aplica a CLIs de terminal).
