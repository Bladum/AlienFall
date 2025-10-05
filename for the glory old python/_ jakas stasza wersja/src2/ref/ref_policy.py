from utils.modifiers import Modifiers
from utils.requs import Requirements


class Policies:

    def __init__(self, args = {}):

        self.tag = args.get('tag', 'aa')
        self.name = self.tag.title()
        self.label = args.get('label', ' TO BE DONE ')
        self.desc = args.get('desc', ' TO BE DONE ')

        self.image = 'policy.png'
        self.cost = 1               # in advisors
        self.delay = 12             # in turns / months
        self.stab_change = -1

        self.modifiers = Modifiers( {} )
        self.requirements = Requirements( {} )
