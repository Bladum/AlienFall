"""
region.py

Defines the TRegion class, representing a region on the world map. Used for mission control, analytics, and region-based gameplay mechanics.

Classes:
    TRegion: Region entity for world map and mission control.

Last standardized: 2025-06-30
"""

from typing import TYPE_CHECKING, List, Dict, Optional, Union
if TYPE_CHECKING:
    from globe.world_tile import TWorldTile


class TRegion:
    """
    TRegion represents a region on the world map. Each tile is assigned to a region.
    Regions are used to control mission locations and provide analytics for score.

    Attributes:
        pid (Union[str, int]): Unique region identifier.
        name (str): Name of the region.
        is_land (bool): Whether the region is land.
        tiles (List[TWorldTile]): List of TWorldTile instances in the region.
        neighbors (List['TRegion']): List of neighboring TRegion instances.
        description (str): Description of the region.
        color (str): Color code for the region.
        mission_weight (int): Weight for mission generation.
        base_cost (int): Cost to build a base in this region.
        service_provided (List[str]): List of services provided.
        service_forbidden (List[str]): List of forbidden services.
    """

    def __init__(self, pid: Union[str, int], name: str = '', is_land: bool = False, description: str = '', color: str = '#000000', mission_weight: int = 10, base_cost: int = 500, service_provided: Optional[List[str]] = None, service_forbidden: Optional[List[str]] = None) -> None:
        self.pid: Union[str, int] = pid
        self.name: str = name
        self.is_land: bool = is_land
        self.tiles: List['TWorldTile'] = []
        self.neighbors: List['TRegion'] = []
        self.description: str = description
        self.color: str = color
        self.mission_weight: int = mission_weight
        self.base_cost: int = base_cost
        self.service_provided: List[str] = service_provided if service_provided is not None else []
        self.service_forbidden: List[str] = service_forbidden if service_forbidden is not None else []

    def calculate_region_tiles(self, tiles: List[List['TWorldTile']], width: int, height: int, region_neighbors: Dict[Union[str, int], List['TRegion']]) -> None:
        """
        Calculate and assign this region's tiles and neighbors.
        """
        region_tiles: List['TWorldTile'] = []
        for y in range(height):
            for x in range(width):
                tile = tiles[y][x]
                if tile.region and tile.region.pid == self.pid:
                    region_tiles.append(tile)
        self.tiles = region_tiles
        self.neighbors = region_neighbors.get(self.pid, [])
