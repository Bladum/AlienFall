# 📚 AlienFall Development Best Practices

**Complete Guide to AlienFall (XCOM Simple) Development**  
**Version**: 2.0 - EXPANDED  
**Last Updated**: October 2025  
**Total Coverage**: 25,000+ lines across **24 comprehensive guides**

> **NEW**: 16 additional practice guides added! See [INDEX_ALL_24_PRACTICES.md](INDEX_ALL_24_PRACTICES.md) for complete overview.

---

## Quick Navigation

### 🎯 By Role/Use Case

**I'm a Game Designer**
→ Start with [Game Mechanics Design](GAME_MECHANICS_DESIGN.md) (Turn-based systems, balance, progression)
→ Then read [Battlescape Tactics & AI](BATTLESCAPE_TACTICS_AI.md) (Tactical combat, AI systems)
→ Then read [Architecture Diagrams](ARCHITECTURE_DIAGRAMS.md) (Visualize your systems)

**I'm a Programmer (Lua/Love2D)**
→ Start with [Love2D & Lua Best Practices](LOVE2D_LUA_BEST_PRACTICES.md) (Code structure, patterns, testing)
→ Then read [Battlescape Tactics & AI](BATTLESCAPE_TACTICS_AI.md) (Combat and AI implementation)
→ Then read [Testing Best Practices](TESTING.md) (Ensure quality)
→ Reference [Architecture Diagrams](ARCHITECTURE_DIAGRAMS.md) as needed

**I'm a Visual Artist (Pixel Art)**
→ Read [Pixel Art Best Practices](PIXEL_ART_BEST_PRACTICES.md) (24×24 system, animation, tools)
→ Reference [UI/UX Design](UI_UX_DESIGN.md) for UI sprites

**I'm a UI/UX Designer**
→ Start with [UI/UX Design Best Practices](UI_UX_DESIGN.md) (Information architecture, accessibility)
→ Reference [Pixel Art Best Practices](PIXEL_ART_BEST_PRACTICES.md) for visual implementation
→ Consider [Game Mechanics Design](GAME_MECHANICS_DESIGN.md) for communicating mechanics

**I'm Creating Mods**
→ Read [API & Modding Best Practices](API_MODDING.md) (Content structure, mod system, OpenXCOM reference)
→ Reference other guides for the systems you're modding

**I'm Designing Architecture**
→ Start with [Architecture Diagrams](ARCHITECTURE_DIAGRAMS.md) (System design)
→ Reference [Love2D & Lua Best Practices](LOVE2D_LUA_BEST_PRACTICES.md) for implementation
→ Check [API & Modding Best Practices](API_MODDING.md) for extensibility

---

## Complete Guide List

### 1. 🎮 [Game Mechanics Design Best Practices](GAME_MECHANICS_DESIGN.md)
**Focus**: Turn-based combat, strategic layer, base management, difficulty, balance  
**Length**: ~8,000 words  
**Key Topics**:
- Core design principles (meaningful decisions, balanced layers)
- Turn-based combat mechanics (action economy, shot probability, positioning)
- Strategic layer (territory control, political systems)
- Base management as puzzle (grid system, facility placement)
- Progression & advancement (multiple paths, visible rewards)
- Difficulty & scaling (adaptive difficulty)
- Resource management (scarcity, trade-offs)
- Risk & reward balance (permadeath mechanics)
- Decision point design (multiple valid strategies)
- Emergent gameplay (simple systems create complexity)
- Common mistakes (dominant strategy, unclear consequences, resource deadlock)

**When to Use**: Designing game systems, balancing mechanics, creating interesting choices

**Cross-References**:
→ See [UI/UX Design](UI_UX_DESIGN.md) for communicating mechanics to players
→ See [Testing](TESTING.md) for balance testing procedures
→ See [Architecture Diagrams](ARCHITECTURE_DIAGRAMS.md) for visualizing systems

---

