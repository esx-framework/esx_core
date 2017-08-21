ESX                = nil
PlayersHarvesting  = {}
PlayersHarvesting2 = {}
PlayersHarvesting3 = {}
PlayersCrafting    = {}
PlayersCrafting2   = {}
PlayersCrafting3   = {}

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

if Config.MaxInService ~= -1 then
	TriggerEvent('esx_service:activateService', 'mecano', Config.MaxInService)
end

TriggerEvent('esx_phone:registerCallback', function(source, phoneNumber, message, anon)
	local _source = source
	local xPlayer  = ESX.GetPlayerFromId(_source)
	local xPlayers = ESX.GetPlayers()
	
	if phoneNumber == 'mecano' then
		for i=1, #xPlayers, 1 do
			
			local xPlayer2 = ESX.GetPlayerFromId(xPlayers[i])

			if xPlayer2.job.name == 'mecano' then
				TriggerClientEvent('esx_phone:onMessage', xPlayer2.source, xPlayer.get('phoneNumber'), message, xPlayer.get('coords'), anon, 'Appel Mécano')
			end
		end
	end
end)
-------------- Récupération bouteille de gaz -------------
---- Sqlut je teste ------
local function Harvest(source)

	SetTimeout(4000, function()

		if PlayersHarvesting[source] == true then

			local xPlayer  = ESX.GetPlayerFromId(source)
			local GazBottleQuantity = xPlayer.getInventoryItem('gazbottle').count

			if GazBottleQuantity >= 5 then
				TriggerClientEvent('esx:showNotification', source, '~r~Vous n\'avez plus de place')		
			else   
                xPlayer.addInventoryItem('gazbottle', 1)
					
				Harvest(source)
			end
		end
	end)
end

RegisterServerEvent('esx_mecanojob:startHarvest')
AddEventHandler('esx_mecanojob:startHarvest', function()
	local _source = source
	PlayersHarvesting[_source] = true
	TriggerClientEvent('esx:showNotification', _source, 'Récupération de ~b~bouteille de gaz~s~...')
	Harvest(source)
end)

RegisterServerEvent('esx_mecanojob:stopHarvest')
AddEventHandler('esx_mecanojob:stopHarvest', function()
	local _source = source
	PlayersHarvesting[_source] = false
end)
------------ Récupération Outils Réparation --------------
local function Harvest2(source)

	SetTimeout(4000, function()

		if PlayersHarvesting2[source] == true then

			local xPlayer  = ESX.GetPlayerFromId(source)
			local FixToolQuantity  = xPlayer.getInventoryItem('fixtool').count
			if FixToolQuantity >= 5 then
				TriggerClientEvent('esx:showNotification', source, 'Vous n\'avez ~r~plus de place')				
			else
                xPlayer.addInventoryItem('fixtool', 1)
					
				Harvest2(source)
			end
		end
	end)
end

RegisterServerEvent('esx_mecanojob:startHarvest2')
AddEventHandler('esx_mecanojob:startHarvest2', function()
	local _source = source
	PlayersHarvesting2[_source] = true
	TriggerClientEvent('esx:showNotification', _source, 'Récupération d\'~b~Outils réparation~s~...')
	Harvest2(_source)
end)

RegisterServerEvent('esx_mecanojob:stopHarvest2')
AddEventHandler('esx_mecanojob:stopHarvest2', function()
	local _source = source
	PlayersHarvesting2[_source] = false
end)
----------------- Récupération Outils Carosserie ----------------
local function Harvest3(source)

	SetTimeout(4000, function()

		if PlayersHarvesting3[source] == true then

			local xPlayer  = ESX.GetPlayerFromId(source)
			local CaroToolQuantity  = xPlayer.getInventoryItem('carotool').count
            if CaroToolQuantity >= 5 then
				TriggerClientEvent('esx:showNotification', source, 'Vous n\'avez ~r~plus de place')					
			else
                xPlayer.addInventoryItem('carotool', 1)
					
				Harvest3(source)
			end
		end
	end)
end

RegisterServerEvent('esx_mecanojob:startHarvest3')
AddEventHandler('esx_mecanojob:startHarvest3', function()
	local _source = source
	PlayersHarvesting3[_source] = true
	TriggerClientEvent('esx:showNotification', _source, 'Récupération d\'~b~Outils carosserie~s~...')
	Harvest3(_source)
end)

