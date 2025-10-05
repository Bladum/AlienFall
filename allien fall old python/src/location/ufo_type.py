"""
XCOM Location Module: ufo_type.py

Defines the specifications and capabilities of a specific UFO class.

Classes:
    TUfoType: Represents alien craft stats, combat, detection, and deployment for world and tactical gameplay.

Last updated: 2025-06-14
"""

class TUfoType:
    """
    Represents the specifications and capabilities of a specific UFO class.
    """
    def __init__(self, pid: str, data: dict[str, object]):
        """
        Initialize a TUfoType instance.
        Args:
            pid (str): Unique identifier for the UFO type.
            data (dict): Dictionary with UFO type attributes.
        """
        self.pid: str = pid  # Unique identifier for the UFO type
        self.name: str = data.get('name', pid)  # Name of the UFO type
        self.pedia: str = data.get('pedia', '')  # Encyclopedia entry or description
        self.vessel: str = data.get('vessel', '')        # Image during dogfight
        self.marker: str = data.get('marker', 'alien')   # Image marker for geoscape visualization
        # Basic stats
        self.size: int = data.get('size', 1)  # Size of the UFO
        self.health: int = data.get('health', 50)  # Maximum health
        self.speed: int = data.get('speed', 0)  # Maximum speed
        self.shield: int = data.get('shield', 0)  # Shield value
        self.shield_regen: int = data.get('shield_regen', 0)  # Shield regeneration per turn
        # Combat capabilities
        self.damage: int = data.get('damage', 0)  # Weapon damage
        self.rate: int = data.get('rate', 0)  # Weapon fire rate
        self.range: int = data.get('range', 0)  # Weapon range
        self.accuracy: float = data.get('accuracy', 0.0)  # Weapon accuracy
        self.fire_sound: str = data.get('fire_sound', '')  # Sound played when firing
        # Radar properties
        self.radar_range: int = data.get('radar_range', 0)  # Radar detection range
        self.radar_power: int = data.get('radar_power', 0)  # Radar detection power
        self.radar_cover: int = data.get('radar_cover', 0)  # Radar cover value
        self.radar_cover_change: int = data.get('radar_cover_change', 0)  # Radar cover change per turn
        # Hunter capabilities
        self.is_hunter: bool = data.get('is_hunter', False)  # Whether the UFO hunts player craft
        self.hunt_bravery: float = data.get('hunt_bravery', 0.0)  # Aggressiveness in hunting
        self.bombard_power: int = data.get('bombard_power', 0)  # Bombardment power
        # Scoring
        self.score_complete: int = data.get('score_complete', 0)  # Score for completing mission
        self.score_destroy: int = data.get('score_destroy', 0)  # Score for destroying UFO
        self.score_avoid: int = data.get('score_avoid', 0)  # Score for avoiding UFO
        self.score_damage: int = data.get('score_damage', 0)  # Score for damaging UFO
        self.score_turn: int = data.get('score_turn', 0)  # Score per turn
        # Map generation
        self.map_block: str = data.get('map_block', '')  # Map block for tactical battle
        self.map_width: int = data.get('map_width', 0)  # Map width for tactical battle
        self.map_height: int = data.get('map_height', 0)  # Map height for tactical battle
        self.force_terrain: list = data.get('force_terrain', [])  # Forced terrain types
        # Deployments (alien units that can appear in this UFO)
        self.deployments: dict = data.get('deployments', {})
