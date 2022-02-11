local hasAlreadyEnteredMarker, CurrentActionData = false, {}
local CurrentAction, CurrentActionMsg, LastZone

function OpenRealestateAgentMenu()
	local elements = {
		{label = _U('properties'), value = 'properties'},
		{label = _U('clients'),    value = 'customers'},
	}

	if ESX.PlayerData.job ~= nil and ESX.PlayerData.job.name == 'realestateagent' and ESX.PlayerData.job.grade_name == 'boss' then
		table.insert(elements, {
			label = _U('boss_action'),
			value = 'boss_actions'
		})
	end

	ESX.UI.Menu.CloseAll()

	ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'realestateagent', {
		title    = _U('realtor'),
		align    = 'top-left',
		elements = elements
	}, function(data, menu)
		if data.current.value == 'properties' then
			OpenPropertyMenu()
		elseif data.current.value == 'customers' then
			OpenCustomersMenu()
		elseif data.current.value == 'boss_actions' then
			TriggerEvent('esx_society:openBossMenu', 'realestateagent', function(data, menu)
				menu.close()
			end)
		end
	end, function(data, menu)
		menu.close()

		CurrentAction     = 'realestateagent_menu'
		CurrentActionMsg  = _U('press_to_access')
		CurrentActionData = {}
	end)
end

function OpenPropertyMenu()
	TriggerEvent('esx_property:getProperties', function(properties)

		local elements = {
			head = {_U('property_name'), _U('property_actions')},
			rows = {}
		}

		for i=1, #properties, 1 do
			table.insert(elements.rows, {
				data = properties[i],
				cols = {
					properties[i].label,
					_U('property_actionbuttons')
				}
			})
		end

		ESX.UI.Menu.Open('list', GetCurrentResourceName(), 'properties', elements, function(data, menu)
			if data.value == 'sell' then
				menu.close()

				ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'sell_property_amount', {
					title = _U('amount')
				}, function(data2, menu2)
					local amount = tonumber(data2.value)

					if amount == nil then
						ESX.ShowNotification(_U('invalid_amount'))
					else
						local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()
						if closestPlayer == -1 or closestDistance > 3.0 then
							ESX.ShowNotification(_U('no_play_near'))
							menu2.close()
						else
							TriggerServerEvent('esx_realestateagentjob:sell', GetPlayerServerId(closestPlayer), data.data.name, amount)
							menu2.close()
						end

						OpenPropertyMenu()
					end
				end, function(data2, menu2)
					menu2.close()
				end)
			elseif data.value == 'rent' then
				menu.close()

				ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'rent_property_amount', {
					title = _U('amount')
				}, function(data2, menu2)
					local amount = tonumber(data2.value)

					if amount == nil then
						ESX.ShowNotification(_U('invalid_amount'))
					else
						local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()
						if closestPlayer == -1 or closestDistance > 3.0 then
							ESX.ShowNotification(_U('no_play_near'))
							menu2.close()
						else
							TriggerServerEvent('esx_realestateagentjob:rent', GetPlayerServerId(closestPlayer), data.data.name, amount)
							menu2.close()
						end

						OpenPropertyMenu()
					end
				end, function(data2, menu2)
					menu2.close()
				end)
			elseif data.value == 'gps' then
				TriggerEvent('esx_property:getProperty', data.data.name, function(property)
					if property.isSingle then
						SetNewWaypoint(property.entering.x, property.entering.y)
					else
						TriggerEvent('esx_property:getGateway', property, function(gateway)
							SetNewWaypoint(gateway.entering.x, gateway.entering.y)
						end)
					end
				end)
			end
		end, function(data, menu)
			menu.close()
		end)
	end)
end

