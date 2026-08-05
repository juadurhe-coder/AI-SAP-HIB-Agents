$excel = New-Object -ComObject Excel.Application
$excel.Visible = $false
$excel.DisplayAlerts = $false

try {
    $workbook = $excel.Workbooks.Add()
    $worksheet = $workbook.Worksheets.Item(1)
    $worksheet.Name = "CutOver Plan Template"

    # Define BGR colors matching the Oetiker style
    $colorTitleBg = 6108699         # #1b365d -> BGR: 6108699
    $colorSubBg = 8473615           # #0f4c81 -> BGR: 8473615
    $colorThBg = 16184566           # #F3F4F6 -> BGR: 16184566
    
    # Phase Colors
    $colorP1Bg = 9395243            # #2B5C8F -> BGR: 9395243
    $colorP2Bg = 2775490            # #C2592A -> BGR: 2775490
    $colorP3Bg = 9058846            # #1E3A8A -> BGR: 9058846

    # Status Colors (completed: green, wip: yellow, not: pink)
    $colorCompBg = 14022086
    $colorCompText = 4030485
    $colorWipBg = 13104126
    $colorWipText = 611252
    $colorNotBg = 15984636
    $colorNotText = 6101182

    # Systems Colors
    $colorOeqBg = 16770528
    $colorOeqText = 13252675
    $colorOepBg = 14873342
    $colorOepText = 1842361

    # Main Title (Row 1)
    $worksheet.Range("A1:K1").Merge()
    $worksheet.Cells.Item(1, 1).Value2 = "[PROJECT NAME] - Cut-Over Plan to PROD"
    $worksheet.Cells.Item(1, 1).Font.Name = "Segoe UI"
    $worksheet.Cells.Item(1, 1).Font.Size = 14
    $worksheet.Cells.Item(1, 1).Font.Bold = $true
    $worksheet.Cells.Item(1, 1).Font.Color = 16777215 # White
    $worksheet.Range("A1:K1").Interior.Color = $colorTitleBg
    $worksheet.Cells.Item(1, 1).HorizontalAlignment = -4108 # xlCenter
    $worksheet.Cells.Item(1, 1).VerticalAlignment = -4108 # xlCenter
    $worksheet.Rows.Item(1).RowHeight = 35

    # Sub-Header (Row 2)
    $worksheet.Range("A2:K2").Merge()
    $worksheet.Cells.Item(2, 1).Value2 = "Go-Live Target: [Target Date] | Delivering/Selling: [Entities / Countries] | Prepared by: [Lead Name]"
    $worksheet.Cells.Item(2, 1).Font.Name = "Segoe UI"
    $worksheet.Cells.Item(2, 1).Font.Size = 9
    $worksheet.Cells.Item(2, 1).Font.Bold = $true
    $worksheet.Cells.Item(2, 1).Font.Color = 16772862 # Light Blue
    $worksheet.Range("A2:K2").Interior.Color = $colorSubBg
    $worksheet.Cells.Item(2, 1).HorizontalAlignment = -4108 # xlCenter
    $worksheet.Cells.Item(2, 1).VerticalAlignment = -4108 # xlCenter
    $worksheet.Rows.Item(2).RowHeight = 22

    # Column Headers (Row 3)
    $headers = @("SYSTEM", "TIMING", "TEAM", "ASSIGNED", "ID", "TASK NAME", "START", "END", "DURATION", "DEPENDS ON", "STATUS")
    for ($i = 0; $i -lt $headers.Count; $i++) {
        $cell = $worksheet.Cells.Item(3, $i + 1)
        $cell.Value2 = $headers[$i]
        $cell.Font.Name = "Segoe UI"
        $cell.Font.Size = 9
        $cell.Font.Bold = $true
        $cell.Font.Color = 0 # Black
        $cell.Interior.Color = $colorThBg
        $cell.HorizontalAlignment = -4108 # xlCenter
        $cell.VerticalAlignment = -4108 # xlCenter
    }
    $worksheet.Rows.Item(3).RowHeight = 26

    # Template Data
    $tasks = @(
        # Phase 1 Header
        @("PHASE 1", "PHASE 1 - PREPARATION AND TRANSPORTS IN TESTING (PRE-CUTOVER) - [Date Range]"),
        @("OEQ", "Pre-Cutover", "[Team Name]", "[Assigned]", "1", "[Sample Task 1: Create and release transport requests in DEV]", "[Start Date]", "[End Date]", "[Duration]", "-", "NOT INITIATED"),
        @("OEQ", "Pre-Cutover", "[Team Name]", "[Assigned]", "2", "[Sample Task 2: Import transport requests into OEQ testing system]", "[Start Date]", "[End Date]", "[Duration]", "1", "NOT INITIATED"),
        @("OEQ", "Pre-Cutover", "[Team Name]", "[Assigned]", "3", "[Sample Task 3: Maintain master data in OEQ for testing validation]", "[Start Date]", "[End Date]", "[Duration]", "2", "NOT INITIATED"),
        
        # Phase 2 Header
        @("PHASE 2", "PHASE 2 - GO-LIVE DEPLOYMENT (DURING GO-LIVE) - [Date Range]"),
        @("OEP", "Go-Live", "[Team Name]", "[Assigned]", "4", "[Sample Task 4: Import validated transport requests into OEP production]", "[Start Date]", "[End Date]", "[Duration]", "2", "NOT INITIATED"),
        @("OEP", "Go-Live", "[Team Name]", "[Assigned]", "5", "[Sample Task 5: Maintain master data and condition records in OEP]", "[Start Date]", "[End Date]", "[Duration]", "4", "NOT INITIATED"),
        @("OEP", "Go-Live", "[Team Name]", "[Assigned]", "6", "[Sample Task 6: Verify configurations and system outputs in production]", "[Start Date]", "[End Date]", "[Duration]", "5", "NOT INITIATED"),

        # Phase 3 Header
        @("PHASE 3", "PHASE 3 - BUSINESS OPERATION AND SUPPORT (POST GO-LIVE) - [Date Range]"),
        @("OEP", "Post Go-Live", "[Team Name]", "[Assigned]", "7", "[Sample Task 7: Provide hypercare support and validation of first live operations]", "[Start Date]", "[End Date]", "[Duration]", "6", "NOT INITIATED")
    )

    $rowIdx = 4
    foreach ($row in $tasks) {
        if ($row[0].StartsWith("PHASE")) {
            # Render Phase Row
            $rangeStr = "A$rowIdx:K$rowIdx"
            $worksheet.Range($rangeStr).Merge()
            
            $cell = $worksheet.Cells.Item($rowIdx, 1)
            $cell.Value2 = $row[1]
            
            $targetRange = $worksheet.Range($rangeStr)
            $targetRange.Font.Name = "Segoe UI"
            $targetRange.Font.Size = 9
            $targetRange.Font.Bold = $true
            $targetRange.Font.Color = 16777215 # White
            $targetRange.HorizontalAlignment = -4131 # xlLeft
            $targetRange.VerticalAlignment = -4108 # xlCenter
            
            if ($row[0] -eq "PHASE 1") { $targetRange.Interior.Color = $colorP1Bg }
            elseif ($row[0] -eq "PHASE 2") { $targetRange.Interior.Color = $colorP2Bg }
            elseif ($row[0] -eq "PHASE 3") { $targetRange.Interior.Color = $colorP3Bg }

            $worksheet.Rows.Item($rowIdx).RowHeight = 22
        } else {
            # Render Task Row
            $worksheet.Rows.Item($rowIdx).RowHeight = 28
            for ($col = 1; $col -le 11; $col++) {
                $cell = $worksheet.Cells.Item($rowIdx, $col)
                $cell.Value2 = $row[$col - 1]
                $cell.Font.Name = "Segoe UI"
                $cell.Font.Size = 9
                $cell.Font.Color = 0 # Black

                # Alignments
                if ($col -eq 3 -or $col -eq 4 -or $col -eq 6) {
                    $cell.HorizontalAlignment = -4131 # xlLeft
                } else {
                    $cell.HorizontalAlignment = -4108 # xlCenter
                }
                $cell.VerticalAlignment = -4108 # xlCenter

                # System cell color
                if ($col -eq 1) {
                    $sys = $row[0]
                    if ($sys -eq "OEQ") {
                        $cell.Interior.Color = $colorOeqBg
                        $cell.Font.Color = $colorOeqText
                        $cell.Font.Bold = $true
                    } elseif ($sys -eq "OEP") {
                        $cell.Interior.Color = $colorOepBg
                        $cell.Font.Color = $colorOepText
                        $cell.Font.Bold = $true
                    }
                }

                # Timing cell color
                if ($col -eq 2) {
                    $timing = $row[1]
                    if ($timing -eq "Pre-Cutover") {
                        # Default Gray
                    } elseif ($timing -eq "Go-Live") {
                        $cell.Interior.Color = $colorWipBg
                        $cell.Font.Color = $colorWipText
                        $cell.Font.Bold = $true
                    } elseif ($timing -eq "Post Go-Live") {
                        $cell.Interior.Color = $colorCompBg
                        $cell.Font.Color = $colorCompText
                        $cell.Font.Bold = $true
                    }
                }

                # Status cell color
                if ($col -eq 11) {
                    $status = $row[10]
                    if ($status -eq "COMPLETED") {
                        $cell.Interior.Color = $colorCompBg
                        $cell.Font.Color = $colorCompText
                        $cell.Font.Bold = $true
                    } elseif ($status -eq "IN PROGRESS") {
                        $cell.Interior.Color = $colorWipBg
                        $cell.Font.Color = $colorWipText
                        $cell.Font.Bold = $true
                    } elseif ($status -eq "NOT INITIATED") {
                        $cell.Interior.Color = $colorNotBg
                        $cell.Font.Color = $colorNotText
                        $cell.Font.Bold = $true
                    }

                    # Add Status Data Validation (Dropdown)
                    try {
                        $validation = $cell.Validation
                        $validation.Delete()
                        $validation.Add(3, 1, 1, "NOT INITIATED;IN PROGRESS;COMPLETED")
                        $validation.IgnoreBlank = $true
                        $validation.InCellDropdown = $true
                    } catch {}
                }
            }
        }
        $rowIdx++
    }

    # Apply Borders to all cells
    $range = $worksheet.Range("A3:K$($rowIdx - 1)")
    $borders = $range.Borders
    $borders.LineStyle = 1 # xlContinuous
    $borders.Weight = 2 # xlThin
    $borders.Color = 14277083

    # Set Column Widths
    $worksheet.Columns.Item(1).ColumnWidth = 12
    $worksheet.Columns.Item(2).ColumnWidth = 15
    $worksheet.Columns.Item(3).ColumnWidth = 20
    $worksheet.Columns.Item(4).ColumnWidth = 18
    $worksheet.Columns.Item(5).ColumnWidth = 6
    $worksheet.Columns.Item(6).ColumnWidth = 65
    $worksheet.Columns.Item(7).ColumnWidth = 14
    $worksheet.Columns.Item(8).ColumnWidth = 14
    $worksheet.Columns.Item(9).ColumnWidth = 12
    $worksheet.Columns.Item(10).ColumnWidth = 14
    $worksheet.Columns.Item(11).ColumnWidth = 18

    # Save workbook
    $outputPath = Join-Path $PSScriptRoot "cutover_template.xlsx"
    if (Test-Path $outputPath) {
        Remove-Item $outputPath -Force
    }
    $workbook.SaveAs($outputPath)
    $workbook.Close()
    Write-Host "Excel Template generated successfully."
} catch {
    Write-Host "Error: $_"
} finally {
    $excel.Quit()
    [System.Runtime.Interopservices.Marshal]::ReleaseComObject($excel) | Out-Null
}
