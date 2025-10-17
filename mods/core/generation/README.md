# Procedural Generation Configuration

This directory contains configuration files for all procedural generation systems in AlienFall.

## Files

### map_generation.toml
Configuration for procedural map generation including:
- Map size presets
- Terrain feature distribution rules
- Cover placement algorithms
- Destructible object placement

### mission_generation.toml
Configuration for mission randomization:
- Mission objective variations
- Enemy placement parameters
- Reinforcement wave patterns
- Map layout templates

### entity_generation.toml
Configuration for procedural entity generation:
- Unit stat ranges
- Equipment distribution
- Ability generation
- Level-based scaling

### seed_management.toml
Configuration for deterministic generation:
- Seed generation rules
- Random number distribution
- Reproducibility parameters

## Usage

These TOML files configure the procedural generation systems in the engine. Changes here affect generated content without requiring code modifications.

See `docs/battlescape/procedural_generation.md` for detailed documentation.
