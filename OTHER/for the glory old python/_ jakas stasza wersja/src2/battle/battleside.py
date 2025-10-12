#
#   BATTLE SIDE
#
from object.army import Army


class BattleSide:
    def __init__(self,name, data):
        self.name = name
        self.armies: list[Army] = []
        self.formation = data.get('formation', 'land_standard')
        army_data = data.get('armies', [])
        for arm in army_data:
            self.armies.append( Army( arm ) )

    def add_army(self, army: Army):
        self.armies.append(army)

    def create_regiments(self):
        regiments = []
        for arm in self.armies:
            regi = arm.get_regiments_for_battle()
            regiments.extend( regi )
        return regiments

    # TODO remove army from battle during battle
