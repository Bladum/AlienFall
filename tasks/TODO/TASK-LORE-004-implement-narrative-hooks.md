# Task: Implement Narrative Hooks System

**Status:** TODO  
**Priority:** HIGH  
**Created:** January XX, 2026  
**Completed:** N/A  
**Assigned To:** AI Agent

---

## Overview

Implement narrative hooks system that provides dynamic storytelling through research discoveries, alien interrogations, and diplomatic events. Create Lua system and TOML content files defining narrative triggers and story beats across the campaign.

---

## Purpose

The narrative hooks system drives immersive storytelling by revealing lore through gameplay actions. Currently, there's no system for delivering narrative content dynamically. This task creates the system and content from lore_ideas.md section 15 (Narrative Hooks).

**Current State**: No narrative hooks system exists  
**After This Task**: Complete dynamic narrative system with 50+ story beats

---

## Requirements

### Functional Requirements
- [ ] Research discovery hooks (e.g., discovering plasma weapons reveals Sectoid origin)
- [ ] Interrogation hooks (e.g., interrogating Sectoid Leader reveals invasion plan)
- [ ] Diplomatic event hooks (e.g., successful mission improves country relations)
- [ ] Phase transition story beats (e.g., Phase 0 → Phase 1 First Contact narrative)
- [ ] Conditional narrative based on player choices
- [ ] Lore encyclopedia integration

### Technical Requirements
- [ ] Create engine/lore/narrative_hooks.lua
- [ ] Create mods/core/lore/narrative_events.toml
- [ ] Hook into research completion
- [ ] Hook into interrogation results
- [ ] Hook into mission outcomes
- [ ] Hook into phase transitions
- [ ] UI for displaying narrative content

### Acceptance Criteria
- [ ] Narrative hooks trigger at appropriate times
- [ ] Research discoveries reveal lore
- [ ] Interrogations provide intel
- [ ] Diplomatic events trigger story beats
- [ ] Lore encyclopedia populated
- [ ] Documentation complete
- [ ] Tests verify hook triggering

---

## Plan

### Step 1: Create Narrative Hooks System
**Description:** Core Lua system for managing narrative triggers  
**Files to create:**
- `engine/lore/narrative_hooks.lua`

**Key functions**:
```lua
-- Trigger narrative hook from research
function NarrativeHooks:onResearchComplete(research_id)
    -- Find narrative events linked to this research
    -- Display lore entry, update encyclopedia
    -- Unlock related narrative branches
end

-- Trigger narrative hook from interrogation
function NarrativeHooks:onInterrogationComplete(alien_type, info_gained)
    -- Reveal intel based on alien type
    -- Update strategic layer knowledge
    -- Unlock new research options
end

-- Trigger narrative hook from diplomacy
function NarrativeHooks:onDiplomaticEvent(country_id, event_type, outcome)
    -- Country reactions to player actions
    -- Funding changes based on success/failure
    -- Unlock/lock diplomatic options
end

-- Trigger narrative hook from phase transition
function NarrativeHooks:onPhaseTransition(old_phase, new_phase)
    -- Major story beat (e.g., First Contact)
    -- Update world state
    -- Reveal new narrative threads
end
```

**Estimated time:** 6 hours

### Step 2: Create Narrative Content (Research Hooks)
**Description:** Define narrative events for research discoveries  
**Files to create:**
- `mods/core/lore/narrative_events_research.toml`

**Content**:
```toml
# Research-triggered narrative hooks

[[narrative_hook]]
id = "research_plasma_weapons"
trigger_type = "research_complete"
trigger_id = "plasma_weapons"
title = "Plasma Weapons Discovery"
lore_entry = """
Analysis of alien plasma weapons reveals revolutionary energy containment technology.
The Sectoids have mastered controlled plasma projection at temperatures exceeding 10,000°C.
Our scientists theorize this tech originates from a more advanced civilization.
"""
unlocks = ["plasma_physics", "alien_alloys"]
encyclopedia_category = "technology"

[[narrative_hook]]
id = "research_alien_origins"
trigger_type = "research_complete"
trigger_id = "alien_biology"
title = "Alien Origins"
lore_entry = """
DNA analysis reveals Sectoid genetic markers inconsistent with natural evolution.
Evidence suggests extensive genetic engineering by an unknown precursor race.
The implications are disturbing: these aliens are manufactured, not evolved.
"""
unlocks = ["genetic_engineering", "precursor_theory"]
encyclopedia_category = "lore"

# ... (30+ more research hooks)
```

