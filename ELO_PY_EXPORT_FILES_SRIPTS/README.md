# ELO Export Tool

Export-Tool für ELO Dokumentenmanagementsystem mit automatischer Metadaten-Verwaltung.

## 📋 Features

- ✅ Rekursiver Export von Ordnern und Dateien
- ✅ Streaming-Download mit Retry-Logik
- ✅ Resume-Unterstützung bei Verbindungsabbrüchen
- ✅ Progress Bar für große Dateien
- ✅ Download-Datenbank (download_db.json) für Wiederaufnahme
- ✅ Exclude-Filter für bestimmte Ordner
- ✅ Metadaten-Export als JSON
- ✅ Metadaten-Upload zurück in ELO
- ✅ Timestamp-Erhaltung (Archivierungs- und Änderungsdatum)
- ✅ ACL-Management

## 🚀 Schnellstart

### 1. Export starten
Doppelklick auf **`start_export.bat`**

Oder manuell:
```bash
python main.py --export
```

### 2. Metadaten hochladen
Nach erfolgreichem Export:
```bash
python main.py --upload-metadata
```

Oder Doppelklick auf **`upload_metadata.bat`**

## ⚙️ Konfiguration

Alle Einstellungen in `config.py`:

```python
# Server & Auth
BASE_URL = "http://10.2.200.11:9090/rest-ZEBES"
USERNAME = "administrator"
PASSWORD = "ZebesELO2017!"

# Ordner-IDs (kommasepariert)
FOLDER_IDS = "44464"

# Output-Pfad
DEFAULT_OUTPUT = "G:/EXPORT_12_2025"

# Exclude-Filter
EXCLUDE_FOLDERS = [
    "TN/LS/AB",  # Wird übersprungen
]
```

## 📁 Dateistruktur

```
EXPORT_SRIPTS/
├── main.py                    # Hauptprogramm
├── config.py                  # Konfiguration
├── start_export.bat           # Export starten
├── upload_metadata.bat        # Metadaten hochladen
├── modules/
│   ├── elo_client.py         # API-Client
│   ├── elo_exporter.py       # Export-Logik
│   ├── elo_metadata.py       # Metadaten-Setter
│   ├── elo_metadata_exporter.py
│   └── elo_acl.py            # ACL-Management
└── README.md                  # Diese Datei
```

## 🔄 Download-Datenbank

Die `download_db.json` wird automatisch erstellt und enthält:
- Alle heruntergeladenen Dateien
- Metadaten aus ELO
- Status für Metadata-Upload

**Beim Export-Neustart:**
- Option [1]: DB löschen → Alles neu herunterladen
- Option [2]: DB behalten → Nur neue Dateien laden
- Option [3]: Abbrechen

## 📊 CLI-Parameter

```bash
# Export mit spezifischen Ordnern
python main.py --export --folder-ids "21218,20735"

# Nur Metadaten setzen
python main.py --metadata

# ACL auf Read-Only setzen
python main.py --acl

# Metadaten hochladen
python main.py --upload-metadata

# Mehrere Optionen kombinieren
python main.py --export --metadata --save-metadata
```

## 🛡️ Fehlerbehandlung

### Bei Verbindungsabbruch:
- ✅ Automatischer Retry (5 Versuche)
- ✅ Resume ab letzter Position
- ✅ Script einfach neu starten

### Bei Memory-Error:
- ✅ Streaming-Download für alle Dateien
- ✅ Keine Speicherprobleme mehr

### Bei "Ports erschöpft":
- ✅ Connection-Pooling mit requests.Session
- ✅ Automatische Wiederverwendung

## 📝 Logs

Während des Exports werden angezeigt:
- 📥 Download-Status
- 📊 Progress Bar (für große Dateien)
- ⏭️ Übersprungene Dateien
- ✅ Erfolgreiche Downloads
- ❌ Fehler mit Details
- 🕒 Timestamp-Setzung

## 🎯 Beispiel-Workflow

1. **Config anpassen** (`config.py`)
2. **Export starten** (`start_export.bat`)
3. **Bei Fehler**: Script neu starten (Option [2] wählen)
4. **Nach Abschluss**: `upload_metadata.bat` für ELO-Metadaten

## 🔧 Anforderungen

- Python 3.8+
- requests

Installation:
```bash
pip install requests
```

## 📞 Support

Bei Problemen:
1. Prüfe `config.py` Einstellungen
2. Prüfe `download_db.json` für Status
3. Schau in die Fehlermeldungen
