# AI Usage Log — PSWS Kiosk

This log records all substantive AI-assisted sessions for the project
"PSWS Kiosk — HamSCI / Personal Space Weather Station public display system".

Required per University of Scranton AI Policy, HamSCI Generative AI Use Agreement, NASA AI guidance, NSF AI guidance, and applicable funder expectations (NSF, NASA, ARDC, Frankford Radio Club).

---

<!-- Append new entries below this line, newest at the bottom. Use the format produced by the /commit command. -->

## [2026-04-25 13:26 EDT]

- **Tool**: Claude (Anthropic), claude-opus-4-7
- **Session Purpose**: Fix invalid `$schema` URL in `.claude/settings.json` so Claude Code stops rejecting the file (caught while using a downstream project scaffolded from this template).
- **Sections/Files Affected**: `.claude/settings.json`
- **Nature of Contribution**: Bug fix
- **Human Review Status**: Reviewed and verified
- **Git Hash**: 839ee05

## [2026-04-25 13:31 EDT]

- **Tool**: Claude (Anthropic), claude-opus-4-7
- **Session Purpose**: Align template with the `.claude/` folder anatomy described in the Anatomy of the Claude Folder blog post — gitignore the personal-override file and scope language-specific rules to relevant file types so they don't load when not applicable.
- **Sections/Files Affected**: `.gitignore` (added `CLAUDE.local.md`), `.claude/rules/latex-writing.md` (added `paths:` frontmatter scoping to `.tex`/`.bib`/`.cls`/`.sty`), `.claude/rules/python-code.md` (added `paths:` frontmatter scoping to `.py`/`pyproject.toml`/`requirements*.txt`)
- **Nature of Contribution**: Configuration / scaffolding refinement
- **Human Review Status**: Reviewed and verified
- **Git Hash**: e229ba5

## [2026-05-03 04:53 EDT]

- **Tool**: Claude (Anthropic), claude-sonnet-4-6
- **Session Purpose**: Initialize psws_kiosk repository from template: fill in all {{placeholder}} fields in CLAUDE.md, README.md, ai/ai_usage_log.md, and ai-governance.md with project-specific content (PI, collaborators, funders, description); delete latex-writing.md; remove LaTeX entries from .gitignore; create kiosk/ and server/ directory stubs; refine project description using context from docs/psws_hf_receiver.docx.
- **Sections/Files Affected**: `CLAUDE.md`, `README.md`, `ai/ai_usage_log.md`, `.claude/rules/ai-governance.md`, `.claude/rules/latex-writing.md` (deleted), `.gitignore`, `kiosk/.gitkeep` (new), `server/.gitkeep` (new)
- **Nature of Contribution**: Repository scaffolding / configuration
- **Human Review Status**: Pending review
- **Git Hash**: 70f2069

## [2026-05-03 05:00 EDT]

- **Tool**: Claude (Anthropic), claude-sonnet-4-6
- **Session Purpose**: Set up MeshCentral remote management server on Linode (install, Let's Encrypt TLS, SSH hardening, fail2ban, unattended-upgrades, firewall); install kiosk base OS stack on BeeLink (Ubuntu 24.04, X11, Openbox, amdgpu driver for dual-monitor); create UACNJ site-specific install script and autostart; debug dual-monitor display — diagnosed modesetting driver single-CRTC limitation, switched to xserver-xorg-video-amdgpu, updated xrandr output names, corrected monitor-to-output assignment, fixed Y-offset derivation.
- **Sections/Files Affected**: `kiosk/base/install.sh`, `kiosk/sites/uacnj/install.sh`, `kiosk/sites/uacnj/README.md`, `docs/notes.md`, `server/config.json.example`
- **Nature of Contribution**: Code generation, system configuration, debugging
- **Human Review Status**: Reviewed and verified
- **Git Hash**: a895f65–6a0da5b

## [2026-05-03 12:52 EDT]

- **Tool**: Claude (Anthropic), claude-sonnet-4-6
- **Session Purpose**: Diagnosed and resolved dual-monitor kiosk issue: identified that snap Chromium on Ubuntu 24.04 silently ignores --user-data-dir (remapping all instances to the same snap-confined profile), preventing two independent kiosk windows. Switched to Google Chrome (.deb from Google's apt repo), updated kiosk/base/install.sh and kiosk/sites/uacnj/install.sh, and verified both monitors display separate URLs.
- **Sections/Files Affected**: `kiosk/base/install.sh`, `kiosk/sites/uacnj/install.sh`
- **Nature of Contribution**: Debugging, code generation
- **Human Review Status**: Reviewed and verified
- **Git Hash**: 186e070, 132528c
