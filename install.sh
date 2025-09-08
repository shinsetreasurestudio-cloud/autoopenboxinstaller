#!/bin/bash

# Script de instalación para Debian 13 (Trixie)
# Requiere permisos de superusuario

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Función para verificar errores
check_error() {
    if [ $? -ne 0 ]; then
        echo -e "${RED}Error: $1 falló.${NC}"
        exit 1
    fi
}

# Verificar si es ejecutado como root
if [ "$EUID" -ne 0 ]; then
    echo -e "${RED}Ejecute con sudo o como root${NC}"
    exit 1
fi

# Actualizar lista de paquetes
echo -e "${YELLOW}Actualizando lista de paquetes...${NC}"
apt update
check_error "Actualización de lista de paquetes"

# Actualizar sistema
echo -e "${YELLOW}Actualizando sistema...${NC}"
apt upgrade -y
check_error "Actualización del sistema"

# Instalar programas base 
programas=(
    vim
    git
    curl
    wget
    btop
    build-essential
    python3
    python3-pip
    ark
    lightdm
    openbox
    obconf
    feh
    tint2
    picom
    rofi
    xcompmgr
    nitrogen
    thunar
    lxappearance
    sakura
    ark
    geany
    firefox-esr
    network-manager-gnome
    volumeicon-alsa
    blueman 
)

echo -e "${YELLOW}Instalando paquetes base...${NC}"
apt install -y "${programas[@]}"
check_error "Instalación de paquetes base"

# Instalar software desde repositorios externos 
echo -e "${YELLOW}Agregando repositorio de VS Code...${NC}"
wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
install -D -o root -g root -m 644 packages.microsoft.gpg /etc/apt/keyrings/packages.microsoft.gpg
echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" > /etc/apt/sources.list.d/vscode.list
check_error "Configuración de repositorio VS Code"

echo -e "${YELLOW}Instalando VS Code...${NC}"
apt update
apt install -y code
check_error "Instalación de VS Code"

# Instalar Flatpak 
echo -e "${YELLOW}Configurando Flatpak...${NC}"
apt install -y flatpak
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
check_error "Configuración de Flatpak"

# Instalar aplicaciones Flatpak (Discord)
echo -e "${YELLOW}Instalando Discord via Flatpak...${NC}"
flatpak install -y flathub com.discordapp.Discord
check_error "Instalación de Discord"

# Limpiar paquetes innecesarios
echo -e "${YELLOW}Limpiando sistema...${NC}"
apt autoremove -y
apt clean

echo -e "${GREEN}Instalación completada!${NC}"