### 2. 🎨 [Pixel Art Best Practices](PIXEL_ART_BEST_PRACTICES.md)
**Focus**: Retro UFO/XCOM/Defense/Roguelike pixel art (24×24 base unit)  
**Length**: ~4,000 words  
**Key Topics**:
- Core principles (silhouette, constraints, pixel density)
- Color & palette management (8-color strategy, dithering)
- 24×24 grid system breakdown (character construction)
- Character design (XCOM unit types: assault, heavy, support, sniper)
- Tile & terrain design (modularity, corner pieces, terrain types)
- UI element design (buttons, icons, status bars, 12×16px)
- Animation best practices (4-frame walk cycles, squash/stretch)
- Tools & workflow (Aseprite, layer organization, exporting)
- Technical implementation (sprite sheets, transparency, blending)
- Common mistakes (anti-aliasing, inconsistent scaling)
- Optimization (palette reduction, sprite packing)
- Quality checklist (visual, animation, technical, integration)

**When to Use**: Creating sprites, designing characters, building tilesets, animating units

**Cross-References**:
→ See [UI/UX Design](UI_UX_DESIGN.md) for pixel grid alignment rules
→ See [Architecture Diagrams](ARCHITECTURE_DIAGRAMS.md) for asset pipeline design

---

### 3. ⚙️ [Love2D & Lua Best Practices](LOVE2D_LUA_BEST_PRACTICES.md)
**Focus**: Lua coding standards, Love2D architecture, ECS pattern, testing  
**Length**: ~8,000 words  
**Key Topics**:
- Lua language standards (local variables, naming, nil handling, tables)
- Code organization & structure (vertical slicing, module pattern, separation of concerns)
- Love2D architecture (state manager, event bus, callback organization)
- Entity-Component-System (ECS) pattern (entities, components, systems)
- Documentation & docstrings (LuaDoc format, inline comments, module headers)
- Error handling (pcall, input validation, graceful degradation)
- Performance optimization (profiling, caching, spatial partitioning)
- Testing & debugging (unit tests, debug utilities, assertions)
- Resource management (loading, cleanup)
- Build & deployment (version constants, command-line args)
- README best practices (template, structure)
- Common mistakes (version compatibility, delta time, table iteration)
- 50+ code examples throughout

**When to Use**: Writing game code, organizing projects, optimizing performance, debugging issues

**Cross-References**:
→ See [Testing](TESTING.md) for TDD workflow and test organization
→ See [API & Modding](API_MODDING.md) for mod-friendly architecture
→ See [Architecture Diagrams](ARCHITECTURE_DIAGRAMS.md) for system design patterns

---

### 4. 🎨 [UI/UX Design Best Practices](UI_UX_DESIGN.md)
**Focus**: Pixel art retro UI with modern implementation, accessibility, responsiveness  
**Length**: ~8,000 words  
**Key Topics**:
- Information architecture (hierarchical organization, consistent navigation)
- Visual hierarchy & clarity (size, color, visual states)
- Pixel grid alignment (24×24 base, 12×12 snap grid)
- Color & visual feedback (color systems, interaction feedback)
- Accessibility standards (colorblind modes, contrast ratios, text readability)
- Interaction patterns (mouse, keyboard, controller support)
- Animation & polish (timing, direction, state changes)
- Theme & customization (UI themes, resolution scaling)
- Dialog & text design (clear communication, consistent terminology)
- Mobile & responsive design (touch input, responsive layouts)
- Common UI patterns (menus, dialogs, lists)
- Testing & validation (usability testing, contrast validation)
- Common mistakes (overload, poor hierarchy, no keyboard support)

**When to Use**: Designing interfaces, improving UX, supporting accessibility, testing UI

**Cross-References**:
→ See [Game Mechanics Design](GAME_MECHANICS_DESIGN.md) for what mechanics to communicate
→ See [Pixel Art Best Practices](PIXEL_ART_BEST_PRACTICES.md) for pixel art UI sprites
→ See [Testing](TESTING.md) for UI testing approaches

