from modifiers import Modifiers
from requs import Requirements


class Policies:

    def __init__(self):

        self.name = ''
        self.desc = ''

        self.image = 'policy.png'
        self.cost = 1               # in advisors
        self.delay = 12             # in turns / months
        self.stab_change = -1

        self.modifiers = Modifiers()
        self.requirements = Requirements()
