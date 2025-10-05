import unittest
from gui.gui_core import TGuiCoreScreen
from PySide6.QtWidgets import QApplication
import sys

app = QApplication.instance() or QApplication(sys.argv)

class TestTGuiCoreScreen(unittest.TestCase):
    def test_init(self):
        screen = TGuiCoreScreen()
        self.assertIsNotNone(screen)
        self.assertTrue(screen.screen_activated is not None)
        self.assertTrue(screen.screen_deactivated is not None)
        self.assertTrue(screen.refresh_base_data is not None)
        self.assertTrue(screen.update_summary_display is not None)

if __name__ == '__main__':
    unittest.main()
