param(
    [Parameter(Mandatory=$true)][string]$OutputFilePath
)

# Fechas del proyecto
$projectStart = [datetime]"2026-05-11"
$projectEnd   = [datetime]"2026-07-20"

# Tareas
$tasks = @(
    # REALIZE Sprint 1
    [PSCustomObject]@{ Phase="REALIZE Sprint 1"; Task="Kick-Off y Param. SD (ZAR / ZRAS)";        Owner="T4S";      Start=[datetime]"2026-05-11"; End=[datetime]"2026-05-15"; Type="t4s" },
    [PSCustomObject]@{ Phase="REALIZE Sprint 1"; Task="Param. PM/CS (ZM03)";                       Owner="T4S";      Start=[datetime]"2026-05-13"; End=[datetime]"2026-05-18"; Type="t4s" },
    [PSCustomObject]@{ Phase="REALIZE Sprint 1"; Task="Config. WM - Almacen Polonia 2001";         Owner="T4S";      Start=[datetime]"2026-05-13"; End=[datetime]"2026-05-18"; Type="t4s" },
    [PSCustomObject]@{ Phase="REALIZE Sprint 1"; Task="Unit Testing T4S (OED)";                    Owner="T4S";      Start=[datetime]"2026-05-19"; End=[datetime]"2026-05-24"; Type="t4s" },
    [PSCustomObject]@{ Phase="REALIZE Sprint 1"; Task="[Oetiker] Carga Equipos SF + Integracion"; Owner="Oetiker";  Start=[datetime]"2026-05-11"; End=[datetime]"2026-05-22"; Type="client" },
    [PSCustomObject]@{ Phase="REALIZE Sprint 1"; Task="[Oetiker] Carga Parcial Master Data (OED)"; Owner="Oetiker";  Start=[datetime]"2026-05-11"; End=[datetime]"2026-05-22"; Type="client" },
    # REALIZE Sprint 2
    [PSCustomObject]@{ Phase="REALIZE Sprint 2"; Task="Transporte OED a OEQ";                      Owner="T4S";      Start=[datetime]"2026-05-25"; End=[datetime]"2026-05-26"; Type="t4s" },
    [PSCustomObject]@{ Phase="REALIZE Sprint 2"; Task="Incidencias y Ajustes Post-Transporte";     Owner="T4S";      Start=[datetime]"2026-05-27"; End=[datetime]"2026-06-03"; Type="t4s" },
    [PSCustomObject]@{ Phase="REALIZE Sprint 2"; Task="Unit Testing T4S (OEQ)";                    Owner="T4S";      Start=[datetime]"2026-05-27"; End=[datetime]"2026-06-03"; Type="t4s" },
    [PSCustomObject]@{ Phase="REALIZE Sprint 2"; Task="[Oetiker] Massive Master Data + T399A";     Owner="Oetiker";  Start=[datetime]"2026-05-25"; End=[datetime]"2026-06-07"; Type="client" },
    [PSCustomObject]@{ Phase="REALIZE Sprint 2"; Task="[Oetiker] E2E Unit Testing (OEQ)";          Owner="Oetiker";  Start=[datetime]"2026-05-28"; End=[datetime]"2026-06-07"; Type="client" },
    [PSCustomObject]@{ Phase="REALIZE Sprint 2"; Task="[Oetiker] Revision Formularios y Pricing";  Owner="Oetiker";  Start=[datetime]"2026-06-01"; End=[datetime]"2026-06-07"; Type="client" },
    [PSCustomObject]@{ Phase="REALIZE Sprint 2"; Task="[Oetiker] Formacion Usuarios Polonia";       Owner="Oetiker";  Start=[datetime]"2026-06-01"; End=[datetime]"2026-06-07"; Type="client" },
    # DEPLOY y RUN
    [PSCustomObject]@{ Phase="DEPLOY y RUN";     Task="Pruebas Integradas E2E (OEQ)";              Owner="Conjunto"; Start=[datetime]"2026-06-08"; End=[datetime]"2026-06-14"; Type="shared" },
    [PSCustomObject]@{ Phase="DEPLOY y RUN";     Task="Quality Gate Sign-Off (Hito)";              Owner="Conjunto"; Start=[datetime]"2026-06-15"; End=[datetime]"2026-06-15"; Type="milestone" },
    [PSCustomObject]@{ Phase="DEPLOY y RUN";     Task="Transporte a Productivo (OEP)";             Owner="T4S";      Start=[datetime]"2026-06-16"; End=[datetime]"2026-06-19"; Type="t4s" },
    [PSCustomObject]@{ Phase="DEPLOY y RUN";     Task="RUN: Go-Live + Hypercare";                  Owner="Conjunto"; Start=[datetime]"2026-06-22"; End=[datetime]"2026-07-17"; Type="shared" }
)

