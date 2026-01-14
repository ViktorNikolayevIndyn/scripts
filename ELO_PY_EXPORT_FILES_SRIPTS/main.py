import os
import sys
import subprocess
import argparse

# Überprüfe das Vorhandensein von "modules"
MODULES_PATH = os.path.join(os.path.dirname(__file__), 'modules')
if not os.path.exists(MODULES_PATH):
    print(f"Fehler: Modul-Ordner '{MODULES_PATH}' fehlt.")
    sys.exit(1)

# Installiere fehlende Module
REQUIRED_MODULES = ['requests']
def install_missing_modules():
    for module in REQUIRED_MODULES:
        try:
            __import__(module)
        except ImportError:
            print(f"Modul '{module}' nicht gefunden. Installiere...")
            subprocess.check_call([sys.executable, '-m', 'pip', 'install', module])

install_missing_modules()

# Importiere Module nach der Installation
from modules.elo_client import EloClient
from modules.elo_exporter import EloExporter
from modules.elo_metadata import EloMetadata
from modules.elo_acl import EloACL
from config import BASE_URL, USERNAME, PASSWORD, DEFAULT_FOLDER_ID, DEFAULT_OUTPUT, EXPORT_ENABLED, ACL_ENABLED, METADATA_ENABLED, SAVE_METADATA_ENABLED, FOLDER_IDS

def parse_folder_ids(ids):
    if isinstance(ids, list):
        return ids
    if isinstance(ids, str):
        # [OK] Nach Komma oder Semikolon splitten
        if "," in ids:
            return [int(x.strip()) for x in ids.split(",") if x.strip().isdigit()]
        if ";" in ids:
            return [int(x.strip()) for x in ids.split(";") if x.strip().isdigit()]
        if ids.strip().isdigit():
            return [int(ids.strip())]  # [OK] Einzelne ID übernehmen
    return [DEFAULT_FOLDER_ID]  # [OK] Fallback auf DEFAULT_FOLDER_ID

def main():
    parser = argparse.ArgumentParser(description="ELO Export Tool")
    parser.add_argument("--export", action="store_true", help="Exportiere Dateien")
    parser.add_argument("--metadata", action="store_true", help="Setze Metadaten nach Export")
    parser.add_argument("--acl", action="store_true", help="Setze ACL auf Read-Only nach Export")
    parser.add_argument("--save-metadata", action="store_true", help="Metadaten speichern")
    parser.add_argument("--upload-metadata", action="store_true", help="Lade Metadaten aus download_db.json in ELO hoch")
    parser.add_argument("--folder-ids", type=str, help="Kommaseparierte Liste von Ordner-IDs für den Export")
    parser.add_argument("--output", type=str, help="Zielverzeichnis für den Export")
    parser.add_argument("--username", type=str, help="API Benutzername")
    parser.add_argument("--password", type=str, help="API Passwort")
    parser.add_argument("--base-url", type=str, help="API Basis-URL")

    args = parser.parse_args()

    # Priorität: CLI > config.py > Defaults
    base_url = args.base_url or BASE_URL or "http://localhost:9090/rest-Tenant"
    username = args.username or USERNAME or "administrator"
    password = args.password or PASSWORD or "password"
    folder_ids = parse_folder_ids(args.folder_ids) if args.folder_ids else parse_folder_ids(FOLDER_IDS)
    output = args.output or DEFAULT_OUTPUT

    export_enabled = args.export or EXPORT_ENABLED
    metadata_enabled = args.metadata or METADATA_ENABLED
    acl_enabled = args.acl or ACL_ENABLED
    save_metadata_enabled = args.save_metadata or SAVE_METADATA_ENABLED
    upload_metadata_enabled = args.upload_metadata  # Nur explizit über CLI!

    # Debug-Ausgabe der verwendeten Parameter
    print("===== KONFIGURATION =====")
    print(f"→ BASE_URL: {base_url}")
    print(f"→ USERNAME: {username}")
    print(f"→ PASSWORD: {'***' if password else 'NICHT GESETZT'}")
    print(f"→ FOLDER_IDS: {folder_ids}")
    print(f"→ OUTPUT: {output}")
    print(f"→ EXPORT: {'Aktiviert' if export_enabled else 'Deaktiviert'}")
    print(f"→ METADATA: {'Aktiviert' if metadata_enabled else 'Deaktiviert'}")
    print(f"→ ACL: {'Aktiviert' if acl_enabled else 'Deaktiviert'}")
    print(f"→ METADATA EXPORT: {'Aktiviert' if save_metadata_enabled else 'Deaktiviert'}")
    print(f"→ UPLOAD METADATA: {'Aktiviert' if upload_metadata_enabled else 'Deaktiviert'}")
    print("=========================")

    client = EloClient(base_url, username, password)
    if not client.check_login():
        print("[X] Login fehlgeschlagen.")
        return

    exporter = EloExporter(client, output, set_elo_metadata=metadata_enabled)
    metadata = EloMetadata(client)
    acl = EloACL(client)

    # [OK] Upload Metadaten aus DB wenn --upload-metadata gesetzt
    if upload_metadata_enabled:
        download_db_path = os.path.join(output, "download_db.json")
        metadata.upload_metadata_from_db(download_db_path)
        return  # Beende nach Upload

    # [OK] Wenn Export aktiviert: Prüfe ob download_db.json existiert
    if export_enabled:
        download_db_path = os.path.join(output, "download_db.json")
        if os.path.exists(download_db_path):
            print(f"\n[!]  download_db.json bereits vorhanden in: {output}")
            print("Optionen:")
            print("  [1] Löschen und neu beginnen (alle bisherigen Downloads verloren)")
            print("  [2] Fortsetzen und DB aktualisieren (bereits heruntergeladene Dateien werden übersprungen)")
            print("  [3] Abbrechen")
            
            while True:
                choice = input("\nWähle eine Option [1/2/3]: ").strip()
                if choice == "1":
                    try:
                        os.remove(download_db_path)
                        print("[OK] download_db.json gelöscht. Starte neuen Export...")
                    except Exception as e:
                        print(f"[X] Fehler beim Löschen: {e}")
                        return
                    break
                elif choice == "2":
                    print("[OK] Fortsetzen mit vorhandener DB...")
                    break
                elif choice == "3":
                    print("[X] Export abgebrochen.")
                    return
                else:
                    print("[X] Ungültige Eingabe. Bitte 1, 2 oder 3 eingeben.")

    # [OK] Mehrere FOLDER-IDs nacheinander verarbeiten
    for folder_id in folder_ids:
        print(f"[GO] Starte Export für Ordner-ID: {folder_id}")
        if export_enabled:
            exporter.download_folder(folder_id, output)

        if metadata_enabled:
            print("[DOC] Setze Metadaten...")
            items = client.get(f"/api/files/{folder_id}/children")
            if items:
                for item in items:
                    metadata.set_metadata(item['id'], item['name'], output)

        if acl_enabled:
            print("[LOCK] Setze ACL...")
            items = client.get(f"/api/files/{folder_id}/children")
            if items:
                for item in items:
                    file_id = item['id']
                    filename = item['name']
                    save_path = os.path.join(output, filename)
                    acl.set_read_only(file_id, filename)

        if save_metadata_enabled:
            print("[SAVE] Speichere Metadaten...")
            items = client.get(f"/api/files/{folder_id}/children")
            if items:
                for item in items:
                    file_id = item['id']
                    filename = item['name']
                    save_path = os.path.join(output, filename)
                    exporter.metadata_exporter.save_metadata()

if __name__ == "__main__":
    main()
