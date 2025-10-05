		

co wpływa na wartosc handlowa prowincji ?
    baze province level
    wartosc handlowa surowca
        low         5-10%
        medium      15-20%    
        high        25-30%
    marketplace budynek         x2
    polityka rzadu ?            +25% za poziom
    przykład
        level           12 
        high value      30%
        + marketplace   x2
        politycs        +50%
        12 * 0.3 x2 + 50% = 12
    centrum handlowe zbiera wszystkie prowincje w zasiegu i ma jakas wartosc
    np 800 punktów handlu


(icons temporary) 

diplomacy has 5 statuses and 1 numeric value. It is always about relation between 2 countries. Ally of my ally is not my ally etc.. In general all these 5 statuses are not related to each other and their combination can bring interesting complex cases.

**Military status **-> war | peace | alliance. And in this case its only used to get other countries into same war. Alliance does not mean shared view or access or anything else then bring your allies to war. 
**Trade status **-> agreement | normal | embargo -> controls cost of sending merchant to COT own by country OR via territory owned by country
**Access status** ->  access  | normal | block -> either we have military access to other country, including map exploration or we actually hide | block our data from them (including they cannot see / move to our territory). This comes at cost of course
**Finance status** -> sent tribute | nothing | receive tribute 

## GOODS
    Province may have a resource which may improve province value
    goods are in categories:
        good -> improve population growth
        commodity -> improve tax from province
        trade -> improve trade value of province

    in general value of good is like
        v low   5       50%
        low     10      75%
        medium  15      100%
        high    20      125%
        v high  25      150%

    food            5 types
        FISH        10      
        GRAIN       5       
        RICE        5       (instead of GRAIN in Asia)
        CORN        5       (instead of GRAIN in America)
        LIVESTOCK   10      (rare everywhere instead of GRAIN) 

    commodity       6 types       
        CLOTH       15      
        FURS        10      
        WINE        15      
        LUMBER      5       
        WOOL        5           
        SALT        15      
    
    mines                   6 types
        COPPER      15          
        GOLD        30      
        IRON        20      
        SLAVES      5       
        GEMS        40      NEW
        COAL        10      NEW

    exotic                  10 types
        COFFEE      10      
        TEA         10      
        COTTON      10      
        SUGAR       15      
        TOBACCO     10      
        SPICES      15      
        IVORY       20      
        CHINAWARE   15      
        DYES        10      NEW
        COCOA       15      NEW

## PROVINCE POPULATION
    population growths always in % per year
    it means 15% means it will growth from 5.00 to 5.15 within a year
    province LEVEL is square root from population 
        1 -> L1
        16 -> L4
        49 -> L7
    
    what impact population growth ?
        country stability       -3 to +3%
        capitol                 +1%
        farmlands               +3%
        terrain                 +1%
        climate                 -2%
        COT                     +2%
        occupied                -5%
        looted                  -10%
        enemy                   -20%
        food resource           +2%

## RULER
    ruler has 3-4 stats in range from 1 to 6 highest
        admin
        diplomatic          
        military        morale of army, generation of generals
        technology      generation of tech points

## COUNTRY BUDGET

    spending limits per area
    military            50% - 100% - 150%       basic morale of army / navy    
    technology          0% - 10% - 20%          additional inventors
    taxes               50% - 100% - 150%       
    diplomacy           0% - 10% - 20%          additional diplomats

## ARMY MORALE

    What impact on morale of army
    Land technology level               +10% per level
    Policies                            +25% per polic
    Religion                            e.g. +10%
    Ruler                               per MIL skill +10%
    army leader                         per skill +10%
    stability country                   -30% + 30%
    pogoda / climate
    experience of army
    terrain of battle
    army morale
    entrench level
    supplies level
    leaders orders during battle

## COUNTRY SIZE

    country size modified 
	tiny	1		x1	
	small	2-4		x2	
	medium	5-9		x3	
	large	10-16	x4	
	huge	17+		x5	

    impact on 
        number of armies is based on size of country in provinces
        cost of technology
        basic size of corruption in provinces due to size of country

