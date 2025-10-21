# Phase 2 Task 3: TOML Format Specification - COMPLETE

**Status**: ✅ COMPLETE  
**Date Completed**: October 21, 2025  
**File Created**: `docs/TOML_SCHEMA_SPECIFICATION.md`  
**Time Spent**: ~45 minutes

---

## Overview

Created a **comprehensive TOML schema specification** for all 14 content types in AlienFall. This document serves as the definitive reference for modders, developers, and content creators, enabling community content creation and ensuring mod compatibility.

**Key Achievement**: Complete documentation of 14 content types with 25+ schemas, 30+ practical examples, and validation rules.

---

## Document Contents

### Section 1: Overview (Educational)
- Why TOML? (Human-readable, type-safe, version control friendly)
- Content Types (14 total) with brief descriptions
- Scope and purpose

### Section 2: File Structure (Organization)
- Complete directory hierarchy showing where each TOML file belongs
- Organized by content category (rules, technology, factions, economy, etc.)
- Path patterns for modders to follow

### Section 3: Schemas by Content Type (25+ Schemas)

Detailed documentation for each content type:

#### 1. **Mod Manifest** (`mod.toml`)
- Required fields: `id`, `name`, `version`, `description`
- Optional: `enabled`, `load_order`, `conflicts_with`, `requires`
- Path configuration for content directories

#### 2. **Weapons** (`weapons.toml`)
- Required: `id`, `name`, `type`, `damage`, `accuracy`, `range`, `ammo_type`, `cost`, `tech_level`
- Optional: `fire_rate`, `magazine_size`, `weight`, `critical_chance`, `armor_penetration`
- Example: Rifle (50 dmg, 70% acc, 25 range) vs. Plasma Rifle (70 dmg, 70% acc, plasma)

#### 3. **Armor** (`armor.toml`)
- Required: `id`, `name`, `armor_value`, `cost`, `tech_level`
- Optional: `weight`, `will_bonus`, `movement_penalty`, `special_protection`
- Examples: Light Combat Armor (30 protection) vs. Powered Armor (60 protection, +10 will)

#### 4. **Ammunition** (`ammo.toml`)
- Required: `id`, `name`, `for_weapon_type`, `cost`, `quantity`
- Simple flat structure for ammo definitions
- Links weapons to ammunition types

#### 5. **Equipment** (`equipment.toml`)
- Required: `id`, `name`, `equipment_type`, `cost`
- Types: grenade, medical, special, utility
- Optional: `effect`, `range`, `damage`, `usable_in_combat`

#### 6. **Facilities** (`base_facilities.toml`)
- Required: `id`, `name`, `type`, `width`, `height`, `cost`, `time_to_build`
- Optional: `maintenance_cost`, `capacity`, `production_rate`, `power_consumption/generation`, `requires_tech`
- Examples: Power Generator (1×1) vs. Workshop (2×2) vs. Advanced Lab (3×3)

#### 7. **Soldiers** (`soldiers.toml`)
- Required: `id`, `name`, `type`, `faction`, `side`, `rank`
- Stat block: `health`, `will`, `reaction`, `shooting`, `strength`, `psionic_power`
- Equipment block: `primary`, `secondary`, `armor`, `grenades`
- Examples: Rookie vs. Squaddie vs. Specialist

#### 8. **Aliens** (`aliens.toml`)
- Same stat structure as soldiers
- Additional: `armor_value`, `abilities`, `mission_weight`, `loot_table`
- Faction-based organization (sectoids, mutons, ethereals, etc.)

#### 9. **Technology** (`phase*.toml`)
- Phase-based structure: `[tech_phase0]`, `[tech_phase1]`, etc.
- Required: `id`, `name`, `phase`, `research_time`, `cost`
- Optional: `prerequisites`, `unlocks`, `startUnlocked`
- Progressive unlocking: Early techs (basic_weapons) → Late techs (plasma_weapons)

#### 10. **Factions** (`faction_*.toml`)
- Faction metadata: `id`, `name`, `type`, `tech_level`
- Characteristics: `psionic`, `aquatic`, `dimensional`, `primary_trait`
- Relationships: `allies`, `enemies`, `neutral`
- Unit roster with spawn weights and abilities

