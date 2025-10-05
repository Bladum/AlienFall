"""
XCOM Unit Module: unit.py

Represents an individual unit in the game with all its attributes and capabilities.

Classes:
    TUnit: Handles unit stats, equipment, traits, and status for gameplay.

Last updated: 2025-06-14
"""

from typing import List, Tuple
from item.item_armour import TItemArmour
from item.item_weapon import TItemWeapon
from unit.trait import TTrait
from unit.race import TRace
from unit.side import TSide
from unit.unit_stat import TUnitStats
from unit.unit_type import TUnitType
from unit.unit_inv_manager import TUnitInventoryManager


class TUnit:
    """
    Represents an individual unit in the game with all its attributes and capabilities.
    Handles stats, equipment, traits, and status for gameplay.
    """

    def __init__(
        self,
        unit_type: TUnitType,
        side_id: int,
        name: str,
        nationality: str,
        face: str,
        female: bool,
        stats: TUnitStats,
        race: TRace,
        traits: List[TTrait],
        inventory_manager: TUnitInventoryManager,
        inventory: List[TItemArmour | TItemWeapon],
        position: Tuple[int, int],
        direction: int,
        alive: bool,
        dead: bool,
        mind_controlled: bool,
        panicked: bool,
        crazy: bool,
        stunned: bool,
        kneeling: bool,
        running: bool,
        experience: int,
        level: int,
        trait_points: int,
    ):
        """
        Initialize a TUnit instance.

        Args:
            unit_type (TUnitType): The unit type template.
            side_id (int): Faction/side identifier.
            name (str): Unit name.
            nationality (str): Nationality string.
            face (str): Face/sprite reference.
            female (bool): Gender flag.
            stats (TUnitStats): Unit stats.
            race (TRace): Racial template.
            traits (List[TTrait]): List of traits.
            inventory_manager (TUnitInventoryManager): Equipment manager.
            inventory (List[TItemArmour | TItemWeapon]): List of equipped items.
            position (Tuple[int, int]): Map position.
            direction (int): Facing direction.
            alive (bool): Alive status.
            dead (bool): Dead status.
            mind_controlled (bool): Mind control status.
            panicked (bool): Panic status.
            crazy (bool): Insanity status.
            stunned (bool): Stun status.
            kneeling (bool): Kneeling status.
            running (bool): Running status.
            experience (int): Total experience collected.
            level (int): Current level (starts at 1).
            trait_points (int): Points to spend on new traits.
        """

        self.unit_type: TUnitType = unit_type
        self.side_id: int = side_id
        self.name: str = name
        self.nationality: str = nationality
        self.face: str = face
        self.female: bool = female
        self.stats: TUnitStats = stats
        self.race: TRace = race
        self.traits: List[TTrait] = traits
        self.inventory_manager: TUnitInventoryManager = inventory_manager
        self.inventory: List[TItemArmour | TItemWeapon] = inventory
        self.position: Tuple[int, int] = position
        self.direction: int = direction
        self.alive: bool = alive
        self.dead: bool = dead
        self.mind_controlled: bool = mind_controlled
        self.panicked: bool = panicked
        self.crazy: bool = crazy
        self.stunned: bool = stunned
        self.kneeling: bool = kneeling
        self.running: bool = running
        self.experience: int = experience
        self.level: int = level
        self.trait_points: int = trait_points

    @property
    def armour(self) -> TItemArmour:
        """Get the unit's equipped armor"""
        return self.inventory_manager.equipment_slots.get("Armor")

    @property
    def weapon(self) -> TItemWeapon:
        """Get the unit's primary weapon"""
        return self.inventory_manager.equipment_slots.get("Primary")

    @property
    def equipment(self) -> list[TItemArmour | TItemWeapon]:
        """Get all equipped items as a list"""
        return [item for item in self.inventory_manager.equipment_slots.values() if item]

    def calculate_stats(self) -> TUnitStats:
        # Use stats calculated from inventory manager
        base_stats = self.race.stats.copy()

        # Apply traits modifiers
        for trait in self.traits:
            base_stats = base_stats + trait.stats

        # Get all stat modifiers from equipment through inventory manager
        for slot_name, modifiers in self.inventory_manager.stat_modifiers.items():
            for stat_name, modifier in modifiers.items():
                # Direct attribute access, assume stat_name is always valid
                exec(f"base_stats.{stat_name} += {modifier}")

        return base_stats

    def collect_experience(self, amount: float) -> None:
        """
        Add experience to the unit and check for level up.
        Applies trait modifiers: 'smart' (+25%), 'dumb' (-25%).
        """
        if amount <= 0:
            return
        bonus = 1.0
        trait_names = [str(trait).lower() for trait in self.traits]
        if "smart" in trait_names:
            bonus += 0.25
        if "dumb" in trait_names:
            bonus -= 0.25
        xp_gain = amount * bonus
        self.experience += xp_gain
        self.check_level_up()

    def get_level(self) -> int:
        """
        Return the unit's level based on experience thresholds (up to level 10).
        """
        xp = self.experience
        if xp < 100:
            return 1
        elif xp < 300:
            return 2
        elif xp < 600:
            return 3
        elif xp < 1000:
            return 4
        elif xp < 1500:
            return 5
        elif xp < 2100:
            return 6
        elif xp < 2800:
            return 7
        elif xp < 3600:
            return 8
        elif xp < 4500:
            return 9
        else:
            return 10

    def check_level_up(self) -> None:
        """
        Check if the unit has leveled up and grant trait points if so.
        """
        new_level = self.get_level()
        if new_level > self.level:
            gained = new_level - self.level
            self.trait_points += gained  # 1 point per new level
            self.level = new_level

    def can_gain_trait(self) -> bool:
        """
        Return True if the unit has trait points to spend.
        """
        return self.trait_points > 0

    def gain_trait(self, trait: TTrait) -> bool:
        """
        Spend a trait point to gain a new trait. Returns True if successful.
        """
        if self.can_gain_trait() and trait not in self.traits:
            self.traits.append(trait)
            self.trait_points -= 1
            return True
        return False
