# 🧠 MEMORIA PERSISTENTE DE PROYECTO (PROJECT LONG-TERM MEMORY)

> **MANDATORY FOR ALL AGENTS:** Este archivo es la memoria a largo plazo del proyecto. Los agentes deben leerlo AL INICIO de cada nueva conversación/sesión para no perder el contexto de negocio, inputs clave y decisiones tomadas. Debe ser actualizado cada vez que se valide o cambie una regla de negocio.

## 📌 DATOS GENERALES
- **Ticket ID:** `[TICKET-ID]`
- **Proyecto:** [Nombre del proyecto]
- **Cliente:** [Nombre del cliente y entidades/sociedades involucradas]
- **Módulos SAP en Scope:** [MM, SD, FI-CO, PP, PM, etc.]
- **Versión S/4HANA:** [Ej. S/4HANA 2022, 2023, Cloud]
- **Estado actual:** [Fase SAP Activate: Prepare | Explore | Realize | Deploy | Run]
- **Idioma de los Entregables:** [ES | EN | Ambos]

## 💼 INPUTS Y REGLAS DE NEGOCIO CRÍTICAS

### 1. [Área de Negocio 1 — Ej: Aduanas y Comercio Exterior]
<!-- Ejemplo: Régimen IPR obligatorio, estrategia GTS, restricciones de exportación -->
- [Regla 1]
- [Regla 2]

### 2. [Área de Negocio 2 — Ej: Financiero y Fiscal]
<!-- Ejemplo: Tratamiento IVA intercompany, Transfer Pricing, neutralidad contable -->
- [Regla 1]
- [Regla 2]

### 3. [Área de Negocio 3 — Ej: Logística / Producción / Integración]
<!-- Ejemplo: Arquitectura técnica, flujos de materiales, restricciones de inventario -->
- [Regla 1]
- [Regla 2]

> 💡 **Nota:** Añadir tantas secciones como áreas de negocio impactadas existan. Las secciones deben ser específicas al dominio del proyecto, no genéricas.

## ⚙️ DECISIONES TÉCNICAS Y DE ARQUITECTURA
<!-- Decisiones de diseño que condicionan la implementación -->
- [Decisión 1 — Ej: Uso de material sombra UNBW para neutralidad contable]
- [Decisión 2 — Ej: Tabla Z como Control Tower para trazabilidad]
- [Decisión 3 — Ej: Sin SAP GTS por bajo volumen de operaciones]

## 📑 ARCHIVOS ACTIVOS Y ENTREGABLES
<!-- Lista actualizada de los entregables vigentes con enlaces relativos -->
| Entregable | Versión | Ruta |
|------------|---------|------|
| Propuesta (MD) | vX.Y | `[ruta relativa al archivo]` |
| Propuesta (Word) | vX.Y | `[ruta relativa al archivo]` |
| FS Draft (MD) | vX.Y | `[ruta relativa al archivo]` |
| Gap Analysis | vX.Y | `[ruta relativa al archivo]` |

## 📅 HISTORIAL DE DECISIONES CLAVE
<!-- Registro cronológico de las decisiones estratégicas validadas por el usuario -->
| Fecha | Decisión | Validado por |
|-------|----------|-------------|
| YYYY-MM-DD | [Descripción de la decisión] | [Usuario / Cliente] |

## ❓ PREGUNTAS ABIERTAS / PENDIENTES DE CONFIRMAR
<!-- Items que aún no han sido validados por el usuario o el cliente -->
- ⚠️ [Pregunta pendiente 1]
- ⚠️ [Pregunta pendiente 2]
