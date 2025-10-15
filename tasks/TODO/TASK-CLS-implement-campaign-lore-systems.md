# Task: Implement Campaign and Lore Systems

**Status:** TODO  
**Priority:** High  
**Created:** 2025-01-XX  
**Completed:** N/A  
**Assigned To:** AI Agent

---

## Overview

Implement comprehensive campaign and lore systems based on wiki/wiki/ideas.md. This includes campaign phases (Shadow War → Sky War → Deep War → Dimensional War), faction lore content, technology catalog, narrative hooks, and threat progression mechanics.

---

## Purpose

AlienFall's campaign structure provides narrative depth and long-term progression. The ideas.md file contains rich content for campaign phases, factions, technology trees, and narrative systems that need implementation and proper documentation to deliver engaging story-driven gameplay.

---

## Requirements

### Functional Requirements
- [ ] Campaign phase system with 4 phases (Shadow War, Sky War, Deep War, Dimensional War)
- [ ] Faction lore system with backstories, motivations, and resolution paths
- [ ] Technology catalog with phase-appropriate progression
- [ ] Narrative hooks system (research discoveries, interrogations, diplomacy)
- [ ] Threat progression with escalating difficulty per phase
- [ ] Mission templates tied to campaign phases and factions
- [ ] Materials and artifacts system for salvage and research

### Technical Requirements
- [ ] Implement campaign manager in engine/geoscape/campaign_manager.lua
- [ ] Implement lore system in engine/lore/lore_manager.lua
- [ ] Implement narrative events in engine/core/event_system.lua
- [ ] Create TOML content files for all lore, factions, phases
- [ ] Save/load support for campaign state
- [ ] Performance: Event processing <5ms per trigger

### Acceptance Criteria
- [ ] Campaign progresses through 4 distinct phases with unique content
- [ ] Faction lore unlocks through research and missions
- [ ] Technology progression tied to campaign phases
- [ ] Narrative events trigger based on player actions
- [ ] Threat escalation creates appropriate challenge curve
- [ ] All systems documented in docs/lore/ and docs/campaign/
- [ ] Unit tests verify campaign logic

---

## Plan

### Step 1: Implement Campaign Phase System
**Description:** Create campaign manager with 4-phase progression, phase transitions, and phase-specific content  
**Files to modify/create:**
- `engine/geoscape/campaign_manager.lua` (enhance existing or create)
- `engine/geoscape/phase_manager.lua` (create)
- `mods/core/campaign/phases.toml` (create)
- `mods/core/campaign/phase_transitions.toml` (create)

**Campaign Phases**:
- Phase 0: Shadow War (supernatural, conspiracy)
- Phase 1: Sky War (alien invasion, UFOs)
- Phase 2: Deep War (underwater threats, deep ops)
- Phase 3: Dimensional War (reality-warping enemies)

**Estimated time:** 5 hours

### Step 2: Implement Faction Lore System
**Description:** Create detailed faction data with backstories, technology, motivations, and resolution paths  
**Files to create:**
- `engine/lore/lore_manager.lua`
- `engine/lore/faction_lore.lua`
- `mods/core/lore/factions/` (directory)
- `mods/core/lore/factions/supernatural_entities.toml`
- `mods/core/lore/factions/terrestrial_aliens.toml`
- `mods/core/lore/factions/reticulan_cabal.toml`
- `mods/core/lore/factions/aquatic_species.toml`
- `mods/core/lore/factions/dimensional_species.toml`

**Faction Categories**:
- Supernatural Entities (Phase 0)
- Terrestrial Aliens (Phase 1)
- Reticulan Cabal (Phase 1-2)
- Aquatic Species (Phase 2)
- Dimensional Species (Phase 3)

**Estimated time:** 6 hours

### Step 3: Implement Technology Catalog
**Description:** Phase-based technology progression with weapons, vehicles, artifacts  
**Files to create:**
- `engine/geoscape/technology_catalog.lua`
- `mods/core/technology/phase0_tech.toml` (Shadow War)
- `mods/core/technology/phase1_tech.toml` (Sky War)
- `mods/core/technology/phase2_tech.toml` (Deep War)
- `mods/core/technology/phase3_tech.toml` (Dimensional War)
- `mods/core/technology/progression_tree.toml`

