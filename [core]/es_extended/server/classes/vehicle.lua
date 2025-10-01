---@class CVehicleData
---@field plate string
---@field vin string?
---@field netId number
---@field entity number
---@field modelHash number
---@field owner string

---@class CExtendedVehicle
---@field plate string
---@field isValid fun(self:CExtendedVehicle):boolean
---@field new fun(owner:string, plate:string, coords:vector4): CExtendedVehicle?
---@field getFromPlate fun(plate:string):CExtendedVehicle?
---@field getFromVIN fun(vin:string):CExtendedVehicle?
---@field getPlate fun(self:CExtendedVehicle):string?
---@field getVIN fun(self:CExtendedVehicle):string?
---@field getNetId fun(self:CExtendedVehicle):number?
---@field getEntity fun(self:CExtendedVehicle):number?
---@field getModelHash fun(self:CExtendedVehicle):number?
---@field getOwner fun(self:CExtendedVehicle):string?
---@field setPlate fun(self:CExtendedVehicle, newPlate:string):boolean
---@field setProps fun(self:CExtendedVehicle, newProps:table):boolean
---@field setOwner fun(self:CExtendedVehicle, newOwner:string):boolean
---@field delete fun(self:CExtendedVehicle, garageName:string?, isImpound:boolean?):nil
Core.vehicleClass = {
	plate = "",
	new = function(owner, plate, coords)
		assert(type(owner) == "string", "Expected 'owner' to be a string")
		assert(type(plate) == "string", "Expected 'plate' to be a string")
		assert(type(coords) == "vector4", "Expected 'coords' to be a vector4")

		local xVehicle = Core.vehicleClass.getFromPlate(plate)
		if xVehicle then
			return xVehicle
		end

		local vehicleData = MySQL.single.await("SELECT `vehicle`, `vin` FROM `owned_vehicles` WHERE `stored` = true AND `owner` = ? AND `plate` = ? LIMIT 1", { owner, plate })
		if not vehicleData then
			return
		end
		local vehicleProps = json.decode(vehicleData.vehicle)
		local vin = vehicleData.vin

		if type(vehicleProps.model) ~= "number" then
			vehicleProps.model = joaat(vehicleProps.model)
		end

		-- Generate VIN if it doesn't exist
		if not vin or vin == "" then
			if not ESX.VIN then
				print("^1[ESX] VIN module not loaded^0")
				return
			end
			vin = ESX.VIN.generateUnique(vehicleProps.model, owner)
			if vin then
				MySQL.update.await("UPDATE `owned_vehicles` SET `vin` = ? WHERE `owner` = ? AND `plate` = ?", { vin, owner, plate })
			end
		end

		local netId = ESX.OneSync.SpawnVehicle(vehicleProps.model, coords.xyz, coords.w, vehicleProps)
		if not netId then
			return
		end

		local entity = NetworkGetEntityFromNetworkId(netId)
		if entity <= 0 then
			return
		end
		Entity(entity).state:set("owner", owner, false)
		Entity(entity).state:set("plate", plate, false)
		if vin then
			Entity(entity).state:set("vin", vin, false)
		end

		---@type CVehicleData
		local vehicleData = {
			plate = plate,
			vin = vin,
			entity = entity,
			netId = netId,
			modelHash = vehicleProps.model,
			owner = owner,
		}
		Core.vehicles[plate] = vehicleData

		MySQL.update.await("UPDATE `owned_vehicles` SET `stored` = false WHERE `owner` = ? AND `plate` = ?", { owner, plate })

		local obj = table.clone(Core.vehicleClass)
		obj.plate = plate
		TriggerEvent("esx:createdExtendedVehicle", obj)

		return obj
	end,
	getFromPlate = function(plate)
		assert(type(plate) == "string", "Expected 'plate' to be a string")

		if Core.vehicles[plate] then
			local obj = table.clone(Core.vehicleClass)
			obj.plate = plate

			if obj:isValid() then
				return obj
			end
		end
	end,
	getFromVIN = function(vin)
		assert(type(vin) == "string", "Expected 'vin' to be a string")

		-- Find vehicle by VIN in Core.vehicles
		for plate, vehicleData in pairs(Core.vehicles) do
			if vehicleData.vin == vin then
				local obj = table.clone(Core.vehicleClass)
				obj.plate = plate

				if obj:isValid() then
					return obj
				end
				break
			end
		end
	end,
	isValid = function(self)
		local vehicleData = Core.vehicles[self.plate]
		if not vehicleData then
			return false
		end

		local entity = NetworkGetEntityFromNetworkId(vehicleData.netId)
		if entity <= 0 or Entity(entity).state.owner ~= vehicleData.owner or Entity(entity).state.plate ~= vehicleData.plate then
			self:delete()
			return false
		end

		vehicleData.entity = entity

		return true
	end,
	getNetId = function(self)
		if not self:isValid() then
			return
		end

		return Core.vehicles[self.plate].netId
	end,
	getEntity = function(self)
		if not self:isValid() then
			return
		end

		return Core.vehicles[self.plate].entity
	end,
	getPlate = function(self)
		if not self:isValid() then
			return
		end

		return Core.vehicles[self.plate].plate
	end,
	getVIN = function(self)
		if not self:isValid() then
			return
		end

		return Core.vehicles[self.plate].vin
	end,
	getModelHash = function(self)
		if not self:isValid() then
			return
		end

		return Core.vehicles[self.plate].modelHash
	end,
	getOwner = function(self)
		if not self:isValid() then
			return
		end

		return Core.vehicles[self.plate].owner
	end,
	setPlate = function(self, newPlate)
		if not self:isValid() then
			return false
		end
		assert(type(newPlate) == "string", "Expected 'plate' to be a string")

		local vehicleData = Core.vehicles[self.plate]
		local affectedRows = MySQL.update.await("UPDATE `owned_vehicles` SET `plate` = ? WHERE `plate` = ? AND `owner` = ?", { newPlate, vehicleData.plate, vehicleData.owner })
		if affectedRows <= 0 then
			self:delete()
			return false
		end

		Entity(vehicleData.entity).state:set("plate", newPlate, false)
		SetVehicleNumberPlateText(vehicleData.entity, newPlate)

		local oldPlate = vehicleData.plate
		vehicleData.plate = newPlate
		Core.vehicles[newPlate] = table.clone(vehicleData)
		Core.vehicles[oldPlate] = nil
		
		-- Update self.plate to reflect the change
		self.plate = newPlate

		TriggerEvent("esx:changedExtendedVehiclePlate", vehicleData.plate, oldPlate)
		Wait(0)

		return true
	end,
	setProps = function(self, newProps)
		if not self:isValid() then
			return false
		end
		assert(type(newProps) == "table", "Expected 'props' to be a table")

		local vehicleData = Core.vehicles[self.plate]
		local affectedRows = MySQL.update.await("UPDATE `owned_vehicles` SET `vehicle` = ? WHERE `plate` = ? AND `owner` = ?", json.encode(newProps), vehicleData.plate, vehicleData.owner)
		if affectedRows <= 0 then
			self:delete()
			return false
		end

		Entity(vehicleData.entity).state:set("VehicleProperties", newProps, true)

		return true
	end,
	setOwner = function(self, newOwner)
		if not self:isValid() then
			return false
		end
		assert(type(newOwner) == "string", "Expected 'owner' to be a string")

		local vehicleData = Core.vehicles[self.plate]
		if vehicleData.owner == newOwner then
			return true
		end

		local affectedRows = MySQL.update.await("UPDATE `owned_vehicles` SET `owner` = ? WHERE owner = ? AND `plate` = ?", { newOwner, vehicleData.owner, vehicleData.plate })
		if affectedRows <= 0 then
			self:delete()
			return false
		end

		Entity(vehicleData.entity).state:set("owner", newOwner, false)
		vehicleData.owner = newOwner

		return true
	end,
	delete = function(self, garageName, isImpound)
		if type(garageName) ~= "string" then
			garageName = nil
		end
		if type(isImpound) ~= "boolean" then
			isImpound = false
		end

		local vehicleData = Core.vehicles[self.plate]
		if not vehicleData then
			return
		end

		local entity = NetworkGetEntityFromNetworkId(vehicleData.netId)
		if entity >= 0 and Entity(entity).state.owner == vehicleData.owner then
			DeleteEntity(vehicleData.entity)
		end

		local query = "UPDATE `owned_vehicles` SET `stored` = true WHERE `plate` = ? AND `owner` = ?"
		local queryParams = { vehicleData.plate, vehicleData.owner }
		if garageName then
			if isImpound then
				query = "UPDATE `owned_vehicles` SET `stored` = true, `parking` = NULL, `pound` = ? WHERE `plate` = ? AND `owner` = ?"
			else
				query = "UPDATE `owned_vehicles` SET `stored` = true, `pound` = NULL, `parking` = ? WHERE `plate` = ? AND `owner` = ?"
			end

			queryParams = { garageName, vehicleData.plate, vehicleData.owner }
		end

		MySQL.update.await(query, queryParams)
		TriggerEvent("esx:deletedExtendedVehicle", self)

		Core.vehicles[self.plate] = nil
	end,
}
