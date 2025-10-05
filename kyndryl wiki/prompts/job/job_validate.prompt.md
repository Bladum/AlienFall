Title: BIS job YAML validation prompt

Purpose: Use this prompt when you want an AI agent to validate a workspace job YAML against the annotated API documentation at `wiki/BIS API.yml`. The agent should only read files, perform non-destructive SQL checks (EXPLAIN/PREPARE), and return a structured validation report.

Inputs (to provide to the agent):
- `job_path`: Path to the job YAML to validate (e.g., `workspace/BALLUFF/balluff.yml`).
- `api_doc_path`: Path to the annotated API doc (default: `wiki/BIS API.yml`).
- `workspace_root`: Root folder for resolving relative file references (default: repository root).

Validation goals (high level):
1. Structural: Ensure required keys are present and types match the API annotations (meta, indicators, tables, formats, pipelines, etc.).
2. Referential: Confirm referenced files (e.g., `sql_ref_file`, `format_ref_file`, `gfx_ref_file`) exist and are readable relative to `workspace_root`.
3. Schema/contract: Check that referenced format/rule/styler names exist in `formats_class`, `rules_class`, and `stylers` where applicable.
4. SQL safety/syntax: For any `sql_code` or external SQL file, run a non-destructive DuckDB check: `EXPLAIN` or `PREPARE` the query in a sandboxed DuckDB instance (do not execute DML/DDL that mutates data).
5. Anchors/merge: Expand YAML anchors/aliases locally and validate the merged result.
6. Produce a concise, actionable report grouped by category (structural, referential, SQL) with severity levels and exact file/line pointers when available.

Agent instructions (copy/paste to the AI agent):

--- BEGIN PROMPT ---
You are an assistant that validates BIS workspace job YAML files against the annotated API doc at `wiki/BIS API.yml`.
Inputs you will be given:
- `job_path`: absolute or repo-relative path to the job YAML to validate.
- `api_doc_path`: path to `wiki/BIS API.yml` (defaults to `wiki/BIS API.yml`).
- `workspace_root`: base folder for resolving file references (defaults to repository root).

Step-by-step validation procedure:
1) Load and parse `api_doc_path` as YAML. Read the comment annotations (Type/Purpose) to infer expected keys and types. Treat the comments as authoritative documentation only — do not modify the API doc.
2) Load and parse `job_path` as YAML, preserving anchors and aliases. Expand all in-document anchors/aliases to produce a fully merged representation of the job for validation.
3) Structural checks:
   - For each top-level section present in the job (indicators, tables, pipelines, workspace, formats, charts, stylers, actions, symptoms, macros, practices), check required sub-keys using the API field catalog. Report missing required keys and type mismatches. Use the comment Type hints (string/int/bool/list/mapping/SQL) to validate types.
   - For lists of mappings (e.g., `pipelines.<name>.steps`, `charts.<name>.series`), validate presence of `id`, `type`, and expected typed fields.
4) Referential checks:
   - For every field ending with `_ref_file` or named `format_ref_file`, `gfx_ref_file`, `sql_ref_file`, resolve path relative to `workspace_root` and check existence and readability. If the reference is missing, mark as referential error.
   - For every named format/rule/styler reference (e.g., `format`, `rules`, `default_styler`), confirm the name exists in `api_doc_path` under `formats_class`, `rules_class`, `stylers`, or `workspace.formats`.
5) SQL checks (safe mode only):
   - For every `sql_ref_file` that exists, read the SQL file and run `EXPLAIN` or `PREPARE` in a DuckDB sandbox instance to verify syntax. For extremely large queries, perform a lightweight lint (token/keyword checks) first.
   - For every inline `sql_code`, run `EXPLAIN`/`PREPARE` similarly. Never execute queries that perform writes or DDL. If the SQL contains non-SELECT statements, flag for manual review.
   - If DuckDB returns errors, include the DuckDB error message and the offending SQL fragment in the report.
6) Anchors and templates:
   - If the job uses `<<: *ANCHOR` style merges, resolve the anchor locally and validate the merged node. Note: anchors are document-local; if an anchor reference points outside the document, note this as a potential portability issue.
7) Produce an output JSON object with the following shape:
{
  "job_path": "...",
  "summary": {"status": "pass|warn|fail", "errors": N, "warnings": M},
  "structural": [ {"path": "indicators.myind.name", "severity": "error|warn", "message": "Missing required field 'table'", "suggestion": "Add 'table: incidents'"} ],
  "referential": [ {"path": "indicators.myind.sql_ref_file", "severity": "error|warn", "message": "File missing", "path_checked": "workspace/BALLUFF/sql/myind.sql"} ],
  "sql": [ {"path": "indicators.myind.sql_code", "severity": "error|warn", "message": "DuckDB syntax error: ...", "sql_excerpt": "SELECT ..."} ],
  "notes": ["Human-readable notes or non-blocking suggestions"],
}

8) If possible, provide exact line/column locations for errors (best effort) and a short one-line suggested fix for each error.
9) Keep the validation non-destructive: do not modify files, do not run SQL beyond EXPLAIN/PREPARE, and do not upload or send files externally.

Deliverable: The JSON object described above plus a 3-line human summary at the top-level.

--- END PROMPT ---

Usage examples:
- "Validate `workspace/BALLUFF/balluff.yml` against `wiki/BIS API.yml` and return the JSON report."
- "Run only structural checks on `workspace/DUMMY/dummy.yml`."

Notes for implementers:
- If you are building a script around this prompt, prefer a fast DuckDB in-memory instance for EXPLAIN checks and mount no external data sources.
- Consider caching `api_doc_path` parsing for batch validations.

Saved: `wiki/validate_job_prompt.md` — place this in the repo and use it when invoking an AI validator.



