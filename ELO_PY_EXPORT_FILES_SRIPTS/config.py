# ELO Export Konfiguration

# ========== Server & Authentication ==========
BASE_URL = "http://10.2.200.11:9090/rest-ZEBES"
USERNAME = "administrator"
PASSWORD = "ZebesELO2017!"

# ========== Export Optionen ==========
EXPORT_ENABLED = True           # Dateien exportieren
ACL_ENABLED = False             # ACL auf Read-Only setzen
METADATA_ENABLED = True         # Metadaten in ELO setzen (EXPORTED=1)
SAVE_METADATA_ENABLED = True    # Metadaten als JSON exportieren

# ========== Ordner-Konfiguration ==========
# Mehrere Ordner-IDs mit Komma oder Semikolon trennen
# Beispiel: "21022, 20643, 19664" oder als Liste: [21022, 20643, 19664]
DEFAULT_FOLDER_ID = ""
FOLDER_IDS = "21225"  
# FOLDER_IDS = "21022, 20643, 19664, 20128, 11083, 10432, 21209, 21013, 19686, 46265, 52779, 57240"

DEFAULT_OUTPUT = "G:/EXPORT_KUNDEN_2026"

# ========== Exclude-Filter ==========
# Ordner die vom Export ausgeschlossen werden sollen
# Beispiel: Kunden-Ordner exportieren, aber ohne "TN/LS/AB" Unterordner
EXCLUDE_FOLDERS = [
    "TN/LS/AB",     # Wird in jedem Kunden-Ordner übersprungen
    # Weitere Ausschlüsse hier hinzufügen:
    # "Temp",
    # "Archive/Old",
]

# ========== Keywording-Felder ==========
# Felder die nach Export in ELO gesetzt werden
KEYWORDING_FIELDS = {
    "EXPORT_TYPE": "script - file export",
    "EXPORTED": "1",
    "EXPORTED_ACL": "0"  # Korrigiert (war: EXPORTET_ACL)
}

