class Clock:
    def __init__(self):
        self.current_year = 1400
        self.current_month = 1
        self.current_week = 1

    def add_weeks(self, weeks):
        total_weeks = self.current_week + weeks
        self.current_month += (total_weeks - 1) // 4
        self.current_week = (total_weeks - 1) % 4 + 1
        self.current_year += (self.current_month - 1) // 12
        self.current_month = (self.current_month - 1) % 12 + 1

    def subtract_weeks(self, weeks):
        total_weeks = (self.current_month - 1) * 4 + self.current_week - weeks
        self.current_year += (total_weeks - 1) // 48
        self.current_month = ((total_weeks - 1) % 48) // 4 + 1
        self.current_week = (total_weeks - 1) % 4 + 1

    def add_months(self, months):
        total_months = self.current_month + months
        self.current_year += (total_months - 1) // 12
        self.current_month = (total_months - 1) % 12 + 1

    def subtract_months(self, months):
        total_months = (self.current_year * 12 + self.current_month - 1) - months
        self.current_year = total_months // 12
        self.current_month = total_months % 12 + 1

    def convert_to_game_date(self, year, month, day):
        week = (day - 1) // 7 + 1
        return f"{year:04d}-{month:02d}-W{week}"

    def display_actual_date(self):
        return f"{self.current_year:04d}-{self.current_month:02d}-{(self.current_week - 1) * 7 + 1:02d}"

    def difference_in_years(self, year, month, week):
        years_diff = year - self.current_year
        if month < self.current_month or (month == self.current_month and week < self.current_week):
            years_diff -= 1
        return years_diff

    def difference_in_months(self, year, month, week):
        months_diff = (year - self.current_year) * 12 + (month - self.current_month)
        if week < self.current_week:
            months_diff -= 1
        return months_diff

    def difference_in_weeks(self, year, month, week):
        total_weeks_current = (self.current_year * 12 + self.current_month - 1) * 4 + self.current_week
        total_weeks_target = (year * 12 + month - 1) * 4 + week
        return total_weeks_target - total_weeks_current

    def is_within_range(self, start_year, start_month, start_week, end_year, end_month, end_week):
        start_total_weeks = (start_year * 12 + start_month - 1) * 4 + start_week
        end_total_weeks = (end_year * 12 + end_month - 1) * 4 + end_week
        current_total_weeks = (self.current_year * 12 + self.current_month - 1) * 4 + self.current_week
        return start_total_weeks <= current_total_weeks <= end_total_weeks


import unittest


class TestClock(unittest.TestCase):
    def setUp(self):
        self.clock = Clock()

    def test_initial_date(self):
        self.assertEqual((self.clock.current_year, self.clock.current_month, self.clock.current_week), (1500, 1, 1))

    def test_add_weeks(self):
        self.clock.add_weeks(1)
        self.assertEqual((self.clock.current_year, self.clock.current_month, self.clock.current_week), (1500, 1, 2))

    def test_subtract_weeks(self):
        self.clock.subtract_weeks(1)
        self.assertEqual((self.clock.current_year, self.clock.current_month, self.clock.current_week), (1499, 12, 4))

    def test_add_months(self):
        self.clock.add_months(1)
        self.assertEqual((self.clock.current_year, self.clock.current_month, self.clock.current_week), (1500, 2, 1))

    def test_subtract_months(self):
        self.clock.subtract_months(1)
        self.assertEqual((self.clock.current_year, self.clock.current_month, self.clock.current_week), (1499, 12, 1))

    def test_convert_to_game_date(self):
        self.assertEqual(self.clock.convert_to_game_date(1500, 1, 15), '1500-01-W3')

    def test_display_actual_date(self):
        self.assertEqual(self.clock.display_actual_date(), '1500-01-01')

    def test_difference_in_years(self):
        self.assertEqual(self.clock.difference_in_years(1501, 1, 1), 1)
        self.assertEqual(self.clock.difference_in_years(1500, 1, 1), 0)
        self.assertEqual(self.clock.difference_in_years(1499, 12, 4), -1)

    def test_difference_in_months(self):
        self.assertEqual(self.clock.difference_in_months(1501, 1, 1), 12)
        self.assertEqual(self.clock.difference_in_months(1500, 2, 1), 1)
        self.assertEqual(self.clock.difference_in_months(1499, 12, 4), -1)

    def test_difference_in_weeks(self):
        self.assertEqual(self.clock.difference_in_weeks(1500, 1, 2), 1)
        self.assertEqual(self.clock.difference_in_weeks(1500, 2, 1), 4)
        self.assertEqual(self.clock.difference_in_weeks(1499, 12, 4), -1)

    def test_is_within_range(self):
        self.assertTrue(self.clock.is_within_range(1499, 12, 4, 1500, 1, 1))
        self.assertFalse(self.clock.is_within_range(1500, 2, 1, 1501, 1, 1))
        self.assertTrue(self.clock.is_within_range(1500, 1, 1, 1500, 1, 1))


if __name__ == '__main__':
    unittest.main()