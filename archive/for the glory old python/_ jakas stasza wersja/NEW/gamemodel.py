from enum import Enum

class TileType(Enum):
    EMPTY = "empty"
    WALL = "wall"

class Unit:
    def __init__(self, x: int, y: int):
        self.x = x
        self.y = y

class GameModel:
    def __init__(self):
        self.width = 14
        self.height = 14
        self.tiles = [[TileType.EMPTY for _ in range(self.width)] for _ in range(self.height)]
        self.units = []

    def add_unit(self, unit: Unit):
        if not (0 <= unit.x < self.width and 0 <= unit.y < self.height) or self.tiles[unit.y][unit.x] != TileType.EMPTY:
            raise ValueError("Invalid position")
        self.units.append(unit)

    def remove_unit(self, unit_id):
        try:
            index = next(i for i, u in enumerate(self.units) if u.id == unit_id)
            del self.units[index]
        except StopIteration:
            pass
