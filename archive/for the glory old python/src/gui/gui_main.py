import sys

from PySide6.QtCore import Qt
from PySide6.QtWidgets import QApplication, QMainWindow, QHBoxLayout, QVBoxLayout, QWidget, QStackedWidget

from gui_status import TopWidget
from manager import manager_province, manager_cot
from map import map_mode


class GameWindow(QMainWindow):

    def __init__(self, mod_name):
        super().__init__()

        from src.db import TDB
        self.db = TDB()
        self.db.current_zoom_index = 2

        # create scene
        from game_scene import GameScene
        self.game_scene = GameScene()

        # create game logic
        import game_logic

        # setup game logic and game scene to db
        self.db.game_scene = self.game_scene

        # setup mod
        self.db.setup_mod( mod_name )

        # load mod
        from map import map_loader
        map_loader.load_mod()

        # create all background calculation
        game_logic.process_game_logic_before()

        # here enter GUI
        self.create_gui()

        # Create a top-level widget to hold the layout
        self.global_widget = QWidget()
        self.global_layout = QHBoxLayout(self.global_widget)

        # Add the menu widget to the left
        self.global_layout.addWidget(self.menu_widget)

        # Create a vertical layout for the top widget and game scene
        self.right_layout = QVBoxLayout()
        self.right_layout.addWidget(self.top_widget)
        self.right_layout.addWidget(self.game_scene.game_view)

        # Add the right layout to the global layout
        self.global_layout.addLayout(self.right_layout)

        # Set the top-level widget as the central widget
        self.setCentralWidget(self.global_widget)

        # create all map graphics
        self.game_scene.create_graphics()

        # make full screen
        # self.showMaximized()
        self.game_scene.apply_zoom()

        from map.map_scenario import ScenarioLoader
        scenario_loader = ScenarioLoader(self.db.path_mod / "scenarios" / 'world.yml')
        scenario_loader.load_scenarios()
        scenario = scenario_loader.select_scenario('1399')
        scenario.load_content()

        manager_cot.calculate_range_of_cots()

        tag_to_own = 'POL'
        manager_province.switch_current_country_tag(tag_to_own)
        map_mode.switch_map_mode('terrain')

    #
    #   GUI
    #

    def create_gui(self):
        print("GUI Creation")
        # create menu widget
        self.menu_widget = QStackedWidget()
        self.menu_widget.setFixedWidth(300)

        # Create 10 panels with random widgets

        from gui_diplomacy import DiplomacyPanel
        panel_diplomacy = DiplomacyPanel(self.menu_widget)
        self.menu_widget.addWidget(panel_diplomacy)

        from gui_province import ProvincePanel
        panel_province = ProvincePanel(self.menu_widget)
        self.menu_widget.addWidget(panel_province)

        from gui_policy import DomesticPolicyPanel
        panel_policies = DomesticPolicyPanel(self.menu_widget)
        self.menu_widget.addWidget(panel_policies)

        from gui_technology import TechnologyPanel
        panel_technologies = TechnologyPanel(self.menu_widget)
        self.menu_widget.addWidget(panel_technologies)

        from gui_budget import BudgetPanel
        panel_budget = BudgetPanel(self.menu_widget)
        self.menu_widget.addWidget(panel_budget)

        from gui_recruit_army import RecruitArmyPanel
        panel_recruit_army = RecruitArmyPanel(self.menu_widget)
        self.menu_widget.addWidget(panel_recruit_army)

        from gui_battle_land import BattleLandPanel
        panel_battle_land = BattleLandPanel(self.menu_widget)
        self.menu_widget.addWidget(panel_battle_land)

        from gui_country import CountryPanel
        panel_country = CountryPanel(self.menu_widget)
        self.menu_widget.addWidget(panel_country)

        from gui_cot import CenterOfTradePanel
        panel_cot = CenterOfTradePanel(self.menu_widget)
        self.menu_widget.addWidget(panel_cot)

        from gui_religion_culture import ReligionCulturePanel
        panel_religion_culture = ReligionCulturePanel(self.menu_widget)
        self.menu_widget.addWidget(panel_religion_culture)

        from gui_editor import EditorPanel
        panel_editor = EditorPanel(self.menu_widget)
        self.menu_widget.addWidget(panel_editor)

        container_layout = QVBoxLayout()
        container_layout.addWidget(self.menu_widget)

        self.menu_widget.setLayout(container_layout)
        self.menu_widget.setParent(self)
        self.menu_widget.move(0, 0)

        # Create a layout for the game scene
        self.layout = QVBoxLayout()
        self.setLayout(self.layout)

        # Add the top widget to the game scene
        self.top_widget = TopWidget(self)
        self.layout.addWidget(self.top_widget)

    def switch_panel(self, index):
        self.menu_widget.setCurrentIndex(index)
        self.menu_widget.currentWidget().show()

    #
    #   KEYBOARD EVENTS GLOBAL
    #
    #   KEYBOARD EVENTS
    #

    def keyPressEvent(self, event):

        if event.key() == Qt.Key_Backspace:
            import random
            random_index = random.randint(0, self.menu_widget.count() - 1)
            self.switch_panel(1)

        super().keyPressEvent(event)


if __name__ == "__main__":
    app = QApplication(sys.argv)
    app.setStyle('Fusion')
    viewer = GameWindow()
    viewer.show()
    sys.exit(app.exec())