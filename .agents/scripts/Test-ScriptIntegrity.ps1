<#
.SYNOPSIS
    Script de auditoria de integridad, sintaxis, verbos oficiales y Clean Code para scripts (.ps1 y .js) en .agents/scripts/.
.DESCRIPTION
    Realiza parsing AST en PowerShell, comprobaciones de sintaxis con Node.js en JavaScript,
    deteccion de verbos oficiales (PSUseApprovedVerbs) y bloques de codigo duplicados/repetidos.
#>

param(
    [switch]$Fix
)

$scriptsDir = $PSScriptRoot
Write-Host "========================================================================" -ForegroundColor Cyan
Write-Host " AUTOMATIZACION DE INTEGRIDAD, SINTAXIS Y CLEAN CODE EN SCRIPTS" -ForegroundColor Cyan
Write-Host "========================================================================" -ForegroundColor Cyan
Write-Host "Ruta auditada: $scriptsDir"
Write-Host ""

$psFiles = Get-ChildItem -Path $scriptsDir -Filter "*.ps1" -File
$jsFiles = Get-ChildItem -Path $scriptsDir -Filter "*.js" -File

$totalPassed = 0
$totalErrors = 0
$totalWarnings = 0

$approvedVerbs = @(
    'Add', 'Approve', 'Assert', 'Build', 'Clear', 'Close', 'Compare', 'Compress', 'Confirm', 'Connect',
    'Convert', 'ConvertFrom', 'ConvertTo', 'Copy', 'Debug', 'Deny', 'Disable', 'Disconnect', 'Dismount',
    'Edit', 'Enable', 'Enter', 'Exit', 'Expand', 'Export', 'Find', 'Format', 'Get', 'Grant', 'Group',
    'Hide', 'Import', 'Initialize', 'Install', 'Invoke', 'Join', 'Limit', 'Lock', 'Measure', 'Merge',
    'Mount', 'Move', 'New', 'Open', 'Optimize', 'Out', 'Ping', 'Pop', 'Protect', 'Publish', 'Push',
    'Read', 'Receive', 'Redo', 'Register', 'Remove', 'Rename', 'Repair', 'Request', 'Reset', 'Resize',
    'Resolve', 'Restart', 'Restore', 'Resume', 'Revoke', 'Save', 'Search', 'Select', 'Send', 'Set',
    'Show', 'Skip', 'Split', 'Start', 'Step', 'Stop', 'Submit', 'Suspend', 'Switch', 'Sync', 'Test',
    'Trace', 'Unbind', 'Undo', 'Uninitialize', 'Uninstall', 'Unlock', 'Unprotect', 'Unpublish',
    'Unregister', 'Update', 'Use', 'Wait', 'Watch', 'Write'
)

function Test-DuplicateBlock {
    param([string]$filePath, [string]$fileName)
    $lines = [System.IO.File]::ReadAllLines($filePath, [System.Text.Encoding]::UTF8)
    $windowSize = 3
    $cleanLines = @()

    for ($i = 0; $i -lt $lines.Count; $i++) {
        $t = $lines[$i].Trim()
        # Ignorar comentarios, lineas vacias y llaves sueltas
        if ($t -ne '' -and $t -ne '{' -and $t -ne '}' -and $t -ne 'else' -and -not $t.StartsWith('#') -and -not $t.StartsWith('//')) {
            $cleanLines += [PSCustomObject]@{ LineNum = $i + 1; Content = $t }
        }
    }

    $seenBlocks = @{}
    $warningsCount = 0

    if ($cleanLines.Count -ge $windowSize) {
        for ($i = 0; $i -le ($cleanLines.Count - $windowSize); $i++) {
            $blockKey = ($cleanLines[$i..($i + $windowSize - 1)] | Select-Object -ExpandProperty Content) -join "||"
            $startLine = $cleanLines[$i].LineNum
            $endLine = $cleanLines[$i + $windowSize - 1].LineNum

            if ($seenBlocks.ContainsKey($blockKey)) {
                $prevStart = $seenBlocks[$blockKey].Start
                $prevEnd = $seenBlocks[$blockKey].End
                # Evitar reportar solapamientos inmediatos de 1 linea
                if ($startLine -gt $prevEnd) {
                    Write-Host " [WARN] $fileName tiene un bloque duplicado (Lineas $startLine-$endLine identicas a $prevStart-$prevEnd)" -ForegroundColor Yellow
                    $warningsCount++
                }
            } else {
                $seenBlocks[$blockKey] = @{ Start = $startLine; End = $endLine }
            }
        }
    }
    return $warningsCount
}

