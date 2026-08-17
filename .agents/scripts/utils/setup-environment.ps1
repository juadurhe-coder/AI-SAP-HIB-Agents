<#
.SYNOPSIS
    Script de Inicializacion y Sincronizacion Automatica de Antigravity IDE
.DESCRIPTION
    Configura el entorno local del usuario en cualquier ordenador nuevo, sincronizando
    los agentes, reglas globales y verificando las carpetas de configuracion.
#>

$ErrorActionPreference = "Stop"

Write-Host "===============================================================" -ForegroundColor Cyan
Write-Host " INICIALIZADOR AUTOMATICO DE CONFIGURACION ANTIGRAVITY IDE " -ForegroundColor Cyan
Write-Host "===============================================================" -ForegroundColor Cyan
Write-Host ""

# 1. Detectar rutas locales
$workspacePath = Resolve-Path "$PSScriptRoot\..\.."
$userProfilePath = $env:USERPROFILE
$geminiConfigDir = Join-Path $userProfilePath ".gemini\config"
$geminiIdeDir = Join-Path $userProfilePath ".gemini\antigravity-ide"

Write-Host "Directorio del Workspace: $workspacePath" -ForegroundColor Yellow
Write-Host "Perfil de Usuario Local: $userProfilePath" -ForegroundColor Yellow
Write-Host ""

# 2. Verificar o crear carpetas globales .gemini
if (-not (Test-Path $geminiConfigDir)) {
    Write-Host "Creando directorio de configuracion global (.gemini\config)..." -ForegroundColor Gray
    New-Item -Path $geminiConfigDir -ItemType Directory -Force | Out-Null
}

if (-not (Test-Path $geminiIdeDir)) {
    Write-Host "Creando directorio del IDE (.gemini\antigravity-ide)..." -ForegroundColor Gray
    New-Item -Path $geminiIdeDir -ItemType Directory -Force | Out-Null
}

# 3. Sincronizar Regla Global AGENTS.md
$globalAgentsMd = Join-Path $geminiConfigDir "AGENTS.md"
$workspaceAgentsMd = Join-Path $workspacePath ".agents\AGENTS.md"

if (Test-Path $workspaceAgentsMd) {
    Write-Host "Sincronizando regla global AGENTS.md..." -ForegroundColor Gray
    Copy-Item -Path $workspaceAgentsMd -Destination $globalAgentsMd -Force
    Write-Host "   -> Copiado exitosamente a: $globalAgentsMd" -ForegroundColor Green
}

# 3.1. Asegurar plantilla base de mcp_config.json si no existe
$mcpConfigFile = Join-Path $geminiIdeDir "mcp_config.json"
if (-not (Test-Path $mcpConfigFile)) {
    Write-Host "Generando plantilla base mcp_config.json..." -ForegroundColor Gray
    $mcpTemplate = @'
{
  "mcpServers": {
    "github-mcp-server": {
      "command": "npx",
      "args": [
        "-y",
        "@modelcontextprotocol/server-github"
      ],
      "env": {
        "GITHUB_PERSONAL_ACCESS_TOKEN": "AQUI_PEGA_TU_TOKEN_GHP"
      }
    }
  }
}
'@
    Set-Content -Path $mcpConfigFile -Value $mcpTemplate -Encoding UTF8
    Write-Host "   -> Creado mcp_config.json listo para configurar tu token de GitHub" -ForegroundColor Green
}

# 4. Verificar presencia de componentes clave
$components = @(
    @{ Name = "Orquestador Principal"; Path = ".agents\Agents\master_orchestrator.md" },
    @{ Name = "Constitución del Proyecto"; Path = ".agents\Rules\constitution.md" },
    @{ Name = "Flujos de Trabajo (Workflows)"; Path = ".agents\workflows" },
    @{ Name = "Estándares y Scripts"; Path = ".agents\scripts" }
)

Write-Host ""
Write-Host "Verificando integridad de componentes del ecosistema multi-agente:" -ForegroundColor Yellow
foreach ($comp in $components) {
    $fullPath = Join-Path $workspacePath $comp.Path
    if (Test-Path $fullPath) {
        Write-Host "   [OK] $($comp.Name)" -ForegroundColor Green
    } else {
        Write-Host "   [MISSING] $($comp.Name) - ($($comp.Path))" -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "===============================================================" -ForegroundColor Cyan
Write-Host " ENTORNO CONFIGURADO Y LISTO PARA USAR!                        " -ForegroundColor Green
Write-Host "===============================================================" -ForegroundColor Cyan
Write-Host ""
