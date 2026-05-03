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

## [2026-05-03 13:39 EDT]

- **Tool**: Claude (Anthropic), claude-sonnet-4-6
- **Session Purpose**: Install and configure MeshCentral agent on the UACNJ kiosk for remote management; debug and resolve remote desktop (WebVNC) failure — identified that the AMD GPU does not update /dev/fb0 while X11 is active, making the agent's built-in screen capture unusable; installed x11vnc as the screen capture backend, added it to the Openbox autostart, and verified live dual-monitor view via SSH tunnel to localhost:5900.
- **Sections/Files Affected**: `kiosk/sites/uacnj/install.sh` (x11vnc in autostart, meshagent interactive agent attempts removed)
- **Nature of Contribution**: Debugging, system configuration, code generation
- **Human Review Status**: Reviewed and verified
- **Git Hash**: d9bc960

## [2026-05-03 14:10 EDT]

- **Tool**: Claude (Anthropic), claude-sonnet-4-6
- **Session Purpose**: Clarified that vpn.hamsci.org:46005 is unreachable due to an RX888 hardware fault (not a firewall/routing issue); updated open question in docs/notes.md and TODO comment in install.sh accordingly. Switched test URLs to the home LAN PSWS system (dashboard at 192.168.11.202:5000, WebSDR waterfall at 192.168.11.202:8081) for realistic end-to-end testing before the UACNJ site visit.
- **Sections/Files Affected**: `kiosk/sites/uacnj/install.sh` (URL_TOP, URL_BOTTOM, comments), `docs/notes.md` (open question updated)
- **Nature of Contribution**: Configuration, documentation
- **Human Review Status**: Reviewed and verified
- **Git Hash**: 9ffc089

## [2026-05-03 16:58 EDT]

- **Tool**: Claude (Anthropic), claude-sonnet-4-6
- **Session Purpose**: Built the educational slideshow and split-screen layout for the kiosk using local nginx. Drafted slide content (welcome → ionosphere → screen explanations → why it matters → HamSCI/UACNJ → acknowledgments → partners). Swapped display assignments so live data is on the top monitor and the slideshow on the bottom. Bumped slide text size +30%. Extracted HamSCI branding assets from docs/uacnj_kiosk_slides.pptx (banner image, partner university logos, funder logos), pinned the HamSCI banner across the bottom of every slide to match the PPTX slide master, replaced the text-only partner-institutions slide with a real logo grid, and added a funder logo strip on the acknowledgments slide. Fixed the banner-repeats-the-logo problem by anchoring the image once on the left and filling the rest with a CSS linear-gradient sampled to match the banner's right-edge colors.
- **Sections/Files Affected**: `kiosk/base/install.sh` (nginx, x11vnc), `kiosk/base/www/split.html` (new), `kiosk/sites/uacnj/install.sh` (deploy www, swap displays, build split URL with python urlencode), `kiosk/sites/uacnj/www/slides.html` (new slideshow), `kiosk/sites/uacnj/www/img/*` (15 logo/banner assets extracted from PPTX)
- **Nature of Contribution**: Code generation, design, asset extraction, debugging
- **Human Review Status**: Reviewed and verified
- **Git Hash**: 0ba1d2a, 4118720, 38ae62d, 7b3c7ae, b5207ed

## [2026-05-03 17:43 EDT]

