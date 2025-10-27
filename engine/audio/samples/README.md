# MIDI Samples Directory

This directory is where you place audio samples for MIDI playback. The MidiPlayer will automatically load samples from here for high-quality soundfont-like playback.

## How to Set Up Samples

1. **Extract samples from SF2 soundfont**:
   - Use tools like [Polyphone](https://www.polyphone-soundfonts.com/) to extract individual samples from SF2 files
   - Or use command-line tools like `sf2extract` or `fluidsynth` with appropriate options

2. **File naming convention**:
   - Name files as `note_[MIDINoteNumber].[extension]`
   - Supported formats: `.wav`, `.ogg`, `.mp3`
   - Examples:
     - `note_60.wav` (Middle C)
     - `note_61.wav` (C#)
     - `note_62.wav` (D)
     - etc.

3. **MIDI Note Numbers**:
   - 0-127 (full MIDI range)
   - 60 = Middle C (C4)
   - 69 = A4 (440Hz)
   - 72 = C5

## Directory Structure Options

### Option 1: Single instrument
```
samples/
├── note_60.wav
├── note_61.wav
├── note_62.wav
└── ...
```

### Option 2: Multiple instruments (future enhancement)
```
samples/
├── piano/
│   ├── note_60.wav
│   └── ...
├── drums/
│   ├── note_36.wav  (bass drum)
│   ├── note_38.wav  (snare)
│   └── ...
└── strings/
    └── ...
```

## Sample Requirements

- **Format**: Mono audio files
- **Sample Rate**: 44100Hz recommended (Love2D default)
- **Bit Depth**: 16-bit recommended
- **Length**: Each sample should be the full note duration
- **Quality**: Clean attack, no silence at beginning

## Tools for SF2 Extraction

1. **Polyphone** (Free, GUI):
   - Open SF2 file
   - Select samples
   - Export as WAV

2. **Command Line**:
   ```bash
   # Using fluidsynth to extract samples
   fluidsynth -F output.wav soundfont.sf2 -T wav -g 1.0 -r 44100 "C4"
   ```

3. **Online Converters**:
   - Various online SF2 to WAV converters

## Current Status

The MidiPlayer will automatically detect and load samples from this directory. If no samples are found, it falls back to synthesized tones.

**To test**: Place some sample files here and click "TEST MIDI" in the game menu.
