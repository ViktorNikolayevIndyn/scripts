
# ELO Konfiguration (kann überschrieben werden durch CLI-Parameter)
BASE_URL = "http://10.2.200.11:9090/rest-ZEBES"
USERNAME = "administrator"
PASSWORD = "ZebesELO2017!"

# Optionen
EXPORT_ENABLED = True
ACL_ENABLED = False
METADATA_ENABLED = True
SAVE_METADATA_ENABLED = True

# Standardwerte (falls keine Werte aus der config.py oder CLI vorhanden)
# Beispiel: Mehrere Ordner-IDs mit Komma oder Semikolon trennen
# ✅ Standard-Ordner-ID und mehrere IDs als Array oder String definieren
DEFAULT_FOLDER_ID = ""
FOLDER_IDS = "21218, 44426" # "1212,1313,1414"  # Oder als Liste: [1212, 1313, 1414]


DEFAULT_OUTPUT = "C:/EXPORT/TEST1"

0

3