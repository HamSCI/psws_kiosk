#!/bin/bash
# UACNJ site-specific kiosk setup — run as root after kiosk/base/install.sh.
# Configures display layout and Openbox autostart for the UACNJ observatory kiosk.
#
# Before running:
#   1. Boot the kiosk with both monitors connected
#   2. Run `xrandr` (as the kiosk user) to find actual output names and resolutions
#   3. Update the four variables below to match

set -euo pipefail

KIOSK_USER="kiosk"

# --- Update these to match `xrandr` output on this hardware ---
# Output names when using xserver-xorg-video-amdgpu driver (required for
# dual-monitor on this hardware — modesetting driver only drives one output).
# Test setup (home): HDMI-A-0=1680x1050 (physical top), DisplayPort-0=1920x1080 (physical bottom)
# Production (UACNJ site): both monitors expected to support 1920x1080 — update
# all four variables after running `xrandr` on the site hardware.
DISPLAY_TOP="HDMI-A-0"
RES_TOP="1680x1050"
DISPLAY_BOTTOM="DisplayPort-0"
RES_BOTTOM="1920x1080"

URL_TOP="https://uacnj.kd3ald.com"
# TODO: restore to http://vpn.hamsci.org:46005/radio.html once that URL is confirmed publicly reachable
URL_BOTTOM="https://uacnj.kd3ald.com"
# --------------------------------------------------------------

# Derive the Y offset for the bottom monitor from the top monitor's height
TOP_HEIGHT="${RES_TOP##*x}"
TOP_WIDTH="${RES_TOP%%x*}"
BOTTOM_WIDTH="${RES_BOTTOM%%x*}"
BOTTOM_HEIGHT="${RES_BOTTOM##*x}"

echo "=== Writing Openbox autostart for UACNJ ==="
cat > /home/${KIOSK_USER}/.config/openbox/autostart << EOF
# Display arrangement — top monitor primary, bottom monitor below it
xrandr --output ${DISPLAY_TOP}    --primary --mode ${RES_TOP}    --pos 0x0 \
       --output ${DISPLAY_BOTTOM} --mode ${RES_BOTTOM} --pos 0x${TOP_HEIGHT}

# Kiosk hygiene
xset s off -dpms
xset s noblank
unclutter -idle 0.5 -root &

# Top monitor — PSWS Contesting DX Dashboard
while true; do
    chromium-browser --kiosk --noerrdialogs --disable-infobars \
        --window-position=0,0 --window-size=${TOP_WIDTH},${TOP_HEIGHT} \
        --user-data-dir=/home/${KIOSK_USER}/.chromium-top \
        ${URL_TOP}
    sleep 5
done &

# Bottom monitor — KA9Q-Web SDR waterfall
while true; do
    chromium-browser --kiosk --noerrdialogs --disable-infobars \
        --window-position=0,${TOP_HEIGHT} --window-size=${BOTTOM_WIDTH},${BOTTOM_HEIGHT} \
        --user-data-dir=/home/${KIOSK_USER}/.chromium-bottom \
        ${URL_BOTTOM}
    sleep 5
done &
EOF

chown ${KIOSK_USER}:${KIOSK_USER} /home/${KIOSK_USER}/.config/openbox/autostart

echo "UACNJ site setup complete."
echo ""
echo "NOTE: On the production site hardware, verify display output names:"
echo "  sudo X :1 & sleep 2 && DISPLAY=:1 xrandr; kill %1"
echo "Update DISPLAY_TOP/RES_TOP/DISPLAY_BOTTOM/RES_BOTTOM in this script and re-run."
