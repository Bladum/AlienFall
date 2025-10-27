# SF2 Soundfont Integration Guide for AlienFall MIDI Player

## Quick Start: Get Professional MIDI Sounds in 10 Minutes ⚡

### What is SF2?

SF2 (SoundFont 2) is a file format containing **pre-recorded instrument samples** with metadata about how to play them. Instead of generating beeps, your MIDI player uses real piano, drums, strings, etc. sounds.

### The Problem We're Solving

Current state:
```
MIDI File (5925 notes) → Sine Wave Tones → "Beeeep beeeep beeeep"
```

Desired state:
```
MIDI File (5925 notes) → SF2 Samples → Beautiful Piano & Drums 🎹🥁
```

## Method 1: Download Pre-Extracted Samples ⭐ EASIEST

### Option A: GeneralUser GM (Recommended)

1. **Download**: https://www.schristiancollins.com/generaluser.php
2. **Extract ZIP** to get `GeneralUser GS 1.471.sf2`

### Option B: FluidR3

1. **Already included** with FluidSynth if you have it
2. Usually at: `C:\Program Files\FluidSynth\share\soundfonts\FluidR3_GM.sf2`

## Method 2: Extract Samples Using Polyphone 🛠️

### Installation

1. Download Polyphone: https://www.polyphone-soundfonts.com/
2. Install it (it's free and open-source)

### Extraction Process

1. **Open SF2 File**
   - File → Open
   - Select your SF2 file (e.g., `GeneralUser GS 1.471.sf2`)

2. **Select Preset** (Instrument)
   - Find "Piano" or "Acoustic Grand Piano" in the list
   - Click it

3. **Export Samples**
   - Right-click the preset
   - Select "Export as audio files"
   - Choose folder: `engine/audio/samples/`
   - Format: **WAV** (required for Love2D)
   - It will extract individual note samples: `note_60.wav`, `note_61.wav`, etc.

4. **For Drums**
   - Go to preset **128** (Drums channel)
   - Export again (these use different note mappings)
   - The samples will be named `note_36.wav` through `note_81.wav` (drum range)

### Example Output Structure

After extracting Piano:
```
engine/audio/samples/
├── note_0.wav
├── note_1.wav
├── note_2.wav
...
├── note_60.wav  ← Middle C (Piano)
├── note_61.wav
├── note_62.wav
...
└── note_127.wav
```

## Method 3: Extract Samples Using sf2extract (CLI) 🖥️

### For Windows PowerShell Users

1. **Clone sf2extract**
   ```powershell
   git clone https://github.com/sinshu/sf2extract
   cd sf2extract
   cargo build --release
   ```

2. **Extract Piano Samples**
   ```powershell
   # Extract preset 0 (Acoustic Grand Piano)
   sf2extract.exe "GeneralUser GS 1.471.sf2" 0 "engine/audio/samples/"
   ```

3. **Extract Drum Samples**
   ```powershell
   # Extract preset 128 (Drums)
   sf2extract.exe "GeneralUser GS 1.471.sf2" 128 "engine/audio/samples/drums/"
   ```

## Method 4: Online Extraction 🌐

### Viena (No Installation Needed!)

1. Go to: https://viena.firebaseapp.com/
2. Upload your SF2 file
3. Download extracted samples as ZIP
4. Extract to `engine/audio/samples/`

## Directory Structure Required

Your system expects this exact layout:

```
engine/
└── audio/
    └── samples/
        ├── note_0.wav    (C-1)
        ├── note_1.wav    (C#-1)
        ├── note_2.wav    (D-1)
        ...
        ├── note_60.wav   (C4 - Middle C) ⭐ Queen song uses this range
        ├── note_61.wav   (C#4)
        ├── note_62.wav   (D4)
        ...
        ├── note_127.wav  (G8)
```

**IMPORTANT**: File names MUST follow the pattern `note_N.wav` where N is 0-127.

## MIDI Note Mapping Reference

```
Note #  Note Name  Octave  Scientific Pitch
0       C          -1      C-1
12      C          0       C0
24      C          1       C1
...
60      C          4       C4 (Middle C) ⭐
69      A          4       A4 (Concert Pitch - 440 Hz)
...
127     G          8       G8
```

### Queen Bohemian Rhapsody Uses

- **Channels 1-9**: Piano mainly around **C4-C6** (notes 60-84)
- **Channels 10-14**: Drums around **C2-C3** (notes 36-59)

**You MUST have samples for notes 36-84 minimum!**

## Automatic Loading

Once you create `engine/audio/samples/` with WAV files, the system:

1. **Auto-detects** the samples directory
2. **Loads** all note files automatically
3. **Uses** them for playback instead of tone synthesis

**No code changes needed!** The midi_player.lua function `loadSamples()` handles it:

```lua
function MidiPlayer:loadSamples()
    -- Try to load samples from engine/audio/samples/ directory
    local sampleDirs = {"engine/audio/samples", "samples"}

    for _, baseDir in ipairs(sampleDirs) do
        for note = 0, 127 do
            local samplePath = baseDir .. "/note_" .. note .. ".wav"
            -- ... loads if exists
        end
    end
end
```

## Testing Your Setup

1. Extract samples to `engine/audio/samples/`
2. Run the game: `lovec engine`
3. It should automatically load the samples
4. Press **Play** in MIDI Test Screen
5. **Listen for real instrument sounds instead of beeps!** 🎵

## Console Output When Samples Are Loaded

```
[MidiPlayer] Loaded 128 samples from engine/audio/samples
[MidiPlayer] Playing sampled note: pitch=60, velocity=100, channel=0
[MidiPlayer] Playing sampled note: pitch=64, velocity=95, channel=0
```

vs. Without Samples:

```
[MidiPlayer] No sample directory found, using tone synthesis fallback
[MidiPlayer] Playing tone: pitch=60, freq=261.63, time=0.000, duration=1.000
```

## Recommended SF2 Files for Queen

### GeneralUser GM ⭐ (Best for this song)
- **Size**: ~15 MB
- **Quality**: High
- **License**: Creative Commons (Free)
- **Download**: https://www.schristiancollics.com/generaluser.php
- **Why**: Excellent Piano, authentic Drums, same era as Queen

### FluidR3 GM (Professional)
- **Size**: ~148 MB
- **Quality**: Very High
- **License**: SoundFont 3 (Free)
- **Why**: Full-featured, excellent for game music

### Unison (Modern)
- **Size**: ~50 MB
- **Quality**: High
- **License**: Creative Commons
- **Why**: Bright modern sound, great for atmosphere

## Troubleshooting Sample Loading

### Problem: "No sample directory found"

**Check**:
1. Directory exists: `engine/audio/samples/`
2. Files are named: `note_N.wav` (lowercase, underscore, no spaces)
3. Files are format: WAV or OGG (not MP3)
4. Files are readable by Love2D (< 2GB each)

### Problem: Samples load but sound wrong

**Possible causes**:
1. Wrong preset extracted (not Piano or Drums)
2. Different octave range than expected
3. File corruption during extraction

**Solution**: Re-extract using Polyphone, ensure you select the correct preset

### Problem: Some notes missing

**Normal behavior**: If you extracted only Piano (notes 60-84), only those notes will play. Other notes fall back to tone synthesis automatically.

**To fill in gaps**: Extract multiple instruments to different folders or merge them.

## Quick Reference: Common Presets in SF2

| Preset # | Instrument | Note Range |
|----------|------------|------------|
| 0 | Acoustic Grand Piano | 0-127 (all) |
| 32 | Acoustic Bass | 28-92 |
| 48 | String Ensemble 1 | 0-127 |
| 128 | Drums (Special) | 36-81 |

**Preset 128** is special - it uses drum voices instead of pitched notes:
- Note 36 = Kick drum
- Note 38 = Snare drum
- Note 42 = Closed hi-hat
- Note 46 = Open hi-hat
- Etc.

## One-Liner Guide

**For Windows Users**:

1. Download GeneralUser: https://www.schristiancollins.com/generaluser.php
2. Extract ZIP
3. Open `GeneralUser GS 1.471.sf2` in Polyphone
4. Select "Acoustic Grand Piano" (preset 0)
5. Right-click → Export as audio files
6. Folder: `C:\Users\[YOU]\Documents\Projects\engine\audio\samples\`
7. Format: WAV
8. Done! Run game and click Play

## Next: Integration with FluidSynth (Advanced)

Once you have samples working, you can optionally add **real-time SF2 synthesis** using:

- **TinySoundFont**: Single-file C library (recommended for Love2D)
- **FluidSynth**: Professional synthesizer
- **Both** preserve audio quality without pre-extracting samples

See `docs/MIDI_PLAYER_SYSTEM.md` for advanced integration details.

## Summary

✅ **Simple Path**: Download GeneralUser, use Polyphone, export WAV files to `engine/audio/samples/`

✅ **Fast Path**: Use Viena online (no installation)

✅ **Professional Path**: Use sf2extract CLI for batch processing

✅ **Automatic**: Once files are in place, everything works automatically!

**Time needed**: ~10 minutes from download to first professional-quality MIDI playback 🎵

---

**You're now ready to hear Queen - Bohemian Rhapsody with real piano and drums sounds!**
