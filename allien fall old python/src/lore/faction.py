"""
XCOM Lore Module: faction.py

Defines a faction in the game, with properties, relationships, and requirements.

Classes:
    TFaction: Faction definition for the game.

Last updated: 2025-06-14
"""

from typing import Any

class TFaction:
    """
    Represents a faction in the game, which can own missions and locations. May be ally or enemy of XCOM.

    Attributes:
        pid (str): Faction identifier.
        name (str): Faction name.
        description (str): Faction description.
        id (int): Faction numeric ID.
        aggression (int): Aggression level.
        pedia (str): Encyclopedia entry.
        sprite (str): Faction icon or sprite.
        tech_start (List[str]): Technologies required to start.
        tech_end (List[str]): Technologies that end the faction's activity.
    """
    pid: str
    name: str
    description: str
    id: int
    aggression: int
    pedia: str
    sprite: str
    tech_start: list[str]
    tech_end: list[str]

    def __init__(self, pid: str, data: dict[str, str | int | list[str]] = {}) -> None:
        """
        Initialize a faction.

        Args:
            pid (str): Faction identifier.
            data (dict[str, str | int | list[str]]): Faction data and parameters.
        """
        self.pid = pid
        self.name = data.get("name", "")
        self.description = data.get("description", "")
        self.id = data.get("id", 0)
        self.aggression = data.get("aggression", 0)
        self.pedia = data.get("pedia", '')
        self.sprite = data.get("sprite", '')
        self.tech_start = data.get("tech_start", [])
        self.tech_end = data.get("tech_end", [])