# Politics System

> **Status**: Design Document
> **Last Updated**: 2025-10-28
> **Related Systems**: Countries.md, DiplomaticRelations_Technical.md, Finance.md, ai_systems.md

## Table of Contents

- [Fame System](#fame-system)
- [Karma System](#karma-system)
- [Relationship System](#relationship-system)
- [Power Points](#power-points)
- [Advisors System](#advisors-system)
- [Organization Level](#organization-level)

---

## Fame System

### Overview
Fame represents the player organization's public reputation and recognition by civilians, governments, and media. Fame is a measurable indicator of how well-known the organization has become, with significant gameplay implications.

**Fame Range & Levels**
- Scale: 0 to 100
- **Unknown** (0-24): Minimal public awareness, limited opportunities
- **Known** (25-59): Recognized by some nations, basic supplier access
- **Famous** (60-89): World-renowned, maximum opportunities unlocked
- **Legendary** (90-100): Maximum public recognition, exclusive content available

**Gameplay Effects**
- **Mission Generation**: High fame generates 20-30% additional special missions
- **Supplier Availability**: Tier-locked suppliers (Famous+ required for premium suppliers)
- **Public Confidence**: Affects population morale and support for organization
- **Recruitment**: High fame attracts volunteer soldiers (+15% recruit quality per tier)
- **Cost Modifiers**: Fame affects pricing across marketplace
- **Media Attention**: Famous+ organizations attract scrutiny (black market risks increase)
- **Funding Bonus**: +10% to +50% additional monthly funding per fame tier

**Fame Sources**
- **Mission Success**: +5 fame per completed mission
- **Mission Failure**: -3 fame per mission failure
- **UFO Destroyed**: +2 fame per UFO kill
- **Base Raided**: -10 fame per player base attacked
- **Research Breakthrough**: +3 fame per completed research
- **Black Market Discovery**: -20 fame (major penalty)
- **Major Victory**: +15 fame (defeating epic threats)
- **Civilian Casualties**: -5 fame (collateral damage)

**Maintenance System**
- Fame naturally decays by 1-2 points per month of inactivity
- Active military operations maintain or increase fame
- Peaceful periods reduce fame due to loss of public interest
- Special events reset decay counter

**Strategic Considerations**
- Too much fame can attract unwanted attention from hostile factions
- High-fame organizations experience 30% more enemy campaign frequency
- Balancing public perception with operational security is crucial
- Major victories increase fame; public failures decrease it significantly

---

## Karma System

### Overview
Karma is an internal moral alignment tracker reflecting the player organization's ethical choices and conduct. Unlike fame, karma is invisible to the game world and only affects available options and events behind the scenes.

**Karma Range & Alignment Levels**
- Scale: -100 (malevolent) to +100 (benevolent)
- **Evil** (-100 to -75): Darkest choices, ruthless tactics
- **Ruthless** (-74 to -40): Efficient but amoral operations
- **Pragmatic** (-39 to -10): Balanced between ends and means
- **Neutral** (-9 to +9): No clear alignment
- **Principled** (+10 to +40): Ethical approach to operations
- **Saint** (+41 to +100): Highest moral standards

**Karma Influences**
- **Available Contracts**: Black market and faction missions differ based on karma
- **NPC Reactions**: Certain advisors and allies respond differently
- **Event Outcomes**: Random events may unfold differently (7+ variant outcomes)
- **Recruitment**: Some unit types prefer specific karma alignments
- **Faction Relations**: Some factions favor high/low karma organizations
- **Story Branches**: Multiple ending paths determined by karma trajectory

**Karma Sources & Effects**

| Action | Karma Impact | Notes |
|---|---|---|
| Civilian Killed | -10 | Includes collateral damage |
| Civilian Saved | +5 | Active rescue operations |
| Prisoner Executed | -20 | Severe moral violation |
| Prisoner Spared | +10 | Humanitarian treatment |
| Interrogation (Torture) | -3 | Per prisoner tortured |
| Humanitarian Mission | +15 | Special high-value operations |
| Black Market Purchase | -5 to -20 | Per transaction (varies) |
| Illegal Operation | -10 to -30 | Based on severity |
| Peaceful Resolution | +15 | Diplomatic success |
| War Crime | -30 | Extreme conduct violation |
| Research Completed | +3 | Defensive research only |
| Unethical Experiment | -15 | Alien experimentation |

**Mechanical Effects by Alignment**

| Alignment | Black Market | Humanitarian | Special Missions | Supplier Impact |
|---|---|---|---|---|
| Evil (-100 to -75) | Unlimited | Blocked | Assassination, Raids | War-profiteers embrace |
| Ruthless (-74 to -40) | Enabled | Limited | Covert Ops | Amoral suppliers prefer |
| Pragmatic (-39 to -10) | Available | Available | Varied | Neutral suppliers available |
| Neutral (-9 to +9) | Limited | Limited | Balanced | All suppliers accept |
| Principled (+10 to +40) | Restricted | Enabled | Humanitarian | Ethical suppliers prefer |
| Saint (+41 to +100) | Blocked | Unlimited | Liberation, Defense | Idealistic suppliers embrace |

**Hidden Mechanic**
Players must infer karma effects through gameplay; no explicit moral choice display exists. This creates emergent gameplay where decisions have subtle long-term consequences. Alignment changes unlock different endings and campaign paths.

---

## Relationship System

**See Also**: [DiplomaticRelations_Technical.md](./DiplomaticRelations_Technical.md) for complete relationship mechanics specification

**Overview**
Relationships represent diplomatic standing with three major groups: Countries, Suppliers, and Factions. All relationships operate on a unified scale and significantly impact available options and costs. Relationships are the foundation of strategic positioning and long-term campaign success.

**Universal Relationship Scale**
- Range: -100 (hostile/embargo) to +100 (allied/preferred partner)
- Monthly changes: ±1 to ±5 based on actions, payments, mission success
- Relationships can shift multiple points per month based on events
- Cumulative score system: Each major action adds/subtracts from total

**Relationship Mechanics**
```
Relationship Change = (Action Points) + (Event Bonus/Penalty) - (Time Decay)
Change per Month: Base ±0 (neutral), varies from -10 (major offense) to +10 (treaty signing)
Time Decay: -1 point per 3 months of inactivity (friendship atrophy)
Threshold Events: Every 10-point change can trigger diplomatic incidents
```

---

#### Country Relationships

**Impact on Operations**
- **Mission Generation**: Relationship affects mission availability and types in provinces
  - Hostile (-50 to -100): 50% fewer missions, only defensive/counter-attack types available
  - Neutral (0): Normal mission frequency
  - Allied (+50 to +100): 30% more missions, access to special operations
- **Funding Allocation**: Determines funding level (1-10 scale) for monthly income
  - Per level: 10% base funding adjustment (-50% at level 1, +50% at level 10)
  - Hostile funding cut to 0; country may demand payoff to restore
- **Base Construction**: Negative relationships restrict base building rights (need 0+ relationship)
- **Recruitment**: Country relationship gates access to national military units
  - Allied units require +50 relationship minimum
  - Conscripted units available at +25 relationship
- **Tax Benefits**: Positive relationships may provide tax reductions (5-15%)
- **Provincial Control**: High-trust countries allow more autonomous operations (reduce inspection frequency)

**Diplomatic Influence Mechanics**
- **Military Victories**: +2 per region defended, +3 per major UFO kill in territory
- **Civilian Casualties**: -1 to -5 per incident (severity dependent)
- **Failed Missions**: -2 per failure (reputation damage)
- **International Incidents**: Affecting multiple relationships simultaneously
  - War declaration: -30 with enemy, -10 with neutrals
  - Treaty signing: +20 with parties, ±5 with third parties
  - Black market discovery: -15 with all countries
- **Trade Agreements**: +1 per month active (negotiated through diplomacy)
- **Cultural Exchange**: +0.5 per month (passive, requires embassy)
- **Military Aid**: +3 for substantial forces deployed
- **Intelligence Sharing**: +2 per significant intelligence asset provided

**Country Relationship States**

| Relationship | Diplomatic Status | Mission Access | Funding Mod | Base Rights | Trade |
|---|---|---|---|---|---|
| -100 to -75 | War/Embargo | Combat only | -80% | Blocked | Blocked |
| -74 to -40 | Hostile | Limited | -40% | Restricted | Restricted |
| -39 to -10 | Cold War | Normal | -20% | Normal | Available |
| -9 to +10 | Neutral | Standard | Baseline | Standard | Standard |
| +11 to +40 | Cooperative | Enhanced | +20% | Standard | Enhanced |
| +41 to +75 | Allied | Expanded | +40% | +1 base | Preferred |
| +76 to +100 | Strategic Partner | Maximum | +50% | +2 bases | Exclusive |

---

#### Supplier Relationships

**Impact on Trading**
```
Pricing Modifier = 1.0 + (0.005 × (100 - Relationship))
Availability Modifier = 0.5 + (0.005 × Relationship)
Delivery Speed Modifier = 1.0 - (0.01 × Relationship) [faster at higher relations]
```
Examples:
- At relation -100: Price 1.5x, 0% availability, +5 days delivery
- At relation 0: Price 1.0x, 100% availability, standard delivery
- At relation +100: Price 0.5x, 150% availability, -5 days delivery

- **Availability**: Friendly suppliers provide better stock and priority delivery
- **Embargo Mechanics**: At -100 relationship, suppliers enforce complete trade blocks (cannot purchase at all)
- **Exclusive Items**: Suppliers offer unique equipment only at +50 relationship or higher (locked items)
- **Purchase Limits**: Relationship affects monthly purchase caps
  - Hostile: 50% capacity limit
  - Neutral: 100% capacity
  - Allied: 150% capacity

**Cultivation Mechanics**
- **Regular Purchases**: +0.5 relation per large order (50+ units)
- **Large Orders**: +1 relation per bulk contract (100+ units or 5000+ credits)
- **Diplomacy Investments**: +3-5 relation per diplomatic action (costs power points)
- **Payment Reliability**: +0.2 per month of on-time payments, -5 per late payment
- **Exclusive Contracts**: +2 relation per exclusive supply agreement
- **Long-term Commitment**: +0.1 per month at +50 relationship (loyalty bonus)
- **Betrayal**: -10 to -20 relation for switching to competing supplier

**Supply Priority Tiers**

| Relationship | Priority | Price | Availability | Delivery | Features |
|---|---|---|---|---|---|
| -100 to -50 | Embargo | +500% | Blocked | N/A | None |
| -49 to -1 | Restricted | +25% | 25% normal | +5 days | Rare items blocked |
| 0 to +25 | Standard | Baseline | 100% | Normal | All items available |
| +26 to +50 | Preferred | -15% | 120% | -2 days | Some exclusives unlock |
| +51 to +75 | Priority | -25% | 130% | -3 days | More exclusives |
| +76 to +100 | VIP | -50% | 150% | -5 days | All exclusive access |

---

#### Faction Relationships

**Impact on Opposition**
- **Mission Frequency**: Affects enemy campaign intensity
  - Hostile (-50 to -100): 50% increased enemy missions
  - Neutral: Normal frequency
  - Allied (+50 to +100): 50% reduced enemy missions
- **Mission Difficulty**: Faction relationship affects deployed unit quality
  - Hostile: Elite units (+20% HP, +15% damage)
  - Neutral: Standard units
  - Allied: Reduced deployments (-30% enemy forces)
- **Truce Mechanics**: High relationships (+75+) unlock temporary truces (1-3 months)
- **Intelligence**: Negative relationships trigger spy missions against player
  - Hostile: 2-3 spy missions per month
  - Neutral: 1 spy mission per month
  - Allied: 0 spy missions
- **Reinforcements**: Factions send stronger reinforcements when relationships are poor
  - Hostile: Reinforcements 150% strength
  - Allied: Reinforcements 50% strength

**Tactical Consequence**
- **Active Combat**: -2 relationship per destroyed faction unit
- **Capturing Operatives**: -5 relationship per captured faction leader
- **Diplomatic Concessions**: +10 relationship (temporary, costs funds)
- **Military Withdrawal**: +5 relationship (showing restraint)
- **Tech Transfer**: +15 relationship (technology cooperation)
- **Base Attacks**: -20 relationship per faction base destroyed
- **Civil Support**: +3 relationship (protecting faction's civilians)

**Faction Relationship States**

| Relationship | State | Missions | Forces | Espionage | Trade |
|---|---|---|---|---|---|
| -100 to -60 | War | Offensive | Massive | Heavy | Blocked |
| -59 to -30 | Hostile | Combat | Strong | Moderate | None |
| -29 to 0 | Cold | Contested | Normal | Light | Limited |
| 1 to +30 | Neutral | Rare | Minimal | None | Standard |
| +31 to +60 | Cooperative | Alliance | Support | None | Preferred |
| +61 to +100 | Allied | Joint Ops | Assistance | None | Excellent |

**Multiple Faction Dynamics**
- Each faction operates independently with separate relationships
- Allying with one faction may penalize others (-10 to -30)
- Faction rivalries create complex diplomatic landscape
- Coalition mechanics: United factions increase mission difficulty
- Defection: Switching faction support damages old relationship (-50)

**Relationship Effects on Story**
- Dramatic story events unlock at specific relationship thresholds
- Betrayals trigger narrative consequences
- Reconciliations open new mission paths
- Multiple faction endings possible based on relationship outcomes

---

## Power Points

**Overview**
Power Points represent the player organization's developmental progress, measured monthly. They represent tangible indicators of strategic advancement independent of immediate success metrics. Power Points are the primary currency for organizational growth decisions.

**Acquisition Mechanics**
```
Monthly Generation = 1 (base) + Bonuses - Penalties
```
- **Base Generation**: Standard award of 1 point per month
- **Special Events**:
  - Major victories: +3 to +5 points
  - Treaty signing: +2 points
  - Technology breakthrough: +1 point
  - Base established: +1 point
- **Event Losses**:
  - Catastrophic failure: -3 to -5 points
  - Betrayal/defection: -5 points
  - Black market discovery: -2 points
  - Advisor dismissal: -1 point
- **Milestone Achievements**:
  - 10 successful missions: +2 points
  - 50,000 credits earned: +1 point
  - 5 bases established: +3 points
  - Organization level up: +5 points

**Point Accumulation Over Time**

| Campaign Month | Monthly Generation | Cumulative Total |
|---|---|---|
| Month 1-3 | 1 point/month | 3-5 points |
| Month 4-6 | 1-2 points/month (with events) | 8-15 points |
| Month 7-12 | 2-3 points/month | 20-40 points |
| Year 2+ | 3-5 points/month | 50-100+ points |

**Strategic Purpose**
Power Points serve as:
- **Currency for Recruiting Advisors**: High-quality advisors cost 5-15 points each
- **Organization Advancement**: Leveling up costs 10-50 points depending on level
- **Technology Unlock**: Exclusive tech requires point expenditure (5-20 points)
- **Emergency Measures**: Unlock diplomatic immunity or crisis management features (5-10 points)
- **Indicator of Long-term Campaign Progression**: Direct measure of organizational maturity

**Usage Strategy**
- Early game: Invest in advisors to gain competitive advantage
- Mid game: Balance advisor investment with organization leveling
- Late game: Use points for exclusive unlocks and emergency measures
- Strategic timing: Save points for critical moments vs. steady investment

**Point Management**
- No maximum point accumulation (accumulate indefinitely)
- No point decay or loss (except through spending)
- Monthly summary shows generation and recent spending
- Point forecasting: Predict future availability based on trends

---

## Advisor System Specification (A9: Advisor System Design)

**Overview**
This section specifies comprehensive Advisor system mechanics, including hiring mechanics, advisor specialization, synergy systems, and conflict resolution. Advisors are critical organizational assets providing strategic bonuses and representing leadership structure.

**Core Advisor Mechanics**

Advisors are permanent or temporary staff providing sustained gameplay bonuses. The design focuses on:
1. **Meaningful choice**: Each advisor has distinct impact
2. **Strategic synergy**: Multiple advisors create compound benefits
3. **Opportunity cost**: Limited slots force prioritization
4. **Financial drain**: Monthly salary creates ongoing cost consideration

**Advisor Hiring & Activation**

```
Advisor Acquisition Formula:
Total Cost = Point Cost + (Monthly Salary × Duration)
  Point Cost: One-time cost in Power Points (4-20 depending on tier)
  Monthly Salary: Ongoing cost in Credits (500-8000 depending on tier)
  Duration: Advisor employment duration (months until retirement/dismissal)

Hiring Timeline = 1 month from point expenditure to advisor availability
Example A9-1: Hiring CTO for 6-month term
  - Point Cost: 8 points (paid immediately)
  - Monthly Salary: 2,500 credits
  - 6-month salary: 15,000 credits total
  - Total cost: 8 points + 15,000 credits
  - Duration: From month 2 onwards (1 month hiring lag)
```

**Advisor Conflict Resolution**

Design principle: Advisors should never provide conflicting guidance; if conflicts exist, one advisor's bonus overrides (typically the higher-tier advisor). Player manages advisor team composition to avoid conflicts.

**Conflict Resolution Rules:**
1. **No direct conflicts** between advisor specializations (each focuses on different domain)
2. **Hierarchy override**: If bonuses overlap, highest-tier advisor's bonus applies
3. **Synergy activation**: Multiple compatible advisors stack bonuses (see Advisor Synergies below)
4. **Incompatibility penalty**: Poorly matched advisors reduce both by 5-10%

**Example A9-2: Advisor Conflict Resolution**
- Scenario: Hire Military Commander (combat focus) + Director of Intelligence (espionage focus)
- Compatibility: No direct conflict (different domains)
- Synergy: Can stack bonuses (+10% damage, +20% spy success simultaneously)
- Result: Both advisors provide full benefits

**Advisor Synergy System**

Strategic advisor combinations unlock synergy bonuses exceeding individual advisor bonuses:

```
Advisor Synergies (Multiplicative Stacking):
1. Finance Team (CFO + Quartermaster)
   - Combined bonus: +5% income, -20% transfer costs
   - Formula: Individual bonuses + 5% combo bonus
   - Cost: 16 points (10 + 6)
   - Activation: Requires both advisors hired simultaneously
   - Duration: Synergy lasts as long as both advisors employed

2. War Machine (Military Commander + COO)
   - Combined bonus: +15% unit damage, +10% base production
   - Formula: +10% damage + 5% COO bonus + +10% production bonus
   - Cost: 20 points (11 + 9)
   - Synergy effect: 5% damage bonus enhancement from COO presence

3. Intelligence Network (Director of Intelligence + Minister of Diplomacy)
   - Combined bonus: +25% spy success, +2 relations/month
   - Formula: +20% spy + 5% enhancement + +1 diplomacy + +1 adjacency bonus
   - Cost: 19 points (12 + 7)
   - Special: Synergy improves both diplomatic and espionage operations

4. Research Division (CTO + Chief Engineer)
   - Combined bonus: +25% research speed, +20% construction speed
   - Formula: +20% research + 5% enhancement + +10% construction + +10% enhancement
   - Cost: 16 points (8 + 8)
   - Synergy effect: Speeds up both technology development and facility building

5. Logistics Expert (Quartermaster + COO)
   - Combined bonus: +30% production speed, +25% transfer speed
   - Formula: +20% transfer + 10% COO production bonus + +10% synergy enhancement
   - Cost: 15 points (6 + 9)
   - Synergy effect: Dramatically increases base operational throughput
```

**Synergy Activation Rules:**
- Synergies require both advisors to be actively employed (no partial credit)
- Synergy bonuses are not "chosen"; they activate automatically when conditions met
- Player can deliberately avoid synergy combinations to maintain flexibility
- Synergy bonuses stack multiplicatively with individual bonuses

**Advisor Specialization Impact**

Each advisor excels in specific areas with defined bonus ranges:

| Advisor | Primary Domain | Bonus Range | Secondary Effects | Tier Scaling |
|---------|---|---|---|---|
| CTO | Research | +10-20% | +5-15% facility upgrades | Higher tier: +5% per tier |
| CFO | Financial | +10-20% | -5-10% marketplace prices | Higher tier: +3% per tier |
| COO | Operations | +8-15% | +5-10% unit XP gains | Higher tier: +2% per tier |
| Director of Intelligence | Espionage | +15-30% | -20-50% enemy spy effectiveness | Higher tier: +5% per tier |
| Military Commander | Combat | +8-15% | +5-10% unit accuracy | Higher tier: +3% per tier |
| Minister of Diplomacy | Diplomacy | +1-3 relations/month | -40-60% diplomatic action costs | Higher tier: +0.5 per tier |
| Chief Engineer | Construction | +12-20% | +8-15% repair speed | Higher tier: +4% per tier |
| Quartermaster | Logistics | +15-25% | -10-20% transfer costs | Higher tier: +5% per tier |

**Advisor Hiring Strategy by Campaign Phase**

Phase-based recommendations for optimal progression:

**Phase 1 (Months 1-3: Startup)**
- Primary focus: CTO or Quartermaster
- Strategy: Build research or logistics advantage early
- Rationale: Technology or supply-chain foundation enables all other operations
- Point allocation: 8-10 points total investment
- Recommended: CTO (research advantage compounds over time)

**Phase 2 (Months 4-9: Growth)**
- Add: CFO or COO
- Strategy: Add financial/operational management as complexity increases
- Rationale: Early advantages need reinforcement; manage growing resource pools
- Point allocation: 15-20 points total
- Recommended combo: CTO + CFO (research + finance synergy potential at this tier)

**Phase 3 (Months 10-15: Crisis)**
- Add: Military Commander or Minister of Diplomacy
- Strategy: Prepare for escalation through military or diplomatic strength
- Rationale: Campaign intensifies; need combat edge or diplomatic flexibility
- Point allocation: 25-35 points total
- Recommended: Add Military Commander for combat bonuses during active warfare

**Phase 4 (Months 16+: Endgame)**
- Fill remaining slots: Director of Intelligence or Chief Engineer
- Strategy: Complete tactical picture through espionage or infrastructure
- Rationale: All core systems online; add specialized capabilities
- Point allocation: 40-50+ points total
- Endgame consideration: Can afford multiple synergy combos

**Advisor Retirement & Dismissal**

Advisors can leave through player action or retirement:

```
Dismissal Cost = Monthly Salary × 0.75 (severance package)
Relationship penalty: -20 with advisor's home faction
Re-hire penalty: 20% point cost increase if rehiring same advisor

Retirement Options:
1. Player dismisses advisor (voluntary separation, relationship penalty)
2. Advisor retires naturally (random after 24+ months, no penalty)
3. Advisor dies on mission (rare special event, no dismissal cost)
4. Advisor poached by rival (morale/performance based, -10 relations if accepted offer)
```

**Example A9-3: Advisor Dismissal**
- Advisor: CTO employed for 12 months
- Monthly Salary: 2,500 credits
- Dismissal decision: Player fires CTO to make room for different specialist
- Severance: 2,500 × 0.75 = 1,875 credits due
- Relationship penalty: -20 with Tech faction
- Re-hire cost: Next time hiring CTO costs 8 points × 1.2 = 9.6 points (20% increase)

---

## Relations & Black Market Mechanics (R7: Relations/Black Market Events)

**Overview**
This specification details diplomatic relations mechanics and black market event systems. Note: Espionage is NOT included in this system (diplomatic-only approach). Black Market represents illicit supply sources, rare items, and high-risk/high-reward opportunities independent from normal marketplace.

**Relations System (Diplomacy-Only, No Espionage)**

**Design Philosophy**
Relations represent pure diplomatic standing with countries, factions, and suppliers. No espionage subversion system exists; all relations change through:
- Direct military action (combat, base construction in territory)
- Diplomatic actions (treaties, missions, trades)
- Event outcomes (randomized faction behaviors)
- Supply line interactions (interruption, successful delivery)

**Relations Scale**
```
Universal Relations Scale: -100 (hostile embargo) to +100 (strategic alliance)

Tiers:
- Hostile (-100 to -75): Military action possible against organization
- Antagonistic (-74 to -50): Increased military response, market disruption
- Cold (-49 to -25): Limited cooperation, expensive transactions
- Neutral (-24 to +24): Standard interaction costs
- Warm (+25 to +49): Discounts on services, preferential treatment
- Allied (+50 to +75): Cooperative military actions, shared intelligence
- Bonded (+76 to +100): Maximum cooperation, exclusive treaties, preferential supplier access

Monthly Change Formula:
Relations Change = (Action Points) + (Event Modifier) - (Time Decay × 0.5)
  Action Points: +1 to +5 per completed mission for faction (varies by mission type)
  Event Modifier: -10 to +10 for random events (warfare, supply line disruption, etc)
  Time Decay: -0.5 to -1 per month of no interaction (minimum 0, prevents continuous decay)
```

**Example R7-1: Relations Change**
- Starting relations: +30 (Warm)
- Player completes 2 missions for country: +2 +2 = +4 action points
- Random event: Supply interruption by 3rd party: -5 modifier
- Time decay: 0 months active, no decay applies
- Calculation: 30 + 4 - 5 = 29 (Warm, slightly decreased)

**Relations & Diplomatic Actions**

```
Diplomatic Action Costs (Modified by Relations & Minister of Diplomacy):

Treaty Negotiation:
  - Cold relations: 50K credits
  - Neutral relations: 30K credits
  - Warm relations: 15K credits
  - Allied relations: 5K credits
  - With Minister of Diplomacy: -50% all costs

Trade Agreement:
  - Neutral relations: 10K credits
  - Warm relations: 5K credits
  - Allied relations: Free (automatic negotiation)

Conflict Resolution:
  - Any relations: 20-50K credits depending on conflict severity
  - With Minister of Diplomacy: 75% cost reduction + improved outcome

Barrier to Common Action:
  - Neutral or better relations required
  - Cold relations block military cooperation
  - Warm+ relations enable joint operations (shared XP/rewards)
```

**Example R7-2: Treaty Negotiation**
- Country relations: Neutral (+10)
- Base cost: 30K credits
- Minister of Diplomacy hired: -50% = 15K credits
- Outcome: Treaty established, relations improve to Warm (cost savings allow additional negotiation)

**Relations & Military Conflict**

Military actions directly modify relations:

```
Military Action Relations Impact:

Unit Destruction:
  - Enemy unit killed: -1 relation per unit (scales with unit importance)
  - Elite unit killed: -3 relations
  - Facility destroyed: -5 relations

Territory Actions:
  - Base construction in territory: -10 relations
  - Base captured: -30 relations
  - Territory liberated: +20 relations

Supply Line Disruption:
  - Supply line intercepted (player vs faction): -2 relations
  - Player captures faction shipment: -5 relations

Rescue/Aid Operations:
  - Rescue civilian group: +5 relations
  - Defend faction territory: +10 relations
  - Joint military operation: +5 relations + bonus cooperation
```

**Example R7-3: Relations Through Military Actions**
- Starting relations with Country A: Neutral (+5)
- Player constructs base in Country A territory: -10 = -5 (Cold)
- Country A faces alien invasion; player liberate territory: +20 = +15 (Warm)
- Result: Relations shift from Neutral → Cold → Warm through mixed military actions

---

## Black Market System (R7: Black Market Events & Mechanics)

**Overview**
Black Market represents illicit supply channels independent of mainstream marketplace and government suppliers. Access is based on karma alignment, and interactions trigger random events. Black Market provides unique items and high-risk opportunities.

**Black Market Access & Karma Alignment**

```
Black Market Accessibility by Karma:
- Saint (+41 to +100): No access (moral prohibition)
- Principled (+10 to +40): Very limited (5% event chance per month)
- Neutral (-9 to +9): Full access (30% event chance per month)
- Pragmatic (-39 to -10): Enhanced access (50% event chance per month)
- Ruthless (-74 to -40): Full access (75% event chance per month)
- Evil (-100 to -75): Guaranteed access (100% event chance per month)

Accessibility Formula:
Black Market Event Chance = Base Chance × (1 + Karma Modifier) × Fame Impact
  Base Chance: 20-30% per month (varies by region stability)
  Karma Modifier: -1 to +1 based on alignment (-1 for saints, 0 for neutral, +1 for evil)
  Fame Impact: High fame increases risk of discovery
```

**Example R7-4: Black Market Access Calculation**
- Karma: Pragmatic (-25)
- Base chance: 25% per month
- Karma modifier: 0.5 (negative karma increases access)
- Fame: Legendary (90)
- Fame risk multiplier: 1.0 (no penalty at high fame)
- Total event chance: 25% × (1 + 0.5) × 1.0 = 37.5% per month
- Result: 37.5% chance of black market event offer

**Black Market Event Types**

When black market event triggers, offer one of 5 categories:

**Event Type 1: Rare Item Offers (40% probability)**
- Alien technology not in normal research tree
- Advanced weapons limited-time supply
- Unique armor variants (cosmetic + stats)
- Example: "Pristine alien plasma cannon (15K credits, limited stock 2 units)"
- Risk: Each purchase -3 karma (gradually shifts alignment)
- Strategic value: Access items before normal research completion

**Event Type 2: Shady Missions (25% probability)**
- Assassination targets
- Black market enforcement operations
- Smuggling runs (high reward, high interception risk)
- Example: "Eliminate rival organization leader (50K credits, +50K cash reward if successful)"
- Risk: -10 to -30 karma depending on mission (war crime level)
- Strategic value: Quick credits, rapid karma shift capability

**Event Type 3: Raid Opportunities (20% probability)**
- Organized raids on civilian/corporate targets
- Supply convoy hijacking
- Facility sabotage coordination
- Example: "Raid isolated warehouse complex (50K credits reward, +30 items captured)"
- Risk: Fame penalty (-10 to -30), potential relation drop with affected country
- Strategic value: One-time loot without manufacturing investment

**Event Type 4: Corrupt Officials (10% probability)**
- Bribery opportunities to unlock restricted areas
- Official who can be paid to sabotage enemies
- Contacts for illegal bases
- Example: "Regional administrator accepts 20K credit bribe, blocks enemy base construction for 6 months"
- Risk: -5 to -15 karma, relation penalty with affected country (-5)
- Strategic value: Asymmetric advantage without military action

**Event Type 5: Rescue/Mercy Killings (5% probability)**
- Opportunity to rescue imprisoned allies
- Option to terminate dying faction members (mercy killing)
- Save civilian groups from danger
- Example: "Rescue captured research team (free mission), gain +10 karma, tech unlock"
- Risk: None (karma positive opportunity)
- Strategic value: Unique story moments, alignment building

**Black Market Event Frequency & Probability**

```
Base Event Frequency by Stability:
- Stable regions: 20% per month
- Contested regions: 35% per month
- War zones: 50% per month
- Enemy territory: 65% per month

Regional Modifiers:
- High player fame: +15% (more offers/visibility)
- Active warfare in region: +20% (instability increases opportunity)
- Multiple factions present: +10% (chaos creates options)
- Well-established supply lines: -10% (stability reduces black market appeal)

Stacked Example R7-5: Black Market Frequency
- Region: Contested territory
- Base frequency: 35%
- Player fame: Legendary (+15%)
- Active warfare: +20%
- Multiple factions: +10%
- Well-established supply: -10%
- Total monthly chance: 35% + 15% + 20% + 10% - 10% = 70%
- Result: 70% chance of monthly black market event offer
```

**Black Market Consequences & Balancing**

```
Discovery Risk Formula:
Discovery Chance = Event Participation × Fame Multiplier × Region Visibility
  Event Participation: 30% base (each event increases by 10%)
  Fame Multiplier: 1 + (Fame / 100) (legendary fame = 1.9x multiplier)
  Region Visibility: 0.5 (hidden region) to 1.5 (enemy territory)

Discovery Example R7-6:
- Participate in black market events: 3 events (30% + 20% + 10% = base 30%)
- Fame: Legendary (90) → 1.9x multiplier
- Region: Contested (1.0x visibility)
- Discovery chance: 30% × 1.9 × 1.0 = 57%
- Result: 57% chance per additional event that organization is discovered

Discovery Consequences:
- Media scandal: -20 fame (reputation damage)
- Relation penalties: -5 to -20 with affected countries
- Marketplace disruption: +15% marketplace prices (suppliers avoid liability)
- Supply line vulnerability: +25% interception chance (intelligence leak)
- Investigation: 3-6 month period where authorities increase scrutiny (-10% income during investigation)
```

**Black Market Raid System**

Raids are high-risk, high-reward black market events:

```
Raid Success Formula:
Success Chance = 50% + (Stealth Bonus) - (Target Defenses)
  Stealth Bonus: +10% per Stealth tech research, +5% per elite unit
  Target Defenses: -5% per military unit defending, -10% per facility upgrade level

Raid Rewards:
- Item capture: 30-50 units of target supply
- Equipment loot: 5-15 items (random quality)
- Credits: 10K-50K cash reward

Raid Failure Consequences:
- Combat loss: Fight defending units (potential casualties)
- Capture risk: If routed, 20% chance personnel captured
- Relation penalty: -10 with territory owner
- Investigation: 50% chance discovery triggers scandal (see above)

Example R7-7: Raid Execution**
- Target: Isolated ammunition warehouse in contested region
- Reward: 100 assault rifle ammo, 20K credits
- Stealth bonus: +15% (Stealth tech + elite units)
- Target defense: -5% (1 military unit guarding)
- Success chance: 50% + 15% - 5% = 60%
- Execution result: Player rolls; 60% success = warehouse looted, 40% failure = combat engagement
- If success: Gain 100 ammo + 20K credits, -2 karma (theft), -5 fame (lawlessness)
- If failure: Combat with 4 soldiers; if lose, 1-2 personnel captured, relation -10
```

**Black Market Long-Term Strategy**

Black Market use creates campaign trajectory changes:

**Karma Shift Acceleration**
- Heavy black market use rapidly shifts karma to Evil (-100)
- Can shift 40-50 karma points per campaign month if intensive
- Strategic: Use to deliberately shift alignment or unlock aligned-specific content

**Fame Paradox**
- High fame increases black market discovery risk
- Low fame offers fewer black market events
- Strategic tension: Balance between notoriety and opportunity

**Economic Advantage**
- Black market provides 20-30% income boost (if successfully raiding)
- But discovery consequences (-15% income during investigation) can offset
- Strategic: Use raids for specific resource needs, not steady income

**Alignment Locking**
- Extreme karma (±75 or higher) makes switching alignment very difficult
- Character path becomes "locked in" to evil/good campaign
- Strategic: Commit to alignment or maintain neutral throughout

---

## Advisors System

**Overview**
Advisors are high-level specialists hired to manage critical organizational functions. Each advisor provides meaningful global bonuses and unlocks advanced management capabilities. Advisors represent the leadership structure and expertise level of the organization.

**Advisor Types and Specializations**

| Advisor | Cost | Specialty | Primary Bonus | Secondary Effect |
|---------|------|-----------|---------------|-----------------|
| **CTO** (Chief Technology Officer) | 8 PP | Research & Development | +20% research speed | +15% facility upgrade efficiency |
| **CFO** (Chief Financial Officer) | 10 PP | Financial Management | +15% monthly income | -10% marketplace prices |
| **COO** (Chief Operations Officer) | 9 PP | Operational Efficiency | +10% base production | +5% unit experience gains |
| **Director of Intelligence** | 12 PP | Espionage & Intel | +20% spy success rate | -30% enemy spy effectiveness |
| **Military Commander** | 11 PP | Combat & Units | +10% unit damage | +5% unit accuracy |
| **Minister of Diplomacy** | 7 PP | Diplomatic Relations | +1 relation/month with all countries | -50% cost for diplomatic actions |
| **Chief Engineer** | 8 PP | Construction & Repair | +15% base construction speed | +10% repair speed |
| **Quartermaster** | 6 PP | Supply & Logistics | +20% transfer speed | -15% transfer costs |

**Hiring System**
- **Cost**: Advisors purchased using Power Points (6-12 points typical)
- **Maintenance**: Monthly salary in Credits (substantial ongoing cost)
  - Low-tier advisors: 1,000-2,000 credits/month
  - High-tier advisors: 3,000-5,000 credits/month
- **Availability**: Only elite-tier advisors available; limited pool per tier
- **Recruitment Time**: 1 month from hiring to activation
- **Availability Tier System**:
  - Standard advisors: Always available
  - Elite advisors: Require +50 country/supplier relations
  - Legendary advisors: Require high fame (80+) or specific achievements

**Advisor Qualities**

**Quality-Focused Advisors** (Improve Effectiveness)
- **Research Bonuses**: +10-20% research completion rate globally
- **Unit Experience**: +10-15% experience gained per mission
- **Radar Range**: +15-25% detection range for all radar systems
- **Combat Effectiveness**: +5-10% accuracy, +5-10% damage
- **Intelligence Quality**: Better spy intel, +20-30% success rate

**Quantity-Focused Advisors** (Increase Capacity)
- **Base Capacity**: Maximum bases +4-8 (from 3 to 7-11)
- **Craft Capacity**: Maximum craft +8-12 (from 4 to 12-16)
- **Personnel Slots**: Maximum soldiers per base +12-24 (from 24 to 36-48)
- **Manufacturing Slots**: Additional production queues available (+2-4 per facility)
- **Research Parallel Projects**: Additional simultaneous research (+1-2)

**Specialized Advisors** (Unique Capabilities)
- **Diplomatic Immunity**: Reduced relationship penalties for failures (-20-30%)
- **Financial Cushion**: Additional monthly credit income (+1,000-3,000/month)
- **Counter-Intelligence**: Reduced spy success against organization (-30-50%)
- **Emergency Reserves**: Access to emergency funding (20% interest, once per month)
- **Morale Booster**: Enhanced personnel morale (+15-20%), reduced desertion

**Advisor Synergies**
Hiring multiple complementary advisors creates bonus effects:
- **Finance Team**: CFO + Quartermaster = +5% income, -20% transfer costs (combined effect)
- **War Machine**: Military Commander + COO = +15% unit damage, +10% base production
- **Intelligence Network**: Director of Intelligence + Minister of Diplomacy = +25% spy success, +2 relations/month
- **Research Division**: CTO + Chief Engineer = +25% research speed, +20% construction speed
- **Logistics Expert**: Quartermaster + COO = +30% production speed, +25% transfer speed

**Advisor Management**
- Limited advisor slots (typically 3-5 maximum advisors simultaneously)
- Slot upgrades available through organization leveling
- Advisor specialization affects performance in related areas
- Conflict between certain advisors (-5-10% effectiveness if poorly matched)
- Firing advisors requires refunding partial wages (75% cost refund)
- Rehiring previously employed advisors costs 20% more points

**Advisor Quality Tiers**

| Tier | Point Cost | Monthly Salary | Bonuses | Requirements |
|---|---|---|---|---|
| Junior | 4-6 PP | 500-1000 | +5-10% single area | None |
| Senior | 6-10 PP | 1500-3000 | +10-15% area, synergies unlock | +25 relation |
| Elite | 10-15 PP | 3000-5000 | +15-20% area, strong synergies | +50 relation or fame 60+ |
| Legendary | 15-20 PP | 5000-8000 | +20-30% multiple areas | Fame 90+ or special unlock |

**Strategic Advisor Hiring**
- **Early Game**: Focus on research advisor for technology advantage
- **Mid Game**: Add financial and operations advisors for resource management
- **Late Game**: Recruit specialized advisors for endgame challenges
- **Crisis Situations**: Hire military commander for enhanced combat
- **Economic Focus**: Combine CFO + Quartermaster for financial optimization
- **Diplomatic Route**: Hire Minister of Diplomacy for soft power approach

**Advisor Retirement**
- Advisors can be retired permanently (no rehire)
- Poor organizational performance may trigger advisor departure
- Advisor morale affects effectiveness (-5-25% if unhappy)
- Dismissal creates relationship penalties with advisor's faction (-20)
- Death during espionage mission possible (rare, creates story moment)

**Advisor Availability Events**
- Advisors become available based on game progression
- Random events may offer temporary advisor hiring bonuses (50% cost, limited time)
- Advisor poaching: Rivals may offer advisors employment (-10 relation if successful poach)
- Advisor discovery: Special missions unlock unique advisor recruitment opportunities

---

## Organization Level

**Overview**
Organization Level represents strategic progression milestones that gate access to advanced gameplay features and content. Levels provide clear goals for long-term campaign progression and create a sense of organizational growth and maturity.

**Level Progression System**
```
Organization Level = 1 + (Major Achievements / Achievement Threshold)
Advancement Cost = (Current Level × 5) + 5 Power Points
```
- Unlocked through accumulated Power Points and achievements
- Levels range from 1 (Startup) to 10 (Global Authority)
- Clear prerequisites for advancement (cumulative achievements, required points)
- Each level unlocks new capabilities and areas

**Achievement Requirements by Level**

| Level | PP Cost | Military | Economic | Diplomatic | Growth | Unlocks |
|---|---|---|---|---|---|---|
| 1-2 | 5 | 5 wins | 10K credits | Any | 1 base | Basic features |
| 2-3 | 10 | 15 wins | 50K credits | 1 ally | 2 bases | Multiple bases |
| 3-4 | 15 | 30 wins | 100K credits | 2 allies | 3 bases | Advanced research |
| 4-5 | 20 | 50 wins | 250K credits | 3 allies | 4 bases | Faction contact |
| 5-6 | 25 | 75 wins | 500K credits | +50 relations | 5 bases | Advanced weapons |
| 6-7 | 30 | 100 wins | 1M credits | 5 alliances | 6 bases | Alliance mechanics |
| 7-8 | 35 | 150 wins | 2M credits | League formation | 7 bases | Tech trading |
| 8-9 | 40 | 200 wins | 5M credits | Superpower status | 8 bases | Secret research |
| 9-10 | 50 | 250 wins | 10M credits | World dominance | 10 bases | Endgame content |

**Unlocks by Level**
- **Level 1-2**: Basic base construction, initial research trees, simple missions
- **Level 2-3**: Multiple bases (2+), advanced research unlocks, diplomatic contact
- **Level 3-4**: Professional military units, advanced facilities, faction intel
- **Level 4-5**: Alien research begins, craft customization, advanced suppliers
- **Level 5-6**: Interstellar technology, advanced diplomacy, elite units recruitment
- **Level 6-7**: Strategic alliance mechanics, technology trading with factions
- **Level 7-8**: Secret research branches, advanced espionage, coalition systems
- **Level 8-9**: Endgame weapons, organization transformation options
- **Level 9-10**: Organization-wide transformations, endgame content, multiple ending paths

**Strategic Implications**
- **Enemy Response**: Higher levels unlock more aggressive enemy responses
  - Level 1-3: Basic deployments
  - Level 4-6: Tactical deployments with elite units
  - Level 7-10: Massive coordinated campaigns, multiple faction involvement
- **Faction Appearance**: Advanced factions only appear after certain levels
  - Level 1-3: Basic factions
  - Level 5+: Advanced alien factions
  - Level 7+: Endgame threats
- **Campaign Complexity**: Campaign becomes increasingly complex with progression
  - Level 1-3: Single objective focus
  - Level 4-6: Multiple simultaneous objectives
  - Level 7-10: Global-scale strategic challenges
- **Content Availability**: End-game content becomes available at highest levels

**Advisor Slot Expansion**
- Base slots: 3 advisors
- Level 3: +1 slot (4 total)
- Level 5: +1 slot (5 total)
- Level 7: +1 slot (6 total)
- Level 9: +1 slot (7 total)

**Base Expansion Gates**
- Early levels: 1-2 bases maximum
- Level 3: 3 bases
- Level 5: 5 bases
- Level 7: 7 bases
- Level 10: 10 bases

**Milestone Achievements for Each Level**
- **Military**: Missions completed, enemies defeated, bases captured
- **Economic**: Total credits earned, research completion count, manufacturing volume
- **Diplomatic**: Alliance formation, treaty agreements, suppliers controlled
- **Organizational**: Bases built, personnel recruited, advisor hiring

## Examples

### Scenario 1: Fame Building
**Setup**: Organization starts with 0 fame
**Action**: Complete 10 successful missions
**Result**: Fame increases to 50, unlocks known tier benefits

### Scenario 2: Karma Decision
**Setup**: Captured alien prisoner available
**Action**: Choose interrogation over execution
**Result**: +3 karma, potential research benefits, diplomatic consequences

## Balance Parameters

| Parameter | Value | Range | Reasoning | Difficulty Scaling |
|-----------|-------|-------|-----------|-------------------|
| Fame Decay Rate | 1-2/month | 0-5 | Maintains activity requirement | +1 on Hard |
| Karma Range | -100 to +100 | -200 to +200 | Moral choice impact | No scaling |
| Relationship Base | 0 | -50 to +50 | Neutral starting point | -10 on Hard |
| Power Points per Level | 100 | 50-200 | Progression pacing | -25 on Easy |

## Difficulty Scaling

### Easy Mode
- Faster fame/karma accumulation
- More forgiving relationship penalties
- Increased power point rewards

### Normal Mode
- Standard political mechanics
- Balanced consequence severity
- Normal progression rates

### Hard Mode
- Slower reputation building
- Harsh penalty multipliers
- Reduced power point gains

### Impossible Mode
- Severe reputation penalties
- Maximum consequence severity
- Minimal political rewards

## Testing Scenarios

- [ ] **Fame Progression Test**: Complete missions and check fame increase
  - **Setup**: Organization at 0 fame
  - **Action**: Complete 5 missions successfully
  - **Expected**: Fame increases by 25
  - **Verify**: Fame display and benefits unlock

- [ ] **Relationship Change Test**: Perform diplomatic action
  - **Setup**: Neutral relationship with country
  - **Action**: Complete favor mission
  - **Expected**: Relationship improves by +5
  - **Verify**: Diplomatic status updates correctly

## Related Features

- **[Countries System]**: Nation relationships and diplomacy (Countries.md)
- **[Finance System]**: Economic impacts of political decisions (Finance.md)
- **[AI Systems]**: Faction behavior influenced by politics (AI.md)
- **[Geoscape System]**: Global political effects (Geoscape.md)

## Implementation Notes

- Fame/karma as global state variables
- Relationship matrix between organization and factions
- Power points as experience currency for progression
- Advisor system using composition pattern

## Review Checklist

- [ ] Fame system mechanics defined
- [ ] Karma consequences specified
- [ ] Relationship dynamics clear
- [ ] Power point progression balanced
- [ ] Advisor system implemented
- [ ] Organization level gates appropriate
- [ ] Political feedback loops documented
