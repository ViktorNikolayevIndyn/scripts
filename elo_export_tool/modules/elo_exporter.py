import os
import time
from datetime import datetime
from .elo_metadata_exporter import EloMetadataExporter
from config import SAVE_METADATA_ENABLED

class EloExporter:
    def __init__(self, client, output_path):
        self.client = client
        self.output_path = output_path
        self.metadata_exporter = None

    def sanitize_filename(self, filename):
        # Ersetze ungültige Zeichen durch Unterstriche
        return filename.replace('/', '_').replace('\\', '_').replace(':', '_').replace('*', '_').replace('?', '_').replace('"', '_').replace('<', '_').replace('>', '_').replace('|', '_')

    def download_file(self, file_id, save_path):
        file_info = self.client.get(f"/api/files/{file_id}/info")
        metadata = self.client.get(f"/api/files/{file_id}/keywording")
        if not file_info:
            print(f"❌ Datei {file_id} nicht gefunden.")
            return

        filename = self.sanitize_filename(file_info['name'])

        # ✅ Endung während des Downloads übernehmen
        if '.' not in filename and metadata:
            file_extension = metadata.get('fields', {}).get('ELO_FNAME', '')
            if file_extension and '.' in file_extension:
                _, ext = os.path.splitext(file_extension)
                if ext:
                    filename = f"{filename}{ext}"

        save_path = os.path.join(save_path, filename)

        print(f"📥 Speichere Datei unter: {save_path}")

        # Verzeichnis erstellen, falls es nicht existiert
        os.makedirs(os.path.dirname(save_path), exist_ok=True)

        # Datei herunterladen
        response = self.client.get(f"/api/files/{file_id}/download", is_binary=True)
        if response:
            with open(save_path, "wb") as f:
                f.write(response)
            print(f"✅ Datei {filename} erfolgreich heruntergeladen.")

            # ✅ Metadata erfassen (statt save_metadata!)
            if SAVE_METADATA_ENABLED and self.metadata_exporter:
                relative_path = os.path.relpath(save_path, self.output_path).replace("\\", "/")
                self.metadata_exporter.collect_metadata(file_id, f"/{relative_path}")

            # ✅ Timestamps setzen (dateModified, dateArchived)
            modified_time = file_info.get('dateModified')
            archived_time = file_info.get('dateArchived')

            if modified_time:
                mod_time = time.mktime(datetime.strptime(modified_time, "%Y-%m-%dT%H:%M:%SZ").timetuple())
                os.utime(save_path, (mod_time, mod_time))
                print(f"🕒 Datei-Timestamp auf '{modified_time}' gesetzt (Änderungsdatum).")

            if archived_time:
                arch_time = time.mktime(datetime.strptime(archived_time, "%Y-%m-%dT%H:%M:%SZ").timetuple())
                os.utime(save_path, (arch_time, arch_time))
                print(f"🕒 Datei-Archiv-Timestamp auf '{archived_time}' gesetzt.")

        else:
            print(f"❌ Fehler beim Herunterladen von Datei {file_id}")



    def download_folder2(self, folder_id, save_path, is_root=True):
        folder_info = self.client.get(f"/api/files/{folder_id}/info")
        if not folder_info:
            print(f"❌ Ordner {folder_id} nicht gefunden.")
            return

        root_folder_name = self.sanitize_filename(folder_info['name'])
        root_path = os.path.join(save_path, root_folder_name)
        os.makedirs(root_path, exist_ok=True)

        print(f"📁 Lade Ordner '{root_folder_name}' in: {root_path}")

        # ✅ Metadata-Exporter direkt im ersten Root-Ordner erstellen
        if SAVE_METADATA_ENABLED and is_root:
            metadata_path = os.path.join(root_path, "metadata")
            if not os.path.exists(metadata_path):
                print(f"📁 Erstelle Metadata-Ordner: {metadata_path}")
                os.makedirs(metadata_path, exist_ok=True)
            # ✅ Für jeden Root-Ordner eigene Instanz!
            self.metadata_exporter = EloMetadataExporter(self.client, metadata_path)

        items = self.client.get(f"/api/files/{folder_id}/children")
        if items:
            for item in items:
                sanitized_name = self.sanitize_filename(item['name'])
                item_path = os.path.join(root_path, sanitized_name)

                if item['isDir']:
                    self.download_folder(item['id'], root_path, is_root=False)
                else:
                    self.download_file(item['id'], root_path)

                # ✅ Metadata erfassen (nach Download)
                if SAVE_METADATA_ENABLED and self.metadata_exporter:
                    relative_path = os.path.relpath(item_path, save_path).replace("\\", "/")
                    self.metadata_exporter.collect_metadata(item['id'], f"/{relative_path}")

        # ✅ Metadaten nach vollständigem Download speichern (für jeden Root-Ordner)
        if is_root and SAVE_METADATA_ENABLED and self.metadata_exporter:
            self.metadata_exporter.save_metadata()

    def download_folder(self, folder_id, save_path, is_root=True):
        folder_info = self.client.get(f"/api/files/{folder_id}/info")
        if not folder_info:
            print(f"❌ Ordner {folder_id} nicht gefunden.")
            return

        root_folder_name = self.sanitize_filename(folder_info['name'])
        root_path = os.path.join(save_path, root_folder_name)
        os.makedirs(root_path, exist_ok=True)

        print(f"📁 Lade Ordner '{root_folder_name}' in: {root_path}")

        # ✅ Metadata-Exporter direkt im ersten Root-Ordner erstellen
        if SAVE_METADATA_ENABLED and is_root:
            metadata_path = os.path.join(root_path, "metadata")
            if not os.path.exists(metadata_path):
                print(f"📁 Erstelle Metadata-Ordner: {metadata_path}")
                os.makedirs(metadata_path, exist_ok=True)
            self.metadata_exporter = EloMetadataExporter(self.client, metadata_path)

        items = self.client.get(f"/api/files/{folder_id}/children")
        if items:
            for item in items:
                sanitized_name = self.sanitize_filename(item['name'])
                item_path = os.path.join(root_path, sanitized_name)

                if item['isDir']:
                    self.download_folder(item['id'], root_path, is_root=False)
                else:
                    self.download_file(item['id'], root_path)

                # ✅ Metadata erfassen (nach Download)
                if SAVE_METADATA_ENABLED and self.metadata_exporter:
                    relative_path = os.path.relpath(item_path, save_path).replace("\\", "/")
                    self.metadata_exporter.collect_metadata(item['id'], f"/{relative_path}")

        # ✅ Timestamp für den Ordner setzen
        modified_time = folder_info.get('dateModified')
        archived_time = folder_info.get('dateArchived')

        if modified_time:
            mod_time = time.mktime(datetime.strptime(modified_time, "%Y-%m-%dT%H:%M:%SZ").timetuple())
            os.utime(root_path, (mod_time, mod_time))
            print(f"🕒 Ordner-Timestamp auf '{modified_time}' gesetzt (Änderungsdatum).")

        if archived_time:
            arch_time = time.mktime(datetime.strptime(archived_time, "%Y-%m-%dT%H:%M:%SZ").timetuple())
            os.utime(root_path, (arch_time, arch_time))
            print(f"🕒 Ordner-Archiv-Timestamp auf '{archived_time}' gesetzt.")

        # ✅ Metadaten nach vollständigem Download speichern
        if is_root and SAVE_METADATA_ENABLED and self.metadata_exporter:
            self.metadata_exporter.save_metadata()