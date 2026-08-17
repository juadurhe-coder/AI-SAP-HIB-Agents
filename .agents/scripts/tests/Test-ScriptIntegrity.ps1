<#
.SYNOPSIS
    Script Master de Orquestación de Integridad, Sintaxis y Clean Code en Scripts (.agents/scripts/).
.DESCRIPTION
    Ejecuta modularmente la suite de linters especializados (.agents/scripts/linters/):
    - test-powershell.ps1: Auditoría AST de PowerShell (Clean Code, verbos, variables no usadas, alias).
    - test-javascript.js: Auditoría Node.js y AST/Clean Code de JavaScript (sintaxis, variables no usadas, bloques duplicados).
    Preparado para extensión futura (ej. test-abap, test-ui5).
#>

param(
    [switch]$Fix
)

$scriptsDir = Join-Path $PSScriptRoot ".."
$lintersDir = Join-Path $PSScriptRoot "linters"

Write-Host "========================================================================" -ForegroundColor Cyan
Write-Host " AUTOMATIZACION DE INTEGRIDAD, SINTAXIS Y CLEAN CODE EN SCRIPTS (MASTER)" -ForegroundColor Cyan
Write-Host "========================================================================" -ForegroundColor Cyan
Write-Host "Ruta auditada: $scriptsDir"
Write-Host ""

$totalPassed = 0
$totalWarnings = 0
$totalErrors = 0

# 1. Ejecutar Linter de PowerShell (.ps1)
$psLinter = Join-Path $lintersDir "test-powershell.ps1"
if (Test-Path $psLinter) {
    $psResult = & "$psLinter" -ScriptsDir $scriptsDir
    $totalPassed = $totalPassed + [int]$psResult.Passed
    $totalWarnings = $totalWarnings + [int]$psResult.Warnings
    $totalErrors = $totalErrors + [int]$psResult.Errors
} else {
    Write-Host "❌ Error: Linter de PowerShell no encontrado en $psLinter" -ForegroundColor Red
    $totalErrors++
}

Write-Host ""

# 2. Ejecutar Linter de JavaScript (.js)
$jsLinter = Join-Path $lintersDir "test-javascript.js"
$nodeCmd = Get-Command node -ErrorAction SilentlyContinue
if ($nodeCmd -and (Test-Path $jsLinter)) {
    $jsOutRaw = & node "$jsLinter" "$scriptsDir" 2>&1
    
    $jsonStr = ""
    foreach ($line in $jsOutRaw) {
        if ($line -match '^\{"passed":') {
            $jsonStr = $line
        } else {
            Write-Host $line
        }
    }

    if ($jsonStr) {
        $jsResult = $jsonStr | ConvertFrom-Json
        $totalPassed = $totalPassed + [int]$jsResult.passed
        $totalWarnings = $totalWarnings + [int]$jsResult.warnings
        $totalErrors = $totalErrors + [int]$jsResult.errors
    }
}

Write-Host ""

# 3. Ejecutar Suite de Tests Unitarios de Checkers ABAP y Fiori
$abapFioriLinter = Join-Path $lintersDir "test-abap-fiori.js"
if ($nodeCmd -and (Test-Path $abapFioriLinter)) {
    & node "$abapFioriLinter"
    if ($LASTEXITCODE -ne 0) {
        $totalErrors++
    } else {
        $totalPassed++
    }
}

Write-Host ""
Write-Host "========================================================================" -ForegroundColor Cyan
Write-Host " RESUMEN DE INTEGRIDAD DE SCRIPTS" -ForegroundColor Cyan
Write-Host "========================================================================" -ForegroundColor Cyan
Write-Host "Scripts Correctos (PASS) : $totalPassed"
Write-Host "Advertencias (WARN)      : $totalWarnings"
Write-Host "Errores (FAIL)           : $totalErrors"

if ($totalErrors -gt 0) {
    Write-Host ""
    Write-Host "AUDITORIA FALLIDA: Se detectaron $totalErrors errores de sintaxis en scripts." -ForegroundColor Red
    exit 1
} else {
    Write-Host ""
    Write-Host "AUDITORIA EXITOSA: Todos los scripts tienen sintaxis valida y limpia." -ForegroundColor Green
    exit 0
}
