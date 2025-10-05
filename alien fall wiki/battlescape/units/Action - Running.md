# Running Action System

## Table of Contents
- [Overview](#overview)
- [Mechanics](#mechanics)
  - [Running Mode Activation](#running-mode-activation)
  - [Enhanced Movement Conversion](#enhanced-movement-conversion)
  - [Energy Consumption System](#energy-consumption-system)
  - [Detection and Reaction Integration](#detection-and-reaction-integration)
  - [Path Planning and Resource Validation](#path-planning-and-resource-validation)
  - [UI and Player Communication](#ui-and-player-communication)
- [Examples](#examples)
  - [Rapid Flanking Maneuver](#rapid-flanking-maneuver)
  - [Quick Extraction Scenario](#quick-extraction-scenario)
  - [Hit-and-Run Tactics](#hit-and-run-tactics)
  - [Resource Management Scenarios](#resource-management-scenarios)
- [Related Wiki Pages](#related-wiki-pages)
- [References to Existing Games and Mechanics](#references-to-existing-games-and-mechanics)

## Overview

The Running Action System implements a high-speed movement mode that trades energy consumption and stealth for dramatically increased mobility, creating deliberate tactical trade-offs between speed and survivability. This data-driven system allows designers to tune Action Point-to-movement multipliers, energy costs, and detection penalties to balance burst mobility against tactical risk. Running enables rapid flanking maneuvers, quick extractions, and hit-and-run tactics while maintaining deterministic outcomes through seeded random number generation.

The system integrates seamlessly with existing movement mechanics, applying the same path trimming and resource validation while providing clear UI feedback about energy costs and reaction fire risks. Running transforms tactical positioning from a gradual process into dynamic, high-stakes decisions that reward precise timing and environmental awareness.

## Mechanics

### Running Mode Activation
Toggle-based system for enabling high-speed movement:
- Mode Selection: Explicit player choice to enable/disable running state
- State Persistence: Running mode maintained until manually deactivated
- Resource Validation: Energy threshold checking before activation allowed
- Mode Restrictions: Certain conditions preventing running activation
- UI Indicators: Clear visual feedback showing current movement mode
- Instant Transitions: Immediate switching between movement types

### Enhanced Movement Conversion
Accelerated Action Point-to-distance translation:
- Movement Multiplier: Configurable speed increase (default: 2× normal movement)
- AP Efficiency: Reduced Action Point cost for equivalent distance covered
- Diagonal Scaling: Standard diagonal movement penalties still apply
- Rotation Costs: Facing changes maintain normal movement point costs
- Terrain Integration: Environmental modifiers stack with running bonuses
- Continuous Budget: Fractional AP usage for partial running distances

### Energy Consumption System
Stamina management for high-speed movement:
- Per-AP Drain: Energy consumption per Action Point spent running
- Resource Validation: Minimum energy requirements for running activation
- Consumption Rate: Higher energy cost than normal movement (default: 2×)
- Real-Time Tracking: Continuous energy monitoring during movement planning
- Exhaustion Prevention: Blocking running when energy reserves insufficient
- Partial Execution: Option for reduced running when energy becomes limited

### Detection and Reaction Integration
Increased exposure creating tactical risk:
- Reaction Multiplier: Enhanced overwatch trigger probability (default: 1.5×)
- Detection Enhancement: Higher visibility and sound generation while running
- Trigger Probability: Deterministic chance calculations with seeded RNG
- Multiple Reactions: Potential for multiple overwatch units to respond simultaneously
- Risk Assessment: Clear UI indicators showing reaction fire probability
- Tactical Timing: Critical positioning and cover usage for risk mitigation

### Path Planning and Resource Validation
Movement planning with dual resource constraints:
- Budget Checking: Simultaneous AP and energy resource validation
- Deterministic Trimming: Automatic path reduction when limits exceeded
- Partial Execution: Option to complete partial running moves within limits
- Path Preview: Player feedback showing achievable running distance
- Cost Calculation: Real-time computation of AP and energy expenditures
- Validation Feedback: Clear indicators of movement limitations and constraints

### UI and Player Communication
Comprehensive feedback for informed decision-making:
- Mode Indicators: Visual representation of active running state
- Cost Display: Expected AP and energy consumption breakdown
- Risk Assessment: Qualitative and quantitative reaction danger indicators
- Path Preview: Highlighted achievable running distance visualization
- Resource Warnings: Alerts for insufficient energy or AP reserves
- Tactical Tooltips: Detailed explanations of running trade-offs and consequences

## Examples

### Rapid Flanking Maneuver
Trooper activates running to double movement distance, reaching a flank position in one turn. The speed advantage provides tactical superiority but increases reaction fire risk and drains energy reserves significantly.

### Quick Extraction Scenario
Following objective completion, squad enables running toward extraction point to minimize enemy reinforcement arrival. Path may be trimmed if energy depletes before reaching the evacuation zone, requiring careful resource management.

### Hit-and-Run Tactics
Unit uses running to close distance and engage exposed enemy, then immediately runs back to cover within the same turn. Increased reaction chance makes precise timing and cover positioning critical for success.

### Resource Management Scenarios
- Energy Conservation: Short burst running followed by normal movement to preserve stamina for extended operations
- AP Optimization: Utilizing running to maximize distance covered within turn Action Point limits
- Risk Calculation: Weighing speed advantages against overwatch exposure and reaction probability
- Path Planning: Selecting routes that minimize reaction fire opportunities while maintaining speed
- Tactical Retreat: Running to safety while managing energy depletion and exhaustion prevention
- Coordinated Movement: Squad running in formation to overwhelm overwatch coverage and create opportunities

## Related Wiki Pages

- [Action - Movement.md](../battlescape/Action%20-%20Movement.md) - Base movement system modified by running for increased speed.
- [Unit actions.md](../battlescape/Unit%20actions.md) - Running as an action variant with AP and energy costs.
- [Morale.md](../battlescape/Morale.md) - Running affecting unit morale and panic responses.
- [Panic.md](../battlescape/Panic.md) - Uncontrolled running as panic behavior.
- [Action - Overwatch.md](../battlescape/Action%20-%20Overwatch.md) - Running increasing overwatch trigger risk.
- [Accuracy at Range.md](../battlescape/Accuracy%20at%20Range.md) - Movement penalties for running units.
- [Terrain Elevation.md](../battlescape/Terrain%20Elevation.md) - Height impacts on running speed and energy.
- [Battle map.md](../battlescape/Battle%20map.md) - Map layout influencing running paths.
- [Action - Sneaking.md](../battlescape/Action%20-%20Sneaking.md) - Alternative movement mode with stealth trade-offs.
- [Energy.md](../units/Energy.md) - Energy system for running stamina.
- [Stats.md](../units/Stats.md) - Speed stats affecting running efficiency.
- [Battlescape AI.md](../ai/Battlescape%20AI.md) - AI using running for tactical maneuvers.

## References to Existing Games and Mechanics

The Running Action System draws from sprint mechanics in tactical games:

- **X-COM series (1994-2016)**: Running increasing speed but exposing to overwatch.
- **Jagged Alliance series (1994-2014)**: Running with AP costs and overwatch risk.
- **Tom Clancy's Rainbow Six Siege (2015)**: Sprint with speed but reduced control.
- **Battlefield series (2002-2021)**: Sprint with stamina management.
- **Call of Duty series (2003-2023)**: Sprint mechanics with stamina depletion.
- **Ghost Recon series (2001-2017)**: Tactical running with noise and overwatch.
- **Insurgency (2014)**: Realistic running with stamina and accuracy penalties.
- **Arma series (2006-2023)**: Stamina-based running with fatigue mechanics.

