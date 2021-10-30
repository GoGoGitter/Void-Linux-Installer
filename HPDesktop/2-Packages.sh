#!/usr/bin/env bash

xbps-install -Su # XBPS must use a separate transaction to update itself.
xbps-install -Su # If your update includes the xbps package, you will need to run the command a second time to apply the rest of the updates.

### for intel microcode
#xbps-install -y void-repo-nonfree # Void has a nonfree repository for packages that don't have free licenses. It can enabled by installing the void-repo-nonfree package.
#xbps-install -y intel-ucode # After installing this package, it is necessary to regenerate your initramfs.
#xbps-reconfigure --force linux<x>.<y> # For subsequent updates, the microcode will be added to the initramfs automatically.

### for amd microcode
#xbps-install -y linux-firmware-amd # AMD CPUs and GPUs will automatically load the microcode, no further configuration required.

