# src2/ui/menu/gui_options.py
from PySide6.QtWidgets import QWidget, QVBoxLayout, QPushButton, QLabel
from PySide6.QtCore import Qt

class GUI_OptionsWidget(QWidget):
    """Options/settings widget."""

    def __init__(self, main_window):
        super().__init__()
        self.main_window = main_window

        layout = QVBoxLayout(self)
        layout.setAlignment(Qt.AlignCenter)

        # Title
        title = QLabel("Game Options")
        title.setStyleSheet("font-size: 18pt; font-weight: bold; margin: 20px;")
        title.setAlignment(Qt.AlignCenter)

        # Back button
        back_btn = QPushButton("BACK")
        back_btn.setMinimumWidth(200)
        back_btn.setMinimumHeight(50)
        back_btn.clicked.connect(self.main_window.switch_to_starter_widget)

        # Add widgets to layout
        layout.addWidget(title)
        layout.addStretch()
        layout.addWidget(back_btn)