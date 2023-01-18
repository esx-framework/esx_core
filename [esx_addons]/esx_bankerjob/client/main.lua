local CurrentActionData, CurrentAction, CurrentActionMsg, hasAlreadyEnteredMarker, lastZone = {}

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function (xPlayer)
	ESX.PlayerData = xPlayer
end)

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function (job)
	ESX.PlayerData.job = job
end)

function OpenBankActionsMenu()
	local elements = {
		{unselectable = true, icon = "fas fa-bank", title = TranslateCap("bank")},
		{icon = "fas fa-users", title = TranslateCap("customers"), value = "customers"},
		{icon = "fas fa-scroll", title = TranslateCap("billing"),   value = "billing"}
	}

	if ESX.PlayerData.job.grade_name == 'boss' then
		elements[#elements+1] = {
			icon = "fas fa-wallet",
			title = TranslateCap("boss_actions"),
			value = "boss_actions"
		}
	end

	ESX.CloseContext()

	ESX.OpenContext("right", elements, function(menu,element)
		if element.value == "customers" then
			OpenCustomersMenu()
		elseif element.value == "billing" then
			CreateBillingDialog()
		elseif element.value == "boss_actions" then
			TriggerEvent('esx_society:openBossMenu', 'banker', function(data, menu)
				menu.close()
			end, {wash = false})
			CurrentAction     = 'bank_actions_menu'
			CurrentActionMsg  = TranslateCap('press_input_context_to_open_menu')
			CurrentActionData = {}
		end
	end, function(menu)
		CurrentAction     = 'bank_actions_menu'
		CurrentActionMsg  = TranslateCap('press_input_context_to_open_menu')
		CurrentActionData = {}
	end)
end

function OpenCustomersMenu()
	ESX.TriggerServerCallback('esx_bankerjob:getCustomers', function(customers)
		local elements = {
			{unselectable = true, icon = "fas fa-users", title = TranslateCap('customer')}
		}

		for i=1, #customers do
			elements[#elements+1] = {
				icon = "fas fa-user",
				title = customers[i].name,
				bankSavings = customers[i].bankSavings,
				data = customers[i]
			}
		end

		ESX.OpenContext("right", elements, function(menu,element)
			local elements2 = {
				{unselectable = true, icon = "fas fa-user", title = element.title},
				{unselectable = true, icon = "fas fa-wallet", title = "$"..ESX.Math.GroupDigits(element.bankSavings)},
				{icon = "fas fa-wallet", title = TranslateCap('deposit'), value = "deposit"},
				{icon = "fas fa-wallet", title = TranslateCap('withdraw'), value = "withdraw"},
			}
			ESX.OpenContext("right", elements2, function(menu2,element2)
				local customer = element.data
				if element2.value == "deposit" then
					local elements = {
						{unselectable = true, icon = "fas fa-scroll", title = TranslateCap('amount')},
						{title = "Amount", input = true, inputType = "number", inputMin = 1, inputMax = 250000, inputPlaceholder = "Amount to bill.."},
						{icon = "fas fa-check-double", title = "Confirm", val = "confirm"}
					}

					ESX.OpenContext("right", elements, function(menu,element)
						if element.val == "confirm" then
							local amount = tonumber(menu.eles[2].inputValue)

							if amount == nil then
								ESX.ShowNotification(TranslateCap('invalid_amount'))
							else
								ESX.CloseContext()
								TriggerServerEvent('esx_bankerjob:customerDeposit', customer.source, amount)
								ESX.ShowNotification("You have deposited $"..amount.." into "..element.title.."s account.")
								OpenCustomersMenu()
							end
						end
					end, function(menu)
						CurrentAction     = 'bank_actions_menu'
						CurrentActionMsg  = TranslateCap('press_input_context_to_open_menu')
						CurrentActionData = {}
					end)
				elseif element2.value == "withdraw" then
					local elements = {
						{unselectable = true, icon = "fas fa-scroll", title = TranslateCap('amount')},
						{title = "Amount", input = true, inputType = "number", inputMin = 1, inputMax = 250000, inputPlaceholder = "Amount to bill.."},
						{icon = "fas fa-check-double", title = "Confirm", val = "confirm"}
					}

					ESX.OpenContext("right", elements, function(menu,element)
						if element.val == "confirm" then
							local amount = tonumber(menu.eles[2].inputValue)

							if amount == nil then
								ESX.ShowNotification(TranslateCap('invalid_amount'))
							else
								ESX.CloseContext()
								TriggerServerEvent('esx_bankerjob:customerWithdraw', customer.source, amount)
								ESX.ShowNotification("You have withdrawn $"..amount.." from "..element.title.."s account.")
								OpenCustomersMenu()
							end
						end
					end, function(menu)
						CurrentAction     = 'bank_actions_menu'
						CurrentActionMsg  = TranslateCap('press_input_context_to_open_menu')
						CurrentActionData = {}
					end)
				end
			end, function(menu)	
				CurrentAction     = 'bank_actions_menu'
				CurrentActionMsg  = TranslateCap('press_input_context_to_open_menu')
				CurrentActionData = {}
			end)
		end, function(menu)
			CurrentAction     = 'bank_actions_menu'
			CurrentActionMsg  = TranslateCap('press_input_context_to_open_menu')
			CurrentActionData = {}
		end)
	end)
