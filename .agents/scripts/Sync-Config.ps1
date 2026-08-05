<#
.SYNOPSIS
    Ejecuta la sincronización completa del entorno de agentes desde GitHub.
#>

function Get-GitExecutable {
    $cmd = Get-Command git -ErrorAction SilentlyContinue
    if ($cmd) { return $cmd.Source }
    $possiblePaths = @(
        "C:\Program Files\Git\cmd\git.exe",
        "C:\Program Files\Git\bin\git.exe",
        "$env:LocalAppData\Programs\Git\cmd\git.exe",
        "$env:ProgramFiles\Git\cmd\git.exe",
        "${env:ProgramFiles(x86)}\Git\cmd\git.exe"
    )
    foreach ($p in $possiblePaths) {
        if (Test-Path $p) { return $p }
    }
    return $null
}

Write-Host "===============================================================" -ForegroundColor Cyan
Write-Host " 🔄 SINCRONIZANDO CONFIGURACIÓN DE AGENTES DE HIBERUS         " -ForegroundColor Cyan
Write-Host "===============================================================" -ForegroundColor Cyan
Write-Host ""

$gitBin = Get-GitExecutable

try {
    if ($gitBin) {
        # 1. Descargar cambios de Git
        Write-Host "📥 Descargando últimas actualizaciones desde GitHub..." -ForegroundColor Yellow
        $pullOutput = & $gitBin pull origin main 2>&1
        Write-Host $pullOutput -ForegroundColor Gray
        Write-Host ""
    } else {
        Write-Host "⚠️ No se detectó Git instalado localmente. Omitiendo descarga de repositorio." -ForegroundColor Yellow
    }

    # 2. Sincronizar regla global local
    $workspacePath = Resolve-Path "$PSScriptRoot\..\.."
    $geminiConfigDir = Join-Path $env:USERPROFILE ".gemini\config"
    
    if (-not (Test-Path $geminiConfigDir)) {
        New-Item -Path $geminiConfigDir -ItemType Directory -Force | Out-Null
    }

    $workspaceAgentsMd = Join-Path $workspacePath ".agents\AGENTS.md"
    $globalAgentsMd = Join-Path $geminiConfigDir "AGENTS.md"

    if (Test-Path $workspaceAgentsMd) {
        Copy-Item -Path $workspaceAgentsMd -Destination $globalAgentsMd -Force
        Write-Host "📋 Regla global AGENTS.md sincronizada en: $globalAgentsMd" -ForegroundColor Green
    }

    Write-Host ""
    Write-Host "===============================================================" -ForegroundColor Cyan
    Write-Host " 🎉 ¡ENTORNO ACTUALIZADO Y SINCRONIZADO CORRECTAMENTE!        " -ForegroundColor Green
    Write-Host "===============================================================" -ForegroundColor Cyan
} catch {
    Write-Error "Error durante la sincronización: $_"
}
