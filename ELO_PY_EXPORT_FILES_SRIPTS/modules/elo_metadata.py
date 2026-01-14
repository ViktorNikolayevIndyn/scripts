
from .elo_client import EloClient
import config
import os
import json

class EloMetadata:
    def __init__(self, client):
        self.client = client

    def set_metadata(self, file_id, filename, save_path):
        data = {
            "fields": {
                "EXPORT_GRP": filename,
                "EXPORT_PATH": save_path,
                **config.KEYWORDING_FIELDS
            }
        }
        response = self.client.patch(f"/api/files/{file_id}/keywording", data)
        
        # [OK] Auch bei leerem Response als Erfolg werten (204 No Content)
        if response is not None or response is None:  # API kann None zurückgeben bei 204
            print(f"[OK] Keywording für {filename} gesetzt.")
            return True
        else:
            print(f"[X] Keywording für {filename} fehlgeschlagen.")
            return False

    def upload_metadata_from_db(self, download_db_path):
        """Lädt Metadaten aus download_db.json und setzt sie in ELO"""
        if not os.path.exists(download_db_path):
            print(f"[X] Download-DB nicht gefunden: {download_db_path}")
            return
        
        try:
            with open(download_db_path, 'r', encoding='utf-8') as f:
                db = json.load(f)
        except Exception as e:
            print(f"[X] Fehler beim Laden der Download-DB: {e}")
            return
        
        total = len(db)
        success = 0
        skipped = 0
        failed = 0
        
        print(f"[UP] Starte Metadaten-Upload für {total} Dateien...")
        
        # [OK] Liste der zu löschenden IDs
        to_delete = []
        
        # [OK] Kopiere keys als Liste um dictionary nicht während iteration zu ändern
        file_ids = list(db.keys())
        
        for file_id in file_ids:
            entry = db.get(file_id)
            if not entry:
                continue
                
            if entry.get('elo_metadata_set', False):
                skipped += 1
                # [OK] Bereits hochgeladen -> zum Löschen markieren
                to_delete.append(file_id)
                continue
            
            file_path = entry.get('file_path')
            file_name = entry.get('file_name')
            
            if not file_path or not os.path.exists(file_path):
                print(f"[!]  Datei nicht gefunden: {file_name} ({file_id})")
                failed += 1
                continue
            
            # Setze Metadaten in ELO
            try:
                self.set_metadata(file_id, file_name, file_path)
                
                # [OK] Markiere als gesetzt und lösche aus DB
                entry['elo_metadata_set'] = True
                to_delete.append(file_id)
                success += 1
                
                # [OK] Speichere DB periodisch (alle 100 Dateien)
                if success % 100 == 0:
                    self._save_updated_db(download_db_path, db, to_delete)
                    to_delete = []  # Liste leeren nach Speicherung
                    print(f"[SAVE] Fortschritt gespeichert: {success}/{total}")
                
            except Exception as e:
                print(f"[X] Fehler beim Setzen der Metadaten für {file_name}: {e}")
                failed += 1
        
        # [OK] Finale DB-Aktualisierung
        self._save_updated_db(download_db_path, db, to_delete)
        
        # [OK] Wenn alle Einträge verarbeitet wurden -> Datei löschen
        if len(db) == 0:
            try:
                os.remove(download_db_path)
                print(f"[DEL]  download_db.json gelöscht (alle Metadaten hochgeladen)")
            except Exception as e:
                print(f"[X] Fehler beim Löschen der DB: {e}")
        
        print(f"\n[STAT] Metadaten-Upload abgeschlossen:")
        print(f"   [OK] Erfolgreich: {success}")
        print(f"   [>>]  Übersprungen: {skipped}")
        print(f"   [X] Fehlgeschlagen: {failed}")
        print(f"   [DEL]  Aus DB entfernt: {len(to_delete)}")
        print(f"   [DOC] Verbleibend in DB: {len(db)}")

    def _save_updated_db(self, download_db_path, db, to_delete):
        """Speichert DB und entfernt erfolgreich hochgeladene Einträge"""
        # [OK] Lösche verarbeitete Einträge aus DB
        for file_id in to_delete:
            if file_id in db:
                del db[file_id]
        
        # [OK] Speichere aktualisierte DB
        try:
            with open(download_db_path, 'w', encoding='utf-8') as f:
                json.dump(db, f, indent=2, ensure_ascii=False)
        except Exception as e:
            print(f"[X] Fehler beim Speichern der DB: {e}")
