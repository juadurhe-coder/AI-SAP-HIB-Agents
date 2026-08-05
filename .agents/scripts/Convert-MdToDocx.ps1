param(
    [Parameter(Mandatory = $true)][string]$InputFilePath,
    [Parameter(Mandatory = $true)][string]$OutputFilePath
)

Write-Host "Convirtiendo Markdown a HTML..."
$tempHtml = [System.IO.Path]::ChangeExtension($OutputFilePath, ".html")

function Convert-MarkdownToHtml {
    param([string]$mdText)
    
    $lines = $mdText -split "`r?`n"
    $htmlLines = [System.Collections.Generic.List[string]]::new()
    
    $inList = $false
    $inTable = $false
    
    foreach ($line in $lines) {
        $trimmed = $line.Trim()
        
        # Table parsing
        if ($trimmed -like "|*|") {
            if ($inList) {
                $htmlLines.Add("</ul>")
                $inList = $false
            }
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
            } else {
                $htmlLines.Add("<tr>")
                foreach ($col in $cols) {
                    $htmlLines.Add("<td>$($col.Trim())</td>")
                }
                $htmlLines.Add("</tr>")
            }
            continue
        } else {
            if ($inTable) {
                $htmlLines.Add("</tbody>")
                $htmlLines.Add("</table>")
                $inTable = $false
            }
        }
        
        # Headers
        if ($trimmed -match '^#\s+(.*)$') {
            if ($inList) { $htmlLines.Add("</ul>"); $inList = $false }
            $htmlLines.Add("<h1>$($Matches[1])</h1>")
        } elseif ($trimmed -match '^##\s+(.*)$') {
            if ($inList) { $htmlLines.Add("</ul>"); $inList = $false }
            $htmlLines.Add("<h2>$($Matches[1])</h2>")
        } elseif ($trimmed -match '^###\s+(.*)$') {
            if ($inList) { $htmlLines.Add("</ul>"); $inList = $false }
            $htmlLines.Add("<h3>$($Matches[1])</h3>")
        } elseif ($trimmed -match '^####\s+(.*)$') {
            if ($inList) { $htmlLines.Add("</ul>"); $inList = $false }
            $htmlLines.Add("<h4>$($Matches[1])</h4>")
        }
        # Horizontal Rule
        elseif ($trimmed -eq '---') {
            if ($inList) { $htmlLines.Add("</ul>"); $inList = $false }
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
            if ($inList) {
                $htmlLines.Add("</ul>")
                $inList = $false
            }
        }
        # Blockquote
        elseif ($trimmed -match '^>\s+(.*)$') {
            if ($inList) { $htmlLines.Add("</ul>"); $inList = $false }
            $htmlLines.Add("<blockquote>$($Matches[1])</blockquote>")
        }
        # Normal line
        else {
            if ($inList) {
                $htmlLines.Add("</ul>")
                $inList = $false
            }
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

if (Get-Command npx -ErrorAction SilentlyContinue) {
    # Usar Node/Marked si está disponible
    npx -y marked "$InputFilePath" -o "$tempHtml"
} else {
    # Fallback pure PowerShell converter
    Write-Host "Node/npx no detectado. Utilizando motor de conversión interno de PowerShell..."
    $mdContent = [System.IO.File]::ReadAllText($InputFilePath, [System.Text.Encoding]::UTF8)
    $htmlContent = Convert-MarkdownToHtml $mdContent
    [System.IO.File]::WriteAllText($tempHtml, $htmlContent, [System.Text.Encoding]::UTF8)
}

Write-Host "Envolviendo en un estándar HTML válido para Word..."
$content = [System.IO.File]::ReadAllText($tempHtml, [System.Text.Encoding]::UTF8)
$styleBlock = @"
<style>
    body {
        font-family: 'Calibri', 'Arial', sans-serif;
        color: #333333;
        line-height: 1.5;
        font-size: 11pt;
    }
    h1, h2, h3, h4, h5, h6 {
        color: #2E74B5;
        font-family: 'Calibri Light', 'Arial', sans-serif;
        font-weight: bold;
        margin-top: 18pt;
        margin-bottom: 6pt;
    }
    h1 {
        font-size: 20pt;
        border-bottom: 2px solid #2E74B5;
        padding-bottom: 4px;
        margin-top: 24pt;
    }
    h2 {
        font-size: 16pt;
        border-bottom: 1px solid #D3D3D3;
        padding-bottom: 3px;
        margin-top: 20pt;
    }
    h3 {
        font-size: 13pt;
        margin-top: 16pt;
    }
    table {
        border-collapse: collapse;
        width: 100%;
        margin: 8pt 0;
        font-family: 'Calibri', sans-serif;
        line-height: 1.15;
    }
    th {
        background-color: #2E74B5;
        color: #ffffff;
        font-weight: bold;
        text-align: left;
        padding: 4px 6px;
        border: 1px solid #1F4E79;
        font-size: 9.5pt;
    }
    td {
        padding: 4px 6px;
        border: 1px solid #D3D3D3;
        font-size: 9pt;
        vertical-align: top;
    }
    tr:nth-child(even) td {
        background-color: #F9FBFD;
    }
    blockquote {
        margin: 10pt 0 10pt 15pt;
        border-left: 4.5pt solid #2E74B5;
        padding-left: 10pt;
        color: #555555;
        font-style: italic;
    }
    code {
        font-family: 'Consolas', 'Courier New', monospace;
        background-color: #F4F4F4;
        padding: 2px 4px;
        font-size: 9.5pt;
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
        padding: 10px;
        border: 1px solid #D3D3D3;
        margin: 12pt 0;
    }
    ul, ol {
        margin-top: 4pt;
        margin-bottom: 8pt;
        padding-left: 20pt;
    }
    li {
        margin-bottom: 3pt;
    }
</style>
"@
$corporateHeaderPath = Join-Path $PSScriptRoot "..\resources\corporate_header.png"

# Reemplazar de forma robusta los marcadores de salto de página por la clase nativa de Word
$content = $content -replace '<p>\[PAGE_BREAK\]</p>', '<br style="page-break-before: always;" class="MSOWordPageBreak" />'
$content = $content -replace "\[PAGE_BREAK\]", '<br style="page-break-before: always;" class="MSOWordPageBreak" />'
$content = $content -replace '<div style="page-break-before: always;"></div>', '<br style="page-break-before: always;" class="MSOWordPageBreak" />'
$content = $content -replace '<div style="page-break-before: always;"><\/div>', '<br style="page-break-before: always;" class="MSOWordPageBreak" />'

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
$matches = [regex]::Matches($content, '<img\s+[^>]*src=["'']([^"'']+)["''][^>]*>')
foreach ($match in $matches) {
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
    # Abriendo como solo lectura
    $wordDoc = $word.Documents.Open($tempHtml, $false, $true)
    
    # Aplicar Autoajuste dinámico al contenido para todas las tablas
    foreach ($table in $wordDoc.Tables) {
        $table.AllowAutoFit = $true
        # wdAutoFitContent = 1 (Ajusta el ancho de columna automáticamente al contenido)
        $table.AutoFitBehavior(1)
    }
    
    # Formato 16 = wdFormatXMLDocument (.docx)
    $wordDoc.SaveAs([ref]$OutputFilePath, [ref]16)
    $wordDoc.Close()
    Write-Host "¡Documento Word ($OutputFilePath) generado con éxito!"
}
catch {
    Write-Error "Fallo al convertir con Word: $_"
}
finally {
    $word.Quit()
    [System.Runtime.Interopservices.Marshal]::ReleaseComObject($word) | Out-Null
    
    # Limpiar
    if (Test-Path $tempHtml) { Remove-Item $tempHtml -Force }
}
