
from PIL.ImageQt import QPixmap

from utils.modifiers import Modifiers
from utils.requs import Requirements



#
#   LAND UNIT TYPE
#

class UnitType(object):

    def __init__(self, unit_data = {}):
        from core.game_state import GameState
        gs = GameState()

        self.name = unit_data.get('name', 'Unknown')
        self.tag = unit_data.get('tag', 'TAG')
        self.desc = unit_data.get('desc', 'Description')
        image = unit_data.get('image', 'inf.png')
        self.image: QPixmap = gs.res_images['army'].get(image)
        image_small = unit_data.get('image_small', 'inf.png')
        self.image_small: QPixmap = gs.res_images['army'].get(image_small)

        self.offense = unit_data.get('offense', 1.0)
        self.defense = unit_data.get('defense', 1.0)
        self.siege = unit_data.get('siege', 0)
        self.move = unit_data.get('movement', 1.0)

        self.size = unit_data.get('size', 1.0)
        self.capacity = unit_data.get('capacity', 0)

        self.cost = unit_data.get('cost', 10)
        self.build_time = unit_data.get('build_time', 2)
        self.general = unit_data.get('general', 0)
        self.manpower = unit_data.get('manpower', 1)

        self.unit_class = unit_data.get('class', 'land')

        self.requirements = Requirements( unit_data.get('prereq', {}))
        self.modifiers : Modifiers = Modifiers( unit_data.get('modifiers') )
