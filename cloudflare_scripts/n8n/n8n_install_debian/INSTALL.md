# n8n Server Setup - Quick Start

## 📥 Скачивание на сервер

### Вариант 1: Через Git (рекомендуется)
```bash
# Клонировать весь репозиторий
git clone https://github.com/ViktorNikolayevIndyn/scripts.git
cd scripts/public/cloudflare_scripts/n8n/n8n_install_debian

# Или только эту папку (sparse checkout)
git clone --depth 1 --filter=blob:none --sparse https://github.com/ViktorNikolayevIndyn/scripts.git
cd scripts
git sparse-checkout set public/cloudflare_scripts/n8n/n8n_install_debian
cd public/cloudflare_scripts/n8n/n8n_install_debian
```

### Вариант 2: Прямое скачивание архива
```bash
# Скачать ZIP архив
wget https://github.com/ViktorNikolayevIndyn/scripts/archive/refs/heads/main.zip
unzip main.zip
cd scripts-main/public/cloudflare_scripts/n8n/n8n_install_debian
```

### Вариант 3: Скачать только папку n8n_install_debian
```bash
# Создать папку
mkdir -p n8n_install_debian
cd n8n_install_debian

# Скачать все файлы
wget https://raw.githubusercontent.com/ViktorNikolayevIndyn/scripts/main/public/cloudflare_scripts/n8n/n8n_install_debian/setup.sh
wget https://raw.githubusercontent.com/ViktorNikolayevIndyn/scripts/main/public/cloudflare_scripts/n8n/n8n_install_debian/install-packages.sh
wget https://raw.githubusercontent.com/ViktorNikolayevIndyn/scripts/main/public/cloudflare_scripts/n8n/n8n_install_debian/generate-config.sh
wget https://raw.githubusercontent.com/ViktorNikolayevIndyn/scripts/main/public/cloudflare_scripts/n8n/n8n_install_debian/setup-cloudflare-tunnel.sh
wget https://raw.githubusercontent.com/ViktorNikolayevIndyn/scripts/main/public/cloudflare_scripts/n8n/n8n_install_debian/docker-compose.yml
wget https://raw.githubusercontent.com/ViktorNikolayevIndyn/scripts/main/public/cloudflare_scripts/n8n/n8n_install_debian/.env.example
wget https://raw.githubusercontent.com/ViktorNikolayevIndyn/scripts/main/public/cloudflare_scripts/n8n/n8n_install_debian/README.md
```

### Вариант 4: Через curl (один файл)
```bash
curl -O https://raw.githubusercontent.com/ViktorNikolayevIndyn/scripts/main/public/cloudflare_scripts/n8n/n8n_install_debian/setup.sh
```

### Вариант 5: Через download.sh (автоматический) ⭐
```bash
# Скачать download.sh скрипт
wget https://raw.githubusercontent.com/ViktorNikolayevIndyn/scripts/main/public/cloudflare_scripts/n8n/n8n_install_debian/download.sh

# Запустить
chmod +x download.sh
./download.sh

# Перейти в созданную папку
cd n8n_install_debian
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

## ⚡ One-liner установка (самый простой способ) 🚀

```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/ViktorNikolayevIndyn/scripts/main/public/cloudflare_scripts/n8n/install.sh)"
```

### Альтернатива: Через download.sh

```bash
# Скачать все файлы и запустить установку
wget -qO- https://raw.githubusercontent.com/ViktorNikolayevIndyn/scripts/main/public/cloudflare_scripts/n8n/n8n_install_debian/download.sh | bash && cd n8n_install_debian && sudo bash setup.sh
```

Или по шагам:
```bash
# 1. Скачать все файлы
wget https://raw.githubusercontent.com/ViktorNikolayevIndyn/scripts/main/public/cloudflare_scripts/n8n/n8n_install_debian/download.sh
bash download.sh

# 2. Запустить установку
cd n8n_install_debian
sudo bash setup.sh
```

---

## 🔧 Альтернатива: SCP с локальной машины

Если файлы у вас на Windows:

```powershell
# На Windows (PowerShell)
scp -r C:\PROJECT\public\cloudflare_scripts\n8n\n8n_install_debian root@YOUR-SERVER-IP:/root/
```

Затем на сервере:
```bash
cd /root/n8n_install_debian
chmod +x *.sh
sudo bash setup.sh
```
