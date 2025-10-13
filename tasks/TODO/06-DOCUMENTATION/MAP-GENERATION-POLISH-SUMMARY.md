# System Generowania Map - Podsumowanie w Języku Polskim

**Utworzono:** 13 października 2025  
**Cel:** Dokumentacja systemu generowania map zgodnie z wymaganiami użytkownika

---

## Przegląd Systemu

System generowania map przekształca strategiczny wybór misji (Geoscape) w taktyczne pole bitwy (Battlescape) poprzez wieloetapowy proces:

**Biom Prowincji → Wybór Terenu → Wykonanie MapScript → Złożenie MapBlock Grid → Umieszczenie Drużyn → Stworzenie Battlefield**

---

## Przepływ Generowania - Szczegółowy Opis

### 1. Biom na Prowincji

Każda prowincja w Geoscape ma przypisany **biom**, który definiuje typ terenu:

```
Biomy:
- forest (las)
- urban (miejski)
- industrial (przemysłowy)
- water (wodny)
- rural (wiejski)
- mixed (mieszany)
- desert (pustynny)
- arctic (arktyczny)
```

**Przykład:**
```lua
Province = {
    name = "Środkowa Europa",
    biome = "urban"  -- Miasto
}
```

---

### 2. Biom Definiuje Dostępne Tereny z Wagami

Każdy biom ma listę terenów z wagami prawdopodobieństwa:

**Przykład: Biom "Forest" (Las)**
```lua
Biome = {
    id = "forest",
    name = "Las",
    terrains = {
        {id = "dense_forest", weight = 50},    -- 50% szans - gęsty las
        {id = "light_forest", weight = 30},    -- 30% szans - rzadki las
        {id = "grassland", weight = 15},       -- 15% szans - polana
        {id = "water", weight = 5}             -- 5% szans - rzeka/jezioro
    }
}
```

System wybiera teren używając **ważonego losowania** - gęsty las ma największą szansę (50%).

---

### 3. Misje Mogą Wymuszać Konkretny Teren

Niektóre typy misji nadpisują wybór terenu:

**Przykłady:**
- **Baza XCOM** → wymusza teren "xcom_base" (ignoruje biom)
- **Rozbicie UFO** → wymusza teren "ufo_crash" (modyfikowany przez biom)
- **Lądowanie UFO** → wymusza teren "ufo_landing"
- **Normalna misja** → używa terenu z wag biomu

```lua
MissionConfig = {
    type = "ufo_crash",
    terrainOverride = "ufo_crash_urban"  -- Wymusza miejskie rozbicie UFO
}
```

---

### 4. Teren Określa Jakie MapBlocki Są Dostępne

Kiedy mamy wybrany teren, system **filtruje MapBlocki** według tagów:

**Przykład: Teren "urban_road" (miejska ulica)**
```lua
Terrain = {
    id = "urban_road",
    name = "Miejska Ulica",
    mapBlockTags = {"urban", "road", "buildings", "paved"},
    
    -- Dostępne MapScripty dla tego terenu
    mapScripts = {
        {id = "urban_crossroads", weight = 30},
        {id = "urban_downtown", weight = 25},
        {id = "urban_residential", weight = 25},
        {id = "urban_industrial", weight = 20}
    }
}
```

System znajduje wszystkie MapBlocki oznaczone tagami: `"urban"`, `"road"`, `"buildings"`, `"paved"`

**Z 120 dostępnych MapBlocków, 23 pasują do tagów terenu.**

---

### 5. Losowanie MapScriptu z Terenu

MapScript to **szablon rozmieszczenia MapBlocków** - definiuje strukturę mapy.

System losuje MapScript z terenu używając wag:

