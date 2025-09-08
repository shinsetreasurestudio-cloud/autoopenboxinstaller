#!/bin/bash

# Script de instalación y autoconfiguración para Debian 13 (Trixie)
# Requiere permisos de superusuario

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Función para verificar errores
check_error() {
    if [ $? -ne 0 ]; then
        echo -e "${RED}Error: $1 falló.${NC}"
        exit 1
    fi
}

# Función para imprimir mensajes de estado
print_status() {
    echo -e "${BLUE}[*]${NC} $1"
}

# Función para imprimir mensajes de éxito
print_success() {
    echo -e "${GREEN}[+]${NC} $1"
}

# Función para imprimir mensajes de advertencia
print_warning() {
    echo -e "${YELLOW}[!]${NC} $1"
}

# Verificar si es ejecutado como root
if [ "$EUID" -ne 0 ]; then
    echo -e "${RED}Ejecute con sudo o como root${NC}"
    exit 1
fi

# Obtener nombre de usuario actual
if [ -z "$SUDO_USER" ]; then
    CURRENT_USER=$(whoami)
else
    CURRENT_USER=$SUDO_USER
fi

HOME_DIR="/home/$CURRENT_USER"
if [ "$CURRENT_USER" = "root" ]; then
    HOME_DIR="/root"
fi

print_status "Iniciando instalación y configuración para usuario: $CURRENT_USER"

# Actualizar lista de paquetes
print_status "Actualizando lista de paquetes..."
apt update
check_error "Actualización de lista de paquetes"

# Actualizar sistema
print_status "Actualizando sistema..."
apt upgrade -y
check_error "Actualización del sistema"

# Agregar repositorio para temas Materia
print_status "Agregando repositorio para temas Materia..."
echo 'deb http://deb.debian.org/debian bookworm main' > /etc/apt/sources.list.d/bookworm.list
apt update

# Instalar programas base 
print_status "Instalando paquetes base..."
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
    geany
    firefox-esr
    network-manager-gnome
    volumeicon-alsa
    blueman
    lxpolkit
    scrot
    viewnior
    pavucontrol
    alsa-utils
    arc-theme
    papirus-icon-theme
    fonts-firacode
    fonts-font-awesome
    xfce4-terminal
    xfce4-power-manager
    xfce4-settings
    xfce4-notifyd
    xfce4-screenshooter
    numix-gtk-theme
    numix-icon-theme
    gnome-themes-extra  # Nombre corregido del paquete
    breeze-cursor-theme
)

apt install -y "${programas[@]}"
check_error "Instalación de paquetes base"

# Instalar software desde repositorios externos 
print_status "Agregando repositorio de VS Code..."
wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
install -D -o root -g root -m 644 packages.microsoft.gpg /etc/apt/keyrings/packages.microsoft.gpg
echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" > /etc/apt/sources.list.d/vscode.list
check_error "Configuración de repositorio VS Code"

print_status "Instalando VS Code..."
apt update
apt install -y code
check_error "Instalación de VS Code"

# Instalar Flatpak 
print_status "Configurando Flatpak..."
apt install -y flatpak
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
check_error "Configuración de Flatpak"

# Instalar aplicaciones Flatpak (Discord)
print_status "Instalando Discord via Flatpak..."
flatpak install -y flathub com.discordapp.Discord
check_error "Instalación de Discord"

# Crear directorios de configuración
print_status "Creando directorios de configuración..."
sudo -u $CURRENT_USER mkdir -p $HOME_DIR/.config/openbox
sudo -u $CURRENT_USER mkdir -p $HOME_DIR/.config/tint2
sudo -u $CURRENT_USER mkdir -p $HOME_DIR/.config/picom
sudo -u $CURRENT_USER mkdir -p $HOME_DIR/.config/rofi
sudo -u $CURRENT_USER mkdir -p $HOME_DIR/.config/geany
sudo -u $CURRENT_USER mkdir -p $HOME_DIR/.config/Thunar
sudo -u $CURRENT_USER mkdir -p $HOME_DIR/.themes
sudo -u $CURRENT_USER mkdir -p $HOME_DIR/.icons
sudo -u $CURRENT_USER mkdir -p $HOME_DIR/Imágenes/Screenshots
sudo -u $CURRENT_USER mkdir -p $HOME_DIR/.local/share/applications

# Configurar OpenBox
print_status "Configurando OpenBox..."

