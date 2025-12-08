# 🚀 n8n Automated Setup with Cloudflare Tunnel

**One-command installation** of a secure n8n workflow automation server on Debian 12/13 with Cloudflare Tunnel integration.

## ✨ Features

- ⚡ **Fully Automated** - Single command installation
- 🔒 **Security Hardened** - UFW firewall, Fail2Ban, SSH hardening
- 🐳 **Docker-based** - n8n + PostgreSQL in containers
- 🌐 **Cloudflare Tunnel** - Secure access without port forwarding
- 🔐 **Basic Auth** - Built-in authentication
- 📦 **Production Ready** - Auto-start on boot, persistent data
- 🛠️ **Modular** - Separate scripts for packages, config, tunnel

## 📋 Requirements

- Fresh Debian 12 or 13 server
- Root access (sudo)
- Cloudflare account (for tunnel setup)
- Domain/subdomain (e.g., `n8n.example.com`)

## 🚀 Quick Start

### One-Line Installation

```bash
bash -c "$(curl -fsSL 'https://raw.githubusercontent.com/ViktorNikolayevIndyn/scripts/main/n8n/install.sh?t='$(date +%s))"
```

> **Note:** The `?t=$(date +%s)` parameter bypasses GitHub's cache to ensure you get the latest version.

**That's it!** The script will:
1. ✅ Install all dependencies (Docker, Cloudflared, etc.)
2. ✅ Harden server security (UFW, Fail2Ban, SSH)
3. ✅ Set up n8n with PostgreSQL
4. ✅ Generate secure configuration
5. ✅ Start n8n in Docker

After installation, you'll be prompted to configure Cloudflare Tunnel.

---

## 📚 Alternative Installation Methods

See [INSTALL.md](./INSTALL.md) for:
- Git clone method
- Manual file download
- SCP from Windows
- Offline installation

---

## 🔧 What Gets Installed?

### 1. System Packages
- `curl`, `wget`, `git`, `nano`, `htop`, `jq`
- `ufw` - Firewall (ports: 22, 80, 443)
- `fail2ban` - Brute-force protection

### 2. Docker Stack
- Docker Engine (latest)
- Docker Compose Plugin
- n8n container (latest)
- PostgreSQL 15 container

### 3. Cloudflare Tools
- `cloudflared` - Tunnel client

---

## ⚙️ Configuration

### Interactive Setup

During installation, you'll be asked:

1. **n8n Domain** - Your subdomain (e.g., `n8n.example.com`)
2. **Basic Auth Username** - Default: `admin`
3. **Basic Auth Password** - Auto-generated or custom
4. **PostgreSQL Password** - Auto-generated or custom
5. **Timezone** - Default: `Europe/Berlin`

All settings are saved to `/opt/n8n/.env`

### Manual Configuration

Edit configuration file:
```bash
nano /opt/n8n/.env
```

Restart n8n:
```bash
cd /opt/n8n
docker compose restart
```

---

## 🌐 Cloudflare Tunnel Setup

After main installation, configure Cloudflare Tunnel:

```bash
bash <(curl -fsSL 'https://raw.githubusercontent.com/ViktorNikolayevIndyn/scripts/main/n8n/n8n_install_debian/setup-cloudflare-tunnel.sh?t='$(date +%s))
```

Or if already downloaded:
```bash
cd /opt/n8n
bash setup-cloudflare-tunnel.sh
```

The script will:
1. Use saved Cloudflare API Token (or prompt for new one)
2. Create or reuse existing tunnel
3. Configure DNS record via API
4. Set up systemd service

**Alternative**: Manual tunnel setup via [Cloudflare Dashboard](https://one.dash.cloudflare.com/)

---

## 📊 Management

### Check n8n Status
```bash
docker ps
docker logs n8n -f
```

### Start/Stop n8n
```bash
cd /opt/n8n
docker compose up -d      # Start
docker compose down       # Stop
docker compose restart    # Restart
```

### Check Cloudflare Tunnel
```bash
systemctl status cloudflared-n8n-tunnel
journalctl -u cloudflared-n8n-tunnel -f
```

### View Setup Logs
```bash
tail -f /var/log/server-setup.log
```

---

## 🗂️ File Structure

```
/opt/n8n/
├── .env                    # Configuration
├── docker-compose.yml      # Docker setup
├── setup-cloudflare-tunnel.sh  # Tunnel setup script
└── volumes/
    ├── n8n-data/          # n8n workflows
    └── postgres-data/     # Database

/var/log/
└── server-setup.log       # Installation log

/etc/systemd/system/
└── cloudflared-*.service  # Tunnel service
```

---

## 🔄 Updates

### Update n8n
```bash
cd /opt/n8n
docker compose pull
docker compose up -d
```

### Update Cloudflared
```bash
curl -L --output /usr/local/bin/cloudflared \
    https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64
chmod +x /usr/local/bin/cloudflared
systemctl restart cloudflared-n8n-tunnel
```

### Update System
```bash
apt update && apt upgrade -y
```

---

## 💾 Backup & Restore

### Backup Database
```bash
cd /opt/n8n
docker compose exec postgres pg_dump -U n8n n8n > backup_$(date +%Y%m%d_%H%M%S).sql
```

### Restore Database
```bash
cd /opt/n8n
cat backup_YYYYMMDD_HHMMSS.sql | docker compose exec -T postgres psql -U n8n -d n8n
```

### Backup n8n Data
```bash
tar -czf n8n_backup_$(date +%Y%m%d).tar.gz /opt/n8n
```

---

## 🐛 Troubleshooting

### n8n Not Starting
```bash
# Check logs
docker logs n8n -f

# Check configuration
cat /opt/n8n/.env

# Restart containers
cd /opt/n8n && docker compose restart
```

### Cloudflare Tunnel Issues
```bash
# Check tunnel status
systemctl status cloudflared-n8n-tunnel

# Check tunnel logs
journalctl -u cloudflared-n8n-tunnel -f

# Restart tunnel
systemctl restart cloudflared-n8n-tunnel
```

### Can't Access n8n
1. Check Docker containers: `docker ps`
2. Check Cloudflare Tunnel status
3. Verify DNS record in Cloudflare Dashboard
4. Check firewall: `ufw status`
5. Test local access: `curl http://localhost:80`

### Locked Out via SSH
- Use your hosting provider's console/VNC
- Check if SSH key is properly configured
- Verify `/etc/ssh/sshd_config` settings
- Check fail2ban: `fail2ban-client status sshd`

---

## 🔒 Security Best Practices

1. **Regular Backups** - Automate database backups
2. **Keep Updated** - Update system and containers regularly
3. **Strong Passwords** - Use generated passwords (25+ chars)
4. **Monitor Logs** - Check `/var/log/server-setup.log` regularly
5. **Firewall Rules** - Only allow necessary ports
6. **Fail2Ban** - Monitor brute-force attempts
7. **SSH Keys Only** - Never enable password authentication

---

## 📖 Additional Resources

- [n8n Documentation](https://docs.n8n.io/)
- [n8n Environment Variables](https://docs.n8n.io/hosting/configuration/environment-variables/)
- [Cloudflare Tunnel Docs](https://developers.cloudflare.com/cloudflare-one/connections/connect-apps/)
- [Docker Compose Reference](https://docs.docker.com/compose/)

---

## 🤝 Support

For issues or questions:
- Check [INSTALL.md](./INSTALL.md) for detailed installation steps
- Review logs: `/var/log/server-setup.log`
- Check Docker logs: `docker compose logs`

---

## 📝 License

MIT License - Use freely for personal or commercial projects.

---

**Made with ❤️ for automated n8n deployments**

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
