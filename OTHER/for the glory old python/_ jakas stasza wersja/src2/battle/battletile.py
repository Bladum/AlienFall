from battle.regiment import Regiment


class BattleTile:
    def __init__(self, x: int, y: int, terrain: str = 'plains'):
        self.terrain = terrain
        self.x = x
        self.y = y
        self.neighbors = []
        self.is_block = False
        self.regiment: Regiment = None  # No unit on the tile initially
        self.value = 1

    def set_regiment(self, regiment : Regiment):
        self.regiment = regiment

    def set_neighbours(self, data):
        self.neighbors = data
