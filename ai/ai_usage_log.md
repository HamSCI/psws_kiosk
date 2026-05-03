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
- **Git Hash**: TBD
