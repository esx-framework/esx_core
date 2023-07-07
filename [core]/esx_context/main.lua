local activeMenu
local Debug = ESX.GetConfig().EnableDebug

-- Global functions
-- [ Post | Open | Closed ]

function Post(fn, ...)
	SendNUIMessage({
		func = fn,
		args = { ... }
	})
end

function Open(position, eles, onSelect, onClose, canClose)
	local canClose = canClose == nil and true or canClose
	activeMenu = {
		position = position,
		eles = eles,
		canClose = canClose,
		onSelect = onSelect,
		onClose = onClose
	}

	LocalPlayer.state:set("context:active", true)

	Post("Open", eles, position)
end

function Closed()
	SetNuiFocus(false, false)

	local menu = activeMenu
	local cb = menu.onClose

	activeMenu = nil

	LocalPlayer.state:set("context:active", false)

	if cb then
		cb(menu)
	end
end

-- Exports
-- [ Preview | Open | Close ]

exports("Preview", Open)

exports("Open", function(...)
	Open(...)
	SetNuiFocus(true, true)
end)

exports("Close", function()
	if not activeMenu then
		return
	end

	Post("Closed")

	Closed()
end)

exports("Refresh", function(eles, position)
	if not activeMenu then
		return
	end

	activeMenu.eles = eles or activeMenu.eles
	activeMenu.position = position or activeMenu.position

	Post("Open", activeMenu.eles, activeMenu.position)
end)

-- NUI Callbacks
-- [ closed | selected | changed ]

RegisterNUICallback("closed", function(_, cb)
	if not activeMenu or (activeMenu and not activeMenu.canClose) then
		return cb(false)
	end
	cb(true)
	Closed()
end)

RegisterNUICallback("selected", function(data, cb)
	if not activeMenu or not activeMenu.onSelect or not data.index then
		return
	end

	local index = tonumber(data.index)
	local ele = activeMenu.eles[index]

	if not ele or ele.input then
		return
	end

	activeMenu:onSelect(ele)
	if cb then cb('ok') end
end)

RegisterNUICallback("changed", function(data, cb)
	if not activeMenu or not data.index or not data.value then
		return
	end

	local index = tonumber(data.index)
	local ele = activeMenu.eles[index]

	if not ele or not ele.input then
		return
	end

	if ele.inputType == "number" then
		ele.inputValue = tonumber(data.value)

		if ele.inputMin then
			ele.inputValue = math.max(ele.inputMin, ele.inputValue)
		end

		if ele.inputMax then
			ele.inputValue = math.min(ele.inputMax, ele.inputValue)
		end
	elseif ele.inputType == "text" then
		ele.inputValue = data.value
	elseif ele.inputType == "radio" then
		ele.inputValue = data.value
	end
	if cb then cb('ok') end
end)

-- Keybind

local function focusPreview()
	if not activeMenu or not activeMenu.onSelect then
		return
	end

	SetNuiFocus(true, true)
end

if PREVIEW_KEYBIND then
	RegisterCommand("previewContext", focusPreview)

	RegisterKeyMapping("previewContext", "Preview Active Context", "keyboard", PREVIEW_KEYBIND)
end

exports("focusPreview", focusPreview)

-- Debug/Test
-- Commands:
-- [ ctx:preview | ctx:open | ctx:close | ctx:form ]

if Debug then
	local position = "right"

	local eles = {
		{
			unselectable = true,
			icon = "fas fa-info-circle",
			title = "Unselectable Item (Header/Label?)",
		},
		{
			icon = "fas fa-check",
			title = "Item A",
			description = "Some description here. Add some words to make the text overflow."
		},
		{
			disabled = true,
			icon = "fas fa-times",
			title = "Disabled Item",
			description = "Some description here. Add some words to make the text overflow."
		},
		{
			icon = "fas fa-check",
			title = "Item B",
			description = "Some description here. Add some words to make the text overflow."
		},
	}

	local function onSelect(menu, ele)
		print("Ele selected", ele.title)

		if ele.name == "close" then
			exports["esx_context"]:Close()
		end

		if ele.name ~= "submit" then
			return
		end

		for _, element in ipairs(menu.eles) do
			if element.input then
				print(element.name, element.inputType, element.inputValue)
			end
		end

		exports["esx_context"]:Close()
	end

	local function onClose()
		print("Menu closed.")
	end

	RegisterCommand("ctx:preview", function()
		exports["esx_context"]:Preview(position, eles)
	end)

	RegisterCommand("ctx:open", function()
		exports["esx_context"]:Open(position, eles, onSelect, onClose)
	end)

	RegisterCommand("ctx:close", function()
		exports["esx_context"]:Close()
	end)

	RegisterCommand("ctx:form", function()
		local formMenu = {
			{
				unselectable = true,
				icon = "fas fa-info-circle",
				title = "Unselectable Item (Header/Label?)",
			},
			{
				icon = "",
				title = "Input Text",
				input = true,
				inputType = "text",
				inputPlaceholder = "Placeholder...",
				name = "firstname",
			},
			{
				icon = "",
				title = "Input Text",
				input = true,
				inputType = "text",
				inputPlaceholder = "Placeholder...",
				name = "lastname",
			},
			{
				icon = "",
				title = "Input Number",
				input = true,
				inputType = "number",
				inputPlaceholder = "Placeholder...",
				inputValue = 0,
				inputMin = 0,
				inputMax = 50,
				name = "age",
			},
			{
				icon = "fas fa-check",
				title = "Submit",
				name = "submit"
			}
		}

		exports["esx_context"]:Open(position, formMenu, onSelect, onClose)
	end)
end
