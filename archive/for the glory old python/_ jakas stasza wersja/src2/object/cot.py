import random

from core.game_state import GameState
from object.merchant import Merchant
from object.province import Province

gs = GameState()

owners = [ 'POL', 'ENG', 'ENG', 'CAT', 'LIT', 'TUE', 'RUS', 'OTT', 'VEN' , 'VEN', 'VEN']


class CenterOfTrade(object):

    def __init__(self, args = {}):

        self.name = args.get("name")
        self.location_province_id = args.get("location")

        self.location_province: Province = gs.provinces.get( self.location_province_id )
        self.color_name = args.get("color", 'yellow')

        merchants_dict : dict = args.get("merchants", {})
        self.merchants: list[Merchant] = []

        for key, val in merchants_dict.items():
            self.create_merchant(key, val)

        self.provinces : list[Province] = []

        self.persistent = args.get('persistent', False)
        self.power = sum(merchants_dict.values())

        self.value = 0
        self.stability = random.randint(-3, 3)
        self.add_province_id( self.location_province_id, False )


    def add_provinces(self, provinces ):
        self.provinces.clear()
        self.provinces.extend(provinces)
        self.value = self.calculate_cot_value()

    def add_province_id(self, province_id, with_neighbours = False):
        prov = gs.provinces.get( province_id)
        if prov:
            prov.center_of_trade = self
            self.provinces.append(prov)

            if with_neighbours:
                for key, val in  prov.neighbors.items():
                    if val.is_land:
                        self.provinces.append( val )
                        val.center_of_trade = self

        self.value = self.calculate_cot_value()

    def calculate_cot_value(self):
        val = 0

        for province in self.provinces:
            val += province.trade_value

        return val

    def create_merchant(self, country_tag, count = 1, lifetime = 12, effectiveness = 0.25):

        for _ in range(count):
            data =  {
                'owner' : country_tag,
                'lifetime': random.randint(lifetime - 3, lifetime + 3),
                'effectiveness' : effectiveness,
            }
            merch = Merchant( data )
            self.merchants.append(merch)

    def add_merchant(self, merchant: Merchant):
        self.merchants.append(merchant)

    def cycle_merchants(self):
        removed_count = 0
        for merchant in self.merchants[:]:
            merchant.lifetime -= 1
            if merchant.lifetime <= 0:
                self.merchants.remove(merchant)
                removed_count += 1
        return removed_count

    def calculate_total_income(self):
        owner_effectiveness = {}
        for merchant in self.merchants:
            owner_effectiveness[merchant.owner] = (owner_effectiveness.get(merchant.owner, 0)
                                                   + merchant.effectiveness)

        total_effectiveness = sum(owner_effectiveness.values())
        cot_value = self.calculate_cot_value()

        owner_income = {}
        for owner, effectiveness in owner_effectiveness.items():
            fraction = effectiveness / total_effectiveness
            income = cot_value * fraction
            income = max(cot_value * 0.01, min(income, cot_value * 0.25))
            owner_income[owner] = round(income, 1)

        return owner_income

    #
    #   TEST METHODS
    #

    def add_random_merchants(self, num_merchants):
        for _ in range(num_merchants):
            merchant = Merchant({
                'owner': random.choice(owners),
                'lifetime': random.randint(9, 15),
                'effectiveness': round(random.uniform(0.2, 0.5), 2),
            })
            self.add_merchant(merchant)

