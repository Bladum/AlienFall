# Win-Loss Conditions

## Table of Contents
- [Overview](#overview)
- [Mechanics](#mechanics)
  - [Open-Ended and Soft-Fail Frameworks](#open-ended-and-soft-fail-frameworks)
  - [Achievement System Architecture](#achievement-system-architecture)
  - [Failure State Management Systems](#failure-state-management-systems)
  - [Recovery System Frameworks](#recovery-system-frameworks)
  - [Retirement System Architecture](#retirement-system-architecture)
  - [Progress Tracking and UI Systems](#progress-tracking-and-ui-systems)
  - [Determinism and Moddability Frameworks](#determinism-and-moddability-frameworks)
- [Examples](#examples)
  - [Open-Ended Failure Scenarios](#open-ended-failure-scenarios)
  - [Achievement System Cases](#achievement-system-cases)
  - [Failure State Management Examples](#failure-state-management-examples)
  - [Recovery System Scenarios](#recovery-system-scenarios)
  - [Retirement System Cases](#retirement-system-cases)
  - [Progress Tracking Examples](#progress-tracking-examples)
- [Related Wiki Pages](#related-wiki-pages)
- [References to Existing Games and Mechanics](#references-to-existing-games-and-mechanics)

## Overview

The Win-Loss Conditions system establishes comprehensive campaign conclusion frameworks for Alien Fall's strategic gameplay, implementing achievement-based victory paths, failure state management, and recovery mechanisms while maintaining player agency and open-ended play. The system creates meaningful campaign goals through configurable victory conditions, progressive challenge escalation, and narrative conclusion options while preserving replayability and emergent gameplay. The framework balances structured objectives with player-driven outcomes, enabling diverse strategic approaches and multiple successful campaign conclusions. By default, bankruptcy, base loss, negative score, or zero funding create serious setbacks that limit options rather than automatic endings, with recovery paths including loans, asset sales, alliances, and alternative economic strategies.

## Mechanics

### Open-Ended and Soft-Fail Frameworks

Challenge escalation without immediate termination:
- Failure State Management: Challenge escalation without immediate termination, treating setbacks as strategic limitations
- Recovery Pathway Systems: Multiple rehabilitation options including loans, asset sales, alliances, mercenary hires, and alternative economic strategies
- Player Agency Preservation: Continued gameplay despite setbacks with black market activation, licensing, and mergers as recovery options
- Economic Rehabilitation: Financial recovery mechanisms, debt management options, and bankruptcy restructuring
- Strategic Adaptation: Alternative approaches, contingency planning, and operational redeployment capabilities
- Narrative Continuity: Story progression despite operational difficulties with designer hooks for campaign overrides

### Achievement System Architecture

Configurable victory conditions with data-driven definitions:
- Configurable Victory Conditions: Data-driven achievement definitions (YAML/JSON) with id, trigger conditions, thresholds, and reward payloads
- Trigger Mechanism Variety: Instant events and sustained condition monitoring requiring held thresholds for N turns
- Reward Structure Design: Achievement benefits, campaign progression unlocks, text, animation, and optional auto-retire flags
- Multiplayer Compatibility: Shared and individual achievement handling with per-player or consensus requirements
- Progress Tracking Systems: Achievement advancement monitoring, completion forecasting, and provenance metadata recording
- Modding Integration: Community-created victory condition support with on_achievement_progress and on_achievement_complete hooks

### Failure State Management Systems

Progressive challenge increase with recovery incentives:
- Challenge Escalation: Difficulty increase without campaign termination, enemy strength increases, and mission difficulty elevation
- Option Restriction Frameworks: Strategic limitation implementation with advanced project blocking and recovery incentives
- Recovery Threshold Definition: Rehabilitation requirement establishment, progression tracking, and threshold-based recovery
- Economic Pressure Application: Financial consequence systems, credit rating drops, and borrowing cost increases
- Operational Continuity: Campaign continuation despite significant setbacks with mobile command establishment
- Narrative Adaptation: Story adjustment based on failure state progression and operational context

### Recovery System Frameworks

Multiple rehabilitation pathways and strategic choice:
- Rehabilitation Pathways: Multiple recovery option availability including financial restructuring and operational redeployment
- Asset Management: Resource liquidation, strategic repositioning, and destroyed facility replacement
- Alliance Formation: Cooperative relationship development, mutual support systems, and defense pact establishment
- Economic Restructuring: Financial reorganization, debt management strategies, and black market elimination
- Operational Redeployment: Force redistribution, new base establishment, and strategic advantage regain
- Long-Term Planning: Recovery timeline establishment, sustainable improvement, and strategic assessment

### Retirement System Architecture

Player-initiated and achievement-based campaign conclusion:
- Voluntary Conclusion: Player-initiated campaign termination options with retire/exit availability when recovery impossible
- Achievement-Based Ending: Victory condition completion, campaign conclusion, and optional auto-retire behavior
- Legacy Preservation: Accomplishment recording, historical significance, and future campaign influence
- Strategic Assessment: Campaign performance evaluation, outcome analysis, and experience application
- Future Campaign Integration: Improved starting conditions, character development completion, and legacy benefits
- Narrative Closure: Story conclusion, cinematic endings, and narrative compilation sequences

### Progress Tracking and UI Systems

Achievement visualization and strategic planning support:
- Achievement Visualization: Progress display, requirement communication, and remaining threshold indication
- Forecasting Capabilities: Completion estimation, strategic planning support, and deterministic forecasting based on seeded projections
- Real-Time Updates: Progress monitoring, advancement notification, and achievement progress tracking
- Historical Recording: Achievement timeline, milestone documentation, and contributing event logging
- Strategic Guidance: Goal-oriented decision support, planning assistance, and user-defined objective setting
- User Customization: Personal objective setting, custom challenges, and achievement preference configuration

### Determinism and Moddability Frameworks

Seeded randomness with comprehensive modding support:
- Seeded Randomness: Reproducible achievement timing, outcome consistency, and seeded evaluation for playtesting
- Configuration Flexibility: Data-driven parameter adjustment, per-campaign configuration, and victory path enablement
- Event Integration: Campaign event influence on victory condition progression with hook-based integration
- Balance Testing: Consistent outcome verification, design validation, and reproducible achievement checks
- Community Content: User-created victory conditions, achievement systems, and modder extension capabilities
- Technical Documentation: Implementation guidance, extension capabilities, and director script integration

## Examples

### Open-Ended Failure Scenarios
- Bankruptcy Management: Financial collapse occurred, Recovery loan obtained ($2M), Operations continued with restrictions, Economic rehabilitation initiated
- Base Loss Recovery: Primary base destroyed, Secondary base activated, Emergency construction initiated, Strategic repositioning completed
- Score Decline Management: Public perception dropped to critical, PR campaign launched, Score recovery +50 points, Funding stabilized
- Zero Funding Adaptation: Government support withdrawn, Black market activated (penalty -20 karma), Alternative income streams established
- Strategic Readjustment: Multiple failures occurred, Asset sales completed ($1M generated), Mercenary forces hired, Recovery trajectory established

### Achievement System Cases
- Story Victory: Complete scripted finale (mothership assault), Research "Alien Mastermind's Weakness", Cinematic ending achieved
- Technology Victory: Research specified high-tier technology ("Interworld Drive"), Finish propulsion research subtree, Scientific victory obtained
- Military Victory: Own X capital provinces, Field Y Tier-3 crafts, Hold for Z turns, Supreme military contractor ending unlocked
- Economic Victory: Reach $100M treasury, Control 80% supplier stock, Celebratory investor takeover sequence triggered
- Diplomatic Victory: Obtain FundingLevel 90+ from five powers, Secure simultaneous treaties, Global partner ending granted
- Cultural Victory: Karma ≥ +80 and Fame ≥ 90, Score > X across major countries, Saviour of humanity montage displayed
- Scientific Victory: Discover all worlds/portals, Analyze every artifact, Fully document alien species, Explorer ending achieved
- Exploration Victory: Activate all portals, Map alien homeworld, Complete exploration epilogue with discovery rewards
- Elimination Victory: Destroy rival faction, Capture research tree/assets, Reverse-engineer 100% technology, Corporate assimilation completed
- Infrastructure Victory: Build N bases of size S, K reactors online, L hangars operational, Industrial triumph vignette shown

### Failure State Management Examples
- Challenge Escalation: Base destruction occurred, Enemy strength increased 25%, Mission difficulty elevated, Strategic pressure applied
- Option Restrictions: Funding reduced 50%, Advanced projects blocked, Basic operations only, Recovery incentives activated
- Recovery Thresholds: Bankruptcy declared, Debt restructuring required, 6-month recovery period, Limited operations allowed
- Economic Pressure: Credit rating dropped to 20, Borrowing costs increased 300%, Strategic financial management required
- Operational Continuity: All bases lost, Mobile command established, Emergency operations continued, Campaign preservation achieved

### Recovery System Scenarios
- Financial Rehabilitation: Bankruptcy restructuring completed, Debt reduced 40%, New funding secured, Economic stability restored
- Asset Redeployment: Destroyed facilities replaced, Production capacity restored, Strategic positioning improved, Operational continuity achieved
- Alliance Development: Former enemies allied, Mutual defense pact established, Combined operations initiated, Cooperative advantage gained
- Economic Restructuring: Black market eliminated, Legitimate income streams developed, Reputation restored (+30 fame), Ethical recovery completed
- Operational Redeployment: Forces redistributed, New bases established, Strategic advantage regained, Military repositioning successful

### Retirement System Cases
- Voluntary Conclusion: Campaign objectives achieved, Retirement selected, Legacy preserved, New campaign unlocked with improved conditions
- Achievement Completion: All victory conditions met, Automatic retirement triggered, Final statistics recorded, Narrative closure achieved
- Strategic Withdrawal: Irrecoverable position reached, Honorable retirement chosen, Accomplishments documented, Experience applied
- Legacy Preservation: Historical significance established, Future campaigns influenced, Character development completed, Long-term impact recorded
- Assessment Integration: Performance evaluated (85% success rate), Strategic assessment completed, Improved starting conditions granted

### Progress Tracking Examples
- Achievement Visualization: Territorial control 75% complete, 3 months remaining estimated, Strategic focus maintained, Progress bars displayed
- Forecasting Display: Research completion 60% progress, 8 months projected, Resource allocation optimized, Timeline forecasting active
- Real-Time Updates: Mission success milestone reached, Achievement progress advanced, Notification displayed, Immediate feedback provided
- Historical Recording: Timeline documented, Key events logged, Strategic decisions tracked, Provenance metadata maintained
- Strategic Guidance: Goal completion requirements displayed, Decision support provided, Planning assistance offered, User guidance enhanced
- User Customization: Personal objectives set, Custom challenges defined, Achievement preferences configured, Personalized experience created

## Related Wiki Pages

- [Geoscape.md](../geoscape/Geoscape.md) - Strategic objectives and campaign management.
- [Mission objectives.md](../battlescape/Mission%20objectives.md) - Mission completion and tactical goals.
- [Economy.md](../economy/Economy.md) - Economic goals and resource management.
- [Finance.md](../finance/Finance.md) - Financial systems and budgetary objectives.
- [Crafts.md](../crafts/Crafts.md) - Craft management and fleet objectives.
- [AI.md](../ai/AI.md) - AI objectives and strategic challenges.
- [Lore.md](../lore/Lore.md) - Story progression and narrative goals.
- [Research tree.md](../economy/Research%20tree.md) - Technology goals and advancement.
- [Basescape.md](../basescape/Basescape.md) - Base management and expansion goals.
- [SaveSystem.md](../technical/SaveSystem.md) - Progress tracking and achievement systems.

## References to Existing Games and Mechanics

- **Civilization Series**: Multiple victory conditions and achievement paths
- **X-COM Series**: Campaign progression with flexible objectives
- **Total War Series**: Various victory types and conquest goals
- **Crusader Kings III**: Dynasty goals and achievement system
- **Europa Universalis IV**: Achievement system and historical objectives
- **Stellaris**: Multiple victory conditions and endgame crises
- **Advance Wars**: Campaign objectives and mission completion
- **Fire Emblem Series**: Chapter completion and character survival
- **Final Fantasy Tactics**: Story progression and optional side quests
- **Tactics Ogre**: Conquest objectives and territorial control

