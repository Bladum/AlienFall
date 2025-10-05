import random


from ref.ref_culture import Culture


class MapManager:

    def __init__(self, game_state):
        self.current_map_mode = ''

        from core.game_state import GameState
        self.gs : GameState = game_state
    #
    #   SWITCH GAME MAP MODES
    #

    def switch_map_mode(self, new_mode):
        print("Switch map mode to ", new_mode)

        map_mode_switchers = {
            'terrain': self._switch_map_mode_terrain,
            'political': self._switch_map_mode_politic,
            'culture': self._switch_map_mode_culture,
            'religion': self._switch_map_mode_religion,
            'climate': self._switch_map_mode_climate,
            'trade': self._switch_map_mode_trade,
            'goods': self._switch_map_mode_goods,
            'manpower': self._switch_map_mode_manpower,
            'region': self._switch_map_mode_region,
            'area': self._switch_map_mode_area,
            'continent': self._switch_map_mode_continent
        }

        if new_mode in map_mode_switchers.keys():
            self.gs.current_map_mode = new_mode

            for province in self.gs.provinces.values():
                if province.is_explored:
                    map_mode_switchers[new_mode](province)
        else:
            print("ERROR, map mode not implemented yet ", new_mode)

    def _switch_map_mode_terrain(self, province):
        from object.province import Province

        province: Province
        province_item = province.province_item

        # enable fog of war
        province.enable_fog_of_war()

        country_owner = self.gs.countries.get( province.country_owner_tag)

        primary_color = 'basic_water'
        weather_effect = None
        secondary_color = None

        province_item.set_province_large_frame(None)
        province_item.set_core_pixmap(False)
        province_item.set_city_number()
        if province.is_land:
            province_item.set_city_pixmap()
        else:
            province_item.set_city_pixmap('city', 'sea.png')

        # main terrain
        terrain = province.terrain
        if terrain:
            primary_color = terrain.color_name

            # on terrain map secondary color is WEATHER
            # temporary solution
            climate = province.climate
            if climate:
                if province.is_land:
                    if 11 in climate.snow_months:

                        if random.random() > 0.7:
                            weather_effect = 'snow'
                else:
                    if 11 in climate.snow_months:
                        weather_effect = 'ice'

        # military numbers
        army_size, navy_size = province.total_number_of_units_in_province()
        if army_size > 0:
            province_item.set_city_number(number=army_size)

        # set owner of province
        if province.is_land:
            province_item.set_city_pixmap('flag_frame', province.country_occupant_tag + '.png')

        # set capitol large frame
        if country_owner:
            if province == country_owner.capitol_province:
                province_item.set_province_large_frame(country_owner.budget.stability)

        province_item.set_province_background_colors( primary_color = primary_color,
                                                 weather_effect = weather_effect,
                                                 secondary_color = secondary_color )

    def _switch_map_mode_culture( self, province):
        from object.province import Province

        province: Province
        province_item = province.province_item

        # no fog of war
        province.disable_fog_of_war()

        country_owner = self.gs.countries.get( province.country_owner_tag)

        primary_color = 'basic_water'
        secondary_color = None

        province_item.set_province_large_frame(None)
        province_item.set_core_pixmap(False)
        province_item.set_city_number()
        if province.is_land:
            province_item.set_city_pixmap()
        else:
            province_item.set_city_pixmap('city', 'sea.png')

        # get province culture
        culture : Culture = province.culture
        if culture:
            primary_color = culture.color_name

            # if there is a country owner and what is background color
            if country_owner:

                # is country cultures is not matching with province
                cnt_culture_tags = country_owner.accepted_cultures_tag
                if culture.tag not in cnt_culture_tags:
                    secondary_color = 'black'

                # in capitol city show country flag only
                if province == country_owner.capitol_province:
                    province_item.set_province_large_frame(country_owner.budget.stability)
                    province_item.set_city_pixmap('flag_frame', province.country_owner_tag + '.png')

        province_item.set_province_background_colors(primary_color = primary_color,
                                                secondary_color=secondary_color)

    def _switch_map_mode_religion(self, province ):
        from object.province import Province

        province: Province
        province_item = province.province_item

        # no fog of war
        province.disable_fog_of_war()

        country_owner = self.gs.countries.get( province.country_owner_tag)

        primary_color = 'basic_water'
        secondary_color = None

        province_item.set_province_large_frame(None)
        province_item.set_core_pixmap(False)
        province_item.set_city_number()
        if province.is_land:
            province_item.set_city_pixmap()
        else:
            province_item.set_city_pixmap('city', 'sea.png')

        # religion province
        prov_religion = province.religion
        if prov_religion and province.is_land:
            primary_color = prov_religion.color_name

        # if there is a country owner and what is background color
        if country_owner:

            # is state religion is NOT as province religion
            state_religion = country_owner.state_religion
            if prov_religion and state_religion:
                if state_religion.tag != prov_religion.tag:
                    secondary_color = state_religion.color_name

            # in capitol city show country religion
            if province == country_owner.capitol_province and state_religion:
                province_item.set_city_pixmap('religion_frame', state_religion.tag + '.png')
                province_item.set_province_large_frame(country_owner.budget.stability)

        province_item.set_province_background_colors(primary_color = primary_color,
                                                secondary_color= secondary_color)

    def _switch_map_mode_manpower(self, province):
        from object.province import Province

        province: Province
        province_item = province.province_item

        # no fog of war
        province.disable_fog_of_war()

        country_owner = self.gs.countries.get( province.country_owner_tag)

        province_item.set_province_large_frame(None)
        province_item.set_core_pixmap(False)
        province_item.set_city_number()
        if province.is_land:
            province_item.set_city_pixmap()
        else:
            province_item.set_city_pixmap('city', 'sea.png')

        primary_color = 'basic_water'
        secondary_color = None

        # manpower
        manpower = int(province.manpower)
        if manpower > 0:
            primary_color = f"good_0{min( manpower - 1, 9 )}"
            province_item.set_city_number(number= manpower )

        # set capitol large frame
        if country_owner:
            if province == country_owner.capitol_province:
                province_item.set_province_large_frame(country_owner.budget.stability)
                province_item.set_city_pixmap('flag_frame', province.country_owner_tag + '.png')

        province_item.set_province_background_colors(primary_color = primary_color)

    def _switch_map_mode_region(self, province):
        from object.province import Province

        province: Province
        province_item = province.province_item

        # no fog of war
        province.disable_fog_of_war()

        country_owner = self.gs.countries.get(province.country_owner_tag)

        primary_color = 'basic_water'
        secondary_color = None

        province_item.set_province_large_frame(None)
        province_item.set_core_pixmap(False)
        province_item.set_city_number()
        if province.is_land:
            province_item.set_city_pixmap()
        else:
            province_item.set_city_pixmap('city', 'sea.png')

        # Get region data
        region_data = province.region

        if region_data:
            primary_color = region_data.color_name

        # if there is a country owner and what is background color
        if country_owner:
            # in capitol city show country flag only
            if province == country_owner.capitol_province:
                province_item.set_province_large_frame(country_owner.budget.stability)
                province_item.set_city_pixmap('flag_frame', province.country_owner_tag + '.png')

        province_item.set_province_background_colors(primary_color=primary_color)

    def _switch_map_mode_area(self, province):
        from object.province import Province

        province: Province
        province_item = province.province_item

        # no fog of war
        province.disable_fog_of_war()

        country_owner = self.gs.countries.get(province.country_owner_tag)

        primary_color = 'basic_water'

        province_item.set_province_large_frame(None)
        province_item.set_core_pixmap(False)
        province_item.set_city_number()
        if province.is_land:
            province_item.set_city_pixmap()
        else:
            province_item.set_city_pixmap('city', 'sea.png')

        # Get area data
        area_data = province.area

        if area_data:
            primary_color = area_data.color_name

        # if there is a country owner and what is background color
        if country_owner:
            # in capitol city show country flag only
            if province == country_owner.capitol_province:
                province_item.set_province_large_frame(country_owner.budget.stability)
                province_item.set_city_pixmap('flag_frame', province.country_owner_tag + '.png')

        province_item.set_province_background_colors(primary_color=primary_color)

    def _switch_map_mode_continent(self, province):
        from object.province import Province

        province: Province
        province_item = province.province_item

        # no fog of war
        province.disable_fog_of_war()

        country_owner = self.gs.countries.get(province.country_owner_tag)

        primary_color = 'basic_water'

        province_item.set_province_large_frame(None)
        province_item.set_core_pixmap(False)
        province_item.set_city_number()
        if province.is_land:
            province_item.set_city_pixmap()
        else:
            province_item.set_city_pixmap('city', 'sea.png')

        # Get continent data
        continent_data = province.continent

        if continent_data:
            primary_color = continent_data.color_name

        # if there is a country owner and what is background color
        if country_owner:
            # in capitol city show country flag only
            if province == country_owner.capitol_province:
                province_item.set_province_large_frame(country_owner.budget.stability)
                province_item.set_city_pixmap('flag_frame', province.country_owner_tag + '.png')

        province_item.set_province_background_colors(primary_color=primary_color)

    def _switch_map_mode_climate(self, province):
        from object.province import Province

        province: Province
        province_item = province.province_item

        # no fog of war
        province.disable_fog_of_war()

        country_owner = self.gs.countries.get( province.country_owner_tag)

        primary_color = 'basic_water'
        secondary_color = None

        province_item.set_province_large_frame(None)
        province_item.set_core_pixmap(False)
        province_item.set_city_number()
        if province.is_land:
            province_item.set_city_pixmap()
        else:
            province_item.set_city_pixmap('city', 'sea.png')

        # climate
        climate = province.climate
        if climate :
            primary_color = climate.color_name
            if not province.is_land:
                secondary_color = 'basic_water'

        # if there is a country owner and what is background color
        if country_owner:
            # in capitol city show country flag only
            if province == country_owner.capitol_province:
                province_item.set_province_large_frame(country_owner.budget.stability)
                province_item.set_city_pixmap('flag_frame', province.country_owner_tag + '.png')


        province_item.set_province_background_colors(primary_color = primary_color,
                                                secondary_color= secondary_color)

    def _switch_map_mode_goods(self, province):
        from object.province import Province

        province: Province
        province_item = province.province_item

        # no fog of war
        province.disable_fog_of_war()

        country_owner = self.gs.countries.get( province.country_owner_tag)

        primary_color = 'basic_water'
        secondary_color = None

        province_item.set_province_large_frame(None)
        province_item.set_core_pixmap(False)
        province_item.set_city_number()
        if province.is_land:
            province_item.set_city_pixmap()
        else:
            province_item.set_city_pixmap('city', 'sea.png')

        # good are only on land
        if province.is_land:
            province_item.set_core_pixmap(False)
            goods = province.goods
            if goods:
                province_item.set_city_pixmap('goods_frame', goods.tag + '.png')
                primary_color = goods.color_name
            else:
                primary_color = 'grayed'

        # set capitol large frame
        if country_owner:
            if province == country_owner.capitol_province:
                province_item.set_province_large_frame(country_owner.budget.stability)

        province_item.set_province_background_colors(primary_color = primary_color)

    def _switch_map_mode_trade(self, province):
        from object.province import Province

        province: Province
        province_item = province.province_item

        # disable fog of war
        province.disable_fog_of_war()

        country_owner = self.gs.countries.get( province.country_owner_tag)

        primary_color = 'basic_water'
        secondary_color = None

        province_item.set_province_large_frame(None)
        province_item.set_core_pixmap(False)
        province_item.set_city_number()
        if province.is_land:
            province_item.set_city_pixmap()
        else:
            province_item.set_city_pixmap('city', 'sea.png')

        # trade is only on land
        if province.is_land:
            # province belongs o this center of trade
            cot = province.center_of_trade
            if cot:
                primary_color = cot.color_name

                # if this is location of center of trade
                if cot.location_province_id == province.province_id:
                    province_item.set_city_pixmap('flag_frame', province.country_owner_tag + '.png')
                    province_item.set_province_large_frame(stab_level=cot.stability)
                    province_item.set_city_number(number=len(cot.merchants) * 15)
            else:
                # not in COT range
                primary_color = 'grayed'

        province_item.set_province_background_colors(primary_color = primary_color)

    def _switch_map_mode_politic(self, province):
        from object.province import Province

        province: Province
        province_item = province.province_item

        province.enable_fog_of_war()

        country_owner = self.gs.countries.get(province.country_owner_tag, None)
        country_occup = self.gs.countries.get(province.country_occupant_tag, None)

        primary_color = 'basic_water'
        secondary_color = None

        province_item.set_province_large_frame(None)
        province_item.set_core_pixmap(False)
        province_item.set_city_number()
        if province.is_land:
            province_item.set_city_pixmap()
        else:
            province_item.set_city_pixmap('city', 'sea.png')

        # if there is a country owner and what is background color
        if country_owner:

            if province.is_country_capitol:
                country = self.gs.countries.get( province.country_owner_tag )
                if country:
                    province_item.set_province_large_frame( country.budget.stability )

            # if there is no occupant
            if country_occup == country_owner:
                primary_color = country_owner.color_name
            else:
                # if there is occupant
                if country_occup:
                    primary_color=country_owner.color_name
                    secondary_color=country_occup.color_name
                else:
                    primary_color=country_owner.color_name
                    secondary_color = None
        else:
            if province.is_land:  # no owner
                primary_color = 'basic_land'

        army_size, navy_size = province.total_number_of_units_in_province()
        if army_size > 0:
            province_item.set_city_number(number=army_size)

        # FOR CURRENT COUNTRY

        # nationals or claimed provs
        current_country = self.gs.countries.get( self.gs.current_country_tag )
        if current_country:

            # if province is national province for current player
            nationals = current_country.national_provinces.keys()

            # if province is claim province for current player
            claimed = current_country.claim_provinces.keys()

            # if its national and if not then its claimed or nothing
            if province.province_id in nationals:
                province_item.set_core_pixmap(True, is_core=True)
            else:
                if province.province_id in claimed:
                    province_item.set_core_pixmap(True, is_core=False)

        # flag for who is occupying province
        if province.is_land:
            if country_occup:
                province_item.set_city_pixmap('flag_frame', province.country_occupant_tag + '.png')
            else:
                province_item.set_city_pixmap('city', 'city.png')
                primary_color = 'basic_land'

        province_item.set_province_background_colors(primary_color=primary_color,
                                                secondary_color=secondary_color)