## MILITARY MOVEMENT

    as game turn is 1 month, armies and navies has basic move points per turn,
    This is mainly based on technology
        level   days
        0       28
        1       29
        2       30
        3       31
        4       32
        5       33
        6       34
        7       35
        8       36
        9       37
        10      38
        11      39
        12      40
    
    general may increate speed of its army with TACTICS stat
        1 point gives 5% more points, with baseline = 3

    each unit type has its own speed move
        infrantry       x1.0
        cavalery        x2.0
        artilery        x0.5

    each base terrain has its own move cost
        plains          8
        forest          10
        marsh           14
        hills           16
        desert          12
    roads in province will decrease move points by 4 points

## NAVY MOVE 

    unit speed
        warship     x1
        galley      x1.5    (cannot enter ocean)
        transport   x0.5
    Base cost to enter province
        coastal     10
        sea         15
        ocean       30

## ARMY LEADER
    army leader has some stats
        offensive   bonus to attack 
        defensive   bonus to defense
        siege       bonus to attack during sieges
        tactics     who play first, bonus to move speed

## FAME
    
    this is more or less bad boys or infamy points
    being awarded with points based on global actions
    may impact global relations with other countries

## LAND MANPOWER

    each province gives some manpower to recruit armies
    baseline is province LEVEL
        is not CORE province        -50%
        not connected to capitol    -25%
        has barracks                +100%
        is capitol                  +50%
        some policies               +25%
        min value                   1
        
    manpower locally is regenerated to full within 2 years
    there is no global manpower, only local manpower
    on country level there is just report how much manpower in each province is

    mercenaries does not consume manpower, but instead they cost double gold to buy and maintain

## PROVINCE TAXES

    baseline value is province LEVEL 
        goods modifier for production       50% - 150%
        manufatory                          +100%
        capitol                             +25%
        state religion                      80-120%
        culture diff                        75%
        religion diff                       75%
        no connect to capitol               75%
        technology INFRA                    30% + Tech level * 10%
        stability                           -20% to +20%
        tax level                           50% to 150%
        occupied (rest takes occupant)      50%
        state policies                      up to 150%

## AGENTS
    
    agent is mechanism to limit number of actions in specific area for country
    diplomat        perform diplomatic and espionage actions
    merchant        trade with Center of trades        
    settler         explore provinces under TI and colonize empty provinces     
    general         build new armies, train them
    missionary      convert province culture / religion
    inventor        unlock country TECHNOLOGIES
    advisor         unlock country POLICIES
    engineer        build BUILDING in provinces

    how collect agents per year?
        diplomat
            base value      +1
            ruler skill     DIP -1
            state religion  0 to +2
            at war          +1
            state policies  up to +3
        spy ?
            TODO
        merchant
            each owned COT      +1
            trade tech          tech / 4
            state policies      from -3 to +3
            religion            up to +3
            coastal provinces   count / 4
            stabiility          from -3 to +3
        settlers
            religion            up to +2
            shipyard            +1
            state policies      up to +3
        explorer / colonist
            TODO
        general
            state policies      0 to +3
            ruler skill         MIL / 2
        missionary
            state policy        -3 to +3
            state religion      0 to +2
            temple              +0.2 per province
        inventor
            ruler skill         ADMIN / 2
            tech agreement      +0.5 ?
            library             +0.2 per province
            money from budget   ???
        advisors
            ruler skill         ADMIN / 2
            ??
        engineers
            base                1
            ruler skill         ADMIN / 2
            budget              +1 +2 +3
            state policy        do +3
            tech level INFRA    tech / 3

## POLICIES

    there is an open list of policies available to country
    each cost some advisors to enable, it always hit stability by 1, 2, 3 points
    each policy has 3 levels
    each level cost 3 / 6 / 9 advisors to unlock, this may vary policy by policy
    each change on policies takes some time before next move can be done, usually its 3 years
    some policies may be limited to
        culture, religion, area, region,  technology, country tag, etc...
    policies may be disabled, it cost TIME and STAB hit but advisors return to pool and can be reused

## DIPLOMACY & ESPIONAGE

    special agent DIPLOMAT is used to perform action
    in general all diplomatic actions consume 1 agent and have some chance
    and all espionage actions consume varied number of agents
        10% of fail and diplomatic impact
        70% of nothing
        20% of success

