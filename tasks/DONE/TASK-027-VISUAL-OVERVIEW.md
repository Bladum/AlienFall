# TASK-027 Visual System Overview

## System Architecture Diagram

```
┌─────────────────────────────────────────────────────────────────────┐
│                         TIME MANAGER                                │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐             │
│  │  Daily Tick  │  │ Weekly Tick  │  │ Monthly Tick │             │
│  │  (Training)  │  │  (Recovery)  │  │  (Reports)   │             │
│  └──────┬───────┘  └──────┬───────┘  └──────┬───────┘             │
└─────────┼──────────────────┼──────────────────┼────────────────────┘
          │                  │                  │
          ▼                  ▼                  ▼
┌─────────────────┐  ┌──────────────────┐  ┌──────────────────┐
│ TRAINING SYSTEM │  │ RECOVERY SYSTEMS │  │ MONTHLY SYSTEMS  │
│                 │  │                  │  │                  │
│ • 1 XP/day      │  │ • HP: 1/week     │  │ • Salaries       │
│ • +Facility XP  │  │ • Sanity: 1/week │  │ • Maintenance    │
│ • All units     │  │ • Craft: 20%/wk  │  │ • Reports        │
└────────┬────────┘  └────────┬─────────┘  └──────────────────┘
         │                    │
         ▼                    ▼
┌──────────────────────────────────────────────────────────────┐
│                    UNIT ENTITY (Extended)                     │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐       │
│  │  Experience  │  │    Health    │  │    Sanity    │       │
│  │              │  │              │  │              │       │
│  │ • XP: 250    │  │ • HP: 80/100 │  │ • Current: 7 │       │
│  │ • Level: 1   │  │ • Wounds: 1  │  │ • Max: 10    │       │
│  │ • Next: 300  │  │ • Healing: 1 │  │ • Rate: 1/wk │       │
│  └──────────────┘  └──────────────┘  └──────────────┘       │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐       │
│  │    Trait     │  │Transformation│  │    Medals    │       │
│  │              │  │              │  │              │       │
│  │ • Smart      │  │ • Cybernetic │  │ • Marksman I │       │
│  │ • -20% XP    │  │ • +1 AP      │  │ • Survivor   │       │
│  │ • Permanent  │  │ • -1 Will    │  │ • First Blood│       │
│  └──────────────┘  └──────────────┘  └──────────────┘       │
└──────────────────────────────────────────────────────────────┘
```

## Recovery Flow Diagram

```
┌────────────────────────────────────────────────────────────────┐
│                      BATTLE ENDS                               │
└──────────────────────────┬─────────────────────────────────────┘
                           │
                           ▼
┌──────────────────────────────────────────────────────────────────┐
│              POST-BATTLE PROCESSING                              │
│                                                                  │
│  1. Calculate Damage       ┌──────────────────────────────┐    │
│     • Total HP lost        │  Example Battle Results:      │    │
│     • Count wounds         │  • Unit took 40 HP damage     │    │
│                            │  • Got 2 critical wounds      │    │
│  2. Calculate Mission      │  • Mission stress: 2          │    │
│     Stress (0-3)          │  • Killed 6 enemies           │    │
│                            │  • Completed objective        │    │
│  3. Award Combat XP        └──────────────────────────────┘    │
│     • Base + Kills +                                            │
│       Objectives           ┌──────────────────────────────┐    │
│                            │  Results:                     │    │
│  4. Check Medals           │  • HP Recovery: 40 days       │    │
│     • Marksman I (6 kills)│  • Wound Recovery: 42 days    │    │
│     • Award 50 XP          │  • Total: 82 days (11.7 wks) │    │
│                            │  • Sanity: 8 → 6              │    │
│  5. Apply Sanity Loss      │  • XP: +50 (combat + medal)   │    │
│     • Reduce by stress     └──────────────────────────────┘    │
│                                                                  │
│  6. Start Recovery Timers                                       │
│                                                                  │
└──────────────────────────┬───────────────────────────────────────┘
                           │
                           ▼
┌────────────────────────────────────────────────────────────────┐
│                    RECOVERY PHASE                              │
│                                                                │
│  Week 1-6:   HP Recovery    (40 HP ÷ 1/week = 40 days)       │
│              ░░░░░░░░░░░░░░░░░░░░░░░░░░                       │
│                                                                │
│  Week 1-6:   Wound Recovery (2 wounds × 3 weeks = 42 days)   │
│              ░░░░░░░░░░░░░░░░░░░░░░░░░░                       │
│                                                                │
│  Week 1-6:   Sanity Recovery (6 → 10 = 4 points ÷ 1/week)    │
│              ░░░░░░░░                                          │
│                                                                │
│  Daily:      Training XP (+1/day = +7/week)                   │
│              ████████████████████████████████                  │
│                                                                │
│  Total Time: max(HP, Wound) = 82 days = 11.7 weeks           │
└────────────────────────────────────────────────────────────────┘
```

