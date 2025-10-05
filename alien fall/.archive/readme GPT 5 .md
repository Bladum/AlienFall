# AlienFall Design Dossier Review (2025-10-05)

## Opening notes
I spent time with every folder under `alien fall`, skipping only the five root-level READMEs per your request. There is a lot to appreciate: the scope is ambitious, the modular layout is friendly to Love2D/Lua, and the documentation keeps the X-COM DNA front and center. Below is a consolidated readout aimed at helping you keep momentum, tighten weak spots, and set the stage for AI-assisted, mod-heavy development.

---

## Snapshot of current coverage
- **Major subsystems touched:** Advanced modding, battlescape & tactical combat, geoscape, economy/finance, crafts/interception, units/items, terrain/content generation, GUI, organization/meta-progression, save/load.
- **Strength highlights:**
  - Tactical combat bundle (Battle Tactical Combat, Battlescape, Battlescape AI) is the most thorough: strong linkage between AP/MP/Energy, sight/sense, and environmental systems.
  - Content generation & terrain docs line up with the modular map-block workflow you outlined for procedural play.
  - Modding stack already anticipates loader, validation, and dependency logic—essential for an open-source, AI-assisted ecosystem.
  - Economy/finance set establishes the geoscape pressure loop (funding, debt, score) that makes X-COM-likes sing.
- **Documentation depth variance:** Several areas (Audio, Units, Items, some Crafts/Interception entries) stop at outlines or slogans. Others (Core Systems, Battle Tactical Combat) go deep on mechanics. This unevenness drives most gaps noted below.

---

## Content integrity between modules
| Area | What’s working | Where cohesion frays |
|------|----------------|-----------------------|
| **Core economy ↔ organization** | `Finance` + `Organization` folders both capture reputation, funding, and reporting loops. | Fame/Karma/Score appear in multiple files with partially overlapping descriptions (Core Systems vs Organization). Needs a single source of truth for formulas and effects to keep budgets, diplomacy, and mission generation in sync.
| **AP/MP/Energy systems** | Cross-referenced in `Core Systems`, `Battle Tactical Combat`, `Units`, `Crafts`, `Interception`. | Separate docs restate costs with subtle differences (e.g., craft energy costs in Crafts vs Interception). Missing joint timing diagrams for shared turns (geoscape day, interception minute, battlescape 10s) to ensure the numbers align.
| **Procedural map stack** | `Battle Map Generator`, `Terrain`, and `Content Generator` align on blocks → scripts → tiles → prefabs. | Map script logic references conditional commands, but no shared schema with the generator/loader. Environmental features mention weather effects, yet tactical combat docs don’t explain how modifiers enter AP/accuracy math.
| **Units/items** | Structure mirrors classic X-COM (classes, promotions, medals, encumbrance, equipment). | Most unit/item files are one-paragraph summaries. No consolidated stat table, damage formulas, or equipment progression to mesh with research/manufacturing docs.
| **Modding** | Loader/validator/advanced modding docs point the same direction (TOML + Lua). | There’s no explicit API surface list beyond high-level categories. Need concrete function signatures/events so mods can interact safely with e.g., Mission Lifecycle or Battle Flow.
| **UI** | GUI pages enumerate the major screens and their widgets. | No wireframes, call hierarchy, or Love2D state-machine linkage. UI grid docs reference a 24px baseline while basic widgets cite a 20×20 logical grid—needs reconciliation before layout work.
| **Lore/campaign** | `Lore`, `Mission Management`, and `Geoscape` all describe campaign cadence. | Timing differs: Calendar (Geoscape) uses 6-day weeks/5-week months, Lore Calendar notes 7-day weeks/30-day months, Geo Turn says week = 6 days. Pick one so event pacing, manufacturing ticks, and monthly reports align.

---

## Implementation clarity & actionability
- **Actionable clusters** (clear enough to implement):
  - Battle resolution core (AP/MP/Energy with action tables, suppression, sight/LOS/LOF). Only needs concrete formulas and state diagrams.
  - Geoscape economy loop (funding → budget → reports → debt). Numbers are illustrative, but the flow is there.
  - Map assembly pipeline (blocks/scripts/prefabs) has explicit dimensions and example tables; just needs data schema.
  - Mod loading/validation stack: responsibilities are well defined; implementation can start once file formats are formalized.

- **Under-specified clusters** (teams will stall without more detail):
  - **Unit progression & combat math:** No authoritative damage/accuracy formula, crit rules, armor mitigation, or sanity/morale interplay. Promotions reference XP thresholds but not perks or effects. Medals mention “high XP boosts” without values.
  - **AI behavior:** Battlescape AI docs describe objectives but lack state machines, behavior trees, or weight tables. Geoscape AI’s “Enemy Strategy” is high-level; no decision matrices for resource allocation or response logic.
  - **Craft/interception loop:** Screen layout is described, but there’s no real-time vs turn sequencing, targeting priority, or retreat rules. Fuel/range numbers conflict across documents (e.g., per-action cost 4 vs 10) and there’s no mention of Love2D update cadence.
  - **Research/manufacturing:** Systems mention random cost multipliers and queues, but no base rates, staff requirements, or data structures. Manufacturing has no tie-in to resource items (alloys, corpses). Research leapfrogs to outcomes without durations or dependencies beyond generic “1000 credits”.
  - **Save system:** States intention (“deterministic serialization”) yet lacks file layout, versioning, or mod compatibility plan—critical for a moddable project.
  - **UI implementation:** No information on widget hierarchy, event dispatch, or how GUI scenes map to Love2D states. Accessibility callouts exist, but no specs for focus handling or controller layout.