## EXPLORATION

    you dont sent army / ships to discover map
    you select any province that is nearby terra incognita (it will be highlited by green)
    you can sent explorer depends on distance and chance (e.g. there is war ongoing nearby)
    after N turn explorer either will success or not, making one random province nearby visible
    you spend settlers agents to perform this action

    you can trade which provinces you explored as part of diplomacy

## COLONIZATION

    all explored provinces ladn without owner that you can travel to are hightlighted yellow
        either by sea
        either by land, only your neighbours
    it cost settler agent to do so and some money
    it may fail based on collization difficulty of region / terrain / climate / natives
    once successful you get province with population 1

## BUDGET
    Incomes
        Province taxes
        Trade -> from COT from your merchants
        Tarrifs -> for other merchants going on your country
        Lotting -> your army is on enemy province
        Gold -> from special resource GOLD
        Tributes -> from diplomatic actions
        Interest -> from lending money to others
    Expenses
        Maintance -> upkeep your armi, forts and navy
        Technology -> invest into new stuff
        Stability -> invest into make your country more stable
        Corruption -> lost due to corruption (distance to cap, size of country)
        Tributes -> from diplomatic actions
        Interests -> from loans 

    Sliders for expenses
        Tax level
        Militaty Maintenance level 
        Technology investment level
        Stability invest level
        Tarrifs levels
        Espionage 

## CENTER OF TRADE

    there are from 20 to 30 provinces 
    each COT takes total value from all provinces that belogs to it
    countries can trade in COT

## TRADE VALUE OF PROVINCE
    
    base level province
    value trade 

## LAND BATTLE
    
    two sides of battle, may contain of many armies
    all units are put into two battle armies
    each unit has a chance to fire
    it randomly select enemy unit (3/6 chance for INF, 2/6 CAV , 1/6 ART)
    it damage it, and if its already damage, then kill it
    hit is calculated as ratio between attacker attack and defender defense

    how miltary works in game ?
    in province there are some navies and land armies
    game assume no air units, so its before 1920
    each army has 3 category of units
        infantry
        cavalry
        artillery
    army has a leader with some skills 1-6
    army has an experience and morale
    army has action points (as this is turn based game)
    same all with navy

    how military is presented ?
        on province under flag there is a number that shows total number of units / ships
        there is no information to whom they belong to, or if this is navy or army
        if player click on province in side panel there would be all details

    how battles works ?
        if armies meet on battle field then special battle mode is used
        each country has a technology level for LAND and NAVAL units in range 0-12 (extended 0-15)
        naming convention
            ARMY
                has INF, CAV, ART as numbers
            FLEET
                has WAR, GAL, TRA as numbers
            CATEGORY
                INF, CAV, ART, WAR, GAL, TRA
            CLASS
                INF -> HI, LI, RI
                CAV -> HC, LC, RC
                ART -> HA, LA, SA
                etc
            TYPE
                Pikeman, Bowman, Arqebuzer, Knight, Samurai etc...
                Each type belongs to single CLASS
            UNIT
                Single unit of a specific TYPE 
        unit categories for naval fleets are divided:
            WAR 
                Light warship
                Heavy warship
            GAL
                Light galley
                Heavy galley    
            TRA
                transport
        Based on technology level in specific area (LAND / NAVAL) player gets max type of unit
        Based on player state policies player get ratio of specific categories
        so for level LAND 7 and mobile warfware policy 
            9 INF -> 30% RI + 30% HI + 40% LI -> 3 RI + 3 HI + 3 LI


## BASIC MODEL OF POPULATION 

## IDEAS FOR ECONOMY 

grain + fish or meat -> food     

timber -> lumber -> paper   
                 -> chair



ore + coal  -> iron -> arms
                    -> tools 
copper ?

horse
oil -> fuel -> energy

sugar -> rum 
tobaco -> cigars
furs -> coats 
cotton  -> fabric -> cloth
wool    -> fabric -> cloth

spice -> $$ 5
silver -> $$ 10
gold -> $$ 15
gems -> $$ 20

goods