function OpenCustomersMenu()
	ESX.TriggerServerCallback('esx_realestateagentjob:getCustomers', function(customers)
		local elements = {
			head = {_U('customer_client'), _U('customer_property'), _U('customer_agreement'), _U('customer_actions')},
			rows = {}
		}

		for i=1, #customers, 1 do
			table.insert(elements.rows, {
				data = customers[i],
				cols = {
					customers[i].name,
					customers[i].propertyLabel,
					(customers[i].propertyRented and _U('customer_rent') or _U('customer_sell')),
					_U('customer_contractbuttons')
				}
			})
		end

		ESX.UI.Menu.Open('list', GetCurrentResourceName(), 'customers', elements, function(data, menu)
			if data.value == 'revoke' then
				TriggerServerEvent('esx_realestateagentjob:revoke', data.data.propertyName, data.data.propertyOwner)
				OpenCustomersMenu()
			elseif data.value == 'gps' then
				TriggerEvent('esx_property:getProperty', data.data.propertyName, function(property)
					if property.isSingle then
						SetNewWaypoint(property.entering.x, property.entering.y)
					else
						TriggerEvent('esx_property:getGateway', property, function(gateway)
							SetNewWaypoint(gateway.entering.x, gateway.entering.y)
						end)
					end
				end)
			end
		end, function(data, menu)
			menu.close()
		end)
	end)
end

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
	ESX.PlayerData = xPlayer
	ESX.PlayerLoaded = true

	if ESX.PlayerData.job.name == 'realestateagent' then
		Config.Zones.OfficeActions.Type = 1
	else
		Config.Zones.OfficeActions.Type = -1
	end
end)

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
	ESX.PlayerData.job = job

	if ESX.PlayerData.job.name == 'realestateagent' then
		Config.Zones.OfficeActions.Type = 1
	else
		Config.Zones.OfficeActions.Type = -1
	end
end)

AddEventHandler('esx_realestateagentjob:hasEnteredMarker', function(zone)
	if zone == 'OfficeEnter' then
		local playerPed = PlayerPedId()
		SetEntityCoords(playerPed, Config.Zones.OfficeInside.Pos.x, Config.Zones.OfficeInside.Pos.y, Config.Zones.OfficeInside.Pos.z)
	elseif zone == 'OfficeExit' then
		local playerPed = PlayerPedId()
		SetEntityCoords(playerPed, Config.Zones.OfficeOutside.Pos.x, Config.Zones.OfficeOutside.Pos.y, Config.Zones.OfficeOutside.Pos.z)
	elseif zone == 'OfficeActions' and ESX.PlayerData.job ~= nil and ESX.PlayerData.job.name == 'realestateagent' then
		CurrentAction     = 'realestateagent_menu'
		CurrentActionMsg  = _U('press_to_access')
		CurrentActionData = {}
	end
end)

AddEventHandler('esx_realestateagentjob:hasExitedMarker', function(zone)
	ESX.UI.Menu.CloseAll()
	CurrentAction = nil
end)

-- Create Blips
CreateThread(function()
	local blip = AddBlipForCoord(Config.Zones.OfficeEnter.Pos.x, Config.Zones.OfficeEnter.Pos.y, Config.Zones.OfficeEnter.Pos.z)

	SetBlipSprite (blip, 357)
	SetBlipDisplay(blip, 4)
	SetBlipScale  (blip, 1.0)
	SetBlipColour (blip, 59)
	SetBlipAsShortRange(blip, true)

	BeginTextCommandSetBlipName('STRING')
	AddTextComponentSubstringPlayerName(_U('realtors'))
	EndTextCommandSetBlipName(blip)
end)

