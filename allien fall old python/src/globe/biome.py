"""
biome.py

Defines the TBiome class, representing a biome type assigned to each tile on the world map. Used to generate battles with specific terrain types and for world map analytics.

Classes:
    TBiome: Biome type for world map tiles.

Last standardized: 2025-06-30
"""

from typing import Dict, Optional, Union
import random


class TBiome:
    """
    TBiome represents a biome type assigned to each tile on the world map (e.g., forest, desert, ocean).
    Biomes are used to generate battles with specific terrain types.

    Attributes:
        pid (Union[str, int]): Unique biome identifier.
        name (str): Name of the biome.
        description (str): Description of the biome.
        image (Optional[str]): Sprite/image reference for the biome.
        type (str): Type of biome ('land', 'water', etc.).
        terrains (Dict[str, int]): Mapping of terrain keys to weights for random selection.
    """
    def __init__(self, pid: Union[str, int], name: str = '', description: str = '', image: Optional[str] = None, type_: str = 'land', terrains: Optional[Dict[str, int]] = None) -> None:
        self.pid: Union[str, int] = pid
        self.name: str = name
        self.description: str = description
        self.image: Optional[str] = image
        self.type: str = type_
        self.terrains: Dict[str, int] = terrains if terrains is not None else {}

    def get_random_terrain(self) -> Optional[str]:
        """
        Randomly select a terrain for this biome based on weights in self.terrains.

        Returns:
            Optional[str]: The selected terrain key, or None if no terrains defined.
        """
        if not self.terrains:
            return None
        terrain_keys = list(self.terrains.keys())
        weights = [self.terrains[k] for k in terrain_keys]
        return random.choices(terrain_keys, weights=weights, k=1)[0]
