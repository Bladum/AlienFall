from PySide6 import QtGui
from PySide6.QtCore import Qt
from PySide6.QtWidgets import QWidget, QVBoxLayout, QTableWidget, QLabel, QSizePolicy, QTableWidgetItem, QGridLayout, \
    QPushButton, QHBoxLayout, QHeaderView, QTextEdit


class BattleLandPanel(QWidget):
    def __init__(self, parent=None):
        super().__init__(parent)
        self.setLayout(QVBoxLayout())
        self.layout().setContentsMargins(4, 4, 4, 4)
        self.setFixedWidth(300)
        self.init_ui()

    def  init_ui(self):

        print( "  GUI - battle land panel")

        # Add Battle Panel label
        battle_label = QLabel("<b>LAND BATTLE</b>")
        battle_label.setAlignment(Qt.AlignCenter)
        self.layout().addWidget(battle_label)

        province_label = QLabel("Province:  Mazowsze")
        province_label.setAlignment(Qt.AlignCenter)
        self.layout().addWidget(province_label)

        # Create HBoxLayout for Attacker, Ratio, Defender labels
        hbox_layout = QHBoxLayout()

        attacker_label = QLabel("<b>Attacker</b>")
        attacker_label.setAlignment(Qt.AlignCenter)
        hbox_layout.addWidget(attacker_label)

        ratio_label = QLabel("<b style='font-size: 14pt;'>1.4 : 1</b>")
        ratio_label.setAlignment(Qt.AlignCenter)
        hbox_layout.addWidget(ratio_label)

        defender_label = QLabel("<b>Defender</b>")
        defender_label.setAlignment(Qt.AlignCenter)
        hbox_layout.addWidget(defender_label)

        self.layout().addLayout(hbox_layout)

        # Add Location label
        location_label = QLabel("<b>Location</b>")
        location_label.setAlignment(Qt.AlignCenter)
        self.layout().addWidget(location_label)

        # Add Location table
        location_table = QTableWidget(3, 2)
        location_table.setContentsMargins(0, 0, 0, 0)
        location_table.horizontalHeader().setSectionResizeMode(QHeaderView.Fixed)
        location_table.setSizePolicy(QSizePolicy.Minimum, QSizePolicy.Minimum)
        location_table.setSizeAdjustPolicy(QTableWidget.AdjustToContents)
        location_table.setHorizontalHeaderLabels(["Name", "Value"])
        location_table.setSelectionMode(QTableWidget.NoSelection)
        location_table.setEditTriggers(QTableWidget.NoEditTriggers)
        location_table.verticalHeader().setVisible(False)
        location_table.setColumnWidth(0, 170)
        location_table.setColumnWidth(1, 120)

        location_items = ["Terrain", "Weather", "Phase"]
        for i, item in enumerate(location_items):
            location_table.setItem(i, 0, QTableWidgetItem(item))
            location_table.item(i, 0).setTextAlignment(Qt.AlignCenter)
            location_table.setItem(i, 1, QTableWidgetItem("Value"))
            location_table.item(i, 1).setTextAlignment(Qt.AlignCenter)
            location_table.setRowHeight(i, 20)

        self.layout().addWidget(location_table)

        # Add Armies label
        armies_label = QLabel("<b>Armies</b>")
        armies_label.setAlignment(Qt.AlignCenter)
        self.layout().addWidget(armies_label)

        # Add Armies table
        armies_table = QTableWidget(6, 3)
        armies_table.setContentsMargins(0, 0, 0, 0)
        armies_table.horizontalHeader().setSectionResizeMode(QHeaderView.Fixed)
        armies_table.setSizePolicy(QSizePolicy.Minimum, QSizePolicy.Minimum)
        armies_table.setSizeAdjustPolicy(QTableWidget.AdjustToContents)
        armies_table.setHorizontalHeaderLabels(["Attacker", "Parameter", "Defender"])
        armies_table.setSelectionMode(QTableWidget.NoSelection)
        armies_table.setEditTriggers(QTableWidget.NoEditTriggers)
        armies_table.verticalHeader().setVisible(False)
        armies_table.setColumnWidth(0, 85)
        armies_table.setColumnWidth(1, 120)
        armies_table.setColumnWidth(2, 85)

        armies_items = ["Infantry", "Cavalry", "Artillery", "Offensive", "Defensive", "Morale"]
        for i, item in enumerate(armies_items):
            armies_table.setItem(i, 0, QTableWidgetItem("Value"))
            armies_table.item(i, 0).setTextAlignment(Qt.AlignCenter)
            armies_table.setItem(i, 1, QTableWidgetItem(item))
            armies_table.item(i, 1).setTextAlignment(Qt.AlignCenter)
            armies_table.setItem(i, 2, QTableWidgetItem("Value"))
            armies_table.item(i, 2).setTextAlignment(Qt.AlignCenter)
            armies_table.item(i, 1).setBackground(QtGui.QColor("lightgray"))
            armies_table.setRowHeight(i, 20)

        self.layout().addWidget(armies_table)

        # Add Leader label
        leader_label = QLabel("<b>Leader</b>")
        leader_label.setAlignment(Qt.AlignCenter)
        self.layout().addWidget(leader_label)

        # Add Leader table
        leader_table = QTableWidget(5, 3)
        leader_table.setContentsMargins(0, 0, 0, 0)
        leader_table.horizontalHeader().setSectionResizeMode(QHeaderView.Fixed)
        leader_table.setSizePolicy(QSizePolicy.Minimum, QSizePolicy.Minimum)
        leader_table.setSizeAdjustPolicy(QTableWidget.AdjustToContents)
        leader_table.setHorizontalHeaderLabels(["Attacker", "Parameter", "Defender"])
        leader_table.setSelectionMode(QTableWidget.NoSelection)
        leader_table.setEditTriggers(QTableWidget.NoEditTriggers)
        leader_table.verticalHeader().setVisible(False)
        leader_table.setColumnWidth(0, 85)
        leader_table.setColumnWidth(1, 120)
        leader_table.setColumnWidth(2, 85)

        leader_items = ["Offensive", "Defensive", "Tactics", "Siege", "Logistics"]
        for i, item in enumerate(leader_items):
            leader_table.setItem(i, 0, QTableWidgetItem("Value"))
            leader_table.item(i, 0).setTextAlignment(Qt.AlignCenter)
            leader_table.setItem(i, 1, QTableWidgetItem(item))
            leader_table.item(i, 1).setTextAlignment(Qt.AlignCenter)
            leader_table.setItem(i, 2, QTableWidgetItem("Value"))
            leader_table.item(i, 2).setTextAlignment(Qt.AlignCenter)
            leader_table.item(i, 1).setBackground(QtGui.QColor("lightgray"))
            leader_table.setRowHeight(i, 20)

        self.layout().addWidget(leader_table)

        # Add Orders label
        orders_label = QLabel("<b>Orders</b>")
        orders_label.setAlignment(Qt.AlignCenter)
        self.layout().addWidget(orders_label)

        # Add Orders grid with buttons
        orders_layout = QGridLayout()
        orders_layout.setContentsMargins(0, 0, 0, 0)
        orders_layout.setSpacing(0)
        orders_layout.setAlignment(Qt.AlignTop)

        orders = ["Order 1", "Order 2", "Order 3", "Order 4", "Order 5", "Order 6", "Order 7", "Order 8", "Order 9"]
        for index, order in enumerate(orders):
            row = index // 3
            col = index % 3
            button = QPushButton(order)
            button.setFixedSize(95, 40)
            button.setContentsMargins(0, 0, 0, 0)
            orders_layout.addWidget(button, row, col, alignment=Qt.AlignTop)

        self.layout().addLayout(orders_layout)

        # Add Battle button
        battle_button = QPushButton("BATTLE")
        battle_button.setFixedSize(285, 40)
        battle_button.setContentsMargins(0, 0, 0, 0)
        battle_button.clicked.connect(self.log_battle)
        self.layout().addWidget(battle_button, alignment=Qt.AlignCenter)

        # Add empty panel to fill empty space
        self.log_panel = QTextEdit()
        self.log_panel.setReadOnly(True)
        self.layout().addWidget(self.log_panel)

        # Add empty panel to fill empty space
        empty_panel = QWidget()
        empty_panel.setSizePolicy(QSizePolicy.Expanding, QSizePolicy.Expanding)
        self.layout().addWidget(empty_panel)

    def log_battle(self):
        self.log_panel.append("Battle started!")
        # Add more detailed logs as needed