#### 11. **MapBlocks** (`mapblocks/*.toml`)
- Metadata: `id`, `name`, `width`, `height`, `group`, `difficulty`
- Tiles object: coordinate-based (`"x_y"` → tileset_id)
- 15×15 tile segments assembled into procedural maps
- Example: Farm field with fence perimeter, trees, well

#### 12. **MapScripts** (`mapscripts.toml`)
- Mission layout templates using MapBlocks
- Required: `id`, `name`, `mission_type`, `map_size`, `blocks`, `spawn_zones`
- Block placement with tags, weights, and required flags
- Spawn zones for player/aliens/civilians with scatter radius
- Environmental features: fire, smoke, debris, hazards
- 20+ mission templates documented (crash sites, terror attacks, base defense, alien bases, UFO landings)

#### 13. **Campaigns** (`campaign_timeline.toml`, etc.)
- Phase definition: `id`, `name`, `description`, `phase_number`
- Timeline milestones for narrative progression
- Active factions by phase
- Available mission types
- Tech availability by phase

#### 14. **Economy** (`suppliers.toml`)
- Supplier definitions: `name`, `description`, `region`, `pricing_tier`
- Inventory: `entries` (item IDs for sale)
- Relationships: `base_relationship`, `faction_requirement`
- Special: `requires_research`, `monthly_refresh_day`
- Examples: Military Surplus (budget), Advanced Defense (premium)

---

## Section 4: Common Patterns (Best Practices)

### Pattern 1: Array of Objects
```toml
[[weapon]]
id = "rifle"
# ...

[[weapon]]
id = "pistol"
# ...
```

### Pattern 2: Nested Objects
```toml
[unit.stats]
health = 30

[unit.equipment]
primary = "rifle"
```

### Pattern 3: Comments
```toml
# Full line comment
health = 30  # Inline comment
```

### Pattern 4: Arrays
```toml
prerequisites = ["tech1", "tech2"]
tags = "farmland, rural, trees"
```

---

## Section 5: Validation Rules

### ID Validation
- Format: lowercase + underscores only
- Pattern: `^[a-z0-9_]+$`
- Examples: `rifle`, `combat_armor_light`, `phase0_shadow_war`

### Numeric Ranges (with min/max limits)
- Damage: 1-200
- Accuracy: 0-150 (100% = guaranteed, 150% = guaranteed crit)
- Health: 1-999
- Cost: 0-999999
- Range: 1-100 tiles

### Type Safety
- Strings: Quotes required
- Integers: No quotes
- Floats: Decimal point
- Booleans: `true`/`false` lowercase
- Arrays: `["item1", "item2"]`

### Reference Validation
- IDs must be unique
- Referenced IDs must exist (weapon in equipment, tech in prerequisites)
- Circular dependencies not allowed

---

## Section 6: Complete Examples & Templates

**Weapon**: Plasma Rifle Advanced (75 dmg, 75% acc, plasma, armor penetration)  
**Facility**: Advanced Laboratory (3×3, research acceleration, tech requirements)  
**Unit**: Sniper Specialist (90 shooting, 28 health, sniper rifle + pistol)  
**MapScript**: UFO Landing with defensive emplacements and alien turrets  

Each example shows proper formatting, required vs. optional fields, and real values.

---

## Section 7: Modding Best Practices

1. **Naming Conventions**
   - IDs: snake_case (`combat_armor_light`)
   - Names: PascalCase (`Combat Armor - Light`)

2. **Organization**
   - One file per major category
   - Related items grouped
   - File size < 500 lines

3. **Documentation**
   - Add comments for non-obvious values
   - Document special effects
   - Include balance notes

4. **Compatibility**
   - Check conflicts with existing mods
   - Use unique ID prefixes
   - Document tech requirements

5. **Testing**
   - Validate TOML syntax
   - Test in-game
   - Check mod loading order
   - Verify cross-mod compatibility

---

