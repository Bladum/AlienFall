import toml
from PySide6.QtGui import QColor, QPen, QBrush

from ai.ai_agent import AIAgent
from object.country import Country
from ref.ref_climate import Climate
from ref.ref_mapblock import BattleMapBlock
from ref.ref_period import Period
from ref.ref_policy import Policies
from ref.ref_regiment import RegimentType
from ref.ref_region import GeoRegion
from ref.ref_unit import UnitType
from ref.ref_area import GeoArea
from ref.ref_building import Building
from ref.ref_continent import GeoContinent
from ref.ref_culture import Culture
from ref.ref_formation import BattleFormation
from ref.ref_goods import Goods
from ref.ref_religion import Religion
from ref.ref_techgroup import TechGroup
from ref.ref_terrain import Terrains

from core.game_state import GameState
gs = GameState()

def load_countries_from_toml():
    print("  Load country definitions from toml")
    file_path = gs.path_db / 'country.toml'

    with open(file_path, 'r') as file:
        countries = toml.load(file)

    output_countries : dict[str, Country] = {}

    # setup global lists of who owns what
    for key, val in countries.items():

        gs.country_province_national_dict[key] = []
        gs.country_province_claim_dict[key] = []

        val['tag'] = key
        country = Country(val)
        output_countries[ key] = country

    gs.countries = output_countries


def load_terrains_from_toml():
    print("  Load terrains definitions from toml")

    file_path = gs.path_db / 'terrain.toml'
    with open(file_path, 'r') as file:
        terrains = toml.load(file)

    c_dict = {}
    for key, val in terrains.items():
        val['tag'] = key
        c_dict[ key ] = Terrains( val )

    gs.db_terrains = c_dict

    # load battle tiles codes
    file_path = gs.path_db / 'terrain_code.toml'
    with open(file_path, 'r') as file:
        battle_tile_codes = toml.load(file)

    gs.battle_tile_codes = battle_tile_codes

    gs.db_battle_maps_blocks = {}

    file_path = gs.path_db / 'terrain_block.toml'
    with open(file_path, 'r') as file:
        db_battle_maps_blocks = toml.load(file)

    for key, val in db_battle_maps_blocks.items():
        gs.db_battle_maps_blocks[key] = []
        for block in val:
            b = BattleMapBlock( block )
            gs.db_battle_maps_blocks[key].append( b )


def load_cultures_from_toml():
    print("  Load culture definitions from toml")
    file_path = gs.path_db / 'culture.toml'

    with open(file_path, 'r') as file:
        cultures = toml.load(file)

    c_dict = {}
    for key, val in cultures.items():
        val['tag'] = key
        c_dict[ key ] = Culture( val )

    gs.db_cultures = c_dict


def load_buildings_from_toml():
    print("  Load building definitions from toml")
    file_path = gs.path_db / 'building.toml'

    with open(file_path, 'r') as file:
        buildings = toml.load(file)

    b_dict = {}
    for key, val in buildings.items():
        val['tag'] = key
        b_dict[ key ] = Building( val )

    gs.db_buildings = b_dict


def load_religions_from_toml():
    print("  Load religion definitions from toml")
    file_path = gs.path_db / 'religion.toml'

    with open(file_path, 'r') as file:
        religions = toml.load(file)

    c_dict = {}
    for key, val in religions.items():
        val['tag'] = key
        c_dict[ key ] = Religion( val )

    gs.db_religions = c_dict

def load_climates_from_toml():
    print("  Load climate definitions from toml")
    file_path = gs.path_db / 'climate.toml'

    with open(file_path, 'r') as file:
        climates =  toml.load(file)

    c_dict = {}
    for key, val in climates.items():
        val['tag'] = key
        c_dict[ key ] = Climate( val )

    gs.db_climates = c_dict


def load_goods_from_toml():
    print("  Load goods definitions from toml")
    file_path = gs.path_db / 'good.toml'

    with open(file_path, 'r') as file:
        goods = toml.load(file)

    c_dict = {}
    for key, val in goods.items():
        val['tag'] = key
        c_dict[ key ] = Goods( val )

    gs.db_goods = c_dict


def load_regions_from_toml():
    print("  Load regions definitions from toml")
    file_path = gs.path_db / 'region.toml'

    with open(file_path, 'r') as file:
        regions = toml.load(file)

    c_dict = {}
    for key, val in regions.items():
        val['tag'] = key
        c_dict[ key ] = GeoRegion( val )

    gs.db_regions = c_dict

def load_areas_from_toml():
    print("  Load areas definitions from toml")
    file_path = gs.path_db / 'area.toml'

    with open(file_path, 'r') as file:
        areas =  toml.load(file)

    c_dict = {}
    for key, val in areas.items():
        val['tag'] = key
        c_dict[ key ] = GeoArea( val )

    gs.db_areas = c_dict

