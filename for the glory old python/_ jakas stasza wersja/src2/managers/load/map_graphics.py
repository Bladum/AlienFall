from PIL import ImageFont, ImageDraw, Image
from PIL.ImageQt import ImageQt
from PySide6.QtCore import Qt, QSize, QRectF
from PySide6.QtGui import QPixmap, QColor, QPainter, QBrush, QImage, QPen

from core.game_state import GameState
import os

gs = GameState()

def create_unit_hp_graphics():
    print("  Load and split unit hp graphics")
    from PIL import Image

    file_path = gs.path_gfx / 'army' / 'hp.png'
    hp_image = Image.open(file_path)

    hp_width, hp_height = 22, 7
    hp_pieces = []

    for i in range(10):
        piece = hp_image.crop((0, i * hp_height, hp_width, (i + 1) * hp_height)).convert("RGBA")
        hp_pieces.append(piece)

    gs.res_images['hp'] = {i: QPixmap.fromImage(ImageQt(piece)) for i, piece in enumerate(reversed(hp_pieces))}


def create_map_image_based_on_attributes_debug():
    print("  Create terrain map image")
    from PIL import Image

    def create_map_image(attribute, file_name):
        print(f"    Processing map: {attribute} ")
        map_image = Image.new('RGB', (gs.map_width, gs.map_height))
        for y in range(gs.map_height):
            for x in range(gs.map_width):
                province_id = gs.province_id_map[y][x]
                prov = gs.provinces.get(province_id)
                if prov:
                    attr_value = getattr(prov, attribute, None)
                    if attr_value:
                        color = gs.db_colors_color.get(attr_value.color_name)
                        if color:
                            map_image.putpixel((x, y), (color.red(), color.green(), color.blue()))
        output_path = gs.path_map / 'debug' / f'{file_name}.png'
        map_image.save(output_path)

    attributes = ['terrain', 'climate', 'religion', 'goods', 'region', 'area', 'continent', 'culture']
    for attribute in attributes:
        create_map_image(attribute, attribute)


def create_mini_map_image(country_tag=None):
    print("  Create mini map image")
    from PIL import Image

    if country_tag is None:
        map_image = Image.new('RGB', (gs.map_width, gs.map_height))

        for y in range(gs.map_height):
            for x in range(gs.map_width):
                province_id = gs.province_id_map[y][x]
                prov = gs.provinces.get(province_id)

                # Check if this pixel is a river using the river map in game_state
                is_river = gs.river_id_map[y][x] > 0

                if is_river:
                    # Use water color for rivers
                    color = gs.db_colors_color.get('basic_water')
                    if color:
                        map_image.putpixel((x, y), (color.red(), color.green(), color.blue()))
                elif prov:
                    color_name = 'basic_land' if prov.is_land else 'basic_water'
                    color = gs.db_colors_color.get(color_name)
                    if color:
                        map_image.putpixel((x, y), (color.red(), color.green(), color.blue()))

        # Save the basic map to gs.minimap_pixmap
        gs.minimap_pixmap = map_image
    else:
        map_image = gs.minimap_pixmap.copy()

        # Create an overlay image with the same dimensions as the map
        overlay = Image.new('RGBA', map_image.size, (0, 0, 0, 0))

        # Create color for highlighting the country's provinces
        country_color = Image.new('RGBA', (1, 1), (0, 255, 0, 160))

        # Mark country provinces on the overlay
        for y in range(gs.map_height):
            for x in range(gs.map_width):
                province_id = gs.province_id_map[y][x]
                prov = gs.provinces.get(province_id)
                if prov and prov.is_land and prov.country_owner_tag == country_tag:
                    overlay.putpixel((x, y), country_color.getpixel((0, 0)))

        # Composite the overlay onto the map image
        map_image = Image.alpha_composite(map_image.convert('RGBA'), overlay)
        return QPixmap.fromImage(ImageQt(map_image))


