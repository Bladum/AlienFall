"""
XCOM Lore Module: event.py

Defines a game event that can affect the player, trigger missions, and modify game state.

Classes:
    TEvent: Game event definition.

Last updated: 2025-06-14
"""

from typing import Any

class TEvent:
    """
    Represents an event in the game that can affect the player or trigger missions.

    Attributes:
        pid (str): Event identifier.
        name (str): Event name.
        description (str): Event description.
        sprite (str): Event icon or sprite.
        tech_needed (list): Technologies required for event to occur.
        regions (list): Regions where event can occur.
        is_city (bool): Whether event is city-specific.
        month_start (int): First month event can occur.
        month_random (int): Random month offset.
        month_end (int): Last month event can occur.
        qty_max (int): Maximum occurrences.
        chance (float): Probability of event.
        score (int): Score awarded by event.
        funds (int): Funds awarded by event.
        items (list): Items granted by event.
        units (list): Units granted by event.
        crafts (list): Crafts granted by event.
        facilities (list): Facilities granted by event.
        ufos (list): UFO missions created by event.
        sites (list): Static sites created by event.
        bases (list): Alien bases created by event.
    """
    def __init__(self, pid: str, data: dict[str, Any]) -> None:
        """
        Initialize a game event.

        Args:
            pid (str): Event identifier.
            data (dict[str, Any]): Event data and parameters.
        """
        self.pid: str = pid
        self.name: str = data.get('name', pid)
        self.description: str = data.get('description', '')
        self.sprite: str = data.get('sprite', '')
        # Preconditions
        self.tech_needed: list[str] = data.get('tech_needed', [])
        self.regions: list[str] = data.get('regions', [])
        self.is_city: bool = data.get('is_city', False)
        # Timing
        self.month_start: int = data.get('month_start', 0)
        self.month_random: int = data.get('month_random', 0)
        self.month_end: int = data.get('month_end', 9999)
        # Occurrence limits
        self.qty_max: int = data.get('qty_max', 1)
        self.chance: float = data.get('chance', 1.0)
        # Effects added
        self.score: int = data.get('score', 0)
        self.funds: int = data.get('funds', 0)
        # Items and units added
        self.items: list[str] = data.get('items', [])
        self.units: list[str] = data.get('units', [])
        self.crafts: list[str] = data.get('crafts', [])
        self.facilities: list[str] = data.get('facilities', [])
        # Missions created
        self.ufos: list[str] = data.get('ufos', [])
        self.sites: list[str] = data.get('sites', [])
        self.bases: list[str] = data.get('bases', [])
