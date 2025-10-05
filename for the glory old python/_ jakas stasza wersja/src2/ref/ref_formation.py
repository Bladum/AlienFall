
from utils.modifiers import Modifiers
from utils.requs import Requirements


class BattleFormation:

    def __init__(self, kwargs):
        self.tag = kwargs.get('tag', 'nothing')
        self.color_name = kwargs.get('color', 'brown')

        self.units_details = kwargs.get('units', {} )

        self.modifiers: Modifiers = Modifiers(kwargs.get('modifiers', {}))
        self.requirements: Requirements = Requirements(kwargs.get('prereq', {}))