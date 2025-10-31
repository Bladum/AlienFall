# Craft Capacity Model Specification

> **Status**: Design Document
> **Last Updated**: 2025-10-31
> **Related Systems**: Crafts.md, Missions.md, Pilots.md, Geoscape.md, Units.md
> **Source Note**: Resolves CRITICAL_008 craft capacity contradictions

## Table of Contents

- [Overview](#overview)
- [Craft Types & Capacities](#craft-types--capacities)
- [Pilot Slots Model](#pilot-slots-model)
- [Squad Composition & Deployment](#squad-composition--deployment)
- [Transport Logistics](#transport-logistics)
- [Craft Availability & Scheduling](#craft-availability--scheduling)
- [Inter-Base Craft Assignment](#inter-base-craft-assignment)
- [Mission Squad Assignment](#mission-squad-assignment)
- [Special Deployment Scenarios](#special-deployment-scenarios)
- [Implementation Examples](#implementation-examples)
- [Balance Parameters](#balance-parameters)
- [Testing Scenarios](#testing-scenarios)
- [Review Checklist](#review-checklist)

---

## Overview

### System Architecture

The craft capacity model defines how soldiers and pilots are transported to and from mission sites. This system creates strategic bottlenecks around limited pilots and transport capacity, forcing players to make difficult choices about squad composition and mission assignment.

**Design Philosophy**

Craft capacity creates meaningful resource constraints without being overly punitive. The model balances accessibility (players can deploy reasonable squads) with challenge (limited pilots create strategic trade-offs).

**Core Principle**: Transport capacity is a strategic resource that shapes mission planning and base development.

---

## Craft Types & Capacities

### Craft Classification

| Craft Class | Primary Role | Soldier Capacity | Pilot Capacity | Total Capacity | Notes |
|-------------|--------------|------------------|----------------|----------------|-------|
| **Interceptor** | Air combat | 0 | 1 (+1 optional) | 1-2 | Fast fighter, no troop transport |
| **Transport** | Troop carrier | 4-8 | 2 (required) | 6-10 | Dedicated dropship, VTOL capable |

### Detailed Capacity Specifications

#### Interceptor Craft

**Capacity**: 1 pilot (primary) + 1 optional copilot
**Soldier Capacity**: 0 (fighters cannot carry troops)
**Use Case**: Interception missions, air superiority
**Crew Requirements**: Minimum 1 pilot, maximum 2 crew

#### Transport Craft

**Capacity**: 4-8 soldiers + 2 pilots (primary + copilot)
**Soldier Capacity**: Variable based on mission requirements
**Use Case**: Ground troop deployment and extraction
**Crew Requirements**: Always 2 pilots (primary + copilot)

---

## Pilot Slots Model

### Primary Pilot + Optional Copilot

Every craft requires exactly one **Primary Pilot** who controls the craft and makes critical decisions. Some craft support an **Optional Copilot** who provides support functions.

#### Pilot Roles

**Primary Pilot**:
- Required for all craft
- Controls flight systems
- Makes tactical decisions
- Takes primary risk in combat

**Copilot**:
- Optional enhancement
- Provides support functions
- Can take over if primary pilot incapacitated
- Shares experience and stress

#### Craft-Specific Pilot Requirements

| Craft Type | Primary Pilot | Copilot | Total Crew |
|------------|---------------|---------|------------|
| Interceptor | Required | Optional | 1-2 |
| Transport | Required | Required | 2 |

**Rationale**: Transports require copilots for complex VTOL operations and soldier coordination.

---

## Squad Composition & Deployment

### Squad Size Specification

**Standard Squad Sizes**:

| Squad Type | Soldier Count | Transport Requirement | Use Case |
|------------|---------------|----------------------|----------|
| **Skeleton** | 3 | 1 transport | Emergency/rescue |
| **Standard** | 4-6 | 1 transport | Most missions |
| **Large** | 7-8 | 2 transports | Major operations |

### Squad Composition Rules

**Role Requirements**:

| Role | Minimum | Recommended | Maximum | Notes |
|------|---------|-------------|---------|-------|
| **Leader** | 1 | 1 | 1 | Squad commander |
| **Combat** | 2 | 3-4 | 5 | Main fighting force |
| **Support** | 0 | 1 | 2 | Medic, engineer |
| **Specialist** | 0 | 0-1 | 2 | Heavy weapons, sniper |

**Composition Examples**:

```
Standard Squad (5 soldiers):
- 1 Leader (commander)
- 3 Combat soldiers
- 1 Support (medic)

Large Squad (8 soldiers):
- 1 Leader
- 4 Combat soldiers
- 2 Support (medic + engineer)
- 1 Specialist (sniper)
```

---

## Transport Logistics

### Single Transport Missions

**Capacity Utilization**:

```
Transport capacity: 8 soldiers + 2 pilots = 10 total aboard

Standard deployment:
- 6 soldiers + 2 pilots = 8 total (70% capacity)
- Allows for casualties and extraction

Emergency deployment:
- 3 soldiers + 2 pilots = 5 total (50% capacity)
- Quick insertion/extraction
```

### Multi-Transport Missions

**Deployment Strategy**:

```
Large mission (8 soldiers):
Transport A: 4 soldiers + 2 pilots = 6 aboard
Transport B: 4 soldiers + 2 pilots = 6 aboard
Total: 8 soldiers + 4 pilots = 12 aboard

Deployment sequence:
1. Both transports enter airspace simultaneously
2. Transport A lands first (T+0:30)
3. Transport B lands second (T+0:45) or holds in air
4. Squad deploys from both transports
5. Extraction: Both transports available for pickup
```

**Pilot Requirements for Multi-Transport**:

```
Formula: Pilots needed = (Transports × 2) + 1 reserve

Examples:
- 1 transport: 2 pilots + 1 reserve = 3 total
- 2 transports: 4 pilots + 1 reserve = 5 total
- 3 transports: 6 pilots + 1 reserve = 7 total
```

---

## Craft Availability & Scheduling

### Craft Maintenance System

**Post-Mission Status**:

| Damage Level | Repair Time | Availability |
|--------------|-------------|--------------|
| **None** | 0 days | Immediate |
| **Light** | 1-2 days | Limited |
| **Moderate** | 3-4 days | Unavailable |
| **Heavy** | 5-7 days | Unavailable |
| **Destroyed** | Permanent | Lost |

### Pilot Availability Factors

**Pilot Status System**:

| Status | Duration | Can Fly? | Notes |
|--------|----------|----------|-------|
| **Healthy** | N/A | Yes | Normal operation |
| **Stressed** | 1-3 days | Yes (-1 piloting) | Fatigue penalty |
| **Injured** | 2-5 days | No | Recovery time |
| **Incapacitated** | 1-3 weeks | No | Serious injury |

**Stress Accumulation**:
- Each mission flown: +1 stress
- Rest day at base: -1 stress
- Maximum stress: 5 (cannot fly)
- Forces pilot rotation and rest

---

## Inter-Base Craft Assignment

### Craft Ownership Model

**Base-Specific Assets**:
- Each base owns its own craft
- Craft cannot be easily transferred
- Interceptors: Limited transfer for regional defense
- Transports: Slow transfer (1-2 days travel time)

**Regional Strategy Example**:

```
Base A (threat zone): 3 transports, 6 pilots
Base B (quiet sector): 1 transport, 2 pilots
Base C (research hub): 2 interceptors, 3 pilots

Result: Base A can handle major operations
Base B handles local threats only
Base C focuses on air defense
```

### Pilot Reassignment

**Transfer Mechanics**:
- Pilots can be reassigned between bases
- Travel time: 1-3 days depending on distance
- Maintains pilot experience and stress levels
- Allows strategic redistribution of skilled pilots

---

## Mission Squad Assignment

### UI Flow Specification

**Step 1: Mission Selection**
```
Select mission → System calculates requirements:
- Required: 4-8 soldiers
- Required: 1-2 transports (based on squad size)
- Required: 2-5 pilots (based on transports + reserve)
```

**Step 2: Squad Composition**
```
Choose soldiers:
- Filter by role, health, equipment
- Show fatigue/injury status
- Validate against squad size limits (3-8)
- Check equipment weight vs strength
```

**Step 3: Pilot Assignment**
```
Assign pilots:
- Show piloting skill and stress levels
- Warn about stressed/injured pilots
- Auto-suggest optimal assignments
- Validate pilot requirements met
```

**Step 4: Capacity Validation**
```
Final checks:
- Transport capacity sufficient?
- Pilot crew requirements met?
- Equipment within weight limits?
- Show warnings for violations
```

**Step 5: Launch Confirmation**
```
Display deployment:
- Transport A: Soldiers 1-4 + Pilot + Copilot
- Transport B: Soldiers 5-8 + Pilot + Copilot (if needed)
- Confirm launch or adjust composition
```

### Validation Rules

**Hard Blocks** (Cannot Launch):
- Insufficient transports for squad size
- Not enough pilots for required crew
- Overloaded soldiers (weight > strength capacity)

**Warnings** (Can Launch But Suboptimal):
- Stressed pilots (-1 piloting penalty)
- Injured pilots (risk of incapacitation)
- Suboptimal squad composition

---

## Special Deployment Scenarios

### Reinforcements Policy

**Decision**: No mid-mission reinforcements

**Rationale**:
- Increases mission tension and risk
- Simplifies deployment logistics
- Matches classic XCOM gameplay
- Can be added in future expansion

**Implication**: Squad deploys complete and fights until mission end. No additional soldiers can arrive during combat.

### Multi-Site Missions

**Current Scope**: Single-site missions only

**Future Consideration**: Multi-site missions deferred to expansion
- Phase 1: Assault perimeter
- Phase 2: Clear command center
- Phase 3: Extract

**Current Implementation**: All mission action occurs at single location

---

## Implementation Examples

### Example 1: Standard Mission Deployment

```
Mission: Terror site cleanup
Requirements: 6 soldiers, urban environment

Squad Composition:
- 1 Leader (Sergeant Kelly)
- 4 Combat soldiers (riflemen)
- 1 Medic (support)

Transport: 1 Skyranger
Crew: 2 pilots (Captain Rodriguez + Copilot Chen)

Deployment:
- Transport lands at T+0:30
- All 6 soldiers deploy
- Transport holds position for extraction

Capacity Check: 6 soldiers + 2 pilots = 8/10 (80% capacity) ✓
```

### Example 2: Large Assault Mission

```
Mission: Alien base attack
Requirements: 8 soldiers, heavy combat

Squad Composition:
- 1 Leader
- 5 Combat soldiers
- 2 Support (medic + engineer)

Transports: 2 Skyrangers
Crew: 4 pilots (2 primary + 2 copilot)

Deployment:
- Transport A: Soldiers 1-4 + Pilot A + Copilot A
- Transport B: Soldiers 5-8 + Pilot B + Copilot B

Capacity Check: Each transport 6/10 capacity ✓
Total pilots: 4 + 1 reserve = 5 available ✓
```

### Example 3: Pilot Shortage Scenario

```
Base Status:
- 2 transports available
- 3 pilots available (1 stressed, 2 healthy)
- Mission requires 8 soldiers

Problem: Need 4 pilots + 1 reserve = 5 total
Available: 3 pilots

Solution: Cannot launch (insufficient crew)
UI Message: "Need 2 more pilots. Train pilots or wait for recovery."
```

---

## Balance Parameters

| Parameter | Value | Range | Reasoning | Difficulty Scaling |
|-----------|-------|-------|-----------|-------------------|
| Transport Capacity | 8 soldiers | 6-10 | Allows reasonable squads | No scaling |
| Pilot Requirement | 2 per transport | 2 | Creates bottleneck | No scaling |
| Squad Min Size | 3 soldiers | 2-4 | Emergency capability | No scaling |
| Squad Max Size | 8 soldiers | 6-10 | Major operations | No scaling |
| Pilot Stress Max | 5 | 3-7 | Forces rotation | +1 on Hard |
| Craft Repair Time | 1-7 days | 1-14 | Downtime balance | ×0.5 on Easy |

---

## Testing Scenarios

- [ ] **Squad Size Limits**: Verify 3-8 soldier enforcement
  - **Setup**: Create mission requiring 6 soldiers
  - **Action**: Try to assign 2 soldiers, then 9 soldiers
  - **Expected**: 2 blocked (too small), 9 blocked (too large), 6 allowed
  - **Verify**: UI prevents invalid assignments

- [ ] **Pilot Requirements**: Test crew validation
  - **Setup**: Mission requiring 2 transports (8 soldiers)
  - **Action**: Assign 3 pilots, then 6 pilots
  - **Expected**: 3 pilots blocked (need 5), 6 pilots allowed
  - **Verify**: Launch blocked with insufficient pilots

- [ ] **Transport Capacity**: Test multi-transport distribution
  - **Setup**: 8 soldier squad, 2 transports available
  - **Action**: Assign soldiers to transports
  - **Expected**: Transport A: 4 soldiers, Transport B: 4 soldiers
  - **Verify**: Capacity warnings if uneven distribution

- [ ] **Equipment Overload**: Test weight validation
  - **Setup**: Soldier with STR 5 (50kg capacity)
  - **Action**: Equip 55kg of gear
  - **Expected**: Launch blocked, warning shown
  - **Verify**: Must remove equipment to proceed

- [ ] **Pilot Stress**: Test fatigue system
  - **Setup**: Pilot with 4 stress (max 5)
  - **Action**: Assign to mission
  - **Expected**: Warning shown, -1 piloting penalty applied
  - **Verify**: Mission success chance reduced

---

## Review Checklist

- [ ] Craft capacity matrix complete and consistent
- [ ] Pilot slot model clearly defined
- [ ] Squad composition rules specified
- [ ] Transport logistics explained
- [ ] Multi-base assignments addressed
- [ ] UI flow mockups created
- [ ] Special scenarios decided
- [ ] Balance parameters quantified
- [ ] Testing scenarios comprehensive
- [ ] Cross-references updated
- [ ] Implementation feasible</content>
<parameter name="filePath">c:\Users\tombl\Documents\Projects\design\mechanics\CRAFT_CAPACITY_MODEL.md
