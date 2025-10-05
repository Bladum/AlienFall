# editor.py
from PySide6.QtWidgets import QApplication, QMainWindow, QListWidget, QGraphicsView, QGraphicsScene, \
    QGraphicsPixmapItem, QVBoxLayout, QWidget, QHBoxLayout, QLineEdit, QCheckBox
from PySide6.QtGui import QPixmap, QColor, QMouseEvent, QPainter, QImage, QShortcut, QKeySequence, QPen, QAction
from PySide6.QtCore import Qt, QRectF, QPointF, QSize

map_size_x = 1200
map_size_y = 500
grid_size = 10

world_size_x = map_size_x * grid_size
world_size_y = map_size_y * grid_size

#
#   MAIN WINDOW
#

class MainWindow(QMainWindow):
    def __init__(self):
        super().__init__()
        self.setWindowTitle("Province Editor")
        font = self.font()
        font.setPointSize(12)
        self.setFont(font)
        self.setGeometry(100, 100, 1200, 800)

        # Initialize province_colors dictionary
        self.province_colors = {}

        # Main layout
        main_layout = QHBoxLayout()

        # Left layout for brush size and province list
        left_layout = QVBoxLayout()

        # Brush size widget
        self.brush_size_widget = QListWidget()
        self.brush_size_widget.addItems(["1x1", "3x3", "5x5"])
        self.brush_size_widget.setFixedWidth(200)
        self.brush_size_widget.setFixedHeight(90)
        self.brush_size_widget.currentItemChanged.connect(self.update_brush_size)
        left_layout.addWidget(self.brush_size_widget)

        # Filter line edit
        self.filter_line_edit = QLineEdit()
        self.filter_line_edit.setFixedWidth(200)
        self.filter_line_edit.setPlaceholderText("Filter provinces...")
        self.filter_line_edit.textChanged.connect(self.filter_province_list)
        left_layout.addWidget(self.filter_line_edit)

        # Province list widget
        self.province_list = QListWidget()
        self.province_list.setFixedWidth(200)
        left_layout.addWidget(self.province_list)

        main_layout.addLayout(left_layout)

        # Game screen widget
        self.game_screen = GameScreen(self)
        main_layout.addWidget(self.game_screen)

        # Central widget
        central_widget = QWidget()
        central_widget.setLayout(main_layout)
        self.setCentralWidget(central_widget)

        # Connect list selection to color update
        self.province_list.currentItemChanged.connect(self.update_selected_color)

        # Load province data
        self.load_province_data('prov_mapping.txt')

        # Load initial map
        self.game_screen.grid.load_initial_map('map_provinces.png', self.province_colors)

        # Connect Ctrl + S to save map
        self.action_save_map_png = QShortcut(QKeySequence("Ctrl+S"), self)
        self.action_save_map_png.activated.connect(self.save_map)

        self.action_province_with_id = QShortcut(QKeySequence("Ctrl+R"), self)
        self.action_province_with_id.activated.connect(self.calculate_province_centers)


    def load_province_data(self, file_path):
        with open(file_path, 'r') as file:
            for line in file:
                parts = line.strip().split(',')
                if len(parts) >= 6:
                    province_id = parts[0]
                    color_hex = parts[4]
                    self.province_list.addItem(f"{province_id} - {color_hex}")
                    self.province_colors[color_hex] = province_id

    def update_selected_color(self, current, previous):
        if current:
            color_hex = current.text().split(' - ')[1]
            self.game_screen.selected_color = QColor(color_hex)

    def update_brush_size(self, current, previous):
        if current:
            size = int(current.text().split('x')[0])
            self.game_screen.brush_size = size

    def select_province_by_color(self, color_hex):
        items = self.province_list.findItems(f" - {color_hex}", Qt.MatchEndsWith)
        if items:
            self.province_list.setCurrentItem(items[0])

    def save_map(self):
        self.game_screen.grid.save_map_to_png('map_provinces.png')

    def filter_province_list(self, text):
        for row in range(self.province_list.count()):
            item = self.province_list.item(row)
            item.setHidden(text.lower() not in item.text().lower())

    def update_display_mode(self, state):
        self.game_screen.grid.load_initial_map('map_provinces.png', self.province_colors)

    def calculate_province_centers(self):
        province_map = QImage('map_provinces.png')
        province_cells = {}  # province_id: [(x, y), ...]
        province_centers = {}  # province_id: (center_x, center_y)

        # Load province data to map color to province ID
        color_to_province = {}
        for color_hex, province_id in self.province_colors.items():
            color = QColor(color_hex)
            color_to_province[color.rgb()] = province_id

        # Find all cells for each province
        for x in range(province_map.width()):
            for y in range(province_map.height()):
                color = province_map.pixelColor(x, y)
                if color.rgb() in color_to_province:
                    province_id = color_to_province[color.rgb()]
                    if province_id not in province_cells:
                        province_cells[province_id] = []
                    province_cells[province_id].append((x, y))

        # Calculate the center for each province
        for province_id, cells in province_cells.items():
            if cells:
                # Find the cell closest to the average center
                sum_x = sum(x for x, y in cells)
                sum_y = sum(y for x, y in cells)
                avg_x = sum_x / len(cells)
                avg_y = sum_y / len(cells)
                center_cell = min(cells, key=lambda cell: (cell[0] - avg_x) ** 2 + (cell[1] - avg_y) ** 2)
                province_centers[province_id] = center_cell

        # Display province ID on the map
        province_map2 = province_map.scaled(province_map.width() * grid_size, province_map.height() * grid_size)
        painter = QPainter(province_map2)
        font = painter.font()
        font.setPointSize(8)
        painter.setFont(font)
        painter.setPen(Qt.white)  # Set text color to white
        painter.setBrush(Qt.black)  # Set background color to black

        for province_id, (center_x, center_y) in province_centers.items():
            text_x = int(center_x * grid_size)
            text_y = int(center_y * grid_size)
            painter.drawText(text_x - grid_size, text_y + grid_size // 2, str(province_id))  # Adjust position as needed

        painter.end()
        province_map2.save('map_with_centers2.png')
        print("Province centers saved to province_centers.csv and map_with_centers.png")

        return province_centers

#
#   GAME SCREEN
#

class GameScreen(QGraphicsView):
    def __init__(self, main_window):
        super().__init__()
        self.main_window = main_window
        self.setScene(QGraphicsScene(self))
        self.setRenderHint(QPainter.Antialiasing)
        self.setRenderHint(QPainter.SmoothPixmapTransform)

        # Load map image
        self.map_item = QGraphicsPixmapItem(QPixmap('world map2.png'))
        #self.map_item.setOpacity(0.5)
        self.scene().addItem(self.map_item)

        # Create grid
        self.grid = Grid(world_size_x, world_size_y)
        self.grid.setOpacity(0.65)
        self.scene().addItem(self.grid)

        # Set zoom level to 1.5
        self.scale(2,2)

        # Selected color
        self.selected_color = QColor() #main_window.province_list.item(0).text().split(' - ')[1])
        self.brush_size = 1


    def mousePressEvent(self, event: QMouseEvent):
        pos = self.mapToScene(event.pos())
        if event.button() == Qt.LeftButton:
            if event.modifiers() & Qt.ControlModifier:
                self.grid.flood_fill(pos, self.selected_color)
            else:
                self.grid.set_color_at(pos, self.selected_color, self.brush_size)
        elif event.button() == Qt.RightButton:
            color = self.grid.get_color_at(pos)
            self.selected_color = color
            self.main_window.select_province_by_color(color.name())
            self.main_window.filter_line_edit.clear()


    def mouseMoveEvent(self, event: QMouseEvent):
        if event.buttons() & Qt.LeftButton:
            pos = self.mapToScene(event.pos())
            self.grid.set_color_at(pos, self.selected_color, self.brush_size)

#
# GRID
#

class Grid(QGraphicsPixmapItem):
    def __init__(self, width, height):
        super().__init__()
        self.width = width
        self.height = height
        self.grid = QPixmap(width, height)
        self.grid.fill(Qt.black)
        self.original_image = None  # Store the original image
        self.setPixmap(self.grid)

    def load_initial_map(self, file_path, province_colors):
        map_image = QPixmap(file_path).toImage()
        if self.original_image is None:
            self.original_image = map_image.copy()  # Store a copy of the original image

        painter = QPainter(self.grid)
        font = painter.font()
        font.setPointSize(8)
        painter.setFont(font)

        for x in range(0, map_image.width()):
            for y in range(0, map_image.height()):
                color = QColor(self.original_image.pixel(x, y))
                painter.setPen(color)
                painter.setBrush(color)
                painter.drawRect(x * grid_size, y * grid_size, grid_size, grid_size)

        painter.end()
        self.setPixmap(self.grid)

    def flood_fill(self, pos, new_color):
        image = self.grid.toImage()
        target_color = self.get_color_at(pos)
        if target_color == new_color:
            return

        queue = [(int(pos.x() / grid_size), int(pos.y() / grid_size))]
        visited = set()
        buffer = []

        while queue:
            x, y = queue.pop(0)
            if (x, y) in visited:
                continue
            visited.add((x, y))

            current_color = QColor(image.pixel(x * grid_size + grid_size // 2, y * grid_size + grid_size // 2))
            if current_color == target_color:
                if len(buffer) < 1000:
                    buffer.append((x, y))
                if x > 0:
                    queue.append((x - 1, y))
                if x < image.width() // grid_size - 1:
                    queue.append((x + 1, y))
                if y > 0:
                    queue.append((x, y - 1))
                if y < image.height() // grid_size - 1:
                    queue.append((x, y + 1))

        painter = QPainter(self.grid)
        painter.setPen(new_color)
        painter.setBrush(new_color)
        for x, y in buffer:
            painter.drawRect(x * grid_size, y * grid_size, grid_size, grid_size)
        painter.end()
        self.setPixmap(self.grid)

    def set_color_at(self, pos, color, brush_size):
        painter = QPainter(self.grid)
        painter.setPen(color)
        painter.setBrush(color)
        cell_x = int(pos.x() / grid_size) * grid_size
        cell_y = int(pos.y() / grid_size) * grid_size
        for i in range(brush_size):
            for j in range(brush_size):
                painter.drawRect(cell_x + i * grid_size, cell_y + j * grid_size, grid_size, grid_size)
        painter.end()
        self.setPixmap(self.grid)

    def get_color_at(self, pos):
        image = self.grid.toImage()
        cell_x = int(pos.x() / grid_size) * grid_size + grid_size // 2
        cell_y = int(pos.y() / grid_size) * grid_size + grid_size // 2
        col = QColor(image.pixel(cell_x, cell_y))
        return col

    def save_map_to_png(self, file_path):
        image = QImage(map_size_x, map_size_y, QImage.Format_ARGB32)
        image.fill(Qt.black)
        mm = self.grid.toImage()
        for x in range(map_size_x):
            for y in range(map_size_y):
                color = mm.pixelColor(x * grid_size + 4, y * grid_size + 4)
                image.setPixelColor(x, y, color)
        image.save(file_path)
        print("Map saved")



if __name__ == "__main__":
    app = QApplication([])
    window = MainWindow()
    window.show()
    app.exec()