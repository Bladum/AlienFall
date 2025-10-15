from PySide6.QtWidgets import QStackedWidget, QTabWidget, QVBoxLayout, QWidget


class GUI_GameLeftPanel(QWidget):
    def __init__(self, parent=None, game_state = None, game_controller = None, game_scene = None):
        super().__init__(parent)
        self.setFixedWidth(30)

        from controllers.game_controller import GameController
        self.gc : GameController = game_controller
        from core.game_state import GameState
        self.gs : GameState = game_state
        from core.game_scene import GameScene
        self.game_scene : GameScene = game_scene

        self.setContentsMargins(2, 2, 2, 2)

        layout = QVBoxLayout(self)
        layout.setContentsMargins(2, 2, 2, 2)
        layout.setSpacing(4)

        # Define map modes
        self.map_modes = [
            {"name": "terrain", "icon": "🏔️", "tooltip": "Terrain Map Mode"},
            {"name": "political", "icon": "🗺️", "tooltip": "Political Map Mode"},
            {"name": "culture", "icon": "🎭", "tooltip": "Culture Map Mode"},
            {"name": "religion", "icon": "⛪", "tooltip": "Religion Map Mode"},
            {"name": "climate", "icon": "☀️", "tooltip": "Climate Map Mode"},
            {"name": "trade", "icon": "🛒", "tooltip": "Trade Map Mode"},
            {"name": "goods", "icon": "💰", "tooltip": "Economic Map Mode"},
            {"name": "manpower", "icon": "⚔️", "tooltip": "Military Map Mode"},
            {"name": "area", "icon": "🌍", "tooltip": "Geographical Area Map Mode"},
            {"name": "region", "icon": "🌎", "tooltip": "Region Map Mode"},
            {"name": "continent", "icon": "🌏", "tooltip": "Continent Map Mode"},

            {"name": "diplomatic", "icon": "🤝", "tooltip": "Diplomatic Relations"},
            {"name": "development", "icon": "🏙️", "tooltip": "Development Map Mode"},
            {"name": "population", "icon": "👥", "tooltip": "Population Map Mode"},
            {"name": "fortification", "icon": "🏰", "tooltip": "Fortification Map Mode"},
            {"name": "supply", "icon": "🍞", "tooltip": "Supply Map Mode"},
            {"name": "revolt_risk", "icon": "⚠️", "tooltip": "Revolt Risk Map Mode"},
            {"name": "infrastructure", "icon": "🏗️", "tooltip": "Infrastructure Map Mode"},
            {"name": "stability", "icon": "⚖️", "tooltip": "Stability Map Mode"},
            {"name": "disasters", "icon": "🌪️", "tooltip": "Disasters Map Mode"},
            {"name": "health", "icon": "🏥", "tooltip": "Health Map Mode"},

        ]

        # Create buttons for map modes
        self.buttons = []
        from PySide6.QtWidgets import QPushButton

        for i, mode in enumerate(self.map_modes):
            button = QPushButton(mode["icon"])
            button.setFixedSize(24, 24)
            button.setToolTip(mode["tooltip"])
            button.setCheckable(True)
            button.clicked.connect(lambda checked, idx=i, b=button: self.switch_map_mode(idx))
            layout.addWidget(button)
            self.buttons.append(button)

        # Set the first map mode as default
        self.buttons[0].setChecked(True)
        self.current_mode = 0

        # Add stretch to push buttons to the top
        layout.addStretch()

    def switch_map_mode(self, index):
        # Uncheck all other buttons
        for i, button in enumerate(self.buttons):
            if i != index:
                button.setChecked(False)

        # Make sure the selected button is checked
        self.buttons[index].setChecked(True)
        self.current_mode = index

        map_mode_name = self.map_modes[index]['name']

        # Here you would implement the actual map mode change
        print(f"Switching to {map_mode_name} map mode")
        self.gc.map_manager.switch_map_mode( map_mode_name )

        #
        #   switch zoom modes
        #

        for province in self.gs.provinces.values():
            province.province_item.change_details_based_on_zoom_level(self.gs.current_zoom_index)

        self.game_scene.update()