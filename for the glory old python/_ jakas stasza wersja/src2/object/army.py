#
#   GENERIC ARMY
#
import random

from ref.ref_unit import UnitType
from core.game_state import GameState
gs = GameState()

class Army:

    def __init__(self, args ):

        self.owner_tag = args.get('owner', 'REB')
        self.owner  = gs.countries.get(self.owner_tag)

        self.name = args.get('name', 'Army of Name')
        self.province_id = args.get('location', 300)
        self.province = gs.provinces.get(self.province_id)
        self.current_order = None

        self.morale_current = 0         # float 1 point = 10% of get additional move / lose move
        self.morale_max = 0             # float, morale current move to morale max with 0.1 per battle turn and 1 per game turn
        self.experience = 0             # float, in general 1 point = 10% for double damage
        self.energy = 0                 # float from 0 to 1, level of energy on units in army -> level of ammo usage etc

        self.units = {}
        self.units_det = {}
        units  = args.get('units', {})

        # get all units into army by number
        for key, val in units.items():
            t : UnitType = gs.db_units.get(key)
            self.units[key] = ( val, t )

    def get_total_offense(self):
        cap = 0
        for k, v in self.units.items():
            cap += v[1].offense * v[0]
        return cap

    def get_total_defense(self):
        cap = 0
        for k, v in self.units.items():
            cap += v[1].defense * v[0]
        return cap

    def get_average_speed(self):
        total_speed = 0
        total_units = 0
        for k, v in self.units.items():
            total_speed += v[1].move * v[0]
            total_units += v[0]
        return total_speed / total_units if total_units > 0 else 0

    def get_total_capacity(self):
        cap = 0
        for k, v in self.units.items():
            cap += v[1].capacity * v[0]
        return cap

    def get_total_size(self):
        cap = 0
        for k, v in self.units.items():
            cap += v[1].size * v[0]
        return cap

    def get_total_cost(self):
        cap = 0
        for k, v in self.units.items():
            cap += v[1].cost * v[0]
        return cap

    def get_total_manpower(self):
        cap = 0
        for k, v in self.units.items():
            cap += v[1].manpower * v[0]
        return cap

    def get_total_units(self):
        cap = 0
        for k, v in self.units.items():
            cap += v[0]
        return cap

    def get_total_siege(self):
        cap = 0
        for k, v in self.units.items():
            cap += v[1].siege * v[0]
        return cap

    def get_desc(self):
        return f"{self.name} ({self.owner_tag}) " + " | ".join([f"{key}={v[0]}" for key, v in self.units.items()])

    def get_regiments_for_battle(self):
        country = gs.countries.get(self.owner_tag)
        if country is None:
            return None
        tech_group = country.techgroup
        if tech_group is None:
            return None

        regiments = []

        for unit_name, (count, unit_type) in self.units.items():
            which_unit_regiment_data_tech_name = gs.db_unit_to_regiments[tech_group.tag][unit_name]
            which_tech_name = list(which_unit_regiment_data_tech_name.keys())[0]
            current_tech_details = which_unit_regiment_data_tech_name[which_tech_name]
            country_tech_level = country.technology_levels.get(which_tech_name, 0)
            list_of_potential_regiments = current_tech_details.get( str(country_tech_level), [] )

            for n in range(count):
                regiment_name = random.choice(list_of_potential_regiments)
                regiments.append( (regiment_name, country.tag, unit_name ) )

        return regiments


class ArmyLand(Army):

    def __init__(self, args):
        super().__init__(args)

        self.current_order = None


class ArmyNaval(Army):

    def __init__(self, args):
        super().__init__(args)

        self.current_order = None
