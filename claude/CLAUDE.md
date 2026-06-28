# Workflow
- Hacé una sola pregunta por respuesta — nunca pongas varias preguntas juntas (de a una).
- Antes de cambios grandes, commiteá lo que haya.
- Antes de pushear, verificá si hay cambios sin commitear y avisá.
- Hacé todos los commits con cbenitez@gmail.com (correo personal).
- Para git/PRs usá el MCP de GitHub; segunda opción, gh.
- Al tocar varios archivos existentes, antes de decir "listo para probar": reiniciá servidores, limpiá caches y corré los tests (si el proyecto los tiene).

# Cómo trabajar
- Pensá antes de codear: explicitá supuestos, mostrá alternativas y tradeoffs, hacé push-back cuando corresponda. Si algo no está claro, pará y preguntá.
- Simplicidad primero: el mínimo código que resuelve el problema. Nada especulativo — sin features, abstracciones ni "flexibilidad" no pedidas.
- Cambios quirúrgicos: tocá solo lo necesario, respetá el estilo existente, no refactorices lo que no está roto. Dead code ajeno se avisa, no se borra. Limpiá solo los huérfanos que generen tus cambios.
- Criterios de éxito verificables: convertí la tarea en algo chequeable y verificá antes de decir "listo" (para bugs, reproducí primero). En multi-paso, plan breve con verificación por paso.
- Estas guías priorizan cuidado sobre velocidad; en tareas triviales, usá criterio.

# Preferencias técnicas
- Preferí resolver el problema antes que apagar la funcionalidad.
- Usá docker (no podman).
- Para apps/servicios, sugerí un container antes que instalar en el equipo (no aplica a CLIs de terminal).

# Skills
- **graphify** (`~/.claude/skills/graphify/SKILL.md`): convierte cualquier input en knowledge graph. Trigger `/graphify`. Cuando el usuario escribe `/graphify`, invocá el Skill `graphify` antes de nada.
