"""
XCOM Unit Module: trait.py

Represents a trait of a unit, modifying stats and abilities.

Classes:
    TTrait: Base class for all unit traits (promotions, wounds, effects, etc.).

Last updated: 2025-06-14
"""

from typing import List, Optional
from unit.unit_stat import TUnitStats


class TTrait:
    """
    Represents a trait of a unit, which modifies stats or abilities.
    This is a virtual base class for all specific trait types.
    """

    # Class type constants
    TRAIT_PROMOTION = 0       # XCOM soldier promotion
    TRAIT_ENEMY_RANK = 1      # Enemy only ranks
    TRAIT_ORIGIN = 2          # Random career path when soldier is hired
    TRAIT_TRANSFORMATION = 3  # Soldier transformation during gameplay
    TRAIT_MEDAL = 4           # Special awards/medals
    TRAIT_WOUND = 5           # Permanent wounds from battle/events
    TRAIT_EFFECT = 6          # Temporary effects on battle like auras
    TRAIT_PERK = 7            # special one time added perk to unit on specific level

    def __init__(
        self,
        pid: str,
        name: str,
        sprite: str,
        description: str,
        type: int,
        stats: TUnitStats,
        cost: int,
        items_needed: List[str],
        races: List[str],
        min_level: int,
        max_level: int,
        services_needed: List[str],
        tech_needed: List[str],
        recovery_time: int,
        transfer_time: int,
        battle_duration: int,
        battle_effect: Optional[object],
        battle_chance_complete: int,
        battle_only: bool
    ):
        """
        Initialize a TTrait instance.

        Args:
            pid (str): Unique identifier for the trait.
            name (str): Display name.
            sprite (str): Sprite or image reference.
            description (str): Description of the trait.
            type (int): Trait type/category.
            stats (TUnitStats): Stat modifications provided by the trait.
            cost (int): Cost to acquire the trait.
            items_needed (List[str]): Items required to acquire the trait.
            races (List[str]): Races eligible for the trait.
            min_level (int): Minimum level required.
            max_level (int): Maximum level allowed.
            services_needed (List[str]): Required services for the trait.
            tech_needed (List[str]): Technologies required to unlock.
            recovery_time (int): Recovery time (for transformations).
            transfer_time (int): Transfer time (for transformations).
            battle_duration (int): Duration of battle effect.
            battle_effect (Optional[object]): Effect applied in battle.
            battle_chance_complete (int): Chance to complete effect in battle.
            battle_only (bool): Whether the trait is battle-only.
        """
        self.id: str = pid
        self.name: str = name
        self.sprite: str = sprite
        self.description: str = description
        self.type: int = type
        self.stats: TUnitStats = stats
        self.cost: int = cost
        self.items_needed: List[str] = items_needed
        self.races: List[str] = races
        self.min_level: int = min_level
        self.max_level: int = max_level
        self.services_needed: List[str] = services_needed
        self.tech_needed: List[str] = tech_needed
        self.recovery_time: int = recovery_time
        self.transfer_time: int = transfer_time
        self.battle_duration: int = battle_duration
        self.battle_effect: Optional[object] = battle_effect
        self.battle_chance_complete: int = battle_chance_complete
        self.battle_only: bool = battle_only

    def get_stat_modifiers(self) -> dict:
        """
        Returns a dictionary of stat modifiers provided by this trait.
        Override in subclasses or extend to provide modifiers.
        """
        # Return a shallow copy of all stat fields (explicit, not __dict__)
        if self.stats:
            return {
                'health': self.stats.health,
                'speed': self.stats.speed,
                'strength': self.stats.strength,
                'energy': self.stats.energy,
                'aim': self.stats.aim,
                'melee': self.stats.melee,
                'reflex': self.stats.reflex,
                'psi': self.stats.psi,
                'bravery': self.stats.bravery,
                'sanity': self.stats.sanity,
                'sight': self.stats.sight,
                'sense': self.stats.sense,
                'cover': self.stats.cover,
                'morale': self.stats.morale,
                'action_points': self.stats.action_points,
            }
        return {}

    # TODO create method to check if unit may get this trait

    # TODO get a list of origins traits when new unit is created

    # TODO get a list of promotions traits when unit is promoted, and which one is available

    # TODO get list of transformation traits when unit is transformed, which one are available
