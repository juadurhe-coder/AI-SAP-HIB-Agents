---
name: ui5_version_upgrade
description: Planifica y ejecuta migraciones y actualizaciones de versiones de SAPUI5/OpenUI5 en aplicaciones Fiori. Identifica APIs obsoletas (deprecations), analiza nuevas características (What's New) y valida el manifest.json combinando los servidores MCP sap-docs-hosted y sap-ui5.
---

# 🚀 UI5 Version Upgrade & Migration Skill

Esta habilidad proporciona al agente **SAP Developer** un flujo guiado y automatizado para planificar, auditar y ejecutar actualizaciones de versiones de SAPUI5 u OpenUI5 en aplicaciones Fiori existentes.

---

## 🛠️ Herramientas MCP Involucradas

1. **`sap-docs-hosted` (Documentación & Diff Global)**:
   - `ui5_version_diff`: Compara dos versiones de UI5 (ej. de `1.108.0` a `1.120.0`) y extrae APIs obsoletas, sustitutos recomendados y novedades.
   - `fetch`: Obtiene la guía oficial de migración y documentación de API.
2. **`sap-ui5` (Proyecto Local & Linting)**:
   - `get_project_info`: Lee la versión actual y librerías declaradas del proyecto Fiori local.
   - `get_version_info`: Inspecciona la versión del framework UI5.
   - `run_ui5_linter`: Ejecuta `@ui5/linter` sobre el código del proyecto para detectar código incompatible.
   - `run_manifest_validation`: Valida la estructura del `webapp/manifest.json`.
   - `get_guidelines`: Obtiene directrices oficiales de desarrollo SAPUI5.
   - `get_typescript_conversion_guidelines`: Guía si el proyecto se va a migrar a TypeScript.

---

## 📋 Flujo de Trabajo (Workflow de Actualización)

### Paso 1: Identificación del Proyecto y Versiones
- Localizar la ruta del proyecto Fiori (`webapp/manifest.json`, `ui5.yaml`, `package.json`).
- Determinar versión origen (`from_version`) y versión destino (`to_version`).
- Determinar sabor de librería (`SAPUI5` para apps empresariales con `sap.f`, `sap.fe`, `sap.suite`; u `OpenUI5`).

### Paso 2: Análisis de Diferencias (Version Diff)
Ejecutar `ui5_version_diff` con los parámetros correspondientes para:
- Extraer APIs deprecadas en el rango de versiones.
- Identificar nuevas funcionalidades (*What's New*) aplicables.
- Revisar breaking changes o notas de compatibilidad.

```text
Tool: sap-docs-hosted/ui5_version_diff
Parámetros:
  - library: "SAPUI5"
  - from_version: "<versión_origen>"
  - to_version: "<versión_destino>"
```

### Paso 3: Auditoría y Linter del Código Local
- Ejecutar `run_ui5_linter` en la carpeta del proyecto para contrastar el código fuente real contra las APIs obsoletas.
- Ejecutar `run_manifest_validation` para confirmar que `_version` de manifest y las dependencias de librerías son conformes a la nueva versión.

### Paso 4: Propuesta de Refactorización y Ejecución
1. **Actualizar descriptores**:
   - Modificar `manifest.json` (`minUI5Version`, `_version`).
   - Modificar `ui5.yaml` (versión del framework en `specVersion`).
   - Modificar `package.json` (`@ui5/cli`, tipos TypeScript si aplica).
2. **Reemplazo de APIs**:
   - Sustituir llamadas a clases o métodos deprecados por sus equivalentes modernos (ej. módulos asíncronos en lugar de llamadas síncronas heredadas).
3. **Validación final**:
   - Re-ejecutar linter y verificar que no quedan errores ni warnings críticos.
