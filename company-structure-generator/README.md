# Company Structure Generator

🏢 **Professionelles Tool-Set zum automatischen Erstellen der Dokumentenstruktur für InsideDynamic GmbH**

## 📋 Übersicht

Dieses Tool-Set ermöglicht die automatische Erstellung einer vollständigen, professionellen Ordnerstruktur für die Dokumentenverwaltung von InsideDynamic GmbH. Es bietet drei verschiedene Nutzungsmöglichkeiten: eine benutzerfreundliche GUI, eine leistungsstarke Konsolen-Version und einen einfachen Launcher.

### ✨ Features

- **12 Hauptbereiche** mit durchdachter Struktur (00_SCAN bis PROJEKTE)
- **Automatische OneDrive-Erkennung** für nahtlose Cloud-Integration
- **README.md in jedem Ordner** mit Beschreibungen
- **Zentrale Vorlagen** in 10_Vorlagen/ für alle Dokumenttypen
- **Separate Schulungsstruktur** (07_Schulungen-Weiterbildung)
- **Workflow für sevDesk/Odoo Integration**
- **GUI und Konsolen-Version** für verschiedene Nutzertypen
- **Fortschrittsanzeige** und Live-Logging
- **Fehlerbehandlung** und Statistiken

## 🚀 Schnellstart

### Option 1: Launcher (Einfachste Methode)

1. Doppelklick auf `launcher.bat`
2. Wählen Sie Option [1] für GUI oder [2] für Konsole
3. Fertig!

### Option 2: GUI-Version

```powershell
.\create_structure_GUI.ps1
```

**Vorteile:**
- Benutzerfreundliche Oberfläche
- Ordner-Browser
- Live-Protokoll mit Farbcodierung
- Fortschrittsbalken

### Option 3: Konsolen-Version

```powershell
# Basis-Verwendung
.\create_structure.ps1

# Mit OneDrive
.\create_structure.ps1 -TargetPath "C:\Users\Viktor\OneDrive"

# Mit eigener JSON-Datei
.\create_structure.ps1 -JsonFile "meine_struktur.json" -TargetPath "D:\Firmendokumente"

# Mit Force (ohne Rückfrage)
.\create_structure.ps1 -Force
```

## 📁 Erstellte Struktur

Die erstellte Ordnerstruktur umfasst:

