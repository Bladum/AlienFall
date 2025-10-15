from PySide6.QtCore import Qt
from PySide6.QtWidgets import QProgressBar, QTableWidgetItem, QPushButton, QTableWidget, QLabel, QHBoxLayout, \
    QVBoxLayout, QWidget, QSizePolicy, QHeaderView

technology_year = {
    0: 1250,
    1: 1350,
    2: 1440,
    3: 1510,
    4: 1570,
    5: 1620,
    6: 1660,
    7: 1690,
    8: 1720,
    9: 1750,
    10: 1780,
    11: 1810,
    12: 1830,
    13: 1850,
    14: 1870,
    15: 1890
}

technologies = [
    ("Land", "1", "4"),
    ("Naval", "4", "11"),
    ("Infra", "3", "5"),
    ("Trade", "2", "12"),
    ("Admin", "1", "2"),
    ("Tech 6", "4", "9")
]


class TechnologyPanel(QWidget):
    def __init__(self, parent=None):
        super().__init__(parent)
        self.setLayout(QVBoxLayout())
        self.setFixedWidth(300)
        self.layout().setContentsMargins(4, 4, 4, 4)
        self.init_ui()

    def init_ui(self):
        print("  GUI - Technology panel")

        # Add technology label
        technology_label = QLabel("<b>TECHNOLOGY</b>")
        technology_label.setAlignment(Qt.AlignCenter)
        self.layout().addWidget(technology_label)

        # no n

        # Add date and inventors label
        date_inventors_layout = QHBoxLayout()
        date_label = QLabel("<b>Next change</b><br>2023-10-25")
        date_label.setAlignment(Qt.AlignCenter)
        inventors_label = QLabel("<b>Inventors</b><br>12")
        inventors_label.setAlignment(Qt.AlignCenter)
        date_inventors_layout.addWidget(date_label)
        date_inventors_layout.addWidget(inventors_label)
        self.layout().addLayout(date_inventors_layout)

        # Add investments label
        investments_label = QLabel("<b>Investments</b>")
        investments_label.setAlignment(Qt.AlignCenter)
        self.layout().addWidget(investments_label)

        # Add table widget with data
        data_table = QTableWidget(12, 3)
        data_table.setContentsMargins(0, 0, 0, 0)
        data_table.horizontalHeader().setSectionResizeMode(QHeaderView.Fixed)
        data_table.setSizePolicy(QSizePolicy.Minimum, QSizePolicy.Minimum)
        data_table.setSizeAdjustPolicy(QTableWidget.AdjustToContents)
        data_table.setHorizontalHeaderLabels(["Technology name", "Cost", "Buy"])
        data_table.setSelectionMode(QTableWidget.NoSelection)
        data_table.setEditTriggers(QTableWidget.NoEditTriggers)
        data_table.verticalHeader().setVisible(False)
        data_table.setColumnWidth(0, 170)
        data_table.setColumnWidth(1, 60)
        data_table.setColumnWidth(2, 60)

        def add_table_item(data_table, row, name, cost):
            name_item = QTableWidgetItem(name)
            cost_item = QTableWidgetItem(cost)
            cost_item.setTextAlignment(Qt.AlignCenter)
            action_button = QPushButton("▲")
            action_button.setFlat(True)
            action_button.setStyleSheet("font-size: 12pt; font-weight: bold;")
            data_table.setItem(row, 0, name_item)
            data_table.setItem(row, 1, cost_item)
            data_table.setCellWidget(row, 2, action_button)
            data_table.setRowHeight( row, 20 )

        for i, tech in enumerate(technologies):
            add_table_item(data_table, i * 2, tech[0], tech[1])
            tech_year = technology_year.get( int(tech[2]), 'X')
            progress_bar = QProgressBar()
            progress_bar.setRange(0, 12)  # Set min to 0 and max to 12
            progress_bar.setValue(int(tech[2]))  # Example progress value
            progress_bar.setAlignment(Qt.AlignCenter)
            progress_bar.setFormat(f"Level: {tech[2]}        year ~ {tech_year}")  # Display Level: N as text
            progress_bar.setStyleSheet("QProgressBar::chunk { background-color: lightgreen; } QProgressBar { background-color: salmon; border: none; }")
            data_table.setCellWidget(i * 2 + 1, 0, progress_bar)
            data_table.setSpan(i * 2 + 1, 0, 1, 3)
            data_table.setRowHeight( i * 2 + 1, 20 )

        self.layout().addWidget(data_table)

        # Add empty panel to fill empty space
        empty_panel = QWidget()
        empty_panel.setSizePolicy(QSizePolicy.Expanding, QSizePolicy.Expanding)
        self.layout().addWidget(empty_panel)
