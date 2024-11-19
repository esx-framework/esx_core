Blip = ESX.Class()

function Blip:constructor(properties)
    self.coords = type(properties.coords) == "vector3" and properties.coords or vector3(properties.coords.x, properties.coords.y, properties.coords.z)
    self.sprite = type(properties.sprite) == "number" and properties.sprite or 1
    self.colour = type(properties.colour) == "number" and properties.colour or 0
    self.label = type(properties.label) == "string" and properties.label or "Unknown"
    self.scale = type(properties.scale) == "number" and properties.scale or 1.0
    self.display = type(properties.display) == "number" and properties.display or 4
    self.shortRange = type(properties.shortRange) == "boolean" and properties.shortRange or true 
    self.resource = GetInvokingResource() or GetCurrentResourceName() or "es_extended"

    local handle = ESX.CreateBlipInternal(coords, sprite, colour, label, scale, display, shortRange, resource)
    self.handle = handle 

    return handle
end

function Blip:setCoords(coords)
    self.coords = type(coords) == "vector3" and coords or vector3(coords.x, coords.y, coords.z)
    
    ESX.SetBlipCoords(self.handle, self.coords)
end

function Blip:setSprite(sprite)
    self.sprite = type(sprite) == "number" and sprite or 1

    ESX.SetBlipSprite(self.handle, self.sprite)
end

function Blip:setColour(colour)
    self.colour = type(colour) == "number" and colour or 0

    ESX.SetBlipColour(self.handle, self.colour)
end

function Blip:setLabel(label)
    self.label = type(label) == "string" and label or "Unknown"

    ESX.SetBlipLabel(self.handle, self.label)
end

function Blip:setScale(scale)
    self.scale = type(scale) == "number" and scale or 0

    ESX.SetBlipScale(self.handle, self.scale)
end

function Blip:setDisplay(display)
    self.display = type(display) == "number" and display or 4

    ESX.SetBlipDisplay(self.handle, self.display)
end

function Blip:setShortRange(shortRange)
    self.shortRange = type(shortRange) == "boolean" and shortRange or true 

    ESX.SetBlipShortRange(self.handle, self.shortRange)
end

function Blip:delete()
    ESX.RemoveBlip(self.handle)
end

return Blip