# Crear archivo autostart
sudo -u $CURRENT_USER cat > $HOME_DIR/.config/openbox/autostart << EOF
#!/bin/bash

# Establecer fondo de pantalla
nitrogen --restore &

# Iniciar compositor para efectos visuales
picom --config \$HOME/.config/picom/picom.conf &

# Iniciar panel
tint2 -c \$HOME/.config/tint2/tint2rc &

# Iniciar gestor de volumen
volumeicon &

# Iniciar gestor de Bluetooth
blueman-applet &

# Iniciar gestor de red
nm-applet &

# Iniciar gestor de energía
xfce4-power-manager &

# Iniciar politkit para privilegios
lxpolkit &

# Establecer tema GTK
lxappearance &

# Establecer teclado en español
setxkbmap es

# Establecer cursor
xsetroot -cursor_name left_ptr

EOF

# Configurar menu.xml de OpenBox
sudo -u $CURRENT_USER cat > $HOME_DIR/.config/openbox/menu.xml << EOF
<?xml version="1.0" encoding="UTF-8"?>

<openbox_menu xmlns="http://openbox.org/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://openbox.org/ file:///usr/share/openbox/menu.xsd">

<menu id="root-menu" label="OpenBox 3">
  <item label="Terminal">
    <action name="Execute">
      <command>xfce4-terminal</command>
    </action>
  </item>
  <item label="Navegador Web">
    <action name="Execute">
      <command>firefox-esr</command>
    </action>
  </item>
  <item label="Explorador de Archivos">
    <action name="Execute">
      <command>thunar</command>
    </action>
  </item>
  <separator />
  <menu id="applications-menu" />
  <separator />
  <item label="Recargar OpenBox">
    <action name="Reconfigure" />
  </item>
  <item label="Salir">
    <action name="Exit" />
  </item>
</menu>

</openbox_menu>
EOF

# Configurar rc.xml de OpenBox (configuración principal)
sudo -u $CURRENT_USER cat > $HOME_DIR/.config/openbox/rc.xml << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>

<openbox_config xmlns="http://openbox.org/3.4/rc"
                xmlns:xi="http://www.w3.org/2001/XInclude">

<resistance>
  <strength>10</strength>
  <screen_edge_strength>20</screen_edge_strength>
</resistance>

<focus>
  <focusNew>yes</focusNew>
  <followMouse>no</followMouse>
  <focusLast>yes</focusLast>
  <underMouse>no</underMouse>
  <focusDelay>200</focusDelay>
  <raiseOnFocus>no</raiseOnFocus>
</focus>

<placement>
  <policy>Smart</policy>
  <center>yes</center>
  <monitor>Mouse</monitor>
  <primaryMonitor>First</primaryMonitor>
</placement>

<theme>
  <name>Arc-Dark</name>
  <titleLayout>NLIMC</titleLayout>
  <keepBorder>yes</keepBorder>
  <animateIconify>yes</animateIconify>
  <font place="ActiveWindow">
    <name>sans</name>
    <size>9</size>
    <weight>bold</weight>
    <slant>normal</slant>
  </font>
  <font place="InactiveWindow">
    <name>sans</name>
    <size>9</size>
    <weight>normal</weight>
    <slant>normal</slant>
  </font>
  <font place="MenuHeader">
    <name>sans</name>
    <size>9</size>
    <weight>normal</weight>
    <slant>normal</slant>
  </font>
  <font place="MenuItem">
    <name>sans</name>
    <size>9</size>
    <weight>normal</weight>
    <slant>normal</slant>
  </font>
  <font place="ActiveOnScreenDisplay">
    <name>sans</name>
    <size>9</size>
    <weight>bold</weight>
    <slant>normal</slant>
  </font>
  <font place="InactiveOnScreenDisplay">
    <name>sans</name>
    <size>9</size>
    <weight>normal</weight>
    <slant>normal</slant>
  </font>
</theme>

<desktops>
  <number>4</number>
  <firstdesk>1</firstdesk>
  <names>
    <name>Desktop 1</name>
    <name>Desktop 2</name>
    <name>Desktop 3</name>
    <name>Desktop 4</name>
  </names>
  <popupTime>875</popupTime>
</desktops>

<resize>
  <drawContents>yes</drawContents>
  <popupShow>Nonpixel</popupShow>
  <popupPosition>Center</popupPosition>
  <popupFixedPosition>
    <x>10</x>
    <y>10</y>
  </popupFixedPosition>
