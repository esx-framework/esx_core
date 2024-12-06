-- Inspired by https://github.com/overextended/ox_core/blob/main/server/vehicle/class.ts

---@class VehicleData
---@field plate string
---@field netId number
---@field entity number
---@field modelHash number
---@field props table
---@field owner string

---@class VehicleClass
---@field plate string
---@field getPlate fun(self:VehicleClass):string
---@field getNetId fun(self:VehicleClass):number
---@field getEntity fun(self:VehicleClass):number
---@field getModelHash fun(self:VehicleClass):number
---@field getProps fun(self:VehicleClass):table
---@field getOwner fun(self:VehicleClass):string
---@field setPlate fun(self:VehicleClass, plate:string, apply:boolean):nil
---@field setProps fun(self:VehicleClass, props:table, apply:boolean):nil
---@field setOwner fun(self:VehicleClass, owner:string):nil
---@field despawn fun(self:VehicleClass):nil


Core.vehicleClass = {
	plate = "",
	getNetId = function(self)
		assert(Core.vehicles[self.plate] ~= nil, "Attempted to access invalid vehicle")

		return Core.vehicles[self.plate].netId
	end,
	getEntity = function(self)
		assert(Core.vehicles[self.plate] ~= nil, "Attempted to access invalid vehicle")

		return Core.vehicles[self.plate].entity
	end,
	getPlate = function(self)
		assert(Core.vehicles[self.plate] ~= nil, "Attempted to access invalid vehicle")

		return Core.vehicles[self.plate].plate
	end,
	getModelHash = function(self)
		assert(Core.vehicles[self.plate] ~= nil, "Attempted to access invalid vehicle")

		return Core.vehicles[self.plate].modelHash
	end,
	getProps = function(self)
		assert(Core.vehicles[self.plate] ~= nil, "Attempted to access invalid vehicle")

		return Core.vehicles[self.plate].props
	end,
	getOwner = function(self)
		assert(Core.vehicles[self.plate] ~= nil, "Attempted to access invalid vehicle")

		return Core.vehicles[self.plate].owner
	end,
	setPlate = function(self, plate, apply)
		assert(Core.vehicles[self.plate] ~= nil, "Attempted to access invalid vehicle")
		assert(type(plate) == "string", "Expected 'plate' to be a string")

		local vehicle = Core.vehicles[self.plate]
		if apply and vehicle.owner then
			SetVehicleNumberPlateText(vehicle.entity, plate)
			MySQL.prepare("UPDATE `owned_vehicles` SET `plate` = ? WHERE `plate` = ? AND `owner` = ?", plate, vehicle.plate, vehicle.owner)
		end
		vehicle.plate = plate
	end,
	setProps = function(self, props, apply)
		assert(Core.vehicles[self.plate] ~= nil, "Attempted to access invalid vehicle")
		assert(type(props) == "table", "Expected 'props' to be a table")

		local vehicle = Core.vehicles[self.plate]
		if apply and vehicle.owner then
			Entity(vehicle.entity).state:set("VehicleProperties", props, true)
			MySQL.prepare("UPDATE `owned_vehicles` SET `vehicle` = ? WHERE `plate` = ?", json.encode(props), vehicle.plate)
		end

		vehicle.props = props
	end,
	setOwner = function(self, owner)
		assert(Core.vehicles[self.plate] ~= nil, "Attempted to access invalid vehicle")
		assert(type(owner) == "string", "Expected 'owner' to be a string")

		local vehicle = Core.vehicles[self.plate]
		if (vehicle.owner == owner) then
			return
		end

		MySQL.prepare("UPDATE `owned_vehicles` SET `owner` = ? WHERE `plate` = ?", owner, vehicle.plate)

		Core.vehicles[self.plate].owner = owner
	end,
	despawn = function(self)
		assert(Core.vehicles[self.plate] ~= nil, "Attempted to access invalid vehicle")

		local vehicle = Core.vehicles[self.plate]
		if DoesEntityExist(vehicle.entity) then
			DeleteEntity(vehicle.entity)
		end
		TriggerEvent("esx:vehicleDespawned", self.plate)

		MySQL.prepare("UPDATE `owned_vehicles` SET `stored` = 1 WHERE `plate` = ?", vehicle.plate)

		Core.vehicles[self.plate] = nil
	end,
}
