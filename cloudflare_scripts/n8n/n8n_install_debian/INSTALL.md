# n8n Server Setup - Quick Start

## 📥 Скачивание на сервер

### Вариант 1: Через Git (рекомендуется)
```bash
# Клонировать весь репозиторий
git clone https://github.com/YOUR-USERNAME/YOUR-REPO.git
cd YOUR-REPO/scripts_git/cloudflare_scripts/n8n/n8n_install_debian

# Или только эту папку (sparse checkout)
git clone --depth 1 --filter=blob:none --sparse https://github.com/YOUR-USERNAME/YOUR-REPO.git
cd YOUR-REPO
git sparse-checkout set scripts_git/cloudflare_scripts/n8n/n8n_install_debian
cd scripts_git/cloudflare_scripts/n8n/n8n_install_debian
```

### Вариант 2: Прямое скачивание архива
```bash
# Скачать ZIP архив
wget https://github.com/YOUR-USERNAME/YOUR-REPO/archive/refs/heads/main.zip
unzip main.zip
cd YOUR-REPO-main/scripts_git/cloudflare_scripts/n8n/n8n_install_debian
```

### Вариант 3: Скачать только папку n8n_install_debian
```bash
# Создать папку
mkdir -p n8n_install_debian
cd n8n_install_debian

# Скачать все файлы
wget https://raw.githubusercontent.com/YOUR-USERNAME/YOUR-REPO/main/scripts_git/cloudflare_scripts/n8n/n8n_install_debian/setup.sh
wget https://raw.githubusercontent.com/YOUR-USERNAME/YOUR-REPO/main/scripts_git/cloudflare_scripts/n8n/n8n_install_debian/install-packages.sh
wget https://raw.githubusercontent.com/YOUR-USERNAME/YOUR-REPO/main/scripts_git/cloudflare_scripts/n8n/n8n_install_debian/generate-config.sh
wget https://raw.githubusercontent.com/YOUR-USERNAME/YOUR-REPO/main/scripts_git/cloudflare_scripts/n8n/n8n_install_debian/setup-cloudflare-tunnel.sh
wget https://raw.githubusercontent.com/YOUR-USERNAME/YOUR-REPO/main/scripts_git/cloudflare_scripts/n8n/n8n_install_debian/docker-compose.yml
wget https://raw.githubusercontent.com/YOUR-USERNAME/YOUR-REPO/main/scripts_git/cloudflare_scripts/n8n/n8n_install_debian/.env.example
wget https://raw.githubusercontent.com/YOUR-USERNAME/YOUR-REPO/main/scripts_git/cloudflare_scripts/n8n/n8n_install_debian/README.md
```

### Вариант 4: Через curl (один файл)
```bash
curl -O https://raw.githubusercontent.com/YOUR-USERNAME/YOUR-REPO/main/scripts_git/cloudflare_scripts/n8n/n8n_install_debian/setup.sh
```

### Вариант 5: Создать download.sh скрипт
```bash
# Создать скрипт для автоматического скачивания
cat > download-n8n-setup.sh <<'EOF'
#!/bin/bash
BASE_URL="https://raw.githubusercontent.com/YOUR-USERNAME/YOUR-REPO/main/scripts_git/cloudflare_scripts/n8n/n8n_install_debian"
FILES=(
    "setup.sh"
    "install-packages.sh"
    "generate-config.sh"
    "setup-cloudflare-tunnel.sh"
    "docker-compose.yml"
    ".env.example"
    "README.md"
)

mkdir -p n8n_install_debian
cd n8n_install_debian

for file in "${FILES[@]}"; do
    echo "Downloading $file..."
    wget -q "$BASE_URL/$file"
done

chmod +x *.sh
echo "✅ All files downloaded to $(pwd)"
ls -lh
EOF

chmod +x download-n8n-setup.sh
./download-n8n-setup.sh
```

---

## 🚀 Быстрый старт

После скачивания файлов:

```bash
# Перейти в папку
cd n8n_install_debian

# Сделать скрипты исполняемыми
chmod +x *.sh

# Запустить установку
sudo bash setup.sh
```

---

## 📂 Структура файлов

```
n8n_install_debian/
├── setup.sh                      # Главный скрипт установки
├── install-packages.sh           # Установка пакетов (Docker, Cloudflared)
├── generate-config.sh            # Генерация .env конфигурации
├── setup-cloudflare-tunnel.sh   # Настройка Cloudflare Tunnel
├── docker-compose.yml            # Docker Compose конфигурация
├── .env.example                  # Пример конфигурации
└── README.md                     # Документация
```

---

## ⚡ One-liner установка

```bash
# Скачать и запустить setup.sh одной командой
curl -fsSL https://raw.githubusercontent.com/YOUR-USERNAME/YOUR-REPO/main/scripts_git/cloudflare_scripts/n8n/n8n_install_debian/setup.sh | sudo bash
```

**⚠️ Внимание:** One-liner загружает только главный скрипт. Для полной установки нужны все файлы.

---

## 🔧 Альтернатива: SCP с локальной машины

Если файлы у вас на Windows:

```powershell
# На Windows (PowerShell)
scp -r C:\PROJECT\scripts_git\cloudflare_scripts\n8n\n8n_install_debian root@YOUR-SERVER-IP:/root/
```

Затем на сервере:
```bash
cd /root/n8n_install_debian
chmod +x *.sh
sudo bash setup.sh
```
