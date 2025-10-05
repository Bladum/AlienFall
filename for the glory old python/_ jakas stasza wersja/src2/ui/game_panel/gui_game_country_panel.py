from PySide6.QtCore import Qt
from PySide6.QtWidgets import (
    QLabel, QDialog, QVBoxLayout, QHBoxLayout, QWidget,
    QPushButton, QTabWidget, QStackedWidget
)

from ui.game_panel.country_panel.gui_country_court_panel import GUI_CountryCourtPanel
from ui.game_panel.country_panel.gui_country_diplomacy_panel import GUI_CountryDiplomacyPanel
from ui.game_panel.country_panel.gui_country_politics_panel import GUI_CountryPoliciesPanel


# Import other panel classes as needed


class GUI_GameCountryPanel(QWidget):

    def __init__(self, parent=None, country=None):
        super().__init__(parent)
        self.setFixedSize(740, 500)
        self.move(30, 30)
        # Close any existing instance
        if hasattr(parent, 'country_panel_instance') and parent.country_panel_instance:
            parent.country_panel_instance.close()
        parent.country_panel_instance = self

        from object.country import Country
        self.country: Country = country

        # Create main layout with minimal spacing
        layout = QVBoxLayout(self)
        layout.setContentsMargins(5, 5, 5, 0)
        layout.setSpacing(0)  # Minimal spacing between widgets

        # Initialize widgets
        self.tab_widget = QTabWidget(self)

        # Create panel instances
        panel_court = GUI_CountryCourtPanel(self)
        panel_policies = GUI_CountryPoliciesPanel(self)
        panel_diplomacy = GUI_CountryDiplomacyPanel(self)
        panel_military = QWidget(self)
        panel_budget = QWidget(self)
        panel_trade = QWidget(self)
        panel_technology = QWidget(self)
        panel_culture = QWidget(self)
        panel_religion = QWidget(self)
        panel_stability = QWidget(self)
        panel_mission = QWidget(self)
        panel_reports = QWidget(self)

        # Add header and tab widget to layout
        layout.addWidget(self.create_header())
        layout.addWidget(self.tab_widget)

        self.tab_widget.setFixedSize(720, 460)

        self.tab_widget.addTab(panel_court, "👑")
        self.tab_widget.setTabToolTip(0, "Court")
        self.tab_widget.addTab(panel_policies, "📜")
        self.tab_widget.setTabToolTip(1, "Policies")
        self.tab_widget.addTab(panel_diplomacy, "🤝")
        self.tab_widget.setTabToolTip(2, "Diplomacy")
        self.tab_widget.addTab(panel_military, "⚔️")
        self.tab_widget.setTabToolTip(3, "Military")
        self.tab_widget.addTab(panel_budget, "💰")
        self.tab_widget.setTabToolTip(4, "Budget")
        self.tab_widget.addTab(panel_trade, "🛒")
        self.tab_widget.setTabToolTip(5, "Trade")
        self.tab_widget.addTab(panel_technology, "🔬")
        self.tab_widget.setTabToolTip(6, "Technology")
        self.tab_widget.addTab(panel_culture, "🎭")
        self.tab_widget.setTabToolTip(7, "Culture")
        self.tab_widget.addTab(panel_religion, "✝️")
        self.tab_widget.setTabToolTip(8, "Religion")
        self.tab_widget.addTab(panel_stability, "⚖️")
        self.tab_widget.setTabToolTip(9, "Stability")
        self.tab_widget.addTab(panel_mission, "🎯")
        self.tab_widget.setTabToolTip(10, "Mission")
        self.tab_widget.addTab(panel_reports, "📊")
        self.tab_widget.setTabToolTip(11, "Reports")
        self.tab_widget.setStyleSheet("QTabBar::tab { font-size: 14px; height: 15px; min-width: 35px; width: 35px; } "
                                      " QTabWidget::tab-bar {  alignment: center; }")

        # Add tab widget to main layout
        layout.addWidget(self.tab_widget)

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
        title = QLabel(f"Country: {self.country.name}", header)
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

    #
    # def moveEvent(self, event):
    #     if self.parent():
    #         self.move(self.parent().x() + 60, self.parent().y() + 120)
    #     super().moveEvent(event)