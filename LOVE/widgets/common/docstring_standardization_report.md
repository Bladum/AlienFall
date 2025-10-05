# Docstring Standardization Report for `widgets/common`

This report recommends improvements and a phased plan to standardize file-level and
method-level docstrings for all widget modules under `LOVE/widgets/common` using the
`widgets/docstring_template.md` as the authoritative template.

Summary
-------
- Goal: Ensure every widget file and public method follows the project's docstring
  template (file-level header, constructor docstrings, method `@param`/`@return` tags,
  and private method annotations).
- Location: `LOVE/widgets/common`
- Deliverable: This report plus a follow-up set of patches that apply the template to
  each file incrementally.

Why this matters
-----------------
- Consistent documentation improves readability, onboarding, and modder friendliness.
- Explicit `@param`/`@return` annotations help editors and language servers provide
  better completions and diagnostics (e.g., `lua-language-server`).
- Identifying and removing accidental globals improves runtime safety in Love2D.

High-level recommendations
-------------------------
1. File-level docstring header
   - Every `*.lua` under `widgets/common` MUST start with a file-level docstring that
     includes the file path on the first line, a short description, PURPOSE and
     KEY FEATURES sections, and `@see` references where applicable. Follow
     `docstring_template.md` exactly for structure and tags.

2. Constructor docstrings
   - Add a documented `new` constructor for each widget with `@param` tags for each
     argument and `@return` describing the instance. Use the constructor template
     from `docstring_template.md`.

3. Method-level docstrings
   - For every public method, add a short description and `@param`/`@return` tags.
   - For internal/private methods prefix the description with `(private method)` and
     avoid exporting them in module tables when possible.

4. Type and optionality conventions
   - Use basic Lua types: `number`, `string`, `boolean`, `table`, `function`, `nil`.
   - Mark optional parameters by appending `|nil` (e.g., `@param options table|nil`).

5. Globals and module returns
   - Ensure `local` is used for all variables unless exposing API surface (module
     table or Love callbacks). Add a short `@module` tag in complex modules if
     helpful.

6. Small examples
   - Show one canonical example for a constructor and a method docstring near the
     top of this report (see "Examples" below).

Edge cases to watch for
-----------------------
- Files that `setmetatable` with `core.Base` — document the inheritance and any
  overridden methods.
- Modules that intentionally expose globals for Love callbacks (e.g., `main.lua`)
  should be explicitly documented in the header to avoid accidental global use.
- Large files mixing many widget classes — consider splitting into smaller modules.

Phased plan (practical)
-----------------------
Phase 0 — Prepare
  - Export this report to `LOVE/widgets/common` (done).
  - Configure a simple `.luacheckrc` and enable `lua-language-server` settings
    (phase 3 will add CI job).

Phase 1 — Automated audit
  - Run a repository scan for files under `LOVE/widgets/common`.
  - For each file produce an annotation: missing file header, missing constructor
    docstrings, methods without tags, accidental globals.
  - Save the audit output as `audit_annotations.json` in the same folder.

Phase 2 — Apply changes incrementally
  - Choose 2 low-risk widgets (e.g., `label.lua`, `button.lua`) and apply full
    template docstrings plus small code tidies (add `local` to globals, fix `setmetatable`).
  - Add unit/smoke harness to exercise these widgets in Love2D's headless mode
    or lightweight test runner.
  - Open a PR with these changes for review.

Phase 3 — Bulk update and CI
  - Apply standardized docstrings across remaining files in small commits (1 file
    per commit) to simplify review.
  - Add `luacheck` to `requirements.txt`-adjacent tooling and a CI job to run
    `luacheck` and a docs-check script that fails if a file header is missing.

Phase 4 — Ongoing maintenance
  - Add a contribution checklist entry reminding authors to include docstrings when
    adding new widgets.
  - Consider adding a simple pre-commit hook that checks for file headers.

Implementation suggestions & examples
-----------------------------------
1) File-level header example (for `label.lua`):

--[[
widgets/label.lua
Label widget (versatile text display with rich formatting and animation)

Displays text with formatting, wrapping and animations used across UI screens.

PURPOSE:
- Render text blocks with formatting for mission briefings and UI elements.
- Provide animation helpers for typewriter and fade effects.

KEY FEATURES:
- Word-wrapping, alignment, and icon embedding.
- Animation support (typewriter, fade)

@see widgets.common.core.Base
@see widgets.complex.animation
]]

2) Constructor example:

--- Creates a new Label widget for text display
--- @param x number The x-coordinate position
--- @param y number The y-coordinate position
--- @param w number The width of the label
--- @param h number The height of the label
--- @param options table|nil Optional configuration table for text, styling, etc.
--- @return Label A new label widget instance
function Label:new(x, y, w, h, options)
    -- implementation
end

3) Private method example:

--- Calculates internal layout for wrapped text (private method)
--- @param lines table Array of lines to layout
--- @return table Table with layout metrics
function Label:_calculateLayout(lines)
    -- implementation
end

Checklist for PRs
-----------------
- [ ] File-level docstring present and path matches file path.
- [ ] Constructors documented with `@param` and `@return`.
- [ ] Public methods documented with `@param`/`@return`.
- [ ] Private/internal methods marked as such in their description.
- [ ] No accidental globals introduced.

Next steps (immediate)
----------------------
1. Mark next todo (audit files) as `in-progress` and run an automated scan to
   generate `audit_annotations.json`.
2. Pick `label.lua` and `button.lua` as the two starter files for full refactor.

Contact
-------
If you'd like, I can run the automated audit now and produce `audit_annotations.json`
and then apply docstring edits to the two starter files. Tell me whether to proceed
with the audit now.

Report saved: `LOVE/widgets/common/docstring_standardization_report.md`
