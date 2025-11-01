
from .elo_client import EloClient

class EloMetadata:
    def __init__(self, client):
        self.client = client

    def set_metadata(self, file_id, filename, save_path):
        data = {
            "fields": {
                "EXPORT_GRP": filename,
                "EXPORT_PATH": save_path,
                "EXPORT_TYPE": "script - file export2",
                "EXPORTED": "1",
                "EXPORTET_ACL": "0"
            }
        }
        response = self.client.patch(f"/api/files/{file_id}/keywording", data)
        if response is not None:
            print(f"Keywording für {filename} erfolgreich gesetzt.")
        else:
            print(f"Keywording für {filename} fehlgeschlagen.")
