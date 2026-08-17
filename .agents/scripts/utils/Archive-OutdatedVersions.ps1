<#
.SYNOPSIS
    Script de archivado automático y limpieza de versiones obsoletas en proyectos SAP PMO.
.DESCRIPTION
    Detecta versiones superadas (v1, v2, v3, v4, v1.0, _FINAL), duplicados con (1), ficheros _OLD/_vOLD y temporales desfasados,
    los traslada a 99_Archive/ y actualiza las referencias cruzadas en 00_Project_Memory.md.
#>

param(
    [switch]$WhatIf
)

$projectsDir = Join-Path $PSScriptRoot "..\..\Projects"
if (-not (Test-Path $projectsDir)) {
    Write-Error "La carpeta Projects no existe en $projectsDir"
    exit 1
}

$ignoredDevFiles = @('package.json', 'package-lock.json', 'vite.config.js', 'tailwind.config.js', 'postcss.config.js', 'schema.sql', 'index.html', '.gitignore')

Write-Host "========================================================================" -ForegroundColor Cyan
Write-Host " 📦 AUTOMATIZACIÓN DE ARCHIVADO Y CONTROL DE VERSIONES (99_Archive/)" -ForegroundColor Cyan
Write-Host "========================================================================" -ForegroundColor Cyan
if ($WhatIf) {
    Write-Host " [ MODO DRY-RUN / WHAT-IF ACTIVADO - No se realizarán cambios en disco ]`n" -ForegroundColor Yellow
}

$movedCount = 0
$updatedRefMap = @{}

$projectFolders = Get-ChildItem -Path $projectsDir -Directory | Where-Object { $_.Name -ne '99_Archive' }

foreach ($folder in $projectFolders) {
    $archiveFolder = Join-Path $folder.FullName "99_Archive"
    $files = Get-ChildItem -Path $folder.FullName -File | Where-Object { $_.Name -notlike ".*" -and $ignoredDevFiles -notcontains $_.Name }
    
    # 1. Identificar duplicados con paréntesis (1), (2), _OLD, _vOLD, - copia, _FINAL (si hay versión vX)
    foreach ($file in $files) {
        if ($file.Name -match '\([0-9]+\)' -or $file.Name -match '(?i)_old|_vold|- copia' -or ($file.Name -match '\.html$' -and $file.Name -ne 'index.html')) {
            if (-not (Test-Path -LiteralPath $archiveFolder)) {
                if (-not $WhatIf) { New-Item -ItemType Directory -Path $archiveFolder -Force | Out-Null }
            }
            $targetPath = Join-Path $archiveFolder $file.Name
            Write-Host " 🚚 [ARCHIVAR DUPLICADO/OLD/TEMPORAL] $($folder.Name)\$($file.Name) -> 99_Archive/" -ForegroundColor Yellow
            if (-not $WhatIf) {
                Move-Item -LiteralPath $file.FullName -Destination $targetPath -Force -ErrorAction SilentlyContinue
            }
            $movedCount++
        }
    }

    # Re-obtener ficheros activos tras limpiar duplicados obvios
    $activeFiles = Get-ChildItem -Path $folder.FullName -File | Where-Object { $_.Name -notlike ".*" -and $ignoredDevFiles -notcontains $_.Name }

    # 2. Agrupar por familia de documento para detectar versiones superadas (_v1, _v2, _v3, _v4, _v1.0, _FINAL)
    $docFamilies = @{}

    foreach ($file in $activeFiles) {
        # Extraer base de nombre y versión (ej. _v4, _v1.0, _FINAL)
        if ($file.Name -match '^(.*?)(?:_v([0-9]+)(?:\.([0-9]+))?|_FINAL|_vFINAL)(\.[^.]+)$') {
            $baseName = $Matches[1]
            $major = if ($Matches[2]) { [int]$Matches[2] } else { 1 }
            $minor = if ($Matches[3]) { [int]$Matches[3] } else { 0 }
            $ext = $Matches[4]
            $familyKey = "$baseName$ext".ToLower()

            $verObj = [PSCustomObject]@{
                File      = $file
                Major     = $major
                Minor     = $minor
                VerNum    = ($major * 100) + $minor
                BaseName  = $baseName
                Ext       = $ext
            }

            if (-not $docFamilies.ContainsKey($familyKey)) {
                $docFamilies[$familyKey] = [System.Collections.Generic.List[PSCustomObject]]::new()
            }
            $docFamilies[$familyKey].Add($verObj)
        }
    }

    # Mover versiones inferiores a 99_Archive/
    foreach ($familyKey in $docFamilies.Keys) {
        $versions = $docFamilies[$familyKey] | Sort-Object VerNum -Descending
        if ($versions.Count -gt 1) {
            $latest = $versions[0]
            for ($i = 1; $i -lt $versions.Count; $i++) {
                $oldVer = $versions[$i]
                if (-not (Test-Path -LiteralPath $archiveFolder)) {
                    if (-not $WhatIf) { New-Item -ItemType Directory -Path $archiveFolder -Force | Out-Null }
                }
                $targetPath = Join-Path $archiveFolder $oldVer.File.Name
                Write-Host " 📦 [ARCHIVAR VERSIÓN SUPERADA] $($folder.Name)\$($oldVer.File.Name) (Superada por $($latest.File.Name))" -ForegroundColor Cyan
                
                # Mapear para actualizar referencias en 00_Project_Memory.md
                $updatedRefMap[$oldVer.File.Name] = $latest.File.Name

                if (-not $WhatIf) {
                    Move-Item -LiteralPath $oldVer.File.FullName -Destination $targetPath -Force -ErrorAction SilentlyContinue
                }
                $movedCount++
            }
        }
    }
}

# 3. Actualizar referencias en 00_Project_Memory.md y Markdown asociados
if ($updatedRefMap.Count -gt 0) {
    Write-Host "`n========================================================================" -ForegroundColor Cyan
    Write-Host " ✏️  ACTUALIZANDO REFERENCIAS EN MEMORIA Y DOCUMENTOS MARKDOWN" -ForegroundColor Cyan
    Write-Host "========================================================================" -ForegroundColor Cyan

    $allMdFiles = Get-ChildItem -Path $projectsDir -Recurse -Filter "*.md"
    foreach ($mdFile in $allMdFiles) {
        $content = [System.IO.File]::ReadAllText($mdFile.FullName, [System.Text.Encoding]::UTF8)
        $modified = $false
        
        foreach ($oldName in $updatedRefMap.Keys) {
            $latestName = $updatedRefMap[$oldName]
            if ($content.Contains($oldName)) {
                $content = $content.Replace($oldName, $latestName)
                $modified = $true
                Write-Host " 🔄 En $($mdFile.Name): '$oldName' -> '$latestName'" -ForegroundColor Green
            }
        }
        
        if ($modified -and -not $WhatIf) {
            [System.IO.File]::WriteAllText($mdFile.FullName, $content, [System.Text.Encoding]::UTF8)
        }
    }
}

Write-Host "`n========================================================================" -ForegroundColor Cyan
Write-Host " ✅ PROCESO DE ARCHIVADO COMPLETADO. Total de archivos archivados: $movedCount" -ForegroundColor Green
Write-Host "========================================================================" -ForegroundColor Cyan
