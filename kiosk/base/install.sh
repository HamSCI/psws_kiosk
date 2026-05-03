#!/bin/bash
# Kiosk base install script — run as root on a fresh Ubuntu 24.04 LTS server install.
# Sets up the minimal graphical stack, kiosk user, auto-login, and Chromium.
# Run site-specific setup afterwards from kiosk/sites/<name>/install.sh

set -euo pipefail

KIOSK_USER="kiosk"

echo "=== Installing graphical stack ==="
apt-get update
apt-get install --no-install-recommends -y \
    xserver-xorg \
    x11-xserver-utils \
    xinit \
    openbox \
    unclutter \
    xserver-xorg-video-amdgpu \
    wget \
    gnupg

echo "=== Installing Google Chrome (non-snap; snap Chromium ignores --user-data-dir) ==="
wget -q -O /tmp/google-chrome.deb \
    https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
apt-get install --no-install-recommends -y /tmp/google-chrome.deb
rm /tmp/google-chrome.deb

echo "=== Forcing amdgpu driver (modesetting only drives one output on this hardware) ==="
mkdir -p /etc/X11/xorg.conf.d
cat > /etc/X11/xorg.conf.d/20-amdgpu.conf << 'EOF'
Section "Device"
    Identifier  "AMD GPU"
    Driver      "amdgpu"
    Option      "TearFree" "true"
    Option      "DRI" "3"
EndSection
EOF

echo "=== Creating kiosk user ==="
if ! id "$KIOSK_USER" &>/dev/null; then
    useradd -m -s /bin/bash "$KIOSK_USER"
fi

echo "=== Configuring auto-login on tty1 ==="
mkdir -p /etc/systemd/system/getty@tty1.service.d
cat > /etc/systemd/system/getty@tty1.service.d/override.conf << EOF
[Service]
ExecStart=
ExecStart=-/sbin/agetty --autologin ${KIOSK_USER} --noclear %I \$TERM
EOF

echo "=== Configuring auto-start X on login ==="
cat > /home/${KIOSK_USER}/.bash_profile << 'EOF'
if [ -z "$DISPLAY" ] && [ "$(tty)" = "/dev/tty1" ]; then
    exec startx
fi
EOF
chown ${KIOSK_USER}:${KIOSK_USER} /home/${KIOSK_USER}/.bash_profile

echo "=== Creating Openbox config directory ==="
mkdir -p /home/${KIOSK_USER}/.config/openbox
chown -R ${KIOSK_USER}:${KIOSK_USER} /home/${KIOSK_USER}/.config

echo "=== Disabling sleep/screensaver ==="
mkdir -p /etc/X11/xorg.conf.d
cat > /etc/X11/xorg.conf.d/10-noblank.conf << 'EOF'
Section "ServerFlags"
    Option "BlankTime"   "0"
    Option "StandbyTime" "0"
    Option "SuspendTime" "0"
    Option "OffTime"     "0"
EndSection
EOF

echo "=== Configuring nightly reboot at 04:00 UTC ==="
echo "0 4 * * * root /sbin/reboot" > /etc/cron.d/kiosk-nightly-reboot

echo "=== Reloading systemd ==="
systemctl daemon-reload

echo ""
echo "Base install complete. Now run the site-specific install script:"
echo "  bash kiosk/sites/<name>/install.sh"
