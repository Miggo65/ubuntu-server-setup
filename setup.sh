#!/bin/bash

# Ubuntu Server Setup Script
# Installiert: Docker, Code-Server, n8n, Virtual Browser
# Für: 2 vCPU, 4GB RAM Server

set -e  # Bei Fehler abbrechen

echo "========================================="
echo "  Server Setup wird gestartet..."
echo "========================================="
echo ""

# Farben für Output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 1. System Update
echo -e "${BLUE}[1/6] System wird aktualisiert...${NC}"
sudo apt update && sudo apt upgrade -y
sudo apt install -y curl wget git htop nano ufw

# 2. Docker installieren
echo -e "${BLUE}[2/6] Docker wird installiert...${NC}"
if ! command -v docker &> /dev/null; then
    curl -fsSL https://get.docker.com -o get-docker.sh
    sudo sh get-docker.sh
    sudo usermod -aG docker $USER
    rm get-docker.sh
    echo -e "${GREEN}✓ Docker installiert${NC}"
else
    echo -e "${YELLOW}Docker ist bereits installiert${NC}"
fi

# Docker Compose installieren
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# 3. Code-Server installieren (VS Code im Browser)
echo -e "${BLUE}[3/6] Code-Server wird installiert...${NC}"
curl -fsSL https://code-server.dev/install.sh | sh

# Code-Server konfigurieren
mkdir -p ~/.config/code-server
cat > ~/.config/code-server/config.yaml << EOF
bind-addr: 0.0.0.0:8080
auth: password
password: $(openssl rand -base64 12)
cert: false
EOF

# Code-Server als Service starten
sudo systemctl enable --now code-server@$USER
echo -e "${GREEN}✓ Code-Server installiert (Port 8080)${NC}"

# 4. n8n Docker Container
echo -e "${BLUE}[4/6] n8n wird eingerichtet...${NC}"
docker run -d --restart unless-stopped \
  --name n8n \
  -p 5678:5678 \
  -v ~/.n8n:/home/node/.n8n \
  n8nio/n8n

echo -e "${GREEN}✓ n8n läuft (Port 5678)${NC}"

# 5. Virtual Browser (Chromium mit noVNC)
echo -e "${BLUE}[5/6] Virtual Browser wird eingerichtet...${NC}"
docker run -d \
  --name browser \
  -p 6080:3000 \
  -p 6081:3001 \
  --shm-size=2g \
  -e CUSTOM_USER=$USER \
  -e PASSWORD=browser123 \
  lscr.io/linuxserver/chromium:latest

# Browser erstmal stoppen (on-demand nutzen)
sleep 5
docker stop browser
echo -e "${GREEN}✓ Virtual Browser bereit (Port 6080) - gestoppt${NC}"

# 6. Python Umgebung für Discord Bot & Website
echo -e "${BLUE}[6/6] Python Umgebung wird eingerichtet...${NC}"
sudo apt install -y python3 python3-pip python3-venv

# Arbeitsverzeichnisse erstellen
mkdir -p ~/projects/discord-bot
mkdir -p ~/projects/website

echo -e "${GREEN}✓ Python Umgebung bereit${NC}"

# Firewall konfigurieren (optional - nicht strikt da Lernserver)
echo ""
echo -e "${YELLOW}Firewall wird NICHT aktiviert (Lernserver)${NC}"
echo -e "${YELLOW}Alle Ports sind offen - für Produktion nicht empfohlen!${NC}"

# Zusammenfassung
echo ""
echo "========================================="
echo -e "${GREEN}  ✓ Setup abgeschlossen!${NC}"
echo "========================================="
echo ""
echo "📦 Installierte Services:"
echo ""
echo "1. Code-Server (VS Code im Browser)"
echo "   → http://$(curl -s ifconfig.me):8080"
CODESERVER_PASS=$(grep password ~/.config/code-server/config.yaml | awk '{print $2}')
echo "   → Passwort: $CODESERVER_PASS"
echo ""
echo "2. n8n (Workflow Automation)"
echo "   → http://$(curl -s ifconfig.me):5678"
echo ""
echo "3. Virtual Browser (gestoppt)"
echo "   → http://$(curl -s ifconfig.me):6080"
echo "   → Starten: docker start browser"
echo "   → Stoppen: docker stop browser"
echo ""
echo "📁 Projekt-Ordner:"
echo "   ~/projects/discord-bot"
echo "   ~/projects/website"
echo ""
echo "🔧 Nützliche Befehle:"
echo "   docker ps              → Laufende Container"
echo "   docker start browser   → Browser starten"
echo "   docker stop browser    → Browser stoppen"
echo "   htop                   → RAM/CPU Usage"
echo "   sudo systemctl status code-server@$USER  → Code-Server Status"
echo ""
echo "⚠️  WICHTIG:"
echo "   Du musst dich NEU EINLOGGEN damit Docker funktioniert!"
echo "   → exit"
echo "   → ssh nochmal verbinden"
echo ""
echo "========================================="