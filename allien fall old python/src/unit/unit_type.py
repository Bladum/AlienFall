"""
engine/unit/unit_type.py

Defines the TUnitType class, representing a type/template of unit with stats, race, traits, and equipment. Used as a template for creating units in the game, combining race, traits, and items.

Classes:
    TUnitType: Represents a type/template of unit with stats, race, traits, and equipment.

Last standardized: 2025-06-15
"""

import random
from typing import List, Optional, Tuple

from item.item_armour import TItemArmour
from item.item_weapon import TItemWeapon
from unit.side import TSide


class TUnitType:
    """
    Represents a type of unit with its stats.
    This is a combination of RACE, TRAITS, and ITEMS.
    Used as a template for units, not directly by the player.
    """

    def __init__(
        self,
        pid: str,
        name: str,
        race: str,
        sprite: str,
        rank: int,
        traits: List[str],
        armour: Optional[List[str]],
        primary: Optional[List[str]],
        secondary: Optional[List[List[str]]],
        score_dead: int,
        score_alive: int,
        items_dead: List[str],
        items_alive: List[str],
        ai_ignore: bool,
        vip: bool,
        drop_items: bool,
        drop_armour: bool,
    ):
        """
        Initialize a TUnitType instance.
        Args:
            pid (str): Unique identifier for the unit type.
            name (str): Display name.
            race (str): Race identifier.
            sprite (str): Sprite or image reference.
            rank (int): Rank value.
            traits (List[str]): List of trait identifiers.
            armour (Optional[List[str]]): Armour configuration.
            primary (Optional[List[str]]): Primary weapon configuration.
            secondary (Optional[List[List[str]]]): Secondary weapon configuration.
            score_dead (int): Score for killing this unit.
            score_alive (int): Score for capturing this unit alive.
            items_dead (List[str]): Items dropped on death.
            items_alive (List[str]): Items dropped if alive.
            ai_ignore (bool): AI ignore flag.
            vip (bool): VIP flag.
            drop_items (bool): Drop items on death flag.
            drop_armour (bool): Drop armour on death flag.
        """
        self.pid: str = pid
        self.name: str = name
        self.race: str = race
        self.sprite: str = sprite
        self.rank: int = rank
        self.traits: List[str] = traits
        self.armour: Optional[List[str]] = armour
        self.primary: Optional[List[str]] = primary
        self.secondary: Optional[List[List[str]]] = secondary
        self.score_dead: int = score_dead
        self.score_alive: int = score_alive
        self.items_dead: List[str] = items_dead
        self.items_alive: List[str] = items_alive
        self.ai_ignore: bool = ai_ignore
        self.vip: bool = vip
        self.drop_items: bool = drop_items
        self.drop_armour: bool = drop_armour

    @staticmethod
    def create_unit_from_template(unit_type: str, player: TSide):
        """
        Create a unit instance based on this type
        """

        from engine.game import TGame

        game = TGame()

        # basic unit type
        unit_type = game.mod.units.get(unit_type)
        if unit_type is None:
            return None

        # create basic unit

        from unit.unit import TUnit

        unit = TUnit(unit_type, player)

        # assign race

        unit.race = game.mod.races.get(unit_type.race)

        # assign armour

        armour_name = unit_type.armour
        armour_selected = random.choice(armour_name)
        armour = game.mod.items.get(armour_selected)
        if armour:
            unit.armour = TItemArmour(armour.name)

        # assign primary weapons

        primary_name = unit_type.primary
        primary_selected = random.choice(primary_name)
        prim_weapon = game.mod.items.get(primary_selected)
        if prim_weapon:
            unit.weapon = TItemWeapon(prim_weapon.name)

        # assign secondary weapons
        # this supposed to be list of lists to choose from

        unit.equipment.clear()
        secondary_names_list = unit_type.secondary
        for secondary_name in secondary_names_list:
            secondary_selected = random.choice(secondary_name)
            second_weapon = game.mod.items.get(secondary_selected)
            if second_weapon:
                unit.equipment.append(TItemWeapon(second_weapon.name))

        # assign traits

        unit.traits.clear()  # Clear existing traits if any
        traits = unit_type.traits
        for trait_name in traits:
            trait = game.mod.traits.get(trait_name)
            if trait:
                unit.traits.append(trait)

        return unit
