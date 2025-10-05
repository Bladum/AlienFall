from PySide6.QtCore import Qt
from PySide6.QtWidgets import (
    QLabel, QDialog, QVBoxLayout, QHBoxLayout, QWidget,
    QPushButton, QTabWidget, QStackedWidget
)

class GUI_GameProvincePanel(QWidget):

    def __init__(self, parent=None, province=None):
        super().__init__(parent)
        self.setFixedSize(740, 240)

        # Position panel at the bottom of the parent widget with 50px padding
        if parent:
            # Calculate position relative to the parent widget's bottom
            self.updatePosition()

            # Connect parent's resize signal to update position
            if hasattr(parent, "resizeEvent"):
                original_resize_event = parent.resizeEvent

                def new_resize_event(event):
                    original_resize_event(event)
                    self.updatePosition()

                parent.resizeEvent = new_resize_event
        else:
            # Fallback positioning if no parent
            parent_rect = self.screen().geometry()
            self.move(30, parent_rect.height() - self.height() )

        # Close any existing instance
        if hasattr(parent, 'province_panel_instance') and parent.province_panel_instance:
            parent.province_panel_instance.close()
        parent.province_panel_instance = self

        from object.province import Province
        self.province: Province = province

        # Create main layout
        layout = QVBoxLayout(self)
        layout.setContentsMargins(5, 5, 5, 0)
        layout.setSpacing(0)  # Minimal spacing between widgets

        # Initialize widgets
        self.tab_widget = QTabWidget(self)

        # Create panel instances
        panel_prov_info = QWidget(self)
        panel_prov_infra = QWidget(self)
        panel_prov_recruit = QWidget(self)
        panel_prov_army = QWidget(self)
        panel_prov_navy = QWidget(self)
        panel_prov_social = QWidget(self)
        panel_prov_goods = QWidget(self)
        panel_prov_battle = QWidget(self)

        # Add header and tab widget to layout
        layout.addWidget(self.create_header())
        self.tab_widget.setFixedSize(720, 200)

        self.tab_widget.addTab(panel_prov_info, "ℹ️ Info")
        self.tab_widget.setTabToolTip(0, "Basic Information")

        self.tab_widget.addTab(panel_prov_infra, "🏗️ Infra")
        self.tab_widget.setTabToolTip(1, "Construct buildings")

        self.tab_widget.addTab(panel_prov_recruit, "️🪖 Recruit")
        self.tab_widget.setTabToolTip(2, "Recruitment of armies & navies")

        self.tab_widget.addTab(panel_prov_navy, "⚔️ Units")
        self.tab_widget.setTabToolTip(3, "Movement of armies & navies")

        self.tab_widget.addTab(panel_prov_social, "👥 Social")
        self.tab_widget.setTabToolTip(4, "Social - religion, culture, revolt risk, corruption")

        self.tab_widget.addTab(panel_prov_goods, "💰 Goods")
        self.tab_widget.setTabToolTip(5, "Goods production and trade")

        self.tab_widget.addTab(panel_prov_battle, "🔥 Battle")
        self.tab_widget.setTabToolTip(6, "Battle")

        # Add tab widget to main layout
        layout.addWidget(self.tab_widget)
        self.tab_widget.setStyleSheet("QTabBar::tab { font-size: 12px; height: 15px; min-width: 90px; width: 90px; }"
                                      " QTabWidget::tab-bar {  alignment: center; }")

    def switch_panel(self, index):
        self.tab_widget.setCurrentIndex(index)

    def create_header(self):
        header = QWidget(self)
        header.setFixedHeight(25)
        header.setStyleSheet("background: transparent; border: none; margin: 0; padding: 0;")
        header_layout = QHBoxLayout(header)
        header_layout.setContentsMargins(5, 0, 5, 0)
        header_layout.setSpacing(0)  # Remove spacing for tighter layout

        # Center title
        title = QLabel(f"Province: {self.province.name}", header)
        title.setAlignment(Qt.AlignCenter)
        title.setStyleSheet("font-size: 14px; font-weight: bold; background: #222;")
        header_layout.addWidget(title, 1)  # Stretch factor of 1 to take up space

        # Close button
        close_button = QPushButton("❌", header)
        close_button.setFixedSize(24, 24)
        close_button.setStyleSheet("""    QPushButton { 
                                            background-color: #333; 
                                            color:  #EEE; 
                                            border: 1px solid #555; 
                                            border-radius: 4px; 
                                            padding: 5px;
                                            }
                                            QPushButton:hover { 
                                                background-color: #444; 
                                                border: 1px solid gold;
                                            }
                                            QPushButton:pressed { 
                                                background-color: #222; 
                                                border: 1px solid #AAA;
                                            }
                                            QPushButton:checked {
                                                background-color: #2A2A2A;
                                                border: 1px solid #CCC;
                                                color: gold;
                                            }""")
        close_button.clicked.connect(self.close_dialog)
        header_layout.addWidget(close_button, 0, Qt.AlignRight)

        return header

    def close_dialog(self):
        self.parent().country_panel_instance = None
        self.close()

    def moveEvent(self, event):
        super().moveEvent(event)

    def updatePosition(self):
        if self.parent():
            # Use local coordinates for positioning relative to parent
            parent_rect = self.parent().rect()
            x_pos = 30  # 50px from left edge
            y_pos = parent_rect.height() - self.height()   # 50px from bottom edge
            self.move(x_pos, y_pos)