</resize>

<margins>
  <top>0</top>
  <bottom>0</bottom>
  <left>0</left>
  <right>0</right>
</margins>

<dock>
  <position>Top</position>
  <floatingX>0</floatingX>
  <floatingY>0</floatingY>
  <noStrut>no</noStrut>
  <stacking>Above</stacking>
  <direction>Vertical</direction>
  <autoHide>no</autoHide>
  <hideDelay>300</hideDelay>
  <showDelay>300</showDelay>
  <moveButton>Middle</moveButton>
</dock>

<keyboard>
  <keybind key="C-A-Left">
    <action name="GoToDesktop"><to>left</to></action>
  </keybind>
  <keybind key="C-A-Right">
    <action name="GoToDesktop"><to>right</to></action>
  </keybind>
  <keybind key="W-d">
    <action name="ToggleShowDesktop"/>
  </keybind>
  <keybind key="A-F4">
    <action name="Close"/>
  </keybind>
  <keybind key="A-Escape">
    <action name="Lower"/>
    <action name="FocusToBottom"/>
    <action name="Unfocus"/>
  </keybind>
  <keybind key="A-Tab">
    <action name="NextWindow"/>
  </keybind>
  <keybind key="A-S-Tab">
    <action name="PreviousWindow"/>
  </keybind>
  <keybind key="W-t">
    <action name="Execute">
      <command>xfce4-terminal</command>
    </action>
  </keybind>
  <keybind key="W-e">
    <action name="Execute">
      <command>thunar</command>
    </action>
  </keybind>
  <keybind key="W-f">
    <action name="Execute">
      <command>firefox-esr</command>
    </action>
  </keybind>
  <keybind key="W-r">
    <action name="Execute">
      <command>rofi -show run</command>
    </action>
  </keybind>
  <keybind key="Print">
    <action name="Execute">
      <command>scrot '%Y-%m-%d_$wx$h.png' -e 'mv $f ~/Imágenes/Screenshots/'</command>
    </action>
  </keybind>
</keyboard>

<mouse>
  <dragThreshold>1</dragThreshold>
  <doubleClickTime>500</doubleClickTime>
  <screenEdgeWarpTime>400</screenEdgeWarpTime>
  <screenEdgeWarpMouse>false</screenEdgeWarpMouse>
</mouse>

<menu>
  <file>menu.xml</file>
  <hideDelay>200</hideDelay>
  <middle>no</middle>
  <submenuShowDelay>100</submenuShowDelay>
  <submenuHideDelay>100</submenuHideDelay>
  <applicationIcons>yes</applicationIcons>
  <manageDesktops>yes</manageDesktops>
</menu>

<applications>
  <application class="*">
    <decor>yes</decor>
    <focus>yes</focus>
    <position>
      <x>center</x>
      <y>center</y>
    </position>
    <layer>normal</layer>
    <desktop>all</desktop>
    <maximized>false</maximized>
  </application>
</applications>

</openbox_config>
EOF

# Configurar Tint2 (panel)
print_status "Configurando Tint2..."
sudo -u $CURRENT_USER cat > $HOME_DIR/.config/tint2/tint2rc << 'EOF'
#---------------------------------------------
# TINT2 CONFIG FILE
#---------------------------------------------
# For more information about tint2, see:
# http://code.google.com/p/tint2/

# Background definitions
# ID 1
rounded = 0
border_width = 0
background_color = #000000 60
border_color = #000000 0

# ID 2 - task active
rounded = 2
border_width = 1
background_color = #777777 20
border_color = #ffffff 30

# ID 3 - task
rounded = 2
border_width = 1
background_color = #000000 0
border_color = #ffffff 0

# ID 4
rounded = 0
border_width = 0
background_color = #000000 40
border_color = #000000 0

# Panel
panel_monitor = all
panel_position = bottom center horizontal
panel_size = 100% 30
panel_margin = 0 0
panel_padding = 0 0
panel_dock = 0
wm_menu = 1
panel_layer = bottom
panel_background_id = 1

# Panel Autohide
autohide = 0
autohide_show_timeout = 0.3
autohide_hide_timeout = 1.5
autohide_height = 4
strut_policy = follow_size

# Taskbar
taskbar_mode = multi_desktop
taskbar_padding = 6 0 6
taskbar_background_id = 0
taskbar_active_background_id = 2
taskbar_name = 1
taskbar_name_background_id = 0
taskbar_name_active_background_id = 0
taskbar_name_font_color = #ffffff 100
taskbar_name_active_font_color = #ffffff 100

