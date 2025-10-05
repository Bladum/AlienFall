# Quest

## Table of Contents
- [Overview](#overview)
  - [Key Design Principles](#key-design-principles)
- [Mechanics](#mechanics)
  - [Quest Definition and Lifecycle](#quest-definition-and-lifecycle)
  - [Quest Triggers and Effects](#quest-triggers-and-effects)
  - [Quest Weighting and Campaign Progress](#quest-weighting-and-campaign-progress)
  - [Quest Prerequisite Semantics and Gating](#quest-prerequisite-semantics-and-gating)
  - [Quest Optionality, Failure and Permanence](#quest-optionality,-failure-and-permanence)
  - [Quest Data, Determinism and Moddability](#quest-data,-determinism-and-moddability)
  - [Quest Integration, UI and Telemetry](#quest-integration,-ui-and-telemetry)
- [Examples](#examples)
  - [First Alien Captured Quest](#first-alien-captured-quest)
  - [Mastermind Revealed Quest](#mastermind-revealed-quest)
  - [Design Tuning Notes](#design-tuning-notes)
- [Related Wiki Pages](#related-wiki-pages)
- [References to Existing Games and Mechanics](#references-to-existing-games-and-mechanics)

## Overview

Quests represent lightweight, persistent narrative flags designed to gate story beats, unlock content, and record campaign milestones. Each quest maintains a simple lifecycle (created → in-progress → completed) and can trigger or unlock research, missions, or suppliers. Designers control campaign pacing through quest weights without heavy mechanical overhead. Quest definitions are data-driven and emit provenance for deterministic testing.

The quest system serves as a narrative scaffolding that connects player actions to campaign progression, providing structured milestones while maintaining flexibility for emergent storytelling.

### Key Design Principles

- Lightweight Implementation: Simple state machines avoiding complex quest UI
- Narrative Gating: Story beat sequencing through prerequisite systems
- Progress Tracking: Weighted milestones for campaign advancement
- Data-Driven Design: TOML configuration for extensive modding support
- Deterministic Execution: Seeded randomization ensuring reproducible outcomes

## Mechanics

### Quest Definition and Lifecycle

Canonical States: Quests maintain three primary states - created (available but not started), in-progress (actively being worked toward), and completed (permanently finished).

Persistent Flags: Quest completion remains permanent for the save, creating lasting campaign state changes.

Progress Objects: Quests can track progress values (0-100%) for objectives requiring multiple steps or extended completion.

Lifecycle Metadata: Quests record start days, completion days, trigger sources, and current progress for UI and telemetry purposes.

### Quest Triggers and Effects

Trigger Types: Quests activate through research completion, mission outcomes, item analysis, scripted story moments, or event choices.

Immediate Effects: Quest completion can instantly unlock research entries, enable suppliers, spawn missions, or modify world state.

Delayed Effects: Quests support scheduled effects that apply after completion delays, enabling timed world state changes.

Hook Integration: Quests provide lifecycle hooks (on_quest_start, on_quest_complete, on_quest_fail) for telemetry and scripted logic.

### Quest Weighting and Campaign Progress

Progress Weights: Each quest contributes a numeric weight to end-game or epilogue progress calculation.

Campaign Total: The system defines a maximum quest weight representing total possible progress across all quests.

Progress Accumulation: Completed quest weights sum toward current campaign progress percentage.

Milestone Design: Designers use larger weights for campaign-defining quests and smaller weights for optional side content.

### Quest Prerequisite Semantics and Gating

Cross-System Prerequisites: Quests and research serve as interchangeable prerequisites for game content gating.

Prerequisite Evaluation: Systems accept either quest completion or research completion for conditional logic checks.

Narrative vs Mechanical Gating: Quests handle soft narrative gating while research manages strict mechanical unlocks.

Prerequisite Flexibility: Prerequisites support quest completion, research completion, mission completion, item acquisition, and custom conditions.

### Quest Optionality, Failure and Permanence

Optional Design: Most quests are recommended but not mandatory, allowing player choice in campaign focus.

Failure Handling: Quests can fail through time limits or probability checks, with optional failure effects.

Permanent Completion: Successful quest completion creates irreversible campaign state changes.

Branching Potential: Failed quests may influence future sampling or enable alternative story branches.

### Quest Data, Determinism and Moddability

TOML Definitions: Quest templates authored as data files with triggers, weights, rewards, effects, and failure conditions.

Seeded Randomness: Any quest randomness uses deterministic seeds with named streams for reproducible outcomes.

Lifecycle Hooks: Designer and mod access through on_quest_start, on_quest_complete, and on_quest_fail hooks.

Template Pluggability: Quest definitions designed as versioned, replaceable components for modding support.

### Quest Integration, UI and Telemetry

System Queries: Quests expose state checks to Campaign, Events, Research, and Mission systems for prerequisite evaluation.

UI Presentation: Quest state, weights, rewards, and provenance displayed in player interfaces.

Provenance Emission: Quest events logged with tick identifiers, trigger sources, and seed usage for debugging.

Telemetry Integration: Quest completion and progression data included in campaign analytics and replay systems.

## Examples

### First Alien Captured Quest
Trigger: Successful delivery of live alien to base holding facility
Reward: Research entry unlock for alien_interrogation
Weight: 4 (early campaign milestone)
Purpose: Gates interrogation technology and represents initial breakthrough

### Mastermind Revealed Quest
Trigger: Completion of final-arc research or scripted reveal
Reward: Final mission unlock
Weight: 40 (campaign-defining milestone)
Purpose: Represents campaign climax with maximum progress contribution

### Design Tuning Notes
Weight Scaling: Use smaller weights (1-5) for optional side stories and large weights (20-50) for campaign milestones to shape player pacing and perceived importance.

Progress Shaping: Weight distribution influences how players prioritize different quest lines and perceive campaign advancement.

Milestone Identification: High-weight quests should represent significant narrative or mechanical breakthroughs.

## Related Wiki Pages

- [Campaign.md](../lore/Campaign.md) - Quest campaign integration and progression.
- [Mission.md](../lore/Mission.md) - Quest mission triggers and objectives.
- [Event.md](../lore/Event.md) - Quest event triggers and unlocks.
- [Faction.md](../lore/Faction.md) - Quest faction story progression.
- [Calendar.md](../lore/Calendar.md) - Quest timing and scheduling.
- [Research tree.md](../economy/Research%20tree.md) - Quest research unlocks.
- [Lore items.md](../items/Lore%20items.md) - Quest item rewards and discoveries.
- [Pedia.md](../pedia/Pedia.md) - Quest documentation and codex entries.

## References to Existing Games and Mechanics

- **The Elder Scrolls Series**: Main quest and side quest structures
- **Dragon Age Series**: Quest and companion story progression
- **Mass Effect Series**: Mission and quest advancement systems
- **Fallout Series**: Quest variety and player choice consequences
- **The Witcher Series**: Quest branches and story decisions
- **Deus Ex Series**: Quest objectives and branching narratives
- **Metal Gear Solid Series**: Story mission progression and reveals
- **Assassin's Creed Series**: Main storyline quest progression
- **Final Fantasy Series**: Story quest and character development
- **Kingdom Hearts Series**: Quest structure and world progression

