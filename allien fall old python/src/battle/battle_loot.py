"""
BattleLoot: Handles post-battle report generation, including loot, score, captures, experience, sanity, ammo, medals, and more.

Provides static methods to generate a summary report after a battle, aggregating all relevant statistics and rewards for the player.

Classes:
    BattleLoot: Main class for post-battle report and loot calculation.

Last standardized: 2025-06-22 (typing enforced)
"""

from typing import TYPE_CHECKING

class BattleLoot:
    """
    Handles post-battle report, loot, score, captures, experience, sanity, ammo, medals, etc.
    Usage: BattleLoot.generate(battle) -> dict[str, int | dict | list]
    """
    @staticmethod
    def generate(battle) -> dict[str, int | dict | list]:
        """
        Generate a post-battle report summarizing score, loot, captures, experience, sanity, ammo, and medals.
        Args:
            battle: Battle object containing all relevant data.
        Returns:
            dict[str, int | dict | list]: Report with keys 'score', 'loot', 'captures', 'experience', 'sanity', 'ammo', 'medals'.
        """
        report: dict[str, int | dict | list] = {}
        report['score'] = BattleLoot._calculate_score(battle)
        report['loot'] = BattleLoot._collect_loot(battle)
        report['captures'] = BattleLoot._collect_captures(battle)
        report['experience'] = BattleLoot._calculate_experience(battle, side=battle.SIDE_PLAYER)
        report['sanity'] = BattleLoot._calculate_sanity(battle, side=battle.SIDE_PLAYER)
        report['ammo'] = BattleLoot._calculate_ammo(battle, side=battle.SIDE_PLAYER)
        report['medals'] = BattleLoot._calculate_medals(battle, side=battle.SIDE_PLAYER)
        return report

    @staticmethod
    def _calculate_score(battle) -> int:
        """
        Calculate the total score for the battle based on objectives, unit status, and other factors.
        Args:
            battle: Battle object.
        Returns:
            int: Total score value.
        """
        score: int = 0
        for obj in battle.objectives:
            obj_score = obj.params['score'] if 'score' in obj.params else 0
            obj_penalty = obj.params['penalty'] if 'penalty' in obj.params else 0
            if obj.status == 'complete':
                score += obj_score
            elif obj.status == 'failed':
                score -= obj_penalty
        for unit in battle.find_units(side=battle.SIDE_ENEMY, alive=False):
            score += unit.score_kill
        for unit in battle.find_units(side=battle.SIDE_ENEMY, alive=True):
            if unit.is_stunned or unit.is_surrendered:
                score += unit.score_capture
        for obj in battle.find_objects():
            score += obj.score_loot
        for unit in battle.find_units(side=battle.SIDE_PLAYER, alive=False):
            score -= unit.score_loss
        for side in [battle.SIDE_ALLY, battle.SIDE_NEUTRAL]:
            for unit in battle.find_units(side=side, alive=False):
                score -= unit.score_loss
        for y, row in enumerate(battle.tiles):
            for x, tile in enumerate(row):
                if tile.wall and tile.wall.is_destroyed:
                    score -= tile.wall.score_loss
        return score

    @staticmethod
    def _collect_loot(battle) -> dict[str, int]:
        """
        Collect all loot obtained during the battle.
        Args:
            battle: Battle object.
        Returns:
            dict[str, int]: Dictionary of loot item ids and their counts.
        """
        loot: dict[str, int] = {}
        for obj in battle.find_objects():
            obj_id = obj.id
            if obj_id:
                loot[obj_id] = loot.get(obj_id, 0) + 1
        return loot

    @staticmethod
    def _collect_captures(battle) -> dict[str, int]:
        """
        Collect all captured units or objects during the battle.
        Args:
            battle: Battle object.
        Returns:
            dict[str, int]: Dictionary of captured entity ids and their counts.
        """
        captures: dict[str, int] = {}
        for unit in battle.find_units(side=battle.SIDE_ENEMY, alive=True):
            if unit.is_stunned or unit.is_surrendered:
                unit_id = unit.id
                if unit_id:
                    captures[unit_id] = captures.get(unit_id, 0) + 1
        return captures

    @staticmethod
    def _calculate_experience(battle, side) -> dict[str, int]:
        """
        Calculate experience gained by a given side during the battle.
        Args:
            battle: Battle object.
            side: Side identifier (e.g., player, enemy).
        Returns:
            dict[str, int]: Dictionary of unit ids and experience gained.
        """
        exp: dict[str, int] = {}
        for unit in battle.find_units(side=side):
            exp[unit.id] = unit.experience_gained
        return exp

    @staticmethod
    def _calculate_sanity(battle, side) -> dict[str, int]:
        """
        Calculate sanity changes for a given side during the battle.
        Args:
            battle: Battle object.
            side: Side identifier.
        Returns:
            dict[str, int]: Dictionary of unit ids and sanity lost.
        """
        sanity: dict[str, int] = {}
        for unit in battle.find_units(side=side):
            sanity[unit.id] = unit.sanity_lost
        return sanity

    @staticmethod
    def _calculate_ammo(battle, side) -> dict[str, int]:
        """
        Calculate remaining or used ammo for a given side during the battle.
        Args:
            battle: Battle object.
            side: Side identifier.
        Returns:
            dict[str, int]: Dictionary of item ids and ammo used.
        """
        ammo: dict[str, int] = {}
        for unit in battle.find_units(side=side):
            for item in unit.inventory:
                ammo[item.id] = ammo.get(item.id, 0) + item.ammo_used
        return ammo

    @staticmethod
    def _calculate_medals(battle, side) -> dict[str, list]:
        """
        Calculate medals or awards earned by a given side during the battle.
        Args:
            battle: Battle object.
            side: Side identifier.
        Returns:
            dict[str, list]: Dictionary of unit ids and medals earned.
        """
        medals: dict[str, list] = {}
        for unit in battle.find_units(side=side):
            medals[unit.id] = unit.medals_earned
        return medals
