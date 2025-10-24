# Game Structure Diagrams

**Created:** October 21, 2025  
**Purpose:** Visual representation of AlienFall game layer integration, time scales, and organizational progression

---

## 1. Game Layer Architecture

### Overview
AlienFall consists of three interconnected game layers that represent different time scales and strategic/tactical focuses.

### Visual Diagram

```
┌─────────────────────────────────────────────────────────────────────┐
│                          MAIN GAME LOOP                              │
│  (Runs at 60 FPS, updates game state each frame)                   │
└────────────────────────┬────────────────────────────────────────────┘
                         │
                    ┌────▼────────┐
                    │  Scene Mode  │
                    └────┬─────────┘
                         │
        ┌────────────────┼────────────────┬──────────────┐
        │                │                │              │
        ▼                ▼                ▼              ▼
    ┌────────┐      ┌───────────┐  ┌──────────────┐ ┌───────────┐
    │  Menu  │      │ Geoscape  │  │  Basescape   │ │Battlescape│
    │ Screen │      │(Strategic)│  │(Management) │ │(Tactical) │
    └────────┘      └───────────┘  └──────────────┘ └───────────┘
                         │               │              │
                    ┌────▼───┬──────┬────▼───┐  ┌─────▼──────┐
                    │ Calendar│ Craft│Mission │  │ Turn-Based │
                    │ System  │Deploy│System  │  │   Combat   │
                    └─────────┴──────┴────────┘  └────────────┘
```

### Layer Connections

```
Geoscape (Strategic Layer - Time Scale: DAYS)
│
├─ Manages: World map, craft deployment, mission assignment
├─ Time unit: 1 turn = 1 calendar day
├─ Core loop: Time advance → Mission spawn → Deploy → Battle
│
├─→ Deploys to: Battlescape (when mission selected)
│
└─→ Manages: Base locations, provinces, radar coverage


Basescape (Management Layer - Time Scale: DAYS to WEEKS)
│
├─ Manages: Base facilities, research, manufacturing, personnel
├─ Time unit: Same as Geoscape (1 day), but async processing
├─ Core loop: Queue research → Assign scientists → Progress → Complete
│
├─→ Provides resources to: Geoscape (craft, units, items)
│
└─→ Receives results from: Battlescape (salvage, casualties)


Battlescape (Tactical Layer - Time Scale: SECONDS to MINUTES)
│
├─ Manages: Combat, unit movement, weapon fire, abilities
├─ Time unit: Turn-based (1 turn ≈ 10 game seconds at 1x speed)
├─ Core loop: Player actions → AI response → Resolve → Victory/Defeat
│
├─→ Reports to: Geoscape (mission result, casualties, salvage)
│
└─→ Draws from: Basescape (units, equipment, ammo)
```

---

## 2. Time Scale Hierarchy

### Diagram: Time Progression

```
┌──────────────────────────────────────────────────────────────────┐
│                    REAL WORLD TIME (Seconds)                     │
│ 1 second real-time = various game time depending on speed factor │
└────┬────────────────────────────────────────────────────────────┘
     │
     ├─→ 60 FPS Game Loop (frame update every 16ms)
     │
     ├──────────────────────────────────────────────────────────
     │
     ▼ Geoscape Time Scale (1 day = 1 turn)
     
     ┌────────────────────────────────────┐
     │ 1 Geoscape Turn = 1 Calendar Day   │ (0600-2400 hours)
     │                                    │
     │ ├─ Morning: Mission detection      │
     │ ├─ Daytime: Deployment window      │
     │ ├─ Evening: Research progresses    │
     │ └─ Night: Manufacturing progresses │
     └────────────────────────────────────┘
     
     │
     ├─→ 30 Turns = 1 Month (maintenance costs, funding updates)
     │
     ├─→ 365 Turns = 1 Year (anniversary events)
     │
     └─→ Multiple Months/Years = Campaign progression
     
     │
     ├──────────────────────────────────────────────────────────
     │
     ▼ Interception Time Scale (1 minute = brief encounter)
     
     ┌──────────────────────────────┐
     │ 1 Interception Engagement    │  (5-20 minutes real gameplay)
     │ = Craft vs UFO combat        │
     │                              │
     │ Time units: Seconds/Minutes  │
     │ Turn-based: 1 turn = 1 minute│
     └──────────────────────────────┘
     
     │
     ├──────────────────────────────────────────────────────────
     │
     ▼ Battlescape Time Scale (1 turn = ~10 seconds in-game)
     
     ┌───────────────────────────────────┐
     │ 1 Battlescape Turn = ~10s in-game │ (1-5 minutes per turn)
     │                                   │
     │ ├─ Player action phase (2-3 mins) │
     │ ├─ AI action phase (1-2 mins)     │
     │ └─ Resolution phase (1 min)       │
     │                                   │
     │ Typical battle: 8-15 turns        │
     │ = 80-150 seconds in-game          │
     │ = 15-45 minutes player time       │
     └───────────────────────────────────┘


RELATIONSHIP MATRIX:
┌─────────────────┬─────────────────┬──────────────────────────┐
│ Time Scale      │ Duration        │ Real Player Time         │
├─────────────────┼─────────────────┼──────────────────────────┤
│ 1 Game Loop     │ 16ms            │ 16ms                     │
│ 1 Turn (Geo)    │ 1 day           │ 5-30 seconds (skipped)   │
│ 1 Turn (Battle) │ 10 seconds      │ 2-5 minutes              │
│ 1 Month         │ 30 days         │ 1-5 minutes processing   │
│ 1 Year          │ 365 days        │ 30-60 minutes gameplay   │
└─────────────────┴─────────────────┴──────────────────────────┘
```

