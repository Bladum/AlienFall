# Policies

## Table of Contents
- [Overview](#overview)
- [Mechanics](#mechanics)
  - [Policy Categories](#policy-categories)
  - [Policy Slots](#policy-slots)
  - [Policy Activation](#policy-activation)
  - [Policy Modifiers](#policy-modifiers)
- [System Integration](#system-integration)
  - [Funding System Integration](#funding-system-integration)
  - [Recruitment System Integration](#recruitment-system-integration)
  - [Research System Integration](#research-system-integration)
  - [Operations System Integration](#operations-system-integration)
- [Examples](#examples)
  - [Funding Policy Examples](#funding-policy-examples)
  - [Recruitment Policy Examples](#recruitment-policy-examples)
  - [Operations Policy Examples](#operations-policy-examples)
  - [Policy Combination Examples](#policy-combination-examples)
- [Related Wiki Pages](#related-wiki-pages)
- [References to Existing Games and Mechanics](#references-to-existing-games-and-mechanics)

## Overview

The Policies system enables players to implement organizational directives that provide persistent modifiers to various game systems. Policies represent strategic choices that automate recurring decisions and create distinct playstyles through trade-offs between benefits and costs. The system uses a slot-based approach to force prioritization and maintain balance, with policies that can be changed monthly to adapt to evolving campaign needs.

Key design principles include:
- Slot-Based Limitation: Restricted number of active policies forces strategic prioritization
- Monthly Change Cadence: Semi-permanent commitments with periodic reassessment opportunities
- Benefit-Cost Trade-offs: All policies provide advantages while imposing drawbacks
- Data-Driven Design: Configurable effects, requirements, and interactions for moddability
- Deterministic Application: Consistent and reproducible policy effects

## Mechanics

### Policy Categories
Policies are organized into thematic categories that affect different aspects of organizational operations.

Funding Policies:
- Focus on financial management and resource allocation
- Affect research funding, public grants, and operational costs
- Examples: Budget diversion, transparency initiatives, austerity measures

Recruitment Policies:
- Influence personnel acquisition and quality
- Modify hiring speed, candidate screening, and training costs
- Examples: Aggressive expansion, selective quality focus, specialized recruitment

Operations Policies:
- Impact tactical and strategic execution capabilities
- Affect interception success, resource consumption, and readiness levels
- Examples: Rapid deployment protocols, conservation measures, readiness maintenance

Research Policies:
- Modify technological development and scientific progress
- Influence research speed, project costs, and breakthrough probabilities
- Examples: Accelerated development, focused specialization, resource optimization

Security Policies:
- Affect organizational secrecy and detection management
- Modify visibility, intelligence gathering, and covert capabilities
- Examples: Information control, operational security, intelligence prioritization

### Policy Slots
The system uses a limited slot mechanism to prevent over-specialization and maintain strategic tension.

Slot Distribution:
- Total Slots: Base of 2 slots, increasing with company level (+1 every 2 levels)
- Category Limits: Maximum slots per category (funding: 1, recruitment: 1, operations: 2, research: 1, security: 1)
- Slot Management: Players must deactivate policies to activate new ones when slots are full

Slot Progression:
- Early game: 2 total slots across limited categories
- Mid game: 3 total slots with expanded category access
- Late game: 4+ total slots enabling comprehensive policy suites

Strategic Implications:
- Forces prioritization of organizational priorities
- Creates opportunity costs for policy changes
- Encourages long-term strategic planning
- Prevents min-maxing through unlimited specialization

### Policy Activation
Policies have structured requirements and activation processes to ensure meaningful implementation.

Activation Requirements:
- Company Level: Minimum organizational tier for policy access
- Milestones: Campaign achievements demonstrating capability
- Facilities: Required infrastructure for policy implementation
- Mutual Exclusions: Policies that cannot be active simultaneously
- Prerequisites: Required policies that must be active first

Implementation Process:
- Cost Assessment: Upfront funding requirement for policy activation
- Slot Verification: Available slots in appropriate categories
- Requirement Validation: All prerequisites and conditions met
- Effect Application: Immediate modifier activation across affected systems

Monthly Change Limit:
- Maximum 2 policy changes per month
- Prevents excessive micromanagement and strategic churn
- Encourages commitment to chosen organizational direction
- Allows adaptation to changing campaign circumstances

### Policy Modifiers
Each policy applies specific modifiers that affect game systems with clear trade-off relationships.

Modifier Types:
- Multiplicative Effects: Percentage bonuses/penalties to base values
- Resource Costs: Increased consumption or reduced efficiency
- Capability Adjustments: Enhanced or diminished system performance
- Risk Modifications: Changes to success probabilities and detection

Trade-off Design:
- Research Speed vs. Cost: Faster development increases resource consumption
- Recruitment Quality vs. Speed: Better personnel requires longer hiring times
- Funding vs. Visibility: Additional resources increase public scrutiny
- Operations vs. Sustainability: Enhanced performance raises maintenance costs

Modifier Stacking:
- Policies stack multiplicatively within categories
- Global modifiers combine across all active policies
- Balance validation prevents extreme combinations
- Synergy detection for beneficial policy interactions

## System Integration

### Funding System Integration
Policies directly modify financial flows and resource management.

Budget Allocation:
- Research funding diversion for accelerated development
- Public transparency initiatives for increased grants
- Operational cost modifications for different readiness levels
- Austerity measures reducing overall expenditures

Economic Incentives:
- Strategic funding trade-offs between different organizational priorities
- Long-term financial planning through policy commitments
- Resource allocation optimization for campaign goals

### Recruitment System Integration
Policies affect personnel acquisition and capability development.

Hiring Dynamics:
- Recruitment speed modifications for rapid expansion or careful screening
- Personnel quality adjustments based on selection criteria
- Training cost variations for different development approaches
- Morale and retention effects from organizational policies

Workforce Management:
- Strategic personnel planning through policy commitments
- Quality vs. quantity trade-offs in recruitment strategies
- Specialized hiring programs for specific operational needs

### Research System Integration
Policies influence technological development and scientific progress.

Development Acceleration:
- Research speed modifiers for faster technological advancement
- Project cost adjustments for resource allocation strategies
- Breakthrough probability modifications for different approaches
- Specialization bonuses for focused research directions

Scientific Strategy:
- Long-term technological planning through policy frameworks
- Resource allocation between multiple research priorities
- Risk-reward balances in research investment strategies

### Operations System Integration
Policies modify tactical and strategic execution capabilities.

Performance Enhancement:
- Interception success rate modifications for different readiness levels
- Resource consumption adjustments for sustainability trade-offs
- Maintenance cost variations based on operational priorities
- Detection risk modifications for visibility management

Strategic Flexibility:
- Operational capability adjustments for different mission profiles
- Resource management optimization for campaign sustainability
- Risk assessment modifications for strategic decision-making

## Examples

### Funding Policy Examples
Black Budget Operations:
- Effects: +40% research speed, -30% public funding, +30% detection risk, -10% monthly costs
- Requirements: Company level 3, covert operations milestone
- Trade-off: Accelerated technological development at cost of financial transparency
- Strategic Use: Early-game technology rush with increased visibility risks

Transparent Operations:
- Effects: -10% research speed, +20% public funding, -20% detection risk, +10% monthly costs
- Requirements: Company level 3
- Trade-off: Enhanced financial stability with slower technological progress
- Strategic Use: Sustainable long-term development with reduced strategic pressure

### Recruitment Policy Examples
Aggressive Recruitment:
- Effects: +50% recruitment speed, -20% personnel quality, +20% monthly costs, -5 public opinion
- Requirements: Company level 2
- Trade-off: Rapid personnel expansion with reduced individual capability
- Strategic Use: Quick force buildup for immediate operational needs

Selective Recruitment:
- Effects: -30% recruitment speed, +30% personnel quality, +10% monthly costs, +2 public opinion
- Requirements: Company level 2
- Trade-off: High-quality personnel acquisition with slower expansion
- Strategic Use: Elite force development for specialized operations

### Operations Policy Examples
Rapid Deployment Protocol:
- Effects: +20% interception success, +30% fuel consumption, +10% craft maintenance, +15% monthly costs
- Requirements: Company level 2, advanced hangar facility
- Trade-off: Enhanced response capability with increased resource demands
- Strategic Use: High-readiness posture for frequent interception missions

Conservation Protocol:
- Effects: -10% interception success, -20% fuel consumption, -10% craft maintenance, -5% monthly costs
- Requirements: Company level 2
- Trade-off: Resource efficiency with reduced operational effectiveness
- Strategic Use: Sustainable operations during resource-constrained periods

### Policy Combination Examples
High-Risk Research Focus:
- Policies: Black Budget Operations + Aggressive Recruitment + Rapid Deployment
- Combined Effects: Accelerated research, fast personnel growth, enhanced interception
- Trade-offs: Reduced funding, lower personnel quality, high resource consumption
- Strategic Profile: Aggressive expansion with technological superiority

Sustainable Development:
- Policies: Transparent Operations + Selective Recruitment + Conservation Protocol
- Combined Effects: Stable funding, high-quality personnel, resource efficiency
- Trade-offs: Slower research, reduced interception capability, lower operational tempo
- Strategic Profile: Long-term organizational stability with measured growth

## Related Wiki Pages

- [Company.md](../organization/Company.md) - Organization core and policy framework
- [Finance.md](../finance/Finance.md) - Funding policies and budget allocation
- [Recruitment.md](../units/Recruitment.md) - Recruitment policies and personnel management
- [Research tree.md](../economy/Research%20tree.md) - Research policies and development focus
- [Geoscape.md](../geoscape/Geoscape.md) - Operations policies and strategic direction
- [Economy.md](../economy/Economy.md) - Economic policies and resource management
- [Fame.md](../organization/Fame.md) - Publicity policies and media management
- [Karma.md](../organization/Karma.md) - Ethical policies and moral guidelines
- [Basescape.md](../basescape/Basescape.md) - Base policies and facility management
- [AI.md](../ai/AI.md) - Strategic policies and AI response modifiers

## References to Existing Games and Mechanics

- **Civilization Series**: Government policies and civic systems
- **Crusader Kings III**: Laws and court policies
- **Europa Universalis IV**: Government reforms and administrative policies
- **Victoria Series**: Laws and social policies
- **Stellaris**: Empire edicts and policy systems
- **Hearts of Iron Series**: National focus and government policies
- **Total War Series**: Government policies and faction laws
- **Supreme Commander**: Commander policies and strategic focus
- **XCOM 2**: Resistance policies and faction management
- **Phoenix Point**: Faction policies and organizational structure