zaczac od czegos prostego

        
prowincja ma 
    level (który lekko przenosi sie na populacje np 17 -> 153K)
    growth który jest w % rocznie np 7% rocznie -> 7 na 7.07 w 12 tur
    level jest podstawa do wszystkich podatków etc...





country menu ktore klikam w button na gorze lewej, zarzadzam swoim krajem
    score results
    ruler & goverment type & create vasal etc
    cultures, accepted / tolerance sliders
    state policies / ideas
    diplomacy
    espionage
    agents - z czego wynikaja jacy agenci na ture
    budget / expences / income / taxes
    trade / trade routes / number of merchants etc
    religion / state religion  / tolerance sliders
    technology / invest into level
    missions / select mission
    social = stability / war wariness / revolt risk
    military upkeep for land / naval, manpower 
    resources collected on provinces and bonus it gives
    stats in time aka BI

clikam w stolice innego kraju i widze
    informacje ogolne o kraju
    opcje dyplomatyczne z krajem


click province panel w dolnym rogu lewym
    basic information
    army / navy movement
    army / navy build
    building build
    colonize / explore ??
    battle
    

map types button
    terrains
    political
    diplomatic
    economic (type of good)
    religion
    culture
    trade (COT range)
    geography region / area / continent
    explore / colonize options
    revolt risk
    climate
    plagues etc
    wars ? battles ? war
    stability country level
    weather ?    
    manpower / population level / growth level ?
    technology level per country / province ?
    fort level or in general infrastructure level
						

















							
# BUILDINGS

## General info
- provinces can be improved by building
- It takes some time and money and engineer agent to build a building

List   
- fort:               province defences
- farm:               province growth
- barracks:           army building manpower + generals
- shipyard:           ship building + colonits
- manufactory:        local tax
- library:            inventors
- market:             value for trade + merchants
- roads:              move cost on province
- temple:             zmniejsza revolt risk + missionary

Some building may be multilevel and may depend on 
- area
- region
- continent
- country tag
- climate
- religion
- culture
- province ID
- technology level
- how many other countries build it ? WONDER


# Population

### Core concepts

- Province has a level similar to games like Civilization or Eador.
- Population calculated from level is applied on province level, not a single city. 
- Usually it is up to 6 for good province at start, 9 in the middle and 12 in end game.
- Having 4 province with level 3 is more or less same for power calculation like 2 with power of 6 or 1 with power of 12
- All changes to population are done on level, the actual population is only for reporting. 

### Population growth

- Population level grows automatically in % per decade
- Very good growth is aprox 15-20% per decade which means 1 level up for 50-70 years
- Growth is not related to actual population, its not 20% from base, but it means +0.2 level for 10 years

### Base income from population

- Population level is used for growth only and display on the map
- Actual modifier of income from this province is taken as Bonus column from table below
- Province must grow to specific level to get bonus, nothing is calculated with float values
- Each province level is aprox 20-25% stronger than previous one

### Level of province

- Table can help to convert level of province to aprox population and what is income bonus (depends on model)

| LVL | Pop [k]   | Bonus | Bonus 2 | Bonus 3 |
|-----|-------|-------|--------|-------|
| 1   | 1     | 0.1   | 10%    | 100%  |
| 2   | 2     | 0.2   | 20%    | 110%  |
| 3   | 4     | 0.3   | 30%    | 120%  |
| 4   | 8     | 0.4   | 38%    | 130%  |
| 5   | 16    | 0.5   | 47%    | 150%  |
| 6   | 32    | 0.6   | 59%    | 170%  |
| 7   | 64    | 0.75  | 73%    | 190%  |
| 8   | 128   | 0.95  | 92%    | 220%  |
| 9   | 256   | 1.2   | 114%   | 250%  |
| 10  | 512   | 1.5   | 143%   | 280%  |
| 11  | 1024  | 1.85  | 179%   | 320%  |
| 12  | 2048  | 2.25  | 224%   | 360%  |
| 13  | 4096  | 2.75  | 279%   | 400%  |
| 14  | 8192  | 3.3   | 349%   | 450%  |
| 15  | 16384 | 4     | 437%   | 500%  |

### What impact population growht 

