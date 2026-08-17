param(
    [Parameter(Mandatory=$false)][string]$OutputPath = ".\Calendario_Laboral_Valencia_Mayo_2026.xlsx"
)

Write-Host "Iniciando motor COM de Excel..."
$excel = New-Object -ComObject Excel.Application
$excel.Visible = 0
$excel.DisplayAlerts = 0

try {
    $workbook = $excel.Workbooks.Add()
    $worksheet = $workbook.Worksheets.Item(1)
    $worksheet.Name = "Mayo 2026"
    
    # Asegurar que se vean las líneas de cuadrícula
    $excel.ActiveWindow.DisplayGridlines = $true

    # --- 1. TITULO PRINCIPAL ---
    # Fila 2: Título elegante
    $worksheet.Cells.Item(2, 2) = "CONTROL DE IMPUTACIONES - MAYO 2026"
    $titleRange = $worksheet.Range("B2:AJ2")
    $titleRange.Merge()
    $titleRange.Font.Name = "Segoe UI"
    $titleRange.Font.Size = 16
    $titleRange.Font.Bold = $true
    $titleRange.Font.Color = 16777215 # Blanco
    $titleRange.Interior.Color = 7949855 # Azul Oscuro HIBERUS (RGB 31, 78, 121)
    $titleRange.HorizontalAlignment = -4108 # xlCenter
    $titleRange.VerticalAlignment = -4108 # xlCenter
    $worksheet.Rows.Item(2).RowHeight = 35

    # Fila 3: Subtítulo / Contexto
    $worksheet.Cells.Item(3, 2) = "Calendario Laboral de Valencia | 4 Personas para Imputaciones a Cliente"
    $subTitleRange = $worksheet.Range("B3:AJ3")
    $subTitleRange.Merge()
    $subTitleRange.Font.Name = "Segoe UI"
    $subTitleRange.Font.Size = 10
    $subTitleRange.Font.Italic = $true
    $subTitleRange.Font.Color = 5855577 # Gris Oscuro (#595959)
    $subTitleRange.HorizontalAlignment = -4108 # xlCenter
    $subTitleRange.VerticalAlignment = -4108 # xlCenter
    $worksheet.Rows.Item(3).RowHeight = 20

    # --- 2. CABECERA DE LA TABLA (Fila 5) ---
    $headers = @("Empleado / Recurso", "Cliente / Proyecto", "Total Horas")
    
    # Días de Mayo 2026: 1 al 31
    # 1 de Mayo 2026 es Viernes
    $daysOfWeek = @("V", "S", "D", "L", "M", "X", "J")
    $daysList = @()
    for ($d = 1; $d -le 31; $d++) {
        $index = ($d - 1) % 7
        $wd = $daysOfWeek[$index]
        $daysList += "$d`n($wd)"
    }
    
    $allHeaders = $headers + $daysList
    
    $worksheet.Rows.Item(5).RowHeight = 30
    for ($i = 0; $i -lt $allHeaders.Count; $i++) {
        $col = $i + 2 # Empezar en columna B (B=2)
        $worksheet.Cells.Item(5, $col) = [string]$allHeaders[$i]
        
        $cell = $worksheet.Cells.Item(5, $col)
        $cell.Font.Name = "Segoe UI"
        $cell.Font.Size = 9
        $cell.Font.Bold = $true
        $cell.Font.Color = 16777215 # Blanco
        $cell.Interior.Color = 10250024 # Gris azulado oscuro (#285B88)
        $cell.HorizontalAlignment = -4108 # xlCenter
        $cell.VerticalAlignment = -4108 # xlCenter
        $cell.WrapText = $true
    }

    # --- 3. GENERAR FILAS PARA 4 PERSONAS (Filas 6 a 9) ---
    $personas = @("Empleado 1 (Valencia)", "Empleado 2 (Valencia)", "Empleado 3 (Valencia)", "Empleado 4 (Valencia)")
    
    for ($r = 0; $r -lt 4; $r++) {
        $row = $r + 6
        $worksheet.Rows.Item($row).RowHeight = 24
        
        # Nombre de persona y cliente por defecto
        $worksheet.Cells.Item($row, 2) = $personas[$r]
        $worksheet.Cells.Item($row, 3) = "Cliente Ejemplo"
        
        # Fórmula de Suma Total (Columna D = Columna 4)
        # Los días empiezan en la columna E (columna 5) hasta AJ (columna 36)
        $worksheet.Cells.Item($row, 4) = "=SUM(E$row:AJ$row)"
        
        # Formato de celda de Suma
        $sumCell = $worksheet.Cells.Item($row, 4)
        $sumCell.Font.Name = "Segoe UI"
        $sumCell.Font.Bold = $true
        $sumCell.Font.Color = 32896 # Verde oscuro para destacar totales
        $sumCell.Interior.Color = 15592685 # Verde muy claro (#EDF7ED)
        $sumCell.HorizontalAlignment = -4108 # xlCenter
        
        # Formato general de datos para la fila
        $personCell = $worksheet.Cells.Item($row, 2)
        $personCell.Font.Name = "Segoe UI"
        $personCell.Font.Bold = $true
        
        $clientCell = $worksheet.Cells.Item($row, 3)
        $clientCell.Font.Name = "Segoe UI"

        # Colorear y rellenar los días de mayo
        for ($d = 1; $d -le 31; $d++) {
            $col = $d + 4 # Día 1 está en la columna 5 (E)
            $cell = $worksheet.Cells.Item($row, $col)
            $cell.Font.Name = "Segoe UI"
            $cell.HorizontalAlignment = -4108 # xlCenter
            
            # Determinar tipo de día
            # 1 de mayo es Viernes (Festivo - Fiesta del Trabajo)
            if ($d -eq 1) {
                # Festivo de Valencia (1 de Mayo - Fiesta del Trabajo)
                $cell.Interior.Color = 13421823 # Rojo muy claro suave (#FFCCCC)
                $cell.Value = "Festivo"
                $cell.Font.Color = 2105695 # Texto rojo oscuro (#5F2120)
                $cell.Font.Size = 8
                $cell.Font.Bold = $true
            } else {
                # Fines de semana: sábados y domingos
                # Día 2 es Sábado, Día 3 es Domingo, etc.
                $dayOfWeekNum = ($d - 1) % 7
                if ($dayOfWeekNum -eq 1 -or $dayOfWeekNum -eq 2) {
                    # Sábado (1) o Domingo (2)
                    $cell.Interior.Color = 15000808 # Gris suave
                    $cell.Value = if ($dayOfWeekNum -eq 1) { "Sáb" } else { "Dom" }
                    $cell.Font.Color = 7895160 # Gris oscuro
                    $cell.Font.Size = 8
                } else {
                    # Laborable
                    $cell.Value = 8 # 8 horas por defecto en días laborables
                    $cell.Font.Color = 0
                }
            }
        }
    }

    # --- 4. FORMATO DE BORDES Y AJUSTES FINALES ---
    # Rango de la tabla: B5 a AJ9
    $tableRange = $worksheet.Range("B5:AJ9")
    
    # Bordes finos
    foreach ($borderId in 7..10) { # xlEdgeLeft, xlEdgeTop, xlEdgeBottom, xlEdgeRight
        $border = $tableRange.Borders.Item($borderId)
        $border.LineStyle = 1 # xlContinuous
        $border.Weight = 2 # xlThin
        $border.Color = 12632256 # Gris (#C0C0C0)
    }
    foreach ($borderId in 11..12) { # xlInsideHorizontal, xlInsideVertical
        $border = $tableRange.Borders.Item($borderId)
        $border.LineStyle = 1 # xlContinuous
        $border.Weight = 2 # xlThin
        $border.Color = 14211288 # Gris claro (#D9D9D9)
    }

    # Auto-ajustar las columnas A y B y C
    $worksheet.Columns.Item(2).ColumnWidth = 26 # Empleado
    $worksheet.Columns.Item(3).ColumnWidth = 18 # Cliente
    $worksheet.Columns.Item(4).ColumnWidth = 12 # Total Horas
    
    # Ancho uniforme para los días del mes
    for ($col = 5; $col -le 35; $col++) {
        $worksheet.Columns.Item($col).ColumnWidth = 7.5
    }
    # Último día
    $worksheet.Columns.Item(36).ColumnWidth = 7.5

    # Guardar
    if (Test-Path $OutputPath) {
        Remove-Item $OutputPath -Force -ErrorAction SilentlyContinue
    }
    $workbook.SaveAs($OutputPath, 51) # 51 = xlOpenXMLWorkbook
    $workbook.Close()
    Write-Host "¡Archivo Excel creado con éxito en $OutputPath!"

} catch {
    Write-Error "Ocurrió un error creando el Excel: $_"
    if ($null -ne $workbook) { $workbook.Close($false) }
} finally {
    $excel.Quit()
    [System.Runtime.InteropServices.Marshal]::ReleaseComObject($excel) | Out-Null
    [System.GC]::Collect()
    [System.GC]::WaitForPendingFinalizers()
}
