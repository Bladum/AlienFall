# src/controllers/game_controller.py



class GameController:
    """Central coordination point for the game."""

    def __init__(self):

        print("Create game controller")

        from core.game_state import GameState
        from managers.province_manager import ProvinceManager
        from managers.country_manager import CountryManager
        from managers.diplomacy_manager import DiplomacyManager
        from managers.mod_manager import ModManager
        from managers.map_manager import MapManager
        from managers.scenario_manager import ScenarioManager
        from controllers.ai_controller import AIController
        from managers.cot_manager import COTManager

        # Create game state
        self.game_state = GameState()

        # Create managers
        self.province_manager = ProvinceManager(self.game_state)
        self.country_manager = CountryManager(self.game_state)
        self.diplomacy_manager = DiplomacyManager(self.game_state)
        self.mod_manager = ModManager(self.game_state)
        self.cot_manager = COTManager(self.game_state)
        self.map_manager = MapManager(self.game_state)
        self.scenario_manager = ScenarioManager(self.game_state, self, None)

        # Create AI controller
        self.ai_controller = AIController(self.game_state)


    def advance_day(self):
        """Advance the game by one day."""
        self.game_state.game_clock += 1

        # Process AI actions
        self.process_ai_turn()

        return self.game_state.game_clock

    def process_ai_turn(self):
        """Process AI decisions for each country."""
        actions = self.ai_controller.get_actions()

        for action in actions:
            action_type = action.get("type")

            # TODO