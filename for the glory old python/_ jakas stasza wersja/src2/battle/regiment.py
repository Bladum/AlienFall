from PySide6.QtGui import QPainter, QTransform
from PySide6.QtWidgets import QGraphicsPixmapItem

from ref.ref_regiment import RegimentType
from core.game_state import GameState
from ref.ref_unit import UnitType

gs = GameState()

#
#   REGIMENT - actual unit moved during battle scape
#

class Regiment(QGraphicsPixmapItem):

    def __init__(self,
                 regiment_tag: str = 'peasant',
                 owner_tag: str = 'REB',
                 side : str = 'A',
                 position : tuple = (),
                 experience: int = 0,
                 morale: int = 0,
                 unit_type = 'infantry',
                 hit_points: float = 10):
        super().__init__()

        self.regiment_type : RegimentType = gs.db_regiments.get(regiment_tag)
        self.unit_type : UnitType = gs.db_units.get(unit_type)
        self.owner = gs.countries.get(owner_tag)
        self.experience = experience
        self.hit_points = hit_points
        self.battle_side = side
        self.position = position

        self.image_back = gs.res_images['army_back']['red' if side == 'A' else 'blue']
        self.image_regiment = self.regiment_type.image
        self.image_unit = self.unit_type.image
        self.image_hp = gs.res_images['hp'][0]
        self.setZValue(gs.z_value_army)
        self.image_final = self.create_large_image()


    def calculate_hp_image(self):
        import random
        self.hit_points =  random.uniform(6, 10)
        index = min(10, max(1, int(self.hit_points))) - 1
        self.image_hp = gs.res_images['hp'][index]

    def create_large_image(self):
        # Create a new QPixmap with the same size as the background image
        image_back = self.image_back.copy()

        # Create a QPainter to draw on the final image
        painter = QPainter(image_back)
        painter.setCompositionMode(QPainter.CompositionMode_SourceOver)  # Ensure transparency and layering

        self.calculate_hp_image()

        # Draw the unit image with an offset of 8x8 pixels
        if self.battle_side == 'D':
            painter.drawPixmap(8, 7, self.image_regiment.transformed(QTransform().scale(-1, 1)))
        else:
            painter.drawPixmap(8, 7, self.image_regiment)

        # Draw the HP image with an offset of 10x19 pixels
        painter.drawPixmap( 9, 25, self.image_hp)

        painter.end()

        return image_back