**Technology Categories**:
- Weapons (ballistic → laser → plasma → psionic)
- Vehicles (conventional → UFO tech → experimental)
- Artifacts (alien devices, dimensional anchors)

**Estimated time:** 5 hours

### Step 4: Implement Narrative Hooks System
**Description:** Research discoveries, interrogation results, diplomacy events that unlock lore  
**Files to create:**
- `engine/core/event_system.lua` (enhance)
- `engine/lore/narrative_hooks.lua`
- `mods/core/lore/narrative_events.toml`
- `mods/core/lore/research_discoveries.toml`
- `mods/core/lore/interrogation_results.toml`

**Narrative Triggers**:
- Research completion
- Interrogations
- Mission outcomes
- Diplomatic actions
- Artifact discoveries

**Estimated time:** 4 hours

### Step 5: Implement Threat Progression
**Description:** Escalating difficulty mechanics tied to campaign phases and player performance  
**Files to create:**
- `engine/geoscape/threat_manager.lua`
- `mods/core/campaign/threat_progression.toml`
- `mods/core/campaign/escalation_rules.toml`

**Threat Mechanics**:
- Tower defense-style escalation
- Failed research leads to harder missions
- Time-based threat increase
- Player performance adaptive scaling

**Estimated time:** 4 hours

### Step 6: Create Mission Templates and Encounter System
**Description:** Dynamic mission generation based on campaign phase and faction  
**Files to create:**
- `engine/geoscape/encounter_generator.lua`
- `mods/core/missions/phase0_missions.toml`
- `mods/core/missions/phase1_missions.toml`
- `mods/core/missions/phase2_missions.toml`
- `mods/core/missions/phase3_missions.toml`

**Mission Types per Phase**:
- Phase 0: Investigations, cultist hideouts, paranormal sites
- Phase 1: UFO crashes, terror missions, base defense
- Phase 2: Underwater ops, deep facility raids
- Phase 3: Dimensional rifts, reality breaches

**Estimated time:** 5 hours

### Step 7: Implement Materials and Artifacts System
**Description:** Salvage system for alien materials, research items, and artifacts  
**Files to create:**
- `engine/economy/salvage_system.lua`
- `mods/core/lore/materials.toml`
- `mods/core/lore/artifacts.toml`

**Material Types**:
- Elerium (power source)
- Alien Alloys (construction)
- Psionic Crystals (psionics)
- Dimensional Shards (phase 3)

**Estimated time:** 3 hours

### Step 8: Create Comprehensive Documentation
**Description:** Document campaign structure, lore system, narrative mechanics  
**Files to create:**
- `docs/campaign/campaign_structure.md`
- `docs/campaign/phase_progression.md`
- `docs/lore/faction_guide.md`
- `docs/lore/narrative_hooks.md`
- `docs/lore/technology_catalog.md`
- `docs/modding/lore_creation.md`

**Estimated time:** 4 hours

### Step 9: Testing
**Description:** Unit tests for campaign logic, integration tests for progression  
**Test cases:**
- Campaign phase transitions trigger correctly
- Faction lore unlocks through research
- Technology progression follows phase requirements
- Narrative events trigger based on actions
- Threat escalation scales appropriately

**Files to create:**
- `tests/geoscape/test_campaign_manager.lua`
- `tests/lore/test_lore_manager.lua`
- `tests/integration/test_campaign_progression.lua`

**Estimated time:** 4 hours

---

## Implementation Details

### Architecture
**Campaign Structure**:
- 4 sequential phases with distinct themes and enemies
- Phase transitions triggered by research milestones or time
- Each phase unlocks new factions, missions, technology

**Lore System**:
- Faction lore stored in TOML with backstory, motivations, resolution
- Lore unlocked through research, interrogations, mission outcomes
- Narrative events deliver lore content to player

**Technology Progression**:
- Phase-gated technology trees
- Research dependencies ensure proper progression
- Technology catalog defines available items per phase

**Threat Progression**:
- Escalating enemy stats and abilities per phase
- Failed research/missions increase threat level
- Tower defense mechanics: waves of increasing difficulty

