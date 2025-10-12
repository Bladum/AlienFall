import pathlib
import toml
from PySide6.QtGui import QColor, QPen, Qt


class ModManager:
    """
    ModManager handles loading and managing game mods.
    It consolidates functionality from gs.py, map_loader and game_logic.
    """

    def __init__(self, game_state):
        """
        Initialize the ModManager

        Args:
            db: Reference to the central TDB database instance
        """
        from core.game_state import GameState
        self.gs : GameState = game_state

    def load_mod(self, mod_name, progress_callback=None):
        """
        Main entry point to load a mod

        Args:
            mod_name: Name of the mod to load
        """
        progress_callback(0)

        # 1. Setup paths
        self.setup_mod_paths(f'data/{mod_name}')

        # Load configuration files
        self.load_color_config()

        progress_callback(5)

        self.load_general_config()

        progress_callback(10)

        # 2. Load mod data
        self.load_mod_data(progress_callback)

        progress_callback(130)

        # 3. Run game logic before processing
        self.process_game_logic_before()

        progress_callback(140)


    def setup_mod_paths(self, path):
        """
        Setup all path variables for the mod

        Args:
            path: Base path to the mod folder
        """
        path_home = pathlib.Path.cwd()
        self.gs.path_mod = pathlib.Path(path_home / path)

        print("Setup mod from path", self.gs.path_mod)

        # Setup directory paths
        self.gs.path_gfx = self.gs.path_mod / 'gfx'
        self.gs.path_sfx = self.gs.path_mod / 'sfx'
        self.gs.path_db = self.gs.path_mod / 'db'
        self.gs.path_battle = self.gs.path_mod / 'battles'
        self.gs.path_map = self.gs.path_mod / 'map'
        self.gs.path_tiles = self.gs.path_mod / 'tiles'
        self.gs.path_mod_duck = self.gs.path_mod / 'out'
        self.gs.path_tiles_auto = self.gs.path_tiles / 'autotiles'

        # Setup file paths
        self.gs.path_db_provinces = self.gs.path_db / 'province.toml'
        self.gs.path_db_provinces_toml = self.gs.path_db / 'province.toml'

        self.gs.path_map_pdn = self.gs.path_map / 'map3.pdn'
        self.gs.path_map_province = self.gs.path_map / 'layers' / 'map_provinces.png'
        self.gs.path_map_river = self.gs.path_map / 'layers' / 'map_rivers.png'
        self.gs.path_map_capital = self.gs.path_map / 'layers' / 'map_capitals.png'

        # Setup specialized directories
        self.gs.path_db_events = self.gs.path_db / 'events'
        self.gs.path_db_leaders = self.gs.path_db / 'leaders'
        self.gs.path_db_rulers = self.gs.path_db / 'rulers'
        self.gs.path_db_ideas = self.gs.path_db / 'ideas'
        self.gs.path_db_ai = self.gs.path_db / 'ai'
        self.gs.path_scenarios = self.gs.path_mod / 'scenarios'

        self.gs.path_logs = path_home / 'logs'

    def load_color_config(self):
        """Load color configuration from the mod"""
        with open(self.gs.path_db / 'config' / 'color.toml', 'r') as file:
            data = toml.load(file)
            self.gs.db_colors = data.get('color', {})

            # Set color properties
            self.gs.color_border_province = QColor(self.gs.db_colors.get('border_province'))
            self.gs.color_border_sea = QColor(self.gs.db_colors.get('border_sea'))
            self.gs.color_border_coastal = QColor(self.gs.db_colors.get('border_coastal'))
            self.gs.color_border_country = QColor(self.gs.db_colors.get('border_country'))

            self.gs.color_road_land = QColor(self.gs.db_colors.get('road_land'))
            self.gs.color_road_sea = QColor(self.gs.db_colors.get('road_sea'))
            self.gs.color_road_coast = QColor(self.gs.db_colors.get('road_coastal'))

            self.gs.color_land = QColor(self.gs.db_colors.get('basic_land'))
            self.gs.color_sea = QColor(self.gs.db_colors.get('basic_water'))
            self.gs.color_river = QColor(self.gs.db_colors.get('basic_river'))
            self.gs.color_fog_of_war = QColor(self.gs.db_colors.get('fog_of_war'))

            self.gs.color_font_sea = QColor(self.gs.db_colors.get('font_sea'))
            self.gs.color_font_land = QColor(self.gs.db_colors.get('font_land'))

            self.gs.db_color_sets = data.get('color_sets', {})

    def load_general_config(self):
        """Load general configuration from the mod"""
        with open(self.gs.path_db / 'config' / 'config.toml', 'r') as file:
            data = toml.load(file)

            # Font sizes
            self.gs.db_font_sizes = data.get('font_size', {})
            self.gs.font_size_land = self.gs.db_font_sizes.get('land', 9)
            self.gs.font_size_sea = self.gs.db_font_sizes.get('sea', 11)
            self.gs.font_size_debug = self.gs.db_font_sizes.get('debug', 14)

            # Map sizes
            self.gs.db_map_size = data.get('map_size', {})
            self.gs.map_width = self.gs.db_map_size.get('width', 700)
            self.gs.map_height = self.gs.db_map_size.get('height', 300)
            self.gs.rect_size = self.gs.db_map_size.get('rect_size', 24)

            # Z-values
            self.gs.db_z_values = data.get('z_value', {})
            self.gs.z_value_map_tile = self.gs.db_z_values.get('map_tile', 0)
            self.gs.z_value_sea_border = self.gs.db_z_values.get('sea_border', 1)
            self.gs.z_value_coast_border = self.gs.db_z_values.get('coast_border', 2)
            self.gs.z_value_river = self.gs.db_z_values.get('river', 3)
            self.gs.z_value_prov_border = self.gs.db_z_values.get('province_border', 4)
            self.gs.z_value_country_border = self.gs.db_z_values.get('country_border', 5)
            self.gs.z_value_roads = self.gs.db_z_values.get('road', 7)
            self.gs.z_value_city = self.gs.db_z_values.get('city', 8)
            self.gs.z_value_prov_name = self.gs.db_z_values.get('province_name', 9)
            self.gs.z_value_army = self.gs.db_z_values.get('z_value_army', 12)

            # Pen sizes and settings
            self.gs.db_pen_sizes = data.get('pen_size', {})
            self.gs.pen_road_max_size = self.gs.db_font_sizes.get('road_max_size', 32)
            self.gs.pen_border_province.setWidth(self.gs.db_pen_sizes.get("border_land", 2))
            self.gs.pen_border_sea.setWidth(self.gs.db_pen_sizes.get("border_sea", 3))
            self.gs.pen_border_coastal.setWidth(self.gs.db_pen_sizes.get("border_coastal", 4))
            self.gs.pen_border_country.setWidth(self.gs.db_pen_sizes.get("border_country", 5))
            self.gs.pen_road_sea.setWidth(self.gs.db_pen_sizes.get("road_sea", 1))
            self.gs.pen_road_land.setWidth(self.gs.db_pen_sizes.get("road_land", 1))
            self.gs.pen_road_coast.setWidth(self.gs.db_pen_sizes.get("road_coast", 2))
            self.gs.pen_river.setWidth(self.gs.db_pen_sizes.get("river", 7))

            # Update pen colors
            self.gs.pen_border_province.setColor(self.gs.color_border_province)
            self.gs.pen_border_sea.setColor(self.gs.color_border_sea)
            self.gs.pen_border_coastal.setColor(self.gs.color_border_coastal)
            self.gs.pen_border_country.setColor(self.gs.color_border_country)
            self.gs.pen_road_sea.setColor(self.gs.color_road_sea)
            self.gs.pen_road_land.setColor(self.gs.color_road_land)
            self.gs.pen_road_coast.setColor(self.gs.color_road_coast)
            self.gs.pen_river.setColor(self.gs.color_river)

    def load_mod_data(self, progress_callback):
        """
        Load all the mod data files
        Equivalent to map_loader.load_mod()
        """

        print('Load mod details')

        # Import here to avoid circular imports
        from src2.managers.load import map_loader
        from managers.load import map_ref
        from managers.load import map_graphics

        # load colors definitions from format file
        map_ref.load_colors_from_toml()

        # create pixmaps graphics for effects
        map_graphics.create_pixmaps_with_weather_effect()
        map_graphics.create_pixmaps_with_terrain_effect()
        map_graphics.create_pixmaps_with_pattern_effect()

        progress_callback(20)

        # create all graphics from GFX folder
        map_graphics.create_all_images_from_gfx_folder()

        progress_callback(25)

        # create graphics for flags with frame
        map_graphics.prepate_graphics_flags_goods_religion_with_frame()

        # create graphics for autotiles, which are not used now
        map_graphics.load_and_process_autotiles()

        # load PDN and extract to separate files
        map_loader.load_map_pdn_and_extract_to_png_files()

        progress_callback(30)

        # load CSV with province ID vs RGB
        map_loader.load_province_color_mapping()

        # load from image prov id defs, there were extracted from PDN
        # here only load IDs, do not create any provinces yet
        map_loader.load_province_ids_from_image()
        map_loader.load_cities_from_image()

        progress_callback(35)

        # load and process rivers autotiles, which are used
        map_loader.load_rivers_map_from_image()
        map_graphics.load_river_autotiles()

        progress_callback(40)

        # calculate borders between provinces
        map_loader.calculate_borders_map()

        progress_callback(45)

        # calculate larger rectangles to render provinces
        map_loader.calculate_larger_province_rectangles()

        progress_callback(50)

        # calculate river tile ID to render them later
        map_loader.calculate_province_river_values()

        progress_callback(55)

        # dump all colors to single rect for modelers
        map_graphics.create_color_rectangles_image()

        progress_callback(60)

        # create all images for numbers used in game
        map_graphics.make_font_numbers()

        progress_callback(65)

        # load static definitions from yaml
        map_ref.load_techgroup_from_toml()
        map_ref.load_countries_from_toml()
        map_ref.load_terrains_from_toml()
        map_ref.load_cultures_from_toml()
        map_ref.load_religions_from_toml()
        map_ref.load_goods_from_toml()
        map_ref.load_climates_from_toml()
        map_ref.load_continents_from_toml()
        map_ref.load_regions_from_toml()
        map_ref.load_areas_from_toml()
        map_ref.load_cot_colors_from_toml()
        map_ref.load_units_from_toml()
        map_ref.load_regiments_from_toml()
        map_ref.load_units_to_regiments_from_toml()
        map_ref.load_policies_from_toml()
        map_ref.load_buildings_from_toml()
        map_ref.load_battle_formations_from_toml()
        map_ref.load_periods_from_toml()

        progress_callback(70)

        # save mapping between color HEX and province ID to text file
        map_loader.save_province_colors_to_csv()

        # province IDs color created to PNG file
        map_graphics.generate_province_color_id_png()

        progress_callback(75)

        # loads provinces from MAP
        map_loader.load_provinces_from_prov_id_map()

        # loads provinces from CSV file
        map_loader.load_provinces_def_from_toml()

        progress_callback(80)

        # calculate provinces, borders, roads, positions etc..
        map_loader.calculate_province_city_and_names_positions()
        map_loader.calculate_province_neighbours()
        map_loader.calculate_borders_and_roads()

        progress_callback(85)

        # create report if provinces are used inside map
        map_loader.generate_province_usage_report()

        # generate army / navy pix maps and HP for them
        map_graphics.generate_army_pixmaps()
        map_graphics.create_unit_hp_graphics()

        progress_callback(90)

        # this is TEST only
        map_graphics.create_battle_terrain_graphics()

        progress_callback(95)

        # TODO remember about this method

        # map_graphics.create_full_size_map_with_borders(tile = 2, border = 1, include_text=False, output_file='map_provinces_borders_small', use_colors = False)
        # map_graphics.create_full_size_map_with_borders(tile = 6, border = 2, include_text=True, use_colors = True)
        progress_callback(100)

        # these are only debug
        # map_graphics.create_map_image_based_on_attributes_debug()
        progress_callback(110)

    def process_game_logic_before(self):
        """Process game logic before creating graphics"""