# src/ai/agents/agent_battle_land.py
from ai.ai_agent import AIAgent


class AgentBattleLand(AIAgent):
    """
    Military land battle agent that handles combat decisions and strategy
    """

    def __init__(self, name, trigger_type="weekly", intelligence=80, traits=None, insights=None, priority=1.0):
        # Default insights if not provided
        insights = insights or ["engage_enemy", "retreat", "defensive_position"]

        # Default traits if not provided
        default_traits = {
            "combat_skill": 50,  # Base combat effectiveness
            "strategy_level": 50,  # Strategic planning ability
            "aggression": 50,  # Tendency to take offensive actions
            "caution": 50  # Tendency to be defensive
        }

        traits = {**default_traits, **(traits or {})}
        super().__init__(name, trigger_type, intelligence, traits, insights, priority)

    # ------ Insight generator methods ------

    def engage_enemy(self, game_state):
        """Generate insights for engaging enemies in battle"""
        enemy_units = game_state.get("military", {}).get("enemies", [])
        insights = []

        for enemy in enemy_units:
            if self._should_engage(enemy, game_state):
                insights.append({
                    "description": "engage_enemy",
                    "area": enemy.get("location", "unknown"),
                    "target": enemy.get("id"),
                    "target_strength": enemy.get("strength", 0),
                    "confidence": self._calculate_victory_chance(enemy, game_state)
                })

        return insights

    def retreat(self, game_state):
        """Generate insights for retreating from unfavorable battles"""
        current_battles = game_state.get("military", {}).get("current_battles", [])
        insights = []

        for battle in current_battles:
            if self._should_retreat(battle, game_state):
                insights.append({
                    "description": "retreat",
                    "area": battle.get("location", "unknown"),
                    "battle_id": battle.get("id"),
                    "reason": "unfavorable_odds" if battle.get("enemy_strength", 0) > battle.get("own_strength", 0) * 1.5 else "strategic"
                })

        return insights

    def defensive_position(self, game_state):
        """Generate insights for taking defensive positions"""
        vulnerable_areas = game_state.get("military", {}).get("vulnerable_borders", [])
        insights = []

        for area in vulnerable_areas:
            insights.append({
                "description": "defensive_position",
                "area": area.get("location", "unknown"),
                "threat_level": area.get("threat", 50),
                "current_defense": area.get("defense", 0)
            })

        return insights

    # ------ Scoring methods ------

    def score_engage_enemy(self, insight, game_state):
        """Score engage_enemy insights based on combat traits and military situation"""
        base_score = insight.get("confidence", 50) / 10  # 0-10 score based on confidence

        # Apply trait modifiers
        aggression_factor = self.traits.get("aggression", 50) / 50  # 0-2 range
        combat_factor = self.traits.get("combat_skill", 50) / 50

        return base_score * aggression_factor * combat_factor * self.priority

    def score_retreat(self, insight, game_state):
        """Score retreat insights based on caution and strategy"""
        base_score = 5  # Default medium priority

        # Apply trait modifiers
        caution_factor = self.traits.get("caution", 50) / 25  # 0-4 range for caution
        strategy_factor = self.traits.get("strategy_level", 50) / 50

        if insight.get("reason") == "unfavorable_odds":
            base_score = 8  # Higher priority for bad odds

        return base_score * caution_factor * strategy_factor * self.priority

    def score_defensive_position(self, insight, game_state):
        """Score defensive position insights based on threat level and strategy"""
        threat = insight.get("threat_level", 50)
        current_defense = insight.get("current_defense", 0)

        # Higher threat and lower defense means higher score
        base_score = (threat / 10) * (10 - min(current_defense / 10, 9))

        # Apply trait modifiers
        caution_factor = self.traits.get("caution", 50) / 50
        strategy_factor = self.traits.get("strategy_level", 50) / 50

        return base_score * caution_factor * strategy_factor * self.priority

    # ------ Execution methods ------

    def execute_engage_enemy(self, insight, game_state):
        """Execute an engagement with enemy forces"""
        # Implementation would depend on the game's military system
        return {
            "success": True,
            "action": "engage_enemy",
            "target": insight.get("target"),
            "area": insight.get("area"),
            "message": f"Attacking enemy forces in {insight.get('area')}"
        }

    def execute_retreat(self, insight, game_state):
        """Execute a retreat from battle"""
        return {
            "success": True,
            "action": "retreat",
            "battle_id": insight.get("battle_id"),
            "area": insight.get("area"),
            "message": f"Retreating from battle in {insight.get('area')}"
        }

    def execute_defensive_position(self, insight, game_state):
        """Execute setting up defensive positions"""
        return {
            "success": True,
            "action": "defend",
            "area": insight.get("area"),
            "message": f"Setting up defensive positions in {insight.get('area')}"
        }

    # ------ Helper methods ------

    def _should_engage(self, enemy, game_state):
        """Determine if we should engage this enemy based on traits and situation"""
        own_strength = game_state.get("military", {}).get("own_strength", 100)
        enemy_strength = enemy.get("strength", 100)

        # More aggressive agents will engage at worse odds
        aggression = self.traits.get("aggression", 50)
        threshold = 0.8 + (aggression - 50) / 100  # 0.3 to 1.3 based on aggression

        return own_strength >= enemy_strength * threshold

    def _should_retreat(self, battle, game_state):
        """Determine if we should retreat from this battle"""
        own_strength = battle.get("own_strength", 100)
        enemy_strength = battle.get("enemy_strength", 100)

        # More cautious agents will retreat at better odds
        caution = self.traits.get("caution", 50)
        threshold = 0.8 + (caution - 50) / 100  # 0.3 to 1.3 based on caution

        return enemy_strength >= own_strength * threshold

    def _calculate_victory_chance(self, enemy, game_state):
        """Calculate chance of victory as a percentage"""
        own_strength = game_state.get("military", {}).get("own_strength", 100)
        enemy_strength = enemy.get("strength", 100)

        # Apply combat skill modifier
        combat_skill = self.traits.get("combat_skill", 50)
        effective_strength = own_strength * (combat_skill / 50)

        # Calculate basic odds
        if enemy_strength == 0:
            return 100
        odds = effective_strength / enemy_strength

        # Convert to percentage (0-100)
        return min(100, max(0, odds * 50))