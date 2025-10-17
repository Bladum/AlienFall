# Task: Implement Technology Catalog

**Status:** TODO  
**Priority:** CRITICAL  
**Created:** January XX, 2026  
**Completed:** N/A  
**Assigned To:** AI Agent

---

## Overview

Implement complete technology catalog covering 4 campaign phases with weapon/armor/vehicle progression. Create TOML content files defining all researchable technology from 1996-2004, matching the campaign phase progression system.

---

## Purpose

The technology system needs content files to populate research trees, crafting, and equipment progression. This task creates the complete technology catalog from lore_ideas.md, enabling players to research and unlock phase-appropriate technology.

**Current State**: Tech system exists but lacks comprehensive content catalog  
**After This Task**: Complete 4-phase technology progression with 50+ items

---

## Requirements

### Functional Requirements
- [ ] Phase 0 tech (Ballistic weapons, civilian armor, basic vehicles)
- [ ] Phase 1 tech (Laser, Plasma, Power Suits, Interceptors)
- [ ] Phase 2 tech (Gauss, Sonic, Aqua Armor, Submarines)
- [ ] Phase 3 tech (Particle Beam, Dimensional Armor, Advanced Craft)
- [ ] Technology prerequisites and research chains
- [ ] Manufacturing requirements and costs
- [ ] Phase-based technology unlocking

### Technical Requirements
- [ ] Create phase tech TOML files in mods/core/technology/
- [ ] Define research tree dependencies
- [ ] Define manufacturing requirements
- [ ] Define equipment stats and effects
- [ ] Integrate with research and manufacturing systems

### Acceptance Criteria
- [ ] All 4 phases have complete tech catalogs
- [ ] Research trees properly linked
- [ ] Manufacturing costs balanced
- [ ] Equipment stats appropriate for phase
- [ ] Documentation complete
- [ ] Tests verify tech data loading

---

## Plan

### Step 1: Create Phase 0 Technology
**Description:** Ballistic weapons, civilian armor, basic vehicles  
**Files to create:**
- `mods/core/technology/phase0_technology.toml`

**Content**:
```toml
# Phase 0: Shadow War Technology (1996-1999)

[[weapon]]
id = "pistol_9mm"
name = "9mm Pistol"
phase = "phase0_shadow_war"
type = "ballistic"
damage = 12
accuracy = 65
range = 12
ammo_capacity = 15
manufacturing_cost = 200
research_required = []

[[weapon]]
id = "shotgun"
name = "Combat Shotgun"
phase = "phase0_shadow_war"
type = "ballistic"
damage = 30
accuracy = 50
range = 8
ammo_capacity = 8
manufacturing_cost = 400
research_required = []

[[weapon]]
id = "assault_rifle"
name = "Assault Rifle"
phase = "phase0_shadow_war"
type = "ballistic"
damage = 20
accuracy = 60
range = 20
ammo_capacity = 30
manufacturing_cost = 600
research_required = []

[[armor]]
id = "civilian_clothing"
name = "Civilian Clothing"
phase = "phase0_shadow_war"
protection = 0
weight = 0
manufacturing_cost = 0
research_required = []

[[armor]]
id = "ballistic_vest"
name = "Ballistic Vest"
phase = "phase0_shadow_war"
protection = 15
weight = 5
manufacturing_cost = 300
research_required = []

[[armor]]
id = "blackops_suit"
name = "BlackOps Tactical Suit"
phase = "phase0_shadow_war"
protection = 25
weight = 8
special_abilities = ["stealth_bonus", "night_vision"]
manufacturing_cost = 800
research_required = ["blackops_tech"]

[[vehicle]]
id = "civilian_car"
name = "Civilian Vehicle"
phase = "phase0_shadow_war"
type = "ground"
speed = 100
armor = 10
capacity = 4
manufacturing_cost = 5000
research_required = []
```

**Estimated time:** 4 hours

### Step 2: Create Phase 1 Technology
**Description:** Laser, Plasma, Power Suits, Interceptors  
**Files to create:**
- `mods/core/technology/phase1_technology.toml`

**Content**: Laser weapons (Laser Pistol, Rifle, Heavy), Plasma weapons (Pistol, Rifle, Heavy, Cannon), Power Suit armor, Interceptor/Firestorm craft

**Estimated time:** 6 hours

### Step 3: Create Phase 2 Technology
**Description:** Gauss, Sonic, Aqua Armor, Submarines  
**Files to create:**
- `mods/core/technology/phase2_technology.toml`

