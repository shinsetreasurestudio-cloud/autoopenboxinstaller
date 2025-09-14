#!/bin/bash

# Script de instalación de BSPWM para Debian 13
# Ejecutar como usuario normal (no root)

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

# Verificar que no se ejecute como root
if [ "$EUID" -eq 0 ]; then
    print_error "No ejecutar este script como root. Ejecuta como usuario normal."
    exit 1
fi

# Actualizar sistema
print_status "Actualizando sistema..."
sudo apt update && sudo apt upgrade -y

# Instalar dependencias básicas
print_status "Instalando dependencias básicas..."
sudo apt install -y curl wget git build-essential libx11-dev libxft-dev libxinerama-dev \
libxrandr-dev libxcursor-dev libxcb-xkb-dev libxcb-util0-dev libxcb-icccm4-dev \
libxcb-ewmh-dev libxcb-randr0-dev libxcb-keysyms1-dev libxcb-xinerama0-dev \
libasound2-dev libxcb-xtest0-dev libxcb-shape0-dev cmake cmake-data pkg-config \
python3-sphinx libcairo2-dev libxcb1-dev libxcb-composite0-dev python3-xcbgen \
xcb-proto libxcb-image0-dev libxcb-xrm-dev libxcb-xfixes0-dev libxft-dev \
libjsoncpp-dev libmpdclient-dev libcurl4-openssl-dev libnl-genl-3-dev \
meson ninja-build

# Instalar Xorg y componentes básicos
print_status "Instalando Xorg..."
sudo apt install -y xorg xserver-xorg xinit x11-xserver-utils x11-utils \
x11-apps xauth x11-session-utils x11-common x11-xkb-utils

# Instalar BSPWM y dependencias
print_status "Instalando BSPWM y SXHKD..."
sudo apt install -y bspwm sxhkd

# Instalar utilidades y aplicaciones
print_status "Instalando utilidades y aplicaciones..."
sudo apt install -y rofi polybar dunst picom feh thunar thunar-archive-plugin \
thunar-media-tags-plugin ranger scrot imagemagick mpv mpd mpc ncmpcpp \
pulseaudio pavucontrol alsa-utils playerctl lxappearance qt5ct \
arc-theme papirus-icon-theme fonts-font-awesome fonts-noto \
fonts-roboto fonts-hack-ttf fonts-firacode

# Instalar terminal y editores
print_status "Instalando terminal y editores..."
sudo apt install -y kitty alacritty vim neovim nano

# Instalar herramientas de desarrollo
print_status "Instalando herramientas de desarrollo..."
sudo apt install -y python3 python3-pip nodejs npm

# Crear directorios de configuración
print_status "Creando directorios de configuración..."
mkdir -p ~/.config/{bspwm,sxhkd,polybar,rofi,kitty,dunst,picom,mpd,ncmpcpp}

# Clonar y compilar algunos componentes desde source si es necesario
print_status "Compilando componentes adicionales..."

# Compilar lemonbar (opcional, polybar ya está instalado)
# sudo apt install -y lemonbar

# Instalar algunas utilidades desde pip
print_status "Instalando utilidades Python..."
pip3 install --user i3ipac

# Configurar BSPWM
print_status "Configurando BSPWM..."
cat > ~/.config/bspwm/bspwmrc << 'EOF'
#!/bin/bash

# Monitor configuration
bspc monitor -d 1 2 3 4 5 6 7 8 9 10

# Window settings
bspc config border_width         2
bspc config window_gap          12
bspc config split_ratio          0.52
bspc config borderless_monocle   true
bspc config gapless_monocle      true

# Padding
bspc config top_padding         25
bspc config bottom_padding      0
bspc config left_padding        0
bspc config right_padding       0

# Colors
bspc config normal_border_color  "#444444"
bspc config focused_border_color "#5294e2"
bspc config active_border_color  "#5294e2"
bspc config presel_feedback_color "#5294e2"

# Rules
bspc rule -a Gimp desktop='^8' state=floating follow=on
bspc rule -a Chromium desktop='^2'
bspc rule -a mplayer2 state=floating
bspc rule -a Kupfer.py focus=on
bspc rule -a Screenkey manage=off

