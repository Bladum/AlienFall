# Guides and Reference Documentation

This folder contains evergreen reference documentation and tutorials for the Alien Fall project - an XCOM-inspired turn-based strategy game built with Love2D and Lua.

---

## Quick Start

| I want to... | Read this guide |
|--------------|----------------|
| Learn Lua coding standards | [LUA_STYLE_GUIDE.md](LUA_STYLE_GUIDE.md) |
| Understand XCOM-style game design | [XCOM_DESIGN_PATTERNS.md](XCOM_DESIGN_PATTERNS.md) |
| Create mods like OpenXCOM | [MODDING_TUTORIAL.md](MODDING_TUTORIAL.md) |
| Optimize game performance | [LOVE2D_PERFORMANCE.md](LOVE2D_PERFORMANCE.md) |
| Look up API functions | [API_DOCUMENTATION.md](API_DOCUMENTATION.md) |
| Understand system architecture | [ARCHITECTURE_DIAGRAMS.md](ARCHITECTURE_DIAGRAMS.md) |
| Implement input handling | [INPUT_BUFFER_GUIDE.md](INPUT_BUFFER_GUIDE.md) |

---

## Lua & Love2D Technical Guides

### Core Development

#### [LUA_STYLE_GUIDE.md](LUA_STYLE_GUIDE.md)
Official coding standards for the Alien Fall project.

**Topics Covered:**
- Naming conventions (camelCase, snake_case, UPPER_CASE)
- Middleclass OOP patterns
- Love2D-specific patterns (callbacks, asset management, pixel-perfect rendering)
- Game architecture patterns (ECS, state machines, event buses)
- Turn-based game loops and deterministic RNG
- Error handling and defensive programming
- File organization and documentation standards

**When to Use:** Before writing any code, review this guide to ensure consistency with project standards.

---

#### [LOVE2D_PERFORMANCE.md](LOVE2D_PERFORMANCE.md)
Comprehensive performance optimization guide for Love2D games.

**Topics Covered:**
- Performance cache system (LRU caching for pathfinding, LOS, detection)
- Object pooling (projectiles, particles, UI elements)
- Rendering optimization (batching, canvas caching, culling)
- Memory management (GC control, profiling)
- Hot path optimization (micro-optimizations, table reuse)
- Turn-based game optimizations (deferred updates, update scheduling)

**When to Use:** When optimizing AI turns, rendering large maps, or reducing memory footprint.

**Consolidates:** Previously separate guides PERFORMANCE_OPTIMIZATION.md and OBJECT_POOLING_GUIDE.md

---

#### [INPUT_BUFFER_GUIDE.md](INPUT_BUFFER_GUIDE.md)
Input buffer system to prevent missed inputs during lag spikes.

**Topics Covered:**
- Separate keyboard and mouse buffers
- Priority system (high, normal, low priority inputs)
- Age tracking and stale input expiration
- Integration with Love2D callbacks
- Screen/handler implementation patterns

**When to Use:** When implementing input handling in game screens to ensure responsive controls.

---

### API & Architecture Reference

#### [API_DOCUMENTATION.md](API_DOCUMENTATION.md)
Complete API reference for all game systems.

**Sections:**
- Core Systems (Service Registry, Event Bus)
- Engine Services (RNG, Asset Cache, Save/Load)
- Geoscape Systems (World, Province, Mission Scheduler)
- Battlescape Systems (Pathfinding, Line-of-Sight, Combat)
- UI Widgets (Button, Table, Tooltip, Combobox)
- Utility Functions (Math helpers, Safe I/O)
- Modding API (Mod Loader, Hooks, Content Merger)

**When to Use:** As reference when calling game systems or implementing new features.

---

#### [ARCHITECTURE_DIAGRAMS.md](ARCHITECTURE_DIAGRAMS.md)
Mermaid diagrams showing system architecture and data flow.

**Diagrams:**
- High-level system overview
- Service dependencies
- Game state machine
- Data flow diagrams
- Class hierarchies
- Combat system flow
- Mod loading pipeline

