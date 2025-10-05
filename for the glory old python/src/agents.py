
class Agents:

    def __init__(self):
        self.merchants_max = 12
        self.merchants_growth = 1.0
        self.merchants = 0

        self.general_max = 12
        self.general_growth = 1.0
        self.general = 0

        self.explorer_max = 12
        self.explorer_growth = 1.0
        self.explorer = 0

        self.diplomats_max = 12
        self.diplomats_growth = 1.0
        self.diplomats = 0

        self.engineers_max = 12
        self.engineers_growth = 1.0
        self.engineers = 0

        self.inventors_max = 12
        self.inventors_growth = 1.0
        self.inventors = 0

        self.missionaries_max = 12
        self.missionaries_growth = 1.0
        self.missionaries = 0

        self.advisories_max = 12
        self.advisories_growth = 1.0
        self.advisories = 0

    def get_more_agents(self):
        self.merchants = min(self.merchants + self.merchants_growth, self.merchants_max)
        self.general = min(self.general + self.general_growth, self.general_max)
        self.explorer = min(self.explorer + self.explorer_growth, self.explorer_max)
        self.diplomats = min(self.diplomats + self.diplomats_growth, self.diplomats_max)
        self.engineers = min(self.engineers + self.engineers_growth, self.engineers_max)
        self.inventors = min(self.inventors + self.inventors_growth, self.inventors_max)
        self.missionaries = min(self.missionaries + self.missionaries_growth, self.missionaries_max)
        self.advisories = min(self.advisories + self.advisories_growth, self.advisories_max)