## Experience Progression Flow

```
┌─────────────────────────────────────────────────────────────────┐
│                    XP SOURCES                                   │
│                                                                 │
│  ┌───────────────┐   ┌───────────────┐   ┌───────────────┐   │
│  │    Training   │   │    Combat     │   │    Medals     │   │
│  │               │   │               │   │               │   │
│  │  1 XP/day     │   │  10-100 XP    │   │  50-150 XP    │   │
│  │  +Facilities  │   │  per mission  │   │  one-time     │   │
│  └───────┬───────┘   └───────┬───────┘   └───────┬───────┘   │
│          │                   │                   │             │
│          └───────────────────┼───────────────────┘             │
│                              ▼                                 │
│                    ┌─────────────────┐                         │
│                    │   UNIT XP POOL  │                         │
│                    └────────┬────────┘                         │
└─────────────────────────────┼──────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                    LEVEL PROGRESSION                            │
│                                                                 │
│  Level 0 ─────►  Level 1 ─────►  Level 2 ─────►  Level 3      │
│    0 XP          100 XP          300 XP          600 XP        │
│                                                                 │
│    ▼               ▼               ▼               ▼            │
│  Starting      +5% HP          +5% HP        Promotion!        │
│   Stats        +1 Aim          +1 React      +New Abilities    │
│                                                                 │
│  Level 3 ─────►  Level 4 ─────►  Level 5 ─────►  Level 6      │
│   600 XP         1000 XP         1500 XP         2100 XP       │
│                                                                 │
│    ▼               ▼               ▼               ▼            │
│  Elite         +5% HP        Promotion!        Master          │
│  Soldier       +1 Will       +Advanced Class   Soldier         │
│                                                                 │
│  Timeline (Training Only):                                      │
│  ─────────────────────────────────────────────────────────     │
│  Level 1: ~100 days (3.3 months)                               │
│  Level 2: ~300 days (10 months)                                │
│  Level 3: ~600 days (20 months / 1.7 years)                    │
│  Level 4: ~1000 days (33 months / 2.8 years)                   │
│                                                                 │
│  Timeline (Training + Combat):                                  │
│  ─────────────────────────────────────────────────────────     │
│  Level 1: ~2 months (with ~5 missions)                         │
│  Level 2: ~5 months (with ~10 missions)                        │
│  Level 3: ~10 months (with ~20 missions)                       │
│  Level 4: ~16 months (with ~30 missions)                       │
└─────────────────────────────────────────────────────────────────┘
```

## Facility Bonus System

```
┌─────────────────────────────────────────────────────────────────┐
│                         BASE LAYOUT                             │
│                                                                 │
│  ┌──────┐  ┌──────┐  ┌──────┐  ┌──────┐  ┌──────┐  ┌──────┐  │
│  │  HQ  │  │ Medical │ │Training│ │Workshop│ │ Support│ │Hangar│  │
│  │      │  │  Bay   │ │ Ground │ │        │ │ Center │ │      │  │
│  └──┬───┘  └───┬───┘  └───┬───┘  └───┬───┘  └───┬───┘  └──┬───┘  │
│     │          │          │          │          │         │      │
└─────┼──────────┼──────────┼──────────┼──────────┼─────────┼──────┘
      │          │          │          │          │         │
      ▼          ▼          ▼          ▼          ▼         ▼
┌───────────────────────────────────────────────────────────────────┐
│              FACILITY BONUS CALCULATOR                            │
│                                                                   │
│  Medical Bay:    +1 HP/week,  -25% wound time                   │
│  Training Ground: +5 XP/week                                     │
│  Workshop:       +10% craft repair/week                          │
│  Support Center: +1 sanity/week                                  │
│                                                                   │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │  TOTAL BONUSES (cached, updated on facility changes)    │   │
│  │                                                           │   │
│  │  • Medical:   +1 HP/week                                │   │
│  │  • Training:  +5 XP/week (0.7 XP/day)                  │   │
│  │  • Repair:    +10% craft repair/week                    │   │
│  │  • Support:   +1 sanity/week                            │   │
│  │  • Wound:     -25% recovery time                        │   │
│  └─────────────────────────────────────────────────────────┘   │
└───────────────────────────────────────────────────────────────────┘
```

## Trait & Transformation System

