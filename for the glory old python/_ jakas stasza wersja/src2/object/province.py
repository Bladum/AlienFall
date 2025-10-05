

from ref.ref_area import GeoArea
from ref.ref_climate import Climate
from ref.ref_continent import GeoContinent
from ref.ref_culture import Culture
from ref.ref_goods import Goods
from ref.ref_region import GeoRegion
from ref.ref_religion import Religion
from ref.ref_terrain import Terrains

from core.game_state import GameState
from utils.dice import Dice

gs = GameState()

class Province:

    def __init__(self, prov_data):

        self.province_id = int(prov_data.get('id', 0))

        from items.item_province import ProvinceItem
        self.province_item : ProvinceItem = None

        self.name = prov_data.get('name', "Province Name")
        self.is_land = prov_data.get('is_land', True)
        self.size = 0

        # other provinces nearby

        self.neighbors_distance : dict[int, int] = {}
        self.neighbors : dict[int, Province] = {}

        # province city
        self.city_position = None
        self.army_position = None

        # name text positions
        self.name_text_position = set()

        # roads to other provinces

        from items.item_road import RoadItem
        self.roads : dict[int, RoadItem] = {}

        # borders to other provinces
        from items.item_border import BorderItem
        self.borderlines : dict[int, BorderItem] = {}

        # buildings
        from ref.ref_building import Building
        self.buildings : list[Building] = []

        # who is owner of province
        self.country_owner_tag = ''
        self.country_occupant_tag = ''

        from object.country import Country
        self.country_owner: Country = None
        self.country_occupant: Country = None

        # weather effects
        self.has_snow_or_ice = False          # snow on land, ice on water
        self.has_storm_or_hurricane = False   # storm on water, hurricane on land

        # details tags

        terrain_tag = prov_data.get('terrain', 'plains')
        self.terrain: Terrains = gs.db_terrains.get(terrain_tag)
        if self.terrain is None:
            print('NO TERRAIN', self.province_id, terrain_tag)

        culture_tag = prov_data.get('culture', None)
        self.culture : Culture = gs.db_cultures.get( culture_tag )

        religion_tag = prov_data.get('religion', 'pagan')
        self.religion : Religion = gs.db_religions.get( religion_tag )

        goods_tag = prov_data.get('goods', 'nothing')
        self.goods : Goods = gs.db_goods.get(goods_tag)

        climate_tag = prov_data.get('climate', None)
        self.climate : Climate = gs.db_climates.get(climate_tag)

        region_tag = prov_data.get('region', None)
        self.region : GeoRegion = gs.db_regions.get(region_tag)

        continent_tag = prov_data.get('continent', None)
        self.continent : GeoContinent = gs.db_continents.get(continent_tag)

        area_tag = prov_data.get('area', None)
        self.area : GeoArea = gs.db_areas.get(area_tag)

        # gameplay

        self.population = 1
        self.population_growth = 0.05
        self.population_max = 10
        self.tax_value = 1
        self.trade_value = 1
        self.revolt_risk = 0
        self.manpower: int = int(prov_data.get('manpower', 0) or 0)
        self.manpower_max = self.manpower
        self.income : int = int(prov_data.get('tax', 0) or 0)

        # armies in province
        from object.army import ArmyLand, ArmyNaval

        self.armies : list[ArmyLand] = []
        self.navies : list[ArmyNaval] = []

        # center of trade inside province

        from object.cot import CenterOfTrade
        self.center_of_trade : CenterOfTrade = None

        # is capitol

        self.is_country_capitol = False

        # flags for visibility

        self.is_explored = True
        self.is_visible = True
        self.is_selected = False

        self.is_national = False
        self.is_core = False


    #
    #   MILITARY
    #

    def total_number_of_units_in_province(self):

        val = [0, 0]

        for army in self.armies:
            val[0] += army.get_total_units()

        for navy in self.navies:
            val[1] += navy.get_total_units()

        return val

    #
    #   SELECT DESELECT
    #

    def select_province(self):
        self.is_selected = True

    def deselect_province(self):
        self.is_selected = False


    #
    #   CHANGE VISUALS OF PROVINCE
    #

    def set_snow_or_ice_status(self, new_status):
        self.has_snow_or_ice = new_status

    def process_weather_effects(self):
        # check which month it is
        # check climate
        # check chance to SNOW on land
        # check chance to ICE on water
        # check chance to STORM on water
        # check chance to HURRICANE on land

        # apply effects on province data
        # apply visuals -> works only on terrain map

        pass


    #
    #   GAME PLAY
    #

    def process_all(self):
        pass

    def process_all_occupied(self):
        pass

    #
    #   MANAGE CHANGE STATE OF PROVINCE
    #

    def add_neighbor(self, neighbor_id, distance):
        self.neighbors_distance[neighbor_id] = distance

    def remove_neighbor(self, neighbor_id):
        if neighbor_id in self.neighbors_distance.keys():
            self.neighbors_distance.pop(neighbor_id)

    #
    #   PROVINCE OWNER ? OCCUPANT
    #

    def change_country_capitol_province(self):

        # if there is owner
        if self.country_owner_tag:
            country = gs.countries.get(self.country_owner_tag)

            if country:
                country.change_country_capital_province(self)

    def change_province_owner(self, new_owner_tag, change_occupant = False, visual = False):

        country = gs.countries.get(new_owner_tag, None)
        if country:

            # update globals
            gs.country_province_owner_dict[self.province_id] = new_owner_tag
            self.country_owner_tag = new_owner_tag
            self.country_owner = gs.countries.get( new_owner_tag )

            # update borders for me
            for k, border in self.borderlines.items():
                border.detect_border_type()

            if self.province_item:

                # update owner color
                self.province_item.set_province_background_colors( country.color_name, None )

            # in general when owner is changed then occupant is also changed
            if change_occupant:
                self.change_province_occupant(new_owner_tag)

    def change_province_occupant(self, new_occupant_tag):

        country = gs.countries.get(new_occupant_tag, None)
        if country:

            # update globals
            self.country_occupant_tag = new_occupant_tag
            self.country_occupant = gs.countries.get( new_occupant_tag )
            gs.country_province_occupant_dict[self.province_id] = new_occupant_tag

            if self.province_item:

                # change city image
                self.province_item.set_city_pixmap('flag_frame', new_occupant_tag + ".png")

                # if its different then owner define occupacy
                if self.country_occupant_tag != self.country_owner_tag:
                    self.province_item.set_province_background_colors( primary_color = None,
                                                         secondary_color = country.color_name)
                else:
                    self.province_item.set_province_background_colors(primary_color=None,
                                                        secondary_color=None)

    def reset_province_occupant_to_owner(self):
        self.change_province_occupant(self.country_owner_tag)


    #
    #   show hide province
    #

    def view_province(self):
        self.is_visible = True
        self.province_item.province_fog_of_war.setVisible(False)

    def unview_province(self):
        self.is_visible = False
        self.province_item.province_fog_of_war.setVisible(True)

    def disable_fog_of_war(self):
        self.province_item.province_fog_of_war.setVisible(False)

    def enable_fog_of_war(self):
        if self.is_visible:
            self.province_item.province_fog_of_war.setVisible(False)
        else:
            self.province_item.province_fog_of_war.setVisible(True)

    #
    #   EXPLORE
    #

    def explore_province_by_geography(self, prov_ids = None, names = None):

        if prov_ids:
            if self.province_id in prov_ids:
                self.explore_province()
                return True
        if names:
            if self.continent.tag in names or self.region.tag in names or self.area.tag in names:
                self.explore_province()
                return True

    def explore_province(self):
        self.is_explored = True
        if self.province_item:
            self.province_item.set_province_exploration(True)

    def unexplore_province(self):
        self.is_explored = False
        if self.province_item:
            self.province_item.set_province_exploration(False)

    #
    #   GAME LOGIC
    #

    def calculate_game_logic(self):

        self.manpower_max = self.calculate_manpower_value()
        self.population_growth = self.calculate_population_growth()
        self.tax_value = self.calculate_tax_value()
        self.trade_value = self.calculate_trade_value()
        self.revolt_risk = self.calculate_revolt_risk_value()

        # regenerate manpower all within 2 years = 24 months
        self.manpower += min( self.manpower_max / 24, self.manpower_max )

        # grow population
        self.population += self.population_growth

        # check revolt risk
        check_for_revolt = Dice.K100(self.revolt_risk)
        if check_for_revolt:
            self.create_rebel_army()

    def create_rebel_army(self):
        pass

    def calculate_manpower_value(self):

        # base value is 50% of population but minimum 1
        val = max( self.population // 2, 1)

        # if there is owner
        if self.country_owner_tag:

            # from country
            country = gs.countries.get(self.country_owner_tag)
            if country:

                # this is national province
                is_national = True if self.province_id in country.national_provinces.keys() else False
                if not is_national:
                    val *= 0.5

                # from country policies
                mod = 1.0
                for pol in country.policies:
                    if is_national:
                        mod *= pol.modifiers.mod_manpower_national
                    else:
                        mod *= pol.modifiers.mod_manpower_other
                    mod *= pol.modifiers.mod_army_manpower
                val *= mod

                # from state religion
                val *= country.state_religion.modifiers.mod_army_manpower

                # TODO from war taxes

                # TODO at war
                if country.war_time > 0:
                    val *= 1.5

                # is capitol
                if country.capitol_province == self:
                    val *= 1.25

        # province is occupied then very low
        if self.country_owner_tag != self.country_occupant_tag:
            val *= 0.25

        # from buildings
        for bui in self.buildings:
            val *= bui.modifiers.mod_army_manpower

        # from goods
        good_det = self.goods
        if good_det:
            mod = good_det.modifiers.get('mod_army_manpower')
            if mod:
                val *= mod

        return val

    def calculate_revolt_risk_value(self):

        # base value
        val = -2

        if self.country_owner_tag:

            # from country
            country = gs.countries.get(self.country_owner_tag)
            if country:

                # from country stability
                stability_mod = -country.budget.stability
                val += stability_mod

                # from country policies
                mod = 0
                for pol in country.policies:
                    mod += pol.modifiers.mod_revolt_risk
                val += mod

                # from state religion
                val += country.state_religion.modifiers.mod_revolt_risk

                # from tax level on country level
                val += country.budget.level_tax_revolt

                # wrong religion
                if country.state_religion.tag != self.religion.tag:
                    val += 3

                # wrong culture
                # TODO

                # how long in state of war 3 months = -1
                war_war = country.war_time
                mod = 1.0
                for pol in country.policies:
                    mod *= pol.modifiers.mod_war_exhaustion
                val += war_war * round(mod, 0)

                # is capitol
                if country.capitol_province == self:
                    val -= 2

        # from buildings
        for bui in self.buildings:
            val += bui.modifiers.mod_revolt_risk

        # check all armies to see if army can reduce revolt risk
        for army in self.armies:
            army_size = army.units
            if army.owner_tag == self.country_owner_tag:
                val -= army_size * 0.2
            else:
                val += army_size * 0.2

        # from goods
        good_det = self.goods
        if good_det:
            mod = good_det.modifiers.get('mod_revolt_risk')
            if mod:
                val += mod

        return val

    def calculate_tax_value(self):

        # base value
        val = self.population

        if self.country_owner_tag:

            # from country
            country = gs.countries.get(self.country_owner_tag)
            if country:

                stab_mod = [0.8, 0.9, 1, 1, 1, 1.1, 1.2]
                # from country stability
                stability_mod = stab_mod[ country.budget.stability + 3]
                val *= stability_mod

                # from country policies
                mod = 0
                for pol in country.policies:
                    mod *= pol.modifiers.mod_production_income
                val += mod

                # from state religion
                val *= country.state_religion.modifiers.mod_production_income

                # from tax level on country level
                val *= country.budget.level_tax

                # wrong religion
                if country.state_religion.tag != self.religion.tag:
                    val *= 0.75

                # wrong culture
                # TODO

                # no connection to capitol
                # TODO

                # is capitol
                if country.capitol_province == self:
                    val *= 1.2

        # from buildings
        for bui in self.buildings:
            val *= bui.modifiers.mod_production_income

        # from goods
        good_det =  self.goods
        if good_det:
            mod = good_det.modifiers.get('mod_production_income')
            if mod:
                val *= mod

        # the bigger population the bigger effect
        mod = 0.5 + (self.population // 5)
        mod = max(0.5, min(3.0, 0.5 + (self.population // 5)))
        val *= mod

        # from enemy army
        # from province looted

        return val

    def calculate_trade_value(self):
        # basic trade value of a resource from 5 to 25
        # modifier from population

        # base value
        val = 5.0

        if self.country_owner_tag:

            # from country
            country = gs.countries.get(self.country_owner_tag)
            if country:

                # from country policies
                mod = 0
                for pol in country.policies:
                    mod *= pol.modifiers.mod_trade_value

                val += mod

        # from buildings
        for bui in self.buildings:
            val *= bui.modifiers.mod_trade_value

        # goods
        good_det = self.goods
        if good_det:
            mod = good_det.modifiers.get('mod_trade_value')
            if mod:
                val *= mod

        # the bigger population the bigger effect
        mod = 0.5 + (self.population // 5)
        mod = max(0.5, min(3.0, 0.5 + (self.population // 5)))
        val *= mod

        # from enemy army
        # from province looted

        return val

    def calculate_population_growth(self):

        # base value
        val = 2.0

        if self.country_owner_tag:

            # from country
            country = gs.countries.get(self.country_owner_tag)
            if country:
                # from stability
                val += country.budget.stability

                # from country policies
                mod = 0
                for pol in country.policies:
                    mod += pol.modifiers.mod_population_growth

                val += mod

        # from buildings
        for bui in self.buildings:
            val += bui.modifiers.mod_population_growth

        # goods
        good_det = self.goods
        if good_det:
            mod = good_det.modifiers.get('mod_population_growth')
            if mod:
                val += mod

        # from climate
        climate_tag = self.climate
        if climate_tag:
            mod = climate_tag.modifiers.get('mod_population_growth')
            if mod:
                val += mod

        # the bigger population the slower the growth
        if self.population > self.population_max:
            val -= (self.population - self.population_max)

        # from enemy army
        # from province looted
        # from being capitol province
        # from terrain type ?

        return val

    #
    #   ROADS
    #

    def add_road(self, neighbor_province):

        from items.item_road import RoadItem
        road = RoadItem(self, neighbor_province)
        self.roads[ neighbor_province.province_id ] = road
        neighbor_province.roads[ self.province_id] = road
        return road

    def show_all_roads(self):
        for road in self.roads.values():
            road.show_road()

    def hide_all_roads(self):
        for road in self.roads.values():
            road.hide_road()

    #
    #   province return tool tip per game mode map
    #

    def get_province_tooltip(self, map_mode):

        tooltip_text =  f"Province:    {self.name} ({self.province_id})\n"
        tooltip_text += f"Owner:       {self.country_owner_tag} ( {self.country_occupant_tag} )\n\n"

        match map_mode:

            case 'politic':
                country = gs.countries.get(gs.current_country_tag)
                if country:
                    if self.province_id in country.national_provinces.keys():
                        tooltip_text += f"National:    True \n"
                    if self.province_id in country.claim_provinces.keys():
                        tooltip_text += f"Claimed:     True"

                if len( self.armies ) > 0:
                    tooltip_text += f"\n\nArmies:"
                    for arm in self.armies:
                        tooltip_text += f"\n  {arm.get_desc()}"

                if len( self.navies ) > 0:
                    tooltip_text += f"\n\nNavies:"
                    for arm in self.navies:
                        tooltip_text += f"\n  {arm.get_desc()}"

            case 'culture':
                if self.country_owner_tag:
                    country = gs.countries.get( self.country_owner_tag)
                    if country:
                        accepted_cultures = ', '.join( country.accepted_cultures_tag )
                        tooltip_text +=  f"State:       {accepted_cultures} \n"
                if self.culture:
                    tooltip_text +=  f"Local:       {self.culture.tag}"

            case 'religion':
                if self.country_owner_tag:
                    country = gs.countries.get( self.country_owner_tag)
                    if country:
                        if country.state_religion:
                            state_religion = country.state_religion
                            tooltip_text +=  f"State:       {state_religion.tag} \n"
                if self.religion:
                    tooltip_text +=  f"Local:       {self.religion.tag}"

            case 'goods':
                if self.goods:
                    tooltip_text +=  f"Goods:       {self.goods.tag} \n"
                    tooltip_text +=  f"Value:       {self.goods.value}"

            case 'climate':
                if self.climate:
                    snow_months = ','.join(map(str, self.climate.snow_months))
                    tooltip_text +=  f"Climate:     {self.climate.tag} \n"
                    tooltip_text +=  f"Snowing:     {snow_months} "

            case 'terrain':
                if self.terrain:
                    tooltip_text +=  f"Terrain:     {self.terrain.tag}"

                if len( self.armies ) > 0:
                    tooltip_text += f"\n\nArmies:"
                    for arm in self.armies:
                        tooltip_text += f"\n  {arm.get_desc()}"

                if len( self.navies ) > 0:
                    tooltip_text += f"\n\nNavies:"
                    for arm in self.navies:
                        tooltip_text += f"\n  {arm.get_desc()}"

            case 'trade':
                if self.center_of_trade:
                    tooltip_text +=  f"CoT:         {self.center_of_trade.name}\n"
                    tooltip_text +=  f"Value:       {self.center_of_trade.value}\n"
                    tooltip_text +=  f"Stability:   {self.center_of_trade.stability}\n"
                    tooltip_text +=  f"Merchants:   {len(self.center_of_trade.merchants)}"

            case 'region':
                if self.continent:
                    tooltip_text +=  f"Continent:   {self.continent.tag} \n"
                if self.region:
                    tooltip_text +=  f"Region:      {self.region.tag} \n"
                if self.area:
                    tooltip_text +=  f"Area:        {self.area.tag} \n\n"

                if self.region:
                    tooltip_text +=  f"Natives:     {self.region.natives} \n"
                    tooltip_text +=  f"Pirates:     {self.region.modifiers.piracy_risk} \n"
                    tooltip_text +=  f"Revolts:     {self.region.modifiers.revolt_strength * 100:.2f}%"

        return tooltip_text
