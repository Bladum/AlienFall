# Marketplace System

> **Implementation**: `engine/economy/marketplace/`, `engine/basescape/logic/`
> **Tests**: `tests/economy/`
> **Related**: `docs/economy/funding.md`, `docs/economy/manufacturing.md`

Dynamic trading system for resource acquisition, surplus management, and economic interaction.

## 🏪 Marketplace Architecture

### Marketplace System
Central trading hub managing all commercial transactions and market activities.

**Core Components:**
- **Transaction Processing**: Handle purchases, sales, and transfers
- **Supplier Management**: Track relationships and availability
- **Inventory Tracking**: Monitor stockpiles and availability
- **Price Calculation**: Dynamic pricing based on market conditions

### Purchase System
Procurement of resources and equipment from external suppliers.

**Purchase Elements:**
- **Purchase Entries**: Available items from suppliers
- **Purchase Orders**: Completed acquisition transactions
- **Supplier Selection**: Choose vendors based on availability and prices
- **Delivery Logistics**: Transportation and timing considerations

### Sales System
Disposition of surplus materials and equipment to generate revenue.

**Sales Elements:**
- **Sales Orders**: Transactions for selling excess goods
- **Market Demand**: Buyer interest and pricing power
- **Profit Optimization**: Maximize returns on surplus items
- **Bulk Transactions**: Volume discounts and efficiencies

## 📊 Trading Mechanics

### Transfer Orders
Internal logistics for moving goods between base locations.

**Transfer Features:**
- **Inter-Base Movement**: Redistribute resources across facilities
- **Transportation Costs**: Distance and logistics expenses
- **Delivery Time**: Transit duration based on distance
- **Priority Options**: Expedited delivery for critical items

### Black Market
Underground trading network for restricted or specialized items.

**Black Market Features:**
- **Restricted Items**: Equipment not available through normal channels
- **Premium Pricing**: Higher costs for exclusive goods
- **Risk Factors**: Potential complications or quality issues
- **Special Access**: Requires specific contacts or reputation

### Supplier Relationships
Reputation and trust levels affecting trading conditions.

**Relationship Factors:**
- **Trust Levels**: History of successful transactions
- **Price Discounts**: Better rates for preferred suppliers
- **Priority Access**: First access to limited items
- **Special Deals**: Unique offers for valued customers

## 🏭 Supplier System

### Supplier Definitions
Individual vendor profiles specifying available goods and restrictions.

**Supplier Attributes:**
- **Product Catalog**: Items available for purchase
- **Restrictions**: Items not available or limited
- **Specialization**: Focus areas (weapons, materials, etc.)
- **Geographic Location**: Distance affecting delivery times

### Supplier Stockpiles
Inventory levels affecting pricing and availability.

**Stockpile Dynamics:**
- **Inventory Levels**: Current stock affecting prices
- **Restock Cycles**: Regular replenishment schedules
- **Limited Items**: Rare goods with availability constraints
- **Bulk Availability**: Volume purchase options

### Price Modifiers
Dynamic pricing system responding to market conditions.

**Pricing Factors:**
- **Supply/Demand**: Market balance affecting costs
- **Relationship Bonuses**: Trust level price adjustments
- **Stock Levels**: Inventory scarcity premiums
- **Market Events**: Random economic fluctuations

## 🎮 Player Experience

### Trading Strategy
- **Market Timing**: Buy low during surpluses, sell high during shortages
- **Supplier Relationships**: Build trust for better deals
- **Inventory Management**: Balance stock levels across bases
- **Transfer Logistics**: Optimize inter-base resource distribution

### Economic Opportunities
- **Speculation**: Profit from market fluctuations
- **Bulk Purchasing**: Volume discounts for large orders
- **Surplus Monetization**: Convert excess goods to funding
- **Strategic Procurement**: Secure critical materials before shortages

### Trading Challenges
- **Price Volatility**: Unpredictable market conditions
- **Transportation Delays**: Time costs for distant suppliers
- **Stock Limitations**: Limited availability of key items
- **Relationship Management**: Maintaining supplier trust

## 📈 Marketplace Balance

### Difficulty Scaling
- **Rookie**: Stable prices, generous availability, low transport costs
- **Veteran**: Standard market conditions with moderate volatility
- **Commander**: High volatility, limited availability, expensive transport
- **Legend**: Extreme volatility, scarce resources, maximum transport costs

### Economic Integration
- **Manufacturing Synergy**: Marketplace provides production materials
- **Mission Rewards**: Combat operations generate sellable resources
- **Research Investment**: Technology affects market access and prices
- **Base Development**: Facilities improve trading capabilities

### Market Dynamics
- **Supply Chain Effects**: Production decisions affect market prices
- **Global Events**: Campaign developments influence market conditions
- **Competition**: Multiple organizations competing for resources
- **Economic Cycles**: Boom and bust periods affecting all trading

### Risk Management
- **Market Speculation**: Potential high profits vs losses
- **Supplier Reliability**: Trust vs price trade-offs
- **Inventory Risks**: Stockouts vs carrying costs
- **Transportation Security**: Speed vs safety considerations