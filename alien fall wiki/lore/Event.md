# Event

## Table of Contents
- [Overview](#overview)
  - [Key Design Principles](#key-design-principles)
- [Mechanics](#mechanics)
  - [Event Occurrence and Sampling](#event-occurrence-and-sampling)
  - [Event Scope and Targeting](#event-scope-and-targeting)
  - [Event Effects and Durations](#event-effects-and-durations)
  - [Player Interaction and Choices](#player-interaction-and-choices)
  - [Event Determinism and Safety](#event-determinism-and-safety)
  - [Event Processing and Hooks](#event-processing-and-hooks)
- [Examples](#examples)
  - [Regional Boom Event](#regional-boom-event)
  - [Market Crash Event](#market-crash-event)
  - [Public Heroics Event](#public-heroics-event)
  - [Salvage Windfall Event](#salvage-windfall-event)
  - [Rival Raid Event](#rival-raid-event)
  - [Geomagnetic Storm Event](#geomagnetic-storm-event)
  - [Political Coup Event](#political-coup-event)
  - [Smuggler Proposition Event](#smuggler-proposition-event)
  - [Hostage Negotiation Event](#hostage-negotiation-event)
- [Related Wiki Pages](#related-wiki-pages)
- [References to Existing Games and Mechanics](#references-to-existing-games-and-mechanics)

## Overview

Events represent discrete, authorable occurrences within the campaign that introduce strategic variety and player choice. They function as controlled interruptions to the campaign flow, altering resources, spawning missions, or creating temporary modifiers that affect gameplay balance and pacing. Events are sampled deterministically by the calendar system and configured with scope, filters, and cooldowns to control frequency and impact. All randomness and target selection must be seeded and logged for reproducibility and transparency. Events often present player choices and should include clear mitigations for potentially game-blocking outcomes.

The event system serves as a director-like mechanism that shapes campaign narrative and difficulty curves while maintaining player agency through meaningful choices. Events bridge the gap between procedural generation and authored content, allowing designers to inject specific story moments, balance adjustments, or strategic challenges at appropriate campaign milestones.

### Key Design Principles

- Strategic Interruption: Controlled breaks in campaign flow with lasting consequences
- Player Agency: Meaningful choices that affect multiple game systems
- Deterministic Execution: Seeded randomization ensuring reproducible outcomes
- Data-Driven Design: All event parameters defined in external configuration files
- Safety Mechanisms: Mitigation options for potentially blocking outcomes
- Modding Support: Extensive customization through TOML-based configuration

## Mechanics

### Event Occurrence and Sampling

Monthly Sampling Process: Events are sampled at month boundaries by the calendar system, with a configurable limit on events per month (typically 3). Each event has a weight that determines selection probability, with higher weights increasing trigger likelihood.

Deterministic Selection: Event sampling uses seeded random number generation derived from the world seed and current month. This ensures identical seeds produce identical event sequences across playthroughs.

Cooldown Management: Events can specify cooldown periods in months, preventing repetition. Once triggered, an event cannot occur again until its cooldown expires.

Month Range Restrictions: Events can be restricted to specific campaign phases using minimum and maximum month parameters, allowing temporal progression of event types.

Frequency Controls: Per-campaign frequency weights allow fine-tuning of event distribution, with some events becoming more or less common as the campaign progresses.

### Event Scope and Targeting

Scope Levels: Events operate at four hierarchical scopes - global (affects entire campaign), country (affects specific nations), province (affects geographic regions), and base (affects individual installations).

Target Selection Filters: Events use filter criteria to select appropriate targets, including biome types (urban, rural, coastal), economic thresholds, base presence, and geographic constraints.

Radius-Based Targeting: Some events can target entities within a specified radius of a reference point, such as bases or provinces.

Filter Evaluation: Target selection respects boolean logic for filter combinations, allowing complex targeting rules like "coastal provinces with bases and high economy."

Fallback Handling: When no valid targets exist for an event's scope and filters, the event fails to trigger with appropriate logging.

### Event Effects and Durations

Effect Types: Events can modify any strategic domain including score, funding, fame, karma, cash reserves, resource stockpiles, research progress, quest states, unit/craft counts, province economy, biome characteristics, facility states, or spawn tactical/geoscape missions.

Duration Categories: Effects can be immediate (permanent changes), time-limited (specified in days), or conditional (persist until specific conditions are met).

Effect Chaining: Events can trigger follow-up events based on resolution outcomes, creating event chains that unfold over multiple months.

Resource Modification: Effects can add, subtract, or multiply resource values, with support for both absolute and percentage-based changes.

State Persistence: Temporary effects track expiration dates and automatically reverse when they expire.

### Player Interaction and Choices

Choice Presentation: Events with player choices display as notifications showing scope, magnitude, duration, and available options with costs and consequences.

Choice Costs: Options can require resource expenditures (cash, supplies) or other prerequisites before selection.

Deterministic Outcomes: All choice consequences are seeded and predictable, with clear risk/reward profiles.

Choice Conditions: Options can have prerequisites that must be met for availability, such as minimum resources or facility requirements.

Auto-Resolution: Events without choices resolve automatically using default effects.

### Event Determinism and Safety

Seeded Randomness: Any randomness within events (target selection, loot rolls, resource yields) uses deterministic seeds derived from world seed and event identifiers.

Named RNG Streams: Different event aspects use separate random streams to prevent cross-contamination of random sequences.

Provenance Logging: Events record complete decision history including seeds, targets, applied effects, and player choices for debugging and replay.

Blocking Prevention: Events with potentially game-breaking outcomes include mitigation options or display clear warnings about permanent consequences.

Recovery Paths: Blocking events provide explicit recovery mechanisms, such as time-limited windows for reversal or alternative resolution paths.

### Event Processing and Hooks

Lifecycle Hooks: Events support hooks for on_trigger (initial activation), on_resolve (completion), and per-choice hooks for scripted logic.

Daily Processing: Active events update daily to check effect expirations and trigger resolution when all effects complete.

Effect Expiration: Time-limited effects automatically reverse when their duration expires, with provenance logging.

Resolution Logic: Events resolve when all their effects expire or are manually cleared, triggering cleanup and follow-up effects.

Hook Execution: Hooks enable telemetry export, mission spawning coordination, and UI state management.

## Examples

### Regional Boom Event
Scope: Province-level economic enhancement
Trigger Conditions: Months 1-999, weight 2.0, requires province economy ≥50
Effects: 50% increase to province economy_value for 90 days
Impact: Increases monthly funding and local market stock availability
Design Purpose: Provides positive reinforcement for developed regions, encouraging economic investment

### Market Crash Event
Scope: Global economic disruption
Trigger Conditions: Months 6+, weight 1.0, 12-month cooldown
Effects: 20% reduction to market_price_multiplier for 30 days
Impact: Increases costs for all purchases while active
Design Purpose: Creates temporary economic pressure, testing player resource management

### Public Heroics Event
Scope: Country-level reputation boost
Trigger Conditions: Months 1-999, weight 3.0
Effects: +500 Score and +100 Fame for 30 days
Player Choice: Optional press release for additional +50 Fame at 10,000 cash cost
Design Purpose: Rewards aggressive playstyles with reputation benefits and optional cash investment

### Salvage Windfall Event
Scope: Base-level resource discovery
Trigger Conditions: Months 1-999, weight 4.0, requires base level ≥2
Effects: Grants 50 alien alloys and 5 elerium to target base
Impact: Immediate resource boost for base operations and research
Design Purpose: Provides random positive reinforcement for established bases

### Rival Raid Event
Scope: Province-level confrontation
Trigger Conditions: Months 1-999, weight 2.5
Effects: Spawns convoy_raid mission with region-scaled difficulty
Failure Consequences: -100 Score penalty on mission failure
Design Purpose: Creates tactical opportunities with strategic risk

### Geomagnetic Storm Event
Scope: Region-level detection disruption
Trigger Conditions: Months 3+, weight 1.5, 6-month cooldown
Effects: 70% radar efficiency reduction and 50% interception difficulty increase for 3 days
Impact: Temporarily blinds detection systems and increases interception challenges
Design Purpose: Creates windows of vulnerability requiring adaptive strategies

### Political Coup Event
Scope: Province-level governance crisis
Trigger Conditions: Months 12+, weight 1.0, requires province economy ≥75
Effects: Marks province as contested with 20% funding penalty for 60 days
Player Choice: Diplomatic intervention for 25,000 cash and 20 influence to stabilize
Design Purpose: Introduces political instability requiring resource investment to resolve

### Smuggler Proposition Event
Scope: Country-level black market opportunity
Trigger Conditions: Months 1-999, weight 2.0
Player Choices:
- Accept deal: Gain restricted weapon, lose 25 Karma, cost 50,000 cash
- Decline deal: Gain 10 Fame
Design Purpose: Presents moral choice between gear access and reputation cost

### Hostage Negotiation Event
Scope: Province-level crisis management
Trigger Conditions: Months 1-999, weight 1.8
Effects: Spawns hostage_rescue mission with 7-day time limit
Player Choices:
- Pay ransom: -50 Score, -15 Karma, cost 75,000 cash
- Attempt rescue: 20% difficulty increase to mission
Design Purpose: Forces prioritization between reputation preservation and operational risk

## Related Wiki Pages

- [Calendar.md](../lore/Calendar.md) - Event timing and scheduling.
- [Campaign.md](../lore/Campaign.md) - Campaign event integration.
- [Mission.md](../lore/Mission.md) - Event-spawned missions.
- [Faction.md](../lore/Faction.md) - Faction-specific events.
- [Geoscape.md](../geoscape/Geoscape.md) - Geoscape event effects.
- [Economy.md](../economy/Economy.md) - Economic event impacts.
- [Quest.md](../lore/Quest.md) - Event-triggered quests.
- [UFO Script.md](../lore/UFO%20Script.md) - UFO-related events.

## References to Existing Games and Mechanics

- **Civilization Series**: Random events and historical occurrences
- **Crusader Kings Series**: Character and realm events
- **Europa Universalis Series**: Historical events and diplomatic incidents
- **Total War Series**: Campaign events and historical battles
- **XCOM Series**: Council missions and global events
- **Fire Emblem Series**: Story events and character interactions
- **Final Fantasy Series**: Random encounters and plot events
- **Stellaris**: Random events and galactic occurrences
- **Hearts of Iron Series**: Historical events and diplomatic crises
- **Victoria Series**: Society events and political changes

