# SKILL: COMMUNICATION PROTOCOLS (HUMAN-AGENT INTERACTION)

## CONTEXT
Reglas formales que gobiernan la comunicación entre el usuario humano y cualquier agente del ecosistema. Todos los agentes DEBEN consultar y aplicar estos protocolos.

---

## 1. REGLA DE PARADA (STOP RULE)

### Cuándo parar y preguntar
Un agente DEBE detenerse y solicitar información cuando:
- Faltan >30% de los campos obligatorios de la plantilla correspondiente (`Skills/structured_input_templates.md`)
- El agente necesita hacer más de 2 asunciones de alto impacto (que afectan la arquitectura o el alcance)
- Existe ambigüedad en un requisito que podría llevar a 2+ diseños fundamentalmente distintos

### Cuándo es aceptable asumir
Un agente PUEDE asumir cuando:
- La información es derivable del contexto (e.g., módulo SAP se infiere del proceso descrito)
- La asunción es de bajo impacto (no cambia la arquitectura)
- Se marca explícitamente como ⚠️ ASUMIDO en el output

---

## 2. FORMATO DE PREGUNTAS

### Reglas
1. Numeradas: Siempre preguntas numeradas (1, 2, 3...)
2. Con sugerencia: Cada pregunta incluye un valor sugerido por defecto
3. Máximo 5 por ronda: No saturar al usuario
4. Priorizadas: Ordenadas por impacto en el resultado final
5. Agrupadas por tema: Si hay preguntas de distintos dominios, agrupar con headers

### Formato Estándar
```
### Preguntas Pendientes (Ronda X/3)

Contexto Funcional:
1. [Pregunta sobre proceso] (Sugerencia: [valor])
2. [Pregunta sobre datos] (Sugerencia: [valor])

Contexto Técnico:
3. [Pregunta sobre integración] (Sugerencia: [valor])
```

---

## 3. MARCADO DE ASUNCIONES EN OUTPUTS

### Convención de Iconos
| Icono | Significado | Acción Requerida |
|-------|-------------|------------------|
| ✅ | Confirmado por el usuario | Ninguna |
| ⚠️ | Asumido por el agente | Revisión recomendada |
| ❓ | Pendiente — información faltante | Respuesta requerida |

### Regla de Aplicación
- Todo output de especificación (FS, borrador, proposal) DEBE usar estos iconos
- Al final de cada documento, incluir un Resumen de Asunciones listando todas las ⚠️
- Si un borrador tiene >5 asunciones ⚠️ de alto impacto, añadir un banner de advertencia al inicio

---

## 4. RESUMEN EJECUTIVO (TL;DR)

### Regla
Todo output dirigido al usuario DEBE comenzar con un bloque de resumen:

```markdown
> TL;DR: [Máximo 3 líneas que resumen: qué se hizo, qué decisiones se tomaron, y qué queda pendiente]
```

### Cuándo aplicar
- Especificaciones funcionales (FS)
- Borradores-esqueleto
- Respuestas de cuestionario
- Revisiones de Quality Gate
- Propuestas de solución

---

## 5. FEEDBACK LOOPS

### Regla de Confirmación Explícita
Cuando un agente devuelve un borrador o especificación, DEBE incluir al final:

```markdown
---
### Próximos Pasos
- [ ] Apruebo el borrador tal cual → Escalar a [Agente siguiente]
- [ ] Necesito corregir secciones marcadas ⚠️
- [ ] Faltan datos — necesito responder las preguntas ❓
```

### Regla de No-Silencio
Si el usuario no ha respondido a preguntas pendientes, el agente NO debe:
- Avanzar asumiendo silencio como aprobación
- Generar outputs finales con secciones ❓ sin resolver

---

## 6. ESCALAMIENTO ENTRE AGENTES

### Protocolo de Handoff
Cuando un agente escala trabajo a otro agente, DEBE incluir:
1. Resumen de contexto: Qué se pidió y qué se decidió
2. Estado de completitud: Tabla con campos ✅/⚠️/❓
3. Asunciones activas: Lista de lo que se asumió y no fue confirmado
4. Instrucción clara: Qué se espera que haga el siguiente agente
