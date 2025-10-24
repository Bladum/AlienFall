# Basescape Data

## Goal / Purpose
Stores configuration data and lookup tables for basescape systems including facility definitions, costs, requirements, and basescape-specific game rules.

## Content
- **Facility definitions** - Configuration for all facility types
- **Cost tables** - Building and operation costs
- **Resource requirements** - Materials and resources needed for construction
- **Upgrade paths** - Facility upgrade chains and requirements
- **Base level definitions** - Rules for base expansion
- **Default configurations** - Base game settings for basescape

## Features
- TOML-based configuration
- Modular facility definitions
- Cost and requirement tracking
- Upgrade relationship definitions
- Easy modding support

## Integrations with Other Folders / Systems
- **engine/basescape/facilities** - Facility system using this data
- **engine/basescape/base** - Base construction using data
- **engine/basescape/systems** - All basescape systems reference data
- **engine/core/data_loader.lua** - Data loading system
- **mods/core/rules/facilities** - Modded facility data
- **mods/core/generation** - Data used in generation
