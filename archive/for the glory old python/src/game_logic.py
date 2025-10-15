'''

GAME LOGIC

Class to manage all background processing related to game play



'''
from manager import manager_province, manager_cot, manager_country
from src.db import TDB
db = TDB()


def process_game_logic_before():
    print("Game logic before processing")

    manager_province.process_before_all()
    manager_country.process_before_all()
    manager_cot.process_before_all()