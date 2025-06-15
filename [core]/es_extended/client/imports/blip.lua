local Blip = {}
Blip.__gc = Blip.delete

---@param sprite? number
function Blip:setSprite(sprite)
	self.sprite = sprite or 1
	SetBlipSprite(self.handle, self.sprite)
end

---@param scale? number
function Blip:setScale(scale)
	self.scale = scale or 1
	SetBlipScale(self.handle, self.scale)
end

---@param colour? number
function Blip:setColour(colour)
	self.colour = colour or 1
	SetBlipColour(self.handle, self.colour)
end

---@param shortRange? boolean
function Blip:setShortRange(shortRange)
	self.shortRange = shortRange ~= nil and shortRange or true
	SetBlipAsShortRange(self.handle, self.shortRange)
end

---@param label? string
function Blip:setLabel(label)
	self.label = label or "Blip"
	BeginTextCommandSetBlipName('ESX_BLIP')
    AddTextComponentSubstringPlayerName(self.label)
    EndTextCommandSetBlipName(self.handle)
end

---@param position vector3 | number | vector4 | table
function Blip:setPosition(position)
	if not position then return end
	self.position = position
	if self.handle then
		self:delete()
		Wait(0)
		self:create()
	end
end

---@param position vector3 | number
---@param label? string
---@param sprite? number
---@param scale? number
---@param colour? number
---@param shortRange? boolean
function Blip:new(position, label, sprite, scale, colour, shortRange)
	return setmetatable({
		position = position,
		label = label,
		sprite = sprite,
		scale = scale,
		colour = colour,
		shortRange = shortRange,
	}, Blip)
end

function Blip:create()
	if type(self.position) == "number" then
		if not DoesEntityExist(self.position) then return end
		self.handle = AddBlipForEntity(self.position)
	elseif type(self.position) == "vector3" then
		self.handle = AddBlipForCoord(self.position.x, self.position.y, self.position.z)
	elseif type(self.position) == "vector4" then
		self.handle = AddBlipForRadius(self.position.x, self.position.y, self.position.z, self.position.w)
	elseif type(self.position) == "table" then
		self.handle = AddBlipForArea(self.position.x, self.position.y, self.position.z, self.position.width, self.position.height)
	end

	if not self.handle then
		error("Failed to create Blip")
	end

	self:setSprite(self.sprite)
	self:setScale(self.scale)
	self:setColour(self.colour)
	self:setShortRange(self.shortRange)
	self:setLabel(self.label)
end

function Blip:delete()
	RemoveBlip(self.handle)
	self.handle = nil
end

return Blip