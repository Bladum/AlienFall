from PySide6.QtCore import Qt, QSize, QEvent
from PySide6.QtWidgets import QLabel, QVBoxLayout, QWidget, QGridLayout, QFrame, QGroupBox, QTableWidget, QTableWidgetItem, QHeaderView, QCheckBox, QPushButton, \
    QProgressBar
import random

from core.game_state import GameState
from object.country import Country
from ref.ref_policy import Policies

gs = GameState()

# Define cell size (30px per cell)
CS = 15


class RelationIndicator(QWidget):
    def __init__(self, value=0, parent=None):
        super().__init__(parent)
        self.value = max(-99, min(99, value))  # Clamp value between -99 and 99
        self.setStyleSheet(f"background-color: #333; color: white; font-weight: bold;")
        # Create layout
        layout = QVBoxLayout(self)
        layout.setContentsMargins(0, 0, 0, 0)

        # Create label to display the value
        self.label = QLabel(str(self.value), self)
        self.label.setAlignment(Qt.AlignCenter)
        self.label.setStyleSheet("color: white; font-weight: bold;")

        layout.addWidget(self.label)
        self.setLayout(layout)

        # Set background color based on value
        self.update_color()

    def get_text_color(self):
        if self.value < -75:
            return "#F00"  # Red
        elif self.value < -25:
            return "#F90"  # Orange
        elif self.value <= 25:
            return "#FF0"  # Yellow
        elif self.value <= 75:
            return "#9F0"  # Lime
        else:
            return "#0F0"  # Green

    def update_color(self):
        self.label.setStyleSheet(f"background-color: #333; color: {self.get_text_color()}; font-weight: bold;")


class ThreeStateCheckBox(QPushButton):
    def __init__(self, parent=None, icons=None):
        super().__init__(parent)
        self.state = 0  # -1: low, 0: medium, 1: high
        self.icons = ['❌', '⚽', '🔵'] if icons is None else icons

        # Configure the button appearance
        self.setStyleSheet("""
            QPushButton {
                background-color: transparent;
                border: 0px solid black;
                border-radius 0px;
                font-size: 16pt;
                font-weight: bold;
                min-width: 30px;
                min-height: 35px;
            }
        """)

        # Connect the click event
        self.clicked.connect(self.toggle_state)

        # Set initial state
        self.set_state(0)




    def set_state(self, state):
        """Set the state and update the display"""
        self.state = state
        if state == -1:
            self.setText(self.icons[0])
            self.setStyleSheet("QPushButton { background-color: #733; font-size: 16pt; font-weight: bold; border: 0px solid black; border-radius 0px;}")
        elif state == 0:
            self.setText(self.icons[1])
            self.setStyleSheet("QPushButton { background-color: #773;  font-size: 16pt; font-weight: bold;  border: 0px solid black; border-radius 0px;}")
        elif state == 1:
            self.setText(self.icons[2])
            self.setStyleSheet("QPushButton { background-color: #373; font-size: 16pt; font-weight: bold;  border: 0px solid black; border-radius 0px;}")

    def toggle_state(self):
        """Cycle through the three states"""
        if self.state == -1:
            self.set_state(0)
        elif self.state == 0:
            self.set_state(1)
        else:
            self.set_state(-1)

