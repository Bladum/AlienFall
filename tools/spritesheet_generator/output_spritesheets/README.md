# Spritesheet Generator Output

## Goal / Purpose

The Output_spritesheets folder contains generated sprite sheet images and data produced by the spritesheet generator tool. These are build artifacts generated from source graphics.

## Content

- Generated sprite sheet images
- Sprite metadata files
- Texture atlases
- Sprite mapping data
- Generated asset files

## What's in Here

This folder contains:
- PNG/image files of sprite sheets
- JSON/TOML sprite definitions
- Collision and animation data
- Texture atlas mappings
- Build output from generator

## Using Generated Files

Generated files:
1. **Are build artifacts** - Regenerated from sources
2. **Should NOT be edited** - Edit source, regenerate
3. **Can be deleted** - Will be regenerated
4. **Are version-controlled** - Include in repo
5. **Are used by engine** - Loaded at runtime

## Regenerating Spritesheets

When source graphics change:

```bash
./spritesheet_generator/run_spritesheet_generator.bat
```

Or:

```bash
lovec spritesheet_generator
```

## Workflow

1. Edit source graphics
2. Run spritesheet generator
3. Verify output looks correct
4. Commit generated files
5. Engine loads generated files

## See Also

- [Spritesheet Generator](../README.md) - Generator tool documentation
- [Tools README](../../README.md) - Tools overview
- [Asset Pipeline Instructions](.../.github/instructions/🎨%20Asset%20Pipeline%20&%20Workflow.instructions.md)
