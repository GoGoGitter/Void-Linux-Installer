#!/usr/bin/env bash

echo "-------------------------------------------------"
echo "-----               Packages                -----"
echo "-------------------------------------------------"
PKGS=(
##DNSSEC                 # might use unbound
##alternative to locate  # might go with plocate
'papirus-icon-theme'    # Icons
#'arc-theme'
'firefox'               # Browser
'gvfs'                  # auto-mounting + trash Support for Thunar
'thunar-archive-plugin' # frontend for archivers
'xarchiver'             # desktop independent archive manager
'htop'                  # System Monitor
'yt-dlp'                # Youtube-dl fork
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
'evtest'                # Gamepad Support
#'nitrogen'              # Wallpaper Setter
#'openssh'               # OpenBSD Secure Shell
'aria2'                 # dependency for a git package: ani-cli
#'xboxdrv'
#'protonvpn-cli'
)
for PKG in "${PKGS[@]}"; do
    doas xbps-install -Sy $PKG
done
