# Plan Implementacji - Polskie Podsumowanie

**Data:** 13 października 2025  
**Zadania:** TASK-029, TASK-030  
**Całkowity Czas:** 108 godzin (13.5 dni)

---

## Przegląd Trzech Funkcji

### 1. Ekran Planowania i Rozmieszczenia Misji (TASK-029)

**Czas implementacji:** 54 godziny (6.75 dni)

#### Co zostanie zaimplementowane:

**Wielkości Map i Landing Zones (Strefy Lądowania):**
- **Małe mapy (4×4 MapBlocks):** 1 strefa lądowania
- **Średnie mapy (5×5 MapBlocks):** 2 strefy lądowania  
- **Duże mapy (6×6 MapBlocks):** 3 strefy lądowania
- **Ogromne mapy (7×7 MapBlocks):** 4 strefy lądowania

**Każdy MapBlock = 15×15 kafelków**

#### Funkcjonalność:

**Przed bitwą gracz widzi:**
- Siatkę MapBlocków pokazującą całą mapę (4×4 do 7×7)
- **Strefy lądowania** (zielone) - gdzie można rozmieścić jednostki
- **Sektory celów** (żółte/czerwone/niebieskie) - które MapBlocki trzeba bronić lub zdobyć
- Listę dostępnych jednostek do przydzielenia

**Gracz może:**
- Przeciągać jednostki do stref lądowania
- Widzieć cele misji przed walką
- Strategicznie rozmieścić jednostki w różnych punktach wejścia
- Rozpocząć bitwę po zatwierdzeniu rozmieszczenia

**Podobne do:** Panel planowania w grze Sudden Strike

#### Fazy Implementacji:
1. Struktury danych i metadata MapBlocków (6h)
2. Algorytm wyboru stref lądowania (8h)
3. Stan gry planowania rozmieszczenia (10h)
4. UI planowania rozmieszczenia (12h)
5. Integracja z Battlescape (8h)
6. Przepływ stanów (4h)
7. Testy i walidacja (6h)

---

### 2. System Salwacji i Rozwiązania Zwycięstwa/Porażki (TASK-030)

**Czas implementacji:** 50 godzin (6.25 dni)

#### Zwycięstwo - Co gracz otrzymuje:

**Zbierane automatycznie:**
- **Wszystkie trupy wrogów** → przedmioty specyficzne dla rasy
  - Zabity Sectoid → przedmiot "Dead Sectoid" (do badań)
  - Zabity Floater → przedmiot "Dead Floater"
  - etc.
  
- **Cały sprzęt wrogów** (broń, granaty, wyposażenie)
  - Plasma Rifle × 5
  - Alien Grenade × 3
  - etc.

- **Specjalna salwacja z obiektów:**
  - Ściany UFO → UFO Alloys (5-10 sztuk)
  - Silnik Elerium → Elerium-115 (10-20 sztuk)
  - Komputer Kosmitów → Alien Data Core

- **Trupy sojuszników (jeśli polegli):**
  - Trup ludzki + cały sprzęt zwrócony do bazy

**Punktacja misji:**
- Bazowa punktacja + bonusy za cele
- Bonus za szybkość (liczba tur)
- Bonus za niskie straty
- **Kara za zabicie cywilów** (×2 w misjach publicznych!)
- **Kara za zniszczenie własności** (tylko w misjach publicznych)

#### Porażka - Co gracz traci:

**Jeśli misja przegrana:**
- **Wszystkie jednostki POZA strefami lądowania → STRACONE NA ZAWSZE**
- **Jednostki WEWNĄTRZ stref lądowania → PRZEŻYWAJĄ i wracają**
- **Żadna salwacja nie jest zbierana** (całkowita strata)
- **Żadne trupy wrogów**
- **Żaden sprzęt**
- Nadal dostajesz doświadczenie (żeby zachęcić do nauki)
- Negatywne punkty za porażkę

**To znaczy:**
- Jeśli wycofasz wszystkie jednostki do stref lądowania → Przeżyją
- Jeśli zostawisz jednostki z dala od stref lądowania → Stracone
- Żadnej nagrody, tylko konsekwencje

#### Fazy Implementacji:
1. Struktury danych salwacji (4h)
2. System zbierania salwacji (8h)
3. System punktacji misji (6h)
4. UI ekranu salwacji (10h)
5. Integracja z magazynem bazy (6h)
6. System budżetu ukrycia (8h)
7. Integracja i testy (8h)

---

### 3. System Budżetu Ukrycia (Zintegrowany z TASK-030)