```
InsideDynamic-GmbH/
├── 00_SCAN/                          ← Inbox für gescannte Dokumente
│   ├── Verträge/
│   ├── Post_Behörden/
│   ├── Post_Kunden/
│   ├── HR_Dokumente/
│   ├── Für_sevDesk/
│   ├── Sonstiges/
│   └── Archiviert/
│
├── 01_Unternehmen/                   ← Juristische Firmendokumente
│   ├── Gründung/
│   ├── Satzung/
│   ├── Gesellschafter/
│   ├── Versicherungen/
│   ├── Verträge/
│   ├── Mitgliedschaften/
│   ├── Compliance/
│   └── Korrespondenz/
│
├── 02_Personal/                      ← HR und Mitarbeiterunterlagen
│   ├── _VORLAGEN/                    ← Shortcut zu 10_Vorlagen/01_Personal/
│   ├── Mitarbeiter/
│   ├── Geschäftsführung/
│   ├── Stellenausschreibungen/
│   ├── Bewerbungen/
│   ├── Praktikanten/
│   ├── Arbeitszeit/
│   ├── Betriebsvereinbarungen/
│   └── HR-Controlling/
│
├── 03_Finanzen/                      ← Finanzdokumente (NICHT laufende Buchhaltung!)
│   ├── _VORLAGEN/                    ← Shortcut zu 10_Vorlagen/02_Finanzen/
│   ├── Jahresabschlüsse/
│   ├── Steuern/
│   ├── Banking/
│   ├── Verträge/
│   └── Sonstiges/
│
├── 04_Kunden/                        ← Kundenverwaltung
│   ├── _VORLAGEN/                    ← Shortcut zu 10_Vorlagen/03_Kunden/
│   ├── Aktive_Kunden/
│   ├── Potentielle_Kunden/
│   └── Ehemalige_Kunden/
│
├── 05_Vertrieb/                      ← Vertrieb und Marketing
│   ├── _VORLAGEN/                    ← Shortcut zu 10_Vorlagen/05_Vertrieb/
│   ├── Leads/
│   ├── Angebote/
│   ├── Marketing/
│   ├── Preislisten/
│   ├── Partnerschaften/
│   └── Messen_Events/
│
├── 06_Einkauf/                       ← Einkauf und Beschaffung
│   ├── Lieferanten/
│   ├── Rahmenverträge/
│   ├── Inventar/
│   └── Garantien_Gewährleistungen/
│
├── 07_Schulungen-Weiterbildung/      ← Schulungen und Zertifizierungen
│   ├── _VORLAGEN/                    ← Shortcut zu 10_Vorlagen/10_Schulungen/
│   ├── Externe-Schulungen/
│   ├── Interne-Schulungen/
│   ├── Zertifizierungen/
│   ├── Weiterbildungsplan/
│   ├── Konferenzen-Events/
│   └── Schulungs-Controlling/
│
├── 08_Fuhrpark/                      ← Fuhrparkmanagement
│   ├── Fahrzeuge/
│   ├── Versicherungen/
│   ├── Tankkarten/
│   ├── Führerscheine/
│   ├── Unfälle_Schäden/
│   └── Bußgelder_Verkehrsverstöße/
│
├── 09_IT-Infrastruktur/              ← IT-Infrastruktur
│   ├── Cloud-Services/
│   ├── Domains/
│   ├── Software-Lizenzen/
│   ├── IT-Sicherheit/
│   ├── Zugangsdaten/                 ← 🔐 NUR VERSCHLÜSSELT!
│   └── Dokumentation/
│
├── 10_Vorlagen/                      ← ⭐ ZENTRALE VORLAGEN
│   ├── 01_Personal/
│   ├── 02_Finanzen/
│   ├── 03_Kunden/
│   ├── 04_Projekte/
│   ├── 05_Vertrieb/
│   ├── 06_Briefe/
│   ├── 07_Checklisten/
│   ├── 08_Technische-Dokumentation/
│   ├── 09_Rechtliche-Vorlagen/
│   └── 10_Schulungen/
│
├── 11_Archiv/                        ← Archivierte Dokumente
│   └── Nach_Jahr/
│
└── PROJEKTE/                         ← Alle Projekte
    ├── _VORLAGEN/                    ← Shortcut zu 10_Vorlagen/04_Projekte/
    ├── Eigene_Produkte/
    ├── Kundenprojekte/
    ├── Subunternehmer-Projekte/
    ├── Interne_Projekte/
    └── Abgeschlossene_Projekte/
```

## 📝 Benennungskonventionen

### Dokumente

```
Dokumenttyp_Details_YYYY-MM-DD.ext
```

**Beispiele:**
- `Gesellschaftsvertrag_Original_2024-01-15.pdf`
- `Arbeitsvertrag_Müller-Anna_2024-01-01.pdf`
- `Rechnung-Ausgang_AR001_Kunde-ABC_2024-07-15.pdf`
- `Meeting-Protokoll_Projektname_2024-12-26.docx`

### Vorlagen

```
Dokumenttyp_Details_Vorlage_vYYYY.ext
```

**Beispiele:**
- `Arbeitsvertrag_Festanstellung_Vorlage_v2024.docx`
- `Rechnung_Standard_Vorlage_v2024.xlsx`
- `NDA_Vorlage_v2024.pdf`

### Temporäre Scans

```
SCAN_Typ_YYYY-MM-DD_NNN.pdf
```

**Beispiele:**
- `SCAN_Vertrag_2024-12-26_001.pdf`
- `SCAN_Brief_Finanzamt_2024-12-26_002.pdf`

## 🔄 Workflow-Beispiele

### 1. Dokumenten-Scan Workflow

```
1. Dokument scannen → 00_SCAN/[Kategorie]/
2. Dokument prüfen und kategorisieren
3. Dokument umbenennen nach Konvention
4. Dokument verschieben in Zielordner
5. Scan → 00_SCAN/Archiviert/ verschieben
```

### 2. sevDesk/Odoo Integration

```
Laufende Buchhaltung:
- Rechnungen (Ein- und Ausgang) → sevDesk/Odoo
- Bankbuchungen → sevDesk/Odoo
- UStVA → sevDesk/Odoo

In dieser Struktur:
- Verträge mit Kunden → 04_Kunden/
- Verträge mit Lieferanten → 06_Einkauf/Lieferanten/
- Jahresabschlüsse → 03_Finanzen/Jahresabschlüsse/
- Steuerbescheide → 03_Finanzen/Steuern/
```

### 3. Neuer Mitarbeiter

