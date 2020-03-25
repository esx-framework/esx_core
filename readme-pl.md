# Podziękowania dla KASH oraz XxFri3ndlyxX.
### Jeśli aktualizujesz ESX, pamiętaj o aktualizacji pozostałych skryptów!

## Wymagane zmiany:

* es_extended: (`es_extended/client/main.lua`)

### Zamień podany kod:

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

### na:

```lua
RegisterNetEvent('esx:kashloaded')
AddEventHandler('esx:kashloaded', function()
	TriggerServerEvent('esx:onPlayerJoined')
end)
```

* es_extended: (`es_extended/server/main.lua`)

### Zamień podany kod:

```lua
	for k,v in ipairs(GetPlayerIdentifiers(playerId)) do
		if string.match(v, 'license:') then
			identifier = string.sub(v, 9)
			break
		end
	end
```

### na:


```lua
	for k,v in ipairs(GetPlayerIdentifiers(playerId)) do
		if string.match(v, 'license:') then
			identifier = v
			break
		end
	end
```

# Przeczytaj uważnie...
> **Musisz** zwiększyć limit znaków w tabeli `users`dla kolumny `identifier` do **48**.

> **Nie** używaj essentialsmode, mapmanager oraz spawnmanager.

> **Uwaga!** Musisz nazwać skrypt 'esx_kashacters', aby wszystko działało poprawnie.

## Jak to działa?
> Ten skrypt manipuluje ładowaniem postaci przez ESX.
Kiedy więc wybierasz swoją postać, skrypt zmienia twoją **licencje rockstar**, która jest normalnie zapisywana jako **license:** na **Char:**, co zapobiega ładowaniu przez ESX innej postaci, ponieważ szuka on dokładnej licencji.
