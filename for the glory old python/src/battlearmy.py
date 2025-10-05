import random
from enum import Enum

import polars

polars.Config.set_tbl_cols(1000)
polars.Config.set_tbl_width_chars(1000)

class BattleStatus(Enum):
    RETREAT = "Retreat"
    DESTROY = "Destroy"
    CONTINUE = "Continue"


class VictoryStatus(Enum):
    ATTACKER = "Attacker"
    DEFENDER = "Defender"
    DRAW = "Draw"
    NONE = 'None'


MORALE_LOSS_ENCIRCLED = {
    0: 0.00,
    1: 0.10,
    2: 0.20,
    3: 0.30,
    4: 0.40,
    5: 0.50,
    6: 0.60,
    7: 0.70,
}

UNIT_STATS = {
    'infantry': {
        'gold_cost': 10,
        'manpower_used': 1,
        'speed': 1.0,
        'offensive': 1.0,
        'defensive': 2.0,
        'siege': 0.5,
        'hit_chance': 3 / 6
    },
    'cavalry': {
        'gold_cost': 20,
        'manpower_used': 1.5,
        'speed': 2.0,
        'offensive': 2.0,
        'defensive': 1.0,
        'siege': 0,
        'hit_chance': 2 / 6
    },
    'artillery': {
        'gold_cost': 30,
        'manpower_used': 0.5,
        'speed': 0.5,
        'offensive': 3.0,
        'defensive': 0.5,
        'siege': 2.0,
        'hit_chance': 1 / 6
    }
}

EXPERIENCE_BONUSES = {
    270: 1.7,
    210: 1.6,
    150: 1.5,
    100: 1.4,
    60: 1.3,
    30: 1.2,
    10: 1.1,
    0: 1.0
}

TECHNOLOGY_BATTLE_BONUSES = {
    0:  0.50,
    1:  0.75,
    2:  1.00,
    3:  1.25,
    4:  1.50,
    5:  1.75,
    6:  2.00,
    7:  2.25,
    8:  2.50,
    9:  2.75,
    10: 3.00,
    11: 3.25,
    12: 3.50
}

GENERAL_BONUS = {
    1: 0.8,
    2: 1.0, # default
    3: 1.2,
    4: 1.4,
    5: 1.6, # normal max general
    6: 1.8,
    7: 2.0  # superhero general
}

# idea behind this is max technology is double speed of min technology
TECHNOLOGY_MOVE_BONUSES = {
    0:  0.75,
    1:  0.80,
    2:  0.85,
    3:  0.90,
    4:  0.95,
    5:  1.00,
    6:  1.05,
    7:  1.10,
    8:  1.15,
    9:  1.20,
    10: 1.25,
    11: 1.40,
    12: 1.50

}

ENTRENCHED_BONUS_INITIATIVE = {
    0: 1.0,
    1: 1.1,
    2: 1.3,
    3: 1.5
}

BATTLE_CHANCE_TO_EVADE = 2 / 8
BATTLE_CHANCE_TO_WOUND = 3 / 8
BATTLE_CHANCE_TO_KILL = 2 / 8
BATTLE_CHANCE_TO_CRITICAL_HIT = 1 / 8


TERRAIN_MODIFIERS = {
    'plains': {
        'infantry': 1.0,
        'cavalry': 1.25,
        'artillery': 1.0,
        'defense': 1.0
    },
    'forest': {
        'infantry': 1.0,
        'cavalry': 0.5,
        'artillery': 1.0,
        'defense': 1.25
    },
    'mountains': {
        'infantry': 0.75,
        'cavalry': 0.5,
        'artillery': 1.0,
        'defense': 1.5
    },
    'swamp': {
        'infantry': 0.5,
        'cavalry': 0.25,
        'artillery': 0.75,
        'defense': 0.75
    },
    'desert': {
        'infantry': 1.0,
        'cavalry': 1.0,
        'artillery': 1.0,
        'defense': 1.0
    }
}


