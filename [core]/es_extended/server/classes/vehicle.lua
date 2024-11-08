-- Inspired by https://github.com/overextended/ox_core/blob/main/server/vehicle/class.ts

---@class VehicleData
---@field netId number
---@field entity number
---@field plate string
---@field modelHash number
---@field props table
---@field owner string|false

---@class VehicleClass
---@field netId number
---@field getNetId fun(self:VehicleClass):number
---@field getEntity fun(self:VehicleClass):number
---@field getPlate fun(self:VehicleClass):string
---@field getModelHash fun(self:VehicleClass):number
---@field getProps fun(self:VehicleClass):table
---@field getOwner fun(self:VehicleClass):string|false
---@field setPlate fun(self:VehicleClass, plate:string, apply:boolean):nil
---@field setProps fun(self:VehicleClass, props:table, apply:boolean):nil
---@field setOwner fun(self:VehicleClass, owner:string|false):nil
---@field despawn fun(self:VehicleClass):nil

---@type table<number, VehicleData>
local vehicles = {}

---@type VehicleClass
local vehicleClass = {
	netId = -1,
	getNetId = function(self)
		assert(vehicles[self.netId] ~= nil, "Attempted to access invalid vehicle")

		return vehicles[self.netId].netId
	end,
	getEntity = function(self)
		assert(vehicles[self.netId] ~= nil, "Attempted to access invalid vehicle")

		return vehicles[self.netId].entity
	end,
	getPlate = function(self)
		assert(vehicles[self.netId] ~= nil, "Attempted to access invalid vehicle")

		return vehicles[self.netId].plate
	end,
	getModelHash = function(self)
		assert(vehicles[self.netId] ~= nil, "Attempted to access invalid vehicle")

		return vehicles[self.netId].modelHash
	end,
	getProps = function(self)
		assert(vehicles[self.netId] ~= nil, "Attempted to access invalid vehicle")

		return vehicles[self.netId].props
	end,
	getOwner = function(self)
		assert(vehicles[self.netId] ~= nil, "Attempted to access invalid vehicle")

		return vehicles[self.netId].owner
	end,
	setPlate = function(self, plate, apply)
		assert(vehicles[self.netId] ~= nil, "Attempted to access invalid vehicle")
		assert(type(plate) == "string", "Expected 'plate' to be a string")

		local vehicle = vehicles[self.netId]
		if apply and vehicle.owner then
			SetVehicleNumberPlateText(vehicle.entity, plate)
			MySQL.prepare("UPDATE `owned_vehicles` SET `plate` = ? WHERE `plate` = ? AND `owner` = ?", plate, vehicle.plate, vehicle.owner)
		end
		vehicle.plate = plate
	end,
	setProps = function(self, props, apply)
		assert(vehicles[self.netId] ~= nil, "Attempted to access invalid vehicle")
		assert(type(props) == "table", "Expected 'props' to be a table")

		local vehicle = vehicles[self.netId]
		if apply and vehicle.owner then
			Entity(vehicle.entity).state:set("VehicleProperties", props, true)
			MySQL.prepare("UPDATE `owned_vehicles` SET `vehicle` = ? WHERE `plate` = ?", json.encode(props), vehicle.plate)
		end

		vehicle.props = props
	end,
	setOwner = function(self, owner)
		assert(vehicles[self.netId] ~= nil, "Attempted to access invalid vehicle")
		assert(type(owner) == "string" or owner == false, "Expected 'owner' to be a string or false")

		local vehicle = vehicles[self.netId]
		if (vehicle.owner == owner) then return end

		if owner then
			---@TODO: Insert if not exists?
			MySQL.prepare("UPDATE `owned_vehicles` SET `owner` = ? WHERE `plate` = ?", owner, vehicle.plate)
		else
			MySQL.prepare("DELETE FROM `owned_vehicles` WHERE `owner` = ? AND `plate` = ?", vehicle.owner, vehicle.plate)
		end

		vehicles[self.netId].owner = owner
	end,
	despawn = function(self)
		assert(vehicles[self.netId] ~= nil, "Attempted to access invalid vehicle")

		local vehicle = vehicles[self.netId]
		if DoesEntityExist(vehicle.entity) then
			DeleteEntity(vehicle.entity)
		end
		TriggerEvent("esx:vehicleDespawned", self.netId)

		MySQL.prepare("UPDATE `owned_vehicles` SET `stored` = 1 WHERE `plate` = ?", vehicle.plate)

		vehicles[self.netId] = nil
	end,
}

---@param plate string
---@param entity number
---@param model string|number
---@param props table
---@param owner string|false
---@return VehicleClass
function ESX.CreateExtendedVehicle(plate, entity, model, props, owner)
	assert(type(plate) == "string", "Expected 'plate' to be a string")
	assert(type(entity) == "number", "Expected 'entity' to be a number")
	assert(type(model) == "string" or type(model) == "number", "Expected 'model' to be a string or number")
	assert(type(props) == "table", "Expected 'props' to be a table")
	assert(type(owner) == "string" or owner == false, "Expected 'owner' to be a string or false")
	assert(DoesEntityExist(entity) == true, "Entity does not exist")
	assert(GetEntityType(entity) == 2, "Entity is not a vehicle")

	local netId = NetworkGetNetworkIdFromEntity(entity)

	if vehicles[netId] then
		local obj = table.clone(vehicleClass)
		obj.netId = netId
		return obj
	end

	if type(model) ~= "number" then
		model = GetHashKey(model)
	end

	---@type VehicleData
	local vehicle = {
		plate = plate,
		entity = entity,
		netId = netId,
		modelHash = model,
		props = props,
		owner = owner,
	}
	vehicles[netId] = vehicle

	if owner then
		---@TODO: Insert to db if not exists?
	end

	local obj = table.clone(vehicleClass)
	obj.netId = netId
	TriggerEvent("esx:vehicleCreated", obj)

	MySQL.prepare("UPDATE `owned_vehicles` SET `stored` = 0 WHERE `plate` = ?", plate)

	return obj
end

---@param netId number
---@return VehicleClass|nil
function ESX.GetVehicleFromNetId(netId)
	if vehicles[netId] then
		local obj = table.clone(vehicleClass)
		obj.netId = netId
		return obj
	end
end
