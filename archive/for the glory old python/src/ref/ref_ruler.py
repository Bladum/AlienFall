import datetime


class Ruler:

    def __init__(self):
        self.name = ''
        self.admin_skill = 2
        self.diplo_skill = 2
        self.mil_skill = 2
        self.start = datetime.date.fromisocalendar(1500, 20, 10)
        self.end = datetime.date.fromisocalendar(1500, 20, 10)
        self.culture = 'name'


