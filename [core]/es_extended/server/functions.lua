function ESX.Trace(msg)
	if Config.EnableDebug then
		print(('[^2TRACE^7] %s^7'):format(msg))
	end
end

function ESX.RegisterCommand(name, group, cb, allowConsole, suggestion)
	if type(name) == 'table' then
		for _, v in ipairs(name) do
			ESX.RegisterCommand(v, group, cb, allowConsole, suggestion)
		end

		return
	end

	if Core.RegisteredCommands[name] then
		print(('[^3WARNING^7] Command ^5"%s" ^7already registered, overriding command'):format(name))

		if Core.RegisteredCommands[name].suggestion then
			TriggerClientEvent('chat:removeSuggestion', -1, ('/%s'):format(name))
		end
	end

	if suggestion then
		if not suggestion.arguments then
			suggestion.arguments = {}
		end
		if not suggestion.help then
			suggestion.help = ''
		end

		TriggerClientEvent('chat:addSuggestion', -1, ('/%s'):format(name), suggestion.help, suggestion.arguments)
	end

	Core.RegisteredCommands[name] = { group = group, cb = cb, allowConsole = allowConsole, suggestion = suggestion }

	RegisterCommand(name, function(playerId, args)
		local command = Core.RegisteredCommands[name]

		if not command.allowConsole and playerId == 0 then
			print(('[^3WARNING^7] ^5%s'):format(TranslateCap('commanderror_console')))
		else
			local xPlayer, error = ESX.Players[playerId], nil

			if command.suggestion then
				if command.suggestion.validate then
					if #args ~= #command.suggestion.arguments then
						error = TranslateCap('commanderror_argumentmismatch', #args, #command.suggestion.arguments)
					end
				end

				if not error and command.suggestion.arguments then
					local newArgs = {}

					for k, v in ipairs(command.suggestion.arguments) do
						if v.type then
							if v.type == 'number' then
								local newArg = tonumber(args[k])

								if newArg then
									newArgs[v.name] = newArg
								else
									error = TranslateCap('commanderror_argumentmismatch_number', k)
								end
							elseif v.type == 'player' or v.type == 'playerId' then
								local targetPlayer = tonumber(args[k])

								if args[k] == 'me' then
									targetPlayer = playerId
								end

								if targetPlayer then
									local xTargetPlayer = ESX.GetPlayerFromId(targetPlayer)

									if xTargetPlayer then
										if v.type == 'player' then
											newArgs[v.name] = xTargetPlayer
										else
											newArgs[v.name] = targetPlayer
										end
									else
										error = TranslateCap('commanderror_invalidplayerid')
									end
								else
									error = TranslateCap('commanderror_argumentmismatch_number', k)
								end
							elseif v.type == 'string' then
								local newArg = tonumber(args[k])
								if not newArg then
									newArgs[v.name] = args[k]
								else
									error = TranslateCap('commanderror_argumentmismatch_string', k)
								end
							elseif v.type == 'item' then
								if ESX.Items[args[k]] then
									newArgs[v.name] = args[k]
								else
									error = TranslateCap('commanderror_invaliditem')
								end
							elseif v.type == 'weapon' then
								if ESX.GetWeapon(args[k]) then
									newArgs[v.name] = string.upper(args[k])
								else
									error = TranslateCap('commanderror_invalidweapon')
								end
							elseif v.type == 'any' then
								newArgs[v.name] = args[k]
							elseif v.type == 'merge' then
								local lenght = 0
								for i = 1, k - 1 do
									lenght = lenght + string.len(args[i]) + 1
								end
								local merge = table.concat(args, " ")

								newArgs[v.name] = string.sub(merge, lenght)
                            elseif v.type == 'coordinate' then
                                local coord = tonumber(args[k]:match("(-?%d+%.?%d*)"))
                                if(not coord) then
                                    error = TranslateCap('commanderror_argumentmismatch_number', k)
                                else
                                    newArgs[v.name] = coord
                                end
						    end
						end

						--backwards compatibility
						if v.validate ~= nil and not v.validate then
							error = nil
						end

						if error then
							break
						end
					end

					args = newArgs
				end
			end

			if error then
				if playerId == 0 then
					print(('[^3WARNING^7] %s^7'):format(error))
				else
					xPlayer.showNotification(error)
				end
			else
				cb(xPlayer or false, args, function(msg)
					if playerId == 0 then
						print(('[^3WARNING^7] %s^7'):format(msg))
					else
						xPlayer.showNotification(msg)
					end
				end)
			end
		end
	end, true)

	if type(group) == 'table' then
		for _, v in ipairs(group) do
			ExecuteCommand(('add_ace group.%s command.%s allow'):format(v, name))
		end
	else
		ExecuteCommand(('add_ace group.%s command.%s allow'):format(group, name))
	end
end

function Core.SavePlayer(xPlayer, cb)
	local parameters <const> = {
		json.encode(xPlayer.getAccounts(true)),
		xPlayer.job.name,
		xPlayer.job.grade,
		xPlayer.group,
		json.encode(xPlayer.getCoords()),
		json.encode(xPlayer.getInventory(true)),
		json.encode(xPlayer.getLoadout(true)),
		json.encode(xPlayer.getMeta()),
		xPlayer.identifier
	}

	MySQL.prepare(
		'UPDATE `users` SET `accounts` = ?, `job` = ?, `job_grade` = ?, `group` = ?, `position` = ?, `inventory` = ?, `loadout` = ?, `metadata` = ? WHERE `identifier` = ?',
		parameters,
		function(affectedRows)
			if affectedRows == 1 then
				print(('[^2INFO^7] Saved player ^5"%s^7"'):format(xPlayer.name))
				TriggerEvent('esx:playerSaved', xPlayer.playerId, xPlayer)
			end
			if cb then
				cb()
			end
		end
	)
end

function Core.SavePlayers(cb)
	local xPlayers <const> = ESX.Players
	if not next(xPlayers) then
		return
	end

	local startTime <const> = os.time()
	local parameters = {}

	for _, xPlayer in pairs(ESX.Players) do
		parameters[#parameters + 1] = {
			json.encode(xPlayer.getAccounts(true)),
			xPlayer.job.name,
			xPlayer.job.grade,
			xPlayer.group,
			json.encode(xPlayer.getCoords()),
			json.encode(xPlayer.getInventory(true)),
			json.encode(xPlayer.getLoadout(true)),
			json.encode(xPlayer.getMeta()),
			xPlayer.identifier
		}
	end

	MySQL.prepare(
		"UPDATE `users` SET `accounts` = ?, `job` = ?, `job_grade` = ?, `group` = ?, `position` = ?, `inventory` = ?, `loadout` = ?, `metadata` = ? WHERE `identifier` = ?",
		parameters,
		function(results)
			if not results then
				return
			end

			if type(cb) == 'function' then
				return cb()
			end

			print(('[^2INFO^7] Saved ^5%s^7 %s over ^5%s^7 ms'):format(#parameters, #parameters > 1 and 'players' or 'player', ESX.Math.Round((os.time() - startTime) / 1000000, 2)))
		end
	)
end

ESX.GetPlayers = GetPlayers

local function checkTable(key, val, player, xPlayers)
	for valIndex = 1, #val do
		local value = val[valIndex]
		if not xPlayers[value] then
			xPlayers[value] = {}
		end

		if (key == 'job' and player.job.name == value) or player[key] == value then
			xPlayers[value][#xPlayers[value] + 1] = player
		end
	end
end

function ESX.GetExtendedPlayers(key, val)
	if not key then return ESX.Players end

	local xPlayers = {}
	if type(val) == "table" then
		for _, v in pairs(ESX.Players) do
			checkTable(key, val, v, xPlayers)
		end
	else
		for _, v in pairs(ESX.Players) do
			if (key == 'job' and v.job.name == val) or v[key] == val then
				xPlayers[#xPlayers + 1] = v
			end
		end
	end

	return xPlayers
end

function ESX.GetPlayerFromId(source)
	return ESX.Players[tonumber(source)]
end

function ESX.GetPlayerFromIdentifier(identifier)
	return Core.playersByIdentifier[identifier]
end

function ESX.GetIdentifier(playerId)
	local fxDk = GetConvarInt('sv_fxdkMode', 0)
	if fxDk == 1 then
		return "ESX-DEBUG-LICENCE"
	end
	for _, v in ipairs(GetPlayerIdentifiers(playerId)) do
		if string.match(v, 'license:') then
			local identifier = string.gsub(v, 'license:', '')
			return identifier
		end
	end
end

local classFromName = {
    ["adder"] = 7,
    ["airbus"] = 17,
    ["airtug"] = 11,
    ["akuma"] = 8,
    ["alpha"] = 6,
    ["ambulance"] = 18,
    ["annihilator"] = 15,
    ["armytanker"] = 11,
    ["armytrailer"] = 11,
    ["armytrailer2"] = 11,
    ["asea"] = 1,
    ["asea2"] = 1,
    ["asterope"] = 1,
    ["bagger"] = 8,
    ["baletrailer"] = 11,
    ["baller"] = 2,
    ["baller2"] = 2,
    ["baller3"] = 2,
    ["baller4"] = 2,
    ["baller5"] = 2,
    ["baller6"] = 2,
    ["banshee"] = 6,
    ["banshee2"] = 7,
    ["barracks"] = 19,
    ["barracks2"] = 19,
    ["barracks3"] = 19,
    ["bati"] = 8,
    ["bati2"] = 8,
    ["benson"] = 20,
    ["besra"] = 16,
    ["bestiagts"] = 6,
    ["bfinjection"] = 9,
    ["biff"] = 20,
    ["bifta"] = 9,
    ["bison"] = 12,
    ["bison2"] = 12,
    ["bison3"] = 12,
    ["bjxl"] = 2,
    ["blade"] = 4,
    ["blazer"] = 9,
    ["blazer2"] = 9,
    ["blazer3"] = 9,
    ["blimp"] = 16,
    ["blimp2"] = 16,
    ["blista"] = 0,
    ["blista2"] = 6,
    ["blista3"] = 6,
    ["bmx"] = 13,
    ["boattrailer"] = 11,
    ["bobcatxl"] = 12,
    ["bodhi2"] = 9,
    ["boxville"] = 12,
    ["boxville2"] = 12,
    ["boxville3"] = 12,
    ["boxville4"] = 12,
    ["brawler"] = 9,
    ["brickade"] = 17,
    ["btype"] = 5,
    ["btype2"] = 5,
    ["btype3"] = 5,
    ["buccaneer"] = 4,
    ["buccaneer2"] = 4,
    ["buffalo"] = 6,
    ["buffalo2"] = 6,
    ["buffalo3"] = 6,
    ["bulldozer"] = 10,
    ["bullet"] = 7,
    ["burrito"] = 12,
    ["burrito2"] = 12,
    ["burrito3"] = 12,
    ["burrito4"] = 12,
    ["burrito5"] = 12,
    ["bus"] = 17,
    ["buzzard"] = 15,
    ["buzzard2"] = 15,
    ["cablecar"] = 21,
    ["caddy"] = 11,
    ["caddy2"] = 11,
    ["camper"] = 12,
    ["carbonizzare"] = 6,
    ["carbonrs"] = 8,
    ["cargobob"] = 15,
    ["cargobob2"] = 15,
    ["cargobob3"] = 15,
    ["cargobob4"] = 15,
    ["cargoplane"] = 16,
    ["casco"] = 5,
    ["cavalcade"] = 2,
    ["cavalcade2"] = 2,
    ["cheetah"] = 7,
    ["chino"] = 4,
    ["chino2"] = 4,
    ["coach"] = 17,
    ["cog55"] = 1,
    ["cog552"] = 1,
    ["cogcabrio"] = 3,
    ["cognoscenti"] = 1,
    ["cognoscenti2"] = 1,
    ["comet2"] = 6,
    ["coquette"] = 6,
    ["coquette2"] = 5,
    ["coquette3"] = 4,
    ["cruiser"] = 13,
    ["crusader"] = 19,
    ["cuban800"] = 16,
    ["cutter"] = 10,
    ["daemon"] = 8,
    ["dilettante"] = 0,
    ["dilettante2"] = 0,
    ["dinghy"] = 14,
    ["dinghy2"] = 14,
    ["dinghy3"] = 14,
    ["dinghy4"] = 14,
    ["dloader"] = 9,
    ["docktrailer"] = 11,
    ["docktug"] = 11,
    ["dodo"] = 16,
    ["dominator"] = 4,
    ["dominator2"] = 4,
    ["double"] = 8,
    ["dubsta"] = 2,
    ["dubsta2"] = 2,
    ["dubsta3"] = 9,
    ["dukes"] = 4,
    ["dukes2"] = 4,
    ["dump"] = 10,
    ["dune"] = 9,
    ["dune2"] = 9,
    ["duster"] = 16,
    ["elegy2"] = 6,
    ["emperor"] = 1,
    ["emperor2"] = 1,
    ["emperor3"] = 1,
    ["enduro"] = 8,
    ["entityxf"] = 7,
    ["exemplar"] = 3,
    ["f620"] = 3,
    ["faction"] = 4,
    ["faction2"] = 4,
    ["faction3"] = 4,
    ["faggio2"] = 8,
    ["fbi"] = 18,
    ["fbi2"] = 18,
    ["felon"] = 3,
    ["felon2"] = 3,
    ["feltzer2"] = 6,
    ["feltzer3"] = 5,
    ["firetruk"] = 18,
    ["fixter"] = 13,
    ["flatbed"] = 10,
    ["fmj"] = 7,
    ["forklift"] = 11,
    ["fq2"] = 2,
    ["freight"] = 21,
    ["freightcar"] = 21,
    ["freightcont1"] = 21,
    ["freightcont2"] = 21,
    ["freightgrain"] = 21,
    ["freighttrailer"] = 11,
    ["frogger"] = 15,
    ["frogger2"] = 15,
    ["fugitive"] = 1,
    ["furoregt"] = 6,
    ["fusilade"] = 6,
    ["futo"] = 6,
    ["gauntlet"] = 4,
    ["gauntlet2"] = 4,
    ["gburrito"] = 12,
    ["gburrito2"] = 12,
    ["glendale"] = 1,
    ["graintrailer"] = 11,
    ["granger"] = 2,
    ["gresley"] = 2,
    ["guardian"] = 10,
    ["habanero"] = 2,
    ["hakuchou"] = 8,
    ["handler"] = 10,
    ["hauler"] = 20,
    ["hexer"] = 8,
    ["hotknife"] = 4,
    ["huntley"] = 2,
    ["hydra"] = 16,
    ["infernus"] = 7,
    ["ingot"] = 1,
    ["innovation"] = 8,
    ["insurgent"] = 9,
    ["insurgent2"] = 9,
    ["intruder"] = 1,
    ["issi2"] = 0,
    ["jackal"] = 3,
    ["jb700"] = 5,
    ["jester"] = 6,
    ["jester2"] = 6,
    ["jet"] = 16,
    ["jetmax"] = 14,
    ["journey"] = 12,
    ["kalahari"] = 9,
    ["khamelion"] = 6,
    ["kuruma"] = 6,
    ["kuruma2"] = 6,
    ["landstalker"] = 2,
    ["lazer"] = 16,
    ["lectro"] = 8,
    ["lguard"] = 18,
    ["limo2"] = 1,
    ["lurcher"] = 4,
    ["luxor"] = 16,
    ["luxor2"] = 16,
    ["mamba"] = 5,
    ["mammatus"] = 16,
    ["manana"] = 5,
    ["marquis"] = 14,
    ["marshall"] = 9,
    ["massacro"] = 6,
    ["massacro2"] = 6,
    ["maverick"] = 15,
    ["mesa"] = 2,
    ["mesa2"] = 2,
    ["mesa3"] = 9,
    ["metrotrain"] = 21,
    ["miljet"] = 16,
    ["minivan"] = 12,
    ["minivan2"] = 12,
    ["mixer"] = 10,
    ["mixer2"] = 10,
    ["monroe"] = 5,
    ["monster"] = 9,
    ["moonbeam"] = 4,
    ["moonbeam2"] = 4,
    ["mower"] = 11,
    ["mule"] = 20,
    ["mule2"] = 20,
    ["mule3"] = 20,
    ["nemesis"] = 8,
    ["nightshade"] = 4,
    ["nimbus"] = 16,
    ["ninef"] = 6,
    ["ninef2"] = 6,
    ["oracle"] = 3,
    ["oracle2"] = 3,
    ["osiris"] = 7,
    ["packer"] = 20,
    ["panto"] = 0,
    ["paradise"] = 12,
    ["patriot"] = 2,
    ["pbus"] = 18,
    ["pcj"] = 8,
    ["penumbra"] = 6,
    ["peyote"] = 5,
    ["pfister811"] = 7,
    ["phantom"] = 20,
    ["phoenix"] = 4,
    ["picador"] = 4,
    ["pigalle"] = 5,
    ["police"] = 18,
    ["police2"] = 18,
    ["police3"] = 18,
    ["police4"] = 18,
    ["policeb"] = 18,
    ["policeold1"] = 18,
    ["policeold2"] = 18,
    ["policet"] = 18,
    ["polmav"] = 15,
    ["pony"] = 12,
    ["pony2"] = 12,
    ["pounder"] = 20,
    ["prairie"] = 0,
    ["pranger"] = 18,
    ["predator"] = 14,
    ["premier"] = 1,
    ["primo"] = 1,
    ["primo2"] = 1,
    ["proptrailer"] = 11,
    ["prototipo"] = 7,
    ["radi"] = 2,
    ["raketrailer"] = 11,
    ["rancherxl"] = 9,
    ["rancherxl2"] = 9,
    ["rapidgt"] = 6,
    ["rapidgt2"] = 6,
    ["ratloader"] = 4,
    ["ratloader2"] = 4,
    ["reaper"] = 7,
    ["rebel"] = 9,
    ["rebel2"] = 9,
    ["regina"] = 1,
    ["rentalbus"] = 17,
    ["rhapsody"] = 0,
    ["rhino"] = 19,
    ["riot"] = 18,
    ["ripley"] = 11,
    ["rocoto"] = 2,
    ["romero"] = 1,
    ["rubble"] = 10,
    ["ruffian"] = 8,
    ["ruiner"] = 4,
    ["rumpo"] = 12,
    ["rumpo2"] = 12,
    ["rumpo3"] = 12,
    ["sabregt"] = 4,
    ["sabregt2"] = 4,
    ["sadler"] = 11,
    ["sadler2"] = 11,
    ["sanchez"] = 8,
    ["sanchez2"] = 8,
    ["sandking"] = 9,
    ["sandking2"] = 9,
    ["savage"] = 15,
    ["schafter2"] = 1,
    ["schafter3"] = 6,
    ["schafter4"] = 6,
    ["schafter5"] = 1,
    ["schafter6"] = 1,
    ["schwarzer"] = 6,
    ["scorcher"] = 13,
    ["scrap"] = 11,
    ["seashark"] = 14,
    ["seashark2"] = 14,
    ["seashark3"] = 14,
    ["seminole"] = 2,
    ["sentinel"] = 3,
    ["sentinel2"] = 3,
    ["serrano"] = 2,
    ["seven70"] = 6,
    ["shamal"] = 16,
    ["sheriff"] = 18,
    ["sheriff2"] = 18,
    ["skylift"] = 15,
    ["slamvan"] = 4,
    ["slamvan2"] = 4,
    ["slamvan3"] = 4,
    ["sovereign"] = 8,
    ["speeder"] = 14,
    ["speeder2"] = 14,
    ["speedo"] = 12,
    ["speedo2"] = 12,
    ["squalo"] = 14,
    ["stalion"] = 4,
    ["stalion2"] = 4,
    ["stanier"] = 1,
    ["stinger"] = 5,
    ["stingergt"] = 5,
    ["stockade"] = 20,
    ["stockade3"] = 20,
    ["stratum"] = 1,
    ["stretch"] = 1,
    ["stunt"] = 16,
    ["submersible"] = 14,
    ["submersible2"] = 14,
    ["sultan"] = 6,
    ["sultanrs"] = 7,
    ["suntrap"] = 14,
    ["superd"] = 1,
    ["supervolito"] = 15,
    ["supervolito2"] = 15,
    ["surano"] = 6,
    ["surfer"] = 12,
    ["surfer2"] = 12,
    ["surge"] = 1,
    ["swift"] = 15,
    ["swift2"] = 15,
    ["t20"] = 7,
    ["taco"] = 12,
    ["tailgater"] = 1,
    ["tampa"] = 4,
    ["tanker"] = 11,
    ["tanker2"] = 11,
    ["tankercar"] = 21,
    ["taxi"] = 17,
    ["technical"] = 9,
    ["thrust"] = 8,
    ["tiptruck"] = 10,
    ["tiptruck2"] = 10,
    ["titan"] = 16,
    ["tornado"] = 5,
    ["tornado2"] = 5,
    ["tornado3"] = 5,
    ["tornado4"] = 5,
    ["tornado5"] = 5,
    ["toro"] = 14,
    ["toro2"] = 14,
    ["tourbus"] = 17,
    ["towtruck"] = 11,
    ["towtruck2"] = 11,
    ["tr2"] = 11,
    ["tr3"] = 11,
    ["tr4"] = 11,
    ["tractor"] = 11,
    ["tractor2"] = 11,
    ["tractor3"] = 11,
    ["trailerlogs"] = 11,
    ["trailers"] = 11,
    ["trailers2"] = 11,
    ["trailers3"] = 11,
    ["trailersmall"] = 11,
    ["trash"] = 17,
    ["trash2"] = 17,
    ["trflat"] = 11,
    ["tribike"] = 13,
    ["tribike2"] = 13,
    ["tribike3"] = 13,
    ["tropic"] = 14,
    ["tropic2"] = 14,
    ["tug"] = 14,
    ["turismor"] = 7,
    ["tvtrailer"] = 11,
    ["utillitruck"] = 11,
    ["utillitruck2"] = 11,
    ["utillitruck3"] = 11,
    ["vacca"] = 7,
    ["vader"] = 8,
    ["valkyrie"] = 15,
    ["valkyrie2"] = 15,
    ["velum"] = 16,
    ["velum2"] = 16,
    ["verlierer2"] = 6,
    ["vestra"] = 16,
    ["vigero"] = 4,
    ["vindicator"] = 8,
    ["virgo"] = 4,
    ["virgo2"] = 4,
    ["virgo3"] = 4,
    ["volatus"] = 15,
    ["voltic"] = 7,
    ["voodoo"] = 4,
    ["voodoo2"] = 4,
    ["warrener"] = 1,
    ["washington"] = 1,
    ["windsor"] = 3,
    ["windsor2"] = 3,
    ["xls"] = 2,
    ["xls2"] = 2,
    ["youga"] = 12,
    ["zentorno"] = 7,
    ["zion"] = 3,
    ["zion2"] = 3,
    ["ztype"] = 5,
}

---@param model number|string
---@return string
function ESX.GetVehicleType(model)
    model = type(model) == 'string' and joaat(model) or model

    if model == `submersible` or model == `submersible2` then
        return 'submarine'
    end

    if model == `blimp` then
        return 'heli'
    end

    local vehicleType = classFromName[model]
    local types = {
        [8] = "bike",
        [11] = "trailer",
        [13] = "bike",
        [14] = "boat",
        [15] = "heli",
        [16] = "plane",
        [21] = "train",
    }

    return types[vehicleType] or "automobile"
end

function ESX.DiscordLog(name, title, color, message)
	local webHook = Config.DiscordLogs.Webhooks[name] or Config.DiscordLogs.Webhooks.default
	local embedData = { {
		['title'] = title,
		['color'] = Config.DiscordLogs.Colors[color] or Config.DiscordLogs.Colors.default,
		['footer'] = {
			['text'] = "| ESX Logs | " .. os.date(),
			['icon_url'] = "https://cdn.discordapp.com/attachments/944789399852417096/1020099828266586193/blanc-800x800.png"
		},
		['description'] = message,
		['author'] = {
			['name'] = "ESX Framework",
			['icon_url'] = "https://cdn.discordapp.com/emojis/939245183621558362.webp?size=128&quality=lossless"
		}
	} }
	PerformHttpRequest(webHook, nil, 'POST', json.encode({
		username = 'Logs',
		embeds = embedData
	}), {
		['Content-Type'] = 'application/json'
	})
end

function ESX.DiscordLogFields(name, title, color, fields)
	local webHook = Config.DiscordLogs.Webhooks[name] or Config.DiscordLogs.Webhooks.default
	local embedData = { {
		['title'] = title,
		['color'] = Config.DiscordLogs.Colors[color] or Config.DiscordLogs.Colors.default,
		['footer'] = {
			['text'] = "| ESX Logs | " .. os.date(),
			['icon_url'] = "https://cdn.discordapp.com/attachments/944789399852417096/1020099828266586193/blanc-800x800.png"
		},
		['fields'] = fields,
		['description'] = "",
		['author'] = {
			['name'] = "ESX Framework",
			['icon_url'] = "https://cdn.discordapp.com/emojis/939245183621558362.webp?size=128&quality=lossless"
		}
	} }
	PerformHttpRequest(webHook, nil, 'POST', json.encode({
		username = 'Logs',
		embeds = embedData
	}), {
		['Content-Type'] = 'application/json'
	})
end

--- Create Job at Runtime
--- @param name string
--- @param label string
--- @param grades table
function ESX.CreateJob(name, label, grades)
	if not name then
		return print('[^3WARNING^7] missing argument `name(string)` while creating a job')
	end

	if not label then
		return print('[^3WARNING^7] missing argument `label(string)` while creating a job')
	end

	if not grades or not next(grades) then
		return print('[^3WARNING^7] missing argument `grades(table)` while creating a job!')
	end

	local parameters = {}
	local job = { name = name, label = label, grades = {} }

	for _, v in pairs(grades) do
		job.grades[tostring(v.grade)] = { job_name = name, grade = v.grade, name = v.name, label = v.label, salary = v.salary, skin_male = {}, skin_female = {} }
		parameters[#parameters + 1] = { name, v.grade, v.name, v.label, v.salary }
	end

	MySQL.insert('INSERT IGNORE INTO jobs (name, label) VALUES (?, ?)', { name, label })
	MySQL.prepare('INSERT INTO job_grades (job_name, grade, name, label, salary) VALUES (?, ?, ?, ?, ?)', parameters)

	ESX.Jobs[name] = job
end

function ESX.RefreshJobs()
	local Jobs = {}
	local jobs = MySQL.query.await('SELECT * FROM jobs')

	for _, v in ipairs(jobs) do
		Jobs[v.name] = v
		Jobs[v.name].grades = {}
	end

	local jobGrades = MySQL.query.await('SELECT * FROM job_grades')

	for _, v in ipairs(jobGrades) do
		if Jobs[v.job_name] then
			Jobs[v.job_name].grades[tostring(v.grade)] = v
		else
			print(('[^3WARNING^7] Ignoring job grades for ^5"%s"^0 due to missing job'):format(v.job_name))
		end
	end

	for _, v in pairs(Jobs) do
		if ESX.Table.SizeOf(v.grades) == 0 then
			Jobs[v.name] = nil
			print(('[^3WARNING^7] Ignoring job ^5"%s"^0 due to no job grades found'):format(v.name))
		end
	end

	if not Jobs then
		-- Fallback data, if no jobs exist
		ESX.Jobs['unemployed'] = { label = 'Unemployed', grades = { ['0'] = { grade = 0, label = 'Unemployed', salary = 200, skin_male = {}, skin_female = {} } } }
	else
		ESX.Jobs = Jobs
	end
end

function ESX.RegisterUsableItem(item, cb)
	Core.UsableItemsCallbacks[item] = cb
end

function ESX.UseItem(source, item, ...)
	if ESX.Items[item] then
		local itemCallback = Core.UsableItemsCallbacks[item]

		if itemCallback then
			local success, result = pcall(itemCallback, source, item, ...)

			if not success then
				return result and print(result) or print(('[^3WARNING^7] An error occured when using item ^5"%s"^7! This was not caused by ESX.'):format(item))
			end
		end
	else
		print(('[^3WARNING^7] Item ^5"%s"^7 was used but does not exist!'):format(item))
	end
end

function ESX.RegisterPlayerFunctionOverrides(index, overrides)
	Core.PlayerFunctionOverrides[index] = overrides
end

function ESX.SetPlayerFunctionOverride(index)
	if not index or not Core.PlayerFunctionOverrides[index] then
		return print('[^3WARNING^7] No valid index provided.')
	end

	Config.PlayerFunctionOverride = index
end

function ESX.GetItemLabel(item)
	if Config.OxInventory then
		item = exports.ox_inventory:Items(item)
		if item then
			return item.label
		end
	end

	if ESX.Items[item] then
		return ESX.Items[item].label
	else
		print(('[^3WARNING^7] Attemting to get invalid Item -> ^5%s^7'):format(item))
	end
end

function ESX.GetJobs()
	return ESX.Jobs
end

function ESX.GetUsableItems()
	local Usables = {}
	for k in pairs(Core.UsableItemsCallbacks) do
		Usables[k] = true
	end
	return Usables
end

if not Config.OxInventory then
	function ESX.CreatePickup(type, name, count, label, playerId, components, tintIndex)
		local pickupId = (Core.PickupId == 65635 and 0 or Core.PickupId + 1)
		local xPlayer = ESX.Players[playerId]
		local coords = xPlayer.getCoords()

		Core.Pickups[pickupId] = { type = type, name = name, count = count, label = label, coords = coords }

		if type == 'item_weapon' then
			Core.Pickups[pickupId].components = components
			Core.Pickups[pickupId].tintIndex = tintIndex
		end

		TriggerClientEvent('esx:createPickup', -1, pickupId, label, coords, type, name, components, tintIndex)
		Core.PickupId = pickupId
	end
end

function ESX.DoesJobExist(job, grade)
	grade = tostring(grade)

	if job and grade then
		if ESX.Jobs[job] and ESX.Jobs[job].grades[grade] then
			return true
		end
	end

	return false
end

function Core.IsPlayerAdmin(playerId)
	if (IsPlayerAceAllowed(playerId, 'command') or GetConvar('sv_lan', '') == 'true') and true or false then
		return true
	end

	local xPlayer = ESX.Players[playerId]

	if xPlayer then
		if Config.AdminGroups[xPlayer.group] then
			return true
		end
	end

	return false
end
