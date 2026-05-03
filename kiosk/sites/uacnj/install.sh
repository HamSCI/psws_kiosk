#!/bin/bash
# UACNJ site-specific kiosk setup — run as root after kiosk/base/install.sh.
# Configures display layout and Openbox autostart for the UACNJ observatory kiosk.
#
# Before running:
#   1. Boot the kiosk with both monitors connected
#   2. Run `xrandr` (as the kiosk user) to find actual output names
#   3. Update DISPLAY_TOP and DISPLAY_BOTTOM below to match

set -euo pipefail

KIOSK_USER="kiosk"

# --- Update these to match `xrandr` output on this hardware ---
DISPLAY_TOP="HDMI-1"
DISPLAY_BOTTOM="HDMI-2"
RESOLUTION="1920x1080"

URL_TOP="https://uacnj.kd3ald.com"
URL_BOTTOM="http://vpn.hamsci.org:46005/radio.html"
# --------------------------------------------------------------

echo "=== Writing Openbox autostart for UACNJ ==="
cat > /home/${KIOSK_USER}/.config/openbox/autostart << EOF
# Display arrangement
xrandr --output ${DISPLAY_TOP}    --mode ${RESOLUTION} --pos 0x0 \
       --output ${DISPLAY_BOTTOM} --mode ${RESOLUTION} --pos 0x1080

# Kiosk hygiene
xset s off -dpms
xset s noblank
unclutter -idle 0.5 -root &

# Top monitor — PSWS Contesting DX Dashboard
while true; do
    chromium-browser --kiosk --noerrdialogs --disable-infobars \
        --window-position=0,0 --window-size=1920,1080 \
        --user-data-dir=/home/${KIOSK_USER}/.chromium-top \
        ${URL_TOP}
    sleep 5
done &

# Bottom monitor — KA9Q-Web SDR waterfall
while true; do
    chromium-browser --kiosk --noerrdialogs --disable-infobars \
        --window-position=0,1080 --window-size=1920,1080 \
        --user-data-dir=/home/${KIOSK_USER}/.chromium-bottom \
        ${URL_BOTTOM}
    sleep 5
done &
EOF

chown ${KIOSK_USER}:${KIOSK_USER} /home/${KIOSK_USER}/.config/openbox/autostart

echo "UACNJ site setup complete."
echo ""
echo "NOTE: Verify display output names before rebooting:"
echo "  sudo -u ${KIOSK_USER} DISPLAY=:0 xrandr"
echo "Update DISPLAY_TOP / DISPLAY_BOTTOM in this script if needed, then re-run."
