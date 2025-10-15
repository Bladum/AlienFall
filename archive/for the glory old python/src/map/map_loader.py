
'''

MAP LOADER

Loads all resources files and process them

'''

from PIL import Image

from battle.battle import BattleField
from src.db import TDB

db = TDB()
from map import map_yaml, map_graphics


def load_mod():
    print('Load mod details')

    map_yaml.load_colors_from_yaml()
    map_yaml.load_color_sets_from_yaml()

    map_graphics.create_pixmaps_with_weather_effect()
    map_graphics.create_pixmaps_with_terrain_effect()
    map_graphics.create_pixmaps_with_pattern_effect()

    map_graphics.create_all_images_from_gfx_folder()
    map_graphics.prepate_graphics_flags_goods_religion_with_frame()

    load_map_pdn_and_extract_to_png_files()
    map_graphics.load_and_process_autotiles()

    load_rivers_map_from_image()
    map_graphics.load_river_autotiles()

    # load CSV with province ID vs RGB
    load_province_color_mapping()

    # load from image prov id defs
    load_province_ids_from_image()
    load_cities_from_image()

    calculate_borders_map()
    calculate_larger_province_rectangles()
    calculate_province_river_values()

    map_graphics.create_color_rectangles_image()
    map_graphics.make_font_numbers()

    map_yaml.load_countries_from_yaml()
    map_yaml.load_terrains_from_yaml()
    map_yaml.load_cultures_from_yaml()
    map_yaml.load_religions_from_yaml()
    map_yaml.load_goods_from_yaml()
    map_yaml.load_climates_from_yaml()
    map_yaml.load_continents_from_yaml()
    map_yaml.load_regions_from_yaml()
    map_yaml.load_areas_from_yaml()
    map_yaml.load_cot_colors_from_yaml()
    map_yaml.load_units_from_yaml()
    map_yaml.load_buildings_from_yaml()

    save_province_colors_to_csv()

    load_provinces_from_prov_id_map()
    load_provinces_def_from_csv()

    calculate_province_city_and_names_positions()
    calculate_province_neighbours()
    calculate_borders_and_roads()

    map_graphics.generate_army_pixmaps()
    map_graphics.create_unit_hp_graphics()
    map_graphics.create_battle_terrain_graphics()
    create_random_battle_map()

def load_province_color_mapping():
    import csv
    print("  Load province color definition")
    csv_path = db.path_map / 'prov_mapping.txt'

    # Load the province colors from the CSV file
    province_colors = {}
    province_colors_hex = {}
    with open(csv_path, newline='') as csvfile:
        reader = csv.reader(csvfile)
        next(reader)  # Skip the header row
        for row in reader:
            province_id, r, g, b, h, c = row
            province_colors[(int(r), int(g), int(b))] = int(province_id)
            province_colors_hex[ h ] = int(province_id)

    db.province_mapping_color = province_colors
    db.province_mapping_color_hex = province_colors_hex

def load_province_ids_from_image( ):
    print("  Load province id map")

    from PIL import Image

    prov_id_map_path = db.path_map_province
    prov_id_defs = db.province_mapping_color

    # Load the image
    image = Image.open(prov_id_map_path)
    pixels = image.load()

    # Create a 2D array of province IDs
    width, height = image.size

    db.map_width = width
    db.map_height = height

    province_ids = [[0 for _ in range(db.map_width)] for _ in range(db.map_height)]
    province_border_map = {}
    province_tile_list = {}

    # find which tiles to which province ID
    for y in range(db.map_height):
        for x in range(db.map_width):
            r, g, b = pixels[x, y][:3]  # Get RGB values

            # set this tile has province ID
            province_id = prov_id_defs.get((r, g, b), 0)  # Default to 0 if not found
            if province_id == 0 and (r,g,b) != (0,0,0):
                print("Province not found", r, g, b)
            province_ids[y][x] = province_id

            # set province ID has these tiles
            if province_id not in province_tile_list.keys():
                province_tile_list[province_id] = []
                province_border_map[ province_id ] = {}
            province_tile_list[ province_id ].append( (x, y) )

    db.province_tile_list = province_tile_list
    db.province_id_map = province_ids

