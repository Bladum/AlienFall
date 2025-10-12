import random

from battle.battlefield import BattleField
from battle.battleside import BattleSide

from core.game_state import GameState

gs = GameState()

#
#  BATTLE
#


class Battle:
    def __init__(self, battle_data ):

        print("Create battle simulation")

        self.date = battle_data.get('date')
        self.name = battle_data.get('name')
        self.desc = battle_data.get('desc')
        self.map_type = battle_data.get('map_type')

        prov_data = battle_data.get('province')
        attacker_data = battle_data.get('attacker')
        defender_data = battle_data.get('defender')
        country_data = battle_data.get('countries')

        # country data required for battle only
        for key, val in country_data.items():
            country = gs.countries.get( key )

            religion = val.get("social", {}).get('religion')
            if religion:
                country.change_religion(religion)

            cultures = val.get("social", {}).get('cultures')
            if cultures:
                country.add_culture( cultures )

            # technologies
            technologies = val.get('technology', {})
            if technologies:
                country.technology_levels = technologies

            # policies
            policies = val.get('policies', {})
            if policies:
                country.policy_sliders = policies

            # TODO ruler add here
            # TODO leader of army add here

        self.battlefield = BattleField( prov_data )
        self.attacker = BattleSide("Attacker", attacker_data)
        self.defender = BattleSide("Defender", defender_data)
        self.turn = 0


    def prepare_battle(self, index = 0):

        attacker_regiments = self.attacker.create_regiments()
        defender_regiments = self.defender.create_regiments()
        self.battlefield.regiments.clear()

        for regiment in attacker_regiments:
            formation_name = self.attacker.formation
            formation = gs.db_battle_formations[formation_name]
            unit = regiment[2]
            possible_regions_id = formation.units_details.get(unit)
            if possible_regions_id:
                while True:
                    selected_region_id = random.choice(possible_regions_id)
                    region_map = gs.db_battle_regions.get('attacker', [])[selected_region_id]
                    potential_locations = gs.db_battle_map.get(region_map)
                    location = random.choice(potential_locations)
                    x, y = location
                    if self.battlefield.is_tile_has_regiment(x, y):
                        self.battlefield.create_regiment_on_tile(x, y, regiment[0], regiment[1], "A", unit)
                        break

        for regiment in defender_regiments:
            formation_name = self.defender.formation
            formation = gs.db_battle_formations[formation_name]
            unit = regiment[2]
            possible_regions_id = formation.units_details.get(unit)
            if possible_regions_id:
                while True:
                    selected_region_id = random.choice(possible_regions_id)
                    region_map = gs.db_battle_regions.get('defender', [])[selected_region_id]
                    potential_locations = gs.db_battle_map.get(region_map)
                    location = random.choice(potential_locations)
                    x, y = location
                    if self.battlefield.is_tile_has_regiment(x, y):
                        self.battlefield.create_regiment_on_tile(x, y, regiment[0], regiment[1], "D", unit)
                        break

        self.battlefield.reveal_fow_for_side('A')
        self.battlefield.reveal_fow_for_side('D')
        self.battlefield.save_to_png(f"{index}A", 'A')
        self.battlefield.save_to_png(f"{index}D", 'D')


    def pretty_print(self):
        print(f"Battle Name: {self.name}")
        print(f"Date: {self.date}")
        print(f"Description: {self.desc}")
        print(f"Map Type: {self.map_type}")
        print("Countries:")
        for key, country in gs.countries.items():
            print(f"  {key}: {country}")
        print("Battlefield:")
        print(f"  Width: {self.battlefield.width}, Height: {self.battlefield.height}")
        print("Attacker:")
        print(f"  {self.attacker}")
        print("Defender:")
        print(f"  {self.defender}")
        print(f"Turn: {self.turn}")


    def next_turn(self):
        self.turn += 1
