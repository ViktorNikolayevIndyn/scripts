import os
import json
import time
from datetime import datetime

class EloMetadataExporter:
    def __init__(self, client, output_path):
        self.client = client
        self.output_path = os.path.abspath(output_path)
        self.metadata_path = os.path.join(self.output_path, "metadata.json")
        self.metadata = []
        os.makedirs(os.path.dirname(self.metadata_path), exist_ok=True)

    def collect_metadata(self, file_id, local_path):
        metadata = self.client.get(f"/api/files/{file_id}/keywording")
        file_info = self.client.get(f"/api/files/{file_id}/info")

        if metadata and file_info:
            # ✅ Dateityp und Parent-Informationen abrufen
            is_dir = file_info.get('isDir', False)
            parent_folder_id = file_info.get('parentId', None)
            parent_folder_name = None

            if parent_folder_id:
                parent_info = self.client.get(f"/api/files/{parent_folder_id}/info")
                if parent_info:
                    parent_folder_name = parent_info.get('name')

            # ✅ Endung aus Metadaten auslesen, wenn vorhanden
            file_name = file_info.get('name')
            if not is_dir and '.' not in file_name:
                file_extension = metadata.get('fields', {}).get('ELO_FNAME', '')
                if file_extension and '.' in file_extension:
                    file_name = f"{file_name}{os.path.splitext(file_extension)[1]}"

            # ✅ Timestamps auslesen
            date_modified = file_info.get('dateModified', '')
            date_archived = file_info.get('dateArchived', '')

            # ✅ Version, falls vorhanden
            version = metadata.get('fields', {}).get('VERSION', '')

            # ✅ Dokumenttyp aus Metadaten oder File-Typ übernehmen
            doctype = metadata.get('fields', {}).get('DOC_TYPE') or file_info.get('type', '')

            # ✅ Änderungschronik abfragen
            history = self.get_history(file_id)

            # ✅ Clean local path → auf Basis des Export-Roots
            if is_dir:
                clean_local_path = local_path
            else:
                clean_local_path = f"{local_path}/{file_name}" if local_path else f"/{file_name}"
            clean_local_path = f"/{clean_local_path}" if not clean_local_path.startswith("/") else clean_local_path

            # ✅ Datenstruktur vorbereiten
            data = {
                "file_id": file_id,
                "name": file_name,
                "isDir": is_dir,
                "local_path": clean_local_path,
                "parent_folder_id": parent_folder_id,
                "parent_folder_name": parent_folder_name,
                "date_modified": date_modified if date_modified else None,
                "date_archived": date_archived if date_archived else None,
                "version": version if version else None,  # ✅ Version hinzufügen
                "doctype": doctype if doctype else None,  # ✅ Doctype hinzufügen
                "history": history if history else None,  # ✅ Änderungschronik hinzufügen
                "metadata": metadata
            }

            self.metadata.append(data)

    def get_history(self, file_id):
        # ✅ Änderungschronik abrufen
        response = self.client.get(f"/api/files/{file_id}/history")
        if response:
            history = []
            for entry in response:
                history.append({
                    "timestamp": entry.get('date', None),
                    "user": entry.get('user', None),
                    "action": entry.get('action', None)
                })
            return history
        return None

    def save_metadata(self):
        if self.metadata:
            with open(self.metadata_path, "w", encoding="utf-8") as f:
                json.dump(self.metadata, f, indent=4)

            print(f"✅ Metadaten gespeichert unter: {self.metadata_path}")
        else:
            print(f"❌ Keine Metadaten verfügbar.")
