# Politics

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