# Generar semanas
$weeks = [System.Collections.Generic.List[datetime]]::new()
$cur = $projectStart
while ($cur -le $projectEnd) { $weeks.Add($cur); $cur = $cur.AddDays(7) }
$numWeeks = $weeks.Count

# Funcion de color RGB
function cRGB($r,$g,$b){ return [int]($r -bor ($g -shl 8) -bor ($b -shl 16)) }

# Paleta de colores
$cHeader     = cRGB 30  58  138
$cT4s        = cRGB 37  99  235
$cClient     = cRGB 109 40  217
$cShared     = cRGB 4  120  87
$cMilestone  = cRGB 217 119  6
$cPhase1     = cRGB 239 246 255
$cPhase2     = cRGB 245 243 255
$cPhaseDR    = cRGB 236 253 245
$cRowEven    = cRGB 255 255 255
$cRowOdd     = cRGB 248 250 252
$cBorder     = cRGB 203 213 225
$cWhite      = cRGB 255 255 255
$cDarkText   = cRGB  30  41  59
$cGrayText   = cRGB 100 116 139
$cBarEmpty   = cRGB 241 245 249

# Layout
$COL_TASK   = 1
$COL_OWNER  = 2
$COL_START  = 3
$COL_END    = 4
$COL_GANTT  = 5
$ROW_TITLE  = 1
$ROW_HEADER = 2
$ROW_DATA   = 3

Write-Host "Iniciando Excel..."
$excel = New-Object -ComObject Excel.Application
$excel.Visible = $false
$excel.DisplayAlerts = $false