---

## 3. Campaign Progression Timeline

### Diagram: Campaign Flow

```
START GAME
    │
    ├─ Character selection
    ├─ Base location selection  
    └─ Initial funding allocation
    │
    ▼
MONTH 1 (Early Game)
    ├─ Establish first base
    ├─ Deploy first patrols
    ├─ First alien encounter
    └─ Initial research started
    │
    ▼
MONTH 2-3 (Expansion Phase)
    ├─ Expand research (unlock new tech)
    ├─ Deploy second base (optional)
    ├─ Build facilities (hangar, workshop, lab)
    ├─ Train additional units
    └─ First major battle
    │
    ▼
MONTH 4-6 (Mid Game)
    ├─ Advanced research available
    ├─ Manufacture better weapons
    ├─ Establish supplier relationships
    ├─ Regional conflicts escalate
    └─ Craft interception becomes critical
    │
    ▼
MONTH 7-12 (Late Game)
    ├─ Economy stabilizes or fails
    ├─ Global tensions increase
    ├─ Final tech becoming available
    ├─ Major faction contact
    └─ Strategic choices (alliances, aggression)
    │
    ▼
YEAR 2+ (Endgame)
    ├─ Victory conditions possible
    ├─ Alternative endings unlocked
    ├─ Campaign escalation peaks
    └─ Long-term strategy pays off
    │
    ▼
CAMPAIGN END (Victory or Defeat)
    ├─ Epilogue event
    ├─ Final statistics
    └─ New Game+ option
```

---

## 4. Organization Progression Tree

### Diagram: Org Level Advancement

