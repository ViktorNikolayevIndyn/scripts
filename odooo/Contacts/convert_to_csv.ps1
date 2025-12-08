# Excel to CSV Converter for Odoo Contacts Import
# This script converts Excel file to CSV format compatible with Odoo 19

param(
    [string]$ExcelFile = "Kontakt (res.partner).xlsx",
    [string]$OutputFile = "contacts_import.csv"
)

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$ExcelPath = Join-Path $ScriptDir $ExcelFile
$CsvPath = Join-Path $ScriptDir $OutputFile

Write-Host "=== Odoo Contacts CSV Converter ===" -ForegroundColor Cyan
Write-Host "Input: $ExcelPath" -ForegroundColor Yellow
Write-Host "Output: $CsvPath" -ForegroundColor Yellow

if (-not (Test-Path $ExcelPath)) {
    Write-Host "Error: Excel file not found: $ExcelPath" -ForegroundColor Red
    exit 1
}

try {
    # Create Excel COM object
    $excel = New-Object -ComObject Excel.Application
    $excel.Visible = $false
    $excel.DisplayAlerts = $false
    
    Write-Host "`nOpening Excel file..." -ForegroundColor Green
    $workbook = $excel.Workbooks.Open($ExcelPath)
    $worksheet = $workbook.Worksheets.Item(1)
    
    # Get used range
    $range = $worksheet.UsedRange
    $rowCount = $range.Rows.Count
    $colCount = $range.Columns.Count
    
    Write-Host "Found $rowCount rows and $colCount columns" -ForegroundColor Green
    
    # Display headers
    Write-Host "`nColumn headers:" -ForegroundColor Cyan
    for ($j = 1; $j -le $colCount; $j++) {
        $header = $worksheet.Cells.Item(1, $j).Text
        Write-Host "  Column $j : $header" -ForegroundColor Gray
    }
    
    # Save as CSV with UTF-8 encoding
    Write-Host "`nConverting to CSV..." -ForegroundColor Green
    
    # Export to temporary CSV
    $tempCsv = Join-Path $env:TEMP "temp_odoo_contacts.csv"
    $workbook.SaveAs($tempCsv, 6) # 6 = xlCSV format
    
    # Close Excel
    $workbook.Close($false)
    $excel.Quit()
    [System.Runtime.Interopservices.Marshal]::ReleaseComObject($worksheet) | Out-Null
    [System.Runtime.Interopservices.Marshal]::ReleaseComObject($workbook) | Out-Null
    [System.Runtime.Interopservices.Marshal]::ReleaseComObject($excel) | Out-Null
    [System.GC]::Collect()
    [System.GC]::WaitForPendingFinalizers()
    
    # Read and re-save with proper UTF-8 encoding
    Write-Host "Applying UTF-8 encoding..." -ForegroundColor Green
    $content = Get-Content $tempCsv -Encoding Default
    $content | Out-File -FilePath $CsvPath -Encoding UTF8
    
    # Clean up temp file
    Remove-Item $tempCsv -Force -ErrorAction SilentlyContinue
    
    Write-Host "`n=== Conversion completed successfully! ===" -ForegroundColor Green
    Write-Host "CSV file created: $CsvPath" -ForegroundColor Yellow
    
    # Display first few rows
    Write-Host "`nFirst 3 rows of CSV:" -ForegroundColor Cyan
    Get-Content $CsvPath -TotalCount 3 | ForEach-Object { Write-Host $_ -ForegroundColor Gray }
    
    Write-Host "`n=== Next Steps ===" -ForegroundColor Cyan
    Write-Host "1. Open your Odoo instance" -ForegroundColor White
    Write-Host "2. Go to Contacts app" -ForegroundColor White
    Write-Host "3. Click on 'Actions' -> 'Import records'" -ForegroundColor White
    Write-Host "4. Upload the CSV file: $OutputFile" -ForegroundColor White
    Write-Host "5. Map the columns to Odoo fields" -ForegroundColor White
    Write-Host "6. Click 'Test' and then 'Import'" -ForegroundColor White
    
} catch {
    Write-Host "`nError: $_" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    
    # Cleanup Excel if still running
    if ($excel) {
        $excel.Quit()
        [System.Runtime.Interopservices.Marshal]::ReleaseComObject($excel) | Out-Null
    }
    exit 1
}
