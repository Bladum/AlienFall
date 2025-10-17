# Task: Implement Faction Definitions

**Status:** TODO  
**Priority:** CRITICAL  
**Created:** January XX, 2026  
**Completed:** N/A  
**Assigned To:** AI Agent

---

## Overview

Implement complete faction definitions for 15+ factions across all campaign phases. Create TOML content files defining units, tech trees, campaigns, and characteristics for each faction. This task completes the strategic layer's faction content system.

---

## Purpose

The faction system has Lua code (engine/lore/factions/faction_system.lua - 291 lines) but **NO content files**. This task creates all faction definitions from lore_ideas.md, enabling the faction system to spawn enemies, manage faction relationships, and drive strategic gameplay.

**Current State**: Stub implementation - system exists but has NO faction data  
**After This Task**: Complete 15+ faction definitions with units, tech, and campaigns

---

## Requirements

### Functional Requirements
- [ ] 6 primary factions (Sectoids, Mutons, Ethereals, Cult, BlackOps, Aquatic)
- [ ] 9+ secondary factions (Floaters, Chryssalids, Cyberdiscs, Gill Men, etc.)
- [ ] Unit rosters for each faction
- [ ] Tech trees per faction
- [ ] Campaign associations (which phases each faction appears)
- [ ] Faction relationships (ally/enemy/neutral)
- [ ] Faction characteristics (psionic, aquatic, dimensional, human)

### Technical Requirements
- [ ] Create faction TOML files in mods/core/factions/
- [ ] Define unit rosters with stats
- [ ] Define tech progression
- [ ] Define faction traits and abilities
- [ ] Integrate with faction_system.lua
- [ ] Support faction spawning based on campaign phase

### Acceptance Criteria
- [ ] All 15+ factions defined with complete content
- [ ] Unit rosters include soldier/leader/specialist types
- [ ] Tech trees match campaign phase progression
- [ ] Faction relationships configured
- [ ] Documentation complete in docs/lore/factions/
- [ ] Unit tests verify faction data loading

---

## Plan

### Step 1: Create Phase 0/1 Terrestrial Factions
**Description:** Define human and early alien factions  
**Files to create:**
- `mods/core/factions/faction_sectoids.toml`
- `mods/core/factions/faction_mutons.toml`
- `mods/core/factions/faction_ethereals.toml`
- `mods/core/factions/faction_cult.toml`
- `mods/core/factions/faction_blackops.toml`

**Content example** (faction_sectoids.toml):
```toml
[faction]
id = "faction_sectoids"
name = "Sectoid Empire"
description = "Grey-skinned psionic aliens, scouts and infiltrators of the Reticulan Cabal."
tags = ["alien", "psionic", "terrestrial", "Phase1"]
phase_active = ["phase1_sky_war"]
tech_level = "plasma"

[characteristics]
psionic = true
aquatic = false
dimensional = false
human = false
tech_specialty = "psionics"

[relationships]
allies = ["faction_ethereals", "faction_reticulan_cabal"]
enemies = ["xcom", "faction_blackops"]
neutral = []

[[units]]
type = "sectoid_soldier"
name = "Sectoid Soldier"
health = 30
armor = 10
weapons = ["plasma_pistol"]
abilities = ["psi_panic", "mind_probe"]
spawn_weight = 10

[[units]]
type = "sectoid_leader"
name = "Sectoid Leader"
health = 40
armor = 15
weapons = ["plasma_rifle"]
abilities = ["psi_panic", "mind_control", "mind_probe"]
spawn_weight = 3

[[units]]
type = "sectoid_commander"
name = "Sectoid Commander"
health = 50
armor = 20
weapons = ["plasma_rifle", "psi_amp"]
abilities = ["psi_panic", "mind_control", "psi_blast", "telepathy"]
spawn_weight = 1

[technology]
weapons = ["plasma_pistol", "plasma_rifle", "psi_amp"]
armor = ["sectoid_biosuit"]
research_unlocks = ["psionics_theory", "plasma_weapons", "alien_alloys"]

[missions]
# Mission types this faction participates in
types = ["ufo_crash_site", "ufo_landing_site", "terror_mission", "abduction", "alien_base_assault"]
```

**Estimated time:** 10 hours (2h per faction)

### Step 2: Create Phase 2 Aquatic Factions
**Description:** Define underwater alien species  
**Files to create:**
- `mods/core/factions/faction_gill_men.toml`
- `mods/core/factions/faction_lobster_men.toml`
- `mods/core/factions/faction_deep_ones.toml`
- `mods/core/factions/faction_tasoth.toml`

**Content structure**: Similar to Step 1 but with aquatic traits, sonic weapons, underwater units

**Estimated time:** 8 hours (2h per faction)

### Step 3: Create Phase 3 Dimensional Factions
**Description:** Define reality-warping endgame factions  
**Files to create:**
- `mods/core/factions/faction_anthropods.toml`
- `mods/core/factions/faction_multi_worms.toml`
- `mods/core/factions/faction_dimension_lord.toml`
- `mods/core/factions/faction_reticulans_true.toml`