```
1. Bewerbung → 02_Personal/Bewerbungen/In-Bearbeitung/
2. Zusage und Vertragsunterzeichnung
3. Ordner erstellen → 02_Personal/Mitarbeiter/[Nachname-Vorname]/
4. Dokumente ablegen:
   - Arbeitsvertrag
   - Personalfragebogen
   - Führerscheinkopie → 08_Fuhrpark/Führerscheine/
   - Zeugnisse
```

### 4. Neues Kundenprojekt

```
1. Lead → 05_Vertrieb/Leads/Eingehende-Anfragen/
2. Angebot erstellen → 05_Vertrieb/Angebote/2024/
3. Bei Zusage:
   - Kundenordner → 04_Kunden/Aktive_Kunden/[Firmenname]/
   - Projektordner → PROJEKTE/Kundenprojekte/[Projektname]_[Kunde]/
4. Vertragsunterlagen im Kundenordner
5. Projektdokumentation im Projektordner
```

## 🔧 Parameter (Konsolen-Version)

```powershell
.\create_structure.ps1 [Parameter]

Parameter:
  -JsonFile <String>        Pfad zur JSON-Konfigurationsdatei
                           Standard: "structure.json"
                           
  -TargetPath <String>     Zielpfad für die Ordnerstruktur
                           Standard: Aktuelles Verzeichnis oder OneDrive
                           
  -CreateReadme            README.md in jedem Ordner erstellen
                           Standard: $true
                           
  -CreateExamples          .gitkeep Dateien erstellen
                           Standard: $true
                           
  -Force                   Bestehende Dateien ohne Rückfrage überschreiben
                           Standard: $false
```

## 🎯 Technische Anforderungen

- **Betriebssystem:** Windows 10/11 oder Windows Server 2016+
- **PowerShell:** Version 5.1 oder höher
- **Rechte:** Schreibrechte im Zielordner
- **.NET Framework:** Für GUI-Version (normalerweise bereits installiert)
- **Encoding:** UTF-8 mit BOM für PowerShell-Skripte

## 📂 Anpassung der Struktur

### Eigene Struktur erstellen

1. Kopieren Sie `structure.json` → `meine_struktur.json`
2. Passen Sie die Struktur nach Ihren Bedürfnissen an
3. Führen Sie aus:
   ```powershell
   .\create_structure.ps1 -JsonFile "meine_struktur.json"
   ```

### JSON-Format

```json
{
  "company_name": "MeineFirma-GmbH",
  "description": "Beschreibung der Struktur",
  "version": "1.0",
  "created": "2024-12-26",
  "author": "Ihr Name",
  
  "structure": {
    "01_Ordner": {
      "description": "Beschreibung des Ordners",
      "folders": {
        "Unterordner1": {
          "description": "Beschreibung Unterordner"
        },
        "Unterordner2": {
          "description": "Beschreibung Unterordner"
        }
      }
    }
  }
}
```

## 🔐 Sicherheitshinweise

### Zugangsdaten

⚠️ **WICHTIG:** Der Ordner `09_IT-Infrastruktur/Zugangsdaten/` sollte nur Platzhalter enthalten!

**Verwenden Sie stattdessen:**
- KeePass
- 1Password
- Bitwarden
- Azure Key Vault

### DSGVO-Konformität

- Personenbezogene Daten nur verschlüsselt ablegen
- Regelmäßige Backups erstellen
- Zugriffsrechte korrekt konfigurieren
- Aufbewahrungsfristen beachten

## 🔗 Shortcuts erstellen

Einige Ordner enthalten `_VORLAGEN/` Unterordner. Diese sollten als Shortcuts/Symlinks auf `10_Vorlagen/` verweisen.

### Windows (OneDrive/SharePoint)

1. Rechtsklick auf `10_Vorlagen/` → **"Link erstellen"**
2. Link in den Zielordner verschieben
3. Umbenennen zu `_VORLAGEN`

### PowerShell (erweitert)

```powershell
# Symbolische Links erstellen (Administrator-Rechte erforderlich)
New-Item -ItemType SymbolicLink -Path ".\02_Personal\_VORLAGEN" -Target ".\10_Vorlagen\01_Personal"
```

### Betroffene Ordner

- `02_Personal/_VORLAGEN/` → `10_Vorlagen/01_Personal/`
- `03_Finanzen/_VORLAGEN/` → `10_Vorlagen/02_Finanzen/`
- `04_Kunden/_VORLAGEN/` → `10_Vorlagen/03_Kunden/`
- `05_Vertrieb/_VORLAGEN/` → `10_Vorlagen/05_Vertrieb/`
- `07_Schulungen-Weiterbildung/_VORLAGEN/` → `10_Vorlagen/10_Schulungen/`
- `PROJEKTE/_VORLAGEN/` → `10_Vorlagen/04_Projekte/`

