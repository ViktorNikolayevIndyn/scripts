import os
import json

class EloMetadataExporter:
    def __init__(self, client, output_path):
        self.client = client
        self.output_path = os.path.abspath(output_path)
        self.metadata = {}

    def collect_metadata(self, file_id, local_path):
        metadata = self.client.get(f"/api/files/{file_id}/keywording")
        file_info = self.client.get(f"/api/files/{file_id}/info")

        if metadata and file_info:
            is_dir = file_info.get('isDir', False)
            parent_folder_id = file_info.get('parentId', None)
            parent_folder_name = None

            # [OK] Parent-Informationen abrufen
            if parent_folder_id:
                parent_info = self.client.get(f"/api/files/{parent_folder_id}/info")
                if parent_info:
                    parent_folder_name = parent_info.get('name')

            # [OK] Dateinamen und Endung setzen
            file_name = file_info.get('name')
            if not is_dir and '.' not in file_name:
                file_extension = metadata.get('fields', {}).get('ELO_FNAME', '')
                if file_extension and '.' in file_extension:
                    file_name = f"{file_name}{os.path.splitext(file_extension)[1]}"

            # [OK] Ordnerstruktur im JSON erstellen
            path_parts = local_path.strip("/").split("/")
            current_level = self.metadata

            for part in path_parts[:-1]:
                if part not in current_level:
                    current_level[part] = {}
                current_level = current_level[part]

            # [OK] Metadaten für die Datei/Ordner setzen
            current_level[file_name] = {
                "file_id": file_id,
                "name": file_name,
                "isDir": is_dir,
                "local_path": f"/{local_path}",
                "parent_folder_id": parent_folder_id,
                "parent_folder_name": parent_folder_name,
                "metadata": metadata
            }

    def save_metadata(self):
        if self.metadata:
            # [OK] Direkt im Root-Ordner speichern → Kein zusätzlicher 'metadata'-Ordner!
            metadata_path = os.path.join(self.output_path, "metadata.json")
            with open(metadata_path, "w", encoding="utf-8") as f:
                json.dump(self.metadata, f, indent=4)

            print(f"[OK] Metadaten gespeichert unter: {metadata_path}")
        else:
            print(f"[X] Keine Metadaten verfügbar.")
