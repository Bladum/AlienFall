
'''

MAP LOADER

Loads all resources files and process them

'''
import toml
from PIL import Image

from core.game_state import GameState
gs = GameState()

def load_province_color_mapping():
    import csv
    print("  Load province color definition")
    csv_path = gs.path_map / 'prov_mapping.txt'

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

    gs.province_mapping_color = province_colors
    gs.province_mapping_color_hex = province_colors_hex

def load_province_ids_from_image( ):
    print("  Load province id map")

    from PIL import Image

    prov_id_map_path = gs.path_map_province
    prov_id_defs = gs.province_mapping_color

    # Load the image
    image = Image.open(prov_id_map_path)
    pixels = image.load()

    # Create a 2D array of province IDs
    width, height = image.size

    gs.map_width = width
    gs.map_height = height

    province_ids = [[0 for _ in range(gs.map_width)] for _ in range(gs.map_height)]
    province_border_map = {}
    province_tile_list = {}

    # find which tiles to which province ID
    for y in range(gs.map_height):
        for x in range(gs.map_width):
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

    gs.province_tile_list = province_tile_list
    gs.province_id_map = province_ids

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

    province_id_map = [row[:] for row in gs.province_id_map]  # Create a copy of the province_id_map
    rectangles = {}

    for row in range(len(province_id_map)):
        for col in range(len(province_id_map[0])):
            province_id = province_id_map[row][col]
            if province_id > 0:
                end_row, end_col = find_largest_rectangle(province_id_map, row, col, province_id)
                cover_rectangle(province_id_map, row, col, end_row, end_col)
                rectangles.setdefault(province_id, []).append((col, row, end_col, end_row))

    gs.province_rectangles = rectangles

def scale_map_pdn():
    print("  Scale map3.pdn to new dimensions")

    import pypdn
    from PIL import Image

    pdn_file_path = gs.path_map / 'map3.pdn'
    pdn_image = pypdn.read(pdn_file_path)

    new_width, new_height = 1200, 500
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
        scaled_image.save(gs.path_map / f'scaled_{layer_name}.png')

def calculate_borders_map():
    print("  Calculate border per province")

    RECT_SIZE = gs.rect_size
    province_ids = gs.province_id_map

    width = gs.map_width
    height = gs.map_height

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

    gs.province_border_map = province_border_map

def load_cities_from_image():
    print("  Load city id map")
    from PIL import Image

    CAPITAL_LAND = (255,0,255)
    NAME_LOCATION = (0,255,0)
    CAPITAL_SEA = (255,255,255)

    capital_map_path = gs.path_map_capital
    province_id_map = gs.province_id_map

    # Load the image
    image = Image.open(capital_map_path)
    pixels = image.load()

    # Create a 2D array of province IDs
    height, width = gs.map_height, gs.map_width
    city_id_map = [[0 for _ in range(width)] for _ in range(height)]
    province_name_map = [[0 for _ in range(width)] for _ in range(height)]

    for y in range(height):
        for x in range(width):
            r, g, b = pixels[x, y][:3]  # Get RGB values
            if (r, g, b) in [ CAPITAL_LAND, CAPITAL_SEA ]:
                city_id_map[y][x] = province_id_map[y][x]
            if (r,g,b) == NAME_LOCATION:
                province_name_map[y][x] = province_id_map[y][x]

    gs.city_id_map = city_id_map
    gs.name_id_map = province_name_map

def load_rivers_map_from_image():

    print("  Load rivers from image")
    from PIL import Image

    RIVER = (0,0,255)
    SEA = (0,255,0)
    LAND = (255, 255, 255)
    STRAIT = (255,0,0)

    river_map_path = gs.path_map_river

    # Load the image
    image = Image.open(river_map_path)
    pixels = image.load()

    # Create a 2D array of province IDs
    height, width = gs.map_height, gs.map_width
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

    gs.river_id_map = rivers_id_map


def calculate_province_river_values():
    print("  Calculate province river values")
    province_river_values = {}

    for y, row in enumerate(gs.province_id_map):
        for x, province_id in enumerate(row):
            if province_id not in province_river_values:
                province_river_values[province_id] = set()
            river_value = gs.river_id_map[y][x]
            if river_value > 0:
                province_river_values[province_id].add((x, y, river_value))

    gs.province_river_tiles_list = province_river_values

def load_map_pdn_and_extract_to_png_files():

    print("  Convert map PDN to PNG files")

    import pypdn

    pdn_file_path = gs.path_map_pdn

    # Open the .pdn file
    pdn_image = pypdn.read(pdn_file_path)

    # Accessing and saving each layer as a separate PNG file
    for i, layer in enumerate(pdn_image.layers):
        layer_name = layer.name
        layer_image = Image.fromarray(layer.image)
        layer_image.save( gs.path_map / 'layers' /  f'map_{layer_name}.png')

