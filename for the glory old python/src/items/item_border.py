from enum import Enum

from PySide6.QtCore import QPointF
from PySide6.QtGui import QPainterPath
from PySide6.QtWidgets import QGraphicsPathItem

from src.db import TDB

db = TDB()

class BorderType(Enum):
    PROVINCE = 0
    SEA = 1
    COAST = 2
    COUNTRY = 3
    NONE = 4


class BorderItem(QGraphicsPathItem):
    def __init__(self, border_lines, prov_id_1, prov_id_2, parent=None):
        super().__init__(parent)
        self.border_lines = border_lines  # List of tuples [(start_point, end_point), ...]
        self.path = self.create_path()
        self.setPath(self.path)
        # self.setCacheMode(QGraphicsItem.DeviceCoordinateCache)  # Cache for performance
        self.setZValue(db.z_value_prov_border)
        self.border_type = None
        self.prov_id_1 = prov_id_1
        self.prov_id_2 = prov_id_2

        self.detect_border_type()

    def create_path(self):
        path = QPainterPath()

        for line in self.border_lines:
            start, end = line
            path.moveTo(QPointF(start[0], start[1]))
            path.lineTo(QPointF(end[0], end[1]))

        return path

    def detect_border_type(self):
        from items.item_province import ProvinceItem
        prov1_data : ProvinceItem = db.provinces.get(self.prov_id_1)
        prov2_data : ProvinceItem = db.provinces.get(self.prov_id_2)

        if not prov1_data or not prov2_data:
            print("  ERROR with border, no prov IDs", self.prov_id_1, self.prov_id_2)
            return

        is_land_prov1 = prov1_data.is_land
        is_land_prov2 = prov2_data.is_land

        owner_prov1 = db.country_province_owner_dict.get(self.prov_id_1, "Unknown")
        owner_prov2 = db.country_province_owner_dict.get(self.prov_id_2, "Unknown")

        if not is_land_prov1 and not is_land_prov2:
            self.set_border_type(BorderType.SEA)
            self.border_type = 'water'
        if (is_land_prov2 and not is_land_prov1) or (is_land_prov1 and not is_land_prov2):
            self.set_border_type(BorderType.COAST)
            self.border_type = 'coastal'
        if is_land_prov1 and is_land_prov2:
            self.border_type = 'land'
            if owner_prov1 == owner_prov2:
                self.set_border_type(BorderType.PROVINCE)
            else:
                self.set_border_type(BorderType.COUNTRY)

    def set_border_type(self, border_type):
        match border_type:
            case BorderType.PROVINCE:
                self.setPen(db.pen_border_province)
                self.setZValue(db.z_value_prov_border)
            case BorderType.SEA:
                self.setPen(db.pen_border_sea)
                self.setZValue(db.z_value_sea_border)
            case BorderType.COAST:
                self.setPen(db.pen_border_coastal)
                self.setZValue(db.z_value_coast_border)
            case BorderType.COUNTRY:
                self.setPen(db.pen_border_country)
                self.setZValue(db.z_value_country_border)
            case BorderType.NONE:
                self.pen().setWidth(0)
                self.setZValue(2)