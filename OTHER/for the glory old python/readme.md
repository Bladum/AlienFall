		

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

## Building
    provinces can be improved by building
    It takes some time and money and engineer agent to build a building
    
    fort:               province defences
    farm:               province growth
    barracks:           army building manpower + generals
    shipyard:           ship building + colonits
    manufactory:        local tax
    library:            inventors
    market:             value for trade + merchants
    roads:              move cost on province
    temple:             zmniejsza revolt risk + missionary

    some building may be multilevel and may depend on 
        area
        region
        continent
        country tag
        climate
        religion
        culture
        province ID
        technology level
        how many other countries build it ? WONDER

## Province defences
    Each level of province defence give local army + number of months for siege
    0   army size / months with supplies
    1   5 / 3
    2   10 / 6
    3   15 / 9
    4   20 / 12
    5   25 / 15
    6   30 / 18

    fort cost 
        200$ per level so level 5 cost 1000$
        takes 3 turns to build per level
        technology required is fort size * 2 so 2, 4, 6, 8, etc

## TECHNOLOGY
    Game has 5-6 areas how technology can be improved
    Teach area is in level from 0 to lets say 12-15 (for 600 years game)
    Each level costs agent Inventor to unlock
    The higher the level the higher the cost
    Everytime you buy technology, there is 1 year lock not to be able to buy again
    There is no stab hit to buy technology
    Technology cannot be sold to regain inventors
    Technology can be shared in diplomacy screen

    What impact cost of technology ?
        Size of country
        Techgroup
        Current level of technology
        State religion
        Year, as some technologies can be unlocked only later on
        ....

    Year of technology
        0 (1250-1350)
        1 (1350-1440) 
        2 (1440-1510) 
        3 (1510-1570) 
        4 (1570-1620) 
        5 (1620-1660) 
        6 (1660-1690) 
        7 (1690-1720) 
        8 (1720-1750) 
        9 (1750-1780) 
        10 (1780-1810)
        11 (1810-1830)
        12 (1830-1850)
        13 (1850-1870)
        14 (1870-1890)
        15 (1890-1910) 

    Types of technologies
        LAND    military land
        NAVAL   military ships
        INFRA   province infrastructure and production
        ADMIN   country administration level
        TRADE   global trade level
        ????    
    
    Technology DOES NOT impact on
        Diplomacy
        Culture
        Religion
        Population
        Exploration

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
        unit category for land armies are divided for battle purpose into:
            INF
                Heavy INF       slow, armoured units like swordsman
                Light INF       melee units like pike-man
                Ranged INF      archers, bowman, and firearms
            CAV
                Heavy CAV       heavy shock knights
                Light CAV       light scout squires, later with basic firearms 
                Ranged CAV      cavalry archers, dragoons
            ART
                Heavy ART       standard catapult, bombards, cannons
                Light ART       mobile artillery with horses, late game, heavy machine guns
                Static ART      only for fort defenses like ballista     
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
        Unit stats (defined on TYPE level)
            fire         damage when using range attack
            shock        damage when using melee attack
            range        range of attack (1 for melee)
            defense      chance to deduct damage       
            speed        move speed per turn
            hitpoints    in general all have 10
            ammo         number of attacks per battle
        example:
                        MEL	RNG	POW	DEF	MOV	SEE AMM TYPE
            peasant	    3	1	0	3	2	1   16  LI
            squire	    4	1	0	4	4	3   16  LC
            pikeman	    5	1	0	5	2	2   16  HI
            knight	    6	1	0	6	3	1   12  HC
            arquebus	1	2	5	3	2	2   8   RI
            bowman	    2	3	3	2	2	2   12  RI
            culverin	1	4	8	2	1	1   4   HA
            general     1   1   0   2   3   4   8   HQ
            palisade    0   1   0   8   0   1   0   DEF


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
    teren 
    religie 
    kulture
    klimat 
    surowiec 
    
prowincja ma 
    armie           
        piechota    
        kavaleria   
        artyleria   
        leader
    flote 
        warships
        galleys
        transports
        
prowincja ma 
    level (który lekko przenosi sie na populacje np 17 -> 153K)
    growth który jest w % rocznie np 7% rocznie -> 7 na 7.07 w 12 tur
    level jest podstawa do wszystkich podatków etc...

    