from PySide6.QtWidgets import QApplication, QMainWindow, QListWidget, QGraphicsView, QGraphicsScene, \
    QGraphicsPixmapItem, QVBoxLayout, QWidget, QHBoxLayout, QLineEdit
from PySide6.QtGui import QPixmap, QColor, QMouseEvent, QPainter, QImage, QShortcut, QKeySequence
from PySide6.QtCore import Qt, QRectF, QPointF

map_size_x = 1408
map_size_y = 512
grid_size = 8


world_size_x = map_size_x * grid_size
world_size_y = map_size_y * grid_size

class MainWindow(QMainWindow):
    def __init__(self):
        super().__init__()
        self.setWindowTitle("Province Editor")
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
        self.brush_size_widget.setFixedWidth(150)
        self.brush_size_widget.setFixedHeight(60)
        self.brush_size_widget.currentItemChanged.connect(self.update_brush_size)
        left_layout.addWidget(self.brush_size_widget)

        # Filter line edit
        self.filter_line_edit = QLineEdit()
        self.filter_line_edit.setFixedWidth(150)
        self.filter_line_edit.setPlaceholderText("Filter provinces...")
        self.filter_line_edit.textChanged.connect(self.filter_province_list)
        left_layout.addWidget(self.filter_line_edit)

        # Province list widget
        self.province_list = QListWidget()
        self.province_list.setFixedWidth(150)
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
        self.game_screen.grid.load_initial_map('map_latests.png', self.province_colors)

        # Connect Ctrl + S to save map
        self.shortcut_save = QShortcut(QKeySequence("Ctrl+S"), self)
        self.shortcut_save.activated.connect(self.save_map)


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
        self.game_screen.grid.save_map_to_png('map_latests.png')

    def filter_province_list(self, text):
        for row in range(self.province_list.count()):
            item = self.province_list.item(row)
            item.setHidden(text.lower() not in item.text().lower())

class GameScreen(QGraphicsView):
    def __init__(self, main_window):
        super().__init__()
        self.main_window = main_window
        self.setScene(QGraphicsScene(self))
        self.setRenderHint(QPainter.Antialiasing)
        self.setRenderHint(QPainter.SmoothPixmapTransform)

        # Load map image
        self.map_item = QGraphicsPixmapItem(QPixmap('world map.png'))
        self.map_item.setOpacity(0.5)
        self.scene().addItem(self.map_item)

        # Create grid
        self.grid = Grid(world_size_x, world_size_y)
        self.grid.setOpacity(0.5)
        self.scene().addItem(self.grid)

        # Set zoom level to 1.5
        self.scale(2, 2)

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

class Grid(QGraphicsPixmapItem):
    def __init__(self, width, height):
        super().__init__()
        self.width = width
        self.height = height
        self.grid = QPixmap(width, height)
        self.grid.fill(Qt.black)
        self.setPixmap(self.grid)

    def load_initial_map(self, file_path, province_colors):
        map_image = QPixmap(file_path).toImage()
        painter = QPainter(self.grid)
        for x in range(0, map_image.width()):
            for y in range(0, map_image.height()):
                color = QColor(map_image.pixel(x, y)).name()
                if color in province_colors:
                    province_id = province_colors[color]
                    painter.setPen(QColor(color))
                    painter.setBrush(QColor(color))
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