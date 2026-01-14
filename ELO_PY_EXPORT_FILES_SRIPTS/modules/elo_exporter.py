import os
import time
import json
from datetime import datetime
from .elo_metadata_exporter import EloMetadataExporter
from config import SAVE_METADATA_ENABLED, EXCLUDE_FOLDERS

class EloExporter:
    def __init__(self, client, output_path, set_elo_metadata=False):
        self.client = client
        self.output_path = output_path
        self.metadata_exporter = None
        self.download_db_path = os.path.join(output_path, "download_db.json")
        self.download_db = self._load_download_db()
        self.set_elo_metadata = set_elo_metadata  # Флаг для установки метаданных в ELO

    def _load_download_db(self):
        """Lädt die Download-Datenbank aus JSON"""
        if os.path.exists(self.download_db_path):
            try:
                with open(self.download_db_path, 'r', encoding='utf-8') as f:
                    return json.load(f)
            except Exception as e:
                print(f"[!]  Fehler beim Laden der Download-DB: {e}")
                return {}
        return {}

    def _save_download_db(self):
        """Speichert die Download-Datenbank als JSON"""
        try:
            os.makedirs(os.path.dirname(self.download_db_path), exist_ok=True)
            with open(self.download_db_path, 'w', encoding='utf-8') as f:
                json.dump(self.download_db, f, indent=2, ensure_ascii=False)
        except Exception as e:
            print(f"[X] Fehler beim Speichern der Download-DB: {e}")

    def _add_to_download_db(self, file_id, file_path, file_info, metadata):
        """Fügt Datei zur Download-Datenbank hinzu"""
        self.download_db[str(file_id)] = {
            "file_id": file_id,
            "file_path": file_path,
            "file_name": file_info.get('name'),
            "size": file_info.get('size', 0),
            "dateModified": file_info.get('dateModified'),
            "dateArchived": file_info.get('dateArchived'),
            "downloaded_at": datetime.now().isoformat(),
            "metadata": metadata.get('fields', {}) if metadata else {},
            "elo_metadata_set": False  # Ob Metadaten in ELO gesetzt wurden
        }
        self._save_download_db()

    def sanitize_filename(self, filename):
        # Ersetze ungültige Zeichen durch Unterstriche
        filename = filename.replace('/', '_').replace('\\', '_').replace(':', '_').replace('*', '_').replace('?', '_').replace('"', '_').replace('<', '_').replace('>', '_').replace('|', '_')
        # Ersetze Umlaute für bessere Kompatibilität
        filename = filename.replace('ä', 'ae').replace('ö', 'oe').replace('ü', 'ue').replace('ß', 'ss')
        filename = filename.replace('Ä', 'Ae').replace('Ö', 'Oe').replace('Ü', 'Ue')
        return filename

    def should_exclude_folder(self, folder_path, folder_name, original_name):
        """Prüft ob ein Ordner aufgrund der Exclude-Liste übersprungen werden soll"""
        for exclude_pattern in EXCLUDE_FOLDERS:
            # Prüfe originalen Namen (vor sanitize)
            if original_name == exclude_pattern:
                return True
            # Prüfe sanitized Namen
            if folder_name == exclude_pattern:
                return True
            # Prüfe sanitized Pattern (TN/LS/AB -> TN_LS_AB)
            sanitized_pattern = exclude_pattern.replace('/', '_').replace('\\', '_')
            if folder_name == sanitized_pattern:
                return True
            # Prüfe ob das Pattern im Pfad vorkommt
            if exclude_pattern in folder_path or sanitized_pattern in folder_path:
                return True
            # Prüfe Pfad-Ende
            normalized_pattern = exclude_pattern.replace('/', os.sep)
            if folder_path.endswith(normalized_pattern):
                return True
        return False

    def download_file(self, file_id, save_path):
        # [OK] Prüfe Download-DB zuerst
        db_entry = self.download_db.get(str(file_id))
        
        file_info = self.client.get(f"/api/files/{file_id}/info")
        metadata = self.client.get(f"/api/files/{file_id}/keywording")
        if not file_info:
            print(f"[X] Datei {file_id} nicht gefunden.")
            return

        filename = self.sanitize_filename(file_info['name'])

        # [OK] Endung während des Downloads übernehmen
        if '.' not in filename and metadata:
            file_extension = metadata.get('fields', {}).get('ELO_FNAME', '')
            if file_extension and '.' in file_extension:
                _, ext = os.path.splitext(file_extension)
                if ext:
                    filename = f"{filename}{ext}"

        save_path = os.path.join(save_path, filename)

        # [OK] Skip wenn Datei in DB und existiert mit korrekter Größe
        if db_entry and os.path.exists(save_path):
            existing_size = os.path.getsize(save_path)
            expected_size = db_entry.get('size', 0)
            
            if existing_size > 0 and (expected_size == 0 or existing_size == expected_size):
                print(f"[>>]  Datei bereits heruntergeladen (DB): {filename}")
                
                # [OK] Metadata trotzdem erfassen für JSON-Export
                if SAVE_METADATA_ENABLED and self.metadata_exporter:
                    relative_path = os.path.relpath(save_path, self.output_path).replace("\\", "/")
                    self.metadata_exporter.collect_metadata(file_id, f"/{relative_path}")
                return

        # [OK] Fallback: Prüfe nur Dateisystem
        if os.path.exists(save_path):
            existing_size = os.path.getsize(save_path)
            expected_size = file_info.get('size', 0)
            
            if existing_size > 0:
                if expected_size > 0 and existing_size == expected_size:
                    print(f"[>>]  Datei bereits vorhanden (gleiche Größe): {filename}")
                    self._add_to_download_db(file_id, save_path, file_info, metadata)
                    
                    if SAVE_METADATA_ENABLED and self.metadata_exporter:
                        relative_path = os.path.relpath(save_path, self.output_path).replace("\\", "/")
                        self.metadata_exporter.collect_metadata(file_id, f"/{relative_path}")
                    return
                elif expected_size == 0:
                    print(f"[>>]  Datei bereits vorhanden: {filename}")
                    self._add_to_download_db(file_id, save_path, file_info, metadata)
                    
                    if SAVE_METADATA_ENABLED and self.metadata_exporter:
                        relative_path = os.path.relpath(save_path, self.output_path).replace("\\", "/")
                        self.metadata_exporter.collect_metadata(file_id, f"/{relative_path}")
                    return
                else:
                    print(f"[!]  Datei existiert mit anderer Größe ({existing_size} vs {expected_size}): {filename} - Download erneut...")

        print(f"[>>] Speichere Datei unter: {save_path}")

        # Verzeichnis erstellen, falls es nicht existiert
        os.makedirs(os.path.dirname(save_path), exist_ok=True)

        # [OK] Используем ВСЕГДА streaming download с retry (безопаснее для всех размеров)
        file_size = file_info.get('size', 0)
        
        if file_size > 50 * 1024 * 1024:  # > 50 MB - показать сообщение
            print(f"[PKG] Große Datei ({file_size:,} Bytes) - verwende Streaming-Download...")
        
        success = self.client.download_file_streaming(
            f"/api/files/{file_id}/download", 
            save_path,
            max_retries=5,
            chunk_size=1024 * 1024  # 1MB chunks
        )
        
        if not success:
            print(f"[X] Download fehlgeschlagen: {filename}")
            return

        print(f"[OK] Datei {filename} erfolgreich heruntergeladen.")
        
        # [OK] Setze Metadaten in ELO wenn aktiviert
        if self.set_elo_metadata:
            from .elo_metadata import EloMetadata
            metadata_setter = EloMetadata(self.client)
            metadata_setter.set_metadata(file_id, filename, save_path)
            
            # Markiere in DB als gesetzt
            if str(file_id) in self.download_db:
                self.download_db[str(file_id)]['elo_metadata_set'] = True
                self._save_download_db()
        
        # [OK] In Download-DB speichern
        self._add_to_download_db(file_id, save_path, file_info, metadata)

        # [OK] Metadata erfassen (statt save_metadata!)
        if SAVE_METADATA_ENABLED and self.metadata_exporter:
            relative_path = os.path.relpath(save_path, self.output_path).replace("\\", "/")
            self.metadata_exporter.collect_metadata(file_id, f"/{relative_path}")

        # [OK] Timestamps setzen (dateModified, dateArchived)
        modified_time = file_info.get('dateModified')
        archived_time = file_info.get('dateArchived')

        if modified_time:
            mod_time = time.mktime(datetime.strptime(modified_time, "%Y-%m-%dT%H:%M:%SZ").timetuple())
            os.utime(save_path, (mod_time, mod_time))
            print(f"[T] Datei-Timestamp auf '{modified_time}' gesetzt (Änderungsdatum).")

        if archived_time:
            arch_time = time.mktime(datetime.strptime(archived_time, "%Y-%m-%dT%H:%M:%SZ").timetuple())
            os.utime(save_path, (arch_time, arch_time))
            print(f"[T] Datei-Archiv-Timestamp auf '{archived_time}' gesetzt.")



    def download_folder(self, folder_id, save_path, is_root=True, current_path=""):
        folder_info = self.client.get(f"/api/files/{folder_id}/info")
        if not folder_info:
            print(f"[X] Ordner {folder_id} nicht gefunden.")
            return

        root_folder_name = self.sanitize_filename(folder_info['name'])
        root_path = os.path.join(save_path, root_folder_name)
        os.makedirs(root_path, exist_ok=True)

        print(f"[DIR] Lade Ordner '{root_folder_name}' in: {root_path}")

        # [OK] Metadata-Exporter direkt im ersten Root-Ordner erstellen
        if SAVE_METADATA_ENABLED and is_root:
            metadata_path = os.path.join(root_path, "metadata")
            if not os.path.exists(metadata_path):
                print(f"[DIR] Erstelle Metadata-Ordner: {metadata_path}")
                os.makedirs(metadata_path, exist_ok=True)
            self.metadata_exporter = EloMetadataExporter(self.client, metadata_path)

        items = self.client.get(f"/api/files/{folder_id}/children")
        if items:
            for item in items:
                original_name = item['name']
                sanitized_name = self.sanitize_filename(original_name)
                item_path = os.path.join(root_path, sanitized_name)
                relative_path = os.path.join(current_path, root_folder_name, sanitized_name) if current_path or not is_root else os.path.join(root_folder_name, sanitized_name)

                if item['isDir']:
                    # [OK] Prüfe ob dieser Ordner ausgeschlossen werden soll (MIT original_name!)
                    if self.should_exclude_folder(relative_path, sanitized_name, original_name):
                        print(f"[!] Ordner übersprungen (Exclude-Liste): {original_name} -> {relative_path}")
                        continue
                    
                    # Rekursiv den Unterordner verarbeiten
                    new_current_path = os.path.join(current_path, root_folder_name) if current_path else root_folder_name
                    self.download_folder(item['id'], root_path, is_root=False, current_path=new_current_path)
                else:
                    self.download_file(item['id'], root_path)

                # [OK] Metadata erfassen (nach Download)
                if SAVE_METADATA_ENABLED and self.metadata_exporter:
                    relative_path = os.path.relpath(item_path, save_path).replace("\\", "/")
                    self.metadata_exporter.collect_metadata(item['id'], f"/{relative_path}")

        # [OK] Timestamp für den Ordner setzen
        modified_time = folder_info.get('dateModified')
        archived_time = folder_info.get('dateArchived')

        if modified_time:
            mod_time = time.mktime(datetime.strptime(modified_time, "%Y-%m-%dT%H:%M:%SZ").timetuple())
            os.utime(root_path, (mod_time, mod_time))
            print(f"[T] Ordner-Timestamp auf '{modified_time}' gesetzt (Änderungsdatum).")

        if archived_time:
            arch_time = time.mktime(datetime.strptime(archived_time, "%Y-%m-%dT%H:%M:%SZ").timetuple())
            os.utime(root_path, (arch_time, arch_time))
            print(f"[T] Ordner-Archiv-Timestamp auf '{archived_time}' gesetzt.")

        # [OK] Metadaten nach vollständigem Download speichern
        if is_root and SAVE_METADATA_ENABLED and self.metadata_exporter:
            self.metadata_exporter.save_metadata()