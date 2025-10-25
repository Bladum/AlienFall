# Graphics Spritesheet Generator - Object-Oriented Edition# Graphics Spritesheet Generator



## ✅ What's NewGenerator arkuszy do druku A4 z grafikami. Każda grafika jest replikowana **150 razy** w siatce 10×15.



**Completely restructured for flexibility and scalability:**## ✓ Status

- ✅ **Object-Oriented Design**: Each army is a self-contained Army class

- ✅ **YAML Configuration**: Define which graphics and repetitions per army**Generator działa!** Wszystkie 10 grafik zostały przetworzone i są gotowe do drukowania na papierze A4.

- ✅ **Multi-Army Support**: Easily add red, yellow, blue, or more armies

- ✅ **Clean Architecture**: Separation of engine code, configs, and armies## Opis

- ✅ **Common Output**: All spritesheets in one `output/` directory

Skrypt Love2D tworzy arkusze do drukowania (A4 @ 300 DPI) dla każdej grafiki. Każda grafika jest wklejana **150 razy** w siatce:

## 📋 Overview- **10 kolumn** × **15 wierszy** = 150 kopii na arkusz



Generates A4 (300 DPI) spritesheets for printing. Each army gets its own folder with:## Specyfikacja

- `config.yaml` - Defines which graphics and how many times to repeat

- `graphics/` - PNG files for that army| Parametr | Wartość |

|----------|---------|

The generator processes all armies and outputs to `output/` directory.| **Format papieru** | A4 (210 × 297 mm) |

| **Rozdzielczość** | 300 DPI |

## 🏗️ Structure| **Wymiary (piksele)** | 2480 × 3508 px |

| **Margines** | 50 px |

```| **Kolumny** | 10 |

spritesheet_generator/| **Wiersze** | 15 |

├── armies/                    # Army configurations| **Razem kopii na arkusz** | 150 |

│   ├── red/                   # Red army config + graphics

│   ├── yellow/                # Yellow army config + graphics## Uruchomienie

│   └── blue/                  # Blue army config + graphics

├── src/                       # Engine code (shared)### Opcja 1: Batch (Windows CMD)

│   ├── Army.lua              # Army class```bash

│   ├── Generator.lua         # Generator coordinatorrun_spritesheet_generator.bat

│   └── YAMLParser.lua        # Config parser```

├── cfg/                       # Engine configuration (reserved)

├── output/                    # Generated spritesheets### Opcja 2: PowerShell (Windows)

├── main.lua                   # Entry point```powershell

└── conf.lua                   # Love2D config.\run_spritesheet_generator.ps1

``````



## 🚀 Quick Start### Opcja 3: Bezpośrednio z Love2D

```bash

### 1. Run Generatorlovec "spritesheet_generator"

```bash```

# Windows Batch

run_spritesheet_generator.bat## Wyjście



# PowerShellWygenerowane arkusze będą dostępne w:

.\run_spritesheet_generator.ps1```

spritesheet_generator/output_spritesheets/

# Or direct```

lovec "."

```### Wygenerowane pliki:



### 2. Find Output| Plik | Wymiary | Grafiki |

```|------|---------|---------|

output/| red_archer_A4_150items.png | 2480×3508 px | 150× red_archer (64×64) |

├── red_A4_150items.png| red_balista_A4_150items.png | 2480×3508 px | 150× red_balista (64×63) |

├── yellow_A4_150items.png| red_cavalery_A4_150items.png | 2480×3508 px | 150× red_cavalery (64×64) |

└── blue_A4_150items.png| red_dragon_A4_150items.png | 2480×3508 px | 150× red_dragon (64×64) |

