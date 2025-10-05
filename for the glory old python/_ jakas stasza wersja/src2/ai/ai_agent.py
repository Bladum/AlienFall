class AIAgent:
    def __init__(self, name, trigger_type="daily", intelligence=80, traits=None, insights=None, priority=1.0):
        self.name = name
        self.trigger_type = trigger_type
        self.intelligence = intelligence
        self.priority = priority
        self.traits = traits or {}
        self.insights = insights or []

    # Other methods as defined previously

    def should_trigger(self, game_state):
        """Check if the agent should be triggered based on the current game day"""
        current_day = game_state.get('current_day', 0)

        if self.trigger_type == "daily":
            return True
        elif self.trigger_type == "weekly":
            # Assuming a week is 6 days
            return current_day % 6 == 0
        elif self.trigger_type == "monthly":
            # Assuming a month is 30 days
            return current_day % 30 == 0
        elif self.trigger_type == "quarterly":
            # Assuming a quarter is 90 days
            return current_day % 90 == 0
        elif self.trigger_type == "yearly":
            # Assuming a year is 360 days
            return current_day % 360 == 0
        return False

    def check(self, game_state):
        """
        Check the game state and return a list of insights
        """
        insights = self.suggest_insights(game_state)

        # Score each insight
        scored_insights = []
        for insight in insights:
            score = self.score_insight(insight, game_state)
            insight['score'] = score * self.priority
            scored_insights.append(insight)

        # Sort by score
        return sorted(scored_insights, key=lambda x: x['score'], reverse=True)

    def suggest_insights(self, game_state):
        """
        Generate a list of insights based on registered insight names.
        Each insight name corresponds to a method in the agent class.
        """
        all_insights = []

        for insight_name in self.insights:
            # Check if the agent has a method matching the insight name
            if hasattr(self, insight_name) and callable(getattr(self, insight_name)):
                # Call the method to generate the insight
                method = getattr(self, insight_name)
                insights = method(game_state)

                # If returned value is not a list, convert it to a list
                if not isinstance(insights, list):
                    insights = [insights] if insights is not None else []

                # Add the insights to the collection
                all_insights.extend(insights)
            else:
                # Fallback for unimplemented insights
                all_insights.append({
                    'description': insight_name,
                    'area': 'unknown',
                    'score': 0.5  # Default low score for unimplemented insights
                })

        return all_insights

    def score_insight(self, insight, game_state):
        """
        Score an insight based on the agent's traits and the game state.
        Higher scores indicate more important insights.

        Returns:
            float: A score value (typically between 0-10) for the insight
        """
        # Check if there's a specific scoring method for this insight type
        scoring_method_name = f"score_{insight}"

        if hasattr(self, scoring_method_name) and callable(getattr(self, scoring_method_name)):
            return getattr(self, scoring_method_name)(insight, game_state)

        # Apply intelligence modifier to base score
        return 1.0 * (self.intelligence / 100.0)

    def execute_insight(self, insight, game_state):
        """
        Execute an insight by calling the corresponding method

        Args:
            insight (dict): The insight to execute
            game_state (dict): The current game state

        Returns:
            dict: Updated game state or action result
        """
        execute_method_name = f"execute_{insight}"

        if hasattr(self, execute_method_name) and callable(getattr(self, execute_method_name)):
            return getattr(self, execute_method_name)(insight, game_state)

        # Default implementation
        return {
            'success': False,
            'message': f"No execution method found for {insight}"
        }