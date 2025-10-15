from modifiers import Modifiers
from requs import Requirements

class Building:

    def __init__(self, data):
        self.name = data.get('name', "NAME")
        image = data.get('image', 'nothing.png')
        from src.db import TDB
        db = TDB()

        self.image = db.res_images['building'].get(image)

        self.modifiers = Modifiers( data.get('modifiers') )
        self.requirements = Requirements()

        self.max_levels = 1
        self.build_cost = data.get('build_cost', 100)       # in ducats
        self.build_time = data.get('build_time', 3)
        self.tooltip = data.get('tooltip', None)
