import random

from PySide6.QtCore import Qt
from PySide6.QtWidgets import QWidget, QVBoxLayout, QHBoxLayout, QLabel, QTableWidget, QTableWidgetItem, QPushButton, \
    QSizePolicy, QHeaderView, QRadioButton


class CenterOfTradePanel(QWidget):
    def __init__(self, parent=None):
        super().__init__(parent)
        self.setLayout(QVBoxLayout())
        self.layout().setContentsMargins(4, 4, 4, 4)
        self.setFixedWidth(300)
        self.init_cot_ui()

    def init_cot_ui(self):

        print("  GUI - CoT panel")

        # Add Center of Trade label
        cot_label = QLabel("<b>CENTER OF TRADE</b>")
        cot_label.setAlignment(Qt.AlignCenter)
        self.layout().addWidget(cot_label)

        # Add province name label
        province_name_label = QLabel("Province:  Venice")
        province_name_label.setAlignment(Qt.AlignCenter)
        self.layout().addWidget(province_name_label)

        # Add cost, CoT value, and income labels
        cot_info_layout = QHBoxLayout()
        cost_label = QLabel("<b>Sent cost</b><br>4$")
        cost_label.setAlignment(Qt.AlignCenter)
        cot_info_layout.addWidget(cost_label)

        cot_value_label = QLabel("<b>CoT value</b><br>490$")
        cot_value_label.setAlignment(Qt.AlignCenter)
        cot_info_layout.addWidget(cot_value_label)

        cot_total_merchants = QLabel("<b>Merchant #</b><br>42")
        cot_total_merchants.setAlignment(Qt.AlignCenter)
        cot_info_layout.addWidget(cot_total_merchants)

        income_label = QLabel("<b>Our income</b><br>44.4$")
        income_label.setAlignment(Qt.AlignCenter)
        cot_info_layout.addWidget(income_label)

        self.layout().addLayout(cot_info_layout)

        # Add merchants label
        merchants_label = QLabel("<b>Merchants</b>")
        merchants_label.setAlignment(Qt.AlignCenter)
        self.layout().addWidget(merchants_label)

        # Add merchants table
        merchants_table = QTableWidget(20, 2)
        merchants_table.setContentsMargins(0, 0, 0, 0)
        merchants_table.horizontalHeader().setSectionResizeMode(QHeaderView.Fixed)
        merchants_table.setMaximumHeight(200)
        merchants_table.setHorizontalHeaderLabels(["Country", "Count"])
        merchants_table.verticalHeader().setVisible(False)
        merchants_table.setColumnWidth(0, 185)
        merchants_table.setColumnWidth(1, 90)
        for i in range(20):
            country = random.choice(["Country 1", "Country 2", "Country 3", "Country 4", "Country 5"] )
            number = random.randint(1, 5)
            merchants_table.setItem(i, 0, QTableWidgetItem(country))
            merchants_table.setItem(i, 1, QTableWidgetItem(str(number)))
            merchants_table.setRowHeight(i, 20)
        self.layout().addWidget(merchants_table)
        merchants_table.sortItems(1, Qt.DescendingOrder)

        # Add provinces label
        provinces_label = QLabel("<b>Provinces</b>")
        provinces_label.setAlignment(Qt.AlignCenter)
        self.layout().addWidget(provinces_label)

        # Add provinces table
        provinces_table = QTableWidget(15, 2)
        provinces_table.setContentsMargins(0, 0, 0, 0)
        provinces_table.horizontalHeader().setSectionResizeMode(QHeaderView.Fixed)
        provinces_table.setMaximumHeight(200)
        provinces_table.setHorizontalHeaderLabels(["Name", "Value [$]"])
        provinces_table.verticalHeader().setVisible(False)
        provinces_table.setColumnWidth(0, 185)
        provinces_table.setColumnWidth(1, 90)
        for i in range(15):
            province = random.choice(["Province 1", "Province 2", "Province 3", "Province 4", "Province 5"])
            value = random.randint(4, 25)
            provinces_table.setItem(i, 0, QTableWidgetItem(province))
            provinces_table.setItem(i, 1, QTableWidgetItem(str(value)))
            provinces_table.setRowHeight(i, 20)
        self.layout().addWidget(provinces_table)
        provinces_table.sortItems(1, Qt.DescendingOrder)

        # Add actions label
        actions_label = QLabel("<b>Actions</b>")
        actions_label.setAlignment(Qt.AlignCenter)
        self.layout().addWidget(actions_label)

        # Add action buttons
        actions_layout = QHBoxLayout()

        cancel_trade_button = QPushButton("Cancel\nTrade")
        cancel_trade_button.setFixedSize(95, 40)
        cancel_trade_button.setContentsMargins(0, 0, 0, 0)
        actions_layout.addWidget(cancel_trade_button)

        send_merchant_button = QPushButton("Send\nMerchant")
        send_merchant_button.setFixedSize(95, 40)
        send_merchant_button.setContentsMargins(0, 0, 0, 0)
        actions_layout.addWidget(send_merchant_button)

        auto_send_button = QRadioButton("Auto\nSend")
        auto_send_button.setFixedSize(95, 40)
        auto_send_button.setContentsMargins(0, 0, 0, 0)
        actions_layout.addWidget(auto_send_button)

        self.layout().addLayout(actions_layout)

        # Add empty panel to fill empty space
        empty_panel = QWidget()
        empty_panel.setSizePolicy(QSizePolicy.Expanding, QSizePolicy.Expanding)
        self.layout().addWidget(empty_panel)