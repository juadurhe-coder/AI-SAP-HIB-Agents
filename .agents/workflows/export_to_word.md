---
description: Exportar una propuesta en Markdown a Word (.docx) nativo
---

Este workflow se utiliza cuando el usuario final pide explícitamente "generar o exportar el documento Word final" de una presentación, propuesta, documento de RFI o archivo originado en formato Markdown (`.md`).

### Por qué usar este workflow
No utilices paquetes externos de NPM (como `md-to-pdf` o módulos problemáticos que lanzan avisos o errores) si puedes usar el propio motor local del host de Microsoft Word. Este workflow llama a un script de PowerShell que ejecuta nativamente Word en segundo plano para abrir HTML renderizado y guardarlo como `.docx` inmaculado, evitando errores de apertura o formato.

### Pasos

1. Ejecuta el script de exportación ubicado en tus herramientas de agentes:
// turbo
```powershell
& ".\.agents\scripts\Convert-MdToDocx.ps1" -InputFilePath "<RUTA_ABSOLUTA_DEL_ARCHIVO_MD>" -OutputFilePath "<RUTA_ABSOLUTA_DEL_RESULTADO_DOCX>"
```

*Nota: Asegúrate SIEMPRE de utilizar las rutas completas y absolutas (c:\...) para evitar problemas de directorios de ejecución.*

2. Notifica al usuario que el archivo ha sido convertido y se encuentra listo en la ruta asignada.

### Estándar Corporativo: Cabecera Visual por Defecto
El script de PowerShell está configurado con un **estándar de identidad corporativa**. Si existe la imagen de cabecera institucional en la carpeta de recursos de agentes:
`.agents/resources/corporate_header.png`

El motor de conversión **inyectará automáticamente** esta imagen al inicio de cualquier documento de Word generado, a menos que el archivo Markdown origen ya contenga una referencia manual a una imagen de cabecera local (`header_image.png` o `corporate_header.png`), evitando duplicidades y garantizando que todos los entregables de Word luzcan una presentación premium estandarizada sin esfuerzo adicional.
