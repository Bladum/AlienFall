"""
engine/test/test_savegame_modset.py

Tests for savegame modset validation functionality.

Last standardized: 2025-08-31
"""

import pytest
import tempfile
import json
from pathlib import Path
from unittest.mock import patch

from engine.savegame import TSaveGame, ModsetMismatchError
from engine.mod_manifest import TModManifest


class TestSaveGameModset:
    """Test savegame functionality with modset validation."""

    def test_save_with_modset_info(self):
        """Test saving with modset information."""
        with tempfile.TemporaryDirectory() as temp_dir:
            save_path = Path(temp_dir) / "test_save.json"

            # Create savegame instance
            savegame = TSaveGame(str(save_path))

            # Mock game state
            game_state = {"player": {"name": "Test Player", "level": 5}}

            # Mock modset info
            modset_info = {
                "mods": {
                    "xcom": {
                        "name": "X-COM",
                        "description": "X-COM: UFO Defense",
                        "author": "Tomek",
                        "enabled": True,
                        "priority": 0
                    }
                },
                "total_mods": 1,
                "mod_ids": ["xcom"]
            }

            # Save with modset info
            savegame.save(game_state, modset_info, "test_seed_123")

            # Verify file was created
            assert save_path.exists()

            # Verify file contents
            with open(save_path, 'r') as f:
                saved_data = json.load(f)

            assert "header" in saved_data
            assert "game_state" in saved_data
            assert saved_data["header"]["modset_fingerprint"] is not None
            assert saved_data["header"]["seed_lineage_root"] == "test_seed_123"
            assert saved_data["header"]["modset_info"] == modset_info
            assert saved_data["game_state"] == game_state

    def test_load_with_matching_modset(self):
        """Test loading with matching modset."""
        with tempfile.TemporaryDirectory() as temp_dir:
            save_path = Path(temp_dir) / "test_save.json"

            # Create and save
            savegame = TSaveGame(str(save_path))
            game_state = {"player": {"name": "Test Player"}}
            modset_info = {
                "mods": {"xcom": {"name": "X-COM", "enabled": True}},
                "mod_ids": ["xcom"]
            }
            savegame.save(game_state, modset_info)

            # Load with same modset
            loaded_state = savegame.load(str(save_path), modset_info)

            assert loaded_state == game_state

    def test_load_with_mismatched_modset_raises_error(self):
        """Test that loading with mismatched modset raises ModsetMismatchError."""
        with tempfile.TemporaryDirectory() as temp_dir:
            save_path = Path(temp_dir) / "test_save.json"

            # Create save with one modset
            savegame = TSaveGame(str(save_path))
            game_state = {"player": {"name": "Test Player"}}
            saved_modset = {
                "mods": {"xcom": {"name": "X-COM", "enabled": True}},
                "mod_ids": ["xcom"]
            }
            savegame.save(game_state, saved_modset)

            # Try to load with different modset
            current_modset = {
                "mods": {"expansion": {"name": "Expansion Pack", "enabled": True}},
                "mod_ids": ["expansion"]
            }

            with pytest.raises(ModsetMismatchError) as exc_info:
                savegame.load(str(save_path), current_modset)

            assert "Modset mismatch" in str(exc_info.value)
            assert "xcom" in str(exc_info.value)
            assert "expansion" in str(exc_info.value)

    def test_load_with_force_mod_bypasses_validation(self):
        """Test that force_load bypasses modset validation."""
        with tempfile.TemporaryDirectory() as temp_dir:
            save_path = Path(temp_dir) / "test_save.json"

            # Create save with one modset
            savegame = TSaveGame(str(save_path))
            game_state = {"player": {"name": "Test Player"}}
            saved_modset = {
                "mods": {"xcom": {"name": "X-COM", "enabled": True}},
                "mod_ids": ["xcom"]
            }
            savegame.save(game_state, saved_modset)

            # Load with different modset but force_load=True
            current_modset = {
                "mods": {"expansion": {"name": "Expansion Pack", "enabled": True}},
                "mod_ids": ["expansion"]
            }

            # Should not raise error
            loaded_state = savegame.load(str(save_path), current_modset, force_load=True)
            assert loaded_state == game_state

    def test_modset_fingerprint_generation(self):
        """Test that modset fingerprints are generated consistently."""
        savegame = TSaveGame()

        modset1 = {
            "mods": {"xcom": {"name": "X-COM", "enabled": True}},
            "mod_ids": ["xcom"]
        }
        modset2 = {
            "mods": {"xcom": {"name": "X-COM", "enabled": True}},
            "mod_ids": ["xcom"]
        }
        modset3 = {
            "mods": {"expansion": {"name": "Expansion", "enabled": True}},
            "mod_ids": ["expansion"]
        }

        # Same modset should produce same fingerprint
        fingerprint1 = savegame._generate_modset_fingerprint(modset1)
        fingerprint2 = savegame._generate_modset_fingerprint(modset2)
        assert fingerprint1 == fingerprint2

        # Different modset should produce different fingerprint
        fingerprint3 = savegame._generate_modset_fingerprint(modset3)
        assert fingerprint1 != fingerprint3

    def test_save_without_modset_info(self):
        """Test saving without modset info uses default values."""
        with tempfile.TemporaryDirectory() as temp_dir:
            save_path = Path(temp_dir) / "test_save.json"

            savegame = TSaveGame(str(save_path))
            game_state = {"player": {"name": "Test Player"}}

            # Save without modset info
            savegame.save(game_state)

            # Verify file contents
            with open(save_path, 'r') as f:
                saved_data = json.load(f)

            assert saved_data["header"]["modset_fingerprint"] == "no_modset"
            assert saved_data["header"]["modset_info"] == {}
            assert saved_data["header"]["seed_lineage_root"] == "unknown"

    def test_load_nonexistent_file_raises_error(self):
        """Test that loading non-existent file raises FileNotFoundError."""
        savegame = TSaveGame()

        with pytest.raises(FileNotFoundError):
            savegame.load("nonexistent_file.json")

    def test_get_save_metadata(self):
        """Test getting save metadata."""
        savegame = TSaveGame("test_path.json")

        metadata = savegame.get_save_metadata()

        assert metadata["save_path"] == "test_path.json"
        assert metadata["modset_fingerprint"] is None
        assert metadata["seed_lineage_root"] is None
        assert metadata["last_saved"] is None


