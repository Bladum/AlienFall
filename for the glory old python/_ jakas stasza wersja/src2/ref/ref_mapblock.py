import copy
import random


#
# BATTLE MAP BLOCK
#

class BattleMapBlock:

    def __init__(self, data):
        self.chance = data.get('chance', 1)
        self.data = data.get('data', 'pp\npp').strip().split('\n')

        self.map_array = self.create_map_array()
        self.map_array_org = copy.deepcopy(self.map_array)
        self.terrain_map = self.assign_terrain()

    def randomize_map_block(self):
        self.random_transformation()
        self.terrain_map = self.assign_terrain()
        return self.terrain_map

    def create_map_array(self):
        map_array = []
        for line in self.data:
            map_array.append([char for char in line])
        return map_array

    def rotate_left_90(self):
        self.map_array = [list(row) for row in zip(*self.map_array[::-1])]

    def rotate_right_90(self):
        self.map_array = [list(row) for row in zip(*self.map_array)][::-1]

    def rotate_180(self):
        self.map_array = [row[::-1] for row in self.map_array[::-1]]

    def mirror_vertical(self):
        self.map_array = self.map_array[::-1]

    def mirror_horizontal(self):
        self.map_array = [row[::-1] for row in self.map_array]

    def random_transformation(self):
        self.map_array = copy.deepcopy(self.map_array_org)
        num_transformations = random.randint(0, 3)
        transformations = [
            self.rotate_left_90,
            self.rotate_right_90,
            self.rotate_180,
            self.mirror_vertical,
            self.mirror_horizontal
        ]
        for _ in range(num_transformations):
            random.choice(transformations)()

    def assign_terrain(self):
        from core.game_state import GameState
        gs = GameState()

        terrain_map = []
        for row in self.map_array:
            terrain_row = []
            for char in row:
                terrain_row.append(gs.battle_tile_codes.get(char, 'Unknown'))
            terrain_map.append(terrain_row)
        return terrain_map

