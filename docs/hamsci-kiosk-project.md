# HamSCI Observatory Kiosk Project

Project briefing capturing decisions and plans from prior conversation. Intended as Claude Code context for the build phase.

## Goal

Build a kiosk display system for a public observatory museum (UACNJ context) that shows HamSCI / WSPR ionospheric data, plus set up centralized remote management for this kiosk and future ones.

## Hardware

- **Kiosk**: BeeLink mini PC, currently running Windows 11 Home (will be replaced with Linux)
- **Displays**: 2× 22" monitors, stacked vertically (top + bottom)
- **Touchscreen**: not yet confirmed — affects lockdown details if yes
- **Future**: additional similar kiosks expected; build should be cloneable

## Content

Two web URLs displayed fullscreen, one per monitor:

- **Top monitor**: `https://uacnj.kd3ald.com` — WSPR Map + Table dashboard (UACNJ Personal Space Weather Station data)
- **Bottom monitor**: `http://vpn.hamsci.org:46005/radio.html` — HamSCI radio waterfall/spectrum display

Note: hostname starts with `vpn.` but per project owner (HamSCI admin), this URL is intended to be used without VPN. **Verify public reachability from a non-HamSCI network before finalizing.** If not public, plan needs WireGuard client on each kiosk.

## Architecture (final, post-discussion)

```
                  Internet
                     │
       ┌─────────────┼──────────────┐
       │             │              │
   Kiosk 1       Kiosk 2        Kiosk N
       │             │              │
       └──→ uacnj.kd3ald.com         (public web, top display)
       └──→ vpn.hamsci.org:46005/radio.html  (public web, bottom display)
       └──→ meshcentral.hamsci.org:443       (MeshCentral agent, outbound)
```

**No VPN on kiosks.** No WireGuard. Pure public internet to all three endpoints. MeshCentral and HamSCI VPN infrastructure are kept fully isolated to limit blast radius during this experimental phase.

## Decisions made

| Question | Decision | Rationale |
|---|---|---|
| Remote access tool | MeshCentral | Self-hosted RMM, monitoring + support of fleet, no commercial-license issues, web-based, open source |
| Server hosting | New dedicated Linode (`meshcentral.hamsci.org`) | Isolation from existing HamSCI infra during experimental phase |
| OS for kiosks | Debian 12 minimal (Linux, not Windows 11 Home) | No Pro license cost, lower resource usage, no nag screens, kiosk patterns well-trodden, owner is Linux-comfortable |
| Window manager | Openbox | Lightweight, no DE bloat |
| Browser | Chromium in `--kiosk` mode | Standard, multi-instance with separate user-data-dirs |
| Display server | X11 (not Wayland) | Better tooling for multi-monitor + xinput touch + xrandr |
| VPN integration | None on kiosks; MeshCentral server not on HamSCI VPN | Keep failure domains separate during build-out |
| Updates | `unattended-upgrades` for security only, nightly reboot via cron picks up kernel updates |

## Server build plan: `meshcentral.hamsci.org`

### Linode sizing

- **Nanode (1 GB RAM, ~$5/mo)** is sufficient for dozens of agents.
- Bump to 2 GB tier (~$12/mo) if planning to co-host other HamSCI services later.

### Steps

1. Provision Linode, point `meshcentral.hamsci.org` DNS A record at it (public DNS, not internal).
2. Lock down SSH:
   - Key-only auth: `PasswordAuthentication no`, `PermitRootLogin prohibit-password`
   - Non-default port (optional, mostly cuts log noise)
   - Linode Cloud Firewall: 22 allowlisted to admin IP(s); 80/443 world-open
   - Fail2ban as backstop
3. Install Node.js + MeshCentral per official docs.
4. Configure `config.json`:
   - Cert via Let's Encrypt (MeshCentral handles natively)
   - Enable email alerts for device offline events
   - Set up device groups in advance (e.g., per exhibit area, or "public-facing kiosks" vs. staff)
5. Enable 2FA on every admin account.
6. Configure `unattended-upgrades` (no auto-reboot).
7. Set up backup of `meshcentral-data/` directory + `config.json`. Store **outside** HamSCI infrastructure for failure-domain independence.
8. Document the isolation from HamSCI VPN explicitly in runbook so future maintainers don't re-couple them inadvertently.

