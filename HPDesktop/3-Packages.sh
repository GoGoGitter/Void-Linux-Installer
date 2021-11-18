### Packages
#'xdg-user-dirs'         # general user directories
'light'                 # Manages Screen Brightness
#'pulsemixer'            # TUI app for controlling volume of applications
##DNSSEC                 # might use unbound
#'xf86-input-mtrack'     # Driver for Touchpads
##alternative to locate  # might go with plocate
#'font-hack-ttf'         # monospace font
##normal font            # general font (probably going with deja vu)
##fontpreviewer          # fontpreviewer
#'papirus-icon-theme'    # Icons
#'arc-theme'
#'firefox'               # Browser
#'nnn'                   # File Manager
#'trash-cli'             # Trash Utility
#'udisks2'               # Auto-mounting
#'udiskie'               # Auto-mounting
#'ytop'                  # System Monitor
#'dunst'                 # Notification Manager
#'parcellite'            # Clipboard Manager
#'xclip'                 # Clipboard Utility (keepass-cli requires it for copying password entries)
#'redshift'              # Blue Light Filter
#'gnome-screenshot'      # Screenshot Utility
#'sxiv'                  # Image Viewer
#'mpv'                   # Multimedia Player
#'yt-dlp'                # Youtube-dl fork
#'p7zip'                 # Archiving and Extracting Tool
#'transmission'          # BitTorrent Client
#'keepassxc'             # Password Manager
#'bleachbit'             # Disk Cleaning Utility
#'tor'                   # Tor
#'libreoffice'           # Office Suite
#'hunspell'              # Office Suite
#'hunspell-en_US'        # Office Suite
#'hyphen'                # Office Suite
#'mythes'                # Office Suite
#'evtest'                # Gamepad Support
#'nitrogen'              # Wallpaper Setter
#'openssh'               # OpenBSD Secure Shell
#'ffmpeg'                # dependency for a git package: ani-cli
#'xboxdrv'
#'protonvpn-cli'
#'pkgconf'               # dependency for git package: joycond
#'cmake'                 # dependency for git package: joycond
#'libevdev-devel'        # dependency for git package: joycond
#'eudev-libudev-devel'   # dependency for git package: joycond

doas gpasswd -a ${USER} video # adding the user to the video group so that 'light' does not require root permission to work

#curl -Ls https://raw.githubusercontent.com/jarun/nnn/master/plugins/getplugs | sh # 'nnn' downloading nnn plugins

#doas gpasswd -a ${USER} input # 'evtest' adding user to input group to ensure gamepads can be used without root privileges

#doas ln -s /etc/sv/xboxdrv /var/service/
#doas touch /etc/sv/xboxdrv/down # allowing the service to be run during runtime but not started on boot

### Source Packages
cd ~/.git-clones/void-packages
./xbps-src pkg <package_name>
doas xbps-install --repository hostdir/binpkgs <package_name>
'dwm'                # Window Manager
'st'                 # Terminal Emulator
'dmenu'              # Application Launcher
'slock'              # Screen Locker
'slstatus'           # Status Monitor
'surf'               # Browser
'tabbed'             # 
#                     # Minecraft Launcher
echo "exec dwm" >> ~/.xinitrc

### Git Clones
cd ~/.git-clones
git clone https://github.com/pystardust/ani-cli.git
cd ani-cli
doas make

cd ~/.git-clones
git clone https://github.com/DanielOgorchock/joycond.git
cd joycond
cmake .
doas make install
