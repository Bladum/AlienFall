# Content Override System

> **Purpose:** Complete guide to modifying, extending, and overriding existing game content in Alien Fall.

---

## Overview

The Content Override System allows mods to modify existing game content without replacing files or conflicting with other mods. This system uses **declarative data merging** with configurable strategies to ensure compatibility.

---

## Core Concepts

### Override vs Extension

**Override:** Replace specific values while keeping others
```toml
# Override rifle damage only
[[weapon]]
id = "rifle_assault"  # Same ID as base game
damage = 45           # Changed (was 35)
# accuracy, range, etc. inherited from base
```

**Extension:** Add new content alongside existing
```toml
# Add new rifle variant
[[weapon]]
id = "mymod_rifle_advanced"  # New ID
base_template = "rifle_assault"
damage = 50
name = "Advanced Assault Rifle"
```

---

## Merge Strategies

Configure how your mod merges with existing content in `mod.toml`:

```toml
[mod.load]
content_strategy = "patch"  # Options: "patch", "merge", "replace"
```

### Patch Strategy (Default)

Modifies specific fields only, inherits rest from base.

**Best for:** Balance tweaks, stat adjustments

```toml
# Base game weapon
[[weapon]]
id = "rifle_assault"
damage = 35
accuracy = 80
range = 20

# Your mod (patch strategy)
[[weapon]]
id = "rifle_assault"
damage = 45  # Only this changes

# Result
damage = 45      # From mod
accuracy = 80    # From base
range = 20       # From base
```

---

### Merge Strategy

Combines arrays and tables, keeps newest values for primitives.

**Best for:** Adding options, expanding lists

```toml
# Base game weapon
[[weapon]]
id = "rifle_assault"
fire_modes = ["single", "burst"]
tags = ["rifle", "military"]

# Your mod (merge strategy)
[[weapon]]
id = "rifle_assault"
fire_modes = ["auto"]      # Adds to existing
tags = ["advanced"]        # Adds to existing

# Result
fire_modes = ["single", "burst", "auto"]
tags = ["rifle", "military", "advanced"]
```

---

### Replace Strategy

Completely overrides base content.

**Best for:** Total conversions, complete redesigns

```toml
# Base game weapon (ignored)
[[weapon]]
id = "rifle_assault"
damage = 35
accuracy = 80
range = 20

# Your mod (replace strategy)
[[weapon]]
id = "rifle_assault"
damage = 100
range = 50
# accuracy not specified = not present

# Result (only mod values)
damage = 100
range = 50
# No accuracy field
```

---

## Per-Type Override Rules

### Weapons

```toml
[[weapon]]
id = "rifle_assault"              # REQUIRED: Must match existing ID

# Override specific stats
[weapon.stats]
damage = 45                       # Override damage
accuracy = 85                     # Override accuracy
# range inherited if not specified

# Add new fire modes (merge)
[weapon.fire_modes]
auto = true

# Override requirements
[weapon.requirements]
research = ["advanced_ballistics"] # Replace research requirements
```

**Inheritance Rules:**
- Stats: Individual field override
- Requirements: Complete replacement
- Fire modes: Additive (merge)
- Tags: Additive (merge)

---

### Units

```toml
[[unit_class]]
id = "soldier_assault"

# Override base stats
[unit_class.base_stats]
health = 120                      # Override (was 100)
accuracy = 85                     # Override (was 80)
# Other stats inherited

# Add new traits (merge)
[unit_class.traits]
possible_traits = ["tough", "mymod_veteran"]

# Override progression
[unit_class.progression]
xp_per_level = 150                # Override (was 100)
```

---

### Missions

```toml
[[mission]]
id = "extraction_standard"

# Override difficulty
[mission.parameters]
difficulty = 4                    # Override (was 3)

# Add new objectives (merge)
[mission.objectives]
secondary = ["mymod_bonus_objective"]

# Override rewards
[mission.rewards]
credits = 2000                    # Override (was 1500)
```

---

### Research

```toml
[[research_entry]]
id = "plasma_weapons"

# Override research time
[research_entry.requirements]
time = 72                         # Override (was 96 hours)

# Override costs
[research_entry.costs]
credits = 8000                    # Override (was 10000)

# Add new unlocks (merge)
[research_entry.unlocks]
items = ["mymod_plasma_pistol"]   # Added to existing unlocks
```

---

## Advanced Override Techniques

### Conditional Overrides

Override content only when certain conditions are met:

```toml
[mod.overrides.rifle_assault]
condition = "difficulty >= 2"     # Only on medium+ difficulty
damage = 40
```

