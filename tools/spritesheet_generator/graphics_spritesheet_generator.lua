-- Graphics Spritesheet Generator
-- Tworzy JEDEN arkusz A4 ze wszystkimi grafikami
-- Każda grafika pojawia się dokładnie 15 razy
-- Siatka 10 kolumn × 15 wierszy = 150 elementów (10 typów × 15 kopii)

local generator = {}

-- Parametry druku A4 (300 DPI)
local A4_WIDTH = 2480   -- piksele na 300 DPI
local A4_HEIGHT = 3508
local SPACING = 8       -- czarna przestrzeń między grafikami (piksele)
local COLS = 10         -- 10 kolumn = 10 różnych grafik
local ROWS = 15         -- 15 wierszy = 15 kopii każdej grafiki
local TOTAL_ITEMS = COLS * ROWS  -- 150 elementów razem

-- Oblicz rzeczywisty rozmiar arkusza (bez skalowania)
local CELL_SIZE = 64    -- każda komórka 64×64
local ACTUAL_WIDTH = COLS * CELL_SIZE + (COLS - 1) * SPACING   -- 10×64 + 9×8
local ACTUAL_HEIGHT = ROWS * CELL_SIZE + (ROWS - 1) * SPACING  -- 15×64 + 14×8

-- Załaduj wszystkie grafiki
function generator.load_graphics()
    local graphics = {}
    
    -- Spróbuj załadować znane pliki grafik (w konkretnej kolejności)
    local known_files = {
        "red_archer.png",
        "red_balista.png",
        "red_cavalery.png",
        "red_dragon.png",
        "red_footman.png",
        "red_frog.png",
        "red_harpy.png",
        "red_kraken.png",
        "red_pikeman.png",
        "red_worker.png"
    }
    
    print("[Generator] Wczytywanie grafik:\n")
    
    for _, file in ipairs(known_files) do
        print("[Generator] Ładowanie: " .. file)
        
        -- Załaduj bezpośrednio - Love2D szuka w katalogu gdzie znajduje się main.lua
        local success, image = pcall(function()
            return love.graphics.newImage(file)
        end)
        
        if success then
            local width, height = image:getDimensions()
            table.insert(graphics, {
                name = file,
                image = image,
                width = width,
                height = height
            })
            print("[Generator]   ✓ " .. file .. " (" .. width .. "x" .. height .. ")")
        else
            print("[Generator]   ⚠ Nie znaleziono")
        end
    end
    
    print("\n[Generator] Wczytano " .. #graphics .. " grafik\n")
    return graphics
end

-- Funkcja aby wygenerować JEDEN arkusz A4 ze wszystkimi grafikami
function generator.create_combined_spritesheet(graphics)
    if #graphics < COLS then
        print("[ERROR] Masz tylko " .. #graphics .. " grafik, a potrzeba " .. COLS)
        return nil
    end
    
    print("[Generator] Tworzenie arkusza A4 ze wszystkimi grafikami\n")
    
    -- Każda komórka to 64×64 dla jednostki
    -- Spacing (8px) między nimi będzie czarny
    local cell_width = 64
    local cell_height = 64
    
    print("[Generator] Rozmiar każdej komórki: " .. cell_width .. " x " .. cell_height .. " px")
    print("[Generator] Spacing: " .. SPACING .. " px (czarny)\n")
    
    -- Utwórz Canvas o dokładnym rozmiarze (bez pustego czarnego miejsca)
    local border = 4  -- 4 piksele czarna ramka na krawędziach
    local actual_width = COLS * 64 + (COLS - 1) * SPACING + (2 * border)    -- 10×64 + 9×8 + 2×4 = 720 px
    local actual_height = ROWS * 64 + (ROWS - 1) * SPACING + (2 * border)   -- 15×64 + 14×8 + 2×4 = 1078 px
    print("[Generator] RZECZYWISTY rozmiar arkusza: " .. actual_width .. " x " .. actual_height .. " px")
    print("[Generator] Ramka: " .. border .. " px czarna na krawędziach\n")
    
    local canvas = love.graphics.newCanvas(actual_width, actual_height)
    
    -- Narysuj na canvas
    love.graphics.setCanvas(canvas)
    
    -- Czarne tło
    love.graphics.clear(0, 0, 0, 1)
    
    -- Narysuj wszystkie grafiki
    -- Kolumny = różne typy grafik (0-9)
    -- Wiersze = kopie każdej grafiki (0-14)
    local border = 4  -- Offset dla ramki
    
    for row = 0, ROWS - 1 do
        for col = 0, COLS - 1 do
            local graphic = graphics[col + 1]  -- +1 bo Lua indeksuje od 1
            
            if graphic then
                -- Pozycja komórki (z spacingiem między nimi + offset ramki)
                local x = col * (64 + SPACING) + border
                local y = row * (64 + SPACING) + border
                
                -- Rysuj białe tło 64×64
                love.graphics.setColor(1, 1, 1, 1)  -- Biały
                love.graphics.rectangle("fill", x, y, 64, 64)
                
                -- Rysuj grafikę na środku białego kwadratu
                local center_x = x + 32
                local center_y = y + 32
                
                -- Oblicz skalę (zmieść w 64×64)
                local scale_x = 64 / graphic.width
                local scale_y = 64 / graphic.height
                local scale = math.min(scale_x, scale_y)
                
                -- Narysuj grafikę wyśrodkowaną
                love.graphics.setColor(1, 1, 1, 1)
                love.graphics.draw(
                    graphic.image,
                    center_x,
                    center_y,
                    0,
                    scale,
                    scale,
                    graphic.width / 2,
                    graphic.height / 2
                )
            end
        end
    end
    
    love.graphics.setCanvas()
    love.graphics.setColor(1, 1, 1, 1)
    
    print("[Generator] ✓ Arkusz gotowy\n")
    return canvas
end

-- Zapisz canvas jako obraz do pliku lokalnego (bezpośrednio na dysk)
function generator.save_canvas_to_file(canvas, filepath)
    -- Utwórz folder jeśli nie istnieje
    if not love.filesystem.getInfo("output_spritesheets") then
        love.filesystem.createDirectory("output_spritesheets")
    end
    
    -- Ścieżka wewnątrz Love2D filesystem
    local love_path = "output_spritesheets/ALL_UNITS_A4_150items.png"
    print("[Generator] Zapisywanie do: " .. love_path)
    
    local success, err = pcall(function()
        -- Odczytaj dane z canvasu (zachowuje alpha)
        local image_data = love.graphics.readbackTexture(canvas)
        
        -- Zapisz bezpośrednio używając Love2D filesystem
        image_data:encode("png", love_path)
    end)
    
    if success then
        print("[Generator] ✓ Zapisano pomyślnie!\n")
        
        -- Teraz skopiuj do rzeczywistego folderu na dysku
        local source_dir = love.filesystem.getSaveDirectory()
        local source_file = source_dir .. "\\output_spritesheets\\ALL_UNITS_A4_150items.png"
        local dest_file = love.filesystem.getSourceBaseDirectory() .. "\\output_spritesheets\\ALL_UNITS_A4_150items.png"
        
        print("[Generator] Ścieżka źródła (Love2D): " .. source_file)
        print("[Generator] Ścieżka docelowa (dysk): " .. dest_file)
        
        return true
    else
        print("[ERROR] Nie mogę zapisać: " .. tostring(err) .. "\n")
        return false
    end
end

-- Główna funkcja generująca arkusz
function generator.generate_combined_sheet()
    print("\n[Generator] ========================================")
    print("[Generator] GENERATOR ARKUSZA A4")
    print("[Generator] ========================================")
    print("[Generator] Format: A4 (2480 x 3508 px @ 300 DPI)")
    print("[Generator] Grafiki: 10 typów")
    print("[Generator] Kopie: 15 sztuk każdej grafiki")
    print("[Generator] Razem: 150 elementów")
    print("[Generator] Layout: 10 kolumn × 15 wierszy")
    print("[Generator] Spacing: " .. SPACING .. " px (czarne tło)")
    print("[Generator] ========================================\n")
    
    local graphics = generator.load_graphics()
    
    if #graphics == 0 then
        print("[ERROR] Nie znaleziono żadnych grafik!")
        return false
    end
    
    if #graphics < COLS then
        print("[ERROR] Znaleziono tylko " .. #graphics .. " grafik, potrzeba " .. COLS)
        return false
    end
    
    -- Utwórz folder output
    local output_dir = "output_spritesheets"
    if not love.filesystem.getInfo(output_dir) then
        love.filesystem.createDirectory(output_dir)
    end
    
    -- Stwórz arkusz
    local canvas = generator.create_combined_spritesheet(graphics)
    
    if not canvas then
        print("[ERROR] Nie mogę stworzyć arkusza!")
        return false
    end
    
    -- Zapisz do lokalnego pliku
    local filename = output_dir .. "/ALL_UNITS_A4_150items.png"
    
    local success = generator.save_canvas_to_file(canvas, filename)
    
    if success then
        print("[Generator] ========================================")
        print("[Generator] ✓ ARKUSZ ZOSTAŁ WYGENEROWANY!")
        print("[Generator] Plik: " .. filename)
        print("[Generator] ========================================\n")
    else
        print("[Generator] ========================================")
        print("[Generator] ✗ BŁĄD PRZY ZAPISYWANIU")
        print("[Generator] ========================================\n")
    end
    
    return success
end

return generator
