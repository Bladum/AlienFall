# 📊 Docs Folder: Current vs Proposed Structure Diagram

**Visual comparison of documentation organization before and after recommended changes**

---

## 🔴 CURRENT STRUCTURE (Problems Highlighted)

```
docs/ (58 items)
│
├── 📄 README.md ........................ Folder intro & standards
├── 📄 OVERVIEW.md ..................... Game overview (186 lines)
├── 📄 QUICK_NAVIGATION.md ............ Index of docs (355 lines) ← OVERLAP
├── 📄 API.md .......................... Technical reference (1,811 lines)
├── 📄 FAQ.md
├── 📄 GLOSSARY.md
├── 📄 DEVELOPMENT.md
│
├── 🔴 AI/ ............................ ❌ NO README, unclear structure
│   ├── diplomacy/
│   ├── pathfinding/
│   ├── strategic/
│   └── tactical/
│
├── 🔴 ANALYTICS/ ..................... ❌ EMPTY?
│
├── 📁 ASSETS/
│   ├── audio.md
│   └── graphics.md
│
├── 🔴 BALANCE/ ....................... ⚠️ DUPLICATE
│   └── GAME_NUMBERS.md (276 lines)
│
├── 🔴 BALANCING/ ..................... ⚠️ DUPLICATE - CONSOLIDATE
│   └── framework.md (148 lines) - BALANCE FRAMEWORK
│
├── 📁 BASESCAPE/
│   ├── README.md
│   ├── base/
│   ├── data/
│   ├── facilities/
│   ├── logic/
│   └── services/
│
├── 🔴 BATTLESCAPE/ ................... ⚠️ MIXED design + technical
│   ├── README.md
│   ├── 3D_BATTLESCAPE_ARCHITECTURE.md ❌ SHOULD BE: technical/
│   ├── 3D_BATTLESCAPE_SUMMARY.md ❌ SHOULD BE: technical/
│   ├── QUICK_REFERENCE.md
│   ├── COMBAT_SYSTEMS_COMPLETE.md ❌ SHOULD BE: technical/
│   ├── ECS_BATTLE_SYSTEM_API.md ❌ SHOULD BE: technical/
│   ├── armors.md
│   ├── weapons.md
│   ├── maps.md
│   ├── ai-system/
│   ├── combat-mechanics/
│   ├── map-generation/
│   ├── map-system/
│   ├── mission-system/
│   └── unit-systems/
│
├── 🔴 CONTENT/ ...................... ⚠️ Unclear parent structure
│   ├── items.md
│   ├── crafts/
│   ├── equipment/
│   ├── facilities/
│   └── units/
│
├── 📁 CORE/
│   ├── README.md
│   ├── concepts.md
│   ├── implementation.md
│   ├── physics.md
│   ├── LUA_BEST_PRACTICES.md
│   ├── LUA_DOCSTRING_GUIDE.md
│   └── [code examples - OK here]
│
├── 📁 DESIGN/
│   └── REFERENCES.md (single file) ⚠️ COULD MOVE TO references/
│
├── 🔴 ECONOMY/ ....................... ⚠️ CONFUSING STRUCTURE
│   ├── funding.md
│   ├── manufacturing.md
│   ├── marketplace.md
│   ├── research.md
│   ├── finance/ ..................... ❌ Duplicate of funding?
│   ├── marketplace/ ................. ❌ Subfolder + file same name
│   ├── production/ .................. ❌ Subfolder + file same name
│   ├── research/ .................... ❌ Subfolder + file same name
│   └── [NO README]
│
├── 🔴 GEOSCAPE/ ..................... ⚠️ MIXED structure, unclear
│   ├── README.md
│   ├── missions.md
│   ├── world-map.md
│   ├── STRATEGIC_LAYER_DIAGRAMS.md ❌ SHOULD BE: technical/
│   ├── STRATEGIC_LAYER_IMPLEMENTATION_PLAN.md ❌ SHOULD BE: technical/
│   ├── STRATEGIC_LAYER_QUICK_REFERENCE.md ❌ SHOULD BE: technical/
│   ├── data/
│   ├── geography/
│   ├── logic/
│   ├── rendering/
│   ├── screens/
│   ├── systems/
│   ├── ui/
│   └── world/
│
├── 🔴 INTERCEPTION/ ................. ❌ EMPTY?
│
├── 🔴 LOCALIZATION/ ................. ❌ EMPTY?
│
├── 📁 LORE/
│   └── narrative.md (single file)
│
├── 📁 MODS/
│   └── system.md (single file)
│
├── 📁 NETWORK/
│   └── multiplayer.md (single file)
│
├── 📁 POLITICS/ ..................... ⚠️ NO README
│   ├── diplomacy/
│   ├── fame/
│   ├── government/
│   ├── karma/
│   ├── organization/
│   └── relations/
│
├── 📁 PROGRESSION/
│   └── organization.md
│
├── 🔴 RENDERING/ .................... ⚠️ TECHNICAL, should move
│   └── HEX_RENDERING_GUIDE.md (611 lines) ❌ SHOULD BE: technical/
│
├── 📁 RULES/
│   └── MECHANICAL_DESIGN.md (single file)
│
├── 🔴 SCENES/ ....................... ❌ EMPTY?
│
├── 🔴 SYSTEMS/ ....................... ⚠️ TECHNICAL, should move
│   ├── FIRE_SMOKE_MECHANICS.md (334 lines, 6 lua blocks) ❌ CODE
│   ├── RESOLUTION_SYSTEM_ANALYSIS.md (656 lines, 7 lua) ❌ CODE
│   └── TILESET_SYSTEM.md (825 lines, 12 toml + 7 lua) ❌❌ LOTS OF CODE
│
├── 📁 TESTING/
│   ├── TESTING.md (has lua blocks) ⚠️ Extract code
│   └── framework.md
│
├── 🔴 TUTORIAL/ ..................... ❌ EMPTY?
│
├── 📁 UI/
│   └── system.md
│
├── 🔴 UTILS/ ......................... ❌ EMPTY?
│
└── 🔴 WIDGETS/ ....................... ❌ EMPTY?

LEGEND:
✅ OK as-is
⚠️ Needs improvement
❌ Problem needs fixing
🔴 Critical issue
```