```
                        ORG LEVEL PROGRESSION
                        (5 Levels: Rookie→Commander)

                            Level 1: RECRUIT
                           (Starting level)
                                │
                    ┌───────────┼───────────┐
                    │           │           │
              Max Bases:    Max Research:  Facility Types:
                1-2         Tier 1-2       Basic (5 types)
                    │           │           │
                    └───────────┼───────────┘
                                │
                    ┌──────────▼──────────┐
                    │  Requirements Met?  │
                    │ • 10 Total Missions │
                    │ • 50k Funds Earned  │
                    │ • 3 Alien Kills     │
                    └──────────┬──────────┘
                               │
                              ▼
                          Level 2: SERGEANT
                              │
                    ┌───────────┼───────────┐
                    │           │           │
              Max Bases:    Max Research:  Facility Types:
                2-3         Tier 2-3       Advanced (8 types)
                    │           │           │
                    └───────────┼───────────┘
                                │
                    ┌──────────▼──────────┐
                    │  Requirements Met?  │
                    │ • 30 Total Missions │
                    │ • 150k Funds Earned │
                    │ • 50 Alien Kills    │
                    └──────────┬──────────┘
                               │
                              ▼
                          Level 3: CAPTAIN
                              │
                    ┌───────────┼───────────┐
                    │           │           │
              Max Bases:    Max Research:  Facility Types:
                3-4         Tier 3-4       Specialized (10 types)
                    │           │           │
                    └───────────┼───────────┘
                                │
                    ┌──────────▼──────────┐
                    │  Requirements Met?  │
                    │ • 60 Total Missions │
                    │ • 300k Funds Earned │
                    │ • 150 Alien Kills   │
                    └──────────┬──────────┘
                               │
                              ▼
                          Level 4: COMMANDER
                              │
                    ┌───────────┼───────────┐
                    │           │           │
              Max Bases:    Max Research:  Facility Types:
                4-5         Tier 4-5       Exotic (12 types)
                    │           │           │
                    └───────────┼───────────┘
                                │
                    ┌──────────▼──────────┐
                    │  Requirements Met?  │
                    │ • 100+ Missions     │
                    │ • 500k Funds Earned │
                    │ • 300 Alien Kills   │
                    │ • All Research Done │
                    └──────────┬──────────┘
                               │
                              ▼
                        Level 5: SUPREME
                      (All limits removed)


BENEFITS BY LEVEL:
┌────────────┬──────────┬────────────┬────────────────┬─────────────┐
│ Level      │ Max Base │ Research   │ Facility Types │ Unit Slots  │
├────────────┼──────────┼────────────┼────────────────┼─────────────┤
│ 1-Recruit  │ 1-2      │ Tier 1-2   │ 5 basic        │ 6-10 units  │
│ 2-Sergeant │ 2-3      │ Tier 2-3   │ 8 advanced     │ 10-15 units │
│ 3-Captain  │ 3-4      │ Tier 3-4   │ 10 special     │ 15-20 units │
│ 4-Commander│ 4-5      │ Tier 4-5   │ 12 exotic      │ 20-25 units │
│ 5-Supreme  │ Unlimited│ All tech   │ All types      │ Unlimited   │
└────────────┴──────────┴────────────┴────────────────┴─────────────┘
```

---

## 5. Game Mode Transitions

### Diagram: Scene Navigation Flow

```
                        MAIN MENU SCREEN
                              │
                ┌─────────────┼─────────────┐
                │             │             │
                ▼             ▼             ▼
            [New Game]    [Continue]    [Settings]
                │             │
                └──────┬──────┘
                       │
                       ▼
                GEOSCAPE SCREEN
                (Strategic Layer)
                       │
        ┌──────────────┼──────────────┐
        │              │              │
        ▼              ▼              ▼
    [Advance     [Manage Base]   [Manage Craft]
     Time]       [BASESCAPE]     [Select Mission]
        │              │              │
        │              │              │
        └──────────────┼──────────────┘
                       │
                    ┌──▼──────────────┐
                    │ Deploy to Battle?│
                    └──┬──────────────┘
                       │
          ┌────────────┴────────────┐
          │                         │
         YES                        NO
          │                    (Stay in Geoscape)
          │                         │
          ▼                         │
    [Load Battle]                  │
    [Generate Map]                 │
          │                         │
          ▼                         │
    BATTLESCAPE SCREEN         Geoscape Loop
    (Tactical Layer)                │
          │                    ┌────┘
          │              ┌─────▼────────┐
          ├─ Move units │ Advance time? │
          ├─ Attack     └─────┬────────┘
          ├─ Use items  ┌─────▼─────┐
          ├─ Cast spell │   YES     │
          └─ Take cover │   (Day passes)
                        └─────┬─────┘
                              │
                        ┌─────▼──────────┐
                        │ Monthly events?│
                        │ • Maintenance  │
                        │ • Research     │
                        │ • Manufacturing│
                        └─────┬──────────┘
                              │
                    (Return to Geoscape)


BATTLE RESOLUTION:
        │
    ┌───▼────────────┐
    │ Victory?       │ Defeat?    Other?
    │ Completion?    │ Withdrawal │ Timeout
    └───┬──────────┬─┴────────────┴────┐
        │          │                   │
        ▼          ▼                   ▼
    [Victory]  [Defeat]            [Draw]
    [Screen]   [Screen]            [Screen]
        │          │                   │
        ├─ Collect ├─ Casualties   ├─ Partial
        │  Salvage │  Report       │  Salvage
        ├─ Revive  ├─ Reload Save  └─ Limited
        │  Units   │  Or Continue     Reward
        ├─ XP Gain │
        └─ Reward  │
               ┌───┴────────────────┐
               │                    │
               ▼                    ▼
          GEOSCAPE              GEOSCAPE
          (Continue)            (Continue)
```

---

## 6. Core Gameplay Loop (Detailed)

