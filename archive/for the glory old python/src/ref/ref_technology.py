from modifiers import Modifiers


class Technology:

    def __init__(self, args):
        self.name = args.get("name", "Country")
        self.tag = args.get("tag", "TAG")
        self.modifiers = Modifiers()