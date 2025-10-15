from modifiers import Modifiers


class GeoContinent :

    def __init__(self, kwargs):
        self.tag = kwargs.get('tag', 'nothing')
        self.color_name = kwargs.get('color', 'brown')

        self.modifiers = kwargs.get('modifiers', Modifiers())
