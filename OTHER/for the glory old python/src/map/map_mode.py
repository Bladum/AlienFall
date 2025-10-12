import random

from items.item_province import ProvinceItem
from ref.ref_culture import Culture
from src.db import TDB

db = TDB()
#
#   SWITCH GAME MAP MODES
#

def switch_map_mode(new_mode):
    print("Switch map mode to ", new_mode)

    map_mode_switchers = {
        'terrain': _switch_map_mode_terrain,
        'culture': _switch_map_mode_culture,
        'religion': _switch_map_mode_religion,
        'climate': _switch_map_mode_climate,
        'goods': _switch_map_mode_goods,
        'politic': _switch_map_mode_politic,
        'region': _switch_map_mode_region,
        'manpower': _switch_map_mode_manpower,
        'trade': _switch_map_mode_trade,
    }

    if new_mode in map_mode_switchers.keys():
        # cycle on region map
        if db.current_map_mode == 'region' and new_mode == 'region':
            db.current_map_mode_region = (  db.current_map_mode_region + 1 ) % 3
        else:
            db.current_map_mode_region = 0

        db.current_map_mode = new_mode
        for province in db.provinces.values():
            if province.is_explored:
                map_mode_switchers[new_mode](province)

def _switch_map_mode_terrain( province):

    province: ProvinceItem

    # enable fog of war
    province.enable_fog_of_war()

    country_owner = db.countries.get( province.country_owner_tag)

    primary_color = 'basic_water'
    weather_effect = None
    secondary_color = None

    province.set_province_large_frame(None)
    province.set_core_pixmap(False)
    province.set_city_number()
    if province.is_land:
        province.set_city_pixmap()
    else:
        province.set_city_pixmap('city', 'sea.png')

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
        province.set_city_number(number=army_size)

    # set owner of province
    if province.is_land:
        province.set_city_pixmap('flag_frame', province.country_occupant_tag + '.png')

    # set capitol large frame
    if country_owner:
        if province == country_owner.capitol_province:
            province.set_province_large_frame(country_owner.budget.stability)

    province.set_province_background_colors( primary_color = primary_color,
                                             weather_effect = weather_effect,
                                             secondary_color = secondary_color )

def _switch_map_mode_culture( province):

    # no fog of war
    province.disable_fog_of_war()

    country_owner = db.countries.get( province.country_owner_tag)

    primary_color = 'basic_water'
    secondary_color = None

    province.set_province_large_frame(None)
    province.set_core_pixmap(False)
    province.set_city_number()
    if province.is_land:
        province.set_city_pixmap()
    else:
        province.set_city_pixmap('city', 'sea.png')

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
                province.set_province_large_frame(country_owner.budget.stability)
                province.set_city_pixmap('flag_frame', province.country_owner_tag + '.png')

    province.set_province_background_colors(primary_color = primary_color,
                                            secondary_color=secondary_color)

def _switch_map_mode_religion(province ):

    # no fog of war
    province.disable_fog_of_war()

    country_owner = db.countries.get( province.country_owner_tag)

    primary_color = 'basic_water'
    secondary_color = None

    province.set_province_large_frame(None)
    province.set_core_pixmap(False)
    province.set_city_number()
    if province.is_land:
        province.set_city_pixmap()
    else:
        province.set_city_pixmap('city', 'sea.png')

    # religion province
    prov_religion = province.religion
    if prov_religion:
        primary_color = prov_religion.color_name

    # if there is a country owner and what is background color
    if country_owner:

        # is state religion is NOT as province religion
        state_religion = country_owner.state_religion
        if state_religion.tag != prov_religion.tag:
            secondary_color = state_religion.color_name

        # in capitol city show country religion
        if province == country_owner.capitol_province:
            province.set_city_pixmap('religion_frame', state_religion.tag + '.png')
            province.set_province_large_frame(country_owner.budget.stability)

    province.set_province_background_colors(primary_color = primary_color,
                                            secondary_color= secondary_color)

def _switch_map_mode_manpower(province):

    # no fog of war
    province.disable_fog_of_war()

    country_owner = db.countries.get( province.country_owner_tag)

    province.set_province_large_frame(None)
    province.set_core_pixmap(False)
    province.set_city_number()
    if province.is_land:
        province.set_city_pixmap()
    else:
        province.set_city_pixmap('city', 'sea.png')

    primary_color = 'basic_water'
    secondary_color = None

    # manpower
    manpower = int(province.manpower)
    if manpower > 0:
        primary_color = f"good_0{min( manpower - 1, 9 )}"
        province.set_city_number(number= manpower )

    # set capitol large frame
    if country_owner:
        if province == country_owner.capitol_province:
            province.set_province_large_frame(country_owner.budget.stability)
            province.set_city_pixmap('flag_frame', province.country_owner_tag + '.png')

    province.set_province_background_colors(primary_color = primary_color)

def _switch_map_mode_region(province):
    # no fog of war
    province.disable_fog_of_war()

    country_owner = db.countries.get( province.country_owner_tag)

    region_map_mode = db.current_map_mode_region

    primary_color = 'basic_water'
    secondary_color = None
    terrain_effect = None

    province.set_province_large_frame(None)
    province.set_core_pixmap(False)
    province.set_city_number()
    if province.is_land:
        province.set_city_pixmap()
    else:
        province.set_city_pixmap('city', 'sea.png')

    region_data = {}

    # primary is regions / area / contient
    if region_map_mode == 0:
        region_data = province.region
    elif region_map_mode == 1:
        region_data = province.continent
    elif region_map_mode == 2:
        region_data = province.area

    if region_data:
        primary_color = region_data.color_name

    # if there is a country owner and what is background color
    if country_owner:

        # in capitol city show country flag only
        if province == country_owner.capitol_province:
            province.set_province_large_frame(country_owner.budget.stability)
            province.set_city_pixmap('flag_frame', province.country_owner_tag + '.png')

    province.set_province_background_colors(primary_color = primary_color)

