# 🎖️ Fame, Karma & Reputation System
## Canonical Reference for Player Organization Metrics

**Version**: 1.0
**Status**: Complete specification
**Canonical Source**: YES (all other files reference this document)

## Table of Contents

- [Overview](#overview)
- [Karma System](#system-1-karma-100-to-100)
- [Fame System](#system-2-fame-0-100)
- [Reputation System](#system-3-reputation-0-100)
- [Score System](#system-4-score-0-)
- [Integration with Gameplay](#integration-with-gameplay)

---

## OVERVIEW

AlienFall tracks player organization standing through four independent metrics:

| Metric | Range | Purpose | Decay | Impact |
|--------|-------|---------|-------|--------|
| **Karma** | -100 to +100 | Moral alignment | Passive to 0 | Mission gating, Advisor access |
| **Fame** | 0-100 | Public awareness | Passive to 0 | Mission difficulty, UFO threat |
| **Reputation** | 0-100 | Legal organizational power | +1/quarter | Diplomatic leverage |
| **Score** | 0-∞ | Humanity saved per country | Never | Ending determination |

---

## SYSTEM 1: KARMA (-100 to +100)

### Definition
Tracks player moral alignment based on decisions and actions during campaign.

### Gain/Loss Sources
- **Mission outcomes**: Victory vs surrender/escape
- **Unit treatment**: Casualties, prisoner treatment, unit demotion context
- **Advisor choices**: Alignment-based advisors (+1/month passive)
- **Diplomatic actions**: Country blackmail, support, or protection
- **Special events**: Moral dilemma outcomes

### Decay Mechanics
- Passive decay to 0 over time (no active decay rate specified; modder-defined)
- No minimum or maximum penalties
- Independent of Fame/Reputation (no cross-linking)

### Impact on Gameplay
- Mission gating: Some missions require Karma threshold (e.g., "requires Karma 50+ to negotiate alliance")
- Advisor access: Evil advisors require Karma -50 or lower; good advisors require +50 or higher
- Recruitment: Mercenary units available at any Karma; special units gated by alignment
- Narrative: Ending affected by cumulative Karma (good vs neutral vs evil path)

### Examples
```
Save civilian colony → +5 Karma
Execute captured enemies → -10 Karma each
Hire "Dr. Tygan" (neutral advisor) → No change, but +1/month passive
Hire "Black Ops Director" (evil advisor) → No Karma requirement, +1 Karma/month bonus
Mission "Rescue Scientists" → +20 if successful, -5 if you abandon them
```

---

## SYSTEM 2: FAME (0-100)

### Definition
Tracks how well-known player organization is globally; represents public awareness and notoriety.

### Gain/Loss Sources
- **Mission success**: Visibility = fame gain (loud tactics = +Fame, stealth = minimal)
- **Research breakthroughs**: Published research = +Fame
- **High-profile operations**: Destroying high-value targets or defending key cities
- **Propaganda**: Country media coverage (modder-defined events)
- **Defeats**: High-casualty losses = reputation gain (infamy = fame too)

### Decay Mechanics
- Passive decay to 0 over time (no active decay rate specified; modder-defined)
- Fame without activity fades (public forgets unremarkable organization)
- Independent of Karma/Reputation

### Impact on Gameplay
- Mission generation: Higher Fame = more mission offers, higher difficulty scaling
- UFO attention: Aliens prioritize famous organizations (more interception attempts)
- Diplomat reactions: Countries notice famous organizations, may request partnership
- Black market: Some black market services require Fame threshold

### Examples
```
Successful mission (stealth) → +2 Fame
Successful mission (loud: explosives) → +5 Fame
No missions for 1 month → -1 Fame passive
Research published "Plasma Weapons" → +10 Fame
UFO interception (succeeded) → +15 Fame
Large casualty loss (mission failure) → +10 Fame (notoriety)
```

---

## SYSTEM 3: REPUTATION (0-100)

### Definition
Tracks legal organizational authority and legitimacy in the international community.

### Gain/Loss Sources
- **Quarterly accumulation**: +1 Reputation per quarter (automatic, no action needed)
- **Country protection**: Defending country = +Reputation with that country
- **Legal operations**: Operating within country borders with permission = +Reputation
- **Research sharing**: Publishing research with UN/countries = +Reputation

### Decay Mechanics
- NO DECAY: Reputation never decreases (permanent organizational authority)
- Only increases via passive quarterly gain and specific actions
- Very slow progression (max 400 reputation in 100 in-game years)

### Impact on Gameplay
- Diplomatic leverage: Higher Reputation = better negotiation results with countries
- Legal standing: Countries more likely to grant base placement permission
- Funding: Government grants affected by Reputation (higher = better support)
- Ending: Affects how countries view player organization (legal hero vs rogue agency)

### Examples
```
Quarter 1 → +1 Reputation (automatic)
Quarter 2 → +1 Reputation (automatic)
Defend USA city successfully → +5 Reputation with USA
Research published to UN → +3 global Reputation
Total after 2.5 quarters: 1 + 1 + 5 + 3 = 10 Reputation
```

---

## SYSTEM 4: SCORE (0-∞)

### Definition
Tracks total humanity saved in each country; measures organizational effectiveness in mission.

### Gain/Loss Sources
- **Mission success**: Each mission saves population points (modder-defined per mission)
- **Country defense**: Protect country = +Score with that country
- **Casualties prevented**: If mission saves civilians = +Score
- **UFO destruction**: Each UFO destroyed = +Score (humanity spared)

### No Decay
- Score accumulates permanently
- Per-country tracking (e.g., USA Score separate from China Score)

### Impact on Gameplay
- Ending determination: Total Score across all countries affects ending cinematics
- Country gratitude: Countries with high Score more supportive
- Narrative: Reflects how well player is saving humanity

### Examples
```
Mission "Save Arctic Research Station": +50 Score (global)
Mission "Defend Moscow": +30 Score (Russia), +5 Score (global)
Destroy UFO → +20 Score (global)
After campaign: USA=500, China=400, Russia=300, etc.
Total Score determines ending: 5000+ = positive ending, 0-1000 = grim ending
```

---

## CRITICAL DESIGN NOTES

### Independence
- All four systems track independently
- NO cross-linking or dependencies
- Karma does NOT affect Fame, Relations do NOT affect Score, etc.
- Each system is its own progression track

### Visibility to Player
- All metrics visible in strategy layer UI
- Trend indicators show direction (increasing/decreasing)
- Thresholds clearly marked (e.g., "Advisor unlocked at Karma +50")

### Modder Configuration
- Decay rates: Modder defines how fast Karma/Fame decay
- Gains/losses: Modder defines per-action values
- Mission gating: Modder defines which missions require thresholds
- Score calculation: Modder defines per-mission points

### Relations System (SEPARATE)
- **Relations** = diplomacy with countries/suppliers/factions (NOT tracked here)
- Relations system documented in Relations.md
- Relations do NOT affect Karma/Fame/Reputation/Score
- Player can have high Karma but low Relations (e.g., attacked a country but for moral reasons)

---

## QUICK REFERENCE

```
KARMA: How good/evil you are
→ Affects: Advisor alignment access, narrative alignment
→ Decay: Passive to 0 (modder-defined rate)
→ Gating: Some missions require Karma threshold

FAME: How well-known you are
→ Affects: Mission difficulty scaling, UFO interception rate, diplomat attention
→ Decay: Passive to 0 (modder-defined rate)
→ Gating: Some black market services require Fame threshold

REPUTATION: How legally legitimate you are
→ Affects: Country permission, funding, ending
→ NO DECAY: Permanent accumulation (+1/quarter)
→ Gating: Affects diplomatic negotiation results

SCORE: How much humanity you've saved
→ Affects: Ending determination, country gratitude
→ NO DECAY: Permanent accumulation
→ Per-country tracking: USA Score ≠ China Score
```

---

## FILE REFERENCES

**Canonical Source**: This file (FameKarmaReputation.md)

**Reference from**:
- Geoscape.md § Mission Generation (Fame affects difficulty)
- Politics.md § Advisor System (Karma affects access)
- Relations.md (Note: Relations ≠ Karma/Fame/Reputation)
- Units.md § Demotion System (Karma impact)
- Glossary.md § Terminology
- Overview.md § Ending Determination (Score-based)

**Do not duplicate**: All game mechanics referencing Karma/Fame/Reputation/Score should link to this document.
