# n8n One-Click Setup mit Cloudflare Tunnel für Debian 12/13

Dieses Skript richtet automatisch einen sicheren n8n-Server mit Cloudflare Tunnel auf Debian 12 oder 13 ein.

## Features

- ✅ Vollständig automatisiertes Setup
- ✅ System-Härtung (UFW Firewall, Fail2Ban)
- ✅ SSH-Hardening
- ✅ Docker & Docker Compose Installation
- ✅ n8n mit PostgreSQL-Datenbank
- ✅ Cloudflare Tunnel für sicheren Zugriff
- ✅ Automatischer Start beim Booten
- ✅ Basic Auth für n8n

## Voraussetzungen

- Frischer Debian 12 oder 13 Server
- Root-Zugriff
- Cloudflare Account mit konfiguriertem Tunnel
- Domain/Subdomain für n8n (z.B. `n8n.example.com`)

## Vorbereitung

### 1. Cloudflare Tunnel erstellen

1. Gehe zu [Cloudflare Zero Trust Dashboard](https://one.dash.cloudflare.com/)
2. Navigiere zu **Access** → **Tunnels**
3. Klicke auf **Create a tunnel**
4. Wähle **Cloudflared** als Connector
5. Gib dem Tunnel einen Namen (z.B. `n8n-server`)
6. Kopiere den **Tunnel Token** (wird später benötigt)
7. Konfiguriere die Public Hostname:
   - **Subdomain**: `n8n`
   - **Domain**: `example.com`
   - **Service**: `http://localhost:5678`

### 2. Server vorbereiten

Stelle sicher, dass du SSH-Schlüssel für den Zugriff eingerichtet hast, da das Skript Passwort-Authentifizierung deaktiviert.

```bash
# Von deinem lokalen Rechner
ssh-copy-id root@your-server-ip
```

## Installation

### Schritt 1: Repository klonen oder Dateien hochladen

```bash
# Mit Git
cd /tmp
git clone <repository-url>
cd cloudflare_scripts/n8n/n8n_install_debian/

# Oder Dateien manuell hochladen
scp -r n8n_install_debian/ root@your-server:/tmp/
```

### Schritt 2: Skript ausführen

```bash
cd /tmp/n8n_install_debian/
chmod +x setup.sh

# Option 1: Mit Umgebungsvariable
export CLOUDFLARE_TUNNEL_TOKEN="your-tunnel-token-here"
bash setup.sh

# Option 2: Token wird während der Installation abgefragt
bash setup.sh
```

### Schritt 3: Interaktive Eingaben

Das Skript fragt während der Installation:

1. **n8n Hostname**: z.B. `n8n.example.com`
2. **Basic Auth Username**: z.B. `admin` (Standard)
3. **Basic Auth Password**: Sicheres Passwort
4. **Cloudflare Tunnel Token**: Falls nicht als Umgebungsvariable gesetzt

## Was macht das Skript?

### 1. System-Härtung
- UFW Firewall aktivieren (Ports 22, 80, 443)
- Fail2Ban konfigurieren (Schutz vor Brute-Force)
- SSH härten (Passwort-Auth deaktivieren)

### 2. Docker Installation
- Offizielle Docker-Repository einbinden
- Docker Engine & Docker Compose installieren
- Docker beim Booten starten

### 3. n8n Setup
- PostgreSQL als Datenbank
- n8n Container mit allen Konfigurationen
- Volumes für persistente Daten
- Basic Auth aktiviert

### 4. Cloudflare Tunnel
- cloudflared installieren
- Systemd-Service erstellen
- Automatischer Start beim Booten

### 5. Auto-Start
- Systemd-Service für n8n
- Automatischer Start nach Reboot

## Nach der Installation

### Zugriff auf n8n

Öffne deinen Browser und gehe zu:
```
https://n8n.example.com
```

Logge dich mit deinen konfigurierten Credentials ein.

### Wichtige Pfade

- **n8n Verzeichnis**: `/opt/n8n/`
- **Docker Compose Config**: `/opt/n8n/docker-compose.yml`
- **Umgebungsvariablen**: `/opt/n8n/.env`
- **Logs**: `/var/log/server-setup.log`

### Nützliche Befehle

```bash
# n8n Logs anzeigen
cd /opt/n8n && docker compose logs -f

# n8n Container neustarten
cd /opt/n8n && docker compose restart

# n8n Container stoppen
cd /opt/n8n && docker compose down

# n8n Container starten
cd /opt/n8n && docker compose up -d

# Cloudflare Tunnel Status
systemctl status cloudflared

# Cloudflare Tunnel Logs
journalctl -u cloudflared -f

# n8n Service Status
systemctl status n8n-docker

# Firewall Status
ufw status

# Fail2Ban Status
fail2ban-client status sshd
```

### Container Status prüfen

```bash
docker ps
```

Erwartete Container:
- `n8n-n8n-1` - n8n Application
- `n8n-postgres-1` - PostgreSQL Database

### Datenbank-Backup erstellen

```bash
cd /opt/n8n
docker compose exec postgres pg_dump -U n8n n8n > backup_$(date +%Y%m%d).sql
```

## Konfiguration anpassen

### n8n Umgebungsvariablen ändern

```bash
nano /opt/n8n/.env
```

Nach Änderungen Container neu starten:
```bash
cd /opt/n8n && docker compose restart
```

### Weitere n8n Optionen

Siehe [n8n Environment Variables](https://docs.n8n.io/hosting/configuration/environment-variables/) für alle verfügbaren Optionen.

## Troubleshooting

### n8n startet nicht

```bash
# Logs prüfen
cd /opt/n8n && docker compose logs

# Container neu starten
docker compose restart
```

### Cloudflare Tunnel verbindet nicht

```bash
# Status prüfen
systemctl status cloudflared

# Logs prüfen
journalctl -u cloudflared -f

# Service neu starten
systemctl restart cloudflared
```

### Firewall-Probleme

```bash
# UFW Status
ufw status verbose

# Port öffnen (falls nötig)
ufw allow PORT/tcp
```

### SSH-Zugriff nach Installation

Falls du ausgesperrt wirst:
- Stelle sicher, dass dein SSH-Key vor der Installation kopiert wurde
- Nutze die Server-Konsole deines Hosters
- Prüfe `/etc/ssh/sshd_config`

## Sicherheitshinweise

1. **Backup erstellen**: Erstelle regelmäßig Backups der n8n-Datenbank
2. **Updates**: Halte das System und Docker-Images aktuell
3. **Passwörter**: Verwende starke Passwörter für Basic Auth
4. **Firewall**: Ändere nur Firewall-Regeln, wenn du weißt, was du tust
5. **Monitoring**: Überwache die Logs regelmäßig

## Updates

### n8n aktualisieren

```bash
cd /opt/n8n
docker compose pull
docker compose up -d
```

### System aktualisieren

```bash
apt update && apt upgrade -y
```

### cloudflared aktualisieren

```bash
curl -L --output /usr/local/bin/cloudflared https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64
chmod +x /usr/local/bin/cloudflared
systemctl restart cloudflared
```

## Deinstallation

```bash
# n8n stoppen und entfernen
cd /opt/n8n && docker compose down -v

# Services deaktivieren
systemctl disable n8n-docker
systemctl disable cloudflared

# Dateien entfernen
rm -rf /opt/n8n
rm /etc/systemd/system/n8n-docker.service
rm /etc/systemd/system/cloudflared.service
rm /usr/local/bin/cloudflared

# Docker (optional)
apt remove --purge docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# System-Konfiguration zurücksetzen (optional)
# WARNUNG: Nur auf Test-Systemen!
# ufw disable
# systemctl disable fail2ban
```

## Support

Bei Problemen:
1. Prüfe die Logs in `/var/log/server-setup.log`
2. Prüfe Docker-Container Logs
3. Prüfe Cloudflare Tunnel Status

## Lizenz

Dieses Skript ist frei verfügbar und kann nach Belieben angepasst werden.

## Changelog

### Version 1.0.0 (2025-12-08)
- Initiales Release
- Vollständiges Setup-Skript
- Docker Compose Konfiguration
- Cloudflare Tunnel Integration
- Systemd Services
- Dokumentation
