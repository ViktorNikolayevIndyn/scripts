# Cloudflare Tunnel Setup (`cloudflared-tunnel.sh`)

Create and run a **Cloudflare Tunnel** that maps your **FQDN** (e.g., `webai.1ait.eu`) to a **local HTTP service** (default `http://localhost:8080`), plus install a persistent `systemd` service.

> **Note:** The shell script is provided as a separate file named `cloudflared-tunnel.sh`. This README explains usage and operations only.

---

## Features

- Browser-based `cloudflared login` (only if not authenticated).
- Creates a named tunnel and saves credentials.
- Generates minimal `config.yml` with ingress rules.
- Adds/links DNS CNAME for your FQDN.
- Installs and starts a `systemd` unit `cloudflared-<TUNNEL_NAME>.service`.
- Safety checks for existing tunnels and DNS conflicts.

---

## Prerequisites

- Debian/Ubuntu host with `apt`.
- Root privileges (`sudo`).
- Domain managed by Cloudflare (zone active).
- Ability to open the login URL in a browser (for the first run).

The script auto-installs: `curl`, `jq`, `cloudflared` (if missing), and `uuid-runtime`.

---

## Quick Start

1) Ensure the script file is present and executable:
```bash
chmod +x cloudflared-tunnel.sh
```

2) Run as root:
```bash
sudo ./cloudflared-tunnel.sh
```

3) Answer the prompts:
- **Tunnel name** (default: `webai`)
- **FQDN** (default: `webai.1ait.eu`)
- **Local URL** (default: `http://localhost:8080`)

After success:
- Service available at `https://<FQDN>`.
- Config at `/root/.cloudflared/config.yml`.
- Service name: `cloudflared-<TUNNEL_NAME>.service`.

---

## Placeholders (optional hardcoded defaults)

If you prefer to hardcode defaults as placeholders in the script, replace these variables there:

```bash
# --- Placeholders (edit these) ---
TUNNEL_NAME_DEFAULT="<your_tunnel_name>"
DOMAIN_DEFAULT="<your_fqdn>"
LOCAL_URL_DEFAULT="<your_local_url>"
CONFIG_DIR="<path_to_cloudflared_dir>"
CLOUDFLARED_BIN="<path_to_cloudflared_binary>"
# ---------------------------------
```

Examples:
```bash
TUNNEL_NAME_DEFAULT="<your_tunnel_name>"      # e.g., "webai"
DOMAIN_DEFAULT="<your_fqdn>"                  # e.g., "webai.1ait.eu"
LOCAL_URL_DEFAULT="<your_local_url>"          # e.g., "http://localhost:8080"
CONFIG_DIR="<path_to_cloudflared_dir>"        # e.g., "/root/.cloudflared"
CLOUDFLARED_BIN="<path_to_cloudflared_binary>"# e.g., "/usr/local/bin/cloudflared"
```

---

## Systemd Management

```bash
# Status / logs
systemctl status cloudflared-<TUNNEL_NAME>.service
journalctl -u cloudflared-<TUNNEL_NAME>.service -e

# Restart / Stop
systemctl restart cloudflared-<TUNNEL_NAME>.service
systemctl stop cloudflared-<TUNNEL_NAME>.service

# Disable autostart
systemctl disable cloudflared-<TUNNEL_NAME>.service
```

---

## Config Reference (`/root/.cloudflared/config.yml`)

```yaml
tunnel: <TUNNEL_ID>
credentials-file: /root/.cloudflared/<TUNNEL_ID>.json

ingress:
  - hostname: <FQDN>
    service: http://localhost:8080
  - service: http_status:404
```

### Multiple ingress (optional)
```yaml
ingress:
  - hostname: api.example.com
    service: http://localhost:3000
  - hostname: app.example.com
    service: http://localhost:8080
  - service: http_status:404
```

Path-based (requires an origin/router that supports path routing, e.g., reverse proxy):
```yaml
ingress:
  - hostname: example.com
    path: /api/*
    service: http://localhost:3000
  - hostname: example.com
    service: http://localhost:8080
  - service: http_status:404
```

---

## Troubleshooting

- **Login never completes**  
  Open the URL printed by `cloudflared login` in a browser with access to your Cloudflare account. After authorization, `cert.pem` appears under `/root/.cloudflared/`.

- **DNS “already exists”**  
  A CNAME exists for your FQDN linked to another tunnel. Remove it in **Cloudflare Dashboard → DNS**, then re-run the script.

- **Service fails to start**  
  Check logs:
  ```bash
  journalctl -u cloudflared-<TUNNEL_NAME>.service -e
  ```
  Confirm the local app is up and reachable at the `LOCAL_URL`.

- **Port / firewall issues**  
  Ensure your local service listens on the specified port and localhost is not blocked.

---

## Cleanup / Uninstall

```bash
# Stop and disable service
systemctl disable --now cloudflared-<TUNNEL_NAME>.service
rm -f /etc/systemd/system/cloudflared-<TUNNEL_NAME>.service
systemctl daemon-reload

# Delete tunnel (optional)
cloudflared tunnel delete <TUNNEL_NAME>

# Remove config & credentials (optional and destructive)
rm -rf /root/.cloudflared
```

---

## Security Notes

- Keep `/root/.cloudflared/` permissions strict; it contains credentials.
- Restrict who can run or edit `cloudflared-tunnel.sh`.
- Consider a dedicated service user and `sudoers` rule if needed.
