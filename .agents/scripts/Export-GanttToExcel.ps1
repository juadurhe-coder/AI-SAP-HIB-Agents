param(
    [Parameter(Mandatory=$true)][string]$InputJsonPath,
    [Parameter(Mandatory=$true)][string]$OutputXlsxPath,
    [Parameter(Mandatory=$false)][string]$ProjectTitle   = "Project Schedule",
    [Parameter(Mandatory=$false)][string]$ProjectFooter  = "",
    [Parameter(Mandatory=$false)][string]$KickOffLabel   = "Kick-Off",
    [Parameter(Mandatory=$false)][string]$GoLiveLabel    = "Go-Live",
    # Granularity: "workday" = 1 col/working day (Mon-Fri) | "day" = 1 col/calendar day | "3day" = 1 col/3 days | "week" = 1 col/7 days
    [Parameter(Mandatory=$false)][ValidateSet("day","workday","3day","week")][string]$Granularity = "workday"
)

# ─── 1. LOAD DATA ─────────────────────────────────────────────────────────────
if (-not (Test-Path $InputJsonPath)) { Write-Error "Input JSON not found: $InputJsonPath"; return }

$tasks = (Get-Content -Raw -Path $InputJsonPath) | ConvertFrom-Json
if ($null -eq $tasks) { Write-Error "Failed to parse JSON."; return }

# ─── 2. FIELD NORMALISATION ───────────────────────────────────────────────────
function Get-Field($obj, [string[]]$names) {
    foreach ($n in $names) {
        $v = $obj.PSObject.Properties[$n]
        if ($null -ne $v -and $null -ne $v.Value -and "$($v.Value)" -ne "") { return $v.Value }
    }
    return $null
}

# ─── 3. TIMELINE CALCULATION ──────────────────────────────────────────────────
$allDates = @()
foreach ($t in $tasks) {
    $s = Get-Field $t "Start","Inicio"
    $e = Get-Field $t "End","Fin"
    if ($null -ne $s) { try { $allDates += [datetime]$s } catch {} }
    if ($null -ne $e) { try { $allDates += [datetime]$e } catch {} }
}
if ($allDates.Count -eq 0) { Write-Error "No valid dates found in JSON."; return }

$projStart = ($allDates | Measure-Object -Minimum).Minimum
$projEnd   = ($allDates | Measure-Object -Maximum).Maximum

# Snap start to Monday
while ($projStart.DayOfWeek -ne [System.DayOfWeek]::Monday) { $projStart = $projStart.AddDays(-1) }
$projEnd = $projEnd.AddDays(7)

# Build slot list based on granularity
$stepDays = switch ($Granularity) {
    "workday" { 1 }
    "day"     { 1 }
    "3day"    { 3 }
    "week"    { 7 }
}

$slots = [System.Collections.Generic.List[datetime]]::new()
$cur   = $projStart
while ($cur -le $projEnd) {
    $isWeekend = ($cur.DayOfWeek -eq [System.DayOfWeek]::Saturday -or $cur.DayOfWeek -eq [System.DayOfWeek]::Sunday)
    # workday: one column per Mon-Fri, skip weekends entirely
    if ($Granularity -eq "workday") {
        if (-not $isWeekend) { $slots.Add($cur) }
        $cur = $cur.AddDays(1)
        continue
    }
    # day: calendar days, skip weekends
    if ($Granularity -eq "day" -and $isWeekend) {
        $cur = $cur.AddDays(1); continue
    }
    $slots.Add($cur)
    $cur = $cur.AddDays($stepDays)
}
$numSlots = $slots.Count

# ─── 4. COLOR PALETTE ─────────────────────────────────────────────────────────
function cRGB($r, $g, $b) { return [int]($r -bor ($g -shl 8) -bor ($b -shl 16)) }

$cHeader    = cRGB  30  58 138
$cT4s       = cRGB  37  99 235
$cClient    = cRGB 109  40 217
$cShared    = cRGB   4 120  87
$cMilestone = cRGB 217 119   6
$cRowEven   = cRGB 255 255 255
$cRowOdd    = cRGB 248 250 252
$cBorder    = cRGB 203 213 225
$cBorderWk  = cRGB 148 163 184  # stronger border every Monday
$cWhite     = cRGB 255 255 255
$cDarkText  = cRGB  30  41  59
$cGrayText  = cRGB 100 116 139

