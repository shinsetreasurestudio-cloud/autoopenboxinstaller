#!/bin/bash

# Script de instalación para Openbox en Debian 13
# Actualizado para Debian 13 (Trixie)

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Función para imprimir mensajes
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Verificar que el script se ejecuta como root
if [ "$EUID" -ne 0 ]; then
    print_error "Este script debe ejecutarse como root. Usa: sudo $0"
    exit 1
fi

# Verificar que estamos en Debian
if ! grep -q "Debian" /etc/os-release; then
    print_error "Este script está diseñado para Debian"
    exit 1
fi

print_status "Iniciando instalación de Openbox y paquetes..."

# Actualizar lista de paquetes
print_status "Actualizando lista de paquetes..."
apt update

# Instalar paquetes esenciales
print_status "Instalando paquetes esenciales..."
apt install -y \
    vim \
    git \
    curl \
    wget \
    btop \
    build-essential \
    python3 \
    python3-pip \
    ark \
    lightdm \
    openbox \
    obconf \
    feh \
    tint2 \
    picom \
    rofi \
    xcompmgr \
    nitrogen \
    thunar \
    lxappearance \
    sakura \
    geany \
    firefox-esr \
    network-manager-gnome \
    volumeicon-alsa \
    blueman \
    lxpolkit \
    scrot \
    viewnior \
    pavucontrol \
    alsa-utils \
    arc-theme \
    papirus-icon-theme \
    fonts-firacode \
    fonts-font-awesome \
    xfce4-terminal \
    xfce4-settings \
    xfce4-notifyd \
    xfce4-screenshooter \
    numix-gtk-theme \
    numix-icon-theme \
    gnome-themes-extra \
    breeze-cursor-theme

# Verificar si la instalación fue exitosa
if [ $? -eq 0 ]; then
    print_success "Todos los paquetes instalados correctamente"
else
    print_error "Hubo problemas instalando algunos paquetes"
    exit 1
fi

# Configuración adicional
print_status "Configurando el sistema..."

# Habilitar lightdm (gestor de inicio de sesión)
print_status "Habilitando lightdm..."
systemctl enable lightdm

# Crear directorios de configuración para el usuario
print_status "Creando directorios de configuración..."
sudo -u $SUDO_USER mkdir -p /home/$SUDO_USER/.config/openbox
sudo -u $SUDO_USER mkdir -p /home/$SUDO_USER/.config/tint2
sudo -u $SUDO_USER mkdir -p /home/$SUDO_USER/.config/picom

# Configuración básica de Openbox
print_status "Creando configuración básica de Openbox..."
cat > /tmp/autostart.sh << 'EOF'
#!/bin/bash
# Autostart script for Openbox

# Establecer fondo de pantalla
nitrogen --restore &

# Panel
tint2 &

# Gestor de ventanas
picom &

# Volume icon
volumeicon &

# Network manager
nm-applet &

# Bluetooth
blueman-applet &

# Policy kit
lxpolkit &

# XFCE notifications
xfce4-notifyd &

EOF

# Mover el archivo de autostart
mv /tmp/autostart.sh /home/$SUDO_USER/.config/openbox/autostart.sh
chown $SUDO_USER:$SUDO_USER /home/$SUDO_USER/.config/openbox/autostart.sh
chmod +x /home/$SUDO_USER/.config/openbox/autostart.sh

# Crear archivo de menú básico
print_status "Creando menú básico de Openbox..."
cat > /home/$SUDO_USER/.config/openbox/menu.xml << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<openbox_menu xmlns="http://openbox.org/3.4/menu">
<menu id="root-menu" label="Openbox 3">
    <item label="Terminal">
        <action name="Execute">
            <command>xfce4-terminal</command>
        </action>
    </item>
    <item label="File Manager">
        <action name="Execute">
            <command>thunar</command>
        </action>
    </item>
    <item label="Web Browser">
        <action name="Execute">
            <command>firefox-esr</command>
        </action>
    </item>
    <separator />
    <menu id="applications-menu" execute="obmenu-generator -p" />
    <separator />
    <item label="ObConf">
        <action name="Execute">
            <command>obconf</command>
        </action>
    </item>
    <item label="Appearance">
        <action name="Execute">
            <command>lxappearance</command>
        </action>
    </item>
    <separator />
    <item label="Reconfigure Openbox">
        <action name="Reconfigure" />
    </item>
    <item label="Exit">
        <action name="Exit" />
    </item>
</menu>
</openbox_menu>
EOF

chown $SUDO_USER:$SUDO_USER /home/$SUDO_USER/.config/openbox/menu.xml

# Configuración básica de tint2
print_status "Creando configuración básica de tint2..."
cat > /home/$SUDO_USER/.config/tint2/tint2rc << 'EOF'
# Basic tint2 configuration
panel_monitor = all
panel_position = bottom center
panel_size = 100% 30
panel_margin = 0 0
panel_padding = 5 0 5
panel_dock = 0
wm_menu = 0
panel_layer = bottom
panel_background_id = 0
rounded_corners = 1

# Taskbar
taskbar_mode = multi_desktop
taskbar_padding = 6 2 6
taskbar_background_id = 1
taskbar_active_background_id = 2

# System tray
systray_padding = 0 4 2
systray_background_id = 0
systray_sort = ascending

# Clock
time1_format = %H:%M
time1_font = sans 10
time2_format = %A %d %B
time2_font = sans 8
clock_font_color = #ffffff 100
clock_padding = 4 0
clock_background_id = 0
clock_rclick = command:gsimplecal

# Battery
battery = 1
battery_low_status = 10
battery_low_cmd = notify-send "Battery low"
battery_hide = 100
battery_font = sans 8
battery_padding = 2 0

# Tooltip
tooltip = 1
tooltip_padding = 4 4
tooltip_show_timeout = 0.5
tooltip_hide_timeout = 0.1
EOF

chown $SUDO_USER:$SUDO_USER /home/$SUDO_USER/.config/tint2/tint2rc

# Mensajes finales
print_success "Instalación completada!"
echo ""
print_warning "Para completar la configuración:"
echo "1. Reinicia el sistema: sudo reboot"
echo "2. En el gestor de inicio de sesión (lightdm), selecciona Openbox"
echo "3. Una vez iniciada la sesión, puedes personalizar:"
echo "   - Temas: lxappearance"
echo "   - Openbox: obconf"
echo "   - Panel: editar ~/.config/tint2/tint2rc"
echo ""
print_status "Para más personalización, consulta la documentación de Openbox"

exit 0
