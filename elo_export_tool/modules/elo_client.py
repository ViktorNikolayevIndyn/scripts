import requests
from requests.auth import HTTPBasicAuth
import sys
import os

# Add the project root directory to the system path
sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

class EloClient:
    def __init__(self, base_url, username, password):
        self.base_url = base_url
        self.auth = HTTPBasicAuth(username, password)

    def check_login(self):
        url = f"{self.base_url}/api/system/colors/_all"
        response = requests.get(url, auth=self.auth)
        return response.status_code == 200

    def get(self, endpoint, is_binary=False):
        url = f"{self.base_url}{endpoint}"
        response = requests.get(url, auth=self.auth)

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

    def post(self, endpoint, data):
        url = f"{self.base_url}{endpoint}"
        response = requests.post(url, json=data, auth=self.auth)
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
        response = requests.patch(url, json=data, auth=self.auth)
        if response.status_code in [200, 204]:
            try:
                return response.json()
            except requests.exceptions.JSONDecodeError:
                print(f"Leere Antwort von {url} erhalten.")
                return None
        else:
            print(f"Fehler bei PATCH {url}: {response.status_code} - {response.text}")
            return None

    def put(self, endpoint, data):
        url = f"{self.base_url}{endpoint}"
        response = requests.put(url, json=data, auth=self.auth)
        if response.status_code in [200, 204]:
            try:
                return response.json()
            except requests.exceptions.JSONDecodeError:
                print(f"Leere Antwort von {url} erhalten.")
                return None
        else:
            print(f"Fehler bei PUT {url}: {response.status_code} - {response.text}")
            return None
