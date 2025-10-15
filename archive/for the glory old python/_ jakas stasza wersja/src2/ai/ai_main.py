import toml
import random

from ai.ai_factory import AgentFactory


class MainAI:
    def __init__(self, global_config_path, country_config_path=None):
        self.agents = []
        self.insights = []

        # Load global configuration
        with open(global_config_path, 'r') as file:
            global_data = toml.load(file)
            self.priorities = global_data.get('priorities', {})
            self.geography = global_data.get('geography', {})
            self.global_traits = global_data.get('global', {})

        # Create agents using factory
        self.agents = AgentFactory.create_agents_for_country(
            global_config_path,
            country_config_path
        )

        # Global intelligence affects overall AI capability
        self.intelligence = self.global_traits.get('intelligence', 100)

    def add_agent(self, agent):
        self.agents.append(agent)

    def gather_insights(self, game_state):
        self.insights = []
        for agent in self.agents:
            # Only check and get insights if the agent should trigger now
            if agent.should_trigger(game_state):
                agent.check(game_state)
                self.insights.extend(agent.suggest_insights(game_state))

    def decide_actions(self, game_state):
        scored_insights = []
        for agent in self.agents:
            for insight in agent.suggest_insights(game_state):
                score = self.priorities.get(agent.name, {}).get(insight['description'], self.priorities.get('default', 1.0))
                score *= self.geography.get('area', {}).get(insight['area'], 1.0)
                score *= self.geography.get('region', {}).get(insight['region'], 1.0)
                score *= self.geography.get('continent', {}).get(insight['continent'], 1.0)

                # Use agent's intelligence to influence scoring
                score *= agent.intelligence / 80  # Normalize based on average intelligence of 80

                scored_insights.append((insight, score))

        # Sort insights by score in descending order
        scored_insights.sort(key=lambda x: x[1], reverse=True)

        # Determine the number of actions based on intelligence
        actions = []
        for i, (insight, score) in enumerate(scored_insights):
            if i == 0 or random.random() < (self.intelligence - 100) / 100:
                actions.append(insight)
            if len(actions) >= self.intelligence // 100 + 1:
                break

        return actions