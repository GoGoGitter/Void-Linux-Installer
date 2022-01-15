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
'yt-dlp'                # Youtube-dl fork
''                # PDF viewer
#'keepassxc'             # Password Manager
#'bleachbit'             # Disk Cleaning Utility
'libreoffice'           # Office Suite
'hunspell-en_US'        # Office Suite
#'openssh'               # OpenBSD Secure Shell
)
for PKG in "${PKGS[@]}"; do
    doas xbps-install -Sy $PKG
done
