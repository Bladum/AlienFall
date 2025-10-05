# Documentation Style Guide

> **Scope:** Applies to every page under `AF_WIKI/`. Use these rules when adding new docs or refactoring existing ones so contributors deliver consistent, Love2D-aligned guidance.

## Naming & Terminology
- **Project Name:** Always "AlienFall" (no space) when referring to the game. Use "Love2D" (capital L) for the engine.
- **Systems:** Proper-case primary systems (`Geoscape`, `Basescape`, `Battlescape`, `Interception`, `Economy`, `Finance`).
- **Files & Paths:** Wrap file or module names in backticks, e.g. `services/registry.lua`.
- **RNG Scopes:** Use lowercase namespaces (`campaign`, `director`, `mission`, `actor`).
- **Units:** Grid spacing is "20×20 logical pixels"; sprite sources are "10×10 art scaled ×2".

## Page Structure Template
Each wiki page should follow this outline unless a special format (e.g., data tables) is required.

```markdown
# <Title>

> **Purpose:** One sentence explaining what the document is for.

## Role in AlienFall
Brief description of how the system or topic interacts with the overall game.

## Player / Design Goals
Bullet list (3–5) highlighting intended player experience or design constraints.

## System Boundaries
Clarify inputs, outputs, dependencies, and exclusions.

## Mechanics / Implementation
Break down the core rules, algorithms, or patterns. Use subheadings as needed.

## Data & Events
- **Primary Catalogs:** Bullet list of TOML sources.
- **Services:** Which Lua modules consume them.
- **Events:** Namespaced events emitted/consumed.

## Integration Hooks
Call out cross-links to other docs, key services, or sequences. Reference the Integration Handbook when applicable.

## Tags
Backtick formatted tags on a single line, e.g. `#battlescape` `#grid20x20` `#love2d`
```

## Metadata & Front Matter
- Avoid YAML front matter unless the doc is consumed by external tooling. Prefer inline sections as shown above.
- When front matter is required (e.g., `widgets/` index pages), include at minimum `title`, `summary`, and `tags`, keeping tag strings aligned with the tag glossary below.

## Tag Glossary
Keep tags lowercase and kebab-case when multiword. Authoritative tags include:
- `#love2d`, `#determinism`, `#grid20x20`, `#modding`, `#events`
- System tags: `#geoscape`, `#basescape`, `#battlescape`, `#interception`, `#economy`, `#finance`, `#ai`, `#widgets`, `#gui`
- Cross-cutting: `#architecture`, `#services`, `#integration`, `#history`, `#data`
Add new tags only after checking for existing equivalents; update this list when new tags are accepted.

## Voice & Tone
- Use active voice and present tense.
- Keep sentences concise; prefer bullet lists over dense paragraphs for mechanics.
- Highlight deterministic requirements explicitly ("seeded by", "namespaced RNG").
- Call out Love2D-specific constraints rather than legacy engine notes.

## Cross-Linking Rules
- Link to sibling docs using relative paths (`../economy/README.md`).
- When referencing data catalogs or services, pair them with the module path: "See `economy/research_manager.lua`".
- Add breadcrumbs ("See also") when a doc has complementary specs.

## Diagrams & Tables
- Use Mermaid for sequence or flow diagrams; ensure node titles match code/service names.
- Tables should include concise columns; wrap long identifiers in backticks.
- Include diagram captions when the intent is not obvious.

## Review Checklist
Before merging a documentation change:
- [ ] Page follows the structure template or justifies deviations.
- [ ] Tags are present and listed in the final section.
- [ ] Cross-links resolve and use relative paths.
- [ ] Legacy terminology (Qt, PySide6, YAML-first) is absent unless discussing history.
- [ ] Event names and payload fields match `integration/README.md`.

## Maintenance
- Update this guide whenever structural conventions change.
- Reference it in PR descriptions for documentation-heavy updates.
- Run lint tooling (planned) to enforce tag and heading conventions.

Tags: `#documentation` `#style` `#love2d`
