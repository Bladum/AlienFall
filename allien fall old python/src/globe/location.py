"""
location.py

Defines the TLocation class, representing a single location on the world map (base, city, crash site, etc.). Handles radar detection, visibility, and cover mechanics for world map locations.

Classes:
    TLocation: World map location entity.

Last standardized: 2025-06-30
"""

from typing import TYPE_CHECKING
if TYPE_CHECKING:
    from globe.world_point import TWorldPoint

class TLocation:
    """
    TLocation represents a single location on the world map, such as a base, city, or UFO crash site.
    Locations may or may not be detected by XCOM, depending on radar coverage.

    Attributes:
        pid (str|int): Unique location identifier.
        name (str): Name of the location.
        description (str): Description of the location.
        position (TWorldPoint): Position of the location on the world map.
        initial_cover (int): Maximum cover value (for radar detection).
        cover (int): Current cover value.
        cover_change (int): Amount of cover recovered per turn.
        visible (bool): Whether the location is visible to the player.
    """
    def __init__(self, pid: str | int, name: str, description: str, position: 'TWorldPoint', initial_cover: int = 0, cover: int = 0, cover_change: int = 0) -> None:
        self.pid: str | int = pid
        self.name: str = name
        self.description: str = description
        self.position: 'TWorldPoint' = position
        self.initial_cover: int = initial_cover
        self.cover: int = cover if cover != 0 else initial_cover
        self.cover_change: int = cover_change
        self.visible: bool = False

    def update_visibility(self) -> None:
        """
        Update the visibility status of the location based on its cover value.
        """
        self.visible = self.cover <= 0

    def replenish_cover(self) -> None:
        """
        Replenish the cover value for the location by cover_change amount.
        """
        self.cover = min(self.initial_cover, self.cover + self.cover_change)

    def get_position(self) -> 'TWorldPoint':
        """
        Returns the position of the location as a TWorldPoint.
        """
        return self.position

    def distance_to(self, other: 'TLocation | TWorldPoint') -> float:
        """
        Returns the Euclidean distance to another TLocation or TWorldPoint.

        Args:
            other: TLocation or TWorldPoint.

        Returns:
            float: Euclidean distance.
        """
        if isinstance(other, TLocation):
            other = other.get_position()
        return self.position.distance_to(other)