# Autostart
sxhkd &
polybar main &
picom --config ~/.config/picom/picom.conf &
dunst &
feh --bg-fill ~/.config/wallpaper.jpg &
xsetroot -cursor_name left_ptr &
EOF

chmod +x ~/.config/bspwm/bspwmrc

# Configurar SXHKD
print_status "Configurando SXHKD..."
cat > ~/.config/sxhkd/sxhkdrc << 'EOF'
# Terminal emulator
super + Return
    kitty

# Program launcher
super + d
    rofi -show drun

# Window operations
super + {_,shift + }w
    bspc node -{c,k}

super + m
    bspc node -t ~floating

super + f
    bspc node -t \~fullscreen

super + {_,shift + }{1-9,0}
    bspc {desktop -f,node -d} '^{1-9,10}'

# Window focus
super + {h,j,k,l}
    bspc node -f {west,south,north,east}

# Window move
super + shift + {h,j,k,l}
    bspc node -v {west,south,north,east}

# Window resize
alt + {h,j,k,l}
    bspc node -z {left -20 0,bottom 0 20,top 0 -20,right 20 0}

alt + shift + {h,j,k,l}
    bspc node -z {right -20 0,top 0 20,bottom 0 -20,left 20 0}

# Preselect
super + ctrl + {h,j,k,l}
    bspc node -p {west,south,north,east}

super + ctrl + {1-9}
    bspc node -o 0.{1-9}

# Layout
super + t
    bspc node -t tiled

super + s
    bspc node -t floating

super + space
    bspc node -t next

# State
super + ctrl + m
    bspc desktop -l next

# Misc
super + r
    bspc wm -r

super + Print
    scrot -s '%Y-%m-%d_$wx$h_scrot.png' -e 'mv $f ~/Pictures/'

# Volume control
XF86AudioRaiseVolume
    pamixer -i 5

XF86AudioLowerVolume
    pamixer -d 5

XF86AudioMute
    pamixer -t

# Brightness control
XF86MonBrightnessUp
    brightnessctl set +5%

XF86MonBrightnessDown
    brightnessctl set 5%-
EOF

# Configurar Polybar
print_status "Configurando Polybar..."
cat > ~/.config/polybar/config.ini << 'EOF'
[colors]
background = #2f343f
background-alt = #404552
foreground = #fbfbfb
primary = #5294e2
secondary = #5294e2
alert = #e53935

[bar/main]
monitor = ${env:MONITOR:eDP1}
width = 100%
height = 25
offset-x = 0
offset-y = 0
fixed-center = true
background = ${colors.background}
foreground = ${colors.foreground}
wm-restack = bspwm
modules-left = bspwm
modules-center = date
modules-right = volume cpu memory temperature battery
font-0 = "Noto Sans:size=10;3"
font-1 = "Font Awesome 6 Free Solid:style=Solid:size=10;3"
font-2 = "Font Awesome 6 Brands:style=Regular:size=10;3"

[module/bspwm]
type = internal/bspwm
label-focused = %index%
label-focused-background = ${colors.primary}
label-focused-foreground = ${colors.background}
label-occupied = %index%
label-urgent = %index%
label-empty = %index%

[module/date]
type = internal/date
interval = 1
date = %Y-%m-%d%
time = %H:%M
label = %date% %time%

[module/volume]
type = internal/pulseaudio
format-volume = <label-volume> <bar-volume>
label-volume = VOL
label-volume-foreground = ${colors.foreground}
bar-volume-width = 10
bar-volume-foreground-0 = #55aa55
bar-volume-foreground-1 = #55aa55
bar-volume-foreground-2 = #55aa55
bar-volume-foreground-3 = #55aa55
bar-volume-foreground-4 = #55aa55
bar-volume-foreground-5 = #f5a70a
bar-volume-foreground-6 = #ff5555
bar-volume-gradient = false
bar-volume-indicator = |
bar-volume-fill = |
bar-volume-empty = |

[module/cpu]
type = internal/cpu
interval = 2
format-prefix = "CPU "
format-prefix-foreground = ${colors.foreground}
label = %percentage:2%%