def calculate_larger_province_rectangles():
    print("  Decompose province rectangles")

    def find_largest_rectangle(grid, start_row, start_col, province_id):
        max_row = len(grid)
        max_col = len(grid[0])
        end_row = start_row
        end_col = start_col

        # Find the maximum width
        while end_col < max_col and grid[start_row][end_col] == province_id:
            end_col += 1

        # Find the maximum height
        for row in range(start_row, max_row):
            for col in range(start_col, end_col):
                if grid[row][col] != province_id:
                    end_row = row
                    break
            else:
                continue
            break
        else:
            end_row = max_row

        return end_row, end_col

    def cover_rectangle(grid, start_row, start_col, end_row, end_col):
        for row in range(start_row, end_row):
            for col in range(start_col, end_col):
                grid[row][col] = -1  # Mark as processed

    province_id_map = [row[:] for row in db.province_id_map]  # Create a copy of the province_id_map
    rectangles = {}

    for row in range(len(province_id_map)):
        for col in range(len(province_id_map[0])):
            province_id = province_id_map[row][col]
            if province_id > 0:
                end_row, end_col = find_largest_rectangle(province_id_map, row, col, province_id)
                cover_rectangle(province_id_map, row, col, end_row, end_col)
                rectangles.setdefault(province_id, []).append((col, row, end_col, end_row))

    db.province_rectangles = rectangles

def scale_map_pdn():
    print("  Scale map3.pdn to new dimensions")

    import pypdn
    from PIL import Image

    pdn_file_path = db.path_map / 'map3.pdn'
    pdn_image = pypdn.read(pdn_file_path)

    new_width, new_height = 1050, 450
    old_width, old_height = 875, 375

    scaled_layers = []

    for layer in pdn_image.layers:
        layer_name = layer.name
        layer_image = Image.fromarray(layer.image)

        if layer_name == 'provinces':
            scaled_image = layer_image.resize((new_width, new_height), Image.NEAREST)
        else:
            scaled_image = Image.new("RGBA", (new_width, new_height))
            for y in range(old_height):
                for x in range(old_width):
                    pixel = layer_image.getpixel((x, y))
                    new_x = int(x * new_width / old_width)
                    new_y = int(y * new_height / old_height)
                    scaled_image.putpixel((new_x, new_y), pixel)

        scaled_layers.append((layer_name, scaled_image))

    for layer_name, scaled_image in scaled_layers:
        scaled_image.save(db.path_map / f'scaled_{layer_name}.png')

def calculate_borders_map():
    print("  Calculate border per province")

    RECT_SIZE = db.rect_size
    province_ids = db.province_id_map

    width = db.map_width
    height = db.map_height

    province_border_map = {}

    # find borders
    for y in range(height):
        for x in range(width):
            current_province = province_ids[y][x]
            if current_province == 0:
                continue
            neighbors = [
                ((x, y), (x + 1, y)),  # Right
                ((x, y), (x, y + 1)),  # Down
            ]
            for (sx, sy), (ex, ey) in neighbors:
                if 0 <= ex < width and 0 <= ey < height:
                    neighbor_province = province_ids[ey][ex]
                    if neighbor_province == 0:
                        continue
                    if neighbor_province != current_province:
                        start = (sx * RECT_SIZE + RECT_SIZE, sy * RECT_SIZE + RECT_SIZE)
                        end = (ex * RECT_SIZE, ey * RECT_SIZE)
                        if current_province not in province_border_map:
                            province_border_map[current_province] = {}
                        province_border_map[current_province].setdefault(neighbor_province, []).append((start, end))

            # Check left neighbor
            if x > 0 and province_ids[y][x - 1] != current_province:
                if province_ids[y][x - 1] > 0:
                    start = (x * RECT_SIZE, y * RECT_SIZE + RECT_SIZE)
                    end = (x * RECT_SIZE, y * RECT_SIZE)
                    neighbor_province = province_ids[y][x - 1]
                    if current_province not in province_border_map:
                        province_border_map[current_province] = {}
                    province_border_map[current_province].setdefault(neighbor_province, []).append((start, end))

            # Check up neighbor
            if y > 0 and province_ids[y - 1][x] != current_province:
                if province_ids[y - 1][x] > 0:
                    start = (x * RECT_SIZE + RECT_SIZE, y * RECT_SIZE)
                    end = (x * RECT_SIZE, y * RECT_SIZE)
                    neighbor_province = province_ids[y - 1][x]
                    if current_province not in province_border_map:
                        province_border_map[current_province] = {}
                    province_border_map[current_province].setdefault(neighbor_province, []).append((start, end))

    db.province_border_map = province_border_map

def load_cities_from_image():
    print("  Load city id map")
    from PIL import Image

    CAPITAL_LAND = (255,0,255)
    NAME_LOCATION = (0,255,0)
    CAPITAL_SEA = (255,255,255)

    capital_map_path = db.path_map_capital
    province_id_map = db.province_id_map

    # Load the image
    image = Image.open(capital_map_path)
    pixels = image.load()

    # Create a 2D array of province IDs
    height, width = db.map_height, db.map_width
    city_id_map = [[0 for _ in range(width)] for _ in range(height)]
    province_name_map = [[0 for _ in range(width)] for _ in range(height)]

    for y in range(height):
        for x in range(width):
            r, g, b = pixels[x, y][:3]  # Get RGB values
            if (r, g, b) in [ CAPITAL_LAND, CAPITAL_SEA ]:
                city_id_map[y][x] = province_id_map[y][x]
            if (r,g,b) == NAME_LOCATION:
                province_name_map[y][x] = province_id_map[y][x]

    db.city_id_map = city_id_map
    db.name_id_map = province_name_map

