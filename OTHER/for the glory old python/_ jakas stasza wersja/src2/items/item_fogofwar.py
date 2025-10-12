from PySide6.QtCore import QRectF
from PySide6.QtGui import QPainter, QPainterPath, QBrush, Qt
from PySide6.QtWidgets import QGraphicsItem

from core.game_state import GameState

gs = GameState()


class ProvinceFogOfWarOverlayItem(QGraphicsItem):
    def __init__(self):
        super().__init__()
        self.bounding_rect : QRectF = None
        self.brush = QBrush( gs.color_fog_of_war )
        self.tiles = []
        self.size = 0
        self.path: QPainterPath = None

    def create_path(self, tiles):
        path = QPainterPath()
        self.tiles = tiles
        for tile in self.tiles:
            path.addRect(tile)
        self.size = len(self.tiles)
        self.path = path
        self.bounding_rect : QRectF = self.calculate_bounding_rect()
        self.setZValue(gs.z_value_fog_of_war)     # High ZValue to cover all elements
        self.setVisible(True)  # Initially hidden

    def paint(self, painter, option, widget=None):
        painter.setCompositionMode(QPainter.CompositionMode_SourceOver)  # Ensure transparency and layering

        # primary color
        painter.setBrush(self.brush)
        painter.setPen(Qt.NoPen)
        painter.drawPath(self.path)

    def boundingRect(self):
        return self.bounding_rect

    def calculate_bounding_rect(self):
        if len(self.tiles) > 0:
            bounding_rect = self.tiles[0]
            for tile in self.tiles[1:]:
                bounding_rect = bounding_rect.united(tile)
            return bounding_rect
        return QRectF()