- base value              +5%
- country stability       -3 to +3%
- capitol                 +1%
- farmlands               +3% per level 
- terrain                 e.g. +1%
- climate                 e.g. -2%
- COT                     +2%
- nearby COT              +1%
- occupied                -5%
- looted                  -10%
- enemy                   -20%
- food resource           e.g. +2%
- current level           -1% per level

# TECHNOLOGY

### General info

- Game has 6 areas how technology can be improved
- Teach area is in level from 0 to 15 (for 600-700 years game)
- Each level costs agent Inventor to unlock
- The higher the level the higher the cost
- Everytime you buy technology, there is 1 year lock not to be able to buy again
- There is no stab hit to buy technology
- Technology cannot be sold to regain inventors
- Technology can be shared in diplomacy screen
- Technology can be stolen or bought

### What impact cost of technology ?

- Size of country
- Techgroup
- Current level of technology
- State religion
- Year, as some technologies can be unlocked only later on

### Timeline 

Year of technology

- Pre EU
  - 0 (1250-1350)
  - I (1350-1440) 

- Core EU
  - II (1440-1510) 
  - III (1510-1570) 
  - IV (1570-1620) 
  - V (1620-1660) 
  - VI (1660-1690) 
  - VII (1690-1720) 
  - VIII (1720-1750) 
  - IX (1750-1780) 
  - X (1780-1810)
  - XI (1810-1830)
  - XII (1830-1850)
 
- Post EU
  - XIII (1850-1870)
  - XIV (1870-1890)
  - XV (1890-1910) 

### Types of technologies

- Military 
  - LAND      how good you are with land warfrafe
  - NAVAL     how good you are with naval warfrare

- Economy
  - INFRA     how good you are in making money on your own provinces and building new infrastructure
  - TRADE     how good you are in making money on virtual market e.g. trade or finance

- Governance
  - ADMIN     how good you manage your own country, mainly policies (domestic sliders, ideas etc)
  - FOREIGN   how good you manage relation with other countries including diplomacy and espionage  

### Technology DOES NOT impact on
-  Culture
-  Religion
-  Population (indirectly via new infrastructure)
-  Exploration (indirectly via new options to explore)

# DIPLOMACY 


### DIPLOMAT

Diplomatic actions are in table.
They are always either negative, positive or neutral.
Clicking button will perform action vs this country and of its status type, also switch to it if succesfull. 

| Relation       | Negative  | Neutral  | Positive  | type    |
|----------------|-----------|----------|-----------|---------|
| Trade          | Embargo   | -        | Agreement | status  |
| Military       | War       | Peace    | Alliance  | status  |
| Access         | Demand    | -        | Grant     | status  |
| Vassal         | Subjugate | -        | Submit    | status  |
| Dynasty        | Rivalry   | -        | Union     | status  |
| Relations      | Damage    | -        | Improve   | onetime |
| Money          | Demand    | Loan     | Give      | onetime |
| Province       | Demand    | Exchange | Give      | onetime |
| Religion       | Convert   | -        | Tolerate  | onetime |
| Culture        | Convert   | -        | Tolerate  | onetime |
| Agents         | Block     | -        | Expand    | onetime |
| Resources      | Steal     | Exchange | Share     | onetime |
| Technology     | Steal     | Exchange | Share     | onetime |
| Maps           | Steal     | Exchange | Share     | onetime |
| Ruler          | Overthrow | -        | Advise    | onetime |
| Leader         | Eliminate | -        | Train     | onetime |
| Fame           | Slander   | -        | Enhance   | onetime |
| Revolt risk    | Rebel     | -        | Suppress  | onetime |
| Units          | Bribe     | -        | Share     | onetime |
| Population     | Decline   | -        | Grow      | onetime |
| Manpower       | Deplete   | -        | Mobilize  | onetime |
| Stability      | Disrupt   | -        | Secure    | onetime |
| Infrastructure | Sabotage  | -        | Develop   | onetime |
| Policies       | Subvert   | -        | Reform    | onetime |

## One time actions

