# Example Mod - Comprehensive Modding Reference

This mod serves as a complete reference implementation demonstrating all modding capabilities available in Alien Fall. It showcases every configuration type, proper folder structure, and best practices for mod development.

## Mod Structure

```
example_mod/
├── main.toml              # Mod metadata and content declarations
├── README.md              # This documentation
├── assets/                # Asset files
│   ├── Earth.png          # Mod icon/thumbnail
│   ├── icons.png          # Mod icon sprites
│   ├── custom_sprites.png # Custom game sprites
│   ├── ui_overlays.png    # UI overlay graphics
│   ├── custom_font.ttf    # Custom font file
│   ├── mod_effect.frag    # Shader effects
│   ├── sfx/               # Sound effects
│   │   ├── rifle_fire.wav # Rifle fire sound
│   │   └── explosion.wav  # Explosion sound
│   └── music/             # Background music
│       ├── battle_theme.ogg # Battle music
│       └── victory.ogg    # Victory fanfare
├── config/                # Configuration files
│   ├── assets.toml        # Asset configuration
│   ├── research_tree.toml # Technology tree
│   ├── recipes.toml       # Manufacturing recipes
│   ├── ui_config.toml     # UI styling and themes
│   ├── world.toml         # World/geography configuration
│   ├── events.toml        # Custom events
│   ├── logging.toml       # Mod-specific logging
│   ├── save_config.toml   # Custom save sections
│   └── hooks.toml         # Lifecycle hooks
├── data/                  # Game data catalogs
│   ├── units/
│   │   └── units.toml     # Unit definitions
│   ├── items/
│   │   └── items.toml     # Item definitions
│   ├── weapons/
│   │   └── weapons.toml   # Weapon definitions
│   ├── armor/
│   │   └── armor.toml     # Armor definitions
│   ├── missions/
│   │   └── missions.toml  # Mission definitions
│   ├── facilities/
│   │   └── facilities.toml # Facility definitions
│   └── research/
│       └── research.toml  # Research definitions
├── locale/                # Localization files
│   ├── en.toml            # English translations
│   └── es.toml            # Spanish translations
├── logs/                  # Log files (created at runtime)
│   ├── example_mod.log    # Main mod log
│   ├── example_mod_errors.log # Error log
│   └── example_mod_debug.log # Debug log
└── scripts/               # Lua script extensions
    ├── hooks.lua          # Hook implementations
    ├── events.lua         # Event handlers
    └── ui.lua             # UI extensions
```

## Configuration Files

### Core Mod Files

#### main.toml
- **Purpose**: Defines mod metadata, dependencies, and content declarations
- **Required**: Yes
- **Sections**:
  - `[metadata]`: Name, version, author, description
  - `[dependencies]`: Required mods and versions
  - `[content]`: Lists all provided content files

#### assets.toml
- **Purpose**: Configures asset loading, paths, and preprocessing
- **Required**: No
- **Features**:
  - Asset path mappings
  - Image preprocessing (scaling, color correction)
  - Font loading and sizing
  - Sound configuration

### Data Catalogs

Each data catalog contains arrays of game objects. All catalogs follow the same structure:

#### units.toml
- **Purpose**: Defines playable units, soldiers, and characters
- **Required**: No
- **Content**: Unit stats, abilities, equipment slots

#### items.toml
- **Purpose**: Defines consumable items, resources, and materials
- **Required**: No
- **Content**: Item properties, effects, stack sizes

#### weapons.toml
- **Purpose**: Defines weapons and their combat statistics
- **Required**: No
- **Content**: Damage, range, accuracy, ammo types

#### armor.toml
- **Purpose**: Defines armor and protective equipment
- **Required**: No
- **Content**: Defense values, weight, mobility penalties

#### missions.toml
- **Purpose**: Defines mission types and objectives
- **Required**: No
- **Content**: Mission parameters, rewards, difficulty

#### facilities.toml
- **Purpose**: Defines base facilities and buildings
- **Required**: No
- **Content**: Construction costs, effects, requirements

#### research.toml
- **Purpose**: Defines research projects and technologies
- **Required**: No
- **Content**: Research costs, prerequisites, unlocks

### Advanced Configuration

#### research_tree.toml
- **Purpose**: Defines the technology tree structure
- **Required**: No
- **Content**: Tech dependencies, unlock chains, research paths

#### recipes.toml
- **Purpose**: Defines manufacturing and production recipes
- **Required**: No
- **Content**: Input materials, output items, production times

#### ui_config.toml
- **Purpose**: Customizes UI appearance and behavior
- **Required**: No
- **Content**: Colors, fonts, layouts, grid settings

#### world.toml
- **Purpose**: Configures world geography and regions
- **Required**: No
- **Content**: Provinces, terrain, strategic locations

#### events.toml
- **Purpose**: Defines custom game events and triggers
- **Required**: No
- **Content**: Event conditions, effects, probabilities

#### logging.toml
- **Purpose**: Configures mod-specific logging behavior
- **Required**: No
- **Content**: Log levels, output destinations, filters

#### save_config.toml
- **Purpose**: Defines custom save game sections
- **Required**: No
- **Content**: Save data structures, versioning, migration

#### hooks.toml
- **Purpose**: Registers lifecycle hooks for mod integration
- **Required**: No
- **Content**: Hook definitions, priorities, conditions

### Localization

#### locale/*.toml
- **Purpose**: Provides translations for mod content
- **Required**: No (but recommended for international mods)
- **Structure**: Key-value pairs for all translatable strings

### Scripts

#### scripts/hooks.lua
- **Purpose**: Implements lifecycle hooks
- **Required**: No
- **Content**: Functions called at specific game events

#### scripts/events.lua
- **Purpose**: Handles custom event logic
- **Required**: No
- **Content**: Event trigger functions and effects

#### scripts/ui.lua
- **Purpose**: Extends or modifies UI behavior
- **Required**: No
- **Content**: UI customization and new widget definitions

## Best Practices

### File Organization
- Keep related configurations in appropriate subdirectories
- Use consistent naming conventions
- Group localization files in `locale/` directory
- Place scripts in `scripts/` directory

### Content Design
- Use unique IDs for all game objects
- Provide fallbacks for missing assets
- Include comprehensive descriptions
- Test configurations with the game engine

### Compatibility
- Specify mod dependencies clearly
- Use version ranges for compatibility
- Document breaking changes
- Test with different mod combinations

### Performance
- Minimize script execution time
- Cache expensive operations
- Use efficient data structures
- Profile mod impact on game performance

## Development Workflow

1. **Plan**: Design your mod concept and required configurations
2. **Structure**: Create the proper folder hierarchy
3. **Implement**: Write TOML configurations and Lua scripts
4. **Test**: Validate with the game engine and test suite
5. **Document**: Update README and provide usage instructions
6. **Package**: Ensure all files are included and properly referenced

## API Reference

For complete API documentation, see `GAME API.toml` in the project root. This file contains all available configuration options, data structures, and scripting interfaces.

## Support

- Check the main project documentation for detailed guides
- Review existing mods for implementation examples
- Test configurations using the built-in validation tools
- Report issues with clear reproduction steps
#
# ## Development
# - Edit `main.toml` to change mod metadata
# - Add new items to the appropriate data files
# - Each data file should contain only one type of item
# - Use arrays (`[[item_type]]`) to define multiple items
# - Test by running the game with console enabled