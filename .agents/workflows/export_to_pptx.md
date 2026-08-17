---
description: Exportar una presentación en Markdown a PowerPoint (.pptx) nativo
---

Este workflow se utiliza cuando el usuario pide explícitamente "generar la presentación PowerPoint" o "preparar las diapositivas de la propuesta" a partir de contenido Markdown estructurado.

### Estructura del Markdown
Para que las diapositivas se generen correctamente, utiliza el separador `---` entre ellas:
```markdown
# Slide 1 Title
Slide content

---

# Slide 2 Title
- Bullet 1
- Bullet 2
```

### Pasos

1. Asegúrate de que el contenido Markdown esté formateado con el separador `---`.
2. Ejecuta el script de exportación:
// turbo
```powershell
& ".\.agents\scripts\converters\Convert-MdToPptx.ps1" -InputFilePath "<RUTA_ABSOLUTA_DEL_ARCHIVO_MD>" -OutputFilePath "<RUTA_ABSOLUTA_DEL_RESULTADO_PPTX>"
```

3. Notifica al usuario que la presentación ha sido creada y se encuentra lista.