---

## 🟢 PROPOSED STRUCTURE (After Improvements)

```
docs/ (Same ~55 files, MUCH better organized)
│
├── 📄 README.md ....................... Consolidated navigation (150-200 lines)
├── 📄 OVERVIEW.md ..................... Game overview (unchanged)
├── 📄 QUICK_NAVIGATION.md ............ Extended index (or archive)
├── 📄 API.md .......................... Technical reference (unchanged)
├── 📄 FAQ.md
├── 📄 GLOSSARY.md
├── 📄 DEVELOPMENT.md
│
├── ✅ GAME SYSTEMS
│   │
│   ├── 📁 AI/ ......................... ✅ NOW HAS README
│   │   ├── README.md .................. NEW: Explain structure
│   │   ├── diplomacy/ ................. Relations & faction behavior
│   │   ├── pathfinding/ ............... Unit navigation
│   │   ├── strategic/ ................. High-level strategy
│   │   └── tactical/ .................. Combat AI
│   │
│   ├── 📁 GEOSCAPE/ ................... ✅ CLARIFIED STRUCTURE
│   │   ├── README.md .................. Clarified structure
│   │   ├── missions.md ................ Mission system
│   │   ├── world-map.md ............... Geography & world
│   │   ├── data/ ...................... Data & constants
│   │   ├── geography/ ................. Provinces & regions
│   │   ├── logic/ ..................... Systems & mechanics
│   │   ├── rendering/ ................. Visual representation
│   │   ├── screens/ ................... UI screens
│   │   ├── systems/ ................... Geoscape systems
│   │   ├── ui/ ........................ Geoscape UI
│   │   └── world/ ..................... World data structures
│   │   [MOVED: STRATEGIC_LAYER files → docs/technical/]
│   │
│   ├── 📁 BASESCAPE/ .................. ✅ UNCHANGED (good structure)
│   │   ├── README.md
│   │   ├── base/
│   │   ├── data/
│   │   ├── facilities/
│   │   ├── logic/
│   │   └── services/
│   │
│   ├── 📁 BATTLESCAPE/ ............... ✅ DESIGN DOCS ONLY
│   │   ├── README.md
│   │   ├── quick-reference.md
│   │   ├── armors.md
│   │   ├── weapons.md
│   │   ├── maps.md ................... Design (not code)
│   │   ├── ai-system/
│   │   ├── combat-mechanics/
│   │   ├── map-generation/
│   │   ├── map-system/
│   │   ├── mission-system/
│   │   └── unit-systems/
│   │   [MOVED: Technical files → docs/technical/]
│   │
│   ├── 📁 INTERCEPTION/ .............. ✅ CLARIFIED
│   │   ├── README.md .................. Design docs
│   │   └── [design content]
│   │
│   ├── 📁 ECONOMY/ ................... ✅ REORGANIZED
│   │   ├── README.md .................. NEW: Explain structure
│   │   ├── research.md
│   │   ├── manufacturing.md
│   │   ├── marketplace.md
│   │   ├── funding.md
│   │   └── [CLEANED: removed duplicate subfolders]
│   │   OR [OPTION B: Organized with subfolders]
│   │   ├── research/
│   │   │   ├── README.md
│   │   │   └── research.md
│   │   ├── manufacturing/
│   │   │   ├── README.md
│   │   │   └── manufacturing.md
│   │   ├── marketplace/
│   │   │   ├── README.md
│   │   │   └── marketplace.md
│   │   └── funding.md
│   │
│   ├── 📁 POLITICS/ .................. ✅ NOW HAS README
│   │   ├── README.md .................. NEW: Explain structure
│   │   ├── diplomacy/
│   │   ├── fame/
│   │   ├── government/
│   │   ├── karma/
│   │   ├── organization/
│   │   └── relations/
│   │
│   ├── 📁 LORE/ ...................... ✅ CLARIFIED
│   │   ├── README.md .................. NEW
│   │   └── narrative.md
│   │
│   └── 📁 UI/ ........................ ✅ CLARIFIED
│       ├── README.md .................. NEW
│       └── system.md
│
├── ✅ CONTENT (Game Content)
│   │
│   └── 📁 CONTENT/ ................... ✅ CLARIFIED
│       ├── README.md .................. NEW: Explain content organization
│       ├── items/
│       │   ├── README.md
│       │   └── items.md
│       ├── equipment/
│       │   ├── README.md
│       │   └── [equipment docs]
│       ├── crafts/
│       │   ├── README.md
│       │   └── [craft docs]
│       ├── facilities/
│       │   ├── README.md
│       │   └── [facility docs]
│       └── units/
│           ├── README.md
│           └── [unit docs]
│
├── ✅ CORE SYSTEMS
│   │
│   └── 📁 CORE/ ...................... ✅ UNCHANGED (good)
│       ├── README.md
│       ├── concepts.md
│       ├── implementation.md
│       ├── physics.md
│       ├── LUA_BEST_PRACTICES.md
│       └── LUA_DOCSTRING_GUIDE.md
│
├── ✅ TESTING & QUALITY
│   │
│   └── 📁 TESTING/ ................... ✅ IMPROVED
│       ├── README.md
│       ├── TESTING.md ................ Design (code extracted)
│       ├── framework.md
│       └── balancing/ ................ MOVED FROM: docs/balancing/
│           ├── README.md ............. NEW
│           └── framework.md
│
├── ✅ TECHNICAL ANALYSIS (NEW FOLDER)
│   │   Large technical analysis and implementation guides
│   │
│   └── 📁 TECHNICAL/ ................. ✅ NEW FOLDER
│       ├── README.md .................. NEW: Purpose of this folder
│       ├── TILESET_SYSTEM.md ......... MOVED FROM: docs/systems/
│       ├── RESOLUTION_SYSTEM_ANALYSIS.md .... MOVED FROM: docs/systems/
│       ├── FIRE_SMOKE_MECHANICS.md .. MOVED FROM: docs/systems/
│       ├── HEX_RENDERING_GUIDE.md ... MOVED FROM: docs/rendering/
│       ├── COMBAT_SYSTEMS_COMPLETE.md .... MOVED FROM: docs/battlescape/
│       ├── 3D_BATTLESCAPE_ARCHITECTURE.md .... MOVED FROM: docs/battlescape/
│       ├── 3D_BATTLESCAPE_SUMMARY.md .... MOVED FROM: docs/battlescape/
│       ├── ECS_BATTLE_SYSTEM_API.md .... MOVED FROM: docs/battlescape/
│       └── GEOSCAPE_STRATEGIC_LAYER_*.md (3 files) .... MOVED FROM: docs/geoscape/
│
├── ✅ INFRASTRUCTURE
│   │
│   ├── 📁 ASSETS/ .................... ✅ UNCHANGED
│   │   ├── README.md
│   │   ├── audio.md
│   │   └── graphics.md
│   │
│   ├── 📁 LOCALIZATION/ ............. ✅ READY FOR CONTENT
│   │   ├── README.md .................. NEW (ready for docs)
│   │   └── [design content when added]
│   │
│   ├── 📁 MODS/ ...................... ✅ CLARIFIED
│   │   ├── README.md .................. NEW
│   │   └── system.md
│   │
│   ├── 📁 NETWORK/ ................... ✅ CLARIFIED
│   │   ├── README.md .................. NEW
│   │   └── multiplayer.md
│   │
│   ├── 📁 SCENES/ .................... ✅ READY FOR CONTENT
│   │   ├── README.md .................. NEW
│   │   └── [design content when added]
│   │
│   ├── 📁 TUTORIAL/ .................. ✅ READY FOR CONTENT
│   │   ├── README.md .................. NEW
│   │   └── [design content when added]
│   │
│   ├── 📁 UTILS/ ..................... ✅ READY FOR CONTENT
│   │   ├── README.md .................. NEW
│   │   └── [design content when added]
│   │
│   └── 📁 WIDGETS/ ................... ✅ READY FOR CONTENT
│       ├── README.md .................. NEW
│       └── [design content when added]
│
└── 📖 REFERENCE & CONTEXT
    │
    ├── 📁 PROGRESSION/ ............... ✅ CLARIFIED
    │   ├── README.md .................. NEW
    │   └── organization.md
    │
    ├── 📁 DESIGN/ .................... ✅ CLARIFIED
    │   ├── README.md .................. NEW
    │   └── REFERENCES.md
    │
    └── 📁 RULES/ ..................... ✅ CLARIFIED
        ├── README.md .................. NEW
        └── MECHANICAL_DESIGN.md

SUMMARY:
✅ All 35-40 designed folders have README.md
✅ ~10 new README files created
✅ 0 code blocks in design docs
✅ Separate technical/ folder for analysis
✅ No duplicate folder pairs
✅ Clear folder purposes
✅ Same number of files, better organized
```