**Estimated time:** 4 hours

### Step 3: Create Narrative Content (Interrogation Hooks)
**Description:** Define narrative events for alien interrogations  
**Files to create:**
- `mods/core/lore/narrative_events_interrogation.toml`

**Content**:
```toml
# Interrogation-triggered narrative hooks

[[narrative_hook]]
id = "interrogate_sectoid_soldier"
trigger_type = "interrogation_complete"
trigger_id = "sectoid_soldier"
title = "Sectoid Soldier Interrogation"
intel_gained = """
Subject reveals fragmented memories of a distant star system.
Psionics allow limited mind-reading: invasion orchestrated by 'Ethereal Overseers'.
Sectoids are terrified of their masters, suggesting coercion rather than loyalty.
"""
unlocks = ["psionic_interrogation", "ethereal_hierarchy"]
strategic_info = { alien_base_locations = 1, ufo_patterns = "revealed" }
encyclopedia_category = "factions"

[[narrative_hook]]
id = "interrogate_muton_commander"
trigger_type = "interrogation_complete"
trigger_id = "muton_commander"
title = "Muton Commander Interrogation"
intel_gained = """
Subject reveals tactical data on alien base locations.
Mutons serve as enforcers for Sectoid operations.
Commander mentions 'Cydonia' - possible alien HQ on Mars?
"""
unlocks = ["alien_base_detection", "mars_mission"]
strategic_info = { alien_base_locations = 3, mars_coordinates = "revealed" }
encyclopedia_category = "factions"

# ... (20+ more interrogation hooks)
```

**Estimated time:** 3 hours

### Step 4: Create Narrative Content (Diplomatic Hooks)
**Description:** Define narrative events for diplomatic outcomes  
**Files to create:**
- `mods/core/lore/narrative_events_diplomacy.toml`

**Content**:
```toml
# Diplomacy-triggered narrative hooks

[[narrative_hook]]
id = "diplomatic_success_terror_mission"
trigger_type = "mission_complete"
trigger_id = "terror_mission"
outcome = "success"
country_reaction = """
[Country] expresses gratitude for swift action.
Public panic levels decrease. Funding increased by 10%.
Government officials request regular briefings on alien threat.
"""
effects = { panic_reduction = 20, funding_bonus = 10 }

[[narrative_hook]]
id = "diplomatic_failure_terror_mission"
trigger_type = "mission_complete"
trigger_id = "terror_mission"
outcome = "failure"
country_reaction = """
[Country] condemns XCOM's inability to protect citizens.
Public panic increases. Funding cut by 15%.
Government considers withdrawing from XCOM project.
"""
effects = { panic_increase = 30, funding_penalty = 15 }

# ... (15+ more diplomatic hooks)
```

**Estimated time:** 3 hours

### Step 5: Create Narrative Content (Phase Transition Hooks)
**Description:** Define major story beats for phase transitions  
**Files to create:**
- `mods/core/lore/narrative_events_phases.toml`

