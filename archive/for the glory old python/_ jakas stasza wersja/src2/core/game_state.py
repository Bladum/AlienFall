import pathlib

from PIL.Image import Image
from PIL.ImageQt import QPixmap
from PySide6.QtGui import QColor, QPen, Qt, QBrush
from pypdn import LayeredImage

#
# in general this file contains all variables to manage data inside mod
#


class GameState:

    _instance = None

    def __new__(cls, *args, **kwargs):
        if not cls._instance:
            cls._instance = super(GameState, cls).__new__(cls)
        return cls._instance

    def __init__(self):

        if not hasattr(self, 'initialized'):
            self.initialized = True

            self.rect_size = 24
            print("Create game state")

            self.path_mod : pathlib.Path = None
            self.path_mod_duck : pathlib.Path = None

            self.path_gfx  : pathlib.Path = None
            self.path_sfx  : pathlib.Path = None
            self.path_db  : pathlib.Path = None
            self.path_battle  : pathlib.Path = None
            self.path_map  : pathlib.Path = None
            self.path_tiles  : pathlib.Path = None
            self.path_tiles_auto  : pathlib.Path = None

            self.path_db_provinces : pathlib.Path = None
            self.path_db_provinces_toml : pathlib.Path = None

            self.path_db_events  : pathlib.Path = None
            self.path_db_leaders  : pathlib.Path = None
            self.path_db_rulers  : pathlib.Path = None
            self.path_db_ai  : pathlib.Path = None
            self.path_db_ideas  : pathlib.Path = None
            self.path_scenarios  : pathlib.Path = None

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

            from ref.ref_period import Period
            self.db_periods : list[Period] = []

            from ai.ai_agent import AIAgent
            self.db_ai_agents : dict[str, AIAgent] = {}

            from ref.ref_culture import Culture
            self.db_cultures: dict[str, Culture] = {}

            from ref.ref_goods import Goods
            self.db_goods: dict[str, Goods] = {}

            from ref.ref_climate import Climate
            self.db_climates: dict[str, Climate] =  {}

            self.db_natives = {}
            self.db_rebels = {}

            from ref.ref_unit import UnitType
            self.db_units : dict[str, UnitType] = {}

            from ref.ref_regiment import RegimentType
            self.db_regiments : dict[str, RegimentType] = {}

            from ref.ref_techgroup import TechGroup
            self.db_techgroups : dict[str, TechGroup] = {}

            from ref.ref_policy import Policies
            self.db_policies : dict[str, Policies] = {}

            self.db_unit_to_regiments = {}

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

            from ref.ref_mapblock import BattleMapBlock
            self.db_battle_maps_blocks: dict[str, list[BattleMapBlock]] = {}

            from ref.ref_formation import BattleFormation
            self.db_battle_formations : dict[str, BattleFormation ] = {}

            self.db_battle_regions = {}
            self.db_battle_map = {}

            self.db_decisions = {}

            self.map_width = 875
            self.map_height = 375
            self.db_cot_colors = {}

            # mini map pixmap

            self.minimap_pixmap : Image = None

            # colors as Qt objects with key as color name

            self.db_colors_color: dict[str, QColor] = {}
            self.db_colors_pen: dict[str, QPen] = {}
            self.db_colors_brush: dict[str, QBrush] = {}

            #
            #   resources like grahics and sounds
            #

            self.res_images: dict[str, dict[str,QPixmap]] = {}
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

            from object.cot import CenterOfTrade
            self.center_of_trades : dict[str, CenterOfTrade] = {}           # main list of COTs

            from object.province import Province
            self.provinces : dict[int, Province] = {}                   # main list of provinces

            from object.country import Country
            self.countries : dict[str, Country] = {}                        # main list of countries

            from ref.ref_ruler import Ruler
            self.rulers : dict[int, Ruler] = {}                             # main list of rulers

            self.db_leaders = {}
            self.db_events = {}

            # Diplomatic and military data
            self.diplomacy = {
                "relations": {},  # Relations between countries -99 to 99
                "wars": {},  # Active wars
                "allies": {},  # Alliances
                "trade": {},  # Trade agreements
                "dynasties": {},  # Rival or unions declarations
                "vassals": {},  # Vassals and financial relation
                "claims": {},  # Territorial claims
                "access": {}  # Military access agreements
            }

            # what is this ?
            self.economy = {
                'budgets' : {},
                'manpower' : {},
                "agents" : {},
                "stability" : {},
                "prestige" : {}
            }

            # Military units and positions
            self.military = {
                "armies": {},  # Military land units by country
                "navies": {},  # Military naval units by country
                "battles": [],  # Active or recent battles
                "total_strength": {},  # Total military strength by country
                "total_loses": {}  # Total military losses by country
            }

            self.current_map_mode = 'terrain'
            self.current_map_mode_region = 0

            from utils.clock import Clock
            self.game_clock = Clock(1200,1,1)

            self.current_country_tag = 'REB'             # current country TAG

            self.current_display_map_mode = 'politic'    # current map mode
            self.current_zoom_index = 2                  # current zoom level

            self.country_province_owner_dict: dict[int, str] = {}        # which province has who as owner TAG
            self.country_province_occupant_dict: dict[int, str] = {}     # which province has who as occupant TAG
            self.country_province_national_dict: dict[str, list] = {}   # which country has which provinces as national
            self.country_province_claim_dict : dict[str, list] = {}        # which country has which provinces as claim

            #
            #   more like engine level
            #

            from items.item_border import BorderItem
            self.borders_items : dict[ tuple, BorderItem] = {}                # dict of borders, key = tuple ( provA, provB) and value = border

            from items.item_province import ProvinceItem
            self.province_items: dict[ int, ProvinceItem] = {}              # list of provinceitems

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

            self.pen_border_province = QPen(self.color_border_province, 2, Qt.SolidLine, Qt.RoundCap, Qt.RoundJoin)
            self.pen_border_coastal = QPen(self.color_border_coastal, 4, Qt.SolidLine, Qt.RoundCap, Qt.RoundJoin)
            self.pen_border_sea = QPen(self.color_border_sea, 3, Qt.DotLine, Qt.RoundCap, Qt.RoundJoin)
            self.pen_border_country = QPen(self.color_border_country, 5, Qt.DashLine, Qt.RoundCap, Qt.RoundJoin)
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

    def trigger_event(self, name, args):
        pass