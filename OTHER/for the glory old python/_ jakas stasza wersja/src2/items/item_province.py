# src/province/province.py
import math

from PySide6.QtCore import QRectF
from PySide6.QtGui import QFont, Qt, QColor, QTextOption, QBrush, QPainterPath, QPainter, QPixmap
from PySide6.QtWidgets import QGraphicsItem

from items.item_fogofwar import ProvinceFogOfWarOverlayItem
from items.item_river import RiverItem
from core.game_state import GameState

gs = GameState()

TEXT_CENTER = QTextOption()
TEXT_CENTER.setAlignment(Qt.AlignCenter)

BRUSH_SELECTION = QBrush(QColor("#40000000"))



class ProvinceItem(QGraphicsItem):
    def __init__(self, province, scene):

        from object.province import Province
        province: Province
        self.province = province

        super().__init__()

        self.province_id = province.province_id
        self.name = province.name
        self.tiles = []     # rects
        self.color : QColor = QColor()
        self.bounding_rect : QRectF = None
        self.size = 0
        self.province_path : QPainterPath = None
        self.province_fog_of_war : ProvinceFogOfWarOverlayItem = None

        self.brush : QBrush = QBrush()
        self.brush_secondary : QBrush = QBrush()
        self.brush_effect : QBrush = QBrush()
        self.brush_terrain : QBrush = QBrush()

        self.setZValue( gs.z_value_map_tile)

        self.pixmap: QPixmap = None  # Add pixmap attribute

        # diagonal effect color
        self.color_primary : QColor = None
        self.color_secondary : QColor = None

        # river

        self.river_path : RiverItem = None

        # pixmaps
        self.pixmap_province_name : QPixmap = None
        self.pixmap_province_city : QPixmap = None                # who is owner
        self.pixmap_province_large_frame : QPixmap = None     # if province is capital city

        self.pixmap_province_core : QPixmap  = None
        self.pixmap_province_number : QPixmap  = None

        self.pixmap_province_city_show = True
        self.pixmap_province_large_frame_show = False
        self.pixmap_province_core_show = False
        self.pixmap_province_number_show = False

        if self.province.terrain:
            self.brush_terrain = gs.db_colors_brush.get('terrain_' + self.province.terrain.tag)
        else:
            self.brush_terrain = gs.db_colors_brush.get('terrain_plains')
            print( "no terrain brush", self.province_id)

    #
    #   GRAPHICS
    #

    def set_river(self):
        river_riles = gs.province_river_tiles_list.get(self.province_id)
        if river_riles:
            self.river_path = RiverItem(river_riles)

    def set_tiles(self, tiles):
        self.tiles = tiles
        self.province_path = self.create_path()
        self.bounding_rect : QRectF = self.calculate_bounding_rect()

        # create river
        self.set_river()

        # Create fog of war overlay
        self.province_fog_of_war = ProvinceFogOfWarOverlayItem()
        self.province_fog_of_war.create_path(tiles)

    def create_path(self):
        path = QPainterPath()
        self.size = 0
        for tile in self.tiles:
            path.addRect(tile)
            self.size += tile.width() // gs.rect_size * tile.height() // gs.rect_size
        return path

    def create_polygon_from_borders(self):
        pass

    def calculate_bounding_rect(self):
        if len(self.tiles) > 0:
            bounding_rect = self.tiles[0]
            for tile in self.tiles[1:]:
                bounding_rect = bounding_rect.united(tile)
            return bounding_rect
        return QRectF()

    def boundingRect(self):
        return self.bounding_rect

    def paint(self, painter, option, widget=None):
        painter.setCompositionMode(QPainter.CompositionMode_SourceOver)  # Ensure transparency and layering

        # primary color
        painter.setBrush(self.brush)
        painter.setPen(Qt.NoPen)
        painter.drawPath(self.province_path)

        # secondary color with 50% coverage only
        if self.brush_secondary:
            painter.setBrush(self.brush_secondary)
            painter.setPen(Qt.NoPen)
            painter.drawPath(self.province_path)

        # brush for terrain icons
        if self.brush_terrain:
            painter.setBrush(self.brush_terrain)
            painter.setPen(Qt.NoPen)
            painter.drawPath(self.province_path)

        # brush effect like snow / storm
        if self.brush_effect:
            painter.setBrush(self.brush_effect)
            painter.setPen(Qt.NoPen)
            painter.drawPath(self.province_path)

        # 50% gray for selection
        if self.province.is_selected:
            painter.setBrush(BRUSH_SELECTION)
            painter.setPen(Qt.NoPen)
            painter.drawPath(self.province_path)


    #
    #   EXPLORATION
    #

    def set_province_exploration(self, visible):



        # set him self
        self.setVisible(visible)

        # river
        if self.river_path:
            self.river_path.setVisible(visible)

        # set all tile borders
        for key, bord in self.province.borderlines.items():
            bord.setVisible(visible)

        # set roads to other provinces
        # for id, road in self.roads.items():
        #    road.setVisible(visible)

        # province name
        if self.pixmap_province_name:
            self.pixmap_province_name.setVisible( visible )

        # set capital province
        if self.pixmap_province_city :
            self.pixmap_province_city.setVisible(self.pixmap_province_city_show and visible)

        # set province number
        if self.pixmap_province_number :
            self.pixmap_province_number.setVisible(self.pixmap_province_number_show and visible)

        # set capital province
        if self.pixmap_province_large_frame:
            self.pixmap_province_large_frame.setVisible(self.pixmap_province_large_frame_show and visible)

        # core national pixmap
        if self.pixmap_province_core and ( self.province.is_core or self.province.is_national) :
            self.pixmap_province_core.setVisible(self.pixmap_province_core_show and visible)

        # fog of war pixmap
        if self.province_fog_of_war:
            self.province_fog_of_war.setVisible(visible)

    #
    #   METHODS TO SET STATE
    #

    def set_province_background_colors(self,
                                       primary_color = None,
                                       weather_effect = None,
                                       secondary_color = None):

        # primary color brush

        if primary_color:
            self.brush = gs.db_colors_brush.get( primary_color )

        # secondary color with 50% coverage

        if secondary_color:
            self.brush_secondary = gs.db_colors_brush.get( secondary_color + "_half" , None)
        else:
            self.brush_secondary = None

        # weather effects like SNOW, ICE, STORM, MUD

        if weather_effect:
            self.brush_effect = gs.db_colors_brush.get( "effect_" + weather_effect )
        else:
            self.brush_effect = None

    def set_city_pixmap(self,
                        category = 'city',
                        name = 'city.png' ):

        self.pixmap_province_city_show = True

        if self.pixmap_province_city:
            # set capital pixmap
            image = gs.res_images[category].get(name, None)
            if image:
                self.pixmap_province_city.setPixmap(image)
            else:
                image = gs.res_images['city'].get('city.png')
                self.pixmap_province_city.setPixmap(image)

    def set_city_number(self,
                        category = 'numbers',
                        number = 0):

        if self.pixmap_province_number:

            if number == 0:
                self.pixmap_province_number_show = False
                self.pixmap_province_number.setVisible(False)
            else:
                self.pixmap_province_number_show = True
                self.pixmap_province_number.setVisible(True)

            image = gs.res_images[category].get(str(number), None)
            if image:
                self.pixmap_province_number.setPixmap(image)
            else:
                image = gs.res_images['numbers'].get(0)
                self.pixmap_province_number.setPixmap(image)


    def set_core_pixmap(self, enable, is_core = True):

        if self.pixmap_province_core:
            self.is_core = False
            self.is_national = False
            image = None

            if enable:
                if is_core:
                    image = gs.res_images['city']["core.png"]
                    self.is_core = True
                else:
                    image = gs.res_images['city']["claim.png"]
                    self.is_national = True

            if image:
                self.pixmap_province_core.setPixmap(image)
                self.pixmap_province_core.setVisible(enable)
                self.pixmap_province_core_show = True
            else:
                self.pixmap_province_core.setVisible(False)
                self.pixmap_province_core_show = False

    def set_province_large_frame(self,
                                 stab_level = None):
        if self.pixmap_province_large_frame:
            # if nothing is done then its not capitol just create empty pixmap
            if stab_level is None:
                self.pixmap_province_large_frame.setVisible(False)
                self.pixmap_province_large_frame_show = False
            else:
                if isinstance(stab_level, int):
                    image = gs.res_images['stability'].get(f'stab0{stab_level + 3}.png', None)
                else:
                    image = gs.res_images['stability'].get(f'stab03.png', None)
                self.pixmap_province_large_frame.setPixmap(image)
                self.pixmap_province_large_frame.setVisible(True)
                self.pixmap_province_large_frame_show = True

    #
    #   METHODS TO CREATE STATE
    #

    def create_province_large_frame(self, scene, col, row):

        image = gs.res_images['stability']["stab03.png"]

        # if no image then create image
        if scene:
            pixmap_item = scene.addPixmap(image)
            pixmap_item.setOffset(col * gs.rect_size + (gs.rect_size - image.width()) / 2,
                                  row * gs.rect_size + (gs.rect_size - image.height()) / 2)
            pixmap_item.setZValue(gs.z_value_city - 1)
            self.pixmap_province_large_frame = pixmap_item
            pixmap_item.setVisible(False)

    def create_city_pixmap(self, category, name, scene, col, row):
        image = gs.res_images[category][name]

        # if no image then create image
        if scene:
            pixmap_item = scene.addPixmap(image)
            pixmap_item.setOffset(col * gs.rect_size + (gs.rect_size - image.width()) / 2,
                                  row * gs.rect_size + (gs.rect_size - image.height()) / 2)
            pixmap_item.setZValue(gs.z_value_city)
            self.pixmap_province_city = pixmap_item

    def create_number_pixmap(self, category, name, scene, col, row):
        image = gs.res_images[category][name]

        # if no image then create image
        if scene:
            pixmap_item = scene.addPixmap(image)
            pixmap_item.setOffset(col * gs.rect_size + (gs.rect_size - image.width()) / 2,
                                  (row + 1) * gs.rect_size + (gs.rect_size - image.height()) / 2)
            pixmap_item.setZValue(gs.z_value_army)
            self.pixmap_province_number = pixmap_item

    def create_core_pixmap(self, scene, col, row):

        # if no image then create image
        if scene:
            image = gs.res_images['city']["core.png"]

            pixmap_item = scene.addPixmap(image)
            pixmap_item.setOffset(col * gs.rect_size + (gs.rect_size - image.width()) / 2,
                                  (row-1) * gs.rect_size + (gs.rect_size - image.height()) / 2)
            pixmap_item.setZValue(gs.z_value_city + 1)
            self.pixmap_province_core = pixmap_item
            self.pixmap_province_core.setVisible(False)

    def move_pixmaps(self, col, row):

        self.province.city_position = (col, row)

        if not self.pixmap_province_city:
            self.create_city_pixmap('city', 'city.png', self.scene, col, row)
        else:
            self.pixmap_province_city.setOffset(
                col * gs.rect_size + (gs.rect_size - self.pixmap_province_city.pixmap().width()) / 2,
                row * gs.rect_size + (gs.rect_size - self.pixmap_province_city.pixmap().height()) / 2)

        if not self.pixmap_province_number:
            self.create_city_pixmap('numbers', 0, self.scene, col, row)
        else:
            self.pixmap_province_number.setOffset(
                col * gs.rect_size + (gs.rect_size - self.pixmap_province_number.pixmap().width()) / 2,
                (row + 1) * gs.rect_size + (gs.rect_size - self.pixmap_province_number.pixmap().height()) / 2)

        if not self.pixmap_province_core:
            self.create_core_pixmap(self.scene, col, row - 1)
        else:
            self.pixmap_province_core.setOffset(
                col * gs.rect_size + (gs.rect_size - self.pixmap_province_core.pixmap().width()) / 2,
                (row - 1) * gs.rect_size + (gs.rect_size - self.pixmap_province_core.pixmap().height()) / 2)

        if not self.pixmap_province_large_frame:
            self.create_province_large_frame(self.scene, col, row)
        else:
            self.pixmap_province_large_frame.setOffset(
                col * gs.rect_size + (gs.rect_size - self.pixmap_province_large_frame.pixmap().width()) / 2,
                row * gs.rect_size + (gs.rect_size - self.pixmap_province_large_frame.pixmap().height()) / 2)

        self.update()

    def set_name_text(self, scene=None, text=None, points=None):
        self.name = text
        self.scene = scene
        if self.pixmap_province_name:
            self.update_text()
        else:
            self.create_text_object(scene, points)
            self.update_text_position(points)

    def create_text_object(self, scene, points):
        col1, row1 = points[0]
        col2, row2 = points[-1]
        x1, y1 = col1 * gs.rect_size + gs.rect_size / 2, row1 * gs.rect_size + gs.rect_size / 2
        x2, y2 = col2 * gs.rect_size + gs.rect_size / 2, row2 * gs.rect_size + gs.rect_size / 2
        mid_x = (x1 + x2) / 2
        mid_y = (y1 + y2) / 2
        angle = math.degrees(math.atan2(y2 - y1, x2 - x1))
        angle = angle - 180 if angle > 90 else angle + 180 if angle < -90 else angle

        text_to_display = self.name
        if not text_to_display:
            return

        font_size = gs.font_size_land if self.province.is_land else gs.font_size_sea
        font_size += int(math.sqrt(self.size) // 2) - len(text_to_display) // 4
        font_color = gs.color_font_land if self.province.is_land else gs.color_font_sea

        z_value =  gs.z_value_prov_name

        text_item = scene.addText(text_to_display.replace("\\n", "\n"))
        font = QFont('Consolas', font_size, QFont.Bold)
        text_item.setFont(font)
        text_bbox = text_item.boundingRect()
        text_item.setTextWidth(text_bbox.width())
        text_item.document().setDefaultTextOption(TEXT_CENTER)
        text_item.setDefaultTextColor(font_color)
        text_item.setTransformOriginPoint(text_bbox.center())
        text_item.setPos(mid_x - text_bbox.width() / 2, mid_y - text_bbox.height() / 2)
        text_item.setRotation(angle)
        text_item.setZValue(z_value)

        self.pixmap_province_name = text_item

    def update_text_position(self, points):
        col1, row1 = points[0]
        col2, row2 = points[-1]
        self.province.name_text_position = set(points)
        x1, y1 = col1 * gs.rect_size + gs.rect_size / 2, row1 * gs.rect_size + gs.rect_size / 2
        x2, y2 = col2 * gs.rect_size + gs.rect_size / 2, row2 * gs.rect_size + gs.rect_size / 2
        mid_x = (x1 + x2) / 2
        mid_y = (y1 + y2) / 2
        angle = math.degrees(math.atan2(y2 - y1, x2 - x1))
        angle = angle - 180 if angle > 90 else angle + 180 if angle < -90 else angle

        if not self.pixmap_province_name:
            self.create_text_object(self.scene, points)
        text_bbox = self.pixmap_province_name.boundingRect()
        self.pixmap_province_name.setPos(mid_x - text_bbox.width() / 2, mid_y - text_bbox.height() / 2)
        self.pixmap_province_name.setRotation(angle)

    def update_text(self):
        self.pixmap_province_name.setPlainText(self.name)
        font_size = gs.font_size_land if self.province.is_land else gs.font_size_sea
        font_size += int(math.sqrt(self.size) // 3) - len(self.name) // 4 + 1
        font = QFont('Consolas', font_size, QFont.Bold)
        self.pixmap_province_name.setFont(font)

    #
    #   METHODS TO MANAGE ZOOM LEVELS
    #

    def _hide_city(self):
        if self.province.is_explored:
            if self.pixmap_province_city and self.pixmap_province_city_show:
                self.pixmap_province_city.setVisible(False)
            if self.pixmap_province_number and self.pixmap_province_number_show:
                self.pixmap_province_number.setVisible(False)
            if self.pixmap_province_large_frame and self.pixmap_province_large_frame_show:
                self.pixmap_province_large_frame.setVisible(False)
            if self.pixmap_province_core and self.pixmap_province_core_show:
                self.pixmap_province_core.setVisible(False)

    def _hide_river(self):
        if self.river_path and self.province.is_explored:
            self.river_path.setVisible(False)

    def _hide_name(self):
        if self.pixmap_province_name and self.province.is_explored:
            self.pixmap_province_name.setVisible(False)

    def _show_river(self):
        if self.river_path and self.province.is_explored:
            self.river_path.setVisible(True)

    def _show_city(self):
        if self.province.is_explored:
            if self.pixmap_province_city and self.pixmap_province_city_show:
                self.pixmap_province_city.setVisible(True)
            if self.pixmap_province_number and self.pixmap_province_number_show:
                self.pixmap_province_number.setVisible(True)
            if self.pixmap_province_large_frame and self.pixmap_province_large_frame_show:
                self.pixmap_province_large_frame.setVisible(True)
            if self.pixmap_province_core and self.pixmap_province_core_show:
                self.pixmap_province_core.setVisible(True)

    def _show_name(self):
        if self.pixmap_province_name and self.province.is_explored:
            self.pixmap_province_name.setVisible(True)

    def change_details_based_on_zoom_level(self, zoom_level):

        if True:
            if zoom_level == 0:
                self._hide_name()
                self._hide_city()
                #self._show_river()
            elif zoom_level == 1:
                self._hide_name()
                self._show_city()
                #self._show_river()
            elif zoom_level == 2:
                self._show_name()
                self._show_city()
                #self._show_river()
            elif zoom_level == 3:
                self._show_name()
                self._show_city()
                #self._show_river()


