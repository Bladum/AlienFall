import yaml
from PySide6.QtGui import QColor, QPen, QBrush

from battle.battle import BattleMapBlock, LandUnitType
from ref.ref_area import GeoArea
from ref.ref_building import Building
from ref.ref_climate import Climate
from ref.ref_continent import GeoContinent
from ref.ref_culture import Culture
from ref.ref_goods import Goods
from ref.ref_region import GeoRegion
from ref.ref_religion import Religion
from ref.ref_terrain import Terrains
from src.db import TDB

db = TDB()

def load_countries_from_yaml():
    print("  Load country definitions from yaml")
    file_path = db.path_db / 'countries.yml'

    from country import Country

    with open(file_path, 'r') as file:
        countries_data = yaml.safe_load(file)
    countries = countries_data.get('country', {})

    output_countries : dict[str, Country] = {}

    # setup global lists of who owns what
    for key, val in countries.items():

        db.country_province_national_dict[key] = []
        db.country_province_claim_dict[key] = []

        val['tag'] = key
        country = Country(val)
        output_countries[ key] = country

    db.countries = output_countries


def load_terrains_from_yaml():
    print("  Load terrains definitions from yaml")
    file_path = db.path_db / 'terrains.yml'

    with open(file_path, 'r') as file:
        terrains_data = yaml.safe_load(file)
    terrains = terrains_data.get('terrains', {})

    c_dict = {}
    for key, val in terrains.items():
        val['tag'] = key
        c_dict[ key ] = Terrains( val )

    db.db_terrains = c_dict

    # load battle tiles codes
    battle_tile_codes = terrains_data.get('battle_tile_codes', {})
    db.battle_tile_codes = battle_tile_codes

    db.db_battle_maps_blocks = {}

    db_battle_maps_blocks = terrains_data.get('battle_map_blocks', {})
    for key, val in db_battle_maps_blocks.items():
        db.db_battle_maps_blocks[key] = []
        for block in val:
            b = BattleMapBlock( block )
            db.db_battle_maps_blocks[key].append( b )


def load_cultures_from_yaml():
    print("  Load culture definitions from yaml")
    file_path = db.path_db / 'culture.yml'

    with open(file_path, 'r') as file:
        cultures_data = yaml.safe_load(file)
    cultures = cultures_data.get('cultures', {})

    c_dict = {}
    for key, val in cultures.items():
        val['tag'] = key
        c_dict[ key ] = Culture( val )

    db.db_cultures = c_dict


def load_buildings_from_yaml():
    print("  Load building definitions from yaml")
    file_path = db.path_db / 'buildings.yml'

    with open(file_path, 'r') as file:
        build_data = yaml.safe_load(file)
    buildings = build_data.get('buildings', {})

    b_dict = {}
    for key, val in buildings.items():
        val['tag'] = key
        b_dict[ key ] = Building( val )

    db.db_buildings = b_dict


def load_religions_from_yaml():
    print("  Load religion definitions from yaml")
    file_path = db.path_db / 'religion.yml'

    with open(file_path, 'r') as file:
        religions_data = yaml.safe_load(file)
    religions = religions_data.get('religions', {})

    c_dict = {}
    for key, val in religions.items():
        val['tag'] = key
        c_dict[ key ] = Religion( val )

    db.db_religions = c_dict

def load_climates_from_yaml():
    print("  Load climate definitions from yaml")
    file_path = db.path_db / 'climate.yml'

    with open(file_path, 'r') as file:
        climates_data = yaml.safe_load(file)
    climates = climates_data.get('climates', {})

    c_dict = {}
    for key, val in climates.items():
        val['tag'] = key
        c_dict[ key ] = Climate( val )

    db.db_climates = c_dict


def load_goods_from_yaml():
    print("  Load goods definitions from yaml")
    file_path = db.path_db / 'goods.yml'

    with open(file_path, 'r') as file:
        goods_data = yaml.safe_load(file)
    goods = goods_data.get('goods', {})

    c_dict = {}
    for key, val in goods.items():
        val['tag'] = key
        c_dict[ key ] = Goods( val )

    db.db_goods = c_dict


def load_regions_from_yaml():
    print("  Load regions definitions from yaml")
    file_path = db.path_db / 'regions.yml'

    with open(file_path, 'r') as file:
        regions_data = yaml.safe_load(file)
    regions = regions_data.get('regions', {})

    c_dict = {}
    for key, val in regions.items():
        val['tag'] = key
        c_dict[ key ] = GeoRegion( val )

    db.db_regions = c_dict

def load_areas_from_yaml():
    print("  Load areas definitions from yaml")
    file_path = db.path_db / 'area.yml'

    with open(file_path, 'r') as file:
        areas_data = yaml.safe_load(file)
    areas = areas_data.get('areas', {})

    c_dict = {}
    for key, val in areas.items():
        val['tag'] = key
        c_dict[ key ] = GeoArea( val )

    db.db_areas = c_dict

def load_continents_from_yaml():
    print("  Load continents definitions from yaml")
    file_path = db.path_db / 'continents.yml'

    with open(file_path, 'r') as file:
        cont_data = yaml.safe_load(file)
    conts = cont_data.get('continents', {})

    c_dict = {}
    for key, val in conts.items():
        val['tag'] = key
        c_dict[ key ] = GeoContinent( val )

    db.db_continents = c_dict

def load_cot_colors_from_yaml():
    print("  Load cot colors definitions from yaml")
    file_path = db.path_db / 'cots.yml'

    with open(file_path, 'r') as file:
        cots_data = yaml.safe_load(file)
    cots = cots_data.get('cots_colors', {})

    db.db_cot_colors = cots


def load_units_from_yaml():
    print("  Load units definitions from yaml")
    file_path = db.path_db / 'units.yml'

    with open(file_path, 'r') as file:
        units_data = yaml.safe_load(file)
    units = units_data.get('land_unit', {})

    units_obj : dict[str, LandUnitType] = {}
    for k, val in units.items():
        u = LandUnitType( val )
        units_obj[k] = u

    db.db_units = units_obj


def load_colors_from_yaml():
    print("  Load colors definitions from yaml file")
    file_path = db.path_db / 'colors.yml'

    with open(file_path, 'r') as file:
        colors_data = yaml.safe_load(file)
    colors = {}
    for name, hex_value in colors_data['colors'].items():
        colors[name] = QColor(hex_value)

    db.db_colors = colors

    # Create QColor, QPen, and QBrush for each color
    db.db_colors_color = {}
    db.db_colors_pen = {}
    db.db_colors_brush = {}

    for name, color in colors.items():
        db.db_colors_color[name] = QColor(color)
        db.db_colors_pen[name] = QPen(color)
        db.db_colors_brush[name] = QBrush(color)


def load_color_sets_from_yaml():
    print("  Load color sets from yaml")
    file_path = db.path_db / 'colors.yml'

    with open(file_path, 'r') as file:
        color_sets_data = yaml.safe_load(file)
    color_sets = color_sets_data.get('color_sets', {})

    db.db_color_sets = color_sets
