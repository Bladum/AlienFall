import datetime

from utils.modifiers import Modifiers


class Religion :

    def __init__(self, kwargs):
        self.start = datetime.date.fromisocalendar(1500, 20, 4)
        self.tag = kwargs.get('tag', 'nothing')
        self.group = kwargs.get('group', 'nothing')
        self.subgroup = kwargs.get('subgroup', 'nothing')
        self.color_name = kwargs.get('color', 'brown')
        self.image = kwargs.get('image', self.tag + ".png")

        self.allowed_conversion = kwargs.get('allowed_conversion', [])
        self.war = kwargs.get('war', [])
        self.aggressiveness = kwargs.get('aggressiveness', [])
        self.conflict = kwargs.get('conflict', [])
        self.heretic = kwargs.get('heretic', [])

        self.modifiers: Modifiers = Modifiers( kwargs.get('modifiers' ) )