### Diagram: Day-to-Day Cycle

```
GEOSCAPE DAY CYCLE (Simplified view of 1 calendar day)

START OF DAY (0600 hours)
│
├─ Mission Detection Phase
│  ├─ Scan each province for alien activity
│  ├─ Roll for mission spawns (based on location, time, difficulty)
│  └─ Add new missions to active list
│
├─ Mission Management Phase
│  ├─ Update mission timers (urgency countdown)
│  ├─ Remove expired missions
│  ├─ Check victory/failure conditions
│  └─ Display active missions list
│
▼ MIDDAY (1200 hours)
│
├─ Player Decision Phase
│  ├─ Option 1: Deploy craft to mission
│  │  ├─ Select craft (with units, items)
│  │  ├─ Select mission destination
│  │  ├─ Launch mission (transition to Battlescape)
│  │  └─ [PLAY TACTICAL COMBAT]
│  │
│  ├─ Option 2: Advance time
│  │  ├─ Skip to next turn
│  │  └─ Process end-of-day events
│  │
│  └─ Option 3: Manage bases
│     ├─ View basescape
│     ├─ Queue research/manufacturing
│     └─ Manage personnel/equipment
│
▼ EVENING (1800 hours)
│
├─ Research Progress Phase
│  ├─ Calculate daily progress (scientists × multiplier)
│  ├─ Check for tech completion
│  └─ Apply unlock notifications
│
├─ Manufacturing Progress Phase
│  ├─ Calculate daily progress (engineers × efficiency)
│  ├─ Check for item completion
│  └─ Move completed items to inventory
│
▼ NIGHT (2200-0600 hours)
│
├─ Economic Processing
│  ├─ Calculate monthly updates (if last day of month):
│  │  ├─ Deduct maintenance costs
│  │  ├─ Receive funding
│  │  ├─ Calculate net balance
│  │  ├─ Update relations (decay by time)
│  │  └─ Generate market price changes
│  │
│  └─ Craft Recovery
│     ├─ Repair damaged craft (fuel, ammo)
│     ├─ Crew rest (recover morale/energy)
│     └─ Maintenance checks
│
├─ Campaign Events (Random)
│  ├─ 5% chance: Country relations shift
│  ├─ 3% chance: Supplier incident
│  ├─ 2% chance: Lore event triggers
│  └─ 1% chance: Special encounter
│
▼ MIDNIGHT - DAY ENDS
│
└─ Next day begins automatically
   (Notification of new missions, events, etc.)


MONTHLY CYCLE (Last day of month):

END OF MONTH PROCESSING:
├─ Expense Report
│  ├─ Total maintenance costs
│  ├─ Personnel salaries
│  ├─ Supplier payments
│  └─ Net economic impact
│
├─ Funding Update
│  ├─ Country funding received
│  ├─ Reputation multipliers applied
│  ├─ Account updated
│  └─ Warning if funds low
│
├─ Research Milestone
│  ├─ Bonus progress if funded well
│  └─ Penalty if underfunded
│
├─ Manufacturing Update
│  ├─ Bonus output if well-resourced
│  └─ Delay if underfunded
│
├─ Relations Decay
│  ├─ Each alliance/hostility decays slightly
│  ├─ Funding from countries affected by relations
│  └─ Market prices influenced by politics
│
└─ Market Update
   ├─ Price fluctuations (supply/demand)
   ├─ New suppliers available
   └─ Black market opportunities
```

---

## Summary

This section establishes the temporal and structural framework of AlienFall:

- **Game Loop:** Runs at 60 FPS, updates game state each frame
- **Geoscape Time:** 1 turn = 1 calendar day (campaign-scale decisions)
- **Interception Time:** 1 turn = 1 minute (brief encounters)
- **Battlescape Time:** 1 turn ≈ 10 seconds in-game (tactical combat)
- **Organization Progression:** 5 levels with increasing capabilities
- **Campaign Arc:** ~12-24 months of gameplay, multiple endings possible

These diagrams serve as reference for developers implementing time management, state transitions, and game loop mechanics.

---

**Related Documentation:**
- `wiki/systems/Geoscape.md` - Geoscape detailed mechanics
- `wiki/systems/Battlescape.md` - Battlescape detailed mechanics
- `wiki/systems/Basescape.md` - Basescape detailed mechanics
- `engine/core/state_manager.lua` - State transition implementation
- `engine/main.lua` - Game loop implementation
