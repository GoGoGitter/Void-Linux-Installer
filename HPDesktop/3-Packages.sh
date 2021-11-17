# Packages
doas xbps-install -Sy mpv
doas xbps-install -Sy ffmpeg # dependency for a git package: ani-cli

# Source Packages

# Git Clones
cd ~/.git-clones
git clone https://github.com/pystardust/ani-cli.git
cd ani-cli
doas make
