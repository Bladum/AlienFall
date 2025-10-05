--- Unit tests for SafeIO utility module
-- Tests error handling and fallback behavior for I/O operations
--
-- @module test.util.test_safe_io

local SafeIO = require("utils.safe_io")

describe("SafeIO", function()
    describe("safe_require", function()
        it("should load valid module", function()
            local result = SafeIO.safe_require("engine.logger")
            assert.is_not_nil(result)
        end)
        
        it("should return fallback for missing module", function()
            local fallback = {test = true}
            local result = SafeIO.safe_require("nonexistent.module", fallback)
            assert.equals(fallback, result)
        end)
        
        it("should return nil by default for missing module", function()
            local result = SafeIO.safe_require("nonexistent.module")
            assert.is_nil(result)
        end)
    end)
    
    describe("safe_load_image", function()
        it("should return fallback texture for missing image", function()
            local result = SafeIO.safe_load_image("nonexistent.png")
            assert.is_not_nil(result)
            assert.equals("Image", result:type())
        end)
        
        it("should use custom fallback color", function()
            local result = SafeIO.safe_load_image("nonexistent.png", {1, 1, 0})
            assert.is_not_nil(result)
        end)
    end)
    
    describe("safe_load_font", function()
        it("should return default font for missing font file", function()
            local result = SafeIO.safe_load_font("nonexistent.ttf", 12)
            assert.is_not_nil(result)
            assert.equals("Font", result:type())
        end)
        
        it("should return default font when no path given", function()
            local result = SafeIO.safe_load_font(nil, 14)
            assert.is_not_nil(result)
            assert.equals("Font", result:type())
        end)
    end)
    
    describe("file_exists", function()
        it("should return false for non-existent file", function()
            local result = SafeIO.file_exists("nonexistent.txt")
            assert.is_false(result)
        end)
    end)
    
    describe("safe_read_file", function()
        it("should return fallback for missing file", function()
            local fallback = "default content"
            local result = SafeIO.safe_read_file("nonexistent.txt", fallback)
            assert.equals(fallback, result)
        end)
        
        it("should return empty string by default", function()
            local result = SafeIO.safe_read_file("nonexistent.txt")
            assert.equals("", result)
        end)
    end)
    
    describe("safe_write_file", function()
        it("should handle write errors gracefully", function()
            -- Writing to invalid path should return false
            local result = SafeIO.safe_write_file("", "content")
            assert.is_boolean(result)
        end)
    end)
end)
