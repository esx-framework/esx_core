---@class VehicleData
---@field plate string
---@field netId number
---@field entity number
---@field modelHash number
---@field owner string

---@class VehicleClass
---@field plate string
---@field isValid fun(self:VehicleClass):boolean
---@field new fun(owner:string, plate:string, coords:vector4): VehicleClass?
---@field getFromPlate fun(plate:string):VehicleClass?
---@field getPlate fun(self:VehicleClass):string?
---@field getNetId fun(self:VehicleClass):number?
---@field getEntity fun(self:VehicleClass):number?
---@field getModelHash fun(self:VehicleClass):number?
---@field getOwner fun(self:VehicleClass):string?
---@field setPlate fun(self:VehicleClass, plate:string):boolean
---@field setProps fun(self:VehicleClass, props:table):boolean
---@field setOwner fun(self:VehicleClass, owner:string):boolean
---@field delete fun(self:VehicleClass):nil
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

		local vehicleProps = MySQL.scalar.await("SELECT `vehicle` FROM `owned_vehicles` WHERE `stored` = true AND `owner` = ? AND `plate` = ? LIMIT 1", { owner, plate })
		if not vehicleProps then
			return
		end
		vehicleProps = json.decode(vehicleProps)

		if type(vehicleProps.model) ~= "number" then
			vehicleProps.model = joaat(vehicleProps.model)
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

		local vehicleData = {
			plate = plate,
			entity = entity,
			netId = netId,
			modelHash = vehicleProps.model,
			owner = owner,
		}
		Core.vehicles[plate] = vehicleData

		MySQL.update.await("UPDATE `owned_vehicles` SET `stored` = 0 WHERE `owner` = ? AND `plate` = ?", { owner, plate })

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
	isValid = function(self)
		local xVehicle = Core.vehicles[self.plate]
		if not xVehicle then
			return false
		end

		local entity = NetworkGetEntityFromNetworkId(xVehicle.netId)
		if entity <= 0 or Entity(entity).state.owner ~= xVehicle.owner or Entity(entity).state.plate ~= xVehicle.plate then
			self:delete()
			return false
		end

		xVehicle.entity = entity

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
	setPlate = function(self, plate)
		if not self:isValid() then
			return false
		end
		assert(type(plate) == "string", "Expected 'plate' to be a string")

		local xVehicle = Core.vehicles[self.plate]
		local affectedRows = MySQL.update.await("UPDATE `owned_vehicles` SET `plate` = ? WHERE `plate` = ? AND `owner` = ?", { plate, xVehicle.plate, xVehicle.owner })
		if affectedRows <= 0 then
			self:delete()
			return false
		end

		Entity(xVehicle.entity).state:set("plate", plate, false)
		SetVehicleNumberPlateText(xVehicle.entity, plate)

		local oldPlate = xVehicle.plate
		xVehicle.plate = plate
		Core.vehicles[plate] = table.clone(xVehicle)
		Core.vehicles[self.plate] = nil

		TriggerEvent("esx:changedExtendedVehiclePlate", xVehicle.plate, oldPlate)
		Wait(0)

		return true
	end,
	setProps = function(self, props)
		if not self:isValid() then
			return false
		end
		assert(type(props) == "table", "Expected 'props' to be a table")

		local xVehicle = Core.vehicles[self.plate]
		local affectedRows = MySQL.update.await("UPDATE `owned_vehicles` SET `vehicle` = ? WHERE `plate` = ? AND `owner` = ?", json.encode(props), xVehicle.plate, xVehicle.owner)
		if affectedRows <= 0 then
			self:delete()
			return false
		end

		Entity(xVehicle.entity).state:set("VehicleProperties", props, true)

		return true
	end,
	setOwner = function(self, owner)
		if not self:isValid() then
			return false
		end
		assert(type(owner) == "string", "Expected 'owner' to be a string")

		local xVehicle = Core.vehicles[self.plate]
		if xVehicle.owner == owner then
			return true
		end

		local affectedRows = MySQL.update.await("UPDATE `owned_vehicles` SET `owner` = ? WHERE owner = ? AND `plate` = ?", { owner, xVehicle.owner, xVehicle.plate })
		if affectedRows <= 0 then
			self:delete()
			return false
		end

		Entity(xVehicle.entity).state:set("owner", owner, false)
		xVehicle.owner = owner

		return true
	end,
	delete = function(self)
		local xVehicle = Core.vehicles[self.plate]
		if not xVehicle then
			return
		end

		local entity = NetworkGetEntityFromNetworkId(xVehicle.netId)
		if entity >= 0 and Entity(entity).state.owner == xVehicle.owner then
			DeleteEntity(xVehicle.entity)
		end

		MySQL.update.await("UPDATE `owned_vehicles` SET `stored` = 1 WHERE `plate` = ?", { xVehicle.plate })
		TriggerEvent("esx:deletedExtendedVehicle", self)

		Core.vehicles[self.plate] = nil
	end,
}
