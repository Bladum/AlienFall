# AlienFall Design Specification Template

**Audience**: Game Designers | **Status**: Active | **Last Updated**: October 2025

Use this template for all new game design specifications. Complete all sections before implementation.

---

## Template

```markdown
# [Feature Name] Design Specification

**Designer**: [Your Name]
**Date**: [Date]
**Status**: [Draft | Review | Approved | Implemented]
**Complexity**: [Low | Medium | High]

---

## Overview

[1-2 paragraph summary of the feature and its purpose in the game]

---

## Design Goals

- [Goal 1]: [Why this matters]
- [Goal 2]: [Why this matters]
- [Goal 3]: [Why this matters]

---

## Mechanics & Rules

### Core Mechanic
[Clear explanation of how the feature works]

### Input/Triggers
- What triggers this feature?
- What input does the player provide?

### Output/Results
- What are the possible outcomes?
- How does this affect the game state?

### Edge Cases
- What happens if [edge case 1]?
- What happens if [edge case 2]?

---

## Examples

### Scenario 1
[Setup: What's the game state?]
[Action: What does the player do?]
[Result: What happens?]

### Scenario 2
[Setup]
[Action]
[Result]

---

## Balance Parameters

| Parameter | Value | Reasoning |
|-----------|-------|-----------|
| [Param 1] | [Value] | [Why this value?] |
| [Param 2] | [Value] | [Why this value?] |
| [Param 3] | [Value] | [Why this value?] |

---

## Difficulty Scaling

### Easy Mode
[Adjustments for easy difficulty]

### Normal Mode
[Default values from Balance Parameters]

### Hard Mode
[Adjustments for hard difficulty]

### Impossible Mode
[Adjustments for maximum difficulty]

---

## Testing Scenarios

- [ ] Test Scenario 1: [Description]
  - Expected: [Result]
  - Verify: [What to check]

- [ ] Test Scenario 2: [Description]
  - Expected: [Result]
  - Verify: [What to check]

---

## Related Features

- [Related Feature 1](../Mechanics.md#feature1)
- [Related Feature 2](../Mechanics.md#feature2)

---

## Implementation Notes

[Any special considerations for implementation]

---

## Review Checklist

- [ ] All mechanics clearly defined
- [ ] Edge cases addressed
- [ ] Examples provided and verified
- [ ] Balance parameters specified
- [ ] Difficulty scaling considered
- [ ] Testing scenarios documented
- [ ] No undefined terminology

---

**Status**: [Draft | Ready for Review | Approved for Implementation]
```

---

## How to Use This Template

### 1. Create New Design Doc

Copy this template:
```
TASK-XXX-description.md → docs/design/TASK-XXX-description.md
```

### 2. Fill Each Section

**Overview**: What is this feature? Why does it matter?

**Design Goals**: What does this feature accomplish? What player needs does it meet?

**Mechanics & Rules**: The actual rules of the feature. Be precise and testable.

**Examples**: Walk through concrete scenarios so implementation is clear.

**Balance Parameters**: What numbers drive the feature? Document each with reasoning.

**Difficulty Scaling**: How does the feature change at different difficulties?

**Testing**: What needs to be tested to verify it works?

### 3. Review & Iterate

1. Self-review for clarity
2. Get feedback from team
3. Revise based on feedback
4. Mark as "Approved for Implementation"

### 4. Implementation

1. Share design doc with implementer
2. Implementer creates parallel documentation of actual implementation
3. Compare design vs. implementation for gaps
4. Update if actual differs from design

---

## Example: Completed Design Doc