def create_all_images_from_gfx_folder():
    print('  Load images from gfx folder')

    gfx_folder = gs.path_gfx

    images_dict = {}
    for root, dirs, files in os.walk(gfx_folder):
        for subdir in dirs:
            subdir_path = os.path.join(root, subdir)
            images_dict[subdir] = {}
            for file in os.listdir(subdir_path):
                if file.endswith('.png'):
                    file_path = os.path.join(subdir_path, file)
                    pixmap = QPixmap(file_path)
                    images_dict[subdir][file] = pixmap

    gs.res_images = images_dict

def generate_army_pixmaps():
    print("  Create army pixmap with color effect")
    input_image_path = gs.path_gfx / 'army' / 'army.png'
    input_image = Image.open(input_image_path).convert('RGBA')  # Load as RGBA

    gs.res_images['army_back'] = {}
    for color_name, color_value in gs.db_colors_color.items():
        if color_name in gs.db_color_sets['army']:
            color = QColor(color_value)
            color_rgb = (color.red(), color.green(), color.blue(), color.alpha())

            # Create a new image with the same size as the input image
            colorized_image = Image.new('RGBA', input_image.size)

            # Iterate over each pixel in the input image
            for y in range(input_image.height):
                for x in range(input_image.width):
                    pixel = input_image.getpixel((x, y))
                    # Apply the color transformation
                    new_pixel = (int(pixel[0] * color_rgb[0] / 255),
                                 int(pixel[1] * color_rgb[1] / 255),
                                 int(pixel[2] * color_rgb[2] / 255),
                                 pixel[3])
                    colorized_image.putpixel((x, y), new_pixel)

            pixmap = QPixmap.fromImage(ImageQt(colorized_image))
            gs.res_images['army_back'][color_name] = pixmap



def prepate_graphics_flags_goods_religion_with_frame():

    print("  Process country flags into frame")
    from PIL import Image

    # Load the frame image
    frame_path = gs.path_gfx / 'city' / 'frame.png'
    frame = Image.open(frame_path).convert("RGBA")

    # Initialize the dictionary to store the images
    def process_images_in_folder(folder_name, output_key):
        folder_path = gs.path_gfx / folder_name
        gs.res_images[output_key] = {}

        for file in os.listdir(folder_path):
            if file.endswith('.png'):
                tag = file.split('.')[0]
                file_path = folder_path / file
                image = Image.open(file_path).convert("RGBA")

                # Create a new image with the same size as the frame
                combined_image = Image.new("RGBA", frame.size, (0, 0, 0, 0))

                # Calculate the position to center the image on the frame
                image_x = (frame.width - image.width) // 2
                image_y = (frame.height - image.height) // 2

                # Paste the image and then the frame over it
                combined_image.paste(image, (image_x, image_y), image)
                combined_image.paste(frame, (0, 0), frame)

                # Convert the combined image to QPixmap
                combined_pixmap = QPixmap.fromImage(ImageQt(combined_image))

                # Store the combined pixmap in the dictionaryF"
                gs.res_images[output_key][tag + '.png'] = combined_pixmap

    # Example usage for flags
    process_images_in_folder('flag', 'flag_frame')
    process_images_in_folder('goods', 'goods_frame')
    process_images_in_folder('religion', 'religion_frame')


