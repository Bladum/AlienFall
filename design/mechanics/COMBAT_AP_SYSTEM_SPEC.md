# Combat Action Point (AP) System Specification

**Status:** Complete Specification
**Version:** 1.0
**Created:** 2025-10-31
**Last Updated:** 2025-10-31

---

## Overview

The Action Point (AP) system is the core tactical resource that governs unit actions in Battlescape combat. AP represents a unit's tactical flexibility and ability to respond to battlefield situations. This specification resolves all contradictions and provides definitive rules for implementation.

---

## Core AP Values

### Base Action Points
- **Base AP per turn**: 4 (fixed across all units)
- **Minimum AP**: 1 (guaranteed after all penalties applied)
- **Maximum AP**: 4 (standard maximum without bonuses)
- **Maximum with bonuses**: 5 (achievable through rare exceptional circumstances)

### Valid Range
- **Standard range**: 1-4 AP per turn
- **Exceptional range**: 1-5 AP per turn (with positive modifiers)

---

## Penalty Application System

### Application Order
Penalties are applied in the following order to ensure consistent calculation:

1. Start with base 4 AP
2. Apply health penalties
3. Apply morale penalties
4. Apply sanity penalties
5. Apply status effect penalties (stun, suppression)
6. Apply bonuses
7. Clamp to valid range (minimum 1, maximum 5)

### Health Penalties

**Exact Thresholds**:
- **Health ≤ 50% of maximum**: -1 AP
- **Health ≤ 25% of maximum**: -2 AP (cumulative with above penalty)

**Calculation Example**:
```
Unit with 20/20 health (100%): No penalty
Unit with 10/20 health (50%): -1 AP
Unit with 9/20 health (45%): -1 AP
Unit with 5/20 health (25%): -2 AP
Unit with 4/20 health (20%): -2 AP
```

### Morale Penalties

**Thresholds**:
- **Morale ≤ 2**: -1 AP per turn
- **Morale ≤ 1**: -2 AP per turn
- **Morale = 0**: Unit cannot act (0 AP, but clamped to minimum 1)

### Sanity Penalties

**Thresholds**:
- **Sanity < 50**: -1 AP per turn

### Status Effect Penalties

**Stun Effect**:
- **Stunned units**: -2 AP (loses most of turn)
- **Implementation**: Stunned units can spend their remaining AP to recover from stun

**Suppression**:
- **Suppressed units**: Actions limited but AP unchanged
- **Effect**: Cannot perform certain actions (shoot, throw) but can move or use items

---

## Bonus Sources

### Positive Modifiers

**Trait Bonuses**:
- **Agile trait** (Rank 2+): +1 AP
- **Requires**: Unit must have Agile trait equipped

**Equipment Bonuses**:
- **Heroic Stimulant** (item): +1 AP (one-time use, risky)
- **Psionic Amplifier** (equipment): No direct AP bonus

**Situational Bonuses**:
- **Leadership Aura**: +1 AP when within 8 hexes of leader unit
- **Adrenaline Surge**: +1 AP when under direct fire (temporary)

**Maximum Stacking**: Bonuses can stack to reach 5 AP maximum

---

## Movement System Integration

### Movement Action Model (Chosen Formula)

**Core Rule**: Movement is a dedicated action that costs 1 AP and grants movement equal to the unit's Speed stat in hexagons.

**Formula**:
```
Movement Action Cost: 1 AP
Movement Distance: Speed stat hexagons
```

**Examples**:
- Speed 6 unit: 1 AP = 6 hexagons of movement
- Speed 9 unit: 1 AP = 9 hexagons of movement
- Speed 12 unit: 1 AP = 12 hexagons of movement

### Movement Action Details

**Requirements**:
- Must be continuous path (no teleportation)
- Cannot exceed movement allowance in one action
- Can be combined with other actions in the same turn

**Terrain Effects**:
- **Difficult terrain**: Costs additional movement points
- **Impassable terrain**: Blocks movement entirely

**Armor Weight Penalties**:
- **Light armor**: No movement penalty
- **Medium armor**: Speed -1 for movement calculations
- **Heavy armor**: Speed -2 for movement calculations

### Turn Structure Example

**Unit with 4 AP and Speed 8**:
```
Turn 1 Actions:
- Movement (1 AP): Move 8 hexagons
- Shoot (1 AP): Fire weapon
- Movement (1 AP): Move additional 8 hexagons
- Use Item (1 AP): Throw grenade

Total: 4 AP used, full tactical flexibility
```

---

## Action Cost Reference

### Standard Action Costs

| Action Type | AP Cost | Notes |
|-------------|---------|-------|
| **Movement** | 1 | Grants Speed hexagons of movement |
| **Shoot** | 1-2 | 1 AP for aimed shot, 2 AP for snapshot |
| **Melee Attack** | 1 | Close combat |
| **Throw Grenade** | 1 | Standard grenade throw |
| **Use Item** | 1 | Medkit, scanner, etc. |
| **Reload** | 1 | Weapon reload action |
| **Overwatch** | 2 | Set up reaction fire |
| **Rest** | 2 | Recover morale (+1 morale) |
| **Rally** | 4 | Restore ally morale (+2 to target) |

### Special Action Costs

| Special Action | AP Cost | Conditions |
|----------------|---------|------------|
| **Psionic Attack** | 2-3 | Requires psionic amplifier |
| **Transformation** | 3 | Special ability |
| **Hack Terminal** | 2 | Requires technician skill |
| **Rescue Ally** | 1 | Must be adjacent to incapacitated unit |

---

## Difficulty Scaling

