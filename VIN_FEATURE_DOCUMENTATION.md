# Vehicle Identification Number (VIN) System

## Overview
This feature adds a comprehensive Vehicle Identification Number (VIN) system to the ESX Framework, providing unique identifiers for all vehicles. The VIN system follows real-world standards while being adapted for FiveM/GTA V use.

## Features

### 1. VIN Generation
- **17-character VIN format** following modified ISO 3779 standard
- **Unique identifiers** for every vehicle
- **Check digit validation** to prevent tampering
- **Model-specific encoding** when vehicle model is provided

### 2. VIN Structure
```
1ES XXXXX X Y ZZZZZZ
│││ │││││ │ │ ││││││
│││ │││││ │ │ └─────── Serial Number (6 chars)
│││ │││││ │ └───────── Plant Code (1 char)
│││ │││││ └─────────── Model Year (1 char)
│││ ││││└───────────── Check Digit (1 char)
│││ └───────────────── Vehicle Descriptor (5 chars)
└───────────────────── World Manufacturer ID (ESX)
```

### 3. Database Changes
- Added `vin` column to `owned_vehicles` table
- Added index for faster VIN lookups
- Optional VIN history tracking table
- Database triggers for audit trail

## API Reference

### Server Functions

#### ESX.GenerateVehicleVIN(modelHash?, owner?)
Generates a unique VIN for a vehicle.
```lua
local vin = ESX.GenerateVehicleVIN(GetHashKey("adder"), "char1:identifier")
print(vin) -- Output: 1ES2X3Y45S1X123456
```

#### ESX.ValidateVehicleVIN(vin)
Validates a VIN's format and check digit.
```lua
local isValid = ESX.ValidateVehicleVIN("1ES2X3Y45S1X123456")
if isValid then
    print("VIN is valid")
end
```

#### ESX.DecodeVehicleVIN(vin)
Decodes a VIN to extract information.
```lua
local info = ESX.DecodeVehicleVIN("1ES2X3Y45S1X123456")
print(info.modelYear) -- 2025
print(info.serial)    -- 123456
```

#### ESX.GetExtendedVehicleFromVIN(vin)
Gets an extended vehicle object by its VIN.
```lua
local xVehicle = ESX.GetExtendedVehicleFromVIN("1ES2X3Y45S1X123456")
if xVehicle then
    print(xVehicle:getPlate())
end
```

### Vehicle Class Methods

#### xVehicle:getVIN()
Gets the VIN of a vehicle.
```lua
local xVehicle = ESX.GetExtendedVehicleFromPlate("ABC 123")
local vin = xVehicle:getVIN()
print(vin) -- Vehicle's VIN
```

## Installation

### 1. Database Migration
Run the SQL migration script to add VIN support:
```sql
mysql -u root -p esx_legacy < [SQL]/add_vin_support.sql
```

### 2. Generate VINs for Existing Vehicles (Optional)
After installation, you can generate VINs for existing vehicles:
```sql
CALL GenerateVINsForExistingVehicles();
```

### 3. Testing
Run the test suite to verify installation:
```
testvin
```

## Usage Examples

### Creating a Vehicle with VIN
```lua
-- When creating a new owned vehicle
local xPlayer = ESX.GetPlayerFromId(source)
local vehicleProps = {model = "adder", plate = "NEW CAR"}

-- Generate VIN before inserting
local vin = ESX.GenerateVehicleVIN(GetHashKey("adder"), xPlayer.identifier)

MySQL.insert("INSERT INTO owned_vehicles (owner, plate, vehicle, vin) VALUES (?, ?, ?, ?)",
    {xPlayer.identifier, vehicleProps.plate, json.encode(vehicleProps), vin})
```

### Searching by VIN
```lua
-- Find a vehicle by VIN
local vin = "1ES2X3Y45S1X123456"
local xVehicle = ESX.GetExtendedVehicleFromVIN(vin)

if xVehicle then
    print("Found vehicle with plate: " .. xVehicle:getPlate())
    print("Owner: " .. xVehicle:getOwner())
end
```

### VIN Validation in Commands
```lua
RegisterCommand("checkvin", function(source, args)
    local vin = args[1]
    
    if not vin then
        TriggerClientEvent("esx:showNotification", source, "Usage: /checkvin [VIN]")
        return
    end
    
    if ESX.ValidateVehicleVIN(vin) then
        local info = ESX.DecodeVehicleVIN(vin)
        TriggerClientEvent("esx:showNotification", source, 
            ("Valid VIN - Year: %d, Serial: %s"):format(info.modelYear, info.serial))
    else
        TriggerClientEvent("esx:showNotification", source, "Invalid VIN format")
    end
end)
```

## Migration Guide

### For Existing Resources
Resources that create vehicles should be updated to include VIN generation:

**Before:**
```lua
MySQL.insert("INSERT INTO owned_vehicles (owner, plate, vehicle) VALUES (?, ?, ?)",
    {owner, plate, vehicleData})
```

**After:**
```lua
local vin = ESX.GenerateVehicleVIN(vehicleModel, owner)
MySQL.insert("INSERT INTO owned_vehicles (owner, plate, vehicle, vin) VALUES (?, ?, ?, ?)",
    {owner, plate, vehicleData, vin})
```

## Performance Considerations

- VIN generation is optimized with caching
- Database indexes ensure fast lookups
- Check digit validation is lightweight
- Batch operations supported for multiple vehicles

## Security Features

- **Check digit** prevents VIN tampering
- **Unique constraint** prevents duplicates
- **Audit trail** tracks VIN history
- **Validation** ensures data integrity

## Troubleshooting

### Common Issues

1. **Duplicate VIN Error**
   - The system will retry generation up to 10 times
   - If persistent, check database constraints

2. **Invalid VIN Format**
   - Ensure VIN is exactly 17 characters
   - Check for invalid characters (I, O, Q are not allowed)

3. **Migration Fails**
   - Ensure MySQL user has ALTER TABLE permissions
   - Check for existing `vin` column

## Future Enhancements

- [ ] Client-side VIN display UI
- [ ] VIN barcode generation
- [ ] Export/Import VIN registry
- [ ] VIN-based insurance system
- [ ] Vehicle history tracking

## Contributing

Please follow the ESX contribution guidelines when submitting improvements to the VIN system.

## License

This feature is part of the ESX Framework and follows the same license terms.