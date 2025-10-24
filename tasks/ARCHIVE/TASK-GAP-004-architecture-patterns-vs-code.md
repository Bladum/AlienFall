# TASK-GAP-004: Compare Architecture Patterns vs Engine Code

**Status:** TODO
**Priority:** MEDIUM
**Created:** October 23, 2025
**Estimated Time:** 6-8 hours
**Task Type:** Architecture Review + Code Audit

---

## Overview

Compare documented architectural patterns against actual engine code to verify:
1. Layered architecture properly implemented
2. Design patterns (ECS, state machine, event-driven) used correctly
3. System separation maintained
4. Integration patterns followed
5. Architectural principles violated anywhere

---

## Scope: TWO SOURCES ONLY

**Source A:** `architecture/` (documented patterns)
**Source B:** `engine/` (actual code patterns)

**Key Patterns to Verify:**
1. Layered Architecture
2. State Machine Pattern
3. ECS (Entity Component System)
4. Event-Driven Pattern
5. Dependency Injection / Modularity

---

## Pattern 1: Layered Architecture Verification (2 hours)

**Documented In:** `architecture/01-game-structure.md`

**Expected Layers:**
```
Presentation Layer
    ↓ (clean interface)
Game Logic Layer
    ↓ (clean interface)
System Layer
    ↓ (clean interface)
Data Layer
```

**Engine Implementation Check:**
- [ ] **Presentation:** Verify `engine/gui/`, `engine/*/rendering/` isolated
  - Should NOT call game logic directly
  - Should use events for updates
  - Should handle input only

- [ ] **Game Logic:** Verify `engine/core/`, `engine/battlescape/systems/`, `engine/basescape/`
  - Should NOT call rendering directly
  - Should use state management
  - Should communicate via events

- [ ] **System Layer:** Verify `engine/ai/`, `engine/core/pathfinding.lua`, `engine/economy/`
  - Should be reusable independent modules
  - Should NOT know about game rules
  - Should have clear interfaces

- [ ] **Data Layer:** Verify `engine/assets/`, `engine/core/data_loader.lua`, `engine/mods/`
  - Should be pure data storage
  - Should not contain logic
  - Should support loading/saving

**Violations to Document:**
- Rendering code calling game logic?
- Game logic calling UI?
- Cross-layer dependencies?

---

## Pattern 2: State Machine Verification (1.5 hours)

**Documented In:** `architecture/01-game-structure.md`

**Expected State Transitions:**
```
Menu → Geoscape → Battlescape → Basescape → (back to any)
```

**Engine Implementation Check:**
- [ ] **State Manager:** Verify `engine/core/state_manager.lua`
  - Centralized state control?
  - Prevents invalid transitions?
  - Proper lifecycle (init/update/draw/cleanup)?

- [ ] **State Transitions:** Check each game screen
  - Menu → Geoscape? ✅ (verified)
  - Geoscape → Battlescape? ✅ (verified)
  - Battlescape → Basescape? ⚠️ (check)
  - Basescape → Geoscape? ⚠️ (check)
  - Return to Menu? ✅ (verified)

- [ ] **State Data:** Verify state persistence
  - Campaign data survives Geoscape → Battlescape?
  - Unit state survives Battlescape → Basescape?
  - Equipment state survives transitions?

**Violations to Document:**
- Invalid state transitions possible?
- State data lost in transitions?
- Race conditions in transitions?

---

## Pattern 3: ECS (Entity Component System) Verification (1.5 hours)

**Documented In:** `architecture/03-combat-tactics.md`

**Expected in Battlescape:**
```
Entities (Units, Projectiles, Terrain)
    + Components (Health, Armor, Weapons)
    + Systems (CombatSystem, AbilitySystem, etc)
```

**Engine Implementation Check:**
- [ ] **ECS Framework:** Verify `engine/battlescape/battle_ecs/`
  - Proper entity creation?
  - Component attachment correct?
  - Systems process components?

- [ ] **Entity Types:** Check all entity types
  - Units: Components for health, armor, equipment?
  - Projectiles: Components for trajectory, damage?
  - Terrain: Components for destruction, cover?

