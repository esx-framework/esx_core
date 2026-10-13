--[[
    https://github.com/overextended/ox_lib

    This file is licensed under LGPL-3.0 or higher <https://www.gnu.org/licenses/lgpl-3.0.en.html>

    Copyright © 2025 Linden <https://github.com/thelindat>
]]

---@class KeybindProps
---@field name string
---@field description string
---@field defaultMapper? string (see: https://docs.fivem.net/docs/game-references/input-mapper-parameter-ids/)
---@field defaultKey? string
---@field disabled? boolean
---@field disable? fun(self: CKeybind, toggle: boolean)
---@field onPressed? fun(self: CKeybind)
---@field onReleased? fun(self: CKeybind)
---@field remove? fun(self: CKeybind)
---@field [string] any

---@class CKeybind : KeybindProps
---@field currentKey string
---@field disabled boolean
---@field isPressed boolean
---@field hash number
---@field getCurrentKey fun(): string
---@field isControlPressed fun(): boolean

local keybinds = {}

local IsPauseMenuActive = IsPauseMenuActive
local GetControlInstructionalButton = GetControlInstructionalButton

local keybind_mt = {
    disabled = false,
    isPressed = false,
    defaultKey = '',
    defaultMapper = 'keyboard',
}

function keybind_mt:__index(index)
    return index == 'currentKey' and self:getCurrentKey() or keybind_mt[index]
end

function keybind_mt:getCurrentKey()
    return GetControlInstructionalButton(0, self.hash, true):sub(3)
end

function keybind_mt:isControlPressed()
    return self.isPressed
end

function keybind_mt:disable(toggle)
    self.disabled = toggle
end

function keybind_mt:remove()
    if not keybinds[self.name] then return end
    keybinds[self.name] = nil
end

---@param data KeybindProps
---@return CKeybind
function xLib.addKeybind(data)
    data.hash = joaat("+" .. data.name) | 0x80000000
    keybinds[data.name] = setmetatable(data, keybind_mt)

    RegisterCommand('+' .. data.name, function()
        if not keybinds[data.name] then return end
        if data.disabled or IsPauseMenuActive() then return end
        data.isPressed = true
        if data.onPressed then data:onPressed() end
    end)

    RegisterCommand('-' .. data.name, function()
        if not keybinds[data.name] then return end
        if data.disabled or IsPauseMenuActive() then return end
        data.isPressed = false
        if data.onReleased then data:onReleased() end
    end)

    RegisterKeyMapping('+' .. data.name, data.description, data.defaultMapper, data.defaultKey)

    SetTimeout(500, function()
        TriggerEvent('chat:removeSuggestion', ('/+%s'):format(data.name))
        TriggerEvent('chat:removeSuggestion', ('/-%s'):format(data.name))
    end)

    return data
end

return xLib.addKeybind