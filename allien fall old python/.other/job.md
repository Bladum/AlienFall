
# Compact GPT‑5‑mini prompt — improved

Purpose
- Produce a deterministic, small, and strict 5‑section rewrite of a wiki topic for modders and implementers.

Required output shape (exact H2 headers and order)
- Use exactly these H2 headers in this order: 
    ## Concept
    ## Mechanics
    ## Design
    ## Examples
    ## Implementation
    ## References
- Return only those six sections and nothing else. 

Global rules (tonal & length)
- Keep language simple and direct. Aim for short sentences a 12‑year‑old can follow.
- Be deterministic: no creative variation in ordering, labels, or phrasing that affects parsing.
- Strict length caps per section: 
  - Concept 3–8 sentences; 
  - Mechanics ≤ 30 short bullets; 
  - Examples include all original example blocks verbatim plus at most 8 added examples; 
  - Implementation ≤ 60 concise lines; 
  - References ≤ 12 lines.

Concept section rules

- 3–8 sentences. High‑level what + why only. No numbers, no examples, no implementation details.
- Use present tense and avoid modal verbs.

Mechanics section rules

- List distinct mechanics as short titled bullets that is self explanatory from game design perspective.
- Mechanics are any rules, systems, logics, processes, formulas, mechanics, gameplay, or interactions that govern gameplay.
- For each mechanic add from 2 to max 7 sub‑bullets explaining it in details, as single sentence, proving clear idea description with no ambiguity.
- No code, no classes, no file names in Mechanics.
- Try not to remove so much content from mechanics, i just need to rewrite and structure them.

Design section rules:

- Answer few of below topics that are relevent to this subject:
    - Required short description — what it is and why it exists (no numbers, no implementation).
    - Triggers → What and who and when this mechanic is triggered.
    - Inputs and outputs — list needed inputs and produced outputs.
    - Processing steps / flow — sequence A → B → C. (Optional mermaid diagram if flow is complex.)
    - Player choices — decision points, available options, and outcome effects.
    - Player interaction — UI controls, expected player reaction, and one UX cue to reduce confusion.
    - Difficulty impact — how difficulty changes behavior or "no effect".
    - Modding & configurability — modable vs hardcoded, expected limits, one-line mod risk.
    - Testing & edge cases — key edge cases and inputs that could break the mechanic (one-line each).
    - Balance & tuning — known balance risks and mitigation steps.
    - Telemetry & metrics — required events and key metrics for balancing, debugging, anti-abuse.
    - Data-driven parameters — require tunable values exposed in YAML with sensible defaults.
    - Mod sandboxing & validation — resource caps/timeouts, validation steps, and safe fail policy.
    - Performance & scalability — CPU, memory, network considerations.
    - Security & anti-cheat — cheat vectors, detection signals, and one short mitigation strategy.
    - Localization & accessibility — textual/visual/audio elements requiring localization or alternatives.
    - Designer notes on balance philosophy — brief preferred philosophy (risk/reward, agency, predictability).

Examples section rules:

- Paste all original example blocks verbatim and unchanged, in the same format and order they appeared in source.
- If any mechanic lacks examples, append "Additional Examples" with labeled entries A, B, ... and mark each "(designer-supplied)".
- Added examples must be concrete and cover normal, boundary, and one edge case.
- End with a 1–2 line creative suggestions paragraph for modders.

Implementation section rules:

- For each mechanic suggest if there is class needed with minimal artifacts:
    - Methods: ClassName.method_name — one-line purpose.
    - Properties: ClassName.property_name — type / one-line purpose.

- Only include a YAML config when the class is designer/modder configurable.
    - For each YAML file give a compact schema overview: top keys and required fields (one line per key).

- If a mechanic lacks implementation, add the exact token:
    Missing: Implementation
    and supply proposed mapping and class suggestions.

- Constraints and style:
    - No method bodies or code blocks.
    - Keep each line short and factual.
    - Use the tokens "Missing: Implementation" and "See Implementation" verbatim.
    - Keep the Implementation section concise (aim ≤ 60 lines).


References section rules:
- Provide 3+ game:mechanic lines where applicable (Game — Mechanic: why relevant). If fewer than 3 relevant games, state the count and reason.
- Then list relevant wiki paths (one per line).

Validation & error handling
- If source contains no examples: add "Missing: Examples" then supply designer examples.
- If any rule is violated during generation, include a single-line diagnostics footer (before end of section but inside the five sections) labeled "Generation notes:" with at most two short items.
- Do not include any content outside the five sections.

Determinism & parsing hints for GPT‑5‑mini
- Use fixed tokens for markers: "Missing: Examples", "Missing: Implementation", "See Implementation", "Additional Examples", "Generation notes:".
- Avoid mermaid diagrams unless flow cannot be expressed in one line; prefer "A → B → C".
- Favor many small mechanics over one large system.

Practical limits
- Target total output ≤ 2000 tokens.
- Keep sentences under 30 words where practical.

Quick checklist (to enforce at finish)
- Concept: 3–8 sentences.
- Mechanics: each mechanic references an Example and contains no implementation.
- Design: Depends on needs, it may be one or many.
- Examples: original blocks unchanged; added labeled and marked.
- Implementation: mapping lines + Python artifacts + YAML overview + tests.
- References: 3 game entries or explicit reason why fewer.

Use this prompt as a strict template. If input is ambiguous, prefer explicit "Missing:" lines over guessing.