def load_continents_from_toml():
    print("  Load continents definitions from toml")
    file_path = gs.path_db / 'continent.toml'

    with open(file_path, 'r') as file:
        conts = toml.load(file)

    c_dict = {}
    for key, val in conts.items():
        val['tag'] = key
        c_dict[ key ] = GeoContinent( val )

    gs.db_continents = c_dict

def load_cot_colors_from_toml():
    print("  Load cot colors definitions from toml")
    file_path = gs.path_db / 'cots.toml'

    with open(file_path, 'r') as file:
        cots = toml.load(file)

    gs.db_cot_colors = cots['cot_colors']



def load_units_from_toml():
    print("  Load units definitions from toml")
    file_path = gs.path_db / 'units.toml'

    with open(file_path, 'r') as file:
        units = toml.load(file)

    units_obj : dict[str, UnitType] = {}
    for k, val in units.items():
        val['tag'] = k
        u = UnitType( val )
        units_obj[k] = u

    gs.db_units = units_obj

def load_regiments_from_toml():
    print("  Load regiment definitions from toml")
    file_path = gs.path_db / 'regiments.toml'

    with open(file_path, 'r') as file:
        units = toml.load(file)

    units_obj : dict[str, RegimentType] = {}
    for k, val in units.items():
        val['tag'] = k
        u = RegimentType( val )
        units_obj[k] = u

    gs.db_regiments = units_obj

def load_techgroup_from_toml():
    print("  Load technology group definitions from toml")
    file_path = gs.path_db / 'technology_group.toml'

    with open(file_path, 'r') as file:
        techgroups = toml.load(file)

    techgroups_obj : dict[str, TechGroup] = {}
    for k, val in techgroups.items():
        val['tag'] = k
        u = TechGroup( val )
        techgroups_obj[k] = u

    gs.db_techgroups = techgroups_obj

def load_policies_from_toml():
    print("  Load domestic policies definitions from toml")
    file_path = gs.path_db / 'policy.toml'

    with open(file_path, 'r') as file:
        policy = toml.load(file)

    policy_obj : dict[str, Policies] = {}
    for k, val in policy.items():
        val['tag'] = k
        u = Policies( val )
        policy_obj[k] = u

    gs.db_policies = policy_obj

def load_units_to_regiments_from_toml():
    print("  Load regiment unit to definitions from toml")
    file_path = gs.path_db / 'unit_regiment.toml'

    with open(file_path, 'r') as file:
        data = toml.load(file)

    gs.db_unit_to_regiments = data


def load_battle_formations_from_toml():
    print("  Load battle region formations from toml")
    file_path = gs.path_db / 'battle_formation.toml'

    with open(file_path, 'r') as file:
        data = toml.load(file)

    map = data.get('battle_map').strip().split('\n')

    map_dict = {}
    for y, row in enumerate(map):
        for x, value in enumerate(row.split('\t')):
            for sub_value in value.split('|'):
                if sub_value not in map_dict:
                    map_dict[sub_value] = []
                map_dict[sub_value].append((x, y))

    gs.db_battle_map = map_dict
    gs.db_battle_regions = data.get('battle_regions')

    form_reg = data.get('battle_formations')

    data_obj : dict[str, BattleFormation] = {}
    for k, val in form_reg.items():
        val['tag'] = k
        u = BattleFormation( val )
        data_obj[k] = u

    gs.db_battle_formations = data_obj

def load_colors_from_toml():
    print("  Load colors definitions from format.toml file")
    file_path = gs.path_db / 'config' / 'color.toml'

    with open(file_path, 'r') as file:
        colors_data = toml.load(file)
    colors = {}
    for name, hex_value in colors_data['color'].items():
        colors[name] = QColor(hex_value)

    gs.db_colors = colors

    # Create QColor, QPen, and QBrush for each color
    gs.db_colors_color = {}
    gs.db_colors_pen = {}
    gs.db_colors_brush = {}

    for name, color in colors.items():
        gs.db_colors_color[name] = QColor(color)
        gs.db_colors_pen[name] = QPen(color)
        gs.db_colors_brush[name] = QBrush(color)

    print("  Load color sets from toml")
    color_sets = colors_data.get('color_sets', {})

    gs.db_color_sets = color_sets

def load_periods_from_toml():
    print("  Load historical periods from toml")
    file_path = gs.path_db / 'period.toml'

    with open(file_path, 'r') as file:
        periods = toml.load(file)

    gs.db_periods = [Period(period) for period in periods]


def load_ai_agents_from_toml():
    print("  Load AI agents definitions from toml")
    file_path = gs.path_db / 'ai.toml'

    with open(file_path, 'r') as file:
        agents = toml.load(file)

    ai_agents = {}
    for key, val in agents.items():
        # Skip sections that are not agent definitions (like comments or other categories)
        if not key.startswith('agent_'):
            continue

        val['tag'] = key
        # Create the agent object
        agent = AIAgent(val)
        ai_agents[key] = agent

    gs.db_ai_agents = ai_agents