### Key Components
- **CampaignManager**: Tracks current phase, progression, and transitions
- **LoreManager**: Handles faction lore and narrative content
- **TechnologyCatalog**: Manages phase-based tech progression
- **ThreatManager**: Calculates and applies threat escalation
- **EncounterGenerator**: Creates phase-appropriate missions

### Dependencies
- engine/geoscape/ for campaign management
- engine/lore/ for lore system (may need to create)
- engine/core/event_system.lua for narrative triggers
- mods/core/ TOML files for all content

---

## Testing Strategy

### Unit Tests
- Test 1: Campaign phase transition logic
- Test 2: Faction lore unlock conditions
- Test 3: Technology gating by phase
- Test 4: Narrative event triggering

### Integration Tests
- Test 1: Complete playthrough of all 4 phases
- Test 2: Verify lore unlocks through research
- Test 3: Technology progression matches phase
- Test 4: Threat escalation creates appropriate challenge

### Manual Testing Steps
1. Run game with `lovec "engine"`
2. Start new campaign (Phase 0: Shadow War)
3. Complete Phase 0 research and missions
4. Verify transition to Phase 1 (Sky War)
5. Check faction lore unlocks through research
6. Verify technology progression matches phase
7. Confirm threat escalation over time
8. Progress through all 4 phases
9. Check console for any errors

### Expected Results
- Campaign progresses smoothly through all phases
- Faction lore is engaging and well-integrated
- Technology feels appropriately paced
- Threat escalation creates challenge without frustration
- Narrative events enhance story immersion

---

## How to Run/Debug

### Running the Game
```bash
lovec "engine"
```
or use the VS Code task: "Run XCOM Simple Game"

### Debugging
- Love2D console is enabled in `conf.lua` (t.console = true)
- Use `print("[Campaign] Current phase: " .. phase)` for campaign tracking
- Use `print("[Lore] Unlocked: " .. lore_id)` for lore debugging
- Use `print("[Threat] Current level: " .. threat_level)` for threat tracking
- Add phase transition logs
- Monitor narrative event triggering

### Temporary Files
- Campaign state cache: `os.getenv("TEMP") .. "\\alienfall\\campaign.cache"`
- Lore unlock log: `os.getenv("TEMP") .. "\\alienfall\\lore.log"`

---

## Documentation Updates

### Files to Update
- [x] `docs/campaign/campaign_structure.md` - Create campaign guide
- [x] `docs/campaign/phase_progression.md` - Document phase system
- [x] `docs/lore/faction_guide.md` - Faction lore reference
- [x] `docs/lore/narrative_hooks.md` - Narrative system guide
- [x] `docs/lore/technology_catalog.md` - Technology reference
- [x] `docs/modding/lore_creation.md` - TOML lore creation guide
- [ ] `wiki/API.md` - Add CampaignManager, LoreManager APIs
- [ ] `wiki/FAQ.md` - Add "How does campaign progression work?" entry
- [ ] Code comments - Document all campaign and lore logic

---

## Notes

- Campaign structure provides long-term progression and narrative depth
- Faction lore delivers engaging story without cutscenes
- Technology progression creates meaningful research goals
- Threat escalation ensures challenge scales with player capability
- Mod system allows community to create custom campaigns and factions

---

## Blockers

- May need to create engine/lore/ folder if it doesn't exist
- Requires event system enhancement for narrative triggers

---

## Review Checklist

- [ ] Code follows Lua/Love2D best practices
- [ ] No global variables (all use `local`)
- [ ] Proper error handling with `pcall` where needed
- [ ] Performance optimized (object reuse, efficient loops)
- [ ] All temporary files use TEMP folder
- [ ] Console debugging statements added
- [ ] Tests written and passing
- [ ] Documentation updated
- [ ] Code reviewed
- [ ] No warnings in Love2D console
- [ ] Save/load preserves campaign state
- [ ] TOML files validated
- [ ] Narrative content is engaging and well-written

---

## Post-Completion

### What Worked Well
- TBD after implementation

### What Could Be Improved
- TBD after implementation

### Lessons Learned
- TBD after implementation
