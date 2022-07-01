local commands = {}

SetTimeout(1000, function()
	TriggerClientEvent('chat:addSuggestions', -1, commands)
end)

AddEventHandler('playerJoining', function(source)
	TriggerClientEvent('chat:addSuggestions', source, commands)
end)

local function chatSuggestion(name, parameters, help)
	local params = {}

	if parameters then
		for i = 1, #parameters do
			local arg, argType = string.strsplit(':', parameters[i])

			if argType and argType:sub(0, 1) == '?' then
				argType = argType:sub(2, #argType)
			end

			params[i] = {
				name = arg,
				help = argType
			}
		end
	end

	commands[#commands + 1] = {
		name = '/'..name,
		help = help,
		params = params
	}
end

---@param group string
---@param name string
---@param callback function
---@param parameters table
local function addCommand(group, name, callback, parameters, help)
	if not group then group = 'builtin.everyone' end

	if type(name) == 'table' then
		for i = 1, #name do
			addCommand(group, name[i], callback, parameters, help)
		end
	else
		chatSuggestion(name, parameters, help)

		RegisterCommand(name, function(source, args)
			source = tonumber(source)

			if parameters then
				for i = 1, #parameters do
					local arg, argType = string.strsplit(':', parameters[i])
					local value = args[i]

					if arg == 'target' and value == 'me' then value = source end

					if argType then
						local optional

						if argType:sub(0, 1) == '?' then
							argType = argType:sub(2, #argType)
							optional = true
						end

						if argType == 'number' then
							value = tonumber(value) or value
						end

						local type = type(value)

						if type ~= argType and (not optional or type ~= 'nil') then
							local invalid = ('^1%s expected <%s> for argument %s (%s), received %s^0'):format(name, argType, i, arg, type)
							if source < 1 then
								return print(invalid)
							else
								return TriggerClientEvent('chat:addMessage', source, invalid)
							end
						end
					end

					args[arg] = value
					args[i] = nil
				end
			end

			callback(source, args)
		end, group and true)

		name = ('command.%s'):format(name)
		if not IsPrincipalAceAllowed(group, name) then lib.addAce(group, name) end
	end
end

return addCommand

--[[ Example
	AddCommand('group.admin', {'additem', 'giveitem'}, function(source, args)
		args.item = Items(args.item)
		if args.item and args.count > 0 then
			Inventory.AddItem(args.target, args.item.name, args.count, args.metatype)
		end
	end, {'target:number', 'item:string', 'count:number', 'metatype:?string'})
	-- /additem 1 burger 1
]]