# Tasks
task_text = 1
task_icon = 1
task_centered = 1
task_maximum_size = 150 30
task_padding = 8 4
task_background_id = 3
task_active_background_id = 2
task_urgent_background_id = 0
task_iconified_background_id = 3

# Task Icons
task_icon_asb = 100 0 0
task_active_icon_asb = 100 0 0
task_urgent_icon_asb = 100 0 0
task_iconified_icon_asb = 100 0 0

# Fonts
task_font = sans 9
task_font_color = #dddddd 100
task_active_font_color = #ffffff 100
task_urgent_font_color = #ffffff 100
task_iconified_font_color = #777777 100

# System tray (notification area)
systray = 1
systray_padding = 4 0 6
systray_background_id = 0
systray_sort = right2left
systray_icon_size = 22
systray_icon_asb = 100 0 0

# Clock
time1_format = %H:%M
time2_format = %d %b %Y
time1_font = sans 10
time2_font = sans 8
clock_font_color = #ffffff 100
clock_padding = 4 0
clock_background_id = 0
clock_rclick = command:gsimplecal

# Tooltip
tooltip = 1
tooltip_padding = 4 4
tooltip_show_timeout = 0.0
tooltip_hide_timeout = 0.0
tooltip_background_id = 4
tooltip_font_color = #dddddd 100
tooltip_font = sans 9

# Mouse
mouse_middle = none
mouse_right = close
mouse_scroll_up = toggle
mouse_scroll_down = iconify

# Battery
battery = 0
battery_low_status = 10
battery_low_cmd = notify-send "Battery low!"
battery_hide = 100
battery_font_color = #ffffff 100
battery_padding = 2 0
battery_background_id = 0

# Button
button = 
button_text = 
button_font = sans 10
button_font_color = #ffffff 100
button_padding = 4 4
button_background_id = 4

# Separator
separator = 
separator_background_id = 0

# Launcher
launcher_item_app = /usr/share/applications/firefox-esr.desktop
launcher_item_app = /usr/share/applications/thunar.desktop
launcher_item_app = /usr/share/applications/xfce4-terminal.desktop
launcher_icon_theme = Papirus
launcher_icon_size = 22
launcher_padding = 4 4 4
launcher_background_id = 0
launcher_rtl = 0

# Executor
executor = 
executor_interval = 5
executor_font = sans 10
executor_font_color = #ffffff 100
executor_padding = 2 0
executor_background_id = 0

EOF

# Configurar Picom (compositor)
print_status "Configurando Picom..."
sudo -u $CURRENT_USER cat > $HOME_DIR/.config/picom/picom.conf << 'EOF'
# Shadow
shadow = true;
no-dnd-shadow = true;
no-dock-shadow = true;
clear-shadow = true;
shadow-radius = 10;
shadow-offset-x = -15;
shadow-offset-y = -15;
shadow-opacity = 0.3;
shadow-ignore-shaped = false;
shadow-exclude = [
    "name = 'Notification'",
    "class_g = 'Conky'",
    "class_g ?= 'Notify-osd'",
    "class_g = 'Cairo-clock'",
    "_GTK_FRAME_EXTENTS@:c"
];

# Opacity
inactive-opacity = 1.0;
frame-opacity = 1.0;
inactive-opacity-override = false;
active-opacity = 1.0;
inactive-dim = 0.0;
blur-background = false;
blur-background-frame = false;
blur-background-fixed = false;
blur-kern = "3x3box";
blur-background-exclude = [
    "window_type = 'dock'",
    "window_type = 'desktop'",
    "_GTK_FRAME_EXTENTS@:c"
];

# Fading
fading = true;
fade-delta = 5;
fade-in-step = 0.03;
fade-out-step = 0.03;
no-fading-openclose = false;
no-fading-destroyed-argb = false;
fade-exclude = [ ];

# Other
backend = "glx";
mark-wmwin-focused = true;
mark-ovredir-focused = true;
detect-rounded-corners = true;
detect-client-opacity = true;
refresh-rate = 0;
vsync = "none";
dbe = false;
unredir-if-possible = false;
focus-exclude = [ ];
detect-transient = true;
detect-client-leader = true;

