class Modifiers:

    def __init__(self, data = {}):

        # AGENTS

        self.diplomat = 0  # country or province, number of diplomat income per year
        self.diplomat_max = 12  # country or province, max number of diplomats

        # what about spies ?

        self.general = 0  # country or province, number of agents collecte
        self.general_max = 12  # country or province, max number of agents

        # what about explored / colonist ?

        self.settler = 0  # country or province, number of agents collecte
        self.settler_max = 12  # country or province, max number of agents
        self.settler_coastal = 0  # country or province, number of agents collected only from coastal provinces
        self.colonize_cost = 1.0  # country, cost to perform missions on colonize
        self.colonize_chance = 1.0  # country, chance to perform missions on colonize

        self.advisor = 0  # country or province, number of agents collecte
        self.advisor_max = 12  # country or province, max number of agents
        self.policy_cost = 1.0  # country modifier to cost of policy

        self.merchant = 0  # country or province, number of agents collecte
        self.merchant_max = 12  # country or province, max number of agents
        self.merchant_cost = 1.0  # country, modifier to sent a merchant in ducats
        self.merchant_movement = 1.0  # province, modifier to merchant movement path
        self.merchant_duration = 1.0  # country, modifier how long merchant stays at COT

        self.inventor = 0  # country or province, number of agents collecte
        self.inventor_max = 12  # country or province, max number of agents
        self.tech_cost = 1.0  # country modifier to cost of technology

        self.engineer = 0  # country or province, number of agents collecte
        self.engineer_max = 12  # country or province, max number of agents

        self.missionary = 0  # country or province, number of agents collected per year
        self.missionary_max = 12  # country or province, max number of agents

        self.religion_convert_cost = 1.0  # country, cost to perform missions on religion convert
        self.religion_convert_time = 1.0
        self.culture_convert_cost = 1.0  # country, cost to perform missions on culture convert
        self.culture_convert = 1.0  # province, how fast culture convert is

        self.vasal_income = 1.0

        # DIPLOMACY

        self.diplomacy_eff = 1.0  # country, country modifier to chance for all diplomatic actions
        self.espionage_eff = 1.0  # country, modifier for spy missions

        # STABILITY

        self.stability_cost = 1.0  # country cost of stability for 1 level
        self.stability_invest = 0  # country, monthly change of stab (range is from -3 to +3)
        self.war_exhaustion = 1.0  # country, during war period how long you can
        self.rebelion_delay = 1.0
        self.revolt_risk = 0  # country or province level, revolt risk in % per month
        self.revolt_strength = 1.0  # province level how strong are rebels if they already happen
        self.nationalism_religion = 1.0  # province level modifier if people are revolting due to religion difference
        self.nationalism_culture = 1.0  # province level modifier if people are revolting due to culture difference
        self.piracy_risk = 0  # province level piracy chance on water / land, random
        self.bravery = 0  # province, morale of units build from this province

        # wind penelty move to climate / weather
        # galley penelty move to type of terrain like sea / ocean

        # TRADE

        self.trade_eff = 1.0  # country, trade effieciency mod on trade from COTs
        self.trade_cot_max_usage = 0.25  # country, max value of COT assigned to one country
        self.trade_value = 1.0  # province, value for COT
        self.trade_tariffs_cot = 1.0  # country, value of tariffs on COT level to owner
        self.trade_tariffs_road = 1.0  # country, value of tariffs on merchant path
        self.trade_boycott = 0  # country, something with trade refusal

        # EXPLORE

        self.vp_discovery = 0  # province, get points for who first discover this place
        self.vp_colonization = 0  # province, get points for who first have province in this place
        self.explore_cost = 1  # province, cost to explore this province

        # FAME

        self.fame = 0  # country / province - change of fame per turn
        self.fame_eff = 1.0  # country - modifier to all actions that cause change of fame

        # CORRUPTION

        self.corruption = 1.0  # province - total impact on corruption on this province
        self.coruption_distance = 1.0  # country - corruption related to distance from capitol
        self.coruption_size = 1.0  # country - corruption related to size of country
        self.coruption_no_capitol = 1.0  # country - corryption related to no connection to capitol
        self.coruption_religion_diff = 1.0  # country - corruption related to religion diff
        self.coruption_culture_diff = 1.0  # country - corruption related to

        # ARMY

        self.army_morale = 1.0  # country / province / army land army morale modifier
        self.army_cost = 1.0  # country / province land army build cost in gold
        self.army_wounds = 0.5  # country / province land army ability to heal after battle
        self.army_upkeep = 1.0  # country land army maintenance cost
        self.army_manpower = 1.0  # country / province land army modifier to build units

        self.army_experience = 1.0  # country modifier how fast army gain experinece
        self.army_train = 1.0  # province / army - how army get experience via training
        self.army_attrition = 1.0  # country / province -  modifier to attrition for your units, which is damage taken on province without battle
        self.army_siege = 1.0  # country / army - modifier to your army how much they do consume supplies of fort during siege
        self.army_movement = 1.0  # country / army / province - what is cost to move for army
        self.army_speed = 1.0  # country / army / province - how fast is army
        self.army_supply = 1.0  # country or province modifier how large army can be suplied in province

        self.army_max = 1.0  # country or province, max nmber of armies for a country

        self.army_mercenary = 1.0  # province, price of mercenary, if zero then not available
        self.army_entrench = 1.0  # province modifier ???

        self.unit_quality = {}  # country / province / army - quality of this category of unit, morale
        self.unit_cost = {}  # country / army - bonus to morale to unit category
        self.unit_speed = {}  # country / army - bonus to speed to unit category
        self.unit_experience = {}  # country / army - bonus to experience to unit category

        # NAVY

        self.navy_morale = 1.0  # country or province modifier to naval morale
        self.navy_cost = 1.0  # country or province modifier to build cost of navy
        self.navy_wounds = 0.6  # country or province modifier for auto repair of units after battle
        self.navy_upkeep = 1.0  # country modifier of naval units maintenance
        self.navy_manpower = 1.0  # country or provice modifier of naval manpower available to build units

        self.navy_experience = 1.0  # country, modifier how fast you gain experince on army levels
        self.navy_train = 1.0  # province, how navy in this province get experience via training
        self.navy_piracy = 1.0  # ????
        self.navy_attrition = 1.0  # country modifier to attrition for your units, which is damage taken on province without battle
        self.navy_movement = 1.0  # country / army / province - modifier to navy on terrain level
        self.navy_speed = 1.0  # country / army / province - how navy moves fast
        self.navy_supply = 1.0  # country or province modifier how large navy can be supplied in province

        self.navy_mercenary = 1.0  # province, price of mercenary, if zero then not available
        self.navy_max = 1.0  # country or province max number of navies for a country

        self.unit_quality = {}  # country / province / army - quality of this category of unit, morale
        self.unit_cost = {}  # country / province / army - bonus to morale to unit category
        self.unit_speed = {}  # country / army - bonus to speed to unit category
        self.unit_experience = {} # country / army - bonus to experience to unit category

        # POPULATION

        self.population_growth = 3  # province level, population growth in % per decade for all provinces
        self.population_growth_island = 0  # province level, population growth in % per decade for islands
        self.population_growth_coastal = 0  # province level, population growth in % per decade for coastal
        self.population_growth_inland = 0  # province level, population growth in % per decade for inland
        self.isolation_penalty = 1.0  # country, modifier to ??? when country has no

        # PLAGUE

        self.plague_risk = 0.0  # province, chance to get this province with plague as source
        self.plague_spread = 0.2  # province, chance to get this province spread plague to neighbours, where there is no plague yet
        self.plague_duration = 0  # province, how long plague last in province until it will die out
        self.plague_mortality = 0  # how plague affects population growth in province
        self.population_health = 1.0  # country or province level ability to fight with illness

        # WEATHER

        self.wind_power = 1.0  # province, ability to impact ships on sea similar way to morale (lose move or get move)
        # weak wind, there is a chance ship will lose turn due to no wind
        # string wind, there is a chance ship will gain turn / get damage due to weather

        # PRODUCTION

        self.production_eff = 1.0  # province or country, income from production of goods

        # FINANCE

        self.taxes_eff = 1.0  # province or country, income from population
        self.budget_spending = 1.0  # country, total spending from budget before going to treasure

        # CORE

        self.manpower_core = 1.0  # country, modifier to manpower for core provs
        self.manpower_non_core = 0.5  # country, modifier to manpower for non core provs
        self.tax_core = 1.0  # country, modifier to taxes for core provs
        self.tax_non_core = 0.5  # country, modifier to taxes for none core provs
        self.production_core = 1.0  # country, modifier to production for core provs
        self.production_non_core = 0.75  # country, modifier to production for non core provs

        # BUILIDNG

        self.building_cost = 1.0  # country, modifier to cost of building in ducats
        self.building_time = 1.0  # country, modifier to time build of building in turns

        # FORT

        self.fort_cost = 1.0  # country, modifier to fort cost in ducats
        self.fort_upkeep = 1.0  # country, modifier to upkeep exisits forts
        self.fort_units = 1.0  # province, how many units exist in fort for purpose of assult
        self.fort_defences = 3.0  # province, how strong defences in province vs enemy siege skill
        # higher supplies = longer siege as defender
        # if its zero then province is captured

        # BATTLE

        self.battle_initiative = 0  # army, who first starts battle, if difference is more then 1 then it got free turn
        self.general_chance = 0  # army, chance to have a special general unit for this battle