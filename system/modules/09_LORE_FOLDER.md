# Lore Folder - Game World & Narrative

**Purpose:** Store game world lore, backstory, and narrative context  
**Audience:** Writers, designers, content creators, players  
**Format:** Markdown documents + images

---

## What Goes in lore/

### Structure
```
lore/
├── README.md                    Lore documentation overview
│
├── story/                       Main narrative
│   ├── timeline.md             Historical timeline
│   ├── setting.md              World setting overview
│   ├── factions.md             Major factions and organizations
│   ├── conflicts.md            Current conflicts and tensions
│   └── characters.md           Major characters and personalities
│
└── images/                      Lore-related images
    ├── maps/                   World maps
    ├── faction_logos/          Faction symbols
    └── concept_art/            Concept artwork
```

---

## Core Principle: Context for Design

**Lore provides the "why" behind game mechanics:**

```
Lore explains:
- Why factions exist (political context)
- Why conflicts happen (motivations)
- Why technologies work (setting rules)
- Why locations matter (historical significance)

Design uses lore:
- Faction units have lore-appropriate abilities
- Technologies follow lore constraints
- Missions reflect lore conflicts
- Locations based on lore geography
```

**Key Rule:** Lore serves the game, game doesn't serve lore. Lore provides context and flavor, not rigid constraints.

---

## Content Guidelines

### What Belongs Here
- ✅ World setting and background
- ✅ Faction histories and motivations
- ✅ Character backgrounds
- ✅ Historical events and timeline
- ✅ Technology explanations
- ✅ Geographic information
- ✅ Cultural context
- ✅ Narrative hooks for content

### What Does NOT Belong Here
- ❌ Game mechanics - goes in design/
- ❌ Stat values - goes in mods/
- ❌ Implementation - goes in engine/
- ❌ Detailed designs - goes in design/
- ❌ Player-facing story content - goes in mods/

---

## Lore Structure

### Timeline

```markdown
# Historical Timeline

## Pre-Contact Era (Before 2025)
- 2020: First UFO sightings increase globally
- 2023: Governments begin secret preparations
- 2024: XCOM organization secretly formed

## First Contact (2025)
- March 2025: First confirmed alien landing
- April 2025: Public reveals alien existence
- May 2025: XCOM goes public, begins operations

## Current Era (2025-present)
- June 2025: First major battle (New York)
- July 2025: Discovery of alien base network
- **Game starts here**
```

**Purpose:** Establish when events happen, provide historical context

---

### Setting

```markdown
# World Setting

## Overview
Near-future Earth (2025) facing alien invasion. Governments coordinate through
XCOM (Extraterrestrial Combat Unit) - international defense force.

## Key Features
- **Time Period:** 2025 (near-future, recognizable technology)
- **Scope:** Global (missions worldwide)
- **Tone:** Serious, grounded sci-fi (not space opera)
- **Technology Level:** Near-future (drones, advanced materials, aliens more advanced)

## Core Conflict
Mysterious alien force invading Earth. Motives unknown. XCOM defends humanity
while researching alien technology to fight back.
```

**Purpose:** Define the world players experience

---

### Factions

```markdown
# Major Factions

## XCOM (Player Faction)
**Full Name:** Extraterrestrial Combat Unit  
**Founded:** 2024 (secretly), 2025 (public)  
**Purpose:** Defend Earth from alien invasion  
**Leadership:** International council  
**Resources:** Funding from member nations  

**Motivation:** Survival of human race

**Key Units:**
- Soldiers (various specializations)
- Scientists (research alien tech)
- Engineers (manufacture equipment)

---

## The Invaders (Enemy Faction)
**Identity:** Unknown alien species  
**Origin:** Unknown  
**Purpose:** Unclear (conquest? resources? other?)  
**Organization:** Hierarchical, disciplined  

**Motivation:** Unknown (discovered through play)

**Key Units:**
- Sectoids (basic troops, psychic)
- Mutons (heavy troops, strong)
- Floaters (flying units)
- [More discovered during game]

---

## World Governments (Allied Factions)
**Role:** Fund XCOM, provide support  
**Concern:** Panic levels - if too high, withdraw support  
**Interaction:** Missions protect countries, keep support high  
```

**Purpose:** Define who's who, why they do what they do

---

### Technology

```markdown
# Technology Context

## Human Technology (2025)
- Advanced drones and robotics
- Early genetic engineering
- Sophisticated AI
- Advanced materials (carbon nanotubes, graphene)
- **But:** No energy weapons, no FTL, no psionics

## Alien Technology (To Be Researched)
- Plasma weapons (energy-based)
- UFO propulsion (gravity manipulation)
- Advanced materials (alien alloys)
- Genetic engineering (biological enhancements)
- Psionics (mental abilities)

## Research Progression
Game starts: Human tech only
Early game: Capture alien tech, begin research
Mid game: Hybrid tech (reverse-engineered)
Late game: Advanced human-alien hybrid tech

**Lore Rule:** All tech must be researched/unlocked through gameplay
(No starting with plasma rifles - must earn it)
```

**Purpose:** Explain what technology exists and why

---

## Integration with Other Folders

### lore/ → design/
Lore informs design decisions:
- **Lore:** Sectoids are psychic aliens
- **Design:** Sectoid units have mind control ability

### lore/ → mods/
Lore provides context for content:
- **Lore:** Mutons are heavily armored
- **Mods:** Muton units have high defense stats

