--[[
    https://github.com/overextended/ox_lib

    This file is licensed under LGPL-3.0 or higher <https://www.gnu.org/licenses/lgpl-3.0.en.html>

    Copyright © 2025 Linden <https://github.com/thelindat>
]]

---@class DuiProperties
---@field url string
---@field width number
---@field height number
---@field debug? boolean

---@class Dui
---@field private_id string
---@field private_debug boolean
---@field url string
---@field duiObject number
---@field duiHandle string
---@field runtimeTxd number
---@field txdObject number
---@field dictName string
---@field txtName string
xLib.dui = xLib.class()

local resource<const> = GetCurrentResourceName()

---@type table<string, Dui>
local Duis = {}

local currentId = 0

---@param data DuiProperties
function xLib.dui:constructor(data)
	local time = GetGameTimer()
	local id = ("%s_%s_%s"):format(resource, time, currentId)
	currentId = currentId + 1
	local dictName = ("%s_dui_dict_%s"):format(resource, id)
	local txtName = ("%s_lib_dui_txt_%s"):format(resource, id)
	local duiObject = CreateDui(data.url, data.width, data.height)
	local duiHandle = GetDuiHandle(duiObject)
	local runtimeTxd = CreateRuntimeTxd(dictName)
	local txdObject = CreateRuntimeTextureFromDuiHandle(runtimeTxd, txtName, duiHandle)
	self.private_id = id
	self.private_debug = data.debug or false
	self.url = data.url
	self.duiObject = duiObject
	self.duiHandle = duiHandle
	self.runtimeTxd = runtimeTxd
	self.txdObject = txdObject
	self.dictName = dictName
	self.txtName = txtName
	Duis[id] = self

	if self.private_debug then
		print(("Dui %s created"):format(id))
	end
end

function xLib.dui:remove()
	SetDuiUrl(self.duiObject, "about:blank")
	DestroyDui(self.duiObject)
	Duis[self.private_id] = nil

	if self.private_debug then
		print(("Dui %s removed"):format(self.private_id))
	end
end

---@param url string
function xLib.dui:setUrl(url)
	self.url = url
	SetDuiUrl(self.duiObject, url)

	if self.private_debug then
		print(("Dui %s url set to %s"):format(self.private_id, url))
	end
end

---@param message table
function xLib.dui:sendMessage(message)
	SendDuiMessage(self.duiObject, json.encode(message))

	if self.private_debug then
		print(("Dui %s message sent with data :"):format(self.private_id), json.encode(message, { indent = true }))
	end
end

---@param x number
---@param y number
function xLib.dui:sendMouseMove(x, y)
	SendDuiMouseMove(self.duiObject, x, y)
end

---@param button "left" | "middle" | "right"
function xLib.dui:sendMouseDown(button)
	SendDuiMouseDown(self.duiObject, button)
end

---@param button "left" | "middle" | "right"
function xLib.dui:sendMouseUp(button)
	SendDuiMouseUp(self.duiObject, button)
end

---@param deltaX number
---@param deltaY number
function xLib.dui:sendMouseWheel(deltaX, deltaY)
	SendDuiMouseWheel(self.duiObject, deltaY, deltaX)
end

AddEventHandler("onResourceStop", function(resourceName)
	if resource ~= resourceName then return end

	for id in next, Duis do
        Duis[id]:remove()
    end
end)

return xLib.dui