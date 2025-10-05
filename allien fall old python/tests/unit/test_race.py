import pytest
from src.unit.race import TRace
from src.unit.unit_stat import TUnitStats

class TestTRace:
    def test_init_defaults(self):
        data = {}
        race = TRace('ALIEN', data)
        assert race.pid == 'ALIEN'
        assert race.name == 'ALIEN'
        assert race.description == ''
        assert race.sprite == ''
        assert race.is_big is False
        assert race.is_mechanical is False
        assert race.gain_experience is True
        assert race.health_regen == 0
        assert race.sound_death is None
        assert race.corpse_image is None
        assert isinstance(race.stats, TUnitStats)
        assert race.aggression == 0.0
        assert race.intelligence == 0.0
        assert race.immune_panic is False
        assert race.immune_pain is False
        assert race.immune_bleed is False
        assert race.can_run is True
        assert race.can_kneel is True
        assert race.can_sneak is True
        assert race.can_surrender is False
        assert race.can_capture is False
        assert race.spawn_on_death is None
        assert race.avoids_fire is False
        assert race.spotter == 0
        assert race.sniper == 0
        assert race.sell_cost == 0
        assert race.female_frequency == 0.0
        assert race.level_max == 0
        assert race.level_train == 0
        assert race.level_start == 0

    def test_init_custom(self):
        data = {
            'name': 'Sectoid',
            'description': 'Alien race',
            'sprite': 'sectoid.png',
            'is_big': True,
            'is_mechanical': True,
            'gain_experience': False,
            'health_regen': 2,
            'sound_death': 'alien_die.wav',
            'corpse_image': 'sectoid_corpse.png',
        }
        race = TRace('SECTOID', data)
        assert race.pid == 'SECTOID'
        assert race.name == 'Sectoid'
        assert race.description == 'Alien race'
        assert race.sprite == 'sectoid.png'
        assert race.is_big is True
        assert race.is_mechanical is True
        assert race.gain_experience is False
        assert race.health_regen == 2
        assert race.sound_death == 'alien_die.wav'
        assert race.corpse_image == 'sectoid_corpse.png'
