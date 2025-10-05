# src/ai/agents/agent_war.py
from ai.ai_agent import AIAgent


class AgentWar(AIAgent):
    """
    Strategic agent that handles war declarations and peace negotiations
    """

    def __init__(self, name, trigger_type="monthly", intelligence=80, traits=None, insights=None, priority=1.0):
        # Default insights if not provided
        insights = insights or ["declare_war", "negotiate_peace", "join_ally_war"]

        # Default traits if not provided
        default_traits = {
            "aggression": 50,  # Willingness to initiate conflicts
            "warmonger": 50,  # Desire to expand through warfare
            "honor": 50,  # Adherence to alliances and obligations
            "strategy": 50  # Ability to assess war strategically
        }

        traits = {**default_traits, **(traits or {})}
        super().__init__(name, trigger_type, intelligence, traits, insights, priority)

    # ------ Insight generator methods ------

    def declare_war(self, game_state):
        """Generate insights for declaring war on other countries"""
        countries = game_state.get("diplomacy", {}).get("countries", [])
        insights = []

        for country in countries:
            # Skip countries we're already at war with
            if country.get("at_war", False):
                continue

            # Skip very strong allies
            if country.get("relation", 0) > 80:
                continue

            war_score = self._calculate_war_justification(country, game_state)
            if war_score > 60:  # Only suggest war if score is high enough
                insights.append({
                    "description": "declare_war",
                    "target_country": country.get("id"),
                    "target_name": country.get("name", "unknown"),
                    "justification": self._get_war_reason(country, game_state),
                    "strength_ratio": self._calculate_strength_ratio(country, game_state),
                    "war_score": war_score
                })

        return insights

    def negotiate_peace(self, game_state):
        """Generate insights for negotiating peace with enemies"""
        active_wars = game_state.get("diplomacy", {}).get("wars", [])
        insights = []

        for war in active_wars:
            enemy_id = war.get("enemy_id")
            war_exhaustion = war.get("exhaustion", 0)
            war_progress = war.get("progress", 0)  # Positive means winning
            duration = war.get("duration", 0)

            # Consider peace if war is going poorly or has lasted long
            if war_exhaustion > 60 or war_progress < -20 or duration > 24:
                insights.append({
                    "description": "negotiate_peace",
                    "target_country": enemy_id,
                    "target_name": war.get("enemy_name", "unknown"),
                    "war_id": war.get("id"),
                    "duration": duration,
                    "exhaustion": war_exhaustion,
                    "progress": war_progress,
                    "concession_level": self._calculate_concession_level(war_progress, war_exhaustion)
                })

        return insights

    def join_ally_war(self, game_state):
        """Generate insights for joining allies in their wars"""
        allies = game_state.get("diplomacy", {}).get("allies", [])
        insights = []

        for ally in allies:
            ally_wars = ally.get("wars", [])

            for war in ally_wars:
                # Skip wars we're already in
                if war.get("joined", False):
                    continue

                enemy_id = war.get("enemy_id")
                honor = self.traits.get("honor", 50)

                # Calculate value of joining
                join_value = self._calculate_join_value(ally, war, game_state)

                if join_value > 50 or (honor > 70 and join_value > 30):
                    insights.append({
                        "description": "join_ally_war",
                        "ally_id": ally.get("id"),
                        "ally_name": ally.get("name", "unknown"),
                        "enemy_id": enemy_id,
                        "enemy_name": war.get("enemy_name", "unknown"),
                        "war_id": war.get("id"),
                        "join_value": join_value
                    })

        return insights

    # ------ Scoring methods ------

    def score_declare_war(self, insight, game_state):
        """Score declare_war insights based on war score and aggression"""
        war_score = insight.get("war_score", 0)
        strength_ratio = insight.get("strength_ratio", 1.0)

        # Base score from war justification
        base_score = war_score / 10

        # Modify by strength ratio (favorable = higher score)
        if strength_ratio > 1.5:
            base_score *= 1.5
        elif strength_ratio < 0.8:
            base_score *= 0.5

        # Apply trait modifiers
        aggression_factor = self.traits.get("aggression", 50) / 40
        warmonger_factor = self.traits.get("warmonger", 50) / 50
        strategy_factor = self.traits.get("strategy", 50) / 50

        return base_score * aggression_factor * warmonger_factor * strategy_factor * self.priority

    def score_negotiate_peace(self, insight, game_state):
        """Score negotiate_peace insights based on war exhaustion and progress"""
        exhaustion = insight.get("exhaustion", 0)
        progress = insight.get("progress", 0)
        duration = insight.get("duration", 0)

        # Base score - higher when war is going poorly
        if progress < -30:
            base_score = 8  # High priority for bad wars
        elif progress < 0:
            base_score = 6  # Medium priority for losing wars
        elif exhaustion > 70:
            base_score = 5  # Consider peace for exhausting wars
        elif duration > 36:
            base_score = 4  # Consider peace for long wars
        else:
            base_score = 2  # Low priority for favorable wars

        # Apply trait modifiers - lower aggression means more willing to peace
        aggression_factor = (100 - self.traits.get("aggression", 50)) / 50
        strategy_factor = self.traits.get("strategy", 50) / 50

        return base_score * aggression_factor * strategy_factor * self.priority

    def score_join_ally_war(self, insight, game_state):
        """Score join_ally_war insights based on join value and honor"""
        join_value = insight.get("join_value", 0)

        # Base score from join value
        base_score = join_value / 10

        # Apply trait modifiers
        honor_factor = self.traits.get("honor", 50) / 40
        strategy_factor = self.traits.get("strategy", 50) / 50

        return base_score * honor_factor * strategy_factor * self.priority

    # ------ Execution methods ------

    def execute_declare_war(self, insight, game_state):
        """Execute war declaration against target country"""
        return {
            "success": True,
            "action": "declare_war",
            "target_country": insight.get("target_country"),
            "justification": insight.get("justification"),
            "message": f"Declaring war on {insight.get('target_name')} with justification: {insight.get('justification')}"
        }

    def execute_negotiate_peace(self, insight, game_state):
        """Execute peace negotiation with target country"""
        concession_level = insight.get("concession_level", "white_peace")

        return {
            "success": True,
            "action": "negotiate_peace",
            "war_id": insight.get("war_id"),
            "target_country": insight.get("target_country"),
            "concession_level": concession_level,
            "message": f"Negotiating {concession_level} peace with {insight.get('target_name')}"
        }

    def execute_join_ally_war(self, insight, game_state):
        """Execute joining ally's war"""
        return {
            "success": True,
            "action": "join_war",
            "ally_id": insight.get("ally_id"),
            "enemy_id": insight.get("enemy_id"),
            "war_id": insight.get("war_id"),
            "message": f"Joining {insight.get('ally_name')}'s war against {insight.get('enemy_name')}"
        }

    # ------ Helper methods ------

    def _calculate_war_justification(self, country, game_state):
        """Calculate justification score for going to war (0-100)"""
        score = 0

        # Negative relations increase war justification
        relation = country.get("relation", 0)
        if relation < 0:
            score += min(40, abs(relation))

        # Threat level increases justification
        threat = country.get("threat_level", 0)
        score += threat * 0.5

        # Historical claims or contested territories
        claims = self._get_territorial_claims(country.get("id"), game_state)
        score += len(claims) * 15

        # Resource needs
        if self._has_needed_resources(country, game_state):
            score += 20

        # Strategic value
        strategic_value = country.get("strategic_value", 0)
        score += strategic_value * 0.3

        # Apply trait modifiers
        warmonger = self.traits.get("warmonger", 50)
        aggression = self.traits.get("aggression", 50)

        trait_modifier = (warmonger + aggression) / 100  # 0.5-2.0 range

        return min(100, score * trait_modifier)

    def _calculate_strength_ratio(self, country, game_state):
        """Calculate military strength ratio (own/enemy)"""
        own_strength = game_state.get("military", {}).get("total_strength", 100)
        enemy_strength = country.get("military_strength", 100)

        if enemy_strength == 0:
            return 10.0  # Avoid division by zero

        return own_strength / enemy_strength

    def _get_war_reason(self, country, game_state):
        """Get the primary reason for declaring war"""
        claims = self._get_territorial_claims(country.get("id"), game_state)

        if claims:
            return "territorial_claim"

        if self._has_needed_resources(country, game_state):
            return "resource_acquisition"

        if country.get("threat_level", 0) > 50:
            return "preemptive_strike"

        if country.get("relation", 0) < -50:
            return "ideological_differences"

        return "strategic_interests"

    def _get_territorial_claims(self, country_id, game_state):
        """Get list of territorial claims against specified country"""
        return game_state.get("diplomacy", {}).get("claims", {}).get(country_id, [])

    def _has_needed_resources(self, country, game_state):
        """Check if country has resources we need"""
        needed_resources = game_state.get("economy", {}).get("needed_resources", [])
        country_resources = country.get("resources", [])

        return any(resource in country_resources for resource in needed_resources)

    def _calculate_concession_level(self, war_progress, war_exhaustion):
        """Determine what level of peace terms to offer"""
        if war_progress > 50:
            return "demand_concessions"
        elif war_progress > 20:
            return "favorable_peace"
        elif war_progress < -30 or war_exhaustion > 80:
            return "offer_concessions"
        else:
            return "white_peace"

    def _calculate_join_value(self, ally, war, game_state):
        """Calculate the value of joining ally's war"""
        value = 0

        # Base value from alliance strength
        relation = ally.get("relation", 0)
        value += relation * 0.3

        # Assess enemy threat
        enemy_id = war.get("enemy_id")
        enemy = self._find_country_by_id(enemy_id, game_state)

        if enemy:
            # If enemy is already hostile to us, higher value
            own_relation = enemy.get("relation_to_us", 0)
            if own_relation < 0:
                value += abs(own_relation) * 0.5

            # If enemy is a threat, higher value
            enemy_threat = enemy.get("threat_to_us", 0)
            value += enemy_threat * 0.5

            # If we have claims on them, higher value
            claims = self._get_territorial_claims(enemy_id, game_state)
            value += len(claims) * 10

        # Apply honor - higher honor means higher value placed on honoring alliances
        honor_modifier = self.traits.get("honor", 50) / 50

        return min(100, value * honor_modifier)

    def _find_country_by_id(self, country_id, game_state):
        """Find a country by ID in the game state"""
        countries = game_state.get("diplomacy", {}).get("countries", [])
        for country in countries:
            if country.get("id") == country_id:
                return country
        return None