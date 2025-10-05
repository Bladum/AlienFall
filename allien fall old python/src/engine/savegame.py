"""
engine/engine/savegame.py

Defines the TSaveGame class, which handles serialization, saving, and loading of game state.

Classes:
    TSaveGame: Handles saving and loading game state.

Last standardized: 2025-06-15
"""

import logging
import json
import hashlib
from datetime import datetime
from pathlib import Path
from typing import Dict, List, Any, Optional

class ModsetMismatchError(Exception):
    """Raised when loading a save with incompatible modset."""
    pass

class TSaveGame:
    """
    Handles saving and loading game state.
    Manages serialization of all game objects and state.

    Attributes:
        save_path (str): Path to the save file.
        last_saved (datetime): Timestamp of the last save.
        modset_fingerprint (str): Hash of the modset used for this save.
        seed_lineage_root (str): Root seed for deterministic lineage.
    """
    def __init__(self, save_path=None):
        """
        Initialize the save game manager.

        Args:
            save_path (str, optional): Path to the save file.
        """
        self.save_path = save_path
        self.last_saved = None
        self.modset_fingerprint = None
        self.seed_lineage_root = None
        logging.debug(f"TSaveGame initialized with save_path: {save_path}")

    def save(self, game_state, modset_info: Optional[Dict[str, Any]] = None, seed_lineage: Optional[str] = None):
        """
        Save the current game state to disk.

        Args:
            game_state (object): The game state to serialize and save.
            modset_info (dict, optional): Information about the current modset.
            seed_lineage (str, optional): Root seed for deterministic lineage.
        """
        if not self.save_path:
            raise ValueError("Save path not set")

        # Generate modset fingerprint if not provided
        if modset_info:
            self.modset_fingerprint = self._generate_modset_fingerprint(modset_info)
        else:
            self.modset_fingerprint = "no_modset"

        # Set seed lineage
        self.seed_lineage_root = seed_lineage or "unknown"

        # Create save data structure
        save_data = {
            "header": {
                "version": "1.0",
                "timestamp": datetime.now().isoformat(),
                "modset_fingerprint": self.modset_fingerprint,
                "seed_lineage_root": self.seed_lineage_root,
                "modset_info": modset_info or {}
            },
            "game_state": game_state
        }

        # Save to file
        save_path = Path(self.save_path)
        save_path.parent.mkdir(parents=True, exist_ok=True)

        with open(save_path, 'w', encoding='utf-8') as f:
            json.dump(save_data, f, indent=2, default=str)

        self.last_saved = datetime.now()
        logging.info(f"Game state saved to {self.save_path} with modset fingerprint: {self.modset_fingerprint}")

    def load(self, path: str, current_modset_info: Optional[Dict[str, Any]] = None, force_load: bool = False):
        """
        Load a game state from disk.

        Args:
            path (str): Path to the save file.
            current_modset_info (dict, optional): Current modset information for validation.
            force_load (bool): If True, skip modset validation.

        Returns:
            dict: The loaded game state.

        Raises:
            ModsetMismatchError: If modset doesn't match and force_load is False.
            FileNotFoundError: If save file doesn't exist.
        """
        save_path = Path(path)
        if not save_path.exists():
            raise FileNotFoundError(f"Save file not found: {path}")

        # Load save data
        with open(save_path, 'r', encoding='utf-8') as f:
            save_data = json.load(f)

        # Validate structure
        if "header" not in save_data or "game_state" not in save_data:
            raise ValueError(f"Invalid save file format: {path}")

        header = save_data["header"]
        self.modset_fingerprint = header.get("modset_fingerprint")
        self.seed_lineage_root = header.get("seed_lineage_root")
        self.last_saved = datetime.fromisoformat(header["timestamp"]) if "timestamp" in header else None

        # Validate modset if not forcing load
        if not force_load and current_modset_info:
            saved_modset = header.get("modset_info", {})
            if not self._validate_modset_compatibility(saved_modset, current_modset_info):
                raise ModsetMismatchError(
                    f"Modset mismatch! Save was created with different mods.\n"
                    f"Saved modset: {saved_modset}\n"
                    f"Current modset: {current_modset_info}\n"
                    f"Use --force-mod to load anyway."
                )

        logging.info(f"Game state loaded from {path}")
        return save_data["game_state"]

    def _generate_modset_fingerprint(self, modset_info: Dict[str, Any]) -> str:
        """
        Generate a fingerprint for the modset.

        Args:
            modset_info (dict): Modset information.

        Returns:
            str: SHA256 hash of the modset.
        """
        # Create a normalized string representation for consistent hashing
        modset_str = json.dumps(modset_info, sort_keys=True, default=str)
        return hashlib.sha256(modset_str.encode('utf-8')).hexdigest()[:16]  # Short hash

    def _validate_modset_compatibility(self, saved_modset: Dict[str, Any], current_modset: Dict[str, Any]) -> bool:
        """
        Validate if the saved modset is compatible with the current modset.

        Args:
            saved_modset (dict): Modset from the save file.
            current_modset (dict): Current modset.

        Returns:
            bool: True if compatible, False otherwise.
        """
        # For now, require exact match. Future versions could be more permissive.
        return saved_modset == current_modset

    def get_save_metadata(self):
        """
        Return metadata about the save file (e.g., last saved time, version).

        Returns:
            dict: Metadata about the save file.
        """
        return {
            'save_path': self.save_path,
            'last_saved': self.last_saved,
            'modset_fingerprint': self.modset_fingerprint,
            'seed_lineage_root': self.seed_lineage_root
        }
