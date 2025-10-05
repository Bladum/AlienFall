"""
TWorldTile: Represents a single tile on the world map.
Each tile is assigned to a region, may belong to a country, and has a biome.
May also have one or more locations (e.g., cities, bases, crash sites).

Classes:
    TWorldTile: Main class for world map tiles.

Last standardized: 2025-06-30
"""

from typing import TYPE_CHECKING, List, Optional, Union
if TYPE_CHECKING:
    from globe.region import TRegion
    from globe.country import TCountry
    from globe.biome import TBiome
    from globe.location import TLocation


class TWorldTile:
    """
    Represents a single tile on the world map.
    Each tile is assigned to a region, may belong to a country, and has a biome.
    May also have one or more locations (e.g., cities, bases, crash sites).

    Attributes:
        x (int): X coordinate of the tile.
        y (int): Y coordinate of the tile.
        region (Optional[TRegion]): Region object for this tile.
        country (Optional[TCountry]): Country object for this tile.
        biome (Optional[TBio me]): Biome object for this tile.
        locations (List[TLocation]): List of location objects present on this tile.
    """
    def __init__(self, x: int, y: int, region: Optional['TRegion'] = None, country: Optional['TCountry'] = None, biome: Optional['TBiome'] = None, locations: Optional[List['TLocation']] = None) -> None:
        """
        Initialize a TWorldTile instance.

        Args:
            x (int): X coordinate of the tile.
            y (int): Y coordinate of the tile.
            region (Optional[TRegion]): Region object for this tile.
            country (Optional[TCountry]): Country object for this tile.
            biome (Optional[TBio me]): Biome object for this tile.
            locations (Optional[List[TLocation]]): List of location objects present on this tile.
        """
        self.x: int = x
        self.y: int = y
        self.region: Optional['TRegion'] = region
        self.country: Optional['TCountry'] = country
        self.biome: Optional['TBiome'] = biome
        self.locations: List['TLocation'] = locations if locations is not None else []

    def __repr__(self) -> str:
        """
        Return a string representation of the TWorldTile instance.

        Returns:
            str: Informal string representation of the TWorldTile instance,
            including x, y, region, country, biome, and locations.
        """
        return (f"TWorldTile(x={self.x}, y={self.y}, region={self.region}, "
                f"country={self.country}, biome={self.biome}, locations={self.locations})")
