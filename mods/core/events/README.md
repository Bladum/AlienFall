# Campaign Events Subsystem

**Purpose:** Defines strategic campaign events that affect game state and trigger missions

**Layer:** Strategic (Geoscape)

**Parent:** Geoscape

## Contents

This folder contains campaign event definitions:
- Event type definitions with triggers
- Event effects and consequences
- Positive events (research breakthroughs, opportunities)
- Negative events (terror attacks, crises)
- Event chains and sequencing
- Availability and probability rules

## Key Components

- **Event Definition:** Core event structure
- **Triggers:** Conditions for event activation
- **Effects:** Consequences and state changes
- **Duration:** Event lifespan and persistence
- **Chaining:** Relation to other events

## Dependencies

- Depends on: `geoscape` (campaign system), `missions` (event-triggered missions)
- Used by: Campaign event manager, turn resolution

## Architecture Notes

- Events triggered based on game conditions
- Effects can modify game state directly
- Events can chain to create sequences
- Probability determines occurrence likelihood
- Duration controls when event expires
- Some events are blockable by player choice

## Available Event Types

### Current Events
- `event_research_breakthrough.toml` - Positive research event
- `event_terror_attack.toml` - Negative military event
- `event_economic_boost.toml` - Positive economy event

### Event Categories
- **Positive:** Research, Economy, Military Successes
- **Negative:** Terror Attacks, Crises, Losses
- **Neutral:** Encounters, Discoveries

### Future Events
Additional event types can be added following the same template format.

## Event Chains

Some events trigger other events:
- Research Breakthrough → Tech Unlock → Military Advantage
- Terror Attack → Panic Spiral → Additional Attacks
- Economic Opportunity → Expansion → New Facilities

## See Also

- `api/EVENTS.md` - Event API documentation
- `design/events/` - Event design documentation
- `mods/core/campaigns/` - Campaign definitions (event availability)
