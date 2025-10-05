# Fame

## Table of Contents
- [Overview](#overview)
- [Mechanics](#mechanics)
  - [Fame Scale and Levels](#fame-scale-and-levels)
  - [Fame Sources](#fame-sources)
  - [Fame Effects](#fame-effects)
  - [Fame Modifiers](#fame-modifiers)
- [System Integration](#system-integration)
  - [Funding System Integration](#funding-system-integration)
  - [Recruitment System Integration](#recruitment-system-integration)
  - [Mission System Integration](#mission-system-integration)
  - [Research System Integration](#research-system-integration)
  - [Black Market System Integration](#black-market-system-integration)
- [Examples](#examples)
  - [Mission Fame Examples](#mission-fame-examples)
  - [Publicity Action Examples](#publicity-action-examples)
  - [Fame Level Progression Examples](#fame-level-progression-examples)
  - [Modifier Stacking Examples](#modifier-stacking-examples)
- [Related Wiki Pages](#related-wiki-pages)
- [References to Existing Games and Mechanics](#references-to-existing-games-and-mechanics)

## Overview

The Fame system measures the player's organizational visibility and public prestige, creating strategic trade-offs between public recognition and operational security. Fame influences funding availability, recruitment quality, and mission difficulty while providing players with meaningful choices about their public profile. The system uses deterministic calculations and comprehensive tracking to ensure reproducible outcomes and clear player feedback.

Key design principles include:
- Visibility Trade-offs: High fame provides benefits but increases risks
- Deterministic Calculations: Seeded modifiers ensure consistent outcomes
- Comprehensive Tracking: Complete audit trail of fame changes
- Strategic Depth: Multiple paths to manage organizational reputation
- Player Agency: Clear visibility into fame consequences and modifiers

## Mechanics

### Fame Scale and Levels
Fame operates on a 0-100 scale with five distinct levels that determine global effects and capabilities.

Fame Levels:
- Obscure (0-20): Minimal public awareness with operational freedom
- Notable (21-40): Growing recognition with moderate visibility effects
- Prominent (41-60): Significant public presence with balanced trade-offs
- Famous (61-80): High visibility with enhanced benefits and risks
- Legendary (81-100): Maximum prestige with extreme consequences

Level Characteristics:
- Each level provides specific multipliers for game systems
- Threshold crossings trigger immediate effect changes
- Visual and narrative representation in UI
- Progressive scaling of benefits and drawbacks

### Fame Sources
Fame changes originate from various game activities with different visibility impacts.

Mission Outcomes:
- High-Visibility Success: Major public displays (+10 base)
- Standard Success: Routine operations (+5 base)
- Low-Visibility Success: Covert operations (+1 base)
- Mission Failure: Public setbacks (-2 base)
- Civilian Casualties: Public relations damage (-3 per casualty)

Publicity Actions:
- Press Release: Deliberate media engagement (+20)
- Public Celebration: Victory announcements (+15)
- Official Denial: Damage control (-10)

Research Completions:
- Stealth Technology: Reduced visibility research (+2)
- Public Relations Tech: Media manipulation research (+8)
- Cloaking Research: Concealment technology (+1)

Base Events:
- Attack Successfully Repelled: Defensive victory (+8)
- Base Destroyed: Major setback (-15)
- New Base Construction: Expansion announcement (+3)
- Public Facility Tour: Media event (+12)

### Fame Effects
Fame levels provide global modifiers that affect multiple game systems simultaneously.

Funding Effects:
- Low Fame: Reduced government support (0.5x multiplier)
- High Fame: Increased official funding (1.5x multiplier)
- Moderate Fame: Standard funding levels (1.0x multiplier)

Recruitment Effects:
- Low Fame: Limited access to quality personnel (0.7x quality)
- High Fame: Premium recruitment opportunities (1.3x quality)
- Moderate Fame: Standard recruitment pool (1.0x quality)

Mission Effects:
- Low Fame: Reduced strategic pressure (0.8x difficulty)
- High Fame: Increased detection and targeting (1.2x difficulty)
- Moderate Fame: Standard mission parameters (1.0x difficulty)

Economic Effects:
- Low Fame: Improved black market terms (1.2x discount)
- High Fame: Reduced black market access (0.9x discount)
- Moderate Fame: Standard market rates (1.0x multiplier)

### Fame Modifiers
Players can influence fame generation through policies, research, and equipment choices.

Policy Modifiers:
- Silent Running: Global reduction in fame accrual (50% reduction)
- Public Relations Focus: Increased fame from positive events (25% bonus)
- Covert Operations: Reduced fame from mission successes (30% reduction)

Research Modifiers:
- Stealth Technology: Mission visibility reduction (30% fame decrease)
- Cloaking Systems: Public display fame reduction (50% decrease)
- Media Training: Publicity action effectiveness increase (50% bonus)

Equipment Modifiers:
- Stealth Armor: Individual mission fame reduction (20% decrease)
- Silent Weapons: Combat visibility reduction (10% decrease)
- Cloaking Fields: Detection avoidance enhancement (60% decrease)

Modifier Application:
- Multiplicative stacking with defined precedence order
- Source-specific targeting (missions, publicity, research)
- Temporary vs. permanent modifier distinctions
- Clear UI presentation of active modifiers

## System Integration

### Funding System Integration
Fame directly influences monthly government funding and financial support levels.

Funding Multipliers:
- Base funding adjusted by fame level multipliers
- Additional discretionary funding for high-fame organizations
- Reduced allocations for low-visibility operations
- Emergency funding availability based on public support

Economic Incentives:
- High fame unlocks additional funding sources
- Low fame provides alternative revenue streams
- Strategic funding decisions based on fame management goals

### Recruitment System Integration
Fame affects personnel availability and quality in recruitment pools.

Recruitment Quality:
- Enhanced applicant pools at high fame levels
- Specialized recruitment access for prestigious organizations
- Reduced competition for low-profile operations
- Quality bonuses applied to all recruitment categories

Availability Effects:
- Increased recruitment speed at high fame
- Expanded candidate pools for famous organizations
- Limited options during periods of obscurity
- Strategic timing of recruitment based on fame cycles

### Mission System Integration
Fame influences mission generation, difficulty, and strategic targeting.

Mission Difficulty:
- Increased challenge scaling with fame levels
- Higher priority targeting by alien forces
- Enhanced mission objectives for prestigious organizations
- Reduced pressure during low-visibility periods

Mission Availability:
- Access to high-profile mission types at elevated fame
- Covert operation opportunities during obscurity
- Strategic mission generation based on public profile
- Dynamic difficulty adjustment based on fame trends

### Research System Integration
Certain research projects provide ongoing fame modification capabilities.

Stealth Research:
- Technologies that reduce mission visibility
- Equipment modifiers for covert operations
- Detection avoidance enhancements
- Long-term fame management tools

Public Relations Research:
- Media manipulation technologies
- Publicity campaign effectiveness improvements
- Crisis management capabilities
- Reputation repair and enhancement tools

### Black Market System Integration
Fame levels affect access to unofficial suppliers and resources.

Market Access:
- Improved terms and availability at low fame levels
- Restricted access for highly visible organizations
- Premium pricing for famous entity transactions
- Alternative supply chain availability based on discretion

## Examples

### Mission Fame Examples
High-Visibility Urban Interception:
- Scenario: UFO shot down over major city during daylight
- Base Fame Gain: +5 (mission success) +10 (public display) = +15
- Modifiers Applied: None
- Final Result: +15 fame, "High-visibility mission success"
- Strategic Impact: Increased funding but higher detection risk

Covert Rural Operation:
- Scenario: Alien cell eliminated with no witnesses
- Base Fame Gain: +5 (mission success) +1 (covert operation) = +6
- Modifiers Applied: Stealth technology (-30%) = -2
- Final Result: +4 fame, "Covert mission success"
- Strategic Impact: Minimal visibility increase, operational security maintained

Battleship Destruction with Ocean Debris:
- Scenario: Large UFO destroyed, wreckage falls into ocean
- Base Fame Gain: +5 (mission success) +5 (battleship bonus) -3 (ocean debris) = +7
- Modifiers Applied: Silent weapons (-10%) = -1
- Final Result: +6 fame, "Battleship-class UFO destroyed (debris in ocean)"
- Strategic Impact: Major victory with controlled visibility

### Publicity Action Examples
Victory Press Release:
- Scenario: Official announcement following major success
- Base Fame Gain: +20
- Modifiers Applied: Public relations tech (+50%) = +10
- Final Result: +30 fame, "Public press release issued"
- Strategic Impact: Rapid fame increase, enhanced recruitment and funding

Post-Incident Denial:
- Scenario: Official statement denying involvement in public event
- Base Fame Gain: -10
- Modifiers Applied: None
- Final Result: -10 fame, "Public denial of involvement"
- Strategic Impact: Controlled damage limitation, reduced scrutiny

### Fame Level Progression Examples
Obscure to Notable Transition (Fame 18 → 25):
- Previous Effects: 0.5x funding, 0.7x recruitment quality, 0.3x detection risk
- New Effects: 0.8x funding, 0.85x recruitment quality, 0.5x detection risk
- Player Impact: Improved financial stability, better personnel access
- Strategic Shift: More viable overt operations, increased alien attention

Prominent to Famous Transition (Fame 58 → 72):
- Previous Effects: 1.0x funding, 1.0x recruitment quality, 1.0x detection risk
- New Effects: 1.2x funding, 1.15x recruitment quality, 1.3x detection risk
- Player Impact: Enhanced resources but higher operational pressure
- Strategic Shift: Access to elite capabilities with increased strategic challenges

### Modifier Stacking Examples
Comprehensive Stealth Setup:
- Base Mission Fame: +8 (successful interception)
- Policy Modifier: Silent Running (-50%) = -4
- Research Modifier: Stealth Technology (-30%) = -2
- Equipment Modifier: Stealth Armor (-20%) = -1
- Final Result: +1 fame, "Covert mission success"
- Effectiveness: 87.5% reduction in fame gain

Public Relations Campaign:
- Base Publicity Fame: +20 (press release)
- Research Modifier: Media Manipulation (+25%) = +5
- Policy Modifier: Public Focus (+15%) = +3
- Final Result: +28 fame, "Enhanced press release issued"
- Effectiveness: 40% increase in publicity effectiveness

## Related Wiki Pages

- [Company.md](../organization/Company.md) - Organization core and management
- [Finance.md](../finance/Finance.md) - Funding effects and budget bonuses
- [Recruitment.md](../units/Recruitment.md) - Recruitment bonuses and quality improvements
- [Mission objectives.md](../battlescape/Mission%20objectives.md) - Mission fame rewards and publicity
- [Research tree.md](../economy/Research%20tree.md) - Research bonuses and funding increases
- [Black market.md](../economy/Black%20market.md) - Market access and special deals
- [Geoscape.md](../geoscape/Geoscape.md) - Global reputation and strategic effects
- [Basescape.md](../basescape/Basescape.md) - Base operations and expansion bonuses
- [Karma.md](../organization/Karma.md) - Reputation systems and moral standing
- [Policies.md](../organization/Policies.md) - Publicity actions and media management

## References to Existing Games and Mechanics

- **X-COM Series**: Council reputation and funding based on performance
- **Civilization Series**: Diplomatic reputation and cultural influence
- **Crusader Kings III**: Dynasty fame and legacy systems
- **Europa Universalis IV**: Nation reputation and diplomatic standing
- **Total War Series**: Faction reputation and campaign standing
- **Stellaris**: Empire reputation and diplomatic relations
- **Victoria Series**: National prestige and international standing
- **Hearts of Iron Series**: World tension and international reputation
- **Company of Heroes**: Company reputation and reinforcement bonuses
- **Battlefleet Gothic**: Fleet reputation and command standing

