import toml
import importlib
from ai.ai_agent import AIAgent

from core.game_state import GameState
gs = GameState()


class AgentFactory:
    @staticmethod
    def create_agents_for_country(country_id, ai_file = None):
        """
        Create AI agents for a specific country using global configurations
        and applying country-specific overrides.

        Args:
            country_id (str): The identifier of the country (e.g., "FRA")

        Returns:
            tuple: (agents_list, country_data) where agents_list is a list of agent instances
                  and country_data contains other country-specific configurations
                  :param country_id:
                  :param ai_file:
        """
        # Get global agent configurations from gs.db_ai_agents
        if not gs.db_ai_agents:
            raise ValueError("Global AI agent configurations not loaded. Call load_ai_agents_from_toml first.")

        if ai_file is None:
            ai_file = country_id

        # Load country-specific configuration if it exists
        country_config = {}
        country_file_path = gs.path_db / 'ai' / f"{ai_file}.toml"

        if country_file_path.exists():
            try:
                with open(country_file_path, 'r') as file:
                    country_config = toml.load(file)
            except Exception as e:
                print(f"Error loading country config for {country_id}: {e}")
        else:
            print(f"No country-specific config found for {country_id}, using global defaults")

        # Extract non-agent specific data from country config
        country_data = {
            'country_id': country_id,
            'name': country_config.get('name', country_id),
            'agents': country_config.get('agents', {}),
            'geography': country_config.get('geography', {})
        }

        # Create agent instances with country-specific overrides
        agents_list = []
        for agent_id, global_agent in gs.db_ai_agents.items():
            # Skip any non-agent items
            if not agent_id.startswith('agent_'):
                continue

            # Start with a copy of the global agent's attributes
            agent_name = global_agent.name
            trigger = global_agent.trigger_typepriority
            priority = global_agent.priority
            intelligence = global_agent.intelligence
            traits = global_agent.traits.copy() if global_agent.traits else {}
            insights = global_agent.insights.copy() if global_agent.insights else []

            # Apply country-specific overrides if available
            if 'agents' in country_config and agent_id in country_config['agents']:
                override = country_config['agents'][agent_id]
                if 'trigger' in override:
                    trigger = override['trigger']
                if 'priority' in override:
                    priority = override['priority']
                if 'intelligence' in override:
                    intelligence = override['intelligence']
                if 'traits' in override:
                    for trait, value in override['traits'].items():
                        traits[trait] = value

            # Attempt to load specialized agent class
            agent_class = AIAgent
            try:
                module = importlib.import_module(f"src.ai.agents.{agent_id}")
                agent_class = getattr(module, f"AI{agent_id.replace("_", " ").title().replace(' ', '')}")
            except (ImportError, AttributeError):
                # If specialized class doesn't exist, use base AIAgent class
                pass

            # Create and add the agent instance
            agent = agent_class(agent_name, trigger, intelligence, traits, insights, priority)
            agents_list.append(agent)

        return agents_list, country_data

    @staticmethod
    def load_all_country_configs():
        """
        Load all country-specific configurations from the db/ai directory.

        Returns:
            dict: A dictionary mapping country IDs to their configuration data
        """
        country_configs = {}
        ai_dir = gs.path_db / 'ai'

        if ai_dir.exists():
            for file_path in ai_dir.glob('*.toml'):
                country_id = file_path.stem  # Get filename without extension
                try:
                    with open(file_path, 'r') as file:
                        country_configs[country_id] = toml.load(file)
                except Exception as e:
                    print(f"Error loading country config {file_path}: {e}")

        return country_configs

    @staticmethod
    def create_agents_for_all_countries():
        """
        Create AI agents for all countries with specific configurations.

        Returns:
            dict: A dictionary mapping country IDs to tuples of (agents, country_data)
        """
        country_configs = AgentFactory.load_all_country_configs()
        country_agents = {}

        for country_id in country_configs:
            agents_list, country_data = AgentFactory.create_agents_for_country(country_id)
            country_agents[country_id] = (agents_list, country_data)

        return country_agents

    @staticmethod
    def switch_ai_for_country(country_id, ai_file):
        """
        Switch the AI agent for a specific country to a new agent.

        Args:
            country_id (str): The identifier of the country (e.g., "FRA")
            new_agent_id (str): The identifier of the new AI agent (e.g., "agent_war")

        Returns:
            bool: True if the switch was successful, False otherwise
            :param country_id:
            :param ai_file:
        """
        try:
            # Create agents for the country, which will overwrite the current configuration
            agents_list, country_data = AgentFactory.create_agents_for_country(country_id, ai_file)

            return agents_list
        except Exception as e:
            print(f"Error switching AI agent for {country_id}: {e}")
            return []