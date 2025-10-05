# Smoke & Fire

## Table of Contents
- [Overview](#overview)
- [Mechanics](#mechanics)
  - [Tile Hazard State Model](#tile-hazard-state-model)
  - [Visibility and Occlusion Integration](#visibility-and-occlusion-integration)
  - [Per-Turn Effect Application](#per-turn-effect-application)
  - [Propagation and Spread System](#propagation-and-spread-system)
  - [Dissipation and Duration Control](#dissipation-and-duration-control)
  - [Extinguish and Control Mechanisms](#extinguish-and-control-mechanisms)
  - [Burning Status Processing](#burning-status-processing)
- [Examples](#examples)
  - [Chokepoint Area Denial](#chokepoint-area-denial)
  - [Overwatch Lane Breaking](#overwatch-lane-breaking)
  - [Concealed Approach Masking](#concealed-approach-masking)
  - [Sight-Gated Ability Disruption](#sight-gated-ability-disruption)
  - [Fuel Cache Flame Traps](#fuel-cache-flame-traps)
  - [Formation Morale Pressure](#formation-morale-pressure)
- [Related Wiki Pages](#related-wiki-pages)
- [References to Existing Games and Mechanics](#references-to-existing-games-and-mechanics)

## Overview

Smoke and Fire represent deterministic tile hazards providing area denial, concealment, and environmental damage mechanics within missions. Hazards alter visibility through LoS/LoF occlusion budgets, apply persistent statuses (burning, stun, morale penalties) per turn, and propagate through seeded RNG for reproducible environmental cascades. Data-driven spread, intensity, and fuel rules enable extensive tuning while comprehensive provenance logging supports debug and replay of mission flow influences. Protection systems through gas masks, sealed armor, and fire resistance create strategic equipment choices.

## Mechanics

### Tile Hazard State Model
- Hazard Record: Boolean flags for smoke/fire presence, optional gas type, intensity scale (0-100)
- Fuel Tagging: Optional fuel type for spread calculations and propagation modifiers
- Unit Protection: Gas mask, sealed armor, and fire resistance flags with effectiveness values
- Seeded RNG: All random elements use mission-seeded streams for deterministic reproducibility
- State Persistence: Hazards maintain creation time, spread history, and extinguish attempts

### Visibility and Occlusion Integration
- Smoke Penalty: Reduces sight along any line passing through tile (-4 default sight points)
- Fire Penalty: Additional visibility reduction (-3 default sight points)
- Gas Effects: Type-specific visibility modifiers for specialized hazards
- Intensity Scaling: Penalty magnitude scales with hazard intensity percentage
- LoS/LoF Integration: Penalties apply during planning/execution and UI aim previews

### Per-Turn Effect Application
- Smoke Effects: STUN accumulation for unprotected units (1 STUN/tick default, intensity-scaled)
- Fire Effects: Direct HP damage, morale penalties, and burning status application
- Gas Types: Configurable effects (toxic damage, soporific stun) with protection bypass checks
- Protection Logic: Gas masks/sealed armor block smoke/gas, fire resistance reduces fire damage
- Status Stacking: Multiple hazards combine effects, burning provides periodic damage over time

### Propagation and Spread System
- Deterministic Spread: Base chance × intensity × fuel multiplier × terrain flammability
- Distance Attenuation: Spread probability decreases with tile separation
- Fuel Properties: Wood (1.2×), gasoline (2.0×), dry grass (1.5×) spread multipliers
- Terrain Influence: Stone (0.5×), metal (0.3×), water (0.1×) flammability modifiers
- Chain Reactions: Successful spread can propagate further from newly affected tiles

### Dissipation and Duration Control
- Age-Based Decay: Intensity reduction over time with configurable base decay rate
- Weather Effects: Rain (2× decay), wind (1.2× decay) environmental modifiers
- Terrain Conditions: Wet surfaces accelerate dissipation
- Automatic Removal: Hazards eliminated when intensity reaches zero
- Duration Tracking: Age calculation from creation tick for decay application

### Extinguish and Control Mechanisms
- Method Modifiers: Water (1.2×), extinguisher (1.5×), foam (1.8×) chance bonuses
- Unit Skills: Firefighting ability provides additional success modifiers
- Terrain Bonuses: Wet surfaces improve extinguish effectiveness
- Attempt Tracking: Failed attempts recorded for difficulty scaling
- Self-Extinguish: Burning units have chance to automatically extinguish each tick

### Burning Status Processing
- Duration Range: 3-5 ticks with seeded random determination
- Tick Effects: Configurable damage and AP reduction per turn
- Self-Extinguish Chance: Base probability with terrain/skill modifiers
- Duration Reduction: Automatic expiration after maximum duration
- Provenance Tracking: Complete logging of application, effects, and removal

## Examples

### Chokepoint Area Denial
- Ignition Source: Fuel cache in narrow corridor
- Spread Pattern: High intensity (80) fire propagates to adjacent flammable tiles
- Tactical Effect: Forces enemy pathing around hazard, protecting extraction route
- Duration: 8-12 ticks before natural dissipation
- Strategic Value: Creates persistent no-go zone for 2-3 turns

### Overwatch Lane Breaking
- Deployment: Smoke grenade in line-of-sight corridor
- Visibility Impact: -4 sight points per smoke tile, breaking overwatch coverage
- Movement Window: 3-5 ticks of reduced visibility for repositioning
- Protection Requirements: Enemy gas masks reduce effectiveness
- Counterplay: Wind conditions accelerate smoke dissipation

### Concealed Approach Masking
- Smoke Screen: Multiple smoke sources creating 6-tile concealment area
- Detection Prevention: Reduces sight along approach vectors by 60-80%
- Duration Management: 4-6 ticks before significant dissipation
- Unit Vulnerability: Unprotected units suffer 1 STUN per tick in smoke
- Mission Integration: Enables undetected objective proximity

### Sight-Gated Ability Disruption
- Heavy Smoke: High-intensity smoke blocking sniper lanes
- Effectiveness: -4 visibility penalty breaks line-of-fire for psionic abilities
- Duration: 5-8 ticks with wind acceleration potential
- Strategic Timing: Deployed before enemy ability usage windows
- Countermeasures: Gas mask equipped units maintain effectiveness

### Fuel Cache Flame Traps
- Ignition Trigger: Mission event or player action on gasoline deposits
- Propagation: 2.0× spread multiplier creates rapid 8-12 tile hazard zone
- Burning Effects: 5 HP/tick damage, morale penalties, persistent DoT
- Area Denial: Punishes camping behaviors near fuel sources
- Repair Prevention: Damages nearby objectives and equipment

### Formation Morale Pressure
- Sustained Burning: Multiple fire sources among defender positions
- Morale Impact: -10 per tick, triggering panic cascade potential
- Psychological Effect: Creates pressure for withdrawal or repositioning
- Duration: 6-10 ticks with extinguish attempts reducing effectiveness
- Squad Integration: Combines with suppression for enhanced psychological impact

## Related Wiki Pages

- [Terrain damage.md](../battlescape/Terrain%20damage.md) - Fire can cause terrain damage and destruction.
- [Lighting & Fog of War.md](../battlescape/Lighting%20&%20Fog%20of%20War.md) - Smoke affects visibility and lighting conditions.
- [Unit actions.md](../battlescape/Unit%20actions.md) - Actions taken in or around smoke and fire hazards.
- [Wounds.md](../battlescape/Wounds.md) - Burning status causes wounds and damage over time.
- [Morale.md](../battlescape/Morale.md) - Fire and smoke can affect unit morale.
- [Line of sight.md](../battlescape/Line%20of%20sight.md) - Smoke blocks line of sight.
- [Movement.md](../battlescape/Movement.md) - Hazards affect movement through areas.
- [Grenades.md](../battlescape/Grenades.md) - Smoke grenades create smoke hazards.
- [Accuracy at Range.md](../battlescape/Accuracy%20at%20Range.md) - Visibility penalties affect ranged accuracy.
- [Unconscious.md](../battlescape/Unconscious.md) - Severe burning can lead to unconsciousness.

## References to Existing Games and Mechanics

- X-COM series: Smoke grenades for concealment and area denial, plasma weapons causing fire damage.
- Fire Emblem series: Terrain hazards like lava or fire that damage units over time.
- Advance Wars: Weather effects and environmental hazards affecting unit performance.
- Dungeons & Dragons: Fire damage and smoke effects in combat encounters.
- Battlefield series: Environmental destruction and fire propagation in maps.
- Silent Hill: Psychological effects of smoke and fire in horror settings.
- Warhammer 40k: Flamers and incendiary weapons creating fire zones.
- Fallout: Radiation and environmental hazards with persistent effects.

