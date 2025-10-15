from datetime import date, datetime
import calendar

# Add this at the top with the other global constants
YEAR_START = 1200
YEAR_END = 1925
DAYS_PER_MONTH = 30
MONTHS_PER_YEAR = 12
DAYS_PER_WEEK = 6
DAYS_PER_YEAR = DAYS_PER_MONTH * MONTHS_PER_YEAR  # 360

from core.game_state import GameState
gs = GameState()

class Clock:
    def __init__(self, year=1400, month=1, day=1, date_str=None):
        if date_str:
            self.convert_from_str(date_str)
        else:
            self.current_year = year
            self.current_month = month
            self.current_day = day
        self.events = []
        self.recurring_events = []  # [(interval_days, callback, last_triggered)]

    #
    #   SEASON
    #

    def get_season(self):
        if self.current_month in [1, 2, 3]:
            return "Winter"
        elif self.current_month in [4, 5, 6]:
            return "Spring"
        elif self.current_month in [7, 8, 9]:
            return "Summer"
        elif self.current_month in [10, 11, 12]:
            return "Fall"

    @property
    def season(self):
        return self.get_season()

    @property
    def total_days(self):
        """Get the current date as total days since year 0"""
        return self.current_year * DAYS_PER_YEAR + (self.current_month - 1) * DAYS_PER_MONTH + self.current_day

    #
    #   OPERATIONS
    #

    def advance_time(self, days=1):
        """Advance time by the specified number of days and process events"""
        for _ in range(days):
            self.add_days(1)
            self.check_events()
            self.check_recurring_events()

    def add_days(self, days):
        total_days = self.current_day + days
        self.current_month += (total_days - 1) // DAYS_PER_MONTH
        self.current_day = (total_days - 1) % DAYS_PER_MONTH + 1
        self.add_months(0)  # Adjust for month overflow

    def subtract_days(self, days):
        total_days = (self.current_year * DAYS_PER_YEAR + self.current_month * DAYS_PER_MONTH + self.current_day) - days
        self.current_year = total_days // DAYS_PER_YEAR
        self.current_month = (total_days % DAYS_PER_YEAR) // DAYS_PER_MONTH + 1
        self.current_day = (total_days % DAYS_PER_YEAR) % DAYS_PER_MONTH + 1

    def add_months(self, months):
        total_months = self.current_month + months
        self.current_year += (total_months - 1) // MONTHS_PER_YEAR
        self.current_month = (total_months - 1) % MONTHS_PER_YEAR + 1

    def subtract_months(self, months):
        total_months = (self.current_year * MONTHS_PER_YEAR + self.current_month - 1) - months
        self.current_year = total_months // MONTHS_PER_YEAR
        self.current_month = total_months % MONTHS_PER_YEAR + 1

    def add_years(self, years):
        self.current_year += years

    def subtract_years(self, years):
        self.current_year -= years

    #
    #   TURNS
    #

    def calculate_turns_from_start(self):
        total_days_start = YEAR_START * DAYS_PER_YEAR + 1
        total_days_current = self.current_year * DAYS_PER_YEAR + self.current_month * DAYS_PER_MONTH + self.current_day
        return total_days_current - total_days_start

    def calculate_turns_from_date(self, year, month, day):
        total_days_start = YEAR_START * DAYS_PER_YEAR + 1
        total_days_target = year * DAYS_PER_YEAR + month * DAYS_PER_MONTH + day
        return total_days_target - total_days_start

    def calculate_turns_to_date(self, year, month, day):
        total_days_end = YEAR_END * DAYS_PER_YEAR + DAYS_PER_YEAR
        total_days_target = year * DAYS_PER_YEAR + month * DAYS_PER_MONTH + day
        return total_days_target - total_days_end

    def calculate_turns_until_end(self):
        total_days_end = YEAR_END * DAYS_PER_YEAR + DAYS_PER_YEAR
        total_days_current = self.current_year * DAYS_PER_YEAR + self.current_month * DAYS_PER_MONTH + self.current_day
        return total_days_end - total_days_current

    #
    #   ROUND
    #

    def round_to_closest_month(self, date_str):
        date_obj = datetime.strptime(date_str, "%Y-%m-%d")
        if date_obj.day > 15:
            date_obj = date_obj.replace(day=1)
        else:
            date_obj = date_obj.replace(day=1)
        self.current_year = date_obj.year
        self.current_month = date_obj.month
        self.add_months(1)

    def round_to_beginning_of_year(self):
        self.current_month = 1
        self.current_day = 1

    def round_to_closest_decade(self):
        if self.current_year % 10 >= 5:
            self.current_year = (self.current_year // 10 + 1) * 10
        else:
            self.current_year = (self.current_year // 10) * 10
        self.current_month = 1
        self.current_day = 1

    def round_to_beginning_of_month(self):
        self.current_day = 1

    def round_to_beginning_of_season(self):
        season = self.get_season()
        if season == "Winter":
            self.current_month = 1
        elif season == "Spring":
            self.current_month = 4
        elif season == "Summer":
            self.current_month = 7
        elif season == "Fall":
            self.current_month = 10
        self.current_day = 1

    #
    #   PRINT
    #

    def __str__(self):
        month_abbr = calendar.month_abbr[self.current_month]
        return f"{self.current_year:04d}-{month_abbr}-{self.current_day:02d}"

    def __repr__(self):
        return f"Clock(year={self.current_year}, month={self.current_month}, day={self.current_day})"

    #
    #   CHECK RANGE
    #

    def difference_in_years(self, other_clock):
        years_diff = other_clock.current_year - self.current_year
        if other_clock.current_month < self.current_month or (other_clock.current_month == self.current_month and other_clock.current_day < self.current_day):
            years_diff -= 1
        return years_diff

    def difference_in_months(self, other_clock):
        total_days_current = self.current_year * DAYS_PER_YEAR + self.current_month * DAYS_PER_MONTH + self.current_day
        total_days_other = other_clock.current_year * DAYS_PER_YEAR + other_clock.current_month * DAYS_PER_MONTH + other_clock.current_day
        return (total_days_other - total_days_current) // DAYS_PER_MONTH

    def difference_in_days(self, other_clock):
        total_days_current = self.current_year * DAYS_PER_YEAR + self.current_month * DAYS_PER_MONTH + self.current_day
        total_days_other = other_clock.current_year * DAYS_PER_YEAR + other_clock.current_month * DAYS_PER_MONTH + other_clock.current_day
        return total_days_other - total_days_current

    def is_within_range(self, days_difference):
        current_total_days = self.current_year * DAYS_PER_YEAR + self.current_month * DAYS_PER_MONTH + self.current_day
        target_total_days = current_total_days + days_difference
        return target_total_days >= 0

    def is_between(self, start_clock, end_clock):
        """Check if this clock is between start and end dates"""
        return self.total_days >= start_clock.total_days and self.total_days <= end_clock.total_days

    #
    #   CONVERT FROM DATE
    #

    def convert_to_str(self):
        return f"{self.current_year:04d}-{self.current_month:02d}-{self.current_day:02d}"

    def convert_to_long_str(self):
        return f"{self.current_year:04d} {calendar.month_abbr[self.current_month]} {self.current_day:02d}"

    def convert_from_str(self, date_str):
        year, month, day = map(int, date_str.split('-'))
        self.current_year = year
        self.current_month = month
        self.current_day = day

    def load_from_date(self, date_obj):
        self.current_year = date_obj.year
        self.current_month = date_obj.month
        self.current_day = date_obj.day

    def save_to_date(self):
        return date(self.current_year, self.current_month, self.current_day)

    #
    #   OPERATORS
    #

    def __eq__(self, other):
        if not isinstance(other, Clock):
            return NotImplemented
        return (self.current_year == other.current_year and
                self.current_month == other.current_month and
                self.current_day == other.current_day)

    def __lt__(self, other):
        if not isinstance(other, Clock):
            return NotImplemented
        return self.total_days < other.total_days

    def __gt__(self, other):
        if not isinstance(other, Clock):
            return NotImplemented
        return self.total_days > other.total_days

    def __le__(self, other):
        if not isinstance(other, Clock):
            return NotImplemented
        return self.total_days <= other.total_days

    def __ge__(self, other):
        if not isinstance(other, Clock):
            return NotImplemented
        return self.total_days >= other.total_days

    def __add__(self, other):
        if not isinstance(other, Clock):
            return NotImplemented
        total_days = self.current_year * DAYS_PER_YEAR + self.current_month * DAYS_PER_MONTH + self.current_day + other.current_year * DAYS_PER_YEAR + other.current_month * DAYS_PER_MONTH + other.current_day
        new_year = total_days // DAYS_PER_YEAR
        new_month = (total_days % DAYS_PER_YEAR) // DAYS_PER_MONTH + 1
        new_day = (total_days % DAYS_PER_YEAR) % DAYS_PER_MONTH + 1
        return Clock(new_year, new_month, new_day)

    def __sub__(self, other):
        if not isinstance(other, Clock):
            return NotImplemented
        total_days = self.current_year * DAYS_PER_YEAR + self.current_month * DAYS_PER_MONTH + self.current_day - (
                    other.current_year * DAYS_PER_YEAR + other.current_month * DAYS_PER_MONTH + other.current_day)
        new_year = total_days // DAYS_PER_YEAR
        new_month = (total_days % DAYS_PER_YEAR) // DAYS_PER_MONTH + 1
        new_day = (total_days % DAYS_PER_YEAR) % DAYS_PER_MONTH + 1
        return Clock(new_year, new_month, new_day)

    #
    #   EVENT
    #

    def schedule_event(self, event_date, callback):
        """Schedule an event for a specific date"""
        self.events.append((event_date, callback))
        self.events.sort()

    def schedule_relative_event(self, days_from_now, callback):
        """Schedule an event to occur a certain number of days from now"""
        future_date = Clock(self.current_year, self.current_month, self.current_day)
        future_date.add_days(days_from_now)
        self.schedule_event(future_date.convert_to_str(), callback)

    def schedule_recurring_event(self, interval_days, callback):
        """Schedule an event to occur every interval_days"""
        self.recurring_events.append((interval_days, callback, self.total_days))

    def check_events(self):
        """Check for and trigger scheduled events"""
        current_date = self.convert_to_str()
        events_to_remove = []

        for event_date, callback in self.events:
            if event_date <= current_date:
                callback()
                events_to_remove.append((event_date, callback))

        for event in events_to_remove:
            self.events.remove(event)

    def check_recurring_events(self):
        """Check for and trigger recurring events"""
        for i, (interval_days, callback, last_triggered) in enumerate(self.recurring_events):
            days_passed = self.total_days - last_triggered
            if days_passed >= interval_days:
                callback()
                self.recurring_events[i] = (interval_days, callback, self.total_days)

    def clear_events(self):
        """Clear all scheduled events"""
        self.events = []

    def clear_recurring_events(self):
        """Clear all recurring events"""
        self.recurring_events = []

    def copy(self):
        """Create a copy of this clock"""
        new_clock = Clock(self.current_year, self.current_month, self.current_day)
        return new_clock

    def is_start_of_month(self):
        """Return True if the current day is the first day of the month"""
        return self.current_day == 1

    def is_start_of_week(self):
        """Return True if the current day is the first day of a week
        Assuming weeks are 6 days long (30 days / 5 weeks = 6 days per week)"""
        return self.current_day % DAYS_PER_WEEK == 1

    def is_start_of_quarter(self):
        """Return True if the current day is the first day of a quarter (3 months)"""
        return self.current_day == 1 and self.current_month % 3 == 1

    def is_start_of_year(self):
        """Return True if the current date is the first day of the year"""
        return self.current_day == 1 and self.current_month == 1

    def is_start_of_biweekly(self):
        """Return True if the current day is the first day of a bi-weekly period
        Assuming bi-weekly is every 12 days (2 weeks of 6 days each)"""
        day_of_year = (self.current_month - 1) * DAYS_PER_MONTH + self.current_day
        return day_of_year % (DAYS_PER_WEEK * 2) == 1

    def get_day_of_week(self):
        """Return the day of the week (1-6) based on 6-day weeks"""
        return ((self.current_day - 1) % DAYS_PER_WEEK) + 1

    def get_week_of_month(self):
        """Return which week of the month (1-5) the current day falls in"""
        return (self.current_day - 1) // DAYS_PER_WEEK + 1

    def get_quarter(self):
        """Return the quarter (1-4) the current month falls in"""
        return (self.current_month - 1) // 3 + 1

    def get_epoch(self):
        """Return the current epoch based on year ranges"""
        if self.current_year < 1400:
            return "Medieval"
        elif self.current_year < 1600:
            return "Renaissance"
        elif self.current_year < 1700:
            return "Enlightenment"
        elif self.current_year < 1800:
            return "Industrial"
        elif self.current_year < 1900:
            return "Modern"
        else:
            return "Contemporary"


    def get_technology_cap(self):
        """Return the maximum technology level available based on the current year"""
        # Technology levels from 0-15 spread across the game's timeline
        year_span = YEAR_END - YEAR_START
        current_progress = self.current_year - YEAR_START
        progress_ratio = current_progress / year_span
        return min(15, int(progress_ratio * 15))


    def calculate_siege_duration(self, fort_level):
        """Calculate siege duration in months based on fort level"""
        if fort_level <= 0:
            return 0
        return fort_level * 3  # As per docs, each fort level = 3 months siege time


    def calculate_fort_build_time(self, fort_level):
        """Calculate time in turns to build a fort of given level"""
        return fort_level * 3  # 3 turns per level as per docs


    def calculate_fort_maintenance(self, fort_level):
        """Calculate maintenance cost for a fort of given level"""
        return fort_level * 200  # $200 per level


    def get_turns_for_project(self, days_required):
        """Convert a number of days into game turns"""
        # Define how many days constitute a game turn
        DAYS_PER_TURN = 30  # Assuming 1 turn = 1 month
        return (days_required + DAYS_PER_TURN - 1) // DAYS_PER_TURN  # Ceiling division


    def is_suitable_for_campaign(self):
        """Return True if current season is suitable for military campaigns"""
        return self.get_season() not in ["Winter"]  # Assume winter campaigns are difficult


    def days_until_season_change(self):
        """Return number of days until the next season change"""
        season = self.get_season()
        target_month = 0

        if season == "Winter":
            target_month = 4  # Spring starts
        elif season == "Spring":
            target_month = 7  # Summer starts
        elif season == "Summer":
            target_month = 10  # Fall starts
        elif season == "Fall":
            target_month = 1  # Winter starts, in next year

        clone = self.copy()
        if target_month < clone.current_month:
            clone.add_years(1)
        clone.current_month = target_month
        clone.current_day = 1

        return clone.total_days - self.total_days


    def get_military_tech_period(self):
        """Return the military technology period name based on year"""
        if self.current_year < 1400:
            return "Medieval Warfare"
        elif self.current_year < 1500:
            return "Pike and Shot"
        elif self.current_year < 1600:
            return "Early Gunpowder"
        elif self.current_year < 1700:
            return "Line Infantry"
        elif self.current_year < 1800:
            return "Napoleonic Era"
        elif self.current_year < 1870:
            return "Rifled Muskets"
        elif self.current_year < 1900:
            return "Early Modern"
        else:
            return "Modern Warfare"

    def get_historical_period(self):
        """Return the historical period information based on current date"""
        if not hasattr(db, 'db_periods') or not gs.db_periods:
            return None

        for period in gs.db_periods:
            if period.contains_date(self):
                return period

        return None

    def get_period_label(self):
        """Return the name of the current historical period"""
        period = self.get_historical_period()
        if period:
            return period.label
        return "Unknown Period"

    def is_ftg_era(self):
        """Check if the current date is within the FTG era"""
        period = self.get_historical_period()
        if period:
            return period.remark == "FTG"
        return False
