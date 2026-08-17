<#
.SYNOPSIS
    Script de Sincronización Automática de ID de Proyecto (Sync-ProjectId.ps1).
.DESCRIPTION
    Lee '.project_metadata.json' de una carpeta de proyecto y sincroniza el prefijo [[IDTrazabilidad]]
    de todos los archivos físicos y sus referencias cruzadas dentro de los ficheros Markdown (.md).
#>

param(
    [string]$FolderPath,
    [switch]$WhatIf
)

if ([string]::IsNullOrWhiteSpace($FolderPath)) {
    $FolderPath = Get-Location
}

$targetDir = [System.IO.Path]::GetFullPath($FolderPath)
$metaPath = Join-Path $targetDir ".project_metadata.json"

if (-not (Test-Path $metaPath)) {
    Write-Error "No se encontró '.project_metadata.json' en $targetDir"
    exit 1
}

try {
    $jsonRaw = [System.IO.File]::ReadAllText($metaPath, [System.Text.Encoding]::UTF8)
    $meta = $jsonRaw | ConvertFrom-Json
}
catch {
    Write-Error "Fallo al leer '.project_metadata.json': $_"
    exit 1
}

$newProjectId = $meta.project_id
if ([string]::IsNullOrWhiteSpace($newProjectId)) {
    Write-Error "El campo 'project_id' en '.project_metadata.json' está vacío."
    exit 1
}

Write-Host "========================================================================" -ForegroundColor Cyan
Write-Host " SINCRONIZANDO ARCHIVOS E HIPERVINCULOS AL ID: [$newProjectId]" -ForegroundColor Cyan
Write-Host "========================================================================" -ForegroundColor Cyan

$files = Get-ChildItem -Path $targetDir -File | Where-Object { $_.Name -notlike ".*" -and $_.Name -ne "cutover_tasks.xlsx" }
$renameMap = @{}

foreach ($file in $files) {
    $oldName = $file.Name
    
    # Detectar prefijo entre corchetes ej: [PRJ-IC-DROP-001]
    if ($oldName -match '^\[([^\]]+)\](.*)$') {
        $currentId = $Matches[1]
        $rest = $Matches[2]
        
        if ($currentId -ne $newProjectId) {
            $newName = "[$newProjectId]$rest"
            $oldPath = $file.FullName
            $newPath = Join-Path $targetDir $newName
            
            $renameMap[$oldName] = $newName
            Write-Host " [RENOMBRAR] $oldName -> $newName" -ForegroundColor Green
            
            if (-not $WhatIf) {
                if (Test-Path -LiteralPath $newPath) {
                    Remove-Item -LiteralPath $oldPath -Force -ErrorAction SilentlyContinue
                } elseif (Test-Path -LiteralPath $oldPath) {
                    Rename-Item -LiteralPath $oldPath -NewName $newName -Force -ErrorAction SilentlyContinue
                }
            }
        }
    }
}

# Sincronizar referencias cruzadas dentro de archivos Markdown
if ($renameMap.Count -gt 0) {
    Write-Host "`nActualizando referencias en ficheros Markdown (.md)..." -ForegroundColor Yellow
    $mdFiles = Get-ChildItem -Path $targetDir -Recurse -Filter "*.md"
    
    foreach ($mdFile in $mdFiles) {
        $content = [System.IO.File]::ReadAllText($mdFile.FullName, [System.Text.Encoding]::UTF8)
        $modified = $false
        
        foreach ($oldKey in $renameMap.Keys) {
            $newVal = $renameMap[$oldKey]
            if ($content.Contains($oldKey)) {
                $content = $content.Replace($oldKey, $newVal)
                $modified = $true
                Write-Host " [REFERENCIA] En $($mdFile.Name): '$oldKey' -> '$newVal'" -ForegroundColor Yellow
            }
        }
        
        if ($modified -and -not $WhatIf) {
            [System.IO.File]::WriteAllText($mdFile.FullName, $content, [System.Text.Encoding]::UTF8)
        }
    }
}

$count = $renameMap.Count
Write-Host "`n========================================================================" -ForegroundColor Cyan
Write-Host " SINCRONIZACION FINALIZADA. Archivos renombrados: $count" -ForegroundColor Green
Write-Host "========================================================================" -ForegroundColor Cyan