```| red_footman_A4_150items.png | 2480×3508 px | 150× red_footman (64×64) |

| red_frog_A4_150items.png | 2480×3508 px | 150× red_frog (64×64) |

### 3. Print| red_harpy_A4_150items.png | 2480×3508 px | 150× red_harpy (64×64) |

- Open PNG in image viewer| red_kraken_A4_150items.png | 2480×3508 px | 150× red_kraken (64×64) |

- Print with **100% scaling, no margins**| red_pikeman_A4_150items.png | 2480×3508 px | 150× red_pikeman (64×64) |

| red_worker_A4_150items.png | 2480×3508 px | 150× red_worker (64×64) |

## 🎨 Customize

## Drukowanie

### Change Repetitions

1. Otwórz wygenerowany plik PNG w programie do drukowania (np. Windows Photo Viewer)

Edit `armies/red/config.yaml`:2. Ustaw parametry drukowania:

```yaml   - **Rozmiar papieru**: A4 (210 × 297 mm)

units:   - **Orientacja**: Portret

  - name: "archer"   - **Skala**: **100% (bez skalowania!)**

    file: "red_archer.png"   - **Marginesy**: Brak

    repetitions: 15  # Change this number   - **Jakość**: Best (RGB color)

```3. Drukuj



### Add New Army### Dlaczego 100%?



1. Create folder: `armies/green/`Arkusze są przygotowane w rozdzielczości 2480×3508 px (300 DPI dla A4).

2. Create `config.yaml` (copy from red/config.yaml and edit)Jeśli zmienisz skalę, wymiary będą nieprawidłowe i grafiki się nie zmieszczą w czystych 10×15.

3. Add PNG files to `armies/green/graphics/`

4. Edit `main.lua` to include "green" in armies list## Parametry techniczne



### Change Grid### Układ strony

- **Wymiary**: 2480 × 3508 px (300 DPI)

Edit `armies/red/config.yaml`:- **Papier**: A4 (210 × 297 mm)

```yaml- **Margines**: 50 px

print:- **Siatka**: 10 kolumn × 15 wierszy

  grid:- **Rozmiar komórki**: ~238 × 227 px

    columns: 10  # Change grid columns

    rows: 15     # Change grid rows### Skalowanie grafik

```- Grafiki są skalowane automatycznie, aby zmieściły się w komórce

- Zachowują proporcje aspect ratio

## 📝 Configuration (YAML)- Mają marginesek od krawędzi (95% dostępnego miejsca)



Each army has a `config.yaml` that defines:## Struktura projektu



```yaml```

army: red                        # Army identifierspritesheet_generator/

name: "Red Army"                 # Display name├── main.lua                              -- Punkt wejścia

description: "Red units"         # Description├── conf.lua                              -- Konfiguracja Love2D

├── graphics_spritesheet_generator.lua    -- Moduł generatora

print:└── output_spritesheets/                  -- Wyjście (tworzone automatycznie)

  format: "A4"    ├── red_archer_A4_150items.png

  dpi: 300    ├── red_dragon_A4_150items.png

  width_px: 2480    └── ...

  height_px: 3508

  grid:graphics/

    columns: 10├── red_archer.png

    rows: 15├── red_dragon.png

    total_items: 150├── ...

```

units:

  - name: "archer"## Techniczne detale

    file: "red_archer.png"

    repetitions: 15              # How many times to repeat### Rozmiary komórek

    width: 64- **Szerokość**: (2480 - 100) / 10 = 238 px

    height: 64- **Wysokość**: (3508 - 100) / 15 ≈ 227 px

```

### Skalowanie grafik

## 🔧 ArchitectureGrafiki są automatycznie skalowane, aby:

1. Zmieściły się w komórce

### Army Class2. Zachowały proporcje aspect ratio

Represents a single army. Handles:3. Miały marginesek od krawędzi komórki (95% dostępnego miejsca)

- Loading configuration from YAML

- Loading graphics from PNG files### Kolory

- Generating spritesheet canvas- **Tło arkusza**: Biały (255, 255, 255)

- Saving output PNG- **Grafiki**: Oryginalne kolory z PNG (z przezroczystością)



**Usage:**## Wymagania

```lua

