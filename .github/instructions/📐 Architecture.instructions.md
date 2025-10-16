# 📐 Architecture Best Practices for AlienFall

**Domain**: System Design & Architecture  
**Focus**: Diagrams, patterns, ECS, design structures  
**Version**: 1.0  
**Last Updated**: October 16, 2025

---

## Table of Contents

1. [Diagram Fundamentals](#diagram-fundamentals)
2. [Class Diagram Patterns](#class-diagram-patterns)
3. [Sequence Diagrams](#sequence-diagrams)
4. [Data Flow Diagrams](#data-flow-diagrams)
5. [Deployment Architecture](#deployment-architecture)
6. [System Architecture Patterns](#system-architecture-patterns)
7. [ECS Visualization](#ecs-visualization)
8. [State Machine Diagrams](#state-machine-diagrams)
9. [Game Loop Architecture](#game-loop-architecture)
10. [Multi-Layer Architecture](#multi-layer-architecture)
11. [Mermaid Best Practices](#mermaid-best-practices)
12. [Documentation & Maintenance](#documentation--maintenance)

---

## Diagram Fundamentals

### ✅ DO: Use Diagrams to Communicate

Visual representation aids understanding.

**When to Diagram:**

```
Use diagrams for:
- System architecture (how it's organized)
- Component relationships (what connects)
- Data flow (how data moves)
- State transitions (how state changes)
- Sequences (what happens in order)

Good diagram:
- Shows essential information
- Omits irrelevant details
- Is easy to understand
- Accurate to actual code
```

### ✅ DO: Keep Diagrams Simple

Fewer elements = clearer message.

**Diagram Simplicity:**

```
TOO COMPLEX:
Every class, every method, all relationships
→ Diagram is unreadable maze

JUST RIGHT:
Main components, key relationships
→ Clear picture of architecture

Test: Can someone understand in 30 seconds?
If no: Simplify further
```

---

## Class Diagram Patterns

### ✅ DO: Model Core Relationships

Show how classes connect.

**Class Diagram Example:**

```
┌─────────────────┐
│     Entity      │
├─────────────────┤
│ + id: int       │
│ + position: Vec │
├─────────────────┤
│ + update(dt)    │
│ + draw()        │
└────────┬────────┘
         △
         │
    ┌────┴─────┬────────────┐
    │           │            │
┌───────────┐ ┌────────┐ ┌──────────┐
│   Unit    │ │ Weapon │ │Terrain   │
├───────────┤ ├────────┤ ├──────────┤
│ + health  │ │+damage │ │+blocking │
│ + name    │ │+ammo   │ │+passable │
├───────────┤ ├────────┤ ├──────────┤
│ + attack()│ │+fire() │ │+getProps()
└───────────┘ └────────┘ └──────────┘
    │            △
    │            │ uses
    └────────────┘

Inheritance shown with △
Relationships shown with arrows
```

### ✅ DO: Show Composition vs Aggregation

Difference in ownership.

**Composition vs Aggregation:**

```
Composition (strong ownership):
Team ◆──── Unit
Team owns units (units die with team)

Aggregation (weak ownership):
Player ○──── Unit
Player manages units (units survive if dismissed)

Implementation difference:
Composition: @property units (created, destroyed together)
Aggregation: @ref units (can exist separately)

Use correctly for accurate diagrams
```

---

## Sequence Diagrams

### ✅ DO: Show Interaction Sequences

Document how components communicate.

**Sequence Diagram Example:**

```
Player      UI         Combat      Target
  │          │            │          │
  │─Click──→ │            │          │
  │          │─validate──→│          │
  │          │            │─check───→│
  │          │            │←accept───│
  │          │←roll dice──│          │
  │          │            │          │
  │          │─update────→│          │
  │←Display──│            │          │

Timeline shown top to bottom
Objects across top
Messages between with arrows
```

### ✅ DO: Document Critical Flows

Show complex interactions.

**Critical Flow Examples:**

```
Combat Flow:
Player chooses target
→ System validates action
→ Calculate hit chance
→ Roll dice
→ Apply damage
→ Trigger death if needed
→ Update UI

Each sequence shows:
- Who initiates (Player/System)
- What happens (action)
- Verification (validate)
- Result (outcome)
```

---

## Data Flow Diagrams

### ✅ DO: Show How Data Moves

Track information flow.

**Data Flow Diagram:**

```
┌──────────┐
│  Player  │
│  Input   │
└────┬─────┘
     │
     ▼
┌──────────────┐
│ Input        │
│ Handler      │ (Processes input)
└────┬─────────┘
     │
     ▼
┌──────────────┐
│ Game         │ (Updates game state)
│ Logic        │
└────┬─────────┘
     │
     ▼
┌──────────────┐
│ Render       │ (Converts state to visuals)
│ System       │
└────┬─────────┘
     │
     ▼
┌──────────────┐
│ Screen       │ (Display to player)
│ Output       │
└──────────────┘

Data flows one direction
Clear transformation at each step
```

---

## Deployment Architecture

### ✅ DO: Show Physical Deployment

How systems are deployed.

**Deployment Diagram:**

```
Developer Machine:
┌────────────────────────────┐
│ VS Code                    │
│ ├── engine/ (Lua source)   │
│ ├── tests/                 │
│ ├── assets/                │
│ └── mods/                  │
└────────────────────────────┘
            │
            │ (Git push)
            ▼
┌────────────────────────────┐
│ GitHub Repository          │
│ ├── main branch            │
│ ├── develop branch         │
│ └── releases/              │
└────────────────────────────┘
            │
            │ (CI/CD)
            ▼
┌────────────────────────────┐
│ Build Server               │
│ ├── Lint                   │
│ ├── Test                   │
│ ├── Build                  │
│ └── Release                │
└────────────────────────────┘
            │
            ▼
┌────────────────────────────┐
│ Distribution               │
│ ├── Steam                  │
│ ├── Itch.io                │
│ └── Direct Download        │
└────────────────────────────┘
```

---

## System Architecture Patterns

### ✅ DO: Document Layered Architecture

Separation of concerns.

**Layered Architecture:**

```
┌─────────────────────────────────────┐
│     Presentation Layer              │
│  (UI, Graphics, User Interaction)   │
├─────────────────────────────────────┤
│     Business Logic Layer            │
│  (Game Rules, Combat, Progression)  │
├─────────────────────────────────────┤
│     Data Access Layer               │
│  (Save/Load, Database, Config)      │
├─────────────────────────────────────┤
│     Infrastructure Layer            │
│  (Networking, Logging, Filesystem)  │
└─────────────────────────────────────┘

Each layer depends on layers below
Each layer independent of layers above
```

### ✅ DO: Show Module Dependencies

Map out code structure.

**Dependency Diagram:**

```
Core Systems:
├── StateManager
│   └── (manages game states)
├── EventBus
│   └── (broadcasts events)
└── EntityManager
    └── (manages entities)

Combat System:
├── DamageCalculator
├── TurnSystem
└── Depends on: Core Systems

Graphics System:
├── Renderer
├── Camera
└── Depends on: EntityManager

UI System:
├── UIManager
├── Widgets
└── Depends on: Graphics, EventBus

Circular dependencies: BAD
Clear dependency flow: GOOD
```

---

## ECS Visualization

### ✅ DO: Diagram Component Architecture

Show ECS structure.

**ECS Architecture:**

```
┌──────────────────────────────────┐
│         Entity Manager           │
│ (Manages all entities)           │
└──────────────────┬───────────────┘
                   │
        ┌──────────┴──────────┐
        │                     │
    ┌───▼─────┐        ┌─────▼───┐
    │ Entities│        │Components
    │  (IDs)  │        │  (Data)
    └─────────┘        └────┬────┘
        │                   │
        │          ┌────────┼────────┐
        │          │        │        │
        │      Position  Health   Sprite
        │      (x, y)    (HP)   (Image)
        │
    ┌───▼──────────────────────────┐
    │     Systems (Logic)          │
    ├──────────────────────────────┤
    │ MovementSystem (uses Position)
    │ CombatSystem (uses Health)
    │ RenderSystem (uses Sprite)
    └──────────────────────────────┘

Clear separation:
- Entities = Collections
- Components = Data
- Systems = Logic
```

---

## State Machine Diagrams

### ✅ DO: Diagram State Transitions

Show valid state changes.

**Game State Machine:**

```
        ┌─────────────────┐
        │   MainMenu      │
        └────────┬────────┘
                 │ [New Game]
                 ▼
        ┌─────────────────┐
    ┌─→ │   Campaign      │ ←─┐
    │   └────────┬────────┘   │
    │            │            │
    │    ┌───────┴────────┐   │
    │    │                │   │
    │    ▼                ▼   │
    │ ┌──────────┐   ┌─────────────┐
    └─│Geoscape  │   │ Battlescape │─┐
      └──────────┘   └─────────────┘ │
         ▲               │           │
         │               │           │
         └───────────────┴───────────┘
               [Mission Complete]

Valid transitions shown
Invalid transitions not shown
```

---

## Game Loop Architecture

### ✅ DO: Document Game Loop

Show update/draw cycle.

**Game Loop Pattern:**

```
┌────────────────────────────────┐
│      love.load()               │
│ (Initialize everything)        │
└───────────────┬────────────────┘
                │
                ▼
        ┌──────────────────┐
        │   Main Loop      │
        │ (Runs every frame)
        └────────┬─────────┘
                 │
        ┌────────▼─────────┐
        │  Input handling  │
        │  (Process events)
        └────────┬─────────┘
                 │
        ┌────────▼─────────┐
        │  Update (dt)     │
        │  (Game logic)
        └────────┬─────────┘
                 │
        ┌────────▼─────────┐
        │  Draw ()         │
        │  (Render)
        └────────┬─────────┘
                 │
        ┌────────▼─────────┐
        │  Display         │
        │  (Show to player)
        └────────┬─────────┘
                 │
        Loop back to Input
```

---

## Multi-Layer Architecture

### ✅ DO: Show Feature Layers

Different gameplay systems.

**Geoscape → Battlescape Architecture:**

```
┌───────────────────────────────────────┐
│         Game Manager                  │
│  (Orchestrates everything)            │
└───────────────┬───────────────────────┘
                │
        ┌───────┴────────┐
        │                │
    ┌───▼────────┐   ┌──▼──────────┐
    │ Geoscape   │   │ Battlescape │
    │ Layer      │   │ Layer       │
    ├────────────┤   ├─────────────┤
    │World Map   │   │ Tactical Map│
    │Regions     │   │ Turn System │
    │Nations     │   │ Combat      │
    │Missions    │   │ AI          │
    └────────────┘   └─────────────┘
        │                   │
        │    [Launch]       │
        ├──────────────────→│
        │    [Return]       │
        │←──────────────────┤
        │                   │

Geoscape launches Battlescape
When mission complete, return to Geoscape
Each layer independent
```

---

## Mermaid Best Practices

### ✅ DO: Use Mermaid for Diagrams

Easy to create and version control.

**Mermaid Syntax:**

```mermaid
graph TD
    A[Player Input] -->|Click| B[UI Handler]
    B -->|Validate| C{Valid Action?}
    C -->|Yes| D[Execute Action]
    C -->|No| E[Show Error]
    D --> F[Update Game State]
    E --> F
    F --> G[Render]

This creates a flowchart
Syntax is simple
Can be embedded in markdown
```

### ✅ DO: Document Complex Systems

Make architecture visible.

**System Diagram:**

```
AllSystems should have:
1. High-level overview (what is it?)
2. Component diagram (what parts?)
3. Sequence diagram (how does it work?)
4. State machine (what states?)
5. Example workflow (real scenario)

Together these explain the system
```

---

## Documentation & Maintenance

### ✅ DO: Keep Diagrams Updated

Diagrams out of sync = misinformation.

**Diagram Maintenance:**

```
When architecture changes:
1. Update diagram (same day)
2. Add comment explaining change
3. Link to commit/PR
4. Test that diagram still makes sense

Version diagrams with code:
- In same git repo
- Track changes in git history
- Can see when changed and why

Update frequency:
- Major changes: Update immediately
- Minor changes: Update within sprint
- Never: Let diagrams rot
```

### ✅ DO: Provide Context

Diagrams need explanation.

**Documentation Pattern:**

```
Architecture Section:

[High-level diagram]

**Overview**: 2-3 sentence explanation

**Components**:
- Component A: Purpose, responsibility
- Component B: Purpose, responsibility

**Data Flow**:
- Step 1: What happens
- Step 2: What happens

**Example Scenario**:
"When player clicks combat button..."

**See Also**:
- Detailed implementation: engine/combat/
- Related systems: Game Loop Architecture
```

---

## Common Architecture Patterns

### MVC Pattern (for UI)

```
Model (Data)
  ↕ (read/update)
View (Display)
  ↔
Controller (Input)

User interacts with View
View updates Model
Model notifies View of changes
```

### Observer Pattern (for Events)

```
Publisher (emits events)
   │
   ├─→ Subscriber A (listens)
   ├─→ Subscriber B (listens)
   └─→ Subscriber C (listens)

When event fires:
All subscribers notified
Decoupled communication
```

### Factory Pattern (for Creation)

```
Factory (creates objects)
   │
   ├─→ Unit
   ├─→ Weapon
   ├─→ Ability
   └─→ Item

Central creation point
Consistent initialization
Easy to modify creation logic
```

---

## Reference Architecture

### Recommended AlienFall Structure

```
┌─────────────────────────────────────────┐
│         Game Application                │
│  (main.lua - Entry point)               │
└────────────────────┬────────────────────┘
                     │
        ┌────────────┴──────────────┐
        │                           │
    ┌───▼──────┐            ┌──────▼────┐
    │ Core     │            │ Content    │
    │ Systems  │            │ Layers     │
    ├──────────┤            ├───────────┤
    │State Mgr │            │Geoscape   │
    │Event Bus │            │Battlescape│
    │Entity    │            │Base Mgmt  │
    │Manager   │            │Research   │
    └──────────┘            └───────────┘
        │                           │
        │         ┌─────────────────┤
        │         │                 │
    ┌───▼─────────▼───┐   ┌────────▼─────┐
    │ Systems         │   │ Graphics/UI  │
    │ (Combat, etc)   │   │ (Rendering)  │
    ├─────────────────┤   ├──────────────┤
    │Movement System  │   │Renderer      │
    │Combat System    │   │UI Manager    │
    │AI System        │   │Camera        │
    └────────────────┘    └──────────────┘

Clear separation of concerns
Easy to understand
Easy to maintain
```

---

**Version**: 1.0  
**Last Updated**: October 16, 2025  
**Status**: Active Best Practice Guide

*For specific system architectures, see engine/ documentation*
