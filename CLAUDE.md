# PSWS Kiosk

## Project Overview

This repository builds and manages a public-display kiosk system for the HamSCI Personal Space Weather Station (PSWS) HF Receiver deployed at the United Astronomy Clubs of New Jersey (UACNJ) public observatory museum, with the architecture designed to scale to additional outreach venues. Each kiosk is a BeeLink mini PC running Ubuntu 24.04 LTS with two stacked 22" monitors in fullscreen Google Chrome: the top monitor runs an auto-advancing educational slideshow that explains what visitors are seeing, and the bottom monitor shows a split view of the KA9Q-Web SDR waterfall (left) and the PSWS Contesting DX Dashboard (right). All on-screen content (slideshow + split iframe page) is served from a local nginx on the kiosk itself.

**PI**: Nathaniel A. Frissell, W2NAF — University of Scranton
**Collaborators**: University of Scranton, New Jersey Institute of Technology, University of Alabama, Case Western Reserve University, Dartmouth College, MIT Haystack Observatory, and others; TAPR, Frankford Radio Club, United Astronomy Clubs of New Jersey (UACNJ), and community volunteers
**Funder**: NSF AGS-2045755, AGS-2432821, AGS-2432822, AGS-2432824, AGS-2432823, AGS-2431666, OPP-2332427; NASA 80NSSC23K1322, 80NSSC25K7026, 80NSSC26K0051; Frankford Radio Club; ARDC
**Project period**: Ongoing

## Project Goal

Build a portable, site-agnostic kiosk platform that displays live HamSCI ionospheric data at science outreach venues. The design separates shared base configuration from per-site overrides so that deploying to a new location requires only a new site config — not a new build. The first deployment is at the UACNJ public observatory.

## Repository Structure

```text
psws_kiosk/
├── CLAUDE.md
├── README.md
├── .gitignore
├── .claude/
│   ├── settings.json
│   ├── commands/commit.md        ← /commit workflow
│   └── rules/
│       ├── ai-governance.md
│       └── python-code.md
├── ai/
│   └── ai_usage_log.md           ← mandatory AI session log
├── docs/
│   └── hamsci-kiosk-project.md   ← architecture decisions and build plans
├── kiosk/
│   ├── base/
│   │   ├── install.sh            ← shared OS setup (Chrome, nginx, x11vnc, Openbox, etc.)
│   │   └── www/split.html        ← generic split-iframe page (URLs via query string)
│   └── sites/
│       └── uacnj/
│           ├── install.sh        ← per-site config (display layout, URLs, autostart)
│           ├── README.md         ← site description + monitor info
│           └── www/
│               ├── slides.html   ← UACNJ-specific educational slideshow
│               └── img/          ← HamSCI banner + partner-institution logos
```

## AI Governance

All AI-assisted work must comply with the policies in `.claude/rules/ai-governance.md`.
Every substantive AI session must be logged in `ai/ai_usage_log.md` before committing.
Use the `/commit` command to handle logging and committing in the correct order.
