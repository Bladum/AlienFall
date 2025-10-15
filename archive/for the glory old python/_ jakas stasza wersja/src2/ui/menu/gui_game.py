# ui/menu/gui_game.py

from PySide6.QtCore import Qt
from PySide6.QtWidgets import QWidget, QVBoxLayout, QHBoxLayout, QSizePolicy

from ui.game_panel.gui_game_left_panel import GUI_GameLeftPanel
from ui.game_panel.gui_game_top_panel import GUI_GameTopPanel


class GUI_GameWidget(QWidget):
    def __init__(self, main_window):
        super().__init__()
        self.main_window = main_window
        self.gc = main_window.game_controller
        self.gs = main_window.game_state
        self.game_scene = main_window.game_scene
        self.setSizePolicy(QSizePolicy.Expanding, QSizePolicy.Expanding)

        # Main vertical layout
        main_layout = QVBoxLayout()
        main_layout.setContentsMargins(0, 0, 0, 0)
        main_layout.setSpacing(0)

        # Add the top panel
        self.top_panel = GUI_GameTopPanel(self, self.gs, self.gc, self.game_scene)
        main_layout.addWidget(self.top_panel)

        # Create horizontal layout for game view and left panel
        game_area_layout = QHBoxLayout()
        game_area_layout.setContentsMargins(0, 0, 0, 0)
        game_area_layout.setSpacing(0)

        # Add left panel
        self.left_panel = GUI_GameLeftPanel(self, self.gs, self.gc, self.game_scene)
        game_area_layout.addWidget(self.left_panel)

        # Add game view
        self.game_view = self.main_window.game_view
        game_area_layout.addWidget(self.game_view, 1)  # 1 = stretch factor

        # Add the game area to the main layout
        main_layout.addLayout(game_area_layout, 1)  # 1 = stretch factor

        self.setLayout(main_layout)

    def showEvent(self, event):
        # When widget becomes visible, make sure it's properly set up
        self.game_view.setScene(self.main_window.game_scene)
        super().showEvent(event)

        # Trigger country switch with a small delay to ensure everything is loaded
        from PySide6.QtCore import QTimer
        QTimer.singleShot(100, self.game_scene.switch_to_country_by_tag)


    def keyPressEvent(self, event):
        if event.key() == Qt.Key_Escape:
            # Add escape key to return to menu
            self.main_window.switch_to_starter_widget()
        super().keyPressEvent(event)