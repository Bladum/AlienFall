import sys

from PySide6.QtWidgets import QApplication

from gui.gui_main import GameWindow

if __name__ == "__main__":
    app = QApplication(sys.argv)
    app.setStyle('Fusion')
    viewer = GameWindow()
    viewer.show()
    sys.exit(app.exec())