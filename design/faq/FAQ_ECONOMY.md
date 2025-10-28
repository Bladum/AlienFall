# FAQ: Economy & Trading

[← Back to FAQ Index](FAQ_INDEX.md)

---

## Q: How does the economy work? Is it like Civilization's gold system?

**A**: **Similar but more complex**:

AlienFall has a multi-layered economy:
- **Credits**: Main currency for purchases (like Civ gold)
- **Resources**: Raw materials for manufacturing (like RTS resources)
- **Research**: Technology unlocks (like Civ science)
- **Manufacturing**: Production queues (like StarCraft)
- **Trading**: Marketplace + Black Market (like Grand Strategy games)

**Comparison**:
- **Like Civilization**: Monthly income, research trees, building costs
- **Like StarCraft**: Production queues, resource gathering, manufacturing
- **Like X-COM**: Funding from countries, sell salvage for profit
- **Like Europa Universalis**: Trade relationships, supplier networks

---

## Q: How do I make money?

**A**: **Multiple income sources**:

### Primary Income
1. **Country Funding**: Monthly payments from allied countries (largest source)
2. **Mission Rewards**: Complete missions for bonus payments
3. **Salvage Sales**: Sell battlefield loot on marketplace
4. **Manufacturing Profits**: Produce items, sell for markup
5. **Black Market**: High-risk trades and corpse selling

### Income Breakdown

| Source | Monthly Income | Reliability | Requirements |
|--------|---------------|-------------|--------------|
| **Country Funding** | 50,000-200,000 | High | Good relations |
| **Mission Rewards** | 10,000-50,000 | Medium | Complete missions |
| **Salvage Sales** | 20,000-80,000 | Medium | Successful missions |
| **Manufacturing** | 10,000-40,000 | High | Workshop facilities |
| **Black Market** | Variable | Low | Karma/fame requirements |

**Comparison**:
- **Like X-COM**: Country funding is primary income
- **Like Civilization**: Trade routes provide steady income
- **Like Resident Evil 4**: Sell loot from missions

---

## Q: What's the Black Market? How is it different from the regular marketplace?

**A**: **Underground economy with unique services**:

### Black Market Features

**What You Can Buy**:
1. **Restricted Items**: Experimental weapons, banned tech (200-500% markup)
2. **Special Units**: Mercenaries, defectors, augmented soldiers
3. **Special Craft**: Stolen military craft, captured UFOs
4. **Custom Missions**: Generate assassination, sabotage, heist missions
5. **Political Events**: Trigger events like improving relations or sabotaging economies
6. **Corpse Trading**: Sell dead units for credits (morally questionable)

### Comparison to Similar Games

| Feature | AlienFall Black Market | Similar To |
|---------|----------------------|-----------|
| **Restricted items** | Experimental/banned gear | Fallout black market |
| **Corpse trading** | Sell dead units | Darkest Dungeon (dark but profitable) |
| **Mission generation** | Buy custom missions | Contract systems in MechWarrior |
| **Event purchasing** | Trigger political events | Europa Universalis covert actions |
| **Karma impact** | All trades affect morality | Mass Effect Renegade/Paragon |

---

## Q: How does Black Market access work?

**A**: **Karma and fame gates**:

### Access Requirements

**Initial Access**:
- Karma below +40 (cannot be "too good")
- Fame above 25 (must be known to find contacts)
- Entry fee: 10,000 credits (one-time)
- Discovery of black market contact (special mission/event)

### Access Tiers

| Karma | Fame | Access Level | Available Options |
|-------|------|--------------|-------------------|
| +40 to +10 | 25-59 | Restricted | Items only |
| +9 to -39 | 25-100 | Standard | Items, Units, Services |
| -40 to -74 | 60-100 | Enhanced | All except extreme |
| -75 to -100 | 75-100 | Complete | Everything |

**Comparison**:
- **Like Mass Effect**: Morality system affects availability
- **Like Grand Theft Auto**: Wanted level restricts access
- **Like Skyrim**: Thieves Guild reputation unlocks services
- **Unlike X-COM**: No black market in original