class LandArmy:

    def __init__(self):

        self.owner_tag = 'REB'
        self.units = 10
        self.name = "Name"


class BattleArmy:
    def __init__(self, name, battle_side, infantry, cavalry, artillery, general, technology_level, morale = 1.0, entrenched = 0):
        self.infantry = {'live': infantry, 'wounded': 0, 'killed': 0 }
        self.cavalry = {'live': cavalry, 'wounded': 0, 'killed': 0 }
        self.artillery = {'live': artillery, 'wounded': 0, 'killed': 0 }
        self.name = name
        self.battle_side = battle_side
        self.technology_level = technology_level
        self.general = general
        self.speed = 0
        self.initiative = 1
        self.entrenched = entrenched
        self.experience = 0
        self.morale = morale
        self.offensive_power = 1.0
        self.defensive_power = 1.0
        self.times_hit_this_phase = 0
        self.active = True

    def calculate_average_speed(self):
        total_units = self.infantry['live'] + self.cavalry['live'] + self.artillery['live'] + \
                      self.infantry['wounded'] + self.cavalry['wounded'] + self.artillery['wounded']

        # killed units are left behind
        # wounded units have half of speed
        _wounded_mod = 0.5
        # live units have normal speed

        if total_units == 0:
            self.speed = 0

        weighted_speed_sum = ((self.infantry['live'] + self.infantry['wounded'] * _wounded_mod ) * UNIT_STATS['infantry']['speed'] +
                              (self.cavalry['live'] + self.cavalry['wounded'] * _wounded_mod ) * UNIT_STATS['cavalry']['speed'] +
                              (self.artillery['live'] + self.artillery['wounded'] * _wounded_mod ) * UNIT_STATS['artillery']['speed'])

        speed = round( weighted_speed_sum / total_units, 2)

        # Apply technology move bonus
        technology_move_bonus = TECHNOLOGY_MOVE_BONUSES.get(self.technology_level, 1.0)

        self.speed = speed * technology_move_bonus

    def check_retreat(self):
        if self.morale <= 0:
            self.morale = 0
            return True
        else:
            return False

    def check_destroy(self):
        if self.infantry['live'] <= 0 and self.cavalry['live'] <= 0 and self.artillery['live'] <= 0:
            self.infantry['live'] = 0
            self.cavalry['live'] = 0
            self.artillery['live'] = 0
            return True
        else:
            return False

    def select_unit_to_be_hit(self):
        infantry_weight = self.infantry['live'] * UNIT_STATS['infantry']['hit_chance']
        cavalry_weight = self.cavalry['live'] * UNIT_STATS['cavalry']['hit_chance']
        artillery_weight = self.artillery['live'] * UNIT_STATS['artillery']['hit_chance']

        total_weight = infantry_weight + cavalry_weight + artillery_weight
        if total_weight == 0:
            return None

        roll = random.uniform(0, total_weight)
        if roll < infantry_weight:
            return 'infantry'
        elif roll < infantry_weight + cavalry_weight:
            return 'cavalry'
        else:
            return 'artillery'

    def resolve_hit(self):

        # select which type of defender unit type to be hit
        unit_to_hit = self.select_unit_to_be_hit()
        if unit_to_hit:
            roll = random.random()
            if roll < BATTLE_CHANCE_TO_CRITICAL_HIT:
                self.__dict__[unit_to_hit]['killed'] += 1
                self.__dict__[unit_to_hit]['live'] -= 1
                self.morale -= 0.5           # larger lose of morale due to killed
                self.experience += 0.75      # some more experience from getting killed
                print(f"          One {unit_to_hit} killed critically, morale left {self.morale:.2f}")

            elif roll < BATTLE_CHANCE_TO_CRITICAL_HIT + BATTLE_CHANCE_TO_KILL:
                self.__dict__[unit_to_hit]['killed'] += 1
                self.__dict__[unit_to_hit]['live'] -= 1
                self.morale -= 0.25         # larger lose of morale due to killed
                self.experience += 0.5      # some more experience from getting killed
                print(f"          One {unit_to_hit} killed, morale left {self.morale:.2f}")
            elif roll < BATTLE_CHANCE_TO_CRITICAL_HIT + BATTLE_CHANCE_TO_WOUND + BATTLE_CHANCE_TO_KILL:
                self.__dict__[unit_to_hit]['wounded'] += 1
                self.__dict__[unit_to_hit]['live'] -= 1
                self.morale -= 0.1          # small lose of morale due to wound
                self.experience += 0.25     # some experience from getting wounded
                print(f"          One {unit_to_hit} wounded, morale left {self.morale:.2f}")
            else:
                self.experience += 0.1      # micro experience gain from being hit but no damage
                print(f"          Hit but no loss")

        if self.check_retreat():
            return BattleStatus.RETREAT
        if self.check_destroy():
            return BattleStatus.DESTROY
        return BattleStatus.CONTINUE

    def calculate_experience_bonus(self):
        for exp, bonus in sorted(EXPERIENCE_BONUSES.items(), reverse=True):
            if self.experience >= exp:
                return bonus
        return 0.0

    def calculate_offensive_unit_bonus(self, terrain_name):
        total_units = self.infantry['live'] + self.cavalry['live'] + self.artillery['live']
        if total_units == 0:
            return 0

        terrain_bonus = TERRAIN_MODIFIERS.get(terrain_name, {'infantry': 1.0, 'cavalry': 1.0, 'artillery': 1.0})

        offensive_sum = (self.infantry['live'] * UNIT_STATS['infantry']['offensive'] * terrain_bonus['infantry'] +
                         self.cavalry['live'] * UNIT_STATS['cavalry']['offensive'] * terrain_bonus['cavalry'] +
                         self.artillery['live'] * UNIT_STATS['artillery']['offensive'] * terrain_bonus['artillery'])

        return offensive_sum / total_units

    def calculate_defensive_unit_bonus(self, terrain_name ):
        total_units = self.infantry['live'] + self.cavalry['live'] + self.artillery['live']
        if total_units == 0:
            return 0

        terrain_bonus = TERRAIN_MODIFIERS.get(terrain_name, {'defense': 1.0})

        defensive_sum = (self.infantry['live'] * UNIT_STATS['infantry']['defensive'] +
                         self.cavalry['live'] * UNIT_STATS['cavalry']['defensive'] +
                         self.artillery['live'] * UNIT_STATS['artillery']['defensive']) * terrain_bonus['defense']

        return defensive_sum / total_units

    def calculate_technology_bonus(self):
        return TECHNOLOGY_BATTLE_BONUSES.get(self.technology_level, 1.0)

    def calculate_general_offensive_bonus(self):
         return GENERAL_BONUS.get( self.general.offensive , 1.0)

    def calculate_general_defensive_bonus(self):
         return GENERAL_BONUS.get( self.general.defensive , 1.0)

    def calculate_general_siege_bonus(self):
         return GENERAL_BONUS.get( self.general.siege , 1.0)

    def calculate_initiative(self):

        general_tactics_mod = GENERAL_BONUS.get(self.general.tactics, 1.0)

        army_size = self.infantry['live'] + self.cavalry['live'] + self.artillery['live']

        def calculate_army_size_initiative(army_size):
            if army_size <= 3:
                return 1.5
            elif army_size <= 6:
                return 1.4
            elif army_size <= 10:
                return 1.3
            elif army_size <= 15:
                return 1.2
            elif army_size <= 21:
                return 1.1
            elif army_size <= 28:
                return 1.0
            elif army_size <= 36:
                return 0.9
            elif army_size <= 45:
                return 0.8
            elif army_size <= 55:
                return 0.7
            elif army_size <= 66:
                return 0.6
            else:
                return 0.5

        army_size_mod = calculate_army_size_initiative(army_size)

        technology_level_mod = TECHNOLOGY_MOVE_BONUSES.get(self.technology_level, 1.0)

        entrenched_mod = ENTRENCHED_BONUS_INITIATIVE.get(self.entrenched, 1.0)

        random_mod = random.uniform(0.8, 1.2)

        self.calculate_average_speed()

        # Calculate initiative based on the given factors
        self.initiative = (self.speed * general_tactics_mod * army_size_mod *
                           technology_level_mod * entrenched_mod * random_mod)

    def calculate_offensive_power_total(self, terrain_name):
        general_offensive_mod = self.calculate_general_offensive_bonus()
        experience_mod = self.calculate_experience_bonus()
        technology_mod = self.calculate_technology_bonus()
        unit_offensive_mod = self.calculate_offensive_unit_bonus(terrain_name)

        self.offensive_power = (general_offensive_mod *
                                experience_mod *
                                technology_mod *
                                unit_offensive_mod)

    def calculate_defensive_power_total(self, terrain_name):
        general_defensive_bonus = self.calculate_general_defensive_bonus()
        experience_bonus = self.calculate_experience_bonus()
        technology_bonus = self.calculate_technology_bonus()
        defensive_unit_bonus = self.calculate_defensive_unit_bonus(terrain_name)

        self.defensive_power = (general_defensive_bonus *
                                experience_bonus *
                                technology_bonus *
                                defensive_unit_bonus)


