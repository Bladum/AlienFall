# ui/game_panel/gui_game_top_panel.py

from PySide6.QtCore import QTimer
from PySide6.QtGui import QPixmap, Qt
from PySide6.QtWidgets import QWidget, QLabel, QHBoxLayout, QPushButton

from core.game_state import GameState
from utils.clock import Clock

gs = GameState()

class GUI_GameTopPanel(QWidget):
    def __init__(self, parent=None, game_state = None, game_controller = None, game_scene = None):
        super().__init__(parent)
        self.setFixedHeight(30)
        self.parent = parent
        layout = QHBoxLayout()
        layout.setContentsMargins(2, 2, 2, 2)
        layout.setSpacing(5)

        from controllers.game_controller import GameController
        self.gc : GameController = game_controller
        from core.game_state import GameState
        self.gs : GameState = game_state
        from core.game_scene import GameScene
        self.game_scene : GameScene = game_scene

        layout.addStretch()

        # Add Country and World buttons
        self.province_button = QPushButton("Province")
        self.province_button.setFixedSize(70, 24)
        layout.addWidget(self.province_button)
        self.province_button.clicked.connect(self.on_province_button_clicked)

        # Add Country and World buttons
        self.country_button = QPushButton("Country")
        self.country_button.setFixedSize(70, 24)
        layout.addWidget(self.country_button)
        self.country_button.clicked.connect(self.on_country_button_clicked)

        self.world_button = QPushButton("World")
        self.world_button.setFixedSize(70, 24)
        layout.addWidget(self.world_button)
        self.world_button.clicked.connect(self.on_world_button_clicked)

        layout.addStretch()

        # Add gold, stability, fame
        self.add_icon_with_text(layout, "gold", "1000", "Gold tooltip")
        layout.addStretch()
        self.add_icon_with_text(layout, "stability", "+3", "Stability tooltip")
        self.add_icon_with_text(layout, "fame", "-12", "Fame tooltip")
        self.add_icon_with_text(layout, "manpower", "10", "Manpower tooltip")
        layout.addStretch()

        # Add agents
        agents = ["merchant", "diplomat", "explorer", "engineer", "inventor", "advisor", "general", "missionary"]
        for agent in agents:
            self.add_icon_with_text(layout, agent, f"12", f"{agent.capitalize()} tooltip")

        # Add current date
        self.date_label = QLabel("23 Dec 1430")
        self.date_label.setStyleSheet("background-color: transparent; font-size: 12px;")
        layout.addStretch()
        layout.addWidget(self.date_label)

        # Add end turn button
        # Add game speed radio buttons
        self.pause_button = QPushButton("||")
        self.pause_button.setFixedSize(24, 24)
        self.pause_button.setCheckable(True)
        self.pause_button.setToolTip("Pause game")
        self.pause_button.setChecked(True)  # Start with pause checked
        self.pause_button.setStyleSheet(
            "QPushButton { background-color: #333; color: #EEE; font-size: 10px; font-weight: bold; } "
            "QPushButton:hover { background-color: #555; } "
            "QPushButton:checked { background-color: red; }")
        layout.addWidget(self.pause_button)

        self.play_button = QPushButton(">")
        self.play_button.setFixedSize(24, 24)
        self.play_button.setCheckable(True)
        self.play_button.setToolTip("Setup standard game speed\n1 second = 1 day")
        self.play_button.setStyleSheet(
            "QPushButton { background-color: #333; color: #EEE; font-size: 10px; font-weight: bold; } "
            "QPushButton:hover { background-color: #555; } "
            "QPushButton:checked { background-color: green; }")
        layout.addWidget(self.play_button)

        self.fast_play_button = QPushButton(">>>")
        self.fast_play_button.setFixedSize(24, 24)
        self.fast_play_button.setCheckable(True)
        self.fast_play_button.setToolTip("Setup turbo game speed\n1 second = 5 days")
        self.fast_play_button.setStyleSheet(
            "QPushButton { background-color: #333; color: #EEE; font-size: 10px; font-weight: bold; } "
            "QPushButton:hover { background-color: #555; } "
            "QPushButton:checked { background-color: blue; }")
        layout.addWidget(self.fast_play_button)

        self.speed_buttons = [self.pause_button, self.play_button, self.fast_play_button]
        for button in self.speed_buttons:
            button.setFlat(True)
            button.clicked.connect(self.handle_speed_button)

        layout.addStretch()

        self.clock = Clock(1400,1,1)

        self.setLayout(layout)
        self.timer = QTimer(self)
        self.timer.timeout.connect(self.advance_day)
        self.update_speed()
        self.date_label.setText( self.clock.convert_to_long_str() )

    def on_country_button_clicked(self):
        print("Country button clicked")

        main_game_widget = self.parent
        if hasattr(main_game_widget, 'gc'):
            # Get current country
            current_tag = self.gs.current_country_tag
            country = self.gs.countries.get(current_tag)
            if country:
                print(f"Showing country panel for {country.name} ({current_tag})")
                # You would import and instantiate your country panel here
                from ui.game_panel.gui_game_country_panel import GUI_GameCountryPanel
                country_panel = GUI_GameCountryPanel(self.parent, country)
                country_panel.show()

    def on_province_button_clicked(self):
        print("Province button clicked")

        main_game_widget = self.parent
        if hasattr(main_game_widget, 'gc'):
            # Get current country
            current_id = 300
            province = self.gs.provinces.get(current_id)
            if province:
                print(f"Showing province panel for {province.name} ({province.province_id})")

                from ui.game_panel.gui_game_province_panel import GUI_GameProvincePanel
                province_panel = GUI_GameProvincePanel(self.parent, province)
                province_panel.show()

    def on_world_button_clicked(self):
        print("World button clicked")

    def handle_speed_button(self):
        # Uncheck all other speed buttons except the sender
        sender = self.sender()
        for button in self.speed_buttons:
            if button != sender:
                button.setChecked(False)

        # Make sure at least one button is checked
        if not any(button.isChecked() for button in self.speed_buttons):
            self.pause_button.setChecked(True)

        self.update_speed()

    def update_speed(self):
        if self.pause_button.isChecked():
            self.timer.stop()
        elif self.play_button.isChecked():
            self.timer.start(1000)  # 1 tick = 1 second
        elif self.fast_play_button.isChecked():
            self.timer.start(200)  # 1 tick = 0.2 seconds

    def advance_day(self):
        # Logic to advance the game by one day
        print("Advancing one day")
        self.clock.advance_time(1)
        self.date_label.setText( self.clock.convert_to_long_str() )

    def add_icon_with_text(self, layout, icon_name, text, tooltip):
        icon_label = QLabel()
        icon_label.setPixmap(QPixmap(f'data/ftg/gfx/agents/{icon_name}.png'))
        icon_label.setToolTip(tooltip)
        icon_label.setStyleSheet("background-color: transparent; font-size: 12px;")
        layout.addWidget(icon_label)

        text_label = QLabel(text)
        text_label.setStyleSheet("background-color: transparent; font-size: 12px;")
        layout.addWidget(text_label)

    def keyPressEvent(self, event):
        if event.key() == Qt.Key_Space:
            pass

        super().keyPressEvent(event)