class TestModManifest:
    """Test mod manifest functionality."""

    def test_load_modset_info_from_toml(self):
        """Test loading modset info from TOML file."""
        # Create a temporary TOML file
        toml_content = """
[xcom]
name = 'X-COM'
description = 'X-COM: UFO Defense'
author = 'Tomek'
mod_path = 'C:/mods/xcom'

[expansion]
name = 'Expansion Pack'
description = 'Additional content'
author = 'Developer'
mod_path = 'C:/mods/expansion'
"""

        with tempfile.TemporaryDirectory() as temp_dir:
            mods_dir = Path(temp_dir) / "mods"
            mods_dir.mkdir()
            toml_file = mods_dir / "mods.toml"

            with open(toml_file, 'w') as f:
                f.write(toml_content)

            # Test loading
            manifest = TModManifest(str(mods_dir))
            modset_info = manifest.load_modset_info()

            assert modset_info["total_mods"] == 2
            assert "xcom" in modset_info["mod_ids"]
            assert "expansion" in modset_info["mod_ids"]
            assert modset_info["mods"]["xcom"]["name"] == "X-COM"
            assert modset_info["mods"]["expansion"]["author"] == "Developer"

    def test_get_enabled_mods(self):
        """Test getting list of enabled mods."""
        # Mock modset info
        with patch.object(TModManifest, 'load_modset_info') as mock_load:
            mock_load.return_value = {
                "mods": {
                    "xcom": {"enabled": True},
                    "expansion": {"enabled": False},
                    "patch": {"enabled": True}
                }
            }

            manifest = TModManifest()
            enabled_mods = manifest.get_enabled_mods()

            assert "xcom" in enabled_mods
            assert "expansion" not in enabled_mods
            assert "patch" in enabled_mods

    def test_validate_mod_compatibility(self):
        """Test mod compatibility validation."""
        with patch.object(TModManifest, 'load_modset_info') as mock_load:
            # Current modset
            mock_load.return_value = {
                "mod_ids": ["xcom", "expansion"]
            }

            manifest = TModManifest()

            # Compatible saved modset
            compatible_saved = {
                "mod_ids": ["xcom", "expansion"]
            }
            assert manifest.validate_mod_compatibility(compatible_saved)

            # Incompatible saved modset
            incompatible_saved = {
                "mod_ids": ["xcom", "different_mod"]
            }
            assert not manifest.validate_mod_compatibility(incompatible_saved)

    def test_get_mod_info(self):
        """Test getting specific mod information."""
        with patch.object(TModManifest, 'load_modset_info') as mock_load:
            mock_load.return_value = {
                "mods": {
                    "xcom": {"name": "X-COM", "author": "Tomek"},
                    "expansion": {"name": "Expansion Pack", "author": "Dev"}
                }
            }

            manifest = TModManifest()

            # Get existing mod info
            xcom_info = manifest.get_mod_info("xcom")
            assert xcom_info["name"] == "X-COM"
            assert xcom_info["author"] == "Tomek"

            # Get non-existing mod info
            nonexistent_info = manifest.get_mod_info("nonexistent")
            assert nonexistent_info is None
