from utils.modifiers import Modifiers


class Goods:

    def __init__(self, kwargs):
        self.tag = kwargs.get('tag', 'nothing')
        self.color_name = kwargs.get('color', 'brown')
        self.image = kwargs.get('image', 'nothing')
        self.value = kwargs.get('base_price', 5)

        self.modifiers : Modifiers = Modifiers( kwargs.get('modifiers' ))