-- Display markers
CreateThread(function()
	while true do
		Wait(0)

		local coords = GetEntityCoords(PlayerPedId())

		for k,v in pairs(Config.Zones) do
			if(v.Type ~= -1 and #(coords - v.Pos) < Config.DrawDistance) then
				DrawMarker(v.Type, v.Pos.x, v.Pos.y, v.Pos.z, 0.0, 0.0, 0.0, 0, 0.0, 0.0, v.Size.x, v.Size.y, v.Size.z, Config.MarkerColor.r, Config.MarkerColor.g, Config.MarkerColor.b, 100, false, true, 2, false, false, false, false)
			end
		end
	end
end)

-- Enter / Exit marker events
CreateThread(function()
	while true do
		Wait(0)

		local coords      = GetEntityCoords(PlayerPedId())
		local isInMarker  = false
		local currentZone = nil

		for k,v in pairs(Config.Zones) do
			if #(coords - v.Pos) < v.Size.x then
				isInMarker  = true
				currentZone = k
			end
		end

		if (isInMarker and not hasAlreadyEnteredMarker) or (isInMarker and LastZone ~= currentZone) then
			hasAlreadyEnteredMarker = true
			LastZone                = currentZone
			TriggerEvent('esx_realestateagentjob:hasEnteredMarker', currentZone)
		end

		if not isInMarker and hasAlreadyEnteredMarker then
			hasAlreadyEnteredMarker = false
			TriggerEvent('esx_realestateagentjob:hasExitedMarker', LastZone)
		end
	end
end)

-- Key controls
CreateThread(function()
	while true do
		Wait(0)

		if CurrentAction then
			ESX.ShowHelpNotification(CurrentActionMsg)

			if IsControlJustReleased(0, 38) then
				if CurrentAction == 'realestateagent_menu' then
					OpenRealestateAgentMenu()
				end

				CurrentAction = nil
			end
		else
			Wait(500)
		end
	end
end)

-- Load IPLS
CreateThread(function()
	RequestIpl('ex_dt1_02_office_02c')
end)

RegisterNetEvent('esx_phone:loaded')
AddEventHandler('esx_phone:loaded', function(phoneNumber, contacts)
	local specialContact = {
		name       = _U('realtor'),
		number     = 'realestateagent',
		base64Icon = 'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAGQAAABkCAMAAABHPGVmAAAAAXNSR0IArs4c6QAAAARnQU1BAACxjwv8YQUAAAMAUExURQAAAAkuhgkvhwowhgowhwwxhwowiAwxiAwyiA0yiQ4zig80iQ40ihA0iRA0ihA1ixE2ixI3jBM4ixM4jBQ4jBQ4jRY6jRY6jhg7jhg7jxg8jRk8jhk8jxo+jxo+kBw/kB1AkB1AkR9Bkh9CkR9CkiBDkSBCkiFEkyNElCNGlCVGlCZIlSdIlihJlipKlilKlytMlyxLlyxNlytMmCxMmC5OmS9PmjBPmTBPmjFQmTBQmjNSmzNSnDRTnDVUmzVUnDdVnjZWnTdWnjhXnjpYnjxZnj1bnztaoD1aoD5coT9dokBdoUBdokFeokNgo0NgpERgo0RhpEVipEZipUdkpUdkpkhkpEhkpkpmpUpmpkpmp0xnpk5qp0xoqE5pqU5qqVBrqFBrqVFrqlJsqVJsqlJuqlNuq1RuqlRurFZwrFdyrVhxrllyrVhyrlt0r1x1r112r1x1sF12sF94sWF5sGB4sWF5smJ6smR8s2V9tGZ+tGd/tWl/tWh/tmmAtWmAtmuCtmqCt2yDt2yDuG6EuG+GuXGGuXGGunGIunSJunSJu3WKvHeMvXiNvHmOvnuQvnyQvn6SwICTwYCUwICUwYKWwoSWw4SYw4WYxIeaxIiaxIqcxoydx4yex46fyI+gyJGiyZGiypOkypSky5amzJeozZinzZmozZmpzpqqzpysz5+u0KCu0KGw0aKw0qWz06a01Ki11Ki21aq31qu41qy41q2616+72LC82LG+2bK+2rS/27XA2rbB3LfC3LjD3LrE3brF3rvG3rzG3r7I37/I4MHK4MPM4cTN4sXO4sbP5MfQ48fQ5MjQ5MnS5cvT5szT5s3U5s7W587W6NDX6NHY6NPa6dPa6tTa6tXc6tfd7Nnf7drg7dvg7tzh7t3i7t/k7+Dl8OLm8OPo8ePo8uTo8eTo8ubq8ufr9Ons9Oru9ezu9ezv9u3w9u/y9+/x+PDy+PL0+PP1+vP2+fT1+fX2+vb4+/f4/Pj5+/j5/Pn6/Pv8/fz8/fz8/v7+/gAAACSdcMIAAAEAdFJOU////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////wBT9wclAAAACXBIWXMAAC4iAAAuIgGq4t2SAAAAGHRFWHRTb2Z0d2FyZQBwYWludC5uZXQgNC4xLjb9TgnoAAAKNUlEQVRoQ92af1hV5R3Ax/HuXI5eb9fimguQUEN3CbFEW1i51l2PVCJg6qTYapGhm1iaYm6r3O7UciQWmOkonWyOpWJkTh3TJobilIbKlETvvNvAS9zG3YTlxcvp/fE9v3/cK3uePXv2+eue97zn++Gc9/2+P87hS/x/gf89SfmKp+fm5eTMLFiwEkqiI1rJy9nJnJWRsFiHps1dBScjEY1k6fgRHMRWYrHH3/cKVDIjsuThL0NIA+IWQUVjIkieSJQ/IwOGpC6F6gaYSuY6IEwkYhJfhEt0MZE8HwchoiHG9QZcpoOhpOw2C1wfJdztcKUWI8mT16nA3FgKF6vRl6y/NQYuvC4sd8P1KnQlK/TTIgqSIIISPUkuXDEQLMshiBwdyZ0DaA6J2MchjAytZDzUNiFhlEkCxTwDgSQ0krFQ1xjn8hMtjXs3PPd110g7FCkYNBtCiaglke7DEpdzqLcfEe7r9Z+t31m28H7XyGEcy8J5zKAHIZiASnIn1DPCUVDTjRUi4VBve9Nvq17/UWFWRqJoegrCAUpJboQ2H7X70zBEVxLqCfq9LfWV30sh9WKVaamQrCA1jGAnec5BTCP+UjWJuRknmQMiUuSS9aY5mLyuLQSxDAhszbTZv7snGdceBTEJcsmtJJgc1soKD5B9dNuRCx2f9Yb1n1d/f7Aux2bP3hv8K+mfMfIuJpM8qR6vrPeXbVxdnHdvCsfYbmZZK3dTxqPLXnunpv6MrwciiwQPzI+zZVf5+/vbaRLEroGwCElSpm70wWsvhfo+vxLwtVZzWcfqN88fi3sPaxuWMG6Se+GW43KRryiBZSo68F2ChImFuAhJchs9J5BUfFR8MEe5uaTjdjbVvOl5Lv8baSgiw9jS81dV7jjQ2Oo7vTWddf2khdQVJYz0wETJ84obiVv8R9kfKkgwod6gv625/teeORNShrPovka4Jo/jRvz03FWoIErsEFkmkc+1jhl1ioculwhcC3V7T+7fsnJm+hiOmd4gdTxRwtwFoUXJXDhBKG70K3rrUW5mAH6qQa4WN3cMjjCSxAKxRYliWP1K2j3ZK9/95BpchiS5SOKt2OeDAgVX8wc3wU+MJGHugOAgeQKKEeOLZkwZdxNuIefUop9trTnUdH4fkZy0MWxyVkn5eRxKli6hAiPJEBpckCRCMWJJsLu99fjezSXu1CQHa7XHJaSmW0BC2ItDfVToqTpy0f9P9DNUwBlImMdodJDI1oklfaRuuC/U2dpQW7HY7Up2MBrJ7hvYWG74xNwDWMIcJ5dQ5JJbaHQqeRgKMSABwn1X/acqyeNqIckoSshva2XYTMI8S8JTiXxNrZQQTg3GktC5hsp5o69PQluFSJZCEYFIhMyiUAnF/zEan/r76742Eo/ZkSSMJFHMuVjiX1BcXtviC5CJVikBerzNh6tX507aHkFC1vtEMgJKCFjS4bKwnG3M1FnL3vrgjK+zkbSJlnAoeMW04RnGLUoUkxWR3A4HDMvdkOLOZfUlFFPJaEHyMhRQsOSyetGCJf9o0Z8ZTSUxgiQbCihYEr5Yt+21FwqzMlNguMGSk7bY9O+srtzRDtEETCVMGUjIpCyCJZjw1Z6A7+yx2vXFU5Nlycja9uGzH2+qPe0LkE5oLpkOEuX6QZAIhPs+PySMXQSaJ8M4++h7819qiiTBWyMsUe491RIE7cJ/gkcnT0bubW0X/io5I5BIJeVwCBhK/rVnjRvfjCLjf66RdKSSMwJ4BYYkqiUdlnStKa+qPXLa20X7k5SMvecPbv8E/9ibQCpbN/ZpJGL3J1ip5Gk4BLCkI9XCOZzJGe58D15t/UGbjIET75cXT3UlV17r7ys0k+CBBUkUMy9IpGS0cs60ybrJiHrE5XOoP4ejkeTBEYAlgaJ0suoRye6CEDpEJcmBI4A0/KfelsObilLEZdIjZOjVZ8ASSrjzxK4NnkX5mZaHkKRh7LQlr1e9X69eHUUlmQlHgExCQKu5ExyWNA5GZ1F/qMOllxq8/iCtGZWkAI4AtQTRZsMSRca/5xyenlW0trotSskCOAKik9BkZG3vhKOTrIQjAEtCyh5LJe3FLlJBkfFo+jWXcFTCK/cMWNLuGvNQScX2D46cuRRA60gqQQSadr+1phn/UkoOkbMUlcQJEu0AScYfmvTTvu351Q7S8ABdvP6tevWcjBSnjUoOkjKKSoKnRiwZCscUIkmXpSJaxTEyiQCa4L0n61pJw5tIJoAkDY4pWHJlc0mBO80pPUcdiYi5BL8EwRLl4IUlaF/e3dF2an9FASxkBi5B8YlklaLliUQk3N6ws2IxiyXN8zyb30W7N1iMiZhKyBISS3jFexilhNBKetdHHNmVuupxUfDvXYLMVJImSuKhhKAjuaBNxj2pU+Ys2bDnNBrITCU5ouQ+KCFgSc/BhnMd0irrgl0jIXnCcsO2RejCHlHyCpQQsKQ9I9GVmfVCdTN9JN44LDkLN6yT8cYSHJ5KFFtfLBEr2jMLX317x28cWNL/b+/hqnU/mE92oYIEzfFmkgQSnkoWQRmGSOSpw9ocUhcOh3pIm7WUPOBKclisG0wlZJEqSPghUIogbVJVMj012cmJ729EiUhfyN/aULNhv/Zxyf5AF40OEtlaCUvwjrHrzO+rN3oWzshMQU9GK6HgPbBK4s+AQOhG4GsESJZKb4iIBOjrDXZdaj1ZKR8gNaglkyCQ9OIDJLI9tlwCeJ1Y0v3SwtKtNQc7oFDEWJIFwQXJi+KtGEoCWag32eO2kqJDi9ftOnGpE7+CMZTYILYo4emshzCVIDaRop12luMSJs9CqwpDybcgtCR5Q9hARCfZRdNfJxlFifRxQJTwQveOTiIk46ZrhpLvQ2C5hL+Rnsv7sNkbUIp0JAdc5M51Mt4/kVQjGxNAJimlicc5kya681du+bDtcje4FJI3SVHwz0d+sfyBsfGb1JL2V+leKQ6iYmQS/m5ylkJW89MKV/2y/kLHZ61ySSlEQ1nU42u6qGj4sL/6Htq2lh9CUIxcwieR83JQFxqeMXMeSUaNBJAkl3fmwXTAfBNCEhQS1QpMRsbvgpElzdOdpAZiOASkKCXLY6GSFtvEPDoq/DhIIkpQydXGUrrDw8RDPEAp4R+P/FUu6ZGF699r9olTPJGEW0tGSUu1GPyGQIZKwj8zCCqaYEEtlTxl1rKK2lO+zmAoVMjs3Agv3AhD10IwAbWEnx2FBWA5W4p7nmfjVCZevvcbqvmmqZHwD0LdaLFwit0lE6O+Dz0J/5Rx60dBvKo9MDoSvtTkA18klH0X0JPw/KgBffpFj06RgyL6En72gB5ZnHwskWEg4dcMwCIbd5UYSdDN6H4ONSZJmj/UGEt4/i7DoUyLTZxrdTCT8PwdskWfCTF2YV2ij7mE5x+7BQIZE+OK8B8lESU8/2yEu6FralMiSxBL3aN1E2dIWg7Zf0QiKgmmLCc10SHu+Dnn6Anaj/tGRC35T/h/kfD8FwUEvcFd1jgBAAAAAElFTkSuQmCC'
	}

	TriggerEvent('esx_phone:addSpecialContact', specialContact.name, specialContact.number, specialContact.base64Icon)
end)

if ESX.PlayerLoaded and ESX.PlayerData.job.name == 'realestateagent' then
	Config.Zones.OfficeActions.Type = 1
else
	Config.Zones.OfficeActions.Type = -1
end