class Modifiers:

    def __init__(self, data = {}):

        # diplomacy

        self.mod_diplomats_max = 1.0                      # max number of diplomats
        self.mod_diplomat = 0                             # number of diplomat income per year
        self.mod_diplomat_skills = 1.0                    # diplomatic skill modifier

        self.mod_vassal_income = 1.0                      # modifier for base vassal income

        self.mod_spies_max = 1.0                          # max number of spies
        self.mod_spy = 0                                  # number of spies income per year
        self.mod_spy_skills = 1.0                         # spy skills modifier

        self.mod_generals_max = 1.0                       # max number of generals
        self.mod_general = 0                              # generals income per year

        # global actions and FAME impact

        self.mod_fame_reduce = 1.0                        # how fast you reduce your bad fame, default is 0.5 per year
        self.mod_fame_act = 1.0                           # how negative FAME points you get default is 1.0

        # land army

        # province level

        self.mod_army_morale = 1.0                      # local province level morale bonus

        self.mod_army_manpower = 1.0                    # local manpower from province modifier
        self.mod_manpower_national = 1.0                # local manpower from province CORE
        self.mod_manpower_other = 1.0                   # local manpower from province NON CORE

        self.mod_army_training = 0.0                    # local number of exp points army get from province with this mod

        # country level

        self.mod_armies_max = 1.0                       # max number of armies modifier
        self.mod_army_maintenance = 1.0                 # global army maintenance modifier
        self.mod_army_morale_max = 0.0                  # global max army morale

        self.mod_army_movement = 1.0                    # global army movement modifier
        self.mod_army_offense = 1.0                     # global army offense modifier
        self.mod_army_defense = 1.0                     # global army defense modifier
        self.mod_army_siege = 1.0                       # global army siege modifier

        self.mod_army_infantry_movement = 1.0           # global INF units movement modifier
        self.mod_army_cavalry_movement = 1.0            # global CAV units movement modifier
        self.mod_army_artillery_movement = 1.0          # global ART units movement modifier

        self.mod_army_infantry_offense = 1.0            # global INF units offense modifier
        self.mod_army_cavalry_offense = 1.0             # global CAV units offense modifier
        self.mod_army_artillery_offense = 1.0           # global ART units offense modifier

        self.mod_army_infantry_defense = 1.0            # global INF units defense modifier
        self.mod_army_cavalry_defense = 1.0             # global CAV units defense modifier
        self.mod_army_artillery_defense = 1.0           # global ART units defense modifier

        self.mod_army_infantry_siege = 1.0              # global INF units siege modifier
        self.mod_army_cavalry_siege = 1.0               # global CAV units siege modifier
        self.mod_army_artillery_siege = 1.0             # global ART units siege modifier

        self.mod_army_entrench = 1.0                     # global army entrench level modifier
        self.mod_army_experience = 1.0                   # ??
        self.mod_army_supplies = 1.0                     # ilosc zaopatrzenia jak daleko moze chodzic armia
        self.mod_army_wounded = 0.5                      # chance to unit get killed or wounded
        self.mod_army_battle_length = 0.5                # default lenght of batlte phases based on army size

        self.mod_army_attrition = 0.0                    # global chance to get enemy army lose a unit as war of attrition

        # fortifications

        self.mod_fort_cost = 1.0                         # global cost to build new fort
        self.mod_fort_maintenance = 1.0                  # global cost to maintain fort
        self.mod_fort_units = 1.0                        # local size of army inside forts as local defenders
        self.mod_fort_supplies = 1.0                     # local number of turns province will defend siege

        # ships

        # per province

        self.mod_navy_manpower = 1.0                     # number of ships being build in province
        self.mod_navy_morale = 1.0                       # morale of fleet build in this province
        self.mod_navy_training = 1.0                     # local bonus to experience of navy from shipyard
        self.mod_naval_piracy = 1.0                      # chance for enemy ship to be wounded on our national waters

        # global

        self.mod_navies_max = 1.0                       # global number of navies

        self.mod_navy_movement = 1.0                    # global navy movement
        self.mod_navy_offense = 1.0                     # global navy offense
        self.mod_navy_defense = 1.0                     # global navy defense

        self.mod_navy_warship_movement = 1.0            # global warship movement
        self.mod_navy_galley_movement = 1.0             # global galley movement
        self.mod_navy_transport_movement = 1.0          # global transport movement

        self.mod_navy_warship_offense = 1.0             # global warship offense
        self.mod_navy_galley_offense = 1.0              # global galley offense
        self.mod_navy_transport_offense = 1.0           # global transport offense

        self.mod_navy_warship_defense = 1.0             # global warship defense
        self.mod_navy_galley_defense = 1.0              # global galley defense
        self.mod_navy_transport_defense = 1.0           # global transport defense

        self.mod_navy_warship_cost = 1.0                # global price for warships
        self.mod_navy_galley_cost = 1.0                 # global price for galley
        self.mod_navy_transport_cost = 1.0              # global price for transport
        self.mod_navy_maintenance = 1.0                 # global maintenance cost for ships

        self.mod_navy_experience = 1.0                  # additional mod for offence, albo z GENERAL albo z WALKI

        self.mod_navy_supplies = 1.0                    # default supplies for navy
        self.mod_navy_damaged = 1.0                     # default chance to damage or destroy ship
        self.mod_navy_battle_length = 1.0               # default lenght of one battle phase

        # korupcja

        self.mod_corruption_distance = 1.0               # waste reduction due to distance to capitol           -5% za każde 5
        self.mod_corruption_size = 1.0                   # waste reduction due to size of country               -5% za każde 10
        self.mod_corruption_connection = 1.0             # waste reduction due to no connection to capital     -25%
        self.mod_corruption_religion_diff = 1.0          # waste reduction due to religion difference             -25%
        self.mod_corruption_culture_diff = 1.0           # waste reduction due to culture difference              -25%

        # stabilizacja

        self.mod_stab_cost = 1.0                    # base cost to increase stability
        self.mod_war_exhaustion = 1.0               # max duration of war without additional revolt risk
        self.mod_rebelion_delay = 1.0               # time after which rebelion province will become independent

        # trade

        self.mod_trade_income = 1.0                   # global modifier for trance income After COT
        self.mod_trade_cot_max_usage = 1.0            # global modifier max COT value converted to income per country
        self.mod_trade_value = 1.0                    # local province trade value modifier
        self.mod_trade_tariffs = 1.0                  # global trade tariffs, cost for others to sent merchants on us
        self.mod_trade_refusal = 1.0                  # ???

        self.mod_merchants_max = 1.0                  # global max number of merchants
        self.mod_merchant = 0.0                       # merchant income per year
        self.mod_merchant_duration = 1.0              # global, how long merchant stays in COT
        self.mod_merchant_cost = 1.0                  # global, cost to sent merchant to COT

        # colonization / explorers

        self.mod_explorers_max = 1.0                    # max number of explorers
        self.mod_explorer = 0.0                         # number of explores per year
        self.mod_explorer_cost = 1.0                    # cost to sent explorer

        self.mod_colonists_max = 1.0                    # max number of colonists
        self.mod_colonist = 0.0                         # number of colonist per year
        self.mod_colonization_cost = 1.0                # cost to sent colonist

        self.mod_advisors_max = 1.0                     # max number of advisors
        self.mod_advisor = 0                            # number of advisors per year
        self.mod_advisor_cost = 1.0                     # ????

        self.mod_missionaries_max = 1.0                 # max number of missiionaries
        self.mod_missionary = 0                         # number of missionary per year
        self.mod_missionary_religion_cost = 1.0         # global religion cost convertion
        self.mod_missionary_culture_cost = 1.0          # global culture cost convertion

        # culture specific

        self.mod_bravery = 1.0                            # local province level bonus to army bravery
        self.mod_revolt_risk = 0.0                        # local province level change to revolt risk of province

        # population & agriculture

        self.mod_population_growth = 1.0                  # local province population growth in % per year
        self.mod_population_supply = 0                    # max size of army province can supply

        # economy

        self.mod_income_national = 1.0                    # global income from production for national province
        self.mod_income_other = 1.0                       # global income from production for non national province
        self.mod_production_income = 1.0                  # local basic income from production for province
        self.mod_land_movement_cost = 1.0                 # local province army movement modifier

        # infrastructure

        self.mod_building_cost = 1.0                      # global cost of building new building
        self.mod_engineers_max = 1.0                      # max number of engineers
        self.mod_engineer = 0                             # number of engineers per year

        # technology

        self.mod_inventors_max = 1.0                      # max number of inventors
        self.mod_inventor = 0.0                           # new inventors per year
        self.mod_tech_cost = 1.0                          # global technology cost modifier