---

## Missing or thin areas from a game-design perspective
1. **Player-facing feedback loops**
   - No UX flow for tutorial/onboarding, difficulty scaling, or post-mission analytics beyond text tables.
   - Reputation/Fame/Karma systems lack concrete rewards/penalties (exact funding multipliers, mission unlock lists).
   - Sanity/fatigue/psionics interplay is hinted but no combined chart showing thresholds, recovery, and failure states.

2. **Balancing and pacing plans**
   - No tiered progression charts aligning research unlocks, unit classes, weapons, enemies, and mission difficulty over time.
   - Map size scaling exists, but there’s no reference to expected squad sizes, average mission length, or resource payouts per mission type.
   - Campaign generator doesn’t list failure conditions or success metrics beyond “escalation”; players need strategic goals for open-ended play.

3. **Technical architecture for Love2D**
   - Documentation never states how Love2D callbacks (`love.update`, `love.draw`, `love.load`) orchestrate geoscape vs battlescape vs menus.
   - No mention of a state machine module, scene loader, or service locator usage beyond the Foundation Services blurb.
   - Performance targets reference <500MB RAM and 60 FPS but without profiling strategy or asset budget per scene.

4. **Mod ecosystem specifics**
   - Absent: versioning scheme, mod metadata schema example, load-order conflict resolution policy, or sample mod pack.
   - API doc lacks authentication/permissions model for sandboxed Lua (which functions are whitelisted, how to prevent `love.filesystem` abuse, etc.).

5. **Testing and tooling**
   - Engine test docs list categories but no harness description, test runner interface, or coverage expectations.
   - No automated balancing tools (e.g., spreadsheets, simulation scripts) despite heavy interlocking systems.

6. **Narrative & world-building integration**
   - Lore files describe mechanics (campaigns, events) but little about factions’ motivations, story arcs, or dynamic narrative triggers.
   - Pedia framework exists, yet no sample entries tying stats to lore—important for AI-generated content validation.

---

## Improvement roadmap (prioritized)
### Immediate (unlock implementation)
1. **Unify calendars & temporal scales**: Decide on day/week/month structure and propagate to Geo Turn, Calendar, Lore Calendar, Mission Lifecycle, manufacturing/research tick rates.
2. **Author the core combat math spec**: One document covering accuracy, range modifiers, cover interaction, damage/armor formulas, crits, suppression, morale/sanity effects. Link Units, Items, Battle Tactical Combat.
3. **Draft authoritative data schemas**: JSON/TOML prototypes for units, items, maps, research, missions. Include field names, types, example entries.
4. **Clarify AP/MP/Energy cross-system timing**: Diagram how geoscape turns, interception rounds, and battlescape turns interleave; align craft energy costs with unit energy rules.

### Short term (smooth content integrity)
1. **Merge duplicated meta systems**: Create a single `Reputation & Influence` doc capturing Fame/Karma/Score formulas, thresholds, and links to funding, diplomacy, mission generation.
2. **Detail AI behavior trees**: For Battlescape (pods, reactions, patrols) and Geoscape (invasion phases, resource allocation). Provide pseudo-code or state diagrams.
3. **Expand research/manufacturing pipelines**: Specify base times, resource costs, staff requirements, and synergy with resource items and facilities.
4. **Produce UI flow specs**: Wireframes or component maps for Menu, Geo Scape, Base Scape, Battle Scape, Interception. Reconcile 20×20 vs 24px grid guidance.

### Medium term (player experience & tooling)
1. **Design progression charts**: Map months to tech tiers, enemy upgrades, mission availability, and expected squad capabilities. Add balancing checkpoints.
2. **Write Save System technical spec**: File format, versioning, compression, mod compatibility, deterministic replay plan.
3. **Mod API reference**: Enumerate events, callback signatures, sandboxed utilities, and sample mod with tests.
4. **Testing infrastructure blueprint**: Define test harness structure, coverage goals, and automation pipeline (Love2D headless runs, Lua test framework, data validation scripts).

### Long term (quality & narrative depth)
1. **Narrative integration plan**: Connect campaign events, quests, and factions with story beats, Pedia entries, and player choices.
2. **Dynamic difficulty tuning**: Specify how fame/karma/score feed into enemy escalation, mission density, and economy adjustments.
3. **Analytics & telemetry**: Plan for logging mission outcomes, unit performance, and economy trends to support balancing and AI content generation.

---

## Supportive closing
The backbone is solid: you’ve mapped the same pillars that made UFO Defense timeless, and you’ve already embraced modularity and moddability—which is perfect for an AI-assisted workflow. The next leap is coherence: unify overlapping systems, promote the key math specs from “idea” to “contract”, and give developers (human or AI) schemas they can implement against. Once those anchors are in place, the documentation becomes a launchpad both for core development and for the massive mod scene you’re targeting.

Happy to dive deeper into any subsystem or help turn the roadmap into issue trackers or implementation stubs when you’re ready.
