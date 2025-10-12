from PySide6 import QtGui
from PySide6.QtCore import Qt
from PySide6.QtWidgets import QPushButton, QLabel, QVBoxLayout, QWidget, QGridLayout, QTableWidget, \
    QTableWidgetItem, QTabWidget, QSizePolicy, QHeaderView

countries = [
    "United States", "Canada", "Mexico", "Brazil", "Argentina", "United Kingdom", "France", "Germany", "Italy",
    "Spain", "Russia", "China", "Japan", "South Korea", "India", "Australia", "New Zealand", "South Africa",
    "Egypt", "Nigeria", "Kenya", "Turkey", "Saudi Arabia", "Iran", "Israel", "Pakistan", "Indonesia",
    "Thailand",
    "Vietnam", "Philippines"
]

agreements = [
    "at war", "alliance", "trade embargo", "trade agreement", "pact", "royal marriage", "is vassal"
]





class DiplomacyPanel(QWidget):
    def __init__(self, parent=None):
        super().__init__(parent)
        self.setLayout(QVBoxLayout())
        self.layout().setContentsMargins(4, 4, 4, 4)
        self.setFixedWidth(300)
        self.init_ui()

        self.relations_table : QTableWidget = None
        self.agreements_table : QTableWidget = None

    def init_ui(self):

        print("  GUI - Diplomacy panel")

        # Add country label
        diplomacy_label = QLabel("<b>DIPLOMACY & ESPIONAGE</b>")
        diplomacy_label.setAlignment(Qt.AlignCenter)
        self.layout().addWidget(diplomacy_label)

        country_label = QLabel("Poland")
        country_label.setAlignment(Qt.AlignCenter)
        self.layout().addWidget(country_label)

        # Add relations label
        relations_label = QLabel("<b>Relations</b>")
        relations_label.setAlignment(Qt.AlignCenter)
        self.layout().addWidget(relations_label)

        # Add list with country name and relation
        relations_table = QTableWidget(50, 2)
        relations_table.setContentsMargins(0, 0, 0, 0)
        relations_table.horizontalHeader().setSectionResizeMode(QHeaderView.Fixed)
        relations_table.setSizePolicy(QSizePolicy.Minimum, QSizePolicy.Minimum)
        relations_table.setMaximumHeight(
            relations_table.verticalHeader().defaultSectionSize() * 10 + relations_table.horizontalHeader().height())
        relations_table.setHorizontalHeaderLabels(["Country", "Val"])
        relations_table.setSelectionMode(QTableWidget.NoSelection)
        relations_table.setEditTriggers(QTableWidget.NoEditTriggers)
        relations_table.verticalHeader().setVisible(False)
        relations_table.setColumnWidth(0, 170)
        relations_table.setColumnWidth(1, 105)

        self.relations_table = relations_table
        self.layout().addWidget(relations_table)

        self.add_random_countries_to_relation_table()

        # Add relations label
        relations_label = QLabel("<b>Agreements</b>")
        relations_label.setAlignment(Qt.AlignCenter)
        self.layout().addWidget(relations_label)

        # Add agreements label
        # Add agreements table
        agreements_table = QTableWidget(15, 2)
        agreements_table.setContentsMargins(0, 0, 0, 0)
        agreements_table.horizontalHeader().setSectionResizeMode(QHeaderView.Fixed)
        agreements_table.setSizePolicy(QSizePolicy.Minimum, QSizePolicy.Minimum)
        agreements_table.setMaximumHeight(
            agreements_table.verticalHeader().defaultSectionSize() * 10 + agreements_table.horizontalHeader().height())
        agreements_table.setHorizontalHeaderLabels(["Country", "Type"])
        agreements_table.setSelectionMode(QTableWidget.NoSelection)
        agreements_table.setEditTriggers(QTableWidget.NoEditTriggers)
        agreements_table.verticalHeader().setVisible(False)
        agreements_table.setColumnWidth(0, 170)
        agreements_table.setColumnWidth(1, 105)

        self.agreements_table = agreements_table
        self.layout().addWidget(agreements_table)

        self.add_random_agreements_to_table()

        # Add actions label
        actions_label = QLabel("<b>Actions</b>")
        actions_label.setAlignment(Qt.AlignCenter)
        self.layout().addWidget(actions_label)

        def create_action_button(text, row, col, layout, enabled=True, style=None):
            button = QPushButton(text)
            button.setFixedSize(95, 40)
            button.setContentsMargins(0, 0, 0, 0)

            button.setEnabled(enabled)
            if style:
                button.setStyleSheet(style)
            layout.addWidget(button, row, col, alignment=Qt.AlignTop)

            return button

        # Add tab widget for actions ----------------------

        tab_widget = QTabWidget()
        tab_widget.setTabBarAutoHide(False)
        tab_widget.setTabPosition(QTabWidget.North)

        self.layout().addWidget(tab_widget)

        # Create Diplomacy Actions tab

        diplomacy_tab = QWidget()
        diplomacy_tab.setLayout(QVBoxLayout())
        diplomacy_tab.setContentsMargins(0, 0, 0, 0)
        tab_widget.addTab(diplomacy_tab, "Diplomacy")

        # Add action buttons to Diplomacy tab
        button_layout_diplo = QGridLayout()
        button_layout_diplo.setContentsMargins(0, 0, 0, 0)
        button_layout_diplo.setSpacing(0)
        button_layout_diplo.setAlignment(Qt.AlignTop)

        diplomacy_tab.layout().addLayout(button_layout_diplo)

        # Add buttons in a 3-column grid
        actions = [
            "Declare war", "Offer peace", "Trade\nagreement",
            "Improve\nrelations", "Damage\nrelations", "Trade\nembargo",
            "Buy\nprovince", "Sell\nprovince", "Offer Loan",
            "Grant mil.\naccess", "Demand mil.\naccess", "Offer vassal",
            "Royal\nmarriage", "Offer\nannexation", "Demand vassal",
            "Demand\nterritory", "Guarantee\nindependence", "Claim\nthrone",
            "Join\nalliance", "Invite\nalliance", "Leave\nalliance",
            "Ban from\nalliance", "Exchange\ntechnologies", "Exchange\ndiscoveries",
            "Demand\nconversion", "Offer\ntribute", "Demand\ntribute"
        ]

        for index, action in enumerate(actions):
            row = index // 3
            col = index % 3
            create_action_button(action, row, col, button_layout_diplo)

        # Create Espionage Actions tab

        espionage_tab = QWidget()
        espionage_tab.setContentsMargins(0, 0, 0, 0)
        espionage_tab.setLayout(QVBoxLayout())
        tab_widget.addTab(espionage_tab, "Espionage")

        # Add espionage action buttons
        espionage_button_layout = QGridLayout()
        espionage_button_layout.setContentsMargins(0, 0, 0, 0)
        espionage_button_layout.setSpacing(0)
        espionage_button_layout.setAlignment(Qt.AlignTop)
        espionage_tab.layout().addLayout(espionage_button_layout)

        espionage_actions = [
            "Rebellion", "Monitor", "Steal Money",
            "Steal Maps", "Steal\nTechnology", "Destabilize",
            "Propaganda", "Sabotage", "Poison",
            "Disrupt Trade", "Assassinate", "Overthrow",
            "Bribe"
        ]

        for index, action in enumerate(espionage_actions):
            row = index // 3
            col = index % 3
            create_action_button(action, row, col, espionage_button_layout)

        self.layout().addWidget(tab_widget)

        # Add empty panel to fill empty space
        empty_panel = QWidget()
        empty_panel.setSizePolicy(QSizePolicy.Expanding, QSizePolicy.Expanding)
        self.layout().addWidget(empty_panel)


    def add_random_countries_to_relation_table(self):
        import random

        def calculate_color(value):
            if value < -75:
                return "red"
            elif -75 <= value < -25:
                return "orange"
            elif -25 <= value < 25:
                return "yellow"
            elif 25 <= value < 75:
                return "lightgreen"
            elif 75 <= value <= 100:
                return "green"
            else:
                return "gray"

        for i in range(45):
            country = random.choice(countries)
            relation = random.randint(-100, 100)
            country_item = QTableWidgetItem(country)
            relation_item = QTableWidgetItem(str(relation))
            relation_item.setBackground(QtGui.QColor(calculate_color(relation)))
            self.relations_table.setItem(i, 0, country_item)
            self.relations_table.setItem(i, 1, relation_item)
            self.relations_table.setRowHeight(i, 20)

    def add_random_agreements_to_table(self):
        import random

        for i in range(10):
            country = random.choice(countries)
            agreement = random.choice(agreements)
            country_item = QTableWidgetItem(country)
            agreement_item = QTableWidgetItem(agreement)
            self.agreements_table.setItem(i, 0, country_item)
            self.agreements_table.setItem(i, 1, agreement_item)
            self.agreements_table.setRowHeight(i, 20)


