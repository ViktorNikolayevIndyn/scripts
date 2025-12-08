# Find Missing Contact Information
# Analyzes contacts and identifies missing data (phone, email, tax number, etc.)

param(
    [string]$InputFile = "sevdesk_contacts.csv",
    [string]$OutputFile = "missing_info_report.csv"
)

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$InputPath = Join-Path $ScriptDir $InputFile
$OutputPath = Join-Path $ScriptDir $OutputFile

Write-Host "=== Missing Contact Information Finder ===" -ForegroundColor Cyan

if (-not (Test-Path $InputPath)) {
    Write-Host "Error: Input file not found: $InputPath" -ForegroundColor Red
    exit 1
}

# Read contacts
$contacts = Import-Csv -Path $InputPath -Delimiter ";" -Encoding UTF8
Write-Host "Analyzing $($contacts.Count) contacts..." -ForegroundColor Green

$missingInfoList = @()

foreach ($contact in $contacts) {
    $name = if ($contact.Organisation) { $contact.Organisation } else { "$($contact.Vorname) $($contact.Nachname)".Trim() }
    $website = $contact.Webseite
    
    # Check for missing information
    $missing = @()
    
    if ([string]::IsNullOrWhiteSpace($contact.Telefon)) { $missing += "Phone" }
    if ([string]::IsNullOrWhiteSpace($contact.'E-Mail')) { $missing += "Email" }
    if ([string]::IsNullOrWhiteSpace($contact.Steuernummer)) { $missing += "Tax Number" }
    if ([string]::IsNullOrWhiteSpace($contact.'UmSt.-ID')) { $missing += "VAT ID" }
    if ([string]::IsNullOrWhiteSpace($contact.Webseite)) { $missing += "Website" }
    if ([string]::IsNullOrWhiteSpace($contact.Strasse)) { $missing += "Street" }
    if ([string]::IsNullOrWhiteSpace($contact.PLZ)) { $missing += "ZIP" }
    if ([string]::IsNullOrWhiteSpace($contact.IBAN)) { $missing += "IBAN" }
    
    # Only add if there's missing info
    if ($missing.Count -gt 0) {
        $missingInfoList += [PSCustomObject]@{
            "Customer Nr" = $contact.'Kunden-Nr.'
            "Name" = $name
            "Category" = $contact.Kategorie
            "Website" = $website
            "Has Website" = if ($website) { "Yes" } else { "No" }
            "Missing Fields" = ($missing -join ", ")
            "Missing Count" = $missing.Count
            "Current Phone" = $contact.Telefon
            "Current Email" = $contact.'E-Mail'
            "Current City" = $contact.Ort
            "Priority" = if ($missing -contains "Email" -or $missing -contains "Phone") { "High" } else { "Medium" }
        }
    }
}

# Sort by priority and missing count
$missingInfoList = $missingInfoList | Sort-Object @{Expression="Priority";Descending=$true}, @{Expression="Missing Count";Descending=$true}

# Export report
$missingInfoList | Export-Csv -Path $OutputPath -Delimiter ";" -Encoding UTF8 -NoTypeInformation

Write-Host "`n=== Analysis Complete ===" -ForegroundColor Green
Write-Host "Total contacts analyzed: $($contacts.Count)" -ForegroundColor White
Write-Host "Contacts with missing info: $($missingInfoList.Count)" -ForegroundColor Yellow
Write-Host "Report saved: $OutputPath" -ForegroundColor Yellow

# Statistics
$missingPhone = ($missingInfoList | Where-Object { $_.'Missing Fields' -match "Phone" }).Count
$missingEmail = ($missingInfoList | Where-Object { $_.'Missing Fields' -match "Email" }).Count
$missingTax = ($missingInfoList | Where-Object { $_.'Missing Fields' -match "Tax Number" }).Count
$missingVAT = ($missingInfoList | Where-Object { $_.'Missing Fields' -match "VAT ID" }).Count
$missingWebsite = ($missingInfoList | Where-Object { $_.'Missing Fields' -match "Website" }).Count
$hasWebsite = ($missingInfoList | Where-Object { $_.Website }).Count

Write-Host "`n=== Missing Fields Statistics ===" -ForegroundColor Cyan
Write-Host "Missing Phone: $missingPhone" -ForegroundColor $(if ($missingPhone -gt 0) { "Red" } else { "Green" })
Write-Host "Missing Email: $missingEmail" -ForegroundColor $(if ($missingEmail -gt 0) { "Red" } else { "Green" })
Write-Host "Missing Tax Number: $missingTax" -ForegroundColor $(if ($missingTax -gt 0) { "Yellow" } else { "Green" })
Write-Host "Missing VAT ID: $missingVAT" -ForegroundColor $(if ($missingVAT -gt 0) { "Yellow" } else { "Green" })
Write-Host "Missing Website: $missingWebsite" -ForegroundColor $(if ($missingWebsite -gt 0) { "Yellow" } else { "Green" })

Write-Host "`n=== Research Opportunities ===" -ForegroundColor Cyan
Write-Host "Contacts WITH website (can research): $hasWebsite" -ForegroundColor Green
Write-Host "Contacts WITHOUT website (manual search needed): $($missingInfoList.Count - $hasWebsite)" -ForegroundColor Yellow

# Show high priority contacts
$highPriority = $missingInfoList | Where-Object { $_.Priority -eq "High" } | Select-Object -First 10
if ($highPriority) {
    Write-Host "`n=== Top 10 High Priority Contacts (Missing Phone/Email) ===" -ForegroundColor Red
    $highPriority | Format-Table "Name", "Website", "Missing Fields" -AutoSize
}

Write-Host "`n=== Next Steps ===" -ForegroundColor Cyan
Write-Host "1. Open: $OutputFile" -ForegroundColor White
Write-Host "2. For contacts with websites, visit them to find missing info" -ForegroundColor White
Write-Host "3. Search Google for contacts without websites" -ForegroundColor White
Write-Host "4. Update sevdesk_contacts.csv with found information" -ForegroundColor White
Write-Host "5. Re-run sevdesk_to_odoo.ps1 to regenerate import file" -ForegroundColor White