def load_rivers_map_from_image():

    print("  Load rivers from image")
    from PIL import Image

    RIVER = (0,0,255)
    SEA = (0,255,0)
    LAND = (255, 255, 255)
    STRAIT = (255,0,0)

    river_map_path = db.path_map_river

    # Load the image
    image = Image.open(river_map_path)
    pixels = image.load()

    # Create a 2D array of province IDs
    height, width = db.map_height, db.map_width
    rivers_id_map = [[0 for _ in range(width)] for _ in range(height)]

    all_types = [RIVER, SEA]

    for y in range(height):
        for x in range(width):
            r, g, b = pixels[x, y][:3]  # Get RGB values
            rgb = (r, g, b)
            if  rgb == RIVER :
                value = 0
                # Check neighbors
                if x < width - 1 and pixels[x + 1, y][:3] in all_types:  # Right
                    value += 1
                if y < height - 1 and pixels[x, y + 1][:3] in all_types:  # Bottom
                    value += 2
                if x > 0 and pixels[x - 1, y][:3] in all_types:  # Left
                    value += 4
                if y > 0 and pixels[x, y - 1][:3] in all_types:  # Up
                    value += 8
                rivers_id_map[y][x] = value
            elif rgb == SEA:
                continue
            else:
                continue

    db.river_id_map = rivers_id_map


def calculate_province_river_values():
    print("  Calculate province river values")
    province_river_values = {}

    for y, row in enumerate(db.province_id_map):
        for x, province_id in enumerate(row):
            if province_id not in province_river_values:
                province_river_values[province_id] = set()
            river_value = db.river_id_map[y][x]
            if river_value > 0:
                province_river_values[province_id].add((x, y, river_value))

    db.province_river_tiles_list = province_river_values

def load_map_pdn_and_extract_to_png_files():

    print("  Convert map PDN to PNG files")

    import pypdn

    pdn_file_path = db.path_map_pdn

    # Open the .pdn file
    pdn_image = pypdn.read(pdn_file_path)

    # Accessing and saving each layer as a separate PNG file
    for i, layer in enumerate(pdn_image.layers):
        layer_name = layer.name
        layer_image = Image.fromarray(layer.image)
        layer_image.save( db.path_map / f'map_{layer_name}.png')

def dump_all_map_data_to_files():
    import csv
    print("  Dump all map data to text files")
    data_maps = {
        'province_id_map': db.province_id_map,
        'city_id_map': db.city_id_map,
        'province_name_map': db.name_id_map,
        'province_river_map': db.river_id_map,
        'province_neighbours_list': db.province_neighbors_list,
        'province_mapping_color': db.province_mapping_color,
        'province_border_map': db.province_border_map
    }

    for map_name, data in data_maps.items():
        with open(db.path_mod_duck / f'{map_name}.csv', 'w', newline='') as file:
            writer = csv.writer(file)
            print("  Saving", map_name)
            if isinstance(data, list):
                writer.writerows(data)
            elif isinstance(data, dict):
                for key, value in data.items():
                    writer.writerow([key, value])


def create_random_battle_map():
    for index in range(0, 10):
        aaa  = BattleField('forest')
        aaa.save_to_png(index)


def create_province_color_mapping():
    colors = {}
    used_colors = set()

    def eu4_color(province_id):
        r = int(province_id * 23.123) % 250  # Full red
        g = int(province_id * 47.456) % 250  # Full green
        b = int(province_id * 71.789) % 250  # Less blue
        return r, g, b

    for province_id in range(1, 4000):
        r, g, b = eu4_color(province_id)
        color = (r, g, b)
        if color not in used_colors:
            used_colors.add(color)
            colors[province_id] = color
        else:
            print("Color province mapping repeated", color)
    return colors


def save_province_colors_to_csv():
    import csv
    print( "  Save province color mapping to CSV")

    def rgb_to_hex(r, g, b):
        return f"#{r:02x}{g:02x}{b:02x}"

    rows = len(db.province_id_map)
    cols = len(db.province_id_map[0])

    colors = create_province_color_mapping()
    province_size = {}

    for row in range(rows):
        for col in range(cols):
            prov_id = db.province_id_map[row][col]
            if prov_id in province_size.keys():
                province_size[prov_id] += 1
            else:
                province_size[prov_id] = 1

    pathka = db.path_map / 'prov_mapping.txt'

    with open( str(pathka), mode='w', newline='') as file:
        writer = csv.writer(file)
        writer.writerow(["ID", "R", "G", "B", "hex", "count"])

        for province_id, (r, g, b) in colors.items():
            hex_color = rgb_to_hex(r, g, b)
            cell_count = province_size.get(province_id, 0)
            writer.writerow([f"{province_id:04}", f"{r:03}", f"{g:03}", f"{b:03}", hex_color, f"{cell_count:04}"])



