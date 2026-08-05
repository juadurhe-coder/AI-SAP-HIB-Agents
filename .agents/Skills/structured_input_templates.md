# SKILL: STRUCTURED INPUT TEMPLATES

## CONTEXT
Plantillas que definen los campos obligatorios y opcionales para cada tipo de solicitud. El Intake Analyst las utiliza para evaluar la completitud del input del usuario y generar preguntas inteligentes.

---

## TEMPLATE: FUNCTIONAL SPECIFICATION (FS)

### Campos Obligatorios
| # | Campo | Descripción | Ejemplo |
|---|-------|-------------|---------|
| 1 | Módulo SAP | Módulos S/4HANA impactados | MM, SD, FI-CO |
| 2 | Proceso Estándar de Referencia | Best Practice o proceso estándar SAP más cercano | Stock Transfer Order (STO) |
| 3 | Problema / Necesidad de Negocio | Descripción clara del "Por Qué" | "No se puede reservar stock por cliente" |
| 4 | Roles de Usuario | Quién usará la solución | Planificador de materiales, Comercial |
| 5 | Datos Maestros Impactados | Maestros que se crean/modifican | Material, Cliente, Info Record |
| 6 | Criterios de Aceptación | Condiciones de "Done" medibles | "El stock reservado no aparece como disponible para otros" |

### Campos Opcionales (Alta Prioridad)
| # | Campo | Descripción |
|---|-------|-------------|
| 7 | Integraciones | Sistemas o módulos con los que interactúa |
| 8 | Volumen Estimado | Transacciones/día, usuarios concurrentes |
| 9 | Restricciones Técnicas | Cloud-only, on-premise, BTP side-by-side |
| 10 | Documentos de Referencia | Actas de reunión, emails, specs previas |

### Campos Opcionales (Baja Prioridad)
| # | Campo | Descripción |
|---|-------|-------------|
| 11 | Prioridad | Alta / Media / Baja |
| 12 | Timeline | Fecha objetivo de entrega |
| 13 | Presupuesto | Horas/días estimados disponibles |

---

## TEMPLATE: PROPOSAL (PRE-VENTA)

### Campos Obligatorios
| # | Campo | Descripción | Ejemplo |
|---|-------|-------------|---------|
| 1 | Cliente | Nombre y sector del cliente | "ACME Corp - Industria Química" |
| 2 | Problema de Negocio | Pain point principal del cliente | "Pricing manual consume 3 días/mes" |
| 3 | Ámbito Modular | Módulos SAP en scope | SD Pricing, MM Purchasing |
| 4 | Tipo de Solución | On-stack / Side-by-side / Híbrido | "Side-by-side BTP + Fiori" |
| 5 | Estimación de Esfuerzo | Rango de horas/días | "80-120 horas consultor" |
| 6 | Número de Ticket | Referencia en Jira o ServiceNow | "HIBERUS-2026-001" |

### Campos Opcionales
| # | Campo | Descripción |
|---|-------|-------------|
| 6 | Competidores/Alternativas | Qué ha evaluado el cliente previamente |
| 7 | Landscape Técnico | Versión S/4HANA, BTP disponible |
| 8 | Stakeholders | Decisores clave en el cliente |
| 9 | Casos de Éxito | Referencias internas similares |

---

## TEMPLATE: GAP ANALYSIS

### Campos Obligatorios
| # | Campo | Descripción | Ejemplo |
|---|-------|-------------|---------|
| 1 | Proceso AS-IS | Flujo actual del cliente | "Pricing calculado en Excel desde BW" |
| 2 | Requisito TO-BE | Objetivo deseado | "Pricing calculado automáticamente en S/4HANA" |
| 3 | Solución Estándar Evaluada | T-Code / App / Best Practice evaluada | "VK11 + Condition Records" |
| 4 | Razón del Gap | Por qué el estándar no cubre el requisito | "Access sequence no soporta aging de máquinas" |
| 5 | Impacto de Negocio | Consecuencia de no resolver | "Error de margen del 3-5% por distorsión COGS" |

### Campos Opcionales
| # | Campo | Descripción |
|---|-------|-------------|
| 6 | Clasificación RICEFW | Report / Interface / Conversion / Enhancement / Form / Workflow |
| 7 | Complejidad Estimada | Baja / Media / Alta / Muy Alta |
| 8 | Dependencias | Otros gaps o desarrollos relacionados |

---

## TEMPLATE: CHANGE REQUEST (CR)

### Campos Obligatorios
| # | Campo | Descripción | Ejemplo |
|---|-------|-------------|---------|
| 1 | Referencia Original | FS o desarrollo que se modifica | "FS-MM-001: Reserva de Stock" |
| 2 | Cambio Solicitado | Descripción precisa del cambio | "Añadir campo de fecha de expiración" |
| 3 | Justificación | Razón de negocio para el cambio | "Regulación nueva exige trazabilidad" |
| 4 | Impacto Estimado | Áreas afectadas por el cambio | "UI Fiori + CDS View + Validación" |

### Campos Opcionales
| # | Campo | Descripción |
|---|-------|-------------|
| 5 | Urgencia | Bloqueante / Alta / Normal |
| 6 | Aprobador | Quién autoriza el cambio |
