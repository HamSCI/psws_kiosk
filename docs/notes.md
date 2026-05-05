# Project Notes

Design decisions, open questions, and session notes for the psws_kiosk project.

---

## Architecture

- **No VPN on kiosks.** Upstream endpoints (the PSWS dashboard, KA9Q-Web SDR) are reached over the public internet.
- **X11 over Wayland** — better tooling for multi-monitor xrandr config and xinput touch mapping.
- **Openbox over a full DE** — no desktop environment bloat; kiosk only needs to launch two browser windows.
- **Google Chrome (`.deb`), not snap Chromium.** Snap Chromium silently remaps `--user-data-dir` to its confined storage, which prevents launching two independent kiosk instances (the second invocation finds the profile locked and just messages the first window). The Google Chrome `.deb` honors `--user-data-dir` correctly, so each monitor gets its own Chrome instance.
- **Separate `--user-data-dir` per Chrome instance** — required; second instance otherwise opens as a tab in the first.
- **Local nginx serves all on-screen content.** The slideshow (`/slides.html`) and the split-iframe page (`/split.html?left=…&right=…`) live in `/var/www/html`. Chrome only ever points at `localhost`, so display stability isn't held hostage to upstream URL changes or transient network blips.
- **Static monitor layout via `xorg.conf.d`, not runtime `xrandr`.** On this AMD hardware (amdgpu DDX driver), any runtime `xrandr` command that moves `HDMI-A-0` causes it to lose physical signal. We instead set monitor positions in `/etc/X11/xorg.conf.d/30-monitor-layout.conf` so the layout is established when the X server starts.
- **`amdgpu` DDX driver, not `modesetting`.** The generic modesetting driver only drives one CRTC at a time on this BeeLink hardware. The site install pins `Driver "amdgpu"` via `/etc/X11/xorg.conf.d/20-amdgpu.conf`.
- **`x11vnc` for live screen view.** Built-in framebuffer-based screen capture doesn't work on this AMD hardware because the KMS driver doesn't write the active X desktop to `/dev/fb0` while X is running. `x11vnc -display :0 -localhost -nopw` captures the real X display; we tunnel VNC over SSH for access.
- **Portable site design** — shared base config in `kiosk/base/`, per-site overrides in `kiosk/sites/<name>/`. Deploying to a new venue requires only a new site config.

## Open Questions

- [ ] Choose deployment workflow for cloning to additional kiosks: Clonezilla image vs. Ansible playbook from base Ubuntu.

## Resolved

- **xrandr output names on the installed hardware** — confirmed: `DisplayPort-0` (physical top, 1920×1080) and `HDMI-A-0` (physical bottom, 1920×1080) on the test setup; production UACNJ hardware to be re-verified at install time.
- **BeeLink model and Linux hardware compatibility** — verified working with Ubuntu 24.04 + amdgpu driver. Ethernet used; Wi-Fi/audio not exercised.

## Display content (UACNJ)

| Monitor | Source served by local nginx | What it actually shows |
| ------- | ---------------------------- | ---------------------- |
| Top | `http://localhost/slides.html` | Auto-advancing educational slideshow (15 s per slide) |
| Bottom | `http://localhost/split.html?left=<SDR>&right=<dashboard>` | Split iframes — KA9Q-Web SDR waterfall (left), PSWS Contesting DX Dashboard (right) |

Upstream URLs (configured in `kiosk/sites/uacnj/install.sh`):

- **PSWS Contesting DX Dashboard** — production: `https://uacnj.kd3ald.com`; home-LAN test: `http://192.168.11.202:5000/`
- **KA9Q-Web SDR waterfall** — production target: `http://vpn.hamsci.org:46005/radio.html` (currently blocked by RX888 hardware issue); home-LAN test: `http://192.168.11.202:8081/radio.html`
