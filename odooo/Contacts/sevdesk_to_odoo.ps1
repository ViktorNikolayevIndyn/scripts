# SevDesk to Odoo Contacts Converter
# Converts SevDesk CSV export to Odoo-compatible CSV format

param(
    [string]$InputFile = "sevdesk_contacts.csv",
    [string]$OutputFile = "odoo_contacts_import.csv"
)

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$InputPath = Join-Path $ScriptDir $InputFile
$OutputPath = Join-Path $ScriptDir $OutputFile

Write-Host "=== SevDesk to Odoo Converter ===" -ForegroundColor Cyan
Write-Host "Input: $InputPath" -ForegroundColor Yellow
Write-Host "Output: $OutputPath" -ForegroundColor Yellow

if (-not (Test-Path $InputPath)) {
    Write-Host "Error: Input file not found: $InputPath" -ForegroundColor Red
    exit 1
}

try {
    # Read SevDesk CSV (semicolon-separated, German format)
    Write-Host "`nReading SevDesk CSV..." -ForegroundColor Green
    $sevdeskData = Import-Csv -Path $InputPath -Delimiter ";" -Encoding UTF8
    
    Write-Host "Found $($sevdeskData.Count) contacts" -ForegroundColor Green
    
    # Map SevDesk fields to Odoo fields
    Write-Host "`nMapping fields to Odoo format..." -ForegroundColor Green
    
    $odooContacts = @()
    $counter = 1
    
    foreach ($contact in $sevdeskData) {
        # Determine if it's a company or individual
        $isCompany = -not [string]::IsNullOrWhiteSpace($contact.Organisation)
        
        # Build contact name
        if ($isCompany) {
            $name = $contact.Organisation
        } else {
            $nameParts = @()
            if ($contact.Anrede) { $nameParts += $contact.Anrede }
            if ($contact.Titel) { $nameParts += $contact.Titel }
            if ($contact.Vorname) { $nameParts += $contact.Vorname }
            if ($contact.Nachname) { $nameParts += $contact.Nachname }
            $name = ($nameParts -join " ").Trim()
            if ([string]::IsNullOrWhiteSpace($name)) {
                $name = $contact.Organisation
            }
        }
        
        # Build street address
        $street = $contact.Strasse
        
        # Determine contact type/category based on Kategorie field
        $tags = $contact.Kategorie
        
        # Get customer number and clean it
        $customerNr = if ($contact.'Kunden-Nr.') { $contact.'Kunden-Nr.'.Trim() } else { "" }
        
        # Create Odoo contact object with extended fields
        $odooContact = [PSCustomObject]@{
            "External ID" = "sevdesk_$customerNr"
            "Name" = $name
            "Is a Company" = if ($isCompany) { "True" } else { "False" }
            "Street" = $street
            "ZIP" = $contact.PLZ
            "City" = $contact.Ort
            "Country" = $contact.Land
            "Phone" = $contact.Telefon
            "Mobile" = $contact.Mobil
            "Fax" = $contact.Fax
            "Email" = $contact.'E-Mail'
            "Website" = $contact.Webseite
            "VAT" = $contact.'UmSt.-ID'
            "Reference" = $customerNr
            "KDNR" = $customerNr
            "Comment" = $contact.Beschreibung
            "Tags" = $tags
        }
        
        $odooContacts += $odooContact
        
        if ($counter % 10 -eq 0) {
            Write-Host "  Processed $counter contacts..." -ForegroundColor Gray
        }
        $counter++
    }
    
    # Export to Odoo CSV format (comma-separated, UTF-8)
    Write-Host "`nExporting to Odoo CSV format..." -ForegroundColor Green
    $odooContacts | Export-Csv -Path $OutputPath -Delimiter "," -Encoding UTF8 -NoTypeInformation
    
    Write-Host "`n=== Conversion completed successfully! ===" -ForegroundColor Green
    Write-Host "Converted $($odooContacts.Count) contacts" -ForegroundColor Yellow
    Write-Host "Output file: $OutputPath" -ForegroundColor Yellow
    
    # Display statistics
    $companies = ($odooContacts | Where-Object { $_.'Is a Company' -eq "True" }).Count
    $individuals = ($odooContacts | Where-Object { $_.'Is a Company' -eq "False" }).Count
    
    Write-Host "`n=== Statistics ===" -ForegroundColor Cyan
    Write-Host "Total contacts: $($odooContacts.Count)" -ForegroundColor White
    Write-Host "Companies: $companies" -ForegroundColor White
    Write-Host "Individuals: $individuals" -ForegroundColor White
    
    # Display first contact as example
    Write-Host "`n=== First Contact Example ===" -ForegroundColor Cyan
    $odooContacts[0] | Format-List
    
    Write-Host "`n=== Next Steps for Odoo Import ===" -ForegroundColor Cyan
    Write-Host "1. Login to your Odoo instance" -ForegroundColor White
    Write-Host "2. Go to: Contacts app" -ForegroundColor White
    Write-Host "3. Click: Actions (⚙) -> Import records" -ForegroundColor White
    Write-Host "4. Upload file: $OutputFile" -ForegroundColor White
    Write-Host "5. Odoo will auto-map the fields" -ForegroundColor White
    Write-Host "6. Click 'Test' to verify" -ForegroundColor White
    Write-Host "7. Click 'Import' to complete" -ForegroundColor White
    Write-Host "`nNote: External IDs will prevent duplicates on re-import" -ForegroundColor Yellow
    
} catch {
    Write-Host "`nError: $_" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    Write-Host $_.ScriptStackTrace -ForegroundColor Red
    exit 1
}
