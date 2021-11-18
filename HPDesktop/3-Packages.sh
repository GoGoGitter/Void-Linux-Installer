### Packages
xdg-user-dirs # installing general user directories
light
pulsemixer
#DNSSEC
xf86-input-mtrack
#alternative to locate
font-hack-ttf
#normal font
#fontpreviewer
papirus-icon-theme
arc-theme
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

### Source Packages
#'dwm'                # Window Manager
#'st'                 # Terminal Emulator
#'dmenu'              # Application Launcher
#'slock'              # Screen Locker
#'slstatus'           # Status Monitor
#'surf'               # Browser
#                     # Minecraft Launcher

### Git Clones
cd ~/.git-clones
git clone https://github.com/pystardust/ani-cli.git
cd ani-cli
doas make
