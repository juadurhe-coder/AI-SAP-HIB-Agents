param(
    [Parameter(Mandatory = $true)][string]$InputFilePath,
    [Parameter(Mandatory = $true)][string]$OutputFilePath
)

Write-Host "Convirtiendo Markdown a HTML..."
$tempHtml = [System.IO.Path]::Combine([System.IO.Path]::GetTempPath(), "AGY_MD_" + [System.Guid]::NewGuid().ToString("N") + ".html")

function Convert-MarkdownToHtml {
    param([string]$mdText)
    
    $lines = $mdText -split "`r?`n"
    $htmlLines = [System.Collections.Generic.List[string]]::new()
    
    $inList = $false
    $inTable = $false
    
    # DRY helper: cierra lista abierta si existe (elimina duplicación del patrón if($inList))
    $closeList = {
        if ($inList) {
            $htmlLines.Add("</ul>")
            Set-Variable -Name 'inList' -Value $false -Scope 1
        }
    }
    
    foreach ($line in $lines) {
        $trimmed = $line.Trim()
        
        # Table parsing
        if ($trimmed.StartsWith('|')) {
            & $closeList
            if ($trimmed -match '^\|\s*:\s*-') {
                continue
            }
            $cols = $trimmed.Split('|') | Where-Object { $_ -ne "" }
            if (-not $inTable) {
                $htmlLines.Add("<table>")
                $htmlLines.Add("<thead>")
                $htmlLines.Add("<tr>")
                foreach ($col in $cols) {
                    $htmlLines.Add("<th>$($col.Trim())</th>")
                }
                $htmlLines.Add("</tr>")
                $htmlLines.Add("</thead>")
                $htmlLines.Add("<tbody>")
                $inTable = $true
            }
            else {
                $htmlLines.Add("<tr>")
                foreach ($col in $cols) {
                    $htmlLines.Add("<td>$($col.Trim())</td>")
                }
                $htmlLines.Add("</tr>")
            }
            continue
        }
        else {
            if ($inTable) {
                $htmlLines.Add("</tbody>")
                $htmlLines.Add("</table>")
                $inTable = $false
            }
        }
        
    # Headers
    if ($trimmed -match '^#\s+(.*)$') {
        & $closeList
        $htmlLines.Add("<h1>$($Matches[1])</h1>")
    }
    elseif ($trimmed -match '^##\s+(.*)$') {
        & $closeList
        $htmlLines.Add("<h2>$($Matches[1])</h2>")
    }
    elseif ($trimmed -match '^###\s+(.*)$') {
        & $closeList
        $htmlLines.Add("<h3>$($Matches[1])</h3>")
    }
    elseif ($trimmed -match '^####\s+(.*)$') {
        & $closeList
        $htmlLines.Add("<h4>$($Matches[1])</h4>")
    }
    # Horizontal Rule
    elseif ($trimmed -eq '---') {
        & $closeList
        $htmlLines.Add("<hr />")
    }
    # Unordered List Items
    elseif ($trimmed -match '^[\*\-]\s+(.*)$') {
        if (-not $inList) {
            $htmlLines.Add("<ul>")
            $inList = $true
        }
        $htmlLines.Add("<li>$($Matches[1])</li>")
    }
    # Empty Line
    elseif ($trimmed -eq '') {
        & $closeList
    }
    # Blockquote
    elseif ($trimmed -match '^>\s+(.*)$') {
        & $closeList
        $htmlLines.Add("<blockquote>$($Matches[1])</blockquote>")
    }
    # Normal line
    else {
        & $closeList
        $htmlLines.Add("<p>$line</p>")
    }
}
    
if ($inList) { $htmlLines.Add("</ul>") }
if ($inTable) { $htmlLines.Add("</tbody></table>") }
    
$result = $htmlLines -join "`n"
    
# Inline formatting (bold, links, images, code)
$result = [regex]::Replace($result, '\*\*(.*?)\*\*', '<strong>$1</strong>')
$result = [regex]::Replace($result, '`(.*?)`', '<code>$1</code>')
$result = [regex]::Replace($result, '!\[(.*?)\]\((.*?)\)', '<img src=''$2'' alt=''$1'' />')
$result = [regex]::Replace($result, '\[(.*?)\]\((.*?)\)', '<a href=''$2''>$1</a>')
    
return $result
}