[module/memory]
type = internal/memory
interval = 2
format-prefix = "RAM "
format-prefix-foreground = ${colors.foreground}
label = %percentage_used:2%%

[module/temperature]
type = internal/temperature
thermal-zone = 0
warn-temperature = 80
format = <label>
format-warn = <label-warn>
label = TEMP %temperature-c%
label-warn = TEMP %temperature-c%
label-warn-foreground = ${colors.alert}

[module/battery]
type = internal/battery
battery = BAT0
adapter = AC
full-at = 98
format-charging = <label-charging>
format-discharging = <label-discharging>
format-full = <label-full>
label-charging = BAT %percentage%%
label-discharging = BAT %percentage%%
label-full = BAT FULL
EOF

# Crear script de lanzamiento de Polybar
cat > ~/.config/polybar/launch.sh << 'EOF'
#!/bin/bash
killall -q polybar
while pgrep -u $UID -x polybar >/dev/null; do sleep 1; done
polybar main &
EOF

chmod +x ~/.config/polybar/launch.sh

# Configurar Picom
print_status "Configurando Picom..."
cat > ~/.config/picom/picom.conf << 'EOF'
# Shadows
shadow = true;
shadow-radius = 12;
shadow-offset-x = -5;
shadow-offset-y = -5;
shadow-opacity = 0.5;

# Fading
fading = true;
fade-in-step = 0.03;
fade-out-step = 0.03;

# Opacity
inactive-opacity = 0.8;
frame-opacity = 0.7;
inactive-opacity-override = false;

# Corners
corner-radius = 10
round-borders = 1

# Blur
blur-background = true;
blur-background-frame = true;
blur-background-fixed = true;
blur-kern = "3x3box";
blur-method = "kernel";
blur-strength = 5;

# Other
backend = "glx";
vsync = true;
mark-wmwin-focused = true;
mark-ovredir-focused = true;
detect-rounded-corners = true;
detect-client-opacity = true;
use-damage = true;
log-level = "warn";
EOF

# Configurar Dunst
print_status "Configurando Dunst..."
cat > ~/.config/dunst/dunstrc << 'EOF'
[global]
    monitor = 0
    follow = keyboard
    width = 300
    height = 300
    origin = top-right
    offset = 10x50
    scale = 0
    notification_limit = 0
    progress_bar = true
    transparency = 0
    separator_height = 2
    padding = 8
    horizontal_padding = 8
    frame_width = 3
    frame_color = "#5294e2"
    separator_color = frame
    sort = yes
    idle_threshold = 120
    font = Monospace 8
    line_height = 0
    markup = full
    format = "<b>%s</b>\n%b"
    alignment = left
    show_age_threshold = 60
    word_wrap = yes
    ellipsize = middle
    ignore_newline = no
    stack_duplicates = true
    hide_duplicate_count = false
    show_indicators = yes
    icon_position = left
    max_icon_size = 32
    icon_path = /usr/share/icons/gnome/16x16/status/:/usr/share/icons/gnome/16x16/devices/
    sticky_history = yes
    history_length = 20
    dmenu = /usr/bin/dmenu -p dunst:
    browser = /usr/bin/firefox -new-tab
    always_run_script = true
    title = Dunst
    class = Dunst
    startup_notification = false
    verbosity = mesg
    corner_radius = 10

[shortcuts]
    close = ctrl+space
    close_all = ctrl+shift+space
    history = ctrl+grave
    context = ctrl+shift+period

[urgency_low]
    background = "#2f343f"
    foreground = "#f3f4f5"
    timeout = 10

[urgency_normal]
    background = "#285577"
    foreground = "#f3f4f5"
    timeout = 10

[urgency_critical]
    background = "#900000"
    foreground = "#ffffff"
    timeout = 0
EOF

# Configurar Kitty
print_status "Configurando Kitty..."
cat > ~/.config/kitty/kitty.conf << 'EOF'
font_family      FiraCode Nerd Font Mono
font_size        11.0
bold_font        auto
italic_font      auto
bold_italic_font auto

background_opacity 0.95