**Przykład: MapScript "urban_crossroads"**
```lua
MapScript = {
    id = "urban_crossroads",
    name = "Miejskie Skrzyżowanie",
    description = "Skrzyżowanie ulic z budynkami na rogach",
    terrain = "urban_road",
    gridSize = {width = 5, height = 5},  -- 5×5 MapBlocków
    
    -- Instrukcje rozmieszczenia bloków
    blocks = {
        -- Główna ulica (północ-południe)
        {position = {x = 3, y = 1}, tags = {"road", "straight"}, priority = 1},
        {position = {x = 3, y = 2}, tags = {"road", "straight"}, priority = 1},
        {position = {x = 3, y = 3}, tags = {"road", "intersection"}, priority = 1},
        {position = {x = 3, y = 4}, tags = {"road", "straight"}, priority = 1},
        {position = {x = 3, y = 5}, tags = {"road", "straight"}, priority = 1},
        
        -- Główna ulica (wschód-zachód)
        {position = {x = 1, y = 3}, tags = {"road", "straight"}, priority = 1},
        {position = {x = 2, y = 3}, tags = {"road", "straight"}, priority = 1},
        {position = {x = 4, y = 3}, tags = {"road", "straight"}, priority = 1},
        {position = {x = 5, y = 3}, tags = {"road", "straight"}, priority = 1},
        
        -- Budynki (rogi)
        {position = {x = 1, y = 1}, tags = {"building", "urban"}, priority = 2},
        {position = {x = 5, y = 1}, tags = {"building", "urban"}, priority = 2},
        {position = {x = 1, y = 5}, tags = {"building", "urban"}, priority = 2},
        {position = {x = 5, y = 5}, tags = {"building", "urban"}, priority = 2},
        
        -- Pozostałe pozycje (dowolne miejskie bloki)
        {position = {x = 2, y = 1}, tags = {"urban", "any"}, priority = 3},
        -- ... itd.
    },
    
    -- Landing zones (strefy lądowania dla gracza)
    landingZones = {
        {mapBlockPosition = {x = 1, y = 1}},  -- Północno-zachodni róg
        {mapBlockPosition = {x = 5, y = 5}},  -- Południowo-wschodni róg
    },
    
    -- Cele misji
    objectives = {
        {mapBlockPosition = {x = 3, y = 3}, type = "capture"},  -- Środek skrzyżowania
    }
}
```

**Wizualizacja MapScriptu:**
```
┌────────┬────────┬────────┬────────┬────────┐
│ Budynek│ Miasto │  Ulica │ Miasto │ Budynek│
│  LZ-1  │        │   │    │        │        │
├────────┼────────┼────────┼────────┼────────┤
│ Miasto │ Park   │  Ulica │ Park   │ Miasto │
│        │        │   │    │        │        │
├────────┼────────┼────────┼────────┼────────┤
│  Ulica │  Ulica │Skrzyż. │  Ulica │  Ulica │
│────────│────────│───┼────│────────│────────│
│        │        │  CEL   │        │        │
├────────┼────────┼────────┼────────┼────────┤
│ Miasto │ Sklep  │  Ulica │ Sklep  │ Miasto │
│        │        │   │    │        │        │
├────────┼────────┼────────┼────────┼────────┤
│ Budynek│ Miasto │  Ulica │ Miasto │ Budynek│
│        │        │   │    │        │  LZ-2  │
└────────┴────────┴────────┴────────┴────────┘

LZ = Landing Zone (strefa lądowania gracza)
CEL = Cel misji (do obrony/zdobycia)
```

---

### 6. MapScript Tworzy Map Grid (2D Array MapBlocków)

MapScript wykonuje instrukcje i tworzy **MapBlock Grid** - siatkę 4×4 do 7×7:

**Wielkości map:**
- **Small (mała)**: 4×4 MapBlocki = 60×60 kafelków = 1 landing zone
- **Medium (średnia)**: 5×5 MapBlocki = 75×75 kafelków = 2 landing zones
- **Large (duża)**: 6×6 MapBlocki = 90×90 kafelków = 3 landing zones
- **Huge (ogromna)**: 7×7 MapBlocki = 105×105 kafelków = 4 landing zones

Każdy MapBlock to 15×15 kafelków terenu.

**Przykład Map Grid 5×5:**
```lua
MapBlockGrid = {
    width = 5,
    height = 5,
    blocks = {
        [1] = {mapBlock1, mapBlock2, mapBlock3, mapBlock4, mapBlock5},
        [2] = {mapBlock6, mapBlock7, mapBlock8, mapBlock9, mapBlock10},
        [3] = {mapBlock11, mapBlock12, mapBlock13, mapBlock14, mapBlock15},
        [4] = {mapBlock16, mapBlock17, mapBlock18, mapBlock19, mapBlock20},
        [5] = {mapBlock21, mapBlock22, mapBlock23, mapBlock24, mapBlock25}
    },
    landingZones = {{x=1, y=1}, {x=5, y=5}},
    objectives = {{x=3, y=3, type="capture"}}
}
```

---

### 7. Sprawdzanie Mission Objectives

Na tym etapie system określa:

**Landing Zones (Strefy Lądowania):**
- Gdzie gracz będzie miał swoje jednostki na początku
- Ilość zależy od wielkości mapy (1-4 strefy)
- W przypadku porażki, jednostki poza strefami lądowania giną

**High Value Sectors (Sektory Wysokiej Wartości dla AI):**
- Gdzie AI będzie spawować swoje jednostki
- Priorytetowe pozycje dla obrony/ataku
- Np. centrum skrzyżowania = priorytet 10