# DRY helper: convierte Markdown a HTML usando el motor interno de PowerShell
function Invoke-MarkdownFallback {
    param([string]$SourcePath, [string]$DestPath)
    $mdContent = [System.IO.File]::ReadAllText($SourcePath, [System.Text.Encoding]::UTF8)
    $htmlContent = Convert-MarkdownToHtml $mdContent
    [System.IO.File]::WriteAllText($DestPath, $htmlContent, [System.Text.Encoding]::UTF8)
}

if (Get-Command npx -ErrorAction SilentlyContinue) {
    # Usar Node/Marked si está disponible
    npx -y marked "$InputFilePath" -o "$tempHtml"
} else {
    # Fallback pure PowerShell converter
    Write-Host "Node/npx no detectado. Utilizando motor de conversión interno de PowerShell..."
    Invoke-MarkdownFallback -SourcePath $InputFilePath -DestPath $tempHtml
}

# Verificar que npx generó contenido válido; fallback si no
if (-not (Test-Path $tempHtml) -or (Get-Item $tempHtml).Length -eq 0) {
    Write-Warning "npx marked no generó contenido válido. Utilizando motor de conversión interno de PowerShell..."
    Invoke-MarkdownFallback -SourcePath $InputFilePath -DestPath $tempHtml
}

Write-Host "Envolviendo en un estándar HTML válido para Word..."
$content = [System.IO.File]::ReadAllText($tempHtml, [System.Text.Encoding]::UTF8)
$styleBlock = @"
<style>
    body {
        font-family: 'Calibri', 'Arial', sans-serif;
        color: #333333;
        line-height: 1.35;
        font-size: 10.5pt;
    }
    h1, h2, h3, h4, h5, h6 {
        color: #2E74B5;
        font-family: 'Calibri Light', 'Arial', sans-serif;
        font-weight: bold;
        margin-top: 10pt;
        margin-bottom: 3pt;
    }
    h1 {
        font-size: 16pt;
        border-bottom: 1.5px solid #2E74B5;
        padding-bottom: 2px;
        margin-top: 6pt;
        margin-bottom: 3pt;
    }
    h2 {
        font-size: 13pt;
        border-bottom: 1px solid #D3D3D3;
        padding-bottom: 2px;
        margin-top: 10pt;
        margin-bottom: 3pt;
    }
    h3 {
        font-size: 11.5pt;
        margin-top: 8pt;
        margin-bottom: 2pt;
    }
    p {
        margin-top: 2pt;
        margin-bottom: 3pt;
    }
    hr {
        margin: 4pt 0;
        border: 0;
        border-top: 1px solid #2E74B5;
    }
    table {
        border-collapse: collapse;
        width: 100%;
        margin: 4pt 0 6pt 0;
        font-family: 'Calibri', sans-serif;
        line-height: 1.15;
    }
    th {
        background-color: #2E74B5;
        color: #ffffff;
        font-weight: bold;
        text-align: left;
        padding: 3pt 5pt;
        border: 1px solid #1F4E79;
        font-size: 9pt;
    }
    td {
        padding: 2.5pt 5pt;
        border: 1px solid #D3D3D3;
        font-size: 8.5pt;
        vertical-align: middle;
    }
    tr:nth-child(even) td {
        background-color: #F9FBFD;
    }
    blockquote {
        margin: 6pt 0 6pt 10pt;
        border-left: 3.5pt solid #2E74B5;
        padding-left: 8pt;
        color: #555555;
        font-style: italic;
    }
    code {
        font-family: 'Consolas', 'Courier New', monospace;
        background-color: #F4F4F4;
        padding: 1px 3px;
        font-size: 9pt;
        border: 1px solid #E0E0E0;
    }
    td code {
        font-family: 'Consolas', monospace;
        background-color: #F2F4F7;
        color: #1F4E79;
        padding: 1px 3px;
        font-size: 8.5pt;
        border: 1px solid #D0D7DE;
    }
    pre {
        font-family: 'Consolas', 'Courier New', monospace;
        background-color: #F4F4F4;
        padding: 6px;
        border: 1px solid #D3D3D3;
        margin: 6pt 0;
    }
    ul, ol {
        margin-top: 2pt;
        margin-bottom: 4pt;
        padding-left: 18pt;
    }
    li {
        margin-bottom: 2pt;
    }
