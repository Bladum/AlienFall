from PySide6.QtCore import Qt
from PySide6.QtWidgets import QWidget, QVBoxLayout, QLabel, QHBoxLayout, QTableWidget, QTableWidgetItem, QRadioButton, \
    QHeaderView, QPushButton, QSizePolicy, QButtonGroup


class ReligionCulturePanel(QWidget):
    def __init__(self, parent=None):
        super().__init__(parent)
        self.setLayout(QVBoxLayout())
        self.layout().setContentsMargins(4, 4, 4, 4)
        self.setFixedWidth(300)
        self.init_religion_culture_ui()

    def init_religion_culture_ui(self):

        print("  GUI - religion culture sliders panel")

        # Add top bold label
        top_label = QLabel("<b>RELIGION & CULTURE</b>")
        top_label.setAlignment(Qt.AlignCenter)
        self.layout().addWidget(top_label)

        # Add country label
        country_label = QLabel("Country: Poland")
        country_label.setAlignment(Qt.AlignCenter)
        self.layout().addWidget(country_label)

        # Add culture, flag, and religion labels
        top_layout = QHBoxLayout()
        culture_label = QLabel("<b>Culture</b><br>Polish")
        culture_label.setAlignment(Qt.AlignCenter)
        flag_label = QLabel("<b>Country Flag<b>")
        flag_label.setAlignment(Qt.AlignCenter)
        religion_label = QLabel("<b>Religion</b><br>Catholic")
        religion_label.setAlignment(Qt.AlignCenter)
        top_layout.addWidget(culture_label)
        top_layout.addWidget(flag_label)
        top_layout.addWidget(religion_label)
        self.layout().addLayout(top_layout)

        # Add religion tolerance label
        religion_tolerance_label = QLabel("<b>Religion tolerance</b>")
        religion_tolerance_label.setAlignment(Qt.AlignCenter)
        self.layout().addWidget(religion_tolerance_label)

        # Add religion tolerance table
        religion_tolerance_table = QTableWidget(12, 4)
        religion_tolerance_table.setContentsMargins(0, 0, 0, 0)
        religion_tolerance_table.horizontalHeader().setSectionResizeMode(QHeaderView.Fixed)
        religion_tolerance_table.setMaximumHeight(200)
        religion_tolerance_table.setHorizontalHeaderLabels(["Religion", "Low", "Med", "High"])
        religion_tolerance_table.verticalHeader().setVisible(False)
        religion_tolerance_table.setColumnWidth(0, 150)
        religion_tolerance_table.setColumnWidth(1, 40)
        religion_tolerance_table.setColumnWidth(2, 40)
        religion_tolerance_table.setColumnWidth(3, 40)
        for i in range(6):
            religion_tolerance_table.setItem(i, 0, QTableWidgetItem(f"Religion {i + 1}"))
            labels = ["", "▼", "●", "▲"]
            button_group = QButtonGroup(self)
            for j in range(1, 4):
                radio_button = QRadioButton()
                radio_button.setText(labels[j])
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
                        background-color: {'salmon' if j == 1 else 'yellow' if j == 2 else 'green'};
                    }}
                """)
                if j == 2:
                    radio_button.setChecked(True)
                button_group.addButton(radio_button)
                cell_widget = QWidget()
                cell_layout = QHBoxLayout(cell_widget)
                cell_layout.addWidget(radio_button)
                cell_layout.setAlignment(Qt.AlignCenter)
                cell_layout.setContentsMargins(0, 0, 0, 0)
                religion_tolerance_table.setCellWidget(i, j, cell_widget)
            religion_tolerance_table.setRowHeight(i, 20)
        self.layout().addWidget(religion_tolerance_table)

        # Add culture tolerance label
        culture_tolerance_label = QLabel("<b>Culture tolerance</b>")
        culture_tolerance_label.setAlignment(Qt.AlignCenter)
        self.layout().addWidget(culture_tolerance_label)

        # Add culture tolerance table
        culture_tolerance_table = QTableWidget(6, 4)
        culture_tolerance_table.setContentsMargins(0, 0, 0, 0)
        culture_tolerance_table.horizontalHeader().setSectionResizeMode(QHeaderView.Fixed)
        culture_tolerance_table.setMaximumHeight(200)
        culture_tolerance_table.setHorizontalHeaderLabels(["Culture", "Low", "Med", "High"])
        culture_tolerance_table.verticalHeader().setVisible(False)
        culture_tolerance_table.setColumnWidth(0, 150)
        culture_tolerance_table.setColumnWidth(1, 40)
        culture_tolerance_table.setColumnWidth(2, 40)
        culture_tolerance_table.setColumnWidth(3, 40)
        for i in range(6):
            culture_tolerance_table.setItem(i, 0, QTableWidgetItem(f"Culture {i + 1}"))
            labels = ["", "▼", "●", "▲"]
            button_group = QButtonGroup(self)
            for j in range(1, 4):
                radio_button = QRadioButton()
                radio_button.setText(labels[j])
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
                                    background-color: {'salmon' if j == 1 else 'yellow' if j == 2 else 'green'};
                                }}
                            """)
                if j == 2:
                    radio_button.setChecked(True)
                button_group.addButton(radio_button)
                cell_widget = QWidget()
                cell_layout = QHBoxLayout(cell_widget)
                cell_layout.addWidget(radio_button)
                cell_layout.setAlignment(Qt.AlignCenter)
                cell_layout.setContentsMargins(0, 0, 0, 0)
                culture_tolerance_table.setCellWidget(i, j, cell_widget)
            culture_tolerance_table.setRowHeight(i, 20)
        self.layout().addWidget(culture_tolerance_table)

        # Add actions label
        actions_label = QLabel("<b>Actions</b>")
        actions_label.setAlignment(Qt.AlignCenter)
        self.layout().addWidget(actions_label)

        # Add action buttons
        actions_layout = QHBoxLayout()

        convert_religion_button = QPushButton("Convert\nReligion")
        convert_religion_button.setFixedSize(95, 40)
        convert_religion_button.setContentsMargins(0, 0, 0, 0)
        actions_layout.addWidget(convert_religion_button)

        defender_of_faith_button = QPushButton("Defender\nof Faith")
        defender_of_faith_button.setFixedSize(95, 40)
        defender_of_faith_button.setContentsMargins(0, 0, 0, 0)
        actions_layout.addWidget(defender_of_faith_button)

        convert_culture_button = QPushButton("Convert\nCulture")
        convert_culture_button.setFixedSize(95, 40)
        convert_culture_button.setContentsMargins(0, 0, 0, 0)
        actions_layout.addWidget(convert_culture_button)

        self.layout().addLayout(actions_layout)

        # Add empty panel to fill empty space
        empty_panel = QWidget()
        empty_panel.setSizePolicy(QSizePolicy.Expanding, QSizePolicy.Expanding)
        self.layout().addWidget(empty_panel)