**Content**: Gauss weapons, Sonic weapons (Pistol, Pulser, Cannon), Aqua Plastic Armor, Magnetic Ion Armor, Barracuda/Manta submarines

**Estimated time:** 6 hours

### Step 4: Create Phase 3 Technology
**Description:** Particle Beam, Dimensional Armor, Advanced Craft  
**Files to create:**
- `mods/core/technology/phase3_technology.toml`

**Content**: Particle Beam weapons, Phase Disruptors, Vortex weapons, Dimensional Phase Armor, Quantum Weave, advanced interceptors

**Estimated time:** 6 hours

### Step 5: Create Research Tree Dependencies
**Description:** Define research prerequisites and unlock chains  
**Files to create:**
- `mods/core/technology/research_tree.toml`

**Content**: Research dependencies (e.g., Plasma Rifle requires Plasma Physics + Alien Weapons), unlock conditions, research costs

**Estimated time:** 3 hours

### Step 6: Integration with Research/Manufacturing
**Description:** Connect tech catalog to game systems  
**Files to modify:**
- Research system integration
- Manufacturing system integration
- Equipment system integration

**Estimated time:** 3 hours

### Step 7: Documentation
**Description:** Complete technology catalog documentation  
**Files to create:**
- `docs/lore/technology_catalog.md` - Complete tech list
- `docs/modding/technology_creation.md` - TOML tech guide

**Estimated time:** 2 hours

### Step 8: Testing
**Description:** Unit tests and integration tests  
**Test cases:**
- Tech TOML loading
- Research tree validation
- Manufacturing requirements
- Phase-based unlocking

**Files to create:**
- `tests/lore/test_technology_catalog.lua`

**Estimated time:** 2 hours

---

## Implementation Details

### Technology Progression
**Phase 0 (1996-1999)**: Ballistic → BlackOps specialized  
**Phase 1 (1999-2001)**: Laser → Plasma → Psionics  
**Phase 2 (2001-2002)**: Gauss → Sonic → Aquatic  
**Phase 3 (2003-2004)**: Particle Beam → Dimensional → Endgame

### Weapon Tiers
- **Ballistic** (Phase 0): 9mm, Shotgun, Assault Rifle, Sniper Rifle
- **Laser** (Phase 1): Laser Pistol, Rifle, Heavy Laser
- **Plasma** (Phase 1): Plasma Pistol, Rifle, Heavy Plasma, Cannon
- **Gauss** (Phase 2): Gauss Pistol, Rifle, Heavy Gauss
- **Sonic** (Phase 2): Sonic Pistol, Pulser, Cannon
- **Particle Beam** (Phase 3): Particle Beam Pistol, Rifle, Heavy

### Armor Tiers
- **Civilian** (Phase 0): Clothing, Ballistic Vest
- **Basic** (Phase 1): Personal Armor, Power Suit, Flying Suit
- **Aquatic** (Phase 2): Aqua Plastic, Magnetic Ion, Triton Armor
- **Dimensional** (Phase 3): Phase Armor, Quantum Weave

### Vehicles
- **Phase 0**: Civilian vehicles, helicopters
- **Phase 1**: Interceptor, Firestorm, Skyranger
- **Phase 2**: Barracuda, Manta, Leviathan (submarines)
- **Phase 3**: Dimensional Interceptor, Gate Breaker

---

## Testing Strategy

### Unit Tests
- Test 1: Load all phase tech TOML files
- Test 2: Validate research tree dependencies
- Test 3: Validate manufacturing requirements
- Test 4: Check equipment stat ranges

### Integration Tests
- Test 1: Research unlocks phase-appropriate tech
- Test 2: Manufacturing produces correct items
- Test 3: Equipment equips with correct stats
- Test 4: Phase transitions unlock new tech tiers

### Manual Testing
1. Start Phase 0 campaign
2. Research ballistic tech
3. Progress to Phase 1
4. Research laser tech
5. Verify plasma tech requires laser research
6. Test all weapon types
7. Verify armor progression

---

## Documentation Updates

- [x] `docs/lore/technology_catalog.md`
- [x] `docs/modding/technology_creation.md`
- [ ] `wiki/API.md` - Add Technology API
- [ ] `wiki/FAQ.md` - Add tech progression info

---

## Review Checklist

- [ ] All tech TOML files validate
- [ ] Research trees correct
- [ ] Manufacturing costs balanced
- [ ] Equipment stats appropriate
- [ ] Phase progression smooth
- [ ] Documentation complete
- [ ] Tests passing
