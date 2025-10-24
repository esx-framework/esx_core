---VIN System Test Suite
---This file contains comprehensive tests for the Vehicle Identification Number (VIN) system

local function runTests()
    local testResults = {
        passed = 0,
        failed = 0,
        tests = {}
    }
    
    local function test(name, func)
        local success, err = pcall(func)
        if success then
            testResults.passed = testResults.passed + 1
            table.insert(testResults.tests, {name = name, status = "PASSED"})
            print(("^2[TEST PASSED] %s^0"):format(name))
        else
            testResults.failed = testResults.failed + 1
            table.insert(testResults.tests, {name = name, status = "FAILED", error = err})
            print(("^1[TEST FAILED] %s - %s^0"):format(name, err))
        end
    end
    
    -- Test 1: VIN Generation
    test("VIN Generation", function()
        local vin = ESX.GenerateVehicleVIN()
        assert(vin, "VIN generation failed")
        assert(#vin == 17, "VIN length is not 17 characters")
        assert(vin:sub(1, 3) == "1ES", "VIN doesn't start with ESX identifier")
    end)
    
    -- Test 2: VIN Validation
    test("VIN Validation - Valid VIN", function()
        local vin = ESX.GenerateVehicleVIN()
        assert(ESX.ValidateVehicleVIN(vin), "Valid VIN failed validation")
    end)
    
    -- Test 3: VIN Validation - Invalid VIN
    test("VIN Validation - Invalid VIN", function()
        local invalidVINs = {
            "1234567890123456",    -- Wrong length (16)
            "12345678901234567",   -- Contains invalid characters
            "1ES00000000000000",   -- Invalid check digit
            "",                    -- Empty string
            nil                    -- Nil value
        }
        
        for _, invalidVIN in ipairs(invalidVINs) do
            assert(not ESX.ValidateVehicleVIN(invalidVIN), 
                ("Invalid VIN passed validation: %s"):format(tostring(invalidVIN)))
        end
    end)
    
    -- Test 4: VIN Uniqueness
    test("VIN Uniqueness", function()
        local vins = {}
        local iterations = 100
        
        for i = 1, iterations do
            local vin = ESX.GenerateVehicleVIN()
            assert(not vins[vin], ("Duplicate VIN generated: %s"):format(vin))
            vins[vin] = true
        end
    end)
    
    -- Test 5: VIN Decoding
    test("VIN Decoding", function()
        local vin = ESX.GenerateVehicleVIN()
        local decoded = ESX.DecodeVehicleVIN(vin)
        
        assert(decoded, "VIN decoding failed")
        assert(decoded.wmi == "1ES", "WMI not correctly decoded")
        assert(decoded.isValid == true, "Valid VIN not marked as valid")
        assert(decoded.modelYear, "Model year not decoded")
        assert(decoded.plantCode, "Plant code not decoded")
        assert(decoded.serial, "Serial number not decoded")
    end)
    
    -- Test 6: VIN with Model Hash
    test("VIN Generation with Model Hash", function()
        local modelHash = GetHashKey("adder")
        local vin = ESX.GenerateVehicleVIN(modelHash)
        
        assert(vin, "VIN generation with model hash failed")
        assert(#vin == 17, "VIN length is not 17 characters")
        
        -- Generate multiple VINs with same model to ensure they're different
        local vin2 = ESX.GenerateVehicleVIN(modelHash)
        assert(vin ~= vin2, "Same VIN generated for same model")
    end)
    
    -- Test 7: Vehicle Class Integration
    test("Vehicle Class VIN Integration", function()
        -- This test requires database access and would be run in a live environment
        -- Commenting out for safety, but including for completeness
        
        --[[
        local testOwner = "test_owner_" .. os.time()
        local testPlate = "TEST" .. math.random(1000, 9999)
        local coords = vector4(0, 0, 0, 0)
        
        -- First, insert a test vehicle in database
        MySQL.insert.await("INSERT INTO owned_vehicles (owner, plate, vehicle, stored) VALUES (?, ?, ?, ?)",
            {testOwner, testPlate, json.encode({model = "adder"}), true})
        
        -- Create extended vehicle
        local xVehicle = ESX.CreateExtendedVehicle(testOwner, testPlate, coords)
        assert(xVehicle, "Failed to create extended vehicle")
        
        -- Check VIN was generated
        local vin = xVehicle:getVIN()
        assert(vin, "VIN not generated for vehicle")
        assert(#vin == 17, "Invalid VIN length")
        
        -- Test getting vehicle by VIN
        local xVehicle2 = ESX.GetExtendedVehicleFromVIN(vin)
        assert(xVehicle2, "Failed to get vehicle by VIN")
        assert(xVehicle2:getPlate() == testPlate, "Retrieved wrong vehicle by VIN")
        
        -- Cleanup
        xVehicle:delete()
        MySQL.update.await("DELETE FROM owned_vehicles WHERE owner = ?", {testOwner})
        ]]--
        
        print("^3[INFO] Skipping live database test - would test vehicle class VIN integration^0")
    end)
    
    -- Test 8: Check Digit Validation
    test("Check Digit Calculation", function()
        -- Generate a VIN and modify check digit
        local vin = ESX.GenerateVehicleVIN()
        local invalidVIN = vin:sub(1, 8) .. "0" .. vin:sub(10)
        
        assert(ESX.ValidateVehicleVIN(vin), "Original VIN should be valid")
        
        -- This might fail if check digit happens to be 0
        if vin:sub(9, 9) ~= "0" then
            assert(not ESX.ValidateVehicleVIN(invalidVIN), 
                "VIN with wrong check digit should be invalid")
        end
    end)
    
    -- Print test results
    print("\n" .. string.rep("=", 50))
    print("^3VIN SYSTEM TEST RESULTS^0")
    print(string.rep("=", 50))
    print(("^2Passed: %d^0"):format(testResults.passed))
    print(("^1Failed: %d^0"):format(testResults.failed))
    print(("^3Total:  %d^0"):format(testResults.passed + testResults.failed))
    print(string.rep("=", 50))
    
    return testResults
end

-- Command to run tests
RegisterCommand("testvin", function(source, args, rawCommand)
    if source > 0 then
        print("^1This command can only be run from server console^0")
        return
    end
    
    print("\n^3Starting VIN System Tests...^0\n")
    local results = runTests()
    
    if results.failed == 0 then
        print("\n^2All tests passed successfully!^0")
    else
        print("\n^1Some tests failed. Please review the errors above.^0")
    end
end, true)

-- Export test function for external use
exports("runVINTests", runTests)