```
┌─────────────────────────────────────────────────────────────────┐
│                  UNIT BIRTH (Creation)                          │
│                                                                 │
│              ┌──────────────────────┐                           │
│              │   Roll Trait (RNG)   │                           │
│              └──────────┬───────────┘                           │
│                         │                                       │
│        ┌────────────────┼────────────────┐                      │
│        ▼                ▼                ▼                      │
│   ┌─────────┐     ┌─────────┐     ┌─────────┐                 │
│   │  Smart  │     │  Fast   │     │  Lucky  │                 │
│   │ -20% XP │     │  +1 AP  │     │+50% Crit│    (+ 12 more)  │
│   └─────────┘     └─────────┘     └─────────┘                 │
│                                                                 │
│   ★ PERMANENT - Cannot be changed                              │
│   ★ ONE PER UNIT                                               │
│   ★ Defined at creation                                        │
└─────────────────────────────────────────────────────────────────┘
                            │
                            ▼ (Later in game...)
┌─────────────────────────────────────────────────────────────────┐
│              TRANSFORMATION (Base Operation)                    │
│                                                                 │
│  Requirements:                                                  │
│  ✓ Transformation Facility built                               │
│  ✓ Technology researched                                       │
│  ✓ Resources available                                         │
│  ✓ Unit not wounded                                            │
│                                                                 │
│  ┌──────────────────────────────────────────────────────────┐ │
│  │              TRANSFORMATION OPTIONS                       │ │
│  │                                                           │ │
│  │  ┌─────────────────┐  ┌─────────────────┐  ┌──────────┐ │ │
│  │  │   Cybernetic    │  │    Psionic      │  │   Gene   │ │ │
│  │  │  Enhancement    │  │   Awakening     │  │   Mod    │ │ │
│  │  │                 │  │                 │  │          │ │ │
│  │  │  +1 AP          │  │  +5 Psi         │  │ +2 STR   │ │ │
│  │  │  -1 Will        │  │  +2 Sanity      │  │ +10% HP  │ │ │
│  │  │  4 wks recovery │  │  6 wks recovery │  │ 8 wks    │ │ │
│  │  └─────────────────┘  └─────────────────┘  └──────────┘ │ │
│  └──────────────────────────────────────────────────────────┘ │
│                                                                 │
│  Select One ──► Operation (1-2 weeks) ──► Recovery (4-8 weeks) │
│                                                                 │
│  ★ PERMANENT - Cannot be changed                               │
│  ★ ONE TRANSFORMATION SLOT                                     │
│  ★ Significant recovery time                                   │
└─────────────────────────────────────────────────────────────────┘
```

## Medal System Flow

```
┌─────────────────────────────────────────────────────────────────┐
│                       DURING BATTLE                             │
│                                                                 │
│  Track Statistics:                                              │
│  • Kills per unit                                              │
│  • Damage dealt                                                │
│  • Damage taken                                                │
│  • Civilians saved                                             │
│  • Mission objectives                                          │
│  • Panic events                                                │
│  • Special actions                                             │
└──────────────────────────┬──────────────────────────────────────┘
                           │
                           ▼
┌─────────────────────────────────────────────────────────────────┐
│                    POST-BATTLE PROCESSING                       │
│                                                                 │
│  For each unit:                                                 │
│  ┌────────────────────────────────────────────────────────┐   │
│  │  Check Medal Conditions:                                │   │
│  │                                                          │   │
│  │  IF (kills >= 5 AND never_earned("marksman_1"))        │   │
│  │      Award "Marksman I" (+50 XP)                        │   │
│  │                                                          │   │
│  │  IF (health_percent < 10 AND never_earned("survivor")) │   │
│  │      Award "Survivor" (+75 XP)                          │   │
│  │                                                          │   │
│  │  IF (no_civilian_deaths AND never_earned("protector")) │   │
│  │      Award "Protector" (+100 XP)                        │   │
│  │                                                          │   │
│  │  IF (mission_count == 1 AND never_earned("first_blood"))│   │
│  │      Award "First Blood" (+50 XP)                       │   │
│  └────────────────────────────────────────────────────────┘   │
│                                                                 │
│  Medal Awarded ──► +XP Bonus ──► Mark as Earned ──► UI Notify  │
└─────────────────────────────────────────────────────────────────┘
                           │
                           ▼
┌─────────────────────────────────────────────────────────────────┐
│                    MEDAL COLLECTION                             │
│                                                                 │
│  Unit "John Doe" Medals:                                        │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐       │
│  │Marksman I│  │Survivor  │  │Protector │  │First Blood│      │
│  │  50 XP   │  │  75 XP   │  │ 100 XP   │  │  50 XP   │       │
│  │2025-01-15│  │2025-02-03│  │2025-02-10│  │2025-01-05│       │
│  └──────────┘  └──────────┘  └──────────┘  └──────────┘       │
│                                                                 │
│  Total Medal XP: 275 XP                                         │
│  (Cannot earn same medal twice)                                 │
└─────────────────────────────────────────────────────────────────┘
```

