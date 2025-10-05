"""
radar.py

Defines the TGlobalRadar class, which manages radar detection of UFOs and locations on the world map. Handles radar scanning from bases and crafts, updating cover and visibility for all locations.

Classes:
    TGlobalRadar: Global radar detection manager.

Last standardized: 2025-06-30
"""

from typing import TYPE_CHECKING, List
from globe.world_point import TWorldPoint
if TYPE_CHECKING:
    from globe.world import TWorld
    from globe.location import TLocation
    from base.xbase import XBase
    from craft.craft import TCraft

class TGlobalRadar:
    """
    TGlobalRadar manages radar detection of UFOs and locations on the world map.

    Attributes:
        world (TWorld): TWorld instance representing the world map.
    """
    def __init__(self, world: 'TWorld') -> None:
        """
        Initialize a TGlobalRadar instance.

        Args:
            world (TWorld): TWorld instance.
        """
        self.world: 'TWorld' = world

    def scan(self, locations: List['TLocation'], bases: List['XBase'], crafts: List['TCraft']) -> None:
        """
        Perform radar scan from all bases and crafts, update cover and visibility for all locations.

        Args:
            locations (List[TLocation]): List of TLocation instances.
            bases (List[XBase]): List of XCOM base objects (must provide get_radar_facilities()).
            crafts (List[TCraft]): List of XCOM craft objects (must provide radar_power, radar_range, and position).
        """
        # 1. Scan from bases
        for base in bases:
            radar_list = base.get_radar_facilities()  # Each should have .power and .range
            base_pos = TWorldPoint.from_iterable(base.position)
            for radar in radar_list:
                for loc in locations:
                    if loc.name.startswith('XCOM'):
                        continue
                    if not loc.position:
                        continue
                    loc_pos = TWorldPoint.from_iterable(loc.position)
                    if base_pos.tile_distance(loc_pos) <= radar.range:
                        loc.cover = max(0, loc.cover - radar.power)
                        loc.update_visibility()

        # 2. Scan from crafts
        for craft in crafts:
            if not craft.is_on_world():
                continue
            craft_pos = TWorldPoint.from_iterable(craft.position)
            radar_power = craft.radar_power
            radar_range = craft.radar_range
            for loc in locations:
                if loc.name.startswith('XCOM'):
                    continue
                if not loc.position:
                    continue
                loc_pos = TWorldPoint.from_iterable(loc.position)
                if craft_pos.tile_distance(loc_pos) <= radar_range:
                    loc.cover = max(0, loc.cover - radar_power)
                    loc.update_visibility()

        # 3. Replenish cover for all locations
        for loc in locations:
            loc.replenish_cover()
