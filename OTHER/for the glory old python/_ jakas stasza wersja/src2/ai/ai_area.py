class AIArea:
    def __init__(self, province_id, area, region, continent):
        self.province_id = province_id
        self.area = area
        self.region = region
        self.continent = continent

    def create_insight(self, description):
        return {
            'description': description,
            'province_id': self.province_id,
            'area': self.area,
            'region': self.region,
            'continent': self.continent
        }