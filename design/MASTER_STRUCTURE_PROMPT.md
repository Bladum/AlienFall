# Opus-ready master-structure prompt (final, uniqueness & semantic integrity)

Purpose (one line)
Produce a single canonical master skeleton (3–4 heading levels), a validated manifest (YAML), and a shell-style file list derived from NEW.md + OVERVIEW.md + all H1–H5 headers from design/mechanics/* — ensuring unique, non-duplicative structure that makes game-design sense.

High-level rules (must obey)

- Use NEW.md as primary source, OVERVIEW.md as secondary, then other mechanics headers.
- Output ONLY three fenced code blocks (in order): Markdown skeleton, manifest (YAML, valid), shell-style file list. Nothing else.
- No prose content besides one-line placeholders after each heading: `TODO: outline (source: <SOURCE>)`.
- Headings must be slugs (lowercase snake_case) and deterministically derived from original titles (see slug rules).
- Ensure a single canonical location for every concept (no duplicates) by semantic merging using title similarity and source priority.

Deterministic slug rules

- Normalize heading text:
  1. Trim, downcase.
  2. Remove diacritics (apply Unicode NFKD, then remove combining marks).
  3. Replace any non-alphanumeric with underscore.
  4. Collapse consecutive underscores.
  5. Trim leading/trailing underscores.
- The final slug MUST match regex `^[a-z0-9_]+$`.

- If two different headings map to the same slug after normalization, apply the following deterministic namespace rules in order:

  1. If headings have different canonical parents, use the code-style namespace: `<parent_slug>__<slug>`.
  2. If the collision is between two H1 headings (no parent), append the normalized source-filename slug as namespace: `<sourcefile_slug>__<slug>`.
  3. If a collision still remains, append a numeric suffix: `__2`, `__3`, ... using the lowest available integer.

- Keep slugs human-readable (prefer readable words over numeric-only names).

Filesystem mapping rules

- H1 → `design/mechanics/<slug>.md`
- H2 → `design/mechanics/<parent_slug>/<slug>.md`
- H3/H4 → file placed with H2 parent folder: `design/mechanics/<parent_slug>/<child_slug>.md`
- Max filesystem depth: `design/mechanics/<topic>/<subtopic>.md` (two segments under design/mechanics).
- If collisions occur, use the parent-prefixed filename rule above.

Semantic grouping & canonical parent selection

- Group headings into these primary H1 areas (prefer this order): geoscape, basescape, battlescape, units, items, missions, crafts, interception, ai, economy, research, manufacturing, damage_types, environment, gui, assets, analytics, tests, lore, politics, relations, black_market, glossary, integration, future.
- For headings that logically belong to multiple parents, pick canonical parent by:
  1. Presence in NEW.md under that parent.
  2. If ambiguous, use topical keyword matching (e.g., "radar" → geoscape; "facility" → basescape; "line_of_sight" → battlescape).
  3. If still ambiguous, prefer Battlescape > Basescape > Geoscape for combat-adjacent topics.
- Merge semantically duplicate headings (use string similarity / token overlap). When merging, record all original sources in manifest["sources"].

Priority assignment (auto)

- P0: battlescape, basescape, geoscape, units, damage_types, ai, economy, power, tests
- P1: interception, missions, research, manufacturing, hex_system, craft_operations
- P2: assets, analytics, gui, lore, relations, politics, black_market, integration
- P3: future, experimental, cosmetic, minor_docs
- Allow overriding only if heading originates in NEW.md and explicit priority tag exists there.

Manifest schema (each entry)
Manifest schema (top-level and entries)

- Top-level manifest MUST be a single YAML mapping with two keys:

  - `entries`: a sequence of entry mappings (the canonical manifest entries).
  - `validation_summary`: a mapping containing machine-checkable validation results.

- Each entry mapping has these fields (example in YAML):

```yaml
- slug: battlescape
  title: Battlescape
  file: design/mechanics/battlescape.md
  priority: P0
  source: NEW.md
  sources:
    - NEW.md
  children: []
  notes: |
    optional notes string
  related_to: []
```

- Example top-level manifest structure (YAML):

```yaml
entries:
  - slug: battlescape
    title: Battlescape
    file: design/mechanics/battlescape.md
    priority: P0
    source: NEW.md
    sources: [NEW.md]
    children: []
validation_summary:
  checks_passed: true
  issues: []
  h1_count: 14
  h2_count: 58
  slug_count: 72
```

Merging & conflict resolution

- If same semantic node appears in multiple sources:
  - Choose canonical title from NEW.md (if present), else OVERVIEW.md, else earliest mechanics file alphabetically.
  - Combine sources into entry["sources"] array.
  - Ensure canonical file path uses canonical parent as above.

- If two headings are near-duplicates but represent distinct subtleties, keep both but add manifest["notes"] indicating relation (e.g., "related_to":"other_slug").


Validation steps (agent must run and fix before returning)
Run validations in this order and populate `validation_summary` accordingly:

1. YAML parseability — manifest must be valid YAML (top-level mapping with `entries` sequence).

2. Slug uniqueness — all slugs in `entries` and their children must be unique (report duplicates and applied namespace fixes).

3. Heading-to-manifest mapping — every Markdown heading extracted from sources must have a matching manifest entry with identical slug and intended file path (report missing mappings).

4. File list match — the shell-style file list must exactly equal the set of `file` values in manifest[`entries`] (one per line).

5. Core counts & distribution — compute `h1_count`, `h2_count_total` and verify they are within target ranges (H1 target: ~12–20; H2 per H1 target: 3–6; H3 per H2 target: up to 6). Validation should WARN if outside a +/-25% tolerance and only FAIL if distribution is egregiously off.

6. P0 coverage — ensure P0 systems cover core gameplay and list missing P0 slugs if any.

7. Produce `validation_summary` with at least: `{ "checks_passed": bool, "issues": [], "h1_count": n, "h2_count": n, "slug_count": n }`.

Formatting & strict output

- Markdown heading lines must be exactly: `# <slug>`, `## <slug>`, `### <slug>`, `#### <slug>`.
- Immediately following each heading line: a placeholder line exactly: `TODO: outline (source: <SOURCE>)` where `<SOURCE>` is `NEW.md`/`OVERVIEW.md`/`<mechanics_filename>`.
- No extra lines between heading and placeholder.
- The manifest block must be the second fenced block and valid YAML (top-level mapping with `entries` and `validation_summary`). Include the `sources` sequence in each entry and populate `validation_summary`.
- The third block is shell-style file list (one path per line).

Design-sense heuristics (for Opus)

- Prefer vertical organization reflecting game layers first, then cross-cutting systems, then content/data, then tools/ops.
- Put tactical/combat topics into battlescape; base/management into basescape; world/strategic into geoscape.
- Keep items/weapons/armor under items or subfolders of items, but reference cross-links in manifest.
- Avoid splitting a single coherent subsystem across many top-level files—prefer grouping under a sensible H1 and then split into H2/H3.

Example (format only — the agent must replicate format)

Markdown (first fenced block):

```markdown
# battlescape
TODO: outline (source: NEW.md)
## combat_mechanics
TODO: outline (source: NEW.md)
### line_of_sight
TODO: outline (source: NEW.md)
```

YAML manifest (second fenced block):

```yaml
entries:
  - slug: battlescape
    title: Battlescape
    file: design/mechanics/battlescape.md
    priority: P0
    source: NEW.md
    sources: [NEW.md]
    children: []
validation_summary:
  checks_passed: true
  issues: []
```

Shell file list (third fenced block):

```text
design/mechanics/battlescape.md
design/mechanics/battlescape/combat_mechanics.md
design/mechanics/battlescape/line_of_sight.md
```

Operational notes for runner

- Provide NEW.md and OVERVIEW.md full texts and the list of H1–H5 headers extracted from the mechanics folder to Opus as input documents.
- After generation, run the validation steps; if any test fails, request an automatic re-run with the same prompt (Opus should self-correct).
- Use the manifest to create files; each file should begin with the single placeholder line from the Markdown skeleton.

Sources (authoritative)

- NEW.md (primary)
- OVERVIEW.md (secondary)
- design/mechanics/* (headers only)

End of prompt.