end

function CreateBillingDialog()
	local elements = {
		{unselectable = true, icon = "fas fa-scroll", title = TranslateCap('bill_amount')},
		{title = "Amount", input = true, inputType = "number", inputMin = 1, inputMax = 250000, inputPlaceholder = "Amount to bill.."},
		{icon = "fas fa-check-double", title = "Confirm", val = "confirm"}
	}

	ESX.OpenContext("right", elements, function(menu,element)
		if element.val == "confirm" then
			local amount = tonumber(menu.eles[2].inputValue)

			if amount == nil then
				ESX.ShowNotification(TranslateCap('invalid_amount'))
			else
				ESX.CloseContext()

				local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()

				if closestPlayer == -1 or closestDistance > 5.0 then
					ESX.ShowNotification(TranslateCap('no_player_nearby'))
				else
					TriggerServerEvent('esx_billing:sendBill', GetPlayerServerId(closestPlayer), 'society_banker', 'Bank', amount)
				end
			end
		end
	end, function(menu)
		CurrentAction     = 'bank_actions_menu'
		CurrentActionMsg  = TranslateCap('press_input_context_to_open_menu')
		CurrentActionData = {}
	end)
end

AddEventHandler('esx_bankerjob:hasEnteredMarker', function (zone)
	if zone == 'BankActions' and ESX.PlayerData.job and ESX.PlayerData.job.name == 'banker' then
		CurrentAction     = 'bank_actions_menu'
		CurrentActionMsg  = TranslateCap('press_input_context_to_open_menu')
		CurrentActionData = {}
	end
end)

AddEventHandler('esx_bankerjob:hasExitedMarker', function (zone)
	CurrentAction = nil
	ESX.CloseContext()
end)

-- Create Blips
CreateThread(function()
	local blip = AddBlipForCoord(Config.Zones.BankActions.Coords)

	SetBlipSprite(blip, 108)
	SetBlipColour(blip, 30)
	SetBlipAsShortRange(blip, true)

	BeginTextCommandSetBlipName('STRING')
	AddTextComponentSubstringPlayerName(TranslateCap('bank'))
	EndTextCommandSetBlipName(blip)
end)

-- Draw marker & activate menu when player is inside marker
CreateThread(function()
	while true do
		Wait(0)

		if ESX.PlayerData.job and ESX.PlayerData.job.name == 'banker' then
			local playerCoords = GetEntityCoords(PlayerPedId())
			local isInMarker, letSleep, currentZone = false, true

			for k,v in pairs(Config.Zones) do
				local distance = #(playerCoords - v.Coords)

				if v.Type ~= -1 and distance < Config.DrawDistance then
					letSleep = false
					DrawMarker(v.Type, v.Coords, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, v.Size.x, v.Size.y, v.Size.z, v.Color.r, v.Color.g, v.Color.b, 100, false, true, 2, false, nil, nil, false)
				end

				if distance < v.Size.x then
					isInMarker, currentZone, letSleep = true, k, false
				end
			end

			if isInMarker and not hasAlreadyEnteredMarker then
				hasAlreadyEnteredMarker, lastZone = true, currentZone
				TriggerEvent('esx_bankerjob:hasEnteredMarker', currentZone)
			end

			if not isInMarker and hasAlreadyEnteredMarker then
				hasAlreadyEnteredMarker = false
				TriggerEvent('esx_bankerjob:hasExitedMarker', lastZone)
			end

			if letSleep then
				Wait(500)
			end
		else
			Wait(500)
		end
	end
end)

-- Key Controls
CreateThread(function()
	while true do
		Wait(0)

		if CurrentAction then
			ESX.ShowHelpNotification(CurrentActionMsg)

			if IsControlJustReleased(0, 38) and ESX.PlayerData.job and ESX.PlayerData.job.name == 'banker' then
				if CurrentAction == 'bank_actions_menu' then
					OpenBankActionsMenu()
				end

				CurrentAction = nil
			end
		else
			Wait(500)
		end
	end
end)
