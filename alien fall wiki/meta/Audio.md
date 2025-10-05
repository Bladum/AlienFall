# Audio Design

## Table of Contents
- [Overview](#overview)
- [Mechanics](#mechanics)
- [Examples](#examples)
- [Related Wiki Pages](#related-wiki-pages)
- [References to Existing Games and Mechanics](#references-to-existing-games-and-mechanics)

## Overview

The Audio Design system orchestrates sound effects, music integration, ambient audio, and audio feedback throughout Alien Fall to enhance tactical awareness, emotional resonance, and player immersion through layered soundscapes, positional audio cues, dynamic music systems, and context-sensitive feedback that reinforces gameplay events without overwhelming strategic decision-making.  
**Related Systems:** [Accessibility](Accessibility.md) | [UI System](../widgets/README.md) | [Battlescape](../battlescape/README.md)

---

## Overview

The Audio Design System defines all sound effects, music, and ambient audio for Alien Fall. The system provides immersive audio feedback while maintaining clarity and avoiding overwhelming the player. All audio is designed with accessibility in mind.

### Purpose
- Provide clear audio feedback for all game actions
- Create immersive atmosphere appropriate to context
- Support gameplay through audio cues
- Enable customization and accessibility options
- Maintain performance with efficient audio management

### Core Principles
- **Clarity First**: Essential sounds must be easily distinguishable
- **Context-Appropriate**: Music and ambience match game state
- **Never Overwhelming**: Audio never drowns out important information
- **Accessibility**: Support for hearing-impaired players
- **Performance**: Efficient streaming and memory management

---

## Audio Categories

### Category Overview

```
┌────────────────────────────────────────────────────────────────┐
│                    AUDIO CATEGORY STRUCTURE                    │
├────────────────────────────────────────────────────────────────┤
│                                                                │
│  UI Sounds (Priority: High)                                   │
│  ├─ Button clicks, menu navigation                            │
│  ├─ Confirmations, cancellations                              │
│  ├─ Alerts, warnings, errors                                  │
│  └─ Tooltip hovers, panel slides                              │
│  Volume Range: 0.3 - 1.0 (adjustable)                         │
│  Max Concurrent: 4 sounds                                     │
│                                                                │
│  Combat Sounds (Priority: Critical)                           │
│  ├─ Weapon fire (7 weapon types × 3 variants)                │
│  ├─ Impacts (hit, miss, armor, flesh)                        │
│  ├─ Explosions (grenades, rockets, environment)              │
│  ├─ Movement (footsteps, doors, climbing)                    │
│  └─ Alien vocalizations (5 species × 4 types)                │
│  Volume Range: 0.5 - 1.0 (adjustable)                         │
│  Max Concurrent: 8 sounds                                     │
│                                                                │
│  Ambient Audio (Priority: Low)                                │
│  ├─ Environmental loops (wind, rain, urban)                  │
│  ├─ Base facility hums                                        │
│  ├─ Geoscape background                                       │
│  └─ Situational ambience (tension, calm)                     │
│  Volume Range: 0.1 - 0.5 (adjustable)                         │
│  Max Concurrent: 2 loops                                      │
│                                                                │
│  Music (Priority: Medium)                                     │
│  ├─ Main menu theme                                           │
│  ├─ Geoscape exploration                                      │
│  ├─ Tactical combat (3 intensity levels)                     │
│  ├─ Base management                                           │
│  └─ Victory/Defeat stings                                     │
│  Volume Range: 0.2 - 0.8 (adjustable)                         │
│  Max Concurrent: 1 track (crossfade)                          │
│                                                                │
│  Voice/Narration (Priority: Medium)                           │
│  ├─ Central Officer announcements                             │
│  ├─ Mission briefings                                         │
│  ├─ Tactical callouts (optional)                              │
│  └─ Tutorial instructions                                     │
│  Volume Range: 0.5 - 1.0 (adjustable)                         │
│  Max Concurrent: 1 voice line                                 │
│                                                                │
└────────────────────────────────────────────────────────────────┘

Total Audio Channels: 32 (Love2D default)
Reserved Channels: 
  - Music: 2 (main + crossfade)
  - Voice: 1 (narration)
  - Ambient: 2 (loops)
  - Available: 27 (dynamic allocation)
```

---

## UI Sounds

### Button and Menu Sounds

```lua
local ui_sounds = {
    -- Button interactions
    button_hover = {
        file = "assets/audio/ui/button_hover.ogg",
        volume = 0.3,
        pitch_variance = 0.05,  -- Slight pitch variation
        cooldown = 0.1          -- Minimum time between plays
    },
    
    button_click = {
        file = "assets/audio/ui/button_click.ogg",
        volume = 0.5,
        pitch_variance = 0.1
    },
    
    button_disabled = {
        file = "assets/audio/ui/button_disabled.ogg",
        volume = 0.4,
        pitch_variance = 0.0
    },
    
    -- Panel interactions
    panel_open = {
        file = "assets/audio/ui/panel_open.ogg",
        volume = 0.4,
        duration = 0.3  -- Synced with animation
    },
    
    panel_close = {
        file = "assets/audio/ui/panel_close.ogg",
        volume = 0.4,
        duration = 0.2
    },
    
    -- Confirmations
    confirm_action = {
        file = "assets/audio/ui/confirm.ogg",
        volume = 0.6,
        usage = "mission_launch, research_start, construction_start"
    },
    
    cancel_action = {
        file = "assets/audio/ui/cancel.ogg",
        volume = 0.5,
        usage = "mission_abort, cancel_construction"
    },
    
    -- Alerts
    alert_warning = {
        file = "assets/audio/ui/alert_warning.ogg",
        volume = 0.8,
        priority = "high",
        usage = "low_funds, soldier_wounded, UFO_detected"
    },
    
    alert_critical = {
        file = "assets/audio/ui/alert_critical.ogg",
        volume = 1.0,
        priority = "critical",
        usage = "base_assault, soldier_killed, country_withdrawal"
    },
    
    alert_info = {
        file = "assets/audio/ui/alert_info.ogg",
        volume = 0.6,
        priority = "low",
        usage = "research_complete, construction_complete"
    }
}

-- Example: Playing UI sound with cooldown
function play_ui_sound(sound_name)
    local sound_config = ui_sounds[sound_name]
    if not sound_config then return end
    
    -- Check cooldown
    local now = love.timer.getTime()
    if sound_config.last_played and 
       (now - sound_config.last_played) < (sound_config.cooldown or 0) then
        return  -- Too soon, skip
    end
    
    -- Load and play sound
    local sound = love.audio.newSource(sound_config.file, "static")
    sound:setVolume(sound_config.volume * game.audio:get_ui_volume())
    
    -- Apply pitch variance if specified
    if sound_config.pitch_variance and sound_config.pitch_variance > 0 then
        local pitch = 1.0 + (math.random() - 0.5) * sound_config.pitch_variance * 2
        sound:setPitch(pitch)
    end
    
    sound:play()
    
    sound_config.last_played = now
end
```

### Notification Sounds

```lua
local notification_sounds = {
    research_complete = {
        file = "assets/audio/notifications/research_complete.ogg",
        volume = 0.7,
        message = "Research project completed"
    },
    
    construction_complete = {
        file = "assets/audio/notifications/construction_complete.ogg",
        volume = 0.7,
        message = "Facility construction completed"
    },
    
    soldier_promotion = {
        file = "assets/audio/notifications/promotion.ogg",
        volume = 0.6,
        message = "Soldier promoted"
    },
    
    ufo_detected = {
        file = "assets/audio/notifications/ufo_detected.ogg",
        volume = 0.9,
        message = "UFO detected on scanners",
        priority = "high"
    },
    
    base_assault = {
        file = "assets/audio/notifications/base_assault.ogg",
        volume = 1.0,
        message = "BASE UNDER ATTACK!",
        priority = "critical"
    }
}
```

---

## Combat Sounds

### Weapon Fire Sounds

```lua
local weapon_sounds = {
    -- Ballistic weapons
    assault_rifle = {
        fire = {
            files = {
                "assets/audio/weapons/rifle_fire_01.ogg",
                "assets/audio/weapons/rifle_fire_02.ogg",
                "assets/audio/weapons/rifle_fire_03.ogg"
            },
            volume = 0.7,
            pitch_range = {0.95, 1.05},
            falloff_distance = 20  -- Grid units
        },
        reload = {
            file = "assets/audio/weapons/rifle_reload.ogg",
            volume = 0.5,
            duration = 1.5
        }
    },
    
    sniper_rifle = {
        fire = {
            files = {
                "assets/audio/weapons/sniper_fire_01.ogg",
                "assets/audio/weapons/sniper_fire_02.ogg"
            },
            volume = 0.9,
            pitch_range = {0.98, 1.02},
            falloff_distance = 30
        },
        reload = {
            file = "assets/audio/weapons/sniper_reload.ogg",
            volume = 0.6,
            duration = 2.0
        }
    },
    
    shotgun = {
        fire = {
            files = {
                "assets/audio/weapons/shotgun_fire_01.ogg",
                "assets/audio/weapons/shotgun_fire_02.ogg"
            },
            volume = 0.8,
            pitch_range = {0.90, 1.10},
            falloff_distance = 15
        },
        pump = {
            file = "assets/audio/weapons/shotgun_pump.ogg",
            volume = 0.5,
            delay = 0.3  -- Play after fire
        }
    },
    
    -- Energy weapons
    laser_pistol = {
        fire = {
            file = "assets/audio/weapons/laser_fire.ogg",
            volume = 0.6,
            pitch_range = {1.0, 1.2},
            falloff_distance = 25
        }
    },
    
    laser_rifle = {
        fire = {
            file = "assets/audio/weapons/laser_fire.ogg",
            volume = 0.7,
            pitch_range = {0.8, 1.0},
            falloff_distance = 30
        }
    },
    
    plasma_rifle = {
        fire = {
            file = "assets/audio/weapons/plasma_fire.ogg",
            volume = 0.8,
            pitch_range = {0.95, 1.05},
            falloff_distance = 30
        },
        charge = {
            file = "assets/audio/weapons/plasma_charge.ogg",
            volume = 0.4,
            duration = 0.5,
            play_before_fire = true
        }
    },
    
    -- Heavy weapons
    rocket_launcher = {
        fire = {
            file = "assets/audio/weapons/rocket_launch.ogg",
            volume = 1.0,
            pitch_range = {0.95, 1.05},
            falloff_distance = 40
        },
        whoosh = {
            file = "assets/audio/weapons/rocket_whoosh.ogg",
            volume = 0.7,
            duration = 1.0,
            play_during_flight = true
        }
    }
}

function play_weapon_sound(weapon_type, sound_type, position_3d)
    local weapon_config = weapon_sounds[weapon_type]
    if not weapon_config or not weapon_config[sound_type] then return end
    
    local sound_config = weapon_config[sound_type]
    local sound_file
    
    -- Select random variant if multiple files
    if sound_config.files then
        sound_file = sound_config.files[math.random(#sound_config.files)]
    else
        sound_file = sound_config.file
    end
    
    -- Load sound
    local sound = love.audio.newSource(sound_file, "static")
    
    -- Apply volume with distance falloff
    local volume = sound_config.volume
    if position_3d and sound_config.falloff_distance then
        local distance = calculate_distance_to_camera(position_3d)
        local falloff = math.max(0, 1.0 - (distance / sound_config.falloff_distance))
        volume = volume * falloff
    end
    sound:setVolume(volume * game.audio:get_combat_volume())
    
    -- Apply pitch variance
    if sound_config.pitch_range then
        local min_pitch, max_pitch = unpack(sound_config.pitch_range)
        local pitch = min_pitch + math.random() * (max_pitch - min_pitch)
        sound:setPitch(pitch)
    end
    
    -- Play sound
    sound:play()
    
    return sound
end
```

### Impact and Damage Sounds

```lua
local impact_sounds = {
    -- Hit impacts
    hit_flesh = {
        files = {
            "assets/audio/impacts/hit_flesh_01.ogg",
            "assets/audio/impacts/hit_flesh_02.ogg",
            "assets/audio/impacts/hit_flesh_03.ogg"
        },
        volume = 0.6
    },
    
    hit_armor = {
        files = {
            "assets/audio/impacts/hit_armor_01.ogg",
            "assets/audio/impacts/hit_armor_02.ogg"
        },
        volume = 0.7
    },
    
    hit_critical = {
        file = "assets/audio/impacts/hit_critical.ogg",
        volume = 0.9,
        pitch_range = {0.9, 1.1}
    },
    
    -- Miss impacts
    miss_dirt = {
        files = {
            "assets/audio/impacts/miss_dirt_01.ogg",
            "assets/audio/impacts/miss_dirt_02.ogg"
        },
        volume = 0.5
    },
    
    miss_concrete = {
        files = {
            "assets/audio/impacts/miss_concrete_01.ogg",
            "assets/audio/impacts/miss_concrete_02.ogg"
        },
        volume = 0.6
    },
    
    miss_metal = {
        file = "assets/audio/impacts/miss_metal.ogg",
        volume = 0.7
    }
}
```

### Explosion Sounds

```lua
local explosion_sounds = {
    grenade_small = {
        file = "assets/audio/explosions/grenade_small.ogg",
        volume = 0.8,
        falloff_distance = 25,
        screen_shake = 0.3
    },
    
    grenade_large = {
        file = "assets/audio/explosions/grenade_large.ogg",
        volume = 0.9,
        falloff_distance = 30,
        screen_shake = 0.5
    },
    
    rocket_explosion = {
        file = "assets/audio/explosions/rocket_explosion.ogg",
        volume = 1.0,
        falloff_distance = 40,
        screen_shake = 0.7
    },
    
    building_destruction = {
        file = "assets/audio/explosions/building_collapse.ogg",
        volume = 0.8,
        falloff_distance = 35,
        duration = 2.0
    }
}
```

### Movement Sounds

```lua
local movement_sounds = {
    -- Footsteps (different surfaces)
    footstep_concrete = {
        files = {
            "assets/audio/movement/step_concrete_01.ogg",
            "assets/audio/movement/step_concrete_02.ogg",
            "assets/audio/movement/step_concrete_03.ogg",
            "assets/audio/movement/step_concrete_04.ogg"
        },
        volume = 0.4,
        cadence = 0.5  -- Seconds between steps
    },
    
    footstep_dirt = {
        files = {
            "assets/audio/movement/step_dirt_01.ogg",
            "assets/audio/movement/step_dirt_02.ogg"
        },
        volume = 0.3,
        cadence = 0.5
    },
    
    footstep_metal = {
        files = {
            "assets/audio/movement/step_metal_01.ogg",
            "assets/audio/movement/step_metal_02.ogg"
        },
        volume = 0.5,
        cadence = 0.5
    },
    
    -- Doors
    door_open = {
        file = "assets/audio/movement/door_open.ogg",
        volume = 0.6
    },
    
    door_close = {
        file = "assets/audio/movement/door_close.ogg",
        volume = 0.6
    },
    
    -- Climbing
    ladder_climb = {
        file = "assets/audio/movement/ladder_climb.ogg",
        volume = 0.5,
        loop = true
    }
}

-- Footstep sequencer
function play_footsteps_during_movement(unit, path)
    local surface_type = get_surface_type(unit.position)
    local footstep_config = movement_sounds["footstep_" .. surface_type]
    
    local steps = math.floor(#path / 2)  -- One step per 2 tiles
    local step_delay = footstep_config.cadence
    
    for i = 1, steps do
        love.timer.sleep(step_delay)
        
        local sound_file = footstep_config.files[math.random(#footstep_config.files)]
        local sound = love.audio.newSource(sound_file, "static")
        sound:setVolume(footstep_config.volume * game.audio:get_combat_volume())
        sound:play()
    end
end
```

### Alien Vocalizations

```lua
local alien_sounds = {
    sectoid = {
        spot = {
            files = {
                "assets/audio/aliens/sectoid_spot_01.ogg",
                "assets/audio/aliens/sectoid_spot_02.ogg"
            },
            volume = 0.7
        },
        attack = {
            file = "assets/audio/aliens/sectoid_attack.ogg",
            volume = 0.6
        },
        hit = {
            files = {
                "assets/audio/aliens/sectoid_hit_01.ogg",
                "assets/audio/aliens/sectoid_hit_02.ogg"
            },
            volume = 0.6
        },
        death = {
            file = "assets/audio/aliens/sectoid_death.ogg",
            volume = 0.7
        }
    },
    
    floater = {
        spot = {
            file = "assets/audio/aliens/floater_spot.ogg",
            volume = 0.8
        },
        fly = {
            file = "assets/audio/aliens/floater_fly.ogg",
            volume = 0.5,
            loop = true
        },
        attack = {
            file = "assets/audio/aliens/floater_attack.ogg",
            volume = 0.7
        },
        death = {
            file = "assets/audio/aliens/floater_death.ogg",
            volume = 0.8
        }
    },
    
    muton = {
        spot = {
            file = "assets/audio/aliens/muton_spot.ogg",
            volume = 0.9
        },
        roar = {
            file = "assets/audio/aliens/muton_roar.ogg",
            volume = 0.9
        },
        attack = {
            file = "assets/audio/aliens/muton_attack.ogg",
            volume = 0.8
        },
        death = {
            file = "assets/audio/aliens/muton_death.ogg",
            volume = 0.9
        }
    },
    
    snakeman = {
        spot = {
            file = "assets/audio/aliens/snakeman_spot.ogg",
            volume = 0.7
        },
        hiss = {
            file = "assets/audio/aliens/snakeman_hiss.ogg",
            volume = 0.6
        },
        attack = {
            file = "assets/audio/aliens/snakeman_attack.ogg",
            volume = 0.7
        },
        death = {
            file = "assets/audio/aliens/snakeman_death.ogg",
            volume = 0.7
        }
    },
    
    ethereal = {
        spot = {
            file = "assets/audio/aliens/ethereal_spot.ogg",
            volume = 0.8
        },
        psionic = {
            file = "assets/audio/aliens/ethereal_psionic.ogg",
            volume = 0.9
        },
        attack = {
            file = "assets/audio/aliens/ethereal_attack.ogg",
            volume = 0.8
        },
        death = {
            file = "assets/audio/aliens/ethereal_death.ogg",
            volume = 0.9
        }
    }
}
```

---

## Music System

### Music Tracks

```lua
local music_tracks = {
    -- Main menu
    main_menu = {
        file = "assets/audio/music/main_menu.ogg",
        volume = 0.6,
        loop = true,
        duration = 180  -- 3 minutes
    },
    
    -- Geoscape (strategic layer)
    geoscape_calm = {
        file = "assets/audio/music/geoscape_calm.ogg",
        volume = 0.4,
        loop = true,
        duration = 240
    },
    
    geoscape_tension = {
        file = "assets/audio/music/geoscape_tension.ogg",
        volume = 0.5,
        loop = true,
        duration = 210,
        trigger = "ufo_detected OR multiple_threats"
    },
    
    -- Base management
    base_management = {
        file = "assets/audio/music/base_ambient.ogg",
        volume = 0.3,
        loop = true,
        duration = 300
    },
    
    -- Tactical combat (3 intensity levels)
    combat_exploration = {
        file = "assets/audio/music/combat_exploration.ogg",
        volume = 0.5,
        loop = true,
        duration = 180,
        trigger = "mission_start, no_enemies_visible"
    },
    
    combat_engagement = {
        file = "assets/audio/music/combat_engagement.ogg",
        volume = 0.6,
        loop = true,
        duration = 240,
        trigger = "enemies_spotted, combat_active"
    },
    
    combat_intense = {
        file = "assets/audio/music/combat_intense.ogg",
        volume = 0.7,
        loop = true,
        duration = 200,
        trigger = "soldier_wounded OR multiple_enemies OR low_hp"
    },
    
    -- Mission results
    victory = {
        file = "assets/audio/music/victory.ogg",
        volume = 0.7,
        loop = false,
        duration = 30
    },
    
    defeat = {
        file = "assets/audio/music/defeat.ogg",
        volume = 0.6,
        loop = false,
        duration = 30
    },
    
    -- Special events
    base_assault = {
        file = "assets/audio/music/base_assault.ogg",
        volume = 0.8,
        loop = true,
        duration = 240
    },
    
    final_mission = {
        file = "assets/audio/music/final_mission.ogg",
        volume = 0.8,
        loop = true,
        duration = 300
    }
}
```

### Music Manager

```lua
-- Music Manager (src/audio/music_manager.lua)
local MusicManager = {
    current_track = nil,
    next_track = nil,
    crossfade_duration = 2.0,  -- Seconds
    crossfading = false
}

function MusicManager:play_track(track_name, crossfade)
    local track_config = music_tracks[track_name]
    if not track_config then return end
    
    -- If already playing this track, do nothing
    if self.current_track and self.current_track.name == track_name then
        return
    end
    
    -- Load new track
    local new_source = love.audio.newSource(track_config.file, "stream")
    new_source:setLooping(track_config.loop)
    new_source:setVolume(0)  -- Start at 0 for fade-in
    
    if crossfade and self.current_track then
        -- Crossfade from current to new
        self:crossfade_to(new_source, track_config)
    else
        -- Stop current and play new immediately
        if self.current_track then
            self.current_track.source:stop()
        end
        
        new_source:setVolume(track_config.volume * game.audio:get_music_volume())
        new_source:play()
        
        self.current_track = {
            name = track_name,
            source = new_source,
            config = track_config
        }
    end
end

function MusicManager:crossfade_to(new_source, new_config)
    self.crossfading = true
    self.next_track = {
        source = new_source,
        config = new_config,
        target_volume = new_config.volume * game.audio:get_music_volume()
    }
    
    -- Start new track at 0 volume
    new_source:play()
end

function MusicManager:update(dt)
    if not self.crossfading then return end
    
    local fade_speed = 1.0 / self.crossfade_duration
    local volume_change = fade_speed * dt
    
    -- Fade out current track
    if self.current_track then
        local current_volume = self.current_track.source:getVolume()
        current_volume = math.max(0, current_volume - volume_change)
        self.current_track.source:setVolume(current_volume)
        
        if current_volume <= 0 then
            self.current_track.source:stop()
        end
    end
    
    -- Fade in next track
    if self.next_track then
        local next_volume = self.next_track.source:getVolume()
        next_volume = math.min(self.next_track.target_volume, next_volume + volume_change)
        self.next_track.source:setVolume(next_volume)
        
        -- Complete crossfade
        if next_volume >= self.next_track.target_volume then
            self.current_track = {
                name = self.next_track.config.name,
                source = self.next_track.source,
                config = self.next_track.config
            }
            self.next_track = nil
            self.crossfading = false
        end
    end
end

function MusicManager:stop(fade_out)
    if fade_out then
        -- Crossfade to silence
        self.next_track = nil
        self.crossfading = true
    else
        -- Stop immediately
        if self.current_track then
            self.current_track.source:stop()
            self.current_track = nil
        end
    end
end
```

### Dynamic Music Triggers

```lua
function update_combat_music(combat_state)
    local intensity = calculate_combat_intensity(combat_state)
    
    if intensity < 0.3 then
        -- Low intensity: exploration music
        game.music:play_track("combat_exploration", true)
        
    elseif intensity < 0.7 then
        -- Medium intensity: engagement music
        game.music:play_track("combat_engagement", true)
        
    else
        -- High intensity: intense combat music
        game.music:play_track("combat_intense", true)
    end
end

function calculate_combat_intensity(state)
    local intensity = 0.0
    
    -- Factor 1: Visible enemies (0.0 - 0.4)
    local enemy_factor = math.min(0.4, state.visible_enemies * 0.1)
    intensity = intensity + enemy_factor
    
    -- Factor 2: Soldier HP (0.0 - 0.3)
    local avg_hp_percent = calculate_average_soldier_hp(state.soldiers)
    local hp_factor = (1.0 - avg_hp_percent) * 0.3
    intensity = intensity + hp_factor
    
    -- Factor 3: Recent damage (0.0 - 0.3)
    local damage_factor = math.min(0.3, state.damage_taken_this_turn / 20.0)
    intensity = intensity + damage_factor
    
    return intensity
end
```

---

## Ambient Audio

### Environment Loops

```lua
local ambient_loops = {
    -- Outdoor environments
    forest_ambient = {
        file = "assets/audio/ambient/forest.ogg",
        volume = 0.3,
        loop = true
    },
    
    urban_ambient = {
        file = "assets/audio/ambient/urban.ogg",
        volume = 0.4,
        loop = true
    },
    
    desert_ambient = {
        file = "assets/audio/ambient/desert.ogg",
        volume = 0.2,
        loop = true
    },
    
    -- Indoor environments
    base_hum = {
        file = "assets/audio/ambient/base_hum.ogg",
        volume = 0.2,
        loop = true
    },
    
    lab_ambient = {
        file = "assets/audio/ambient/lab.ogg",
        volume = 0.3,
        loop = true
    },
    
    -- Weather
    rain_light = {
        file = "assets/audio/ambient/rain_light.ogg",
        volume = 0.4,
        loop = true
    },
    
    rain_heavy = {
        file = "assets/audio/ambient/rain_heavy.ogg",
        volume = 0.5,
        loop = true
    },
    
    wind = {
        file = "assets/audio/ambient/wind.ogg",
        volume = 0.3,
        loop = true
    }
}
```

---

## Volume Mixing and Priorities

### Audio Priority System

```lua
local AudioMixer = {
    volumes = {
        master = 1.0,
        music = 0.6,
        combat = 0.8,
        ui = 0.7,
        ambient = 0.4,
        voice = 0.9
    },
    
    priorities = {
        critical = 10,  -- Alerts, warnings
        high = 8,       -- Combat sounds
        medium = 5,     -- Music, voice
        low = 3,        -- UI sounds
        ambient = 1     -- Background loops
    }
}

function AudioMixer:play_sound(sound_config, category, priority)
    local volume = sound_config.volume
    volume = volume * self.volumes[category]
    volume = volume * self.volumes.master
    
    -- Check if channel available
    local channel = self:allocate_channel(priority)
    if not channel then
        return nil  -- No channels available
    end
    
    local sound = love.audio.newSource(sound_config.file, "static")
    sound:setVolume(volume)
    sound:play()
    
    return sound
end

function AudioMixer:allocate_channel(priority)
    local active_sources = love.audio.getActiveSourceCount()
    
    if active_sources < 27 then
        return true  -- Channel available
    end
    
    -- Need to evict lower priority sound
    -- (Implementation would track active sounds with priorities)
    return self:evict_lower_priority_sound(priority)
end

function AudioMixer:set_volume(category, volume)
    self.volumes[category] = math.clamp(volume, 0.0, 1.0)
    
    -- Update all active sounds in category
    -- (Implementation would track active sounds by category)
end

function AudioMixer:get_volume(category)
    return self.volumes[category]
end
```

---

## Asset Specifications

### Audio File Format Standards

```
Format: OGG Vorbis (.ogg)
  Reason: Good compression, looping support, royalty-free

Sample Rates:
  Music: 44.1 kHz stereo
  Combat: 44.1 kHz mono/stereo
  UI: 22.05 kHz mono
  Ambient: 44.1 kHz stereo

Bit Depth: 16-bit

Compression Quality:
  Music: Quality 6-8 (192-256 kbps)
  Combat: Quality 5-6 (160-192 kbps)
  UI: Quality 4-5 (128-160 kbps)
  Ambient: Quality 5-6 (160-192 kbps)

Duration Limits:
  UI sounds: < 1 second
  Combat sounds: < 3 seconds
  Music: 2-5 minutes (loopable)
  Ambient: 1-2 minutes (seamless loops)
```

### File Naming Convention

```
{category}_{subcategory}_{descriptor}_{variant}.ogg

Examples:
  ui_button_click_01.ogg
  weapon_rifle_fire_02.ogg
  alien_sectoid_death.ogg
  music_combat_intense.ogg
  ambient_forest_loop.ogg
  impact_armor_hit_03.ogg
```

---

## Implementation Notes

### Love2D Audio Manager

```lua
-- Audio Manager (src/audio/audio_manager.lua)
local AudioManager = {
    mixer = AudioMixer,
    music_manager = MusicManager,
    
    sound_cache = {},  -- Preloaded frequently-used sounds
    max_cache_size = 50
}

function AudioManager:init()
    -- Set audio distance model
    love.audio.setDistanceModel("linear")
    
    -- Preload common sounds
    self:preload_common_sounds()
    
    -- Load volume settings from save
    self:load_volume_settings()
end

function AudioManager:preload_common_sounds()
    local common_sounds = {
        "ui/button_click.ogg",
        "ui/button_hover.ogg",
        "weapons/rifle_fire_01.ogg",
        "impacts/hit_flesh_01.ogg",
        -- ... more common sounds
    }
    
    for _, sound_path in ipairs(common_sounds) do
        local full_path = "assets/audio/" .. sound_path
        self.sound_cache[sound_path] = love.audio.newSource(full_path, "static")
    end
end

function AudioManager:play(sound_config, category, position_3d)
    local priority = sound_config.priority or "medium"
    return self.mixer:play_sound(sound_config, category, priority)
end

function AudioManager:save_settings()
    return {
        master_volume = self.mixer.volumes.master,
        music_volume = self.mixer.volumes.music,
        combat_volume = self.mixer.volumes.combat,
        ui_volume = self.mixer.volumes.ui,
        ambient_volume = self.mixer.volumes.ambient,
        voice_volume = self.mixer.volumes.voice
    }
end

function AudioManager:load_settings(data)
    for category, volume in pairs(data) do
        self.mixer:set_volume(category:gsub("_volume", ""), volume)
    end
end
```

---

## Cross-References

### Related Systems
- [Accessibility](Accessibility.md) - Audio accessibility options
- [UI System](../widgets/README.md) - UI sound integration
- [Combat](../battlescape/README.md) - Combat audio triggers
- [Save System](../technical/Save_System.md) - Persist audio settings

---

**Version:** 1.0  
**Last Updated:** September 30, 2025  
**Status:** Complete
