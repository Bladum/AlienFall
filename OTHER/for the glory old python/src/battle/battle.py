import copy

from PySide6.QtGui import QPainter, QPixmap, Qt
from PySide6.QtWidgets import QGraphicsPixmapItem
import random

from src.db import TDB
db = TDB()

#
# 	LAND ARMY
#

class LandArmy:

    def __init__(self, args ):

        self.owner_tag = args.get('owner', 'REB')
        self.name = args.get('name', 'Army of Name')
        self.province_id = args.get('location', 300)
        self.current_order = None

        self.infantry = args.get('infantry', 0)
        self.cavalry = args.get('cavalry', 0)
        self.artillery = args.get('artillery', 0)
        self.leaders = args.get('leaders', 0)

        self.units: list[LandUnit] = []

        self.total_units = self.infantry + self.cavalry + self.artillery + self.leaders

        for _ in range( self.total_units ):
            self.units.append(LandUnit(owner_tag=self.owner_tag,
                                       province_id=self.province_id))

    def get_desc(self):
        return f"{self.name} ({self.owner_tag})  {self.infantry} | {self.cavalry} | {self.artillery}"

#
#   NAVAL FLEET
#

class NavalArmy:

    def __init__(self, args):

        self.owner_tag = args.get('owner', 'REB')
        self.name = args.get('name', 'Army of Name')
        self.province_id = args.get('location', 300)
        self.current_order = None

        self.warships = args.get('warships', 0)
        self.galleys = args.get('galleys', 0)
        self.transports = args.get('transports', 0)
        self.leaders = args.get('leaders', 0)

        self.units: list[LandUnit] = []

        self.total_units = self.warships + self.galleys + self.transports + self.leaders

        for _ in range(self.total_units):
            self.units.append(LandUnit(owner_tag=self.owner_tag,
                                       province_id=self.province_id))

    def get_desc(self):
        return f"{self.name} ({self.owner_tag})  {self.warships} | {self.galleys} | {self.transports}"

#
#   LAND UNIT TYPE
#

class LandUnitType(object):

    def __init__(self, unit_data = {}):
        self.name = unit_data.get('name', 'Unknown')
        self.desc = unit_data.get('desc', 'Description')
        image = unit_data.get('image', 'inf.png')
        self.image: QPixmap = db.res_images['army'].get(image)
        self.offense = unit_data.get('offense', 1.0)
        self.defense = unit_data.get('defense', 1.0)
        self.siege = unit_data.get('siege', 0)
        self.move = unit_data.get('move', 1.0)
        self.cost = unit_data.get('cost', 10)
        self.manpower = unit_data.get('manpower', 1)


#
#   LAND UNIT
#

class LandUnit(QGraphicsPixmapItem):

    def __init__(self,
                 unit_type_tag: str = 'infantry',
                 province_id: int = 300,
                 owner_tag: str = 'REB',
                 experience: int = 0,
                 hit_points: float = 1.0):
        super().__init__()

        self.unit_type = db.db_units.get(unit_type_tag)
        self.province = db.provinces.get(province_id)
        self.owner = db.countries.get(owner_tag)
        self.experience = experience
        self.hit_points = hit_points

        self.image_back = db.res_images['army_back'][self.owner.color]
        self.image_unit = self.unit_type.image
        self.image_hp = db.res_images['hp'][0]
        self.setZValue(db.z_value_army)

    def calculate_hp_image(self):
        hp_index = min(9, max(0, int(self.hit_points * 10)))
        self.image_hp = db.res_images['hp'][hp_index]

    def paint(self, painter: QPainter, option, widget=None):
        painter.setCompositionMode(QPainter.CompositionMode_SourceOver)  # Ensure transparency and layering

        position = self.province.pixmap_province_city

        self.calculate_hp_image()

        # Draw the background image at the center of the province city position
        painter.drawPixmap(position.x() - self.image_back.width() // 2,
                           position.y() - self.image_back.height() // 2,
                           self.image_back)

        # Draw the unit image with an offset of 8x8 pixels
        painter.drawPixmap(position.x() - self.image_unit.width() // 2 + 8,
                           position.y() - self.image_unit.height() // 2 + 8,
                           self.image_unit)

        # Draw the HP image with an offset of 10x19 pixels
        painter.drawPixmap(position.x() - self.image_hp.width() // 2 + 10,
                           position.y() - self.image_hp.height() // 2 + 19,
                           self.image_hp)