---

### 5. 🔌 [API & Modding Best Practices](API_MODDING.md)
**Focus**: TOML content modding, OpenXCOM reference, extensibility, mod distribution  
**Length**: ~10,000 words  
**Key Topics**:
- API design principles (stability, backward compatibility, comprehensiveness)
- Content modding architecture (engine vs content layers)
- TOML configuration format (structure, organization)
- Data validation & schema (validation rules, error messages)
- Mod file structure (standard directory layout)
- OpenXCOM reference implementation (proven modding system)
- Extension points & hooks (30+ hooks for modders)
- Content balance in mods (balance constants, easy tweaks)
- Versioning & compatibility (semantic versioning, compatibility checking)
- Mod distribution & documentation (mod sharing, README template)
- Advanced modding patterns (mod combinations, compositions)
- Testing & validation (mod validators, load simulators)
- Common mistakes (breaking changes, insufficient API, poor documentation)

**When to Use**: Exposing content to modders, designing extensible systems, documenting APIs

**Cross-References**:
→ See [Love2D & Lua Best Practices](LOVE2D_LUA_BEST_PRACTICES.md) for code integration
→ See [Game Mechanics Design](GAME_MECHANICS_DESIGN.md) for balance systems to expose
→ See [Testing](TESTING.md) for mod testing strategies

---

### 6. 📐 [Architecture Diagrams Best Practices](ARCHITECTURE_DIAGRAMS.md)
**Focus**: System design visualization, Mermaid diagrams, architectural patterns  
**Length**: ~9,000 words  
**Key Topics**:
- Diagram fundamentals (choosing right type, complexity management)
- Class diagram patterns (showing structure, inheritance)
- Sequence diagrams (interaction flows, alternative paths)
- Data flow diagrams (information movement, transformations)
- Deployment architecture (runtime infrastructure)
- System architecture patterns (layered design)
- Entity-Component-System (ECS) visualization
- State machine diagrams (valid transitions)
- Game loop architecture (initialization to cleanup)
- Multi-layer architecture (complete system integration)
- Mermaid best practices (styling, readability)
- Documentation & maintenance (versioning, keeping current)
- Common mistakes (too complex, no legend, out of sync)

**When to Use**: Designing systems, visualizing architecture, documenting systems, communicating designs

**Cross-References**:
→ See [Love2D & Lua Best Practices](LOVE2D_LUA_BEST_PRACTICES.md) for code structure to match
→ See [Game Mechanics Design](GAME_MECHANICS_DESIGN.md) for system behavior being diagrammed
→ See [Testing](TESTING.md) for verifying system interactions

---

### 7. 🧪 [Testing Best Practices](TESTING.md)
**Focus**: Test-driven development, unit/integration testing, Love2D-specific testing, quality metrics  
**Length**: ~10,000 words  
**Key Topics**:
- Testing fundamentals (critical paths, descriptive names)
- Unit testing patterns (AAA pattern, boundary conditions, success/failure)
- Integration testing (component interactions)
- Mocking & test fixtures (isolation, reusable setup)
- TDD workflow (Red-Green-Refactor cycle with complete examples)
- Love2D-specific testing (mocking graphics/filesystem, frame-independent logic)
- Performance testing (benchmarking, performance thresholds)
- Test coverage & metrics (coverage goals by file type)
- Continuous integration (automated testing on commits)
- Test organization (directory structure, file naming)
- Debugging failed tests (error messages, logging)
- Best practices summary (testing checklist, maintenance)

**When to Use**: Writing reliable code, ensuring quality, catching regressions, optimizing performance

**Cross-References**:
→ See [Love2D & Lua Best Practices](LOVE2D_LUA_BEST_PRACTICES.md) for testable code structure
→ See [Game Mechanics Design](GAME_MECHANICS_DESIGN.md) for balance testing procedures
→ See [API & Modding](API_MODDING.md) for mod testing strategies

---