### Relation
- Improve or damage relation between countries, which are between -100 to +100
### Money
- Demand lump sum of gold as tribute 
- Offer loan on interest
- Offer to give a lump sum of gold as a gift
### Province
- Demand to give a province
- Exchange provinces
- Offer to give a provinc
### Religion
- Demand state religion convertion to our state religion
- Tolerate religion of another country ????
### Culture
- Demand to adapt culture as national
- Tolerate culture of another country ????
### Agents
- Try to block other country agents (they will lose them)
- Try to expand other country agents (they will gain them)
### Resources
- Try to steal other country resource
- Start exchange resources 
- Share a resource for free
### Technology
- Try to steal other country technology
- Start exchange technology 
- Share a technology for free
### Maps
- Try to steal other country maps
- Start exchange maps 
- Share a maps for free
### Rule
- Try to overthrow other country ruler, so it will be gone and another ruler will take over
- Try to advice other country ruler so it will have benefits for 1 years to his skills
### Leader
- Try to eliminate other country army or navy leader
- Try to train other country random leader and get higher level
### Fame
- Try to slender other country fame (negative bad boys) so other countries may not like them
- Try to Enhance fame of other country so other countries will like them more
### Revolt risk
- Try to help local rebels so random provinces have increased revolt risk
- Try to suppress local rebels and help local government so random provinces have decreased revolt risk
### Units
- Try to bribe some units inside army so they will be destroyed
- Share some your units with other country. It will be moved to capital city
### Population
- Try to impact province population growth and make it decline by few %
- Try to grow local population and make it incrase by few %
### Manpower
- Try to impact province manpower and make it deplete by some time
- Try to mobilize local manpwoer and increase it by some time
### Stability
- Try to disrupt country stability (stab hit)
- Try to Secure country stability (increase stab)
### Infrastructure
- Try to sabotage a building inside province
- Try to invest into a building inside a province ??
### Policies
- Try to subvert other country to drop one of its policies
- Try to help other country to reform with specific policy

## Change status action

### Trade
- Embargo
  - Reduced cost of merchant in COT
  - Reduced cost of merchant patch via country to COT
- Normal
- Agreement
  - Reduced cost of merchant in COT
  - Reduced cost of merchant patch via country to COT
### Military
- War
  - Can use military  operations over enemy
- Peace
- Alliance
  - Only means that if at war with alliance it will also change to war
### Access
- Demand
  - You can move your army over enemy provinces
- Normal
- Grant
  - Other country can move army / navy over your provinces
### Vassal
- Subjugate
  - You are senior and receive 30% of your vassal income 
- Normal
- Submit
  - You become vassal and give 30% of income to your senior
### Dynasty
- Rivalry
  - You are from two rival houses
  - ??
- Normal
- Union
  - This is personal union sharing same dynasty
  - ??

# FORTS

Province may have a building that improve defences level
Normally fort gives +5 to defences but other building may be different
Each level of province defence give local army + number of months for siege
   - N   army size / months with supplies
   - 1   1 / 3
   - 2   2 / 6
   - 3   3 / 9
   - 4   4 / 12
   - 5   5 / 15
   - 6   6 / 18

fort cost 
    200$ per level so level 5 cost 1000$
    takes 3 turns to build per level
    technology required is fort size * 2 so 2, 4, 6, 8, etc

# Exploration

Player collect explorer agent on country level
It could be used to explore region, area or continent
No units are used to unlock territories, it must be connected to your own explored area and just unlock it
each province based on location and size and terrain type / climate has cost to explore
Areas are cheap (based on province count and size), regions are x2 cost they should and continent are x3 cost they should

When sharing / stealing maps with other countries you never explore individual provinces, but areas, regions, continents

# Tactical warfare

## General info

Armies has 3 **types** of units:
- Infantry 
- Cavalry 
- Artillery 
- Leader (special unit that is created when strong leader is on army)
- Wall  (special unit that is created when defending province with FORT)

Scale is aprox 2-4k soldiers = 1 unit
Navies has 3 **types** of units: 
 - warship, 
 - small ship, 
 - transport
 - admiral

### Special unit Leader

Leader is unit that has very small fight skill BUT can support friendly units nearby:
 - Heal 
 - Improve morale (double move)
 - Panic enemy (lose move) 
 - has high sight range 
 - can cover nearby unit ?
 - can ghost one friendly unit ?

