# Assets & Resource Pipeline

## Table of Contents

- [Asset Types & Organization](#asset-types--organization)
- [Asset Pipeline & Workflow](#asset-pipeline--workflow)
- [Resource Management & Optimization](#resource-management--optimization)
- [Tileset System](#tileset-system)
- [Asset Caching & Performance](#asset-caching--performance)
- [Mod Creation & Integration](#mod-creation--integration)
- [Testing & Validation](#testing--validation)

## Asset Types & Organization

- **Graphics**: PNG with transparency, 12×12 pixel art upscaled to 24×24 display
  - Spritesheet atlases (optimized for batch rendering)
  - Individual sprites with metadata
  - UI icons (consistent sizing, color variants)
  - Environmental art (terrain, objects, weather effects)
- **Audio**: OGG Vorbis (music), WAV (sound effects)
  - Ambient tracks (looping, 3-5 minute length)
  - Combat tracks (high energy, 2-3 minute loops)
  - UI sounds (short SFX, < 1 second)
  - Voice acting (if applicable)
- **Data**: TOML configuration files with hierarchical structure and fallbacks
  - Game content (units, items, facilities, missions)
  - Configuration (settings, balance values)
  - Localization strings
  - Mod definitions

---

## Asset Pipeline & Workflow

### Asset Creation Workflow

**Stage 1: Design**
- Define asset specifications (size, format, purpose)
- Create mood boards/references
- Plan sprite sheets and animations

**Stage 2: Development**
- Create pixel art in external tools (Aseprite, Piskel, etc.)
- Export at 12×12 native resolution
- Generate color variants if needed
- Test at 24×24 upscaled size

**Stage 3: Integration**
- Pack sprites into atlases for performance
- Create TOML metadata files
- Add to version control
- Document in asset registry

**Stage 4: Testing**
- Load in game context
- Verify colors and alignment
- Check animation timing
- Performance profiling

**Stage 5: Optimization**
- Compress PNG files (lossless, optimize palette)
- Test on lower-end systems
- Cache precomputed data
- Document load times

### Performance Optimization

**Sprite Sheet Optimization:**
- Combine related sprites into single sheets (32×32 or 64×64)
- Power-of-two dimensions for optimal GPU handling
- Consistent sprite sizing within sheets
- Leave 1px padding between sprites (prevent bleed)

**Compression:**
- PNG compression: pngquant or PNGCrush
- Target 100-500 KB per sprite sheet
- OGG audio: ~128 kbps bitrate for ambient, ~64 kbps for SFX

**Memory Management:**
- Only load assets needed for current scene
- Unload scene assets immediately when switching
- Cache frequently-used assets (UI, common objects)
- Stream large assets (music) rather than load entirely

---

## Resource Management & Optimization

### Asset Streaming Strategy

**Scene Loading:**
- Pre-load all assets during fade-in (250ms)
- Display loading screen if assets > 50 MB
- Streaming threshold: Load assets < 10 MB synchronously
- Stream larger assets on background thread

**In-Game Loading:**
- Load new mission map asynchronously
- Smooth transition: fade out old map, load, fade in new
- Background asset unloading during non-critical times

### Memory Budgets

**Per Platform:**
- Desktop: 256 MB asset cache
- Laptop: 128 MB asset cache
- Target: Keep total memory < 512 MB

**Per Scene:**
- Geoscape: ~50 MB (world map, UI, overlays)
- Basescape: ~30 MB (facilities, equipment, UI)
- Battlescape: ~80 MB (map blocks, units, effects, UI)
- Menu: ~10 MB (logos, menus, backgrounds)

**Asset Preloading:**
- Preload next expected scene during current scene
- Example: During mission briefing, load battlescape map
- Reduces perceived load time at scene transitions

### Atlasing Strategy

**Texture Atlas Organization:**
- **UI Atlas**: All UI icons/buttons (512×512)
- **Unit Atlas**: All unit sprites by size/type (1024×1024)
- **Terrain Atlas**: Tileset variations (2048×2048)
- **Effect Atlas**: Particles, explosions, fire, smoke (1024×1024)
- **Object Atlas**: Environmental objects, furniture (1024×1024)

**Benefits:**
- Single texture binding per atlas (reduced draw calls)
- Batch rendering of similar object types
- Simplified sprite lookup (UV coordinates precomputed)

---

## Tileset System

**Structure**: Folder-based, each tileset contains PNG variations
- **Autotiles** (self-connecting terrain, e.g., grass borders)
  - 47-tile autotile sets for seamless connection
  - Corners, edges, intersections preconfigured
- **Random Variants** (3-4 variations of same tile for visual variety)
  - Prevents repetitive appearance
  - Chosen randomly during map generation
- **Animations** (frame sequences for water, lava, grass)
  - 4-8 frames per animation
  - 100ms per frame timing
- **Directional** (8-way variants for objects like buildings)
  - N, NE, E, SE, S, SW, W, NW variants
  - Used for walls, buildings, terrain slopes
- **Static** (non-animated, non-connecting tiles)
  - Single sprite per tile type
  - Examples: rocks, craters, debris

**Definition**: TOML specifies tile properties
```toml
[tile.grass]
sprite = "tileset/terrain_atlas.png"
autotile = true
walkable = true
cover = 0
block_vision = false

[tile.wall]
sprite = "tileset/structures_atlas.png"
autotile = false
walkable = false
cover = 80
block_vision = true
```

**Loading**: On-demand per map, cached during session
- Load tileset metadata at map creation
- Cache sprite references in memory
- Unload on map switch

---

## Asset Caching & Performance

### Cache Management

**Cache Types:**
- **Memory Cache**: Fast access, limited size
  - Atlas textures (permanent, session lifetime)
  - Recently loaded assets (LRU eviction)
- **Disk Cache**: Persistent, unlimited
  - Precomputed atlases (avoid repackaging)
  - Compiled TOML (faster loading)
- **GPU Memory**: Video RAM
  - Active textures for current scene
  - Automatically managed by GPU

**Cache Invalidation:**
- Manual invalidation on asset file changes
- Automatic on load: Hash file modification time
- Rebuild atlas if any sprite source changes
- Version check for TOML data format changes

### Load Time Optimization

**Precomputation:**
- Atlas generation on first load, cached for future runs
- TOML parsing: Convert to Lua tables, cache results
- Sprite coordinate lookups: Precompute UV coordinates

**Lazy Loading:**
- Only load assets when first needed
- Scenes specify asset dependencies
- Load in background during other operations

### Performance Metrics

**Target Performance:**
- Asset load time < 500ms per scene
- Atlas generation < 1s on first run
- Memory usage < 256 MB total
- FPS not affected by asset loading (< 2ms per frame)

---



### Inventory System

Each base maintains a centralized inventory tracking all equipment, resources, and supplies:

**Inventory Capacity:**
- Maximum weight capacity per base: (Base Level) × 500 kg
- Weight penalties: Heavy armor +20 kg, Weapons +5-15 kg per item, Resources +1-10 kg per unit

**Item Organization:**
- Grouped by category (Weapons, Armor, Equipment, Resources, Consumables)
- Search and filter by type, condition, compatibility
- Sort by weight, value, rarity, or acquisition date

**Inventory Management:**
- Transfer items between bases via transport aircraft
- Quick-equip system for mission preparation
- Loadout templates for rapid unit outfitting
- Duplicate detection and stack management

### Storage Facilities

Dedicated storage structures increase inventory capacity:

| Facility | Capacity Bonus | Construction Cost | Time | Maintenance |
|----------|---|---|---|---|
| Small Storage (1×1) | +500 kg | 5,000 credits | 7 days | 500 credits/month |
| Medium Storage (2×2) | +2,000 kg | 15,000 credits | 14 days | 1,200 credits/month |
| Large Storage (3×3) | +5,000 kg | 40,000 credits | 21 days | 3,000 credits/month |

**Storage Degradation:**
- Base inventory ABOVE capacity: -10% equipment effectiveness per 20% overfilled
- Critical overflow (>150% capacity): Equipment damaged, mission effectiveness reduced
- Storage facility destruction: 25% chance of losing stored items per destroyed facility

### Equipment Loadout System

Create and save equipment configurations for rapid unit deployment:

**Loadout Features:**
- Save up to 5 loadout templates per base
- Automatic validation (weight, compatibility, availability)
- Assign loadouts to unit classes (Assault, Support, Sniper, etc.)
- Pre-mission loadout suggestions based on mission type
- Historical loadout tracking (see what worked previously)

**Loadout Constraints:**
- Primary weapon + Secondary weapon (2 slots max)
- Body armor (1 slot, mandatory)
- Utility equipment (4 slots: grenades, medkits, scanners, etc.)
- Total weight < 100 kg per unit for combat effectiveness

### Item Maintenance & Degradation

Equipment degrades through combat use and requires maintenance:

**Durability System:**
- All equipment has 100-point durability scale
- Durability decreases through combat usage:
  - Weapons: -5 per mission (fired shots)
  - Armor: -3 per hit taken
  - Equipment: -2 per mission
  
**Condition States:**
- 100-75: Pristine (full effectiveness)
- 74-50: Worn (cosmetic wear, no penalty)
- 49-25: Damaged (-10% effectiveness, visual damage)
- 24-1: Broken (-30% effectiveness, repair strongly recommended)
- 0: Destroyed (item permanently lost)

**Repair Mechanics:**
- Repair in base workshop: 1 durability point = 1% of item purchase price
- Repair time: 1 day per 10 durability points repaired
- Full repair available: 100% cost, 10 days time
- Broken items (durability 0) cannot be repaired

**Preventive Maintenance:**
- Maintenance facility: +20 durability per month (stored equipment only)
- Maintains equipment condition during base operations
- Cost: 2,000 credits per month for active maintenance

### Item Modification System

Upgrade equipment with attachments providing stat bonuses:

**Modification Slots:**
- Weapons: 2 modification slots available
- Armor: 1 modification slot available
- Equipment: 1 modification slot (varies by type)

**Modification Categories:**

| Category | Example Mods | Effects | Cost |
|----------|---|---|---|
| Weapon Accuracy | Scope, Laser Sight | +5-15% accuracy | 1,000-3,000 cr |
| Weapon Damage | Armor-Piercing | +10-20% damage | 2,000-5,000 cr |
| Weapon Utility | Extended Magazine | +50% ammo capacity | 1,500 cr |
| Armor Defense | Ceramic Plates | +5 armor rating | 2,000 cr |
| Armor Mobility | Lightweight Frame | -1 movement penalty | 2,500 cr |

**Modification Restrictions:**
- Maximum 2 modifications per item
- Some mods mutually exclusive (scope vs laser sight)
- Modifications require technology research unlock
- Modifications transferable between items (can be uninstalled)
- Lost if item is destroyed in combat

## Procurement System

### Supplier Network

Access equipment through country suppliers and black market contacts:

**Supplier Relationship Mechanics:**

| Relationship | Effect | Price Multiplier | Stock Availability |
|---|---|---|---|
| Enemy (-100) | Blocked access | N/A | 0% (unavailable) |
| Hostile (-50) | Limited items | 1.5× (50% markup) | 25% |
| Neutral (0) | Standard service | 1.0× (normal) | 100% |
| Allied (+50) | Priority access | 0.8× (20% discount) | 150% |
| Trusted (+100) | Premium benefits | 0.5× (50% discount) | 200% exclusive items |

**Relationship Calculation:**
```
Relationship Change Per Month = (Purchase_Amount / 5000) - (Negative_Events)
- +0.2 per $5,000 in purchases
- -0.5 per failed mission in their territory
- -1.0 per civilian casualty
- -2.0 per discovered atrocity
```

### Procurement Order System

Submit purchase requests to suppliers for delivery:

**Order Process:**
1. Select item from supplier catalog
2. Set quantity (bulk discount: 5+ items = 5% off, 20+ = 15% off, 50+ = 25% off)
3. Confirm cost and delivery time
4. Funds deducted from organization account
5. Delivery arrives at base after delay period

**Delivery Times:**
- Same-region supplier: 1-3 days
- Different-region supplier: 3-7 days
- Black market: 5-14 days (higher risk, longer time)
- Expedited delivery (+50% cost): Cuts delivery time in half

**Order Limits:**
- Maximum 5 active orders per supplier
- Minimum order value: 500 credits
- Bulk order discounts apply automatically
- Payment required upfront (non-refundable if cancelled)

### Equipment Tiering & Availability

Equipment availability locked by technology progression:

**Tech Tier Gates:**

| Tier | Research Unlock | Example Items |
|---|---|---|
| Tier 1 (Human) | Ballistics 101 | Pistols, Rifles, Light Armor |
| Tier 2 (Advanced) | Plasma Theory | Plasma Rifles, Combat Armor |
| Tier 3 (Alien Tech) | Alien Research | Plasma Cannons, Powered Armor |
| Tier 4 (Strategic) | Strategic Tech | Plasma Cannons, Advanced Armor |
| Tier 5 (Endgame) | Ultimate Research | Experimental Weapons, Prototype Armor |

**Supplier Specialization:**
- Military Contractors: Standard weapons, explosives
- Research Companies: Advanced tech, prototypes (premium pricing)
- Black Market: Rare items, restricted equipment, illegal modifications
- Alien Technology: Captured alien equipment (rare, expensive)

### Inter-Base Transfer System

Move equipment between bases via transport aircraft:

**Transfer Mechanics:**
- Any item can be transferred via transport craft
- Transfer time: (Distance in hexes) × 1 day + 1 day base loading
- Transfer cost: 100 credits + 10 credits per kg transported
- Supply line interception risk: Higher during conflict zones

**Transfer Logistics:**
- Aircraft assignment: "Automatic" or manual craft selection
- Route planning: Can avoid hostile territories (+1 day per hex detour)
- Transfer status: Track in-transit deliveries on Geoscape
- Failed delivery: 50% of items returned/destroyed if aircraft shot down

---



- **Structure**: Folder-based, each tileset contains PNG variations
- **Types**: 
  - Autotiles (self-connecting)
  - Random variants
  - Animations (frame sequences)
  - Directional (8-way)
  - Static
- **Definition**: TOML specifies tile properties (walkable, cover value, priority)
- **Loading**: On-demand per map, cached during session

## Asset Management & Caching

- Tileset caching with invalidation on file changes
- Automatic save points and manual save slots with compression
- Mod asset loading with precedence system
- Asset validation and dependency tracking

## Mod Creation & Integration

### Mod Structure
- **Basic folder structure** for new mods
  ```
  mods/my_mod/
  ├── mod.toml           # Mod metadata
  ├── content/           # Game content
  │   ├── units/
  │   ├── items/
  │   ├── facilities/
  │   └── missions/
  ├── graphics/          # Sprite assets
  │   └── *.png
  ├── audio/             # Sound assets
  │   ├── music/
  │   └── sfx/
  └── data/              # Configuration
      └── *.toml
  ```

- **Entry point file** definition (`mod.toml`)
  ```toml
  [mod]
  name = "My Awesome Mod"
  version = "1.0.0"
  author = "YourName"
  description = "Description of mod content"
  dependencies = ["core", "optional_mod"]
  ```

- **Asset organization conventions**
  - Graphics: Organize by entity type (units/, items/, etc.)
  - Audio: Separate music and SFX directories
  - Data: One TOML file per entity type

- **Configuration template generation**
  - Tools to auto-generate TOML templates from schemas
  - Type validation for field values
  - Required field detection

### Mod Data Format (TOML)

Standard format for mod data definitions:

```toml
[item]
id = "laser_rifle"
name = "Laser Rifle"
description = "Advanced energy weapon"
type = "weapon"
stats = { damage = 25, accuracy = 85, range = 25, ap_cost = 4 }
weight = 4.5
cost = 5000
research_unlock = "laser_weapons"

[unit]
id = "sectoid_commander"
name = "Sectoid Commander"
class = "Leader"
hp = 45
str = 8
accuracy = 85
psi = 10
abilities = ["psi_damage", "mind_control", "suppress_fire"]

[facility]
id = "plasma_lab"
name = "Plasma Laboratory"
size = { width = 2, height = 2 }
cost = 50000
construction_time = 14
capacity = 1
services = ["research"]
research_unlock = "plasma_weapons"
```

### Load Order & Priority

**Load Sequence:**
1. Core game assets loaded first (baseline functionality)
2. User mods loaded in priority order (defined in load_order.toml)
3. Asset precedence: Later mods override earlier ones
4. Dependency resolution: Mods require their dependencies to load first

**Conflict Resolution:**
- Report conflicts when multiple mods define same ID
- Allow explicit overrides (mod can extend core items)
- Warning system for deprecated features
- Graceful degradation if optional mod unavailable

**Example Load Order:**
```toml
[load_order]
mods = [
  "core",              # Base game content (always first)
  "expanded_weapons",  # Adds new weapons
  "balance_tweaks",    # Modifies core item stats
  "my_campaign"        # Custom campaign (uses all above)
]
```

---

## Testing & Validation

### Asset Validation

**TOML Syntax Validation:**
- Check valid TOML syntax before loading
- Report line numbers for errors
- Suggest fixes for common mistakes

**Required Field Checking:**
- Validate all required fields present
- Type validation for values (string, number, array)
- Range validation (0-100 for percentages)

**Cross-Reference Validation:**
- Verify item references exist (e.g., research_unlock field)
- Check for circular dependencies
- Ensure all assets referenced in data files exist

**Automated Checks:**
- Naming conventions (snake_case IDs)
- Icon size consistency (all UI icons 24×24)
- Color palette validation (matches theme)
- Balance values within reasonable ranges

**Warning System for Deprecated Features:**
- Flag use of old/deprecated fields
- Suggest migration path
- Provide version upgrade guide

**Compatibility Checking:**
- Game version compatibility validation
- Mod dependency version checking
- API version verification

### Testing Framework

**Load Testing:**
- Load specific mods in test environment
- Compare expected vs actual outcomes
- Verify data integrity after loading

**Performance Profiling:**
- Track asset memory usage
- Monitor load times per scene
- Measure FPS with mod assets

**Automated Tests:**
- Asset loading validation
- TOML parsing correctness
- Sprite coordinate accuracy
- Audio file integrity

---