**Objective Sectors (Sektory Celów):**
- Które MapBlocki zawierają cele misji
- Typy: defend (obrona), capture (zdobycie), critical (krytyczny)

---

### 8. Transformacje MapBlocków (Różnorodność)

Przed kopiowaniem kafelków, system **losowo transformuje MapBlocki**:

**Dostępne transformacje:**
- **Rotate 90°** (obrót o 90 stopni w prawo)
- **Rotate 180°** (obrót o 180 stopni)
- **Rotate 270°** (obrót o 270 stopni)
- **Mirror Horizontal** (odbicie poziome)
- **Mirror Vertical** (odbicie pionowe)

**50% szans na transformację każdego MapBlocku**

**Przykład:**
```
ORYGINALNY MAPBLOCK:        OBRÓCONY O 90°:
┌───────────────┐          ┌───────────────┐
│ ###########   │          │         #####D│
│ #         #   │          │         #   ##│
│ #  POKÓJ  #   │          │         #   # │
│ #         #   │          │         # S # │
│ #    S    #   │          │         #   # │
│ #         #   │          │         D   # │
│ D         D   │          │         #####D│
│ ###########   │          └───────────────┘
└───────────────┘

# = Ściana
. = Podłoga
D = Drzwi
S = Stół
```

**Dzięki transformacjom** ten sam MapBlock może wyglądać na 6 różnych sposobów!

---

### 9. Kopiowanie Map Tiles do Battlefield (Pole Bitwy)

System kopiuje wszystkie kafelki z MapBlocków do jednego wielkiego **Battlefield** (2D array):

**Proces:**
```
MapBlock Grid 5×5 (25 bloków po 15×15 kafelków)
    ↓
Battlefield 75×75 kafelków (jeden wielki array)
```

**Śledzenie sektorów:**
Każdy kafelek pamięta z którego MapBlocku pochodzi:
```lua
battlefield.sectors[y][x] = mapBlockIndex  -- Który sektor/blok
```

**To pozwala na:**
- Sprawdzenie czy jednostka jest w landing zone (TASK-030)
- Identyfikację sektorów celów
- Debug i wizualizację granic MapBlocków

---

### 10. Dodawanie Obiektów i Jednostek

### Obiekty

MapBlocki mogą definiować **obiekty** do umieszczenia:

**Przykład w MapBlock TOML:**
```toml
[[objects]]
position = {x = 7, y = 7}
type = "weapon"
itemId = "plasma_rifle"

[[objects]]
position = {x = 8, y = 8}
type = "furniture"
itemId = "crate_large"
```

System umieszcza te obiekty na battlefield:
- Broń (do podniesienia)
- Meble (krzesła, stoły, skrzynie)
- Obiekty interaktywne (drzwi, konsole)
- Artefakty UFO (alien alloys, elerium)

### Jednostki

System dodaje jednostki wszystkich stron:

**4 Battle Sides (Strony Bitwy):**
```
1. PLAYER (Gracz)
2. ALLY (Sojusznicy gracza)
3. ENEMY (Wrogowie)
4. NEUTRAL (Neutralni - cywile)
```

**8 Team Colors (Kolory Drużyn):**
```
- Red (Czerwony)
- Green (Zielony)
- Blue (Niebieski)
- Yellow (Żółty)
- Cyan (Cyjan)
- Violet (Fioletowy)
- White (Biały)
- Gray (Szary)
```

**Przykład misji:**
```lua
-- Drużyna 1: Gracz
Team = {
    id = "team_xcom",
    name = "XCOM Squad Alpha",
    side = PLAYER,           -- Strona: Gracz
    color = GREEN,           -- Kolor: Zielony
    units = {8 żołnierzy}
}

-- Drużyna 2: Wróg 1
Team = {
    id = "team_sectoids",
    name = "Sectoid Scout Party",
    side = ENEMY,            -- Strona: Wróg
    color = RED,             -- Kolor: Czerwony
    units = {6 sectoidów}
}

-- Drużyna 3: Wróg 2
Team = {
    id = "team_floaters",
    name = "Floater Patrol",
    side = ENEMY,            -- Strona: Wróg
    color = YELLOW,          -- Kolor: Żółty
    units = {4 floaterów}
}

-- Drużyna 4: Neutralni
Team = {
    id = "team_civilians",
    name = "Local Civilians",
    side = NEUTRAL,          -- Strona: Neutralni
    color = WHITE,           -- Kolor: Biały
    units = {12 cywili}
}
```

**W bitwie może być do 8 drużyn, każda należy do jednej ze stron.**

---

