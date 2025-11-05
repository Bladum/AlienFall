# AlienFall Game Design Gap Analysis

> **Analysis Date:** November 2, 2025
> **Analyst:** Game Design Perspective
> **Status:** Critical Issues Identified
> **Scope:** Design mechanics, balance, player experience, narrative integration
> **Severity Levels:** 🔴 Critical | 🟠 High | 🟡 Medium | 🟢 Low

---

## Executive Summary

AlienFall has **exceptionally comprehensive design documentation** with 25+ mechanics files, 564+ documented mechanics, and well-structured systems. However, analysis from a **game design perspective** reveals significant **gaps in gameplay depth, decision space, and narrative integration** that could undermine the core promise of "interesting decisions" and "emergent gameplay."

**Key Findings:**
- ✅ **Technical Design:** 90% - Systems well-specified
- ⚠️ **Player Experience:** 65% - Decision space under-explored
- ⚠️ **Narrative Integration:** 40% - Story largely disconnected
- ⚠️ **Emergence & Depth:** 55% - Systems deterministic, limited interaction
- ❌ **Design Rationale:** 60% - Many parameters lack justification

**Immediate Actions Required:**
1. Define decision space for each layer (Geoscape, Basescape, Battlescape)
2. Clarify economy incentives and late-game scaling
3. Specify campaign escalation mechanics completely
4. Integrate narrative with gameplay consequences
5. Justify balance parameters with design reasoning

---

## 1. 🔴 CRITICAL: Decision Space Under-Specification

**Problem:** Core design principle states "interesting decisions" but decision space not articulated.

### 1.1 - Geoscape Decisions (Repetitive)

**Current State:**
- Monthly decisions: Deploy craft (where?), defend (which region?), research (next tech?), recruit (more units?)
- After initial setup, loop becomes: respond to alien threat → defend → research → repeat

**Gaps:**
- ❌ No mention of strategic positioning (building bases in specific locations for advantage)
- ❌ No mention of economic opportunities (trade routes, resource hubs, contested territories)
- ❌ No mention of diplomatic gameplay (forming alliances vs. going independent)
- ❌ No mention of tech path tradeoffs (rushing weapons vs. armor vs. facilities)
- ❌ Limited discussion of "pivot" moments (when player changes strategy mid-campaign)

**Questions Designers Should Answer:**
- What makes one base location strategically superior to another? (Beyond "near enemies")
- How does player choice of research path meaningfully change future options?
- What's the equivalent of "X-COM's fuel crisis" - a decision point that forces player hand?
- How do diplomatic relations create strategic tension?

**Example from X-COM:** Players had to choose: defend funding countries (diplomatic win path) vs. pursue research-only path vs. intercept UFOs (military win path). Different paths required different base locations, unit types, and research priorities.

**Design Recommendation:**
Create 2-3 **"Strategic Pivots"** that force decisions:
- **The Alliance Question** (Month 3-4): Form diplomatic coalition (easier but limited choices) vs. independent (harder but more freedom)
- **The Technology Question** (Month 6-8): Pursue alien reverse-engineering (opens portal but attracts more aliens) vs. conventional tech (slower but safer)
- **The Territory Question** (Month 10+): Expand bases (economic pressure) vs. consolidate (stability)

---

### 1.2 - Basescape Decisions (Formulaic)

**Current State:**
- Facility construction follows economy-driven logic: build Power → Research → Manufacturing → Barracks → Repeat
- After base layout established, becomes: "Which tech next? Which items manufacture?"
- Facility maintenance is passive (just subtract credits monthly)

**Gaps:**
- ❌ No meaningful adjacency bonuses (explicitly stated "NO BONUSES despite previous specs")
- ❌ No facility destruction consequences (repair vs. rebuild tradeoff not articulated)
- ❌ No base specialization (all bases play same, just different locations)
- ❌ No mention of base defenses affecting strategy
- ❌ No discussion of facility prioritization (what if forced to choose between barracks and lab?)

