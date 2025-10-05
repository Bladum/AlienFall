"""
TBattleObjective: Represents a single mission objective for the battle (eliminate, escape, defend, rescue, etc.).

Encapsulates the type, parameters, status, and progress of an objective, and provides methods to check completion based on battle state.

Classes:
    TBattleObjective: Main class for battle mission objectives.

Last standardized: 2025-06-22 (typing enforced)
"""

from typing import Dict, Any

OBJECTIVE_TYPES = [
    # Core
    "eliminate",
    "escape",
    # Time Limited
    "hold",
    "blitz",
    # Territory
    "defend",
    "conquer",
    "explore",
    # Unit-based
    "rescue",
    "capture",
    "hunt",
    "recon",
    "protect",
    # Object-based
    "sabotage",
    "retrieve",
    # Other
    "escort",
    "ambush",
]

class TBattleObjective:
    """
    Represents a single mission objective for the battle.

    Attributes:
        type (str): Objective type identifier (e.g. 'eliminate', 'escape', etc.).
        params (dict[str, Any]): Dictionary with objective parameters (unit ids, tile coords, turns, etc.).
        status (str): 'incomplete', 'complete', or 'failed'.
        progress (int): Progress value for objectives with progress (e.g. explore %).
    """
    def __init__(self, pid: str, data: dict[str, Any] = {}):
        """
        Initialize a TBattleObjective instance with type and parameters.

        Args:
            pid (str): Objective type identifier.
            data (dict[str, Any], optional): Dictionary with objective parameters.
        """
        self.type: str = pid
        self.params: dict[str, Any] = data
        self.status: str = 'incomplete'
        self.progress: int = 0  # For objectives with progress (e.g. explore %)

    def check_status(self, battle) -> None:
        """
        Dispatch to the specific check method for this objective type, updating status and progress.
        Args:
            battle: The current battle instance.
        """
        if self.type == "eliminate":
            method = self._check_eliminate
        elif self.type == "escape":
            method = self._check_escape
        elif self.type == "hold":
            method = self._check_hold
        elif self.type == "blitz":
            method = self._check_blitz
        elif self.type == "defend":
            method = self._check_defend
        elif self.type == "conquer":
            method = self._check_conquer
        elif self.type == "explore":
            method = self._check_explore
        elif self.type == "rescue":
            method = self._check_rescue
        elif self.type == "capture":
            method = self._check_capture
        elif self.type == "hunt":
            method = self._check_hunt
        elif self.type == "recon":
            method = self._check_recon
        elif self.type == "protect":
            method = self._check_protect
        elif self.type == "sabotage":
            method = self._check_sabotage
        elif self.type == "retrieve":
            method = self._check_retrieve
        elif self.type == "escort":
            method = self._check_escort
        elif self.type == "ambush":
            method = self._check_ambush
        else:
            raise ValueError(f"Unknown objective type: {self.type}")

        method(battle)

    # --- CORE OBJECTIVES ---
    def _check_eliminate(self, battle) -> None:
        """
        Check if all enemy units have been eliminated.
        Args:
            battle: The current battle instance.
        """
        # Defeat all enemy units
        enemies = battle.find_units(side=battle.SIDE_ENEMY, alive=True)
        self.status = 'complete' if not enemies else 'incomplete'

    def _check_escape(self, battle) -> None:
        """
        Check if escape objective is complete.
        Args:
            battle: The current battle instance.
        """
        # Move all player units to extraction point(s)
        extraction_tiles = battle.find_tiles(objective_marker='extraction')
        player_units = battle.find_units(side=battle.SIDE_PLAYER, alive=True)
        if not player_units:
            self.status = 'failed'
            return
        all_extracted = all(any((unit.x, unit.y) == (x, y) for (x, y, _) in extraction_tiles) for unit in player_units)
        self.status = 'complete' if all_extracted else 'incomplete'

    # --- TIME LIMITED OBJECTIVES ---
    def _check_hold(self, battle) -> None:
        """
        Check if hold objective is complete.
        Args:
            battle: The current battle instance.
        """
        # Survive for specified number of turns
        turns = self.params['turns'] if 'turns' in self.params else 10
        self.status = 'complete' if battle.turn >= turns else 'incomplete'

    def _check_blitz(self, battle) -> None:
        """
        Check if blitz objective is complete.
        Args:
            battle: The current battle instance.
        """
        # Eliminate all enemies before time limit
        turns = self.params['turns'] if 'turns' in self.params else 10
        enemies = battle.find_units(side=battle.SIDE_ENEMY, alive=True)
        if not enemies and battle.turn <= turns:
            self.status = 'complete'
        elif battle.turn > turns and enemies:
            self.status = 'failed'
        else:
            self.status = 'incomplete'

    # --- TERRITORY OBJECTIVES ---
    def _check_defend(self, battle) -> None:
        """
        Check if defend objective is complete.
        Args:
            battle: The current battle instance.
        """
        # Prevent enemies from capturing marked POC
        poc_tiles = battle.find_tiles(objective_marker='poc')
        for (x, y, tile) in poc_tiles:
            if tile.unit and tile.unit.side == battle.SIDE_ENEMY:
                self.status = 'failed'
                return
        self.status = 'complete'

    def _check_conquer(self, battle) -> None:
        """
        Check if conquer objective is complete.
        Args:
            battle: The current battle instance.
        """
        # Conquer marked POC from enemy forces
        poc_tiles = battle.find_tiles(objective_marker='poc')
        for (x, y, tile) in poc_tiles:
            if not tile.unit or tile.unit.side != battle.SIDE_PLAYER:
                self.status = 'incomplete'
                return
        self.status = 'complete'

    def _check_explore(self, battle) -> None:
        """
        Check if explore objective is complete.
        Args:
            battle: The current battle instance.
        """
        # Reveal specified percentage of the map
        percent = self.params['percent'] if 'percent' in self.params else 80
        total = battle.width * battle.height
        visible = sum(1 for row in battle.tiles for tile in row if tile.fog_of_war and any(fw > 0 for fw in tile.fog_of_war))
        self.progress = int(visible / total * 100)
        self.status = 'complete' if self.progress >= percent else 'incomplete'

    # --- UNIT-BASED OBJECTIVES ---
    def _check_rescue(self, battle) -> None:
        """
        Check if rescue objective is complete.
        Args:
            battle: The current battle instance.
        """
        # Locate friendly units and escort to extraction
        rescue_ids = self.params['unit_ids'] if 'unit_ids' in self.params else []
        extraction_tiles = battle.find_tiles(objective_marker='extraction')
        rescued = 0
        for unit in battle.find_units(unit_ids=rescue_ids, alive=True):
            if any((unit.x, unit.y) == (x, y) for (x, y, _) in extraction_tiles):
                rescued += 1
        self.progress = rescued
        self.status = 'complete' if rescued == len(rescue_ids) else 'incomplete'

    def _check_capture(self, battle) -> None:
        """
        Check if capture objective is complete.
        Args:
            battle: The current battle instance.
        """
        # Capture alive specific units
        capture_ids = self.params['unit_ids'] if 'unit_ids' in self.params else []
        captured = 0
        for unit in battle.find_units(unit_ids=capture_ids, alive=True):
            # Direct attribute access, type must guarantee is_captured exists
            if unit.is_captured:
                captured += 1
        self.progress = captured
        self.status = 'complete' if captured == len(capture_ids) else 'incomplete'

    def _check_hunt(self, battle) -> None:
        """
        Check if hunt objective is complete.
        Args:
            battle: The current battle instance.
        """
        # Eliminate specific units
        hunt_ids = self.params['unit_ids'] if 'unit_ids' in self.params else []
        alive = [unit for unit in battle.find_units(unit_ids=hunt_ids, alive=True)]
        self.progress = len(hunt_ids) - len(alive)
        self.status = 'complete' if not alive else 'incomplete'

    def _check_recon(self, battle) -> None:
        """
        Check if recon objective is complete.
        Args:
            battle: The current battle instance.
        """
        # Identify/mark specific enemy units without engaging
        recon_ids = self.params['unit_ids'] if 'unit_ids' in self.params else []
        seen = 0
        for unit in battle.find_units(unit_ids=recon_ids, alive=True):
            # Direct attribute access, type must guarantee is_spotted exists
            if unit.is_spotted:
                seen += 1
        self.progress = seen
        self.status = 'complete' if seen == len(recon_ids) else 'incomplete'

    def _check_protect(self, battle) -> None:
        """
        Check if protect objective is complete.
        Args:
            battle: The current battle instance.
        """
        # Ensure specific units survive the mission
        protect_ids = self.params['unit_ids'] if 'unit_ids' in self.params else []
        alive = [unit for unit in battle.find_units(unit_ids=protect_ids, alive=True)]
        self.progress = len(alive)
        self.status = 'complete' if len(alive) == len(protect_ids) else 'incomplete'

    # --- OBJECT-BASED OBJECTIVES ---
    def _check_sabotage(self, battle) -> None:
        """
        Check if sabotage objective is complete.
        Args:
            battle: The current battle instance.
        """
        # Destroy designated objects
        obj_ids = self.params['object_ids'] if 'object_ids' in self.params else []
        destroyed = 0
        for obj in battle.find_objects(object_ids=obj_ids):
            # Direct attribute access, type must guarantee is_destroyed exists
            if obj.is_destroyed:
                destroyed += 1
        self.progress = destroyed
        self.status = 'complete' if destroyed == len(obj_ids) else 'incomplete'

    def _check_retrieve(self, battle) -> None:
        """
        Check if retrieve objective is complete.
        Args:
            battle: The current battle instance.
        """
        # Collect designated objects
        obj_ids = self.params['object_ids'] if 'object_ids' in self.params else []
        collected = 0
        for obj in battle.find_objects(object_ids=obj_ids):
            # Direct attribute access, type must guarantee is_collected exists
            if obj.is_collected:
                collected += 1
        self.progress = collected
        self.status = 'complete' if collected == len(obj_ids) else 'incomplete'

    # --- OTHER OBJECTIVES ---
    def _check_escort(self, battle) -> None:
        """
        Check if escort objective is complete.
        Args:
            battle: The current battle instance.
        """
        # Protect moving target as it travels across the map
        escort_ids = self.params['unit_ids'] if 'unit_ids' in self.params else []
        alive = [unit for unit in battle.find_units(unit_ids=escort_ids, alive=True)]
        self.progress = len(alive)
        self.status = 'complete' if len(alive) == len(escort_ids) else 'incomplete'

    def _check_ambush(self, battle) -> None:
        """
        Check if ambush objective is complete.
        Args:
            battle: The current battle instance.
        """
        # Set up position and eliminate enemy patrol/convoy
        ambush_ids = self.params['unit_ids'] if 'unit_ids' in self.params else []
        eliminated = 0
        for unit in battle.find_units(unit_ids=ambush_ids, alive=False):
            eliminated += 1
        self.progress = eliminated
        self.status = 'complete' if eliminated == len(ambush_ids) else 'incomplete'

