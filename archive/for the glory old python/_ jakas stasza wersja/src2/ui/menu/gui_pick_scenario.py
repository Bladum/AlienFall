# src2/ui/menu/gui_pick_scenario.py
from PySide6.QtGui import QIcon
from PySide6.QtWidgets import QWidget, QVBoxLayout, QPushButton, QLabel, QListWidget, QScrollArea, QSizePolicy, QHBoxLayout, QTextEdit, QListWidgetItem
from PySide6.QtCore import Qt, QSize

from managers.scenario_manager import ScenarioManager


class GUI_PickScenarioWidget(QWidget):
    """Scenario selection widget."""

    def __init__(self, main_window):
        super().__init__()
        self.main_window = main_window
        self.selected_mod = None
        self.current_country = 'REB'

        from core.game_state import GameState
        self.gs = GameState()

        from controllers.game_controller import GameController
        self.gc : GameController = main_window.game_controller

        # main layout

        main_layout = QHBoxLayout()
        main_layout.setAlignment(Qt.AlignCenter)
        main_layout.setContentsMargins(2, 2, 2, 2)
        main_layout.setSpacing(2)

        # Left side layout

        left_layout = QVBoxLayout()
        left_layout.setContentsMargins(2, 2, 2, 2)
        left_layout.setSpacing(2)

        # List of scenarios

        self.scenario_list = QListWidget()
        self.scenario_list.setSelectionMode(QListWidget.SingleSelection)
        self.scenario_list.setFixedWidth(240)
        self.scenario_list.currentItemChanged.connect(self.on_scenario_item_clicked)
        left_layout.addWidget(QLabel("Scenarios"))
        left_layout.addWidget(self.scenario_list)

        # List of game saves

        self.save_list = QListWidget()
        self.save_list.setFixedWidth(240)
        left_layout.addWidget(QLabel("Game Saves"))
        left_layout.addWidget(self.save_list)

        # main layout

        main_layout.addLayout(left_layout)

        # Scenario description

        self.scenario_description = QTextEdit()
        self.scenario_description.setReadOnly(True)
        self.scenario_description.setTextInteractionFlags(Qt.NoTextInteraction)

        scenario_desc_layout = QVBoxLayout()
        scenario_desc_layout.addWidget(QLabel("Scenario Description"))
        scenario_desc_layout.addWidget(self.scenario_description)
        scenario_desc_layout.setContentsMargins(2, 2, 2, 2)
        scenario_desc_layout.setSpacing(2)

        self.scenario_list.clearSelection()
        self.scenario_description.clear()

        # Bottom right layout

        bottom_right_layout = QHBoxLayout()
        bottom_right_layout.setContentsMargins(2, 2, 2, 2)
        bottom_right_layout.setSpacing(2)

        # Country description
        self.country_mini_map = QLabel()
        self.country_mini_map.setAlignment(Qt.AlignCenter)
        self.country_mini_map.setStyleSheet("background-color: #333;  border-radius: 5px;")
        self.country_mini_map.setScaledContents(True)

        self.scroll_area = QScrollArea()
        self.scroll_area.setWidget(self.country_mini_map)
        self.scroll_area.setWidgetResizable(True)
        self.scroll_area.setSizePolicy(QSizePolicy.Expanding, QSizePolicy.Expanding)
        self.scroll_area.setAlignment(Qt.AlignCenter)

        country_desc_layout = QVBoxLayout()
        country_desc_layout.addWidget(QLabel("Mini Map"))
        country_desc_layout.addWidget(self.scroll_area)
        country_desc_layout.setContentsMargins(2, 2, 2, 2)
        country_desc_layout.setSpacing(2)

        bottom_right_layout.addLayout(country_desc_layout)

        # List of countries and buttons
        country_list_and_buttons_layout = QVBoxLayout()
        country_list_and_buttons_layout.addWidget(QLabel("Country List"))
        country_list_and_buttons_layout.setContentsMargins(2, 2, 2, 2)
        country_list_and_buttons_layout.setSpacing(2)

        self.country_list = QListWidget()
        self.country_list.currentItemChanged.connect(self.on_country_list_clicked)
        self.country_list.setFixedWidth(240)
        self.country_list.setIconSize(QSize(32, 32))
        country_list_and_buttons_layout.addWidget(self.country_list)

        # Buttons layout
        buttons_layout = QVBoxLayout()
        buttons_layout.setContentsMargins(2, 2, 2, 2)
        buttons_layout.setSpacing(2)

        self.button1 = QPushButton("Start")
        self.button1.setFixedSize(160, 40)
        self.button1.clicked.connect(self.start_scenario)

        self.button2 = QPushButton("Options")
        self.button2.setFixedSize(160, 40)

        self.return_button = QPushButton("Back")
        self.return_button.setFixedSize(160, 40)
        self.return_button.clicked.connect(self.main_window.switch_to_starter_widget)

        #buttons_layout.addStretch()
        buttons_layout.addWidget(self.button1, alignment=Qt.AlignCenter)
        buttons_layout.addWidget(self.button2, alignment=Qt.AlignCenter)
        buttons_layout.addWidget(self.return_button, alignment=Qt.AlignCenter)

        country_list_and_buttons_layout.addLayout(buttons_layout)
        bottom_right_layout.addLayout(country_list_and_buttons_layout)

        # Combine upper and bottom right layouts
        right_layout = QVBoxLayout()
        right_layout.addLayout(scenario_desc_layout, 1)
        right_layout.addLayout(bottom_right_layout, 2)
        right_layout.setContentsMargins(2, 2, 2, 2)
        right_layout.setSpacing(2)

        main_layout.addLayout(right_layout)
        self.setLayout(main_layout)

    def on_country_list_clicked(self, item: QListWidgetItem):
        country_name = item.text()
        print(f"Country clicked: {country_name}")

        country_name = country_name.split(" - ")[0]
        self.current_country = country_name

        # Create and display the mini map image
        from managers.load.map_graphics import create_mini_map_image
        mini_map_pixmap = create_mini_map_image(country_name)
        self.country_mini_map.setPixmap(mini_map_pixmap)
        self.adjust_image_size(mini_map_pixmap)

    def start_scenario(self):
        # Add the logic to start the selected scenario
        current_item = self.scenario_list.currentItem()
        if current_item:
            scenario_name = current_item.text()
            print(f"Starting scenario: {scenario_name}")

            scenario = self.gc.scenario_manager.select_scenario(scenario_name)
            scenario.load_content()

            from managers import cot_manager
            self.gc.cot_manager.calculate_range_of_cots()

            # switch to selected country
            self.gs.current_country_tag = self.current_country

            # switch to game widget
            self.main_window.switch_to_game_widget()

    def on_scenario_item_clicked(self, item: QListWidgetItem):
        scenario_name = item.text()
        print(f"Scenario clicked: {scenario_name}")

        if item:
            self.scenario_description.setText(item.data(Qt.UserRole))
        else:
            self.scenario_description.clear()

        scenario = self.gc.scenario_manager.select_scenario(scenario_name)
        scenario.load_content()

        self.country_list.clear()
        self.country_mini_map.clear()

        # Add items to the country list
        for n, cnt in scenario.countries_details.items():
            self.add_country_item(f"{n} - {cnt['name']}", f"data/ftg/gfx/flag/{n}.png")

    def showEvent(self, event):
        from managers.load.map_graphics import create_mini_map_image
        create_mini_map_image()
        self.on_widget_displayed()
        super().showEvent(event)

    def add_scenario_item(self, name, description):
        item = QListWidgetItem(name)
        item.setData(Qt.UserRole, description)
        self.scenario_list.addItem(item)

    def add_country_item(self, name, icon_path):
        item = QListWidgetItem(name)
        item.setIcon(QIcon(icon_path))
        self.country_list.addItem(item)

    def on_widget_displayed(self):
        # load scenarios
        self.scenario_list.clear()
        self.gc.scenario_manager.base_path = self.gs.path_scenarios / 'scenarios.toml'
        self.gc.scenario_manager.load_scenarios()

        for name, scen in self.gc.scenario_manager.scenarios.items():
            self.add_scenario_item(name, scen.description)

        # Auto-select first scenario if available
        if self.scenario_list.count() > 0:
            self.scenario_list.setCurrentRow(0)
            first_item = self.scenario_list.item(0)

            # Load scenario content
            scenario_name = first_item.text()
            scenario = self.gc.scenario_manager.select_scenario(scenario_name)
            scenario.load_content()

            # Display scenario description
            self.scenario_description.setText(first_item.data(Qt.UserRole))

            # Populate country list
            self.country_list.clear()
            for n, cnt in scenario.countries_details.items():
                self.add_country_item(f"{n} - {cnt['name']}", f"data/ftg/gfx/flag/{n}.png")

            # Select first country if available
            if self.country_list.count() > 0:
                self.country_list.setCurrentRow(0)
                first_country_item = self.country_list.item(0)

                # Extract country tag (first part before the dash)
                country_name = first_country_item.text().split(" - ")[0]
                self.current_country = country_name

                # Create and display mini map
                from managers.load.map_graphics import create_mini_map_image
                mini_map_pixmap = create_mini_map_image(country_name)
                self.country_mini_map.setPixmap(mini_map_pixmap)
                self.adjust_image_size(mini_map_pixmap)

    def adjust_image_size(self, pixmap):
        """Adjust the image size to fit the scroll area while maintaining aspect ratio."""
        if pixmap and not pixmap.isNull():
            available_width = self.scroll_area.width() - 10  # Subtract some padding
            available_height = self.scroll_area.height() - 10

            # Set maximum dimensions
            max_width = 1200
            max_height = 500

            # Calculate target dimensions (respecting both available space and max limits)
            target_width = min(available_width, max_width)
            target_height = min(available_height, max_height)

            # Ensure minimum size based on parent (at least 50% of scroll area)
            min_width = max(int(self.scroll_area.width() * 0.5), 100)
            min_height = max(int(self.scroll_area.height() * 0.5), 100)

            target_width = max(min_width, target_width)
            target_height = max(min_height, target_height)

            # Scale pixmap to fit available space while maintaining aspect ratio
            scaled_pixmap = pixmap.scaled(
                target_width,
                target_height,
                Qt.KeepAspectRatio,
                Qt.SmoothTransformation
            )

            # Update the label size to match the scaled pixmap
            self.country_mini_map.setFixedSize(scaled_pixmap.size())
            self.country_mini_map.setPixmap(scaled_pixmap)

    def resizeEvent(self, event):
        """Handle resize events to adjust the mini map size."""
        super().resizeEvent(event)
        if hasattr(self, 'country_mini_map') and self.country_mini_map.pixmap():
            self.adjust_image_size(self.country_mini_map.pixmap())
