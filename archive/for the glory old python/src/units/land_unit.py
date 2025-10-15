from PySide6.QtGui import QPixmap, QPainter
from PySide6.QtWidgets import QGraphicsPixmapItem

from src.db import TDB

db = TDB()

class LandUnitType(object):

	def __init__(self, unit_data):
		self.name = unit_data.get('name', 'Unknown')
		self.desc = unit_data.get('desc', 'Description')
		image = unit_data.get('image', 'inf.png')
		self.image : QPixmap = db.res_images['army'].get(image)
		self.offense = unit_data.get('offense', 1.0)
		self.defense = unit_data.get('defense', 1.0)
		self.siege = unit_data.get('siege', 0)
		self.move = unit_data.get('move', 1.0)
		self.cost = unit_data.get('cost', 10)
		self.manpower = unit_data.get('manpower', 1)

class LandUnit(QGraphicsPixmapItem):

	def __init__(self,
	             unit_type_tag: str,
	             province_id: int,
	             owner_tag: str,
	             experience: int = 0,
	             hit_points: float = 1.0):
		super().__init__()

		self.unit_type = db.db_units.get(unit_type_tag)
		self.province = db.provinces.get(province_id)
		self.owner = db.countries.get(owner_tag)
		self.experience = experience
		self.hit_points = hit_points

		self.image_back = db.res_images['army_back'][self.owner.color]
		self.image_unit = self.unit_type.image
		self.image_hp = db.res_images['hp'][0]
		self.setZValue(db.z_value_army)

	def calculate_hp_image(self):
		hp_index = min(9, max(0, int(self.hit_points * 10)))
		self.image_hp = db.res_images['hp'][hp_index]

	def paint(self, painter: QPainter, option, widget=None):
		painter.setCompositionMode(QPainter.CompositionMode_SourceOver)  # Ensure transparency and layering

		position = self.province.pixmap_province_city

		self.calculate_hp_image()

		# Draw the background image at the center of the province city position
		painter.drawPixmap(position.x() - self.image_back.width() // 2,
		                   position.y() - self.image_back.height() // 2,
		                   self.image_back)

		# Draw the unit image with an offset of 8x8 pixels
		painter.drawPixmap(position.x() - self.image_unit.width() // 2 + 8,
		                   position.y() - self.image_unit.height() // 2 + 8,
		                   self.image_unit)

		# Draw the HP image with an offset of 10x19 pixels
		painter.drawPixmap(position.x() - self.image_hp.width() // 2 + 10,
		                   position.y() - self.image_hp.height() // 2 + 19,
		                   self.image_hp)



