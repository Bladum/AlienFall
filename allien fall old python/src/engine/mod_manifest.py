"""
engine/engine/mod_manifest.py

Defines the TModManifest class, which handles modset information extraction and validation.

Classes:
    TModManifest: Manages modset metadata for save/load validation.

Last standardized: 2025-08-31
"""

import logging
import tomli
from pathlib import Path
from typing import Dict, List, Any, Optional

class TModManifest:
    """
    Manages modset metadata for save/load validation.
    Extracts mod information from mods.toml and provides modset fingerprints.

    Attributes:
        mods_path (Path): Path to the mods directory.
        modset_info (dict): Current modset information.
    """

    def __init__(self, mods_path: str = "mods"):
        """
        Initialize the mod manifest manager.

        Args:
            mods_path (str): Path to the mods directory.
        """
        self.mods_path = Path(mods_path)
        self.modset_info = {}
        logging.debug(f"TModManifest initialized with mods_path: {mods_path}")

    def load_modset_info(self) -> Dict[str, Any]:
        """
        Load modset information from mods.toml file.

        Returns:
            dict: Modset information including mod IDs, versions, and priorities.
        """
        mods_toml_path = self.mods_path / "mods.toml"

        if not mods_toml_path.exists():
            logging.warning(f"mods.toml not found at {mods_toml_path}")
            return {}

        try:
            with open(mods_toml_path, 'rb') as f:
                mods_data = tomli.load(f)

            # Extract mod information
            modset_info = {
                "mods": {},
                "total_mods": len(mods_data),
                "mod_ids": list(mods_data.keys())
            }

            for mod_id, mod_info in mods_data.items():
                modset_info["mods"][mod_id] = {
                    "name": mod_info.get("name", mod_id),
                    "description": mod_info.get("description", ""),
                    "author": mod_info.get("author", "Unknown"),
                    "mod_path": mod_info.get("mod_path", ""),
                    "enabled": True,  # Assume enabled if listed
                    "priority": 0  # Default priority
                }

            self.modset_info = modset_info
            logging.info(f"Loaded modset info for {len(modset_info['mods'])} mods")
            return modset_info

        except Exception as e:
            logging.error(f"Failed to load mods.toml: {e}")
            return {}

    def get_modset_fingerprint(self) -> str:
        """
        Get a fingerprint for the current modset.

        Returns:
            str: Modset fingerprint for comparison.
        """
        if not self.modset_info:
            self.load_modset_info()

        # Use the savegame's fingerprint generation method
        from .savegame import TSaveGame
        savegame = TSaveGame()
        return savegame._generate_modset_fingerprint(self.modset_info)

    def validate_mod_compatibility(self, saved_modset: Dict[str, Any]) -> bool:
        """
        Validate if a saved modset is compatible with the current modset.

        Args:
            saved_modset (dict): Modset from a save file.

        Returns:
            bool: True if compatible, False otherwise.
        """
        current_modset = self.load_modset_info()

        # For now, require exact match of mod IDs
        saved_mod_ids = set(saved_modset.get("mod_ids", []))
        current_mod_ids = set(current_modset.get("mod_ids", []))

        return saved_mod_ids == current_mod_ids

    def get_enabled_mods(self) -> List[str]:
        """
        Get list of enabled mod IDs.

        Returns:
            list: List of enabled mod IDs.
        """
        if not self.modset_info:
            self.load_modset_info()

        return [mod_id for mod_id, info in self.modset_info.get("mods", {}).items()
                if info.get("enabled", True)]

    def get_mod_info(self, mod_id: str) -> Optional[Dict[str, Any]]:
        """
        Get information about a specific mod.

        Args:
            mod_id (str): The mod ID to look up.

        Returns:
            dict or None: Mod information if found, None otherwise.
        """
        if not self.modset_info:
            self.load_modset_info()

        return self.modset_info.get("mods", {}).get(mod_id)
