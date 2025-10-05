from utils.modifiers import Modifiers

class TechnologyLevel(object):

    def __init__(self, data):
        self.min_year = data.get('year', 1200)
        self.inventor_cost = data.get('inventor_cost', 3)
        self.label = data.get('label', "Tech")

class Technology:

    def __init__(self, args):
        self.label = args.get("label", "Technology")
        self.ruler_skill = args.get("ruler_skill", "MIL")
        self.base_cost = args.get("base_cost", 1)
        self.desc = args.get("desc", "Technology desc")
        self.image = args.get("image", "tech.png")
        self.tag = args.get("tag", "TAG")

        self.levels : list[TechnologyLevel] = []
        self.modifiers : list[ Modifiers ] = []

        tech_levels = args.get('levels', [])
        if tech_levels:
            for level in tech_levels:
                self.levels.append( TechnologyLevel(level) )

        modifiers = args.get('modifiers', [])
        if modifiers:
            for modif in modifiers:
                self.modifiers.append( Modifiers(modif) )