</style>
"@
$corporateHeaderPath = Join-Path $PSScriptRoot "..\..\resources\corporate_header.png"
if (-not (Test-Path $corporateHeaderPath)) {
    $corporateHeaderPath = Join-Path $PSScriptRoot "..\resources\corporate_header.png"
}

# Reemplazar de forma robusta los marcadores de salto de página por la clase nativa de Word
$content = $content -replace '<p>\[PAGE_BREAK\]</p>', '<br style="page-break-before: always;" class="MSOWordPageBreak" />'
$content = $content -replace "\[PAGE_BREAK\]", '<br style="page-break-before: always;" class="MSOWordPageBreak" />'
$content = $content -replace '<div style="page-break-before: always;"></div>', '<br style="page-break-before: always;" class="MSOWordPageBreak" />'
$content = $content -replace '<div style="page-break-before: always;"><\/div>', '<br style="page-break-before: always;" class="MSOWordPageBreak" />'

# Sanitizar símbolos matemáticos LaTeX comunes a caracteres Unicode limpios
$content = $content.Replace('$\rightarrow$', [string][char]0x2192)
$content = $content.Replace('\rightarrow', [string][char]0x2192)
$content = $content.Replace('$\leftarrow$', [string][char]0x2190)
$content = $content.Replace('\leftarrow', [string][char]0x2190)
$content = $content.Replace('$\Rightarrow$', [string][char]0x2794)
$content = $content.Replace('\Rightarrow', [string][char]0x2794)
$content = $content.Replace('$\le$', [string][char]0x2264)
$content = $content.Replace('$\ge$', [string][char]0x2265)
$content = $content.Replace('$\neq$', [string][char]0x2260)


# Si el markdown contiene una cabecera, se usará. Si no, se inyecta la corporativa por defecto
if ((Test-Path $corporateHeaderPath) -and ($content -notmatch "header_image\.png" -and $content -notmatch "corporate_header\.png")) {
    Write-Host "Inyectando cabecera corporativa automática al documento..."
    $content = "<p><img src='$corporateHeaderPath' alt='Corporate Header' /></p>" + $content
}

# --- EMBEBIDO DE IMÁGENES EN BASE64 ---
# Buscamos todas las imágenes en el HTML para convertirlas a base64 inline y evitar rutas locales rotas
Write-Host "Incrustando imágenes locales como Base64 para que el Word sea autocontenido..."
$inputDir = [System.IO.Path]::GetDirectoryName([System.IO.Path]::GetFullPath($InputFilePath))

# Encontrar coincidencias de img src
$imgMatches = [regex]::Matches($content, '<img\s+[^>]*src=["'']([^"'']+)["''][^>]*>')
foreach ($match in $imgMatches) {
    $rawSrc = $match.Groups[1].Value
    $resolvedPath = $rawSrc

    # Si es ruta relativa, resolverla respecto al directorio del MD
    if (-not [System.IO.Path]::IsPathRooted($resolvedPath)) {
        $resolvedPath = [System.IO.Path]::Combine($inputDir, $resolvedPath)
    }
    $resolvedPath = [System.IO.Path]::GetFullPath($resolvedPath)

    if (Test-Path $resolvedPath) {
        Write-Host "Embebiendo imagen: $resolvedPath"
        $extension = [System.IO.Path]::GetExtension($resolvedPath).ToLower().Replace(".", "")
        if ($extension -eq "jpg") { $extension = "jpeg" }
        
        try {
            $bytes = [System.IO.File]::ReadAllBytes($resolvedPath)
            $base64 = [Convert]::ToBase64String($bytes)
            $dataUri = "data:image/$extension;base64,$base64"
            
            # Reemplazar la ruta local por el Data URI Base64
            $content = $content.Replace($rawSrc, $dataUri)
        }
        catch {
            Write-Warning "No se pudo convertir la imagen a Base64: $resolvedPath. Error: $_"
        }
    }
    else {
        Write-Warning "No se encontró el archivo de imagen en la ruta física: $resolvedPath"
    }
}