- **Tool**: Claude (Anthropic), claude-sonnet-4-6
- **Session Purpose**: Made the kiosk's virtual monitor layout match the physical (stacked) layout via /etc/X11/xorg.conf.d Monitor sections, avoiding the runtime-xrandr signal-loss bug. Adjusted for new symmetric FHD test setup (HDMI=bottom, DP=top, both 1920×1080) so there's no width mismatch or dead zone, which also fixed a cursor-wraparound symptom. Swapped Chrome window assignments so the educational slideshow is on the top monitor and the live data (SDR + dashboard split) is on the bottom; updated slide text from "screen above" → "screen below" to match. Iterated on slideshow typography (130% → 160% → 200% body, with hero/title shrunk so the welcome slide fits), removed the corner site-label, reordered the partner-institutions logo grid (Scranton, then NJIT, then the rest), and dropped the trailing "Visit hamsci.org" line on slide 6 that was getting cut off. Off-repo: set up uacnj-kiosk.hamsci.org as a 301 redirect to the MeshCentral sharing URL — created a dedicated Apache vhost (rather than touching the Drupal hamsci.org config) and obtained a Let's Encrypt cert so <https://uacnj-kiosk.hamsci.org> also works.
- **Sections/Files Affected**: `kiosk/sites/uacnj/install.sh` (xorg.conf monitor layout, FHD resolutions, swapped Chrome windows), `kiosk/sites/uacnj/www/slides.html` (text size iterations, "screen below" wording, removed site-label divs and CSS, reordered partner logos, removed trailing hamsci.org line), `CLAUDE.md` (matching collaborator order)
- **Off-repo changes**: New Apache vhost `/etc/apache2/sites-available/003-uacnj-kiosk.hamsci.org.conf` on hamsci.org server with `Redirect 301` to MeshCentral sharing URL; certbot-issued cert at `/etc/letsencrypt/live/uacnj-kiosk.hamsci.org/`
- **Nature of Contribution**: Configuration, CSS/HTML iteration, system administration
- **Human Review Status**: Reviewed and verified
- **Git Hash**: 0a10948, 730d2f5, c516029, 61375a1, 191b30c, 6f75031, 5845f29, dc3f7e8, 7f75a7a, 463d91b

## [2026-05-03 18:57 EDT]

- **Tool**: Claude (Anthropic), claude-sonnet-4-6
- **Session Purpose**: Iterated on slide content based on review feedback. Toned down the overstated "this data helps keep astronauts safe" line on slide 5 to a more honest "helps researchers better understand how the ionosphere responds to space weather." Updated slide 6 to credit both University of Scranton AND New Jersey Institute of Technology as the HamSCI team home institutions. On slide 8, moved Space Science Institute from "Community & Industry Partners" to "Universities & Research Institutes" (right after Case Western), then reorganized the universities grid into 4 columns × 2 rows so logos are larger; shortened cell aspect ratio (3:2 → 5:2) so everything fits the slide. On slide 7 (Acknowledgments), dropped the individual-name dashboard credits paragraph, and removed ARRL and DX Engineering from the funder strip (they're community partners, not funders, and already appear on slide 8). Added the UACNJ logo as the first community partner on slide 8 (logo fetched from uacnj.org).
- **Sections/Files Affected**: `kiosk/sites/uacnj/www/slides.html` (slides 5, 6, 7, 8 text and logo grid layout), `kiosk/sites/uacnj/www/img/uacnj.png` (new asset)
- **Nature of Contribution**: Content editing, layout iteration, asset acquisition
- **Human Review Status**: Reviewed and verified
- **Git Hash**: 642bcb9, 9fc6ea8, 0de8292, 6150b8b, ed2e559, 3869e80, 8f913e8

## [2026-05-03 19:11 EDT]

- **Tool**: Claude (Anthropic), claude-sonnet-4-6
- **Session Purpose**: Cleaned up the UACNJ logo (the version on uacnj.org rendered too faint/grayscale on the dark slide background) by running it through ImageMagick's threshold filter at 85% to produce a crisp pure-black-and-white version with legible text around the ring. Also tightened slide 7 (Acknowledgments): removed Frankford Radio Club from the funder strip since it's already a community partner on slide 8, and enlarged the remaining funder logos (NSF, NASA, ARDC) significantly — bumped max dimensions and gave each img `flex: 1` so they share the strip's full width instead of leaving large horizontal gaps.
- **Sections/Files Affected**: `kiosk/sites/uacnj/www/img/uacnj.png` (B&W threshold), `kiosk/sites/uacnj/www/slides.html` (slide 7 funder strip cleanup + sizing)
- **Nature of Contribution**: Image processing, layout polish
- **Human Review Status**: Reviewed and verified
- **Git Hash**: 7da3d4a, 91c9c6d, f94f00b