## UI Layout Overview

```
┌─────────────────────────────────────────────────────────────────┐
│                    BASESCAPE - UNIT ROSTER                      │
├─────────────────────────────────────────────────────────────────┤
│ [BACK] [Facilities] [Soldiers] [Research] [Manufacturing]      │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│ Filter: [All] [Available] [Wounded] [Training]   Sort: [Name▼] │
│                                                                 │
│ ┌─────────────────────────────────────────────────────────────┐│
│ │ Unit Name       │ Lvl │ Health    │ Sanity   │ XP Progress ││
│ ├─────────────────┼─────┼───────────┼──────────┼─────────────┤│
│ │ John Doe  ★     │  2  │ ██████░░  │ ████░░░░ │ ████░░░░░░░ ││
│ │ [Soldier]       │     │  80/100   │   6/10   │  250/300 XP ││
│ │ Smart trait     │     │           │          │ 🏅 x3       ││
│ ├─────────────────┼─────┼───────────┼──────────┼─────────────┤│
│ │ Jane Smith      │  1  │ ████████  │ ████████ │ ██░░░░░░░░░ ││
│ │ [Medic]         │     │  100/100  │   8/8    │  120/300 XP ││
│ │ Fast trait      │     │ Available │          │ 🏅 x1       ││
│ ├─────────────────┼─────┼───────────┼──────────┼─────────────┤│
│ │ Bob Wilson 🔧   │  3  │ ██░░░░░░  │ ██░░░░░░ │ ██████░░░░░ ││
│ │ [Heavy]         │     │  30/100   │   3/12   │  650/1000   ││
│ │ Survivor trait  │     │ WOUNDED   │          │ 🏅 x5       ││
│ │                 │     │ 🏥 21 days│          │             ││
│ └─────────────────┴─────┴───────────┴──────────┴─────────────┘│
│                                                                 │
│ ┌───────────────────────────────────────────────────────────┐  │
│ │ SELECTED: John Doe (Level 2 Soldier)                      │  │
│ ├───────────────────────────────────────────────────────────┤  │
│ │ Health: 80/100  Sanity: 6/10  XP: 250/300                │  │
│ │ Trait: Smart (-20% XP required)                           │  │
│ │ Transformation: None                                       │  │
│ │ Medals: Marksman I, Survivor, First Blood                │  │
│ │ Stats: Aim 75 | React 60 | Will 50 | Strength 8          │  │
│ │ Status: Wounded - Recovery time: 14 days                  │  │
│ └───────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────┘
```

## Data Flow Summary

```
TIME PROGRESSION
     │
     ├──► Daily Tick ──► Training System ──► +1 XP per unit
     │
     ├──► Weekly Tick ─┬► HP Recovery ──► +1 HP + facilities
     │                 ├► Sanity Recovery ──► +1 sanity + facilities
     │                 └► Craft Repair ──► +20% HP + facilities
     │
     └──► Monthly Tick ──► Salaries, Reports, Maintenance

BATTLE FLOW
     │
     ├──► Combat ──► Damage Tracking
     │              └► Wound Counting
     │              └► Kill Tracking
     │              └► Objective Tracking
     │
     ├──► Post-Battle ─┬► Calculate Recovery Time
     │                 ├► Award Combat XP
     │                 ├► Check Medal Conditions
     │                 ├► Award Medal XP
     │                 ├► Apply Sanity Loss
     │                 └► Initialize Recovery Timers
     │
     └──► Back to Base ──► Recovery Phase begins

PROGRESSION FLOW
     │
     ├──► XP Gain ──► Check Level Thresholds
     │                └► Apply Stat Bonuses
     │                └► Check Class Promotion
     │                └► UI Notification
     │
     ├──► Trait (at creation) ──► Permanent Modifiers
     │
     ├──► Transformation (base op) ──► Operation Time
     │                                 └► Recovery Time
     │                                 └► Permanent Changes
     │
     └──► Medal (achievement) ──► One-time XP Bonus
                                  └► Mark as Earned
                                  └► Display in Collection
```

---

**Document Version:** 1.0  
**Last Updated:** October 13, 2025  
**Status:** Visual reference for TASK-027 implementation
