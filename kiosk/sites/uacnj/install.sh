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

URL_TOP="http://192.168.11.202:5000/"
# TODO: restore to http://vpn.hamsci.org:46005/radio.html once RX888 hardware issue is resolved (requires in-person site visit)
# Test (home LAN): http://192.168.11.202:8081/radio.html
URL_BOTTOM="http://192.168.11.202:8081/radio.html"
# --------------------------------------------------------------

# Derive the Y offset for the bottom monitor from the top monitor's height
TOP_HEIGHT="${RES_TOP##*x}"
TOP_WIDTH="${RES_TOP%%x*}"
BOTTOM_WIDTH="${RES_BOTTOM%%x*}"
BOTTOM_HEIGHT="${RES_BOTTOM##*x}"

echo "=== Deploying kiosk web content ==="
mkdir -p /var/www/html
cp "$(dirname "$0")/www/slides.html" /var/www/html/slides.html
cp "$(dirname "$0")/../../base/www/split.html" /var/www/html/split.html

echo "=== Writing Openbox autostart for UACNJ ==="
# The amdgpu driver defaults to side-by-side: DISPLAY_BOTTOM (DisplayPort-0)
# at virtual 0,0 and DISPLAY_TOP (HDMI-A-0) at virtual BOTTOM_WIDTH,0.
# We do NOT run xrandr — reconfiguring HDMI-A-0's position kills its signal
# on this hardware. Chrome windows are placed at the default virtual coords.
#
# Top monitor:    slideshow served by local nginx
# Bottom monitor: split iframe page — SDR waterfall left, dashboard right
SPLIT_URL="http://localhost/split.html?left=$(python3 -c 'import urllib.parse,sys; print(urllib.parse.quote(sys.argv[1]))' "${URL_BOTTOM}")&right=$(python3 -c 'import urllib.parse,sys; print(urllib.parse.quote(sys.argv[1]))' "${URL_TOP}")"

cat > /home/${KIOSK_USER}/.config/openbox/autostart << EOF
# Kiosk hygiene
xset s off -dpms
xset s noblank
unclutter -idle 0.5 -root &

# Physical bottom monitor (${DISPLAY_BOTTOM}, virtual 0,0) — split: SDR left, dashboard right
while true; do
    google-chrome-stable --kiosk --noerrdialogs --disable-infobars \
        --no-first-run --disable-translate --disable-features=TranslateUI \
        --window-position=0,0 --window-size=${BOTTOM_WIDTH},${BOTTOM_HEIGHT} \
        --user-data-dir=/home/${KIOSK_USER}/.chrome-bottom \
        "${SPLIT_URL}"
    sleep 5
done &

# Physical top monitor (${DISPLAY_TOP}, virtual ${BOTTOM_WIDTH},0) — educational slideshow
while true; do
    google-chrome-stable --kiosk --noerrdialogs --disable-infobars \
        --no-first-run --disable-translate --disable-features=TranslateUI \
        --window-position=${BOTTOM_WIDTH},0 --window-size=${TOP_WIDTH},${TOP_HEIGHT} \
        --user-data-dir=/home/${KIOSK_USER}/.chrome-top \
        http://localhost/slides.html
    sleep 5
done &

# x11vnc — VNC server capturing the live X display; localhost only, access via SSH tunnel
x11vnc -display :0 -localhost -nopw -forever -shared -noxdamage -bg -o /tmp/x11vnc.log
EOF

chown ${KIOSK_USER}:${KIOSK_USER} /home/${KIOSK_USER}/.config/openbox/autostart

echo "UACNJ site setup complete."
echo ""
echo "NOTE: On the production site hardware, verify display output names:"
echo "  sudo X :1 & sleep 2 && DISPLAY=:1 xrandr; kill %1"
echo "Update DISPLAY_TOP/RES_TOP/DISPLAY_BOTTOM/RES_BOTTOM in this script and re-run."
