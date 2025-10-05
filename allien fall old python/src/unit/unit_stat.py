"""
XCOM Unit Module: unit_stat.py

Represents a unit's stats and provides methods to manage them during the game.

Classes:
    TUnitStats: Handles health, energy, morale, action points, and other core stats for units.

Last updated: 2025-06-14
"""
from typing import Tuple

class TUnitStats:
    """
    Represents a unit's stats and provides methods to manage them during the game.
    """
    def __init__(
        self,
        health: int,
        speed: int,
        strength: int,
        energy: int,
        aim: int,
        melee: int,
        reflex: int,
        psi: int,
        bravery: int,
        sanity: int,
        sight: Tuple[int, int],
        sense: Tuple[int, int],
        cover: Tuple[int, int],
        morale: int,
        action_points: int,
        size: int,
        action_points_left: int,
        energy_left: int,
        hurt: int,
        stun: int,
        morale_left: int
    ):
        """
        Initialize a TUnitStats instance.
        Args:
            health (int): Max health.
            speed (int): Speed stat.
            strength (int): Strength stat.
            energy (int): Energy stat.
            aim (int): Aim stat.
            melee (int): Melee stat.
            reflex (int): Reflex stat.
            psi (int): Psi stat.
            bravery (int): Bravery stat.
            sanity (int): Sanity stat.
            sight (Tuple[int, int]): (day, night) sight.
            sense (Tuple[int, int]): (day, night) sense.
            cover (Tuple[int, int]): (day, night) cover.
            morale (int): Morale stat.
            action_points (int): Action points stat.
            size (int): Unit size.
            action_points_left (int): Current AP.
            energy_left (int): Current energy.
            hurt (int): Damage to health.
            stun (int): Damage to stun.
            morale_left (int): Current morale.
        """
        self.health: int = health
        self.speed: int = speed
        self.strength: int = strength
        self.energy: int = energy
        self.aim: int = aim
        self.melee: int = melee
        self.reflex: int = reflex
        self.psi: int = psi
        self.bravery: int = bravery
        self.sanity: int = sanity
        self.sight: Tuple[int, int] = sight
        self.sense: Tuple[int, int] = sense
        self.cover: Tuple[int, int] = cover
        self.morale: int = morale
        self.action_points: int = action_points
        self.size: int = size
        self.action_points_left: int = action_points_left
        self.energy_left: int = energy_left
        self.hurt: int = hurt
        self.stun: int = stun
        self.morale_left: int = morale_left

    # damage and status effects

    def receive_damage(self, dmg):
        """
        Apply hurt damage. If hurt >= health, unit dies.
        If hurt + stun >= health, unit loses consciousness.
        Returns (dead, unconscious)
        """
        self.hurt += dmg
        dead = self.hurt >= self.health
        unconscious = (self.hurt + self.stun) >= self.health
        if dead:
            self.hurt = self.health
        return dead, unconscious

    def receive_stun(self, stun):
        """
        Apply stun damage. If stun >= health, unit loses consciousness.
        If hurt + stun >= health, unit loses consciousness.
        Returns unconscious (bool)
        """
        self.stun += stun
        unconscious = (self.hurt + self.stun) >= self.health or self.stun >= self.health
        if self.stun > self.health:
            self.stun = self.health
        return unconscious

    # restoration methods

    def restore_health(self, amount):
        self.hurt = max(0, self.hurt - amount)

    def restore_stun(self, amount):
        self.stun = max(0, self.stun - amount)

    def restore_energy(self, amount):
        self.energy_left = min(self.energy, self.energy_left + amount)

    def restore_morale(self, amount):
        self.morale_left = min(self.morale, self.morale_left + amount)

    # action points management

    def use_ap(self, amount):
        self.action_points_left = max(0, self.action_points_left - amount)

    # new battle handling

    def new_game(self):
        self.morale_left = self.morale  # Reset morale to initial value
        self.action_points_left = self.action_points  # Reset action points to max
        self.hurt = 0  # Reset hurt to 0
        self.stun = 0  # Reset stun to 0
        self.energy_left = self.energy

    # new turn handling

    def new_turn(self):
        # Use effective AP based on morale/sanity
        self.action_points_left = self.get_effective_ap()
        self.restore_energy(self.energy / 4)  # Reset energy by 25% of base
        self.restore_stun(1)  # Reset hurt to max health

    def action_rest(self):
        # this action should cost 2 AP
        self.restore_energy(1)
        self.restore_stun(0.25)
        self.restore_morale(0.5)

    def get_effective_ap(self):
        """
        Returns the effective action points for the turn, reduced by low morale or sanity.
        If morale or sanity is 3 or lower, deduct 1 AP per missing point (from 4).
        The lowest value between morale and sanity is used for deduction.
        """
        penalty = 0
        for stat in [self.morale_left, self.sanity]:
            if stat <= 3:
                penalty = max(penalty, 4 - max(0, stat))
        effective_ap = max(0, self.action_points - penalty)
        return effective_ap

    # alive checks

    def is_alive(self):
        return self.hurt < self.health

    def is_conscious(self):
        return (self.hurt + self.stun) < self.health and self.stun < self.health

    # morale and sanity checks

    def is_panicked(self):
        return self.morale_left <= 0

    def is_crazy(self):
        return self.sanity <= 0

    # sight and sense handling

    def get_sight(self, is_day=True):
        if isinstance(self.sight, tuple):
            return self.sight[0] if is_day else self.sight[1]
        return self.sight

    def get_health_left(self):
        return max(0, self.health - self.hurt)

    def get_stun_left(self):
        return max(0, self.health - self.stun)

    def __add__(self, other):
        if not isinstance(other, TUnitStats):
            return NotImplemented
        data = {
            'health': self.health + other.health,
            'speed': self.speed + other.speed,
            'strength': self.strength + other.strength,
            'energy': self.energy + other.energy,
            'aim': self.aim + other.aim,
            'melee': self.melee + other.melee,
            'reflex': self.reflex + other.reflex,
            'psi': self.psi + other.psi,
            'bravery': self.bravery + other.bravery,
            'sanity': self.sanity + other.sanity,
            'sight': tuple(a + b for a, b in zip(self.sight, other.sight)),
            'sense': tuple(a + b for a, b in zip(self.sense, other.sense)),
            'cover': tuple(a + b for a, b in zip(self.cover, other.cover)),
            'morale': self.morale + other.morale,
            'action_points': self.action_points + other.action_points,
        }
        return TUnitStats(data)

    def sum_with(self, other):
        """
        Sums this object's stats with another TUnitStats and updates self.
        """
        summed = self + other
        self.__dict__.update(summed.__dict__)
        return self

    def __repr__(self):
        return f"<TUnitStats HP:{self.get_health_left()}/{self.health} Hurt:{self.hurt} Stun:{self.stun} AP:{self.action_points_left}/{self.action_points} Morale:{self.morale_left}/{self.morale}>"