$phaseColors = @(
    (cRGB 239 246 255),
    (cRGB 245 243 255),
    (cRGB 236 253 245),
    (cRGB 255 247 237),
    (cRGB 240 253 250)
)

# ─── 5. COLUMN WIDTHS BY GRANULARITY ─────────────────────────────────────────
$slotWidth = switch ($Granularity) {
    "workday" { 2.8 }
    "day"     { 2.8 }
    "3day"    { 4.0 }
    "week"    { 5.0 }
}

$slotLabelFmt = switch ($Granularity) {
    "workday" { "d/M" }
    "day"     { "d/M" }
    "3day"    { "d MMM" }
    "week"    { "d MMM" }
}

# ─── 6. LAYOUT CONSTANTS ──────────────────────────────────────────────────────
$COL_TASK   = 1
$COL_OWNER  = 2
$COL_START  = 3
$COL_END    = 4
$COL_GANTT  = 5
$ROW_TITLE  = 1
$ROW_HEADER = 2
$ROW_DATA   = 3

# ─── 7. EXCEL AUTOMATION ──────────────────────────────────────────────────────
Write-Host "Starting Excel automation (Granularity: $Granularity, $numSlots slots)..."
$excel = New-Object -ComObject Excel.Application
$excel.Visible       = $false
$excel.DisplayAlerts = $false

