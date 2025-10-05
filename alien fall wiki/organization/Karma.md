# Karma

## Table of Contents
- [Overview](#overview)
- [Mechanics](#mechanics)
  - [Karma Scale and Alignments](#karma-scale-and-alignments)
  - [Karma Sources](#karma-sources)
  - [Karma Effects](#karma-effects)
- [System Integration](#system-integration)
  - [Supplier System Integration](#supplier-system-integration)
  - [Research System Integration](#research-system-integration)
  - [Mission System Integration](#mission-system-integration)
  - [Faction System Integration](#faction-system-integration)
- [Examples](#examples)
  - [Mission Karma Examples](#mission-karma-examples)
  - [Decision Point Examples](#decision-point-examples)
  - [Alignment Progression Examples](#alignment-progression-examples)
- [Related Wiki Pages](#related-wiki-pages)
- [References to Existing Games and Mechanics](#references-to-existing-games-and-mechanics)

## Overview

The Karma system measures the player's moral and ethical standing throughout the campaign, creating meaningful consequences for humanitarian vs. ruthless decision-making. Karma operates as a reputation metric that influences available content, relationships, and capabilities without creating immediate failure states. The system provides players with clear visibility into moral consequences while maintaining replayability through different ethical approaches.

Key design principles include:
- Moral Choice Consequences: Ethical decisions have tangible gameplay impacts
- Content Branching: Different karma levels unlock unique narrative and gameplay paths
- Deterministic Tracking: Complete audit trail for moral decision outcomes
- Player Agency: Clear visibility into karma consequences and projections
- Non-Punitive Design: Karma creates incentives rather than restrictions

## Mechanics

### Karma Scale and Alignments
Karma operates on a -100 to +100 scale with five distinct alignment categories that determine global effects and content access.

Karma Alignments:
- Renegade (-100 to -60): Ruthless pragmatism with access to unethical capabilities
- Ruthless (-59 to -20): Hard-nosed approach with limited moral constraints
- Neutral (-19 to 19): Balanced methodology with standard options available
- Principled (20 to 59): Ethical considerations with humanitarian bonuses
- Paragon (60 to 100): Noble idealism with advanced ethical capabilities

Alignment Characteristics:
- Each alignment provides specific content unlocks and restrictions
- Threshold crossings trigger immediate effect changes
- Visual and narrative representation in UI
- Progressive scaling of ethical consequences

### Karma Sources
Karma changes originate from various player decisions and actions with different moral implications.

Mission Outcomes:
- Zero Civilian Casualties: Humanitarian success (+5 base)
- Civilian Casualties: Moral cost (-5 per casualty)
- Collateral Damage: Unintended harm penalty (-8)
- Chemical Weapon Use: War crime designation (-15)
- Non-Lethal Hostage Rescue: Ethical resolution (+10)

Capture and Interrogation:
- Live Alien Capture: Preservation of life (+3)
- Torture Methods: Cruelty penalty (-5 additional)
- Unethical Sale: Commodification of life (-10)
- Ethical Study: Moral research approach (+3)

Equipment and Research:
- Non-Lethal Weapons: Humanitarian technology (+1 equip, +2 use)
- Chemical Weapons: Indiscriminate harm (-2 equip, -5 use)
- Mind Control Devices: Autonomy violation (-3 equip, -8 use)
- Medical Technology: Life preservation (+1 equip, +3 use)

Ethical Decisions:
- Hostage Sacrifice: Utilitarian calculus (-15)
- Civilian Evacuation: Protective priority (+8)
- Prisoner Release: Mercy and rehabilitation (+5)
- Unethical Experimentation: Scientific cruelty (-12)

### Karma Effects
Karma alignments provide global modifiers and content access that affect multiple game systems simultaneously.

Supplier Access:
- Renegade: Black market, arms dealers, rogue scientists
- Ruthless: Black market, arms dealers (limited)
- Neutral: All standard supplier categories
- Principled: Standard and ethical suppliers, humanitarian organizations
- Paragon: Ethical suppliers, humanitarian orgs, international aid

Research Availability:
- Renegade: Chemical weapons, mind control, enhanced interrogation
- Ruthless: Chemical weapons, enhanced interrogation
- Neutral: Standard research tree
- Principled: Non-lethal weapons, ethical research, humanitarian technology
- Paragon: All principled research plus advanced ethical technologies

Mission Types:
- Renegade: Assassination, ruthless intervention
- Ruthless: Covert operations, deniable missions
- Neutral: Standard mission categories
- Principled: Humanitarian missions, protective details
- Paragon: Peacekeeping, rescue operations, humanitarian interventions

Diplomatic Effects:
- Renegade: Significant diplomatic penalties (-20)
- Ruthless: Moderate diplomatic penalties (-10)
- Neutral: Standard diplomatic relations (0)
- Principled: Diplomatic bonuses (+10)
- Paragon: Major diplomatic advantages (+20)

## System Integration

### Supplier System Integration
Karma directly controls access to different types of equipment and service providers.

Ethical Suppliers:
- Access restricted to principled and paragon alignments
- Premium equipment with humanitarian applications
- Higher quality standards and reliability guarantees
- Research collaboration opportunities

Black Market Suppliers:
- Available only to renegade and ruthless alignments
- Questionable equipment with powerful capabilities
- Unreliable delivery and potential complications
- Covert transaction requirements

Standard Suppliers:
- Available to neutral alignment and above
- Balanced equipment options with proven reliability
- Transparent pricing and support arrangements
- Professional service guarantees

### Research System Integration
Karma influences available research topics and technological development paths.

Ethical Research Trees:
- Unlocked at principled and paragon alignments
- Technologies focused on non-lethal applications
- Humanitarian and protective innovations
- Advanced ethical research capabilities

Unethical Research Paths:
- Restricted to renegade and ruthless alignments
- Dangerous technologies with moral implications
- Powerful capabilities with significant risks
- Covert development requirements

Standard Research:
- Available across all alignments
- Balanced technological progression
- Neutral applications and capabilities
- Publicly acceptable development paths

### Mission System Integration
Karma affects mission generation, objectives, and available strategic options.

Humanitarian Missions:
- Exclusive to principled and paragon alignments
- Focus on civilian protection and rescue operations
- Bonus rewards for ethical completion
- Enhanced diplomatic outcomes

Ruthless Missions:
- Limited to renegade and ruthless alignments
- Aggressive objectives with moral flexibility
- Higher risk/reward ratios
- Covert operation requirements

Standard Missions:
- Available across all alignments
- Balanced objectives and challenges
- Neutral diplomatic implications
- Flexible completion approaches

### Faction System Integration
Karma influences relationships with various geopolitical and extraterrestrial entities.

Diplomatic Relationships:
- Alignment-based faction attitudes and trust levels
- Unique alliance opportunities for different moral stances
- Trade agreement availability and terms
- International cooperation possibilities

Faction-Specific Content:
- Alignment-gated dialogue options with faction leaders
- Unique quests and missions based on moral standing
- Specialized equipment and technology access
- Alternative narrative outcomes and endings

## Examples

### Mission Karma Examples
Urban Rescue Operation - Zero Casualties:
- Scenario: Hostage situation resolved with stun weapons and evacuation
- Karma Gains: +5 (zero casualties) +10 (non-lethal rescue) = +15
- Alignment Impact: Movement toward Principled alignment
- Content Unlocks: Access to humanitarian mission types
- Strategic Benefit: Enhanced diplomatic relations

Chemical Weapon Deployment:
- Scenario: Alien infestation cleared using area-denial chemical agents
- Karma Cost: -15 (chemical weapon use) -8 (collateral damage) = -23
- Alignment Impact: Shift toward Ruthless alignment
- Content Unlocks: Black market supplier access
- Strategic Cost: Diplomatic penalties and ethical research restrictions

Live Alien Capture with Torture:
- Scenario: Sectoid captured alive but subjected to enhanced interrogation
- Karma Calculation: +3 (live capture) -5 (torture) = -2
- Alignment Impact: Minor negative shift
- Content Effects: Limited research access, supplier restrictions
- Ethical Trade-off: Intelligence gains vs. moral cost

### Decision Point Examples
Hostage Crisis Dilemma:
- Lethal Force Option: -10 karma, ruthless capabilities unlocked
- Non-Lethal Resolution: +10 karma, humanitarian alliances available
- Civilian Sacrifice: -15 karma, maximum ruthless access
- Strategic Impact: Long-term faction relationships and mission availability

Prisoner Disposition Choice:
- Ethical Study: +3 karma, principled research paths
- Unethical Experimentation: -12 karma, dangerous technology access
- Black Market Sale: -10 karma, immediate funding boost
- Release: +5 karma, diplomatic reputation improvement

### Alignment Progression Examples
Neutral to Principled Transition (Karma 15 → 35):
- Previous Access: Standard suppliers and research
- New Capabilities: Ethical suppliers, non-lethal research, humanitarian missions
- Diplomatic Effects: +10 bonus to international relations
- Player Experience: More cooperative gameplay options

Ruthless to Renegade Transition (Karma -45 → -75):
- Previous Access: Black market and ruthless missions
- New Capabilities: Rogue scientists, chemical weapons, enhanced interrogation
- Diplomatic Effects: -20 penalty to international relations
- Player Experience: High-risk, high-reward strategic options

Paragon Alignment Benefits (Karma 85):
- Supplier Access: International aid organizations, advanced ethical tech
- Research Options: Humanitarian technology, advanced ethical research
- Mission Types: Peacekeeping operations, rescue missions
- Diplomatic Standing: Maximum international cooperation bonuses

## Related Wiki Pages

- [Company.md](../organization/Company.md) - Organization core and ethical standing
- [Suppliers.md](../economy/Suppliers.md) - Supplier relationships and availability
- [Research tree.md](../economy/Research%20tree.md) - Research access and technology restrictions
- [Mission objectives.md](../battlescape/Mission%20objectives.md) - Mission choices and ethical decisions
- [Geoscape.md](../geoscape/Geoscape.md) - Faction relationships and diplomatic effects
- [Economy.md](../economy/Economy.md) - Economic effects and trade restrictions
- [Finance.md](../finance/Finance.md) - Financial consequences and funding effects
- [Fame.md](../organization/Fame.md) - Reputation systems and public perception
- [Policies.md](../organization/Policies.md) - Ethical decisions and policy choices
- [Lore.md](../lore/Lore.md) - Story integration and narrative consequences

## References to Existing Games and Mechanics

- **X-COM Series**: Ethical choices and council relations
- **Mass Effect Series**: Paragon/Renegade morality system
- **Dragon Age Series**: Moral choice consequences and reputation
- **Fallout Series**: Karma system and faction standing
- **Vampire: The Masquerade**: Humanity and morality mechanics
- **Planescape: Torment**: Alignment and ethical consequences
- **Baldur's Gate Series**: Reputation and moral standing
- **Star Wars: Knights of the Old Republic**: Light/Dark side morality system
- **Fable Series**: Morality system and reputation effects
- **The Witcher Series**: Moral choice consequences and relationships

