"""
organization.py

Defines the TOrganization class, representing a player organization level. Encapsulates unlock requirements, quest dependencies, and progression logic for organizations in the game.

Classes:
    TOrganization: Player organization level definition.

Last standardized: 2025-06-14
"""

from typing import Any

class TOrganization:
    """
    TOrganization represents a player organization level.
    Each level has its own name, description, icon, pedia, and quests.
    Prerequisites (tech/quests) are required to unlock the next level.

    Attributes:
        key (str): Organization key.
        name (str): Organization name.
        description (str): Description of the organization level.
        sprite (str): Icon or sprite for the organization.
        pedia (str): Encyclopedia entry.
        quests (List[str]): Quests associated with this level.
        quests_needed (List[str]): Quests required to unlock this level.
        tech_needed (List[str]): Technologies required to unlock this level.
        unlocked (bool): Whether the organization is unlocked.
    """
    key: str
    name: str
    description: str
    sprite: str
    pedia: str
    quests: list[str]
    quests_needed: list[str]
    tech_needed: list[str]
    unlocked: bool

    def __init__(self, key: str, data: dict[str, str | list[str]] = None) -> None:
        """
        Initialize an organization level.

        Args:
            key (str): Organization key.
            data (dict[str, str | list[str]]): Organization data and parameters.
        """
        data = data or {}
        self.key = key
        self.name = data.get('name', '')
        self.description = data.get('description', '')
        self.sprite = data.get('sprite', '')
        self.pedia = data.get('pedia', '')
        self.quests = data.get('quests', [])
        self.quests_needed = data.get('quests_needed', [])
        self.tech_needed = data.get('tech_needed', [])
        self.unlocked = False

    def can_be_unlocked(self, completed_quests: set[str], completed_techs: set[str]) -> bool:
        """
        Check if the organization can be unlocked based on completed quests and technologies.

        Args:
            completed_quests (set[str]): Set of completed quest keys.
            completed_techs (set[str]): Set of completed technology keys.
        Returns:
            bool: True if organization can be unlocked, False otherwise.
        """
        return all(q in completed_quests for q in self.quests_needed) and \
               all(t in completed_techs for t in self.tech_needed)

    def unlock(self) -> None:
        """
        Unlock the organization.
        """
        self.unlocked = True

    def __repr__(self) -> str:
        """
        String representation of the organization.
        Returns:
            str: Representation string.
        """
        return f"<TOrganization {self.key} ({'Unlocked' if self.unlocked else 'Locked'})>"
