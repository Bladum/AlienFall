import sys

from PySide6.QtWidgets import QApplication

from NEW.gamemodel import GameModel
from NEW.mainview import MainView

if __name__ == "__main__":
    app = QApplication(sys.argv)

    game_model = GameModel()
    main_view = MainView(game_model)
    main_view.show()

    sys.exit(app.exec())