RegisterServerEvent('esx_mecanojob:stopHarvest3')
AddEventHandler('esx_mecanojob:stopHarvest3', function()
	local _source = source
	PlayersHarvesting3[_source] = false
end)
------------ Craft Chalumeau -------------------
local function Craft(source)

	SetTimeout(4000, function()

		if PlayersCrafting[source] == true then

			local xPlayer  = ESX.GetPlayerFromId(source)
			local GazBottleQuantity = xPlayer.getInventoryItem('gazbottle').count

			if GazBottleQuantity <= 0 then
				TriggerClientEvent('esx:showNotification', source, 'Vous n\'avez ~r~pas assez~s~ de bouteille de gaz')		
			else   
                xPlayer.removeInventoryItem('gazbottle', 1)
                xPlayer.addInventoryItem('blowpipe', 1)
					
				Craft(source)
			end
		end
	end)
end

RegisterServerEvent('esx_mecanojob:startCraft')
AddEventHandler('esx_mecanojob:startCraft', function()
	local _source = source
	PlayersCrafting[_source] = true
	TriggerClientEvent('esx:showNotification', _source, 'Assemblage de ~b~Chalumeaux~s~...')
	Craft(_source)
end)

RegisterServerEvent('esx_mecanojob:stopCraft')
AddEventHandler('esx_mecanojob:stopCraft', function()
	local _source = source
	PlayersCrafting[_source] = false
end)
------------ Craft kit Réparation --------------
local function Craft2(source)

	SetTimeout(4000, function()

		if PlayersCrafting2[source] == true then

			local xPlayer  = ESX.GetPlayerFromId(source)
			local FixToolQuantity  = xPlayer.getInventoryItem('fixtool').count
			if FixToolQuantity <= 0 then
				TriggerClientEvent('esx:showNotification', source, 'Vous n\'avez ~r~pas assez~s~ d\'outils réparation')				
			else
                xPlayer.removeInventoryItem('fixtool', 1)
                xPlayer.addInventoryItem('fixkit', 1)
					
				Craft2(source)
			end
		end
	end)
end

RegisterServerEvent('esx_mecanojob:startCraft2')
AddEventHandler('esx_mecanojob:startCraft2', function()
	local _source = source
	PlayersCrafting2[_source] = true
	TriggerClientEvent('esx:showNotification', _source, 'Assemblage de ~b~Kit réparation~s~...')
	Craft2(_source)
end)

RegisterServerEvent('esx_mecanojob:stopCraft2')
AddEventHandler('esx_mecanojob:stopCraft2', function()
	local _source = source
	PlayersCrafting2[_source] = false
end)
----------------- Craft kit Carosserie ----------------
local function Craft3(source)

	SetTimeout(4000, function()

		if PlayersCrafting3[source] == true then

			local xPlayer  = ESX.GetPlayerFromId(source)
			local CaroToolQuantity  = xPlayer.getInventoryItem('carotool').count
            if CaroToolQuantity <= 0 then
				TriggerClientEvent('esx:showNotification', source, 'Vous n\'avez ~r~pas assez~s~ d\'outils carosserie')					
			else
                xPlayer.removeInventoryItem('carotool', 1)
                xPlayer.addInventoryItem('carokit', 1)
					
				Craft3(source)
			end
		end
	end)
end

RegisterServerEvent('esx_mecanojob:startCraft3')
AddEventHandler('esx_mecanojob:startCraft3', function()
	local _source = source
	PlayersCrafting3[_source] = true
	TriggerClientEvent('esx:showNotification', _source, 'Assemblage de ~b~kit carosserie~s~...')
	Craft3(_source)
end)

RegisterServerEvent('esx_mecanojob:stopCraft3')
AddEventHandler('esx_mecanojob:stopCraft3', function()
	local _source = source
	PlayersCrafting3[_source] = false
end)

---------------------------- register usable item --------------------------------------------------
ESX.RegisterUsableItem('blowpipe', function(source)

	local _source = source
	local xPlayer  = ESX.GetPlayerFromId(source)

	xPlayer.removeInventoryItem('blowpipe', 1)

	TriggerClientEvent('esx_mecanojob:onHijack', _source)
    TriggerClientEvent('esx:showNotification', _source, 'Vous avez utilisé un ~b~Chalumeau')

end)

ESX.RegisterUsableItem('fixkit', function(source)

	local _source = source
	local xPlayer  = ESX.GetPlayerFromId(source)

	xPlayer.removeInventoryItem('fixkit', 1)

	TriggerClientEvent('esx_mecanojob:onFixkit', _source)
    TriggerClientEvent('esx:showNotification', _source, 'Vous avez utilisé un ~b~Kit de réparation')

end)

ESX.RegisterUsableItem('carokit', function(source)

	local _source = source
	local xPlayer  = ESX.GetPlayerFromId(source)

	xPlayer.removeInventoryItem('carokit', 1)

	TriggerClientEvent('esx_mecanojob:onCarokit', _source)
    TriggerClientEvent('esx:showNotification', _source, 'Vous avez utilisé un ~b~Kit de carosserie')

end)