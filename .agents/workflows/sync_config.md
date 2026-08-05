---
description: Sincroniza y actualiza los agentes, reglas y scripts a la última versión del equipo desde GitHub
---

Este workflow se utiliza cuando el usuario o el agente detectan que existen cambios en GitHub subidos por otros compañeros o desde otro PC, o cuando se desea forzar una sincronización limpia del entorno de agentes.

### Pasos

1. Ejecuta el script de sincronización automática de agentes:
// turbo
```powershell
& ".\.agents\scripts\Sync-Config.ps1"
```

2. Revisa el resultado de la salida del script y confirma al usuario que el repositorio, los agentes y la regla global local están 100% al día.
