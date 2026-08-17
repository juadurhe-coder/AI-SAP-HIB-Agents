<#
.SYNOPSIS
    Linter especializado para PowerShell (.ps1) en .agents/scripts/
.DESCRIPTION
    Auditoría AST Clean Code: Verbos oficiales, variables no utilizadas,
    alias de cmdlets, objetos COM no liberados y bloques duplicados.
#>

param(
    [string]$ScriptsDir = $PSScriptRoot
)

$psFiles = Get-ChildItem -Path $ScriptsDir -Filter "*.ps1" -Recurse -File | Where-Object { $_.FullName -notmatch '[\\/]fixtures[\\/]' }

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

$systemVars = @(
    '_', 'Matches', 'PSScriptRoot', 'null', 'true', 'false', 'LASTEXITCODE', 'env',
    'args', 'input', 'PSItem', 'ErrorActionPreference', 'WhatIf'
)

$autoAssignProtected = @('Matches', 'Args', 'Input', 'PID', 'Host', 'Profile', 'Home', 'Error', 'ExecutionContext')

$aliasMap = @{
    'gci'    = 'Get-ChildItem'
    'gc'     = 'Get-Content'
    'sc'     = 'Set-Content'
    'select' = 'Select-Object'
    'where'  = 'Where-Object'
    'sort'   = 'Sort-Object'
    'rm'     = 'Remove-Item'
    'ri'     = 'Remove-Item'
    'del'    = 'Remove-Item'
    'dir'    = 'Get-ChildItem'
    'cat'    = 'Get-Content'
    'echo'   = 'Write-Output / Write-Host'
    'cls'    = 'Clear-Host'
    'clear'  = 'Clear-Host'
}

function Test-DuplicateBlock {
    param([string]$filePath, [string]$fileName)
    $lines = [System.IO.File]::ReadAllLines($filePath, [System.Text.Encoding]::UTF8)
    $windowSize = 3
    $cleanLines = @()

    for ($i = 0; $i -lt $lines.Count; $i++) {
        $t = $lines[$i].Trim()
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
                if ($startLine -gt $prevEnd) {
                    Write-Host " [WARN] $fileName tiene un bloque duplicado (Líneas $startLine-$endLine idénticas a $prevStart-$prevEnd)" -ForegroundColor Yellow
                    $warningsCount++
                }
            } else {
                $seenBlocks[$blockKey] = @{ Start = $startLine; End = $endLine }
            }
        }
    }
    return $warningsCount
}

Write-Host "--- AUDITANDO SCRIPTS POWERSHELL (.ps1) ---" -ForegroundColor Yellow

