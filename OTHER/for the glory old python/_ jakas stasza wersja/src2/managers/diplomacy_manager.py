
# src/managers/diplomacy_manager.py
class DiplomacyManager:
    """Handles diplomatic relations between countries."""

    def __init__(self, game_state):
        from core.game_state import GameState
        self.gs : GameState = game_state

    def set_relation(self, country1, country2, value):
        """Set diplomatic relation between two countries."""
        key1 = f"{country1}_{country2}"
        key2 = f"{country2}_{country1}"
        self.gs.diplomacy["relations"][key1] = value
        self.gs.diplomacy["relations"][key2] = value

    def get_relation(self, country1, country2):
        """Get diplomatic relation between two countries."""
        key = f"{country1}_{country2}"
        return self.gs.diplomacy["relations"].get(key, 0)

    def declare_war(self, attacker, defender, cb=None):
        """Declare war between countries."""
        war_id = f"war_{len(self.gs.diplomacy['wars'])}"

        war = {
            "id": war_id,
            "attacker": attacker,
            "defender": defender,
            "cb": cb,
            "start_day": self.gs.game_clock.current_day
        }

        self.gs.diplomacy["wars"].append(war)
        self.set_relation(attacker, defender, -100)

        # Trigger event
        self.gs.trigger_event("war_declared", war)

        return war