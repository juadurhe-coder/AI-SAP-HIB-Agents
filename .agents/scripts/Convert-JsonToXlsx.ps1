param(
    [Parameter(Mandatory=$true)][string]$InputFilePath,
    [Parameter(Mandatory=$true)][string]$OutputFilePath
)

if (-not (Test-Path $InputFilePath)) {
    Write-Error "El archivo de entrada no existe: $InputFilePath"
    return
}

Write-Host "Cargando datos JSON desde $InputFilePath (con codificación UTF8)..."
$jsonData = Get-Content -Raw -Encoding UTF8 -Path $InputFilePath | ConvertFrom-Json

if ($null -eq $jsonData -or $jsonData.Count -eq 0) {
    Write-Warning "El archivo JSON está vacío o no contiene un array de objetos."
    return
}

Write-Host "Iniciando motor COM de Excel..."
$excel = New-Object -ComObject Excel.Application
$excel.Visible = 0 # msoFalse
$excel.DisplayAlerts = 0 

try {
    $workbook = $excel.Workbooks.Add()
    $worksheet = $workbook.Worksheets.Item(1)
    
    # 1. Extraer encabezados del primer objeto
    $headers = $jsonData[0].PSObject.Properties.Name
    for ($i = 0; $i -lt $headers.Count; $i++) {
        $worksheet.Cells.Item(1, $i + 1) = [string]$headers[$i]
        $worksheet.Cells.Item(1, $i + 1).Font.Bold = $true
    }

    # 2. Llenar datos
    Write-Host "Escribiendo $($jsonData.Count) filas..."
    $rowIndex = 2
    foreach ($item in $jsonData) {
        for ($colIndex = 0; $colIndex -lt $headers.Count; $colIndex++) {
            $propName = $headers[$colIndex]
            $val = $item.$propName
            
            if ($null -eq $val) { $val = "" }
            elseif ($val -is [PSCustomObject]) { $val = $val | ConvertTo-Json -Compress }
            
            # Asignación sin .Value explicito para dejar que PS maneje el default property
            $worksheet.Cells.Item($rowIndex, $colIndex + 1) = $val
        }
        $rowIndex++
    }

    # 3. Formato final: Diseño manual de nivel premium ultra-robusto
    $usedRange = $worksheet.UsedRange
    $rowCount = $jsonData.Count + 1
    $colCount = $headers.Count

    # --- 3.1 Formatear Cabecera ---
    $headerRange = $worksheet.Range($worksheet.Cells.Item(1, 1), $worksheet.Cells.Item(1, $colCount))
    $headerRange.Font.Name = "Segoe UI"
    $headerRange.Font.Size = 11
    $headerRange.Font.Bold = $true
    $headerRange.Font.Color = 16777215 # Blanco
    $headerRange.Interior.Color = 7949855 # Azul oscuro premium (RGB 31, 78, 121)
    $headerRange.RowHeight = 28
    $headerRange.VerticalAlignment = -4108 # xlCenter
    $headerRange.HorizontalAlignment = -4108 # xlCenter

    # --- 3.2 Formatear Datos ---
    # Aplicar fuente general a todo el rango usado
    $usedRange.Font.Name = "Segoe UI"
    $usedRange.Font.Size = 10
    $usedRange.VerticalAlignment = -4108 # xlCenter

    # Aplicar Zebra y Altura de Fila de forma segura
    for ($row = 2; $row -le $rowCount; $row++) {
        $rowRange = $worksheet.Rows.Item($row)
        $rowRange.RowHeight = 22
        
        # Zebra striping (Filas alternas)
        if ($row % 2 -eq 0) {
            # Aplicar color de cebra solo a las celdas con datos, no a toda la fila
            $dataRowRange = $worksheet.Range($worksheet.Cells.Item($row, 1), $worksheet.Cells.Item($row, $colCount))
            $dataRowRange.Interior.Color = 16250098 # Gris azulado ultra claro (#F2F4F7)
        }
    }

    # Alinear columnas específicas, estilos condicionales y listas desplegables (Data Validation)
    for ($col = 1; $col -le $colCount; $col++) {
        $headerVal = [string]$worksheet.Cells.Item(1, $col).Text
        $colRange = $worksheet.Range($worksheet.Cells.Item(2, $col), $worksheet.Cells.Item($rowCount, $col))
        
        # Centrar columnas cortas
        if ($headerVal -eq "ID" -or $headerVal -eq "Priority" -or $headerVal -eq "Status" -or $headerVal -eq "Deadline" -or $headerVal -eq "Dependencies") {
            $colRange.HorizontalAlignment = -4108 # xlCenter
        }

        # --- Agregar Listas Desplegables (Ajustado a ';' por configuración regional de Excel en español)
        if ($headerVal -eq "Status") {
            try {
                $validation = $colRange.Validation
                $validation.Delete()
                # xlValidateList = 3, xlValidAlertStop = 1, xlBetween = 1
                $validation.Add(3, 1, 1, "Pending;In Progress;Completed")
                $validation.IgnoreBlank = $true
                $validation.InCellDropdown = $true
            } catch {
                Write-Warning "No se pudo agregar desplegables a Status: $_"
            }
        }

        if ($headerVal -eq "Priority") {
            try {
                $validation = $colRange.Validation
                $validation.Delete()
                $validation.Add(3, 1, 1, "High;Medium;Low")
                $validation.IgnoreBlank = $true
                $validation.InCellDropdown = $true
            } catch {
                Write-Warning "No se pudo agregar desplegables a Priority: $_"
            }
        }

        # --- Estilos condicionales de Prioridad y Estado ---
        if ($headerVal -eq "Priority" -or $headerVal -eq "Status") {
            for ($row = 2; $row -le $rowCount; $row++) {
                $cell = $worksheet.Cells.Item($row, $col)
                $cellText = [string]$cell.Text

                if ($headerVal -eq "Priority") {
                    if ($cellText -eq "High") {
                        $cell.Interior.Color = 15595261 # Rojo muy claro (#FDEEED)
                        $cell.Font.Color = 2105695      # Texto rojo oscuro (#5F2120)
                        $cell.Font.Bold = $true
                    } elseif ($cellText -eq "Medium") {
                        $cell.Interior.Color = 15070463 # Amarillo muy claro (#FFF4E5)
                        $cell.Font.Color = 15462        # Texto naranja (#663C00)
                        $cell.Font.Bold = $true
                    } elseif ($cellText -eq "Low") {
                        $cell.Interior.Color = 15592685 # Verde muy claro (#EDF7ED)
                        $cell.Font.Color = 2115102      # Texto verde oscuro (#1E4620)
                    }
                }

                if ($headerVal -eq "Status") {
                    if ($cellText -eq "In Progress") {
                        $cell.Interior.Color = 16773862 # Azul claro (#E6F2FF)
                        $cell.Font.Color = 8389120      # Texto azul oscuro (#004280)
                        $cell.Font.Bold = $true
                    } elseif ($cellText -eq "Completed" -or $cellText -eq "Resolved") {
                        $cell.Interior.Color = 15073254 # Verde claro (#E6F5E6)
                        $cell.Font.Color = 26112        # Texto verde (#006622)
                        $cell.Font.Bold = $true
                    } elseif ($cellText -eq "Pending") {
                        $cell.Interior.Color = 16119285 # Gris muy claro (#F5F5F5)
                        $cell.Font.Color = 8421504      # Texto gris oscuro (#808080)
                    }
                }
            }
        }
    }

    # Auto-ajustar columnas con padding adicional para evitar cortes
    try {
        $usedRange.Columns.AutoFit() | Out-Null
        for ($col = 1; $col -le $colCount; $col++) {
            $currentWidth = $worksheet.Columns.Item($col).ColumnWidth
            if ($null -ne $currentWidth -and $currentWidth -gt 0) {
                $worksheet.Columns.Item($col).ColumnWidth = $currentWidth + 4
            }
        }
    } catch {
        Write-Warning "No se pudo auto-ajustar el ancho de las columnas: $_"
    }

    # Activar autofiltro para interacción ágil
    try {
        $worksheet.UsedRange.AutoFilter() | Out-Null
    } catch {}

    # 4. Guardar (Estrategia ultra-robusta: Guardado Local Temporal + Copiado de Sistema)
    Write-Host "Guardando archivo XLSX..."
    $tempDir = [System.IO.Path]::GetTempPath()
    $tempFileName = "temp_export_" + [System.Guid]::NewGuid().ToString() + ".xlsx"
    $tempPath = [System.IO.Path]::Combine($tempDir, $tempFileName)

    try {
        Write-Host "Guardando copia de seguridad local en $tempPath..."
        $workbook.SaveAs($tempPath, 51)
        $workbook.Close()
        
        Write-Host "Transfiriendo archivo generado a la ruta destino: $OutputFilePath..."
        if (Test-Path $OutputFilePath) {
            Remove-Item $OutputFilePath -Force -ErrorAction SilentlyContinue
        }
        Copy-Item -Path $tempPath -Destination $OutputFilePath -Force
        Remove-Item $tempPath -Force -ErrorAction SilentlyContinue
        Write-Host "¡Archivo Excel generado con éxito!"
    } catch {
        Write-Error "Error en proceso de guardado y transferencia: $_"
        try { $workbook.Close() } catch {}
    }
    
    Write-Host "¡Archivo Excel generado con éxito!"
} catch {
    Write-Error "Fallo durante la automatización de Excel: $_"
} finally {
    $excel.Quit()
    [System.Runtime.Interopservices.Marshal]::ReleaseComObject($excel) | Out-Null
    [System.GC]::Collect()
    [System.GC]::WaitForPendingFinalizers()
}
