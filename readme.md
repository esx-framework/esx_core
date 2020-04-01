# Thanks to KASH and XxFri3ndlyxX
### If you are updating ESX, be sure to update the remaining scripts!

Instrukcja w języku Polskim znajduje się [tutaj](https://github.com/fivem-ex/esx_kashacter/blob/master/readme-pl.md).

## Required changes:

* es_extended: (`es_extended/client/main.lua`)

### Comment out this code:
```lua
-- check if player is coming from loading screen
	if GetEntityModel(PlayerPedId()) == GetHashKey('PLAYER_ZERO') then
		local defaultModel = GetHashKey('a_m_y_stbla_02')
		RequestModel(defaultModel)

		while not HasModelLoaded(defaultModel) do
			Citizen.Wait(100)
		end

		SetPlayerModel(PlayerId(), defaultModel)
		local playerPed = PlayerPedId()

		SetPedDefaultComponentVariation(playerPed)
		SetPedRandomComponentVariation(playerPed, true)
		SetModelAsNoLongerNeeded(defaultModel)
		FreezeEntityPosition(playerPed, false)
	end
```

### Replace this code:

```lua
Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)

		if NetworkIsPlayerActive(PlayerId()) then
			TriggerServerEvent('esx:onPlayerJoined')
			break
		end
	end
end)
```

### with:

```lua
RegisterNetEvent('esx:kashloaded')
AddEventHandler('esx:kashloaded', function()
	if isFirstSpawn then
		TriggerServerEvent('esx:onPlayerJoined')
	end
end)
```

* es_extended: (`es_extended/server/main.lua`)

### Change this code in `onPlayerJoined(playerId)` function:

```lua
	for k,v in ipairs(GetPlayerIdentifiers(playerId)) do
		if string.match(v, 'license:') then
			identifier = string.sub(v, 9)
			break
		end
	end
```

### to:


```lua
	for k,v in ipairs(GetPlayerIdentifiers(playerId)) do
		if string.match(v, 'license:') then
			identifier = v
			break
		end
	end
```

# Read carefully...
> You **MUST** incerase the character limit in the `users` table for row `identifier` to **48**.

> Do **not** use essentialsmode, mapmanager and spawnmanager!

> *Pay ATTENTION: You have to call the resource **esx_kashacter** in order for the javascript to work!**

## How it works
> What this script does it manipulates ESX for loading characters
So when you are choosing your character it changes your **Rockstar license** which is normally **license:** to **Char:** this prevents ESX from loading another character because it is looking for you exact license. So when you choose your character it will change it from Char: to your normal Rockstar license (license:). When creating a new character it will spawn you without an exact license which creates a new database entry for your license.