---

## Q: What are the risks of using the Black Market?

**A**: **Discovery, karma loss, diplomatic damage**:

### Discovery Risk System

**Base Discovery Chance**: 5-15% per transaction
**Modified By**:
- Fame level: +1% per 10 fame (high profile = more scrutiny)
- Transaction size: +2% per 100,000 credits spent
- Transaction count: +1% per 10 Black Market purchases
- Karma level: -1% per 10 negative karma (criminals protect criminals)

**Example Discovery Calculation**:
```
Transaction: Buy experimental weapon (50,000 credits)
Base risk: 10%
Fame (80): +8% (high profile)
Transaction size: +1% (50K credits)
Transaction count (15 previous): +1.5%
Karma (-30): -3% (criminal reputation helps)

Final Discovery Risk: 10 + 8 + 1 + 1.5 - 3 = 17.5%
Roll: d100 = 22 → NOT DISCOVERED (safe)
```

### Consequences of Discovery

**If Discovered**:
1. **Fame Loss**: -20 to -50 (public scandal)
2. **Diplomatic Damage**: -30 to -70 relations with discovering country
3. **Supplier Restrictions**: Some legitimate suppliers refuse business
4. **Mission Availability**: Certain missions become unavailable
5. **No Legal Penalty**: Cannot be arrested (you're too powerful)

**Example Discovery Event**:
```
Scenario: Player buys stolen military craft from Black Market

Discovery Roll: Failed (caught)
Discovering Country: United States (-50 relations)
Immediate Effects:
- Fame: 75 → 35 (-40 lost, "Public Scandal")
- Relations: USA 60 → 10 (-50, "Diplomatic Incident")
- Funding: USA stops monthly payment (lose 50,000/month)
- Suppliers: Military Supply Corp. embargo (6 months)
- Black Market: +10 reputation (criminals respect the risk)

Recovery Options:
- Complete missions for USA (+10 relations per mission)
- Wait 12 months for scandal to fade
- Use Black Market to purchase "Improve Relations" event (50,000 credits)
```

### Karma Impact by Transaction

**Black Market Karma Costs**:

| Transaction Type | Karma Loss | Reasoning |
|----------------|-----------|-----------|
| **Buy restricted item** | -5 | Supporting illegal arms trade |
| **Buy augmented unit** | -15 | Human trafficking/exploitation |
| **Buy stolen craft** | -20 | Military theft, national security |
| **Sell corpse** | -10 to -30 | Grave desecration, unethical |
| **Buy assassination mission** | -25 | Contract killing |
| **Trigger political sabotage** | -30 | Destabilizing nations |
| **Buy rebellion event** | -40 | Causing civil war |

**Karma Spiral Example**:
```
Starting Karma: +20 (slightly good)

Month 1: Buy experimental weapon (-5 karma → +15)
Month 2: Sell 3 alien corpses (-30 karma → -15)
Month 3: Buy mercenary unit (-15 karma → -30)
Result: Now "Evil" aligned, full Black Market access

Side Effect: Legitimate suppliers now distrust you
- Military Supply Corp: Prices +20%
- Research Materials Ltd: -50% availability
- Tactical Supply Network: Embargo until karma improves
```

**For complete Black Market mechanics, see: design/mechanics/BlackMarket.md**
- **Like Mass Effect**: Renegade actions unlock dark options
- **Like Fable**: Evil alignment opens criminal opportunities
- **Unlike X-COM**: Not just items, full services and manipulation
- **Like Deus Ex**: Moral choices affect available paths

---

## Q: What are the risks of using the Black Market?

**A**: **Discovery, karma loss, fame damage**:

### Consequences

**Per Transaction**:
- **Karma**: -5 to -40 (depending on severity)
- **Fame**: -5 to -30 (if discovered)
- **Relations**: -30 to -70 with discovering country
- **Discovery chance**: 5-15% per transaction

**Cumulative Effects**:
- 10+ transactions: "Known Criminal" status
- 25+ transactions: International sanctions possible
- Discovery triggers investigations and raids

**Comparison**:
- **Like XCOM 2**: High-risk, high-reward strategic choices
- **Like Darkest Dungeon**: Dark choices have consequences
- **Like Fallout**: Karma system affects reputation
- **Unlike X-COM**: No black market at all

---

## Q: Can I buy MISSIONS on the Black Market?

**A**: **Yes! Custom mission generation**:

### Mission Purchasing

**Available Mission Types**:

| Mission | Cost | Karma | Reward Potential |
|---------|------|-------|------------------|
| **Assassination** | 50,000 | -30 | 120,000 + unique items |
| **Sabotage** | 40,000 | -20 | 100,000 + intel |
| **Heist** | 30,000 | -15 | 80,000 + stolen goods |
| **Kidnapping** | 35,000 | -25 | 90,000 + prisoner |
| **False Flag** | 60,000 | -40 | 150,000 + political shift |
| **Data Theft** | 25,000 | -10 | 60,000 + research |

**How It Works**:
1. Pay cost to Black Market
2. Mission spawns on Geoscape in 3-7 days
3. Complete mission for rewards (150-300% profit)
4. Success: Keep rewards, karma penalty
5. Failure: Mission exposed, relations/fame loss

**Comparison**:
- **Like MechWarrior/BattleTech**: Buy mercenary contracts
- **Like Hitman**: Assassination contracts with payment
- **Unlike X-COM**: Missions are given, not purchased
- **Like EVE Online**: Contract system for custom jobs

---

## Q: What are "Events" I can buy?

**A**: **Political manipulation and economic sabotage**:

### Event Purchasing

**Available Events**:

| Event | Cost | Karma | Effect | Duration |
|-------|------|-------|--------|----------|
| **Improve Relations** | 30,000 | -10 | +20 relations with country | Permanent |
| **Sabotage Economy** | 50,000 | -25 | Economy drops 1 tier | 6 months |
| **Incite Rebellion** | 80,000 | -35 | Province contested | 3 months |
| **Spread Propaganda** | 20,000 | -5 | +10 fame, +10 relations | 3 months |
| **Frame Rival** | 60,000 | -30 | Rival loses -30 relations | Permanent |
| **Bribe Officials** | 40,000 | -15 | Ignore black market activity | 6 months |
| **Crash Market** | 70,000 | -20 | 30% cheaper items | 3 months |

**Example Use**:
```
Scenario: Need to build base in hostile country
Solution: Buy "Improve Relations" event (30K, -10 karma)
Result: +20 relations → can now build base
Risk: 12% chance of discovery → -30 fame if caught
```

**Comparison**:
- **Like Europa Universalis**: Covert actions and sabotage
- **Like Civilization VI**: Espionage missions
- **Like Crusader Kings**: Plot and scheme mechanics
- **Unlike X-COM**: No political manipulation available

---

## Q: Can I sell corpses? How does that work?

**A**: **Yes, through Black Market - morally dark but profitable**:

### Corpse Trading System

**Corpse Types & Values**:

| Corpse Type | Value | Karma Impact | Use |
|-------------|-------|--------------|-----|
| **Human Soldier** | 5,000 | -10 | Organ trade |
| **Alien (Common)** | 15,000 | -15 | Black market research |
| **Alien (Rare)** | 50,000 | -25 | High-value specimens |
| **VIP/Hero** | 100,000 | -30 | Political leverage |
| **Mechanical** | 8,000 | -5 | Scrap parts |

**How It Works**:
1. Collect corpses from battlefield (post-mission salvage)
2. Store in base (2 inventory slots per corpse)
3. Sell through Black Market corpse traders
4. Receive credits + karma penalty
5. 5% discovery risk per sale

**Ethical Alternative Uses**:
- **Research**: Study for science (0 karma, free tech)
- **Burial**: Proper disposal (0 karma, +5 morale to squad)
- **Ransom**: Return enemy corpses (0 karma, +relations)

**Comparison**:
- **Like Darkest Dungeon**: Dark choices for profit
- **Like Rimworld**: Organ harvesting mechanics
- **Unlike X-COM**: Bodies just disappear
- **Like Fallout**: Morally questionable trading

---

## Q: How does research work?

**A**: **Like Civilization tech tree meets X-COM alien research**:

### Research System

**Requirements**:
- **Scientists**: Allocate personnel to project
- **Facility**: Research lab with capacity
- **Items**: Some research needs specific artifacts
- **Credits**: Funding the project
- **Time**: Man-days to complete

**Research Calculation**:
```
Progress = Scientists × Days
Example: 5 scientists on 30 man-day project = 6 days
```

**Comparison**:
- **Like Civilization**: Tech tree with prerequisites
- **Like X-COM**: Research alien items for reverse engineering
- **Like XCOM 2**: Scientists speed research, not just "science points"
- **Unlike Civilization**: Need physical items, not just "beakers"

---

## Q: How does manufacturing work?

**A**: **Production queues like StarCraft**:

### Manufacturing System

**Requirements**:
- **Engineers**: Allocated personnel
- **Workshop**: Manufacturing facility
- **Resources**: Raw materials for item
- **Credits**: Production cost
- **Time**: Engineer-days to complete

**Production Queue**:
- Queue multiple projects (3-10 typical)
- Auto-starts next when one completes
- Can reorder or prioritize
- Batch bonuses: 10 units = 10% speed boost

**Comparison**:
- **Like StarCraft**: Production queue, engineers = workers
- **Like Factorio**: Production chains and efficiency
- **Like X-COM**: Manufacture items to equip or sell
- **Unlike Civilization**: Not instant, takes time

---

## Q: What's the optimal economic strategy?

**A**: **Balance funding, manufacturing, and trading**:

### Economic Priorities

**Early Game**:
1. Maintain country relations (funding)
2. Build basic workshops (manufacturing)
3. Sell excess salvage (quick cash)
4. Avoid Black Market (preserve karma)

**Mid Game**:
1. Expand manufacturing capacity
2. Research profitable items
3. Establish supplier relationships
4. Selective Black Market use

**Late Game**:
1. Vertical integration (manufacture everything)
2. Export surplus for profit
3. Black Market for strategic advantage
4. Multiple income streams

**Comparison**:
- **Like Civilization**: Balance gold, science, production
- **Like X-COM**: Funding is critical early game
- **Like StarCraft**: Expand economy for late-game power
- **Like EVE Online**: Multiple income streams optimal

---

## Q: How do suppliers work?

**A**: **Relationship-based trading network**:

### Supplier System

**Supplier Types**:
- **Military**: Weapons, ammo (standard pricing)
- **Tech**: Electronics, systems (high pricing)
- **Black Market**: Restricted items (extreme pricing)
- **Regional**: Local goods (variable pricing)

**Relationship Effects**:

| Relation | Pricing | Availability | Delivery |
|----------|---------|--------------|----------|
| -100 | Embargo | Blocked | N/A |
| 0 | 100% | Standard | Normal |
| +50 | 75% | +20% | -2 days |
| +100 | 50% | +50% | -5 days |

**Building Relations**:
- Regular purchases: +1 per large order
- Bulk contracts: +0.3 per month
- Betrayal: -100 (permanent ban)

**Comparison**:
- **Like Europa Universalis**: Trade relationships
- **Like X-COM**: Single marketplace (simpler)
- **Like Mount & Blade**: Multiple merchants with relations
- **Like EVE Online**: Market manipulation possible

---

## Next Steps

- **Understand diplomacy**: Read [Politics FAQ](FAQ_POLITICS.md)
- **Learn research trees**: Read [Items FAQ](FAQ_ITEMS.md)
- **Master base building**: Read [Basescape FAQ](FAQ_BASESCAPE.md)
- **See full mechanics**: Check [design/mechanics/Economy.md](../mechanics/Economy.md)
- **Black Market details**: Check [design/mechanics/BlackMarket.md](../mechanics/BlackMarket.md)

[← Back to FAQ Index](FAQ_INDEX.md)

