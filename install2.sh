#!/bin/bash

# Configuración de variables
CURRENT_USER="frodo"
HOME_DIR="/home/$CURRENT_USER"

# Función para imprimir estado
print_status() {
    echo "[+] $1"
}

# Verificar que el script se ejecute como root
if [ "$(id -u)" -ne 0 ]; then
    echo "Este script debe ejecutarse como root. Usa: sudo $0"
    exit 1
fi

# Verificar que el usuario frodo existe
if ! id "$CURRENT_USER" &>/dev/null; then
    echo "Error: El usuario '$CURRENT_USER' no existe."
    exit 1
fi

# Crear directorios de configuración necesarios
print_status "Creando directorios de configuración..."
directories=(
    "$HOME_DIR/.config/openbox"
    "$HOME_DIR/.config/tint2"
    "$HOME_DIR/.config/picom"
    "$HOME_DIR/.config/rofi"
    "$HOME_DIR/.config/nitrogen"
    "$HOME_DIR/.config/gtk-3.0"
    "$HOME_DIR/.config/xfce4/terminal"
    "$HOME_DIR/.config/Thunar"
    "$HOME_DIR/.config/xfce4/xfconf/xfce-perchannel-xml"
    "$HOME_DIR/.local/share/rofi/themes"
    "$HOME_DIR/Imágenes/Screenshots"
)

for dir in "${directories[@]}"; do
    sudo -u $CURRENT_USER mkdir -p "$dir"
done

# Instalar dependencias necesarias (opcional - descomenta si quieres)
# print_status "Instalando dependencias..."
# apt update
# apt install -y openbox tint2 picom rofi nitrogen thunar xfce4-terminal firefox-esr \
#               papirus-icon-theme arc-theme gsimplecal scrot

# Configurar rc.xml de OpenBox
print_status "Configurando OpenBox rc.xml..."
sudo -u $CURRENT_USER cat > "$HOME_DIR/.config/openbox/rc.xml" << 'EOF'
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
sudo -u $CURRENT_USER cat > "$HOME_DIR/.config/tint2/tint2rc" << 'EOF'
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
sudo -u $CURRENT_USER cat > "$HOME_DIR/.config/picom/picom.conf" << 'EOF'
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
sudo -u $CURRENT_USER cat > "$HOME_DIR/.config/rofi/config.rasi" << 'EOF'
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
sudo -u $CURRENT_USER wget -O "$HOME_DIR/Imágenes/wallpaper.jpg" "https://picsum.photos/1920/1080" > /dev/null 2>&1 || \
sudo -u $CURRENT_USER cp /usr/share/backgrounds/*.jpg "$HOME_DIR/Imágenes/wallpaper.jpg" 2>/dev/null || true

sudo -u $CURRENT_USER cat > "$HOME_DIR/.config/nitrogen/bg-saved.cfg" << EOF
[xin_-1]
file=$HOME_DIR/Imágenes/wallpaper.jpg
mode=5
bgcolor=#000000
EOF

# Configurar temas GTK e iconos
print_status "Configurando temas GTK e iconos..."
sudo -u $CURRENT_USER cat > "$HOME_DIR/.gtkrc-2.0" << 'EOF'
gtk-theme-name="Arc-Dark"
gtk-icon-theme-name="Papirus"
gtk-font-name="Sans 10"
gtk-cursor-theme-name="breeze_cursors"
gtk-cursor