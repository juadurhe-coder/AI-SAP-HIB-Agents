param(
    [switch]$WhatIf
)

$projectsDir = Join-Path $PSScriptRoot "..\..\Projects"
if (-not (Test-Path $projectsDir)) {
    Write-Error "La carpeta Projects no existe en $projectsDir"
    exit 1
}

Write-Host "========================================================================" -ForegroundColor Cyan
Write-Host " INICIANDO MIGRACION AUTOMATICA DE TIPOS DE DOCUMENTOS SAP PMO" -ForegroundColor Cyan
Write-Host "========================================================================" -ForegroundColor Cyan

$renameMap = @{}

# Escanear subdirectorios en Projects/
$projectFolders = Get-ChildItem -Path $projectsDir -Directory | Where-Object { $_.Name -ne '99_Archive' }

foreach ($folder in $projectFolders) {
    $files = Get-ChildItem -Path $folder.FullName -File | Where-Object { $_.Name -notlike ".*" }
    
    foreach ($file in $files) {
        $oldName = $file.Name
        $newName = $oldName

        # Normalizar espacios tras corchetes: [ID] Explore... -> [ID]_01_PR_Explore...
        if ($oldName -match '^(\[[^\]]+\])\s+(Proposal|Explore_01|Proposal_)') {
            $newName = $oldName -replace '^(\[[^\]]+\])\s+', '$1_01_PR_'
        }
        elseif ($oldName -match '^(\[[^\]]+\])\s+(Explore_02|StorageLocation|StockReservation)') {
            $newName = $oldName -replace '^(\[[^\]]+\])\s+', '$1_03_FS_'
        }
        elseif ($oldName -match '02_FS_.*(manual|User_Manual|manual_usuario)') {
            $newName = $oldName -replace '02_FS_', '05_UM_'
        }
        elseif ($oldName -match '02_FS_.*(plan|Planning|planificacion|Gantt)') {
            $newName = $oldName -replace '02_FS_', '08_PP_'
        }
        elseif ($oldName -match '02_FS_.*(bpd|Overview|BPD)') {
            $newName = $oldName -replace '02_FS_', '02_BPD_'
        }
        elseif ($oldName -match '02_FS_') {
            $newName = $oldName -replace '02_FS_', '03_FS_'
        }
        elseif ($oldName -match '03_TS_') {
            $newName = $oldName -replace '03_TS_', '04_TS_'
        }
        elseif ($oldName -match '04_UAT_' -or $oldName -match '05_Test_') {
            $newName = $oldName -replace '04_UAT_', '06_TC_' -replace '05_Test_', '06_TC_'
        }
        elseif ($oldName -match '06_Cutover_') {
            $newName = $oldName -replace '06_Cutover_', '07_CO_'
        }

        if ($oldName -ne $newName) {
            $oldPath = $file.FullName
            $newPath = Join-Path $folder.FullName $newName
            $renameMap[$oldName] = $newName
            
            Write-Host " [RENOMBRAR/LIMPIAR] $($folder.Name)\$oldName -> $newName" -ForegroundColor Green
            if (-not $WhatIf) {
                if (Test-Path -LiteralPath $newPath) {
                    # Si la versión renombrada ya existe, borrar el duplicado sin prefijo
                    Remove-Item -LiteralPath $oldPath -Force -ErrorAction SilentlyContinue
                } elseif (Test-Path -LiteralPath $oldPath) {
                    Rename-Item -LiteralPath $oldPath -NewName $newName -Force -ErrorAction SilentlyContinue
                }
            }
        }
    }
}

Write-Host "`n========================================================================" -ForegroundColor Cyan
Write-Host " ACTUALIZANDO REFERENCIAS CRUZADAS EN DOCUMENTOS MARKDOWN" -ForegroundColor Cyan
Write-Host "========================================================================" -ForegroundColor Cyan

if ($renameMap.Count -gt 0) {
    $allMdFiles = Get-ChildItem -Path $projectsDir -Recurse -Filter "*.md"
    foreach ($mdFile in $allMdFiles) {
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
Write-Host "`n MIGRACION COMPLETADA. Total de ficheros procesados: $count" -ForegroundColor Green
