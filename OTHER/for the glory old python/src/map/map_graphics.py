import os

from PIL import ImageFont, ImageDraw, Image
from PIL.ImageQt import ImageQt
from PySide6.QtCore import Qt
from PySide6.QtGui import QPixmap, QColor, QPainter, QBrush

from src.db import TDB
import os

db = TDB()

from eng.map_loader import TILE_SIZE

def create_unit_hp_graphics():
    print("  Load and split unit hp graphics")
    from PIL import Image

    file_path = db.path_gfx / 'army' / 'hp.png'
    hp_image = Image.open(file_path)

    hp_width, hp_height = 12, 5
    hp_pieces = []

    for i in range(10):
        piece = hp_image.crop((0, i * hp_height, hp_width, (i + 1) * hp_height))
        hp_pieces.append(piece)

    db.res_images['hp'] = {i: QPixmap.fromImage(ImageQt(piece)) for i, piece in enumerate(hp_pieces)}



def create_all_images_from_gfx_folder():
    print('  Load images from gfx folder')

    gfx_folder = db.path_gfx

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

    db.res_images = images_dict

def generate_army_pixmaps():
    print("  Create army pixmap with color effect")
    input_image_path = db.path_gfx / 'army' / 'army.png'
    input_image = Image.open(input_image_path).convert('RGBA')  # Load as RGBA

    db.res_images['army_back'] = {}
    for color_name, color_value in db.db_colors_color.items():
        if color_name in db.db_color_sets['army']:
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
            db.res_images['army_back'][color_name] = pixmap



def prepate_graphics_flags_goods_religion_with_frame():

    print("  Process country flags into frame")
    from PIL import Image

    # Load the frame image
    frame_path = db.path_gfx / 'city' / 'frame.png'
    frame = Image.open(frame_path).convert("RGBA")

    # Initialize the dictionary to store the images
    def process_images_in_folder(folder_name, output_key):
        folder_path = db.path_gfx / folder_name
        db.res_images[output_key] = {}

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
                db.res_images[output_key][tag + '.png'] = combined_pixmap

    # Example usage for flags
    process_images_in_folder('flag', 'flag_frame')
    process_images_in_folder('goods', 'goods_frame')
    process_images_in_folder('religion', 'religion_frame')


def load_and_process_autotiles():
    print('  Load autotiles graphics')

    from PIL import Image

    file_path = db.path_tiles / 'autotiles.png'

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

        output_image.save( db.path_tiles_auto / f'auto_{tiles_names[x]}.png')


def load_river_autotiles():
    print("  Process rivers autotile")
    from PySide6.QtGui import QPixmap

    file_path = db.path_tiles_auto / 'auto_river2.png'

    # Load the auto_river.png image
    river_image = QPixmap(str(file_path))

    # Create a list to store the 16 sub-images
    river_tiles = []

    # Split the image into 16 sub-images
    for y in range(4):
        for x in range(4):
            tile = river_image.copy(x * TILE_SIZE, y * TILE_SIZE, TILE_SIZE, TILE_SIZE)
            river_tiles.append(tile)

    db.res_image_river = river_tiles


def create_color_rectangles_image():
    print('  Dump all colors to single png file')

    # Define image dimensions
    rect_width = 75
    rect_height = 25
    num_colors = len(db.db_colors_brush)
    image_width = rect_width
    image_height = rect_height * num_colors

    # Create a new image with white background
    image = Image.new('RGB', (image_width, image_height), 'white')
    draw = ImageDraw.Draw(image)

    # Load a font
    font = ImageFont.load_default()

    # Draw each rectangle with the color brush and write the color name
    for i, (name, brush) in enumerate(db.db_colors_brush.items()):
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
    output_path = db.path_tiles / 'color_rectangles.png'
    image.save(output_path)



def make_font_numbers():
    print("  Generate numbers to png file")
    tw, tile_height = 8, 12
    output_path = db.path_gfx / "numbers"

    db.res_images['numbers'] = {}

    if not os.path.exists(output_path):
        os.makedirs(output_path)

    def create_numbers_from_base():
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

            db.res_images['numbers'][number] = QPixmap.fromImage(ImageQt(number_image))

    create_numbers_from_base()

