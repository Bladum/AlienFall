from utils.modifiers import Modifiers
from utils.requs import Requirements

class Building:

    def __init__(self, data):
        self.name = data.get('label', "NAME")
        self.desc = data.get('desc', "NAME")
        image = data.get('image', 'nothing.png')
        from core.game_state import GameState
        gs = GameState()

        self.image = gs.res_images['building'].get(image)

        self.modifiers = Modifiers( data.get('modifiers') )
        self.requirements = Requirements( data.get('prereq', {}) )

        self.max_levels = 1
        self.unique = data.get('unique', False)
        self.upkeep =  data.get('upkeep', 0)       # in ducats
        self.build_cost = data.get('build_cost', 100)       # in ducats
        self.build_time = data.get('build_time', 3)         # in turns
        self.engineer_cost = data.get('engineer_cost', 1)
        self.tooltip = data.get('tooltip', None)