## Kiosk build plan: Debian 12

### Base install

- Debian 12 netinst, no desktop environment, SSH server only.
- Single unprivileged user: `kiosk`.

### Minimal graphical stack

```bash
apt install --no-install-recommends \
  xserver-xorg x11-xserver-utils xinit \
  openbox unclutter chromium
```

Add `pipewire pipewire-pulse` if `radio.html` plays audio.

### Auto-login to TTY

`/etc/systemd/system/getty@tty1.service.d/override.conf`:

```ini
[Service]
ExecStart=
ExecStart=-/sbin/agetty --autologin kiosk --noclear %I $TERM
```

### Auto-start X on login

`~/.bash_profile`:

```bash
if [ -z "$DISPLAY" ] && [ "$(tty)" = "/dev/tty1" ]; then
  exec startx
fi
```

### Openbox autostart

`~/.config/openbox/autostart`:

```bash
# Display arrangement — adjust output names from `xrandr` output
xrandr --output HDMI-1 --mode 1920x1080 --pos 0x0 \
       --output HDMI-2 --mode 1920x1080 --pos 0x1080

# Kiosk hygiene
xset s off -dpms
xset s noblank
unclutter -idle 0.5 -root &

# Top monitor — WSPR map/table
chromium --kiosk --noerrdialogs --disable-infobars \
  --window-position=0,0 --window-size=1920,1080 \
  --user-data-dir=/home/kiosk/.chromium-top \
  https://uacnj.kd3ald.com &

# Bottom monitor — HamSCI radio waterfall
chromium --kiosk --noerrdialogs --disable-infobars \
  --window-position=0,1080 --window-size=1920,1080 \
  --user-data-dir=/home/kiosk/.chromium-bottom \
  http://vpn.hamsci.org:46005/radio.html &
```

**Important**: separate `--user-data-dir` per Chromium instance. Otherwise the second instance opens as a tab in the first.

Adjust resolutions to actual display specs.

### Watchdog

Wrap each chromium launch in `while true; do ...; sleep 5; done`, OR (cleaner) define a per-instance systemd user service. Systemd approach preferred.

### Periodic refresh

Nightly reboot via root cron (`0 4 * * * /sbin/reboot`). Cleaner than userscript injection; also picks up unattended-upgrades kernel updates.

### MeshCentral agent

Generated `.deb` from the MeshCentral server, install with `dpkg -i`. Runs as system service, survives reboots.

### Touchscreen (if applicable)

- `xinput map-to-output <touch-device-id> <monitor-output>` per touch device, in autostart
- Add `--touch-events=enabled` to Chromium flags
- Suppress right-click context menus and pinch zoom via Chromium flags / userscript

## Open questions / next steps

- [ ] **Verify `vpn.hamsci.org:46005/radio.html` reachable from public internet** (test from cellular hotspot or unrelated VPS).
- [ ] Confirm BeeLink model + Linux compatibility (Wi-Fi/audio chipset). Use Ethernet regardless for kiosks.
- [ ] Confirm whether displays are touchscreens. Affects lockdown plan.
- [ ] Decide deployment workflow for cloning to additional kiosks (Clonezilla image vs. Ansible playbook from a base Debian).
- [ ] Decide Linode tier (Nanode vs 2 GB) based on whether other HamSCI services will co-host.
- [ ] Build runbook documenting the deliberate isolation between MeshCentral Linode and HamSCI VPN infra.

## Future considerations (not blocking)

- If kiosk count grows past ~10, evaluate **Tactical RMM** (built on MeshCentral, adds alerting, scheduled scripts, patch management).
- After MeshCentral has earned its keep, consider whether to put `meshcentral.hamsci.org` itself on the HamSCI VPN as a peer for management-plane access (still keeping MeshCentral's public 443 for agents). Not now.
- Image the first working kiosk before deploying more — `dd` of the SSD or Clonezilla — for fast bring-up of subsequent units.

## Notes

- All conversational rationale and trade-off discussion has been condensed to decisions in this document. Earlier conversation explored AnyDesk, RustDesk, Parsec, TeamViewer, Splashtop before settling on MeshCentral, and explored Windows 11 Pro upgrade vs Linux before settling on Debian.
