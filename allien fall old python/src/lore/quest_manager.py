"""
quest_manager.py

Defines the QuestManager class, which tracks quest and organization progress, unlocks new content, and provides progress metrics for the player. Used to manage the player's advancement through quests and organization levels.

Classes:
    QuestManager: Quest and organization progress tracker.

Last standardized: 2025-06-14
"""

from typing import Optional
from quest import TQuest
from organization import TOrganization

class QuestManager:
    """
    QuestManager tracks quest and organization progress, unlocks new content, and provides progress metrics.

    Attributes:
        quests (dict[str, TQuest]): All quests by key.
        organizations (dict[str, TOrganization]): All organizations by key.
        completed_techs (set[str]): Set of completed technologies.
        completed_quests (set[str]): Set of completed quests.
    """
    def __init__(self, quests_data: dict[str, dict], orgs_data: dict[str, dict], completed_techs: Optional[list[str]] = None) -> None:
        """
        Initialize the quest manager.

        Args:
            quests_data (dict[str, dict]): Quest data keyed by quest key.
            orgs_data (dict[str, dict]): Organization data keyed by org key.
            completed_techs (Optional[list[str]]): Completed technologies.
        """
        self.quests: dict[str, TQuest] = {k: TQuest(k, **v) for k, v in quests_data.items()}
        self.organizations: dict[str, TOrganization] = {k: TOrganization(k, **v) for k, v in orgs_data.items()}
        self.completed_techs: set[str] = set(completed_techs or [])
        self.completed_quests: set[str] = set()
        self.update_quests()
        self.update_organizations()

    def update_quests(self) -> None:
        """
        Update the status of all quests, marking them as completed if their requirements are met.
        """
        for quest in self.quests.values():
            if not quest.completed and quest.can_be_completed(self.completed_quests, self.completed_techs):
                quest.complete()
                self.completed_quests.add(quest.key)

    def update_organizations(self) -> None:
        """
        Update the status of all organizations, unlocking them if their requirements are met.
        """
        for org in self.organizations.values():
            if not org.unlocked and org.can_be_unlocked(self.completed_quests, self.completed_techs):
                org.unlock()

    def get_progress(self) -> tuple[int, int, float]:
        """
        Get the current progress of completed quests.

        Returns:
            tuple[int, int, float]: (completed_value, total_value, percent_complete)
        """
        total_value = sum(q.value for q in self.quests.values())
        completed_value = sum(q.value for q in self.quests.values() if q.completed)
        return completed_value, total_value, (completed_value / total_value * 100) if total_value else 0

    def unlock_new_content(self) -> None:
        """
        Update quests and organizations, unlocking any new content that is now available.
        """
        self.update_quests()
        self.update_organizations()

    def get_unlocked_organizations(self) -> list[TOrganization]:
        """
        Get a list of unlocked organizations.

        Returns:
            list[TOrganization]: Unlocked organizations.
        """
        return [org for org in self.organizations.values() if org.unlocked]

    def get_locked_organizations(self) -> list[TOrganization]:
        """
        Get a list of locked organizations.

        Returns:
            list[TOrganization]: Locked organizations.
        """
        return [org for org in self.organizations.values() if not org.unlocked]

    def __repr__(self) -> str:
        """
        String representation of the quest manager, showing progress summary.

        Returns:
            str: Progress summary string.
        """
        completed, total, percent = self.get_progress()
        return f"Quests: {len(self.completed_quests)}/{len(self.quests)} completed, Progress: {percent:.1f}%"
