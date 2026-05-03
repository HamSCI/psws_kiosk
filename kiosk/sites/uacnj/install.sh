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
mkdir -p /var/www/html/img
cp "$(dirname "$0")/www/slides.html" /var/www/html/slides.html
cp "$(dirname "$0")/../../base/www/split.html" /var/www/html/split.html
cp -r "$(dirname "$0")/www/img/." /var/www/html/img/

echo "=== Writing X11 monitor layout (stacked vertically to match physical layout) ==="
# Physical layout: ${DISPLAY_TOP} sits physically above ${DISPLAY_BOTTOM}.
# We position monitors via xorg.conf Monitor sections so the layout is set when the
# X server starts (rather than at runtime via xrandr, which causes ${DISPLAY_TOP}
# to lose signal on this AMD hardware).
cat > /etc/X11/xorg.conf.d/30-monitor-layout.conf << EOF
# Position the displays vertically so the virtual layout matches the physical one
# (top monitor above the bottom monitor). Without this, the AMD driver places them
# side-by-side at virtual coords (0,0) and (${BOTTOM_WIDTH},0) — which doesn't match
# how a visitor sees the screens stacked on the wall.
Section "Monitor"
    Identifier "${DISPLAY_TOP}"
    Option     "Position" "0 0"
EndSection

Section "Monitor"
    Identifier "${DISPLAY_BOTTOM}"
    Option     "Position" "0 ${TOP_HEIGHT}"
    Option     "Primary"  "true"
EndSection
EOF

echo "=== Writing Openbox autostart for UACNJ ==="
# Stacked virtual layout (after the xorg.conf.d above is applied):
#   ${DISPLAY_TOP}    @ (0, 0)            — physical top    — live data
#   ${DISPLAY_BOTTOM} @ (0, ${TOP_HEIGHT}) — physical bottom — educational slideshow
SPLIT_URL="http://localhost/split.html?left=$(python3 -c 'import urllib.parse,sys; print(urllib.parse.quote(sys.argv[1]))' "${URL_BOTTOM}")&right=$(python3 -c 'import urllib.parse,sys; print(urllib.parse.quote(sys.argv[1]))' "${URL_TOP}")"

cat > /home/${KIOSK_USER}/.config/openbox/autostart << EOF
# Kiosk hygiene
xset s off -dpms
xset s noblank
unclutter -idle 0.5 -root &

# Physical top monitor (${DISPLAY_TOP}, virtual 0,0) — split: SDR left, dashboard right
while true; do
    google-chrome-stable --kiosk --noerrdialogs --disable-infobars \
        --no-first-run --disable-translate --disable-features=TranslateUI \
        --window-position=0,0 --window-size=${TOP_WIDTH},${TOP_HEIGHT} \
        --user-data-dir=/home/${KIOSK_USER}/.chrome-top \
        "${SPLIT_URL}"
    sleep 5
done &

# Physical bottom monitor (${DISPLAY_BOTTOM}, virtual 0,${TOP_HEIGHT}) — educational slideshow
while true; do
    google-chrome-stable --kiosk --noerrdialogs --disable-infobars \
        --no-first-run --disable-translate --disable-features=TranslateUI \
        --window-position=0,${TOP_HEIGHT} --window-size=${BOTTOM_WIDTH},${BOTTOM_HEIGHT} \
        --user-data-dir=/home/${KIOSK_USER}/.chrome-bottom \
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
