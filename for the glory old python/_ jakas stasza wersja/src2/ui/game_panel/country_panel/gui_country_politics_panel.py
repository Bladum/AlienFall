from PySide6.QtCore import Qt, QSize
from PySide6.QtWidgets import QLabel, QVBoxLayout, QWidget, QGridLayout, QFrame, QGroupBox, QTableWidget, QTableWidgetItem, QHeaderView, QCheckBox, QPushButton, \
    QProgressBar
import random

from core.game_state import GameState
from ref.ref_policy import Policies

gs = GameState()

# Define cell size (30px per cell)
CS = 15

class GUI_CountryPoliciesPanel(QWidget):
    def __init__(self, parent=None):
        super().__init__(parent)

        ruler_frame = QGroupBox(self)
        ruler_frame.setTitle("Agent info")
        ruler_frame.setGeometry( 1 * CS, 1 * CS, 22 * CS, 8 * CS)

        table_label = QLabel("National Ideas", self)
        table_label.setAlignment(Qt.AlignCenter)
        table_label.setGeometry(1 * CS, 10 * CS, 22 * CS, 1 * CS)

        self.table_national_ideas = QTableWidget(self)
        self.table_national_ideas.setColumnCount(5)
        self.table_national_ideas.setHorizontalHeaderLabels(["Name", "Cst", "Tim", "Per", "Act"])
        self.table_national_ideas.setColumnWidth(0, 165)
        self.table_national_ideas.setColumnWidth(1, 40)
        self.table_national_ideas.setColumnWidth(2, 40)
        self.table_national_ideas.setColumnWidth(3, 40)
        self.table_national_ideas.setColumnWidth(4, 30)

        self.table_national_ideas.setGeometry(1 * CS, 11 * CS, 22 * CS, 17 * CS)
        self.table_national_ideas.setSortingEnabled(False)
        self.table_national_ideas.setVerticalScrollBarPolicy(Qt.ScrollBarAlwaysOn)
        self.table_national_ideas.horizontalHeader().setSectionResizeMode(QHeaderView.Fixed)
        self.table_national_ideas.verticalHeader().setVisible(False)



        self.table_national_ideas.setRowCount(10)
        self.table_national_ideas.verticalHeader().setDefaultSectionSize(30)
        for row in range(10):
            self.table_national_ideas.setItem(row, 0, QTableWidgetItem(f"Idea name very long"))
            self.table_national_ideas.item(row, 0).setFlags(Qt.ItemIsEnabled)
            self.table_national_ideas.item(row, 0).setToolTip("This is the first item tool tip and tralalala")
            self.table_national_ideas.setItem(row, 1, QTableWidgetItem(f"{random.randint(100, 200)}"))
            self.table_national_ideas.item(row, 1).setFlags(Qt.ItemIsEnabled)
            self.table_national_ideas.item(row, 1).setTextAlignment(Qt.AlignCenter)
            self.table_national_ideas.setItem(row, 2, QTableWidgetItem(f"{random.randint(10, 20)}"))
            self.table_national_ideas.item(row, 2).setFlags(Qt.ItemIsEnabled)
            self.table_national_ideas.item(row, 2).setTextAlignment(Qt.AlignCenter)
            self.table_national_ideas.setItem(row, 3, QTableWidgetItem(f"{random.randint(-5, 5)}"))
            self.table_national_ideas.item(row, 3).setFlags(Qt.ItemIsEnabled)
            self.table_national_ideas.item(row, 3).setTextAlignment(Qt.AlignCenter)
            checkbox = QCheckBox()
            checkbox.setStyleSheet("""
                QCheckBox { margin: 0; padding: 0; }
                QCheckBox::indicator { width: 30px; height: 30px; background-color: darkred; }
                QCheckBox::indicator:checked { background-color: darkgreen; }                
            """)
            self.table_national_ideas.setCellWidget(row, 4, checkbox)



        table_label2 = QLabel("Domestic Policies", self)
        table_label2.setAlignment(Qt.AlignCenter)
        table_label2.setGeometry(25 * CS, 0 * CS, 22 * CS, 1 * CS)
        table_label2.setStyleSheet("background-color: transparent; font-size: 9pt; ")

        self.domestic_sliders_table = QTableWidget(self)
        self.domestic_sliders_table.setColumnCount(6)
        self.domestic_sliders_table.setHorizontalHeaderLabels(["Name", "cost", "time", "", "Level", ""])
        self.domestic_sliders_table.setColumnWidth(0, 120)
        self.domestic_sliders_table.setColumnWidth(1, 40)
        self.domestic_sliders_table.setColumnWidth(2, 40)
        self.domestic_sliders_table.setColumnWidth(3, 20)   # LEFT
        self.domestic_sliders_table.setColumnWidth(4, 75)   # LEVEL
        self.domestic_sliders_table.setColumnWidth(5, 20)   # RIGHT

        self.domestic_sliders_table.setGeometry(25 * CS, 1 * CS, 22 * CS, 27 * CS)
        self.domestic_sliders_table.setSortingEnabled(False)
        self.domestic_sliders_table.setVerticalScrollBarPolicy(Qt.ScrollBarAlwaysOn)
        self.domestic_sliders_table.horizontalHeader().setSectionResizeMode(QHeaderView.Fixed)
        self.domestic_sliders_table.verticalHeader().setVisible(False)

        policies = list(gs.db_policies.values())

        self.domestic_sliders_table.setRowCount( len(policies) )
        self.domestic_sliders_table.verticalHeader().setDefaultSectionSize(30)
        for row in range( len(policies) ):
            policy_data : Policies = policies[row]
            self.domestic_sliders_table.setItem(row, 0, QTableWidgetItem(policy_data.name))
            self.domestic_sliders_table.item(row, 0).setFlags(Qt.ItemIsEnabled)
            self.domestic_sliders_table.item(row, 0).setToolTip(policy_data.label)
            self.domestic_sliders_table.setItem(row, 1, QTableWidgetItem(f"{random.randint(100, 200)}"))
            self.domestic_sliders_table.item(row, 1).setFlags(Qt.ItemIsEnabled)
            self.domestic_sliders_table.item(row, 1).setTextAlignment(Qt.AlignCenter)
            self.domestic_sliders_table.setItem(row, 2, QTableWidgetItem(f"{random.randint(10, 20)}"))
            self.domestic_sliders_table.item(row, 2).setFlags(Qt.ItemIsEnabled)
            self.domestic_sliders_table.item(row, 2).setTextAlignment(Qt.AlignCenter)

            progress_bar = QProgressBar()
            progress_bar.setRange(0, 10)
            progress_bar.setValue(random.randint(0, 10))
            progress_bar.setAlignment(Qt.AlignCenter)
            progress_bar.setTextVisible(True)
            progress_bar.setFormat("%v")  # Show actual value instead of percentage
            progress_bar.setStyleSheet("""
                QProgressBar {
                    border: 1px solid #555;
                    border-radius: 0px;
                    background-color: darkred;
                    text-align: center;
                }
                QProgressBar::chunk {
                    background-color: darkgreen;
                    width: 1px;
                }
            """)
            self.domestic_sliders_table.setCellWidget(row, 4, progress_bar)

            # Create decrease button
            decrease_button = QPushButton("<<")
            decrease_button.setStyleSheet("""
                QPushButton { 
                    background-color: #555;
                    color: white;
                    font-size: 10pt;
                    margin: 1;
                    padding: 0;
                    border: 0px solid black;
                    border-radius: 0px;
                }
                QPushButton:hover {
                    background-color: #333;
                }
                QPushButton:pressed {
                    background-color: #777;
                }
            """)
            decrease_button.setFixedSize(QSize(20, 30))

            # Create increase button
            increase_button = QPushButton(">>")
            increase_button.setStyleSheet("""
                QPushButton { 
                    background-color: #555;
                    color: white;
                    font-size: 10pt;
                    margin: 1;
                    padding: 0;
                    border: 0px solid black;
                    border-radius: 0px;
                }
                QPushButton:hover {
                    background-color: #333;
                }
                QPushButton:pressed {
                    background-color: #777;
                }
            """)
            increase_button.setFixedSize(QSize(20, 30))

            self.domestic_sliders_table.setCellWidget(row, 3, decrease_button)
            self.domestic_sliders_table.setCellWidget(row, 5, increase_button)

