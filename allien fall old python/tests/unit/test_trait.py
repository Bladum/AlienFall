"""
Test suite for engine.unit.trait (TTrait)
Covers initialization and attribute defaults using pytest.
"""
import pytest
from src.unit.trait import TTrait
from src.unit.unit_stat import TUnitStats

@pytest.fixture
def trait():
    data = {
        'name': 'Brave',
        'sprite': 'brave_icon',
        'description': 'Increases morale',
        'type': 0,
        'cost': 100,
        'items_needed': ['medal'],
        'races': ['human'],
        'min_level': 1,
        'max_level': 5,
        'services_needed': ['training'],
        'tech_needed': ['psi_labs'],
        'recovery_time': 0,
        'transfer_time': 0,
        'battle_duration': 0,
        'battle_effect': None,
        'battle_chance_complete': 0,
        'battle_only': False,
    }
    return TTrait('BRAVE', data)

def test_init_defaults(trait):
    """Test initialization and attribute values from data dict using explicit engine types."""
    assert trait.id == 'BRAVE'
    assert trait.name == 'Brave'
    assert trait.sprite == 'brave_icon'
    assert trait.description == 'Increases morale'
    assert trait.type == 0
    assert trait.cost == 100
    assert trait.items_needed == ['medal']
    assert trait.races == ['human']
    assert trait.min_level == 1
    assert trait.max_level == 5
    assert trait.services_needed == ['training']
    assert trait.tech_needed == ['psi_labs']
    assert trait.recovery_time == 0
    assert trait.transfer_time == 0
    assert trait.battle_duration == 0
    assert trait.battle_effect is None
    assert trait.battle_chance_complete == 0
