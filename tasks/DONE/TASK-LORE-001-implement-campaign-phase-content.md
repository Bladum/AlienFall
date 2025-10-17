# Task: Implement Campaign Phase Content

**Status:** TODO  
**Priority:** CRITICAL  
**Created:** January XX, 2026  
**Completed:** N/A  
**Assigned To:** AI Agent

---

## Overview

Implement complete campaign phase system with 4 distinct phases covering 1996-2004. Create TOML content files defining all phase progression, triggers, missions, and transitions. Enhance phase_manager.lua to handle phase logic and progression tracking.

---

## Purpose

The campaign phase system is the backbone of AlienFall's strategic progression. Currently, engine/lore/campaign/ has manager code but **NO content files**. This task creates all phase definitions from the comprehensive lore_ideas.md design document, completing the strategic layer content system.

**Current State**: Stub implementation - systems exist but have NO data  
**After This Task**: Complete 4-phase campaign with full content and progression

---

## Requirements

### Functional Requirements
- [ ] Phase 0: Shadow War (1996-1999) - Human factions, supernatural threats
- [ ] Phase 1: Sky War (1999-2001) - Alien invasion, UFO combat
- [ ] Phase 2: Deep War (2001-2002) - Aquatic species, USO threats
- [ ] Phase 3: Dimensional War (2003-2004) - Reality-warping endgame
- [ ] Phase transitions triggered by campaign milestones
- [ ] Phase-specific mission generation
- [ ] Phase-appropriate enemy factions
- [ ] Timeline tracking (18 major milestones from 1996-2004)

### Technical Requirements
- [ ] Create 4 phase TOML files in mods/core/campaigns/
- [ ] Create campaign_timeline.toml with 18 milestone definitions
- [ ] Enhance engine/lore/campaign/phase_manager.lua
- [ ] Implement phase transition logic
- [ ] Add timeline progression tracking
- [ ] Save/load support for current phase and progress

### Acceptance Criteria
- [ ] All 4 phases defined with complete content
- [ ] 18 timeline milestones configured
- [ ] Phase transitions work based on triggers
- [ ] Mission generation respects current phase
- [ ] Faction spawning follows phase rules
- [ ] Documentation complete in docs/campaign/
- [ ] Unit tests verify phase logic

---

## Plan

### Step 1: Create Phase 0 Content (Shadow War)
**Description:** Define Phase 0 with human factions, supernatural threats, and covert operations  
**Files to create:**
- `mods/core/campaigns/phase0_shadow_war.toml`

**Content** (from lore_ideas.md):
```toml
[phase]
id = "phase0_shadow_war"
name = "Shadow War"
description = "Human factions, covert operations, and supernatural outbreaks. Evidence suppression intensifies as subtle alien signs appear."
years = [1996, 1997, 1998, 1999]
tags = ["Phase0", "covert", "supernatural"]

[timeline]
# Timeline milestones for this phase
milestones = [
    "start_private_firm",          # 1996 start
    "first_anomalies",             # Mid 1996
    "supernatural_outbreaks",      # Late 1996
    "blackops_evidence",           # Early 1997
    "alien_signatures",            # Mid 1997
    "build_network",               # Late 1997 - Early 1998
    "intelligence_spike",          # Mid 1998
    "formalize_xcom"               # Late 1998 - Early 1999
]

[factions]
# Active factions during this phase
active = [
    "faction_cult",
    "faction_blackops",
    "faction_supernatural",
    "faction_syndicate",
    "faction_mib"
]

[missions]
# Mission types available in this phase
types = [
    "investigation",
    "containment",
    "covert_raid",
    "cult_ritual",
    "supernatural_hunt",
    "evidence_recovery"
]

[technology]
# Tech available/researchable in this phase
weapons = ["ballistic", "blackops_specialized", "occult_countermeasures"]
armor = ["civilian_clothing", "ballistic_vest", "blackops_suit"]
vehicles = ["civilian_car", "van", "helicopter"]

[transition]
# How to progress to Phase 1
trigger_type = "milestone"
required_milestone = "formalize_xcom"
next_phase = "phase1_sky_war"
```

**Estimated time:** 6 hours

