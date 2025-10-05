"""
XCOM Unit Module: side.py

Represents a faction or side in the game (e.g., player, alien, civilian).

Classes:
    TSide: Identifies unit allegiance and determines combat relationships.

Last updated: 2025-06-14
"""
from typing import ClassVar

class TSide:
    """
    Represents a faction or side in the game (e.g., player, alien, civilian).
    Used to define unit ownership, allegiance, and combat relationships.
    """

    XCOM: ClassVar[int] = 0
    ALIEN: ClassVar[int] = 1
    CIVILIAN: ClassVar[int] = 2
    ALLIED: ClassVar[int] = 3