**Content structure**: Dimensional traits, particle beam weapons, psionic mastery

**Estimated time:** 8 hours (2h per faction)

### Step 4: Create Secondary/Support Factions
**Description:** Define support species and hybrid factions  
**Files to create:**
- `mods/core/factions/faction_floaters.toml`
- `mods/core/factions/faction_chryssalids.toml`
- `mods/core/factions/faction_cyberdiscs.toml`
- `mods/core/factions/faction_tentaculat.toml`

**Estimated time:** 4 hours (1h per faction)

### Step 5: Integrate with Faction System
**Description:** Enhance faction_system.lua to load TOML factions  
**Files to modify:**
- `engine/lore/factions/faction_system.lua`

**Enhancements needed:**
- Load faction TOML files
- Track active factions based on campaign phase
- Spawn faction units based on mission type
- Handle faction relationships
- Filter factions by phase/tech level

**Estimated time:** 4 hours

### Step 6: Create Faction Documentation
**Description:** Document all factions with lore, units, and modding guide  
**Files to create:**
- `docs/lore/factions/README.md` - Faction system overview
- `docs/lore/factions/sectoids.md`
- `docs/lore/factions/mutons.md`
- ... (one per major faction)
- `docs/modding/faction_creation.md` - TOML faction guide

**Estimated time:** 3 hours

### Step 7: Testing
**Description:** Unit tests for faction loading and integration tests  
**Test cases:**
- Faction TOML loading
- Unit roster spawning
- Tech tree validation
- Phase-based faction filtering
- Faction relationships

**Files to create:**
- `tests/lore/test_faction_system.lua`
- `tests/integration/test_faction_spawning.lua`

**Estimated time:** 2 hours

---

## Implementation Details

### Faction Categories
1. **Terrestrial Aliens (Phase 1)**:
   - Sectoids (psionic scouts)
   - Mutons (heavy infantry)
   - Ethereals (psionic masters)
   - Floaters (flying units)
   - Chryssalids (terror units)
   - Cyberdiscs (robotic units)

2. **Aquatic Aliens (Phase 2)**:
   - Gill Men (amphibious soldiers)
   - Lobster Men (heavy underwater units)
   - Deep Ones (terror units)
   - Tasoth (elite aquatic soldiers)
   - Tentaculat (psionic underwater)

3. **Dimensional Aliens (Phase 3)**:
   - Anthropods (insectoid reality-warpers)
   - Multi-Worms (hive mind)
   - Dimension Lord (endgame boss faction)
   - Reticulans True (true form aliens)

4. **Human Factions (Phase 0-3)**:
   - Cult of Sirius (human collaborators)
   - BlackOps (government agents)
   - Human superpowers (Phase 3)

### Dependencies
- engine/lore/factions/faction_system.lua (exists)
- engine/lore/campaign/phase_manager.lua (from TASK-LORE-001)
- mods/core/technology/ (from TASK-LORE-003)

---

## Testing Strategy

### Unit Tests
- Test 1: Faction TOML loading
- Test 2: Unit roster validation
- Test 3: Tech tree validation
- Test 4: Faction relationship resolution

### Integration Tests
- Test 1: Faction spawning in Phase 1 missions
- Test 2: Faction filtering by campaign phase
- Test 3: Unit roster generation for missions
- Test 4: Faction technology unlocks

### Manual Testing Steps
1. Run game with `lovec "engine"`
2. Start campaign in Phase 1
3. Launch UFO crash mission
4. Verify Sectoids spawn with correct units
5. Check unit stats match TOML
6. Progress to Phase 2
7. Verify aquatic factions now spawn
8. Check console for faction loading logs

---

## How to Run/Debug

### Running the Game
```bash
lovec "engine"
```

### Debugging
- Use `print("[FactionSystem] Loaded faction: " .. faction_id)`
- Use `print("[FactionSystem] Spawning unit: " .. unit_type)`
- Use `print("[FactionSystem] Active factions for phase: " .. phase_id)`
- Monitor faction loading in console

---

## Documentation Updates

### Files to Update
- [x] `docs/lore/factions/README.md`
- [x] Individual faction docs
- [x] `docs/modding/faction_creation.md`
- [ ] `wiki/API.md` - Add FactionSystem API
- [ ] `wiki/FAQ.md` - Add faction information

---

## Notes

- 15+ factions based on lore_ideas.md
- Each faction has distinct identity and role
- Faction progression mirrors campaign phases
- Unit rosters include soldier/leader/specialist
- Tech trees match campaign tech progression
- System designed for moddability

---

## Review Checklist

- [ ] All faction TOML files validate
- [ ] Unit rosters balanced
- [ ] Tech trees correct
- [ ] Faction relationships configured
- [ ] Phase filtering works
- [ ] Documentation complete
- [ ] Tests passing
