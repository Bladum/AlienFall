# Procedural Event System

> **Status**: Design Proposal  
> **Last Updated**: 2025-10-28  
> **Priority**: CRITICAL  
> **Related Systems**: Geoscape.md, Politics.md, AI.md, Countries.md, Economy.md

## Table of Contents

- [Overview](#overview)
- [Design Philosophy](#design-philosophy)
- [Event Categories](#event-categories)
- [Event Generation System](#event-generation-system)
- [Political Events](#political-events)
- [Alien Events](#alien-events)
- [Scientific Events](#scientific-events)
- [Economic Events](#economic-events)
- [Environmental Events](#environmental-events)
- [Event Response System](#event-response-system)
- [Event Chains & Consequences](#event-chains--consequences)
- [Balancing & Pacing](#balancing--pacing)
- [Integration with Existing Systems](#integration-with-existing-systems)
- [Technical Implementation](#technical-implementation)
- [Example Event Scenarios](#example-event-scenarios)

---

## Overview

### System Purpose

The Procedural Event System addresses the **mid-game engagement crisis** (months 4-8) by injecting dynamic, unpredictable narrative moments that force strategic adaptation and create emergent storytelling. Events are algorithmically generated based on game state, player actions, and random chance, ensuring no two campaigns feel identical.

**Core Goals**:
- Break mid-game monotony with surprising developments
- Create meaningful strategic dilemmas (no "correct" answer)
- Generate emergent narratives through cascading consequences
- Maintain tension through unpredictable challenges
- Reward player adaptability over rigid optimization

### Key Principles

1. **Player Agency**: Events offer meaningful choices with distinct consequences
2. **Contextual Generation**: Events emerge from current game state (not random chaos)
3. **Cascading Impact**: Player choices trigger follow-up events (chains)
4. **Risk/Reward Balance**: All choices have both benefits and drawbacks
5. **No Dead Ends**: Events never create unwinnable scenarios (recoverable setbacks only)

---

## Design Philosophy

### Inspiration Sources

- **Crusader Kings 3**: Character-driven events with personality-based outcomes
- **Stellaris**: Mid-game crisis system injecting major plot twists
- **FTL: Faster Than Light**: Binary choices with hidden consequences
- **XCOM 2**: Covert ops system with time-limited strategic choices
- **Civilization VI**: Emergencies and world congress decisions

### Core Event Loop

```
Game State Analysis → Event Trigger Evaluation → Event Generation →
Player Presented with Choice → Player Selects Option → Immediate Effects Applied →
Long-Term Consequences Tracked → Potential Follow-Up Events Queued
```

### Frequency & Pacing

**Event Cadence**:
- **Months 1-3**: No events (learning phase, establish baseline)
- **Months 4-6**: 1 minor event per month (introduce system)
- **Months 7-9**: 1 major event per 2 months (increase stakes)
- **Months 10-12**: 1 major + 1 minor per month (crisis escalation)
- **Months 13+**: 2 major events per month (endgame chaos)

**Event Severity Tiers**:
- **Minor**: Single-country impact, 1-2 month duration, low resource cost
- **Major**: Multi-country/region impact, 3-6 month duration, significant resources
- **Critical**: Global impact, campaign-altering, permanent consequences

---

## Event Categories

### 1. Political Events (30% of all events)

Focus on diplomatic relations, government stability, and faction politics.

**Themes**:
- Coups and regime changes
- Trade agreements and sanctions
- Border conflicts and territorial disputes
- Ideological movements (fascism, democracy, theocracy)
- Espionage and intelligence operations

### 2. Alien Events (25% of all events)

Focus on alien faction behavior, internal conflicts, and adaptive strategies.

**Themes**:
- Alien civil wars and faction splits
- Technology breakthroughs (aliens unlock new capabilities)
- Strategic retreats and regroupings
- Diplomatic overtures (aliens seek truce/alliance)
- Biological mutations and evolution

### 3. Scientific Events (20% of all events)

Focus on research breakthroughs, experimental technology, and scientific ethics.

**Themes**:
- Revolutionary discoveries (double-edged sword)
- Laboratory accidents and containment breaches
- Scientist defections and espionage
- Ethical dilemmas (human experimentation)
- Prototype weapon testing (risk/reward)

### 4. Economic Events (15% of all events)

Focus on resource scarcity, market fluctuations, and funding crises.

**Themes**:
- Material shortages (titanium, elerium, fuel)
- Supplier bankruptcies and monopolies
- Black market opportunities
- Inflation and currency devaluation
- Corporate espionage and industrial sabotage

### 5. Environmental Events (10% of all events)

Focus on natural disasters, climate anomalies, and ecological consequences.

**Themes**:
- Natural disasters (earthquakes, hurricanes, tsunamis)
- Alien terraforming attempts
- Chemical/biological contamination zones
- Climate manipulation (alien weather control)
- Ecological collapse (resource depletion)

---

## Event Generation System

### Trigger Conditions

Events are generated when specific conditions are met:

#### Player Performance Triggers
```yaml
High Success Rate (>75% win rate):
  - Alien factions coordinate retaliation
  - Countries become complacent (-10% funding)
  - "Overconfidence" events (trap missions)

Low Success Rate (<40% win rate):
  - Sympathetic nations offer emergency aid
  - Alien factions become overextended (civil war)
  - "Desperation" events (high-risk/high-reward)

Balanced Performance (40-75%):
  - Standard event pool
  - No special modifiers
```

#### Time-Based Triggers
```yaml
Month 4: First political event guaranteed (introduce system)
Month 6: First alien event guaranteed (escalation)
Month 8: First scientific event guaranteed (breakthrough phase)
Month 10: Major crisis event guaranteed (endgame prep)
```

#### Resource-Based Triggers
```yaml
Credits > 10× monthly income:
  - Inflation event (market saturation)
  - Corporate espionage (competitors target player)

Credits < 1× monthly income:
  - Economic crisis event (debt collectors)
  - Fire sale event (desperate suppliers offer deals)

Fuel < 20% capacity:
  - Fuel shortage crisis
  - Alternative energy research unlock

Salvage > storage capacity:
  - Black market opportunity (sell excess)
  - Alien intelligence intercept (they know you're weak)
```

#### Diplomatic Triggers
```yaml
Allied with 5+ countries:
  - United Nations proposal (global alliance)
  - Jealous nations coordinate sanctions

Hostile with 3+ countries:
  - International isolation (embargo)
  - Mercenary recruitment opportunity

Karma > +75:
  - Humanitarian organization requests aid
  - Peaceful alien faction seeks contact

Karma < -75:
  - Black market syndicate offers partnership
  - War crimes tribunal threat
```

### Event Pool Structure

Each event category has 20-30 unique events with variations:

```yaml
Event Template:
  id: "event_political_coup_01"
  category: "political"
  severity: "major"
  title: "Military Coup in [Country]"
  description: "The government of [Country] has been overthrown..."
  
  trigger_conditions:
    - country_relation: < 30
    - fame: > 50
    - month: >= 5
    - random_chance: 15%
  
  choices:
    - option_1:
        text: "Support the new military regime"
        immediate_effects:
          - country_relation: +20
          - karma: -15
          - fame: -5
        long_term_effects:
          - unlock_military_supplier: true
          - trigger_event_chain: "coup_aftermath_military"
      
    - option_2:
        text: "Support democratic restoration"
        immediate_effects:
          - country_relation: -10
          - karma: +20
          - fame: +10
        long_term_effects:
          - trigger_mission: "restore_democracy"
          - risk_lose_country: 30%
      
    - option_3:
        text: "Remain neutral"
        immediate_effects:
          - country_relation: -5
          - karma: 0
        long_term_effects:
          - country_unstable: 3_months
          - random_events_increased: true
```

---

## Political Events

### Military Coup

**Trigger**: Country relation < 30, Fame > 50, Month >= 5

**Scenario**: A military junta overthrows the democratic government in a country where player has operations. The new regime is more authoritarian but potentially more cooperative with military organizations.

**Player Choices**:

1. **Support New Regime**
   - Immediate: +20 country relation, -15 karma, -5 fame
   - Long-term: Access to military suppliers, +10% funding from that country
   - Risk: Democratic countries reduce relations by -10
   - Follow-up: "Regime Consolidation" event in 2 months

2. **Support Restoration**
   - Immediate: -10 country relation, +20 karma, +10 fame
   - Long-term: Unlock "Restore Democracy" mission chain (5 missions)
   - Risk: 30% chance country becomes hostile if missions fail
   - Follow-up: "Democratic Elections" event in 6 months (if successful)

3. **Stay Neutral**
   - Immediate: -5 country relation, 0 karma change
   - Long-term: Country remains unstable (random events +50% for 3 months)
   - Risk: 20% chance of civil war (country unusable)
   - Follow-up: "Neutrality Tested" event (pressure from both sides)

### Trade Embargo

**Trigger**: Hostile with 2+ countries, Month >= 6

**Scenario**: A coalition of nations imposes economic sanctions on player organization due to controversial tactics or political pressure.

**Player Choices**:

1. **Accept Sanctions**
   - Immediate: -30% marketplace prices for 3 months
   - Long-term: Improve relations with sanctioning countries (+10 over time)
   - Risk: Black market becomes only option for rare items
   - Follow-up: "Sanction Relief" event in 4 months

2. **Defy Sanctions**
   - Immediate: -20 relation with 5+ countries
   - Long-term: Maintain full marketplace access
   - Risk: Countries may withdraw funding entirely
   - Follow-up: "International Incident" event (escalation)

3. **Negotiate Compromise**
   - Immediate: Diplomatic skill check (Fame × Karma modifier)
   - Success: -15% prices, +5 relation with all countries
   - Failure: Full sanctions + -30 relation penalty
   - Follow-up: "Trade Agreement" event (if successful)

### Border Conflict

**Trigger**: Two allied countries have relation delta > 40, Month >= 7

**Scenario**: Two countries player is allied with enter armed conflict over territorial dispute. Player must choose a side or mediate.

**Player Choices**:

1. **Support Country A**
   - Immediate: Country A relation +30, Country B relation -40
   - Long-term: Military alliance with Country A (joint operations)
   - Risk: Lose Country B as funding source
   - Follow-up: "War Escalation" event (Country B seeks revenge)

2. **Support Country B**
   - Immediate: Country B relation +30, Country A relation -40
   - Long-term: Military alliance with Country B
   - Risk: Lose Country A as funding source
   - Follow-up: "War Escalation" event (Country A seeks revenge)

3. **Mediate Peace**
   - Immediate: Diplomatic skill check (Fame + Karma bonus)
   - Success: Both countries +15 relation, +25 fame
   - Failure: Both countries -20 relation (anger at interference)
   - Follow-up: "Ceasefire Monitoring" mission (if successful)

---

## Alien Events

### Alien Civil War

**Trigger**: 2+ alien factions hostile to player, Month >= 6

**Scenario**: Two alien factions (e.g., Sectoids vs. Ethereals) enter internal conflict over resources or ideology. Their attacks on Earth temporarily decrease.

**Player Choices**:

1. **Support Sectoids**
   - Immediate: Sectoid faction becomes neutral (-50 hostility)
   - Long-term: Ethereal faction becomes vendetta (+50 aggression)
   - Benefit: Access to Sectoid technology research
   - Risk: Ethereals deploy elite units against player
   - Follow-up: "Sectoid Alliance" event (diplomatic missions)

2. **Support Ethereals**
   - Immediate: Ethereal faction becomes neutral
   - Long-term: Sectoid faction becomes vendetta
   - Benefit: Unlock psionic research tree (2 months faster)
   - Risk: Sectoids deploy swarm tactics (more frequent attacks)
   - Follow-up: "Psionic Training" event (unlock psi units)

3. **Exploit Both**
   - Immediate: +100% salvage from alien battlefield missions (6 new missions)
   - Long-term: Both factions unite against player after war (2 months)
   - Benefit: Massive resource windfall
   - Risk: Coordinated attacks from both factions simultaneously
   - Follow-up: "Alien Alliance" event (united retaliation)

### Faction Defection

**Trigger**: Defeat 50%+ of one alien faction's bases, Month >= 8

**Scenario**: A splinter group from a defeated alien faction offers to defect and join player forces in exchange for protection.

**Player Choices**:

1. **Accept Defection**
   - Immediate: 5-10 alien units join player roster (Rank 2)
   - Long-term: Main faction becomes vendetta (-100 relation permanent)
   - Benefit: Unique alien abilities available to player
   - Risk: Some countries reduce relations (-10) due to ethical concerns
   - Follow-up: "Integration" missions (train alien units)

2. **Reject Defection**
   - Immediate: +20 fame (honor and principle)
   - Long-term: Must eliminate remaining faction bases by force
   - Benefit: +10 karma (ethical choice)
   - Risk: Harder endgame (no alien allies)
   - Follow-up: "Last Stand" missions (final faction bases)

3. **Double Agent Strategy**
   - Immediate: Use defectors as spies (intelligence missions unlock)
   - Success: +50% warning time for alien attacks (4 months)
   - Failure: 30% chance of betrayal (false information, trap missions)
   - Risk: If betrayed, lose 3-5 units and 1 base is compromised
   - Follow-up: "Espionage" event chain (verify intelligence)

### Alien Breakthrough

**Trigger**: Player uses same tactics 5+ missions in a row, Month >= 7

**Scenario**: Aliens analyze player combat patterns and develop counter-tactics (adaptive AI).

**Player Choices**:

1. **Adapt Tactics**
   - Immediate: -20% effectiveness of current strategy (2 months)
   - Long-term: Must develop new tactics (forces experimentation)
   - Benefit: Become more versatile player
   - Risk: Learning curve = potential mission failures
   - Follow-up: "Tactical Innovation" event (unlock new strategies)

2. **Counter-Research**
   - Immediate: Emergency research project (100 man-days)
   - Long-term: Negate alien advantage if completed in time
   - Benefit: Maintain current strategy
   - Risk: Resource intensive (scientists diverted from other projects)
   - Follow-up: "Arms Race" event (aliens respond with new counter)

3. **Brute Force**
   - Immediate: Accept -20% effectiveness permanently
   - Long-term: Increase aggression (+30% damage output)
   - Benefit: No strategy change needed
   - Risk: Higher casualties, more expensive missions
   - Follow-up: "Attrition Warfare" event (unsustainable losses)

---

## Scientific Events

### Revolutionary Discovery

**Trigger**: Complete 15+ research projects, Month >= 6

**Scenario**: Lead scientist achieves unexpected breakthrough. Player must choose which experimental technology to pursue.

**Player Choices**:

1. **Quantum Weapons**
   - Immediate: Unlock experimental weapon tier (2× current damage)
   - Long-term: 10% chance of critical failure per use (weapon explodes)
   - Benefit: Devastates enemies when successful
   - Risk: Can kill own units on failure
   - Follow-up: "Quantum Stability" research (reduce failure rate)

2. **Genetic Enhancement**
   - Immediate: All units gain +2 to all stats
   - Long-term: 5% mutation chance per mission
   - Benefit: Significant power increase
   - Risk: Mutations unpredictable (could be positive or negative)
   - Follow-up: "Mutation Control" research (stabilize genetics)

3. **Dimensional Technology**
   - Immediate: Unlock teleportation research (instant travel)
   - Long-term: Dimensional rifts appear (new enemy type: Rift Demons)
   - Benefit: Strategic mobility advantage
   - Risk: New threat must be managed
   - Follow-up: "Rift Containment" missions (seal breaches)

### Rogue Scientist

**Trigger**: Research speed > 150% expected, Month >= 8

**Scenario**: Lead scientist defects to aliens, taking sensitive research data.

**Player Choices**:

1. **Hunt Down**
   - Immediate: Unlock assassination mission (difficulty: Very Hard)
   - Success: Prevent tech leak, recover research, +20 fame
   - Failure: Scientist escapes, permanent tech leak, aliens get player tech
   - Follow-up: "Infiltration" event (aliens know your tactics)

2. **Accept Loss**
   - Immediate: -30% research speed for 1 month (morale damage)
   - Long-term: -10 fame (security failure)
   - Benefit: No further risk
   - Risk: Aliens equipped with player weapons for 3 months
   - Follow-up: "Counter-Intelligence" event (prevent future defections)

3. **Counter-Intelligence**
   - Immediate: Feed false data to aliens via defector (deception)
   - Success: Aliens research useless technology (waste 3 months)
   - Failure: 50% chance scientist discovers deception (worse betrayal)
   - Risk: If failed, aliens get DOUBLE information advantage
   - Follow-up: "Espionage War" event chain (ongoing deception)

### Laboratory Accident

**Trigger**: Research 3+ alien biology projects, Month >= 5

**Scenario**: Containment breach in research facility. Alien specimens escape.

**Player Choices**:

1. **Quarantine Base**
   - Immediate: Base unusable for 2 months (lockdown)
   - Long-term: All specimens secured, no further risk
   - Benefit: Safety guaranteed
   - Risk: Lose research progress, mission deployment capacity reduced
   - Follow-up: "Decontamination" event (restore base faster)

2. **Emergency Containment**
   - Immediate: Unlock emergency base defense mission
   - Success: Specimens recaptured, research continues
   - Failure: Base destroyed, 10-15 units lost
   - Risk: High difficulty mission
   - Follow-up: "Containment Protocols" research (prevent future breaches)

3. **Controlled Release**
   - Immediate: Release specimens into nearby wilderness (hide accident)
   - Long-term: -30 karma, random civilian attacks (3 months)
   - Benefit: Base remains operational, no publicity
   - Risk: Civilians die, fame decreases when discovered
   - Follow-up: "Cover-Up" event (media investigation)

---

## Economic Events

### Material Shortage

**Trigger**: Manufacturing queue > 10 projects, Month >= 6

**Scenario**: Global shortage of critical material (Titanium, Elerium, etc.). Prices skyrocket.

**Player Choices**:

1. **Accept Shortage**
   - Immediate: Material unavailable for 2 months
   - Long-term: Must adapt (use alternative equipment)
   - Benefit: No additional cost
   - Risk: Manufacturing halted, tactical disadvantage
   - Follow-up: "Resource Discovery" event (new supplier found)

2. **Black Market Purchase**
   - Immediate: Pay 3× market price for materials
   - Long-term: -15 karma per transaction
   - Benefit: Manufacturing continues uninterrupted
   - Risk: Expensive, ethical compromise, potential legal issues
   - Follow-up: "Black Market Dependence" event (supplier demands more)

3. **Alternative Research**
   - Immediate: Emergency research (synthetic materials, 50 man-days)
   - Success: Unlock substitute material (permanent solution)
   - Failure: Waste 50 man-days, still need materials
   - Risk: Diverts scientists from other projects
   - Follow-up: "Synthetic Materials" research tree unlock

### Supplier Bankruptcy

**Trigger**: Purchase > 50K from single supplier, Month >= 7

**Scenario**: Major supplier goes bankrupt. Player can acquire their assets or watch competitor take over.

**Player Choices**:

1. **Buy Out Supplier**
   - Immediate: Cost 100K credits (one-time payment)
   - Long-term: -20% prices from that supplier permanently
   - Benefit: Long-term savings, exclusive items
   - Risk: Large upfront cost, may cause cash flow crisis
   - Follow-up: "Business Management" events (run supplier)

2. **Let Competitor Win**
   - Immediate: No cost
   - Long-term: Competitor monopolizes market (+30% prices for 6 months)
   - Benefit: Preserve cash reserves
   - Risk: Higher costs later, limited selection
   - Follow-up: "Market Competition" event (competitor aggressive)

3. **Negotiate Partnership**
   - Immediate: Diplomatic check (Fame × Credits modifier)
   - Success: Joint ownership, -10% prices, +10% inventory
   - Failure: Supplier hostile, refuses business (permanently blocked)
   - Risk: Relationship-dependent, can fail
   - Follow-up: "Partnership" event chain (collaborative benefits)

### Economic Boom

**Trigger**: Complete 5 successful missions in 1 month, Month >= 5

**Scenario**: Media attention on player successes triggers economic boom. Investors interested.

**Player Choices**:

1. **Accept Investors**
   - Immediate: +100K credits one-time payment
   - Long-term: Investors demand 10% monthly revenue (permanent)
   - Benefit: Large cash injection
   - Risk: Long-term profit reduction, lose autonomy
   - Follow-up: "Shareholder Pressure" events (demands/expectations)

2. **Reject Investors**
   - Immediate: +15 fame (independence)
   - Long-term: No strings attached
   - Benefit: Complete financial autonomy
   - Risk: Miss opportunity for growth capital
   - Follow-up: "Self-Sufficiency" event (unlock special missions)

3. **Negotiate Terms**
   - Immediate: Diplomatic check (Fame + Karma)
   - Success: +50K credits, only 5% monthly revenue share
   - Failure: Investors offended, -10 fame (bad publicity)
   - Risk: Can fail negotiation
   - Follow-up: "Business Expansion" events (growth opportunities)

---

## Environmental Events

### Natural Disaster

**Trigger**: Base in high-risk biome (coastal, seismic, etc.), Month >= 4

**Scenario**: Earthquake, hurricane, or tsunami threatens base infrastructure.

**Player Choices**:

1. **Emergency Evacuation**
   - Immediate: Base offline for 3 months (evacuation + rebuild)
   - Long-term: All personnel and equipment saved
   - Benefit: Zero casualties, complete recovery
   - Risk: Long downtime, mission capacity reduced
   - Follow-up: "Disaster Recovery" event (faster rebuild option)

2. **Ride It Out**
   - Immediate: Risk assessment (base fortification level)
   - Success: 70% chance minor damage only (1 month repair)
   - Failure: 30% chance major damage (6 months repair, lose 5-10 units)
   - Risk: Potential catastrophic loss
   - Follow-up: "Structural Reinforcement" research unlock

3. **Relocate Base**
   - Immediate: Cost 50% of base construction value
   - Long-term: Move to safer location (new province)
   - Benefit: Future disaster risk reduced 80%
   - Risk: Expensive, lose territorial control temporarily
   - Follow-up: "New Location" event (establish presence)

### Alien Terraforming

**Trigger**: Alien bases > 5 globally, Month >= 9

**Scenario**: Aliens begin large-scale environmental modification (climate change).

**Player Choices**:

1. **Sabotage Operations**
   - Immediate: Unlock 3 sabotage missions (destroy terraforming equipment)
   - Success: Stop terraforming, save affected regions
   - Failure: Terraforming continues, -20% affected region productivity
   - Risk: High-difficulty missions, elite alien defenders
   - Follow-up: "Environmental Restoration" missions

2. **Adapt to Changes**
   - Immediate: Emergency research (environmental suits, 100 man-days)
   - Long-term: Units can operate in transformed environments
   - Benefit: Maintain operational capability
   - Risk: Diverts research, aliens continue terraforming
   - Follow-up: "Alien Biome" missions (new tactical environments)

3. **Counter-Terraforming**
   - Immediate: Massive research project (300 man-days)
   - Success: Reverse alien changes globally
   - Failure: Waste resources, terraforming irreversible
   - Risk: Resource-intensive, uncertain outcome
   - Follow-up: "Ecological Warfare" event (strategic options unlock)

### Contamination Zone

**Trigger**: Use chemical/biological weapons 3+ times, Month >= 6

**Scenario**: Previous battlefield contaminated with hazardous materials. Spreading.

**Player Choices**:

1. **Clean Up Operation**
   - Immediate: Cost 50K credits + 2 month cleanup mission
   - Long-term: Zone restored, +20 karma (responsibility)
   - Benefit: Ethical choice, positive publicity
   - Risk: Expensive, diverts resources
   - Follow-up: "Environmental Stewardship" events (positive relations)

2. **Ignore Problem**
   - Immediate: No cost
   - Long-term: -30 karma, -15 fame, zone becomes no-go area
   - Benefit: Save resources
   - Risk: Lose strategic territory, civilian casualties
   - Follow-up: "Ecological Disaster" event (consequences escalate)

3. **Weaponize Zone**
   - Immediate: Research "Hazard Warfare" (50 man-days)
   - Long-term: Can create contamination zones tactically
   - Benefit: New strategic capability
   - Risk: -50 karma (war crime), countries may sanction
   - Follow-up: "War Crimes" event (international pressure)

---

## Event Response System

### Choice Timer

Events have limited response windows:

- **Minor Events**: 5 days in-game time (player can delay 1 month max)
- **Major Events**: 10 days in-game time (player can delay 2 months max)
- **Critical Events**: 30 days in-game time (immediate attention required)

**Timeout Consequences**:
- If player ignores event, random choice selected (worst outcome bias)
- Fame penalty (-5 to -20 depending on severity)
- "Indecisive" trait applied (future events have shorter timers)

### Player Resources for Decisions

Some events allow spending resources to improve outcomes:

```yaml
Example: Border Conflict Mediation
Base Success Chance: 50%
Modifiers:
  - Spend 10K credits (diplomatic gift): +10%
  - Spend 50 fame (leverage reputation): +15%
  - Deploy 5 units as peacekeepers: +20%
  - Have "Diplomat" advisor: +25%
Final Success Chance: Calculated when player commits
```

### Skill Checks

Certain choices require skill checks:

**Diplomatic Check**:
```
Success Chance = (Fame × 0.5) + (Karma × 0.3) + (Advisor Bonus) + (Random 1-20)
Threshold: 50 (easy), 75 (medium), 100 (hard)
```

**Intelligence Check**:
```
Success Chance = (Research Projects Completed × 2) + (Scientist Count × 3) + (Random 1-20)
Threshold: 40 (easy), 70 (medium), 100 (hard)
```

**Military Check**:
```
Success Chance = (Win Rate × 100) + (Average Unit Rank × 10) + (Random 1-20)
Threshold: 60 (easy), 85 (medium), 110 (hard)
```

---

## Event Chains & Consequences

### Multi-Stage Events

Events can trigger follow-up events based on player choices:

**Example Chain: Military Coup**

```
Stage 1: Military Coup (Month 5)
  → Choose Support Regime
  
Stage 2: Regime Consolidation (Month 7)
  → New regime purges opposition
  → Player must choose: Support purge (more karma loss) or distance self
  
Stage 3a: Authoritarian Alliance (Month 9) [if supported]
  → Regime offers exclusive military tech
  → Access to "Elite Conscript" units
  
Stage 3b: International Condemnation (Month 9) [if supported]
  → Other countries pressure player to cut ties
  → Choose: Maintain alliance (lose 2-3 countries) or abandon regime
  
Stage 4: Civil War (Month 12) [if maintained alliance]
  → Regime faces popular uprising
  → Player must defend regime (5 missions) or watch collapse
```

### Permanent Consequences

Some event choices create permanent changes:

- **Faction Reputation**: Alien factions remember betrayals (vendetta status)
- **Country Memory**: Countries track player support/abandonment
- **Technology Locks**: Choosing one research path may permanently lock others
- **Character Deaths**: Some events can kill advisors or hero units (permanent loss)
- **Base Destruction**: Critical failures can destroy bases (rebuild from scratch)

### Butterfly Effects

Minor choices early can have major late-game impacts:

```yaml
Example: Scientist Defection (Month 8)
  → Player chooses "Counter-Intelligence" (feed false data)
  → Success: Aliens waste 3 months researching fake tech
  
  → Late-Game Effect (Month 15):
    - Aliens develop paranoia about their research
    - 20% of alien research projects delayed (they doubt everything)
    - Player gains permanent intelligence advantage
    
  → BUT: If player later defects to alien faction
    - Aliens remember the deception
    - Refuse all diplomatic overtures (vendetta)
    - Endgame alliance path blocked
```

---

## Balancing & Pacing

### Event Probability Curves

Event generation follows designed probability curves:

**Early Game (Months 1-4)**: 0% event chance (learning phase)

**Mid Game (Months 5-8)**: Gradual ramp
- Month 5: 20% chance per month
- Month 6: 40% chance per month
- Month 7: 60% chance per month
- Month 8: 80% chance per month

**Late Game (Months 9-12)**: High frequency
- Month 9-10: 100% chance (1 guaranteed event per month)
- Month 11-12: 150% chance (1-2 events per month)

**Endgame (Month 13+)**: Crisis mode
- 200% chance (2+ events per month, overlapping)

### Player Power Adjustment

Event difficulty scales with player power:

```yaml
Player Power Score = (Total Bases × 10) + (Average Unit Rank × 5) + 
                     (Research Projects × 3) + (Monthly Income / 1000)

Event Difficulty Modifier:
  Low Power (0-50): Events offer more aid, easier choices
  Medium Power (51-100): Standard events, balanced choices
  High Power (101-150): Events more challenging, harder tradeoffs
  Overwhelming Power (151+): Crisis events, desperate alien tactics
```

### Cooldown System

To prevent event spam:

- **Same Event**: Cannot repeat for 6 months minimum
- **Same Category**: Maximum 2 events per category per 3 months
- **Major Events**: Maximum 1 per month
- **Critical Events**: Maximum 1 per 2 months
- **Player-Triggered Events**: No cooldown (consequence of actions)

---

## Integration with Existing Systems

### Geoscape Integration

Events can modify Geoscape state:

- Change country relations dynamically
- Spawn special missions (time-limited)
- Alter alien faction behavior
- Modify resource availability globally
- Create temporary no-go zones (contamination, war zones)

### Basescape Integration

Events can affect base operations:

- Force base evacuations or shutdowns
- Trigger base defense missions
- Provide facility upgrade opportunities
- Introduce new personnel (defectors, refugees)
- Cause resource shortages (manufacturing delays)

### Battlescape Integration

Events can influence tactical combat:

- Unlock new mission types (special operations)
- Modify enemy unit composition (adaptive tactics)
- Introduce environmental hazards (contamination zones)
- Provide temporary unit bonuses (morale boosts)
- Create rescue missions (save VIPs, defectors)

### Economy Integration

Events drive economic pressure:

- Material shortages (manufacturing bottlenecks)
- Funding volatility (country crises)
- Black market opportunities (limited-time deals)
- Inflation events (marketplace chaos)
- Supplier changes (new vendors, bankruptcies)

### Politics Integration

Events shape diplomatic landscape:

- Country alignment shifts (coups, wars)
- Faction reputation changes (betrayals, alliances)
- Fame/Karma adjustments (publicity events)
- Advisor loyalty tests (must choose sides)
- International law changes (new restrictions)

---

## Technical Implementation

### Event Data Structure

```lua
Event = {
  id = "event_coup_01",
  category = "political",
  severity = "major",
  
  -- Trigger conditions
  triggers = {
    month_min = 5,
    country_relation_max = 30,
    fame_min = 50,
    random_chance = 0.15,
    cooldown_months = 6
  },
  
  -- Narrative content
  content = {
    title = "Military Coup in {country_name}",
    description = "The government of {country_name} has been overthrown...",
    icon = "event_coup.png",
    audio_cue = "event_political.ogg"
  },
  
  -- Player choices
  choices = {
    {
      id = "support_regime",
      text = "Support the new military regime",
      
      -- Immediate effects
      immediate = {
        country_relation = {country_id, 20},
        karma = -15,
        fame = -5
      },
      
      -- Long-term effects
      long_term = {
        unlock_supplier = "military_syndicate",
        trigger_event_chain = "coup_aftermath_military",
        track_choice = "supported_coup"
      },
      
      -- Requirements
      requirements = {
        karma_max = 50 -- Can't choose if too high karma
      }
    },
    
    {
      id = "support_restoration",
      text = "Support democratic restoration",
      
      immediate = {
        country_relation = {country_id, -10},
        karma = 20,
        fame = 10
      },
      
      long_term = {
        spawn_mission_chain = "restore_democracy",
        risk_lose_country = {country_id, 0.30}
      }
    },
    
    {
      id = "stay_neutral",
      text = "Remain neutral",
      
      immediate = {
        country_relation = {country_id, -5}
      },
      
      long_term = {
        country_unstable = {country_id, 3}, -- 3 months
        random_events_modifier = 1.5
      }
    }
  },
  
  -- Follow-up events
  follow_ups = {
    {
      event_id = "coup_aftermath_military",
      condition = "supported_coup",
      delay_months = 2
    },
    {
      event_id = "coup_aftermath_democratic",
      condition = "supported_restoration",
      delay_months = 6
    }
  }
}
```

### Event Manager Module

```lua
-- engine/geoscape/event_manager.lua

EventManager = {}

function EventManager:init()
  self.active_events = {}
  self.event_history = {}
  self.event_cooldowns = {}
end

function EventManager:update(game_state, delta_time)
  -- Check for event triggers
  for _, event_template in ipairs(EventDatabase.all_events) do
    if self:checkTriggers(event_template, game_state) then
      self:spawnEvent(event_template, game_state)
    end
  end
  
  -- Update active event timers
  for event_id, event in pairs(self.active_events) do
    event.time_remaining = event.time_remaining - delta_time
    
    if event.time_remaining <= 0 then
      self:handleTimeout(event, game_state)
    end
  end
end

function EventManager:checkTriggers(event_template, game_state)
  -- Month requirement
  if game_state.current_month < event_template.triggers.month_min then
    return false
  end
  
  -- Cooldown check
  if self:isOnCooldown(event_template.id) then
    return false
  end
  
  -- Random chance
  if math.random() > event_template.triggers.random_chance then
    return false
  end
  
  -- Custom trigger conditions
  for condition, value in pairs(event_template.triggers) do
    if not self:evaluateCondition(condition, value, game_state) then
      return false
    end
  end
  
  return true
end

function EventManager:spawnEvent(event_template, game_state)
  local event = {
    id = event_template.id,
    template = event_template,
    spawn_time = game_state.current_time,
    time_remaining = event_template.response_window or 10 * DAY_LENGTH,
    context = self:buildContext(event_template, game_state)
  }
  
  self.active_events[event.id] = event
  
  -- Notify UI
  GUI:showEventNotification(event)
  
  -- Track history
  table.insert(self.event_history, {
    event_id = event.id,
    timestamp = game_state.current_time
  })
end

function EventManager:handlePlayerChoice(event_id, choice_id, game_state)
  local event = self.active_events[event_id]
  local choice = event.template.choices[choice_id]
  
  -- Apply immediate effects
  self:applyImmediateEffects(choice.immediate, game_state)
  
  -- Queue long-term effects
  self:queueLongTermEffects(choice.long_term, game_state)
  
  -- Trigger follow-up events
  self:scheduleFollowUps(event.template.follow_ups, choice_id, game_state)
  
  -- Apply cooldown
  self:applyCooldown(event.template.id, event.template.triggers.cooldown_months)
  
  -- Remove from active events
  self.active_events[event_id] = nil
  
  -- Log choice for future reference
  game_state.event_choices[event_id] = choice_id
end
```

### UI Integration

Events displayed as popup windows with:

- **Event Icon**: Visual representation (political, alien, scientific, etc.)
- **Title**: Clear event name
- **Description**: 2-3 paragraphs of narrative context
- **Choice Buttons**: 2-4 options with clear labels
- **Hover Tooltips**: Show predicted effects before committing
- **Timer Display**: Countdown showing time remaining to decide
- **History Log**: Access previous events and review choices made

---

## Example Event Scenarios

### Complete Event: "The Purge"

**Context**: Follow-up to Military Coup if player supported regime

```yaml
Event: "The Purge"
Trigger: 2 months after supporting military coup
Severity: Major
Category: Political

Description:
"The military regime in {country_name} has begun systematically eliminating
political opposition. Thousands of civilians are being arrested, and reports
of executions are emerging. International observers are calling for your
organization to intervene or clarify your stance. Your continued support
is under scrutiny."

Choices:

1. "Publicly Support the Purge"
   Immediate:
     - Country relation: +20 (regime grateful)
     - Karma: -30 (war crimes complicity)
     - Fame: -25 (international outrage)
     - 3 countries reduce relations by -20
   Long-term:
     - Unlock "Authoritarian Alliance" benefit (+20% funding from regime)
     - Regime provides elite military units (5 "Elite Conscripts")
     - Permanent karma penalty (cap at +50 maximum)
   Follow-up: "International Tribunal" event (war crimes investigation)

2. "Condemn the Purge"
   Immediate:
     - Country relation: -40 (regime betrayed)
     - Karma: +15 (ethical stand)
     - Fame: +10 (positive publicity)
   Long-term:
     - Lose access to military supplier
     - Country becomes hostile (may attack bases)
     - Unlock "Redemption" event chain (restore democratic government)
   Follow-up: "Regime Retaliation" event (sabotage attempts)

3. "Stay Silent"
   Immediate:
     - Country relation: -10 (regime disappointed)
     - Karma: -10 (complicity through inaction)
     - Fame: -15 (seen as cowardly)
   Long-term:
     - Maintain lukewarm relations with regime
     - 2 countries reduce relations by -10 (ethical concerns)
     - Protesters target your bases (civilian unrest events)
   Follow-up: "Fence Sitting" event (both sides pressure you)

4. "Covert Intervention" [Requires Intelligence 70+]
   Immediate:
     - Unlock secret mission: "Extract Opposition Leaders" (5 missions)
     - Country relation: 0 (regime unaware)
     - Karma: +20 (heroic action)
   Success Path:
     - Save 10-15 civilian NPCs (become units or advisors)
     - Regime eventually collapses from internal resistance
     - +30 fame when truth revealed
   Failure Path:
     - Regime discovers intervention (-60 country relation)
     - War declared on player organization
     - -40 fame (international incident)
   Follow-up: "Underground Railroad" event chain
```

---

## Conclusion

The Procedural Event System transforms AlienFall's mid-game from repetitive mission grinding into dynamic, narrative-driven strategic gameplay. By forcing meaningful choices with cascading consequences, events create emergent stories unique to each player's campaign.

**Key Success Metrics**:
- Player engagement hours 20-40 increase by 30%
- Mission variety perception increases (survey feedback)
- Replay value increases (different event chains per playthrough)
- Strategic depth increases (more player choices matter)

**Implementation Priority**: CRITICAL (Tier 1)  
**Estimated Development Time**: 3-4 weeks  
**Dependencies**: Politics.md, AI.md, Geoscape.md  
**Risk Level**: Medium (requires extensive playtesting for balance)

---

**Document Status**: Design Proposal - Ready for Review  
**Next Steps**: Prototype 10 events (2 per category), implement event manager, playtest  
**Author**: Senior Game Designer  
**Review Date**: 2025-10-28