### Easy Mode
- **Base AP**: 5 (more generous)
- **Health penalty threshold**: Health ≤ 40% (-1 AP), Health ≤ 20% (-2 AP)
- **Morale penalty threshold**: Morale ≤ 1 (-1 AP), Morale = 0 (-2 AP)
- **Result**: Units stay effective longer, more forgiving combat

### Normal Mode
- **Base AP**: 4 (standard)
- **Health penalty threshold**: Health ≤ 50% (-1 AP), Health ≤ 25% (-2 AP)
- **Morale penalty threshold**: Morale ≤ 2 (-1 AP), Morale ≤ 1 (-2 AP)
- **Result**: Balanced tactical challenge

### Hard Mode
- **Base AP**: 4 (same as normal)
- **Health penalty threshold**: Health ≤ 60% (-1 AP), Health ≤ 30% (-2 AP)
- **Morale penalty threshold**: Morale ≤ 3 (-1 AP), Morale ≤ 2 (-2 AP)
- **Result**: Units become ineffective faster, higher tactical pressure

---

## Implementation Examples

### Example 1: Healthy Soldier
```
Base AP: 4
Health: 100/100 (100%) → No penalty
Morale: 8 → No penalty
Sanity: 10 → No penalty
No status effects
No bonuses

Final AP: 4
Movement: 1 AP = 6 hexagons (assuming Speed 6)
```

### Example 2: Wounded Soldier
```
Base AP: 4
Health: 8/20 (40%) → -1 AP (≤50%)
Morale: 2 → No penalty (>2)
Sanity: 8 → No penalty (≥50)
No status effects
No bonuses

Final AP: 3
Movement: 1 AP = 6 hexagons
```

### Example 3: Critical Soldier
```
Base AP: 4
Health: 4/20 (20%) → -2 AP (≤25%)
Morale: 1 → -2 AP (≤1)
Sanity: 3 → -1 AP (<50)
Stunned: -2 AP

Subtotal: 4 - 2 - 2 - 1 - 2 = -3 AP
Clamp to minimum: 1 AP

Final AP: 1
Movement: 1 AP = 6 hexagons (uses entire turn)
```

### Example 4: Elite Soldier with Bonuses
```
Base AP: 4
Health: 100/100 → No penalty
Morale: 10 → No penalty
Sanity: 10 → No penalty
No status effects
Agile trait: +1 AP
Leadership aura: +1 AP

Subtotal: 4 + 1 + 1 = 6 AP
Clamp to maximum: 5 AP

Final AP: 5
Movement: 1 AP = 6 hexagons each
```

---

## Code Implementation Pattern

```lua
function calculate_unit_ap(unit)
    local ap = 4  -- Base AP

    -- Health penalties (exact thresholds)
    local health_percent = (unit.health / unit.max_health) * 100
    if health_percent <= 50 then
        ap = ap - 1
    end
    if health_percent <= 25 then
        ap = ap - 1  -- Cumulative
    end

    -- Morale penalties
    if unit.morale <= 2 then
        ap = ap - 1
    end
    if unit.morale <= 1 then
        ap = ap - 1  -- Cumulative
    end

    -- Sanity penalties
    if unit.sanity < 50 then
        ap = ap - 1
    end

    -- Status effect penalties
    if unit.is_stunned then
        ap = ap - 2
    end

    -- Bonuses
    if unit:has_trait("agile") then
        ap = ap + 1
    end
    if unit:in_leadership_aura() then
        ap = ap + 1
    end

    -- Clamp to valid range
    ap = math.max(1, ap)  -- Minimum 1
    ap = math.min(5, ap)  -- Maximum 5

    return ap
end
```

---

## Testing Validation

### Unit Tests Required
- [ ] Base AP calculation (4 AP for healthy unit)
- [ ] Health penalty application (≤50% = -1, ≤25% = -2)
- [ ] Morale penalty application (≤2 = -1, ≤1 = -2)
- [ ] Sanity penalty application (<50 = -1)
- [ ] Stun penalty application (-2 AP)
- [ ] Bonus stacking (Agile + Leadership = +2)
- [ ] Range clamping (minimum 1, maximum 5)
- [ ] Cumulative penalties (all penalties together)

### Integration Tests Required
- [ ] Movement distance calculation (Speed × hexagons per AP)
- [ ] Turn progression (AP reset each turn)
- [ ] Action cost validation (all actions cost correct AP)
- [ ] Status effect interaction (stun prevents most actions)
- [ ] Difficulty scaling (Easy/Hard mode differences)

### Manual Testing Scenarios
1. **Full Health Unit**: Verify 4 AP, full movement/action capability
2. **Wounded Unit**: Verify reduced AP, limited actions
3. **Stunned Unit**: Verify severe AP reduction, limited options
4. **Elite Unit**: Verify bonus AP, enhanced capability
5. **Difficulty Modes**: Verify different penalty thresholds

---

## Related Systems

- **Units.md**: Core unit statistics and AP definitions
- **Battlescape.md**: Combat system integration
- **MoraleBraverySanity.md**: Psychological state effects on AP
- **Items.md**: Equipment that modifies AP (stimulants, etc.)

---

## Change History

- **v1.0** (2025-10-31): Complete AP system specification with resolved contradictions
  - Defined exact health penalty thresholds (≤50%, ≤25%)
  - Established movement action model (1 AP = Speed hexagons)
  - Set maximum AP at 5 (with bonuses)
  - Created comprehensive examples and implementation code</content>
<parameter name="filePath">c:\Users\tombl\Documents\Projects\design\mechanics\COMBAT_AP_SYSTEM_SPEC.md