#
#   BATTLE TILE
#

class BattleTile:
    def __init__(self, terrain: str, x: int, y: int):
        self.terrain = terrain
        self.x = x
        self.y = y
        self.unit: LandUnitType = None  # No unit on the tile initially

#
#   BATTLE FIELD
#

class BattleField:
    def __init__(self, province_terrain: str):
        self.width = 15
        self.height = 10
        self.tile_size = 32
        self.map_blocks = self.generate_map_blocks(province_terrain)
        self.tiles = self.generate_tiles()

    def generate_map_blocks(self, province_terrain: str):

        map_blocks = db.db_battle_maps_blocks.get(province_terrain, [])
        weights = [block.chance for block in map_blocks]
        selected_blocks = random.choices(map_blocks, weights=weights, k=6)  # 4x3 blocks
        selected_map_terrains = []
        for block in selected_blocks:
            selected_map_terrains.append(block.randomize_map_block())
        return [selected_map_terrains[i:i + 3] for i in range(0, len(selected_map_terrains), 2)]

    def generate_tiles(self):
        tiles = []
        for y in range(self.height):
            row = []
            for x in range(self.width):
                block_row_index = y // 5
                block_index = x // 5
                block = self.map_blocks[block_row_index][block_index]
                block_y = y % 5
                block_x = x % 5
                terrain_type = block[block_y][block_x]
                bt = BattleTile(terrain_type, x, y)
                row.append(bt)
            tiles.append(row)
        return tiles

    def pretty_print(self):
        print()
        for row in self.tiles:
            for tile in row:
                print(tile.terrain, end=' ')
            print()

    def save_to_png(self, index = 0):
        width = self.width * self.tile_size

        height = self.height * self.tile_size
        pixmap = QPixmap(width, height)
        pixmap.fill(Qt.transparent)
        painter = QPainter(pixmap)

        for y in range(self.height):
            for x in range(self.width):
                tile = self.tiles[y][x]
                image = db.res_images['battle_terrain'].get(tile.terrain)

                if image:
                    painter.drawPixmap(x * self.tile_size, y * self.tile_size, image)

        file_path = str(db.path_gfx / 'textures' / f'battlemap_{index}.png' )

        painter.end()
        pixmap.save(file_path)

#
#   BATTLE SIDE
#

class BattleSide:
    def __init__(self, name: str):
        self.name = name
        self.units: list[LandUnit] = []

    def add_unit(self, unit: LandUnit):
        self.units.append(unit)

#
#  BATTLE
#

class Battle:
    def __init__(self, province_terrain: str):
        self.battlefield = BattleField(province_terrain)
        self.attacker = BattleSide("Attacker")
        self.defender = BattleSide("Defender")
        self.turn = 0
        self.fog_of_war = {"Attacker": self.initialize_fog(), "Defender": self.initialize_fog()}

    def initialize_fog(self):
        return [[True for _ in range(self.battlefield.width)] for _ in range(self.battlefield.height)]

    def update_fog_of_war(self, side: str):
        # Implement fog of war logic here
        pass

    def next_turn(self):
        self.turn += 1

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
        terrain_map = []
        for row in self.map_array:
            terrain_row = []
            for char in row:
                terrain_row.append(db.battle_tile_codes.get(char, 'Unknown'))
            terrain_map.append(terrain_row)
        return terrain_map

    def pretty_print_terrain_map(self):
        print()
        for row in self.map_array:
            print(' '.join(row))