---

### Percentage Modifications

Modify values by percentage rather than absolute:

```toml
[mod.overrides.all_weapons]
damage_multiplier = 1.25          # +25% damage to all weapons
accuracy_multiplier = 0.9         # -10% accuracy to all weapons
```

---

### Bulk Overrides

Override multiple items with filters:

```toml
[mod.bulk_overrides]
# All rifles get +5 damage
[[mod.bulk_overrides.rule]]
filter = { type = "rifle" }
changes = { damage = "+5" }

# All alien units get +20 health
[[mod.bulk_overrides.rule]]
filter = { faction = "alien" }
changes = { health = "+20" }
```

---

## Conflict Resolution

### Load Priority

Higher priority mods override lower priority mods:

```toml
[mod.load]
priority = 75  # Higher number = loads later = overrides earlier mods
```

**Priority Ranges:**
- 0-25: Framework mods
- 26-50: Content mods (default)
- 51-75: Balance mods
- 76-100: Compatibility patches

---

### Explicit Conflicts

Declare known conflicts in manifest:

```toml
[mod.compatibility]
conflicts = [
    "weapon_overhaul",     # Incompatible
    "legacy_weapons_mod"   # Conflicts with same changes
]
```

Game will:
1. Warn player about conflicts
2. Prevent loading conflicting mods together
3. Show conflict resolution UI

---

### Override Tracking

See which mod last modified content:

```lua
local weapon = modAPI:getData("weapons/rifle_assault")
local provenance = weapon._metadata.modified_by

modAPI:log("Last modified by: " .. provenance.mod_id)
modAPI:log("At priority: " .. provenance.priority)
```

---

## Override Debugging

### Console Commands

```lua
-- View override history
/mod_trace rifle_assault

-- Output:
-- Base Game: damage=35, accuracy=80
-- mod_balance_v1 (priority 60): damage=40
-- mod_realism_v2 (priority 70): accuracy=75
-- Final: damage=40, accuracy=75

-- List all overrides by mod
/mod_overrides mymod

-- Check for conflicts
/mod_conflicts
```

---

### Validation

Enable override validation in dev mode:

```toml
[mod.load]
validate_overrides = true  # Warn about potential issues
```

**Warnings Generated:**
- Override of non-existent content
- Type mismatches (string vs number)
- Missing required fields after override
- Circular dependencies
- Suspicious value ranges

---

## Examples

### Example 1: Weapon Rebalance

**Scenario:** Make all rifles more accurate but slower

**File:** `data/overrides/rifle_rebalance.toml`

```toml
# Override all assault rifles
[[weapon]]
id = "rifle_assault"
[weapon.stats]
accuracy = 90    # +10
ap_cost = 4      # +1 (was 3)

[[weapon]]
id = "rifle_sniper"
[weapon.stats]
accuracy = 95    # +5
ap_cost = 5      # +1 (was 4)

[[weapon]]
id = "rifle_heavy"
[weapon.stats]
accuracy = 75    # +5
ap_cost = 6      # +1 (was 5)
```

---

### Example 2: Research Speed Boost

**Scenario:** Faster early-game research

**File:** `data/overrides/research_speed.toml`

```toml
# All tier 1 research
[[research_entry]]
id = "basic_weapons"
[research_entry.requirements]
time = 24  # Was 48 hours

[[research_entry]]
id = "basic_armor"
[research_entry.requirements]
time = 24  # Was 48 hours

# Use bulk override for all tier 1
[mod.bulk_overrides]
[[mod.bulk_overrides.rule]]
filter = { tier = 1 }
changes = { time = "*0.5" }  # Half time for all tier 1
```

---

### Example 3: Mission Rewards Increase

**Scenario:** Double mission rewards

**File:** `data/overrides/mission_rewards.toml`

```toml
# Bulk override all missions
[mod.bulk_overrides]
[[mod.bulk_overrides.rule]]
filter = { type = "mission" }
changes = {
    credits = "*2.0",
    experience = "*2.0"
}
```

---

### Example 4: Unit Stat Tweaks

**Scenario:** Buff soldiers, nerf aliens

**File:** `data/overrides/unit_balance.toml`

```toml
# Soldier buffs
[[unit_class]]
id = "soldier_assault"
[unit_class.base_stats]
health = 120  # +20
accuracy = 85 # +5

[[unit_class]]
id = "soldier_heavy"
[unit_class.base_stats]
health = 140  # +20
strength = 90 # +10

# Alien nerfs
[[unit_class]]
id = "alien_sectoid"
[unit_class.base_stats]
health = 60   # -10
accuracy = 70 # -5

[[unit_class]]
id = "alien_muton"
[unit_class.base_stats]
damage_reduction = 0.15  # -0.05
```

