from modifiers import Modifiers


class GeoRegion :

    def __init__(self, kwargs):
        self.tag = kwargs.get('tag', 'nothing')
        self.color_name = kwargs.get('color', 'brown')
        self.revolt_strength = kwargs.get('revolt_strength', 1.0)
        self.piracy = kwargs.get('piracy', 'normal')
        self.natives = kwargs.get('natives', 'europe')

        self.modifiers = kwargs.get('modifiers', Modifiers())
