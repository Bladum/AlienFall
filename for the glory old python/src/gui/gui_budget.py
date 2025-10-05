from PySide6.QtCore import Qt
from PySide6.QtWidgets import QVBoxLayout, QWidget, QLabel, QHBoxLayout, QTableWidget, QTableWidgetItem, QRadioButton, \
    QButtonGroup, QSizePolicy, QHeaderView


class BudgetPanel(QWidget):
    def __init__(self, parent=None):
        super().__init__(parent)
        self.setLayout(QVBoxLayout())
        self.layout().setContentsMargins(4, 4, 4, 4)
        self.setFixedWidth(300)
        self.init_budget_ui()

    def init_budget_ui(self):

        print("  GUI - country budget panel")

        # Add Budget label
        budget_label = QLabel("<b>BUDGET</b>")
        budget_label.setAlignment(Qt.AlignCenter)
        self.layout().addWidget(budget_label)

        # Add incomes, balance, and expenses labels
        budget_layout = QHBoxLayout()
        incomes_label = QLabel("<b><font color='darkgreen'>Incomes</font></b><br>+123$")
        incomes_label.setAlignment(Qt.AlignCenter)
        balance_label = QLabel("<b><font color='darkyellow'>Balance</font></b><br>+32$")
        balance_label.setAlignment(Qt.AlignCenter)
        expenses_label = QLabel("<b><font color='darkred'>Expenses</font></b><br>-12$")
        expenses_label.setAlignment(Qt.AlignCenter)
        budget_layout.addWidget(incomes_label)
        budget_layout.addWidget(balance_label)
        budget_layout.addWidget(expenses_label)
        self.layout().addLayout(budget_layout)

        # Add Incomes label
        incomes_table_label = QLabel("<b>Incomes</b>")
        incomes_table_label.setAlignment(Qt.AlignCenter)
        self.layout().addWidget(incomes_table_label)

        # Add incomes table
        incomes_table = QTableWidget(7, 2)
        incomes_table.setContentsMargins(0, 0, 0, 0)
        incomes_table.horizontalHeader().setSectionResizeMode(QHeaderView.Fixed)
        incomes_table.setSizePolicy(QSizePolicy.Minimum, QSizePolicy.Minimum)
        incomes_table.setSizeAdjustPolicy(QTableWidget.AdjustToContents)
        incomes_table.setHorizontalHeaderLabels(["Name", "Value"])
        incomes_table.setSelectionMode(QTableWidget.NoSelection)
        incomes_table.setEditTriggers(QTableWidget.NoEditTriggers)
        incomes_table.verticalHeader().setVisible(False)
        incomes_table.setColumnWidth(0, 170)
        incomes_table.setColumnWidth(1, 120)
        incomes = ["Taxes", "Trade", "Tariffs", "Tributes", "Looting", "Gold", "Interests" ]
        for i, income in enumerate(incomes):
            incomes_table.setItem(i, 0, QTableWidgetItem(income))
            incomes_table.setItem(i, 1, QTableWidgetItem("Value"))
            incomes_table.setRowHeight(i, 20)
        self.layout().addWidget(incomes_table)

        # Add Expenses label
        expenses_table_label = QLabel("<b>Expenses</b>")
        expenses_table_label.setAlignment(Qt.AlignCenter)
        self.layout().addWidget(expenses_table_label)

        # Add expenses table
        expenses_table = QTableWidget(7, 2)
        expenses_table.setContentsMargins(0, 0, 0, 0)
        expenses_table.horizontalHeader().setSectionResizeMode(QHeaderView.Fixed)
        expenses_table.setSizePolicy(QSizePolicy.Minimum, QSizePolicy.Minimum)
        expenses_table.setSizeAdjustPolicy(QTableWidget.AdjustToContents)
        expenses_table.setHorizontalHeaderLabels(["Name", "Value"])
        expenses_table.setSelectionMode(QTableWidget.NoSelection)
        expenses_table.setEditTriggers(QTableWidget.NoEditTriggers)
        expenses_table.verticalHeader().setVisible(False)
        expenses_table.setColumnWidth(0, 170)
        expenses_table.setColumnWidth(1, 120)
        expenses = ["Military", "Technology", "Stability", "Corruption", "Tributes", "Interests"]
        for i, expense in enumerate(expenses):
            expenses_table.setItem(i, 0, QTableWidgetItem(expense))
            expenses_table.setItem(i, 1, QTableWidgetItem("Value"))
            expenses_table.setRowHeight(i, 20)
        self.layout().addWidget(expenses_table)

        # Add Sliders label
        sliders_label = QLabel("<b>Sliders</b>")
        sliders_label.setAlignment(Qt.AlignCenter)
        self.layout().addWidget(sliders_label)

        # Add sliders table
        sliders_table = QTableWidget(7, 4)
        sliders_table.setSelectionMode(QTableWidget.NoSelection)
        sliders_table.setEditTriggers(QTableWidget.NoEditTriggers)
        sliders_table.setContentsMargins(0, 0, 0, 0)
        sliders_table.setSizePolicy(QSizePolicy.Minimum, QSizePolicy.Minimum)
        sliders_table.setSizeAdjustPolicy(QTableWidget.AdjustToContents)
        sliders_table.setHorizontalHeaderLabels(["Name", "Low", "Med", "High"])

        sliders_table.verticalHeader().setVisible(False)
        sliders_table.setColumnWidth(0, 170)
        sliders_table.setColumnWidth(1, 40)
        sliders_table.setColumnWidth(2, 40)
        sliders_table.setColumnWidth(3, 40)

        slider_rows = ["Taxes", "Military", "Technology", "Stability", "Administration", "Diplomacy", "Tariffs" ]
        for i, row_label in enumerate(slider_rows):
            sliders_table.setItem(i, 0, QTableWidgetItem(row_label))

            labels = ["", "▼", "●", "▲"]

            button_group = QButtonGroup(self)
            for j in range(1, 4):
                radio_button = QRadioButton(  )
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
                        background-color: {'red' if j == 1 else 'yellow' if j == 2 else 'green'};
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
                sliders_table.setCellWidget(i, j, cell_widget)
                sliders_table.setRowHeight(i, 20)

        self.layout().addWidget(sliders_table)

        # Add empty panel to fill empty space
        empty_panel = QWidget()
        empty_panel.setSizePolicy(QSizePolicy.Expanding, QSizePolicy.Expanding)
        self.layout().addWidget(empty_panel)

        # TODO add buttons here
        # Raise War Taxes
        # Take Load
        # Repay Load

