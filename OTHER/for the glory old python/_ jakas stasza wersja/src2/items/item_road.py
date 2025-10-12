from PySide6.QtGui import QPen, QPainterPath
from PySide6.QtWidgets import QGraphicsPathItem

from core.game_state import GameState

gs = GameState()


class RoadItem(QGraphicsPathItem):
    def __init__(self, province_from, province_to):
        super().__init__()

        from object.province import Province

        self.province_from : Province = province_from
       # self.setCacheMode(QGraphicsItem.DeviceCoordinateCache)  # Cache for performance
        self.province_to : Province = province_to

        if self.province_from.is_land and self.province_to.is_land:
            self.road_type = 'land'
            self.pen = QPen(gs.pen_road_land)
        elif not self.province_from.is_land and not self.province_to.is_land:
            self.road_type = 'water'
            self.pen = QPen(gs.pen_road_sea)
        else:
            self.road_type = 'coastal'
            self.pen = QPen(gs.pen_road_coast)

        self.setPen(self.pen)
        self.setVisible(False)
        self.setZValue(gs.z_value_roads)
        self.create_path()

    def create_path(self):
        path = QPainterPath()
        x1, y1 = self.province_from.city_position
        x2, y2 = self.province_to.city_position

        rect_size = gs.rect_size
        map_width = gs.map_width

        # this is for closed world map
        if abs(x1 - x2) > 500:
            if x1 < x2:
                path.moveTo(x1 * rect_size + rect_size / 2, y1 * rect_size + rect_size / 2)
                path.lineTo((x2 - map_width) * rect_size + rect_size / 2, y2 * rect_size + rect_size / 2)
                path.moveTo(x2 * rect_size + rect_size / 2, y2 * rect_size + rect_size / 2)
                path.lineTo((x1 + map_width) * rect_size + rect_size / 2, y1 * rect_size + rect_size / 2)
            else:
                path.moveTo((x1 - map_width) * rect_size + rect_size / 2, y1 * rect_size + rect_size / 2)
                path.lineTo(x2 * rect_size + rect_size / 2, y2 * rect_size + rect_size / 2)
                path.moveTo((x2 + map_width) * rect_size + rect_size / 2, y2 * rect_size + rect_size / 2)
                path.lineTo(x1 * rect_size + rect_size / 2, y1 * rect_size + rect_size / 2)
        else:
            path.moveTo(x1 * rect_size + rect_size / 2, y1 * rect_size + rect_size / 2)
            path.lineTo(x2 * rect_size + rect_size / 2, y2 * rect_size + rect_size / 2)

        self.setPath(path)

    def show_road(self, pen_size = 8, pen_color = 'black'):
        self.setVisible(True)
        self.set_pen_size(pen_size)

    def hide_road(self):
        self.setVisible(False)

    def set_pen_size(self, size):
        self.pen.setWidth(size)
        self.setPen(self.pen)

