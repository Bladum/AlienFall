---
title: Specialized Game Widgets
summary: Game-specific widgets for core AlienFall mechanics and interfaces
tags:
  - gui
  - widgets
  - specialized
  - game
  - love2d
---

# Specialized Game Widgets

This document provides comprehensive specifications for the 12 specialized game widgets that implement core AlienFall mechanics and provide game-specific interface functionality.

## Table of Contents
- [Overview](#overview)
- [UnitPortrait Widget](#unitportrait-widget)
- [HealthBar Widget](#healthbar-widget)
- [ActionQueue Widget](#actionqueue-widget)
- [InventorySlot Widget](#inventoryslot-widget)
- [TechTree Widget](#techtree-widget)
- [ResourceDisplay Widget](#resourcedisplay-widget)
- [MissionBriefing Widget](#missionbriefing-widget)
- [CraftStatus Widget](#craftstatus-widget)
- [FacilityPanel Widget](#facilitypanel-widget)
- [ResearchProgress Widget](#researchprogress-widget)
- [GeoscapeMap Widget](#geoscapemap-widget)
- [UFOPediaEntry Widget](#ufopediaentry-widget)
- [Implementation Notes](#implementation-notes)

## Overview

Specialized game widgets implement the core mechanics and visual systems unique to AlienFall's XCOM-inspired gameplay. These widgets handle tactical combat, strategic management, and information systems with deep integration into game systems.

## UnitPortrait Widget

### Purpose
Visual representation of game units with status indicators and interactive elements for unit management.

### Key Features

#### Portrait Display
- High-resolution unit portraits with animation support
- Multiple angles and poses for different states
- Equipment and customization visualization
- Damage and status effect overlays

#### Status Integration
- Health, morale, and fatigue indicators
- Active ability and cooldown displays
- Equipment status and ammunition counters
- Rank and experience level indicators

#### Interaction Features
- Click selection and multi-selection support
- Drag-and-drop for unit positioning
- Context menu for unit actions
- Tooltip integration with detailed unit information

#### Visual States
- Selected, hovered, and disabled states
- Combat readiness and deployment status
- Injury and recovery state visualization
- Customizable appearance based on unit type

### Game-Specific Usage
- Battlescape unit selection and management
- Base personnel roster displays
- Mission team composition interfaces
- Unit recruitment and training displays

## HealthBar Widget

### Purpose
Visual health and status tracking system for units, facilities, and game entities.

### Key Features

#### Health Visualization
- Color-coded health bars (green/yellow/red gradients)
- Numerical health display options
- Smooth health transitions and animations
- Critical health warning states

#### Multi-Layer Status
- Primary health with secondary armor/shields
- Status effect overlays and indicators
- Temporary health and regeneration displays
- Damage type resistance indicators

#### Customization Options
- Size variants for different interface contexts
- Horizontal and vertical orientations
- Compact modes for space-constrained displays
- Themed styling for different entity types

#### Real-Time Updates
- Live health updates during combat
- Damage number display and animation
- Healing and regeneration visualization
- Status effect duration timers

### Game-Specific Usage
- Unit health tracking in battlescape
- Facility integrity monitoring in base management
- Craft hull integrity in geoscape
- Alien health displays in tactical combat

## ActionQueue Widget

### Purpose
Turn-based action management interface showing planned and executed actions for units.

### Key Features

#### Queue Visualization
- Sequential action display with time indicators
- Action icons and descriptions
- Progress indicators for multi-turn actions
- Queue manipulation controls (reorder, cancel, modify)

#### Action Types
- Movement actions with path visualization
- Combat actions with targeting indicators
- Special ability activations
- Item usage and equipment management

#### Time Management
- Action point costs and remaining points
- Turn progression and time remaining
- Interrupt and reaction action handling
- Cooldown and recovery timers

#### Interaction Model
- Drag-and-drop action reordering
- Click-to-modify action parameters
- Right-click context menus for action options
- Keyboard shortcuts for common actions

### Game-Specific Usage
- Battlescape unit action planning
- Multi-unit coordination interfaces
- Special ability sequencing
- Automated behavior programming

## InventorySlot Widget

### Purpose
Equipment and inventory management interface with drag-and-drop functionality for item manipulation.

### Key Features

#### Slot Types
- Weapon slots with compatibility checking
- Armor and equipment slots by body location
- Utility and accessory slots
- Ammunition and consumable storage

#### Visual Feedback
- Item icons with quality and rarity indicators
- Equipment status (equipped, stored, damaged)
- Compatibility highlighting and warnings
- Drag preview and drop zone indicators

#### Item Information
- Detailed tooltips with item statistics
- Comparison displays for equipment choices
- Upgrade and modification indicators
- Item condition and durability displays

#### Management Features
- Drag-and-drop equipment swapping
- Bulk operations for inventory management
- Item filtering and search functionality
- Equipment loadout presets and templates

### Game-Specific Usage
- Unit equipment management in base
- Pre-mission loadout configuration
- Battlefield item pickup and management
- Research material and component storage

## TechTree Widget

### Purpose
Research technology tree visualization with dependency management and progress tracking.

### Key Features

#### Tree Structure
- Hierarchical technology organization
- Prerequisite dependency visualization
- Research path branching and alternatives
- Technology category grouping

#### Progress Display
- Research progress bars and time remaining
- Completed technology highlighting
- Available research options
- Blocked technologies with requirement indicators

#### Interaction Features
- Technology selection and detailed information
- Research queue management
- Technology comparison and planning
- Research priority adjustment

#### Visual Design
- Connection lines showing technology dependencies
- Color coding for technology categories
- Zoom and pan controls for large trees
- Filter options for technology types

### Game-Specific Usage
- Research laboratory management interface
- Technology planning and strategy
- Research priority setting
- Technology unlock progression tracking

## ResourceDisplay Widget

### Purpose
Real-time resource tracking and management interface for game economy and logistics.

### Key Features

#### Resource Types
- Financial resources (funding, costs)
- Material resources (alloys, elerium, alien alloys)
- Personnel resources (scientists, engineers, soldiers)
- Strategic resources (power, maintenance, supplies)

#### Display Modes
- Current values with change indicators
- Budget and allocation displays
- Resource flow visualization
- Warning systems for shortages and surpluses

#### Management Tools
- Resource allocation sliders and controls
- Budget planning and forecasting
- Resource conversion and trading interfaces
- Automated resource management options

#### Visual Indicators
- Color-coded resource status (normal/warning/critical)
- Trend arrows showing resource flow
- Historical data and usage patterns
- Resource efficiency metrics

### Game-Specific Usage
- Base resource management dashboard
- Monthly budget planning interfaces
- Resource allocation for projects
- Economic status monitoring

## MissionBriefing Widget

### Purpose
Comprehensive mission information display with objectives, intelligence, and strategic data.

### Key Features

#### Information Organization
- Mission objectives with completion tracking
- Intelligence data and known threats
- Terrain and environmental information
- Historical mission data and patterns

#### Interactive Elements
- Objective detail expansion
- Map integration with key locations
- Unit assignment and preparation
- Risk assessment and difficulty indicators

#### Briefing Phases
- Pre-mission intelligence briefing
- Mission execution updates
- Post-mission debriefing
- Mission history and statistics

#### Customization
- Briefing detail level controls
- Information filtering options
- Custom briefing templates
- Multi-language support

### Game-Specific Usage
- Pre-mission planning and preparation
- In-mission objective tracking
- Post-mission analysis and reporting
- Mission template creation and management

## CraftStatus Widget

### Purpose
Aircraft and spacecraft management interface with status monitoring and mission assignment.

### Key Features

#### Craft Information
- Craft specifications and capabilities
- Current status and operational readiness
- Fuel, ammunition, and maintenance status
- Crew assignment and training levels

#### Mission Management
- Available mission assignments
- Mission progress and status updates
- Return time and interception windows
- Mission success probability calculations

#### Visual Indicators
- Craft position on geoscape map
- Status icons for different operational states
- Damage and repair status displays
- Upgrade and modification indicators

#### Control Interface
- Mission assignment controls
- Craft recall and redirection
- Emergency protocols and overrides
- Maintenance scheduling

### Game-Specific Usage
- Geoscape craft management
- Interception mission coordination
- Base defense craft deployment
- Transport and supply mission management

## FacilityPanel Widget

### Purpose
Base facility management interface with construction, upgrade, and operational controls.

### Key Features

#### Facility Information
- Facility specifications and capabilities
- Construction progress and completion status
- Operational status and efficiency metrics
- Maintenance and power requirements

#### Management Controls
- Construction queue management
- Facility upgrade planning
- Operational mode switching
- Staff assignment and training

#### Visual Layout
- Facility grid layout visualization
- Construction zone indicators
- Power grid and utility connections
- Security and access control displays

#### Status Monitoring
- Facility health and integrity
- Production output and efficiency
- Staff utilization and morale
- Maintenance schedule and alerts

### Game-Specific Usage
- Base construction and expansion
- Facility upgrade planning
- Operational management and optimization
- Base defense and security coordination

## ResearchProgress Widget

### Purpose
Detailed research project tracking with progress visualization and resource allocation.

### Key Features

#### Project Display
- Research project details and requirements
- Progress visualization with time remaining
- Resource allocation and consumption
- Success probability calculations

#### Management Tools
- Research priority adjustment
- Resource reallocation controls
- Project pausing and cancellation
- Research team assignment

#### Progress Tracking
- Milestone achievement indicators
- Breakthrough event notifications
- Research log and discovery tracking
- Statistical analysis and trends

#### Integration Features
- Technology tree integration
- Related research suggestions
- Research synergy bonuses
- Cross-project resource sharing

### Game-Specific Usage
- Research laboratory management
- Project prioritization and planning
- Resource allocation optimization
- Research breakthrough celebration

## GeoscapeMap Widget

### Purpose
Strategic world map interface for global operations, UFO tracking, and mission management.

### Key Features

#### Map Display
- World terrain and geography visualization
- Real-time entity positioning (crafts, UFOs, bases)
- Mission sites and objective markers
- Weather and environmental effects

#### Navigation Controls
- Zoom and pan controls with smooth animation
- Location search and bookmarking
- Coordinate system and measurement tools
- Multiple map projection options

#### Interactive Elements
- Click-to-select entities and locations
- Mission planning and route visualization
- Interception prediction and timing
- Strategic overlay and analysis tools

#### Real-Time Updates
- Live entity movement and status updates
- Mission progress and completion tracking
- Threat level visualization and alerts
- Time acceleration controls

### Game-Specific Usage
- Global strategic operations center
- UFO interception coordination
- Mission site selection and planning
- Base location scouting and expansion

## UFOPediaEntry Widget

### Purpose
Encyclopedia system for alien technology, species, and mission intelligence with rich media content.

### Key Features

#### Content Organization
- Categorized information hierarchy
- Search and filter functionality
- Related entry cross-references
- Progressive unlock system

#### Media Integration
- Text descriptions with formatting
- Images, diagrams, and illustrations
- Video and animation content
- Interactive 3D models where applicable

#### Research Integration
- Entry completion through research
- Partial information for incomplete research
- Intelligence gathering progression
- Classified information access levels

#### Navigation Features
- Breadcrumb navigation and history
- Bookmarking and favorites system
- Print and export functionality
- Multi-language content support

### Game-Specific Usage
- Alien species and technology research
- Mission intelligence and analysis
- Equipment and weapon documentation
- Historical and background information

## Implementation Notes

### Game System Integration
Specialized game widgets require deep integration with game mechanics:
- Real-time synchronization with game state
- Event-driven updates for dynamic content
- Performance optimization for complex visualizations
- Error handling for game state inconsistencies

### Performance Optimization
- Efficient rendering for complex game visualizations
- Memory management for large datasets
- Update batching for smooth performance
- Level-of-detail systems for scalability

### Accessibility Features
- Alternative input methods for complex interactions
- Screen reader support for game information
- High contrast mode for tactical displays
- Configurable control schemes

### Balancing and Tuning
- Visual feedback for game balance considerations
- Performance impact assessment
- User experience testing for complex interfaces
- Iterative design based on gameplay feedback

### Testing Requirements
- Gameplay integration testing
- Performance testing under combat conditions
- Accessibility testing with game mechanics
- Cross-platform compatibility testing