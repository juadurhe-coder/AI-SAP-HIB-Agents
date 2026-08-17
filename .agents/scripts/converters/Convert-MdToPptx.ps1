param(
    [Parameter(Mandatory=$true)][string]$InputFilePath,
    [Parameter(Mandatory=$true)][string]$OutputFilePath
)

if (-not (Test-Path $InputFilePath)) {
    Write-Error "El archivo de entrada no existe: $InputFilePath"
    return
}

Write-Host "Iniciando motor COM de PowerPoint..."
$pptApp = New-Object -ComObject PowerPoint.Application
# $pptApp.Visible = 0 # msoFalse (Causa excepciones en algunos entornos)

try {
    $presentation = $pptApp.Presentations.Add()
    # 1. Leer el archivo y dividir por '---' para detectar diapositivas
    $content = Get-Content -Raw -Path $InputFilePath
    $slidesData = $content -split "---"

    $slideIndex = 1
    foreach ($slideRaw in $slidesData) {
        $slideText = $slideRaw.Trim()
        if ([string]::IsNullOrWhitespace($slideText)) { continue }

        # 2. Extraer Título (la primera línea que empiece con '#')
        $lines = $slideText -split "\r?\n"
        $title = "Título Pendiente"
        $bodyLines = New-Object System.Collections.Generic.List[string]

        foreach ($line in $lines) {
            $trimmed = $line.Trim()
            if ($trimmed -match "^#+\s*(.*)") {
                $title = $matches[1]
            } elseif ($trimmed -ne "") {
                # Manejar limpieza de Markdown simple
                $cleanLine = $trimmed -replace "^[\*\-\+]\s*", "• "
                $bodyLines.Add($cleanLine)
            }
        }

        # 3. Crear Diapositiva (Layout 2: Title and Content)
        # Layouts: 1=Title ONLY, 2=Common Title + Text
        $layout = if ($slideIndex -eq 1) { 1 } else { 2 }
        $slide = $presentation.Slides.Add($slideIndex, $layout)

        # Asignar título
        $slide.Shapes.Title.TextFrame.TextRange.Text = $title

        # Asignar contenido (si existe y no es la primera)
        if ($bodyLines.Count -gt 0 -and $slide.Shapes.Count -ge 2) {
            $bodyText = $bodyLines -join "`r`n"
            $slide.Shapes.Item(2).TextFrame.TextRange.Text = $bodyText
        }

        $slideIndex++
    }

    # 4. Guardar archivo PPTX
    Write-Host "Generando y guardando archivo PPTX en $OutputFilePath..."
    # Formato 24 = ppSaveAsOpenXMLPresentation (.pptx)
    $presentation.SaveAs($OutputFilePath)
    $presentation.Close()

    Write-Host "¡Archivo PowerPoint generado con éxito ($($slideIndex-1) diapositivas)!"
} catch {
    Write-Error "Fallo durante la automatización de PowerPoint: $_"
} finally {
    $pptApp.Quit()
    [System.Runtime.Interopservices.Marshal]::ReleaseComObject($pptApp) | Out-Null
    [System.GC]::Collect()
    [System.GC]::WaitForPendingFinalizers()
}
