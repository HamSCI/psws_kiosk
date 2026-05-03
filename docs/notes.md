# Project Notes

Design decisions, open questions, and session notes for the psws_kiosk project.

---

## Architecture

- **No VPN on kiosks.** All three endpoints (WSPR dashboard, KA9Q-Web SDR, MeshCentral) are reached over public internet. MeshCentral server is kept off the HamSCI VPN to limit blast radius during the experimental phase.
- **MeshCentral on a dedicated Linode** (`meshcentral.hamsci.org`), not co-hosted with existing HamSCI infrastructure.
- **X11 over Wayland** — better tooling for multi-monitor xrandr config and xinput touch mapping.
- **Openbox over a full DE** — no desktop environment bloat; kiosk only needs to launch two browser windows.
- **Separate `--user-data-dir` per Chromium instance** — required; second instance otherwise opens as a tab in the first.
- **Portable site design** — shared base config in `kiosk/base/`, per-site overrides in `kiosk/sites/<name>/`. Deploying to a new venue requires only a new site config.

## Secrets / Credentials

Actual credentials, SSH keys, and private runbooks live in the private companion repo:
**[HamSCI/psws_kiosk-ops](https://github.com/HamSCI/psws_kiosk-ops)** (restricted to project admins).

The public repo holds `.example` config templates; real values go in the ops repo.

## Open Questions

- [ ] Verify `vpn.hamsci.org:46005/radio.html` is reachable from public internet (test from cellular or unrelated VPS).
- [ ] Confirm BeeLink model and Linux hardware compatibility (Wi-Fi/audio chipset). Use Ethernet for kiosks regardless.
- [ ] Confirm whether UACNJ displays are touchscreens — affects Chromium flags and xinput mapping.
- [ ] Determine actual xrandr output names on the installed hardware before finalizing autostart.
- [ ] Decide Linode tier: Nanode (1 GB, ~$5/mo) vs. 2 GB (~$12/mo) — upgrade if other HamSCI services will co-host.
- [ ] Choose deployment workflow for cloning to additional kiosks: Clonezilla image vs. Ansible playbook from base Ubuntu.

## Display URLs (UACNJ)

| Monitor | URL | Content |
| ------- | --- | ------- |
| Top | `https://uacnj.kd3ald.com` | PSWS Contesting DX Dashboard (WSPR/FT8 multi-band spots) |
| Bottom | `http://vpn.hamsci.org:46005/radio.html` | KA9Q-Web SDR — 0.1–64 MHz HF spectrum waterfall |