def load_provinces_from_prov_id_map():
    print("  Load provinces from prov id map 2D")
    unique_ids = set()
    for row in  db.province_id_map:
        unique_ids.update(row)

    for province_id in unique_ids:
        prov_data = {
            'ID': province_id,
            'name': 'PROVINCE NAME'
        }
        db.provinces_data_dict[ province_id ] = prov_data


def load_provinces_def_from_csv():
    print("  Load provinces definitions from csv")
    from items.item_province import ProvinceItem
    import csv

    provinces = {}

    with open(db.path_db_provinces_csv, 'r') as file:
        reader = csv.DictReader(file)
        for row_data in reader:
            row_data['id'] = row_data['\ufeffid']
            prov_id = int(row_data['id'])
            terrain = row_data['terrain']
            if prov_id in db.provinces_data_dict.keys():
                row_data['is_land'] = False if terrain in ['sea', 'river', 'lake'] else True
                P = ProvinceItem(row_data)
                provinces[P.province_id] = P

    # setup global lists of who owns what
    for key, val in provinces.items():
        db.country_province_owner_dict[key] = None
        db.country_province_occupant_dict[key] = None

    db.provinces = provinces


def calculate_province_city_and_names_positions():
    print("  Calculate position of province city and name")
    map_data =  db.city_id_map
    db_provs = db.provinces

    rows = len(map_data)
    cols = len(map_data[0]) if rows > 0 else 0

    for row in range(rows):
        for col in range(cols):
            province_id = map_data[row][col]
            if province_id:
                if province_id in db_provs.keys():
                    prov = db_provs.get(province_id, None)
                    if prov:
                        prov.city_position = (col, row)

    map_data = db.name_id_map

    for key, prov in db_provs.items():
        prov.name_text_position = []

    for row in range(rows):
        for col in range(cols):
            province_id = map_data[row][col]
            if province_id:
                if province_id in db_provs.keys():
                    prov = db_provs.get(province_id, None)
                    if prov:
                        prov.name_text_position.append( (col, row) )
                        if len( prov.name_text_position ) > 2:
                            print(" ERROR, province has more then 2 name points", prov.province_id)


def calculate_province_neighbours():
    print("  Calculate provinces neighbours")
    map_data = db.province_id_map

    db_provs = db.provinces

    rows = len(map_data)
    cols = len(map_data[0]) if rows > 0 else 0

    def get_neighbors(data, r, c):
        neighs = []
        if r > 0:
            neighs.append((r - 1, c, data[r - 1][c]))
        if r < len(data) - 1:
            neighs.append((r + 1, c, data[r + 1][c]))
        if c > 0:
            neighs.append((r, c - 1, data[r][c - 1]))
        if c < len(data[0]) - 1:
            neighs.append((r, c + 1, data[r][c + 1]))
        return neighs

    province_neighbors = {}

    for row in range(rows):
        for col in range(cols):
            province_id = map_data[row][col]
            if province_id in db_provs:
                neighbors = get_neighbors(map_data, row, col)
                for neighbor_row, neighbor_col, neighbor_id in neighbors:
                    if neighbor_id != province_id:
                        if neighbor_id > 0:
                            province_neighbors.setdefault(province_id, set()).add(neighbor_id)

    province_neighbors_list = {prov_id: ';'.join(map(str, neighbors)) for prov_id, neighbors in
                               province_neighbors.items()}
    db.province_neighbors = province_neighbors
    db.province_neighbors_list = province_neighbors_list


def calculate_borders_and_roads():

    print("  Calculate boards and roads")
    province_neighbors = db.province_neighbors
    provinces = db.provinces

    def calculate_distance(row1, col1, row2, col2):
        return int(((row1 - row2) ** 2 + (col1 - col2) ** 2) ** 0.5)

    # Calculate distance between city positions of neighboring provinces
    province_neighbors_dist = {}

    for province_id, neighbors in province_neighbors.items():
        for neighbor_id in neighbors:

            if province_id in provinces.keys() and neighbor_id in provinces.keys():
                city_pos1 = provinces.get(province_id).city_position
                city_pos2 = provinces.get(neighbor_id).city_position

                if city_pos1 and city_pos2:
                    distance = calculate_distance(city_pos1[1], city_pos1[0], city_pos2[1], city_pos2[0])
                    province_neighbors_dist[(province_id, neighbor_id)] = distance
                    province_neighbors_dist[(neighbor_id, province_id)] = distance
            else:
                print("ERROR, no city found", province_id, neighbor_id)

    db.province_neighbours_distance = province_neighbors_dist
