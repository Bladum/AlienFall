"""
TileMapGame: Tactical grid-based game testbed for XCOM mechanics.

Provides a PySide6-based visual test environment for rendering, unit selection, pathfinding, and line of sight calculations.

Classes:
    TileMapGame: Main class for the tactical testbed.

Last standardized: 2025-06-14
"""

from PySide6.QtWidgets import QApplication, QGraphicsView, QGraphicsScene, QGraphicsRectItem
from PySide6.QtCore import Qt, QRectF
from PySide6.QtGui import QPainter, QColor
from typing import TYPE_CHECKING
if TYPE_CHECKING:
    from typing import List
    from PySide6.QtWidgets import QGraphicsScene
    from .unit import MultiTileUnit


class TileMapGame(QGraphicsView):
    """
    Main game class representing a tactical grid-based game similar to XCOM.
    Handles rendering, unit selection, pathfinding and line of sight calculations.
    """
    def __init__(self):
        """
        Initialize the game with map, units and visual elements.
        Sets up the graphics scene, initializes the tile map and units.
        """
        super().__init__()

        # Constants
        self.TILE_SIZE = 16
        self.MAP_WIDTH = 20 * 6
        self.MAP_HEIGHT = 20 * 6

        # Variables for unit selection and pathfinding
        self.selected_unit = None
        self.path: list[tuple[int, int]] = []  # Path as list of coordinates
        self.units: list[MultiTileUnit] = []  # List to store multiple units
        self.tile_items: dict[tuple[int, int], QGraphicsRectItem] = {}
        self.path_items: list[QGraphicsRectItem] = []  # Cache for path items

        # Initialize scene
        self.scene = QGraphicsScene()
        self.setScene(self.scene)

        # Enable resizing
