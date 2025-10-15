from PySide6.QtCore import QPointF
from PySide6.QtGui import QPainterPath
from PySide6.QtWidgets import QGraphicsPathItem

from core.game_state import GameState
gs = GameState()



class RiverItem(QGraphicsPathItem):

    def __init__(self, river_tiles):
        super().__init__()
        self.river_tiles = river_tiles  # 2D list of river tile values
        self.setPath( self.create_path() )
        self.setZValue(gs.z_value_river)  # Set Z value for rendering order
        self.setPen(gs.pen_river)

    def create_path(self):
        path = QPainterPath()
        for col, row, tile_value in self.river_tiles:
            if tile_value > 0:
                self.add_tile_path(path, col, row, tile_value)
        return path

    def add_tile_path(self, path, col, row, tile_value):
        x = col * gs.rect_size
        y = row * gs.rect_size
        points = self.get_tile_points(tile_value)
        for start, end in points:
            path.moveTo(QPointF(x + start[0], y + start[1]))
            path.lineTo(QPointF(x + end[0], y + end[1]))

    def get_tile_points(self, tile_value):

        # t = gs.rect_size
        # t2 = gs.rect_size / 2
        #
        # patterns = {
        #     1: [((t2, t), (t, t))],
        #     2: [((t, t2), (t, t))],
        #     3: [((t, t), (t, t))],
        #
        #     4: [((0, t), (t2, t))],
        #     5: [((0, t), (t, t))],
        #     6: [((0, t), (t, t))],
        #     7: [((0, t), (t, t))],
        #
        #     8: [((t, 0), (t, t2))],
        #     9: [((t, 0), (t, t))],
        #     10: [((t, 0), (t, t))],
        #     11: [((t, 0), (t, t))],
        #
        #     12: [((0, t), (t, t)), ((t, t), (t, 0))],
        #     13: [((0, t), (t, t)), ((t, t), (t, 0))],
        #     14: [((0, t), (t, t)), ((t, t), (t, 0))],
        #     15: [((0, t), (t, t)), ((t, t), (t, 0))],
        # }
        # return patterns.get(tile_value, [])

        t = gs.rect_size
        t2 = gs.rect_size / 2

        # # Check neighbors
        # if x < width - 1 and pixels[x + 1, y][:3] in all_types:  # Right
        #     value += 1
        # if y < height - 1 and pixels[x, y + 1][:3] in all_types:  # Bottom
        #     value += 2
        # if x > 0 and pixels[x - 1, y][:3] in all_types:  # Left
        #     value += 4
        # if y > 0 and pixels[x, y - 1][:3] in all_types:  # Up
        #     value += 8

        patterns = {
            1: [((t2, t2), (t, t2))],  # Right
            2: [((t2, t2), (t2, t))],  # Bottom
            3: [((t2, t2), (t, t2)), ((t2, t2), (t2, t))],  # Right, Bottom

            4: [((t2, t2), (0, t2))],  # Left
            5: [((t2, t2), (0, t2)), ((t2, t2), (t, t2))],  # Left, Right
            6: [((t2, t2), (0, t2)), ((t2, t2), (t2, t))],  # Left, Bottom
            7: [((t2, t2), (0, t2)), ((t2, t2), (t, t2)), ((t2, t2), (t2, t))],  # Left, Right, Bottom

            8: [((t2, t2), (t2, 0))],  # Top
            9: [((t2, t2), (t2, 0)), ((t2, t2), (t, t2))],  # Top, Right
            10: [((t2, t2), (t2, 0)), ((t2, t2), (t2, t))],  # Top, Bottom
            11: [((t2, t2), (t2, 0)), ((t2, t2), (t, t2)), ((t2, t2), (t2, t))],  # Top, Right, Bottom

            12: [((t2, t2), (t2, 0)), ((t2, t2), (0, t2))],  # Top, Left
            13: [((t2, t2), (t2, 0)), ((t2, t2), (0, t2)), ((t2, t2), (t, t2))],  # Top, Left, Right
            14: [((t2, t2), (t2, 0)), ((t2, t2), (0, t2)), ((t2, t2), (t2, t))],  # Top, Left, Bottom
            15: [((t2, t2), (t2, 0)), ((t2, t2), (0, t2)), ((t2, t2), (t, t2)), ((t2, t2), (t2, t))],  # All sides
        }
        return patterns.get(tile_value, [])

