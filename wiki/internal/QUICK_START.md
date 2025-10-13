# XCOM Simple - Quick Start Guide

## Installation (5 minutes)

### Step 1: Install Love2D
1. Go to https://love2d.org/
2. Download **Love2D 12.0** for your operating system
3. Install it (default location is fine)

### Step 2: Run the Game

**Windows - Easy Method:**
1. Double-click `run_game.bat` in the project folder
2. The game will start automatically

**Windows - Manual Method:**
```
"C:\Program Files\LOVE\love.exe" "engine"
```

**Mac:**
```bash
love /Users/tombl/Documents/Projects/xcom_simple
```

**Linux:**
```bash
love ~/Documents/Projects/xcom_simple
```

## First Time Playing

### Main Menu
You'll see four options:
1. **GEOSCAPE** - World map (strategic layer)
2. **BATTLESCAPE DEMO** - Tactical combat
3. **BASESCAPE** - Base management
4. **QUIT** - Exit game

**Tip:** Start with BATTLESCAPE to try the combat, or GEOSCAPE to see the world map.

## Module Guides

### 🌍 GEOSCAPE (World Map)

**What you see:**
- 7 provinces connected like a Risk board
- Lines showing connections between provinces
- North America has a yellow dot (your base)

**What to do:**
1. **Click on any province** - It turns orange and shows info
2. **Check the info panel** (bottom-left) - Shows population, satisfaction, funding
3. **Press SPACE** - Pause/resume time
4. **Watch the day counter** - Top center shows game time

**Tips:**
- Green provinces have bases (only North America at start)
- Hover over provinces to preview info
- Time advances automatically when not paused

### ⚔️ BATTLESCAPE (Tactical Combat)

**What you see:**
- Grid map with tiles (24x24 pixels each)
- Green circles = Your soldiers (4 units)
- Red circles = Aliens (3 units)
- Black areas = Unexplored (fog of war)
- Gray areas = Explored but not currently visible

**What to do:**
1. **Click a green soldier** - Selects unit (yellow highlight appears)
2. **Blue overlay appears** - Shows where unit can move
3. **Click a blue tile** - Unit moves there (costs Time Units)
4. **Watch the TU counter** - Bottom-left info panel
5. **Click "END TURN"** - Ends your turn (enemies get their turn)

**Important:**
- Each unit has 80 Time Units (TU)
- Moving costs 4 TU per tile
- When TU runs out, you can't move that unit
- END TURN restores all TU

**Tips:**
- Use **WASD or Arrow Keys** to pan the camera around
- Health bars show under each unit (green = healthy)
- Selected unit info shows in bottom-left panel
- Explored areas stay visible (darker shade)

### 🏢 BASESCAPE (Base Management)

**What you see:**
- 6x6 grid of facility slots
- 3 starting facilities:
  - Blue = Command Center
  - Green = Living Quarters  
  - Brown = Hangar
- Four view mode buttons on the left

**Four Views:**

**1. FACILITIES (Default)**
- Shows your base grid
- Hover over facilities to see details
- Empty gray slots can be built on (not yet implemented)

**2. SOLDIERS**
- Lists your 4 starting soldiers
- Shows: Name, Health, Accuracy, Rank
- These are the units you use in combat

**3. RESEARCH**
- 3 available projects:
  - Laser Weapons (20 days)
  - Personal Armor (15 days)
  - Advanced Radar (10 days)
- Not yet startable (coming soon)

**4. MANUFACTURING**
- Production queue (empty at start)
- Will be used to build items

**Right Panel (Info):**
- Shows details about current view
- Always displays monthly budget:
  - Income: +$500,000
  - Expenses: -$150,000
  - Balance: +$350,000/month

**Tips:**
- Use number keys 1-4 to quickly switch views
- Starting funds: $1,000,000
- Green balance = profit, Red = loss

## Controls Summary

### All Screens
- **Mouse** - Click to interact
- **ESC** - Return to menu (or quit from menu)

### Geoscape
- **Click province** - Select it
- **Space** - Pause/resume

### Battlescape
- **Click unit** - Select (shows movement range)
- **Click tile** - Move selected unit
- **WASD / Arrow Keys** - Pan camera
- **Space** - End turn

### Basescape
- **1** - Facilities view
- **2** - Soldiers view
- **3** - Research view
- **4** - Manufacturing view

## Troubleshooting

### "Love2D not found" error
- Make sure Love2D 12.0 is installed
- Try the manual method with the full path
- Check installation location matches the path in the command

### Game crashes immediately
- Check console window for error messages
- Make sure all files are present in the folder
- Try running from command line to see errors

### Controls don't work
- Click on the game window to give it focus
- Make sure you're in the right screen (check title/buttons)
- Some features are not yet implemented (see docs)

### Can't see units in Battlescape
- They might be in unexplored areas (black)
- Pan camera with WASD to find them
- Player units start on the left, aliens on the right

## What's Not Implemented Yet

❌ **Combat shooting** - Units can move but not shoot yet  
❌ **Research starting** - Can view but not start projects  
❌ **Facility building** - Can't build new facilities yet  
❌ **Geoscape missions** - Can't launch missions yet  
❌ **Save/Load** - No save system yet  
❌ **Sound/Music** - Silent for now  

These features are planned but not in version 0.1.0.

## Tips for Exploration

### For Programmers:
- Check `GAME_DESIGN_DOCUMENT.md` for full design
- Read `IMPLEMENTATION_SUMMARY.md` for technical details
- Code is heavily commented - read the source!
- Console shows debug messages (enabled in conf.lua)

### For Players:
- This is a prototype - many features are basic
- Try all three modules to see different systems
- Imagine what it could become with more features!
- Feel free to experiment - you can't break anything

## Next: Read the Full Docs

- **README.md** - Full feature list and documentation
- **GAME_DESIGN_DOCUMENT.md** - Complete game design
- **IMPLEMENTATION_SUMMARY.md** - What's built and what's next

## Have Fun!

This is a simplified XCOM experience focused on core mechanics. Explore the three modules, try moving units in combat, check out your base, and see the strategic map!

---

**Questions?** Check the README.md or console output for debug info.  
**Want to extend it?** The code is modular and well-commented - dive in!
