from utils.modifiers import Modifiers


class TechGroup:

    def __init__(self, args):
        self.name = args.get("name", "techgroup")
        self.tag = args.get("tag", "TAG")
        self.label = args.get("label", "Tech Group")
        self.color_name = args.get("color", "white")
        self.modifiers : Modifiers =  Modifiers( args.get("modifiers", {} ) )