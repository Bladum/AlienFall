from PySide6.QtCore import Qt
from PySide6.QtWidgets import QTableWidgetItem, QPushButton, QTableWidget, QLabel, QWidget, QVBoxLayout, \
    QHBoxLayout, QSizePolicy, QHeaderView


class DomesticPolicyPanel(QWidget):
    def __init__(self, parent=None):
        super().__init__(parent)
        self.setLayout(QVBoxLayout())
        self.layout().setContentsMargins(4, 4, 4, 4)
        # self.layout().setSpacing(5)
        self.setFixedWidth(300)
        self.init_ui()

    def init_ui(self):

        print("  GUI - Country policies panel")

        # Add Domestic Policies label
        domestic_policies_label = QLabel("<b>DOMESTIC POLICIES</b>")
        domestic_policies_label.setAlignment(Qt.AlignCenter)
        self.layout().addWidget(domestic_policies_label)

        # Add date and advisors labels
        date_advisors_layout = QHBoxLayout()
        date_label = QLabel("<b>Next change</b><br>2023-10-25")
        date_label.setAlignment(Qt.AlignCenter)
        advisors_label = QLabel("<b>Advisors</b><br>12")
        advisors_label.setAlignment(Qt.AlignCenter)
        date_advisors_layout.addWidget(date_label)
        date_advisors_layout.addWidget(advisors_label)
        self.layout().addLayout(date_advisors_layout)

        # Add Policies label
        policies_label = QLabel("<b>Policies</b>")
        policies_label.setAlignment(Qt.AlignCenter)
        self.layout().addWidget(policies_label)

        # Add table grid with policies data
        policies_table = QTableWidget(25, 4)
        policies_table.setContentsMargins(0, 0, 0, 0)
        policies_table.horizontalHeader().setSectionResizeMode(QHeaderView.Fixed)
        policies_table.setSizePolicy(QSizePolicy.Minimum, QSizePolicy.Minimum)
        policies_table.setSizeAdjustPolicy(QTableWidget.AdjustToContents)
        policies_table.setHorizontalHeaderLabels(['Name','lvl', "", ""])
        policies_table.setEditTriggers(QTableWidget.NoEditTriggers)
        policies_table.setSelectionMode(QTableWidget.NoSelection)
        policies_table.verticalHeader().setVisible(False)
        policies_table.setColumnWidth(0, 170)
        policies_table.setColumnWidth(1, 40)
        policies_table.setColumnWidth(2, 40)
        policies_table.setColumnWidth(3, 40)

        def add_policy_item(table, row, policy, level, tooltips):
            policy_item = QTableWidgetItem(policy)
            table.setRowHeight( row, 20 )
            policy_item.setToolTip(tooltips.get(policy, ""))
            level_item = QLabel(str(level))
            level_item.setAlignment(Qt.AlignCenter)
            minus_button = QPushButton("▼")
            minus_button.setFlat(True)
            minus_button.setStyleSheet("font-size: 12pt; font-weight: bold;")
            plus_button = QPushButton("▲")
            plus_button.setFlat(True)
            plus_button.setStyleSheet("font-size: 12pt; font-weight: bold;")
            table.setItem(row, 0, policy_item)
            table.setCellWidget(row, 1, level_item)
            table.setCellWidget(row, 2, minus_button)
            table.setCellWidget(row, 3, plus_button)

        policies = [
            "Taxation", "Trade", "Military", "Diplomacy", "Economy", "Education", "Healthcare", "Infrastructure",
            "Justice", "Environment", "Technology", "Culture", "Immigration", "Security", "Transport", "Energy",
            "Agriculture", "Housing", "Tourism", "Welfare", "Taxation", "Trade", "Military", "Diplomacy", "Economy"
        ]

        # Add tooltips
        tooltips = {
            "Taxation": "Manage the tax rates and policies to ensure a balanced economy.",
            "Trade": "Regulate trade agreements and tariffs to boost the economy.",
            "Military": "Oversee the military forces and defense strategies.",
            "Diplomacy": "Handle foreign relations and diplomatic negotiations.",
            "Economy": "Develop economic policies to promote growth and stability.",
            "Education": "Improve the education system to enhance literacy and skills.",
            "Healthcare": "Ensure access to quality healthcare for all citizens.",
            "Infrastructure": "Build and maintain essential infrastructure like roads and bridges.",
            "Justice": "Administer the justice system to uphold law and order.",
            "Environment": "Protect the environment through sustainable practices.",
            "Technology": "Promote technological advancements and innovation.",
            "Culture": "Preserve and promote cultural heritage and activities.",
            "Immigration": "Manage immigration policies and integration programs.",
            "Security": "Ensure the safety and security of the nation.",
            "Transport": "Develop and maintain transportation networks.",
            "Energy": "Oversee energy production and distribution.",
            "Agriculture": "Support agricultural development and food security.",
            "Housing": "Provide affordable housing solutions.",
            "Tourism": "Promote tourism to boost the economy.",
            "Welfare": "Implement welfare programs to support the needy."
        }

        for i, policy in enumerate(policies):
            add_policy_item(policies_table, i, policy, 0, tooltips)

        self.layout().addWidget(policies_table)

        # Add empty panel to fill empty space
        empty_panel = QWidget()
        empty_panel.setSizePolicy(QSizePolicy.Expanding, QSizePolicy.Expanding)
        self.layout().addWidget(empty_panel)
