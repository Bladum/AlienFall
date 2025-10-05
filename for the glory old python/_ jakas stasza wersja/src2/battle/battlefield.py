import random

from PIL.ImageQt import QPixmap
from PySide6.QtGui import QPainter, Qt, QColor

from battle.battletile import BattleTile
from battle.regiment import Regiment
from core.game_state import GameState
gs = GameState()



#
#   BATTLE FIELD
#
TILE_SIZE = 40
COLOR_FOG = QColor("#90303030")

class BattleField:
    def __init__(self, data):

        province_terrain = data.get('terrain')
        province_weather = data.get('weather')
        province_id = data.get('location')

        self.width = 15
        self.height = 10
        self.tile_size = TILE_SIZE

        # TODO add here option to generate random map or predefined map
        battle_map_blocks = self.create_map_blocks(province_terrain)
        self.battle_tiles = [[BattleTile(x, y) for x in range(self.width)] for y in range(self.height )]
        self.fog_of_war = {"A": self.initialize_fog_of_war(), "D": self.initialize_fog_of_war()}
        self.regiments : list[Regiment] = []

        self.battle_tiles = self.create_battle_tiles(battle_map_blocks)
        self.initialize_neighbors()

    #
    #   INIT MAP
    #

    def initialize_neighbors(self):
        directions_even = [(-1, 0), (1, 0), (0, -1), (0, 1), (-1, -1), (1, -1)]
        directions_odd = [(-1, 0), (1, 0), (0, -1), (0, 1), (-1, 1), (1, 1)]

        for y in range(self.height):
            for x in range(self.width):
                tile = self.battle_tiles[y][x]
                directions = directions_even if x % 2 == 0 else directions_odd
                for dx, dy in directions:
                    nx, ny = x + dx, y + dy
                    if 0 <= nx < self.width and 0 <= ny < self.height:
                        tile.neighbors.append(self.battle_tiles[ny][nx])

    def initialize_random_blocks(self, num_blocks):
        for _ in range(num_blocks):
            x = random.randint(0, self.width - 1)
            y = random.randint(0, self.height - 1)
            self.battle_tiles[y][x].is_block = True
            self.battle_tiles[y][x].value = 0

    def initialize_tile_values(self):
        for y in range(self.height):
            for x in range(self.width):
                if not self.battle_tiles[y][x].is_block:
                    self.battle_tiles[y][x].value = random.choice([0.5, 1, 1.5, 2])

    #
    #   FOG OF WAR
    #

    def hide_fow_all_tiles(self):
        for side in self.fog_of_war:
            for y in range(self.height):
                for x in range(self.width):
                    self.fog_of_war[side][y][x] = True

    def initialize_fog_of_war(self):
        return [[True for _ in range(self.width)] for _ in range(self.height)]

    def reveal_fow_from_tile(self, start_tile, range_distance, side):
        tiles_in_range = self.get_tiles_in_range(start_tile, range_distance)
        for tile in tiles_in_range:
            self.fog_of_war[side][tile.y][tile.x] = False

    def reveal_fow_for_side(self, side: str):
        # reset
        self.fog_of_war[side] = self.initialize_fog_of_war()

        # set new for one side
        for regiment in self.regiments:
            if regiment.battle_side == side:
                self.reveal_fow_from_tile(self.battle_tiles[regiment.position[1]][regiment.position[0]], regiment.regiment_type.sight, side)

    #
    # HEX LOGIC
    #

    def is_tile_has_regiment(self, x, y):
        battletile : BattleTile = self.battle_tiles[y][x]
        return battletile.regiment is None

    def get_tiles_in_range(self, start_tile, range_distance):
        visited = set()
        to_visit = [(start_tile, 0)]
        result = []

        while to_visit:
            current_tile, distance = to_visit.pop(0)
            if distance > range_distance:
                continue
            if current_tile not in visited:
                visited.add(current_tile)
                result.append(current_tile)
                for neighbor in current_tile.neighbors:
                    to_visit.append((neighbor, distance + 1))

        return result

    def get_movable_tiles(self, start_tile, range_distance):
        visited = set()
        to_visit = [(start_tile, 0)]
        result = []

        while to_visit:
            current_tile, distance = to_visit.pop(0)
            if distance > range_distance:
                continue
            if current_tile not in visited and not current_tile.is_block:
                visited.add(current_tile)
                result.append(current_tile)
                for neighbor in current_tile.neighbors:
                    to_visit.append((neighbor, distance + neighbor.value))

        return result

    def calculate_distance(self, start_tile, end_tile):
        dx = end_tile.x - start_tile.x
        dy = end_tile.y - start_tile.y
        return max(abs(dx), abs(dy), abs(dx + dy))

    def find_path(self, start_tile, end_tile):
        from heapq import heappop, heappush
        import itertools

        counter = itertools.count()  # unique sequence count
        queue = [(0, next(counter), start_tile, [start_tile])]
        visited = set()

        while queue:
            cost, _, current_tile, path = heappop(queue)
            if current_tile == end_tile:
                return path
            if current_tile not in visited:
                visited.add(current_tile)
                for neighbor in current_tile.neighbors:
                    if neighbor not in visited and not neighbor.is_block:
                        heappush(queue, (cost + neighbor.value, next(counter), neighbor, path + [neighbor]))

        return []

    def is_direct_line_clear(self, tile_a, tile_b):
        dx = tile_b.x - tile_a.x
        dy = tile_b.y - tile_a.y
        steps = max(abs(dx), abs(dy))
        for step in range(1, steps):
            x = tile_a.x + step * dx // steps
            y = tile_a.y + step * dy // steps
            if self.battle_tiles[y][x].is_block:
                return False
        return True

    #
    #   CREATE BLOCKS / UNITS
    #

    def create_map_blocks(self, province_terrain: str):
        map_blocks = gs.db_battle_maps_blocks.get(province_terrain, [])
        weights = [block.chance for block in map_blocks]
        selected_blocks = random.choices(map_blocks, weights=weights, k=6)  # 3x2 blocks
        selected_map_terrains = []
        for block in selected_blocks:
            selected_map_terrains.append(block.randomize_map_block())
        return [selected_map_terrains[i:i + 3] for i in range(0, len(selected_map_terrains), 2)]

    def create_battle_tiles(self, battle_map_blocks):
        tiles = []
        for y in range(self.height):
            row = []
            for x in range(self.width):
                block_row_index = y // 5
                block_index = x // 5
                block = battle_map_blocks[block_row_index][block_index]
                block_y = y % 5
                block_x = x % 5
                terrain_type = block[block_y][block_x]
                bt = BattleTile(x, y, terrain_type)
                row.append(bt)
            tiles.append(row)

        return tiles

    def create_regiment_on_tile(self, tilex, tiley, regiment_type, owner, side, unit_type):
        tile : BattleTile = self.battle_tiles[tiley][tilex]
        regiment = Regiment(regiment_type, owner, side, position=(tilex,tiley), unit_type= unit_type)
        tile.set_regiment(regiment)
        self.regiments.append(regiment)

    #
    #   VISUALIZE
    #

    def save_to_png(self, index = 0, side = 'A'):
        width = self.width * TILE_SIZE
        height = self.height * TILE_SIZE
        pixmap = QPixmap(width, height + TILE_SIZE // 2)
        pixmap.fill(Qt.black)
        painter = QPainter(pixmap)

        for y in range(self.height):
            for x in range(self.width):
                tile = self.battle_tiles[y][x]
                image = gs.res_images['battle_terrain'].get(tile.terrain)

                draw_y = y * TILE_SIZE + (TILE_SIZE // 2 if x % 2 == 1 else 0)

                if image:
                    painter.drawPixmap(x * TILE_SIZE, draw_y, image)

                if tile.regiment:
                    regiment_image = tile.regiment.image_final
                    if regiment_image:
                        painter.drawPixmap(x * TILE_SIZE, draw_y, regiment_image)

                if self.fog_of_war[side][y][x]:
                    painter.fillRect(x * TILE_SIZE, draw_y, TILE_SIZE, TILE_SIZE, COLOR_FOG)

        file_path = str(gs.path_gfx / 'battles' / f'battlemap_{index}.png' )

        painter.end()
        pixmap.save(file_path)