### 11. Rozmieszczenie Zespołów

**Gracze (PLAYER teams):**
- Spawują w **landing zones** (strefy lądowania)
- Wybrane przez MapScript
- Zwykle na krawędziach mapy lub w bezpiecznych miejscach

**Wrogowie (ENEMY teams):**
- Spawują w **high-value sectors** (sektory wysokiej wartości)
- Miejsca strategiczne: centrum UFO, budynki obronne, skrzyżowania
- Każdy zespół AI ma przypisane priority sectors

**Neutralni (NEUTRAL teams):**
- Cywile spawują w budynkach mieszkalnych
- Rozproszeni po mapie
- Nie atakują, ale mogą wpaść w panikę

**Przykład rozmieszczenia dla misji 5×5:**
```
┌────────┬────────┬────────┬────────┬────────┐
│XCOM    │        │ Floater│        │        │
│Squad   │        │ Spawn  │        │        │
│(LZ-1)  │        │  (AI)  │        │        │
├────────┼────────┼────────┼────────┼────────┤
│        │ Cywil  │        │ Cywil  │        │
│        │        │        │        │        │
├────────┼────────┼────────┼────────┼────────┤
│        │        │Sectoid │        │        │
│        │        │ Spawn  │        │        │
│        │        │  (AI)  │        │        │
├────────┼────────┼────────┼────────┼────────┤
│        │ Cywil  │        │ Cywil  │        │
│        │        │        │        │        │
├────────┼────────┼────────┼────────┼────────┤
│        │        │        │        │XCOM    │
│        │        │        │        │Squad   │
│        │        │        │        │(LZ-2)  │
└────────┴────────┴────────┴────────┴────────┘
```

**System losuje kierunki patrzenia jednostek (0-5 dla hex grid).**

---

### 12. Fog of War dla Każdego Zespołu

Każdy zespół ma **niezależną mgłę wojny** (fog of war):

**3 stany widoczności:**
```
HIDDEN (Ukryte)     - Nigdy nie widziane, czarne
EXPLORED (Zbadane)  - Widziane wcześniej, szare
VISIBLE (Widoczne)  - Obecnie widoczne, pełny kolor
```

**Każdy zespół widzi tylko to co jego jednostki:**

**Przykład:**
```lua
-- Zespół 1 (XCOM - GREEN)
FogState = {
    teamId = "team_xcom",
    tiles = {
        [25][37] = VISIBLE,   -- Jednostka widzi ten kafelek
        [26][37] = EXPLORED,  -- Był tam wcześniej
        [30][40] = HIDDEN     -- Nigdy nie widział
    }
}

-- Zespół 2 (Sectoids - RED) - NIEZALEŻNA mgła
FogState = {
    teamId = "team_sectoids",
    tiles = {
        [25][37] = HIDDEN,    -- Nie widzi tego samego miejsca!
        [45][50] = VISIBLE,   -- Widzi swój obszar
        -- ... itd.
    }
}
```

**To umożliwia:**
- AI działa tylko na podstawie swojej widoczności
- Różne zespoły mają różną wiedzę o mapie
- Realistyczna symulacja rozpoznania terenu

---

### 13. Battle Tile = Map Tile + Unit + Objects + Smoke/Fire + Fog

Finalna struktura każdego kafelka na polu bitwy:

```lua
BattleTile = {
    -- Z MapBlock
    x = 37,
    y = 25,
    terrainId = "urban_road",
    isPassable = true,
    cover = NONE,
    sightCost = 1,
    
    -- Dodane podczas generowania
    unit = nil,                    -- Jednostka na kafelku (lub nil)
    objects = {"crate_small"},     -- Obiekty na kafelku
    fire = nil,                    -- Ogień (lub nil)
    smoke = nil,                   -- Dym (lub nil)
    
    -- Per-team fog of war
    fogState = {
        ["team_xcom"] = VISIBLE,
        ["team_sectoids"] = HIDDEN,
        ["team_floaters"] = EXPLORED,
        ["team_civilians"] = HIDDEN
    },
    
    -- Metadata
    sector = 12,                   -- Z którego MapBlocku
    landingZone = false,           -- Czy to landing zone?
    objective = nil                -- Czy to cel misji?
}
```

---

### 14. Dodatkowe Skrypty (Opcjonalne)

Niektóre misje mają **environmental effects** (efekty środowiskowe):

**Site Crash (Rozbicie UFO):**
- Losowe eksplozje podczas misji
- Pożary rozprzestrzeniające się
- Uszkodzone ściany i kratery
- Dym zasłaniający widoczność

