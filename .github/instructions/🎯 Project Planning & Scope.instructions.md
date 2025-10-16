# 🎯 Project Planning & Scope Best Practices

**Domain:** Project Management & Planning  
**Focus:** Task estimation, feature breakdown, scope creep prevention, sprint planning  
**Version:** 1.0  
**Date:** October 2025

## Table of Contents

1. [Planning Fundamentals](#planning-fundamentals)
2. [Breaking Down Features](#breaking-down-features)
3. [Task Estimation](#task-estimation)
4. [Scope Management](#scope-management)
5. [Sprint Planning](#sprint-planning)
6. [Risk Assessment](#risk-assessment)
7. [Dependencies & Blocking](#dependencies--blocking)
8. [Prioritization Frameworks](#prioritization-frameworks)
9. [Capacity Planning](#capacity-planning)
10. [Tracking Progress](#tracking-progress)
11. [Handling Changes](#handling-changes)
12. [Team Communication](#team-communication)
13. [Planning for AI Agents](#planning-for-ai-agents)
14. [Common Planning Mistakes](#common-planning-mistakes)
15. [Planning Checklist](#planning-checklist)

---

## Planning Fundamentals

### ✅ DO: Define Clear Acceptance Criteria

**Every task needs SMART criteria:**

```markdown
# Task: Implement Sniper Unit Type

## Goal
Add sniper unit to game with distinct tactical role (high damage, slow reload).

## Acceptance Criteria
- [x] Stats defined: 60 damage, 85 accuracy, 3s reload
- [x] Sprite created (24x24 pixel art)
- [x] Unit can be spawned in battlescape
- [x] Stats display correctly in UI
- [x] All 5 balance tests pass
- [x] Performance benchmark shows <1ms per sniper update
- [x] No console errors in 10-minute gameplay session
- [x] Works correctly with other weapon types
- [x] Documentation updated in units/README.md
- [x] Code reviewed and approved

## Definition of "Done"
- Builds without warnings
- All tests pass
- Works on target hardware
- Code reviewed
- Documented
```

**Why specific criteria matter:**
- Prevents ambiguity
- Makes review easier
- Defines "done" objectively
- Helps with estimation

---

### ✅ DO: Estimate with Uncertainty

**Don't estimate as single number. Use ranges:**

```markdown
# Task Estimates

## Bad Estimation
"Implementation: 2 days"
(Too specific, usually wrong)

## Good Estimation
"Implementation: 2-3 days (with 2 days risk buffer)"
- Optimistic: 1.5 days (if everything goes smoothly)
- Realistic: 2 days (with 1-2 complications)
- Pessimistic: 3.5 days (if major issues found)
- Risk buffer: 2 days (account for unknowns)
- Total: 3-5.5 days

## Recommendation
"Start: 2 days. Revisit if > 2.5 days without major progress."
```

---

### ❌ DON'T: Commit to "Rough Estimates" as Final

**Problem:** Initial estimates often 30-50% off. They improve with research.

```markdown
# Better Estimation Process

## Phase 1: Initial Rough Estimate (1 hour)
"Looks like 3-5 days"

## Phase 2: Spike/Research (4 hours)
- Investigate unknown areas
- Check existing code patterns
- Ask experienced people

## Phase 3: Refined Estimate (2 hours)
"Actually: 2-4 days after investigating"

## Phase 4: Planning (1 hour)
"Let's plan it as: 3 days, with risks known"
```

---

## Breaking Down Features

### ✅ DO: Use User Story Mapping

**Large feature broken into stories:**

```markdown
# Feature: Battlescape Difficulty Scaling

## Epic: Dynamic Difficulty System
Adjust mission difficulty based on player performance.

### Story 1: Capture Player Performance Data
- Track wins/losses per difficulty
- Record player casualty rates
- Store data in save file
- Estimate: 2-3 days

### Story 2: Calculate Recommended Difficulty  
- Analyze performance trends
- Suggest difficulty adjustment
- Add suggestion to UI
- Estimate: 1-2 days

### Story 3: Implement Difficulty Effects
- Adjust enemy unit count
- Modify enemy AI aggression
- Change mission rewards
- Estimate: 2-3 days

### Story 4: Testing & Balance
- Test all difficulty levels
- Gather player feedback
- Adjust thresholds
- Estimate: 2 days

## Total: 7-10 days
```

---

### ✅ DO: Define Task Dependencies

```markdown
# Dependency Graph

```
Player Performance Tracking (2-3 days)
  ↓ (needs data)
Difficulty Calculation (1-2 days)
  ↓ (needs formula)
Difficulty Effects (2-3 days)
  ↓ (parallel: Testing, Balance tuning)
QA & Balance (2 days)
  ↓
Complete
```

**Key insight:** Can't do Difficulty Calculation without Performance Data.

---

## Task Estimation

### ✅ DO: Use Planning Poker

**Team-based estimation improves accuracy:**

1. Read story aloud
2. Each person secretly estimates (1-13)
3. Reveal: If close, that's estimate. If divergent, discuss why.
4. Re-estimate with new info

```markdown
# Example Estimation

Story: "Implement damage falloff system"

Round 1 Votes:
- Person A: 3 days (familiar with physics)
- Person B: 8 days (hasn't done this)
- Person C: 5 days

Discussion:
- A: "Physics is straightforward, just distance formula"
- B: "But we need to integrate with existing damage calc"
- C: "And need extensive testing"

Round 2 Votes:
- Person A: 4 days (accounting for integration)
- Person B: 6 days (convinced it's less than thought)
- Person C: 5 days

Consensus: 5 days
```

---

### ✅ DO: Track Estimation Accuracy

```markdown
# Estimation Accuracy Report

| Task | Estimated | Actual | Ratio |
|------|-----------|--------|-------|
| Unit pooling | 3 days | 2.5 days | 83% |
| UI redesign | 5 days | 7 days | 140% |
| Balance tuning | 2 days | 3 days | 150% |
| Pathfinding | 4 days | 3.5 days | 88% |
| **Average** | | | **115%** |

Insights:
- Underestimate: Complex systems, cross-cutting concerns
- Accurate: Well-defined tasks in familiar areas
- Pattern: Add 15% buffer to estimates
```

---

### ❌ DON'T: Pad Estimates for Pressure

**Bad:** Estimating 5 days because manager says "need it in 3"

**Reality:** False estimates lead to:
- Broken promises
- Crunch
- Lower quality
- Team burnout

**Better:**
- Estimate honestly
- Scope down if timeline firm
- Adjust timeline if scope firm
- Communicate tradeoffs clearly

---

## Scope Management

### ✅ DO: Manage Scope Creep

**Scope creep kills projects. Track it:**

```markdown
# Scope Management Log

## Feature: Sniper Unit

### Original Scope
- [ ] Unit stats
- [ ] Sprite
- [ ] Integration
**Estimate: 3 days**

### Scope Creep Attempts (REJECTED)
- ❌ "Can we add ghillie suit variants?" → NO (separate feature)
- ❌ "Can we add team sniper bonuses?" → NO (defer to v1.1)
- ❌ "Can we add scoped view?" → NO (too much scope creep)
- ❌ "Can we balance against all 15 unit types?" → PARTIAL (core types only)

### Scope Creep Allowed (JUSTIFIED)
- ✅ "Need counter-ability for sniper overpower risk" → Added (scope justified)

### Final Scope (stays as planned)
**Estimate: 3 days** (no change)
```

---

### ✅ DO: Use "Parking Lot" for Ideas

```markdown
# Project: Battlescape AI

## Current Sprint (Oct 16 - Oct 30)
- [x] Implement flanking tactics
- [x] Add suppression system
- [ ] (in progress) Balance enemy squads

## Parking Lot (Future Features)
- "Squad retreat mechanics" → v1.3
- "AI learning from player" → v2.0
- "Dynamic difficulty" → v1.2
- "Commander override orders" → Backlog

This parking lot prevents scope creep while capturing ideas.
```

---

### ✅ DO: Define MVP (Minimum Viable Product)

```markdown
# MVP vs. Final Feature

## MVP: Sniper Unit (what we MUST ship)
- Sprite: basic soldier with rifle
- Stats: higher damage than soldier
- Integration: works in existing battle system
- **Effort: 2 days**

## v1.1 Additions (what we CAN add later)
- Unique sniper sprite (gillie suit)
- Scoped view mode
- Unique animations
- **Effort: 3 days**

## v2.0 Additions (future versions)
- Team bonuses for sniper pairs
- Counter-sniper mechanics
- Customization

Strategy: Ship MVP fast, iterate based on feedback.
```

---

## Sprint Planning

### ✅ DO: Capacity-Based Planning

```markdown
# Sprint Planning Oct 16-30 (2 weeks)

## Team Capacity
- Person A: 10 days (full time)
- Person B: 5 days (part-time)  
- Person C: 0 days (off-site)
- **Total: 15 days of capacity**

## Available Work (in priority order)
1. Fix pathfinding corner cases: 3 days
2. Implement sniper unit: 3 days
3. Improve animation system: 4 days
4. Add new weapon type: 2 days
5. Balance tweaks: 3 days

## Sprint Allocation
- Pathfinding (3 days) - MUST DO
- Sniper (3 days) - MUST DO
- Animation (4 days) - MUST DO
- Weapon type (2 days) - NICE TO HAVE
- **Total: 12 days allocated of 15 available**

## Buffer: 3 days
- Unexpected issues
- Code review iterations
- Bug fixes
- Emergency support
```

---

### ✅ DO: Track Burndown

```markdown
# Sprint Burndown Oct 16-30

Day 1 (Oct 16): 120 hours remaining → start
Day 2 (Oct 17): 114 hours remaining → on track
Day 3 (Oct 18): 110 hours remaining → on track
Day 5 (Oct 21): 95 hours remaining → good progress
Day 7 (Oct 23): 88 hours remaining → slight slip (3 hours)
Day 8 (Oct 24): 75 hours remaining → caught up
Day 10 (Oct 28): 35 hours remaining → on track
Day 11 (Oct 29): 10 hours remaining → good
Day 12 (Oct 30): 0 hours remaining → DONE!

Pattern: Slight mid-sprint dip (normal), recovered well.
```

---

## Risk Assessment

### ✅ DO: Identify Risks Early

```markdown
# Risk Assessment

## High Risk Items

### Risk: New AI Squad Tactics (Est. 4 days)
- **Issue:** Unproven algorithm, unknown complexity
- **Probability:** 60% (will hit issues)
- **Impact:** High (core feature)
- **Mitigation:** 
  - Do spike research first (2 days)
  - Implement simple version first, enhance later
  - Plan for 5-6 days instead of 4
- **Owner:** Person A

### Risk: Save Game Format Migration (Est. 3 days)
- **Issue:** Must support v3 and v4 formats
- **Probability:** 70% (always has issues)
- **Impact:** Very High (can break saves)
- **Mitigation:**
  - Test on existing v3 saves
  - Test on v4 test cases
  - Have rollback plan
  - Plan for 4-5 days instead of 3
- **Owner:** Person B

## Medium Risk Items
(Similar analysis for each)
```

---

### ✅ DO: Have Contingency Plans

```markdown
# Contingency Plans

## If Squad AI Takes Longer Than Expected
Plan A (first choice): Reduce AI complexity, defer advanced tactics to v1.1
Plan B (if A not viable): Reduce other tasks, extend AI time
Plan C (fallback): Ship with basic AI only, iterate post-release

## If Save Migration Breaks Existing Saves
Plan A (first choice): Rollback format, fix code
Plan B (if A not viable): Auto-migrate and validate
Plan C (fallback): Ask players to reset (bad option, last resort)
```

---

## Dependencies & Blocking

### ✅ DO: Map Dependencies Visually

```markdown
# Dependency Map

```
Core Entity System (DONE)
  ├─→ Unit Types (3 days)
  │    ├─→ AI System (4 days)
  │    │    └─→ Squad Tactics (2 days) → FINAL
  │    └─→ Weapon System (2 days)
  │         └─→ Balance Testing (2 days)
  └─→ UI System (2 days)
```

**Critical path:** Entity → Unit Types → AI → Squad Tactics (11 days minimum)

**Non-critical:** UI can happen in parallel.

---

### ✅ DO: Unblock Explicitly

```markdown
# Blocking Issues

## Blocked: Weapon Balance (blocked by AI system)
- Task: Balance weapon damage
- Blocked by: AI system not complete
- Blocker owner: Person A
- Expected unblock date: Oct 25
- Workaround: Use placeholder AI stats for testing
- Assigned: Person B (waiting on Person A)
```

---

## Prioritization Frameworks

### ✅ DO: Use RICE Scoring

```markdown
# RICE Prioritization

## RICE = Reach × Impact × Confidence / Effort

### Feature: Dynamic Difficulty
- Reach: 80% of players
- Impact: 3 (very high - affects retention)
- Confidence: 60% (some uncertainty)
- Effort: 3 person-weeks
- **RICE: 80 × 3 × 0.6 / 3 = 48**

### Feature: Weapon Cosmetics
- Reach: 100% (all players)
- Impact: 1 (low - cosmetic)
- Confidence: 100%
- Effort: 2 person-weeks
- **RICE: 100 × 1 × 1 / 2 = 50**

### Feature: Campaign Mode
- Reach: 100% (all players)
- Impact: 4 (critical feature)
- Confidence: 70%
- Effort: 8 person-weeks
- **RICE: 100 × 4 × 0.7 / 8 = 35**

## Priority Order (by RICE score)
1. Weapon Cosmetics (50)
2. Dynamic Difficulty (48)
3. Campaign Mode (35)

Note: Cosmetics ranks high despite low impact because so easy (great ROI).
```

---

## Capacity Planning

### ✅ DO: Plan Realistic Hours

```markdown
# Realistic Capacity Calculation

## Team Member: 40 hour/week full-time

### Time Allocation
- Coding/Implementation: 25 hours/week (63%)
- Code review/meetings: 8 hours/week (20%)
- Debugging/unexpected: 5 hours/week (12%)
- Breaks, lunch, misc: 2 hours/week (5%)
- **Total: 40 hours**

### Net Productive Time Per Week
25 hours (not 40!)

## For 2-Week Sprint
25 hours/week × 2 weeks = **50 hours available**

## Common Mistake
Assigning 80 hours of work (40 hours × 2 weeks) instead of 50.
Result: Tasks get delayed, team frustrated.
```

---

## Tracking Progress

### ✅ DO: Track with Certainty Levels

```markdown
# Progress Tracking

## Story: "Implement Squad Tactics AI"

### Week 1
- Status: 40% done
- Certainty: "Pretty sure" - still investigating
- Risks identified: Algorithm complexity higher than thought
- Revised estimate: 4 days → 5 days
- Action: Continue investigation

### Week 2
- Status: 75% done
- Certainty: "Very confident" - core algorithm working
- Remaining: Testing, balance, edge cases
- On track: Yes, will finish on time (adjusted estimate)
- Action: Code review ready mid-week

### End of Sprint
- Status: 100% done
- Certainty: "Done-done" - all tests pass, reviewed, merged
- Actual time: 4.8 days (within adjusted estimate)
```

---

## Handling Changes

### ✅ DO: Change Management Process

```markdown
# Change Request: "Add Thermal Vision to Sniper"

## Step 1: Document Request
- **Requestor:** Designer
- **Description:** Sniper can toggle thermal imaging to see heat signatures
- **Why:** Would make sniper more unique and powerful
- **When needed:** "Soon" (vague)

## Step 2: Impact Analysis
- **Scope impact:** +2 days (new UI, new mechanic)
- **Performance impact:** +5% GPU time (thermal overlay)
- **Balance impact:** Sniper becomes 30% stronger
- **Risk:** Might make sniper overpowered

## Step 3: Decision
- **Decision:** DEFER TO V1.1
- **Reason:** Current sprint at capacity, good for post-release iteration
- **Alternative:** Could reduce another feature instead
- **Communicat: "Great idea! Let's do it post-release based on player feedback"

## Step 4: Document Decision
- Added to "Parking Lot" for v1.1 planning
- Decision logged in DECISIONS.md
```

---

## Team Communication

### ✅ DO: Status Updates for Transparency

```markdown
# Sprint Status Update - Week 1 (Oct 16-20)

## Completed
- ✅ Pathfinding corner case fix (3 days) - ON TIME
- ✅ Sniper unit sprite (0.5 days) - EARLY

## In Progress
- 🔄 Sniper unit stats/integration (1.5 of 2.5 days) - ON TRACK
- 🔄 New weapon type (1 of 2 days) - SLIGHT SLIP (0.5 days)

## Blocked
- ⏸️ AI balance testing (blocked by AI system, expected unblock: Oct 25)

## Risks Identified
- Animation system more complex than expected (estimate: 4 → 5 days)
- Mid-sprint review: Still on track overall

## Next Week Plans
- Complete sniper integration
- Start animation improvements
- Begin balance testing once AI ready
```

---

## Planning for AI Agents

### ✅ DO: Clear Handoff Documents

```markdown
# Handoff Document for AI Agent

## Current Sprint Status
- Progress: 60% complete
- Timeline: On track for Oct 30 release
- Major blocker: None currently

## What's Planned Next
1. Complete weapon balance testing (2 days) - START NOW
2. Add new unit type (3 days) - START AFTER BALANCE
3. Performance optimization (2 days) - PARALLEL TRACK

## Detailed Task Breakdown

### Task: Complete Weapon Balance Testing (2 days)

**What needs to be done:**
- Test sniper vs. 5 common unit types
- Log win/loss/casualty rates
- Identify overpowered/underpowered combinations
- Adjust damage values if needed

**How to approach:**
- See docs/GAME_NUMBERS.md for current balance values
- See tests/balance/weapons_test.lua for existing tests
- Add 10+ test scenarios per weapon pair
- Document findings in BALANCE_REPORT.md

**Acceptance criteria:**
- [ ] All 5 unit types tested vs sniper
- [ ] Balance report completed
- [ ] Damage adjustments made if needed
- [ ] All tests pass

**Known risks:**
- Might discover sniper is overpowered
- Might require recursive balancing (if we nerf sniper, soldier becomes weak)

**When stuck:**
- Balance questions: Ask @designer
- Code questions: See weapon balancing examples in weapons.lua line 234-256
- Testing: Use debug mode (press D)

**Success looks like:**
- Sniper has <55% win rate vs other units (balanced)
- No unit type counters sniper 90%+ (would be unfair)
```

---

## Common Planning Mistakes

### ❌ Mistake: Estimating Without Information

**Bad:** "Complex AI system: 5 days" (without research)

**Better:**
- Spike 1 day: Research existing patterns, investigate complexity
- Refined estimate: 7 days (with new info)

---

### ❌ Mistake: No Scope Definition

**Bad:** "Add difficulty scaling" (vague)

**Better:** "Add difficulty scaling: track player performance, suggest difficulty, adjust enemy count/AI aggression" (specific)

---

### ❌ Mistake: Ignoring Risk

**Bad:** Estimating 3 days for risky feature with 70% failure probability

**Better:** Estimating 4-5 days, planning contingency

---

### ❌ Mistake: Over-Committing Capacity

**Bad:** 15 capacity days but 20 days of work planned

**Better:** Plan 12-14 days work in 15 available (leave buffer)

---

## Planning Checklist

- [ ] Define clear acceptance criteria for each task
- [ ] Estimate with ranges and uncertainty
- [ ] Break features into smaller stories
- [ ] Identify dependencies and blocking
- [ ] Assess risks and mitigation strategies
- [ ] Plan capacity realistically (not maximum hours)
- [ ] Track and communicate progress
- [ ] Leave buffer for unexpected issues
- [ ] Have contingency plans
- [ ] Document decisions and scope decisions
- [ ] Review estimation accuracy
- [ ] Update plans based on learnings

---

## References

- User Story Mapping: https://www.jpattonassociates.com/
- RICE Prioritization: https://www.reforge.com/
- Agile Estimation: https://www.mountaingoatsoftware.com/
- The Phoenix Project: Excellent for understanding constraints and flow

