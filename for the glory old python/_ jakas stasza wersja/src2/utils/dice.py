

class Dice:
    import random

    sides = 6

    @staticmethod
    def __init__(sides):
        Dice.sides = sides

    @staticmethod
    def _roll():
        return Dice.random.randint(1, Dice.sides)

    @staticmethod
    def K6(value=None):
        roll = Dice(6)._roll()
        return roll < value if value is not None else roll

    @staticmethod
    def K10(value=None):
        roll = Dice(10)._roll()
        return roll < value if value is not None else roll

    @staticmethod
    def K12(value=None):
        roll = Dice(12)._roll()
        return roll < value if value is not None else roll

    @staticmethod
    def K20(value=None):
        roll = Dice(20)._roll()
        return roll < value if value is not None else roll

    @staticmethod
    def K100(value=None):
        roll = Dice(100)._roll()
        return roll < value if value is not None else roll
