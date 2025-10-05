"""
TileMapGame: Tactical grid-based game testbed for XCOM mechanics (duplicate test file).

Provides a PySide6-based visual test environment for rendering, unit selection, pathfinding, and line of sight calculations.

Classes:
    TileMapGame: Main class for the tactical testbed.

Last standardized: 2025-06-14
"""

from PySide6.QtWidgets import QApplication, QGraphicsView, QGraphicsScene, QGraphicsRectItem
from PySide6.QtCore import Qt, QRectF
from PySide6.QtGui import QPainter, QColor


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
        self.path = []  # Initialize path to avoid AttributeError
        self.units = []  # List to store multiple units
        self.tile_items = {}  # Cache for tile items
        self.path_items = []  # Cache for path items

        # Initialize scene
        self.scene = QGraphicsScene()
        self.setScene(self.scene)

        # Enable resizing
        self.setResizeAnchor(QGraphicsView.ViewportAnchor.AnchorViewCenter)
        self.setRenderHint(QPainter.RenderHint.Antialiasing)

        # Create tilemap
        self.tilemap = [[0 for _ in range(self.MAP_WIDTH)] for _ in range(self.MAP_HEIGHT)]