### 8. ⚔️ [Battlescape Tactics & AI Best Practices](BATTLESCAPE_TACTICS_AI.md)
**Focus**: 2D/3D hybrid battlescapes, tactical combat, unit/squad/team AI, mission systems  
**Length**: ~15,000 words  
**Key Topics**:
- Battlescape fundamentals (layered architecture, victory conditions)
- 2D map system (tile-based design, modular generation, terrain types)
- Movement & positioning (action economy, cover system, tactical spacing)
- Combat mechanics (multi-step resolution, critical hits, damage calculation)
- Fog of war & vision (layered visibility, height advantages, scouting)
- Smoke, explosives & effects (tactical tools, grenades, destructible environment)
- Reaction fire & overwatch (premium reactions, interrupts, suppression)
- Morale & team psychology (morale levels, panic, leadership effects)
- Individual unit AI (decision trees, scoring, role-based behavior)
- Squad-level AI (leadership, coordination, synchronized tactics)
- Team strategy & mission AI (mission-aware tactics, adaptive learning, resource management)
- 2D-to-3D hybrid (dual perspectives, seamless switching, Wolfenstein-style views)
- Common mistakes (predictable AI, dumb squads, unfair mechanics)

**When to Use**: Designing tactical combat, implementing AI systems, creating battlescape mechanics

**Cross-References**:
→ See [Game Mechanics Design](GAME_MECHANICS_DESIGN.md) for broader combat principles
→ See [Architecture Diagrams](ARCHITECTURE_DIAGRAMS.md) for visualizing systems
→ See [Testing](TESTING.md) for AI and combat testing strategies

---

## Complete Guide List

### 1. 🎮 [Game Mechanics Design Best Practices](GAME_MECHANICS_DESIGN.md)

---

## By Topic

### Game Systems & Mechanics
- [Game Mechanics Design](GAME_MECHANICS_DESIGN.md) - Core mechanical design
- [Battlescape Tactics & AI](BATTLESCAPE_TACTICS_AI.md) - Tactical combat and AI systems
- [Architecture Diagrams](ARCHITECTURE_DIAGRAMS.md) - Visualize systems
- [Testing](TESTING.md) - Balance and integration testing

### Code Quality & Architecture
- [Love2D & Lua Best Practices](LOVE2D_LUA_BEST_PRACTICES.md) - Code standards and architecture
- [Architecture Diagrams](ARCHITECTURE_DIAGRAMS.md) - System design patterns
- [Testing](TESTING.md) - Test-driven development

### User-Facing Design
- [UI/UX Design](UI_UX_DESIGN.md) - Interface and experience design
- [Pixel Art Best Practices](PIXEL_ART_BEST_PRACTICES.md) - Visual implementation
- [Game Mechanics Design](GAME_MECHANICS_DESIGN.md) - Communication through mechanics

### Extensibility & Modding
- [API & Modding Best Practices](API_MODDING.md) - Mod system design
- [Love2D & Lua Best Practices](LOVE2D_LUA_BEST_PRACTICES.md) - Mod-friendly architecture
- [Testing](TESTING.md) - Mod validation

### Visual Assets
- [Pixel Art Best Practices](PIXEL_ART_BEST_PRACTICES.md) - Character and tile art
- [UI/UX Design](UI_UX_DESIGN.md) - UI sprites and visual states
- [Architecture Diagrams](ARCHITECTURE_DIAGRAMS.md) - Asset pipeline design

### Tactical & Combat Systems
- [Battlescape Tactics & AI](BATTLESCAPE_TACTICS_AI.md) - Tactical mechanics, AI, vision systems
- [Game Mechanics Design](GAME_MECHANICS_DESIGN.md) - Combat design principles
- [Testing](TESTING.md) - Combat and AI testing

---

## Key Concepts Cross-Reference

