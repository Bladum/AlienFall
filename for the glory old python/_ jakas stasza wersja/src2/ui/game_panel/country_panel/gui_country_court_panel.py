from PySide6.QtCore import Qt
from PySide6.QtWidgets import QLabel, QVBoxLayout, QWidget, QGridLayout, QFrame, QGroupBox

# Define cell size (30px per cell)
CS = 15

class GUI_CountryCourtPanel(QWidget):
    def __init__(self, parent=None):
        super().__init__(parent)

        ruler_frame = QGroupBox(self)
        ruler_frame.setTitle("Ruler")
        ruler_frame.setGeometry( 1 * CS, 1 * CS, 22 * CS, 13 * CS)

        advisor_frame = QGroupBox(self)
        advisor_frame.setTitle("Advisors")
        advisor_frame.setGeometry( 25 * CS, 1 * CS, 22 * CS, 13 * CS)

        heirs_frame = QGroupBox(self)
        heirs_frame.setTitle("Heirs")
        heirs_frame.setGeometry( 1 * CS, 15 * CS, 22 * CS, 13 * CS)

        gov_frame = QGroupBox(self)
        gov_frame.setTitle("Government")
        gov_frame.setGeometry( 25 * CS, 15 * CS, 22 * CS, 13 * CS)