# QUICKSTART - Graphics Spritesheet Generator

## 🚀 Szybki Start

### Krok 1: Uruchom generator
```bash
# Opcja A: Double-click
run_spritesheet_generator.bat

# Opcja B: PowerShell
.\run_spritesheet_generator.ps1

# Opcja C: Love2D
lovec "spritesheet_generator"
```

### Krok 2: Czekaj na zakończenie
Konsola wyświetli status każdej grafiki:
```
[Generator] Ładowanie: red_archer.png
[Generator]   ✓ red_archer.png (64x64)
...
[Generator] ✓ Wszystkie arkusze zostały wygenerowane!
```

### Krok 3: Znajdź pliki
```
📁 spritesheet_generator/output_spritesheets/
   ├── red_archer_A4_150items.png
   ├── red_balista_A4_150items.png
   └── ... (10 plików PNG)
```

## 🖨️ Drukowanie

1. Otwórz PNG (np. `red_archer_A4_150items.png`)
2. **Print Preview** (Ctrl+P)
3. **Ustawienia:**
   - Papier: **A4**
   - Skala: **100%** (ważne!)
   - Marginesy: **0 mm**
4. **DRUKUJ!**

## 📊 Co otrzymujesz

Każdy arkusz zawiera:
- **150 kopii** jednej grafiki
- Układ: **10 kolumn × 15 wierszy**
- Wymiary: **2480 × 3508 px** (A4 @ 300 DPI)
- Format: **PNG** z białym tłem

### Przykład - red_archer_A4_150items.png:
```
[Archer] [Archer] [Archer] ... [Archer]  ← 10 grafik
[Archer] [Archer] [Archer] ... [Archer]
...                            (15 wierszy)
[Archer] [Archer] [Archer] ... [Archer]
```

## 📝 Parametry

| Parametr | Wartość |
|----------|---------|
| Wymiary arkusza | 2480 × 3508 px (A4 @ 300 DPI) |
| Rozmiar komórki | ~238 × 227 px |
| Siatka | 10 × 15 (150 grafik) |
| Margines | 50 px |
| Format | PNG, białe tło |

## 🎯 Oryginalne grafiki

Generator obsługuje te 10 grafik:
1. red_archer.png (64×64)
2. red_balista.png (64×63)
3. red_cavalery.png (64×64)
4. red_dragon.png (64×64)
5. red_footman.png (64×64)
6. red_frog.png (64×64)
7. red_harpy.png (64×64)
8. red_kraken.png (64×64)
9. red_pikeman.png (64×64)
10. red_worker.png (64×64)

## ⚠️ Ważne

- **Skala drukowania MUSI być 100%!**
- Bez skalowania, grafiki będą idealnie zmieśczone
- Jeśli zmienisz skalę, rozmiary mogą być nieprawidłowe

## 🛠️ Potrzebna pomoc?

Czytaj pełny README: `spritesheet_generator/README.md`
