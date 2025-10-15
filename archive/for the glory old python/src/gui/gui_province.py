from PySide6.QtCore import Qt
from PySide6.QtGui import QIcon, QPixmap
from PySide6.QtWidgets import QPushButton, QLabel, QVBoxLayout, QWidget, QGridLayout, QTableWidget, QTableWidgetItem, \
    QHBoxLayout, QSizePolicy, QHeaderView

from battle.battle import LandArmy
from src.db import TDB
from PySide6.QtCore import Qt
db = TDB()

class ProvincePanel(QWidget):
    def __init__(self, parent=None):
        super().__init__(parent)
        self.setLayout(QVBoxLayout())
        self.layout().setContentsMargins(4, 4, 4, 4)
        self.setFixedWidth(300)
        self.init_ui()
        self.setup_infra_table()

    def init_ui(self):

        print("  GUI - province info panel")

        # Add province name label
        main_label = QLabel("<b>PROVINCE DETAILS</b>")
        main_label.setAlignment(Qt.AlignCenter)
        self.layout().addWidget(main_label)

        # Add province name label
        province_label = QLabel("Province:  Pomerania")
        province_label.setAlignment(Qt.AlignCenter)
        self.layout().addWidget(province_label)

        # Add images
        image_layout = QHBoxLayout()
        owner_image = QLabel("Owner Image")
        province_image = QLabel("Province Image")
        occupier_image = QLabel("Occupier Image")
        image_layout.addWidget(owner_image)
        image_layout.addWidget(province_image)
        image_layout.addWidget(occupier_image)
        self.layout().addLayout(image_layout)

        # Add statistics label
        statistics_label = QLabel("<b>Statistics</b>")
        statistics_label.setAlignment(Qt.AlignCenter)
        self.layout().addWidget(statistics_label)

        # Add table grid with data
        data_table = QTableWidget(15, 2)
        data_table.setFixedHeight(
            8 * 20 + data_table.horizontalHeader().height())  # 8 rows * row height + header height
        data_table.setContentsMargins(0, 0, 0, 0)
        data_table.horizontalHeader().setSectionResizeMode(QHeaderView.Fixed)
        data_table.setSizePolicy(QSizePolicy.Minimum, QSizePolicy.Minimum)
        data_table.setSizeAdjustPolicy(QTableWidget.AdjustToContents)
        data_table.setHorizontalHeaderLabels(["Name", "Value"])
        data_table.setSelectionMode(QTableWidget.NoSelection)
        data_table.setEditTriggers(QTableWidget.NoEditTriggers)
        data_table.verticalHeader().setVisible(False)
        data_table.setVerticalScrollBarPolicy(Qt.ScrollBarAlwaysOn)
        data_table.setColumnWidth(0, 165)
        data_table.setColumnWidth(1, 110)

        def add_table_item(data_table, row, name, value, tooltip):
            name_item = QTableWidgetItem(name)
            value_item = QTableWidgetItem(value)
            value_item.setToolTip(tooltip)
            data_table.setItem(row, 0, name_item)
            data_table.setItem(row, 1, value_item)
            data_table.setRowHeight(row, 18)
            data_table.setRowHeight(row + 1, 18)

        add_table_item(data_table, 0, "Population", '7.54', "The current population level of the province")
        add_table_item(data_table, 1, "Growth", '+4.2%', "The growth rate of the population")
        add_table_item(data_table, 2, "Income", '32', "Income generated from production")
        add_table_item(data_table, 3, "Trade Value", '23', "The value of trade in the province")
        add_table_item(data_table, 4, "Manpower", '0.32', "The available manpower for military purposes")
        add_table_item(data_table, 5, "Revolt risk", '0%', "The risk of revolt in the province")
        add_table_item(data_table, 6, "Movement speed", '75%', "Speed modifier for armies and specialists")
        add_table_item(data_table, 7, "Fort Level", '1 - minimal', "The level of fortifications in the province")
        add_table_item(data_table, 8, "Supplies", 'None', "The level of supplies available in the province")
        add_table_item(data_table, 9, "Terrain Type", 'plains', "The type of terrain in the province")
        add_table_item(data_table, 10, "Climate Type", 'arid', "The type of climate in the province")
        add_table_item(data_table, 11, "Religion", 'pagan', "The predominant religion in the province")
        add_table_item(data_table, 12, "Culture", 'polish', "The predominant culture in the province")
        add_table_item(data_table, 13, "Center of Trade", 'Gdansk', "Indicates if the province is a center of trade")

        self.layout().addWidget(data_table)

        # Add actions label
        buildings_label = QLabel("<b>Infrastructure</b>")
        buildings_label.setAlignment(Qt.AlignCenter)
        self.layout().addWidget(buildings_label)

        def create_button(text, row, col, layout):
            button = QPushButton(text)
            button.setFixedSize(95, 40)
            layout.addWidget(button, row, col)
            button.setContentsMargins(0, 0, 0, 0)

            return button

        # Add action buttons to Infrastructure and Military sections
        button_layout = QGridLayout()
        button_layout.setContentsMargins(0, 0, 0, 0)
        button_layout.setSpacing(0)
        button_layout.setAlignment(Qt.AlignTop)
        self.layout().addLayout(button_layout)

        self.infra_table = QTableWidget(len(db.db_buildings), 4)
        self.infra_table.setHorizontalHeaderLabels(["", "Name", "Status", "Cost"])
        self.infra_table.setColumnWidth(0, 50)
        self.infra_table.setColumnWidth(1, 120)
        self.infra_table.setColumnWidth(2, 50)
        self.infra_table.setColumnWidth(3, 50)
        self.infra_table.setFixedHeight(8 * 20 + self.infra_table.horizontalHeader().height())
        self.infra_table.setContentsMargins(0, 0, 0, 0)
        self.infra_table.horizontalHeader().setSectionResizeMode(QHeaderView.Fixed)
        self.infra_table.setSizePolicy(QSizePolicy.Minimum, QSizePolicy.Minimum)
        self.infra_table.setSizeAdjustPolicy(QTableWidget.AdjustToContents)
        self.infra_table.setSelectionMode(QTableWidget.NoSelection)
        self.infra_table.setEditTriggers(QTableWidget.NoEditTriggers)
        self.infra_table.verticalHeader().setVisible(False)
        self.infra_table.setVerticalScrollBarPolicy(Qt.ScrollBarAlwaysOn)
        self.layout().addWidget(self.infra_table)

        # Add military operations label
        military_label = QLabel("<b>Military</b>")
        military_label.setAlignment(Qt.AlignCenter)
        self.layout().addWidget(military_label)

        # Add action buttons to Infrastructure and Military sections
        button_layout2 = QGridLayout()
        button_layout2.setContentsMargins(0, 0, 0, 0)
        button_layout2.setSpacing(0)
        button_layout2.setAlignment(Qt.AlignTop)
        self.layout().addLayout(button_layout2)

        # Add buttons in a 3-column grid for Military Operations
        military_actions = [
            "Build Army", "Train Army", "Mercenaries",
            "Build Navy", "Train Navy", "Pirates"
        ]

        for index, action in enumerate(military_actions):
            row = (index + len(military_actions)) // 3
            col = (index + len(military_actions)) % 3
            create_button(action, row, col, button_layout2)

        # army panel
        army_label = QLabel("<b>Army</b>")
        army_label.setAlignment(Qt.AlignCenter)
        self.layout().addWidget(army_label)

        self.army_table = QTableWidget(0, 7)
        self.army_table.setHorizontalHeaderLabels(["TAG", "Name", "", "", "", "️", ""])
        self.army_table.setColumnWidth(0, 32)
        self.army_table.setColumnWidth(1, 90)
        self.army_table.setColumnWidth(2, 30)
        self.army_table.setColumnWidth(3, 30)
        self.army_table.setColumnWidth(4, 30)
        self.army_table.setColumnWidth(5, 30)
        self.army_table.setColumnWidth(6, 30)
        self.army_table.setFixedHeight(8 * 20 + self.army_table.horizontalHeader().height())
        self.army_table.setContentsMargins(0, 0, 0, 0)
        self.army_table.horizontalHeader().setSectionResizeMode(QHeaderView.Fixed)
        self.army_table.setSizePolicy(QSizePolicy.Minimum, QSizePolicy.Minimum)
        self.army_table.setSizeAdjustPolicy(QTableWidget.AdjustToContents)
        self.army_table.setSelectionMode(QTableWidget.NoSelection)
        self.army_table.setEditTriggers(QTableWidget.NoEditTriggers)
        self.army_table.verticalHeader().setVisible(False)
        self.army_table.setVerticalScrollBarPolicy(Qt.ScrollBarAlwaysOn)

        # Set header images
        self.army_table.horizontalHeaderItem(2).setIcon(
            QIcon(QPixmap(db.res_images['army']['inf.png']).scaled(18, 12, Qt.KeepAspectRatio)))
        self.army_table.horizontalHeaderItem(2).setTextAlignment(Qt.AlignCenter)
        self.army_table.horizontalHeaderItem(3).setIcon(
            QIcon(QPixmap(db.res_images['army']['cav.png']).scaled(18, 12, Qt.KeepAspectRatio)))
        self.army_table.horizontalHeaderItem(3).setTextAlignment(Qt.AlignCenter)
        self.army_table.horizontalHeaderItem(4).setIcon(
            QIcon(QPixmap(db.res_images['army']['art.png']).scaled(18, 12, Qt.KeepAspectRatio)))
        self.army_table.horizontalHeaderItem(4).setTextAlignment(Qt.AlignCenter)
        self.army_table.horizontalHeaderItem(5).setIcon(
            QIcon(QPixmap(db.res_images['army']['morale.png']).scaled(18, 12, Qt.KeepAspectRatio)))
        self.army_table.horizontalHeaderItem(5).setTextAlignment(Qt.AlignCenter)
        self.army_table.horizontalHeaderItem(6).setIcon(
            QIcon(QPixmap(db.res_images['army']['move.png']).scaled(18, 12, Qt.KeepAspectRatio)))
        self.army_table.horizontalHeaderItem(6).setTextAlignment(Qt.AlignCenter)
        self.army_table.horizontalHeader().setFixedHeight(22)

        self.layout().addWidget(self.army_table)

        # Add empty panel to fill empty space
        empty_panel = QWidget()
        empty_panel.setSizePolicy(QSizePolicy.Expanding, QSizePolicy.Expanding)
        self.layout().addWidget(empty_panel)

    def showEvent(self, event):
        super().showEvent(event)
        self.setup_infra_table()

        args = { "owner" : 'POL', 'name': "Army of Mazowia",
                 'infantry': 20, 'cavalry': 17 , 'artillery': 9}
        army = LandArmy(args=args)
        self.add_army_row(army)

        args = {"owner": 'LAT', 'name': "Grand Army of Malbork",
            'infantry': 30, 'cavalry': 2, 'artillery': 11}
        army = LandArmy(args=args)
        self.add_army_row(army)

    def add_army_row(self, army_det : LandArmy):

        row_position = self.army_table.rowCount()
        self.army_table.insertRow(row_position)

        image = db.res_images['flag'].get(army_det.owner_tag + '.png')

        owner_item = QTableWidgetItem()
        owner_item.setData(Qt.DecorationRole, image)
        owner_item.setTextAlignment(Qt.AlignCenter)
        self.army_table.setItem(row_position, 0, owner_item)

        name_item = QTableWidgetItem(army_det.name)
        name_item.setTextAlignment(Qt.AlignLeft | Qt.AlignTop)
        inf_item = QTableWidgetItem(str(army_det.infantry))
        cav_item = QTableWidgetItem(str(army_det.cavalry))
        art_item = QTableWidgetItem(str(army_det.artillery))
        morale_item = QTableWidgetItem('4.5' )
        move_item = QTableWidgetItem( '28' )

        self.army_table.setItem(row_position, 1, name_item)
        self.army_table.setItem(row_position, 2, inf_item)
        self.army_table.setItem(row_position, 3, cav_item)
        self.army_table.setItem(row_position, 4, art_item)
        self.army_table.setItem(row_position, 5, morale_item)
        self.army_table.setItem(row_position, 6, move_item)

        self.army_table.setRowHeight(row_position, 32)

    def setup_infra_table(self):

        if self.infra_table:
            self.infra_table.clearContents()

            for index, action in enumerate(db.db_buildings.values()):
                image_item = QTableWidgetItem()
                image_item.setData(Qt.DecorationRole, action.image)
                image_item.setToolTip(action.tooltip)
                name_item = QTableWidgetItem(action.name)
                status_item = QTableWidgetItem()
                status_item.setCheckState(Qt.Unchecked)
                cost_item = QTableWidgetItem(action.build_cost)

                self.infra_table.setItem(index, 0, image_item)
                self.infra_table.setItem(index, 1, name_item)
                self.infra_table.setItem(index, 2, status_item)
                self.infra_table.setItem(index, 3, cost_item)