try {
    $wb = $excel.Workbooks.Add()
    $ws = $wb.Worksheets.Item(1)
    $ws.Name = "Gantt Chart"

    $titleEnd = $COL_GANTT + $numSlots - 1

    # --- TITLE ROW ---
    $tr = $ws.Range($ws.Cells.Item($ROW_TITLE, 1), $ws.Cells.Item($ROW_TITLE, $titleEnd))
    $tr.Merge() | Out-Null
    $actualGoLive = ($allDates | Measure-Object -Maximum).Maximum
    $tr.Value2              = "${ProjectTitle}   |   ${KickOffLabel}: $($projStart.ToString('dd MMM yyyy'))   |   ${GoLiveLabel}: $($actualGoLive.ToString('dd MMM yyyy'))"
    $tr.Font.Bold           = $true
    $tr.Font.Size           = 12
    $tr.Font.Color          = $cWhite
    $tr.Interior.Color      = $cHeader
    $tr.HorizontalAlignment = -4108
    $tr.VerticalAlignment   = -4108
    $ws.Rows.Item($ROW_TITLE).RowHeight = 28

    # --- COLUMN HEADERS (fixed) ---
    $hdrCols = @{
        $COL_TASK  = "Task / Deliverable"
        $COL_OWNER = "Responsible"
        $COL_START = "Start"
        $COL_END   = "End"
    }
    foreach ($col in $hdrCols.Keys) {
        $c = $ws.Cells.Item($ROW_HEADER, $col)
        $c.Value2             = $hdrCols[$col]
        $c.Font.Bold          = $true
        $c.Font.Size          = 9
        $c.Font.Color         = $cWhite
        $c.Interior.Color     = $cHeader
        $c.HorizontalAlignment = -4108
        $c.VerticalAlignment   = -4108
    }

    # --- SLOT HEADERS (rotated) ---
    for ($s = 0; $s -lt $numSlots; $s++) {
        $slotDate = $slots[$s]
        $c = $ws.Cells.Item($ROW_HEADER, $COL_GANTT + $s)
        $c.Value2             = $slotDate.ToString($slotLabelFmt)
        $c.Font.Bold          = $true
        $c.Font.Size          = 7
        $c.Font.Color         = $cWhite
        $c.Interior.Color     = $cHeader
        $c.HorizontalAlignment = -4108
        $c.VerticalAlignment   = -4160  # xlBottom
        $c.Orientation        = 90
        # Darker left border for Mondays (week start marker)
        if ($slotDate.DayOfWeek -eq [System.DayOfWeek]::Monday -and $s -gt 0) {
            $c.Borders.Item(7).LineStyle = 1
            $c.Borders.Item(7).Color     = $cBorderWk
            $c.Borders.Item(7).Weight    = 2
        }
    }
    $ws.Rows.Item($ROW_HEADER).RowHeight = 65

    # --- COLUMN WIDTHS ---
    $ws.Columns.Item($COL_TASK).ColumnWidth  = 40
    $ws.Columns.Item($COL_OWNER).ColumnWidth = 12
    $ws.Columns.Item($COL_START).ColumnWidth = 10
    $ws.Columns.Item($COL_END).ColumnWidth   = 10
    for ($s = 0; $s -lt $numSlots; $s++) {
        $ws.Columns.Item($COL_GANTT + $s).ColumnWidth = $slotWidth
    }

    # --- DATA ROWS ---
    $dataRow     = $ROW_DATA
    $tasksByPhase = $tasks | Group-Object -Property {
        $p = Get-Field $_ "Phase","Fase"
        if ($null -eq $p) { "General" } else { $p }
    }
    $phaseIdx = 0

    foreach ($group in $tasksByPhase) {

        # Phase header
        $sr = $ws.Range($ws.Cells.Item($dataRow, 1), $ws.Cells.Item($dataRow, $titleEnd))
        $sr.Merge() | Out-Null
        $sr.Value2             = "   " + $group.Name.ToUpper()
        $sr.Font.Bold          = $true
        $sr.Font.Size          = 9
        $sr.Font.Color         = $cDarkText
        $sr.VerticalAlignment  = -4108
        $sr.Interior.Color     = $phaseColors[$phaseIdx % $phaseColors.Count]
        $sr.Borders.Item(9).LineStyle = 1
        $sr.Borders.Item(9).Color     = $cBorder
        $sr.Borders.Item(9).Weight    = 2
        $ws.Rows.Item($dataRow).RowHeight = 20
        $phaseIdx++
        $dataRow++

        $idx = 0
        foreach ($task in $group.Group) {
            $bgRow = if ($idx % 2 -eq 0) { $cRowEven } else { $cRowOdd }

            $tTask  = Get-Field $task "Task","Tarea"
            $tOwner = Get-Field $task "Owner","Responsable"
            $sStr   = Get-Field $task "Start","Inicio"
            $eStr   = Get-Field $task "End","Fin"
            $tType  = Get-Field $task "Type","Tipo"
            if ($null -eq $tType) { $tType = "t4s" }

            $tStart = [datetime]$sStr
            $tEnd   = [datetime]$eStr

            # Fixed info cells
            $ct = $ws.Cells.Item($dataRow, $COL_TASK)
            $ct.Value2            = "   " + $tTask
            $ct.Font.Size         = 9
            $ct.Font.Color        = $cDarkText
            $ct.Interior.Color    = $bgRow
            $ct.VerticalAlignment = -4108

            $co = $ws.Cells.Item($dataRow, $COL_OWNER)
            $co.Value2              = $tOwner
            $co.Font.Size           = 8
            $co.Font.Color          = $cGrayText
            $co.HorizontalAlignment = -4108
            $co.Interior.Color      = $bgRow

            $cs = $ws.Cells.Item($dataRow, $COL_START)
            $cs.Value2              = $tStart.ToString("dd/MM/yy")
            $cs.Font.Size           = 8
            $cs.Font.Color          = $cGrayText
            $cs.HorizontalAlignment = -4108
            $cs.Interior.Color      = $bgRow

            $ce = $ws.Cells.Item($dataRow, $COL_END)
            $ce.Value2              = $tEnd.ToString("dd/MM/yy")
            $ce.Font.Size           = 8
            $ce.Font.Color          = $cGrayText
            $ce.HorizontalAlignment = -4108
            $ce.Interior.Color      = $bgRow

            # Bar color by Type
            $barC = switch ($tType.ToLower()) {
                "client"    { $cClient }
                "shared"    { $cShared }
                "milestone" { $cMilestone }
                default     { $cT4s }
            }

            # Paint Gantt slots
            for ($s = 0; $s -lt $numSlots; $s++) {
                $slotStart = $slots[$s]
                $slotEnd   = $slotStart.AddDays($stepDays - 1)
                $cg        = $ws.Cells.Item($dataRow, $COL_GANTT + $s)

                if ($tStart -le $slotEnd -and $tEnd -ge $slotStart) {
                    $cg.Interior.Color = $barC
                    if ($tType -eq "milestone") {
                        $cg.Value2              = "o"
                        $cg.Font.Bold           = $true
                        $cg.Font.Color          = $cWhite
                        $cg.Font.Size           = 9
                        $cg.HorizontalAlignment = -4108
                    }
                } else {
                    $cg.Interior.Color = $bgRow
                }

                # Slot divider
                $cg.Borders.Item(7).LineStyle = 1
                $cg.Borders.Item(7).Color     = $cBorder
                $cg.Borders.Item(7).Weight    = 1

                # Stronger Monday marker
                if ($slotStart.DayOfWeek -eq [System.DayOfWeek]::Monday -and $s -gt 0) {
                    $cg.Borders.Item(7).Color  = $cBorderWk
                    $cg.Borders.Item(7).Weight = 2
                }
            }

            # Row bottom border
            $fr = $ws.Range($ws.Cells.Item($dataRow, 1), $ws.Cells.Item($dataRow, $titleEnd))
            $fr.Borders.Item(9).LineStyle = 1
            $fr.Borders.Item(9).Color     = $cBorder
            $ws.Rows.Item($dataRow).RowHeight = 19

            $dataRow++
            $idx++
        }
    }

    # --- LEGEND ---
    $dataRow++
    $lRow = $dataRow
    $legendDefs = @(
        [PSCustomObject]@{ Label="T4S Consulting Tasks";    Color=$cT4s },
        [PSCustomObject]@{ Label="Client Responsibilities"; Color=$cClient },
        [PSCustomObject]@{ Label="Joint Tasks";             Color=$cShared },
        [PSCustomObject]@{ Label="Milestone / Quality Gate";Color=$cMilestone }
    )
    $lCol = 1
    foreach ($ld in $legendDefs) {
        $dotCell = $ws.Cells.Item($lRow, $lCol)
        $dotCell.Interior.Color = $ld.Color
        $dotCell.Value2         = "  "

        $lblCell = $ws.Cells.Item($lRow, $lCol + 1)
        $lblCell.Value2     = $ld.Label
        $lblCell.Font.Size  = 9
        $lblCell.Font.Color = $cDarkText
        $lCol += 2
    }
    $ws.Rows.Item($lRow).RowHeight = 18

    # --- FOOTER ---
    if ($ProjectFooter -ne "") {
        $lRow++
        $nr = $ws.Range($ws.Cells.Item($lRow, 1), $ws.Cells.Item($lRow, $titleEnd))
        $nr.Merge() | Out-Null
        $nr.Value2              = $ProjectFooter
        $nr.Font.Size           = 8
        $nr.Font.Italic         = $true
        $nr.Font.Color          = $cGrayText
        $nr.HorizontalAlignment = -4108
        $ws.Rows.Item($lRow).RowHeight = 14
    }

    # --- FREEZE PANES + ZOOM ---
    $ws.Activate()
    $excel.ActiveWindow.SplitColumn = $COL_GANTT - 1
    $excel.ActiveWindow.SplitRow    = $ROW_DATA
    $excel.ActiveWindow.FreezePanes = $true
    $excel.ActiveWindow.Zoom = switch ($Granularity) {
        "workday" { 65 }
        "day"     { 70 }
        "3day"    { 80 }
        default   { 85 }
    }

    # --- SAVE ---
    $wb.SaveAs($OutputXlsxPath, 51)
    $wb.Close($false)
    Write-Host "Success: Gantt chart saved to $OutputXlsxPath"

} catch {
    Write-Error "Error during Excel generation: $_"
} finally {
    $excel.Quit()
    [System.Runtime.Interopservices.Marshal]::ReleaseComObject($excel) | Out-Null
    [System.GC]::Collect()
    [System.GC]::WaitForPendingFinalizers()
}
