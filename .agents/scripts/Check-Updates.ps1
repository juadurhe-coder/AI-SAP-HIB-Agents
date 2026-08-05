<#
.SYNOPSIS
    Comprueba si existen actualizaciones pendientes en GitHub sin modificar el entorno local.
.OUTPUTS
    Devuelve la cantidad de commits pendientes de descargar.
#>

$ErrorActionPreference = "SilentlyContinue"

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

$gitBin = Get-GitExecutable

if (-not $gitBin) {
    Write-Output "UP_TO_DATE"
    exit 0
}

try {
    # 1. Ejecutar git fetch silenciosamente
    & $gitBin fetch origin main 2>$null | Out-Null
    
    # 2. Contar commits por detrás
    $behindCountStr = (& $gitBin rev-list --count HEAD..origin/main 2>$null)
    $behindCount = 0
    if ([int]::TryParse($behindCountStr, [ref]$behindCount) -and $behindCount -gt 0) {
        $lastCommitMsg = (& $gitBin log -1 --format="%s" origin/main 2>$null)
        Write-Output "UPDATES_AVAILABLE:${behindCount}:${lastCommitMsg}"
    } else {
        Write-Output "UP_TO_DATE"
    }
} catch {
    Write-Output "UP_TO_DATE"
}