**Czas implementacji:** 8 godzin (w ramach TASK-030)

#### Misje Tajne (Covert Operations):

**Koncepcja:**
- Każda misja ma **budżet ukrycia** (concealment budget)
- Akcje w walce **konsumują budżet**
- Przekroczenie budżetu = **PORAŻKA MISJI** (dla misji tajnych) lub **CIĘŻKA KARA** (dla misji publicznych)

#### Rodzaje Misji:

**Misje Normalne (Las, Pustynia):**
- Budżet: 100,000 punktów (praktycznie nieograniczony)
- Nikt nie widzi, możesz używać ciężkiej broni
- Śmierć cywila = normalna kara

**Misje Publiczne (Miasto):**
- Budżet: 1,000-5,000 punktów
- Wielu świadków, media obserwują
- Śmierć cywila = **×2 kara punktowa**
- Zniszczenie własności = dodatkowa kara
- Przekroczenie budżetu = ciężka kara punktowa

**Misje Tajne (Covert):**
- Budżet: 50-500 punktów (bardzo niski!)
- MUSISZ być cicho
- Przekroczenie budżetu = **AUTOMATYCZNA PORAŻKA MISJI**

#### Koszty Akcji:

```
Strzał z broni palnej:       1 punkt
Eksplozja granatu:          10 punktów
Rakieta/ładunek wybuchowy:  25 punktów
Masowe zniszczenie:         50 punktów
Śmierć cywila:              20 punktów (×2 w mieście!)
```

#### Przykład Misji Tajnej (Budget: 200):

**Powodzenie:**
- 10 strzałów z tłumikiem = 5 punktów ✓
- 1 granat = 10 punktów ✓
- Cichy take-down wrogów = 0 punktów ✓
- **Całkowity koszt: 15 punktów** ✓ SUKCES

**Porażka:**
- 20 strzałów = 20 punktów
- 5 granatów = 50 punktów
- 2 rakiety = 50 punktów
- Zabicie 1 cywila = 20 punktów
- **Całkowity koszt: 140 punktów**
- Budżet przekroczony → **MISJA SKOMPROMITOWANA** ✗

---

## Przepływ Całego Systemu

### Krok 1: Geoscape
Gracz wybiera misję z mapy świata

### Krok 2: Ekran Planowania Rozmieszczenia (NOWY!)
- Widzi siatkę MapBlocków
- Przydziela jednostki do stref lądowania
- Widzi cele misji
- Rozpoczyna bitwę

### Krok 3: Battlescape (Walka)
- Jednostki pojawiają się w przydzielonych strefach
- Walka turn-based
- **Budżet ukrycia jest śledzony** (dla misji tajnych/publicznych)
- Cel: Zwyciężyć lub wycofać się do stref lądowania

### Krok 4A: Zwycięstwo → Ekran Salwacji
- Pokazuje zebrane trupy, sprzęt, specjalną salwację
- Pokazuje punktację misji z rozbiciem
- Transfer wszystkiego do bazy
- Wraca do Geoscape

### Krok 4B: Porażka → Ekran Porażki
- Pokazuje stracone jednostki (poza strefami lądowania)
- Pokazuje ocalałe jednostki (w strefach lądowania)
- **ŻADNEJ salwacji nie zbiera**
- Negatywne punkty
- Wraca do Geoscape

### Krok 5: Basescape
- Salwacja w magazynie bazy
- Trupy dostępne do badań
- Sprzęt dostępny do użycia/produkcji
- Roster jednostek zaktualizowany (KIA usunięci)

### Krok 6: Geoscape
- Relacje z krajami zaktualizowane (na podstawie punktacji)
- Finansowanie dostosowane
- Kampania trwa dalej...

---

## Kluczowe Zalety

### Dla Gracza:
✅ **Głębia strategiczna** - Rozmieszczenie w wielu punktach  
✅ **Przewidywalność** - Widzi cele przed walką  
✅ **Nagrody za sukces** - Trupy, sprzęt, materiały  
✅ **Konsekwencje za porażkę** - Stracone jednostki, brak salwacji  
✅ **Taktyczna różnorodność** - Misje tajne wymagają ciszy  
✅ **Sprawiedliwy system** - Jasne zasady i punktacja  

### Dla Gry:
✅ **Pętla gameplay** - Bitwa → Salwacja → Badania → Produkcja  
✅ **Progresja** - Trupy kosmitów = nowe badania  
✅ **Balans** - Misje miejskie trudniejsze (kary ×2)  
✅ **Replayability** - Różne strategie rozmieszczenia  
✅ **Immersja** - Realistyczne konsekwencje akcji  