**When to Use:** To visualize system interactions and understand overall architecture.

---

## Game Design Guides

### XCOM-Inspired Strategy Design

#### [XCOM_DESIGN_PATTERNS.md](XCOM_DESIGN_PATTERNS.md)
Core design patterns from the XCOM series and OpenXCOM.

**Topics Covered:**
- **Strategic Layer (Geoscape):** Time management, global threat system, interception mechanics, detection/radar
- **Tactical Layer (Battlescape):** Action point system, reaction fire, fog of war, cover system, morale/panic
- **Research & Technology:** Tech trees, alien autopsies, prerequisite chains
- **Base Management:** Facility construction, personnel management, adjacency bonuses
- **Resource Economy:** Monthly funding, manufacturing, selling loot
- **Mission Generation:** UFO activity simulation, dynamic difficulty scaling
- **Permanent Consequences:** Permadeath, campaign failure conditions

**When to Use:** When designing game systems, balancing mechanics, or understanding XCOM-style gameplay loops.

**References:** Includes comparisons to OpenXCOM implementation details and design philosophies.

---

### Modding System

#### [MODDING_TUTORIAL.md](MODDING_TUTORIAL.md)
Complete modding tutorial from beginner to advanced.

**Topics Covered:**
- **Getting Started:** Mod structure, TOML vs YAML, OpenXCOM comparisons
- **Basic Modding:** Units, items, missions, facilities, research
- **OpenXCOM-Style Content:** Research trees with prerequisites, manufacturing system, tech progression
- **Advanced Modding:** Lua hooks, custom scripts, data validation
- **Testing & Debugging:** Console commands, logging, common issues
- **Publishing:** Distribution, versioning, documentation

**When to Use:** When creating custom content or total conversion mods.

**OpenXCOM Integration:** Explains differences between OpenXCOM's YAML rulesets and Alien Fall's TOML system, with side-by-side examples.

---

## Document Maintenance

### Update Checklist

These documents should be updated when:

- ✅ New systems are added to the codebase
- ✅ API changes are made (update API_DOCUMENTATION.md)
- ✅ Best practices evolve (update LUA_STYLE_GUIDE.md)
- ✅ New modding capabilities are added (update MODDING_TUTORIAL.md)
- ✅ Performance improvements are implemented (update LOVE2D_PERFORMANCE.md)
- ✅ Architecture changes (update ARCHITECTURE_DIAGRAMS.md)

### Style Conventions

All guides follow these conventions:

- **Version number** in header (semantic versioning)
- **Last Updated** date in header
- **Table of Contents** for documents > 200 lines
- **Code examples** with syntax highlighting
- **Cross-references** to related guides
- **Tags** at bottom for searchability

---

## Future Documentation

### Planned Guides

See **[SUGGESTED_GUIDES.md](SUGGESTED_GUIDES.md)** for a comprehensive list of recommended guides to create, including:

**High Priority:**
- Save System Guide (serialization, versioning, migration)
- State Management Guide (screen transitions, game states)
- Data Validation Guide (TOML validation, schemas)
- Testing Guide (unit tests, mocking, deterministic testing)
- ECS Implementation Guide (entity component system patterns)

**Medium Priority:**
- Audio System, Localization, Particle Systems, Camera, Animation

**Specialized:**
- Pathfinding Deep Dive, Line of Sight, AI Decision Making, Procedural Generation

**Workflow:**
- Debugging Guide, Git Workflow, Release Checklist, Contributor Guide

---

## Related Documentation

- **Project Overview:** See `../README.md` for high-level project information
- **Development Guide:** See `../DEVELOPMENT.md` for setup and workflow
- **Implementation Details:** See `../../wiki/` for system-specific documentation
- **Mod Examples:** See `../../mods/example_mod/` for working mod templates
- **Guide Suggestions:** See `SUGGESTED_GUIDES.md` for planned documentation

---

## Tags

`#guides` `#documentation` `#lua` `#love2d` `#xcom` `#openxcom` `#modding` `#game-design` `#performance` `#api-reference`