---

## 📊 COMPARISON TABLE

| Aspect | Current | After Improvement |
|--------|---------|-------------------|
| **Total Folders** | 38+ | 38+ |
| **Total Files** | ~55 | ~55 |
| **Folders without README** | 15+ | 0 |
| **Files with code in design docs** | 25+ | 2-3 |
| **Duplicate folder pairs** | 3 (balance/balancing, economy structure) | 0 |
| **Navigation files** | 4 with overlap | 3-4 clearly separated |
| **Technical files mixed with design** | 10+ | 0 (all in technical/) |
| **Empty folders** | 5+ | 0 |
| **Unclear folder purposes** | 15+ | 0 |
| **Cross-reference clarity** | Moderate | High |

---

## ⏱️ EFFORT BREAKDOWN

### Time to Implement

```
Phase 1: Remove Code (2-3 hours) 
├── Extract code from 4 large files
├── Create TILESET_IMPLEMENTATION.md, etc.
└── Replace code with descriptions

Phase 2: Reorganize Folders (3-4 hours)
├── Create docs/technical/ folder
├── Move 10+ files
├── Consolidate balance/balancing
├── Clarify economy/ structure
└── Update cross-references

Phase 3: Add READMEs (2-3 hours)
├── Create ~35 README files
└── Document folder purposes

Phase 4: Standardize Naming (1-2 hours)
├── Rename inconsistent files
└── Update references

Phase 5: Final Validation (1 hour)
├── Check all links
└── Verify structure

TOTAL: 9-13 hours
```

---

## 🎯 KEY IMPROVEMENTS

✅ **Code Hygiene**: No more code in design docs  
✅ **Organization**: Technical files separated  
✅ **Clarity**: Every folder has README with purpose  
✅ **Consistency**: Standardized naming convention  
✅ **Navigation**: Clear folder structure  
✅ **Maintainability**: Easier to find and update docs  
✅ **Scalability**: Ready for future expansion  
✅ **No data loss**: All content preserved, just reorganized  

---

**Ready to implement?** Start with Phase 1 (code extraction) for quick high-impact improvements!
