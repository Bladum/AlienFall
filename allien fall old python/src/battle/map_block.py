"""
engine/battle/map_block.py

Defines the TMapBlock class, representing a block of the battle map (e.g., 15x15 or larger) for tactical battles.

Classes:
    TMapBlock: Represents a block of the battle map as a 2D array of TBattleTile objects (default 15x15, can be larger).

Last standardized: 2025-06-22 (typing enforced)
"""

import os
from PIL import Image
from pytmx import TiledMap, TiledTileLayer
import pathlib
from battle.battle_tile import TBattleTile
from typing import TYPE_CHECKING

class TMapBlock:
    """
    Represents a block of the battle map as a 2D array of TBattleTile objects (default 15x15, can be larger).
    Used to generate the tactical battle map. Each block can be placed on the battle map grid.

    Attributes:
        game: Reference to the TGame instance.
        name (str): Name of the block (usually the TMX file name).
        group (int): Group identifier for filtering blocks.
        size (int): Size of the block (e.g., 15 for 15x15).
        tiles (list[list[TBattleTile]]): 2D array of TBattleTile objects.
        used_tilesets (set[tuple[str, int, int, int]]): Set of tilesets used in the block.
    """
    def __init__(self, size: int = 15):
        """
        Initialize a TMapBlock instance.

        Args:
            size (int): Size of the block (e.g., 15 for 15x15).
        """
        from engine.game import TGame  # Avoid circular import
        self.game: TGame = TGame()

        self.name: str = ''  # Name of the block (usually the TMX file name)
        self.group: int = 0  # Group identifier for filtering blocks
        self.size: int = size  # Size of the block (e.g., 15 for 15x15)

        # 2D array of TBattleTile
        self.tiles: list[list[TBattleTile]] = [[TBattleTile() for _ in range(size)] for _ in range(size)]
        self.used_tilesets: set[tuple[str, int, int, int]] = set()  # Set of tilesets used in the block

    def get_tile(self, x: int, y: int) -> TBattleTile:
        """
        Return the TBattleTile at (x, y) in this block.

        Args:
            x (int): X coordinate.
            y (int): Y coordinate.
        Returns:
            TBattleTile: The tile at the given coordinates.
        """
        return self.tiles[y][x]

    @classmethod
    def from_tmx(cls, tmx: TiledMap) -> 'TMapBlock | None':
        """
        Create a TMapBlock from a TMX map object.

        Args:
            tmx (TiledMap): The TMX map object to load from.
        Returns:
            TMapBlock | None: The created map block, or None if floor layer is missing.
        """
        # Only process layers: floor, wall, roof
        layers: dict[str, TiledTileLayer] = {l.name: l for l in tmx.visible_layers if l.name in ('floor', 'wall', 'roof')}
        floor_layer: TiledTileLayer = layers['floor'] if 'floor' in layers else None
        wall_layer: TiledTileLayer = layers['wall'] if 'wall' in layers else None
        roof_layer: TiledTileLayer = layers['roof'] if 'roof' in layers else None

        if floor_layer is None:
            return None

        width: int = floor_layer.width
        height: int = floor_layer.height

        # Calculate used tilesets for this block (assume all tilesets have correct attributes)
        used_tilesets: set[tuple[str, int, int, int]] = {
            (
                tileset.name,
                tileset.firstgid,
                tileset.firstgid + tileset.tilecount - 1,
                tileset.tilecount
            )
            for tileset in tmx.tilesets
        }

        # Helper function to process layer data
        def process_layer(layer: TiledTileLayer | None) -> list[list[int]] | None:
            if layer is None:
                return None
            data: list[list[int]] = [[0 for _ in range(width)] for _ in range(height)]
            div_factor: float = 1.0 / 18
            for x, y, image in layer.tiles():
                ix, iy, _, __ = image[1]
                dx = (ix - 1) * div_factor
                dy = (iy - 1) * div_factor
                dn = int(dy * 10 + dx + 1)
                data[y][x] = dn
            return data

        floor_layer_data = process_layer(floor_layer)
        wall_layer_data = process_layer(wall_layer)
        roof_layer_data = process_layer(roof_layer)

        # Create TBattleTile objects for each tile
        tiles: list[list[TBattleTile]] = [[None for _ in range(width)] for _ in range(height)]
        for y in range(height):
            for x in range(width):
                floor_gid = floor_layer_data[y][x] if floor_layer_data else 0
                wall_gid = wall_layer_data[y][x] if wall_layer_data else 0
                roof_gid = roof_layer_data[y][x] if roof_layer_data else 0
                tiles[y][x] = TBattleTile.from_gids(floor_gid, wall_gid, roof_gid, used_tilesets)

        block = cls(size=width)
        block.tiles = tiles
        block.name = ''
        block.group = 0  # Get group from TMX properties if needed
        block.size = width // 15    # Assuming square blocks, size is width but divided by 15
        block.used_tilesets = used_tilesets

        return block

    def render_to_png(self) -> None:
        """
        Render the map block to a PNG file using Pillow.
        Output directory: User Documents/export/maps
        Output PNG name: self.name + ".png"
        """
        tileset_manager = self.game.mod.tileset_manager
        tile_size: int = 16
        width_px: int = self.size * tile_size * 15
        height_px: int = self.size * tile_size * 15
        out_img = Image.new('RGBA', (width_px, height_px), (0, 0, 0, 0))

        def draw_layer(gid: int, x: int, y: int) -> None:
            if gid == 0:
                return
            img, mask = tileset_manager.all_tiles[gid]
            if img:
                pixel_x, pixel_y = x * tile_size, y * tile_size
                out_img.paste(img, (pixel_x, pixel_y), mask)

        for y in range(self.size * 15):
            for x in range(self.size * 15):
                tile = self.tiles[y][x]
                if tile.floor_id:
                    draw_layer(tile.floor_id, x, y)
                if tile.wall_id:
                    draw_layer(tile.wall_id, x, y)
                # if tile.roof_id:
                #     draw_layer(tile.roof_id, x, y)

        user_docs = self.game.mod.mod_path / 'export' / 'maps'
        user_docs.mkdir(parents=True, exist_ok=True)
        out_path = user_docs / f"{self.name}.png"
        out_img.save(out_path)
        print(f"Saved map block image to {out_path}")
