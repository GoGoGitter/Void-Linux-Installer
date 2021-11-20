#!/usr/bin/env bash

curl -O https://raw.githubusercontent.com/GoGoGitter/Void-Linux-Installer/main/HPDesktop/2-Configuration.sh
/bin/bash 2-Configuration.sh
rm 2-Configuration.sh

curl -O https://raw.githubusercontent.com/GoGoGitter/Void-Linux-Installer/main/HPDesktop/3-Packages.sh
/bin/bash 3-Packages.sh
rm 3-Packages.sh
