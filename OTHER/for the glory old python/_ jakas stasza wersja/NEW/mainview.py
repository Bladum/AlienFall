from PySide6.QtWidgets import QWidget, QVBoxLayout, QPushButton, QHBoxLayout, QLabel, QMainWindow

from NEW.gamemodel import GameModel


class MainView(QMainWindow):
    def __init__(self, game_model: GameModel):
        super().__init__()
        self.game_model = game_model
        self.init_ui()

    def init_ui(self):
        central_widget = QWidget()
        layout = QVBoxLayout(central_widget)

        # Top Panel Buttons
        menu_button = QPushButton("Menu")
        info_button = QPushButton("Info")

        left_panel_layout = QVBoxLayout()
        for _ in range(6):  # Assuming there are always 6 buttons here
            button = QPushButton(f"Button {_}")
            left_panel_layout.addWidget(button)

        map_panel_layout = QVBoxLayout()
        for y in range(self.game_model.height):
            row_layout = QHBoxLayout()
            for x in range(self.game_model.width):
                tile_type = self.game_model.tiles[y][x]
                label = QLabel(tile_type.value)
                row_layout.addWidget(label)
            map_panel_layout.addLayout(row_layout)

        layout.addWidget(menu_button)
        layout.addWidget(info_button)
        layout.addLayout(left_panel_layout)
        layout.addLayout(map_panel_layout)

        self.setCentralWidget(central_widget)