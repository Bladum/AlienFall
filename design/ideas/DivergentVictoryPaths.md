# Divergent Victory Paths System

> **Status**: Design Proposal  
> **Last Updated**: 2025-10-28  
> **Priority**: MEDIUM  
> **Related Systems**: Geoscape.md, Politics.md, Research.md, Economy.md, Units.md

## Table of Contents

- [Overview](#overview)
- [Design Philosophy](#design-philosophy)
- [Victory Path Framework](#victory-path-framework)
- [Path 1: Technological Supremacy](#path-1-technological-supremacy)
- [Path 2: Diplomatic Unification](#path-2-diplomatic-unification)
- [Path 3: Military Domination](#path-3-military-domination)
- [Path 4: Shadow Conspiracy](#path-4-shadow-conspiracy)
- [Path 5: Hybrid Paths](#path-5-hybrid-paths)
- [Victory Tracking System](#victory-tracking-system)
- [Milestone Rewards](#milestone-rewards)
- [Victory Cinematics](#victory-cinematics)
- [Integration with Campaign](#integration-with-campaign)
- [Technical Implementation](#technical-implementation)

---

## Overview

### System Purpose

The Divergent Victory Paths system creates **clear long-term goals** beyond simple survival, allowing players to define their playstyle and pursue distinct strategic identities. Each path offers unique rewards, unlocks specialized content, and culminates in a thematically appropriate ending.

**Core Goals**:
- Provide clear victory conditions (beyond "survive alien invasion")
- Encourage diverse playstyles (4× replayability minimum)
- Create meaningful strategic identity ("I'm the tech genius" vs. "I'm the diplomat")
- Reward specialization without punishing experimentation
- Enable multiple victory paths in single playthrough (hybrid strategies)

### Key Principles

1. **Player-Driven**: Paths unlock based on player actions, not pre-selection
2. **Transparent Progress**: Players always know current standing toward each path
3. **No Lockouts**: Can switch paths or pursue multiple simultaneously
4. **Thematic Consistency**: Each path reflects distinct narrative and mechanical identity
5. **Satisfying Climax**: Victory cinematics and rewards match player achievements

---

## Design Philosophy

### Inspiration Sources

- **Civilization Series**: Science/Culture/Domination/Diplomatic victories
- **Stellaris**: Ascension paths (Psionic/Synthetic/Biological)
- **Deus Ex**: Multiple endings based on player philosophy
- **Dishonored**: Chaos system determining ending (high/low chaos)
- **Alpha Centauri**: Faction-specific victory conditions

### Core Victory Loop

```
Player Actions → Path Progress Tracked → Milestones Achieved →
Specialized Content Unlocked → Path-Specific Powers Gained →
Victory Condition Met → Thematic Ending Triggered
```

### Balancing Multiple Paths

Players can:
- **Specialize**: Focus 100% on one path (fastest victory, strongest thematic ending)
- **Hybrid**: Progress 2-3 paths simultaneously (flexible, mid-tier endings)
- **Generalist**: Progress all paths evenly (slowest, "balanced" ending)

**Path Synergies & Conflicts**:
```yaml
Synergistic Pairs:
  - Technology + Military (advanced weapons)
  - Diplomatic + Shadow (manipulate through diplomacy OR coercion)
  
Conflicting Pairs:
  - Diplomatic + Military (peace vs. domination)
  - Shadow + Technology (secrecy vs. fame from breakthroughs)
  
Neutral Pairs:
  - Technology + Diplomatic (can coexist)
  - Military + Shadow (can complement)
```

---

## Victory Path Framework

### Path Activation

All paths unlock at **Month 4** after player has established baseline operations.

**Activation Requirements**:
- Complete 10+ missions (demonstrate competence)
- Maintain 2+ bases (organizational stability)
- Research 5+ projects (technical foundation)
- Allied with 3+ countries (diplomatic presence)

**Activation Notification**:
```
"Victory Paths Available"

Your organization has grown beyond a simple defense force. The world 
watches your next move. How will you shape humanity's future?

[View Victory Paths] [Remind Me Later]
```

### Path Structure

Each path consists of:

1. **5 Milestone Tiers** (0-25%, 25-50%, 50-75%, 75-95%, 95-100%)
2. **Unique Progression Metrics** (different for each path)
3. **Exclusive Unlocks** (facilities, units, missions, technologies)
4. **Thematic Rewards** (bonuses matching path philosophy)
5. **Victory Condition** (clear end goal to achieve)

### Progress Tracking

```yaml
Victory Path UI Panel:
  - Path Name & Icon
  - Current Progress (%) with visual bar
  - Next Milestone (requirements + rewards)
  - Total Contributions (detailed breakdown)
  - Estimated Time to Victory (based on current rate)
  - Path-Specific Bonuses (currently active)
```

---

## Path 1: Technological Supremacy

### Path Philosophy

**"Progress through innovation. Transcend biological limitations. Achieve the Singularity."**

Victory through overwhelming technological superiority. Unlock all research trees, develop experimental technologies, and ascend humanity beyond its current form.

### Victory Condition

**"Technological Singularity"**: Complete ALL research trees + Unlock "Post-Human" technology

### Progression Metrics

```yaml
Progress Formula:
  Research_Progress = (Completed_Projects / Total_Projects) × 100
  Technology_Tier = Highest_Tech_Tier_Unlocked × 10
  Prototype_Deployed = Experimental_Tech_Used × 5
  
Total Progress = (Research_Progress × 0.6) + (Technology_Tier × 0.3) + 
                 (Prototype_Deployed × 0.1)
```

### Milestone Rewards

#### Tier 1: Research Foundation (25%)
**Requirements**: Complete 15 research projects + Unlock Advanced Lab

**Unlocks**:
- **Prototype Lab Facility** (2×2, +50% experimental research speed)
- **"Innovator" Trait** for scientists (+20% research speed)
- **Tech Export** economy option (sell research for 2× normal credits)

**Bonus**: All research 10% faster globally

---

#### Tier 2: Technological Revolution (50%)
**Requirements**: Complete 30 research projects + Unlock 2 "Ultimate" tier technologies

**Unlocks**:
- **Reverse Engineering System** (instant analysis of alien tech, no research time)
- **"Quantum Lab" Facility** (3×3, enables dimensional research)
- **AI Research Assistant** (automated research, +1 project always running)

**Bonus**: All manufacturing 20% faster (better tech = better tools)

---

#### Tier 3: Scientific Mastery (75%)
**Requirements**: Complete 50 research projects + Unlock 4 "Ultimate" tier technologies

**Unlocks**:
- **"Technological Singularity" Research** (final capstone, 500 man-days)
- **"Post-Human" Unit Class** (AI-enhanced soldiers, super-stats)
- **Neural Augmentation** (all units gain +3 to all stats permanently)

**Bonus**: Free research project every month (auto-complete 1 project instantly)

---

#### Tier 4: Transcendence Preparation (95%)
**Requirements**: Complete 75 research projects + Begin Singularity Research

**Unlocks**:
- **Reality Anchor Facility** (prevents dimensional rifts)
- **Nanite Swarm Weapons** (infinite ammo, self-repairing)
- **Consciousness Upload** (units can't die, backed up digitally)

**Bonus**: All alien technology instantly usable (no research needed)

---

#### Tier 5: VICTORY - Technological Singularity (100%)
**Requirements**: Complete Singularity Research + Deploy Post-Human units in 5 missions

**Victory Condition Met**: Humanity transcends biological form

**Victory Effects**:
- Campaign ends with technological ascension
- All remaining alien threats trivial (overwhelming tech advantage)
- Humanity begins colonizing galaxy using dimensional gates
- Player organization becomes AI-run megacorporation

**Ending Cinematic**: Soldiers merge with machines, achieve collective consciousness, Earth becomes technological paradise (or dystopia depending on karma)

---

### Path-Specific Missions

- **"Prototype Testing"**: Deploy experimental weapons in combat (high risk/reward)
- **"Corporate Espionage"**: Steal research from rival organizations
- **"Brain Drain"**: Recruit scientists from countries (reduces their tech)
- **"AI Awakening"**: First Post-Human unit activation mission
- **"Singularity Trigger"**: Final mission, merge human consciousness with AI

---

## Path 2: Diplomatic Unification

### Path Philosophy

**"Unity through cooperation. Peace through understanding. One Earth, one government."**

Victory through global political unification. Achieve perfect relations with all nations, form unified Earth government, eliminate conflict through diplomacy.

### Victory Condition

**"Unified Earth Government"**: Achieve +75 relation with ALL countries + Form United Nations Council

### Progression Metrics

```yaml
Progress Formula:
  Average_Relations = (Sum_of_All_Country_Relations) / (Total_Countries)
  Allied_Nations = (Countries_with_+50_Relation) × 5
  Diplomatic_Missions = (Successful_Diplomatic_Missions) × 3
  
Total Progress = (Average_Relations × 0.5) + (Allied_Nations × 0.3) + 
                 (Diplomatic_Missions × 0.2)
```

### Milestone Rewards

#### Tier 1: Diplomatic Recognition (25%)
**Requirements**: Allied with 3+ countries + Average relations > +25

**Unlocks**:
- **Diplomatic Corps Facility** (2×2, +50% relation gain speed)
- **"Ambassador" Advisor** (can negotiate peace between warring nations)
- **Fast Track Visas** (instant unit recruitment from allied countries)

**Bonus**: All relation changes +50% (faster friendship building)

---

#### Tier 2: Regional Alliance (50%)
**Requirements**: Allied with 6+ countries + Average relations > +50

**Unlocks**:
- **United Nations Council Facility** (3×3, joint decision-making with nations)
- **Joint Military Operations** (allied nations provide backup units)
- **Shared Intelligence Network** (+50% UFO detection globally)

**Bonus**: Allied nations contribute 20% of their military to player (free units monthly)

---

#### Tier 3: Continental Unity (75%)
**Requirements**: Allied with 10+ countries + Average relations > +70

**Unlocks**:
- **Global Defense Initiative Facility** (4×4, world government headquarters)
- **Shared Research Program** (allied nations contribute research points)
- **Unified Currency** (funding from all nations pools together)

**Bonus**: Can build bases in allied territory with no construction cost

---

#### Tier 4: World Government Formation (95%)
**Requirements**: Allied with ALL countries + Begin "Earth Unification" treaty

**Unlocks**:
- **One World Order** (all countries merge into single entity)
- **Global Mobilization** (recruit units from anywhere instantly)
- **Diplomatic Immunity** (karma irrelevant, all actions justified)

**Bonus**: Funding increases by +500% (entire world supports player)

---

#### Tier 5: VICTORY - Unified Earth Government (100%)
**Requirements**: Complete Earth Unification treaty + Hold 3 peaceful months (no wars)

**Victory Condition Met**: All nations united under single banner

**Victory Effects**:
- Campaign ends with global unification
- All borders dissolved, free movement globally
- United Earth Military formed (player becomes supreme commander)
- Alien threats negotiated away (peaceful coexistence)

**Ending Cinematic**: World leaders sign historic treaty, borders erased from maps, humanity speaks with one voice, peaceful future ensured

---

### Path-Specific Missions

- **"Peace Negotiations"**: Mediate conflicts between nations
- **"Cultural Exchange"**: Improve relations through shared values
- **"Joint Training Exercises"**: Coordinate with allied militaries
- **"World Congress"**: Present proposals to global assembly
- **"Unity Ceremony"**: Final mission, sign unification treaty

---

## Path 3: Military Domination

### Path Philosophy

**"Victory through strength. Peace through superior firepower. Humanity united by force."**

Victory through overwhelming military power. Eliminate all alien threats permanently, establish military supremacy, create fortress Earth.

### Victory Condition

**"Human Supremacy"**: Destroy ALL alien factions + Maintain 15+ military bases + Eliminate 200+ alien units

### Progression Metrics

```yaml
Progress Formula:
  Alien_Bases_Destroyed = (Destroyed_Bases) × 5
  Enemy_Casualties = (Aliens_Killed) / 2
  Military_Infrastructure = (Military_Bases_Built) × 10
  
Total Progress = (Alien_Bases_Destroyed × 0.4) + (Enemy_Casualties × 0.3) + 
                 (Military_Infrastructure × 0.3)
```

### Milestone Rewards

#### Tier 1: Military Buildup (25%)
**Requirements**: Build 5 military bases + Destroy 3 alien bases + Kill 50 aliens

**Unlocks**:
- **War Machine Facility** (2×2, double manufacturing speed for weapons)
- **"Veteran" Trait** for all units (+15% combat stats)
- **Propaganda System** (recruit units 50% cheaper)

**Bonus**: All units start at Rank 2 (trained soldiers, not rookies)

---

#### Tier 2: Strategic Superiority (50%)
**Requirements**: Build 10 military bases + Destroy 8 alien bases + Kill 100 aliens

**Unlocks**:
- **Elite Academy Facility** (3×3, trains Rank 4+ units directly)
- **Heavy Weapons Platform** (new craft type, massive firepower)
- **Blitzkrieg Tactics** (deploy 2× units per mission)

**Bonus**: Manufacturing weapons costs 50% less (mass production)

---

#### Tier 3: Total Warfare (75%)
**Requirements**: Build 15 military bases + Destroy 15 alien bases + Kill 150 aliens

**Unlocks**:
- **Orbital Strike Facility** (4×4, can destroy alien bases from space)
- **Doomsday Weapons** (nuclear/antimatter weapons, massive damage)
- **Fortress Earth Protocol** (all bases get +100% defensive capabilities)

**Bonus**: Can field 50% more units per mission (massive armies)

---

#### Tier 4: Alien Extinction (95%)
**Requirements**: Destroy 90% of alien factions + Begin "Final Purge" campaign

**Unlocks**:
- **War Memorial Facility** (honors fallen, +100 morale for all units)
- **Legendary Units** (Rank 7 "War Hero" class, unstoppable)
- **Scorched Earth** (can destroy alien homeworlds permanently)

**Bonus**: All alien technology becomes obsolete (human tech superior)

---

#### Tier 5: VICTORY - Human Supremacy (100%)
**Requirements**: Eliminate ALL alien factions + Hold territory for 3 months

**Victory Condition Met**: No alien threats remain, humanity dominant

**Victory Effects**:
- Campaign ends with alien extinction
- Earth becomes militarized fortress world
- Player organization becomes world government (military dictatorship)
- Galaxy trembles before human aggression

**Ending Cinematic**: Final alien stronghold destroyed, victory parade, humanity begins aggressive space colonization, eternal war machine

---

### Path-Specific Missions

- **"Extermination"**: Wipe out entire alien colonies (no survivors)
- **"Shock and Awe"**: Demonstrate overwhelming force to terrify enemies
- **"Fortress Defense"**: Hold bases against massive alien assaults
- **"Scorched Earth"**: Destroy alien homeworld (planet-killer weapon)
- **"Victory Parade"**: Final mission, celebrate total dominance

---

## Path 4: Shadow Conspiracy

### Path Philosophy

**"Control through manipulation. Power through secrets. Rule from the shadows."**

Victory through covert control. Manipulate all factions from behind scenes, install puppet governments, become invisible puppet master.

### Victory Condition

**"New World Order"**: Control ALL countries through coercion + Operate 10+ black ops + Karma < -50

### Progression Metrics

```yaml
Progress Formula:
  Countries_Controlled = (Puppet_Governments) × 10
  Black_Ops_Success = (Covert_Missions_Completed) × 5
  Shadow_Influence = (Karma_Below_Zero) × 2
  
Total Progress = (Countries_Controlled × 0.5) + (Black_Ops_Success × 0.3) + 
                 (Shadow_Influence × 0.2)
```

### Milestone Rewards

#### Tier 1: Shadow Operations (25%)
**Requirements**: Karma < 0 + Complete 5 covert missions + Control 2 countries

**Unlocks**:
- **Black Ops Facility** (2×2, enables assassination/sabotage missions)
- **"Shadow Agent" Unit Class** (stealth specialists)
- **Blackmail System** (force countries to comply through leverage)

**Bonus**: All covert operations 50% more likely to succeed

---

#### Tier 2: Puppet Masters (50%)
**Requirements**: Karma < -25 + Complete 10 covert missions + Control 5 countries

**Unlocks**:
- **Puppet Government Installation** (install friendly regimes)
- **Espionage Network Facility** (3×3, global intelligence gathering)
- **False Flag Operations** (frame enemies for atrocities)

**Bonus**: Can manipulate country relations remotely (+/- 20 at will)

---

#### Tier 3: Deep State (75%)
**Requirements**: Karma < -50 + Complete 20 covert missions + Control 8 countries

**Unlocks**:
- **Information Warfare Facility** (4×4, control global narrative)
- **Sleeper Agent Network** (agents in all organizations)
- **Total Surveillance** (know all enemy movements in advance)

**Bonus**: Enemies never detect player's true strength (deception mastery)

---

#### Tier 4: Shadow Government (95%)
**Requirements**: Karma < -75 + Control ALL countries + Begin "Consolidation"

**Unlocks**:
- **New World Order Facility** (5×5, shadow government headquarters)
- **Memory Wipe Technology** (erase public knowledge of player's actions)
- **Absolute Control** (all factions obey player without question)

**Bonus**: Can rewrite history (erase past mistakes from record)

---

#### Tier 5: VICTORY - New World Order (100%)
**Requirements**: Control all countries covertly + Maintain secrecy for 3 months

**Victory Condition Met**: Player controls world from shadows

**Victory Effects**:
- Campaign ends with invisible dictatorship
- Public believes elected governments rule (actually player puppets)
- All opposition eliminated silently
- Perfect control maintained through fear and deception

**Ending Cinematic**: Player sits in shadowy room, watching world leaders obey orders via screens, true power revealed only to player, dystopian ending

---

### Path-Specific Missions

- **"Assassination"**: Eliminate political threats permanently
- **"Blackmail"**: Gather compromising intel on world leaders
- **"False Flag"**: Stage attacks blamed on enemies
- **"Puppet Installation"**: Install loyal regime through coup
- **"Shadow Throne"**: Final mission, assume hidden control

---

## Path 5: Hybrid Paths

### Dual-Path Strategies

Players pursuing two paths simultaneously:

#### Technology + Military = "War Machine"
- Focus: Advanced weapons + overwhelming force
- Victory: Destroy aliens with superior technology
- Ending: Militarized technocracy, efficient but cold

#### Diplomatic + Technology = "Enlightened Unity"
- Focus: Share technology globally + unite through progress
- Victory: Peaceful advancement for all humanity
- Ending: Utopian federation, science and cooperation

#### Military + Shadow = "Iron Fist"
- Focus: Military dictatorship + covert control
- Victory: Rule through fear and secret police
- Ending: Totalitarian regime, order through oppression

#### Diplomatic + Shadow = "Velvet Glove"
- Focus: Appear diplomatic while manipulating behind scenes
- Victory: Control through false friendship
- Ending: Hidden oligarchy, benevolent facade

### Triple-Path Strategies

Pursuing three paths requires careful balance:

**Technology + Diplomatic + Military = "Hegemony"**
- Victory: Become unquestionable superpower (all advantages)
- Ending: Absolute dominance, player is god-emperor

**Any combination including Shadow conflicts with others**
- Shadow requires secrecy, other paths create fame
- Difficult but possible (schizophrenic organization)

### Generalist Strategy

Progressing all four paths equally:

**"Balanced" Ending**
- Victory: Achieve moderate success in all areas
- Ending: Competent but uninspiring, no clear identity
- Reward: Generic victory screen, least satisfying

---

## Victory Tracking System

### UI Elements

**Victory Dashboard** (accessible from Geoscape):
```
╔════════════════════════════════════════════════════╗
║           VICTORY PATH PROGRESS                    ║
╠════════════════════════════════════════════════════╣
║                                                    ║
║ [TECH] Technological Supremacy         [67%] ████▓▓▓▓▓▓░░ ║
║   Next: Complete 50 research projects (38/50)    ║
║   Reward: Post-Human Units + Auto-Research       ║
║                                                    ║
║ [DIPLO] Diplomatic Unification        [42%] ███░░░░░░░░░ ║
║   Next: Allied with 6 countries (4/6)            ║
║   Reward: Joint Military Ops + UN Council        ║
║                                                    ║
║ [WAR] Military Domination             [89%] █████████▓░ ║
║   Next: Destroy 15 alien bases (14/15)           ║
║   Reward: Orbital Strike + Fortress Earth        ║
║                                                    ║
║ [SHADOW] Shadow Conspiracy            [15%] █▓░░░░░░░░░ ║
║   Next: Lower karma to -25 (current: -10)        ║
║   Reward: Puppet Governments + Espionage         ║
║                                                    ║
║ [INFO] Hybrid Path Detected: War Machine         ║
║        (Tech + Military synergy active)          ║
╚════════════════════════════════════════════════════╝
```

### Progress Notifications

**Milestone Achievements**:
```
╔══════════════════════════════════════════╗
║   🏆 MILESTONE ACHIEVED! 🏆              ║
╠══════════════════════════════════════════╣
║                                          ║
║  Technological Supremacy: 50% Complete  ║
║                                          ║
║  UNLOCKED:                               ║
║  • Reverse Engineering System            ║
║  • Quantum Lab Facility                  ║
║  • AI Research Assistant                 ║
║                                          ║
║  BONUS: Manufacturing +20% faster        ║
║                                          ║
║  [View Details] [Continue]               ║
╚══════════════════════════════════════════╝
```

---

## Milestone Rewards

### Facility Unlocks

Each path provides exclusive facilities:

**Technology Path**:
- Prototype Lab (2×2) - Experimental research
- Quantum Lab (3×3) - Dimensional research
- Reality Anchor (4×4) - Prevents rifts

**Diplomatic Path**:
- Diplomatic Corps (2×2) - Relation building
- UN Council (3×3) - Joint governance
- Global Defense Initiative (4×4) - World HQ

**Military Path**:
- War Machine (2×2) - Fast weapon manufacturing
- Elite Academy (3×3) - Advanced training
- Orbital Strike (4×4) - Space weapons

**Shadow Path**:
- Black Ops (2×2) - Covert missions
- Espionage Network (3×3) - Intelligence
- Information Warfare (4×4) - Control narrative

### Unit Class Unlocks

Path-specific unit classes:

```yaml
Technology Path:
  - Post-Human (Rank 5): AI-enhanced soldiers
  - Nano-Augmented (Rank 4): Self-repairing units
  
Diplomatic Path:
  - Ambassador (Rank 4): Negotiation specialist
  - Peacekeeper (Rank 3): Non-lethal combat

Military Path:
  - War Hero (Rank 7): Legendary veteran
  - Shock Trooper (Rank 5): Heavy assault

Shadow Path:
  - Shadow Agent (Rank 4): Master infiltrator
  - Puppet Master (Rank 5): Manipulator
```

### Economic Bonuses

Path-specific economic advantages:

- **Technology**: Sell research for 2× credits
- **Diplomatic**: +500% funding from unified world
- **Military**: Weapon manufacturing 50% cheaper
- **Shadow**: Access to black market with no restrictions

---

## Victory Cinematics

### Technology Victory

**Scene 1**: Laboratory with scientists working on Singularity project  
**Scene 2**: First Post-Human unit activates (human merges with machine)  
**Scene 3**: Montage of humans uploading consciousness to collective  
**Scene 4**: Earth transforms into gleaming technological paradise  
**Scene 5**: Humanity begins colonizing galaxy via dimensional gates  

**Narration**: *"Today, humanity transcends flesh. Tomorrow, the universe."*

---

### Diplomatic Victory

**Scene 1**: United Nations assembly with all world leaders present  
**Scene 2**: Player representative delivers speech on unity  
**Scene 3**: Leaders sign historic Earth Unification Treaty  
**Scene 4**: Borders dissolve from map, become one nation  
**Scene 5**: Unified Earth fleet launches to explore galaxy peacefully  

**Narration**: *"United we stand, divided we fall. Today, humanity stands as one."*

---

### Military Victory

**Scene 1**: Final alien stronghold under siege  
**Scene 2**: Player units storm base, eliminate last resistance  
**Scene 3**: Victory parade with massive armies marching  
**Scene 4**: Monument erected honoring fallen soldiers  
**Scene 5**: Humanity builds fortress Earth, ready for any threat  

**Narration**: *"Through sacrifice and strength, humanity claims its destiny among the stars."*

---

### Shadow Victory

**Scene 1**: Player sits in dark room watching security feeds  
**Scene 2**: World leaders receive orders via encrypted channels  
**Scene 3**: Public believes democracy intact (actually puppets)  
**Scene 4**: Opposition silently eliminated in shadows  
**Scene 5**: Player smiles knowingly, world unknowingly controlled  

**Narration**: *"The greatest power is the power unseen. They will never know who truly rules."*

---

## Integration with Campaign

### Natural Emergence

Paths don't require pre-selection - they emerge from player behavior:

**Example Player Journey**:
```
Month 1-3: Learn game, establish bases (no path progress)

Month 4: Unlock victory paths notification
  → Player focuses on research (Tech progress begins)

Month 5-6: Complete many research projects (Tech 35%)
  → Notice Technology path progressing fastest

Month 7: Unlock Prototype Lab (Tech Milestone 25%)
  → Gain research bonuses, accelerate further

Month 8-10: Continue tech focus (Tech 67%)
  → Realize close to Technology victory

Month 11: Unlock Post-Human units (Tech Milestone 75%)
  → Commit fully to Technology path

Month 12: Complete Singularity research (Tech 100%)
  → VICTORY: Technological Supremacy achieved
```

### Path Switching

Players can switch paths mid-campaign:

- Progress retained (switching to Military doesn't erase Tech progress)
- Can return to previous path later
- Hybrid strategies emerge naturally
- No penalties for experimentation

### Endgame Flexibility

Near victory, players can:
- Rush one path to quick victory (specialized)
- Balance multiple paths for hybrid ending (flexible)
- Continue playing after victory (sandbox mode)

---

## Technical Implementation

### Progress Tracking

```lua
-- engine/geoscape/victory_paths.lua

VictoryPaths = {
  technology = {
    progress = 0.0, -- 0.0 to 1.0 (0% to 100%)
    milestones_achieved = {},
    current_bonuses = {},
    unlock_requirements_met = false
  },
  
  diplomatic = {
    progress = 0.0,
    milestones_achieved = {},
    current_bonuses = {},
    unlock_requirements_met = false
  },
  
  military = {
    progress = 0.0,
    milestones_achieved = {},
    current_bonuses = {},
    unlock_requirements_met = false
  },
  
  shadow = {
    progress = 0.0,
    milestones_achieved = {},
    current_bonuses = {},
    unlock_requirements_met = false
  }
}

function VictoryPaths:updateProgress(game_state)
  -- Update Technology path
  self.technology.progress = self:calculateTechProgress(game_state)
  
  -- Update Diplomatic path
  self.diplomatic.progress = self:calculateDiploProgress(game_state)
  
  -- Update Military path
  self.military.progress = self:calculateMilitaryProgress(game_state)
  
  -- Update Shadow path
  self.shadow.progress = self:calculateShadowProgress(game_state)
  
  -- Check for milestone achievements
  self:checkMilestones(game_state)
  
  -- Check for victory conditions
  self:checkVictoryConditions(game_state)
end

function VictoryPaths:calculateTechProgress(game_state)
  local research_progress = (game_state.research.completed_projects / 
                             game_state.research.total_projects) * 100
  
  local tech_tier = game_state.research.highest_tier_unlocked * 10
  
  local prototype_deployed = game_state.research.experimental_uses * 5
  
  return (research_progress * 0.6) + (tech_tier * 0.3) + 
         (prototype_deployed * 0.1)
end

function VictoryPaths:checkMilestones(game_state)
  for path_name, path_data in pairs(self) do
    if type(path_data) == "table" and path_data.progress then
      
      -- Check 25% milestone
      if path_data.progress >= 25 and not path_data.milestones_achieved[1] then
        self:unlockMilestone(path_name, 1, game_state)
      end
      
      -- Check 50% milestone
      if path_data.progress >= 50 and not path_data.milestones_achieved[2] then
        self:unlockMilestone(path_name, 2, game_state)
      end
      
      -- Check 75% milestone
      if path_data.progress >= 75 and not path_data.milestones_achieved[3] then
        self:unlockMilestone(path_name, 3, game_state)
      end
      
      -- Check 95% milestone
      if path_data.progress >= 95 and not path_data.milestones_achieved[4] then
        self:unlockMilestone(path_name, 4, game_state)
      end
    end
  end
end

function VictoryPaths:checkVictoryConditions(game_state)
  -- Technology Victory
  if self.technology.progress >= 100 and
     game_state.research.singularity_completed and
     game_state.units.post_human_deployed >= 5 then
    self:triggerVictory("technology", game_state)
  end
  
  -- Diplomatic Victory
  if self.diplomatic.progress >= 100 and
     game_state.politics.all_countries_allied and
     game_state.facilities.has_global_defense_initiative then
    self:triggerVictory("diplomatic", game_state)
  end
  
  -- Military Victory
  if self.military.progress >= 100 and
     game_state.aliens.all_factions_eliminated and
     game_state.bases.military_bases >= 15 then
    self:triggerVictory("military", game_state)
  end
  
  -- Shadow Victory
  if self.shadow.progress >= 100 and
     game_state.politics.all_countries_controlled and
     game_state.karma < -50 then
    self:triggerVictory("shadow", game_state)
  end
end

function VictoryPaths:triggerVictory(path_name, game_state)
  -- Stop game time
  game_state.time.paused = true
  
  -- Play victory cinematic
  Cinematics:play(path_name .. "_victory")
  
  -- Show victory screen
  GUI:showVictoryScreen(path_name, game_state)
  
  -- Log achievement
  Analytics:recordVictory(path_name, game_state.current_month)
  
  -- Offer continue option (sandbox mode)
  GUI:offerContinueOption()
end
```

---

## Conclusion

The Divergent Victory Paths system transforms AlienFall from an open-ended survival game into a goal-oriented strategic experience. By providing clear victory conditions matching diverse playstyles, players gain strong motivation to specialize and replay with different approaches.

**Key Success Metrics**:
- Replay rate increases by 300% (4 distinct paths)
- Player retention improves (clear goals to pursue)
- Strategic diversity increases (multiple valid approaches)
- Ending satisfaction improves (thematic payoff)

**Implementation Priority**: MEDIUM (Tier 2)  
**Estimated Development Time**: 2-3 weeks  
**Dependencies**: Geoscape.md, Politics.md, Research.md  
**Risk Level**: Low (systems mostly exist, just need tracking + rewards)

---

**Document Status**: Design Proposal - Ready for Review  
**Next Steps**: Implement progress tracking, design cinematics, playtest balance  
**Author**: Senior Game Designer  
**Review Date**: 2025-10-28

