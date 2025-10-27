# lovemidi - Native MIDI Playback for Love2D

This directory contains the lovemidi wrapper for native MIDI playback on Windows.

## Requirements

**Important:** You need to download `midi.dll` to enable real MIDI audio playback.

### Download midi.dll

1. Visit: https://github.com/SiENcE/lovemidi
2. Download the latest release or build from source
3. Extract `midi.dll` from the package
4. Place it in one of these locations:
   - `engine/libs/lovemidi/midi.dll` (recommended)
   - `midi.dll` (game root directory)

### Without midi.dll

If `midi.dll` is not found, the game will fall back to the parser-only MIDI player (which parses MIDI files but doesn't produce audio).

## Features

When `midi.dll` is available:
- ✅ **Real audio playback** through Windows MIDI API
- ✅ **Native quality** using system MIDI synthesizer
- ✅ **Play/Pause/Stop controls**
- ✅ **Volume control** (0-127)
- ✅ **Seek** to any position in the song
- ✅ **Position and length** tracking

## Usage

The lovemidi wrapper is automatically integrated into the AudioManager:

```lua
local AudioManager = require("core.audio_manager")

-- Play MIDI file (uses native player if midi.dll is available)
AudioManager:playMIDI("Metallica_-_Hit_The_Lights")

-- Control playback
AudioManager:stopMIDI()
AudioManager:pauseMIDI()
AudioManager:resumeMIDI()

-- Volume (0-1)
AudioManager:setMIDIVolume(0.6)
```

## Technical Details

- **Platform:** Windows only (uses Windows MIDI API via FFI)
- **Format:** Standard MIDI files (.mid, .midi)
- **Channels:** Supports all 16 MIDI channels
- **Instruments:** Uses Windows General MIDI soundfont

## Troubleshooting

### No audio when playing MIDI

1. Check console for `[lovemidi] ERROR: Could not load midi.dll`
2. Download and place `midi.dll` as described above
3. Restart the game

### "lovemidi not available" message

This means the DLL wasn't found. The game will work but MIDI files won't produce audio (parser-only mode).

### MIDI sounds wrong

Windows uses its built-in General MIDI synthesizer. The quality depends on your system:
- Windows 10/11: Uses Microsoft GS Wavetable Synth (decent quality)
- Older Windows: May use lower quality synthesis

For better quality, consider using a VST host or SoundFont player.

## Building midi.dll

If you want to build from source:

1. Clone: https://github.com/SiENcE/lovemidi
2. Follow build instructions in the repository
3. Compile for your target architecture (x64/x86)
4. Place the resulting DLL in this directory

## Credits

- lovemidi by SiENcE: https://github.com/SiENcE/lovemidi
- Based on Windows MIDI API

## License

lovemidi is subject to its own license. Check the original repository for details.

