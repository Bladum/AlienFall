# Karma System - Moral Alignment & Ethical Choices

> **Implementation**: `engine/geoscape/systems/karma_system.lua`
> **Tests**: `tests/geoscape/`
> **Related**: `docs/politics/fame/`, `docs/economy/marketplace.md`, `docs/lore/`

The Karma system tracks the moral and ethical alignment of the player's organization. Karma affects access to black market, available mission types, recruit morale, story branches, and supplier relationships. It provides meaningful choices with lasting consequences.

## ⚖️ Karma Mechanics

### Karma Scale
- **Range**: -100 (Evil) to +100 (Saint)
- **Starting Level**: 0 (Neutral)
- **Trend Tracking**: Recent actions averaged to show direction

### Alignment Levels

| Alignment | Range | Color | Characteristics | Black Market Access |
|-----------|-------|-------|-----------------|---------------------|
| **Saint** | 75-100 | Green | Humanitarian, peaceful solutions | ❌ No |
| **Good** | 25-74 | Light Green | Ethical, civilian protection | ❌ No |
| **Neutral** | -24-24 | Gray | Pragmatic, flexible approach | ✅ Yes |
| **Dark** | -75 to -25 | Orange | Ruthless, military focus | ✅ Yes |
| **Evil** | -100 to -75 | Red | Cruel, unethical choices | ✅ Yes |

## 🎯 Karma Effects

### Black Market Access
- **Saint/Good** (Karma +25 to +100): Black market unavailable
- **Neutral** (-24 to +24): Black market accessible
- **Dark/Evil** (Karma -100 to -24): Black market preferred contact status

### Mission Types
- **High Karma**: Humanitarian missions, rescue operations, peaceful negotiations
- **Neutral**: Standard military operations, mixed mission types
- **Low Karma**: Covert assassination, black ops, controversial operations

### Recruit Quality & Morale
- **High Karma**: +10% morale, attracts idealistic soldiers
- **Neutral**: Baseline morale (0%)
- **Low Karma**: -10% morale, attracts mercenaries and hardened soldiers

### Supplier Attitudes
- **Ethical Suppliers**: Prefer high karma organization (+10% discount)
- **Neutral Suppliers**: Indifferent to karma (-0%)
- **Underground Suppliers**: Prefer low karma organization (+15% discount on black market)

### Story Branches & Campaign Endings
- Campaign has 3 major endings based on final karma alignment
- **Saint Ending**: Peace with alien species, humanitarian resolution
- **Neutral Ending**: Military victory, pragmatic alien treaty
- **Evil Ending**: Total genocide, dark technological advancement

## 📈 Karma Gains (Virtuous Actions)

| Action | Karma Gain | Context |
|--------|-----------|---------|
| Humanitarian Mission Success | +10 | Rescue/protection mission completed |
| Civilian Saved | +2 | Per civilian evacuated or protected |
| Prisoner Spared | +5 | Chose to interrogate rather than execute |
| Peaceful Resolution | +15 | Diplomatic solution to conflict |
| Research Ethics | +3 | Ethical research direction chosen |
| Ally Protected | +8 | Sacrificed advantage to protect ally |

## 📉 Karma Losses (Unethical Actions)

| Action | Karma Loss | Context |
|--------|-----------|---------|
| Civilian Killed | -5 | Per civilian casualty in mission |
| Prisoner Executed | -10 | Chose to execute captured enemy |
| Torture Interrogation | -3 | Used torture techniques |
| War Crime | -30 | Violation of combat ethics |
| Black Market Purchase | -5 to -20 | Type-dependent (weapons: -5, aliens: -20) |
| Biological Weapon Research | -8 | Choosing harmful research path |
| Genocide | -50 | Systematic elimination of faction |
| Ally Sacrificed | -12 | Sacrificed ally for tactical advantage |

## 🔄 Karma Trends

System tracks recent actions to show momentum:

- **Improving**: Average gain > +2 per recent action (upward arrow indicator)
- **Declining**: Average loss > -2 per recent action (downward arrow indicator)
- **Stable**: Less than ±2 average (neutral indicator)

### Trend Effects
- **Improving Trend**: Unlocks ethical recruitment options
- **Declining Trend**: Attracts underground contacts and black market offers
- **Stable Trend**: No special effects (balanced approach)

## 🎮 Strategic Implications

### High Karma Strategy (Saint/Good)
**Strengths:**
- Attracts idealistic recruits with high morale
- Access to humanitarian equipment suppliers
- Story missions unlock humanitarian branches
- Better country relationships initially

**Weaknesses:**
- No black market access (restricted weapons/tech)
- Lower morale when forced into dark choices
- Some aggressive tactics unavailable
- Suppliers may refuse certain orders

### Low Karma Strategy (Dark/Evil)
**Strengths:**
- Black market provides rare/restricted equipment
- Aggressive tactics available without penalty
- Underground suppliers offer specialist items
- Efficient (amoral) solutions to problems

**Weaknesses:**
- Recruit morale issues with idealistic soldiers
- Ethical suppliers refuse business
- Story limits access to humanitarian endings
- Country relationships may suffer

### Balanced Strategy (Neutral)
**Strengths:**
- Access to all mission types
- Black market available when needed
- Flexible supplier relationships
- All story branches remain possible

**Weaknesses:**
- No bonuses from either ethical or unethical suppliers
- Fewer recruitment specialists
- Story may feel less distinctive

## 📋 Implementation Details

**Key Systems Integration:**
- `BlackMarketSystem`: Karma must be <= 24 for access
- `RecruitmentSystem`: Karma affects recruit type and morale
- `MissionSystem`: Karma determines available mission types
- `ReputationSystem`: Karma is 20% weight in overall reputation
- `StorySystem`: Campaign endings determined by final karma

**State Persistence:**
- Karma value saved in save game
- History of recent changes maintained (last 20 actions)
- Trend calculated from history every update

**Events:**
- `karma_alignment_changed`: Fired when crossing alignment threshold
- `karma_modified`: Fired on any karma change (with delta and reason)

## 🔗 Cross-System Interactions

### With Fame System
- **High Karma + High Fame**: Genuine hero status, strong reputation
- **Low Karma + High Fame**: Ruthless efficiency status, fear-based respect
- **Misaligned (opposite extremes)**: Unstable alignment, risk of sudden shifts

### With Relations System
- Country reactions vary by karma alignment
- Democratic countries prefer high karma organizations
- Authoritarian countries prefer low karma organizations
- Alien factions react inversely to player karma alignment

### With Economy
- Premium suppliers give discounts to high karma
- Black market provides discounts to low karma
- Wealthy suppliers may refuse business with extreme alignments

### With Gameplay
- Mission choices affect karma (player decision impacts alignment)
- Research directions affect karma (science ethics)
- Resource management affects karma (civilian casualties from neglect)

## ⚡ Special Mechanics

### Alignment Shifting
- Extreme actions can shift alignment rapidly
- Warfare (20+ casualties) can shift alignment by -15 in single mission
- Major research breakthrough can shift by +20
- Once per month minimum shift possible from events

### Redemption & Corruption
- High karma character can become evil through repeated dark choices
- Low karma character can achieve sainthood through sustained good acts
- Each threshold crossing is marked with story event
- Characters mention their moral journey in dialogue

### Faction Reactions
- Alien factions judge player by karma
- High karma: Some aliens prefer peaceful coexistence
- Low karma: All aliens consider player merciless exterminator
- Neutral: Aliens neutral to moral standing