### lore/ → missions
Lore creates mission context:
- **Lore:** Aliens abducting civilians
- **Missions:** Abduction mission type

### lore/ ↔ design/
Bidirectional: Lore informs design, design can expand lore
- Start with lore concept
- Design mechanics around it
- Expand lore based on design needs

---

## Lore Development Process

### Step 1: Core Concept
```markdown
Core Question: What is this game about?
Answer: Defending Earth from alien invasion in near-future

Key Elements:
- Recognizable Earth (2025, near-future)
- Mysterious aliens (unknown motives)
- Humanity united (XCOM as global defense)
- Technology progression (human → hybrid)
```

### Step 2: Expand Details
```markdown
Questions to answer:
- Who are the aliens? (Unknown at first, discovered in play)
- Why are they invading? (Unclear, part of mystery)
- How does XCOM function? (International, funded by countries)
- What technology exists? (Near-future human, advanced alien)
- Where do battles happen? (Global - missions worldwide)
```

### Step 3: Create Content Hooks
```markdown
Lore provides hooks for:
- Mission types (abduction, terror, base assault)
- Unit types (different alien species with abilities)
- Technology tree (research progression)
- Strategic layer (country support, panic)
```

### Step 4: Document and Maintain
```markdown
Keep lore:
- Consistent (no contradictions)
- Focused (serve the game, not vice versa)
- Flexible (can evolve with design)
- Accessible (easy to reference)
```

---

## Writing Guidelines

### Keep It Focused
```markdown
GOOD: Brief, relevant to game
"Sectoids are small grey aliens with psychic abilities. They serve as scouts
and basic troops for the invasion force."

BAD: Excessive detail not relevant to game
"Sectoids originate from the planet Sectara Prime in the Zeta Reticuli system.
Their civilization spans 50,000 years and includes 17 distinct subspecies...
[5 more paragraphs of detail that doesn't affect gameplay]"
```

### Make It Useful
```markdown
GOOD: Explains game mechanics
"Mutons are heavily armored warriors. Their tough physiology and advanced armor
make them difficult to kill with conventional weapons."
(Explains why they have high defense in game)

BAD: Flavor with no game connection
"Mutons enjoy ceremonial combat rituals involving three moons."
(Interesting but irrelevant to gameplay)
```

### Leave Mystery
```markdown
GOOD: Creates intrigue
"The aliens' motives remain unclear. Are they conquering? Harvesting resources?
Something else entirely? XCOM must find out."

BAD: Over-explain everything
"The aliens are invading because their home planet died 1,000 years ago due to
a supernova, and they need Earth's water to survive, and their plan is to..."
(Ruins mystery, removes discovery aspect)
```

---

## Lore vs Design Conflict Resolution

**When lore conflicts with design, design wins (but try to adjust lore first):**

```markdown
Scenario: Designer wants fast flying units

Lore says: Aliens don't have flight tech yet

Resolution Options:
1. Adjust lore: Introduce "Floater" alien with flight
2. Adjust design: Make unit fast but ground-based
3. Compromise: Unit can "hover" (limited flight)

Choose: Option 1 (adjust lore) - easiest, maintains design intent
```

**Rule:** Lore is flexible. Game mechanics are concrete. Adjust lore to fit good mechanics, not vice versa.

---

## Validation

### Lore Quality Checklist

- [ ] Supports game mechanics (explains why things work)
- [ ] Internally consistent (no contradictions)
- [ ] Focused and brief (relevant to game, not excessive detail)
- [ ] Leaves room for discovery (mystery and intrigue)
- [ ] Accessible to designers (easy to reference)
- [ ] Flexible (can evolve with design needs)
- [ ] Creates content hooks (mission types, units, tech)

---

## Tools

### Lore Timeline Generator
```bash
lua tools/lore/timeline_generator.lua lore/story/

# Generates:
# - Visual timeline
# - Key events list
# - Character involvement
```

### Consistency Checker
```bash
lua tools/validators/lore_consistency.lua lore/

# Checks:
# - No contradictions in dates
# - Referenced factions exist
# - Character appearances consistent
```

---

## Best Practices

### 1. Start Simple
```
Begin with:
- Core conflict (what is happening)
- Main factions (who is involved)
- Basic timeline (when things happen)

Expand as needed for design
```

### 2. Document Decisions
```markdown
## Design Notes
Why we made this lore choice:
- Aliens remain mysterious to create intrigue
- Near-future (2025) keeps it relatable
- Technology progression supports game arc
```

### 3. Make It Searchable
```
Use consistent terminology
Create index of factions/characters
Tag content by relevance
```

### 4. Keep It Flexible
```
Mark elements as:
- Core (unchangeable, central to game)
- Flexible (can adjust if design needs)
- Undefined (intentionally vague for now)
```

---

## Maintenance

**On Design Change:**
- Review affected lore
- Update for consistency
- Note changes in changelog

**Monthly:**
- Review for consistency
- Check design integration
- Update as needed

**Per Release:**
- Verify lore matches game
- Update documentation
- Archive old versions

---

**See:** lore/README.md

**Related:**
- [modules/01_DESIGN_FOLDER.md](01_DESIGN_FOLDER.md) - Lore informs design
- [modules/05_MODS_FOLDER.md](05_MODS_FOLDER.md) - Content reflects lore