class General:
    def __init__(self, offensive, defensive, tactics, logistics, siege):
        self.offensive = offensive
        self.defensive = defensive
        self.tactics = tactics
        self.logistics = logistics
        self.siege = siege

    @staticmethod
    def create_random_general():

        def random_stat():
            return min(max(int(random.gauss(3.5, 1)), 1), 6)

        offensive = random_stat()
        defensive = random_stat()
        tactics = random_stat()
        logistics = random_stat()
        siege = random_stat()

        return General(offensive, defensive, tactics, logistics, siege)


class LandBattle:
    def __init__(self):
        self.attacker_armies = []
        self.defender_armies = []
        self.terrain_name = ''
        self.weather_name = ''
        self.days = 0

    def recalculate_powers(self):
        for army in self.attacker_armies + self.defender_armies:
            army.calculate_offensive_power_total(self.terrain_name)
            army.calculate_defensive_power_total(self.terrain_name)

    def prepare_armies(self):

        print(f"Prepare armies: attacker {len(self.attacker_armies)} vs defender {len(self.defender_armies)}")

        # calculate initiative for
        for army in self.attacker_armies + self.defender_armies:
            army.calculate_average_speed()
            army.calculate_initiative()
            army.times_hit_this_phase = 0

        self.days = 0

        self.recalculate_powers()

        for army in self.attacker_armies + self.defender_armies:
            army.infantry['live'] += army.infantry['wounded']
            army.infantry['wounded'] = 0
            army.infantry['killed'] = 0

            army.cavalry['live'] += army.cavalry['wounded']
            army.cavalry['wounded'] = 0
            army.cavalry['killed'] = 0

            army.artillery['live'] += army.artillery['wounded']
            army.artillery['wounded'] = 0
            army.artillery['killed'] = 0

    def set_weather(self, weather_name):
        self.weather_name = weather_name

    def set_battle_place(self, terrain_name):
        if terrain_name in TERRAIN_MODIFIERS:
            self.terrain_name = terrain_name
        else:
            raise ValueError(f"Invalid terrain type: {terrain_name}")

    def add_test_army(self, name, battle_side, infantry, cavalry, artillery, tech_level, morale, entrenched = 0):
        general = General.create_random_general()
        army = BattleArmy(name, battle_side, infantry, cavalry, artillery, general, tech_level, morale, entrenched)
        if battle_side == 'attacker':
            self.attacker_armies.append(army)
        elif battle_side == 'defender':
            self.defender_armies.append(army)

    def simulate_phase_of_battle(self):

        for army in self.attacker_armies + self.defender_armies:
            army.times_hit_this_phase = 0

        result_of_battle = self.perform_battle_phase()
        return result_of_battle

    def perform_battle_phase(self):

        print("\n---------------------------------------------------")
        print(f'Battle phase {self.days} starts\n')

        # calculate initiative for
        for army in self.attacker_armies + self.defender_armies:
            army.calculate_average_speed()
            army.calculate_initiative()

        all_armies = sorted([army for army in self.attacker_armies + self.defender_armies if army.active],
                            key=lambda army: army.initiative, reverse=True)

        battle_victory_status = BattleStatus.CONTINUE

        print("Armies in order of initiative:")
        for _, army in enumerate(all_armies):
            print(f"  {_}. '{army.name}' with initiative {army.initiative:.2f}")

        print(f'\nBATTLE')

        for army in all_armies:
            print()
            if army.battle_side == 'attacker':
                if len(self.defender_armies):
                    defender = random.choice(self.defender_armies)
                    print(f"  Attacker army '{army.name}' attacks defender army '{defender.name}'")
                    result = self.perform_attacks(army, self.attacker_armies, defender, self.defender_armies)
                    if result:
                        battle_victory_status = VictoryStatus.ATTACKER
                        break
                else:
                    battle_victory_status = VictoryStatus.ATTACKER
            else:
                if len( self.attacker_armies) > 0:
                    defender = random.choice(self.attacker_armies)
                    print(f"  Defender army '{army.name}' attacks attacker army '{defender.name}'")
                    result = self.perform_attacks(army, self.defender_armies, defender, self.attacker_armies)
                    if result:
                        battle_victory_status = VictoryStatus.DEFENDER
                        break
                else:
                    battle_victory_status = VictoryStatus.DEFENDER

        # very rare case when both are destroyed
        if len(self.attacker_armies) == 0 and len(self.defender_armies) == 0:
            battle_victory_status = VictoryStatus.NONE

        self.recalculate_powers()

        print(f"\n  Battle phase {self.days} ends")
        return battle_victory_status

    def perform_attacks(self, attacking_army, attacker_army, defending_army, defender_armies):

        # check number of attacks on this army this phase
        hits = defending_army.times_hit_this_phase

        multiply_hits_morale = MORALE_LOSS_ENCIRCLED.get(hits, 0)
        if multiply_hits_morale > 0:
            defending_army.morale -= multiply_hits_morale
            print(f"      Army '{defending_army.name}' lose {multiply_hits_morale} morale due to multiple ({hits+1}) attacks")

        defending_army.times_hit_this_phase += 1

        # number of attacks is based on number of live units from attacking army
        max_attacks = attacking_army.infantry['live'] + attacking_army.cavalry['live'] + attacking_army.artillery['live']

        if max_attacks <= 0:
            print(f"        ARMY '{attacking_army.name}' HAS NO MORE UNITS AND IS DESTROYED")
            attacking_army.active = False
            return True

        # this is on purpose to allow longer less intense battles
        attacks = max(int(random.uniform(max_attacks * 0.4, max_attacks * 0.6)), 1)

        print(f"      Number of attacks: {attacks} of max {max_attacks}")
        for _ in range(attacks):
            self.single_attack(_, attacking_army, defender_armies, defending_army)

            # no more defending armies then
            if len(self.defender_armies) == 0:
                print(f"      NO MORE ENEMY ARMIES")
                return True

        return False

    def single_attack(self, n, attacking_army, defender_armies, defending_army):

        if not defending_army in defender_armies:
            return

        # calculate chance to hit
        attack_chance = attacking_army.offensive_power / (attacking_army.offensive_power + defending_army.defensive_power)

        roll = random.random()
        print(f"        {n}. Attack enemy, chance {attack_chance * 100:.1f}%")
        if roll <= attack_chance:
            result = defending_army.resolve_hit()

            # attacking army gets experience from each hit
            attacking_army.experience += 1

            # TODO if morale of defender was hit it will be removed from battle and flew somewhere
            if result == BattleStatus.RETREAT:
                defending_army.active = False
                print(f"\n        ARMY '{defending_army.name}' HAS LOW MORALE AND WILL RETREAT")
                return True

            # TODO if army of defender is destroyed then it will be removed from battle
            if result == BattleStatus.DESTROY:
                defending_army.active = False
                print(f"\n        ARMY '{defending_army.name}' HAS NO MORE ARMY AND IS DESTROYED")
                return True

        return False

    def display_phase_summary(self):
        data = {
            "Side": [],
            "Active": [],
            "Name": [],
            "Infantry": [],
            "Cavalry": [],
            "Artillery": [],
            "Off Pwr": [],
            "Def Pwr": [],
            "Spd": [],
            "Init": [],
            "Exp": [],
            "Gen Off": [],
            "Gen Def": [],
            "Gen Tac": [],
            "Morale": [],
            "Tech Lvl": []
        }

        for side, armies in [("Attacker", self.attacker_armies), ("Defender", self.defender_armies)]:
            for army in armies:
                data["Side"].append(side)
                data["Active"].append(army.active)
                data["Name"].append(army.name)
                data["Infantry"].append(f"{army.infantry['live']} | {army.infantry['wounded']} | {army.infantry['killed']}")
                data["Cavalry"].append(f"{army.cavalry['live']} | {army.cavalry['wounded']} | {army.cavalry['killed']}")
                data["Artillery"].append(f"{army.artillery['live']} | {army.artillery['wounded']} | {army.artillery['killed']}")
                data["Off Pwr"].append(round(army.offensive_power, 2))
                data["Def Pwr"].append(round(army.defensive_power, 2))
                data["Spd"].append(round(army.speed, 2))
                data["Init"].append(round(army.initiative, 2))
                data["Exp"].append(round(army.experience, 2))
                data["Gen Off"].append(army.general.offensive)
                data["Gen Def"].append(army.general.defensive)
                data["Gen Tac"].append(army.general.tactics)
                data["Morale"].append(round(army.morale, 2))
                data["Tech Lvl"].append(round(army.technology_level, 2))

        df = polars.DataFrame(data)

        print(f"---------- Phase Summary ----------")
        print(f"Battle phase:   {self.days}")
        print(f"Terrain type:   {self.terrain_name}")
        print(f"Weather:        {self.weather_name}")
        print()
        print(df.to_pandas().to_markdown(index=False))
        print()

