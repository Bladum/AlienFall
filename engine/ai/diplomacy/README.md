# Diplomacy AI

## Goal / Purpose

The Diplomacy AI folder contains artificial intelligence systems for managing NPC diplomatic interactions, faction relationships, and political decision-making. This includes diplomatic negotiation logic, relationship tracking, and faction-based AI decision trees.

## Content

- Diplomatic AI modules for faction-to-faction interactions
- Relationship state management and negotiation logic
- Faction preference and alliance decision systems

## Features

- **Faction Diplomacy**: AI-driven negotiation between factions
- **Relationship Management**: Track and evolve faction relationships over time
- **Political Positioning**: Factions pursue strategic political objectives
- **Trade Negotiation**: AI handles economic agreements and black market dealings
- **Alliance Formation**: Dynamic alliance and enemy faction calculations
- **Reputation System**: Actions affect diplomatic standing
- **Betrayal Logic**: Factions may break agreements based on conditions

## Integrations with Other Systems

### Politics System
- Provides AI decision-making for `engine/politics/`
- Influences political events and government changes
- Affects government relations and support

### Geoscape
- Diplomatic events trigger geoscape events
- Faction relationships affect mission availability
- Political standing impacts regional control

### Economy System
- Affects trade routes and black market prices
- Influences supplier relationships and pricing
- Impacts research availability and costs

### AI Strategic Planning
- Part of the larger `engine/ai/` tactical decision system
- Influences strategic mission selection
- Affects alien faction behavior on geoscape

## See Also

- [Politics README](../../politics/README.md) - Political system and government management
- [Geoscape README](../../geoscape/README.md) - World map and faction presence
- [AI Systems README](../README.md) - Main AI systems overview
- [Economy README](../../economy/README.md) - Economic systems