```markdown
# Escalation Meter Redesign

**Designer**: Game Designer
**Date**: Oct 2025
**Status**: Approved
**Complexity**: Medium

---

## Overview

The escalation meter tracks how aware and aggressive alien factions
become in response to player actions. It provides ongoing challenge
progression without fixed victory conditions.

---

## Design Goals

- Provide persistent threat that grows over time
- Create difficult decisions about mission priorities
- Enable "just one more turn" gameplay loop

---

## Mechanics & Rules

### Core Mechanic

Escalation meter (0-100%) increases when:
- Player completes successful missions (+10-20%)
- Destroys alien bases (+25%)
- Research completes (+5%)

Decreases when:
- Player loses ground battles (-15%)
- Loses craft to interception (-10%)

At thresholds (25%, 50%, 75%, 100%), alien behavior changes:
- 25%: Mission frequency increases 50%
- 50%: Alien bases generate stronger units
- 75%: UFO armada events trigger
- 100%: Maximum difficulty, most dangerous missions only

### Edge Cases

- Meter caps at 100% (can't go higher)
- Resets to 0% if player loses organization
- Stacks per faction (each has own meter)

---

## Examples

**Scenario**: Player completes first mission
- Start: Meter at 0%
- Action: Complete first UFO crash recovery
- Result: Meter increases to 15%, no behavior change

**Scenario**: Player reaches 50%
- Start: Meter at 48%
- Action: Complete alien base assault (+25%)
- Result: Meter reaches 73%, passes 50% threshold
- Effect: All alien units +2 stats, mission frequency increases

---

## Balance Parameters

| Parameter | Value | Reasoning |
|-----------|-------|-----------|
| Mission completion gain | +15% | Encourages active play |
| Base destruction gain | +25% | Rewards challenge |
| Failure penalty | -10% | Gives recovery chance |
| Armada threshold | 75% | Late-game milestone |
| Threshold effects | -25% each | Creates difficulty curves |

---

## Testing Scenarios

- [ ] Meter increases on mission completion
  - Expected: +15% for UFO mission, +25% for base mission
  - Verify: Check meter value after mission

- [ ] Thresholds trigger behavior changes
  - Expected: At 50%, alien unit stats increase
  - Verify: Compare unit stats before/after crossing 50%

- [ ] Meter caps at 100%
  - Expected: Cannot exceed 100%
  - Verify: Do missions repeatedly, check cap

---
```

---

## Common Design Mistakes to Avoid

❌ **Vague mechanics**: "Make it harder" - Too undefined
✅ **Specific mechanics**: "+2 to all alien unit stats" - Clear and testable

❌ **Missing edge cases**: "What if..." questions unanswered
✅ **Listed edge cases**: Each "what if" has explicit rule

❌ **No examples**: "It should feel good"
✅ **Concrete examples**: "In scenario X, Y happens because Z"

❌ **Undefined balance**: "Adjust the numbers"
✅ **Documented balance**: "Base health = 80, scaling factor = 1.1x per tier"

❌ **No testing strategy**: Assume it works
✅ **Clear testing**: "Test by doing X and checking Y"

---

## Quality Checklist

Before finalizing design:

- [ ] Every mechanic has specific numbers
- [ ] Every rule has an exception case documented
- [ ] Every parameter has reasoning
- [ ] Every scenario has clear example
- [ ] Difficulty variants specified
- [ ] Testing method for each feature
- [ ] Related features referenced
- [ ] All terminology defined
- [ ] Implementation clearly feasible
- [ ] Balance feels right intuitively

---

## Templates for Common Features

### Combat Balance

```
Base Damage: [number]
Range: [distance]
Accuracy: [percentage]
Fire Rate: [shots per turn]
Cost: [resources]
Difficulty Scaling: [multiplier per tier]
```

### Resource Economics

```
Production Rate: [units per day]
Consumption Rate: [units per facility]
Storage Capacity: [max units]
Difficulty Scaling: [% per tier]
```

### Unit Progression

```
Max Level: [number]
XP Per Kill: [amount]
Stats Per Level: [increases]
Special Abilities: [list]
Specializations: [paths]
```

---

## Related Documentation

- **[Balance Reference](BALANCE_REFERENCE.md)** - Current balance parameters
- **[Testing Methodology](TESTING_METHODOLOGY.md)** - How to test designs
- **[Design Decision Records](../architecture/README.md)** - Strategic decisions
- **[Game Mechanics Docs](../Geoscape.md)** - System mechanics

---

**Last Updated**: October 2025 | **Status**: Active | **Version**: 1.0

