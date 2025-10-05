from modifiers import Modifiers


class Climate :

    def __init__(self, kwargs):
        self.tag = kwargs.get('tag', 'nothing')
        self.color_name = kwargs.get('color', 'brown')
        self.snow_months = kwargs.get('snow', [] )

        self.modifiers = kwargs.get('modifiers', Modifiers())


