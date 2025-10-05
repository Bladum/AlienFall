# src/controllers/ai_controller.py
import random


class AIController:
    """Manages AI agents for countries."""

    def __init__(self, game_state):
        print("Create AI controller")
        from core.game_state import GameState
        self.game_state : GameState = game_state

    def get_actions(self):
        """Generate AI actions for the current turn."""
        actions = []

        # Simple random war declaration logic
        if random.random() < 0.1:  # 10% chance each turn
            countries = list(self.game_state.countries.keys())
            if len(countries) >= 2:
                attacker, defender = random.sample(countries, 2)

                # Check if not already at war
                already_at_war = any(
                    war["attacker"] == attacker and war["defender"] == defender
                    for war in self.game_state.diplomacy["wars"]
                )

                if not already_at_war:
                    actions.append({
                        "type": "declare_war",
                        "attacker": attacker,
                        "defender": defender,
                        "cb": "conquest"
                    })

        return actions