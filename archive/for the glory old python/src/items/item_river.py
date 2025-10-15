from PySide6.QtCore import QPointF
from PySide6.QtGui import QPainterPath
from PySide6.QtWidgets import QGraphicsPathItem

from src.db import TDB

db = TDB()



class RiverItem(QGraphicsPathItem):

    def __init__(self, river_tiles):
        super().__init__()
        self.river_tiles = river_tiles  # 2D list of river tile values
        self.setPath( self.create_path() )
        self.setZValue(db.z_value_river)  # Set Z value for rendering order
        self.setPen(db.pen_river)

    def create_path(self):
        path = QPainterPath()
        for col, row, tile_value in self.river_tiles:
            if tile_value > 0:
                self.add_tile_path(path, col, row, tile_value)
        return path

    def add_tile_path(self, path, col, row, tile_value):
        x = col * db.rect_size
        y = row * db.rect_size
        points = self.get_tile_points(tile_value)
        for start, end in points:
            path.moveTo(QPointF(x + start[0], y + start[1]))
            path.lineTo(QPointF(x + end[0], y + end[1]))

    def get_tile_points(self, tile_value):

        t = db.rect_size
        t2 = db.rect_size / 2

        patterns = {
            1: [((t2, t), (t, t))],
            2: [((t, t2), (t, t))],
            3: [((t, t), (t, t))],

            4: [((0, t), (t2, t))],
            5: [((0, t), (t, t))],
            6: [((0, t), (t, t))],
            7: [((0, t), (t, t))],

            8: [((t, 0), (t, t2))],
            9: [((t, 0), (t, t))],
            10: [((t, 0), (t, t))],
            11: [((t, 0), (t, t))],

            12: [((0, t), (t, t)), ((t, t), (t, 0))],
            13: [((0, t), (t, t)), ((t, t), (t, 0))],
            14: [((0, t), (t, t)), ((t, t), (t, 0))],
            15: [((0, t), (t, t)), ((t, t), (t, 0))],
        }
        return patterns.get(tile_value, [])

