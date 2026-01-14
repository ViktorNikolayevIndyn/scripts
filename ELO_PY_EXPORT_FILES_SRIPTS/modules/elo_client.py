import requests
from requests.auth import HTTPBasicAuth
import sys
import os
import time

# Add the project root directory to the system path
sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

class EloClient:
    def __init__(self, base_url, username, password):
        self.base_url = base_url
        self.auth = HTTPBasicAuth(username, password)
        # [OK] Session für Connection-Pooling und Wiederverwendung
        self.session = requests.Session()
        self.session.auth = self.auth

    def check_login(self):
        url = f"{self.base_url}/api/system/colors/_all"
        response = self.session.get(url)
        return response.status_code == 200

    def _print_progress_bar(self, iteration, total, prefix='', suffix='', decimals=1, length=50, fill='#'):
        """Druckt Progress Bar (CMD-kompatibel ohne Unicode)"""
        if total == 0:
            return
        percent = ("{0:." + str(decimals) + "f}").format(100 * (iteration / float(total)))
        filled_length = int(length * iteration // total)
        bar = fill * filled_length + '-' * (length - filled_length)
        
        # Formatiere Bytes
        downloaded_mb = iteration / (1024 * 1024)
        total_mb = total / (1024 * 1024)
        
        print(f'\r{prefix} [{bar}] {percent}% ({downloaded_mb:.1f}/{total_mb:.1f} MB) {suffix}', end='', flush=True)

    def get(self, endpoint, is_binary=False):
        url = f"{self.base_url}{endpoint}"
        response = self.session.get(url)

        if response.status_code != 200:
            print(f"Fehler bei GET {url}: {response.status_code} - {response.text}")
            return None

        if is_binary:
            return response.content

        try:
            return response.json()
        except requests.exceptions.JSONDecodeError:
            print(f"Fehler beim Decodieren von JSON bei {url}")
            return None

    def download_file_streaming(self, endpoint, file_path, max_retries=3, chunk_size=8192):
        """Lädt große Datei mit Streaming und Retry-Logik herunter"""
        url = f"{self.base_url}{endpoint}"
        
        for attempt in range(max_retries):
            try:
                # Prüfe ob Datei teilweise existiert (für Resume)
                resume_byte_pos = 0
                mode = 'wb'
                if os.path.exists(file_path):
                    resume_byte_pos = os.path.getsize(file_path)
                    mode = 'ab'  # Append mode
                    print(f"[~] Fortsetzen ab Byte {resume_byte_pos:,}...")
                
                headers = {}
                if resume_byte_pos > 0:
                    headers['Range'] = f'bytes={resume_byte_pos}-'
                
                response = self.session.get(url, stream=True, headers=headers, timeout=300)
                
                if response.status_code not in [200, 206]:  # 206 = Partial Content
                    print(f"[X] Fehler: HTTP {response.status_code}")
                    return False
                
                total_size = int(response.headers.get('content-length', 0))
                downloaded = resume_byte_pos
                total_final = total_size + resume_byte_pos
                
                # [OK] Progress Bar Initial
                self._print_progress_bar(downloaded, total_final, prefix='Download:', suffix='', length=50)
                
                with open(file_path, mode) as f:
                    for chunk in response.iter_content(chunk_size=chunk_size):
                        if chunk:
                            f.write(chunk)
                            downloaded += len(chunk)
                            
                            # [OK] Progress Bar Update
                            self._print_progress_bar(downloaded, total_final, prefix='Download:', suffix='', length=50)
                
                print()  # Neue Zeile nach Progress Bar
                print(f"[OK] Download abgeschlossen: {downloaded:,} Bytes")
                return True
                
            except (requests.exceptions.ChunkedEncodingError, 
                    requests.exceptions.ConnectionError,
                    requests.exceptions.Timeout) as e:
                print(f"[!]  Versuch {attempt + 1}/{max_retries} fehlgeschlagen: {type(e).__name__}")
                if attempt < max_retries - 1:
                    wait_time = (attempt + 1) * 2
                    print(f"[...] Warte {wait_time}s vor erneutem Versuch...")
                    time.sleep(wait_time)
                else:
                    print(f"[X] Download nach {max_retries} Versuchen fehlgeschlagen")
                    return False
            except Exception as e:
                print(f"[X] Unerwarteter Fehler: {e}")
                return False
        
        return False

    def post(self, endpoint, data):
        url = f"{self.base_url}{endpoint}"
        response = self.session.post(url, json=data)
        if response.status_code in [200, 201]:
            try:
                return response.json()
            except requests.exceptions.JSONDecodeError:
                print(f"Leere Antwort von {url} erhalten.")
                return None
        else:
            print(f"Fehler bei POST {url}: {response.status_code} - {response.text}")
            return None

    def patch(self, endpoint, data):
        url = f"{self.base_url}{endpoint}"
        response = self.session.patch(url, json=data)
        if response.status_code in [200, 204]:  # 204 = No Content (успех без тела ответа)
            try:
                return response.json()
            except requests.exceptions.JSONDecodeError:
                # [OK] Пустой ответ - это нормально для 204 No Content
                return True  # Возвращаем True вместо None
        else:
            print(f"[X] Fehler bei PATCH {url}: {response.status_code} - {response.text}")
            return None

    def put(self, endpoint, data):
        url = f"{self.base_url}{endpoint}"
        response = self.session.put(url, json=data)
        if response.status_code in [200, 204]:
            try:
                return response.json()
            except requests.exceptions.JSONDecodeError:
                print(f"Leere Antwort von {url} erhalten.")
                return None
        else:
            print(f"Fehler bei PUT {url}: {response.status_code} - {response.text}")
            return None
