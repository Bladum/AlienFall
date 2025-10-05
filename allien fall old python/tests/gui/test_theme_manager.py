import unittest
from src.gui.theme_manager import XcomTheme, XcomStyle, px

class TestThemeManager(unittest.TestCase):
    def test_px_scaling(self):
        self.assertEqual(px(16), 32)  # Assuming SCALE = 2

    def test_theme_manager_attributes(self):
        # Direct attribute access, trust type system
        self.assertEqual(XcomTheme.BG_MID, "#2E2E2E")  # Example value, use the actual expected value
        self.assertEqual(XcomTheme.BG_DARK, "#1E1E1E")  # Example value, use the actual expected value

    def test_style_methods(self):
        self.assertTrue(callable(XcomStyle.groupbox))
        self.assertTrue(callable(XcomStyle.lineedit))

if __name__ == '__main__':
    unittest.main()
