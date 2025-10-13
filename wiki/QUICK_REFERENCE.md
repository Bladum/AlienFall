# Alien Fall - Quick Reference Card
## Battlescape Controls & Features

### 🎮 Mouse Controls
| Button | Action | Description |
|--------|--------|-------------|
| **LMB** | Select/Move | Click unit to select, click tile to move |
| **RMB** | Deselect/Action | Click empty to deselect, unit to take action |
| **Minimap** | Quick Travel | Click minimap to move camera |

### ⌨️ Keyboard Shortcuts
| Key | Action | Description |
|-----|--------|-------------|
| **ESC** | Exit | Return to main menu |
| **SPACE** | Next Team | Switch to next team's turn |
| **F4** | Day/Night | Toggle time of day (15/10 sight) |
| **F5** | Save Map | Export map as PNG to TEMP folder |
| **F8** | Toggle FOW | Show/hide fog of war overlay |
| **F9** | Hex Grid | Show/hide hex grid overlay |
| **F10** | Debug | Toggle debug information |
| **↑↓←→** | Camera | Pan camera view |

### 🎨 Team Colors
| Team | Color | RGB |
|------|-------|-----|
| Team 1 | 🔴 Red | (1.0, 0.0, 0.0) |
| Team 2 | 🔵 Blue | (0.0, 0.0, 1.0) |
| Team 3 | 🟢 Green | (0.0, 1.0, 0.0) |
| Team 4 | 🟡 Yellow | (1.0, 1.0, 0.0) |
| Team 5 | 🟣 Purple | (1.0, 0.0, 1.0) |
| Team 6 | 🔷 Cyan | (0.0, 1.0, 1.0) |

### 🗺️ Map Information
- **Size:** 90×90 tiles (8,100 total)
- **Teams:** 6 teams per battle
- **Units:** 12-36 per team (random)
- **Total Units:** 72-216 units possible

### 🌳 Terrain Types
| Terrain | Move Cost | Sight Cost | Description |
|---------|-----------|------------|-------------|
| **Floor** | 2 MP | 1 | Normal ground |
| **Road** | 1 MP | 1 | Fast travel path |
| **Rough** | 4 MP | 1 | Difficult terrain |
| **Slope** | 6 MP | 1 | Steep hill |
| **Bushes** | 2 MP | 5 | Concealing vegetation |
| **Tree** | 99 MP | 3 | Single tree, hard to pass |
| **Trees** | 4 MP | 1000 | Dense forest, blocks sight |
| **Wall** | 0 MP | 1000 | Stone wall, impassable |
| **Wood Wall** | 0 MP | 1000 | Wooden wall, impassable |
| **Water** | 8 MP | 1 | Shallow water |

### 📊 Unit Stats
- **Action Points (AP):** 4 per turn
- **Movement Points (MP):** 24 per turn (4 AP × 6 speed)
- **Sight Range (Day):** 15 tiles
- **Sight Range (Night):** 10 tiles
- **Health:** Varies by unit type

### 🗺️ Map Features
**Wooden Rooms (3 total)**
- Size: 8×6 tiles
- Walls: Wood wall perimeter
- Interior: Floor tiles
- Provides: Cover and chokepoints

**Tree Groves (3 total)**
- Size: 8×8 to 10×10 tiles
- Density: ~70% tree coverage
- Blocks: Partial sight (3 cost)
- Very slow: 99 MP to traverse

**Roads/Paths (2 total)**
- Width: 3 tiles
- Speed: 1 MP (fast travel)
- Connect: Different map quadrants

### 🎯 Minimap Legend
| Color | Meaning |
|-------|---------|
| ⬛ Black | Unexplored terrain |
| ▪️ Dark Gray | Impassable terrain |
| ▫️ Light Gray | Passable terrain |
| 🔴🔵🟢🟡🟣🔷 | Team colored units |

### 💡 Tips & Tricks
1. **Use roads** for fast repositioning (1 MP vs 2 MP)
2. **Trees block sight** but not movement (except single trees)
3. **Night reduces sight** from 15 to 10 tiles
4. **Yellow dots** show what selected unit can see
5. **RMB on empty tile** to quickly deselect
6. **F5 to save map** for external editing
7. **Minimap click** for quick camera movement
8. **Team colors** help identify friend from foe

### 🎬 Turn Order
1. Select your unit (LMB)
2. See movement range (green tiles)
3. See sight range (yellow dots)
4. Click destination or RMB to deselect
5. Press SPACE when done to switch teams

### 🔧 Advanced Features
- **Map Export:** Press F5 to save as PNG (1 pixel = 1 tile)
- **Map Location:** Saved to `%TEMP%\battlefield_[timestamp].png`
- **Edit Maps:** Open PNG in image editor, change pixel colors
- **Terrain Colors:** Each terrain has unique RGB value
- **Future:** Map import from edited PNG files

### 📝 Notes
- Game auto-saves team visibility (fog of war)
- Units show health bars when damaged
- Camera follows selected unit during movement
- Switching teams resets overlays and centers camera
- Day/night cycle affects ALL team sight ranges equally

### 🐛 Known Limitations
- RMB action on units is placeholder (future: attack/interact)
- Map loading from PNG not yet implemented
- Performance untested with 200+ units
- Hex layout is vertical (skewed layout planned for future)

---

**Version:** 1.0 (2025-10-12)  
**For:** Alien Fall  
**Engine:** Love2D 12.0+