# Colors
foreground              #D8DEE9
background              #2E3440
selection_foreground    #000000
selection_background    #FFFACD
url_color               #0087BD
color0                  #3B4252
color8                  #4C566A
color1                  #BF616A
color9                  #BF616A
color2                  #A3BE8C
color10                 #A3BE8C
color3                  #EBCB8B
color11                 #EBCB8B
color4                  #81A1C1
color12                 #81A1C1
color5                  #B48EAD
color13                 #B48EAD
color6                  #88C0D0
color14                 #88C0D0
color7                  #E5E9F0
color15                 #ECEFF4

# Advanced
shell_integration enabled
enable_audio_bell no
confirm_os_window_close 0
EOF

# Crear wallpaper por defecto
print_status "Creando wallpaper por defecto..."
mkdir -p ~/Pictures
cat > ~/.config/wallpaper.jpg << 'EOF'
# Esto creará un wallpaper básico, puedes reemplazarlo luego
# Para un wallpaper real, descarga uno después de la instalación
EOF

# Alternativa: descargar un wallpaper
wget -O ~/.config/wallpaper.jpg https://picsum.photos/1920/1080 || \
print_warning "No se pudo descargar wallpaper, creando uno básico..."

# Configurar .xinitrc
print_status "Configurando .xinitrc..."
cat > ~/.xinitrc << 'EOF'
#!/bin/bash

# Load Xresources
xrdb -merge ~/.Xresources

# Set Spanish keyboard layout
setxkbmap es

# Start BSPWM
exec bspwm
EOF

chmod +x ~/.xinitrc

# Configurar .bashrc para auto-startx
print_status "Configurando auto-start en login..."
if ! grep -q "startx" ~/.bash_profile; then
    echo 'if [[ -z $DISPLAY ]] && [[ $(tty) = /dev/tty1 ]]; then' >> ~/.bash_profile
    echo '    exec startx' >> ~/.bash_profile
    echo 'fi' >> ~/.bash_profile
fi

# Instalar algunos temas e iconos adicionales
print_status "Instalando temas e iconos..."
sudo apt install -y materia-gtk-theme lxappearance

# Crear script de post-instalación
cat > ~/bspwm_post_install.sh << 'EOF'
#!/bin/bash
echo "Post-instalación de BSPWM:"
echo "1. Reinicia o ejecuta 'startx' para iniciar BSPWM"
echo "2. Usa:"
echo "   - Super + Enter: Terminal"
echo "   - Super + D: Lanzador de aplicaciones"
echo "   - Super + W: Cerrar ventana"
echo "   - Super + 1-0: Cambiar workspace"
echo "3. Configura temas con: lxappearance"
echo "4. Personaliza las configuraciones en ~/.config/"
EOF

chmod +x ~/bspwm_post_install.sh

print_success "Instalación completada!"
print_warning "Reinicia o ejecuta 'startx' para iniciar BSPWM"
print_status "Para personalizar, revisa ~/bspwm_post_install.sh"

# Instalar algunas fuentes Nerd Fonts
print_status "Instalando fuentes Nerd Fonts..."
mkdir -p ~/.local/share/fonts
cd ~/.local/share/fonts

# Descargar algunas fuentes Nerd Fonts
wget -O "FiraCode.zip" "https://github.com/ryanoasis/nerd-fonts/releases/download/v3.0.2/FiraCode.zip" && \
unzip -o FiraCode.zip && rm FiraCode.zip 2>/dev/null || \
print_warning "No se pudieron descargar las fuentes Nerd"

wget -O "Hack.zip" "https://github.com/ryanoasis/nerd-fonts/releases/download/v3.0.2/Hack.zip" && \
unzip -o Hack.zip && rm Hack.zip 2>/dev/null || \
print_warning "No se pudieron descargar las fuentes Hack"

# Actualizar cache de fuentes
fc-cache -fv

print_success "¡Instalación completada completamente!"
echo ""
echo "Para iniciar BSPWM:"
echo "1. Reinicia el sistema"
echo "2. O ejecuta: startx"
echo "3. O inicia sesión y se iniciará automáticamente"
echo ""
echo "Atajos importantes:"
echo "Super + Enter - Terminal"
echo "Super + D - Lanzador de aplicaciones"
echo "Super + W - Cerrar ventana"
echo "Super + 1-0 - Cambiar workspace"