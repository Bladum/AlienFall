from ai.ai_agent import AIAgent


class AIAgentDiploRelation(AIAgent):
    """
    Agent that handles diplomatic relations between countries
    """

    def __init__(self, name, trigger_type="weekly", intelligence=80, traits=None, insights=None, priority=1.0):
        # Default insights if not provided
        insights = insights or ["improve_relations", "insult_rival", "send_gift"]

        # Default traits if not provided
        default_traits = {
            "diplomacy_skill": 50,  # Diplomatic ability
            "friendliness": 50,  # Tendency towards positive relations
            "grudge_holder": 50,  # Tendency to remember past issues
            "trustworthiness": 50  # How reliable the country is in agreements
        }

        traits = {**default_traits, **(traits or {})}
        super().__init__(name, trigger_type, intelligence, traits, insights, priority)

    # ------ Insight generator methods ------

    def improve_relations(self, game_state):
        """Generate insights for improving relations with other countries"""
        countries = game_state.get("diplomacy", {}).get("countries", [])
        insights = []

        for country in countries:
            # Skip enemies or already strong allies
            relation = country.get("relation", 0)
            if relation < -50 or relation > 75:
                continue

            # Calculate potential benefit
            benefit = self._calculate_relation_benefit(country, game_state)

            if benefit > 20:  # Only suggest if benefit is meaningful
                insights.append({
                    "description": "improve_relations",
                    "target_country": country.get("id"),
                    "target_name": country.get("name", "unknown"),
                    "current_relation": relation,
                    "potential_benefit": benefit
                })

        return insights

    def insult_rival(self, game_state):
        """Generate insights for insulting rival countries to appease allies"""
        rivals = game_state.get("diplomacy", {}).get("rivals", [])
        insights = []

        for rival in rivals:
            # Only insult if relations are already poor
            relation = rival.get("relation", 0)
            if relation > -20:
                continue

            # Calculate diplomatic impact
            impact = self._calculate_insult_impact(rival, game_state)

            insights.append({
                "description": "insult_rival",
                "target_country": rival.get("id"),
                "target_name": rival.get("name", "unknown"),
                "current_relation": relation,
                "diplomatic_impact": impact
            })

        return insights

    def send_gift(self, game_state):
        """Generate insights for sending gifts to improve relations"""
        countries = game_state.get("diplomacy", {}).get("countries", [])
        treasury = game_state.get("economy", {}).get("treasury", 0)
        insights = []

        # Skip if treasury is too low
        if treasury < 100:
            return []

        for country in countries:
            # Skip enemies
            relation = country.get("relation", 0)
            if relation < -20:
                continue

            # Calculate gift value and impact
            gift_value = self._calculate_gift_value(country, game_state)
            impact = self._calculate_gift_impact(country, gift_value)

            # Only suggest if impact is worthwhile and gift is affordable
            if impact > 10 and gift_value < treasury * 0.25:
                insights.append({
                    "description": "send_gift",
                    "target_country": country.get("id"),
                    "target_name": country.get("name", "unknown"),
                    "gift_value": gift_value,
                    "relation_impact": impact
                })

        return insights

    # ------ Scoring methods ------

    def score_improve_relations(self, insight, game_state):
        """Score improve_relations insights"""
        benefit = insight.get("potential_benefit", 0)
        current_relation = insight.get("current_relation", 0)

        # Base score from benefit
        base_score = benefit / 10

        # Prioritize neutral countries over negative relations
        if -20 <= current_relation <= 20:
            base_score *= 1.2

        # Apply trait modifiers
        diplomacy_factor = self.traits.get("diplomacy_skill", 50) / 50
        friendliness = self.traits.get("friendliness", 50) / 50

        return base_score * diplomacy_factor * friendliness * self.priority

    def score_insult_rival(self, insight, game_state):
        """Score insult_rival insights"""
        impact = insight.get("diplomatic_impact", 0)

        # Base score
        base_score = impact / 10

        # Apply trait modifiers
        diplomacy_factor = self.traits.get("diplomacy_skill", 50) / 50
        grudge_factor = self.traits.get("grudge_holder", 50) / 50
        friendliness = (100 - self.traits.get("friendliness", 50)) / 50  # Less friendly = more likely to insult

        return base_score * diplomacy_factor * grudge_factor * friendliness * self.priority

    def score_send_gift(self, insight, game_state):
        """Score send_gift insights"""
        impact = insight.get("relation_impact", 0)
        gift_value = insight.get("gift_value", 0)
        treasury = game_state.get("economy", {}).get("treasury", 0)

        # Base score from relation impact
        base_score = impact / 10

        # Reduce score if gift is expensive relative to treasury
        if treasury > 0:
            cost_factor = 1 - (gift_value / treasury) * 0.5
            base_score *= max(0.1, cost_factor)

        # Apply trait modifiers
        diplomacy_factor = self.traits.get("diplomacy_skill", 50) / 50
        friendliness = self.traits.get("friendliness", 50) / 50

        return base_score * diplomacy_factor * friendliness * self.priority

    # ------ Execution methods ------

    def execute_improve_relations(self, insight, game_state):
        """Execute improving relations with target country"""
        return {
            "success": True,
            "action": "improve_relations",
            "target_country": insight.get("target_country"),
            "message": f"Improving diplomatic relations with {insight.get('target_name')}"
        }

    def execute_insult_rival(self, insight, game_state):
        """Execute insulting a rival country"""
        return {
            "success": True,
            "action": "insult_rival",
            "target_country": insight.get("target_country"),
            "message": f"Insulting rival nation {insight.get('target_name')}"
        }

    def execute_send_gift(self, insight, game_state):
        """Execute sending a gift to target country"""
        return {
            "success": True,
            "action": "send_gift",
            "target_country": insight.get("target_country"),
            "gift_value": insight.get("gift_value", 0),
            "message": f"Sending gift worth {insight.get('gift_value')} to {insight.get('target_name')}"
        }

    # ------ Helper methods ------

    def _calculate_relation_benefit(self, country, game_state):
        """Calculate the strategic benefit of improving relations"""
        benefit = 30  # Base benefit

        # Strategic location bonus
        if country.get("is_strategic", False):
            benefit += 20

        # Trade potential bonus
        if country.get("trade_potential", 0) > 50:
            benefit += 15

        # Military strength - better relations with strong countries
        if country.get("military_strength", 0) > game_state.get("military", {}).get("total_strength", 0):
            benefit += 15

        # Common rivals bonus
        common_rivals = self._get_common_rivals(country, game_state)
        benefit += len(common_rivals) * 10

        # Current relation adjustment
        current = country.get("relation", 0)
        if current < 0:
            benefit -= 10  # Harder to improve negative relations

        return benefit

    def _calculate_insult_impact(self, rival, game_state):
        """Calculate the diplomatic impact of insulting a rival"""
        impact = 20  # Base impact

        # If rival is already hostile, less impact
        relation = rival.get("relation", 0)
        if relation < -50:
            impact -= 10

        # Impact on allies who also dislike this rival
        allies = game_state.get("diplomacy", {}).get("allies", [])
        for ally in allies:
            if self._is_rival_of(rival.get("id"), ally):
                impact += 5

        # Impact on neutral countries
        impact -= 5  # Small negative with neutrals

        # Apply grudge factor - higher grudge = more impactful insults
        grudge = self.traits.get("grudge_holder", 50) / 50
        impact *= grudge

        return impact

    def _calculate_gift_value(self, country, game_state):
        """Calculate appropriate gift value based on treasury and relation goals"""
        treasury = game_state.get("economy", {}).get("treasury", 0)
        relation = country.get("relation", 0)
        importance = country.get("strategic_importance", 50)

        # Base value as percentage of treasury
        base_value = treasury * 0.05

        # Adjust for current relations
        if relation < 0:
            base_value *= 1.5  # More expensive to improve negative relations
        elif relation > 50:
            base_value *= 0.7  # Less valuable for already good relations

        # Adjust for country importance
        importance_factor = importance / 50
        base_value *= importance_factor

        return max(50, min(treasury * 0.2, round(base_value)))

    def _calculate_gift_impact(self, country, gift_value):
        """Calculate the relation impact of a gift"""
        base_impact = 10

        # Impact scales with gift size but with diminishing returns
        if gift_value > 500:
            base_impact += 20
        elif gift_value > 200:
            base_impact += 15
        elif gift_value > 100:
            base_impact += 10

        # Adjust for current relation
        relation = country.get("relation", 0)
        if relation < 0:
            base_impact *= 0.8  # Less effective for negative relations
        elif relation > 50:
            base_impact *= 0.7  # Less effective for already good relations

        # Apply diplomatic skill
        diplomacy = self.traits.get("diplomacy_skill", 50) / 50

        return base_impact * diplomacy

    def _get_common_rivals(self, country, game_state):
        """Get list of rivals that both countries share"""
        country_rivals = country.get("rivals", [])
        own_rivals = game_state.get("diplomacy", {}).get("rivals", [])

        return [rival for rival in own_rivals if rival.get("id") in country_rivals]

    def _is_rival_of(self, rival_id, country):
        """Check if a country considers the given ID a rival"""
        country_rivals = country.get("rivals", [])
        return rival_id in country_rivals