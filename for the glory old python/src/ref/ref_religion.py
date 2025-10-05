import datetime

from modifiers import Modifiers


class Religion :

    def __init__(self, kwargs):
        self.start = datetime.date.fromisocalendar(1500, 20, 4)
        self.tag = kwargs.get('tag', 'nothing')
        self.group = kwargs.get('group', 'nothing')
        self.subgroup = kwargs.get('subgroup', 'nothing')
        self.color_name = kwargs.get('color', 'brown')
        self.image = kwargs.get('image', 'nothing')

        self.modifiers = kwargs.get('modifiers', Modifiers())