# Window type settings
wintypes:
{
    tooltip = { fade = true; shadow = true; opacity = 0.75; focus = true; full-shadow = false; };
    dock = { shadow = false; clip-shadow-above = true; }
    dnd = { shadow = false; }
    popup_menu = { opacity = 0.8; }
    dropdown_menu = { opacity = 0.8; }
};
EOF

# Configurar Rofi (lanzador de aplicaciones)
print_status "Configurando Rofi..."
sudo -u $CURRENT_USER mkdir -p $HOME_DIR/.local/share/rofi/themes
sudo -u $CURRENT_USER cat > $HOME_DIR/.config/rofi/config.rasi << 'EOF'
@theme "Arc-Dark"

configuration {
  modi: "run,drun,window";
  icon-theme: "Papirus";
  show-icons: true;
  terminal: "xfce4-terminal";
  drun-display-format: "{name}";
  window-format: "{w} · {c} · {t}";
}

EOF

# Configurar fondo de pantalla
print_status "Configurando fondo de pantalla..."
sudo -u $CURRENT_USER wget -O $HOME_DIR/Imágenes/wallpaper.jpg "https://picsum.photos/1920/1080" > /dev/null 2>&1
sudo -u $CURRENT_USER cat > $HOME_DIR/.config/nitrogen/bg-saved.cfg << EOF
[xin_-1]
file=$HOME_DIR/Imágenes/wallpaper.jpg
mode=5
bgcolor=#000000
EOF

# Configurar temas GTK e iconos
print_status "Configurando temas GTK e iconos..."
sudo -u $CURRENT_USER cat > $HOME_DIR/.gtkrc-2.0 << 'EOF'
gtk-theme-name="Arc-Dark"
gtk-icon-theme-name="Papirus"
gtk-font-name="Sans 10"
gtk-cursor-theme-name="breeze_cursors"
gtk-cursor-theme-size=0
gtk-toolbar-style=GTK_TOOLBAR_ICONS
gtk-toolbar-icon-size=GTK_ICON_SIZE_LARGE_TOOLBAR
gtk-button-images=1
gtk-menu-images=1
gtk-enable-event-sounds=1
gtk-enable-input-feedback-sounds=1
gtk-xft-antialias=1
gtk-xft-hinting=1
gtk-xft-hintstyle="hintfull"
EOF

sudo -u $CURRENT_USER cat > $HOME_DIR/.config/gtk-3.0/settings.ini << 'EOF'
[Settings]
gtk-theme-name=Arc-Dark
gtk-icon-theme-name=Papirus
gtk-font-name=Sans 10
gtk-cursor-theme-name=breeze_cursors
gtk-cursor-theme-size=0
gtk-toolbar-style=GTK_TOOLBAR_ICONS
gtk-toolbar-icon-size=GTK_ICON_SIZE_LARGE_TOOLBAR
gtk-button-images=1
gtk-menu-images=1
gtk-enable-event-sounds=1
gtk-enable-input-feedback-sounds=1
gtk-xft-antialias=1
gtk-xft-hinting=1
gtk-xft-hintstyle=hintfull
EOF

# Configurar terminal
print_status "Configurando terminal..."
sudo -u $CURRENT_USER mkdir -p $HOME_DIR/.config/xfce4/terminal
sudo -u $CURRENT_USER cat > $HOME_DIR/.config/xfce4/terminal/terminalrc << 'EOF'
[Configuration]
MiscAlwaysShowTabs=FALSE
MiscBell=FALSE
MiscBellUrgent=FALSE
MiscBordersDefault=TRUE
MiscCursorBlinks=FALSE
MiscCursorShape=TERMINAL_CURSOR_SHAPE_BLOCK
MiscDefaultGeometry=80x24
MiscInheritGeometry=FALSE
MiscMenubarDefault=TRUE
MiscMouseAutohide=FALSE
MiscMouseWheelZoom=TRUE
MiscToolbarDefault=TRUE
MiscConfirmClose=TRUE
MiscCycleTabs=TRUE
MiscTabCloseButtons=TRUE
MiscTabCloseMiddleClick=TRUE
MiscTabPosition=GTK_POS_TOP
MiscHighlightUrls=TRUE
MiscMiddleClickOpensUri=FALSE
MiscCopyOnSelect=FALSE
MiscShowRelaunchDialog=TRUE
MiscRewrapOnResize=TRUE
MiscUseShiftArrowsToScroll=FALSE
MiscSlimTabs=FALSE
MiscNewTabAdjacent=FALSE
ColorBackground=#242424242424
ColorForeground=#FFFFFFFFFFFF
ColorCursor=#FFFFFFFFFFFF
ColorPalette=rgb(0,0,0);rgb(170,0,0);rgb(0,170,0);rgb(170,85,0);rgb(0,0,170);rgb(170,0,170);rgb(0,170,170);rgb(170,170,170);rgb(85,85,85);rgb(255,85,85);rgb(85,255,85);rgb(255,255,85);rgb(85,85,255);rgb(255,85,255);rgb(85,255,255);rgb(255,255,255)
FontName=FiraCode Nerd Font Mono 10
ScrollingUnlimited=TRUE
ScrollingBar=TERMINAL_SCROLLBAR_NONE
EOF

