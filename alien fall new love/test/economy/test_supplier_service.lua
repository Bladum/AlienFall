--- Supplier Service Tests
-- Tests for the SupplierService class

local lust = require 'test.lust'
local SupplierService = require 'economy.SupplierService'

local function testSupplierService()
    lust.describe("SupplierService", function()
        local registry
        local service

        lust.before(function()
            -- Create mock registry
            registry = {
                getService = function(name)
                    if name == 'eventBus' then
                        return {
                            emit = function() end -- Mock emit
                        }
                    elseif name == 'marketplaceService' then
                        return {
                            getMarketPrices = function()
                                return { buyPrice = 1000, sellPrice = 500 }
                            end
                        }
                    elseif name == 'transferService' then
                        return {
                            createPurchaseTransfer = function()
                                return true, "Transfer created"
                            end
                        }
                    end
                    return nil
                end,
                registerService = function() end -- Mock register
            }

            -- Create service instance
            service = SupplierService:new(registry)
        end)

        lust.it("should initialize correctly", function()
            lust.expect(service).to.exist()
            lust.expect(service.suppliers).to.be.a('table')
            lust.expect(service.supplierStock).to.be.a('table')
            lust.expect(service.supplierRelationships).to.be.a('table')
        end)

        lust.it("should load supplier data", function()
            lust.expect(function()
                service:_loadSupplierData()
            end).to_not.fail()
        end)

        lust.it("should get available suppliers", function()
            local suppliers = service:getAvailableSuppliers(1)
            lust.expect(suppliers).to.be.a('table')
        end)

        lust.it("should get stock for supplier item", function()
            local stock = service:getStock("ares_armaments", "assault_rifle")
            lust.expect(stock).to.be.a('number')
            lust.expect(stock).to.be.greater_than_or_equal(0)
        end)

        lust.it("should purchase from supplier", function()
            local success, message = service:purchaseFromSupplier("ares_armaments", "assault_rifle", 1, 1)
            lust.expect(success).to.be.a('boolean')
            lust.expect(message).to.be.a('string')
        end)

        lust.it("should sell to marketplace", function()
            local success, message = service:sellItem("assault_rifle", 1, 1)
            lust.expect(success).to.be.a('boolean')
            lust.expect(message).to.be.a('string')
        end)

        lust.it("should get supplier relationship", function()
            local relationship = service:getSupplierRelationship("ares_armaments")
            lust.expect(relationship).to.be.a('number')
        end)

        lust.it("should get supplier info", function()
            local info = service:getSupplierInfo("ares_armaments")
            if info then
                lust.expect(info).to.be.a('table')
                lust.expect(info.id).to.equal("ares_armaments")
                lust.expect(info.relationship).to.be.a('number')
            end
        end)

        lust.it("should check supplier unlock status", function()
            local unlocked = service:isSupplierUnlocked("ares_armaments")
            lust.expect(unlocked).to.be.a('boolean')
        end)

        lust.it("should update stock", function()
            lust.expect(function()
                service:updateStock()
            end).to_not.fail()
        end)
    end)
end

return testSupplierService