# ui/main_window.py
from PySide6.QtWidgets import (
    QMainWindow, QWidget, QVBoxLayout, QGraphicsView, QStackedWidget
)

# Import only the navigation manager
from ui.navigation_manager import navigation


class MainGameWindow(QMainWindow):
    """Main application window."""

    def __init__(self, game_controller):
        super().__init__()
        print("Create main window")

        from controllers.game_controller import GameController
        self.game_controller : GameController = game_controller

        # main game state
        from core.game_state import GameState
        self.game_state = GameState()

        # Create central widget with layout
        central_widget = QWidget()
        main_layout = QVBoxLayout(central_widget)
        main_layout.setContentsMargins(0, 0, 0, 0)

        # Initialize stacked widget for different screens
        self.global_stacked_widget = QStackedWidget()
        main_layout.addWidget(self.global_stacked_widget)

        # Game scene for map visualization
        from core.game_scene import GameScene
        self.game_view = QGraphicsView()

        # Now create the scene and pass both self and the view
        self.game_scene = GameScene(self, self.game_view)

        # Set central widget
        self.setCentralWidget(central_widget)

        # Register with navigation manager
        navigation.set_main_window(self)

        # Create all sub-widgets (deferred)
        from ui.menu.gui_battle import GUI_BattleWidget
        from ui.menu.gui_starter import GUI_StarterWidget
        from ui.menu.gui_options import GUI_OptionsWidget
        from ui.menu.gui_pick_scenario import GUI_PickScenarioWidget
        from ui.menu.gui_editor import GUI_EditorWidget
        from ui.menu.gui_wiki import GUI_WikiWidget
        from ui.menu.gui_game import GUI_GameWidget

        # Initialize UI widgets
        self.starter_widget = GUI_StarterWidget(self)
        self.battle_widget = GUI_BattleWidget(self)
        self.option_widget = GUI_OptionsWidget(self)
        self.pick_scenario_widget = GUI_PickScenarioWidget(self)
        self.editor_widget = GUI_EditorWidget(self)
        self.wiki_widget = GUI_WikiWidget(self)
        self.game_widget = GUI_GameWidget(self)

        # Add all widgets to the stacked widget
        self.global_stacked_widget.addWidget(self.starter_widget)
        self.global_stacked_widget.addWidget(self.option_widget)
        self.global_stacked_widget.addWidget(self.battle_widget)
        self.global_stacked_widget.addWidget(self.pick_scenario_widget)
        self.global_stacked_widget.addWidget(self.editor_widget)
        self.global_stacked_widget.addWidget(self.wiki_widget)
        self.global_stacked_widget.addWidget(self.game_widget)

        # Start with the main menu
        self.global_stacked_widget.setCurrentWidget(self.starter_widget)

    # Screen navigation methods
    def switch_to_starter_widget(self):
        print("Switch to starter screen")
        self.global_stacked_widget.setCurrentWidget(self.starter_widget)

    def switch_to_options_widget(self):
        print("Switch to options screen")
        self.global_stacked_widget.setCurrentWidget(self.option_widget)

    def switch_to_pick_scenario_widget(self, selected_mod=None):
        print("Switch to select scenario screen")
        self.global_stacked_widget.setCurrentWidget(self.pick_scenario_widget)

    def switch_to_editor_widget(self):
        print("Switch to map editor screen")
        self.global_stacked_widget.setCurrentWidget(self.editor_widget)

    def switch_to_wiki_widget(self):
        print("Switch to wiki screen")
        self.global_stacked_widget.setCurrentWidget(self.wiki_widget)

    def switch_to_battle_widget(self):
        print("Switch to battle simulation screen")
        self.global_stacked_widget.setCurrentWidget(self.battle_widget)

    def switch_to_game_widget(self, scenario=None):
        print("Switch to game screen")
        if self.game_scene:
            self.game_scene.create_graphics()

        self.global_stacked_widget.setCurrentWidget(self.game_widget)

    def exit_application(self):
        """Close the application."""
        self.close()
