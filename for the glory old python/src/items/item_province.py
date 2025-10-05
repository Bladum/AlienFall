# src/province/province.py
import math

from PySide6.QtCore import QRectF
from PySide6.QtGui import QFont, Qt, QColor, QTextOption, QBrush, QPainterPath, QPainter, QPixmap
from PySide6.QtWidgets import QGraphicsItem

from battle.battle import LandArmy, NavalArmy
from items.item_border import BorderItem
from items.item_fogofwar import ProvinceFogOfWarOverlayItem
from items.item_river import RiverItem
from items.item_road import RoadItem
from ref.ref_area import GeoArea
from ref.ref_climate import Climate
from ref.ref_continent import GeoContinent
from ref.ref_culture import Culture
from ref.ref_goods import Goods
from ref.ref_region import GeoRegion
from ref.ref_religion import Religion
from ref.ref_terrain import Terrains
from src.db import Dice
from src.db import TDB

db = TDB()

TEXT_CENTER = QTextOption()
TEXT_CENTER.setAlignment(Qt.AlignCenter)

BRUSH_SELECTION = QBrush(QColor("#40000000"))



class ProvinceItem(QGraphicsItem):
    def __init__(self, prov_data):
        super().__init__()

        self.province_id = int(prov_data.get('id', 0))
        self.tiles = []     # rects
        self.color : QColor = QColor()
        self.bounding_rect : QRectF = None

        self.brush : QBrush = QBrush()
        self.brush_secondary : QBrush = QBrush()
        self.brush_effect : QBrush = QBrush()
        self.brush_terrain : QBrush = QBrush()

        self.province_fog_of_war : ProvinceFogOfWarOverlayItem = None
        self.province_path : QPainterPath = None

        self.setZValue( db.z_value_map_tile)

        self.pixmap: QPixmap = None  # Add pixmap attribute

        # diagonal effect color
        self.color_primary : QColor = None
        self.color_secondary : QColor = None

        # river

        self.river_path : RiverItem = None

        # basic info

        self.name = prov_data.get('name', "Province Name")
        self.is_land = prov_data.get('is_land', True)
        self.size = 0

        # other provinces nearby

        self.neighbors_distance : dict[int, int] = {}
        self.neighbors : dict[int, ProvinceItem] = {}

        # roads to other provinces

        self.roads : dict[int, RoadItem] = {}

        # borders to other provinces

        self.borderlines : dict[int, BorderItem] = {}

        # province city
        self.city_position = None
        self.army_position = None

        # buildings
        from ref.ref_building import Building
        self.buildings : list[Building] = []

        # name text positions

        self.name_text_position = set()

        # who is owner of province
        self.country_owner_tag = ''
        self.country_occupant_tag = ''

        # weather effects

        self.has_snow_or_ice = False          # snow on land, ice on water
        self.has_storm_or_hurricane = False   # storm on water, hurricane on land

        # details tags

        terrain_tag = prov_data.get('terrain', 'plains')
        self.terrain: Terrains = db.db_terrains.get(terrain_tag)

        culture_tag = prov_data.get('culture', 'nothing')
        self.culture : Culture = db.db_cultures.get( culture_tag )

        religion_tag = prov_data.get('religion', 'pagan')
        self.religion : Religion = db.db_religions.get( religion_tag )

        goods_tag = prov_data.get('goods', 'nothing')
        self.goods : Goods = db.db_goods.get(goods_tag)

        climate_tag = prov_data.get('climate', 'none')
        self.climate : Climate = db.db_climates.get(climate_tag)

        region_tag = prov_data.get('region', 'TBD')
        self.region : GeoRegion = db.db_regions.get(region_tag)

        continent_tag = prov_data.get('continent', 'TBD')
        self.continent : GeoContinent = db.db_continents.get(continent_tag)

        area_tag = prov_data.get('area', 'TBD')
        self.area : GeoArea = db.db_areas.get(area_tag)

        # gameplay

        self.population = 1
        self.population_growth = 0.05
        self.population_max = 10
        self.tax_value = 1
        self.trade_value = 1
        self.revolt_risk = 0
        self.manpower: int = int(prov_data.get('manpower', 0) or 0)
        self.manpower_max = self.manpower
        self.income : int = int(prov_data.get('tax', 0) or 0)

        # armies in province

        self.armies : list[LandArmy] = []
        self.navies : list[NavalArmy] = []

        # center of trade inside province

        from cot import CenterOfTrade
        self.center_of_trade : CenterOfTrade = None

        # pixmaps
        self.pixmap_province_name : QPixmap = None
        self.pixmap_province_city : QPixmap = None                # who is owner
        self.pixmap_province_large_frame : QPixmap = None     # if province is capital city
        self.is_country_capitol = False
        self.pixmap_province_core : QPixmap  = None
        self.pixmap_province_number : QPixmap  = None

        self.pixmap_province_city_show = True
        self.pixmap_province_large_frame_show = False
        self.pixmap_province_core_show = False
        self.pixmap_province_number_show = False

        # flags for visibility

        self.is_explored = True
        self.is_visible = True
        self.is_selected = False

        self.is_national = False
        self.is_core = False

        self.brush_terrain = db.db_colors_brush.get('terrain_' + terrain_tag)

    #
    #   GRAPHICS
    #

    def set_river(self):
        river_riles = db.province_river_tiles_list.get(self.province_id)
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
            self.size += tile.width() // db.rect_size * tile.height() // db.rect_size
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
        if self.is_selected:
            painter.setBrush(BRUSH_SELECTION)
            painter.setPen(Qt.NoPen)
            painter.drawPath(self.province_path)

    #
    #   show hide province
    #

    def view_province(self):
        self.is_visible = True
        self.province_fog_of_war.setVisible(False)

    def unview_province(self):
        self.is_visible = False
        self.province_fog_of_war.setVisible(True)

    def disable_fog_of_war(self):
        self.province_fog_of_war.setVisible(False)

    def enable_fog_of_war(self):
        if self.is_visible:
            self.province_fog_of_war.setVisible(False)
        else:
            self.province_fog_of_war.setVisible(True)

    #
    #   MILITARY
    #

    def total_number_of_units_in_province(self):

        val = [0, 0]

        for army in self.armies:
            val[0] += army.total_units

        for navy in self.navies:
            val[1] += navy.total_units

        return val

    #
    #   EXPLORATION
    #

    def explore_province_by_geography(self, prov_ids = None, names = None):

        if prov_ids:
            if self.province_id in prov_ids:
                self.explore_province()
                return True
        if names:
            if self.continent.tag in names or self.region.tag in names or self.area.tag in names:
                self.explore_province()
                return True

    def _set_province_exploration(self, visible):

        self.is_explored = visible

        # set him self
        self.setVisible(visible)

        # river
        if self.river_path:
            self.river_path.setVisible(visible)

        # set all tile borders
        for key, bord in self.borderlines.items():
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
        if self.pixmap_province_core and ( self.is_core or self.is_national) :
            self.pixmap_province_core.setVisible(self.pixmap_province_core_show and visible)

        # fog of war pixmap
        if self.province_fog_of_war:
            self.province_fog_of_war.setVisible(visible)

    def explore_province(self):
        self._set_province_exploration(True)

    def unexplore_province(self):
        self._set_province_exploration(False)

    #
    #   select deselect
    #

    def select_province(self):
        self.is_selected = True

    def deselect_province(self):
        self.is_selected = False

    #
    #   change visuals of province
    #

    def set_snow_or_ice_status(self, new_status):
        self.has_snow_or_ice = new_status

    def process_weather_effects(self):
        # check which month it is
        # check climate
        # check chance to SNOW on land
        # check chance to ICE on water
        # check chance to STORM on water
        # check chance to HURRICANE on land

        # apply effects on province data
        # apply visuals -> works only on terrain map

        pass

    #
    #   METHODS TO SET STATE
    #

    def set_province_background_colors(self,
                                       primary_color = None,
                                       weather_effect = None,
                                       secondary_color = None):

        # primary color brush

        if primary_color:
            self.brush = db.db_colors_brush.get( primary_color )

        # secondary color with 50% coverage

        if secondary_color:
            self.brush_secondary = db.db_colors_brush.get( secondary_color + "_half" , None)
        else:
            self.brush_secondary = None

        # weather effects like SNOW, ICE, STORM, MUD

        if weather_effect:
            self.brush_effect = db.db_colors_brush.get( "effect_" + weather_effect )
        else:
            self.brush_effect = None

    def set_city_pixmap(self,
                        category = 'city',
                        name = 'city.png' ):

        self.pixmap_province_city_show = True

        if self.pixmap_province_city:
            # set capital pixmap
            image = db.res_images[category].get(name, None)
            if image:
                self.pixmap_province_city.setPixmap(image)
            else:
                image = db.res_images['city'].get('city.png')
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

            image = db.res_images[category].get(number, None)
            if image:
                self.pixmap_province_number.setPixmap(image)
            else:
                image = db.res_images['numbers'].get(0)
                self.pixmap_province_number.setPixmap(image)


    def set_core_pixmap(self, enable, is_core = True):

        if self.pixmap_province_core:
            self.is_core = False
            self.is_national = False
            image = None

            if enable:
                if is_core:
                    image = db.res_images['city']["core.png"]
                    self.is_core = True
                else:
                    image = db.res_images['city']["claim.png"]
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
                    image = db.res_images['stability'].get(f'stab0{stab_level + 3}.png', None)
                else:
                    image = db.res_images['stability'].get(f'stab03.png', None)
                self.pixmap_province_large_frame.setPixmap(image)
                self.pixmap_province_large_frame.setVisible(True)
                self.pixmap_province_large_frame_show = True

    #
    #   METHODS TO CREATE STATE
    #

    def create_province_large_frame(self, scene, col, row):

        image = db.res_images['stability']["stab03.png"]

        # if no image then create image
        if scene:
            pixmap_item = scene.addPixmap(image)
            pixmap_item.setOffset(col * db.rect_size + (db.rect_size - image.width()) / 2,
                                  row * db.rect_size + (db.rect_size - image.height()) / 2)
            pixmap_item.setZValue(db.z_value_city - 1)
            self.pixmap_province_large_frame = pixmap_item
            pixmap_item.setVisible(False)

    def create_city_pixmap(self, category, name, scene, col, row):
        image = db.res_images[category][name]

        # if no image then create image
        if scene:
            pixmap_item = scene.addPixmap(image)
            pixmap_item.setOffset(col * db.rect_size + (db.rect_size - image.width()) / 2,
                                  row * db.rect_size + (db.rect_size - image.height()) / 2)
            pixmap_item.setZValue(db.z_value_city)
            self.pixmap_province_city = pixmap_item

    def create_number_pixmap(self, category, name, scene, col, row):
        image = db.res_images[category][name]

        # if no image then create image
        if scene:
            pixmap_item = scene.addPixmap(image)
            pixmap_item.setOffset(col * db.rect_size + (db.rect_size - image.width()) / 2,
                                  (row + 1) * db.rect_size + (db.rect_size - image.height()) / 2)
            pixmap_item.setZValue(db.z_value_army)
            self.pixmap_province_number = pixmap_item

    def create_core_pixmap(self, scene, col, row):

        # if no image then create image
        if scene:
            image = db.res_images['city']["core.png"]

            pixmap_item = scene.addPixmap(image)
            pixmap_item.setOffset(col * db.rect_size + (db.rect_size - image.width()) / 2,
                                  (row-1) * db.rect_size + (db.rect_size - image.height()) / 2)
            pixmap_item.setZValue(db.z_value_city + 1)
            self.pixmap_province_core = pixmap_item
            self.pixmap_province_core.setVisible(False)

    def move_pixmaps(self, col, row):

        self.city_position = (col, row)

        if not self.pixmap_province_city:
            self.create_city_pixmap('city', 'city.png', self.scene, col, row)
        else:
            self.pixmap_province_city.setOffset(
                col * db.rect_size + (db.rect_size - self.pixmap_province_city.pixmap().width()) / 2,
                row * db.rect_size + (db.rect_size - self.pixmap_province_city.pixmap().height()) / 2)

        if not self.pixmap_province_number:
            self.create_city_pixmap('numbers', 0, self.scene, col, row)
        else:
            self.pixmap_province_number.setOffset(
                col * db.rect_size + (db.rect_size - self.pixmap_province_number.pixmap().width()) / 2,
                (row + 1) * db.rect_size + (db.rect_size - self.pixmap_province_number.pixmap().height()) / 2)

        if not self.pixmap_province_core:
            self.create_core_pixmap(self.scene, col, row - 1)
        else:
            self.pixmap_province_core.setOffset(
                col * db.rect_size + (db.rect_size - self.pixmap_province_core.pixmap().width()) / 2,
                (row - 1) * db.rect_size + (db.rect_size - self.pixmap_province_core.pixmap().height()) / 2)

        if not self.pixmap_province_large_frame:
            self.create_province_large_frame(self.scene, col, row)
        else:
            self.pixmap_province_large_frame.setOffset(
                col * db.rect_size + (db.rect_size - self.pixmap_province_large_frame.pixmap().width()) / 2,
                row * db.rect_size + (db.rect_size - self.pixmap_province_large_frame.pixmap().height()) / 2)

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
        x1, y1 = col1 * db.rect_size + db.rect_size / 2, row1 * db.rect_size + db.rect_size / 2
        x2, y2 = col2 * db.rect_size + db.rect_size / 2, row2 * db.rect_size + db.rect_size / 2
        mid_x = (x1 + x2) / 2
        mid_y = (y1 + y2) / 2
        angle = math.degrees(math.atan2(y2 - y1, x2 - x1))
        angle = angle - 180 if angle > 90 else angle + 180 if angle < -90 else angle

        text_to_display = self.name
        if not text_to_display:
            return

        font_size = db.font_size_land if self.is_land else db.font_size_sea
        font_size += int(math.sqrt(self.size) // 3) - len(text_to_display) // 4 + 1
        font_color = db.color_font_land if self.is_land else db.color_font_sea
        z_value =  db.z_value_prov_name

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
        self.name_text_position = set(points)
        x1, y1 = col1 * db.rect_size + db.rect_size / 2, row1 * db.rect_size + db.rect_size / 2
        x2, y2 = col2 * db.rect_size + db.rect_size / 2, row2 * db.rect_size + db.rect_size / 2
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
        font_size = db.font_size_land if self.is_land else db.font_size_sea
        font_size += int(math.sqrt(self.size) // 3) - len(self.name) // 4 + 1
        font = QFont('Consolas', font_size, QFont.Bold)
        self.pixmap_province_name.setFont(font)

    #
    #   METHODS TO MANAGE ZOOM LEVELS
    #

    def _hide_city(self):
        if self.is_explored:
            if self.pixmap_province_city and self.pixmap_province_city_show:
                self.pixmap_province_city.setVisible(False)
            if self.pixmap_province_number and self.pixmap_province_number_show:
                self.pixmap_province_number.setVisible(False)
            if self.pixmap_province_large_frame and self.pixmap_province_large_frame_show:
                self.pixmap_province_large_frame.setVisible(False)
            if self.pixmap_province_core and self.pixmap_province_core_show:
                self.pixmap_province_core.setVisible(False)

    def _hide_river(self):
        if self.river_path and self.is_explored:
            self.river_path.setVisible(False)

    def _hide_name(self):
        if self.pixmap_province_name and self.is_explored:
            self.pixmap_province_name.setVisible(False)

    def _show_river(self):
        if self.river_path and self.is_explored:
            self.river_path.setVisible(True)

    def _show_city(self):
        if self.is_explored:
            if self.pixmap_province_city and self.pixmap_province_city_show:
                self.pixmap_province_city.setVisible(True)
            if self.pixmap_province_number and self.pixmap_province_number_show:
                self.pixmap_province_number.setVisible(True)
            if self.pixmap_province_large_frame and self.pixmap_province_large_frame_show:
                self.pixmap_province_large_frame.setVisible(True)
            if self.pixmap_province_core and self.pixmap_province_core_show:
                self.pixmap_province_core.setVisible(True)

    def _show_name(self):
        if self.pixmap_province_name and self.is_explored:
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


    #
    #   GAME PLAY
    #

    def process_all(self):
        pass

    def process_all_occupied(self):
        pass

    #
    #   MANAGE CHANGE STATE OF PROVINCE
    #

    def add_neighbor(self, neighbor_id, distance):
        self.neighbors_distance[neighbor_id] = distance

    def remove_neighbor(self, neighbor_id):
        if neighbor_id in self.neighbors_distance.keys():
            self.neighbors_distance.pop(neighbor_id)

    #
    #   PROVINCE OWNER ? OCCUPANT
    #

    def change_country_capitol_province(self):

        # if there is owner
        if self.country_owner_tag:
            country = db.countries.get(self.country_owner_tag)

            if country:
                country.change_country_capital_province(self)

    def change_province_owner(self, new_owner_tag, change_occupant = False):

        country = db.countries.get(new_owner_tag, None)
        if country:

            # update globals
            db.country_province_owner_dict[self.province_id] = new_owner_tag
            self.country_owner_tag = new_owner_tag

            # update borders for me
            for k, border in self.borderlines.items():
                border.detect_border_type()

            # update owner color
            self.set_province_background_colors( country.color, None )

            # in general when owner is changed then occupant is also changed
            if change_occupant:
                self.change_province_occupant(new_owner_tag)

    def change_province_occupant(self, new_occupant_tag):

        country = db.countries.get(new_occupant_tag, None)
        if country:

            # update globals
            self.country_occupant_tag = new_occupant_tag
            db.country_province_occupant_dict[self.province_id] = new_occupant_tag

            # change city image
            self.set_city_pixmap('flag_frame', new_occupant_tag + ".png")

            # if its different then owner define occupacy
            if self.country_occupant_tag != self.country_owner_tag:
                self.set_province_background_colors( primary_color = None,
                                                     secondary_color = country.color)
            else:
                self.set_province_background_colors(primary_color=None,
                                                    secondary_color=None)

    def reset_province_occupant_to_owner(self):
        self.change_province_occupant(self.country_owner_tag)


    #
    #   GAME LOGIC
    #

    def calculate_game_logic(self):

        self.manpower_max = self.calculate_manpower_value()
        self.population_growth = self.calculate_population_growth()
        self.tax_value = self.calculate_tax_value()
        self.trade_value = self.calculate_trade_value()
        self.revolt_risk = self.calculate_revolt_risk_value()

        # regenerate manpower all within 2 years = 24 months
        self.manpower += min( self.manpower_max / 24, self.manpower_max )

        # grow population
        self.population += self.population_growth

        # check revolt risk
        check_for_revolt = Dice.K100(self.revolt_risk)
        if check_for_revolt:
            self.create_rebel_army()

    def create_rebel_army(self):
        pass

    def calculate_manpower_value(self):

        # base value is 50% of population but minimum 1
        val = max( self.population // 2, 1)

        # if there is owner
        if self.country_owner_tag:

            # from country
            country = db.countries.get(self.country_owner_tag)
            if country:

                # this is national province
                is_national = True if self.province_id in country.national_provinces.keys() else False
                if not is_national:
                    val *= 0.5

                # from country policies
                mod = 1.0
                for pol in country.policies:
                    if is_national:
                        mod *= pol.modifiers.mod_manpower_national
                    else:
                        mod *= pol.modifiers.mod_manpower_other
                    mod *= pol.modifiers.mod_army_manpower
                val *= mod

                # from state religion
                val *= country.state_religion.modifiers.mod_army_manpower

                # TODO from war taxes

                # TODO at war
                if country.war_time > 0:
                    val *= 1.5

                # is capitol
                if country.capitol_province == self:
                    val *= 1.25

        # province is occupied then very low
        if self.country_owner_tag != self.country_occupant_tag:
            val *= 0.25

        # from buildings
        for bui in self.buildings:
            val *= bui.modifiers.mod_army_manpower

        # from goods
        good_det = self.goods
        if good_det:
            mod = good_det.modifiers.get('mod_army_manpower')
            if mod:
                val *= mod

        return val

    def calculate_revolt_risk_value(self):

        # base value
        val = -2

        if self.country_owner_tag:

            # from country
            country = db.countries.get(self.country_owner_tag)
            if country:

                # from country stability
                stability_mod = -country.budget.stability
                val += stability_mod

                # from country policies
                mod = 0
                for pol in country.policies:
                    mod += pol.modifiers.mod_revolt_risk
                val += mod

                # from state religion
                val += country.state_religion.modifiers.mod_revolt_risk

                # from tax level on country level
                val += country.budget.level_tax_revolt

                # wrong religion
                if country.state_religion.tag != self.religion.tag:
                    val += 3

                # wrong culture
                # TODO

                # how long in state of war 3 months = -1
                war_war = country.war_time
                mod = 1.0
                for pol in country.policies:
                    mod *= pol.modifiers.mod_war_exhaustion
                val += war_war * round(mod, 0)

                # is capitol
                if country.capitol_province == self:
                    val -= 2

        # from buildings
        for bui in self.buildings:
            val += bui.modifiers.mod_revolt_risk

        # check all armies to see if army can reduce revolt risk
        for army in self.armies:
            army_size = army.units
            if army.owner_tag == self.country_owner_tag:
                val -= army_size * 0.2
            else:
                val += army_size * 0.2

        # from goods
        good_det = self.goods
        if good_det:
            mod = good_det.modifiers.get('mod_revolt_risk')
            if mod:
                val += mod

        return val

    def calculate_tax_value(self):

        # base value
        val = self.population

        if self.country_owner_tag:

            # from country
            country = db.countries.get(self.country_owner_tag)
            if country:

                stab_mod = [0.8, 0.9, 1, 1, 1, 1.1, 1.2]
                # from country stability
                stability_mod = stab_mod[ country.budget.stability + 3]
                val *= stability_mod

                # from country policies
                mod = 0
                for pol in country.policies:
                    mod *= pol.modifiers.mod_production_income
                val += mod

                # from state religion
                val *= country.state_religion.modifiers.mod_production_income

                # from tax level on country level
                val *= country.budget.level_tax

                # wrong religion
                if country.state_religion.tag != self.religion_tag:
                    val *= 0.75

                # wrong culture
                # TODO

                # no connection to capitol
                # TODO

                # is capitol
                if country.capitol_province == self:
                    val *= 1.2

        # from buildings
        for bui in self.buildings:
            val *= bui.modifiers.mod_production_income

        # from goods
        good_det =  self.goods
        if good_det:
            mod = good_det.modifiers.get('mod_production_income')
            if mod:
                val *= mod

        # the bigger population the bigger effect
        mod = 0.5 + (self.population // 5)
        mod = max(0.5, min(3.0, 0.5 + (self.population // 5)))
        val *= mod

        # from enemy army
        # from province looted

        return val

    def calculate_trade_value(self):
        # basic trade value of a resource from 5 to 25
        # modifier from population

        # base value
        val = 5.0

        if self.country_owner_tag:

            # from country
            country = db.countries.get(self.country_owner_tag)
            if country:

                # from country policies
                mod = 0
                for pol in country.policies:
                    mod *= pol.modifiers.mod_trade_value

                val += mod

        # from buildings
        for bui in self.buildings:
            val *= bui.modifiers.mod_trade_value

        # goods
        good_det = self.goods
        if good_det:
            mod = good_det.modifiers.get('mod_trade_value')
            if mod:
                val *= mod

        # the bigger population the bigger effect
        mod = 0.5 + (self.population // 5)
        mod = max(0.5, min(3.0, 0.5 + (self.population // 5)))
        val *= mod

        # from enemy army
        # from province looted

        return val

    def calculate_population_growth(self):

        # base value
        val = 2.0

        if self.country_owner_tag:

            # from country
            country = db.countries.get(self.country_owner_tag)
            if country:
                # from stability
                val += country.budget.stability

                # from country policies
                mod = 0
                for pol in country.policies:
                    mod += pol.modifiers.mod_population_growth

                val += mod

        # from buildings
        for bui in self.buildings:
            val += bui.modifiers.mod_population_growth

        # goods
        good_det = self.goods
        if good_det:
            mod = good_det.modifiers.get('mod_population_growth')
            if mod:
                val += mod

        # from climate
        climate_tag = self.climate
        if climate_tag:
            mod = climate_tag.modifiers.get('mod_population_growth')
            if mod:
                val += mod

        # the bigger population the slower the growth
        if self.population > self.population_max:
            val -= (self.population - self.population_max)

        # from enemy army
        # from province looted
        # from being capitol province
        # from terrain type ?

        return val

    #
    #   ROADS
    #

    def add_road(self, neighbor_province):
        road = RoadItem(self, neighbor_province)
        self.roads[ neighbor_province.province_id ] = road
        neighbor_province.roads[ self.province_id] = road
        return road

    def show_all_roads(self):
        for road in self.roads.values():
            road.show_road()

    def hide_all_roads(self):
        for road in self.roads.values():
            road.hide_road()

    #
    #   province return tool tip per game mode map
    #

    def get_province_tooltip(self, map_mode):

        tooltip_text =  f"Province:    {self.name} ({self.province_id})\n"
        tooltip_text += f"Owner:       {self.country_owner_tag} ( {self.country_occupant_tag} )\n\n"

        match map_mode:

            case 'politic':
                country = db.countries.get(db.current_country_tag)
                if country:
                    if self.province_id in country.national_provinces.keys():
                        tooltip_text += f"National:    True \n"
                    if self.province_id in country.claim_provinces.keys():
                        tooltip_text += f"Claimed:     True"

                if len( self.armies ) > 0:
                    tooltip_text += f"\n\nArmies:"
                    for arm in self.armies:
                        tooltip_text += f"\n  {arm.get_desc()}"

                if len( self.navies ) > 0:
                    tooltip_text += f"\n\nNavies:"
                    for arm in self.navies:
                        tooltip_text += f"\n  {arm.get_desc()}"

            case 'culture':
                if self.country_owner_tag:
                    country = db.countries.get( self.country_owner_tag)
                    if country:
                        accepted_cultures = ', '.join( country.accepted_cultures_tag )
                        tooltip_text +=  f"State:       {accepted_cultures} \n"
                if self.culture:
                    tooltip_text +=  f"Local:       {self.culture.tag}"

            case 'religion':
                if self.country_owner_tag:
                    country = db.countries.get( self.country_owner_tag)
                    if country:
                        state_religion = country.state_religion
                        tooltip_text +=  f"State:       {state_religion.tag} \n"
                if self.culture:
                    tooltip_text +=  f"Local:       {self.religion.tag}"

            case 'goods':
                if self.goods:
                    tooltip_text +=  f"Goods:       {self.goods.tag} \n"
                    tooltip_text +=  f"Value:       {self.goods.value}"

            case 'climate':
                if self.climate:
                    snow_months = ','.join(map(str, self.climate.snow_months))
                    tooltip_text +=  f"Climate:     {self.climate.tag} \n"
                    tooltip_text +=  f"Snowing:     {snow_months} "

            case 'terrain':
                if self.terrain:
                    tooltip_text +=  f"Terrain:     {self.terrain.tag}"

                if len( self.armies ) > 0:
                    tooltip_text += f"\n\nArmies:"
                    for arm in self.armies:
                        tooltip_text += f"\n  {arm.get_desc()}"

                if len( self.navies ) > 0:
                    tooltip_text += f"\n\nNavies:"
                    for arm in self.navies:
                        tooltip_text += f"\n  {arm.get_desc()}"

            case 'trade':
                if self.center_of_trade:
                    tooltip_text +=  f"CoT:         {self.center_of_trade.name}\n"
                    tooltip_text +=  f"Value:       {self.center_of_trade.value}\n"
                    tooltip_text +=  f"Stability:   {self.center_of_trade.stability}\n"
                    tooltip_text +=  f"Merchants:   {len(self.center_of_trade.merchants)}"

            case 'region':
                if self.continent:
                    tooltip_text +=  f"Continent:   {self.continent.tag} \n"
                if self.region:
                    tooltip_text +=  f"Region:      {self.region.tag} \n"
                if self.area:
                    tooltip_text +=  f"Area:        {self.area.tag} \n\n"

                if self.region:
                    tooltip_text +=  f"Natives:     {self.region.natives} \n"
                    tooltip_text +=  f"Pirates:     {self.region.piracy} \n"
                    tooltip_text +=  f"Revolts:     {self.region.revolt_strength * 100:.2f}%"

        return tooltip_text
