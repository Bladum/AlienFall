# src2/ui/menu/gui_starter.py
import toml
from PySide6.QtWidgets import QWidget, QVBoxLayout, QPushButton, QLabel, QComboBox, QProgressBar
from PySide6.QtCore import Qt, QCoreApplication
from ui.navigation_manager import navigation
from managers.mod_manager import ModManager


class GUI_StarterWidget(QWidget):
    """Main menu widget."""

    def __init__(self, main_window):
        super().__init__()
        self.main_window = main_window

        self.layout = QVBoxLayout(self)
        self.layout.setAlignment(Qt.AlignCenter)
        self.layout.setContentsMargins(2, 2, 2, 2)
        self.layout.setSpacing(2)

        # Title
        self.title = QLabel("myEU Game")
        self.title.setStyleSheet("font-size: 24pt; font-weight: bold; margin: 20px;")
        self.title.setAlignment(Qt.AlignCenter)
        self.layout.addWidget(self.title)

        # Mod selection combobox
        self.mod_label = QLabel("Select Mod:")
        self.mod_label.setAlignment(Qt.AlignCenter)
        self.layout.addWidget(self.mod_label)

        self.mod_combo_box = QComboBox()
        self.mod_combo_box.setMinimumWidth(160)
        self.mod_combo_box.setMinimumHeight(40)
        self.load_mods()
        self.layout.addWidget(self.mod_combo_box)

        # Create buttons
        self.load_mod_btn = QPushButton("Play")
        self.battle_btn = QPushButton("Battle")
        self.options_btn = QPushButton("Options")
        self.editor_btn = QPushButton("Editor")
        self.wiki_btn = QPushButton("Wiki")
        self.exit_btn = QPushButton("Quit")

        # Set button size
        for btn in [self.load_mod_btn, self.options_btn, self.editor_btn, self.wiki_btn, self.battle_btn, self.exit_btn]:
            btn.setMinimumWidth(160)
            btn.setMinimumHeight(40)

        # Connect buttons
        self.load_mod_btn.clicked.connect(self.start_new_game)
        self.options_btn.clicked.connect(navigation.switch_to_options)
        self.editor_btn.clicked.connect(navigation.switch_to_editor)
        self.wiki_btn.clicked.connect(navigation.switch_to_wiki)
        self.battle_btn.clicked.connect(navigation.switch_to_battle)
        self.exit_btn.clicked.connect(self.quit_game)

        # Add buttons to layout
        self.layout.addWidget(self.load_mod_btn)
        self.layout.addWidget(self.battle_btn)
        self.layout.addWidget(self.options_btn)
        self.layout.addWidget(self.editor_btn)
        self.layout.addWidget(self.wiki_btn)
        self.layout.addWidget(self.exit_btn)

        # Progress bar for loading mods
        self.load_progress = QProgressBar()
        self.load_progress.setMinimumWidth(160)
        self.load_progress.setMaximumWidth(160)
        self.load_progress.setMinimumHeight(40)
        self.load_progress.setValue(0)
        self.load_progress.setMaximum(150)
        self.load_progress.setStyleSheet("""
            QProgressBar {
                border: 1px solid gold;
                border-radius: 5px;
                background-color: #333;
                text-align: center;
                font-size: 9pt;
            }
            QProgressBar::chunk {
                background-color: #777;
                width: 1px;
            }
        """)
        self.layout.addWidget(self.load_progress, alignment=Qt.AlignCenter)

        # Create database instance and mod manager
        from core.game_state import GameState
        self.gs = GameState()
        self.mod_manager = ModManager(self.gs)

    #
    #
    #

    def quit_game(self):
        QCoreApplication.instance().quit()

    def load_mods(self):
        """Load available mods from TOML file"""
        try:
            with open('data/mods.toml', 'r') as file:
                mods_data = toml.load(file)

            for mod in mods_data.get('mods', []):
                self.mod_combo_box.addItem(mod.get('name', 'Unknown Mod'))
        except Exception as e:
            print(f"Error loading mods: {e}")
            self.mod_combo_box.addItem("Default")

    def update_load_progress(self, value):
        """Update the load progress bar value"""
        self.load_progress.setValue(value)
        QCoreApplication.processEvents()  # Ensure UI updates

    def start_new_game(self):
        """Start new game with selected mod"""
        selected_mod = self.mod_combo_box.currentText()
        print(f"Mod selected: {selected_mod}")

        # Show progress bar for loading
        self.update_load_progress(0)

        # Simulate loading steps (replace with actual loading logic)
        self.mod_manager.load_mod(selected_mod, self.update_load_progress)

        import time
        time.sleep(0.5)

        navigation.switch_to_pick_scenario(selected_mod)

    def showEvent(self, event):
        super().showEvent(event)
        self.reset_progress_bar()

    def reset_progress_bar(self):
        """Reset the progress bar to 0 when entering the widget."""
        self.load_progress.setValue(0)