## Section 8: Troubleshooting

**"Invalid TOML syntax"** → Check quotes, array brackets, table headers  
**"ID not found"** → Verify spelling, check mod load order, verify ID exists  
**"Type mismatch"** → Use correct types (integers no quotes, strings with quotes)  
**"Missing required field"** → Review schema, provide required fields  

---

## Section 9: Quick Reference Table

14 content types with file locations and purposes:

| Content Type | File | Purpose |
|---|---|---|
| Mod Manifest | `mod.toml` | Mod metadata |
| Weapons | `rules/items/weapons.toml` | Weapon definitions |
| Armor | `rules/items/armor.toml` | Armor definitions |
| Ammo | `rules/items/ammo.toml` | Ammunition definitions |
| Equipment | `rules/items/equipment.toml` | Equipment definitions |
| Facilities | `rules/facilities/*.toml` | Facility definitions |
| Soldiers | `rules/units/soldiers.toml` | Soldier definitions |
| Aliens | `rules/units/aliens.toml` | Alien definitions |
| Technology | `technology/*.toml` | Tech tree |
| Factions | `factions/*.toml` | Faction definitions |
| MapBlocks | `mapblocks/*.toml` | Tile blocks |
| MapScripts | `mapscripts/mapscripts.toml` | Mission layouts |
| Campaigns | `campaigns/*.toml` | Campaign definitions |
| Economy | `economy/*.toml` | Suppliers & items |

---

## Section 10: Next Steps for Modders

1. Read entire specification
2. Study example files in `mods/core/`
3. Create `mod.toml` with metadata
4. Add custom content using schemas
5. Validate TOML syntax
6. Test in-game with Love2D console
7. Document mod in README.md
8. Share with community

---

## Quality Metrics

**Specification Coverage**:
- ✅ 14/14 content types documented (100%)
- ✅ 25+ schemas with all required/optional fields
- ✅ 30+ working examples
- ✅ Validation rules for all numeric types
- ✅ Troubleshooting section
- ✅ Best practices guide
- ✅ Quick reference table

**Document Size**:
- Total length: ~2,000 lines
- Sections: 10 major sections
- Examples: 30+
- Schemas: 25+
- Tables: 8+

**Modder Readiness**:
- ✅ Complete reference documentation
- ✅ Copy-paste ready examples
- ✅ Clear validation rules
- ✅ Troubleshooting guide
- ✅ Best practices documented
- ✅ Quick lookup table

---

## Impact on Phase 2 Goals

**Task 3 Completion**:
- ✅ All 14 TOML schemas documented
- ✅ Examples provided for each type
- ✅ Validation rules specified
- ✅ Modding best practices included
- ✅ Production-ready documentation

**Enables**:
- Community mod creation
- Content modding support
- Clear technical specifications
- Mod validation and checking
- Developer onboarding

**Alignment Impact**:
- Before: Integration documentation incomplete
- After: Complete content type specifications
- Phase 2 Target: 95%+ alignment (on track)

---

## Document Location

**Main File**: `docs/TOML_SCHEMA_SPECIFICATION.md`

**Access**: 
- Reference for modders: `/docs/TOML_SCHEMA_SPECIFICATION.md`
- Link from mod README: Link to this specification
- Community wiki: Can be published for modders

---

## Next Tasks

**Task 4**: Create Integration Flow Diagrams (state transitions, data flow, save/load)  
**Task 5**: Complete Integration Testing (full game loop)  
**Task 6**: Document Error Recovery Scenarios  
**Task 7**: Gameplay Balance Testing  
**Task 8**: Create Developer Onboarding Guide  

---

## Summary

**Task 3: TOML Format Specification** is **COMPLETE** ✅

**Deliverables**:
- ✅ Comprehensive schema reference (2,000 lines)
- ✅ 25+ working schemas with examples
- ✅ Validation rules for all content types
- ✅ Troubleshooting and best practices
- ✅ Quick reference table
- ✅ Production-ready for community modding

**Status**: Ready for publication and community use

**Next**: Task 4 - Create Integration Flow Diagrams