- [ ] **Systems:** Verify all combat systems
  - AbilitiesSystem processes ability components?
  - CombatSystem processes health/damage?
  - CoverSystem processes cover components?
  - AmmoSystem tracks ammunition?

- [ ] **Performance:** Check ECS usage
  - Systems only iterate relevant components?
  - No direct entity access bypassing ECS?
  - Efficient component queries?

**Violations to Document:**
- Systems bypassing ECS?
- Inefficient component iteration?
- Direct entity manipulation?
- Missing component types?

---

## Pattern 4: Event-Driven Pattern Verification (1.5 hours)

**Documented In:** `architecture/01-game-structure.md` + `api/INTEGRATION.md`

**Expected Event System:**
- Central event bus
- Systems publish events
- Other systems subscribe
- Loose coupling between systems

**Engine Implementation Check:**
- [ ] **Event Bus:** Verify event system exists
  - Central EventBus implemented?
  - Events queued/processed properly?
  - No dropped events?

- [ ] **Event Usage:** Check systems use events
  - Mission completion raises event?
  - Facility constructed raises event?
  - Research completed raises event?
  - Personnel assigned raises event?

- [ ] **Event Subscribers:** Verify listeners respond
  - Mission completion → UI updates?
  - Research complete → triggers manufacturing?
  - Resource gathered → updates economy?

- [ ] **Event Decoupling:** Check systems are loose-coupled
  - Can remove system without breaking others?
  - Events don't contain tight references?
  - Can add new subscribers without modifying publishers?

**Violations to Document:**
- Direct function calls between systems instead of events?
- Tight coupling through direct references?
- Missing event subscriptions?
- Event bus underutilized?

---

## Pattern 5: Modularity & Dependency Injection (1 hour)

**Documented In:** `architecture/01-game-structure.md`

**Expected:**
- Loose coupling between modules
- Clear interfaces between systems
- Testable components
- Reusable systems

**Engine Implementation Check:**
- [ ] **System Independence:** Check each system
  - Can load without other systems?
  - Clear dependencies documented?
  - No circular dependencies?

- [ ] **Mod Loading:** Verify `engine/mods/mod_manager.lua`
  - Loads content before game starts?
  - Proper dependency injection?
  - Content systems isolated from code?

- [ ] **Reusability:** Check utility functions
  - Pathfinding used in multiple systems?
  - Spatial hash reusable?
  - Asset loading generic?

- [ ] **Testing:** Check if systems testable
  - Can mock dependencies?
  - Can test in isolation?
  - Unit tests exist?

**Violations to Document:**
- Circular dependencies?
- Hard-coded dependencies?
- Monolithic systems?
- Untestable code?

---

## Deliverables

### Architecture Compliance Report
**File:** `docs/ARCHITECTURE_COMPLIANCE_AUDIT.md`

Should contain:
- Pattern compliance score (per pattern)
- Violations identified
- Severity assessment
- Recommendations
- Refactoring priorities

### Specific Issues to Fix
Document each violation:
1. **What:** Describe the violation
2. **Where:** Show exact code locations
3. **Why:** Explain why it violates the pattern
4. **How:** Suggest fix
5. **Effort:** Estimate time to fix

### Code Quality Improvements
Identify opportunities to:
- Reduce coupling
- Improve testability
- Enhance reusability
- Increase performance
- Better follow patterns

---

## Success Criteria

✅ All 5 patterns verified
✅ Violations identified with code examples
✅ Severity assessed
✅ Refactoring priorities set
✅ Report created

---

## Related Files

**Compare These:**
- Architecture: `architecture/01-game-structure.md` (patterns) ↔ Code: `engine/core/state_manager.lua` + `engine/main.lua`
- Architecture: `architecture/03-combat-tactics.md` (ECS) ↔ Code: `engine/battlescape/battle_ecs/`
- API: `api/INTEGRATION.md` (events) ↔ Code: Event system search in engine

**Reference Report:** `design/gaps/ARCHITECTURE_ALIGNMENT.md` (Use for known issues)

---

**Task ID:** TASK-GAP-004
**Assignee:** [Architect]
**Due:** November 6, 2025
**Complexity:** High (deep pattern analysis)
