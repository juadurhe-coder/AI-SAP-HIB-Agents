# Plan de Mejora y Colaboración en Procesos IT (SAP Funcional & Técnico)

Este documento sirve como bitácora y repositorio de ideas para estructurar, refinar y automatizar los procesos de trabajo del equipo utilizando Git y agentes de IA (Antigravity).

---

## 📌 1. Estrategia de Control de Versiones (Git) para el Equipo

Para evitar colisiones ("machacarse" el código) y mantener el orden del repositorio:

* **Modelo Híbrido Funcional-Técnico**:
  * **Funcionales (SAP Consultants)**: Trabajan principalmente sobre especificaciones funcionales en Markdown, diagramas de procesos y mockups (ej. carpetas `Standards/` o `Projects/IC Pricing/`).
  * **Técnicos (ABAP/Developers)**: Desarrollan código, integraciones y lógica de negocio.
* **Flujo de Ramas Limpio**:
  * Evitaremos subir código directamente a la rama principal (`main` o `develop`).
  * Se utilizarán ramas de ciclo de vida corto con nomenclatura clara:
    * `feature/funcional-[descripción_corta]` para tareas de análisis, mockups y flujos SAP.
    * `feature/tecnico-[descripción_corta]` para desarrollos ABAP, configuraciones o scripts.
  * Duración máxima recomendada de una rama: **3 días** antes de su fusión.
* **Proceso de Integración (Pull Requests)**:
  * Antes de fusionar cambios en `develop`/`main`, se creará un Pull Request en GitHub.
  * Al menos un compañero (o el propio agente de IA haciendo revisión de código/diseño) revisará el cambio para asegurar alineación.

---

## 🤖 2. Configuración Compartida de Agentes (Antigravity)

Queremos que todo el equipo trabaje con las mismas directrices y herramientas de automatización.

* **Sincronización mediante Git**:
  * La carpeta [`.agents/`](.agents/) y todos sus subdirectorios se incluyen activamente en el repositorio.
  * Al hacer un `git pull`, cualquier compañero obtendrá de forma automática los nuevos flujos de trabajo (workflows) y estándares actualizados.
* **Estándares del Equipo**:
  * Almacenados en la ruta [`.agents/Standards/`](.agents/Standards/) (por ejemplo, el actual [sap_activate_flow.md](.agents/Standards/sap_activate_flow.md)).
  * Los agentes utilizarán estos documentos como "reglas de negocio" al generar código o diseñar flujos.

---

## 💡 3. Banco de Ideas de Mejora (Roadmap)

Registramos aquí las ideas de automatización y optimización de procesos que iremos desarrollando:

| ID | Idea / Iniciativa | Estado | Descripción |
| :--- | :--- | :--- | :--- |
| **001** | Git Flow Simplificado | ⏳ *Propuesto* | Definir el flujo exacto de ramas y subir las primeras plantillas de documentación. |
| **002** | Plantilla Unificada de Especificación Funcional | ⏳ *Propuesto* | Crear un formato Markdown estándar para que los funcionales definan la lógica y los técnicos la implementen. |
| **003** | Integración del Agente con Herramienta Interna de Ticketing | ⏳ *Propuesto* | Usar la nueva herramienta de ticketing de la empresa para la gestión de proyectos y mejoras. Un agente de IA supervisará el estado, preguntando a los consultores y actualizando automáticamente los hitos si detecta falta de actualización manual. |
| **004** | Generación Automática de Dailies y Minutas | ⏳ *Propuesto* | Un agente analiza las modificaciones del día en Git, los commits y las notas de los consultores para redactar de forma automática el resumen diario (Daily Standup) o minutas de avances para el Delivery Manager. |
| **005** | Alertas Proactivas de Desviación y Bloqueos | ⏳ *Propuesto* | Agente que analiza la fecha límite de los tickets en la herramienta de ticketing y, si detecta falta de actividad o un bloqueo técnico reportado en las notas, avisa proactivamente al consultor o al líder del proyecto. |
| **006** | Transcripción y Procesamiento de Reuniones | ⏳ *Propuesto* | Grabar y transcribir automáticamente reuniones (en español o inglés) para que el agente procese el texto y extraiga tareas, actualice estados en la herramienta de ticketing y ponga al día las minutas y especificaciones funcionales del repositorio. |
| **007** | Automatización de Despliegues de Mockups | ⏳ *Propuesto* | Crear un script/workflow para previsualizar de forma ágil los archivos HTML estáticos en un entorno local compartido. |
| **008** | Gobernanza de Conflictos en Git | ⏳ *Propuesto* | Documentar cómo solucionar conflictos de merge comunes en archivos compartidos de configuración. |

---

## 📈 4. Historial de Decisiones y Acuerdos

*(Esta sección se irá completando a medida que el equipo apruebe y adopte nuevas formas de trabajar).*

* **2026-06-17**: Creación de la iniciativa para sincronizar el trabajo entre consultores funcionales y técnicos de SAP compartiendo la carpeta `.agents` y estandarizando ramas en Git.