**Questions Designers Should Answer:**
- Why build multiple bases? (What's the advantage beyond capacity?)
- When should I upgrade a facility vs. building a new one?
- How do I recover from catastrophic base damage (UFO attack)?
- Are there "must-have" facility orderings or can they be built flexibly?

**Example from X-COM:** Different bases served different purposes (Heavy Defense, High Lab Capacity, Manufacturing Focused). Player had to strategically position bases knowing they might get attacked.

**Design Recommendation:**
Add **Base Specialization Mechanics:**
- Primary Base (must always exist, defensive focus, expensive)
- Research Base (3+ Labs, attracts alien attention, economically fragile)
- Manufacturing Base (3+ Workshops, slow alien attacks, vulnerable to raids)
- Outpost (small, specialized, vulnerable but rapid deployment)

---

### 1.3 - Battlescape Decisions (Algorithm-Solvable)

**Current State:**
- Combat formula: Stand in cover with high accuracy weapon, fire until enemy dies
- Cover system: Multiplicative accuracy reduction based on visibility obstruction
- Unit positioning: Fire from max range with armor + heavy weapon = win condition

**Gaps:**
- ❌ No mention of tactical situations where "optimal" play fails
- ❌ No asymmetric missions where stealth beats firepower
- ❌ No resource scarcity in combat (unlimited AP within turn, unlimited ammo)
- ❌ No mention of when retreat is winning condition
- ❌ Flanking mentioned as "future feature" but NOT specified

**Questions Designers Should Answer:**
- How does player with better positioning beat player with better gear?
- When is retreat an acceptable outcome?
- Are there situations where numerical superiority doesn't guarantee victory?
- How does unit morale create tactical dilemmas?

**Example from X-COM:** Sectoid that takes morale damage away from unit = must manage panic, creates tactical decision: protect scared unit or abandon them?

**Design Recommendation:**
Specify **Tactical Decision Points:**
1. **Engagement Distance** - Sniper at long range vs. assault at close range (tradeoff: accuracy vs. damage)
2. **Positioning** - Hold formation vs. spread out (tradeoff: mutual support vs. individual cover)
3. **Initiative** - Attack first vs. wait for enemy (tradeoff: damage vs. information)
4. **Morale Management** - Use leader to rally vs. advance (tradeoff: group cohesion vs. momentum)
5. **Objective vs. Survival** - Win mission vs. keep all units alive (tradeoff: completion vs. squad integrity)

---

## 2. 🟠 HIGH: Psychological Systems Opacity

**Problem:** Morale/Bravery/Sanity system is detailed but may be too complex and opaque for players to understand consequences.

### 2.1 - Morale System Feedback

**Current State:**
- In-battle morale: Starts at unit's Bravery value (6-12 range)
- Drops from: Ally death (-1), damage (-1), enemy superiority (-1)
- Recovers from: Rest action (+1), leader rally (+2)
- Panic at 0: All AP lost

**Gaps:**
- ❌ No mention of UI feedback showing morale value/thresholds
- ❌ No mention of unit behavior changing before panic (warnings)
- ❌ No mention of panic visual/audio feedback
- ❌ No clarity on how many morale points units typically have (6-12 is range, but what's average?)
- ❌ No explanation of when player should sacrifice morale for offensive action

**Player Confusion Scenarios:**
- Unit panics after taking 1 hit (if Bravery=6 and 5 morale losses already)
- Player doesn't realize morale is gone and unit becomes useless
- Panic triggers before player can rally (turn order issue)
- Recovery seems too slow (2-4 AP to gain back 1-2 morale)

**Design Recommendation:**
Specify **Morale Progression Curve:**
```
Morale Tiers (out of max):
- 100%: Confident (+0 to all stats)
- 75-99%: Alert (+0)
- 50-74%: Nervous (-1 accuracy)
- 25-49%: Shaken (-2 accuracy, -1 AP)
- 1-24%: Panicked (-4 accuracy, paralyzed, can only defend/rest)
- 0%: Broken (all AP lost)
```

Add **Visual Indicators** at each threshold (unit animation changes)

---

### 2.2 - Sanity System Recovery Rate

**Current State:**
- Long-term mental stability (persists between missions)
- Drops after missions: -0 to -3 sanity depending on horror
- Recovers: +1/week base, +2/week with Temple
- At 0 sanity: Unit cannot deploy (Broken state)

**Gaps:**
- ❌ Recovery at +1-2/week means broken unit takes 6-12 weeks to recover
- ❌ No mention of intensive recovery (paying more for faster healing)
- ❌ No mention of psychological counseling (role of Temple facility not clear)
- ❌ No mention of unit going "crazy" (lowering sanity doesn't remove unit, just blocks deployment)

**Balance Concern:**
If horror mission at month 6 breaks 3 units, and they each need 8-12 weeks recovery, player is without 25% of squad for 2 months. That's crippling in campaign flow.

**Design Questions:**
- Is high-horror mission supposed to be rare/avoided?
- Or is sanity management a key long-term strategy (Temple expansion required)?

**Design Recommendation:**
Specify **Sanity Recovery Options:**
1. **Rest** (Standard): +1/week, units available for next mission
2. **R&R** (Extra cost: 50K/unit): +2/week, units unavailable 4 weeks
3. **Intensive Therapy** (Temple only, 200K/unit): +4/week, but 50% chance new psychological trait

---

### 2.3 - Bravery as Core Stat Missing Context

**Current State:**
- Bravery: 6-12 range, determines morale capacity
- Increases with: Experience (+1 per 3 ranks), traits
- Mechanics specified but... what does a unit with 6 Bravery actually FEEL like vs. 12?

**Gaps:**
- ❌ No mention of unit personality/background (why is this unit braver?)
- ❌ No mention of recruitment affecting bravery (elite soldiers vs. conscripts)
- ❌ No mention of development over campaign (veteran becomes braver)
- ❌ Bravery stated as "6-12 range" but no explanation of what average is

**Design Questions:**
- Should players care about recruiting specific units for bravery?
- Can they train bravery, or is it fixed?
- Are some missions "scarier" than others, requiring higher bravery threshold?

**Design Recommendation:**
Add **Unit Personality System:**
```
Unit Generated With:
- Bravery (6-12 rolled, affects panic threshold)
- Background (Soldier, Mercenary, Conscript, Volunteer) - affects starting XP and traits
- Psychological Profile (Stoic, Anxious, Confident, Reckless) - affects reactions in stories/dialogue

Mission Events Affect Bravery:
- Friend dies near them: -1 Bravery permanently
- Critical save: +1 Bravery permanently
- Multiple combat tours: +1 Bravery per 3 missions
```

---

## 3. 🔴 CRITICAL: Economy Design Incentive Gaps

**Problem:** Manufacturing vs. marketplace relationship not incentivized, creating non-choice.

### 3.1 - Manufacturing Cost Structures

**Current State:**
- Manufacturing: Costs credits + resources (materials consumed)
- Marketplace: Costs credits (purchase from supplier)
- Both have availability limits but... when should player manufacture vs. buy?

**Gaps:**
- ❌ No mention of manufacturing profit margin (is it 20% cheaper? 50%? varies?)
- ❌ No mention of when marketplace runs out (creates scarcity?)
- ❌ No mention of bulk manufacturing bonuses (5-10% mentioned but context unclear)
- ❌ No mention of craftmanship (manufactured items different quality?)
- ❌ No mention of cost scaling late-game (advanced materials exponentially more expensive?)

**Design Questions:**
- Why would anyone pay marketplace if manufacturing cheaper?
- What if manufacturing is EXPENSIVE early, but becomes better mid-game?
- What creates tension: scarcity of resources, scarcity of workshop capacity, or scarcity of time?

**Scenario Analysis:**

**Early Game (Month 1-3):**
- Manufacturing: NOT AVAILABLE (need research first)
- Marketplace: Only basic equipment available
- Player: Must rely on marketplace

**Mid Game (Month 4-8):**
- Manufacturing: Available but expensive (high material costs)
- Marketplace: More variety, moderate prices
- Player: Mix of buying and manufacturing?

**Late Game (Month 9+):**
- Manufacturing: Cheap (economies of scale), only limitation is workshop capacity
- Marketplace: Expensive, rare items only
- Player: Mostly manufacture?

**Design Recommendation:**
Specify **Economic Progression:**
```
EARLY (Months 1-3):
- Manufacturing: Unavailable (no tech)
- Marketplace: 100K basic rifle, 50K armor (expensive relative to income)
- Income: ~200K/month
- Net: Deficit, must choose carefully

MID (Months 4-8):
- Manufacturing: 60K rifle (60% of marketplace), requires 5 metal (valued at 50K)
- Marketplace: 100K rifle
- Income: ~500K/month
- Net: Breakeven, player choosing where to spend

LATE (Months 9+):
- Manufacturing: 30K rifle (30% of marketplace), requires 5 metal (valued at 10K via synthesis)
- Marketplace: 150K rifle (inflation)
- Income: ~1000K/month
- Net: Surplus, player rich but game challenge maintained
```

---

### 3.2 - Resource Scarcity Pressure

**Current State:**
- Resources mentioned: Fuel, Metal, Titanium, Elerium, Alien Alloy, etc.
- Resources consumed by: Manufacturing, craft fuel, research materials
- No mention of: What happens if player runs out? Can they recover?

**Gaps:**
- ❌ No mention of resource depletion (is there a maximum resource per player?)
- ❌ No mention of resource nodes/provinces (some areas have more metal?)
- ❌ No mention of supply routes (risky logistics for resources)
- ❌ No mention of salvage priority (when loot, what to prioritize?)

**Design Questions:**
- Can player ever be permanently stuck (no resources for manufacturing)?
- What drives player to capture/interrogate aliens (research)?
- Why not just trade with suppliers for everything?

**Design Recommendation:**
Add **Resource Pressure Mechanics:**
1. **Regional Resources**: Some provinces have native resource deposits
   - Metal-rich (+50% metal salvage in region)
   - Fuel-rich (cheaper fuel from suppliers)
   - Alien-tech-rich (more frequent tech drops)
2. **Supply Chain**: Manufacturing requires resources that must be captured or traded
3. **Scarcity Events**: Periodic shortages (supplier embargo, natural disaster) forcing adaptation

---

### 3.3 - Economic Failure Recovery

**Current State:**
- Net monthly budget mentioned: Positive = surplus, negative = deficit
- No mention of: What happens at negative balance? Can player recover?

**Gaps:**
- ❌ No mention of budget crisis mechanics (debt, forced facility sale?)
- ❌ No mention of player recovery options (loan, selling equipment, temporary shutdown?)
- ❌ No mention of late-game economy sustainability (can player ever "win" economically?)

**Design Questions:**
- Can player go bankrupt?
- What happens if they can't pay salaries?
- Is financial collapse same as campaign loss?

**Design Recommendation:**
Specify **Economic Crisis System:**
```
Each turn, check budget:
- Positive: Normal (accumulate surplus)
- -50K to 0: Warning (receive notification "tight budget")
- -100K to -50K: Crisis (must cut spending or sell assets)
- Below -100K: Collapse (random facilities sold to cover debt) → eventually campaign loss

Recovery Options When in Crisis:
1. Sell equipment (10-20% value loss)
2. Temporarily shutdown facilities (50% maintenance cost)
3. Reduce unit salaries (50% morale loss)
4. Take black market loan (+20% interest debt)
5. Sell research data (diplomatic reputation loss)
```

---

## 4. 🔴 CRITICAL: Campaign Escalation Vagueness

**Problem:** Campaign structure mentioned as "4 phases" but actual triggers/mechanics not specified.

### 4.1 - Escalation Phases Undefined

**Current State:**
- Escalation Meter: Numeric tracker accumulating faction pressure
- Phases: Contact, Escalation, Crisis, Climax (mentioned but not detailed)
- Resets: Periodically (frequency unclear)
- Triggers: UFO armada events, increased mission frequency (mechanics unclear)

**Gaps:**
- ❌ No mention of what triggers phase transition (UFO count? Mission frequency? Player power level?)
- ❌ No mention of UFO armada mechanics (how many UFOs? Arrival pattern? Battle resolution?)
- ❌ No mention of what player can do to delay/accelerate escalation
- ❌ No mention of end-game conditions (when does campaign climax occur?)
- ❌ No mention of victory conditions (can player "win" escalation?)

**Design Questions:**
- Is escalation inevitable or can player prevent it?
- Does player power level affect escalation speed?
- Are there multiple escalation paths or single linear path?

**Critical Design Issue:**
"Sandbox game" suggests player can play indefinitely, but escalation system sounds like it leads to climax (ending). These are contradictory.

**Design Recommendation:**
Clarify **Campaign Structure:**

**Option A: Infinite Sandbox (Soft Ending)**
```
Escalation Meter: Never "ends" but cycles
- Cycle 1: Months 1-12, escalates from Contact → Climax
- At Climax: "Final Battle" event (player can win/lose)
- Post-Climax: New cycle begins at lower threat, game continues
- Player can achieve soft victory (defeat first invasion, build empire)
```

**Option B: Progressive Storyline (Hard Ending)**
```
Campaign Phases (Months 1-24+):
- Contact (1-4): Initial alien activity, player defensive
- Escalation (5-12): Alien bases established, regional conflict
- Crisis (13-20): Alien invasion appears inevitable
- Climax (21+): Final confrontation, player victory/defeat determines campaign end
```

**Option C: Dynamic (Player Choice)**
```
Escalation Points: Player accumulates these through missions
- Low Power: <50 points, safe, can relax
- Rising Threat: 50-150 points, aliens actively attacking
- Crisis: 150-250 points, invasion likely
- Climax: 250+ points, final confrontation or surrender
Player can influence point gain through research, facility destruction, or diplomatic actions
```

---

### 4.2 - UFO Armada Events

**Current State:**
- Mentioned as result of escalation phase transition
- No detail on: When? How many? How handled?

**Gaps:**
- ❌ No mention of armada composition (mix of UFO types?)
- ❌ No mention of player response options (evacuate? defend? fight?)
- ❌ No mention of battle scale (1v1 interception vs. region-wide assault?)
- ❌ No mention of consequences (loss of region? base destruction? mission failure?)

**Design Recommendation:**
Specify **Armada Mechanics:**
```
UFO Armada Event (Triggered at phase transition):
Composition:
- 3-7 UFOs (varies by escalation level)
- Mix of Scout/Bomber/Transport types
- Arrival: Staggered over 3-5 turns (prevents overwhelming player instantly)

Player Response Options:
1. Intercept: Engage with crafts (risky, craft can be destroyed)
2. Defend: Prepare bases for UFO attacks (passive, facilities damaged)
3. Evacuate: Abandon region to aliens (lose territory, gain time)

Outcome:
- Intercepted UFOs: Battlescape ground mission for survivors
- Successful attack: Regional facility/base destruction, population loss
- Evacuation: Lose territory but save forces

Stakes: Visible on Geoscape as "Territory Lost" event
```

---

## 5. 🟠 HIGH: Tactical Depth Concerns

**Problem:** Combat system appears solvable by "stand in cover with best gun" strategy.

### 5.1 - Cover System Simplicity

**Current State:**
- Cover Modifier: Accuracy reduction based on visibility obstruction
- Implementation: Multiplicative formula (Base × Range Mod × Mode Mod × Cover Mod × LOS Mod)
- Result: Clamped to 5-95% final accuracy

**Gaps:**
- ❌ No mention of cover advantage (does heavier cover provide more benefit?)
- ❌ No mention of partial cover progression (standing vs. crouching?)
- ❌ No mention of when cover is useless (outflanked positions?)
- ❌ No mention of destruction (can enemy destroy cover?)
- ❌ Flanking explicitly "delayed to future" - means current system has gap

**Design Questions:**
- What makes one cover position better than another?
- Can player force enemy out of cover?
- Is there cover that's truly impenetrable?

**Design Recommendation:**
Add **Cover Depth Mechanics:**
```
Cover Types:
1. Partial (bushes, rubble): -10% attacker accuracy
2. Standard (walls, barriers): -20% attacker accuracy
3. Full (heavy walls, buildings): -30% attacker accuracy
4. High Ground (elevated): +15% attacker accuracy, +1 range

Cover Destruction:
- Partial: 10 damage destroys
- Standard: 30 damage destroys
- Full: 60 damage destroys

Cover Flanking:
- If attacker on different side of cover than target: -50% cover bonus applies
- Incentivizes positioning and movement
```

---

### 5.2 - Morale in Tactical Context

**Current State:**
- Morale affects: AP efficiency (fewer AP when low morale)
- Mentioned: Suppression adds to morale loss
- Tested: Retreat conditions (not mentioned)

**Gaps:**
- ❌ No mention of when retreat is acceptable outcome
- ❌ No mention of leadership inspiring troops mid-battle
- ❌ No mention of unit breaking/fleeing (low morale units run away?)
- ❌ No mention of charismatic leaders (leader presence affects nearby morale?)

**Design Questions:**
- Can player order retreat mid-mission?
- Do low-morale units make tactical blunders (attack recklessly)?
- Is there unit-to-unit morale contagion (one panic triggers others)?

**Design Recommendation:**
Add **Morale Tactical Effects:**
```
Morale Impact on Combat:
- 100% Morale: All bonuses normal
- 75%: No change
- 50%: -1 accuracy, -1 AP per turn
- 25%: -2 accuracy, -2 AP per turn, random actions
- 0%: Broken (disabled, cannot act)

Leadership Effects:
- Bravery > 9 + 2 ranks = Leader (+1 morale nearby units)
- Leader action (Rally): 4 AP, nearby units +2 morale, one-time per battle

Retreat Mechanics:
- Player can order squad retreat to extraction point (mission incomplete)
- Surviving units withdraw safely
- Failed mission = no XP but units live

Fleeing:
- Low morale unit (0 AP, disabled) acts next turn:
  - 50% chance: Regains composure (morale +1)
  - 50% chance: Breaks and flees (leaves battlefield)
```

---

### 5.3 - Suppression Dominance

**Current State:**
- Suppression: -1 AP per attacker next turn
- Stacks: Can lose up to -2 AP maximum
- Resets: Turn end if no fire

**Gaps:**
- ❌ Unclear if suppression stacks (can multiple units suppress same target?)
- ❌ No mention of counter-suppression (defending unit can't suppress back?)
- ❌ No mention of suppression breaking (how to get out of suppressed state?)
- ❌ No mention of fire discipline (should raw suppression be strong?)

**Balance Concern:**
3 units attacking 1 unit = -3 AP theoretical max, but capped at -2 AP. Could be dominant strategy: ignore enemy armor, just suppress everything.

**Design Recommendation:**
Rebalance **Suppression:**
```
Current: -1 AP per attacker (max -2)
Proposed: -0.5 AP per attacker (max -1)

Alternative: Suppression as Accuracy Penalty
- Instead of AP loss, suppressed unit: -20% accuracy next attack
- Can be stacked: multiple suppressors = -20% each
- Encourages fire support without removing agency (units still attack)

Recovery:
- Move action in heavy cover: Suppress ends
- Leadership Rally action: Suppress ends + morale recovery
- Pass turn: Suppress ends at turn end anyway
```

---

## 6. 🟠 HIGH: Narrative & Story Integration Missing

**Problem:** Lore exists but gameplay consequences for story choices not specified.

### 6.1 - Mission Narrative Hooks

**Current State:**
- Mission types: UFO crash, alien base, terror operation, supply raid, etc. (mechanically defined)
- Lore: Story exists in background
- Integration: None mentioned

**Gaps:**
- ❌ No mention of story variations (same mission type plays differently based on narrative?)
- ❌ No mention of mission briefing (player told why they're fighting)
- ❌ No mention of civilian presence (rescue civilians vs. military objective)
- ❌ No mention of captured alien/enemy interrogation giving story rewards
- ❌ No mention of mission aftermath narrative (how does story change based on victory/defeat?)

**Design Questions:**
- Does failed mission have story consequence (region falls, country angry)?
- Can player make deals with aliens (X-COM had this possibility)?
- Are there story-only missions (rescue VIP scientist)?

**Example from X-COM:**
- "Council demands you defend Council nations" → mission spawns in Council country
- VIP rescue mission → if successful, unlock new research tree
- Alien base destruction → next month, alien retaliation in that region

**Design Recommendation:**
Add **Narrative Mission Framework:**
```
Each Mission Has:
1. Tactical Objective (destroy, rescue, defend, retrieve)
2. Story Context (why this mission matters)
3. Story Consequence (what changes if success/failure)

Examples:
- "Alien research facility activated in Brazil"
  Context: Scientists studying abduction victims
  Success: Gain "Alien Biology" research, Brazil +10 relations, facility closes
  Failure: Aliens complete research, humans gain strange powers, Brazil -20 relations

- "Cult ritual in progress, cultists summoning something"
  Context: Black market investigation found cult operation
  Success: Prevent summoning, gain cult member prisoner
  Failure: Something summoned (creates new enemy type), local fear +20

- "VIP scientist captured by aliens, interrogation in progress"
  Context: Lead scientist's location pinged via homing beacon
  Success: Rescue scientist, unlock new research branch
  Failure: Scientist converted (becomes enemy unit in future battles)
```

---

### 6.2 - Character Development Through Story

**Current State:**
- Units have: Rank, class, specialization, traits, health, morale, sanity
- Development: Experience-based rank progression, trait acquisition through... (not specified)
- Story: Implied but not detailed

**Gaps:**
- ❌ No mention of unit storytelling (squad names, character arcs, memorable moments)
- ❌ No mention of unit bonds (do squadmates care about each other?)
- ❌ No mention of permanent scars (psychological or physical)
- ❌ No mention of character death narrative (rest in peace, memorial?)
- ❌ No mention of veteran status (elite units with history?)

**Design Questions:**
- Is unit X just "Rank 4 Soldier" or do they have identity?
- When unit dies, is there emotional impact?
- Can player name units? Create squads with themes?

**Design Recommendation:**
Add **Character Persistence:**
```
Unit Identity:
- Auto-generated first name + player-assigned squad
- Trait descriptions affect personality in story ("Brave Sergeant Chen" vs "Nervous Private Rodriguez")
- Victory/defeat tracking affects story callouts

Story Events:
- First kill: "Soldier's first blood" message
- Survival milestones: "5 missions without injury" → trait unlock
- Death: Narrative goodbye message, option to memorialize
- Squad bonds: "Squadmates avenging lost teammate" bonus

Permanent Effects:
- Psychological scars: "Witnessed alien horror" → new permanent trait
- Physical scars: "Missing eye" → -2 accuracy until healed
- Promotions: Named "Sergeant Chen" after promotion, story moment
- Retirement: Veteran units can retire, open new recruits
```

---

## 7. 🟠 HIGH: Player Skill Expression Limited

**Problem:** RNG-heavy accuracy system (5-95%) reduces player tactical agency.

### 7.1 - Accuracy Variance

**Current State:**
- Base accuracy: 70% (rifle)
- Modifiers: Range (-20% to +20%), cover (-50%), visibility (-50%)
- Final: Clamped 5-95%

**Gaps:**
- ❌ No mention of consistent game (is RNG too high?)
- ❌ No mention of skill vs. luck (does perfect tactical play guarantee victory?)
- ❌ No mention of high-skill play (what do experts do differently?)
- ❌ No mention of clutch moments (dramatic last-minute success?)

**Design Questions:**
- Can skilled player with gear A beat lucky player with gear B?
- Is "optimal play" actually optimal or just feels good?
- How much of game is decided by RNG vs. player choice?

**Balance Concern:**
Example:
- Good position: 85% accuracy (hits 85 of 100 shots)
- Bad position: 40% accuracy (hits 40 of 100 shots)
- 45% swing from positioning alone... but 40-60% variance from RNG

At 40% accuracy, player might miss 6 times straight (realistic but feels unfair). At 85%, might hit 8 times straight (great but not guaranteed).

**Design Recommendation:**
Clarify **Accuracy Philosophy:**
```
Option A: "Positioning > RNG" (Currently ~50% each)
- Reduce accuracy variance to 10-90% (tighter)
- Increase positioning bonuses (flanking +50% accuracy instead of +20%)
- Result: Skill matters more, variance less

Option B: "Tactical Success = Higher Accuracy" (Currently ~70% variance)
- Keep 5-95% range
- Add player skills (Aim training, Focus, Steady Hand) that reduce variance band
- Result: Veteran units more consistent

Option C: "Luck as Game Feature" (Accept current)
- Lean into dramatic moments (long odds success)
- Add morale effects for "lucky" vs "unlucky" units
- Result: Emergent storytelling through variance
```

---

### 7.2 - Stealth System Under-Explored

**Current State:**
- Stealth: "Limited stealth budget" (vague)
- Integration: Optional mission mechanic
- No detail on: How budget works, when available, consequences

**Gaps:**
- ❌ No mention of stealth mechanics (detection range? line of sight? noise?)
- ❌ No mention of alarms (what triggers enemy alert?)
- ❌ No mention of advantage (is stealth start meaningful?)
- ❌ No mention of skill expression (can players learn stealth)

**Design Recommendation:**
Specify **Stealth System:**
```
Stealth Mechanics:
- Budget: 2-4 "stealth turns" per mission (units can move unseen)
- Detection: If discovered, alarm triggers (all enemies activate)
- Advantage: First turn surprise (player units act first in ambush)

Usage Options:
1. Stealth approach: Spend budget moving unseen, ambush enemies
2. Direct assault: Skip stealth, immediate combat
3. Mixed: Some units stealthy, others cover approach

Skill Expression:
- Experienced players: Better positioning during stealth, minimize ambush casualties
- Novice players: Blow stealth early, get ambushed, recover

Consequences:
- Success: Enemy surprised, first turn advantage (3-4 free actions)
- Failure: Enemy alert, tougher battle
- Abort: Can leave stealth early, normal combat
```

---

## 8. 🟡 MEDIUM: Balance Parameters Lack Justification

**Problem:** Many numbers provided but design rationale often absent. Why 4 AP? Why 6-12 HP?

### 8.1 - Action Point Design

**Current State:**
- 4 AP per turn baseline
- Movement: 1 AP per hex
- Attack: 1-4 AP depending on action
- Example: Move (1 AP) + Attack (2 AP) + Reload (1 AP) = 4 AP used

**Gap Analysis:**
- Movement: At 1 AP per hex, 4 AP means 4 hex movement (optimal range with +1 hex if run)
- Combat: 2 AP attack leaves 2 AP for movement, forcing tradeoff
- Question: Why not 5 AP? Or 6 AP? What's the reasoning?

**Design Recommendation:**
Provide **Design Justification:**
```
4 AP Per Turn Rationale:

Tactical Implications:
- Move + Attack + Move = 4 AP total (full engagement cycle)
- Hold + Attack + Attack = 4 AP total (defensive posture)
- Move + Attack + Reload + Move = 5 AP (impossible, forces choice)

Combat Distance:
- 4 AP movement = reach ~4 hex away per turn
- Max sight range 8-12 hex = can't reach enemy in one turn if distant
- Forces tactical setup (positioning first turn)

Economy:
- Turn-based pacing (not too slow, not too fast)
- Squad with 8 units = 32 AP total per turn (manageable complexity)
- Mission: 8 turns average (32 AP total per unit = 256 AP actions total = ~30 minute mission)

Compared to X-COM:
- X-COM: Time Units (60 TU per turn) = more granular
- AlienFall: AP (4 per turn) = more dramatic choices

If 5 AP:
- Pro: More flexibility, less AP economy tension
- Con: Easier to reach distant enemies, less positioning reward

If 3 AP:
- Pro: Tighter decision-making, more turn-based pace
- Con: Movement becomes constrained, combat less interesting
```

---

### 8.2 - Health Point Scaling

**Current State:**
- Unit HP: 6-12 (base human)
- Damage: 12-45 (varies by weapon)
- Result: Most combats resolve in 2-4 shots

**Gap Analysis:**
- Small HP pool means damage matters
- High damage variance (12-45 is 3x spread) makes balance unclear
- Question: Is 10 damage weapon useful if 40 damage available?

**Design Recommendation:**
Justify **Damage Value Design:**
```
HP Scaling Rationale:

Unit Health: 6-12 HP (for humans)
- Represents 10-20 "hit points" of injury capacity
- Average unit: 9 HP (mid-range)
- Rookie: 6 HP (fragile, easily killed)
- Elite: 12 HP (experienced, harder to kill)

Damage Ranges:
- Pistol: 10 damage (one-shot rookie, two-shot average, three-shot elite)
- Rifle: 20 damage (two-shot rookie, one-shot average, one-shot elite)
- Sniper: 35 damage (one-shot all targets)
- Shotgun: 30 damage (one-shot most, situational)

Design Intention:
- Weapon choice matters (sniper vs. rifle tradeoff)
- Unit survivorship depends on armor + HP
- Engagement distance affects outcome (long range favors sniper, close range favors shotgun)

If 15-30 HP Range:
- Pro: More durable combat, less focus on one-hit kills
- Con: Combat grindy, damage variance less impactful

Current Balance:
- Balanced for 3-4 shot average combat
- Rewards positioning (cover reduces damage via accuracy reduction)
- Rewards armor (additional HP effectively)
```

---

## 9. 🟠 HIGH: Cross-System Interactions Sparse

**Problem:** Systems seem isolated rather than interconnected for emergent gameplay.

### 9.1 - Pilot Ranking Impact

**Current State:**
- Pilots: Specialized unit class for craft interception
- Ranking: Separate from squad unit ranking
- Impact: Not specified (what does veteran pilot do differently?)

**Gaps:**
- ❌ No mention of pilot stats (Reflexes, Accuracy, Nerves mentioned but not used)
- ❌ No mention of deck-building (how do pilots improve their card collection?)
- ❌ No mention of ace pilot abilities (what makes 5+ kill pilot special?)
- ❌ No mention of pilot-craft synergy (do specific pilots prefer specific crafts?)

**Design Recommendation:**
Add **Pilot Development:**
```
Pilot Progression:
- Rank 1: Basic pilot, 5-card starting deck
- Rank 2+: Unlock new maneuver cards, improve stats
- Rank 5: Ace pilot, +10% accuracy, +2 energy per turn, special abilities

Deck Building:
- Start with preset deck
- Unlock new cards through:
  - Research (new maneuver tech)
  - Experience (pilot learns through combat)
  - Craft upgrades (better hardware enables better maneuvers)

Pilot-Craft Synergy:
- Experienced pilot + upgraded craft = +20% performance
- Rookie pilot + old craft = -10% performance

Consequences:
- Losing veteran pilot hurts craft capability
- New pilots need time to develop
- Crafts with experienced pilots become valuable
```

---

### 9.2 - Psychology Feeding Strategy

**Current State:**
- Morale/Sanity: Affect combat only
- No mention of: Geoscape strategic impact

**Gaps:**
- ❌ No mention of "shell-shocked units" affecting morale of other squads
- ❌ No mention of recruiting hesitation (veteran soldiers want time off?)
- ❌ No mention of public morale (soldier deaths affect civilian panic?)
- ❌ No mention of unit retention (do broken units leave organization?)

**Design Recommendation:**
Add **Cross-Layer Psychology:**
```
Combat Morale → Unit Availability:
- Unit returns from mission with low sanity
- Takes 2-4 weeks recovery
- During recovery, unavailable for deployment
- Affects squad composition for next missions

Unit Morale → Recruitment:
- High casualty rate in squad → harder to recruit new soldiers
- Soldiers hear about losses, hesitant to join
- Fame/relations affect recruitment pool

Collective Morale → Strategic Options:
- Organization morale low → can't launch risky missions
- Must do "safe" missions for morale recovery
- Affects mission generation (fewer difficult missions available)

Individual Unit → Squad Cohesion:
- Veteran squad (3+ missions together) → +1 accuracy in squad actions
- Squad loses member → -1 morale for survivors
- Squad "bonds" create motivation (revenge bonus)
```

---

### 9.3 - Base Location Strategy

**Current State:**
- Bases placed on hex grid
- Location affects: Radar range (presumably), craft travel time
- No mention of: Strategic advantages, disadvantages, or meaningful choice

**Gaps:**
- ❌ No mention of terrain affecting base construction (mountains harder? flat faster?)
- ❌ No mention of resource-rich provinces (build in resource area?)
- ❌ No mention of alien activity hotspots (risk placing near them?)
- ❌ No mention of population centers (build near cities?)

**Design Recommendation:**
Add **Location Strategy:**
```
Base Location Effects:

Terrain:
- Plains: +0 construction time, +0 defense
- Mountain: +50% construction time, +20% base defense (natural fortification)
- Urban: -50% construction time, -20% base defense (exposed), +10% enemy radar on base
- Forest: Normal, +10% radar reduction (camouflage)

Resource Proximity:
- Near resource province: +5% manufacturing efficiency for that resource
- Example: Base near metal-rich area = cheaper metal manufacturing

Alien Activity:
- High activity area: More missions (bad), aliens find base easier (bad)
- Low activity area: Fewer missions (bad for experience), safer (good)

Strategic Value:
- Control decision: defend? or abandon to aliens?
- Relocation opportunity: move base to better location but costs (production halt)

Consequences:
- Base location matters (not interchangeable)
- Beginners place safely, experts place aggressively
- Regional control affects base viability
```

---

## 10. 🟡 MEDIUM: Difficulty & Accessibility Gaps

**Problem:** Difficulty settings mentioned as "planned" but not specified. New players likely overwhelmed.

### 10.1 - Difficulty Settings

**Current State:**
- Mentioned: "Difficulty options (Easy, Normal, Hard, Impossible)"
- Detailed: None

**Gaps:**
- ❌ No mention of what changes per difficulty
- ❌ No mention of enemy strength (more units? better gear? smarter AI?)
- ❌ No mention of economy scaling (more income? higher costs?)
- ❌ No mention of consequence scaling (can you reload after mistakes?)
- ❌ No mention of ironman mode (permadeath on/off?)

**Design Recommendation:**
Specify **Difficulty Tiers:**
```
EASY (Newcomer):
- Enemy damage -30%, enemy accuracy -20%
- Player income +50%, research -20% cost
- 1 save per mission (tactical reloads allowed)
- Permadeath off (units recoverable)
- Tutorial: Fully assisted, hints frequent

NORMAL (Intended):
- Enemy damage 0%, enemy accuracy 0%
- Player income 100%, costs normal
- No saves (commitment to choices)
- Permadeath on (casualty recovery slow)
- Tutorial: Light assistance

HARD (Veteran):
- Enemy damage +30%, enemy accuracy +20%
- Player income -20%, costs +30%
- Ironman mode (save on mission end only)
- Permadeath on (no revival, permanent loss)
- No hints, full difficulty

IMPOSSIBLE (Hardcore):
- Enemy damage +50%, enemy accuracy +40%
- Player income -50%, costs +50%
- Single save slot (reload resets completely)
- Permadeath on (no revival)
- No UI assists, full tactical complexity
```

---

### 10.2 - Learning Curve

**Current State:**
- Three game layers (Geoscape, Basescape, Battlescape)
- Tutorial mentioned but not specified
- Complex systems (economy, psychology, tactics)

**Gaps:**
- ❌ No mention of tutorial progression (teach one layer at a time?)
- ❌ No mention of difficulty unlock (gate hard content for beginners?)
- ❌ No mention of learning tools (practice modes? campaign walkthrough?)
- ❌ No mention of failure forgiveness (can new players recover from mistakes?)

**Design Recommendation:**
Create **Learning Path:**
```
Week 1 (Tutorial Campaign):
- Geoscape only: Deploy craft, respond to missions, basic strategy
- Introduce economy: Purchase equipment, recruitment
- Single base, single squad

Week 2:
- Battlescape focus: Learn combat mechanics, accuracy, cover
- Practice missions: Defend positions, clear areas, retrieve objectives
- Difficulty: Lowered by 30% for learning

Week 3:
- Basescape focus: Build facilities, research tech, manufacturing
- Economy: Manage money, facility maintenance, expansion
- Integrate systems: Combat missions affect research capability

Week 4:
- Full campaign: All systems active, normal difficulty
- Player ready for full gameplay
```

---

## Summary Table: Gaps by Severity & Layer

| # | Issue | Layer | Severity | Impact | Priority |
|---|-------|-------|----------|--------|----------|
| 1 | Decision space under-specified | All | 🔴 Critical | Gameplay depth | 1 |
| 2 | Psychological system opacity | Battlescape | 🟠 High | Player feedback | 2 |
| 3 | Economy incentive gaps | Basescape | 🔴 Critical | Non-choice | 3 |
| 4 | Campaign escalation vague | Geoscape | 🔴 Critical | End-game unclear | 4 |
| 5 | Tactical depth concerns | Battlescape | 🟠 High | Skill expression | 5 |
| 6 | Narrative integration missing | All | 🟠 High | Story impact | 6 |
| 7 | Player skill limited | Battlescape | 🟠 High | Agency/mastery | 7 |
| 8 | Balance parameters unjustified | All | 🟡 Medium | Trust in design | 8 |
| 9 | Cross-system interactions sparse | All | 🟠 High | Emergence | 9 |
| 10 | Difficulty & accessibility | All | 🟡 Medium | Onboarding | 10 |

---

## Recommendations: Immediate Actions

### Phase 1: Clarification (Week 1-2)
- [ ] Define campaign structure (sandbox vs. story-driven)
- [ ] Specify escalation triggers and phase conditions
- [ ] Clarify manufacturing vs. marketplace incentives
- [ ] Justify key balance parameters (4 AP, 6-12 HP, etc.)

### Phase 2: Design Completion (Week 3-4)
- [ ] Add decision space documentation for each layer
- [ ] Specify cross-system interactions
- [ ] Create narrative framework for missions
- [ ] Develop difficulty settings

### Phase 3: Validation (Week 5)
- [ ] Playtest with target audience
- [ ] Gather feedback on decision space
- [ ] Verify balance numbers through simulation
- [ ] Measure new player comprehension

---

## Conclusion

AlienFall demonstrates **excellent technical design work** with comprehensive system documentation. However, from a **game design perspective**, several **critical gaps** exist that could undermine the core promise of "interesting decisions" and "emergent gameplay":

1. **Decision Space**: Needs explicit specification of meaningful choices per layer
2. **Campaign Flow**: Requires clear structure (sandbox vs. progressing story)
3. **Narrative**: Should integrate with gameplay for story impact
4. **Player Agency**: Must balance RNG with skill expression
5. **Economy**: Needs clear incentive structure for manufacturing

These gaps don't invalidate the design—they're normal for design-in-progress. But addressing them will significantly improve the game's design coherence and player experience.

---

**Questions for Designer Review:**
1. Is AlienFall truly sandbox (infinite play) or story-driven (climactic ending)?
2. What's the ONE decision that defines good vs. bad strategic play in Geoscape?
3. What's the most common way for experienced player to fail?
4. What should feel amazing about end-game play?
5. How does narrative player choice affect game outcome?

**Next Steps:** Schedule design review focused on decision space, campaign structure, and cross-system emergence.

---

**Document Version:** 1.0
**Last Updated:** November 2, 2025
**Status:** Ready for Designer Review
