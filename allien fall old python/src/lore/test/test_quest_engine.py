"""
Test suite for TQuestEngine (quest_engine.py).
Covers class existence and docstring.
"""
import pytest
from lore.quest_engine import TQuestEngine

def test_quest_engine_exists():
    """Test TQuestEngine class exists and has docstring."""
    assert TQuestEngine.__doc__ is not None
    assert isinstance(TQuestEngine(), TQuestEngine)
