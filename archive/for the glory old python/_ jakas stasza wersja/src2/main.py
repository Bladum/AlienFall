import sys

from PySide6.QtGui import QIcon
from PySide6.QtWidgets import QApplication
from src2.controllers.game_controller import GameController
from src2.ui.main_window import MainGameWindow

APP_NAME = 'MyEU'
APP_VERSION = '0.3'
GLOBAL_STYLE = """
    QToolTip { 
        background-color: #222; 
        color:  #EEE; 
        border: 1px solid #555; 
        font-family: 'Consolas'; 
        font-size: 9pt; 
        border-radius: 4px; 
        padding: 3px;
    }
    QWidget { 
        background-color: #1A1A1A; 
        color: #EEE; 
        font-family: 'Consolas'; 
        font-size: 9pt; 
    }
    QMainWindow { 
        background-color: #1A1A1A; 
        border: 1px solid #444;
    }
    QMenuBar { 
        background-color: #2A2A2A; 
        color:  #EEE; 
        border-bottom: 1px solid #444;
    }
    QMenu { 
        background-color: #2A2A2A; 
        color:  #EEE; 
        border: 1px solid #444;
    }
    QMenu::item:selected { 
        background-color: #3A3A3A; 
    }
    QStatusBar { 
        background-color: #2A2A2A; 
        color:  #EEE; 
        border-top: 1px solid #444;
    }

    QPushButton { 
        background-color: #333; 
        color:  #EEE; 
        border: 1px solid #555; 
        border-radius: 4px; 
        padding: 5px;
    }
    QPushButton:hover { 
        background-color: #444; 
        border: 1px solid #AAA;
    }
    QPushButton:pressed { 
        background-color: #222;
        border: 1px solid gold;
    }
    QPushButton:checked {
        background-color: #2A2A2A;
        border: 1px solid #CCC;
        color: gold;
    }
    QLineEdit { 
        background-color: #2A2A2A; 
        color: #EEE; 
        border: 1px solid #555; 
        border-radius: 4px; 
        padding: 3px;
    }
    QLabel { 
        background-color: transparent; 
        font-size: 9pt; 
    }
    QComboBox { 
        background-color: #2A2A2A; 
        color: #EEE; 
        border: 1px solid #555; 
        border-radius: 4px; 
        padding: 3px;
    }
    QCheckBox { 
        color: #EEE; 
        spacing: 5px;
    }
    QListWidget { 
        background-color: #2A2A2A; 
        color: #EEE; 
        border: 1px solid #555; 
        border-radius: 4px;
    }
    QListWidget::item:selected { 
        background-color: #333; 
        color: gold; 
    }
    QRadioButton { 
        color: #EEE; 
        spacing: 5px;
    }
    QTabWidget::pane { 
        border: 1px solid #555; 
        border-radius: 4px; 
        padding: 1px; 
    }
    QTabBar::tab { 
        background: #2A2A2A; 
        color: #EEE; 
        border: 1px solid #555; 
        padding: 6px 10px; 
        border-radius: 4px 4px 0 0; 
        margin-right: 2px;
    }
    QTabBar::tab:selected {
        background: #3A3A3A;
        color: gold;
        border: 1px solid gold;
        border-bottom-color: #3A3A3A;
    }
    QTabWidget::pane { 
        background-color: #222; 
    }
    QTextEdit { 
        background-color: #2A2A2A; 
        color: #EEE; 
        border: 1px solid #555; 
        border-radius: 4px;
    }
    QGroupBox { 
        background-color: transparent; 
        border: 1px solid #555; 
        border-radius: 4px; 
        color: #EEE; 
    }
    QGroupBox:title { 
        subcontrol-origin: margin; 
        subcontrol-position: top center; 
        padding: 0 5px;
    }
    QTableWidget { 
        border: 1px solid #555; 
        background-color: #2A2A2A; 
        font-family: 'Consolas'; 
        font-size: 9pt; 
        border-radius: 4px; 
        gridline-color: #444;
    }
    QTableWidget::item { 
        background-color: #333; 
        font-family: 'Consolas'; 
        font-size: 9pt;
    }
    QTableWidget::item:selected { 
        background-color: #444; 
        color: gold;
    }
    QScrollBar:vertical {
        border: none;
        background: #222;
        width: 12px;
        margin: 12px 0 12px 0;
        border-radius: 6px;
    }
    QScrollBar::handle:vertical {
        background: #555;
        min-height: 20px;
        border-radius: 5px;
    }
    QScrollBar::handle:vertical:hover {
        background: #777;
    }
    QScrollBar::add-line:vertical, QScrollBar::sub-line:vertical {
        height: 0px;
    }
    QScrollBar:horizontal {
        border: none;
        background: #222;
        height: 12px;
        margin: 0 12px 0 12px;
        border-radius: 6px;
    }
    QScrollBar::handle:horizontal {
        background: #555;
        min-width: 20px;
        border-radius: 5px;
    }
    QScrollBar::handle:horizontal:hover {
        background: #777;
    }
    QScrollBar::add-line:horizontal, QScrollBar::sub-line:horizontal {
        width: 0px;
    }
"""


def main():
    # Initialize application
    app = QApplication(sys.argv)
    app.setStyleSheet(GLOBAL_STYLE)

    print("Welcome to myEU game ")

    # Create game controller
    game_controller = GameController()

    # Create main window
    main_window = MainGameWindow(game_controller)

    # Set window properties
    main_window.setWindowTitle(f"{APP_NAME} ver: {APP_VERSION}")
    main_window.setGeometry(50, 50, 1280, 768)
    main_window.setMinimumSize(1280, 768)
    main_window.setToolTipDuration(5000)  # Shorter tooltip duration for better game experience
    main_window.setMouseTracking(True)

    # Set window icon
    try:
        main_window.setWindowIcon(QIcon("icon.ico"))
    except:
        try:
            main_window.setWindowIcon(QIcon("_internal/icon.ico"))
        except:
            pass

    # Show window and run application
    main_window.show()
    sys.exit(app.exec())


if __name__ == "__main__":
    main()