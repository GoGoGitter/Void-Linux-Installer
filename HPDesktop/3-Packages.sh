#!/usr/bin/env bash

echo "-------------------------------------------------"
echo "-----               Packages                -----"
echo "-------------------------------------------------"
PKGS=(
##DNSSEC                 # might use unbound
##alternative to locate  # might go with plocate
'breeze-gtk'            # GTK theme
'paper-icon-theme'      # for the cursor icon
'firefox'               # Browser
'gvfs'                  # auto-mounting + trash Support for Thunar
'thunar-archive-plugin' # frontend for archivers
'xarchiver'             # desktop independent archive manager
'yt-dlp'                # Youtube-dl fork
'xreader'               # PDF viewer
'iwgtk'                 # GUI frontend for iwd
#'keepassxc'             # Password Manager
#'bleachbit'             # Disk Cleaning Utility
'libreoffice'           # Office Suite
'hunspell-en_US'        # Office Suite
'hunspell-es_ES'        # Office Suite
#'openssh'               # OpenBSD Secure Shell
)
for PKG in "${PKGS[@]}"; do
    doas xbps-install -Sy $PKG
done
