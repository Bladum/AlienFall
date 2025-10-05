# Example Weapon Mod

A complete working example mod that adds a new weapon to Alien Fall.

## What This Mod Does

Adds the **"Thunder Cannon"** - a powerful experimental weapon that fires explosive rounds with area damage but lower accuracy.

## Features Demonstrated

- Complete mod structure
- TOML weapon definition
- Proper manifest (mod.toml)
- Balance considerations
- Asset placeholders
- Documentation

## Installation

1. Copy this entire folder to `mods/`
2. Final path should be: `mods/example_weapon_mod/`
3. Launch the game
4. Enable "Example Weapon Mod" in the mod manager
5. Start a new game or load a save

## How to Use

Once enabled, the Thunder Cannon will:
- Appear in the research tree after completing "Heavy Weapons"
- Be craftable in the workshop
- Be equippable by Heavy and Assault classes
- Appear in supplier inventories (late game)

## Files Included

- `mod.toml` - Mod manifest with metadata
- `data/weapons.toml` - Weapon definition
- `README.md` - This file
- `assets/` - Placeholder for weapon sprites (optional)

## Modding It Further

To create your own weapon mod based on this example:

1. Change the weapon ID in `data/weapons.toml`
2. Adjust stats (damage, accuracy, AP cost, etc.)
3. Modify manufacturing costs
4. Update research requirements
5. Change the mod metadata in `mod.toml`

## Balance Notes

The Thunder Cannon is designed as a tier 3 heavy weapon that trades accuracy for raw power and area damage. It's balanced by:

- High AP cost (5) limits shots per turn
- Lower accuracy (70%) vs other tier 3 weapons (85%)
- Expensive to manufacture (12,000 credits)
- Requires rare materials (Elerium)
- Late-game unlock (requires Heavy Weapons research)

## Compatibility

This mod should be compatible with most other mods unless they also add a weapon with ID "thunder_cannon".

## Credits

Created by: AlienFall Team (Example)
Version: 1.0.0
License: Same as Alien Fall base game

## Support

This is an example mod for educational purposes. For questions about modding, see:
- `/wiki/mods/README.md` - Modding documentation
- `/wiki/mods/Getting_Started.md` - Beginner tutorial
- `/wiki/mods/API_Reference.md` - API documentation