### Step 2: Create Phase 1 Content (Sky War)
**Description:** Define Phase 1 with alien invasion, UFO combat, and terrestrial aliens  
**Files to create:**
- `mods/core/campaigns/phase1_sky_war.toml`

**Content** (from lore_ideas.md):
```toml
[phase]
id = "phase1_sky_war"
name = "Sky War"
description = "First Contact leads to open conflict. Terrestrial alien forces escalate; psionics is revealed."
years = [1999, 2000, 2001]
tags = ["Phase1", "aliens", "UFO", "psionics"]

[timeline]
milestones = [
    "first_contact",               # Late 1999 - Early 2000
    "psionics_revealed",           # 2000 mid
    "alien_escalation",            # Late 2000
    "cydonia_offensive"            # ~2001 (milestone - ends Phase 1)
]

[factions]
active = [
    "faction_sectoids",
    "faction_mutons",
    "faction_floaters",
    "faction_chryssalids",
    "faction_cyberdiscs",
    "faction_ethereals",
    "faction_reticulan_cabal"     # Begins during Phase 1
]

[missions]
types = [
    "ufo_crash_site",
    "ufo_landing_site",
    "terror_mission",
    "abduction",
    "alien_base_assault",
    "interception"
]

[technology]
weapons = ["laser", "plasma", "psi_amp"]
armor = ["basic_armor", "power_suit"]
vehicles = ["interceptor", "firestorm", "skyranger"]
research_branches = ["psionics", "plasma_weapons", "alien_alloys"]

[transition]
trigger_type = "milestone"
required_milestone = "cydonia_offensive"
next_phase = "phase2_deep_war"
```

**Estimated time:** 6 hours

### Step 3: Create Phase 2 Content (Deep War)
**Description:** Define Phase 2 with aquatic species, USOs, and two-front war  
**Files to create:**
- `mods/core/campaigns/phase2_deep_war.toml`

**Content** (from lore_ideas.md):
```toml
[phase]
id = "phase2_deep_war"
name = "Deep War"
description = "A second front opens under the oceans. Aquatic species and USOs threaten coasts; politics fragment after major victories."
years = [2001, 2002]
tags = ["Phase2", "aquatic", "USO", "underwater"]

[timeline]
milestones = [
    "uso_emergence",               # 2001 early
    "two_front_war",               # 2001 early-mid
    "aquatic_campaign",            # 2001-2002
    "tleth_neutralized"            # Late 2002 (milestone - ends Phase 2)
]

[factions]
active = [
    "faction_gill_men",
    "faction_tentaculat",
    "faction_tasoth",
    "faction_deep_ones",
    "faction_lobster_men",
    "faction_triton",
    "faction_reticulan_cabal"     # Continues from Phase 1
]

[missions]
types = [
    "uso_crash_site",
    "sunken_wreck",
    "deep_sea_colony_assault",
    "coastal_terror",
    "underwater_base_defense",
    "artifact_retrieval",
    "hybrid_infiltration"
]

[technology]
weapons = ["gauss", "sonic", "magna_plasma"]
armor = ["aqua_plastic_armor", "magnetic_ion_armor", "triton_armor"]
vehicles = ["barracuda", "manta", "leviathan"]
research_branches = ["aquatic_tech", "sonic_weapons", "hybrid_physiology"]

[transition]
trigger_type = "milestone"
required_milestone = "tleth_neutralized"
next_phase = "phase3_dimensional_war"
```

**Estimated time:** 6 hours

### Step 4: Create Phase 3 Content (Dimensional War)
**Description:** Define Phase 3 with dimensional threats, human superpowers, and endgame  
**Files to create:**
- `mods/core/campaigns/phase3_dimensional_war.toml`

