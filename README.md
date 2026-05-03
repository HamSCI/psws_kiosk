# PSWS Kiosk

A portable, site-agnostic kiosk platform for displaying live [HamSCI Personal Space Weather Station (PSWS)](https://hamsci.org/psws) data at science outreach venues. The design separates shared base configuration from per-site overrides so that deploying to a new location requires only a new site config. The first deployment is at the United Astronomy Clubs of New Jersey (UACNJ) public observatory museum.

## What it does

Each kiosk is a BeeLink mini PC running Debian 12 with two stacked 22" monitors:

- **Top monitor** — PSWS Contesting DX Dashboard: live WSPR/FT8 multi-band spots (`https://uacnj.kd3ald.com`)
- **Bottom monitor** — KA9Q-Web SDR: real-time 0.1–64 MHz HF spectrum waterfall (`http://vpn.hamsci.org:46005/radio.html`)

Chromium runs in `--kiosk` mode with Openbox as the window manager. The system auto-starts on boot, restarts browser instances on crash, and reboots nightly to pick up security updates.

A self-hosted [MeshCentral](https://meshcentral.com/) server at `meshcentral.hamsci.org` provides centralized remote access and monitoring for all kiosks.

## Repository layout

| Path | Contents |
| ---- | -------- |
| `kiosk/base/` | Shared install scripts, systemd unit templates, Openbox config |
| `kiosk/sites/<name>/` | Per-site config: display URLs, xrandr layout, hostname |
| `server/` | MeshCentral server setup, `config.json` template, runbook |
| `docs/` | Architecture decisions, hardware notes, open questions |
| `ai/` | AI usage log (required per HamSCI/Scranton/NSF/NASA AI policies) |

## Acknowledgements

HamSCI collaborators gratefully acknowledge funding from NSF AGS-2045755, AGS-2432821, AGS-2432822, AGS-2432824, AGS-2432823, AGS-2431666, OPP-2332427; NASA grants 80NSSC23K1322, 80NSSC25K7026, and 80NSSC26K0051; Frankford Radio Club; and ARDC.
