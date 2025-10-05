from PIL.ImageQt import QPixmap


from utils.modifiers import Modifiers
from utils.requs import Requirements


#
#   REGIMENT TYPE - type of units used during battle
#

class RegimentType(object):
    def __init__(self, unit_data = {}):
        from core.game_state import GameState
        gs = GameState()

        self.name = unit_data.get('name', 'Unknown')
        self.tag = unit_data.get('tag', 'TAG')
        self.label = unit_data.get('label', 'Unknown')
        self.unit = unit_data.get('unit', 'infantry')
        self.desc = unit_data.get('desc', 'Description')
        image = unit_data.get('image', 'inf.png')
        self.image: QPixmap = gs.res_images['army'].get(image)

        self.shock = unit_data.get('shock', 3.0)
        self.range = unit_data.get('range', 1.0)
        self.fire = unit_data.get('fire', 0)
        self.defense = unit_data.get('defense', 3.0)

        self.speed = unit_data.get('speed', 2)
        self.sight = unit_data.get('sight', 2)
        self.cover = unit_data.get('cover', 0)

        self.ammo = unit_data.get('ammo', 16)
        self.hp = unit_data.get('hp', 10)
        self.entrench = unit_data.get('entrench', False)
        self.move_fire = unit_data.get('move_fire', False)
        self.morale = unit_data.get('morale', 0)
        self.experience = unit_data.get('experience', 0)

        self.unit_class = unit_data.get('class', 'land')

        self.requirements = Requirements( unit_data.get('prereq', {}))
        self.modifiers : Modifiers = Modifiers( unit_data.get('modifiers') )