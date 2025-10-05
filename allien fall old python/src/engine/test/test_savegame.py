import pytest
import json
import tempfile
import os
from pathlib import Path
from engine.savegame import TSaveGame, ModsetMismatchError

def test_savegame_init():
    sg = TSaveGame('test.sav')
    assert isinstance(sg, TSaveGame)
    assert sg.save_path == 'test.sav'
    assert sg.last_saved is None

def test_save_with_modset():
    """Test saving with modset information."""
    with tempfile.TemporaryDirectory() as temp_dir:
        save_path = Path(temp_dir) / "test_modset.sav"

        sg = TSaveGame(str(save_path))

        # Sample modset info
        modset_info = {
            "mods": [
                {"id": "core", "version": "1.0.0", "priority": 0},
                {"id": "expansion", "version": "1.1.0", "priority": 10}
            ],
            "seed_lineage_root": "campaign_12345"
        }

        game_state = {"player_name": "TestPlayer", "score": 1000}

        # Save with modset
        sg.save(game_state, modset_info, "campaign_12345")

        # Verify file was created
        assert save_path.exists()

        # Verify content
        with open(save_path, 'r') as f:
            save_data = json.load(f)

        assert "header" in save_data
        assert "game_state" in save_data
        assert save_data["header"]["modset_fingerprint"] is not None
        assert save_data["header"]["seed_lineage_root"] == "campaign_12345"
        assert save_data["header"]["modset_info"] == modset_info
        assert save_data["game_state"] == game_state

def test_load_with_matching_modset():
    """Test loading with matching modset."""
    with tempfile.TemporaryDirectory() as temp_dir:
        save_path = Path(temp_dir) / "test_load.sav"

        # Create save with modset
        sg = TSaveGame(str(save_path))
        modset_info = {
            "mods": [
                {"id": "core", "version": "1.0.0", "priority": 0}
            ]
        }
        game_state = {"level": 5, "items": ["sword", "shield"]}

        sg.save(game_state, modset_info)

        # Load with same modset
        loaded_sg = TSaveGame()
        loaded_state = loaded_sg.load(str(save_path), modset_info)

        assert loaded_state == game_state
        assert loaded_sg.modset_fingerprint is not None
        assert loaded_sg.seed_lineage_root is None  # No seed provided in this test

def test_load_with_mismatched_modset():
    """Test loading with mismatched modset raises error."""
    with tempfile.TemporaryDirectory() as temp_dir:
        save_path = Path(temp_dir) / "test_mismatch.sav"

        # Create save with one modset
        sg = TSaveGame(str(save_path))
        original_modset = {
            "mods": [
                {"id": "core", "version": "1.0.0", "priority": 0}
            ]
        }
        game_state = {"data": "test"}

        sg.save(game_state, original_modset)

        # Try to load with different modset
        different_modset = {
            "mods": [
                {"id": "core", "version": "2.0.0", "priority": 0}  # Different version
            ]
        }

        loaded_sg = TSaveGame()

        with pytest.raises(ModsetMismatchError) as exc_info:
            loaded_sg.load(str(save_path), different_modset)

        assert "Modset mismatch" in str(exc_info.value)
        assert "core" in str(exc_info.value)

def test_load_with_force_override():
    """Test loading with force override bypasses modset validation."""
    with tempfile.TemporaryDirectory() as temp_dir:
        save_path = Path(temp_dir) / "test_force.sav"

        # Create save with one modset
        sg = TSaveGame(str(save_path))
        original_modset = {
            "mods": [
                {"id": "core", "version": "1.0.0", "priority": 0}
            ]
        }
        game_state = {"data": "force_test"}

        sg.save(game_state, original_modset)

        # Load with different modset but force=True
        different_modset = {
            "mods": [
                {"id": "core", "version": "2.0.0", "priority": 0}
            ]
        }

        loaded_sg = TSaveGame()
        loaded_state = loaded_sg.load(str(save_path), different_modset, force_load=True)

        assert loaded_state == game_state

def test_modset_fingerprint_generation():
    """Test that modset fingerprints are generated consistently."""
    sg = TSaveGame()

    modset1 = {
        "mods": [
            {"id": "core", "version": "1.0.0", "priority": 0},
            {"id": "expansion", "version": "1.1.0", "priority": 10}
        ]
    }

    modset2 = {
        "mods": [
            {"id": "core", "version": "1.0.0", "priority": 0},
            {"id": "expansion", "version": "1.1.0", "priority": 10}
        ]
    }

    # Same modset should produce same fingerprint
    fingerprint1 = sg._generate_modset_fingerprint(modset1)
    fingerprint2 = sg._generate_modset_fingerprint(modset2)

    assert fingerprint1 == fingerprint2
    assert len(fingerprint1) == 16  # Short hash length

def test_modset_fingerprint_different():
    """Test that different modsets produce different fingerprints."""
    sg = TSaveGame()

    modset1 = {
        "mods": [
            {"id": "core", "version": "1.0.0", "priority": 0}
        ]
    }

    modset2 = {
        "mods": [
            {"id": "core", "version": "2.0.0", "priority": 0}  # Different version
        ]
    }

    fingerprint1 = sg._generate_modset_fingerprint(modset1)
    fingerprint2 = sg._generate_modset_fingerprint(modset2)

    assert fingerprint1 != fingerprint2

def test_modset_validation():
    """Test modset validation logic."""
    sg = TSaveGame()

    # Same modsets should validate
    modset = {
        "mods": [
            {"id": "core", "version": "1.0.0", "priority": 0}
        ]
    }

    assert sg._validate_modset_compatibility(modset, modset)

    # Different modsets should not validate
    different_modset = {
        "mods": [
            {"id": "core", "version": "2.0.0", "priority": 0}
        ]
    }

    assert not sg._validate_modset_compatibility(modset, different_modset)

def test_save_without_modset():
    """Test saving without modset information."""
    with tempfile.TemporaryDirectory() as temp_dir:
        save_path = Path(temp_dir) / "test_no_modset.sav"

        sg = TSaveGame(str(save_path))
        game_state = {"simple": "data"}

        # Save without modset
        sg.save(game_state)

        # Verify file was created
        assert save_path.exists()

        # Verify content
        with open(save_path, 'r') as f:
            save_data = json.load(f)

        assert save_data["header"]["modset_fingerprint"] == "no_modset"
        assert save_data["game_state"] == game_state

def test_load_nonexistent_file():
    """Test loading a nonexistent file raises FileNotFoundError."""
    sg = TSaveGame()

    with pytest.raises(FileNotFoundError):
        sg.load("nonexistent_file.sav")

def test_get_save_metadata():
    sg = TSaveGame('test.sav')
    meta = sg.get_save_metadata()
    assert meta['save_path'] == 'test.sav'
    assert 'last_saved' in meta
    assert 'modset_fingerprint' in meta
    assert 'seed_lineage_root' in meta