---

## Compatibility Patches

### Creating Compatibility Patches

When mods conflict, create a compatibility patch:

**File:** `mod.toml`

```toml
[mod]
id = "compat_mod_a_and_mod_b"
name = "Mod A + Mod B Compatibility"
version = "1.0.0"

[mod.compatibility]
dependencies = ["mod_a:>=1.0.0", "mod_b:>=2.0.0"]

[mod.load]
priority = 90  # Load after both mods
```

**File:** `data/compatibility_fixes.toml`

```toml
# Resolve conflict between Mod A and Mod B
[[weapon]]
id = "rifle_assault"
damage = 42           # Compromise between Mod A (40) and Mod B (45)
accuracy = 82         # Average of both mods
```

---

## Best Practices

### DO:
✅ Use unique mod ID prefixes for new content  
✅ Document what you override in README  
✅ Test with popular mods  
✅ Use appropriate priority levels  
✅ Provide compatibility patches when possible  
✅ Keep overrides focused and minimal  

### DON'T:
❌ Override without good reason  
❌ Use priority 100 unless truly necessary  
❌ Make breaking changes in patch versions  
❌ Forget to test vanilla compatibility  
❌ Override core game mechanics without documentation  

---

## Testing Overrides

### Test Checklist

- [ ] Load game with only your mod enabled
- [ ] Load game with popular mods
- [ ] Check console for override warnings
- [ ] Verify values in-game match expectations
- [ ] Test that base game still functions
- [ ] Check for performance issues
- [ ] Test save/load compatibility

### Test Script

```lua
-- tests/test_overrides.lua
local test = require('test_framework')

test.describe("Weapon Override Tests", function()
    
    test.it("should override rifle damage", function()
        local rifle = modAPI:getData("weapons/rifle_assault")
        test.expect(rifle.stats.damage).to.equal(45)
    end)
    
    test.it("should preserve unmodified stats", function()
        local rifle = modAPI:getData("weapons/rifle_assault")
        test.expect(rifle.stats.range).to.equal(20)  -- Not overridden
    end)
    
    test.it("should track modification provenance", function()
        local rifle = modAPI:getData("weapons/rifle_assault")
        test.expect(rifle._metadata.modified_by.mod_id).to.equal("mymod")
    end)
    
end)
```

---

## Troubleshooting

### Override Not Working

**Problem:** Changes don't appear in-game

**Solutions:**
1. Check mod load order (lower priority might be overridden)
2. Verify ID matches exactly (case-sensitive)
3. Check console for validation errors
4. Ensure content_strategy is appropriate
5. Clear data cache and reload

---

### Unexpected Values

**Problem:** Values different than specified

**Solutions:**
1. Check if another mod with higher priority overrides
2. Use `/mod_trace <id>` to see override chain
3. Verify merge strategy is correct
4. Check for bulk override rules affecting content

---

### Conflicts with Other Mods

**Problem:** Mod works alone but not with others

**Solutions:**
1. Check load order and priorities
2. Create compatibility patch
3. Use conditional overrides
4. Document known conflicts
5. Contact other mod author for collaboration

---

## Advanced Topics

### Dynamic Overrides

Apply overrides based on runtime conditions:

```lua
-- scripts/dynamic_overrides.lua
modAPI:subscribe("game:loaded", function()
    local difficulty = modAPI:getService("game"):getDifficulty()
    
    if difficulty >= 3 then
        -- Hard mode: reduce weapon damage
        modAPI:overrideData("weapons/rifle_assault", {
            stats = { damage = 30 }
        })
    end
end)
```

---

### Version-Specific Overrides

Different overrides for different game versions:

```toml
[mod.overrides.v0_5_0]
game_version = "0.5.0"
# Overrides for 0.5.0

[mod.overrides.v0_6_0]
game_version = ">=0.6.0"
# Different overrides for 0.6.0+
```

---

## Additional Resources

- **[Modding Hub](README.md)** - Main modding documentation
- **[API Reference](API_Reference.md)** - Programmatic overrides
- **[Data Formats](Data_Formats.md)** - Content schemas
- **[Getting Started](Getting_Started.md)** - Basic modding tutorial

---

## Tags
`#modding` `#override` `#compatibility` `#data` `#merge`
