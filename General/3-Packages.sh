#!/usr/bin/env bash

echo "-------------------------------------------------"
echo "-----               Packages                -----"
echo "-------------------------------------------------"
PKGS=(
'xdg-user-dirs'         # general user directories
'brillo'                # Manages Screen Brightness
'rtkit'                 # 
'pulsemixer'            # TUI app for controlling volume of applications
##DNSSEC                 # might use unbound
#'xf86-input-mtrack'     # Driver for Touchpads
##alternative to locate  # might go with plocate
'font-hack-ttf'         # monospace font
##normal font            # general font (probably going with deja vu)
##fontpreviewer          # fontpreviewer
'papirus-icon-theme'    # Icons
'arc-theme'
'firefox'               # Browser
'chromium'              # Browser
'nnn'                   # File Manager
#'xdotool'               # for nnn's preview-tabbed plugin
'trash-cli'             # Trash Utility
#'udisks2'               # Auto-mounting
#'udiskie'               # Auto-mounting
'htop'                  # System Monitor
#'dunst'                 # Notification Manager
'parcellite'            # Clipboard Manager
'xclip'                 # Clipboard Utility (keepass-cli requires it for copying password entries)
#'redshift'              # Blue Light Filter
#'gnome-screenshot'      # Screenshot Utility
#'sxiv'                  # Image Viewer
#'mpv'                   # Multimedia Player
'yt-dlp'                # Youtube-dl fork
#'p7zip'                 # Archiving and Extracting Tool
#'transmission'          # BitTorrent Client
'keepassxc'             # Password Manager
#'bleachbit'             # Disk Cleaning Utility
#'tor'                   # Tor
#'libreoffice'           # Office Suite
#'hunspell-en_US'        # Office Suite
'evtest'                # for use with xboxdrv
#'nitrogen'              # Wallpaper Setter
#'openssh'               # OpenBSD Secure Shell
'aria2'                 # dependency for a git package: ani-cli
'jq'                    # dependency for a git package: ani-cli
'xboxdrv'               # Xbox Gamepad Userspace Driver
#'protonvpn-cli'         # ProtonVPN
'melonDS'               # Nintendo DS emulator
'dolphin-emu'           # Gamecube/Wii emulator
'steam'                 # Valve's steam client
'libgcc-32bit'          # for steam
'libstdc++-32bit'       # for steam
'libdrm-32bit'          # for steam
'libglvnd-32bit'        # for steam
'mesa-dri-32bit'        # for steam
)
for PKG in "${PKGS[@]}"; do
    xbps-install -y $PKG
done

gpasswd -a ${NAME} video # adding the user to the video group so that 'light' does not require root permission to work
sed -i "s/$(cat /etc/default/grub | grep GRUB_CMDLINE_LINUX_DEFAULT | sed 's/.$//')/$(cat /etc/default/grub | grep GRUB_CMDLINE_LINUX_DEFAULT | sed 's/.$//') acpi_backlight=vendor/" /etc/default/grub
update-grub
echo 'brillo -I' >> /etc/rc.local
echo 'brillo -O' >> /etc/rc.shutdown

curl -Ls https://raw.githubusercontent.com/jarun/nnn/master/plugins/getplugs | sh # 'nnn' downloading nnn plugins

gpasswd -a ${NAME} input # 'evtest' adding user to input group to ensure gamepads can be used without root privileges

echo 'blacklist xpad' > /etc/modprobe.d/xpad.conf

#dracut --force --add-drivers bcm5974 # 'xf86-input-mtrack' without this, trackpad only moves up and down despite configuration given "because of some dracut driver inclusion issue" (from void wiki)

echo "-------------------------------------------------"
echo "-----            Source Packages            -----"
echo "-------------------------------------------------"
su - $NAME <<EOF
    cd ~/.git-clones/void-packages

    PKGS=(
    'dwm'                # Window Manager
    'st'                 # Terminal Emulator
    'dmenu'              # Application Launcher
    'slock'              # Screen Locker
    #'slstatus'           # Status Monitor
    #'tabbed'             # 
    #                     # Minecraft Launcher
    )
    for PKG in "${PKGS[@]}"; do
        ./xbps-src pkg $PKG
        doas xbps-install -y --repository hostdir/binpkgs $PKG
    done

    echo "exec dbus-run-session dwm" >> ~/.xinitrc

    echo "-------------------------------------------------"
    echo "-----             Git Packages              -----"
    echo "-------------------------------------------------"
    cd ~/.git-clones
    git clone https://github.com/pystardust/ani-cli.git
    cd ani-cli
    doas make
EOF
