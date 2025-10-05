from PySide6.QtCore import Qt
from PySide6.QtWidgets import QHBoxLayout, QPushButton, QLabel, QTableWidgetItem, QTableWidget, QWidget, QVBoxLayout, \
    QRadioButton, QSizePolicy, QHeaderView, QButtonGroup


class RecruitArmyPanel(QWidget):
    def __init__(self, parent=None):
        super().__init__(parent)
        self.setLayout(QVBoxLayout())
        self.layout().setContentsMargins(4, 4, 4, 4)
        self.setFixedWidth(300)
        self.init_recruitment_ui()

    def init_recruitment_ui(self):

        print("  GUI - recruit army panel")

        # Add Recruitment label
        recruitment_label = QLabel("<b>BUILD ARMY</b>")
        recruitment_label.setAlignment(Qt.AlignCenter)
        self.layout().addWidget(recruitment_label)

        # Add province name label
        province_label = QLabel("Province:  Pomerania")
        province_label.setAlignment(Qt.AlignCenter)
        self.layout().addWidget(province_label)

        # Add manpower, bravery, and revolt risk labels
        recruitment_layout = QHBoxLayout()
        manpower_label = QLabel("<b><font color='darkgreen'>Manpower</font></b><br>3")
        manpower_label.setAlignment(Qt.AlignCenter)
        bravery_label = QLabel("<b><font color='darkyellow'>Bravery</font></b><br>125%")
        bravery_label.setAlignment(Qt.AlignCenter)
        revolt_risk_label = QLabel("<b><font color='darkred'>Revolt Risk</font></b><br>4%")
        revolt_risk_label.setAlignment(Qt.AlignCenter)
        recruitment_layout.addWidget(manpower_label)
        recruitment_layout.addWidget(bravery_label)
        recruitment_layout.addWidget(revolt_risk_label)
        self.layout().addLayout(recruitment_layout)

        # Add Build Army label
        build_army_label = QLabel("<b>Build Army</b>")
        build_army_label.setAlignment(Qt.AlignCenter)
        self.layout().addWidget(build_army_label)

        # Add Build Army table
        build_army_table = QTableWidget(5, 4)
        build_army_table.setContentsMargins(0, 0, 0, 0)
        build_army_table.horizontalHeader().setSectionResizeMode(QHeaderView.Fixed)
        build_army_table.setSizePolicy(QSizePolicy.Minimum, QSizePolicy.Minimum)
        build_army_table.setSizeAdjustPolicy(QTableWidget.AdjustToContents)
        build_army_table.setHorizontalHeaderLabels(["Item", "More", "Less", "Num"])
        build_army_table.setSelectionMode(QTableWidget.NoSelection)
        build_army_table.setEditTriggers(QTableWidget.NoEditTriggers)
        build_army_table.verticalHeader().setVisible(False)
        build_army_table.setColumnWidth(0, 170)
        build_army_table.setColumnWidth(1, 40)
        build_army_table.setColumnWidth(2, 40)
        build_army_table.setColumnWidth(3, 40)

        build_army_items = ["Infantry", "Cavalry", "Artillery", "Training", "Supplies"]
        for i, item in enumerate(build_army_items):
            build_army_table.setItem(i, 0, QTableWidgetItem(item))
            build_army_table.setRowHeight(i, 20)
            if item in ["Training", "Supplies"]:
                button_group = QButtonGroup(self)
                for j, button_text in enumerate(["Low", "Med", "High"]):
                    radio_button = QRadioButton(button_text)
                    radio_button.setAutoExclusive(True)
                    radio_button.setStyleSheet(f"""
                        QRadioButton {{
                            font-size: 12pt;
                            font-weight: bold;
                        }}
                        QRadioButton::indicator {{
                            width: 40px;
                            height: 20px;
                            background-color: lightgray;
                        }}
                        QRadioButton::indicator:checked {{
                            background-color: {'salmon' if j == 0 else 'yellow' if j == 1 else 'green'};
                        }}
                    """)
                    if j == 0:
                        radio_button.setChecked(True)
                    button_group.addButton(radio_button)
                    build_army_table.setCellWidget(i, j + 1, radio_button)
            else:
                build_army_table.setItem(i, 3, QTableWidgetItem("0"))
                build_army_table.item(i, 3).setTextAlignment(Qt.AlignCenter)
                for j in range(1, 3):
                    button = QPushButton("▼" if j == 1 else "▲")
                    button.setFlat(True)
                    button.setStyleSheet("font-size: 12pt; font-weight: bold;")
                    build_army_table.setCellWidget(i, j, button)
        self.layout().addWidget(build_army_table)

        # Add Mercenaries label
        mercenaries_label = QLabel("<b>Mercenaries</b>")
        mercenaries_label.setAlignment(Qt.AlignCenter)
        self.layout().addWidget(mercenaries_label)

        # Add Mercenaries table
        mercenaries_table = QTableWidget(4, 4)
        mercenaries_table.setContentsMargins(0, 0, 0, 0)
        mercenaries_table.horizontalHeader().setSectionResizeMode(QHeaderView.Fixed)
        mercenaries_table.setSizePolicy(QSizePolicy.Minimum, QSizePolicy.Minimum)
        mercenaries_table.setSizeAdjustPolicy(QTableWidget.AdjustToContents)
        mercenaries_table.setHorizontalHeaderLabels(["Item", "More", "Less", "Num"])
        mercenaries_table.setSelectionMode(QTableWidget.NoSelection)
        mercenaries_table.setEditTriggers(QTableWidget.NoEditTriggers)
        mercenaries_table.verticalHeader().setVisible(False)
        mercenaries_table.setColumnWidth(0, 170)
        mercenaries_table.setColumnWidth(1, 40)
        mercenaries_table.setColumnWidth(2, 40)
        mercenaries_table.setColumnWidth(3, 40)

        build_army_items = ["Infantry", "Cavalry", "Training", "Supplies"]
        for i, item in enumerate(build_army_items):
            mercenaries_table.setItem(i, 0, QTableWidgetItem(item))
            mercenaries_table.setRowHeight(i, 20)
            if item in ["Training", "Supplies"]:
                button_group = QButtonGroup(self)
                for j, button_text in enumerate(["Low", "Med", "High"]):
                    radio_button = QRadioButton(button_text)
                    radio_button.setAutoExclusive(True)
                    radio_button.setStyleSheet(f"""
                        QRadioButton {{
                            font-size: 12pt;
                            font-weight: bold;
                        }}
                        QRadioButton::indicator {{
                            width: 40px;
                            height: 20px;
                            background-color: lightgray;
                        }}
                        QRadioButton::indicator:checked {{
                            background-color: {'salmon' if j == 0 else 'yellow' if j == 1 else 'green'};
                        }}
                    """)
                    if j == 0:
                        radio_button.setChecked(True)
                    button_group.addButton(radio_button)
                    cell_widget = QWidget()
                    cell_layout = QHBoxLayout(cell_widget)
                    cell_layout.addWidget(radio_button)
                    cell_layout.setAlignment(Qt.AlignCenter)
                    cell_layout.setContentsMargins(0, 0, 0, 0)
                    mercenaries_table.setCellWidget(i, j + 1, cell_widget)
            else:
                mercenaries_table.setItem(i, 3, QTableWidgetItem("0"))
                mercenaries_table.item(i, 3).setTextAlignment(Qt.AlignCenter)
                for j in range(1, 3):
                    button = QPushButton("▼" if j == 1 else "▲")
                    button.setFlat(True)
                    button.setStyleSheet("font-size: 12pt; font-weight: bold;")
                    cell_widget = QWidget()
                    cell_layout = QHBoxLayout(cell_widget)
                    cell_layout.addWidget(button)
                    cell_layout.setAlignment(Qt.AlignCenter)
                    cell_layout.setContentsMargins(0, 0, 0, 0)
                    mercenaries_table.setCellWidget(i, j, cell_widget)
        self.layout().addWidget(mercenaries_table)

        # Add Army Leader label
        army_leader_label = QLabel("<b>Army Leader</b>")
        army_leader_label.setAlignment(Qt.AlignCenter)
        self.layout().addWidget(army_leader_label)

        # Add Army Leader table
        army_leader_table = QTableWidget(4, 4)
        army_leader_table.setContentsMargins(0, 0, 0, 0)
        army_leader_table.horizontalHeader().setSectionResizeMode(QHeaderView.Fixed)
        army_leader_table.setSizePolicy(QSizePolicy.Minimum, QSizePolicy.Minimum)
        army_leader_table.setSizeAdjustPolicy(QTableWidget.AdjustToContents)
        army_leader_table.setHorizontalHeaderLabels(["Item", "Low", "Avg", "High"])
        army_leader_table.setSelectionMode(QTableWidget.NoSelection)
        army_leader_table.setEditTriggers(QTableWidget.NoEditTriggers)
        army_leader_table.verticalHeader().setVisible(False)
        army_leader_table.setColumnWidth(0, 170)
        army_leader_table.setColumnWidth(1, 40)
        army_leader_table.setColumnWidth(2, 40)
        army_leader_table.setColumnWidth(3, 40)

        army_leader_items = ["Offense", "Defense", "Siege", "Tactics"]
        for i, item in enumerate(army_leader_items):
            army_leader_table.setItem(i, 0, QTableWidgetItem(item))
            army_leader_table.setRowHeight(i, 20)
            for j, button_text in enumerate(["Low", "Med", "High"]):
                button = QRadioButton(button_text)
                button.setAutoExclusive(True)
                button.setStyleSheet(f"""
                    QRadioButton {{
                        font-size: 12pt;
                        font-weight: bold;
                    }}
                    QRadioButton::indicator {{
                        width: 40px;
                        height: 20px;
                        background-color: lightgray;
                    }}
                    QRadioButton::indicator:checked {{
                        background-color: {'salmon' if j == 0 else 'yellow' if j == 1 else 'green'};
                    }}
                """)
                if j == 0:
                    button.setChecked(True)
                army_leader_table.setCellWidget(i, j + 1, button)
        self.layout().addWidget(army_leader_table)

        # Add Total Cost label
        total_cost_label = QLabel("<b>Total Cost</b>")
        total_cost_label.setAlignment(Qt.AlignCenter)
        self.layout().addWidget(total_cost_label)

        # Add Total Cost table
        total_cost_table = QTableWidget(1, 3)
        total_cost_table.setContentsMargins(0, 0, 0, 0)
        total_cost_table.horizontalHeader().setSectionResizeMode(QHeaderView.Fixed)
        total_cost_table.setSizePolicy(QSizePolicy.Minimum, QSizePolicy.Minimum)
        total_cost_table.setSizeAdjustPolicy(QTableWidget.AdjustToContents)
        total_cost_table.setHorizontalHeaderLabels(["Manpower", "Turns", "General"])
        total_cost_table.setSelectionMode(QTableWidget.NoSelection)
        total_cost_table.setEditTriggers(QTableWidget.NoEditTriggers)
        total_cost_table.verticalHeader().setVisible(False)
        total_cost_table.setColumnWidth(0, 70)
        total_cost_table.setColumnWidth(1, 70)
        total_cost_table.setColumnWidth(2, 70)
        for i in range(3):
            total_cost_table.setItem(0, i, QTableWidgetItem("0"))
            total_cost_table.item(0, i).setTextAlignment(Qt.AlignCenter)
        self.layout().addWidget(total_cost_table)

        # Add Actions label
        actions_label = QLabel("<b>Actions</b>")
        actions_label.setAlignment(Qt.AlignCenter)
        self.layout().addWidget(actions_label)

        # Add Cancel and Build buttons
        actions_layout = QHBoxLayout()
        cancel_button = QPushButton("Cancel")
        build_button = QPushButton("Build")
        cancel_button.setFixedSize(140, 40)
        cancel_button.setContentsMargins(0, 0, 0, 0)
        build_button.setFixedSize(140, 40)
        build_button.setContentsMargins(0, 0, 0, 0)
        actions_layout.addWidget(cancel_button)
        actions_layout.addWidget(build_button)
        self.layout().addLayout(actions_layout)

        # Add empty panel to fill empty space
        empty_panel = QWidget()
        empty_panel.setSizePolicy(QSizePolicy.Expanding, QSizePolicy.Expanding)
        self.layout().addWidget(empty_panel)
