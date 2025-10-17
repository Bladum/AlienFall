# Economy System

Financial management systems handling funding, resource management, manufacturing, and marketplace operations.

## Overview

The Economy system provides comprehensive financial management for AlienFall operations:
- Global funding from government and mission rewards
- Manufacturing facilities converting resources to equipment
- Marketplace for inter-base resource trading
- Personnel salary management and upkeep costs
- Research and facility maintenance expense tracking
- Budget allocation and financial planning

## Features

### Funding System
- **Monthly Income**: Government grants based on performance score
- **Mission Rewards**: Payment for completed operations
- **Research Bonuses**: Funding incentives for technology completion
- **Score Calculation**: Performance metrics affect monthly funding levels
- **Debt Management**: Tracking of loans and interest accumulation

### Income Sources
- **Government Grants**: Primary monthly funding from funding nations
- **Mission Bonuses**: Combat operation completion rewards
- **Research Milestones**: Funding for completed research projects
- **Technology Sales**: Revenue from selling developed technologies
- **Marketplace Profits**: Gains from resource trading

### Expense Categories
- **Personnel Salaries**: Monthly wages for all staff
- **Facility Maintenance**: Base building operating costs
- **Equipment Procurement**: Purchasing weapons, armor, vehicles
- **Research Costs**: Technology development expenses
- **Manufacturing Overhead**: Production facility operating costs
- **Transportation**: Inter-base logistics expenses

### Budget Management
- **Central Treasury**: Unified funding pool across all operations
- **Budget Forecasting**: Project income and expenses
- **Financial Alerts**: Low funding warnings
- **Emergency Funds**: Contingency reserves
- **Loan System**: Short-term financing options

## Manufacturing System

### Production Facilities
- **Workshops**: General manufacturing (weapons, ammunition, basic items)
- **Armor Forge**: Armor and protective equipment production
- **Vehicle Assembly**: Craft and vehicle construction/repair
- **Laboratories**: Advanced equipment and research materials
- **Refineries**: Material processing and enhancement

### Production Process
- **Recipe System**: Define what materials create which items
- **Resource Consumption**: Material requirements per item
- **Labor Requirements**: Engineer-hours needed for production
- **Quality Control**: Success rate and defect handling
- **Production Queue**: Manage multiple simultaneous productions

### Manufacturing Mechanics
- **Time-Based Production**: Items take hours/days to manufacture
- **Resource Caching**: Track materials in facility inventory
- **Worker Assignment**: Assign engineers to facilities
- **Efficiency Modifiers**: Facility upgrades improve production speed
- **Bottleneck Management**: Prioritize production queues

## Marketplace System

### Trading Mechanics
- **Inter-Base Trading**: Resource redistribution between bases
- **Global Market**: Trade with external suppliers
- **Dynamic Pricing**: Supply/demand-based price fluctuations
- **Transportation**: Logistics cost for moving goods
- **Bulk Pricing**: Discounts for large quantity purchases

### Market Items
- **Raw Materials**: Metals, chemicals, alien materials
- **Components**: Electronics, weapons parts, armor segments
- **Finished Goods**: Weapons, armor, equipment
- **Supplies**: Ammunition, medical items, consumables

### Price Dynamics
- **Base Prices**: Foundation cost from game configuration
- **Supply Level**: Available quantity affects price
- **Demand**: Active procurement increases prices
- **Market Events**: Random fluctuations and opportunity trades
- **Negotiation**: Player reputation affects prices

## Architecture

```
economy/
├── funding/
│   ├── budget_manager.lua       # Budget allocation and tracking
│   ├── funding_calculator.lua   # Monthly funding calculation
│   ├── income_manager.lua       # Income source tracking
│   └── expense_manager.lua      # Expense tracking and alerts
├── manufacturing/
│   ├── production_queue.lua     # Production scheduling
│   ├── recipe_system.lua        # Item production recipes
│   ├── workshop_manager.lua     # Facility production management
│   └── resource_manager.lua     # Material inventory tracking
├── marketplace/
│   ├── marketplace_manager.lua  # Main marketplace coordination
│   ├── price_calculator.lua     # Dynamic pricing system
│   ├── trader_ai.lua            # NPC trader behavior
│   └── transaction_log.lua      # Transaction history
└── systems/
    ├── economy_manager.lua      # Main economy coordinator
    ├── financial_state.lua      # Economy state persistence
    └── economic_events.lua      # Random economic events
```

## Configuration

Economy parameters are configured through TOML files in `mods/core/`:

- `mods/core/economy/` - Economy system configuration
  - `funding.toml` - Funding nation parameters
  - `manufacturing_costs.toml` - Item production costs
  - `marketplace_prices.toml` - Base marketplace prices
  - `expenses.toml` - Monthly expense configurations

## Systems Integration

### Geoscape Integration
- Mission rewards affect monthly budget
- Performance score calculation
- Funding nation relationships

### Basescape Integration
- Facility operating costs
- Personnel salary management
- Manufacturing facility operation
- Marketplace transactions

### Battle Integration
- Ammunition consumption costs
- Equipment repair costs
- Casualty medical expenses

## Key Mechanics

### Monthly Financial Cycle
1. Calculate income (government grants, bonuses)
2. Deduct personnel salaries
3. Deduct facility maintenance
4. Deduct manufacturing overhead
5. Calculate net balance
6. Alert if low funding

### Production Workflow
1. Queue item production with recipe
2. Check resource availability
3. Reserve materials
4. Assign workers
5. Track production progress
6. Deliver finished item
7. Update resource inventory

### Marketplace Trading
1. Browse available items
2. Check price and availability
3. Calculate transportation cost
4. Execute transaction
5. Update inventory
6. Apply reputation changes

## Balancing

Key economic parameters for game balance:

- **Monthly Funding**: Base grant amount per nation
- **Salary Costs**: Personnel monthly wages
- **Facility Upkeep**: Monthly maintenance per facility
- **Manufacturing Costs**: Resource multiplier per item
- **Marketplace Markups**: Profit margins on trades

All values are configurable via TOML files for mod compatibility and balancing.

## Testing

Unit tests for economy systems are located in `tests/unit/`:

- `test_funding_calculator.lua` - Income calculation tests
- `test_manufacturing.lua` - Production system tests
- `test_marketplace.lua` - Trading system tests
- `test_budget_manager.lua` - Budget allocation tests
