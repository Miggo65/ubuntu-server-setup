# Ubuntu Server Setup

Automatisches Setup-Script für Ubuntu 24.04 LTS Server (2 vCPU, 4GB RAM).

## Was wird installiert?

- 🐳 **Docker & Docker Compose**
- 💻 **Code-Server** (VS Code im Browser) - Port 8080
- 🔄 **n8n** (Workflow Automation) - Port 5678
- 🌐 **Virtual Browser** (Chromium mit noVNC) - Port 6080
- 🐍 **Python 3** Umgebung
- 📁 Projekt-Ordner für Discord Bot & Website

## Installation

Kopiere diesen Befehl und führe ihn auf deinem frischen Ubuntu Server aus:

```bash
curl -fsSL https://raw.githubusercontent.com/Miggo65/ubuntu-server-setup/main/setup.sh | bash
```

## Nach der Installation

**WICHTIG:** Logge dich neu ein damit Docker funktioniert:
```bash
exit
# Dann erneut per SSH verbinden
```

## Zugriff auf Services

Nach dem Setup zeigt das Script alle URLs und Passwörter an:

- **Code-Server:** `http://deine-server-ip:8080`
- **n8n:** `http://deine-server-ip:5678`
- **Virtual Browser:** `http://deine-server-ip:6080` (muss erst gestartet werden)

## Nützliche Befehle

```bash
# Virtual Browser starten
docker start browser

# Virtual Browser stoppen (RAM sparen)
docker stop browser

# Alle laufenden Container anzeigen
docker ps

# RAM/CPU Usage anzeigen
htop

# Code-Server Status
sudo systemctl status code-server@$USER
```

## Projekt-Ordner

- `~/projects/discord-bot` - Für deinen Discord Bot
- `~/projects/website` - Für deine Website

## Hinweis

Dieses Setup ist für **Lernzwecke** optimiert. Firewall ist deaktiviert und alle Ports sind offen. Für Produktions-Server sollte die Sicherheit erhöht werden!

## Performance

Der Virtual Browser ist standardmäßig gestoppt um RAM zu sparen. Starte ihn nur wenn du ihn brauchst:

- **Ohne Browser:** ~1.7 GB RAM verwendet
- **Mit Browser:** ~2.4 GB RAM verwendet