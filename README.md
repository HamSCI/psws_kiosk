# PSWS Kiosk

A portable, site-agnostic kiosk platform for displaying live [HamSCI Personal Space Weather Station (PSWS)](https://hamsci.org/psws) data at science outreach venues. The design separates shared base configuration from per-site overrides so that deploying to a new location requires only a new site config. The first deployment is at the United Astronomy Clubs of New Jersey (UACNJ) public observatory museum.

## What it does

Each kiosk is a BeeLink mini PC running Ubuntu 24.04 LTS with two stacked 22″ FHD (1920×1080) monitors:

- **Top monitor** — auto-advancing educational slideshow that explains what visitors are seeing (the ionosphere, WSPR/FT8 spots, the SDR waterfall, HamSCI's mission, partners, and funders).
- **Bottom monitor** — split view: the KA9Q-Web SDR waterfall on the left (real-time 0–30 MHz spectrum) and the PSWS Contesting DX Dashboard on the right (live WSPR/FT8 multi-band spot map).

All on-screen content is served from a local **nginx** on the kiosk itself, so the displays stay independent of any single upstream URL's iframe policy or transient network issues. Two **Google Chrome** windows run in `--kiosk` mode (each with its own `--user-data-dir`) under **Openbox**; `x11vnc` runs on `localhost` for live screen viewing via SSH tunnel.

The system auto-starts on boot, restarts browser instances on crash, and reboots nightly at 04:00 UTC to pick up security updates.

## Repository layout

| Path | Contents |
| ---- | -------- |
| `kiosk/base/install.sh` | Shared OS setup — Chrome, nginx, x11vnc, Openbox, AMD GPU driver, auto-login, nightly reboot |
| `kiosk/base/www/split.html` | Generic split-iframe page (URLs supplied via query string) |
| `kiosk/sites/<name>/install.sh` | Per-site config: display layout, URLs, Openbox autostart, xorg.conf monitor positions |
| `kiosk/sites/<name>/www/slides.html` | Site-specific educational slideshow |
| `kiosk/sites/<name>/www/img/` | Banner and partner-institution logos used by the slideshow |
| `docs/` | Architecture decisions, hardware notes, open questions |
| `ai/` | AI usage log (required per HamSCI/Scranton/NSF/NASA AI policies) |

## Deployment & updates

### Provisioning a new kiosk (from scratch)

1. Install Ubuntu 24.04 LTS Server (minimal). Use Ethernet; Wi-Fi/audio chipset support varies on BeeLink hardware.
2. Clone this repo as the `hamsci` (or admin) user: `git clone https://github.com/HamSCI/psws_kiosk.git ~/psws_kiosk`
3. Run the base install: `sudo bash ~/psws_kiosk/kiosk/base/install.sh`
4. Boot with both monitors connected and run `xrandr` (as the `kiosk` user) to confirm the actual output names and resolutions on the hardware.
5. If needed, edit `kiosk/sites/<name>/install.sh` so `DISPLAY_TOP`, `DISPLAY_BOTTOM`, `RES_TOP`, `RES_BOTTOM` match the `xrandr` output.
6. Run the site install: `sudo bash ~/psws_kiosk/kiosk/sites/<name>/install.sh`
7. Reboot. The kiosk should auto-login, start X, run Openbox, and bring up two Chrome windows.

### Updating slideshow content

1. Edit `kiosk/sites/<name>/www/slides.html` (or images under `www/img/`) on your dev machine.
2. Commit and push to GitHub.
3. On the kiosk: `git -C ~/psws_kiosk pull && sudo bash ~/psws_kiosk/kiosk/sites/<name>/install.sh`
4. Restart the slideshow Chrome window so it loads the new HTML: `sudo pkill -u kiosk -f 'chrome.*chrome-top'` (the while loop in the autostart will relaunch it after ~5 s). For URL or autostart changes, reboot instead so the new autostart fully takes effect.

### Remote access

- **SSH** — directly via the kiosk's hostname (e.g. `ssh hamsci@uacnj-kiosk`).
- **Live screen** — open an SSH tunnel and connect any VNC client to `localhost:5900`:
  `ssh -L 5900:localhost:5900 hamsci@<kiosk-host>`

## Acknowledgements

HamSCI collaborators gratefully acknowledge funding from NSF AGS-2045755, AGS-2432821, AGS-2432822, AGS-2432824, AGS-2432823, AGS-2431666, OPP-2332427; NASA grants 80NSSC23K1322, 80NSSC25K7026, and 80NSSC26K0051; Frankford Radio Club; and ARDC.

## License

This repository is released under the [MIT License](LICENSE).

**Logos and trademarks are not covered by the MIT License.** The partner-institution and funder logos under [`kiosk/sites/uacnj/www/img/`](kiosk/sites/uacnj/www/img/) — including the HamSCI banner, the University of Scranton, NJIT, University of Alabama, Case Western Reserve, Dartmouth, MIT Haystack Observatory, Space Science Institute, TAPR, ARRL, DX Engineering, Frankford Radio Club, UACNJ, NSF, NASA, and ARDC — are the trademarks and property of their respective owners. They are included here for attribution and identification only. Anyone forking or reusing this project for a different venue should remove or replace these assets as appropriate.

## AI disclosure

This repository was created with assistance from [Claude](https://claude.ai/) (Anthropic). AI was used for code generation, debugging, configuration, content drafting, and documentation. All AI-assisted work has been reviewed by a human contributor and is logged in [`ai/ai_usage_log.md`](ai/ai_usage_log.md) per the AI governance policy in [`.claude/rules/ai-governance.md`](.claude/rules/ai-governance.md), which aligns with the AI policies of the University of Scranton, HamSCI, NSF, and NASA.
