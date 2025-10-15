'''

GAME SCENE

Class related to manage all interaction with user and graphics management


'''

from managers import map_manager
from object.province import Province
from items.item_province import ProvinceItem
from items.item_road import RoadItem
from PySide6.QtGui import QPainter
from PySide6.QtWidgets import QGraphicsView, QGraphicsScene, QToolTip, QInputDialog
from items.item_border import BorderItem


from PySide6.QtCore import Qt, QRectF, QPoint


#
#   HERE GOES ALL INTERACTION WITH USER
#

class GameScene(QGraphicsScene):

    def __init__(self, main_window, game_view):
        super().__init__()

        print("Create game scene")

        self.main_window = main_window
        from core.game_state import GameState
        self.gs :GameState = main_window.game_state
        from controllers.game_controller import GameController
        self.gc : GameController = main_window.game_controller

        # Store the passed game view
        self.game_view = game_view

        # Configure the view for dragging
        self.game_view.setDragMode(QGraphicsView.ScrollHandDrag)
        self.game_view.setTransformationAnchor(QGraphicsView.AnchorUnderMouse)
        self.game_view.setResizeAnchor(QGraphicsView.AnchorUnderMouse)

        # Disable scrollbars
        self.game_view.setHorizontalScrollBarPolicy(Qt.ScrollBarAlwaysOff)
        self.game_view.setVerticalScrollBarPolicy(Qt.ScrollBarAlwaysOff)

        # Keep the arrow cursor instead of the hand cursor
        self.game_view.viewport().setCursor(Qt.ArrowCursor)

        self.setItemIndexMethod(QGraphicsScene.NoIndex)
        self.setBackgroundBrush(Qt.white)
        self.game_view.setRenderHint(QPainter.Antialiasing, False)
        self.game_view.setRenderHint(QPainter.TextAntialiasing, False)
        self.game_view.setRenderHint(QPainter.SmoothPixmapTransform, False)
        self.game_view.setOptimizationFlag(QGraphicsView.DontAdjustForAntialiasing, True)
        #self.game_view.setCacheMode(QGraphicsView.CacheBackground)
        self.game_view.setViewportUpdateMode(QGraphicsView.BoundingRectViewportUpdate)
        self.game_view.setOptimizationFlag(QGraphicsView.DontSavePainterState, True)

        self.current_country_tag_number = 0
        self.selected_color = ''
        self.selected_province : Province = None
        self.selected_province_id = None

    #
    # MOUSE MOVE TOOLTIP
    #

    def mouseMoveEvent(self, event):
        pos = event.scenePos().toPoint()
        prov : Province = self.get_province_from_position(pos)
        if prov:
            if prov.is_explored:
                tooltip_text = prov.get_province_tooltip( self.gs.current_map_mode )
            else:
                tooltip_text = 'Terra Incognita'
            QToolTip.showText(event.screenPos() + QPoint(0, 0), tooltip_text, self.game_view, msecShowTime=20000)
        else:
            QToolTip.hideText()
        super().mouseMoveEvent(event)
    #
    #   PROVINCE SELECTION
    #

    def get_province_from_position(self, position):

        rect_size = self.gs.rect_size

        col = int(position.x() // rect_size)
        row = int(position.y() // rect_size)

        if 0 <= row < len(self.gs.province_id_map) and 0 <= col < len(self.gs.province_id_map[0]):
            province_id = self.gs.province_id_map[row][col]

            province = self.gs.provinces.get(province_id, None)
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

    def mousePressEvent(self, event):
        # Store position for possible province selection later
        self._click_position = event.scenePos()

        # Let the parent class handle dragging
        super().mousePressEvent(event)

    def mouseReleaseEvent(self, event):
        pos = event.scenePos().toPoint()

        # Only handle as a click if the mouse hasn't moved much
        if hasattr(self, '_click_position'):
            delta = (event.scenePos() - self._click_position).manhattanLength()

            # If it's a small movement, consider it a click
            if delta < 5:
                prov = self.get_province_from_position(pos)
                if prov:
                    if event.button() == Qt.LeftButton:
                        self.select_province(pos)
                    elif event.button() == Qt.RightButton:
                        self.perform_mouse_press_action(event, pos, prov)

            # Clean up the stored position
            del self._click_position

        super().mouseReleaseEvent(event)
        self.update()

    def perform_mouse_press_action(self, event, position, prov):

        tag = self.gs.current_country_tag

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
            self.gc.map_manager.dump_all_map_data_to_files()

        #
        #   explore entire map
        #

        if event.key() == Qt.Key_P:
            self.gc.province_manager.explore_entire_map()

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
            for province in self.gs.provinces.values():
                province.province_item.change_details_based_on_zoom_level(self.gs.current_zoom_index)
        if event.key() == Qt.Key_Minus:
            self.decrease_zoom()
            for province in self.gs.provinces.values():
                province.province_item.change_details_based_on_zoom_level(self.gs.current_zoom_index)

        #
        #   switch zoom modes
        #

        super().keyPressEvent(event)
        self.update()

    #
    #   ZOOM CHANGE
    #

    def increase_zoom(self):
        if self.gs.current_zoom_index < len( self.gs.zoom_levels) - 1:
            self.gs.current_zoom_index += 1
        self.apply_zoom()

    def decrease_zoom(self):
        if self.gs.current_zoom_index > 0:
            self.gs.current_zoom_index -= 1
        self.apply_zoom()

    def apply_zoom(self):
        self.game_view.resetTransform()
        self.game_view.scale(self.gs.zoom_levels[self.gs.current_zoom_index], self.gs.zoom_levels[self.gs.current_zoom_index])

        for province in self.gs.provinces.values():
            province.province_item.change_details_based_on_zoom_level(self.gs.current_zoom_index)

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
        self.apply_zoom()

    def create_provinces(self):
        rect_size = self.gs.rect_size
        print("    Create province graphics on map")
        for province_id, rects in self.gs.province_rectangles.items():
            province = self.gs.provinces.get(province_id)
            if province:
                province_rectangles = [QRectF(x * rect_size, y * rect_size, (x2 - x) * rect_size, (y2 - y) * rect_size)
                                       for x, y, x2, y2 in rects]
                province.province_item = ProvinceItem(province, self)
                province.province_item.set_tiles(province_rectangles)
                self.addItem(province.province_item)
                self.addItem(province.province_item.river_path)
                self.addItem(province.province_item.province_fog_of_war)
            else:
                print("ERROR, cannot find province in province manager", province_id)

    def create_borders(self):
        print("    Create borders")
        borders_data = self.gs.province_border_map
        for province_id, province_info in borders_data.items():
            province = self.gs.provinces.get(province_id)
            if province:
                for neighbor_id, border_lines in province_info.items():
                    border_key = tuple(sorted((province_id, neighbor_id)))
                    if border_key in self.gs.borders_items:
                        continue
                    dist = self.gs.province_neighbours_distance.get(border_key, None)
                    if dist is None:
                        print("  ERROR, distance is null", province_id, neighbor_id)
                    borders = BorderItem(border_lines, province_id, neighbor_id)
                    self.gs.borders_items[border_key] = borders
                    province.borderlines[neighbor_id] = borders
                    province.neighbors_distance[neighbor_id] = dist
                    self.addItem(borders)
                    neighbor_province = self.gs.provinces.get(neighbor_id)
                    if neighbor_province:
                        neighbor_province.borderlines[province_id] = borders
                        neighbor_province.neighbors_distance[province_id] = dist
                        neighbor_province.neighbors[province_id] = province
                        province.neighbors[neighbor_id] = neighbor_province

    def calculate_polygons_from_borders(self):
        print("    Calculate polygons from borders")
        for province in self.gs.provinces.values():
            province.province_item.create_polygon_from_borders()

    def create_roads(self):
        print("    Create roads")
        for key, border in self.gs.borders_items.items():
            border: BorderItem
            province1 = self.gs.provinces.get(key[0])
            province2 = self.gs.provinces.get(key[1])
            if province1 and province2 and province1.city_position and province2.city_position:
                p1_id = province1.province_id
                p2_id = province2.province_id
                if p1_id != p2_id:
                    road = RoadItem(province1, province2)
                    if p2_id not in province1.roads:
                        province1.roads[p2_id] = road
                    if p1_id not in province2.roads:
                        province2.roads[p1_id] = road
                    if (p1_id, p2_id) not in self.gs.roads_items:
                        self.gs.roads_items[(p1_id, p2_id)] = road
                    if (p2_id, p1_id) not in self.gs.roads_items:
                        self.gs.roads_items[(p2_id, p1_id)] = road
                    self.addItem(road)

    def create_province_city_graphics(self):
        print("    Create province city graphics")
        for province in self.gs.provinces.values():
            province_item = province.province_item
            if province.city_position:
                col, row = province.city_position
                if province.is_land:  # Land provinces
                    province_item.create_city_pixmap('city', 'city.png', self, col, row)
                    province_item.create_province_large_frame(self, col, row)
                    province_item.create_core_pixmap(self, col, row)
                    province_item.create_number_pixmap('numbers', 0, self,  col, row)
                else:  # Sea provinces
                    province_item.create_city_pixmap('city', 'sea.png', self, col, row)

    def create_province_name_graphics(self):
        print("    Create province name graphics")
        for province in self.gs.provinces.values():
            province_item = province.province_item
            if province.name_text_position:
                province_item.set_name_text(self, text=province.name, points=province.name_text_position)
                if len(province.name_text_position) != 2:
                    print('ERROR - province does not have proper name position', province.province_id, province.name)

    #
    #   NAVIGATION OVER MAP
    #

    def show_province_id_input(self):
        province_id, ok = QInputDialog.getInt(self.game_view, "Find Province", "Enter Province ID:")
        if ok:
            self.center_view_on_province(province_id)

    def center_view_on_province(self, province_id):

        province = self.gs.provinces.get(province_id)

        if province:
            if province.is_explored:

                # Get the bounding rectangle of the province
                bounding_rect = province.province_item.boundingRect()
                # Calculate the center of the bounding rectangle
                center_point = bounding_rect.center()
                # Center the view on the calculated center point
                self.game_view.centerOn(center_point)

    def switch_to_next_country(self, change):
        self.current_country_tag_number = (self.current_country_tag_number + change) % len( self.gs.countries)

        cnt = list(self.gs.countries.keys())[self.current_country_tag_number]
        self.gc.province_manager.switch_current_country_tag(cnt)
        self.gc.map_manager.switch_map_mode('terrain')

        country = self.gs.countries.get(cnt)
        if country and country.capitol_province:
            self.center_view_on_province(country.capitol_province.province_id)


    def switch_to_country_by_tag(self):
        self.gc.province_manager.switch_current_country_tag( self.gs.current_country_tag )
        self.gc.map_manager.switch_map_mode('terrain')

        country = self.gs.countries.get( self.gs.current_country_tag )
        if country and country.capitol_province:
            self.center_view_on_province(country.capitol_province.province_id)

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
        image.save( str( self.gs.path_logs / 'screenshot.png'), 'png')
        print("Screenshot done")

    def dump_city_and_text_positions_to_png(self):
        from PySide6.QtGui import QPixmap, QPainter, QColor
        from PySide6.QtCore import QPoint

        print("Dumping city and text positions to PNG...")

        image = QPixmap(self.gs.map_width, self.gs.map_height)
        image.fill(Qt.transparent)
        painter = QPainter(image)

        for province in self.gs.provinces.values():
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
        image.save(str( self.gs.path_map / 'layers' / 'map_capitals_fix.png'), 'png')
        print("Dumping done")


    def update_text_position_with_last(self, position, prov):
        if hasattr(self, 'last_position'):
            prev_col, prev_row = self.last_position
            col = int(position.x() // self.gs.rect_size)
            row = int(position.y() // self.gs.rect_size)
            prov.update_text_position([(col, row), (prev_col, prev_row)])
            del self.last_position
        else:
            col = int(position.x() // self.gs.rect_size)
            row = int(position.y() // self.gs.rect_size)
            self.last_position = (col, row)

    def update_city_position(self, position, prov):
        rect_size = self.gs.rect_size
        col = int(position.x() // rect_size)
        row = int(position.y() // rect_size)
        prov.city_position = (col, row)
        prov.move_pixmaps(col, row)