def dump_all_map_data_to_files():
    import csv
    print("  Dump all map data to text files")
    data_maps = {
        'province_id_map': gs.province_id_map,
        'city_id_map': gs.city_id_map,
        'province_name_map': gs.name_id_map,
        'province_river_map': gs.river_id_map,
        'province_neighbours_list': gs.province_neighbors_list,
        'province_mapping_color': gs.province_mapping_color,
        'province_border_map': gs.province_border_map
    }

    for map_name, data in data_maps.items():
        with open(gs.path_mod_duck / f'{map_name}.csv', 'w', newline='') as file:
            writer = csv.writer(file)
            print("  Saving", map_name)
            if isinstance(data, list):
                writer.writerows(data)
            elif isinstance(data, dict):
                for key, value in data.items():
                    writer.writerow([key, value])


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

    rows = len(gs.province_id_map)
    cols = len(gs.province_id_map[0])

    colors = create_province_color_mapping()
    province_size = {}

    for row in range(rows):
        for col in range(cols):
            prov_id = gs.province_id_map[row][col]
            if prov_id in province_size.keys():
                province_size[prov_id] += 1
            else:
                province_size[prov_id] = 1

    pathka = gs.path_map / 'prov_mapping.txt'

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
    for row in  gs.province_id_map:
        unique_ids.update(row)

    for province_id in unique_ids:
        prov_data = {
            'ID': province_id,
            'name': 'PROVINCE NAME'
        }
        gs.provinces_data_dict[ province_id ] = prov_data
    print("    Total provinces loaded from ID MAP", len( gs.provinces_data_dict.keys()))

def load_provinces_def_from_toml():
    print("  Load provinces definitions from toml")
    provinces = {}
    from object.province import Province

    with open(gs.path_db_provinces_toml, 'r', encoding='utf-8') as file:
        prov_data = toml.load(file)

    for key, row_data in prov_data.items():
        prov_id = int(key)
        row_data['id'] = prov_id
        terrain = row_data['terrain']
        row_data['is_land'] = False if terrain in ['sea', 'ocean', 'lake'] else True

        if prov_id in gs.provinces_data_dict.keys():
            P = Province(row_data)
            provinces[P.province_id] = P

    # setup global lists of who owns what
    for key, val in provinces.items():
        gs.country_province_owner_dict[key] = None
        gs.country_province_occupant_dict[key] = None

    gs.provinces = provinces
    print("    Total provinces loaded from TOML", len(gs.provinces.keys()))

def calculate_province_city_and_names_positions():
    print("  Calculate position of province city and name")
    map_data =  gs.city_id_map
    db_provs = gs.provinces

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

    map_data = gs.name_id_map

    for key, prov in db_provs.items():
        if prov:
            prov.name_text_position = []

    for row in range(rows):
        for col in range(cols):
            province_id = map_data[row][col]
            if province_id:
                if province_id in db_provs.keys():
                    prov = db_provs.get(province_id, None)
                    if prov :
                        prov.name_text_position.append( (col, row) )
                        if len( prov.name_text_position ) > 2:
                            print(" ERROR, province has more then 2 name points", prov.province_id)


def calculate_province_neighbours():
    print("  Calculate provinces neighbours")
    map_data = gs.province_id_map

    db_provs = gs.provinces

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
    gs.province_neighbors = province_neighbors
    gs.province_neighbors_list = province_neighbors_list


def calculate_borders_and_roads():

    print("  Calculate boards and roads")
    province_neighbors = gs.province_neighbors
    provinces = gs.provinces

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

    gs.province_neighbours_distance = province_neighbors_dist

def generate_province_usage_report( ):
    print("  Create province usage report saved to province_usage_report.csv")

    used_province_ids = set()

    # Scan the map for used province IDs
    for x in range(gs.map_width):
        for y in range(gs.map_height):
            province_id = gs.province_id_map[y][x]
            used_province_ids.add(str(province_id).zfill(4))

    import csv

    # Generate the report
    province_usage = {}
    for i in range(0, 4001):
        province_id_str = str(i).zfill(4)
        if province_id_str in used_province_ids:
            province_usage[i] = "Used"
        else:
            province_usage[i] = "Not Used"

    # Sort the data by province ID
    sorted_province_usage = dict(sorted(province_usage.items()))

    # Save the report to a CSV file
    with open( str( gs.path_map / 'other' /  'province_usage_report.csv' ), 'w', newline='') as csvfile:
        csv_writer = csv.writer(csvfile)

        # Write header
        csv_writer.writerow(['Province ID', 'Status'])

        # Write data
        for province_id, status in sorted_province_usage.items():
            csv_writer.writerow([province_id, status])