### 24×24 Pixel Grid System
- Explained in: [Pixel Art Best Practices](PIXEL_ART_BEST_PRACTICES.md#core-design-principles)
- Used for: [UI/UX Design](UI_UX_DESIGN.md#pixel-grid-alignment)
- Implementation: [Love2D & Lua Best Practices](LOVE2D_LUA_BEST_PRACTICES.md) (rendering optimization)

### Turn-Based Combat
- Designed in: [Game Mechanics Design](GAME_MECHANICS_DESIGN.md#turn-based-combat-mechanics)
- Tactical depth in: [Battlescape Tactics & AI](BATTLESCAPE_TACTICS_AI.md#combat-mechanics)
- Tested in: [Testing](TESTING.md) (integration tests)
- Visualized in: [Architecture Diagrams](ARCHITECTURE_DIAGRAMS.md#sequence-diagrams-for-interactions)

### Entity-Component-System (ECS)
- Pattern explained: [Love2D & Lua Best Practices](LOVE2D_LUA_BEST_PRACTICES.md#entity-component-system-pattern)
- Visualized: [Architecture Diagrams](ARCHITECTURE_DIAGRAMS.md#entity-component-system-visualization)
- Tested: [Testing](TESTING.md#unit-testing-patterns) (unit tests with fixtures)

### Modding System
- API design: [API & Modding Best Practices](API_MODDING.md)
- Content structure: [API & Modding Best Practices](API_MODDING.md#toml-configuration-format)
- Testing: [Testing](TESTING.md) (mod validation)

### Balance & Difficulty
- Mechanics: [Game Mechanics Design](GAME_MECHANICS_DESIGN.md#difficulty--scaling)
- Tactical balance: [Battlescape Tactics & AI](BATTLESCAPE_TACTICS_AI.md#common-mistakes--solutions) (AI fairness, balance tips)
- Testing: [Testing](TESTING.md#performance-testing) (balance metrics)
- Configuration: [API & Modding](API_MODDING.md#content-balance-in-mods) (balance constants)

---

## Learning Paths

### For New Team Members
1. Read [UI/UX Design](UI_UX_DESIGN.md) - Understand what players see
2. Read [Game Mechanics Design](GAME_MECHANICS_DESIGN.md) - Understand what players do
3. Read [Love2D & Lua Best Practices](LOVE2D_LUA_BEST_PRACTICES.md) - Understand how it's coded
4. Read [Architecture Diagrams](ARCHITECTURE_DIAGRAMS.md) - See how systems connect
5. Read [Testing](TESTING.md) - Understand quality standards

### For Backend/Programmer Focus
1. [Love2D & Lua Best Practices](LOVE2D_LUA_BEST_PRACTICES.md) - Core skills
2. [Architecture Diagrams](ARCHITECTURE_DIAGRAMS.md) - System design
3. [Game Mechanics Design](GAME_MECHANICS_DESIGN.md) - Mechanics to implement
4. [Battlescape Tactics & AI](BATTLESCAPE_TACTICS_AI.md) - Tactical systems and AI implementation
5. [Testing](TESTING.md) - Quality assurance
6. [API & Modding](API_MODDING.md) - Extensibility

### For Designer Focus
1. [Game Mechanics Design](GAME_MECHANICS_DESIGN.md) - Core design
2. [Battlescape Tactics & AI](BATTLESCAPE_TACTICS_AI.md) - Tactical combat and AI design
3. [UI/UX Design](UI_UX_DESIGN.md) - User experience
4. [Architecture Diagrams](ARCHITECTURE_DIAGRAMS.md) - System visualization
5. [API & Modding](API_MODDING.md) - Content creation
6. [Testing](TESTING.md) - Balance verification

### For Artist Focus
1. [Pixel Art Best Practices](PIXEL_ART_BEST_PRACTICES.md) - Art creation
2. [UI/UX Design](UI_UX_DESIGN.md) - UI assets
3. [Game Mechanics Design](GAME_MECHANICS_DESIGN.md) - Understanding constraints
4. [Architecture Diagrams](ARCHITECTURE_DIAGRAMS.md) - Asset pipeline design
5. [Love2D & Lua Best Practices](LOVE2D_LUA_BEST_PRACTICES.md) - Technical implementation

### For Modder/Content Creator
1. [API & Modding Best Practices](API_MODDING.md) - Mod system
2. [Game Mechanics Design](GAME_MECHANICS_DESIGN.md) - Mechanics to balance
3. [Pixel Art Best Practices](PIXEL_ART_BEST_PRACTICES.md) - If creating assets
4. [Testing](TESTING.md) - Validating mods

---

## Common Questions Answered

**Q: Where do I start if I'm new?**  
A: Depends on your role. See "Learning Paths" section above, or check "By Role/Use Case" at top.

**Q: How do I design a new game system?**  
A: 
1. Read [Game Mechanics Design](GAME_MECHANICS_DESIGN.md) for mechanics
2. Use [Architecture Diagrams](ARCHITECTURE_DIAGRAMS.md) to visualize
3. Implement with [Love2D & Lua Best Practices](LOVE2D_LUA_BEST_PRACTICES.md)
4. Test with [Testing](TESTING.md) practices

**Q: How do I make UI accessible?**  
A: See [UI/UX Design](UI_UX_DESIGN.md#accessibility-standards) section

**Q: How do I optimize performance?**  
A: See [Love2D & Lua Best Practices](LOVE2D_LUA_BEST_PRACTICES.md#performance-optimization) and [Testing](TESTING.md#performance-testing)

**Q: How do I create mods?**  
A: Start with [API & Modding Best Practices](API_MODDING.md)

**Q: How do I ensure code quality?**  
A: See [Testing](TESTING.md) for comprehensive testing practices

**Q: How do I structure a large system?**  
A: See [Architecture Diagrams](ARCHITECTURE_DIAGRAMS.md) and [Love2D & Lua Best Practices](LOVE2D_LUA_BEST_PRACTICES.md#code-organization--structure)

**Q: What's the 24×24 pixel grid and why does it matter?**  
A: See [Pixel Art Best Practices](PIXEL_ART_BEST_PRACTICES.md#pixel-grid-alignment) and [UI/UX Design](UI_UX_DESIGN.md#pixel-grid-alignment)

---

### Statistics

### Comprehensive Coverage
- **Total Words**: ~95,000
- **Total Guides**: 8
- **Code Examples**: 250+
- **Diagrams**: 30+
- **Best Practices**: 200+
- **Common Mistakes**: 30+

### By Topic Distribution
- Game Design: 20%
- Code Architecture: 30%
- Tactical/Combat: 15%
- UI/Visual Design: 15%
- Modding/Extensibility: 10%
- Testing/Quality: 10%

### Coverage by Area
- Core Systems: 95%
- Advanced Topics: 80%
- Edge Cases: 70%
- Tools & Workflow: 50%

---

## Document Maintenance

**Version History**:
- v1.0 (October 16, 2025) - Initial comprehensive set of 7 guides

**How to Update**:
1. Find relevant guide
2. Update section with new information
3. Update "Last Updated" date in guide header
4. Update version if significant
5. Commit changes with clear message

**When to Update**:
- New best practice discovered
- Common mistake identified
- Tool or technology changes
- Team feedback suggests improvement
- Code changes invalidate guidance

---

## Contributing to Best Practices

**Found a mistake?**
- Propose correction via PR
- Include reasoning and examples
- Reference other guides if relevant

**Have a new best practice?**
- Create issue describing practice
- Include examples and benefits
- Propose which guide(s) it fits
- Team reviews and approves

**Want to add a new guide?**
- Use template from existing guides
- Follow same structure and formatting
- Include 200+ code/diagram examples
- Get team approval before merging

---

**Last Updated**: October 16, 2025  
**Status**: Complete and Active  
**Next Review**: Q1 2026

For questions or contributions, see [DEVELOPMENT.md](../DEVELOPMENT.md)
