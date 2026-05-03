# Secrets Inventory

This file lists every secret used by the project — what it is, what it's for, and where the real value is stored. **No actual credentials belong in this file or anywhere else in the repository.**

Real values are stored in: *(fill in — e.g., KeePass vault, Bitwarden, shared via Signal with admins)*

---

## MeshCentral Server (`meshcentral.hamsci.org`)

| Secret | Purpose | Where stored |
| ------ | ------- | ------------ |
| MeshCentral admin password | Web UI login | — |
| SMTP credentials | Offline-device alert emails | — |
| Let's Encrypt account key | TLS certificate renewal | auto-managed by MeshCentral, lives in `meshcentral-data/` on server |
| SSH private key (admin → server) | Remote server administration | — |

See `server/config.json.example` for the MeshCentral config structure.

## Kiosks

| Secret | Purpose | Where stored |
| ------ | ------- | ------------ |
| SSH private key (admin → kiosk) | Remote kiosk access via MeshCentral or direct SSH | — |

## Per-Site Credentials

None currently. Add rows here if a site's display URLs require authentication.

---

## Pattern for new secrets

1. Add the real value to the shared credential store above.
2. Add a row to this inventory.
3. If the secret lives in a config file, add a `.example` version of that file to the repo with placeholder values, and add the real filename to `.gitignore`.
