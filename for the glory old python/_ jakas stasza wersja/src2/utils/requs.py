class Requirements:

    def __init__(self, data = {}):

        self.gold_below = 0
        self.gold_above = 100000

        self.fame_below = -100000
        self.fame_above = 100000

        self.stab_below = -4
        self.stab_above = 4

        self.year_above = 1900
        self.year_below = 1200

        self.technology = {}       # format technology: level

        self.policy, self.policy_not = self._process_requirements(data, 'policy')
        self.idea , self.idea_not =  self._process_requirements(data, 'idea')
        self.government , self.government_not =  self._process_requirements(data, 'government')

        self.building, self.building_not =  self._process_requirements(data, 'building')
        self.good, self.good_not =  self._process_requirements(data, 'good')
        self.terrain, self.terrain_not = self._process_requirements(data, 'terrain')

        self.area, self.area_not = self._process_requirements(data, 'area')
        self.region, self.region_not = self._process_requirements(data, 'region')
        self.continent, self.continent_not = self._process_requirements(data, 'continent')
        self.province_id, self.province_id_not = self._process_requirements(data, 'province')

        self.religion, self.religion_not = self._process_requirements(data, 'religion')
        self.culture, self.culture_not  = self._process_requirements(data, 'culture')
        self.tech_group , self.tech_group_not =  self._process_requirements(data, 'techgroup')

        self.country_tag, self.country_tag_not =  self._process_requirements(data, 'country')
        self.organization, self.organization_not =  self._process_requirements(data, 'organization')

        self.ruler_id = []
        self.leader_id = []
        self.event_id = []

    def _process_requirements(self, data, key):
        values = data.get(key, None)
        if values is None:
            return None, None

        positive_list = None
        negative_list = None
        if isinstance(values, str):
            values = [values]
        for value in values:
            if value.startswith('!'):
                if negative_list is None:
                    negative_list = []
                negative_list.append(value[1:])
            else:
                if positive_list is None:
                    positive_list = []
                positive_list.append(value)
        return positive_list, negative_list