def load_and_process_autotiles():
    print('  Load autotiles graphics')

    from PIL import Image

    file_path = gs.path_tiles / 'autotiles.png'

    tiles_names = ['province', 'country', 'coast', 'river', 'sea']

    # Load the tiles.png image
    tiles_image = Image.open(file_path)
    tile_size = 34
    trimmed_tile_size = 32

    # Calculate the number of tiles
    tiles_x = tiles_image.width // tile_size
    tiles_y = 1

    # Function to trim 1 pixel from each side of a tile
    def trim_tile(tile):
        return tile.crop((1, 1, tile.width - 1, tile.height - 1))

    # Function to create autotile set with rotations
    def create_autotile_set(tile):
        autotiles = []
        for i in range(0, 16):
            autotile = Image.new('RGBA', (trimmed_tile_size, trimmed_tile_size))
            if i & 1:  # Right neighbor
                autotile.paste(tile.rotate(0), (0, 0), tile.rotate(0).convert('RGBA'))
            if i & 2:  # top neighbor
                autotile.paste(tile.rotate(-90), (0, 0), tile.rotate(-90).convert('RGBA'))
            if i & 4:  # Left neighbor
                autotile.paste(tile.rotate(-180), (0, 0), tile.rotate(-180).convert('RGBA'))
            if i & 8:  # bottom neighbor
                autotile.paste(tile.rotate(-270), (0, 0), tile.rotate(-270).convert('RGBA'))
            autotiles.append(autotile)
        return autotiles

    # Process each tile
    for x in range(tiles_x):

        # Save each autotile set as a 4x4 array of images
        output_image = Image.new('RGBA', (4 * trimmed_tile_size, 4 * trimmed_tile_size))

        tile = tiles_image.crop((x * tile_size, 0, (x + 1) * tile_size, tile_size))
        trimmed_tile = trim_tile(tile)
        autotile_set = create_autotile_set(trimmed_tile)

        for i, autotile in enumerate(autotile_set):
            row = i // 4
            col = i % 4
            output_image.paste(autotile, (col * trimmed_tile_size, row * trimmed_tile_size))

        output_image.save( gs.path_tiles_auto / f'auto_{tiles_names[x]}.png')


def load_river_autotiles():
    print("  Process rivers autotile")
    from PySide6.QtGui import QPixmap
    TILE_SIZE = gs.rect_size

    file_path = gs.path_tiles_auto / 'auto_river2.png'

    # Load the auto_river.png image
    river_image = QPixmap(str(file_path))

    # Create a list to store the 16 sub-images
    river_tiles = []

    # Split the image into 16 sub-images
    for y in range(4):
        for x in range(4):
            tile = river_image.copy(x * TILE_SIZE, y * TILE_SIZE, TILE_SIZE, TILE_SIZE)
            river_tiles.append(tile)

    gs.res_image_river = river_tiles


def create_color_rectangles_image():
    print('  Dump all colors to single png file')

    # Define image dimensions
    rect_width = 80
    rect_height = 20
    num_colors = len(gs.db_colors_brush)
    image_width = rect_width
    image_height = rect_height * num_colors

    # Create a new image with white background
    image = Image.new('RGB', (image_width, image_height), 'white')
    draw = ImageDraw.Draw(image)

    # Load a font
    font = ImageFont.load_default()

    # Draw each rectangle with the color brush and write the color name
    for i, (name, brush) in enumerate(gs.db_colors_brush.items()):
        y0 = i * rect_height
        y1 = y0 + rect_height

        # Draw the rectangle
        draw.rectangle([0, y0, rect_width, y1], fill=brush.color().name())

        # Calculate text position
        text_bbox = draw.textbbox((0, 0), name, font=font)
        text_width = text_bbox[2] - text_bbox[0]
        text_height = text_bbox[3] - text_bbox[1]
        text_x = (rect_width - text_width) // 2
        text_y = y0 + (rect_height - text_height) // 2

        # Draw the text
        draw.text((text_x, text_y), name, fill='black', font=font)

    # Save the image to a PNG file
    output_path = gs.path_gfx / 'tools' / 'color_rectangles.png'
    image.save(output_path)



