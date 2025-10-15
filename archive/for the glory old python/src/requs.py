class Requirements:

    def __init__(self):

        self.gold_below = 0
        self.gold_above = 100000

        self.fame_below = -100000
        self.fame_above = 100000

        self.stab_below = -4
        self.stab_above = 4

        self.year_above = 1900
        self.year_below = 1200

        self.technologies_below = {}       # format technology: level
        self.technologies_above = {}       # format technology: level

        self.policies_below = {}            # format policy: level max
        self.policies_above = {}            # format policy: level min

        self.regions_needed = []
        self.regions_excluded = []

        self.continents_needed = []
        self.continents_excluded = []

        self.province_id_needed = []
        self.province_id_excluded = []

        self.religion_needed = []
        self.religion_excluded = []

        self.culture_needed = []
        self.culture_excluded = []

        self.country_tag_needed = []
        self.country_tag_excluded = []

        self.monarch_needed = []
        self.monarch_excluded = []