class GUI_CountryDiplomacyPanel(QWidget):
    def __init__(self, parent=None):
        super().__init__(parent)

        ruler_frame = QGroupBox(self)
        ruler_frame.setTitle("Agent info")
        ruler_frame.setGeometry( 1 * CS, 1 * CS, 22 * CS, 8 * CS)

        table_label = QLabel("Diplomatic actions", self)
        table_label.setAlignment(Qt.AlignCenter)
        table_label.setGeometry(1 * CS, 10 * CS, 22 * CS, 1 * CS)

        # self.table_national_ideas = QTableWidget(self)
        # self.table_national_ideas.setColumnCount(5)
        # self.table_national_ideas.setHorizontalHeaderLabels(["Name", "💰", "⏳", "😇", "Act"])
        # self.table_national_ideas.setColumnWidth(0, 175)
        # self.table_national_ideas.setColumnWidth(1, 35)
        # self.table_national_ideas.setColumnWidth(2, 35)
        # self.table_national_ideas.setColumnWidth(3, 35)
        # self.table_national_ideas.setColumnWidth(4, 35)
        #
        # self.table_national_ideas.setGeometry(1 * CS, 11 * CS, 22 * CS, 18 * CS)
        # self.table_national_ideas.setSortingEnabled(True)
        # self.table_national_ideas.setVerticalScrollBarPolicy(Qt.ScrollBarAlwaysOn)
        # self.table_national_ideas.horizontalHeader().setSectionResizeMode(QHeaderView.Fixed)
        # self.table_national_ideas.verticalHeader().setVisible(False)
        #
        #
        #
        # self.table_national_ideas.setRowCount(10)
        # self.table_national_ideas.verticalHeader().setDefaultSectionSize(35)
        # for row in range(10):
        #     self.table_national_ideas.setItem(row, 0, QTableWidgetItem(f"Idea name very long"))
        #     self.table_national_ideas.item(row, 0).setFlags(Qt.ItemIsEnabled)
        #     self.table_national_ideas.item(row, 0).setToolTip("This is the first item tool tip and tralalala")
        #     self.table_national_ideas.setItem(row, 1, QTableWidgetItem(f"{random.randint(100, 200)}"))
        #     self.table_national_ideas.item(row, 1).setFlags(Qt.ItemIsEnabled)
        #     self.table_national_ideas.item(row, 1).setTextAlignment(Qt.AlignCenter)
        #     self.table_national_ideas.setItem(row, 2, QTableWidgetItem(f"{random.randint(10, 20)}"))
        #     self.table_national_ideas.item(row, 2).setFlags(Qt.ItemIsEnabled)
        #     self.table_national_ideas.item(row, 2).setTextAlignment(Qt.AlignCenter)
        #     self.table_national_ideas.setItem(row, 3, QTableWidgetItem(f"{random.randint(-5, 5)}"))
        #     self.table_national_ideas.item(row, 3).setFlags(Qt.ItemIsEnabled)
        #     self.table_national_ideas.item(row, 3).setTextAlignment(Qt.AlignCenter)
        #     checkbox = QCheckBox()
        #     checkbox.setStyleSheet("""
        #         QCheckBox { margin: 0; padding: 0; }
        #         QCheckBox::indicator { width: 35px; height: 35px; background-color: darkred; }
        #         QCheckBox::indicator:checked { background-color: darkgreen; }
        #     """)
        #     self.table_national_ideas.setCellWidget(row, 4, checkbox)

        table_label2 = QLabel("International relations", self)
        table_label2.setAlignment(Qt.AlignCenter)
        table_label2.setGeometry(25 * CS, 0 * CS, 22 * CS, 1 * CS)

        self.diplomatics_table = QTableWidget(self)
        self.diplomatics_table.setColumnCount(7)
        self.diplomatics_table.setHorizontalHeaderLabels(["Name", "Mil", "Tra", "Acc", "Fin", "Dyn", "Rel"])
        self.diplomatics_table.setColumnWidth(0, 120)
        self.diplomatics_table.setColumnWidth(1, 30)  # military
        self.diplomatics_table.setColumnWidth(2, 30)  # trade
        self.diplomatics_table.setColumnWidth(3, 30)  # access
        self.diplomatics_table.setColumnWidth(4, 30)  # tribute
        self.diplomatics_table.setColumnWidth(5, 30)  # dynasty
        self.diplomatics_table.setColumnWidth(6, 40)  # relation

        self.diplomatics_table.horizontalHeader().setSectionResizeMode(QHeaderView.Fixed)
        self.diplomatics_table.setSortingEnabled(False)
        self.diplomatics_table.setGeometry(25 * CS, 1 * CS, 22 * CS, 27 * CS)
        self.diplomatics_table.setVerticalScrollBarPolicy(Qt.ScrollBarAlwaysOn)
        self.diplomatics_table.verticalHeader().setVisible(False)

        countries = gs.countries

        self.diplomatics_table.setRowCount(len(countries))
        self.diplomatics_table.verticalHeader().setDefaultSectionSize(30)
        row = 0
        for tag, country_data in countries.items():
            self.diplomatics_table.setItem(row, 0, QTableWidgetItem(country_data.name))
            self.diplomatics_table.item(row, 0).setToolTip(country_data.name)

            checkbox_military = ThreeStateCheckBox(icons=['⚔️', '️', '🤝'])
            self.diplomatics_table.setCellWidget(row, 1, checkbox_military)

            checkbox_trade = ThreeStateCheckBox(icons=['🚫', '', '🔄'])
            self.diplomatics_table.setCellWidget(row, 2, checkbox_trade)

            checkbox_access = ThreeStateCheckBox(icons=['🛡️', '️', '🚫'])
            self.diplomatics_table.setCellWidget(row, 3, checkbox_access)

            checkbox_finance = ThreeStateCheckBox(icons=['💰', '️', '💸'])
            self.diplomatics_table.setCellWidget(row, 4, checkbox_finance)

            three_state_checkbox = ThreeStateCheckBox(icons=['❌', '', '🔵'])
            self.diplomatics_table.setCellWidget(row, 5, three_state_checkbox)

            # Add the relation indicator with a random value
            relation_value = random.randint(-99, 99)
            relation_widget = RelationIndicator(relation_value)
            self.diplomatics_table.setCellWidget(row, 6, relation_widget)

            row += 1