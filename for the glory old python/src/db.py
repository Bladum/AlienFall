import pathlib

import yaml
from PIL.ImageQt import QPixmap
from PySide6.QtGui import QColor, QPen, Qt, QBrush
from pypdn import LayeredImage

#
# in general this file contains all variables to manage data inside mod
#


class TDB:

    _instance = None

    def __new__(cls, *args, **kwargs):
        if not cls._instance:
            cls._instance = super(TDB, cls).__new__(cls)
        return cls._instance

    def __init__(self):
        if not hasattr(self, 'initialized'):
            self.initialized = True

            self.rect_size = 24

          #
            #   paths
            #]]]

            self.path_mod : pathlib.Path = None
            self.path_mod_duck : pathlib.Path = None

            self.path_gfx  : pathlib.Path = None
            self.path_sfx  : pathlib.Path = None
            self.path_db  : pathlib.Path = None
            self.path_map  : pathlib.Path = None
            self.path_tiles  : pathlib.Path = None
            self.path_tiles_auto  : pathlib.Path = None

            self.path_db_provinces : pathlib.Path = None
            self.path_db_provinces_csv : pathlib.Path = None

            self.path_db_events  : pathlib.Path = None
            self.path_db_generals  : pathlib.Path = None
            self.path_db_monarchs  : pathlib.Path = None
            self.path_db_decisions  : pathlib.Path = None

            self.path_map_pdn : pathlib.Path = None
            self.path_map_province : pathlib.Path = None
            self.path_map_river : pathlib.Path = None
            self.path_map_capital : pathlib.Path = None
            self.path_map_terrain : pathlib.Path = None
            self.path_logs : pathlib.Path = None

            #
            # mod definitions
            #

            self.db_z_values = {}
            self.db_pen_sizes = {}
            self.db_font_sizes = {}
            self.db_map_size = {}

            # this is only dict data, no classes, everything loaded from yaml files

            self.db_colors = {}
            self.db_color_sets = {}

            from ref.ref_culture import Culture
            self.db_cultures: dict[str, Culture] = {}

            from ref.ref_goods import Goods
            self.db_goods: dict[str, Goods] = {}

            from ref.ref_climate import Climate
            self.db_climates: dict[str, Climate] =  {}

            self.db_natives = {}
            self.db_rebels = {}

            from units.land_unit import LandUnitType
            self.db_units : dict[str, LandUnitType] = {}

            from ref.ref_technology import Technology
            self.db_technologies : dict[str, Technology] = {}

            from ref.ref_religion import Religion
            self.db_religions: dict[str, Religion] = {}

            from ref.ref_terrain import Terrains
            self.db_terrains: dict[str, Terrains] = {}

            from ref.ref_building import Building
            self.db_buildings : dict[str, Building] = {}

            from ref.ref_region import GeoRegion
            self.db_regions: dict[str, GeoRegion] = {}

            from ref.ref_continent import GeoContinent
            self.db_continents: dict[str, GeoContinent] = {}

            from ref.ref_area import GeoArea
            self.db_areas: dict[str, GeoArea] = {}

            from ref.ref_ruler import Ruler
            self.db_rulers: dict[str, Ruler] = {}

            self.battle_tile_codes : dict = {}

            from battle.battle import BattleMapBlock
            self.db_battle_maps_blocks: dict[str, list[BattleMapBlock]] = {}

            self.db_generals = {}
            self.db_events = {}
            self.db_decisions = {}

            self.db_cot_colors = {}

            self.current_map_mode = 'terrain'
            self.current_map_mode_region = 0

            # colors as Qt objects with key as color name

            self.db_colors_color: dict[str, QColor] = {}
            self.db_colors_pen: dict[str, QPen] = {}
            self.db_colors_brush: dict[str, QBrush] = {}

            #
            #   resources like grahics and sounds
            #

            self.res_images: dict[str, QPixmap] = {}
            self.res_sounds = {}
            self.res_image_river : list[QPixmap] = []

            #
            # world map in format of PNG / PDN file
            #

            self.map_pdn : LayeredImage = None
            self.map_capitals : QPixmap = None
            self.map_rivers: QPixmap = None
            self.map_terrains: QPixmap = None

            #
            #   ongoing variables
            #

            self.map_width = 875
            self.map_height = 375

            from src.cot import CenterOfTrade
            self.center_of_trades : dict[str, CenterOfTrade] = {}           # main list of COTs

            from items.item_province import ProvinceItem
            self.provinces : dict[int, ProvinceItem] = {}                   # main list of provinces

            from country import Country
            self.countries : dict[str, Country] = {}                        # main list of countries

            from ref.ref_ruler import Ruler
            self.rulers : dict[int, Ruler] = {}                             # main list of rulers

            from items.item_border import BorderItem
            self.borders_items : dict[ tuple, BorderItem] = {}                # dict of borders, key = tuple ( provA, provB) and value = border

            from items.item_road import RoadItem
            self.roads_items: dict[ tuple, RoadItem] = {}                     # dict of roads, key = tuple (provA, provB) and value = road

            self.province_mapping_color : dict[int, str] = {}                # which province is which color
            self.province_mapping_color_hex : dict[str, int] = {}            # which color has which province ID

            self.province_neighbors : dict[ int, list ] = {}                 # per province id list of its neihbours IDs
            self.province_neighbors_list : dict[ int, str] = {}              # which province has which other province as neighbours as 1,2,3,4
            self.province_neighbours_distance : dict[ tuple, float ] =  {}   # distance between two provinces in tiles key = tuple(from to)

            self.province_river_tiles_list : dict[int, tuple] = {}    # list per province which map tiles are rivers with which autotile

            self.provinces_data_dict : dict[int, dict] =  {}          # dict data of provinces loaded from CSV or Yaml

            self.province_border_map: list[list] = []                 # 2D tile map where to put borders
            self.river_id_map : list[list] = []                       # 2D tile map where is river, which direction it flows, values for autotiles

            self.province_id_map : list[list] = []                    # 2D tile map which tile is to which province ID
            self.province_tile_list : dict[int, str] = {}             # province list with map tiles list with ','
            self.province_rectangles : dict[int, list] = {}           # 2D tile map which tile has which rectangle

            self.city_id_map : list[list] = []                    # 2D map which tile is considered as province city
            self.name_id_map : list[list] = []                    # 2D map which tile is considered places to put province name (at least 2)

            self.country_province_owner_dict: dict[int, str] = {}        # which province has who as owner TAG
            self.country_province_occupant_dict: dict[int, str] = {}     # which province has who as occupant TAG
            self.country_province_national_dict: dict[str, list] = {}   # which country has which provinces as national
            self.country_province_claim_dict : dict[str, list] = {}        # which country has which provinces as claim

            self.current_country_tag = 'REB'             # current country TAG

            self.current_display_map_mode = 'politic'    # current map mode
            self.current_zoom_index = 2                  # current zoom level
            self.zoom_levels = [0.25, 0.5, 1.0, 2]

            #
            # graphics constants
            #

            self.COLOR_DEBUG = QColor(0, 0, 0, 255)

            self.color_font_land = QColor()
            self.color_font_sea = QColor()

            self.color_border_province = QColor()
            self.color_border_coastal = QColor()
            self.color_border_country = QColor()
            self.color_border_sea = QColor()

            self.color_land = QColor()       # RGB for navy
            self.color_sea = QColor()       # RGB for navy
            self.color_river = QColor()     # RGB for navy

            self.color_fog_of_war = QColor()

            self.color_road_land = QColor()
            self.color_road_sea = QColor()
            self.color_road_coast = QColor()

            self.pen_road_max_size = 32
            self.pen_road_land = QPen(self.color_road_land, 1, Qt.SolidLine, Qt.RoundCap, Qt.RoundJoin)
            self.pen_road_sea = QPen(self.color_road_sea, 1, Qt.SolidLine, Qt.RoundCap, Qt.RoundJoin)
            self.pen_road_coast = QPen(self.color_road_coast, 1, Qt.SolidLine, Qt.RoundCap, Qt.RoundJoin)

            self.pen_border_province = QPen(self.color_border_province, 2, Qt.DotLine, Qt.RoundCap, Qt.RoundJoin)
            self.pen_border_coastal = QPen(self.color_border_coastal, 4, Qt.SolidLine, Qt.RoundCap, Qt.RoundJoin)
            self.pen_border_sea = QPen(self.color_border_sea, 3, Qt.DashLine, Qt.RoundCap, Qt.RoundJoin)
            self.pen_border_country = QPen(self.color_border_country, 5, Qt.DotLine, Qt.RoundCap, Qt.RoundJoin)
            self.pen_river = QPen(self.color_river, 7, Qt.SolidLine, Qt.RoundCap, Qt.RoundJoin)

            self.font_size_land = 9
            self.font_size_sea = 11
            self.font_size_debug = 14

            #
            #   z level constants
            #

            self.z_value_map_tile = 0
            self.z_value_sea_border = 1
            self.z_value_coast_border = 2
            self.z_value_river = 3
            self.z_value_prov_border = 4
            self.z_value_country_border = 5
            self.z_value_roads = 7
            self.z_value_city = 8
            self.z_value_prov_name = 9
            self.z_value_fog_of_war = 20
            self.z_value_army = 12

            from src.game_scene import GameScene
            self.game_scene : GameScene = None

    def setup_mod(self, path):

        path_home = pathlib.Path.cwd().parent
        self.path_mod = pathlib.Path( path_home / path)

        print("Setup mod from path", self.path_mod)

        self.path_gfx = self.path_mod / 'gfx'
        self.path_sfx = self.path_mod / 'sfx'
        self.path_db = self.path_mod / 'db'
        self.path_map = self.path_mod / 'map'
        self.path_tiles = self.path_mod / 'tiles'
        self.path_mod_duck = self.path_mod / 'duckdb'
        self.path_tiles_auto = self.path_tiles / 'autotiles'

        self.path_db_provinces = self.path_db / 'provinces.yml'
        self.path_db_provinces_csv = self.path_db / 'provinces.csv'

        self.path_map_pdn = self.path_map / 'map3.pdn'
        self.path_map_province = self.path_map / 'map_provinces.png'
        self.path_map_river = self.path_map / 'map_rivers.png'
        self.path_map_capital = self.path_map / 'map_capitals.png'

        self.path_db_events = self.path_db / 'events'
        self.path_db_generals = self.path_db / 'generals'
        self.path_db_monarchs = self.path_db / 'monarchs'
        self.path_db_decisions = self.path_db / 'decisions'

        self.path_logs = path_home / 'logs'

        with open(self.path_db / 'colors.yml', 'r') as file:
            data = yaml.safe_load(file)
            self.db_colors = data.get('colors', {})

            self.color_border_province = QColor(self.db_colors.get('border_province'))
            self.color_border_sea = QColor(self.db_colors.get('border_sea'))
            self.color_border_coastal = QColor(self.db_colors.get('border_coastal'))
            self.color_border_country = QColor(self.db_colors.get('border_country'))

            self.color_road_land = QColor(self.db_colors.get('road_land'))
            self.color_road_sea = QColor(self.db_colors.get('road_sea'))
            self.color_road_coast = QColor(self.db_colors.get('road_coastal'))

            self.color_land = QColor(self.db_colors.get('basic_land'))
            self.color_sea = QColor(self.db_colors.get('basic_water'))
            self.color_river = QColor(self.db_colors.get('basic_river'))
            self.color_fog_of_war = QColor(self.db_colors.get('fog_of_war'))

            self.color_font_sea = QColor(self.db_colors.get('font_sea'))
            self.color_font_land = QColor(self.db_colors.get('font_land'))

            self.db_color_sets = data.get('color_sets', {})

            self.db_font_sizes = data.get('font_size', {})
            self.font_size_land = self.db_font_sizes.get('land', 9)
            self.font_size_sea = self.db_font_sizes.get('sea', 11)
            self.font_size_debug = self.db_font_sizes.get('debug', 14)

            self.db_map_size = data.get('map_size', {})
            self.map_width = self.db_map_size.get('width', 700)
            self.map_height = self.db_map_size.get('height', 300)
            self.rect_size = self.db_map_size.get('rect_size', 24)

            self.db_z_values = data.get('z_value', {})
            self.z_value_map_tile = self.db_z_values.get('map_tile', 0)
            self.z_value_sea_border = self.db_z_values.get('sea_border', 1)
            self.z_value_coast_border = self.db_z_values.get('coast_border', 2)
            self.z_value_river = self.db_z_values.get('river', 3)
            self.z_value_prov_border = self.db_z_values.get('province_border', 4)
            self.z_value_country_border = self.db_z_values.get('country_border', 5)
            self.z_value_roads = self.db_z_values.get('road', 7)
            self.z_value_city = self.db_z_values.get('city', 8)
            self.z_value_prov_name = self.db_z_values.get('province_name', 9)
            self.z_value_army = self.db_z_values.get('z_value_army', 12)

            self.db_pen_sizes = data.get('pen_size', {})
            self.pen_road_max_size = self.db_font_sizes.get('road_max_size', 32)
            self.pen_border_province.setWidth(self.db_pen_sizes.get("border_land", 2))
            self.pen_border_sea.setWidth(self.db_pen_sizes.get("border_sea", 3))
            self.pen_border_coastal.setWidth(self.db_pen_sizes.get("border_coastal", 4))
            self.pen_border_country.setWidth(self.db_pen_sizes.get("border_country", 5))
            self.pen_road_sea.setWidth(self.db_pen_sizes.get("road_sea", 1))
            self.pen_road_land.setWidth(self.db_pen_sizes.get("road_land", 1))
            self.pen_road_coast.setWidth(self.db_pen_sizes.get("road_coast", 2))
            self.pen_river.setWidth(self.db_pen_sizes.get("river", 7))

            self.pen_border_province.setColor(self.color_border_province)
            self.pen_border_sea.setColor(self.color_border_sea)
            self.pen_border_coastal.setColor(self.color_border_coastal)
            self.pen_border_country.setColor(self.color_border_country)
            self.pen_road_sea.setColor(self.color_road_sea)
            self.pen_road_land.setColor(self.color_road_land)
            self.pen_road_coast.setColor(self.color_road_coast)
            self.pen_river.setColor(self.color_river)


class Dice:
    import random

    sides = 6

    @staticmethod
    def __init__(sides):
        Dice.sides = sides

    @staticmethod
    def _roll():
        return Dice.random.randint(1, Dice.sides)

    @staticmethod
    def K6(value=None):
        roll = Dice(6)._roll()
        return roll < value if value is not None else roll

    @staticmethod
    def K10(value=None):
        roll = Dice(10)._roll()
        return roll < value if value is not None else roll

    @staticmethod
    def K12(value=None):
        roll = Dice(12)._roll()
        return roll < value if value is not None else roll

    @staticmethod
    def K20(value=None):
        roll = Dice(20)._roll()
        return roll < value if value is not None else roll

    @staticmethod
    def K100(value=None):
        roll = Dice(100)._roll()
        return roll < value if value is not None else roll