**Content** (from lore_ideas.md):
```toml
[phase]
id = "phase3_dimensional_war"
name = "Dimensional War"
description = "Regional human superpowers rise. Dimensional breaches and psionic, reality-warping enemies culminate in a Nexus assault."
years = [2003, 2004]
tags = ["Phase3", "dimensional", "endgame", "human_factions"]

[timeline]
milestones = [
    "human_factions_rise",         # 2003
    "dimensional_signs",           # 2003
    "dimensional_breaches",        # 2003-2004
    "dimensional_nexus_assault"    # 2004 late (endgame)
]

[factions]
active = [
    "faction_anthropods",
    "faction_multi_worms",
    "faction_brain_suckers",
    "faction_dimensional_hybrids",
    "faction_cult_of_sirius",
    "faction_reticulans_true",
    "faction_dimension_lord",
    # Human factions
    "faction_dragons_shadow",
    "faction_desert_scorpions",
    "faction_pan_american_directorate"
]

[missions]
types = [
    "dimensional_breach_containment",
    "tdv_crash_site",
    "dimensional_outpost",
    "dimensional_terror",
    "rift_extraction",
    "alien_dimension_infiltration",
    "dimensional_base_defense",
    "human_faction_assault",
    "nexus_assault"               # Final mission
]

[technology]
weapons = ["particle_beam", "vortex", "phase_disruptor"]
armor = ["dimensional_phase_armor", "quantum_weave", "reticulan_armor"]
vehicles = ["dimensional_interceptor", "gate_breaker", "void_jumper"]
research_branches = ["dimensional_science", "psionic_mastery", "reality_manipulation"]

[transition]
trigger_type = "milestone"
required_milestone = "dimensional_nexus_assault"
next_phase = "endgame"           # No further phases
game_complete = true
```

**Estimated time:** 7 hours

### Step 5: Create Campaign Timeline
**Description:** Define all 18 campaign milestones with triggers and effects  
**Files to create:**
- `mods/core/campaigns/campaign_timeline.toml`

**Content**:
```toml
# Campaign Timeline - All Major Milestones (1996-2004)

[[milestone]]
id = "start_private_firm"
name = "Private Firm Formed"
phase = "phase0_shadow_war"
year = 1996
month = 1
description = "Player creates private security firm"
triggers = ["player_creation"]
effects = { funding_type = "private", unlock_missions = ["investigation", "covert_raid"] }

[[milestone]]
id = "first_anomalies"
name = "First Anomalies"
phase = "phase0_shadow_war"
year = 1996
month = 6
description = "Investigation chain unlocks; early lore entries appear"
triggers = ["investigation_chain_complete"]
effects = { unlock_missions = ["containment"], unlock_research = ["occult_basics"] }

# ... (continue for all 18 milestones)

[[milestone]]
id = "dimensional_nexus_assault"
name = "Dimensional Nexus Assault"
phase = "phase3_dimensional_war"
year = 2004
month = 10
description = "Endgame assault on the Nexus"
triggers = ["endgame_research_complete"]
effects = { unlock_missions = ["nexus_assault"], game_complete = true }
final_mission = true
```

**Estimated time:** 4 hours

