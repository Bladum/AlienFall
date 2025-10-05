"""
country.py

Defines the TCountry class, representing a country on the world map. Manages funding, relations with XCOM, and country-specific properties for world map analytics and gameplay.

Classes:
    TCountry: Country entity for world map and funding system.

Last standardized: 2025-06-30
"""

from typing import TYPE_CHECKING, List, Tuple, Union
if TYPE_CHECKING:
    from globe.world_tile import TWorldTile

class TCountry:
    """
    TCountry represents a country that owns tiles on the world map.
    The country's score is used to calculate XCOM's funding, and countries can join or leave XCOM.

    Attributes:
        pid (Union[str, int]): Unique country identifier.
        name (str): Name of the country.
        description (str): Description of the country.
        color (str): Color code for the country.
        funding (int): Current funding provided by the country.
        funding_cap (int): Maximum funding the country can provide.
        service_provided (List[str]): List of services provided.
        service_forbidden (List[str]): List of forbidden services.
        owned_tiles (List[Tuple[int, int]]): List of (x, y) tuples owned by the country.
        initial_relation (int): Initial relation value.
        relation (int): Current relation value.
        active (bool): Whether the country is still funding XCOM.
    """
    def __init__(self, pid: Union[str, int], name: str = '', description: str = '', color: str = '#000000', funding: int = 10, funding_cap: int = 500, service_provided: List[str] = None, service_forbidden: List[str] = None, owned_tiles: List[Tuple[int, int]] = None, initial_relation: int = 5) -> None:
        self.pid: Union[str, int] = pid
        self.name: str = name
        self.description: str = description
        self.color: str = color
        self.funding: int = funding
        self.funding_cap: int = funding_cap
        self.service_provided: List[str] = service_provided if service_provided is not None else []
        self.service_forbidden: List[str] = service_forbidden if service_forbidden is not None else []
        self.owned_tiles: List[Tuple[int, int]] = owned_tiles if owned_tiles is not None else []
        self.initial_relation: int = initial_relation
        self.relation: int = self.initial_relation
        self.active: bool = True

    def monthly_update(self, month_score: int) -> None:
        """
        Update relation and funding based on monthly score.
        Args:
            month_score (int): Sum of mission results on this country's tiles.
        """
        import random
        if not self.active:
            self.funding = 0
            return
        if month_score > 0:
            chance = min(1.0, (month_score / 1000.0))
            if random.random() < chance:
                self.relation = min(9, self.relation + 1)
        elif month_score < 0:
            chance = min(1.0, (abs(month_score) / 500.0))
            if random.random() < chance:
                self.relation = max(0, self.relation - 1)
        if self.relation > 5:
            increase = (self.relation - 5) * 0.05
            self.funding = min(self.funding_cap, int(self.funding * (1 + increase)))
            self.funding = max(self.funding, self.funding_cap)
        elif self.relation < 5:
            decrease = (5 - self.relation) * 0.05
            self.funding = max(0, int(self.funding * (1 - decrease)))
        if self.relation == 0:
            self.active = False
            self.funding = 0
        if self.relation > 0 and self.funding < 0:
            self.funding = 0

    def add_tile(self, tile_pos: Tuple[int, int]) -> None:
        """
        Add a tile to the country's owned tiles.
        Args:
            tile_pos (Tuple[int, int]): (x, y) position.
        """
        if tile_pos not in self.owned_tiles:
            self.owned_tiles.append(tile_pos)

    def remove_tile(self, tile_pos: Tuple[int, int]) -> None:
        """
        Remove a tile from the country's owned tiles.
        Args:
            tile_pos (Tuple[int, int]): (x, y) position.
        """
        if tile_pos in self.owned_tiles:
            self.owned_tiles.remove(tile_pos)

    def calculate_owned_tiles(self, tiles: List[List['TWorldTile']]) -> None:
        """
        Calculate and assign this country's owned tiles based on the world tile grid.
        Args:
            tiles (List[List[TWorldTile]]): 2D array of TWorldTile.
        """
        self.owned_tiles = []
        if tiles is None:
            return
        for row in tiles:
            for tile in row:
                if tile.country and tile.country.pid == self.pid:
                    self.owned_tiles.append((tile.x, tile.y))