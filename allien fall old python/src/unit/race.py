"""
XCOM Unit Module: race.py

Represents a race/type of unit and its basic stats, abilities, and AI behavior.

Classes:
    TRace: Race template for unit creation and stat calculation.

Last updated: 2025-06-14
"""

from typing import Optional
from unit.unit_stat import TUnitStats


class TRace:
    """
    Represents a race (type of unit) and its basic stats, abilities, and AI behavior.
    Used as a template for unit creation and stat calculation.
    """

    def __init__(
        self,
        pid: str,
        name: str,
        description: str,
        sprite: str,
        is_big: bool,
        is_mechanical: bool,
        gain_experience: bool,
        health_regen: int,
        sound_death: Optional[str],
        corpse_image: Optional[str],
        stats: TUnitStats,
        aggression: float,
        intelligence: float,
        immune_panic: bool,
        immune_pain: bool,
        immune_bleed: bool,
        can_run: bool,
        can_kneel: bool,
        can_sneak: bool,
        can_surrender: bool,
        can_capture: bool,
        spawn_on_death: Optional[str],
        avoids_fire: bool,
        spotter: int,
        sniper: int,
        sell_cost: int,
        female_frequency: float,
        level_max: int,
        level_train: int,
        level_start: int,
    ):
        """
        Initialize a TRace instance.
        Args:
            pid (str): Race ID.
            name (str): Display name.
            description (str): Description of the race.
            sprite (str): Sprite or image reference.
            is_big (bool): Whether the race is large.
            is_mechanical (bool): Whether the race is mechanical.
            gain_experience (bool): Whether the race gains experience.
            health_regen (int): Health regeneration per turn.
            sound_death (Optional[str]): Death sound.
            corpse_image (Optional[str]): Corpse image reference.
            stats (TUnitStats): Base stats for the race.
            aggression (float): AI aggression.
            intelligence (float): AI intelligence.
            immune_panic (bool): Immune to panic.
            immune_pain (bool): Immune to pain.
            immune_bleed (bool): Immune to bleeding.
            can_run (bool): Can run.
            can_kneel (bool): Can kneel.
            can_sneak (bool): Can sneak.
            can_surrender (bool): Can surrender.
            can_capture (bool): Can be captured.
            spawn_on_death (Optional[str]): Spawned unit on death.
            avoids_fire (bool): Avoids fire.
            spotter (int): Spotter role.
            sniper (int): Sniper role.
            sell_cost (int): Sell cost.
            female_frequency (float): Female frequency.
            level_max (int): Max level.
            level_train (int): Training level.
            level_start (int): Starting level.
        """
        self.pid: str = pid
        self.name: str = name
        self.description: str = description
        self.sprite: str = sprite
        self.is_big: bool = is_big
        self.is_mechanical: bool = is_mechanical
        self.gain_experience: bool = gain_experience
        self.health_regen: int = health_regen
        self.sound_death: Optional[str] = sound_death
        self.corpse_image: Optional[str] = corpse_image
        self.stats: TUnitStats = stats
        self.aggression: float = aggression
        self.intelligence: float = intelligence
        self.immune_panic: bool = immune_panic
        self.immune_pain: bool = immune_pain
        self.immune_bleed: bool = immune_bleed
        self.can_run: bool = can_run
        self.can_kneel: bool = can_kneel
        self.can_sneak: bool = can_sneak
        self.can_surrender: bool = can_surrender
        self.can_capture: bool = can_capture
        self.spawn_on_death: Optional[str] = spawn_on_death
        self.avoids_fire: bool = avoids_fire
        self.spotter: int = spotter
        self.sniper: int = sniper
        self.sell_cost: int = sell_cost
        self.female_frequency: float = female_frequency
        self.level_max: int = level_max
        self.level_train: int = level_train
        self.level_start: int = level_start