---

## Harmonogram Implementacji

### Tydzień 1: Fundament (40 godzin)
- Struktury danych dla obu systemów
- Algorytm wyboru stref lądowania
- System zbierania salwacji
- Podstawowa logika

### Tydzień 2: UI i Integracja (38 godzin)
- UI planowania rozmieszczenia
- UI ekranu salwacji
- Integracja z Battlescape
- System punktacji

### Tydzień 3: Zaawansowane Funkcje (22 godziny)
- Przepływ stanów gry
- Integracja z magazynem bazy
- System budżetu ukrycia
- Logika porażki

### Tydzień 4: Testy i Dopracowanie (8 godzin)
- Testy integracyjne
- Testy manualne
- Balansowanie
- Dokumentacja

**Całkowity czas: ~3.5 tygodnia (108 godzin)**

---

## Pliki Utworzone

### Dokumentacja Zadań:
1. **TASK-029-mission-deployment-planning-screen.md** (54h)
   - Pełna specyfikacja ekranu planowania
   - 7 faz implementacji
   - Struktury danych, algorytmy, UI

2. **TASK-030-mission-salvage-victory-defeat.md** (50h)
   - Pełna specyfikacja systemu salwacji
   - 7 faz implementacji
   - Zbieranie, punktacja, budżet ukrycia

3. **MISSION-SYSTEM-FEATURES-SUMMARY.md**
   - Podsumowanie wszystkich trzech funkcji
   - Plan integracji
   - Strategia testów
   - Kryteria sukcesu

4. **MISSION-SYSTEM-VISUAL-WORKFLOW.md**
   - Wizualne diagramy przepływu
   - Przykłady scenariuszy
   - Macierze danych
   - Metryki sukcesu

5. **tasks.md** (zaktualizowany)
   - Dodano TASK-029 i TASK-030 do aktywnych zadań
   - Zaktualizowano nagłówek z liczbą zadań

---

## Następne Kroki

1. ✅ **Plan utworzony** - Wszystkie dokumenty gotowe
2. ⏳ **Przegląd planu** - Zatwierdź lub zmodyfikuj
3. ⏳ **Rozpocznij implementację** - Zacznij od TASK-029 Faza 1
4. ⏳ **Testy na bieżąco** - Testuj każdą fazę przed przejściem dalej
5. ⏳ **Dokumentacja** - Aktualizuj wiki podczas implementacji

---

## Pytania do Rozważenia

### Przed Rozpoczęciem:
- Czy wielkości map (4×4 do 7×7) są odpowiednie?
- Czy liczba stref lądowania (1-4) jest wystarczająca?
- Czy budżety ukrycia (50-500 dla tajnych, 1000-5000 dla publicznych) są zbalansowane?
- Czy kary ×2 dla misji publicznych są sprawiedliwe?

### Podczas Implementacji:
- Czy UI planowania jest intuicyjny?
- Czy system salwacji zbiera wszystko poprawnie?
- Czy punktacja jest przejrzysta dla gracza?
- Czy porażka jest uczciwa ale surowa?

---

## Ryzyka i Mitygacje

### Wysokie Ryzyko:
- **Błędy przejść stanów** → Dokładne testy, logowanie
- **Problemy z wydajnością** → Optymalizacja algorytmów
- **Błędy zbierania salwacji** → Testy jednostkowe, walidacja

### Średnie Ryzyko:
- **Balans budżetu ukrycia** → Konfigurowalne wartości, feedback graczy
- **Detekcja stref lądowania** → Debug overlay, jasne granice MapBlocków

### Niskie Ryzyko:
- **UI responsywność** → System siatki 24×24, widget system
- **Integracja z bazą** → Istniejące systemy, dobre API

---

## Podsumowanie

**Trzy połączone funkcje które znacząco ulepszą AlienFall:**

1. **Planowanie Rozmieszczenia** - Strategiczna głębia przed walką
2. **System Salwacji** - Namacalne nagrody i konsekwencje
3. **Budżet Ukrycia** - Różnorodność taktyczna i realizm

**Całkowity czas:** 108 godzin (13.5 dni)  
**Priorytet:** Wysoki  
**Wpływ:** Bardzo Wysoki - Podstawowa pętla gameplay  

---

*Wygenerowano: 13 października 2025*  
*Status: Gotowe do Implementacji*  
*Autor: AI Agent (GitHub Copilot)*