local Army = require("src.Army")- **Love2D**: 12.0 lub nowsze

local red = Army.new("red", "armies/red")- **Lua**: 5.1+

red:loadConfig()- **Grafiki**: PNG (preferowane) lub JPG w folderze `graphics/`

red:loadGraphics()

local canvas = red:generateSpritesheet()## Rozwiązywanie problemów

red:saveSpritesheetToFile(canvas, "output")

```### Arkusze są gotowe, gdzie je znaleźć?

```

### Generator ClassC:\Users\[YourUsername]\AppData\Roaming\LOVE\spritesheet_generator\output_spritesheets\

Coordinates multiple armies. Handles:```

- Managing multiple Army instancesLub w projekcie: `spritesheet_generator/output_spritesheets/`

- Batch processing

- Reporting results### Druk wychodzi źle - grafiki są za małe/duże

- **Nie zmieniaj skali drukowania!** Musi być 100%

**Usage:**- Sprawdź czy papier to rzeczywiście A4

```lua- Wyłącz skalowanie do strony w programie do drukowania

local Generator = require("src.Generator")

local gen = Generator.new()### Marginesy są za duże

gen:addArmy(red_army)- W drukarce ustaw **margines na 0**

gen:addArmy(yellow_army)- Wiele drukarek ma domyślne marginesy

gen:generateAll()

```### Grafiki się nakładają

- Sprawdź czy nie ma błędu w skalowaniu

## 📊 Specifications- Spróbuj ponownie wygenerować arkusze



| Parameter | Value |## Skrypt modułu

|-----------|-------|

| **Paper Format** | A4 |Plik `graphics_spritesheet_generator.lua` zawiera:

| **Resolution** | 300 DPI |

| **Dimensions** | 2480 × 3508 px |- `generator.load_graphics()` - Załaduj wszystkie grafiki

| **Default Grid** | 10 columns × 15 rows |- `generator.create_spritesheet(graphic_data)` - Utwórz arkusz

| **Total Items** | 150 (configurable) |- `generator.save_canvas_as_image(canvas, filename)` - Zapisz do PNG

| **Cell Size** | 64 × 64 px |- `generator.generate_all_sheets()` - Główna funkcja

| **Spacing** | 8 px black between cells |

## Licencja

## 🖨️ Printing

Część projektu AlienFall (XCOM Simple)

1. Open generated PNG
2. Print settings:
   - **Paper**: A4
   - **Orientation**: Portrait
   - **Scale**: **100%** (IMPORTANT!)
   - **Margins**: 0 mm
   - **Quality**: Best
3. Click Print

## 🆚 What Changed From Old Version

| Old | New |
|-----|-----|
| Single generator script | Army class + Generator class |
| Hard-coded for red only | Easy to add armies |
| All graphics in root | Organized by army folders |
| YAML not supported | Full YAML configuration |
| One output file | Multiple outputs in common dir |

## 📚 Documentation

- **`ARCHITECTURE.md`** - Detailed technical design
- **`QUICKSTART.md`** - Quick reference
- **`PREVIEW.html`** - Preview of output format

## 🐛 Troubleshooting

### No output files generated
- Check console for errors
- Verify YAML syntax in config.yaml
- Ensure PNG files exist in graphics/ folder

### Wrong number of items
- Edit `repetitions` in config.yaml
- Adjust `columns` and `rows` in grid settings

### Graphics not loading
- Check file names match config.yaml
- Ensure files are in `armies/[army]/graphics/`
- Verify PNG format is valid

## 📦 Requirements

- **Love2D**: 12.0 or newer
- **Lua**: 5.1+
- **PNG graphics**: In each army's graphics/ folder

## 🔗 Resources

- Love2D: https://love2d.org
- Project: AlienFall (XCOM Simple)

---

See `ARCHITECTURE.md` for full technical details.
