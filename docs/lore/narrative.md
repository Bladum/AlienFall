# Lore System

> **Implementation**: `engine/lore/`, `engine/core/`
> **Tests**: `tests/lore/`
> **Related**: `docs/core/README.md`, `docs/geoscape/missions.md`

Narrative framework and world-building system integrating story with gameplay mechanics.

## 📖 Lore Architecture

### Core Concepts
Fundamental narrative elements driving the game world.

**Narrative Elements:**
- **Campaign**: Long-term story arc spanning years of gameplay
- **Faction**: Organized groups with distinct motivations and technologies
- **Mission**: Discrete tactical operations with specific objectives
- **Quest**: Narrative-driven objectives tied to faction lore
- **Event**: Time-sensitive occurrences affecting the world
- **Calendar**: Unified timeline governing all world activities

### Mission Categories
Different operation types with unique narrative and tactical implications.

**Mission Types:**
- **UFO Missions**: Aerial interception of alien spacecraft
- **Site Missions**: Investigation of crash sites and terror incidents
- **Base Missions**: Assault on established alien installations

## 🎭 Narrative Systems

### Script Control
Automated systems managing dynamic world events and AI behavior.

**Script Types:**
- **UFO Behavior**: Flight paths, combat tactics, evasion, crash generation
- **Base Growth**: Facility expansion, defense deployment, research progression
- **Difficulty Scaling**: Adaptive challenge based on player performance

### System Integration
Interconnected mechanics creating emergent narrative experiences.

**Integration Flow:**
- **Campaign Phases**: Determine active factions and story progression
- **Faction Activity**: Generate appropriate mission types and events
- **Mission Completion**: Provide research and advance campaign state
- **Research Impact**: Unlock new capabilities and remove factions

## 🎮 Player Experience

### Narrative Integration
- **Campaign Progression**: Story advancement through mission completion
- **Faction Dynamics**: Relationships affect available missions and allies
- **Event Response**: Time-sensitive decisions impact narrative outcomes
- **Lore Discovery**: Missions reveal story elements and world background

### Strategic Narrative
- **Long-term Planning**: Campaign goals influence tactical decisions
- **Faction Management**: Diplomatic choices affect story possibilities
- **Event Timing**: Strategic timing of operations for narrative impact
- **Research Synergy**: Technology advancement drives story progression

### Lore Challenges
- **Time Pressure**: Events require timely response for optimal outcomes
- **Faction Complexity**: Multiple relationships to manage simultaneously
- **Campaign Pacing**: Balance immediate missions with long-term goals
- **Narrative Branching**: Player choices affect story development

## 📊 Lore Balance

### Difficulty Scaling
- **Rookie**: Simple narrative, generous time limits, clear objectives
- **Veteran**: Standard story complexity and event timing
- **Commander**: Complex narratives, tight deadlines, ambiguous objectives
- **Legend**: Intricate storylines, critical timing, high-stakes decisions

### Integration Points
- **Geoscape**: World events drive mission generation and faction activity
- **Battlescape**: Tactical outcomes affect narrative progression
- **Research**: Technology discoveries advance campaign and unlock lore
- **Progression**: Organization growth influences available story elements

### Balance Considerations
- **Pacing Control**: Narrative progression matches player advancement
- **Choice Impact**: Player decisions meaningfully affect story outcomes
- **Replayability**: Multiple paths through campaign and faction interactions
- **Immersion**: Lore integration enhances gameplay without overwhelming mechanics