from modifiers import Modifiers


class Culture:

    def __init__(self, kwargs):
        self.tag = kwargs.get('tag', 'nothing')
        self.color_name = kwargs.get('color', 'brown')
        self.bravery = kwargs.get('bravery', 1.5)
        self.modifiers = kwargs.get('modifiers', Modifiers())
        self.buildings = kwargs.get('buildings', '')
        self.city = kwargs.get('city', '')
