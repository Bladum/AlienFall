'''

GAME SCENE

Class related to manage all interaction with user and graphics management


'''

from manager import manager_province
from items.item_province import ProvinceItem
from items.item_road import RoadItem
from PySide6.QtCore import Qt, QRectF, QPoint
from PySide6.QtGui import QPainter
from PySide6.QtWidgets import QGraphicsView, QGraphicsScene, QToolTip, QInputDialog
from items.item_border import BorderItem
from map import map_mode

from src.db import TDB
from PySide6.QtCore import Qt, QRectF, QPoint
db = TDB()

from units.land_unit import LandUnit


#
#   HERE GOES ALL INTERACTION WITH USER
#


class GameScene(QGraphicsScene):

    def __init__(self, parent=None):
        super().__init__(parent)

        print("Create game scene")

        from PySide6.QtWidgets import QApplication
        QApplication.instance().setStyleSheet("""
            QToolTip { background-color: #3A3A3A; color: #FFD700; border: 1px solid #FFD700; font-family: Consolas; font-size: 10pt; border-radius: 10px; }
            QWidget { background-color: #2A2A2A; color: #F0F0F0; font-family: Consolas; font-size: 10pt; }
            QMainWindow { background-color: #2A2A2A; }
            QMenuBar { background-color: #3A3A3A; color: #F0F0F0; }
            QMenu { background-color: #3A3A3A; color: #F0F0F0; }
            QStatusBar { background-color: #3A3A3A; color: #F0F0F0; }
            QPushButton { background-color: #4A4A4A; color: #F0F0F0; border: 1px solid #FFD700; }
            QPushButton:hover { background-color: #5A5A5A; }
            QLineEdit { background-color: #3A3A3A; color: #F0F0F0; border: 1px solid #FFD700; }
            QComboBox { background-color: #3A3A3A; color: #F0F0F0; border: 1px solid #FFD700; }
            QCheckBox { color: #F0F0F0; }
            QRadioButton { color: #F0F0F0; }
            QTabWidget::pane { border: 1px solid #FFD700; }
            QTabBar::tab { background: #3A3A3A; color: #F0F0F0; border: 1px solid #FFD700; padding: 5px; }
            QTabBar::tab:selected { background: #4A4A4A; }
        """)
        self.selected_color = ''

        self.game_view = QGraphicsView(self)

        self.setItemIndexMethod(QGraphicsScene.NoIndex)
        self.setBackgroundBrush(Qt.black)
        self.game_view.setRenderHint(QPainter.Antialiasing, False)
        self.game_view.setRenderHint(QPainter.TextAntialiasing, False)
        self.game_view.setRenderHint(QPainter.SmoothPixmapTransform, False)
        self.game_view.setOptimizationFlag(QGraphicsView.DontAdjustForAntialiasing, True)
        #self.game_view.setCacheMode(QGraphicsView.CacheBackground)
        self.game_view.setDragMode(QGraphicsView.ScrollHandDrag)
        self.game_view.setTransformationAnchor(QGraphicsView.AnchorUnderMouse)
        self.game_view.setResizeAnchor(QGraphicsView.AnchorUnderMouse)
        self.game_view.setCursor(Qt.ArrowCursor)
        self.game_view.setViewportUpdateMode(QGraphicsView.BoundingRectViewportUpdate)
        self.game_view.setOptimizationFlag(QGraphicsView.DontSavePainterState, True)

        self.current_country_tag_number = 0

        from items.item_province import ProvinceItem
        self.selected_province : ProvinceItem = None
        self.selected_province_id = None

    #
    # MOUSE MOVE TOOLTIP
    #

    def mouseMoveEvent(self, event):
        pos = event.scenePos().toPoint()
        province : ProvinceItem = self.get_province_from_position(pos)
        if province:
            if province.is_explored:
                tooltip_text = province.get_province_tooltip( db.current_map_mode )
            else:
                tooltip_text = 'Terra Incognita'
            QToolTip.showText(event.screenPos() + QPoint(64, 64), tooltip_text, self.game_view, msecShowTime=20000)
        else:
            QToolTip.hideText()
        super().mouseMoveEvent(event)

    #
    #   PROVINCE SELECTION
    #

    def get_province_from_position(self, position):

        rect_size = db.rect_size

        col = int(position.x() // rect_size)
        row = int(position.y() // rect_size)

        if 0 <= row < len(db.province_id_map) and 0 <= col < len(db.province_id_map[0]):
            province_id = db.province_id_map[row][col]

            province = db.provinces.get(province_id, None)
            if province:
                return province

        return None

    def select_province(self, position):
        prov = self.get_province_from_position(position)
        if prov:
            if prov.is_explored:
                self.update_selected_province( prov )
                print('Selected province', prov.province_id, prov.name)

    def select_province_by_id(self, province_id):
        self.selected_province_id = province_id
        self.update_selected_province( None )
        print('Selected province', province_id)

    def update_selected_province(self, prov ):
        # Clear previous selection highlight
        self.clear_selection_highlight()

        self.selected_province_id = prov.province_id
        self.selected_province = prov

        # Highlight the selected province
        self.highlight_province(prov)

    def clear_selection_highlight(self):
        if self.selected_province:
            self.selected_province.deselect_province()

        self.selected_province = None
        self.selected_province_id = 0

    def highlight_province(self, province):
        province.select_province()

    #
    #   MOUSE EVENTS
    #

    def mouseDoubleClickEvent(self, event):
        pos = event.scenePos().toPoint()
        prov = self.get_province_from_position(pos)

        if prov:
            if event.button() == Qt.RightButton:
                self.perform_mouse_double_press_action(event, pos, prov)

        super().mouseDoubleClickEvent(event)
        self.update()

    def mouseReleaseEvent(self, event):
        pos = event.scenePos().toPoint()
        prov = self.get_province_from_position(pos)

        if prov:
            if event.button() == Qt.LeftButton:
                self.select_province(pos)

            if event.button() == Qt.RightButton:
                self.perform_mouse_press_action(event, pos, prov)

        super().mousePressEvent(event)
        self.update()

    def perform_mouse_press_action(self, event, position, prov):

        tag = db.current_country_tag

        if prov:
            if prov.is_explored:
                if event.modifiers() & Qt.ControlModifier:
                    self.update_city_position(position, prov)

                if event.modifiers() & Qt.AltModifier:
                    self.update_text_position_with_last(position, prov)

    def perform_mouse_double_press_action(self, event, position, prov):
        if event.modifiers() & Qt.ControlModifier:
            if prov:
                if prov.is_explored:
                    prov.change_country_capitol_province( )
        else:
            if prov:
                if prov.is_explored:
                    pass

    #
    #   KEYBOARD EVENTS
    #

    def keyPressEvent(self, event):

        if event.key() == Qt.Key_S:
            self.take_screenshot()

        if event.key() == Qt.Key_M:
            from map import map_loader
            map_loader.dump_all_map_data_to_files()

        #
        #   explore entire map
        #

        if event.key() == Qt.Key_P:
            manager_province.explore_entire_map()

        if event.key() == Qt.Key_D:
            self.dump_city_and_text_positions_to_png()

        #
        #   find province dialog
        #

        if event.key() == Qt.Key_Backslash:
            self.show_province_id_input()

        #
        #   next / prev country
        #

        if event.key() == Qt.Key_BracketRight:
            self.switch_to_next_country(1)

        if event.key() == Qt.Key_BracketLeft:
            self.switch_to_next_country(-1)

        #
        #   ZOOM
        #

        if event.key() == Qt.Key_Plus:
            self.increase_zoom()
        if event.key() == Qt.Key_Minus:
            self.decrease_zoom()

        if event.key() == Qt.Key_Space:
            manager_province.save_provinces_to_file()

        #
        #   switch zoom modes
        #

        if event.key() == Qt.Key_F1:
            map_mode.switch_map_mode('terrain')
        if event.key() == Qt.Key_F2:
            map_mode.switch_map_mode('culture')
        if event.key() == Qt.Key_F3:
            map_mode.switch_map_mode('religion')
        if event.key() == Qt.Key_F4:
            map_mode.switch_map_mode('goods')
        if event.key() == Qt.Key_F5:
            map_mode.switch_map_mode('climate')
        if event.key() == Qt.Key_F6:
            map_mode.switch_map_mode('politic')
        if event.key() == Qt.Key_F7:
            map_mode.switch_map_mode('region')
        if event.key() == Qt.Key_F8:
            map_mode.switch_map_mode('manpower')
        if event.key() == Qt.Key_F9:
            map_mode.switch_map_mode('trade')

        for province in db.provinces.values():
            province.change_details_based_on_zoom_level(db.current_zoom_index)

        super().keyPressEvent(event)
        self.update()

    #
    #   ZOOM CHANGE
    #

    def increase_zoom(self):
        if db.current_zoom_index < len(db.zoom_levels) - 1:
            db.current_zoom_index += 1
        self.apply_zoom()

    def decrease_zoom(self):
        if db.current_zoom_index > 0:
            db.current_zoom_index -= 1
        self.apply_zoom()

    def apply_zoom(self):
        self.game_view.resetTransform()
        self.game_view.scale(db.zoom_levels[db.current_zoom_index], db.zoom_levels[db.current_zoom_index])

        for province in db.provinces.values():
            province.change_details_based_on_zoom_level(db.current_zoom_index)

    #
    #   GRAPHICS CREATIONS
    #

    def create_graphics(self):
        print("  Create map objects graphics")
        self.create_provinces()
        self.create_borders()
        self.calculate_polygons_from_borders()
        self.create_roads()
        self.create_province_city_graphics()
        self.create_province_name_graphics()

    def create_provinces(self):
        rect_size = db.rect_size
        print("    Create provinces")
        for province_id, rects in db.province_rectangles.items():
            province = db.provinces.get(province_id)
            if province:
                province_rectangles = [QRectF(x * rect_size, y * rect_size, (x2 - x) * rect_size, (y2 - y) * rect_size)
                                       for x, y, x2, y2 in rects]
                province.scene = self
                province.set_tiles(province_rectangles)
                self.addItem(province)
                self.addItem(province.river_path)
                self.addItem(province.province_fog_of_war)
            else:
                print("ERROR, cannot find province in province manager", province_id)

    def create_borders(self):
        print("    Create borders")
        borders_data = db.province_border_map
        for province_id, province_info in borders_data.items():
            province = db.provinces.get(province_id)
            if province:
                for neighbor_id, border_lines in province_info.items():
                    border_key = tuple(sorted((province_id, neighbor_id)))
                    if border_key in db.borders_items:
                        continue
                    dist = db.province_neighbours_distance.get(border_key, None)
                    if dist is None:
                        print("  ERROR, distance is null", province_id, neighbor_id)
                    borders = BorderItem(border_lines, province_id, neighbor_id)
                    db.borders_items[border_key] = borders
                    province.borderlines[neighbor_id] = borders
                    province.neighbors_distance[neighbor_id] = dist
                    self.addItem(borders)
                    neighbor_province = db.provinces.get(neighbor_id)
                    if neighbor_province:
                        neighbor_province.borderlines[province_id] = borders
                        neighbor_province.neighbors_distance[province_id] = dist
                        neighbor_province.neighbors[province_id] = province
                        province.neighbors[neighbor_id] = neighbor_province

    def calculate_polygons_from_borders(self):
        print("    Calculate polygons from borders")
        for province in db.provinces.values():
            province.create_polygon_from_borders()

    def create_roads(self):
        print("    Create roads")
        for key, border in db.borders_items.items():
            border: BorderItem
            province1 = db.provinces.get(key[0])
            province2 = db.provinces.get(key[1])
            if province1 and province2 and province1.city_position and province2.city_position:
                p1_id = province1.province_id
                p2_id = province2.province_id
                if p1_id != p2_id:
                    road = RoadItem(province1, province2)
                    if p2_id not in province1.roads:
                        province1.roads[p2_id] = road
                    if p1_id not in province2.roads:
                        province2.roads[p1_id] = road
                    if (p1_id, p2_id) not in db.roads_items:
                        db.roads_items[(p1_id, p2_id)] = road
                    if (p2_id, p1_id) not in db.roads_items:
                        db.roads_items[(p2_id, p1_id)] = road
                    self.addItem(road)

    def create_province_city_graphics(self):
        print("    Create province city graphics")
        for province in db.provinces.values():
            if province.city_position:
                col, row = province.city_position
                if province.is_land:  # Land provinces
                    province.create_city_pixmap('city', 'city.png', self, col, row)
                    province.create_province_large_frame(self, col, row)
                    province.create_core_pixmap(self, col, row)
                    province.create_number_pixmap('numbers', 0, self,  col, row)
                else:  # Sea provinces
                    province.create_city_pixmap('city', 'sea.png', self, col, row)

    def create_province_name_graphics(self):
        print("    Create province name graphics")
        for province in db.provinces.values():
            if province.name_text_position:
                province.set_name_text(self, text=province.name, points=province.name_text_position)
                if len(province.name_text_position) != 2:
                    print('ERROR - province does not have proper name position', province.province_id, province.name)

    def create_units(self):
        print("    Create units")
        for province in db.provinces.values():
            if province.is_land and province.is_explored and province.country_owner_tag:
                unit = LandUnit(unit_type_tag='spearman', province_id=province.province_id,
                                owner_tag=province.country_owner_tag)
                province.armies.append(unit)
                self.addItem(unit)

    #
    #   NAVIGATION OVER MAP
    #

    def show_province_id_input(self):
        province_id, ok = QInputDialog.getInt(self.game_view, "Find Province", "Enter Province ID:")
        if ok:
            self.center_view_on_province(province_id)

    def center_view_on_province(self, province_id):

        province = db.provinces.get(province_id)

        if province:
            if province.is_explored:

                # Get the bounding rectangle of the province
                bounding_rect = province.boundingRect()
                # Calculate the center of the bounding rectangle
                center_point = bounding_rect.center()
                # Center the view on the calculated center point
                self.game_view.centerOn(center_point)


    def switch_to_next_country(self, change):
        self.current_country_tag_number = (self.current_country_tag_number + change) % len(db.countries)

        cnt = list(db.countries.keys())[self.current_country_tag_number]
        manager_province.switch_current_country_tag(cnt)
        map_mode.switch_map_mode('terrain')

    #
    #   SUPPORT METHODS
    #

    def take_screenshot(self):
        from PySide6.QtGui import QPixmap, QPainter
        print("Taking screenshot....")
        rect = self.itemsBoundingRect()
        image = QPixmap(rect.size().toSize())
        image.fill(Qt.transparent)
        painter = QPainter(image)
        self.render(painter, target=rect)
        painter.end()
        image.save( str(db.path_logs / 'screenshot.png'), 'png')
        print("Screenshot done")

    def dump_city_and_text_positions_to_png(self):
        from PySide6.QtGui import QPixmap, QPainter, QColor
        from PySide6.QtCore import QPoint

        print("Dumping city and text positions to PNG...")

        image = QPixmap(db.map_width, db.map_height)
        image.fill(Qt.transparent)
        painter = QPainter(image)

        for province in db.provinces.values():
            if province.city_position:
                col, row = province.city_position
                x = col
                y = row
                if province.is_land:
                    painter.setPen(QColor(255, 0, 255))  # Set color to pink
                else:
                    painter.setPen(QColor(255, 255, 255))  # Set color to white
                painter.drawPoint(QPoint(x, y))  # Draw city position

            if province.name_text_position:
                for col, row in list(province.name_text_position)[:2]:
                    x = col
                    y = row
                    painter.setPen(QColor(0,255,0))  # Set color to green
                    painter.drawPoint(QPoint(x, y))  # Draw city position

        painter.end()
        image.save(str(db.path_map / 'city_and_text_positions.png'), 'png')
        print("Dumping done")


    def update_text_position_with_last(self, position, prov):
        if hasattr(self, 'last_position'):
            prev_col, prev_row = self.last_position
            col = int(position.x() // db.rect_size)
            row = int(position.y() // db.rect_size)
            prov.update_text_position([(col, row), (prev_col, prev_row)])
            del self.last_position
        else:
            col = int(position.x() // db.rect_size)
            row = int(position.y() // db.rect_size)
            self.last_position = (col, row)

    def update_city_position(self, position, prov):
        rect_size = db.rect_size
        col = int(position.x() // rect_size)
        row = int(position.y() // rect_size)
        prov.city_position = (col, row)
        prov.move_pixmaps(col, row)