# 1. Auditar Scripts de PowerShell (.ps1)
Write-Host "--- AUDITANDO SCRIPTS POWERSHELL (.ps1) ---" -ForegroundColor Yellow

foreach ($file in $psFiles) {
    $filePath = $file.FullName
    $fileName = $file.Name
    $filePassed = $true

    # 1.1 Parsing AST para errores de sintaxis
    $parseErrors = $null
    $tokens = $null
    $ast = [System.Management.Automation.Language.Parser]::ParseFile($filePath, [ref]$tokens, [ref]$parseErrors)

    if ($parseErrors.Count -gt 0) {
        $filePassed = $false
        $totalErrors += $parseErrors.Count
        Write-Host " [ERROR SINTAXIS] $fileName tiene $($parseErrors.Count) error(es) de codigo:" -ForegroundColor Red
        foreach ($err in $parseErrors) {
            Write-Host "    - Linea $($err.Extent.StartLineNumber): $($err.Message)" -ForegroundColor Red
        }
    }

    # 1.2 Inspeccionar funciones declaradas mediante AST para Verbos Oficiales (PSUseApprovedVerbs)
    if ($null -ne $ast) {
        $functions = $ast.FindAll({ $args[0] -is [System.Management.Automation.Language.FunctionDefinitionAst] }, $true)
        foreach ($func in $functions) {
            if ($func.Name -match '^(?<Verb>[^-]+)-(?<Noun>.+)$') {
                $verb = $Matches['Verb']
                $noun = $Matches['Noun']
                
                # Validar verbo oficial
                $matchedApproved = $approvedVerbs | Where-Object { $_ -eq $verb }
                if (-not $matchedApproved) {
                    Write-Host " [WARN] $fileName : La funcion '$($func.Name)' usa un verbo no oficial de PowerShell ('$verb'). Usar Test, Find, Get, Set, etc." -ForegroundColor Yellow
                    $totalWarnings++
                }
            }
        }
    }

    # 1.3 Comprobar asignacion a variables automaticas ($matches = ...)
    $content = [System.IO.File]::ReadAllText($filePath, [System.Text.Encoding]::UTF8)
    if ($content -match '^\s*\$matches\s*=' -or $content -match ';\s*\$matches\s*=') {
        Write-Host " [WARN] $fileName reasigna la variable automatica `$matches." -ForegroundColor Yellow
        $totalWarnings++
    }

    # 1.4 Comprobar objetos COM sin limpieza ReleaseComObject
    if ($content -match 'New-Object\s+-ComObject' -and $content -notmatch 'ReleaseComObject') {
        Write-Host " [WARN] $fileName inicializa objetos COM sin invocar ReleaseComObject en bloque finally." -ForegroundColor Yellow
        $totalWarnings++
    }

    # 1.5 Deteccion de bloques duplicados
    $dupWarns = Test-DuplicateBlock -filePath $filePath -fileName $fileName
    $totalWarnings += $dupWarns

    if ($filePassed -and $parseErrors.Count -eq 0) {
        Write-Host " [PASS] $fileName (Sintaxis AST limpia)" -ForegroundColor Green
        $totalPassed++
    }
}

# 2. Auditar Scripts de JavaScript (.js)
Write-Host ""
Write-Host "--- AUDITANDO SCRIPTS JAVASCRIPT (.js) ---" -ForegroundColor Yellow

$nodeCmd = Get-Command node -ErrorAction SilentlyContinue
if ($nodeCmd) {
    foreach ($file in $jsFiles) {
        $filePath = $file.FullName
        $fileName = $file.Name
        
        $nodeCheckOutput = & node --check "$filePath" 2>&1
        if ($LASTEXITCODE -ne 0) {
            Write-Host " [ERROR SINTAXIS] $fileName tiene errores de sintaxis en Node.js:" -ForegroundColor Red
            Write-Host "    $nodeCheckOutput" -ForegroundColor Red
            $totalErrors++
        } else {
            # Deteccion de bloques duplicados
            $dupWarns = Test-DuplicateBlock -filePath $filePath -fileName $fileName
            $totalWarnings += $dupWarns
            Write-Host " [PASS] $fileName (Node --check OK)" -ForegroundColor Green
            $totalPassed++
        }
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
