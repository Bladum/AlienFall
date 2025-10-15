# Asset Verification Tool

Standalone Love2D utility for verifying game assets and creating placeholders for missing files.

## Purpose

This tool scans all TOML configuration files in the mod system and:
1. **Verifies** that referenced image/sound assets exist
2. **Reports** missing assets with file paths
3. **Creates** placeholder images for missing assets (optional)
4. **Generates** comprehensive verification report

Use this tool:
- **Before commits** to catch missing assets
- **After adding new TOML data** to verify references
- **During mod development** to auto-generate placeholders
- **For debugging** asset loading issues

## Running the Tool

### Method 1: Batch File (Recommended)
```
run_asset_verification.bat
```

### Method 2: Love2D Command
```
lovec "tools\asset_verification"
```

### Method 3: From Project Root
```
lovec tools/asset_verification
```

## What It Checks

**Terrain Types** (`mods/core/terrains/*.toml`):
- Tileset references
- Tile image files
- Object sprite files

**Unit Classes** (`mods/core/units/*.toml`):
- Unit sprite images
- Paper doll images
- Icon files
- Armor sprites

**Items** (`mods/core/items/*.toml`):
- Item icons
- Floor sprites (weapons)
- Hand sprites
- Big sprites (inventory)

**Tilesets** (`mods/core/tilesets/*.toml`):
- Tile images
- Object sprites
- Animated tiles
- Death tiles

## Output

**Console Output:**
```
Starting Asset Verification...
Initializing mod system...
[ModManager] Initialized. Mods folder: mods
[ModManager] Loading core mod...
[ModManager] Core mod loaded

Verifying terrain types...
  ✓ URBAN: 45 assets verified
  ✗ FOREST: 3 missing assets
    - Missing: assets/images/tilesets/forest/tree_01.png
    - Missing: assets/images/tilesets/forest/tree_02.png
    - Missing: assets/images/tilesets/forest/bush_01.png

Verifying unit classes...
  ✓ SOLDIER: 12 assets verified
  ✓ SECTOID: 8 assets verified

Asset verification complete!
Results:
  Terrain types found: 5
  Unit classes found: 8
  Assets verified: 234
  Missing assets: 3
  Placeholders created: 3 (if enabled)
```

**Placeholder Creation:**
- **Format:** PNG image, 32×32 pixels
- **Color:** Magenta/pink (#FF00FF) for visibility
- **Label:** Asset filename drawn on image
- **Location:** Exact path specified in TOML file

## File Structure

```
tools/asset_verification/
├── main.lua                    -- Main application entry
├── conf.lua                    -- Love2D configuration
├── run_asset_verification.bat  -- Quick launch script
└── README.md                   -- This file
```

**Dependencies (from engine/):**
- `core.mod_manager` - Mod system initialization
- `utils.verify_assets` - Asset verification logic

## Configuration

Edit `main.lua` to configure:

```lua
-- Enable/disable placeholder creation
local createPlaceholders = true  -- Set to false to only report

local results = AssetVerifier.run(createPlaceholders)
```

## Placeholder Generation

**When enabled** (default), creates placeholder images for missing assets:

**Placeholder Properties:**
- Size: 32×32 pixels (default tile size)
- Background: Magenta (#FF00FF) for high visibility
- Border: Black 1px border
- Label: Filename centered on image
- Format: PNG with transparency

**Why Placeholders?**
- Prevents Love2D errors when loading missing assets
- Provides visual feedback in-game
- Allows development to continue while assets are created
- Easy to identify (bright magenta color)
- Shows exact filename needed

## Integration with Development

**Workflow:**
1. Add new units/items/terrain to TOML files
2. Run asset verification tool
3. Tool creates placeholders for missing assets
4. Game can now load and run with placeholders
5. Replace placeholders with real assets later
6. Re-run tool to verify all assets complete

**CI/CD Integration:**
```bash
# Run verification without placeholders (report only)
lovec tools/asset_verification --report-only

# Check exit code
if [ $? -ne 0 ]; then
    echo "Asset verification failed!"
    exit 1
fi
```

## Troubleshooting

**Tool won't start:**
- Verify Love2D 12.0+ is installed
- Check console for require() errors
- Ensure engine/ folder exists at `../../engine/`
- Ensure mods/ folder exists at `../../mods/`

**No TOML files found:**
- Check mods/core/ folder structure
- Verify mod_manager initialization
- Check console for mod loading errors

**Placeholders not created:**
- Check write permissions on engine/assets/ folders
- Verify target directory exists
- Check console for file I/O errors
- Ensure Love2D has filesystem write access

**False positives (assets exist but reported missing):**
- Check file path case sensitivity (Lua is case-sensitive)
- Verify TOML file syntax (quotes, paths)
- Check for trailing spaces in TOML paths
- Use forward slashes (/) not backslashes (\)

## See Also

- `wiki/API.md` - Asset system API documentation
- `wiki/TILESET_SYSTEM.md` - Tileset format documentation
- `mods/core/README.md` - Mod structure documentation
- `tools/map_editor/` - Map editor tool