# Example usage
# battle = LandBattle()
# battle.set_battle_place('plains')
# battle.set_weather('rain')
# battle.add_test_army("Polska armia 1", 'attacker', 15, 15, 0, 3, 3.1)
# battle.add_test_army("Polska armia 2", 'attacker', 10, 25, 0, 3, 3.8)
# battle.add_test_army("Polska armia 3", 'attacker', 20, 10, 0, 3, 3.2)
# battle.add_test_army("Niemiecka obrona 1", 'defender', 8, 0, 6, 4, 3.5)
# battle.add_test_army("Niemiecka obrona 2", 'defender', 6, 0, 4, 4, 2.5)
# battle.add_test_army("Niemiecka obrona 3", 'defender', 5, 0, 5, 4, 2.5)
# battle.add_test_army("Niemiecka obrona 4", 'defender', 5, 0, 5, 4, 2.5)
# battle.add_test_army("Niemiecka obrona 5", 'defender', 5, 0, 8, 4, 2.5)
# battle.add_test_army("Niemiecka obrona 6", 'defender', 5, 0, 8, 4, 2.5)
# battle.prepare_armies()
#
# battle.display_phase_summary()
# for n in range(10):
#     results = battle.simulate_phase_of_battle()
#     print()
#     battle.display_phase_summary()
#
#     battle.days += 1
#     if results == VictoryStatus.ATTACKER:
#         print("ATTACKER WINS")
#         break
#     if results == VictoryStatus.DEFENDER:
#         print("DEFENDER WINS")
#         break
#