$html = "<!DOCTYPE html><html><head><meta charset='utf-8'>$styleBlock</head><body>$content</body></html>"
[System.IO.File]::WriteAllText($tempHtml, $html, [System.Text.Encoding]::UTF8)

Write-Host "Lanzando motor COM de Word para serializar un documento DOCX nativo..."
$word = New-Object -ComObject Word.Application
$word.Visible = $false
$word.DisplayAlerts = 'wdAlertsNone'

try {
    # Abriendo como solo lectura con ruta absoluta
    $fullTempHtml = [System.IO.Path]::GetFullPath($tempHtml)
    $wordDoc = $word.Documents.Open($fullTempHtml, $false, $true)
    
    # Aplicar Autoajuste dinámico al contenido para todas las tablas
    foreach ($table in $wordDoc.Tables) {
        $table.AllowAutoFit = $true
        # wdAutoFitContent = 1 (Ajusta el ancho de columna automáticamente al contenido)
        $table.AutoFitBehavior(1)
    }
    
    # Formato 16 = wdFormatXMLDocument (.docx)
    # Escalar la imagen de cabecera corporativa al 100% del ancho imprimible (468 pt / 16.5 cm)
    if ($wordDoc.InlineShapes.Count -gt 0) {
        try {
            $firstShape = $wordDoc.InlineShapes.Item(1)
            if ($firstShape.Width -ne 468 -and $firstShape.Width -gt 0) {
                $aspectRatio = [single]($firstShape.Height / $firstShape.Width)
                $firstShape.Width = [single]468
                $firstShape.Height = [single](468 * $aspectRatio)
            }
        } catch {
            Write-Warning "No se pudo escalar la forma inicial: $_"
        }
    }


    # Cargar metadatos del proyecto (.project_metadata.json) si existe en la carpeta del documento
    $metaPath = Join-Path $inputDir ".project_metadata.json"
    $headerLeft = "Hiberus Consulting"
    $headerRight = "SAP S/4HANA"
    $footerLeft = "Hiberus IT Development Services"
    $footerRight = ""
    
    if (Test-Path $metaPath) {
        try {
            $jsonRaw = [System.IO.File]::ReadAllText($metaPath, [System.Text.Encoding]::UTF8)
            $meta = $jsonRaw | ConvertFrom-Json
            if ($meta.client -and $meta.initiative_type) { $headerLeft = "$($meta.client) | $($meta.initiative_type)" }
            elseif ($meta.client) { $headerLeft = "$($meta.client)" }
            
            if ($meta.sap_module -and $meta.sap_environment) { $headerRight = "$($meta.sap_module) - $($meta.sap_environment)" }
            elseif ($meta.sap_module) { $headerRight = "$($meta.sap_module)" }
            
            if ($meta.author) { $footerLeft = "$($meta.author)" }
            if ($meta.project_id -and $meta.ticket_number) { $footerRight = "$($meta.project_id) [#$($meta.ticket_number)]" }
            elseif ($meta.project_id) { $footerRight = "$($meta.project_id)" }
        }
        catch {
            Write-Warning "No se pudieron procesar los metadatos de ${metaPath}: $_"
        }
    }

    # Configurar Encabezado y Pie de Página estilo SAP / Hiberus en todas las secciones
    foreach ($section in $wordDoc.Sections) {
        # Encabezado (Header) - Tabulacion derecha exacta (468 pt) y linea inferior
        $headerRange = $section.Headers.Item(1).Range # wdHeaderFooterPrimary = 1
        $headerRange.Text = "$headerLeft`t$headerRight"
        $headerRange.Font.Name = "Calibri"
        $headerRange.Font.Size = 8.5
        $headerRange.Font.Bold = 1
        
        # Limpiar tabulaciones por defecto y añadir Tabulación Derecha al margen (468 pt)
        $headerRange.ParagraphFormat.TabStops.ClearAll()
        $headerRange.ParagraphFormat.TabStops.Add(468, 2) | Out-Null # wdAlignTabRight = 2
        
        # Borde inferior fino en el párrafo del encabezado
        try {
            $headerRange.ParagraphFormat.Borders.Item(-3).LineStyle = 1 # wdBorderBottom = -3
            $headerRange.ParagraphFormat.Borders.Item(-3).LineWidth = 4 # 0.5 pt
        }
        catch [System.Exception] {
            # Ignorar si la propiedad de bordes no se aplica en la plantilla o sección
            $null = $_
        }
        
        # Pie de página (Footer)
        $footerRange = $section.Footers.Item(1).Range # wdHeaderFooterPrimary = 1
        $footerRange.ParagraphFormat.TabStops.ClearAll()
        $footerRange.ParagraphFormat.TabStops.Add(234, 1) | Out-Null # Tabulación centro (234 pt)
        $footerRange.ParagraphFormat.TabStops.Add(468, 2) | Out-Null # Tabulación derecha (468 pt)
        
        $footerRange.Text = "$footerLeft`tPagina "
        $footerRange.Font.Name = "Calibri"
        $footerRange.Font.Size = 8.5
        
        # Insertar campo dinámico de número de página de Word (wdFieldPage = 33)
        $pRange = $footerRange.Duplicate
        $pRange.Collapse(0) # wdCollapseEnd = 0
        $wordDoc.Fields.Add($pRange, 33) | Out-Null
        
        # Añadir pestaña de tabulación derecha para cliente y consultora
        $pRangeEnd = $footerRange.Duplicate
        $pRangeEnd.Collapse(0)
        $pRangeEnd.Text = "`t$footerRight"
    }

    # Formato 16 = wdFormatXMLDocument (.docx)
    $fullOutputPath = [System.IO.Path]::GetFullPath($OutputFilePath)
    $outputDir = [System.IO.Path]::GetDirectoryName($fullOutputPath)
    $outputFileName = [System.IO.Path]::GetFileName($fullOutputPath)
    
    # Archivar dinámicamente cualquier versión anterior (.docx con sufijos decimales/enteros ej: _v1.1, _1.2, _v2.1, _v3.1.0, _FINAL, _copia) en 99_Archive/
    $baseName = [System.IO.Path]::GetFileNameWithoutExtension($fullOutputPath)
    $cleanBaseName = $baseName -replace '(_v\d+(\.\d+)*|_FINAL|_copia)$', ''
    
    $archiveDir = Join-Path $outputDir "99_Archive"
    [array]$existingVersions = @(Get-ChildItem -Path $outputDir -File -Filter "${cleanBaseName}*.docx" | Where-Object { $_.FullName -ne $fullOutputPath })
    
    if ($existingVersions.Count -gt 0 -or (Test-Path -LiteralPath $fullOutputPath)) {
        if (-not (Test-Path -LiteralPath $archiveDir)) {
            New-Item -ItemType Directory -Path $archiveDir -Force | Out-Null
        }
        if (Test-Path -LiteralPath $fullOutputPath) {
            $archiveTarget = Join-Path $archiveDir $outputFileName
            Move-Item -LiteralPath $fullOutputPath -Destination $archiveTarget -Force -ErrorAction SilentlyContinue
        }
        foreach ($oldFile in $existingVersions) {
            Write-Host "Archivando versión obsoleta detectada: $($oldFile.Name)"
            $oldArchiveTarget = Join-Path $archiveDir $oldFile.Name
            Move-Item -LiteralPath $oldFile.FullName -Destination $oldArchiveTarget -Force -ErrorAction SilentlyContinue
        }
    }

    $wordDoc.SaveAs([ref]$fullOutputPath, [ref]16)
    $wordDoc.Close()
    Write-Host "Documento Word ($OutputFilePath) generado con exito!"
}
catch {
    Write-Error "Fallo al convertir con Word: $_"
}
finally {
    if ($null -ne $wordDoc) { [System.Runtime.Interopservices.Marshal]::ReleaseComObject($wordDoc) | Out-Null }
    if ($null -ne $word) {
        $word.Quit()
        [System.Runtime.Interopservices.Marshal]::ReleaseComObject($word) | Out-Null
    }
    [GC]::Collect()
    [GC]::WaitForPendingFinalizers()
    
    # Limpiar
    if (Test-Path $tempHtml) { Remove-Item $tempHtml -Force -ErrorAction SilentlyContinue }
}
