#!/usr/bin/env python3
"""
Phase 11 Test Runner
Runs the save/load with modset validation tests.
"""

import sys
import os
from pathlib import Path

# Add the src directory to the path so we can import modules
sys.path.insert(0, str(Path(__file__).parent / "src"))

def run_phase11_tests():
    """Run Phase 11 tests manually without pytest."""
    print("=== Phase 11: Save/Load with Modset Validation Tests ===\n")

    try:
        from engine.savegame import TSaveGame, ModsetMismatchError
        print("✓ Successfully imported TSaveGame and ModsetMismatchError")
    except ImportError as e:
        print(f"✗ Failed to import required modules: {e}")
        return False

    # Test 1: Basic initialization
    try:
        sg = TSaveGame('test.sav')
        assert isinstance(sg, TSaveGame)
        assert sg.save_path == 'test.sav'
        print("✓ Basic initialization test passed")
    except Exception as e:
        print(f"✗ Basic initialization test failed: {e}")
        return False

    # Test 2: Modset fingerprint generation
    try:
        sg = TSaveGame()
        modset = {
            "mods": [
                {"id": "core", "version": "1.0.0", "priority": 0}
            ]
        }

        fingerprint1 = sg._generate_modset_fingerprint(modset)
        fingerprint2 = sg._generate_modset_fingerprint(modset)

        assert fingerprint1 == fingerprint2
        assert len(fingerprint1) == 16
        print("✓ Modset fingerprint generation test passed")
    except Exception as e:
        print(f"✗ Modset fingerprint generation test failed: {e}")
        return False

    # Test 3: Modset validation
    try:
        sg = TSaveGame()

        modset1 = {"mods": [{"id": "core", "version": "1.0.0"}]}
        modset2 = {"mods": [{"id": "core", "version": "1.0.0"}]}
        modset3 = {"mods": [{"id": "core", "version": "2.0.0"}]}

        assert sg._validate_modset_compatibility(modset1, modset2)
        assert not sg._validate_modset_compatibility(modset1, modset3)
        print("✓ Modset validation test passed")
    except Exception as e:
        print(f"✗ Modset validation test failed: {e}")
        return False

    # Test 4: Save and load with matching modset
    try:
        import tempfile
        import json

        with tempfile.TemporaryDirectory() as temp_dir:
            save_path = Path(temp_dir) / "test_phase11.sav"

            # Save
            sg = TSaveGame(str(save_path))
            modset_info = {
                "mods": [
                    {"id": "core", "version": "1.0.0", "priority": 0}
                ]
            }
            game_state = {"level": 5, "score": 1000}

            sg.save(game_state, modset_info)

            # Load
            loaded_sg = TSaveGame()
            loaded_state = loaded_sg.load(str(save_path), modset_info)

            assert loaded_state == game_state
            assert loaded_sg.modset_fingerprint is not None
            print("✓ Save and load with matching modset test passed")
    except Exception as e:
        print(f"✗ Save and load test failed: {e}")
        return False

    # Test 5: Modset mismatch error
    try:
        import tempfile

        with tempfile.TemporaryDirectory() as temp_dir:
            save_path = Path(temp_dir) / "test_mismatch.sav"

            # Save with one modset
            sg = TSaveGame(str(save_path))
            original_modset = {
                "mods": [
                    {"id": "core", "version": "1.0.0", "priority": 0}
                ]
            }
            game_state = {"data": "mismatch_test"}

            sg.save(game_state, original_modset)

            # Try to load with different modset
            different_modset = {
                "mods": [
                    {"id": "core", "version": "2.0.0", "priority": 0}
                ]
            }

            loaded_sg = TSaveGame()

            try:
                loaded_sg.load(str(save_path), different_modset)
                assert False, "Should have raised ModsetMismatchError"
            except ModsetMismatchError as e:
                assert "Modset mismatch" in str(e)
                print("✓ Modset mismatch error test passed")
    except Exception as e:
        print(f"✗ Modset mismatch error test failed: {e}")
        return False

    print("\n🎉 All Phase 11 tests passed successfully!")
    print("\nPhase 11 Status: ✅ COMPLETE")
    print("- Save/load with modset validation: IMPLEMENTED")
    print("- Modset fingerprinting: WORKING")
    print("- Modset compatibility checking: WORKING")
    print("- Error handling for mismatches: WORKING")

    return True

if __name__ == "__main__":
    success = run_phase11_tests()
    sys.exit(0 if success else 1)
