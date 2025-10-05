
# src/managers/country_manager.py
class CountryManager:
    """Handles country-related operations."""

    def __init__(self, game_state):
        from core.game_state import GameState
        self.gs : GameState = game_state

    def process_before_all(self):
        print("  Country manager before processing")

        # Process countries
        for id, country in self.gs.countries.items():
            country.process_before_all()

    def create_country(self, country_id, name, color="#808080"):
        """Create a new country."""
        country = {
            "id": country_id,
            "name": name,
            "color": color
        }

        self.gs.countries[country_id] = country
        return country

    def get_owned_provinces(self, country_id):
        """Get all provinces owned by a country."""
        return {
            p_id: p for p_id, p in self.gs.provinces.items()
            if p["owner"] == country_id
        }