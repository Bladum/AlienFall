# Units (`units.md`)
*Purpose: Details soldier stats, classes, and progression for player-controlled forces.*
### Basic Definitions

#### Unit Stats
Core attributes and numerical values defining unit capabilities and performance.

health      hit points
strenght    how much items can carry
energy      energy pool for actions / ammo / fatigue
armour      in build armour 

react       reaction fire / dodge / melee attack
aim         how accurancy good at fire / thrown
speed       how move fast

will        aka bravery for morale tests
morale      battle level fear resistnace
sanity      resistance for long term stress
psi         psionic skills 

sight       day / night range of sight, one dirction
sense       day / night range of sight, omni
cover       hide from enemy sight / sense

size        size for barracks and craft capacity, and battle scape

rank            rank, which is number of promotions to get here
salary          basic salary when player
race            basic race for this class
output class    list of classes that this class might be prompted to

inventory       list of standard inventory for enemy player

#### Unit Classes
Specialized roles like in Wesnoth, determining base stats and abilities.
Each unit class has fixed stats
Each unit class can be promoted to other specific class inside a class tree
Each unit promotion store all classes on a list, so we can check for "class needed or all child class too"
Unit needs to get specific number of EXP to get promoted


#### Unit Experience and Promotion System
Level progression through combat experience leading to stat improvements and unlocks.
Level 0     0 XP
Level 1     100 XP
Level 2     300 XP
Level 3     600 XP
Level 4     1000 XP
Level 5     1500 XP
Level 6     2100 XP

Experience is made by
    - training in base, 1XP per week + bonus from facilities
    - battles 
    - wounds
    - medals from battles

#### Unit Action Points
Resource system for performing actions during combat turns.
Basic unit AP is 4 and defines what unit can do during turn 
Typical basic action cost 1AP
Always replenish at start of turn
Can be impacted by low morale, sanity, wounds, traits

### Unit Move points
Movement points are used to move unit
MP = AP * Unit speed
Speding MP automatically spent AP and viceversa
Cost to move 
    rotate by 90 deg = 1MP
    move on normal terrain = 2MP
    move on tough terrain = 4MP
    move on very tough terrain = 6MP
    move diagonal +50%

#### Unit Energy
Internal resource pool for special abilities and enhanced actions.
Basic unit energy is 6-12 range, and basic energy regen is 1/3 of energy
Equipment heavily infuence energy pool / regen
Unit starts with full pool, replenish is at end of turn
Used for using weapons and some actions (running)

#### Unit Traits
Innate characteristics and personality modifiers affecting behavior and performance.
In most cases trait is pernament, added when unit is created
This works both for player, enemy and ally units
Some traits might be limited to race or class
Traits are e.g. Smart (20% less exp needed for promotion or Fast (have 5 AP not 4 etc))

#### Unit Transformation
Permanent or temporary changes to unit capabilities through research or events.
Every unit has single slot for transformation and it is pernament by default
Transformation usually is done in special facility on specific unit (mechanic / live)

#### Unit Equipment
Weapons, armor, and gear that modify stats and provide special abilities.
In general all units have armour (unless its in build) and 2 weapons. 
Weapon can be anything, there is no limitation even for 2 two handed weapons. 
The only limitation is unit strenght limit and some items requires race / class to use. 
Equpiment can be change in base, before battle during planning
In battle armour cannot be changed, and weapons can be changed

#### Unit Race
Species or faction origin affecting appearance, and lore integration.
Mostly used for checks if unit is race, by itself does not provide any bonus. 

#### Unit Faces
Visual customization and identification system for individual units.
This is just random face for unit only for player to add a flavour, 
4 colors, 2 sex, 8 versions, 4 races

#### Unit Wounds
Injury system tracking damage accumulation and recovery requirements.
1 Wound during battle is considered to be critical wound, and cause 1 health point lose per turn. 
ALl wounds after battled are healed automatically, and health lost are converted to weeks in hospital 
1 health point after battle takes 1 week to recover, unless there is hospital facility to speed this up. 
Wounds are caused by critical hits, some weapons have higher chance to get critical hit and get a wound
This is much more dramatic then system in ufo xcom

#### Unit Roles Based on Class and Equipment
Dynamic specialization determined by class training and equipped gear.

#### Unit Psionic Skills
Mental abilities and psychic powers for advanced units.

#### Unit Sight/Sense/Cover
Perception systems, detection ranges, and environmental interaction mechanics.
Sight - ability to unhide terrain during battle in front of unit side 90 deg cone
Sense - ability to unhide terrain during battle omnidirectional but short range
COver will decrease other units to detect this unit
All stats here are provided seperatly for day and night missions
Equipment can impact all these during battle

#### Unit Morale
Psychological state affecting combat effectiveness and decision making.
Unit starts every battle with morale 10
Every failed morale test (test against its bravery) cause 1 morale lost
if morale is less then 4 then it start to lose AP per turn
morale 3 -> AP 3, morale 2 -> AP 2, morale 1 -> AP 1, morale 0 -> AP 0
The only way to restore morale is by other unit action or by this unit REST action
Morale is recovered after battle to 10
Leadership skills can recover morale faster on battle field

#### Unit Sanity
Mental stability system preventing psychological breakdown from combat stress.
Unit sanity if fixed between 6-12 range
It might be impacted AFTER battle based on how insane mission is (0, -1, -2, -3)
Low sanity effect is same as morale, it impact unit AP per turn 
Sanity after battle is recovered 1 per week + bonus from facilities
This is to simulate long time psychic impact on units

#### Unit Encumbrance
Equipment weight limits affecting movement speed and action efficiency.
In general if unit has strenaght 8 it can cary up to 8 units of equipment. 
There is no affect on actions as its binary system, either it fits or not. 
Equipment may improve strenght or may provide negative weight but first must be equiped. 

#### Unit Salaries
Ongoing payment system for maintaining unit loyalty and performance.
Each class has a salary from 10K to 120K which is paid monthly
Salary increase with class and promptions
Most classes on the same rank has the same salary
Some traits like rolay may impact salary cost

#### Unit Medals
Achievement recognition system for combat accomplishments and service.
Medal is one time high bonus to experience from specific mission. 
Unit cannot achieve same medal twice. 
Medals are added to unit after mission if mission assume for win to get this medal. 
Medal is one time boost to experience points, and later it does not benefit unit at all 

#### Unit Recruitment
Process of hiring and training new personnel for the organization.
Purchase entry may allow to buy specific unit with basic unit classes with may be unlocked by research
Access to specific supplier may also unlock specific option to buy unit class
Units might be also manufactured (if mechanical) or captured during battle 

#### Unit Rank
Hierarchical position system affecting authority, pay, and special privileges.
In general every promotion for unit using experience system will boost its rank by 5
Most starting units are 1 and maximum is 5