**Content**:
```toml
# Phase transition narrative hooks

[[narrative_hook]]
id = "phase0_to_phase1_first_contact"
trigger_type = "phase_transition"
old_phase = "phase0_shadow_war"
new_phase = "phase1_sky_war"
title = "First Contact"
story_beat = """
[Cinematic: UFO crashes in rural area]

After months of covert operations, undeniable proof arrives: we are not alone.

The crash site contains technology decades beyond human capability.
The occupants are dead, but their bodies defy explanation.
Grey skin. Large eyes. Psionic residue.

The Shadow War is over. The Sky War has begun.

XCOM is officially sanctioned by the UN. Funding increases.
All nations commit resources to the defense of Earth.
"""
effects = { funding_multiplier = 1.5, unlock_missions = ["ufo_crash", "ufo_landing"] }

[[narrative_hook]]
id = "phase1_to_phase2_uso_emergence"
trigger_type = "phase_transition"
old_phase = "phase1_sky_war"
new_phase = "phase2_deep_war"
title = "Unidentified Submerged Objects"
story_beat = """
[Cinematic: USO emerges from ocean depths]

Victory against the Sectoid fleet is short-lived.

New contacts emerge from the ocean floor. Aquatic species.
Coastal cities report attacks. Submarines go missing.

A second front has opened. The Deep War begins.

XCOM establishes underwater operations division.
"""
effects = { unlock_missions = ["uso_crash", "underwater_base"], unlock_tech = ["aquatic_operations"] }

# ... (Phase 2 → Phase 3 transition)
```

**Estimated time:** 2 hours

### Step 6: UI Integration
**Description:** Create UI widgets for displaying narrative content  
**Files to create:**
- `engine/ui/narrative_popup.lua` - Popup for lore entries
- `engine/ui/lore_encyclopedia.lua` - Encyclopedia browser

**Estimated time:** 3 hours

### Step 7: Integration with Game Systems
**Description:** Hook narrative system into research, interrogation, missions, phases  
**Files to modify:**
- Research system → call NarrativeHooks:onResearchComplete()
- Interrogation system → call NarrativeHooks:onInterrogationComplete()
- Mission system → call NarrativeHooks:onDiplomaticEvent()
- Phase manager → call NarrativeHooks:onPhaseTransition()

**Estimated time:** 3 hours

### Step 8: Documentation
**Description:** Document narrative hooks system  
**Files to create:**
- `docs/lore/narrative_hooks.md`
- `docs/modding/narrative_events.md`

**Estimated time:** 2 hours

### Step 9: Testing
**Description:** Unit tests and integration tests  
**Test cases:**
- Narrative hooks trigger correctly
- Lore entries display
- Encyclopedia updates
- Phase transitions show story beats

**Files to create:**
- `tests/lore/test_narrative_hooks.lua`

**Estimated time:** 2 hours

---

## Implementation Details

### Narrative Hook Types
1. **Research Hooks**: Triggered when research completes
2. **Interrogation Hooks**: Triggered when alien interrogated
3. **Diplomatic Hooks**: Triggered by mission outcomes
4. **Phase Transition Hooks**: Triggered by campaign progression

### Hook Effects
- Unlock new research options
- Reveal strategic information (alien base locations, UFO patterns)
- Update lore encyclopedia
- Modify country relations
- Change funding levels
- Unlock narrative branches

### Dependencies
- engine/lore/campaign/phase_manager.lua (from TASK-LORE-001)
- Research system
- Interrogation system
- Mission outcome system

---

## Testing Strategy

### Unit Tests
- Test 1: Narrative hook triggering
- Test 2: Lore entry display
- Test 3: Encyclopedia population
- Test 4: Effect application

### Integration Tests
- Test 1: Research completion triggers narrative
- Test 2: Interrogation reveals intel
- Test 3: Mission outcome affects diplomacy
- Test 4: Phase transition shows story beat

### Manual Testing
1. Complete research project
2. Verify narrative popup appears
3. Check encyclopedia updated
4. Interrogate alien
5. Verify intel gained
6. Complete terror mission
7. Verify country reaction
8. Transition to new phase
9. Verify story beat displayed

---

## Documentation Updates

- [x] `docs/lore/narrative_hooks.md`
- [x] `docs/modding/narrative_events.md`
- [ ] `wiki/API.md` - Add NarrativeHooks API
- [ ] `wiki/FAQ.md` - Add narrative system info

---

## Review Checklist

- [ ] Narrative hooks trigger correctly
- [ ] Lore entries well-written
- [ ] Encyclopedia integration works
- [ ] UI displays narrative properly
- [ ] Documentation complete
- [ ] Tests passing
