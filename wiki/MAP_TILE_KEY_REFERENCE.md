# Map Tile KEY Quick Reference

**Quick lookup for all Map Tile KEYs defined in core tilesets**

---

## Common Terrain (_common)

| KEY | Description | Properties |
|-----|-------------|------------|
| `GRASS` | Grass terrain | Passable, no cover |
| `DIRT` | Dirt terrain | Passable, no cover |
| `WATER` | Water terrain | Not passable, blocks LOS |
| `ROCK` | Rock terrain | Not passable, full cover, blocks LOS |
| `SAND` | Sand terrain | Passable, no cover |
| `SNOW` | Snow terrain | Passable, no cover |
| `MUD` | Mud terrain | Passable (slow), no cover |
| `ICE` | Ice terrain | Passable (slippery), no cover |

---

## Urban Terrain (city)

| KEY | Description | Properties |
|-----|-------------|------------|
| `WALL_BRICK` | Brick wall | Not passable, full cover, blocks LOS, destructible, **4 damage states** |
| `WALL_CONCRETE` | Concrete wall | Not passable, full cover, blocks LOS, high health |
| `WINDOW_GLASS` | Glass window | Not passable, partial cover, destructible, fragile |
| `DOOR_WOOD` | Wooden door | Not passable, low cover, destructible, flammable |
| `FLOOR_TILE` | Tile flooring | Passable, no cover |
| `FLOOR_WOOD` | Wood flooring | Passable, no cover, flammable |
| `ROAD_ASPHALT` | Asphalt road | Passable, no cover |
| `SIDEWALK_CONCRETE` | Concrete sidewalk | Passable, no cover |
| `STREETLIGHT` | Street light | Passable, no cover, destructible |
| `FIRE_HYDRANT` | Fire hydrant | Not passable, low cover, destructible |
| `MAILBOX` | Mailbox | Not passable, low cover, destructible |
| `TRASH_BIN` | Trash bin | Not passable, low cover, flammable |
| `BENCH` | Park bench | Not passable, low cover, flammable |
| `PARKING_METER` | Parking meter | Passable, no cover, destructible |

---

## Rural Terrain (farmland)

| KEY | Description | Properties |
|-----|-------------|------------|
| `TREE_PINE` | Pine tree | Not passable, partial cover, destructible, flammable, **4 variants** |
| `TREE_OAK` | Oak tree | Not passable, partial cover, destructible, flammable, **4 variants** |
| `FENCE_WOOD` | Wooden fence | Not passable, low cover, destructible, flammable |
| `FENCE_CHAIN` | Chain-link fence | Not passable, no cover |
| `HAY_BALE` | Hay bale | Not passable, partial cover, flammable |
| `BARN_WALL` | Barn wall (wood) | Not passable, full cover, blocks LOS, flammable |
| `BARN_DOOR` | Barn door | Not passable, low cover, flammable |
| `CROP_WHEAT` | Wheat field | Passable, no cover, flammable |
| `CROP_CORN` | Corn field | Passable, partial cover, flammable |
| `WELL` | Water well | Not passable, partial cover |
| `SCARECROW` | Scarecrow | Passable, no cover, flammable |
| `TRACTOR` | Tractor | Not passable, full cover, destructible |

---

## Furniture (furnitures)

| KEY | Description | Properties |
|-----|-------------|------------|
| `CHAIR` | Chair | Not passable, low cover, flammable |
| `TABLE_SMALL` | Small table | Not passable, low cover, flammable |
| `TABLE_LARGE` | Large table | Not passable, partial cover, flammable, **2×2 occupy mode** |
| `DESK` | Office desk | Not passable, partial cover, flammable |
| `SHELF` | Shelf | Not passable, low cover, flammable |
| `CABINET` | File cabinet | Not passable, partial cover, destructible |
| `BED` | Bed | Not passable, low cover, flammable, **2×1 occupy mode** |
| `SOFA` | Sofa | Not passable, partial cover, flammable, **2×1 occupy mode** |
| `TV` | Television | Not passable, low cover, destructible |
| `COMPUTER` | Computer desk | Not passable, low cover, destructible |
| `PLANT_POTTED` | Potted plant | Passable, no cover, destructible |
| `LAMP_FLOOR` | Floor lamp | Passable, no cover, destructible |
| `LAMP_TABLE` | Table lamp | Passable, no cover, destructible |
| `BOOKSHELF` | Bookshelf | Not passable, partial cover, flammable |

---

## Military Equipment (weapons)

| KEY | Description | Properties |
|-----|-------------|------------|
| `CRATE_AMMO` | Ammo crate | Not passable, partial cover, explosive |
| `CRATE_WEAPON` | Weapon crate | Not passable, partial cover, destructible |
| `CRATE_SUPPLY` | Supply crate | Not passable, partial cover, destructible |
| `WEAPON_RACK` | Weapon rack | Not passable, low cover, destructible |
| `LOCKER_METAL` | Metal locker | Not passable, partial cover |
| `SANDBAG_WALL` | Sandbag wall | Not passable, partial cover, destructible |
| `BARRICADE_WOOD` | Wood barricade | Not passable, low cover, flammable |
| `BARREL_METAL` | Metal barrel | Not passable, partial cover, destructible |
| `BARREL_EXPLOSIVE` | Explosive barrel | Not passable, low cover, **explosive**, flammable |
| `GENERATOR` | Generator | Not passable, full cover, destructible |
| `RADAR_DISH` | Radar dish | Not passable, full cover, destructible |
| `TENT` | Military tent | Not passable, low cover, flammable, **2×2 occupy mode** |

