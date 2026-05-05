# Site: UACNJ — Paul H. Robinson Observatory

**United Astronomy Clubs of New Jersey**
Jenny Jump State Forest, Hope, Warren County, NJ (elevation ~1,100 ft)

All-volunteer 501(c)(3) nonprofit operating one of New Jersey's last truly dark-sky public observatories. Free Saturday public programs April–October.

## Kiosk configuration

| Setting | Value |
| ------- | ----- |
| Top monitor | Auto-advancing educational slideshow (`/slides.html` served by local nginx) |
| Bottom monitor | Split iframes — KA9Q-Web SDR waterfall (left) + PSWS Contesting DX Dashboard (right) |
| Display layout | 2× 22″ FHD monitors, stacked vertically |
| Output names (current home test) | `DisplayPort-0` (top, 1920×1080), `HDMI-A-0` (bottom, 1920×1080) |
| Output names (production at UACNJ) | Re-verify with `xrandr` at install time; both expected to be 1920×1080 |
| GPU driver | `xserver-xorg-video-amdgpu` (set in `kiosk/base/install.sh`) — `modesetting` only drives one output on this hardware |
| Monitor stacking | Set via `/etc/X11/xorg.conf.d/30-monitor-layout.conf` (positions applied at X startup; runtime `xrandr` causes HDMI-A-0 to lose signal on this hardware) |

This directory contains everything UACNJ-specific:

- `install.sh` — writes the Openbox autostart, the xorg.conf monitor layout, and deploys the local web content (`/var/www/html/slides.html`, `/var/www/html/split.html`, `/var/www/html/img/*`).
- `www/slides.html` — the educational slideshow (HTML/CSS), edited directly. Re-deploy with `sudo bash install.sh` and restart the slideshow Chrome window.
- `www/img/` — HamSCI bottom banner and partner-institution logos used by the slideshow.
