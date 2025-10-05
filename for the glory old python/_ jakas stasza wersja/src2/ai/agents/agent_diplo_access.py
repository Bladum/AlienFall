# src/ai/agents/agent_diplo_access.py
from ai.ai_agent import AIAgent


class AgentDiploAccess(AIAgent):
    """
    Diplomatic agent that handles access rights to territories
    """

    def __init__(self, name, trigger_type="monthly", intelligence=80, traits=None, insights=None, priority=1.0):
        # Default insights if not provided
        insights = insights or ["request_access", "revoke_access", "grant_access"]

        # Default traits if not provided
        default_traits = {
            "diplomacy_skill": 50,  # Diplomatic effectiveness
            "trustworthiness": 50,  # How much AI values keeping agreements
            "expansionism": 50  # Interest in securing access to territories
        }

        traits = {**default_traits, **(traits or {})}
        super().__init__(name, trigger_type, intelligence, traits, insights, priority)

    # ------ Insight generator methods ------

    def request_access(self, game_state):
        """Generate insights for requesting access to territories"""
        countries = game_state.get("diplomacy", {}).get("countries", [])
        insights = []

        for country in countries:
            # Skip countries we already have access to
            if country.get("has_access", False):
                continue

            # Skip countries with very negative relations
            if country.get("relation", 0) < 20:
                continue

            strategic_value = self._calculate_access_value(country, game_state)
            if strategic_value > 30:
                insights.append({
                    "description": "request_access",
                    "area": country.get("name", "unknown"),
                    "country_id": country.get("id"),
                    "current_relation": country.get("relation", 0),
                    "strategic_value": strategic_value
                })

        return insights

    def revoke_access(self, game_state):
        """Generate insights for revoking access to our territories"""
        countries_with_access = game_state.get("diplomacy", {}).get("access_granted_to", [])
        insights = []

        for country in countries_with_access:
            relation = country.get("relation", 0)
            threat = country.get("threat_level", 0)

            if relation < 0 or threat > 60:
                insights.append({
                    "description": "revoke_access",
                    "area": "own_territory",
                    "country_id": country.get("id"),
                    "country_name": country.get("name", "unknown"),
                    "reason": "hostility" if relation < 0 else "threat"
                })

        return insights

    def grant_access(self, game_state):
        """Generate insights for granting access to our territories"""
        access_requests = game_state.get("diplomacy", {}).get("access_requests", [])
        insights = []

        for request in access_requests:
            country_id = request.get("country_id")
            relation = request.get("relation", 0)

            # Only consider countries with positive relations
            if relation > 20:
                insights.append({
                    "description": "grant_access",
                    "area": "own_territory",
                    "country_id": country_id,
                    "country_name": request.get("country_name", "unknown"),
                    "relation": relation
                })

        return insights

    # ------ Scoring methods ------

    def score_request_access(self, insight, game_state):
        """Score request_access insights based on strategic value and expansionism"""
        strategic_value = insight.get("strategic_value", 0)
        relation = insight.get("current_relation", 0)

        # Base score depends on strategic value
        base_score = strategic_value / 10

        # Apply trait modifiers
        diplomacy_factor = self.traits.get("diplomacy_skill", 50) / 50
        expansionism_factor = self.traits.get("expansionism", 50) / 40

        # Higher relation means better chance of success
        relation_bonus = min(relation / 20, 2.5)

        return base_score * diplomacy_factor * expansionism_factor * relation_bonus * self.priority

    def score_revoke_access(self, insight, game_state):
        """Score revoke_access insights based on trustworthiness and relations"""
        trust = self.traits.get("trustworthiness", 50)

        # Base score - higher for hostile countries
        if insight.get("reason") == "hostility":
            base_score = 8
        else:  # Threat
            base_score = 6

        # Low trustworthiness increases willingness to revoke access
        trust_factor = (100 - trust) / 50

        return base_score * trust_factor * self.priority

    def score_grant_access(self, insight, game_state):
        """Score grant_access insights based on relations and trustworthiness"""
        relation = insight.get("relation", 0)

        # Base score based on relation
        base_score = relation / 20

        # Apply trait modifiers
        diplomacy_factor = self.traits.get("diplomacy_skill", 50) / 50
        trust_factor = self.traits.get("trustworthiness", 50) / 50

        return base_score * diplomacy_factor * trust_factor * self.priority

    # ------ Execution methods ------

    def execute_request_access(self, insight, game_state):
        """Execute a request for military access"""
        return {
            "success": True,
            "action": "request_access",
            "target_country": insight.get("country_id"),
            "message": f"Requesting military access from {insight.get('area')}"
        }

    def execute_revoke_access(self, insight, game_state):
        """Execute revoking military access"""
        return {
            "success": True,
            "action": "revoke_access",
            "target_country": insight.get("country_id"),
            "reason": insight.get("reason"),
            "message": f"Revoking military access from {insight.get('country_name')}"
        }

    def execute_grant_access(self, insight, game_state):
        """Execute granting military access"""
        return {
            "success": True,
            "action": "grant_access",
            "target_country": insight.get("country_id"),
            "message": f"Granting military access to {insight.get('country_name')}"
        }

    # ------ Helper methods ------

    def _calculate_access_value(self, country, game_state):
        """Calculate the strategic value of getting access to a country's territory"""
        # Various factors that might contribute to strategic value:
        # - Proximity to enemies
        # - Resource access
        # - Strategic positioning

        base_value = 30

        # Add value for strategic location
        if country.get("is_coastal", False):
            base_value += 10

        # Add value for resource access
        base_value += len(country.get("resources", [])) * 5

        # Add value if country borders enemies
        for border in country.get("borders", []):
            border_country = border.get("country_id")
            relation = game_state.get("diplomacy", {}).get("relations", {}).get(border_country, 0)

            if relation < 0:
                # Negative relation indicates potential enemy
                base_value += 15
            elif relation < 20:
                # Cool relations still warrant some strategic value
                base_value += 5

        # Consider military threat levels in the area
        threat_level = country.get("region_threat", 0)
        if threat_level > 50:
            base_value += 20
        elif threat_level > 25:
            base_value += 10

        # Apply traits to final calculation
        expansionism = self.traits.get("expansionism", 50)
        diplomacy = self.traits.get("diplomacy_skill", 50)

        # Adjust value based on traits
        trait_modifier = (expansionism + diplomacy / 2) / 75  # 0.33-2.0 range

        return int(base_value * trait_modifier)