foreach ($file in $psFiles) {
    $filePath = $file.FullName
    $fileName = $file.Name
    $filePassed = $true

    $parseErrors = $null
    $tokens = $null
    $ast = [System.Management.Automation.Language.Parser]::ParseFile($filePath, [ref]$tokens, [ref]$parseErrors)

    if ($parseErrors.Count -gt 0) {
        $filePassed = $false
        $totalErrors += $parseErrors.Count
        Write-Host " [ERROR SINTAXIS] $fileName tiene $($parseErrors.Count) error(es) de código:" -ForegroundColor Red
        foreach ($err in $parseErrors) {
            Write-Host "    - Línea $($err.Extent.StartLineNumber): $($err.Message)" -ForegroundColor Red
        }
    }

    $fileWarnings = 0

    if ($null -ne $ast) {
        $functions = $ast.FindAll({ $args[0] -is [System.Management.Automation.Language.FunctionDefinitionAst] }, $true)
        foreach ($func in $functions) {
            if ($func.Name -match '^(?<Verb>[^-]+)-(?<Noun>.+)$') {
                $verb = $Matches['Verb']
                $matchedApproved = $approvedVerbs | Where-Object { $_ -eq $verb }
                if (-not $matchedApproved) {
                    Write-Host " [WARN] $fileName (Línea $($func.Extent.StartLineNumber)): La función '$($func.Name)' usa un verbo no oficial de PowerShell ('$verb')." -ForegroundColor Yellow
                    $fileWarnings++
                }
            }
        }

        $assignments = $ast.FindAll({ $args[0] -is [System.Management.Automation.Language.AssignmentStatementAst] }, $true)
        $varExprs = $ast.FindAll({ $args[0] -is [System.Management.Automation.Language.VariableExpressionAst] }, $true)

        $assignedVars = @{}
        foreach ($assign in $assignments) {
            if ($assign.Left -is [System.Management.Automation.Language.VariableExpressionAst]) {
                $vName = $assign.Left.VariablePath.UserPath
                $lineNum = $assign.Left.Extent.StartLineNumber

                if ($autoAssignProtected -contains $vName) {
                    Write-Host " [WARN] $fileName (Línea $lineNum): Evitar reasignar la variable automática '`$$vName' (PSAvoidAssignmentToAutomaticVariable)." -ForegroundColor Yellow
                    $fileWarnings++
                }

                if ($systemVars -notcontains $vName -and $vName -notlike 'env:*') {
                    if (-not $assignedVars.ContainsKey($vName)) {
                        $assignedVars[$vName] = $lineNum
                    }
                }
            }
            # PSAvoidDynamicPropertyAssignment: Detectar $obj.prop += val
            elseif ($assign.Left -is [System.Management.Automation.Language.MemberExpressionAst] -and $assign.Operator -eq 'PlusEquals') {
                $lineNum = $assign.Left.Extent.StartLineNumber
                $propExpr = $assign.Left.Extent.Text
                Write-Host " [WARN] $fileName (Línea $lineNum): Evitar asignación += directa sobre propiedad de objeto '$propExpr'. Usar casteo explícito [int] o asignación estándar (PSAvoidDynamicPropertyAssignment)." -ForegroundColor Yellow
                $fileWarnings++
            }
        }

        foreach ($vName in $assignedVars.Keys) {
            $occurrences = $varExprs | Where-Object { $_.VariablePath.UserPath -eq $vName }
            if ($occurrences.Count -le 1) {
                $lineNum = $assignedVars[$vName]
                Write-Host " [ERROR VARIABLE HUÉRFANA] $fileName (Línea $lineNum): La variable '`$$vName' está asignada pero nunca se utiliza (PSUseDeclaredVarsMoreThanAssignments)." -ForegroundColor Red
                $totalErrors++
                $filePassed = $false
            }
        }

        $commands = $ast.FindAll({ $args[0] -is [System.Management.Automation.Language.CommandAst] }, $true)
        foreach ($cmd in $commands) {
            $cmdName = $cmd.GetCommandName()
            if ($null -ne $cmdName -and $aliasMap.ContainsKey($cmdName.ToLower())) {
                $rec = $aliasMap[$cmdName.ToLower()]
                $lineNum = $cmd.Extent.StartLineNumber
                Write-Host " [WARN] $fileName (Línea $lineNum): Usar cmdlet completo '$rec' en lugar del alias '$cmdName' (PSAvoidUsingCmdletAliases)." -ForegroundColor Yellow
                $fileWarnings++
            }
        }

        foreach ($ve in $varExprs) {
            if ($ve.VariablePath.IsGlobal) {
                $lineNum = $ve.Extent.StartLineNumber
                Write-Host " [WARN] $fileName (Línea $lineNum): Evitar contaminar el ámbito global con '`$Global:$($ve.VariablePath.UserPath)' (PSAvoidGlobalVars)." -ForegroundColor Yellow
                $fileWarnings++
            }
        }
    }

    $content = [System.IO.File]::ReadAllText($filePath, [System.Text.Encoding]::UTF8)
    if ($content -match 'New-Object\s+-ComObject' -and $content -notmatch 'ReleaseComObject') {
        Write-Host " [WARN] $fileName inicializa objetos COM sin invocar ReleaseComObject en bloque finally." -ForegroundColor Yellow
        $fileWarnings++
    }

    $dupWarns = Test-DuplicateBlock -filePath $filePath -fileName $fileName
    $fileWarnings += $dupWarns
    $totalWarnings += $fileWarnings

    if ($filePassed -and $parseErrors.Count -eq 0) {
        if ($fileWarnings -gt 0) {
            Write-Host " [WARN] $fileName ($fileWarnings advertencia(s) de Clean Code)" -ForegroundColor Yellow
        } else {
            Write-Host " [PASS] $fileName (AST PowerShell Limpio)" -ForegroundColor Green
            $totalPassed++
        }
    }
}

return @{
    Passed = $totalPassed
    Warnings = $totalWarnings
    Errors = $totalErrors
}
