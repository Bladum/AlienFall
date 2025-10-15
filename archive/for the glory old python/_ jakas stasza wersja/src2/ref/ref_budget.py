import toml
from pathlib import Path

from utils.modifiers import Modifiers
from utils.requs import Requirements


class BudgetDecision:
    """Represents a budget decision category with low/medium/high options"""

    def __init__(self, id, data):
        self.id = id
        self.label = data.get('label', 'Unknown Decision')
        self.prerequisites : Requirements = Requirements( data.get('prereq', {}) )

        # Store modifiers for each level
        self.low_modifiers : Modifiers = Modifiers( data.get('low', {}) )
        self.medium_modifiers : Modifiers = Modifiers( data.get('medium', {}) )
        self.high_modifiers: Modifiers = Modifiers( data.get('high', {}) )

    def get_modifiers_for_level(self, level):
        """Get the modifiers for a specific level (low, medium, high)"""
        if level == 'low':
            return self.low_modifiers
        elif level == 'medium':
            return self.medium_modifiers
        elif level == 'high':
            return self.high_modifiers
        else:
            return None

    def __str__(self):
        return f"{self.label} (ID: {self.id})"


class CountryBudgetDecisions:
    """Handles a country's budget decisions"""

    def __init__(self, country):
        self.country = country
        # Store current decision levels
        self.decisions = {
            'tax_level': 'medium',
            'army_maintenance': 'medium',
            'navy_maintenance': 'medium',
            'technology_invest': 'medium',
            'stability_invest': 'medium',
            'corruption_control': 'medium',
            'tariffs_level': 'medium',
            'diplomacy_invest': 'medium',
            'colonist_maintenance': 'medium',
            'missionary_maintenance': 'medium',
            'agriculture_support': 'medium'
        }

    def set_decision_level(self, decision_id, level):
        """Set a budget decision to low/medium/high"""
        if level not in ['low', 'medium', 'high']:
            raise ValueError(f"Invalid decision level: {level}. Must be 'low', 'medium', or 'high'.")

        if decision_id in self.decisions:
            self.decisions[decision_id] = level
        else:
            raise ValueError(f"Unknown budget decision: {decision_id}")

    def get_decision_level(self, decision_id):
        """Get the current level for a decision"""
        return self.decisions.get(decision_id, 'medium')

    def get_all_active_modifiers(self, budget_manager):
        """Calculate all active modifiers from current decisions"""
        modifiers = {}

        for decision_id, level in self.decisions.items():
            decision = budget_manager.get_decision(decision_id)
            if decision and decision.check_prerequisites(self.country):
                level_modifiers = decision.get_modifiers_for_level(level)
                # Merge modifiers
                for mod_key, mod_value in level_modifiers.items():
                    modifiers[mod_key] = modifiers.get(mod_key, 0) + mod_value

        return modifiers

    def calculate_budget_spending(self, budget_manager):
        """Calculate total budget spending from decisions"""
        spending = 0

        for decision_id, level in self.decisions.items():
            decision = budget_manager.get_decision(decision_id)
            if decision and decision.check_prerequisites(self.country):
                level_modifiers = decision.get_modifiers_for_level(level)
                spending += level_modifiers.get('budget_spending', 0)

        return spending


class BudgetManager:
    """Manages budget decisions loaded from budget.toml"""

    def __init__(self, budget_file_path="data/ftg/db/budget.toml"):
        """Initialize with the path to the budget.toml file"""
        self.decisions = {}
        self.load_budget_decisions(budget_file_path)

    def load_budget_decisions(self, file_path):
        """Load budget decisions data from the toml file"""
        try:
            path = Path(file_path)
            if not path.exists():
                raise FileNotFoundError(f"Budget file not found: {file_path}")

            with open(path, 'r', encoding='utf-8') as f:
                budget_data = toml.load(f)

            # Process each decision
            for decision_id, data in budget_data.items():
                if decision_id != 'document':  # Skip document metadata if present
                    self.decisions[decision_id] = BudgetDecision(decision_id, data)

            print(f"Loaded {len(self.decisions)} budget decisions")
        except Exception as e:
            print(f"Error loading budget decisions: {e}")
            self.decisions = {}

    def get_decision(self, decision_id):
        """Get a specific budget decision by ID"""
        return self.decisions.get(decision_id)

    def get_all_decisions(self):
        """Get all budget decisions"""
        return self.decisions

    def get_available_decisions(self, country):
        """Get decisions available to this country based on prerequisites"""
        available = {}

        for decision_id, decision in self.decisions.items():
            if decision.check_prerequisites(country):
                available[decision_id] = decision

        return available