try {
    $wb = $excel.Workbooks.Add()
    $ws = $wb.Worksheets.Item(1)
    $ws.Name = "Gantt"

    # Fila titulo
    $titleEnd = $COL_GANTT + $numWeeks - 1
    $tr = $ws.Range($ws.Cells.Item($ROW_TITLE,1), $ws.Cells.Item($ROW_TITLE, $titleEnd))
    $tr.Merge() | Out-Null
    $tr.Value2 = "PTC OPL Polonia - Project Schedule (SAP Activate)   |   Kick-Off: 11 Mayo 2026   |   Go-Live: Julio 2026"
    $tr.Font.Bold = $true
    $tr.Font.Size = 12
    $tr.Font.Color = $cWhite
    $tr.Interior.Color = $cHeader
    $tr.HorizontalAlignment = -4108
    $tr.VerticalAlignment  = -4108
    $ws.Rows.Item($ROW_TITLE).RowHeight = 28

    # Encabezados fijos
    $hdrData = @{$COL_TASK="Tarea / Entregable"; $COL_OWNER="Responsable"; $COL_START="Inicio"; $COL_END="Fin"}
    foreach ($col in $hdrData.Keys) {
        $c = $ws.Cells.Item($ROW_HEADER, $col)
        $c.Value2 = $hdrData[$col]
        $c.Font.Bold = $true
        $c.Font.Size = 9
        $c.Font.Color = $cWhite
        $c.Interior.Color = $cHeader
        $c.HorizontalAlignment = -4108
        $c.VerticalAlignment  = -4108
    }

    # Encabezados de semanas (texto vertical)
    for ($w = 0; $w -lt $numWeeks; $w++) {
        $c = $ws.Cells.Item($ROW_HEADER, $COL_GANTT + $w)
        $c.Value2 = $weeks[$w].ToString("d MMM")
        $c.Font.Bold = $true
        $c.Font.Size = 8
        $c.Font.Color = $cWhite
        $c.Interior.Color = $cHeader
        $c.HorizontalAlignment = -4108
        $c.VerticalAlignment  = -4160   # xlBottom
        $c.Orientation = 90
    }
    $ws.Rows.Item($ROW_HEADER).RowHeight = 65

    # Anchos de columna
    $ws.Columns.Item($COL_TASK).ColumnWidth  = 40
    $ws.Columns.Item($COL_OWNER).ColumnWidth = 12
    $ws.Columns.Item($COL_START).ColumnWidth = 11
    $ws.Columns.Item($COL_END).ColumnWidth   = 11
    for ($w = 0; $w -lt $numWeeks; $w++) {
        $ws.Columns.Item($COL_GANTT + $w).ColumnWidth = 4.2
    }

    # Filas de datos
    $dataRow = $ROW_DATA
    $tasksByPhase = $tasks | Group-Object Phase

    foreach ($group in $tasksByPhase) {
        # Encabezado de seccion
        $sr = $ws.Range($ws.Cells.Item($dataRow, 1), $ws.Cells.Item($dataRow, $titleEnd))
        $sr.Merge() | Out-Null
        $sr.Value2 = "   " + $group.Name.ToUpper()
        $sr.Font.Bold = $true
        $sr.Font.Size = 9
        $sr.Font.Color = $cDarkText
        $sr.VerticalAlignment = -4108

        switch -Wildcard ($group.Name) {
            "*Sprint 1*" { $sr.Interior.Color = $cPhase1 }
            "*Sprint 2*" { $sr.Interior.Color = $cPhase2 }
            default       { $sr.Interior.Color = $cPhaseDR }
        }

        # Borde inferior seccion
        $sr.Borders.Item(9).LineStyle = 1
        $sr.Borders.Item(9).Color = $cBorder
        $sr.Borders.Item(9).Weight = 2
        $ws.Rows.Item($dataRow).RowHeight = 20
        $dataRow++

        $idx = 0
        foreach ($task in $group.Group) {
            $bgRow = if ($idx % 2 -eq 0) { $cRowEven } else { $cRowOdd }

            # Celda tarea
            $ct = $ws.Cells.Item($dataRow, $COL_TASK)
            $ct.Value2 = "   " + $task.Task
            $ct.Font.Size = 9
            $ct.Font.Color = $cDarkText
            $ct.Interior.Color = $bgRow
            $ct.VerticalAlignment = -4108

            # Responsable
            $co = $ws.Cells.Item($dataRow, $COL_OWNER)
            $co.Value2 = $task.Owner
            $co.Font.Size = 8
            $co.Font.Color = $cGrayText
            $co.HorizontalAlignment = -4108
            $co.Interior.Color = $bgRow

            # Fechas
            $cs = $ws.Cells.Item($dataRow, $COL_START)
            $cs.Value2 = $task.Start.ToString("dd/MM/yy")
            $cs.Font.Size = 8
            $cs.Font.Color = $cGrayText
            $cs.HorizontalAlignment = -4108
            $cs.Interior.Color = $bgRow

            $ce = $ws.Cells.Item($dataRow, $COL_END)
            $ce.Value2 = $task.End.ToString("dd/MM/yy")
            $ce.Font.Size = 8
            $ce.Font.Color = $cGrayText
            $ce.HorizontalAlignment = -4108
            $ce.Interior.Color = $bgRow

            # Elegir color de barra
            switch ($task.Type) {
                "t4s"       { $barC = $cT4s }
                "client"    { $barC = $cClient }
                "shared"    { $barC = $cShared }
                "milestone" { $barC = $cMilestone }
                default     { $barC = $cT4s }
            }

            # Pintar semanas
            for ($w = 0; $w -lt $numWeeks; $w++) {
                $wkStart = $weeks[$w]
                $wkEnd   = $wkStart.AddDays(6)
                $cg = $ws.Cells.Item($dataRow, $COL_GANTT + $w)

                if ($task.Start -le $wkEnd -and $task.End -ge $wkStart) {
                    $cg.Interior.Color = $barC
                    if ($task.Type -eq "milestone") {
                        $cg.Value2 = "o"
                        $cg.Font.Bold = $true
                        $cg.Font.Color = $cWhite
                        $cg.Font.Size = 11
                        $cg.HorizontalAlignment = -4108
                    }
                } else {
                    $cg.Interior.Color = $bgRow
                }

                # Linea divisoria semanal fina
                $cg.Borders.Item(7).LineStyle = 1
                $cg.Borders.Item(7).Color = $cBorder
                $cg.Borders.Item(7).Weight = 1
            }

            # Borde inferior de fila
            $fr = $ws.Range($ws.Cells.Item($dataRow, 1), $ws.Cells.Item($dataRow, $titleEnd))
            $fr.Borders.Item(9).LineStyle = 1
            $fr.Borders.Item(9).Color = $cBorder
            $ws.Rows.Item($dataRow).RowHeight = 19

            $dataRow++
            $idx++
        }
    }

    # Leyenda
    $dataRow++
    $lRow = $dataRow
    $legendDefs = @(
        [PSCustomObject]@{ Label="T4S Consulting Tasks"; Color=$cT4s },
        [PSCustomObject]@{ Label="Oetiker Responsibilities"; Color=$cClient },
        [PSCustomObject]@{ Label="Joint T4S + Oetiker"; Color=$cShared },
        [PSCustomObject]@{ Label="Milestone / Quality Gate"; Color=$cMilestone }
    )
    $lCol = 1
    foreach ($ld in $legendDefs) {
        $dotCell = $ws.Cells.Item($lRow, $lCol)
        $dotCell.Interior.Color = $ld.Color
        $dotCell.Value2 = "  "

        $lblCell = $ws.Cells.Item($lRow, $lCol + 1)
        $lblCell.Value2 = $ld.Label
        $lblCell.Font.Size = 9
        $lblCell.Font.Color = $cDarkText
        $lCol += 2
    }
    $ws.Rows.Item($lRow).RowHeight = 18

    $lRow++
    $nr = $ws.Range($ws.Cells.Item($lRow, 1), $ws.Cells.Item($lRow, $titleEnd))
    $nr.Merge() | Out-Null
    $nr.Value2 = "PTC OPL Polonia  |  T4S Delivery Team  |  Budget: 12 Consulting Days  |  Target Go-Live: Julio 2026"
    $nr.Font.Size = 8
    $nr.Font.Italic = $true
    $nr.Font.Color = $cGrayText
    $nr.HorizontalAlignment = -4108
    $ws.Rows.Item($lRow).RowHeight = 14

    # Congelar paneles
    $ws.Activate()
    $excel.ActiveWindow.SplitColumn = $COL_GANTT - 1
    $excel.ActiveWindow.SplitRow    = $ROW_DATA
    $excel.ActiveWindow.FreezePanes = $true
    $excel.ActiveWindow.Zoom = 85

    # Guardar
    Write-Host "Guardando en $OutputFilePath ..."
    $wb.SaveAs($OutputFilePath, 51)
    $wb.Close($false)
    Write-Host "Diagrama de Gantt generado correctamente."

} catch {
    Write-Error "Error: $_"
} finally {
    $excel.Quit()
    [System.Runtime.Interopservices.Marshal]::ReleaseComObject($excel) | Out-Null
    [System.GC]::Collect()
    [System.GC]::WaitForPendingFinalizers()
}