**Elerium Explosion (Wybuch Elerium):**
- Jak w obronie bazy XCOM w oryginalnym X-COM
- Duża eksplozja niszczy część bazy
- Pożary i dym
- Uszkodzone obiekty

**Weather Effects (Efekty pogodowe):**
- Deszcz - zmniejsza widoczność
- Mgła - silnie ogranicza wzrok
- Śnieg - zwiększa koszt ruchu

**Przykład:**
```lua
EnvironmentalEffects.applyCrashDamage(battlefield, crashSiteBlocks)
-- 15 losowych zniszczonych kafelków
-- 8 kafelków z ogniem
-- 5 chmur dymu
-- 3 kratery po eksplozjach
```

---

## Podsumowanie Przepływu

```
1. Prowincja ma BIOM (np. "urban")
   ↓
2. BIOM definiuje TERENY z wagami (np. 40% downtown, 30% residential)
   ↓
3. System losuje TEREN (weighted random) lub MISJA wymusza (np. "ufo_crash")
   ↓
4. TEREN określa dostępne MAPBLOCKI (filtrowanie po tagach)
   ↓
5. TEREN ma MAPSCRIPTY (szablony rozmieszczenia)
   ↓
6. System losuje MAPSCRIPT (weighted random)
   ↓
7. MAPSCRIPT buduje MAP GRID (4×4 do 7×7 MapBlocków)
   ↓
8. MAP GRID określa LANDING ZONES i OBJECTIVES
   ↓
9. MAPBLOCKI dostają TRANSFORMACJE (rotate/mirror, 50% szans)
   ↓
10. Kafelki kopiowane do BATTLEFIELD (60×60 do 105×105)
    ↓
11. Dodawane OBIEKTY z MapBlocków
    ↓
12. Tworzone ZESPOŁY (4 strony, 8 kolorów)
    ↓
13. JEDNOSTKI umieszczane na battlefield (landing zones, AI sectors)
    ↓
14. FOG OF WAR liczony dla każdego zespołu
    ↓
15. EFEKTY ŚRODOWISKOWE (opcjonalnie)
    ↓
16. Gotowy BATTLEFIELD → Battlescape (bitwa taktyczna)
```

---

## Zalety Systemu

✅ **Nieskończona różnorodność** - Ten sam biom generuje różne mapy
✅ **Spójność tematyczna** - Miejskie misje wyglądają miejsko
✅ **Strukturalne układy** - MapScripty tworzą interesujące scenerie
✅ **Różnorodność wizualna** - Transformacje zwiększają wariantów
✅ **System drużynowy** - 4 strony × 8 kolorów = złożone bitwy
✅ **Niezależna widoczność** - Każdy zespół ma swoją mgłę wojny
✅ **Obiekty na mapie** - Broń, meble, interaktywne elementy
✅ **Skalowalność** - Mapy 4×4 do 7×7 dla różnych trudności

---

## Pliki Zadań

**Główny task:**
- `tasks/TODO/TASK-031-map-generation-system.md` - Pełna specyfikacja (96 godzin)

**Dokumentacja pomocnicza:**
- `tasks/TODO/MAP-GENERATION-ANALYSIS.md` - Analiza istniejącego kodu
- `tasks/TODO/MAP-GENERATION-VISUAL-GUIDE.md` - Diagramy wizualne

**Aktualizacja tasks.md:**
- Dodano TASK-031 do listy priorytetowych zadań
- Status: TODO
- Priorytet: Critical
- Czas: 96 godzin (12 dni)

---

## Zależności

**TASK-031 wymaga:**
- TASK-025 (Geoscape - Faza 1-2): System prowincji z biome
- TASK-029 (Deployment Planning): UI do wyboru landing zones
- Rozszerzenie biblioteki MapBlocków: 15 → 100+ bloków

**TASK-031 wspiera:**
- TASK-029: Generuje MapBlock Grid do wyświetlenia
- TASK-030: Dostarcza landing zones dla systemu salvage
- Battlescape: Dostarcza gotowe pole bitwy

---

## Status Implementacji

✅ **Już zaimplementowane:**
- System MapBlock (15×15 kafelków, TOML)
- GridMap (4×4 do 7×7 siatka)
- Ładowanie MapBlocków

❌ **Do zrobienia (TASK-031):**
- System biome z wagami terrain
- System MapScript (szablony)
- Transformacje MapBlock (rotate/mirror)
- System 4 stron × 8 kolorów
- Umieszczanie obiektów z MapBlocków
- Fog of war per-team
- Pipeline misja → battlefield
- Efekty środowiskowe

**Szacowany czas:** 96 godzin + 50 godzin na zawartość = 146 godzin (18 dni)
