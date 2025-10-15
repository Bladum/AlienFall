import toml
from pathlib import Path
from utils.clock import Clock


class Period:
    """Represents a single game period based on date information"""

    def __init__(self, period_id=None, start_date=None, end_date=None, years=None,
                 remark=None, label=None, description=None, modifiers=None):
        """Initialize a period with its attributes"""
        self.id = period_id
        self.start = start_date if isinstance(start_date, Clock) else Clock(date_str=start_date) if start_date else None
        self.end = end_date if isinstance(end_date, Clock) else Clock(date_str=end_date) if end_date else None
        self.years = years
        self.remark = remark
        self.label = label
        self.description = description
        self.modifiers = modifiers or {}

    @classmethod
    def from_dict(cls, period_id, data):
        """Create a Period object from dictionary data"""
        return cls(
            period_id=period_id,
            start_date=data['start'],
            end_date=data['end'],
            years=data['years'],
            remark=data['remark'],
            label=data['label'],
            description=data['description'],
            modifiers=data.get('modifiers', {})
        )

    def contains_date(self, clock):
        """Check if this period contains the given date"""
        if not self.start or not self.end:
            return False

        date_str = clock.convert_to_str()
        return self.start.convert_to_str() <= date_str <= self.end.convert_to_str()

    def is_ftg_period(self):
        """Check if this is an FTG period"""
        return self.remark == "FTG" if self.remark else False

    def days_until_end(self, clock):
        """Get days until the end of this period from the given date"""
        if not self.end:
            return None

        return self.end.total_days - clock.total_days

    def to_dict(self):
        """Convert period to dictionary representation"""
        return {
            'id': self.id,
            'start': self.start.convert_to_str() if self.start else None,
            'end': self.end.convert_to_str() if self.end else None,
            'years': self.years,
            'remark': self.remark,
            'label': self.label,
            'description': self.description,
            'modifiers': self.modifiers
        }

    @staticmethod
    def load_from_file(file_path="data/ftg/db/period.toml", period_id=None):
        """Load a specific period from the toml file"""
        try:
            path = Path(file_path)
            if not path.exists():
                raise FileNotFoundError(f"Period file not found: {file_path}")

            with open(path, 'r', encoding='utf-8') as f:
                period_data = toml.load(f)

            if period_id is not None:
                period_id = str(period_id)
                if period_id in period_data:
                    return Period.from_dict(int(period_id), period_data[period_id])
                return None

            # If no specific ID requested, return the first period
            if period_data:
                first_id = next(iter(period_data))
                return Period.from_dict(int(first_id), period_data[first_id])
            return None

        except Exception as e:
            print(f"Error loading period data: {e}")
            return None