import unittest
from gui.globe.gui_research import TGuiGlobeResearch
from gui.globe.gui_reports import TGuiGlobeReports
from gui.globe.gui_production import TGuiGlobeProduction
from PySide6.QtWidgets import QApplication
import sys

app = QApplication.instance() or QApplication(sys.argv)

class TestTGuiGlobeResearch(unittest.TestCase):
    def test_init(self):
        screen = TGuiGlobeResearch()
        self.assertIsNotNone(screen)

class TestTGuiGlobeReports(unittest.TestCase):
    def test_init(self):
        screen = TGuiGlobeReports()
        self.assertIsNotNone(screen)

class TestTGuiGlobeProduction(unittest.TestCase):
    def test_init(self):
        screen = TGuiGlobeProduction()
        self.assertIsNotNone(screen)

if __name__ == '__main__':
    unittest.main()