def _switch_map_mode_climate(province):

    # no fog of war
    province.disable_fog_of_war()

    country_owner = db.countries.get( province.country_owner_tag)

    primary_color = 'basic_water'
    secondary_color = None

    province.set_province_large_frame(None)
    province.set_core_pixmap(False)
    province.set_city_number()
    if province.is_land:
        province.set_city_pixmap()
    else:
        province.set_city_pixmap('city', 'sea.png')

    # climate
    climate = province.climate
    if climate:
        primary_color = climate.color_name
        if not province.is_land:
            secondary_color = 'basic_water'

    # if there is a country owner and what is background color
    if country_owner:
        # in capitol city show country flag only
        if province == country_owner.capitol_province:
            province.set_province_large_frame(country_owner.budget.stability)
            province.set_city_pixmap('flag_frame', province.country_owner_tag + '.png')


    province.set_province_background_colors(primary_color = primary_color,
                                            secondary_color= secondary_color)

def _switch_map_mode_goods(province):

    # no fog of war
    province.disable_fog_of_war()

    country_owner = db.countries.get( province.country_owner_tag)

    primary_color = 'basic_water'
    secondary_color = None

    province.set_province_large_frame(None)
    province.set_core_pixmap(False)
    province.set_city_number()
    if province.is_land:
        province.set_city_pixmap()
    else:
        province.set_city_pixmap('city', 'sea.png')

    # good are only on land
    if province.is_land:
        province.set_core_pixmap(False)
        goods = province.goods
        if goods:
            province.set_city_pixmap('goods_frame', goods.tag + '.png')
            primary_color = goods.color_name
        else:
            primary_color = 'grayed'

    # set capitol large frame
    if country_owner:
        if province == country_owner.capitol_province:
            province.set_province_large_frame(country_owner.budget.stability)

    province.set_province_background_colors(primary_color = primary_color)

def _switch_map_mode_trade( province):
    province: ProvinceItem

    # disable fog of war
    province.disable_fog_of_war()

    country_owner = db.countries.get( province.country_owner_tag)

    primary_color = 'basic_water'
    secondary_color = None

    province.set_province_large_frame(None)
    province.set_core_pixmap(False)
    province.set_city_number()
    if province.is_land:
        province.set_city_pixmap()
    else:
        province.set_city_pixmap('city', 'sea.png')

    # trade is only on land
    if province.is_land:
        # province belongs o this center of trade
        cot = province.center_of_trade
        if cot:
            primary_color = cot.color

            # if this is location of center of trade
            if cot.location_province_id == province.province_id:
                province.set_city_pixmap('flag_frame', province.country_owner_tag + '.png')
                province.set_province_large_frame(stab_level=cot.stability)
                province.set_city_number(number=len(cot.merchants) * 15)
        else:
            # not in COT range
            primary_color = 'grayed'

    province.set_province_background_colors(primary_color = primary_color)

def _switch_map_mode_politic( province):
    province : ProvinceItem

    province.enable_fog_of_war()

    country_owner = db.countries.get(province.country_owner_tag, None)
    country_occup = db.countries.get(province.country_occupant_tag, None)

    primary_color = 'basic_water'
    secondary_color = None

    province.set_province_large_frame(None)
    province.set_core_pixmap(False)
    province.set_city_number()
    if province.is_land:
        province.set_city_pixmap()
    else:
        province.set_city_pixmap('city', 'sea.png')

    # if there is a country owner and what is background color
    if country_owner:

        if province.is_country_capitol:
            country = db.countries.get( province.country_owner_tag )
            if country:
                province.set_province_large_frame( country.budget.stability )

        # if there is no occupant
        if country_occup == country_owner:
            primary_color = country_owner.color
        else:
            # if there is occupant
            if country_occup:
                primary_color=country_owner.color
                secondary_color=country_occup.color
            else:
                primary_color=country_owner.color
                secondary_color = None
    else:
        if province.is_land:  # no owner
            primary_color = 'basic_land'

    army_size, navy_size = province.total_number_of_units_in_province()
    if army_size > 0:
        province.set_city_number(number=army_size)

    # FOR CURRENT COUNTRY

    # nationals or claimed provs
    current_country = db.countries.get( db.current_country_tag )
    if current_country:

        # if province is national province for current player
        nationals = current_country.national_provinces.keys()

        # if province is claim province for current player
        claimed = current_country.claim_provinces.keys()

        # if its national and if not then its claimed or nothing
        if province.province_id in nationals:
            province.set_core_pixmap(True, is_core=True)
        else:
            if province.province_id in claimed:
                province.set_core_pixmap(True, is_core=False)

    # flag for who is occupying province
    if province.is_land:
        if country_occup:
            province.set_city_pixmap('flag_frame', province.country_occupant_tag + '.png')
        else:
            province.set_city_pixmap('city', 'city.png')
            primary_color = 'basic_land'

    province.set_province_background_colors(primary_color=primary_color,
                                            secondary_color=secondary_color)