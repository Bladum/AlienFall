# Design Folder - Game Design & Mechanics Documentation

**Purpose:** Store game design specifications, mechanics documentation, and balance decisions  
**Audience:** Game designers, developers, content creators  
**Format:** Markdown documents with examples and rationale

---

## What Goes in design/

### Structure
```
design/
├── README.md                    Overview and index
├── DESIGN_TEMPLATE.md          Template for new designs
├── GLOSSARY.md                 Game terminology reference
│
├── mechanics/                   Detailed system designs
│   ├── Units.md                Unit progression, stats, abilities
│   ├── Combat.md               Combat resolution, damage, accuracy
│   ├── Economy.md              Resources, costs, progression
│   ├── Research.md             Tech tree, prerequisites, unlocks
│   ├── Bases.md                Base building, facilities, management
│   └── Missions.md             Mission types, objectives, rewards
│
└── gaps/                        Design-to-implementation analysis
    ├── analysis_YYYY_MM_DD.md  Gap identification
    └── tracking.md             Resolution tracking
```

---

## Content Guidelines

### What Belongs Here
- ✅ Game mechanics descriptions ("Units gain XP per kill")
- ✅ Balance parameters ("Strength range: 6-12")
- ✅ Design rationale ("Why this range prevents overpowered units")
- ✅ Edge case handling ("What if unit earns exactly 100 XP?")
- ✅ Player experience goals ("Should feel rewarding but challenging")
- ✅ Examples and use cases

### What Does NOT Belong Here
- ❌ Implementation details ("Use array to store units")
- ❌ Code snippets (examples OK, actual code NO)
- ❌ Technical architecture (belongs in architecture/)
- ❌ TOML schemas (belongs in api/)
- ❌ Test cases (belongs in tests2/)

---

## Example: Unit Design

```markdown
# Units System Design

## Overview
Units are persistent soldiers that gain experience and improve through missions.

## Core Mechanics

### Experience Progression
- **XP Gain:** 5 XP per enemy kill
- **Promotion Threshold:** 100 XP per rank
- **Max Ranks:** 7 (Rookie → Colonel)

### Stat Progression
- **Per Rank:** +10% to all stats
- **Starting Stats:** Strength 8, Dexterity 7, Constitution 9

## Design Rationale

### Why 5 XP per kill?
- 20 kills for promotion = 2-3 missions
- Feels achievable but requires keeping units alive
- Creates attachment to veteran soldiers

### Why 10% stat increase?
- Noticeable improvement (80 HP → 88 HP)
- Not overpowered (would need +50% for double strength)
- Scales well across 7 ranks (1.0 → 1.95x power)

## Edge Cases

**Q: What if unit earns exactly 100 XP?**
A: Promotes immediately after mission ends

**Q: Can units skip ranks?**
A: No, must progress sequentially

**Q: What happens at max rank?**
A: XP still accumulates but no further promotions

## Player Experience
- Early game: Protect rookies to build veterans
- Mid game: Mix of veterans and new recruits
- Late game: Elite squad with high stats
```

---

## Integration with Other Folders

### design/ → api/
Every design decision should have corresponding API definition:
- Design: "Units gain 5 XP per kill"
- API: `gainExperience(amount: integer) → void`

### design/ → architecture/
Complex systems should have architectural diagrams:
- Design: "Unit progression system"
- Architecture: Sequence diagram showing Battle → Unit → XPCalculator

### design/ → engine/
Implementation references design:
```lua
-- See design/mechanics/Units.md for XP progression rationale
function Unit:gainExperience(amount)
    -- Design specifies 5 XP per kill
    self.experience = self.experience + amount
end
```

---

## Design Template Usage

Use `DESIGN_TEMPLATE.md` for new designs:

1. Copy template
2. Fill in all sections
3. Review with team
4. Link from main mechanics document
5. Update API and architecture as needed

---

## Glossary Integration

Define all game terms in `GLOSSARY.md`:
- Unit types (Soldier, Scout, Heavy)
- Game concepts (XP, Rank, Promotion)
- Mechanics (Overwatch, Suppression, Cover)

Reference in designs: "See GLOSSARY.md for Cover mechanics"

---

## Gap Analysis

Track design-to-implementation gaps in `gaps/`:

**Purpose:** Identify where design exists but implementation doesn't (or vice versa)

**Process:**
1. Run gap analysis tool
2. Document findings in `gaps/analysis_DATE.md`
3. Create tasks for missing implementations
4. Track resolution in `gaps/tracking.md`

---

## Best Practices

### 1. Write for Humans
Design docs are for humans to understand. Use clear language, examples, and rationale.

### 2. Document WHY
Don't just say what - explain why decisions were made. Future you will thank you.

### 3. Include Examples
Show concrete examples of mechanics in action. "Unit with 95 XP kills enemy → gains 5 XP → promotes to Sergeant"

### 4. Cover Edge Cases
Think through boundary conditions and document expected behavior.

### 5. Keep Updated
When mechanics change, update design docs immediately. Stale docs are worse than no docs.

### 6. Link Freely
Reference other design docs, glossary terms, and related systems.

---

## Common Patterns

### Pattern 1: Progression System
- Starting state
- Progression mechanism (XP, research, etc.)
- Milestones/thresholds
- End state
- Rationale for pacing

### Pattern 2: Resource System
- Sources (how acquired)
- Sinks (how spent)
- Balance (income vs expenses)
- Scarcity design (intentional bottlenecks)

### Pattern 3: Choice System
- Available options
- Trade-offs
- Optimal strategies (and why they're OK)
- Player expression opportunities

---

## Validation

Check design quality:

- [ ] All mechanics clearly described
- [ ] Rationale provided for key decisions
- [ ] Edge cases documented
- [ ] Examples given
- [ ] Integrated with glossary
- [ ] Links to API/architecture where appropriate
- [ ] No implementation details
- [ ] Reviewed by team

---

## Maintenance

**Monthly:** Review for accuracy and completeness

**Per Release:** Update with any changes to mechanics

**On New Feature:** Create design doc before implementation

---

**See:** design/README.md for complete guidelines