def create_battle_terrain_graphics():
    print("  Create 32x32 pixel graphics for each terrain")
    tile_size = 32

    db.res_images['battle_terrain'] = {}

    for terrain_name, terrain in db.db_terrains.items():
        # Create a new image with the terrain color
        terrain_color = db.db_colors_color[terrain.color_name]
        pixmap = QPixmap(tile_size, tile_size)
        pixmap.fill(terrain_color)

        # Add terrain effect
        if terrain.effect:
            painter = QPainter(pixmap)
            painter.setBrush(db.db_colors_brush['terrain_' + terrain.tag])
            painter.setPen(Qt.NoPen)
            painter.drawRect(0, 0, tile_size, tile_size)
            painter.end()

        # Add border
        # painter = QPainter(pixmap)
        # if terrain.is_land:
        #     border_color = db.db_colors['border_province']
        #     painter.setPen(QPen(border_color, 1))
        # else:
        #     border_color = db.db_colors['border_coastal']
        #     painter.setPen(QPen(border_color, 2))
        # painter.drawRect(0, 0, tile_size, tile_size)
        # painter.end()

        # Save the pixmap
        output_path = db.path_gfx / 'textures' / f'{terrain_name}.png'
        pixmap.save( str(output_path) )
        db.res_images['battle_terrain'][terrain_name] = pixmap



def create_pixmaps_with_weather_effect():
    print("  Create all graphics for textures with weather effects")
    weather_effects = db.db_color_sets['weather']

    output_dir = db.path_gfx / 'textures'

    if not os.path.exists(output_dir):
        os.makedirs(output_dir)

    for effect in weather_effects:
        effect_image_path = db.path_gfx / 'weather' / f'{effect}.png'
        effect_image = QPixmap(str(effect_image_path))
        grid_size = effect_image.size()

        pixmap = QPixmap(grid_size)
        pixmap.fill(Qt.transparent)  # Ensure the pixmap is transparent
        painter = QPainter(pixmap)
        painter.setCompositionMode(QPainter.CompositionMode_SourceOver)  # Ensure transparency and layering
        painter.drawPixmap(0, 0, effect_image)
        painter.end()

        file_name = f"effect_{effect}"
        db.db_colors_brush[file_name] = QBrush(pixmap)


def create_pixmaps_with_terrain_effect():
    print("  Create all graphics for textures with terrain effects")
    terrains_effects = db.db_color_sets['terrains']

    output_dir = db.path_gfx / 'textures'

    if not os.path.exists(output_dir):
        os.makedirs(output_dir)

    for effect in terrains_effects:
        effect_image_path = db.path_gfx / 'terrains' / f'{effect}.png'
        effect_image = QPixmap(str(effect_image_path))
        grid_size = effect_image.size()

        pixmap = QPixmap(grid_size)
        pixmap.fill(Qt.transparent)  # Ensure the pixmap is transparent
        painter = QPainter(pixmap)
        painter.setCompositionMode(QPainter.CompositionMode_SourceOver)  # Ensure transparency and layering
        painter.drawPixmap(0, 0, effect_image)
        painter.end()

        file_name = f"terrain_{effect}"
        db.db_colors_brush[file_name] = QBrush(pixmap)


def create_pixmaps_with_pattern_effect():
    print("  Create all graphics for textures with pattern effects")
    db_color_sets = db.db_color_sets['pattern']
    grid_size = db.rect_size
    output_dir = db.path_gfx / 'textures'

    if not os.path.exists(output_dir):
        os.makedirs(output_dir)

    for color_name in db_color_sets:
        color_value = db.db_colors_color.get(color_name)
        if color_value:
            pixmap = QPixmap(grid_size, grid_size)
            pixmap.fill(Qt.transparent)
            painter = QPainter(pixmap)
            painter.setBrush(color_value)
            painter.setPen(Qt.NoPen)
            painter.drawRect(grid_size // 2, 0, grid_size // 2, grid_size)
            painter.end()

            file_name = f"{color_name}_half"
            db.db_colors_brush[file_name] = QBrush(pixmap)
