from utils.modifiers import Modifiers


class Climate :

    def __init__(self, kwargs):
        self.tag = kwargs.get('tag', 'nothing')
        self.color_name = kwargs.get('color', 'brown')
        self.snow_months = kwargs.get('snow', [] ) # TODO remove this, use future weather system

        # TODO colonist_cost
        # TODO merchant_cost

        self.weather = kwargs.get('weather', {} )
        self.modifiers : Modifiers = Modifiers( kwargs.get('modifiers' ))


