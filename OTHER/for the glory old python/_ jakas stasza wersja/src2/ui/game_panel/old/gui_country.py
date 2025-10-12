from PySide6.QtCore import Qt
from PySide6.QtGui import QPixmap
from PySide6.QtWidgets import QWidget, QVBoxLayout, QHBoxLayout, QLabel, QTableWidget, QTableWidgetItem, QListWidget, \
    QPushButton, QSizePolicy, QHeaderView

from core.game_state import GameState

gs = GameState()


class CountryPanel(QWidget):
    def __init__(self, parent=None):
        super().__init__(parent)
        self.setLayout(QVBoxLayout())
        self.layout().setContentsMargins(4, 4, 4, 4)
        self.setFixedWidth(300)
        self.init_ui()

    def init_ui(self):

        print("  GUI - Country Info panel")

        # Add country name label
        country_name_label = QLabel("<b>COUNTRY DETAILS</b>")
        country_name_label.setAlignment(Qt.AlignCenter)
        self.layout().addWidget(country_name_label)

        # Add province name label
        country_name_label = QLabel("Poland")
        country_name_label.setAlignment(Qt.AlignCenter)
        self.layout().addWidget(country_name_label)

        governance_type_name_label = QLabel("Kingdom")
        governance_type_name_label.setAlignment(Qt.AlignCenter)
        self.layout().addWidget(governance_type_name_label)

        # Add stability, flag, and state religion
        top_layout = QHBoxLayout()
        stab_label = QLabel("<b>Stability</b><br>3")
        stab_label.setAlignment(Qt.AlignCenter)
        flag_label = QLabel("<b>Flag</b>")
        flag_label.setPixmap(QPixmap('data/ftg/gfx/flagFRA.png').scaled(10, 10, Qt.KeepAspectRatio))

        flag_label.setAlignment(Qt.AlignCenter)
        state_religion_label = QLabel("<b>Religion</b><br>CAT")
        state_religion_label.setAlignment(Qt.AlignCenter)
        top_layout.addWidget(stab_label)
        top_layout.addWidget(flag_label)
        top_layout.addWidget(state_religion_label)
        self.layout().addLayout(top_layout)

        # Add points and ranking label
        points_ranking_label = QLabel("Points: 1000      Rank: #3")
        points_ranking_label.setAlignment(Qt.AlignCenter)
        self.layout().addWidget(points_ranking_label)

        # Add monarch label
        monarch_label = QLabel("<b>Monarch</b>")
        monarch_label.setAlignment(Qt.AlignCenter)
        self.layout().addWidget(monarch_label)

        # Add monarch name
        monarch_name_label = QLabel("Wladyslaw IV")
        monarch_name_label.setAlignment(Qt.AlignCenter)
        self.layout().addWidget(monarch_name_label)

        # Add monarch skills
        skills_layout = QHBoxLayout()
        mil_label = QLabel("<b>MIL</b>\n3")
        mil_label.setAlignment(Qt.AlignCenter)
        dip_label = QLabel("<b>DIP</b>\n")
        dip_label.setAlignment(Qt.AlignCenter)
        adm_label = QLabel("<b>ADM</b>\n3")
        adm_label.setAlignment(Qt.AlignCenter)
        skills_layout.addWidget(mil_label)
        skills_layout.addWidget(dip_label)
        skills_layout.addWidget(adm_label)
        self.layout().addLayout(skills_layout)

        # Add technologies label
        technologies_label = QLabel("<b>Technologies</b>")
        technologies_label.setAlignment(Qt.AlignCenter)
        self.layout().addWidget(technologies_label)

        # Add technologies table
        technologies_table = QTableWidget(6, 2)
        technologies_table.setContentsMargins(0, 0, 0, 0)
        technologies_table.horizontalHeader().setSectionResizeMode(QHeaderView.Fixed)
        technologies_table.setSizePolicy(QSizePolicy.Minimum, QSizePolicy.Minimum)
        technologies_table.setSizeAdjustPolicy(QTableWidget.AdjustToContents)
        technologies_table.setHorizontalHeaderLabels(["Technology name", "Value"])
        technologies_table.verticalHeader().setVisible(False)
        technologies_table.setColumnWidth(0, 190)
        technologies_table.setColumnWidth(1, 100)
        technologies_table.setItem(0, 0, QTableWidgetItem("Land"))
        technologies_table.setItem(1, 0, QTableWidgetItem("Naval"))
        technologies_table.setItem(2, 0, QTableWidgetItem("Infra"))
        technologies_table.setItem(3, 0, QTableWidgetItem("Trade"))
        technologies_table.setItem(4, 0, QTableWidgetItem("Admin"))
        for i in range(5):
            technologies_table.setItem(i, 1, QTableWidgetItem("3"))
            technologies_table.setRowHeight(i, 20)
        self.layout().addWidget(technologies_table)

        # Add cultures label
        cultures_label = QLabel("<b>Cultures accepted</b>")
        cultures_label.setAlignment(Qt.AlignCenter)
        self.layout().addWidget(cultures_label)

        # Add cultures list
        cultures_list = QListWidget()
        cultures_list.setContentsMargins(0, 0, 0, 0)
        cultures_list.setSizeAdjustPolicy(QTableWidget.AdjustToContents)
        cultures_list.setMaximumHeight(60)

        cultures_list.addItems(["Culture 1", "Culture 2", "Culture 3"])
        self.layout().addWidget(cultures_list)

        # Add missions label
        missions_label = QLabel("<b>Current missions</b>")
        missions_label.setAlignment(Qt.AlignCenter)
        self.layout().addWidget(missions_label)

        # Add missions list
        missions_list = QListWidget()
        missions_list.setContentsMargins(0, 0, 0, 0)
        missions_list.setSizeAdjustPolicy(QTableWidget.AdjustToContents)
        missions_list.setMaximumHeight(100)

        missions_list.addItems(["Mission 1", "Mission 2", "Mission 3"])
        self.layout().addWidget(missions_list)

        # Add actions label
        actions_label = QLabel("<b>Actions</b>")
        actions_label.setAlignment(Qt.AlignCenter)
        self.layout().addWidget(actions_label)

        # Add action buttons
        actions_layout = QHBoxLayout()

        action_button1 = QPushButton("Action 1")
        action_button1.setFixedSize(95, 40)
        action_button1.setContentsMargins(0, 0, 0, 0)
        actions_layout.addWidget(action_button1)

        action_button2 = QPushButton("Action 2")
        action_button2.setFixedSize(95, 40)
        action_button2.setContentsMargins(0, 0, 0, 0)
        actions_layout.addWidget(action_button2)

        action_button3 = QPushButton("Action 3")
        action_button3.setFixedSize(95, 40)
        action_button3.setContentsMargins(0, 0, 0, 0)
        actions_layout.addWidget(action_button3)

        self.layout().addLayout(actions_layout)

        # Add empty panel to fill empty space
        empty_panel = QWidget()
        empty_panel.setSizePolicy(QSizePolicy.Expanding, QSizePolicy.Expanding)
        self.layout().addWidget(empty_panel)