### Units on forts

Wall is special unit only during sieges. It works like a wall 4 tiles from right side.

Type of wall is based on your land tech level:
- Palisade
- Stone
- Stone 2 ?
- Concreate ?

For every level of fort in province you will get: 
- 1 artillery unit based on your tech level
- 2 infantry unit based on your tech level
- No cavalry neither leader 

Max number of fort is 5 so total 5 ART and 10 INF + Walls

## Morale

### How morale works during battle

Army has morale that is from range -5 to +5 with default 0

Each level means some chance for:
 - if > 0 then double move this turn
 - if < 0 lose move this turn

Panic due to damage:
- unit has 10 HP
- every HP below 5 has 10% to lose turn
- if unit that has failed morale test and has less then 5HP will flee 

### What impacts morale before battle ?

Country ruler military skill 
- skill 1-2     -1
- skill 3-4     0
- skill 5-6     +1

Country state religion
- peacefully    -1
- warmonger     +1

Military upkeep on country level
- low      -1 for 50%
- medium   0 for 100%
- high     +1 for 150%

country policies up to +-2

### How morale is changing during battle ?

- Unit got damage = lose 0.1
- Army lose unit = lose 0.2
- Army lose leader = lose 0.5
- Army kill enemy unit = gain 0.1
- Army kill enemy leader =  gain 0.2

Every turn your morale is moving to initial value by +- 0.2

### How morale is used to calculate moves

Each unit has 1 move per turn
Each morale above 0 is 10% chance to have additional move this turn
Each morale below 0 is 10% chance to have panic this turn and have no moves

### Unit type on battlefield is based on:
 - size of Army per category INF / CAV / ART
 - country technology level LAND / NAVAL, always pick the best unit
 - country tech group
 
### Tech groups:
- Western
- Eastern
- Ottoman
- Muslim
- Indian
- Nomad
- Chinese
- African
- New World (native americans, polynesia, meso america, andean )

### Unit Table

- Land technology level spans from 0 to 15 that gives aprox 6 ranks of units in each category.
- Different tech group may have strong / weak units in different epochs 

## Unit Types

Unit stats (defined on TYPE level)
- fire         damage when using range attack
- shock        damage when using melee attack
- defense      chance to deduct damage       
- range        range of attack (1 for melee)
- speed        move speed per turn
- hitpoints    in general all have 10
- ammo         number of attacks per battle

# Battle field

Battle field is 12x8 small map with units created from each army. 
Each battlefield is build from map blocks each is 4x4 and are hand made for terrain type of province.
Each map block can be randomly selected before inserted into battle field. 
Attacker is on left, defender on right. 
Any fortification that exist on defender province will be added as special type of unit -> Fort


# Game epochs

Compared to suggested technology level

- MILITARY
  - land warfare
  - naval warfare
- POLITICS
  - manage administration of your own country
  - manage relation with other countries
- ECONOMY
  - manage production & infra on province level
  - manage trade, finance, services on country level
- TECHNOLOGY

# Military leader 

## General info

- Each army has a leader (general), each navy has leader (admiral)
- Land Leader has stats from 1 to 5
  - Siege - how fast you can capture province with fort     
  - Leadership - how you impact morale of your army -2 to +2 
  - Maneuver - how many special unit of generals you will have ?

# FAQ

## What if country want to have both bowman and pikeman ?
- provide more names in unit_type_table and game will random unit from this list e.g. pikeman,pikeman,archer

## How technology is bought
- Like in imperialism. We do check each tech and if its available
- Techs do show up only AFTER year like in imperialism
- You can unlock them with Inventor points


# NEW MODEL

TECHNOLOGY, 6 categories, 15 levels
    land
    naval
    trade
    infra
    admin
    diplo

[GOVERNMENT]() - one to choose from 10

POLICIES - 12 sliders, 11 levels from -5 to +5 
    Governance:     
    Progress:       
    Nobility:       
    Servitude:      
    Commerce:      
    Expansion:      
    Domain:         
    Conscription:   
    Balance:        
    Honor:          
    Social:        
    
NATIONAL IDEAS 
    these are flags, you adopt them or not based on your ADVISORS points
    number of ideas are limited
