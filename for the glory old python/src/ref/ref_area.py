from modifiers import Modifiers


class GeoArea :

    def __init__(self, kwargs):
        self.tag = kwargs.get('tag', 'nothing')
        self.color_name = kwargs.get('color', 'brown')
        self.type = kwargs.get('type', 'land')

        self.modifiers = kwargs.get('modifiers', Modifiers())
