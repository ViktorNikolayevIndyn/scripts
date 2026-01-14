class EloACL:
    def __init__(self, client):
        self.client = client

    def print_acl(self, file_id, current_acl, phase="Vor dem Setzen"):
        if current_acl:
            print(f"\n🔎 {phase} → Aktuelle Berechtigungen für Datei {file_id}:")
            for permission in current_acl:
                user = permission.get('member')
                access = permission.get('access')
                print(f"👤 Benutzer/Gruppe: {user} → Berechtigungen: {access}")
        else:
            print(f"[X] Keine ACL-Einträge für Datei {file_id} vorhanden.")

    def set_read_only(self, file_id, filename):
        file_info = self.client.get(f"/api/files/{file_id}/info")
        file_info2 = self.client.get(f"/api/files/{file_id}/keywording")

        if not file_info:
            print(f"[X] Datei {file_id} nicht gefunden.")
            return

        print(f"[DOC] API-Antwort für Datei {file_id}: {file_info}")
        print(f"[DOC] API-Antwort für Datei {file_id}: {file_info2}")

        attr = file_info2.get('fields', {})
        exported_flag = attr.get('EXPORTED')

        if exported_flag != '1':
            print(f"[!] Datei {file_id} hat nicht das Attribut 'EXPORTED:1' → wird jetzt gesetzt...")
            self.client.patch(f"/api/files/{file_id}/keywording", {"fields": {"EXPORTED": "1"}})
            file_info2 = self.client.get(f"/api/files/{file_id}/keywording")
            attr = file_info2.get('fields', {})
            exported_flag = attr.get('EXPORTED')

        if exported_flag == '1':
            current_acl = self.client.get(f"/api/files/{file_id}/acl")
            self.print_acl(file_id, current_acl, "Vor dem Setzen")

            if current_acl:
                new_acl = []
                for permission in current_acl:
                    updated_access = []
                    if 'R' in permission.get('access', []):
                        updated_access.append('R')
                    if 'P' in permission.get('access', []):
                        updated_access.append('P')

                    if updated_access:
                        new_acl.append({
                            'member': permission['member'],
                            'access': ''.join(updated_access)
                        })

                acl_data = new_acl
                response = self.client.put(f"/api/files/{file_id}/acl", acl_data)
                if response is not None:
                    print(f"[OK] Schreibrechte für Datei {file_id} entfernt. Andere Rechte wurden beibehalten.")
                else:
                    print(f"[X] Fehler beim Setzen der ACL für Datei {file_id}.")

                updated_acl = self.client.get(f"/api/files/{file_id}/acl")
                self.print_acl(file_id, updated_acl, "Nach dem Setzen")
            else:
                print(f"[X] Keine ACL-Einträge für Datei {file_id} gefunden.")
        else:
            print(f"[X] Datei {file_id} hat immer noch nicht das Attribut 'EXPORTED:1'")
