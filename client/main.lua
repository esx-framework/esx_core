local Keys = {
	["ESC"] = 322, ["F1"] = 288, ["F2"] = 289, ["F3"] = 170, ["F5"] = 166, ["F6"] = 167, ["F7"] = 168, ["F8"] = 169, ["F9"] = 56, ["F10"] = 57,
	["~"] = 243, ["1"] = 157, ["2"] = 158, ["3"] = 160, ["4"] = 164, ["5"] = 165, ["6"] = 159, ["7"] = 161, ["8"] = 162, ["9"] = 163, ["-"] = 84, ["="] = 83, ["BACKSPACE"] = 177,
	["TAB"] = 37, ["Q"] = 44, ["W"] = 32, ["E"] = 38, ["R"] = 45, ["T"] = 245, ["Y"] = 246, ["U"] = 303, ["P"] = 199, ["["] = 39, ["]"] = 40, ["ENTER"] = 18,
	["CAPS"] = 137, ["A"] = 34, ["S"] = 8, ["D"] = 9, ["F"] = 23, ["G"] = 47, ["H"] = 74, ["K"] = 311, ["L"] = 182,
	["LEFTSHIFT"] = 21, ["Z"] = 20, ["X"] = 73, ["C"] = 26, ["V"] = 0, ["B"] = 29, ["N"] = 249, ["M"] = 244, [","] = 82, ["."] = 81,
	["LEFTCTRL"] = 36, ["LEFTALT"] = 19, ["SPACE"] = 22, ["RIGHTCTRL"] = 70,
	["HOME"] = 213, ["PAGEUP"] = 10, ["PAGEDOWN"] = 11, ["DELETE"] = 178,
	["LEFT"] = 174, ["RIGHT"] = 175, ["TOP"] = 27, ["DOWN"] = 173,
	["NENTER"] = 201, ["N4"] = 108, ["N5"] = 60, ["N6"] = 107, ["N+"] = 96, ["N-"] = 97, ["N7"] = 117, ["N8"] = 61, ["N9"] = 118
}

local GUI                      = {}
local PhoneData                = { phoneNumber = 0, contacts = {} }
local CurrentAction            = nil
local CurrentActionMsg         = ''
local CurrentActionData        = {}
local CurrentDispatchRequestId = -1
local PhoneNumberSources       = {}

ESX                            = nil
GUI.PhoneIsShowed              = false
GUI.MessagesIsShowed           = false
GUI.AddContactIsShowed         = false

Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end
	
	ESX.UI.Menu.RegisterType('phone', OpenPhone, ClosePhone)
end)

function OpenPhone()
	local playerPed = PlayerPedId()

	TriggerServerEvent('esx_phone:reload', PhoneData.phoneNumber)

	SendNUIMessage({
		showPhone = true,
		phoneData = PhoneData
	})

	GUI.PhoneIsShowed = true

	ESX.SetTimeout(250, function()
		SetNuiFocus(true, true)
	end)

	if not IsPedInAnyVehicle(playerPed, false) then
		TaskStartScenarioInPlace(playerPed, 'WORLD_HUMAN_STAND_MOBILE', 0, true)
	end
end

function ClosePhone()
	local playerPed = PlayerPedId()

	SendNUIMessage({
		showPhone = false
	})

	SetNuiFocus(false)
	GUI.PhoneIsShowed = false
	ClearPedTasks(playerPed)
end

RegisterNetEvent('esx_phone:loaded')
AddEventHandler('esx_phone:loaded', function(phoneNumber, contacts)
	PhoneData.phoneNumber = phoneNumber
	PhoneData.contacts = {}

	for i=1, #contacts, 1 do
		contacts[i].online = (PhoneNumberSources[contacts[i].number] == nil and false or NetworkIsPlayerActive(GetPlayerFromServerId(PhoneNumberSources[contacts[i].number]))),
		table.insert(PhoneData.contacts, contacts[i])
	end

	SendNUIMessage({
		reloadPhone = true,
		phoneData   = PhoneData
	})
end)

RegisterNetEvent('esx_phone:addContact')
AddEventHandler('esx_phone:addContact', function(name, phoneNumber, playerOnline)
	table.insert(PhoneData.contacts, {
		name   = name,
		number = phoneNumber,
		online = playerOnline
	})

	SendNUIMessage({
		contactAdded = true,
		phoneData    = PhoneData
	})
end)

RegisterNetEvent('esx_phone:removeContact')
AddEventHandler('esx_phone:removeContact', function(name, phoneNumber)
	for key, value in pairs(PhoneData.contacts) do
		if value.name == name and value.number == phoneNumber then
			table.remove(PhoneData.contacts, key)
			break
		end
	end

	SendNUIMessage({
		contactRemoved = true,
		phoneData      = PhoneData
	})
end)

RegisterNetEvent('esx_phone:addSpecialContact')
AddEventHandler('esx_phone:addSpecialContact', function(name, phoneNumber, base64Icon)
	SendNUIMessage({
		addSpecialContact = true,
		name              = name,
		number            = phoneNumber,
		base64Icon        = base64Icon
	})
end)

RegisterNetEvent('esx_phone:removeSpecialContact')
AddEventHandler('esx_phone:removeSpecialContact', function(phoneNumber)
	SendNUIMessage({
		removeSpecialContact = true,
		number               = phoneNumber
	})
end)

RegisterNUICallback('add_contact', function(data, cb)
	local phoneNumber = tonumber(data.phoneNumber)
	local contactName = tostring(data.contactName)

	if phoneNumber then
		TriggerServerEvent('esx_phone:addPlayerContact', phoneNumber, contactName)
	else
		ESX.ShowNotification(_U('invalid_number'))
	end
end)

