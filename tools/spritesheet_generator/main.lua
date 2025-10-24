-- Graphics Spritesheet Printer
-- Główny skrypt Love2D do generowania jednego arkusza A4 ze wszystkimi grafikami

function love.load()
    print("\n========== GRAPHICS SPRITESHEET GENERATOR ==========\n")
    
    -- Załaduj generator
    local generator = require("graphics_spritesheet_generator")
    
    -- Wygeneruj JEDEN arkusz A4 ze wszystkimi grafikami
    local success = generator.generate_combined_sheet()
    
    if success then
        print("\n✓ Generowanie ukończone!")
        print("Arkusz jest gotowy do drukowania.\n")
        
        -- Skopiuj plik z Love2D save directory do lokalnego folderu
        print("[MAIN] Kopiowanie pliku do lokalnego folderu...")
        
        local source_dir = love.filesystem.getSaveDirectory()
        local source_file = source_dir .. "\\output_spritesheets\\ALL_UNITS_A4_150items.png"
        local dest_file = love.filesystem.getSourceBaseDirectory() .. "\\spritesheet_generator\\output_spritesheets\\ALL_UNITS_A4_150items.png"
        
        -- Użyj PowerShell do kopiowania
        local cmd = 'powershell -Command "Copy-Item -Path \\"' .. source_file .. '\\" -Destination \\"' .. dest_file .. '\\" -Force -ErrorAction SilentlyContinue"'
        local result = os.execute(cmd)
        
        if result == 0 then
            print("[MAIN] ✓ Plik skopiowany do: " .. dest_file .. "\n")
        else
            print("[MAIN] ⚠ Nie mogę skopiować (uprawnienia), ale plik jest w Love2D\n")
        end
    else
        print("\n✗ Błąd przy generowaniu!")
    end
    
    -- Zamknij program po wygenerowaniu
    love.event.quit()
end

function love.draw()
    love.graphics.print("Generowanie arkusza A4... patrz konsolę", 10, 10)
end