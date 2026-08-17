---
description: Exportar datos estructurados (JSON) a un archivo Excel (.xlsx) nativo
---

Este workflow se utiliza cuando el usuario final pide explícitamente "generar este reporte en Excel" o "descargar estos datos a una hoja de cálculo" de resultados obtenidos (por ejemplo, desde SAP OData o tablas internas).

### Requisitos
El usuario debe tener Microsoft Excel instalado.

### Pasos

1. Prepara un archivo JSON intermedio con los datos si no existe uno (puedes guardarlo en `/tmp/` si no es persistente).
2. Ejecuta el script de exportación:
// turbo
```powershell
& ".\.agents\scripts\converters\Convert-JsonToXlsx.ps1" -InputFilePath "<RUTA_ABSOLUTA_DEL_ARCHIVO_JSON>" -OutputFilePath "<RUTA_ABSOLUTA_DEL_RESULTADO_XLSX>"
```

3. Notifica al usuario que la hoja de cálculo ha sido generada y se encuentra lista en la ruta asignada.
