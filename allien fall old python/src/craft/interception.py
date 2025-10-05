"""
interception.py

Defines the TInterception class, which implements the interception combat mechanics for XCOM crafts and UFOs. Manages dogfighting, action points, hit/damage/evasion calculations, and turn-based combat flow.

Classes:
    TInterception: Interception combat system for XCOM crafts and UFOs.

Last standardized: 2025-06-14
"""

import random
from typing import List
from craft.craft import TCraft
from craft.craft_type import TCraftType
from item.craft_item import TCraftItem
from location.ufo import TUfo


class TInterception:
    """
    Handles the interception combat mechanics between XCOM craft and UFOs.

    Manages dogfighting, action points, hit/damage/evasion calculations, and turn-based combat flow.

    Attributes:
        crafts (List[TCraft | TUfo]): List containing the XCOM craft and the UFO.
        distance (int): Current distance between crafts (in km).
        turn (int): Current turn number.
        ap (List[int]): Action points for each craft per turn.
        log (List[str]): Combat log messages.
        crashed (List[bool]): Crash status for each craft.
    """
    def __init__(self, craft1: TCraft, ufo1: TUfo, distance: int = 100):
        """
        Initialize a new interception combat instance.

        Args:
            craft1 (TCraft): The XCOM craft.
            ufo1 (TUfo): The UFO.
            distance (int): Initial distance between crafts (km).
        """
        from engine.game import TGame
        self.game = TGame()
        self.crafts: List[TCraft | TUfo] = [craft1, ufo1]
        self.distance: int = distance
        self.turn: int = 0
        self.ap: List[int] = [4, 4]
        self.log: List[str] = []
        self.crashed: List[bool] = [False, False]

    def get_state(self) -> dict:
        """
        Get the current state of the interception.

        Returns:
            dict: State including distance, crafts, AP, turn, and crash status.
        """
        return {
            'distance': self.distance,
            'crafts': [self._craft_state(c) for c in self.crafts],
            'ap': self.ap[:],
            'turn': self.turn,
            'crashed': self.crashed[:],
        }

    def _craft_state(self, craft: TCraft | TUfo) -> dict:
        """
        Get the state of a single craft for reporting.

        Args:
            craft (TCraft | TUfo): The craft object.

        Returns:
            dict: State including id, health, max_health, weapons, and status.
        """
        return {
            'id': craft.id,
            'health': craft.health,
            'max_health': craft.type.health,
            'weapons': [w.id for w in craft.weapons],
            'status': craft.status,
        }

    def spend_ap(self, craft_idx: int, action: str, **kwargs) -> bool:
        """
        Spend action points for a craft to perform an action.

        Args:
            craft_idx (int): Index of the acting craft (0 or 1).
            action (str): Action to perform ('move_towards', 'move_away', 'fire', etc.).
            **kwargs: Additional arguments for the action.

        Returns:
            bool: True if action was performed, False otherwise.
        """
        if self.crashed[craft_idx]:
            self.log.append(f"Craft {craft_idx} is crashed and cannot act.")
            return False
        if self.ap[craft_idx] <= 0:
            self.log.append(f"Craft {craft_idx} has no AP left.")
            return False
        if action == 'move_towards':
            accel = self.crafts[craft_idx].type.acceleration
            self.distance = max(0, self.distance - accel)
            self.ap[craft_idx] -= 1
            self.log.append(f"Craft {craft_idx} moves towards enemy by {accel} km. Distance: {self.distance}")
        elif action == 'move_away':
            accel = self.crafts[craft_idx].type.acceleration
            self.distance += accel
            self.ap[craft_idx] -= 1
            self.log.append(f"Craft {craft_idx} moves away from enemy by {accel} km. Distance: {self.distance}")
        elif action == 'fire':
            weapon_idx = kwargs.get('weapon_idx', 0)
            target_idx = 1 - craft_idx
            if weapon_idx >= len(self.crafts[craft_idx].weapons):
                self.log.append(f"Craft {craft_idx} tried to fire invalid weapon.")
                return False
            weapon = self.crafts[craft_idx].weapons[weapon_idx]
            # Check range
            if self.distance > weapon.range * 10:  # weapon.range is in 10km units
                self.log.append(f"Weapon out of range.")
                return False
            # Check ammo
            if weapon.ammo <= 0:
                self.log.append(f"Weapon has no ammo.")
                return False
            # Roll to hit
            hit_chance = weapon.accuracy + self.crafts[craft_idx].type.hit_bonus
            hit_roll = random.random()
            if hit_roll < hit_chance:
                damage = weapon.damage + self.crafts[craft_idx].type.damage_bonus
                self.crafts[target_idx].health -= damage
                self.log.append(f"Craft {craft_idx} hits craft {target_idx} for {damage} damage!")
                # Check for crash
                if self.crafts[target_idx].health <= self.crafts[target_idx].type.health * 0.5:
                    over = self.crafts[target_idx].type.health * 0.5 - self.crafts[target_idx].health
                    crash_chance = min(1.0, max(0.1, over / (self.crafts[target_idx].type.health * 0.5)))
                    if random.random() < crash_chance:
                        self.crashed[target_idx] = True
                        self.log.append(f"Craft {target_idx} has crashed!")
            else:
                self.log.append(f"Craft {craft_idx} missed.")
            # Spend AP and ammo
            self.ap[craft_idx] -= 1
            weapon.ammo -= 1
        else:
            self.log.append(f"Unknown action: {action}")
            return False
        return True

    def next_turn(self) -> None:
        """
        Advance the interception to the next turn, refueling, rearming, and repairing crafts as needed.
        Also triggers notifications for fuel, ammo, and health.
        """
        self.turn += 1
        self.ap = [4, 4]
        self.log.append(f"--- Turn {self.turn} ---")
        # Refuel, rearm, and repair logic (1 turn = 1 day)
        for idx, craft in enumerate(self.crafts):
            # Refuel
            if craft.current_fuel < craft.max_fuel:
                fuel_needed = craft.max_fuel - craft.current_fuel
                fuel_cost = craft.craft_type.fuel_cost * fuel_needed
                craft.current_fuel = craft.max_fuel
                craft.add_notification(f"Refueled to max. Cost: {fuel_cost}")
            # Rearm
            for weapon in craft.weapons:
                if weapon.ammo < weapon.max_ammo:
                    ammo_needed = weapon.max_ammo - weapon.ammo
                    rearm_cost = weapon.rearm_cost()
                    weapon.ammo = weapon.max_ammo
                    craft.add_notification(f"Weapon {weapon.id} rearmed. Cost: {rearm_cost}")
            # Maintenance/Repair
            if craft.health_current < craft.health:
                repair_rate = craft.base_repair_rate
                repaired = min(repair_rate, craft.health - craft.health_current)
                craft.health_current += repaired
                craft.add_notification(f"Repaired {repaired} HP. Current HP: {craft.health_current}/{craft.health}")
        # Notification triggers
        for craft in self.crafts:
            # Fuel notifications
            if craft.current_fuel == 0:
                craft.add_notification("No fuel!")
            elif craft.current_fuel < craft.max_fuel * 0.2:
                craft.add_notification("Low fuel!")
            # Ammo notifications
            for weapon in craft.weapons:
                if weapon.ammo == 0:
                    craft.add_notification(f"Weapon {weapon.id} no ammo!")
                elif weapon.ammo < weapon.max_ammo * 0.2:
                    craft.add_notification(f"Weapon {weapon.id} low ammo!")
            # Health notifications
            if craft.health_current < craft.health * 0.2:
                craft.add_notification("Low health!")
        # End if distance > 100km for 3 turns or both crafts crashed
        # (Add more logic as needed)

    def is_over(self) -> bool:
        """
        Check if the interception is over (both crafts crashed or distance > 100km).

        Returns:
            bool: True if combat is over, False otherwise.
        """
        if all(self.crashed):
            return True
        if self.distance > 100:
            return True
        return False

    def get_log(self) -> List[str]:
        """
        Get the combat log for the interception.

        Returns:
            List[str]: List of log messages.
        """
        return self.log

    def calculate_rearm_costs(self) -> List[dict]:
        """
        Calculate the cost to rearm all crafts after interception.

        Returns:
            List[dict]: List of dicts per craft with rearm cost details.
        """
        rearm_summary = []
        for craft in self.crafts:
            craft_info = {'craft_id': craft.id, 'weapons': []}
            for weapon in craft.weapons:
                ammo_needed = weapon.ammo_needed()
                cost = weapon.rearm_cost()
                craft_info['weapons'].append({
                    'weapon_id': weapon.id,
                    'ammo_needed': ammo_needed,
                    'rearm_cost': cost
                })
            rearm_summary.append(craft_info)
        return rearm_summary

    def rearm_crafts(self) -> None:
        """
        Refill all craft weapons to max ammo (should be called after player pays cost).
        """
        for craft in self.crafts:
            for weapon in craft.weapons:
                weapon.ammo = weapon.max_ammo