## 📊 Nach der Erstellung

### 1. Berechtigungen konfigurieren (OneDrive/SharePoint)

**Empfohlene Berechtigungen:**

| Rolle | Zugriff |
|-------|---------|
| Geschäftsführung | Alle Ordner (Vollzugriff) |
| Buchhaltung | 03_Finanzen, 02_Personal (teilweise) |
| Vertrieb | 04_Kunden, 05_Vertrieb |
| Entwickler | PROJEKTE (nur zugewiesene) |
| Praktikanten | Nur zugewiesene Projektordner |

### 2. Vorlagen hochladen

Laden Sie Ihre Dokumentenvorlagen in `10_Vorlagen/` hoch:

- Arbeitsverträge
- Rechnungsvorlagen
- NDA/AGB
- Präsentationen
- Projektpläne
- Checklisten

### 3. Schulung der Mitarbeiter

- Benennungskonventionen erklären
- Workflow für Dokumenten-Scan vorstellen
- Zuständigkeiten klären
- Archivierungsprozess definieren

### 4. Backup einrichten

- OneDrive hat automatisches Backup
- Zusätzlich: Externe Festplatte oder NAS
- Cloud-Backup (z.B. Azure Backup)
- Regelmäßige Tests der Wiederherstellung

## ❓ FAQ

### Warum werden manche Ordner nicht erstellt?

Prüfen Sie die Schreibrechte im Zielordner und ob PowerShell-Ausführungsrichtlinien korrekt gesetzt sind.

### Kann ich die Struktur nachträglich ändern?

Ja! Passen Sie `structure.json` an und führen Sie das Skript erneut aus. Bestehende Ordner werden nicht gelöscht.

### Was ist mit Ordnern die mit `_` beginnen?

Ordner mit `_` am Anfang sind spezielle Ordner:
- `_VORLAGEN/` = Shortcuts zu Vorlagen
- Diese sollten manuell als Symlinks erstellt werden

### Funktioniert das auch mit SharePoint?

Ja! SharePoint wird wie OneDrive behandelt. Stellen Sie sicher, dass der SharePoint-Ordner lokal synchronisiert ist.

### Wie aktualisiere ich die Struktur?

1. JSON-Datei anpassen
2. Skript erneut ausführen
3. Neue Ordner werden erstellt, bestehende bleiben unverändert

### Was bedeutet "NICHT laufende Buchhaltung"?

Die tägliche Buchhaltung (Rechnungen, Bankbuchungen) erfolgt in sevDesk/Odoo. In dieser Struktur werden nur wichtige Dokumente wie Jahresabschlüsse und Verträge abgelegt.

## 🛠️ Problembehandlung

### PowerShell-Ausführungsrichtlinie

Falls Sie eine Fehlermeldung bezüglich Ausführungsrichtlinien erhalten:

```powershell
# Für aktuelle Sitzung
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass

# Oder direkt ausführen
powershell.exe -ExecutionPolicy Bypass -File .\create_structure.ps1
```

### UTF-8 Encoding-Probleme

Die Skripte verwenden UTF-8 Encoding. Bei Problemen:

```powershell
$OutputEncoding = [System.Text.Encoding]::UTF8
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
```

### OneDrive nicht erkannt

Manuell den OneDrive-Pfad angeben:

```powershell
.\create_structure.ps1 -TargetPath "C:\Users\[IhrName]\OneDrive"
```

## 📞 Support

- **Autor:** Viktor Nikolayev
- **Firma:** InsideDynamic GmbH
- **E-Mail:** info@insidedynamic.de
- **GitHub:** https://github.com/ViktorNikolayevIndyn/scripts

## 📜 Lizenz

MIT License - Frei verwendbar für private und kommerzielle Zwecke.

## 🔄 Versionshistorie

### Version 1.0 (2024-12-26)

**Initiale Version:**
- ✅ 12 Hauptbereiche (00_SCAN bis PROJEKTE)
- ✅ Separate Schulungsstruktur
- ✅ Zentrale Vorlagen in 10_Vorlagen/
- ✅ GUI und Konsolen-Version
- ✅ OneDrive Auto-Erkennung
- ✅ Launcher.bat für einfachen Start
- ✅ README.md in jedem Ordner
- ✅ Fortschrittsanzeige und Logging
- ✅ Vollständig auf Deutsch
- ✅ Workflow für sevDesk/Odoo
- ✅ Benennungskonventionen

---

**Erstellt mit ❤️ für InsideDynamic GmbH**
