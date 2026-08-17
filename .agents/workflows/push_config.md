---
description: Publica y sincroniza todos los cambios, propuestas y agentes locales con el repositorio de GitHub
---

Este workflow se utiliza cuando el usuario o el agente finalizan un trabajo, aprueban un documento o desean subir un conjunto de cambios locales al repositorio de GitHub.

### Pasos

1. Ejecuta el script de publicación a GitHub:
// turbo
```powershell
node .\.agents\scripts\governance\push-all.js
```

2. Notifica al usuario que el repositorio `AI-HIBERUS-Projects` ha sido actualizado exitosamente en GitHub.