RegisterNUICallback('remove_contact', function(data, cb)
	local phoneNumber = tonumber(data.phoneNumber)
	local contactName = tostring(data.contactName)

	if phoneNumber then
		TriggerServerEvent('esx_phone:removePlayerContact', phoneNumber, contactName)
	end
end)

RegisterNetEvent('esx_phone:onMessage')
AddEventHandler('esx_phone:onMessage', function(phoneNumber, message, position, anon, job, dispatchRequestId, dispatchNumber)
	if dispatchNumber and phoneNumber == PhoneData.phoneNumber then
		TriggerEvent('esx_phone:cancelMessage', dispatchNumber)

		if WasEventCanceled() then
			return
		end
	end

	if job == 'player' then
		ESX.ShowNotification(_U('new_message', message))
	else
		ESX.ShowNotification(('~b~%s:~s~ %s'):format(job, message))
	end

	PlaySound(-1, 'Menu_Accept', 'Phone_SoundSet_Default', false, 0, true)

	SendNUIMessage({
		newMessage  = true,
		phoneNumber = phoneNumber,
		message     = message,
		position    = position,
		anonyme     = anon,
		job         = job
	})

	if dispatchRequestId then
		CurrentAction            = 'dispatch'
		CurrentActionMsg         = _U('press_take_call', job)
		CurrentDispatchRequestId = dispatchRequestId

		CurrentActionData = {
			phoneNumber = phoneNumber,
			message     = message,
			position    = position,
			actions     = actions,
			anonyme     = anon,
			job         = job
		}
		
		ESX.SetTimeout(15000, function()
			CurrentAction = nil
		end)
	end
end)

RegisterNetEvent('esx_phone:stopDispatch')
AddEventHandler('esx_phone:stopDispatch', function(dispatchRequestId, playerName)
	if CurrentDispatchRequestId == dispatchRequestId and CurrentAction == 'dispatch' then
		CurrentAction = nil
		ESX.ShowNotification(_U('taken_call', playerName))
	end
end)

RegisterNetEvent('esx_phone:setPhoneNumberSource')
AddEventHandler('esx_phone:setPhoneNumberSource', function(phoneNumber, source)
	if source == -1 then
		PhoneNumberSources[phoneNumber] = nil
	else
		PhoneNumberSources[phoneNumber] = source
	end
end)

RegisterNUICallback('setGPS', function(data)
	SetNewWaypoint(data.x,  data.y)
	ESX.ShowNotification(_U('gps_position'))
end)

RegisterNUICallback('send', function(data)
	local phoneNumber = data.number
	local playerPed   = PlayerPedId()
	local coords      = GetEntityCoords(playerPed)

	if tonumber(phoneNumber) ~= nil then
		phoneNumber = tonumber(phoneNumber)
	end

	TriggerServerEvent('esx_phone:send', phoneNumber, data.message, data.anonyme, {
		x = coords.x,
		y = coords.y,
		z = coords.z
	})
	
	SendNUIMessage({
		showMessageEditor = false
	})

	ESX.ShowNotification(_U('message_sent'))
end)

RegisterNUICallback('escape', function()
	ESX.UI.Menu.Close('phone', GetCurrentResourceName(), 'main')
end)

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)

		if GUI.PhoneIsShowed then -- codes here: https://pastebin.com/guYd0ht4
			DisableControlAction(0, 1,    true) -- LookLeftRight
			DisableControlAction(0, 2,    true) -- LookUpDown
			DisableControlAction(0, 25,   true) -- Input Aim
			DisableControlAction(0, 106,  true) -- Vehicle Mouse Control Override

			DisableControlAction(0, 24,   true) -- Input Attack
			DisableControlAction(0, 140,  true) -- Melee Attack Alternate
			DisableControlAction(0, 141,  true) -- Melee Attack Alternate
			DisableControlAction(0, 142,  true) -- Melee Attack Alternate
			DisableControlAction(0, 257,  true) -- Input Attack 2
			DisableControlAction(0, 263,  true) -- Input Melee Attack
			DisableControlAction(0, 264,  true) -- Input Melee Attack 2

			DisableControlAction(0, 12,   true) -- Weapon Wheel Up Down
			DisableControlAction(0, 14,   true) -- Weapon Wheel Next
			DisableControlAction(0, 15,   true) -- Weapon Wheel Prev
			DisableControlAction(0, 16,   true) -- Select Next Weapon
			DisableControlAction(0, 17,   true) -- Select Prev Weapon
		else
			-- open phone
			-- todo: is player busy (handcuffed, etc)
			if IsControlJustReleased(0, Keys['F1']) and GetLastInputMethod(2) then
				if not ESX.UI.Menu.IsOpen('phone', GetCurrentResourceName(), 'main') then
					ESX.UI.Menu.CloseAll()
					ESX.UI.Menu.Open('phone', GetCurrentResourceName(), 'main')
				end
			end
		end
	end
end)

AddEventHandler('onResourceStop', function(resource)
	if resource == GetCurrentResourceName() then
		if GUI.PhoneIsShowed then
			ESX.UI.Menu.CloseAll()
		end
	end
end)

-- Key controls
Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)

		if CurrentAction ~= nil then
			ESX.ShowHelpNotification(CurrentActionMsg)

			if IsControlJustReleased(0, Keys['E']) and GetLastInputMethod(2) then
				if CurrentAction == 'dispatch' then
					TriggerServerEvent('esx_phone:stopDispatch', CurrentDispatchRequestId)
					SetNewWaypoint(CurrentActionData.position.x, CurrentActionData.position.y)
				end

				CurrentAction = nil
			end
		else
			Citizen.Wait(500)
		end
	end
end)
