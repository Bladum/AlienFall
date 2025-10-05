from PySide6.QtCore import Qt
from PySide6.QtWidgets import QFrame, QVBoxLayout, QLabel, QButtonGroup, QRadioButton, QListWidget, QWidget, QSizePolicy

from src.db import TDB

db = TDB()

class EditorPanel(QWidget):
    def __init__(self, parent=None):
        super().__init__(parent)
        self.setLayout(QVBoxLayout())
        self.layout().setContentsMargins(4, 4, 4, 4)
        self.setFixedWidth(300)

        print("  GUI - Game editor panel")

        self.add_label("<b>EDITOR</b>")
        self.add_mode_selection(["ProvID", "Capitals", "Rivers", "Terrains"])
        self.add_prov_id_section()
        self.add_section("Capitals", ["None", "Capital", "Name"])
        self.add_section("Rivers", ["Land", "River", "Sea"])
        self.add_section("Terrains", ["Empty", "Tree", "Desert", "Swamp", "Mountain"])

        empty_panel = QWidget()
        empty_panel.setSizePolicy(QSizePolicy.Expanding, QSizePolicy.Expanding)
        self.layout().addWidget(empty_panel)

    def add_label(self, text):
        label = QLabel(text)
        label.setAlignment(Qt.AlignCenter)
        self.layout().addWidget(label)

    def add_mode_selection(self, modes):
        mode_layout = QVBoxLayout()
        self.mode_group = QButtonGroup(self)
        for mode in modes:
            radio_button = QRadioButton(mode)
            self.mode_group.addButton(radio_button)
            mode_layout.addWidget(radio_button)
        self.layout().addLayout(mode_layout)

    def add_prov_id_section(self):
        frame = self.create_frame("<b>ProvID</b>")
        self.prov_id_list = QListWidget()
        self.prov_id_list.itemClicked.connect(self.on_province_selected)
        self.prov_id_list.setMaximumHeight(200)
        for id, province in db.provinces.items():
            self.prov_id_list.addItem(str(province.province_id))
        frame.layout().addWidget(self.prov_id_list)
        self.layout().addWidget(frame)

    def add_section(self, title, modes):
        frame = self.create_frame(f"<b>{title}</b>")
        group = QButtonGroup(self)
        for mode in modes:
            radio_button = QRadioButton(mode)
            group.addButton(radio_button)
            frame.layout().addWidget(radio_button)
        self.layout().addWidget(frame)

    def create_frame(self, title):
        frame = QFrame()
        frame.setFrameShape(QFrame.StyledPanel)
        layout = QVBoxLayout()
        frame.setLayout(layout)
        label = QLabel(title)
        label.setAlignment(Qt.AlignCenter)
        layout.addWidget(label)
        return frame

    def on_province_selected(self, item):
        province_id = int(item.text())
        db.game_scene.select_province_by_id(province_id)