# Configurar Thunar (gestor de archivos)
print_status "Configurando Thunar..."
sudo -u $CURRENT_USER cat > $HOME_DIR/.config/Thunar/uca.xml << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<actions>
<action>
	<icon>utilities-terminal</icon>
	<name>Abrir en terminal</name>
	<unique-id>1607014584974958-1</unique-id>
	<command>xfce4-terminal --working-directory=%f</command>
	<description>Abrir la carpeta actual en terminal</description>
	<patterns>*</patterns>
	<directories/>
</action>
</actions>
EOF

# Configurar atajos de teclado
print_status "Configurando atajos de teclado globales..."
sudo -u $CURRENT_USER mkdir -p $HOME_DIR/.config/xfce4/xfconf/xfce-perchannel-xml
sudo -u $CURRENT_USER cat > $HOME_DIR/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-keyboard-shortcuts.xml << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>

<channel name="xfce4-keyboard-shortcuts" version="1.0">
  <property name="commands" type="empty">
    <property name="default" type="empty">
      <property name="&lt;Alt&gt;F1" type="string" value="rofi -show drun"/>
      <property name="&lt;Alt&gt;F2" type="string" value="xfce4-terminal"/>
      <property name="&lt;Primary&gt;&lt;Alt&gt;t" type="string" value="xfce4-terminal"/>
      <property name="&lt;Primary&gt;&lt;Alt&gt;l" type="string" value="xfce4-session-logout"/>
      <property name="Print" type="string" value="xfce4-screenshooter"/>
    </property>
  </property>
</channel>
EOF

# Configurar lightdm (gestor de inicio de sesión)
print_status "Configurando LightDM..."
cat > /etc/lightdm/lightdm.conf << 'EOF'
[Seat:*]
greeter-session=lightdm-gtk-greeter
session-wrapper=/etc/X11/Xsession

[Greeter]
theme-name=Arc-Dark
icon-theme-name=Papirus
font-name=Sans 10
background=/usr/share/backgrounds/desktop.jpg
user-background=false
EOF

# Establecer OpenBox como sesión por defecto
print_status "Estableciendo OpenBox como sesión por defecto..."
if [ -d /usr/share/xsessions ]; then
    cat > /usr/share/xsessions/openbox.desktop << 'EOF'
[Desktop Entry]
Name=OpenBox
Comment=Log in using the OpenBox window manager
Exec=/usr/bin/openbox-session
Type=Application
EOF
fi

# Configurar permisos
print_status "Estableciendo permisos..."
chown -R $CURRENT_USER:$CURRENT_USER $HOME_DIR/.config
chown -R $CURRENT_USER:$CURRENT_USER $HOME_DIR/.themes
chown -R $CURRENT_USER:$CURRENT_USER $HOME_DIR/.icons
chown -R $CURRENT_USER:$CURRENT_USER $HOME_DIR/.local

# Instalar fuentes adicionales
print_status "Instalando fuentes adicionales..."
# FiraCode Nerd Font
wget -O /tmp/FiraCode.zip "https://github.com/ryanoasis/nerd-fonts/releases/download/v2.1.0/FiraCode.zip" > /dev/null 2>&1
mkdir -p /usr/local/share/fonts/FiraCode
unzip /tmp/FiraCode.zip -d /usr/local/share/fonts/FiraCode/ > /dev/null 2>&1
fc-cache -fv > /dev/null 2>&1

# Limpiar paquetes innecesarios
print_status "Limpiando sistema..."
apt autoremove -y
apt clean

print_success "Instalación y configuración completada!"
print_warning "Reinicia el sistema para aplicar todos los cambios."

exit 0