def make_font_numbers():
    print("  Generate numbers to png file")

    output_path = gs.path_gfx / "numbers"

    gs.res_images['numbers'] = {}
    gs.res_images['numbers_small_black'] = {}
    gs.res_images['numbers_small_blue'] = {}
    gs.res_images['numbers_small_red'] = {}
    gs.res_images['numbers_small_green'] = {}

    if not os.path.exists(output_path):
        os.makedirs(output_path)

    def create_numbers_small_from_base( color_name ):

        tw, tile_height = 5, 7

        base_image_path = output_path / f"base_small_{color_name}.png"
        base_image = Image.open(base_image_path)

        digits = [base_image.crop((i * tw, 0, (i + 1) * tw, tile_height)) for i in range(10)]

        for number in range(10):
            number_image = Image.new("RGBA", (tw, tile_height ) )  # Transparent background
            number_image.paste(digits[number].convert("RGBA"), (0, 0), digits[number].convert("RGBA"))
            gs.res_images[f'numbers_small_{color_name}'][number] = QPixmap.fromImage(ImageQt(number_image))


    def create_numbers_from_base():
        tw, tile_height = 8, 12

        base_image_path = output_path / "base.png"
        base_image = Image.open(base_image_path)
        digits = [base_image.crop((i * tw, 0, (i + 1) * tw, tile_height)) for i in range(10)]

        for number in range(1000):
            tens = (number // 10) % 10
            units = number % 10
            hundreds = (number // 100) % 10

            number_image = Image.new("RGBA", (tw * 3 + 2, tile_height + 2), (64, 64, 64, 255))  # Transparent background

            if number < 10:
                number_image.paste(digits[units].convert("RGBA"), (tw + 1, 1), digits[units].convert("RGBA"))
            elif number < 100:
                number_image.paste(digits[tens].convert("RGBA"), (tw // 2 + 1, 1), digits[tens].convert("RGBA"))
                number_image.paste(digits[units].convert("RGBA"), (tw * 3 // 2 + 1, 1), digits[units].convert("RGBA"))
            else:
                number_image.paste(digits[hundreds].convert("RGBA"), (1, 1), digits[hundreds].convert("RGBA"))
                number_image.paste(digits[tens].convert("RGBA"), (tw + 1, 1), digits[tens].convert("RGBA"))
                number_image.paste(digits[units].convert("RGBA"), (tw * 2 + 1, 1), digits[units].convert("RGBA"))

            gs.res_images['numbers'][number] = QPixmap.fromImage(ImageQt(number_image))

    create_numbers_from_base()
    create_numbers_small_from_base('black')
    create_numbers_small_from_base('red')
    create_numbers_small_from_base('green')
    create_numbers_small_from_base('blue')

def create_battle_terrain_graphics():
    print("  Create 40x40 pixel graphics for each terrain")
    tile_size = 40

    gs.res_images['battle_terrain'] = {}

    border_color = QColor('#50303030')
    border_pen = QPen(border_color, 1)

    for terrain_name, terrain in gs.db_terrains.items():
        # Create a new image with the terrain color
        terrain_color = gs.db_colors_color[terrain.color_name]
        pixmap = QPixmap(tile_size, tile_size)
        pixmap.fill(terrain_color)

        # Add terrain effect
        if terrain.effect:
            painter = QPainter(pixmap)
            painter.setBrush(gs.db_colors_brush['terrain_' + terrain.tag])
            painter.setPen(Qt.NoPen)
            painter.drawRect(0, 0, tile_size, tile_size)
            painter.end()

        # Add border
        painter = QPainter(pixmap)
        painter.setPen(border_pen)
        painter.drawRect(0, 0, tile_size, tile_size)
        painter.end()

        # Save the pixmap
        output_path = gs.path_gfx / 'textures' / f'{terrain_name}.png'
        pixmap.save( str(output_path) )
        gs.res_images['battle_terrain'][terrain_name] = pixmap



def create_pixmaps_with_weather_effect():
    print("  Create all graphics for textures with weather effects")
    weather_effects = gs.db_color_sets['weather']

    output_dir = gs.path_gfx / 'textures'

    if not os.path.exists(output_dir):
        os.makedirs(output_dir)

    for effect in weather_effects:
        effect_image_path = gs.path_gfx / 'weather' / f'{effect}.png'
        effect_image = QPixmap(str(effect_image_path))
        grid_size = effect_image.size()

        pixmap = QPixmap(grid_size)
        pixmap.fill(Qt.transparent)  # Ensure the pixmap is transparent
        painter = QPainter(pixmap)
        painter.setCompositionMode(QPainter.CompositionMode_SourceOver)  # Ensure transparency and layering
        painter.drawPixmap(0, 0, effect_image)
        painter.end()

        file_name = f"effect_{effect}"
        gs.db_colors_brush[file_name] = QBrush(pixmap)


def create_pixmaps_with_terrain_effect():
    print("  Create all graphics for textures with terrain effects")
    terrains_effects = gs.db_color_sets['terrains']

    output_dir = gs.path_gfx / 'textures'

    if not os.path.exists(output_dir):
        os.makedirs(output_dir)

    for effect in terrains_effects:
        effect_image_path = gs.path_gfx / 'terrains' / f'{effect}.png'
        effect_image = QPixmap(str(effect_image_path))
        grid_size = effect_image.size()

        pixmap = QPixmap(grid_size)
        pixmap.fill(Qt.transparent)  # Ensure the pixmap is transparent
        painter = QPainter(pixmap)
        painter.setCompositionMode(QPainter.CompositionMode_SourceOver)  # Ensure transparency and layering
        painter.drawPixmap(0, 0, effect_image)
        painter.end()

        file_name = f"terrain_{effect}"
        gs.db_colors_brush[file_name] = QBrush(pixmap)


def create_pixmaps_with_pattern_effect():
    print("  Create all graphics for textures with pattern effects")
    db_color_sets = gs.db_color_sets['pattern']
    grid_size = gs.rect_size
    output_dir = gs.path_gfx / 'textures'

    if not os.path.exists(output_dir):
        os.makedirs(output_dir)

    for color_name in db_color_sets:
        color_value = gs.db_colors_color.get(color_name)
        if color_value:
            pixmap = QPixmap(grid_size, grid_size)
            pixmap.fill(Qt.transparent)
            painter = QPainter(pixmap)
            painter.setBrush(color_value)
            painter.setPen(Qt.NoPen)
            painter.drawRect(grid_size // 2, 0, grid_size // 2, grid_size)
            painter.end()

            file_name = f"{color_name}_half"
            gs.db_colors_brush[file_name] = QBrush(pixmap)

def create_full_size_map_with_borders( tile = 5,
                                       border = 1,
                                       include_text = True,
                                       output_file = 'map_provinces_borders',
                                       use_colors = False):
    print("  Create large map with borders and terrain")
    tile_size = tile
    border_width = border
    output = QImage(QSize(gs.map_width * tile_size, gs.map_height * tile_size), QImage.Format_ARGB32)
    output.fill(Qt.black)

    painter = QPainter(output)
    pen = QPen(QColor(Qt.black), border_width)
    painter.setPen(pen)

    if use_colors:
        pen_sea =  QPen(gs.color_border_sea, border_width)
        pen_land = QPen(gs.color_border_province, border_width)
        pen_coast = QPen(gs.color_border_coastal, border_width)
    else:
        pen_sea = QPen(Qt.black, border_width)
        pen_land = QPen(Qt.black, border_width)
        pen_coast = QPen(Qt.black, border_width)

    # Draw the grid and borders
    for y in range(gs.map_height):
        for x in range(gs.map_width):
            province_id = gs.province_id_map[y][x]
            prov = gs.provinces.get(province_id)
            if prov:

                if use_colors:
                    if prov.terrain:
                        color_name = prov.terrain.color_name
                    else:
                        color_name = 'teal'
                else:
                    color_name = 'basic_land' if prov.is_land else 'basic_water'
                color = gs.db_colors_color.get(color_name)

                if color:
                    # Draw tile
                    rect_x = x * tile_size
                    rect_y = y * tile_size
                    painter.fillRect(rect_x, rect_y, tile_size, tile_size, color) # removed fillRect

                rect_x = x * tile_size
                rect_y = y * tile_size

                # Check neighbors and draw borders
                def draw_border(painter, prov, neighbor_prov, rx, ry, dx, dy):
                    if prov.is_land and neighbor_prov.is_land:
                        painter.setPen( pen_land )
                    elif not prov.is_land and not neighbor_prov.is_land:
                        painter.setPen( pen_sea )
                    else:
                        painter.setPen( pen_coast )
                    painter.drawLine(rx, ry, rx + dx, ry + dy)

                if x > 0:
                    other_prov = gs.province_id_map[y][x - 1]
                    other_prov = gs.provinces.get(other_prov)
                    if other_prov and province_id != other_prov.province_id:
                            draw_border(painter, prov,other_prov , rect_x, rect_y , 0, tile_size)

                if y > 0:
                    other_prov = gs.province_id_map[y - 1][x]
                    other_prov = gs.provinces.get(other_prov)
                    if other_prov and province_id != other_prov.province_id:
                        draw_border(painter, prov, other_prov, rect_x , rect_y, tile_size, 0)

                if x < gs.map_width - 1:
                    other_prov = gs.province_id_map[y][x + 1]
                    other_prov = gs.provinces.get(other_prov)
                    if other_prov and province_id != other_prov.province_id:
                        draw_border(painter, prov, other_prov, rect_x + tile_size, rect_y,  tile_size, tile_size )

                if y < gs.map_height - 1:
                    other_prov = gs.province_id_map[y + 1][x]
                    other_prov = gs.provinces.get(other_prov)
                    if other_prov and province_id != other_prov.province_id:
                        draw_border(painter, prov, other_prov, rect_x , rect_y + tile_size, tile_size, tile_size)

    if include_text:
        # Draw city names
        for y in range(gs.map_height):
            for x in range(gs.map_width):
                province_id = gs.province_id_map[y][x]
                prov = gs.provinces.get(province_id)
                if prov:
                    city_x, city_y = prov.city_position
                    text = f"{prov.province_id:04}"
                    text_x = city_x * tile_size
                    text_y = city_y * tile_size

                    if prov.is_land:
                        db_source = gs.res_images['numbers_small_red']
                    else:
                        db_source =  gs.res_images['numbers_small_blue']

                    for i, char in enumerate(text):
                        digit = int(char)
                        digit_pixmap = db_source[digit]
                        painter.drawPixmap(text_x + i * 5 - 8, text_y - 3, digit_pixmap)

    painter.end()

    output_path = str( gs.path_map / 'other' / f'{output_file}.png' )
    output.save(output_path)
    print(f"Borders generated and saved to {output_path}")


def generate_province_color_id_png():
    print("  Create province ID with color rectangle and save to PNG")
    grid_width = 50
    grid_height = 80
    rect_width = 60
    rect_height = 40
    font_size = 12

    image_width = grid_width * rect_width
    image_height = grid_height * rect_height

    image = QImage(QSize(image_width, image_height), QImage.Format_ARGB32)
    image.fill(Qt.white)

    painter = QPainter(image)
    font = painter.font()
    font.setPointSize(font_size)
    painter.setFont(font)

    for i, (color_hex, province_id) in enumerate(gs.province_mapping_color_hex.items()):
        x = (i % grid_width) * rect_width
        y = (i // grid_width) * rect_height

        color = QColor(color_hex)
        painter.setBrush(color)
        painter.setPen(Qt.NoPen)
        painter.drawRect(x, y, rect_width, rect_height)

        if color.lightness() > 128:
            text_color = Qt.black
        else:
            text_color = Qt.white

        painter.setPen(text_color)
        painter.drawText(QRectF(x, y, rect_width, rect_height), Qt.AlignCenter, str(province_id))

    painter.end()
    path = str( gs.path_gfx / 'tools' /  'province_id_rect.png')
    image.save( path )