### Step 6: Enhance Phase Manager
**Description:** Add phase logic, transition handling, and timeline tracking  
**Files to modify:**
- `engine/lore/campaign/phase_manager.lua` (create if doesn't exist)

**Enhancements needed:**
- Load phase TOML files
- Track current phase and progress
- Check phase transition triggers
- Update available factions/missions based on phase
- Timeline milestone progression
- Phase-specific content filtering

**Estimated time:** 6 hours

### Step 7: Create Documentation
**Description:** Document campaign phase system with examples and modding guide  
**Files to create:**
- `docs/campaign/phase_system.md`
- `docs/campaign/campaign_timeline.md`
- `docs/modding/campaign_phases.md`

**Content**: Phase overview, milestone system, how phases affect gameplay, modding guide

**Estimated time:** 3 hours

### Step 8: Testing
**Description:** Unit tests for phase logic and integration tests for progression  
**Test cases:**
- Phase transitions trigger correctly
- Timeline milestones advance
- Mission availability changes with phases
- Faction spawning follows phase rules
- Save/load preserves phase state

**Files to create:**
- `tests/lore/test_phase_system.lua`
- `tests/integration/test_campaign_progression.lua`

**Estimated time:** 2 hours

---

## Implementation Details

### Architecture
**Phase System Structure**:
```
Campaign Phase System
├── Phase Definitions (TOML) - Static phase data
├── Timeline (TOML) - 18 milestone progression
├── Phase Manager (Lua) - Runtime phase logic
└── Integration - Campaign Manager, Mission Generator, Faction System
```

**Phase Lifecycle**:
1. Game starts in Phase 0 (1996)
2. Player completes missions, advances time
3. Milestones trigger based on achievements
4. Phase transitions when milestone requirements met
5. New content unlocks (factions, missions, tech)
6. Repeat until Phase 3 endgame

### Key Components
- **Phase Definitions**: TOML files with complete phase content
- **Campaign Timeline**: Milestone progression system
- **Phase Manager**: Lua logic for phase handling
- **Integration**: Faction system, mission generator, research tree

### Dependencies
- engine/lore/campaign/campaign_manager.lua (exists)
- engine/lore/factions/faction_system.lua (exists)
- engine/lore/missions/mission_system.lua
- mods/core/ TOML loading system

---

## Testing Strategy

### Unit Tests
- Test 1: Phase definition loading from TOML
- Test 2: Phase transition logic
- Test 3: Milestone trigger conditions
- Test 4: Timeline progression

### Integration Tests
- Test 1: Complete Phase 0 → Phase 1 transition
- Test 2: Verify faction availability changes with phase
- Test 3: Verify mission types change with phase
- Test 4: Verify technology unlocks follow phases
- Test 5: Save/load during phase transition

### Manual Testing Steps
1. Run game with `lovec "engine"`
2. Start new campaign (Phase 0)
3. Complete investigation missions
4. Verify milestones progress
5. Reach "formalize_xcom" milestone
6. Verify transition to Phase 1
7. Verify UFO missions now available
8. Check console for phase transition logs
9. Save game, reload, verify phase preserved
10. Continue through all 4 phases

### Expected Results
- Phases progress smoothly based on milestones
- Content availability changes appropriately
- Mission generation respects phase
- Faction spawning follows phase rules
- Timeline feels natural and paced

---

## How to Run/Debug

### Running the Game
```bash
lovec "engine"
```
or use the VS Code task: "Run XCOM Simple Game"

### Debugging
- Love2D console is enabled in `conf.lua` (t.console = true)
- Use `print("[PhaseSystem] Current phase: " .. phase_id)`
- Use `print("[PhaseSystem] Milestone reached: " .. milestone_id)`
- Use `print("[PhaseSystem] Transition to: " .. next_phase)`
- Add timeline tracking: `print("[Timeline] Year: " .. year .. " Month: " .. month)`
- Monitor phase transitions in console

### Temporary Files
- Phase state cache: `os.getenv("TEMP") .. "\\alienfall\\phase_state.cache"`
- Timeline log: `os.getenv("TEMP") .. "\\alienfall\\campaign_timeline.log"`

---

## Documentation Updates

### Files to Update
- [x] `docs/campaign/phase_system.md` - Create phase system guide
- [x] `docs/campaign/campaign_timeline.md` - Document 18 milestones
- [x] `docs/modding/campaign_phases.md` - TOML phase creation guide
- [ ] `wiki/API.md` - Add PhaseManager, Timeline APIs
- [ ] `wiki/FAQ.md` - Add "How does campaign progression work?"
- [ ] Code comments - Document all phase logic

---

## Notes

- Phase system is based on comprehensive lore_ideas.md design
- 18 milestones cover 1996-2004 timeline (8 years)
- Each phase has distinct identity (Shadow → Sky → Deep → Dimensional)
- Phase transitions create major gameplay shifts
- System designed for moddability - easy to add new phases
- Timeline pacing can be adjusted via TOML
- Phases affect ALL game systems (missions, factions, research, tech)

---

## Blockers

- None identified - all systems exist, just need content files

---

## Review Checklist

- [ ] Code follows Lua/Love2D best practices
- [ ] No global variables (all use `local`)
- [ ] Proper error handling with `pcall` where needed
- [ ] All TOML files validate correctly
- [ ] Phase transitions work smoothly
- [ ] Timeline progression feels natural
- [ ] Console debugging statements added
- [ ] Tests written and passing
- [ ] Documentation updated
- [ ] No warnings in Love2D console
- [ ] Save/load preserves phase state
- [ ] Content availability changes correctly with phases

---

## Post-Completion

### What Worked Well
- TBD after implementation

### What Could Be Improved
- TBD after implementation

### Lessons Learned
- TBD after implementation
