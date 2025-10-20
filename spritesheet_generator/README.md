# Graphics Spritesheet Generator

Generator arkuszy do druku A4 z grafikami. Każda grafika jest replikowana **150 razy** w siatce 10×15.

## ✓ Status

**Generator działa!** Wszystkie 10 grafik zostały przetworzone i są gotowe do drukowania na papierze A4.

## Opis

Skrypt Love2D tworzy arkusze do drukowania (A4 @ 300 DPI) dla każdej grafiki. Każda grafika jest wklejana **150 razy** w siatce:
- **10 kolumn** × **15 wierszy** = 150 kopii na arkusz

## Specyfikacja

| Parametr | Wartość |
|----------|---------|
| **Format papieru** | A4 (210 × 297 mm) |
| **Rozdzielczość** | 300 DPI |
| **Wymiary (piksele)** | 2480 × 3508 px |
| **Margines** | 50 px |
| **Kolumny** | 10 |
| **Wiersze** | 15 |
| **Razem kopii na arkusz** | 150 |

## Uruchomienie

### Opcja 1: Batch (Windows CMD)
```bash
run_spritesheet_generator.bat
```

### Opcja 2: PowerShell (Windows)
```powershell
.\run_spritesheet_generator.ps1
```

### Opcja 3: Bezpośrednio z Love2D
```bash
lovec "spritesheet_generator"
```

## Wyjście

Wygenerowane arkusze będą dostępne w:
```
spritesheet_generator/output_spritesheets/
```

### Wygenerowane pliki:

| Plik | Wymiary | Grafiki |
|------|---------|---------|
| red_archer_A4_150items.png | 2480×3508 px | 150× red_archer (64×64) |
| red_balista_A4_150items.png | 2480×3508 px | 150× red_balista (64×63) |
| red_cavalery_A4_150items.png | 2480×3508 px | 150× red_cavalery (64×64) |
| red_dragon_A4_150items.png | 2480×3508 px | 150× red_dragon (64×64) |
| red_footman_A4_150items.png | 2480×3508 px | 150× red_footman (64×64) |
| red_frog_A4_150items.png | 2480×3508 px | 150× red_frog (64×64) |
| red_harpy_A4_150items.png | 2480×3508 px | 150× red_harpy (64×64) |
| red_kraken_A4_150items.png | 2480×3508 px | 150× red_kraken (64×64) |
| red_pikeman_A4_150items.png | 2480×3508 px | 150× red_pikeman (64×64) |
| red_worker_A4_150items.png | 2480×3508 px | 150× red_worker (64×64) |

## Drukowanie

1. Otwórz wygenerowany plik PNG w programie do drukowania (np. Windows Photo Viewer)
2. Ustaw parametry drukowania:
   - **Rozmiar papieru**: A4 (210 × 297 mm)
   - **Orientacja**: Portret
   - **Skala**: **100% (bez skalowania!)**
   - **Marginesy**: Brak
   - **Jakość**: Best (RGB color)
3. Drukuj

### Dlaczego 100%?

Arkusze są przygotowane w rozdzielczości 2480×3508 px (300 DPI dla A4).
Jeśli zmienisz skalę, wymiary będą nieprawidłowe i grafiki się nie zmieszczą w czystych 10×15.

## Parametry techniczne

### Układ strony
- **Wymiary**: 2480 × 3508 px (300 DPI)
- **Papier**: A4 (210 × 297 mm)
- **Margines**: 50 px
- **Siatka**: 10 kolumn × 15 wierszy
- **Rozmiar komórki**: ~238 × 227 px

### Skalowanie grafik
- Grafiki są skalowane automatycznie, aby zmieściły się w komórce
- Zachowują proporcje aspect ratio
- Mają marginesek od krawędzi (95% dostępnego miejsca)

## Struktura projektu

```
spritesheet_generator/
├── main.lua                              -- Punkt wejścia
├── conf.lua                              -- Konfiguracja Love2D
├── graphics_spritesheet_generator.lua    -- Moduł generatora
└── output_spritesheets/                  -- Wyjście (tworzone automatycznie)
    ├── red_archer_A4_150items.png
    ├── red_dragon_A4_150items.png
    └── ...

graphics/
├── red_archer.png
├── red_dragon.png
├── ...
```

## Techniczne detale

### Rozmiary komórek
- **Szerokość**: (2480 - 100) / 10 = 238 px
- **Wysokość**: (3508 - 100) / 15 ≈ 227 px

### Skalowanie grafik
Grafiki są automatycznie skalowane, aby:
1. Zmieściły się w komórce
2. Zachowały proporcje aspect ratio
3. Miały marginesek od krawędzi komórki (95% dostępnego miejsca)

### Kolory
- **Tło arkusza**: Biały (255, 255, 255)
- **Grafiki**: Oryginalne kolory z PNG (z przezroczystością)

## Wymagania

- **Love2D**: 12.0 lub nowsze
- **Lua**: 5.1+
- **Grafiki**: PNG (preferowane) lub JPG w folderze `graphics/`

## Rozwiązywanie problemów

### Arkusze są gotowe, gdzie je znaleźć?
```
C:\Users\[YourUsername]\AppData\Roaming\LOVE\spritesheet_generator\output_spritesheets\
```
Lub w projekcie: `spritesheet_generator/output_spritesheets/`

### Druk wychodzi źle - grafiki są za małe/duże
- **Nie zmieniaj skali drukowania!** Musi być 100%
- Sprawdź czy papier to rzeczywiście A4
- Wyłącz skalowanie do strony w programie do drukowania

### Marginesy są za duże
- W drukarce ustaw **margines na 0**
- Wiele drukarek ma domyślne marginesy

### Grafiki się nakładają
- Sprawdź czy nie ma błędu w skalowaniu
- Spróbuj ponownie wygenerować arkusze

## Skrypt modułu

Plik `graphics_spritesheet_generator.lua` zawiera:

- `generator.load_graphics()` - Załaduj wszystkie grafiki
- `generator.create_spritesheet(graphic_data)` - Utwórz arkusz
- `generator.save_canvas_as_image(canvas, filename)` - Zapisz do PNG
- `generator.generate_all_sheets()` - Główna funkcja

## Licencja

Część projektu AlienFall (XCOM Simple)
