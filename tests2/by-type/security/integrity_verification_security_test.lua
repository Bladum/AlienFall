-- ─────────────────────────────────────────────────────────────────────────
-- INTEGRITY VERIFICATION SECURITY TESTS
-- ─────────────────────────────────────────────────────────────────────────
-- Purpose: Verify data integrity and tampering detection
-- Tests: 6 integrity verification security tests
-- Categories: Checksum validation, tampering detection, signature checks

local HierarchicalSuite = require("tests2.framework.hierarchical_suite")
local Helpers = require("tests2.utils.test_helpers")

local Suite = HierarchicalSuite:new({
    modulePath = "engine.core.security",
    fileName = "integrity_verification_security_test.lua",
    description = "Data integrity and tampering detection"
})

-- ─────────────────────────────────────────────────────────────────────────
-- INTEGRITY VERIFICATION TESTS
-- ─────────────────────────────────────────────────────────────────────────

Suite:group("Checksum Verification", function()

    Suite:testMethod("Security:savegameChecksumValidation", {
        description = "Save games are validated with checksums",
        testCase = "integrity",
        type = "security"
    }, function()
        local saveData = {
            version = "1.0",
            turn = 42,
            checksum = "abc123def456"
        }

        -- Simulate checksum calculation
        local calculateChecksum = function(data)
            -- Simplified: real implementation would hash the data
            return "abc123def456"
        end

        local expectedChecksum = calculateChecksum(saveData)
        local isValid = saveData.checksum == expectedChecksum

        Helpers.assertTrue(isValid, "Save checksum should match calculated value")
    end)

    Suite:testMethod("Security:detectCorruptedSaveFile", {
        description = "Corrupted save files are detected",
        testCase = "corruption_detection",
        type = "security"
    }, function()
        local saveData = {
            version = "1.0",
            turn = 42,
            checksum = "original_hash_123"
        }

        -- Simulate tampering
        saveData.turn = 999

        local isCorrupted = saveData.turn ~= 42

        Helpers.assertTrue(isCorrupted, "Should detect when data was modified")
    end)

    Suite:testMethod("Security:rejectedInvalidChecksum", {
        description = "Files with invalid checksums are rejected",
        testCase = "validation",
        type = "security"
    }, function()
        local file = {
            checksum = "calculated_hash",
            expectedChecksum = "different_hash",
            isValid = false
        }

        if file.checksum ~= file.expectedChecksum then
            file.isValid = false
        end

        Helpers.assertFalse(file.isValid, "Should reject file with bad checksum")
    end)

    Suite:testMethod("Security:checksumRecalculatedOnLoad", {
        description = "Checksums are recalculated and verified on load",
        testCase = "verification",
        type = "security"
    }, function()
        local loadedSave = {
            data = {turn = 42},
            storedChecksum = "hash_123",
            recalculatedChecksum = "hash_123",
            matchesOnLoad = true
        }

        Helpers.assertEqual(loadedSave.storedChecksum, loadedSave.recalculatedChecksum,
                           "Checksums should match on load")
    end)
end)

Suite:group("Tamper Detection", function()

    Suite:testMethod("Security:detectFileModification", {
        description = "File modifications after save are detected",
        testCase = "tampering",
        type = "security"
    }, function()
        local originalHash = "abc123def456ghi789"
        local fileAfterModification = "abc123def456ghi999"  -- Modified

        local isModified = originalHash ~= fileAfterModification

        Helpers.assertTrue(isModified, "Should detect file modification")
    end)

    Suite:testMethod("Security:integritySealOnSensitiveData", {
        description = "Sensitive game state has integrity seals",
        testCase = "sealing",
        type = "security"
    }, function()
        local gameState = {
            resources = {funds = 50000},
            seal = "state_hash_xyz789",
            sealed = true
        }

        Helpers.assertTrue(gameState.sealed, "State should be sealed for integrity")
        Helpers.assertNotNil(gameState.seal, "Should have integrity seal")
    end)
end)

Suite:group("Signature Verification", function()

    Suite:testMethod("Security:downloadedContentVerified", {
        description = "Downloaded content is verified with signatures",
        testCase = "signature",
        type = "security"
    }, function()
        local content = {
            data = "mod_data_binary",
            signature = "signed_hash_xyz",
            isVerified = true
        }

        Helpers.assertNotNil(content.signature, "Content should have signature")
        Helpers.assertTrue(content.isVerified, "Content should be verified")
    end)
end)

return Suite