---

## Alien Structures (ufo_ship)

| KEY | Description | Properties |
|-----|-------------|------------|
| `WALL_ALIEN_HULL` | Alien hull wall | Not passable, full cover, blocks LOS, **very high health** |
| `FLOOR_ALIEN_ALLOY` | Alien alloy floor | Passable, no cover |
| `DOOR_ALIEN` | Alien door | Not passable, partial cover, high health |
| `CONSOLE_ALIEN` | Alien console | Not passable, partial cover, destructible |
| `CONSOLE_NAVIGATION` | Navigation console | Not passable, full cover, destructible, **2×1 occupy mode** |
| `EQUIPMENT_ALIEN` | Alien equipment | Not passable, partial cover, destructible |
| `POWER_SOURCE` | UFO power source | Not passable, full cover, **explosive**, **2×1 occupy mode** |
| `TANK_ALIEN` | Alien fuel tank | Not passable, full cover, **explosive**, **2×2 occupy mode** |
| `POD_STASIS` | Stasis pod | Not passable, partial cover, destructible |
| `DEBRIS_ALIEN` | Alien debris | Passable, low cover |
| `SCORCH_MARK` | Scorch marks | Passable, no cover |
| `FIRE` | Fire (active) | Not passable, **animated**, damages units |

---

## Multi-Tile Examples

### Variants (Random Selection)
- `TREE_PINE`: 4 variants (different tree shapes)
- `TREE_OAK`: 4 variants (different tree shapes)

### Animations (Sprite Cycling)
- `FIRE`: Animated flames (4 frames, 200ms per frame)

### Autotiles (Neighbor-Based)
- (Not yet defined in base tilesets - planned for walls/roads)

### Occupy Mode (Multi-Cell)
- `TABLE_LARGE`: 2×2 cells
- `BED`: 2×1 cells
- `SOFA`: 2×1 cells
- `TENT`: 2×2 cells
- `CONSOLE_NAVIGATION`: 2×1 cells
- `POWER_SOURCE`: 2×1 cells
- `TANK_ALIEN`: 2×2 cells

### Damage States (Health-Based)
- `WALL_BRICK`: 4 states (pristine → light damage → heavy damage → destroyed)

---

## Key Properties Reference

### Passability
- **Passable:** Units can walk through
- **Not passable:** Blocks unit movement

### Cover
- **No cover:** 0% protection
- **Low cover:** 25% protection
- **Partial cover:** 50% protection
- **Full cover:** 75% protection

### Line of Sight
- **Blocks LOS:** Units cannot see through
- **No LOS block:** Units can see through

### Destructibility
- **Destructible:** Can be damaged and destroyed
- **Indestructible:** Cannot be damaged

### Special Properties
- **Flammable:** Can catch fire
- **Explosive:** Explodes when destroyed
- **High health:** Takes many hits to destroy
- **Very high health:** Takes very many hits to destroy

---

## Usage Examples

### In Map Block TOML
```toml
[tiles]
"5_3" = "WALL_BRICK"          # Single brick wall
"6_3" = "DOOR_WOOD"            # Wooden door
"10_5" = "TABLE_LARGE"         # 2×2 table (occupies 10_5, 11_5, 10_6, 11_6)
"12_8" = "TREE_PINE"           # Random pine tree variant
"7_10" = "FIRE"                # Animated fire
```

### In Map Script TOML
```toml
[[commands]]
type = "addBlock"
groups = [1]                   # Urban blocks (group 1)
freqs = [10, 20, 15]          # Weighted selection
size = [1, 1]                 # 15×15 blocks
```

---

## Adding New Map Tiles

1. **Choose KEY:** Use UPPER_SNAKE_CASE (e.g., `LAMP_CEILING`)
2. **Choose Tileset:** Pick appropriate folder (city, farmland, etc.)
3. **Create PNG:** 24×24 pixels (or multiples for multi-tile)
4. **Add to TOML:** Define in `mods/core/tilesets/[folder]/tilesets.toml`
5. **Test:** Run `lovec engine` and check console for errors

**Example:**
```toml
[[maptile]]
key = "LAMP_CEILING"
image = "lamp_ceiling.png"
passable = true
blocksLOS = false
cover = 0
health = 10
destructible = true
flammable = false
```

---

## See Also

- **`wiki/TILESET_SYSTEM.md`** - Complete tileset documentation
- **`wiki/MAPBLOCK_GUIDE.md`** - Map Block creation guide
- **`wiki/MAP_SCRIPT_REFERENCE.md`** - Map Script command reference
- **`engine/battlescape/data/maptile.lua`** - MapTile class source
- **`engine/battlescape/data/tilesets.lua`** - Tilesets loader source

---

**Last Updated:** October 13, 2025  
**Total Map Tiles:** 64+  
**Tilesets:** 6 (_common, city, farmland, furnitures, weapons, ufo_ship)
