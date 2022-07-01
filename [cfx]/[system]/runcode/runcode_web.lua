local cachedFiles = {}

local function sendFile(res, fileName)
	if cachedFiles[fileName] then
		res.send(cachedFiles[fileName])
		return
	end

	local fileData = LoadResourceFile(GetCurrentResourceName(), 'web/' .. fileName)

	if not fileData then
		res.writeHead(404)
		res.send('Not found.')
		return
	end

	cachedFiles[fileName] = fileData
	res.send(fileData)
end

local codeId = 1
local codes = {}

local attempts = 0
local lastAttempt

local function handleRunCode(data, res)
	if not data.lang then
		data.lang = 'lua'
	end

	if not data.client or data.client == '' then
		CreateThread(function()
			local result, err = RunCode(data.lang, data.code)

			res.send(json.encode({
				result = result,
				error = err
			}))
		end)
	else
		codes[codeId] = {
			timeout = GetGameTimer() + 1000,
			res = res
		}

		TriggerClientEvent('runcode:gotSnippet', tonumber(data.client), codeId, data.lang, data.code)

		codeId = codeId + 1
	end
end

RegisterNetEvent('runcode:runInBand')

AddEventHandler('runcode:runInBand', function(id, data)
	local s = source
	local privs = GetPrivs(s)

	local res = {
		send = function(str)
			TriggerClientEvent('runcode:inBandResult', s, id, str)
		end
	}

	if (not data.client or data.client == '') and not privs.canServer then
		res.send(json.encode({ error = 'Insufficient permissions.'}))
		return
	end

	if (data.client and data.client ~= '') and not privs.canClient then
		if privs.canSelf then
			data.client = s
		else
			res.send(json.encode({ error = 'Insufficient permissions.'}))
			return
		end
	end

	SaveResourceFile(GetCurrentResourceName(), 'data.json', json.encode({
		lastSnippet = data.code,
		lastLang = data.lang or 'lua'
	}), -1)

	handleRunCode(data, res)
end)

local function handlePost(req, res)
	req.setDataHandler(function(body)
		local data = json.decode(body)

		if not data or not data.password or not data.code then
			res.send(json.encode({ error = 'Bad request.'}))
			return
		end

		if GetConvar('rcon_password', '') == '' then
			res.send(json.encode({ error = 'The server has an empty rcon_password.'}))
			return
		end

		if attempts > 5 or data.password ~= GetConvar('rcon_password', '') then
			attempts = attempts + 1
			lastAttempt = GetGameTimer()

			res.send(json.encode({ error = 'Bad password.'}))
			return
		end

		handleRunCode(data, res)
	end)
end

CreateThread(function()
	while true do
		Wait(1000)
		
		if attempts > 0 and (GetGameTimer() - lastAttempt) > 5000 then
			attempts = 0
			lastAttempt = 0
		end
	end
end)

local function returnCode(id, res, err)
	if not codes[id] then
		return
	end

	local code = codes[id]
	codes[id] = nil

	local gotFrom

	if source then
		gotFrom = GetPlayerName(source) .. ' [' .. tostring(source) .. ']'
	end

	code.res.send(json.encode({
		result = res,
		error = err,
		from = gotFrom
	}))
end

CreateThread(function()
	while true do
		Wait(100)

		for k, v in ipairs(codes) do
			if GetGameTimer() > v.timeout then
				source = nil
				returnCode(k, '', 'Timed out waiting on the target client.')
			end
		end
	end
end)

RegisterNetEvent('runcode:gotResult')
AddEventHandler('runcode:gotResult', returnCode)

SetHttpHandler(function(req, res)
	local path = req.path

	if req.method == 'POST' then
		return handlePost(req, res)
	end

	-- client shortcuts
	if req.path == '/clients' then
		local clientList = {}

		for _, id in ipairs(GetPlayers()) do
			table.insert(clientList, { GetPlayerName(id), id })
		end

		res.send(json.encode({
			clients = clientList
		}))

		return
	end

	-- should this be the index?
	if req.path == '/' then
		path = 'index.html'
	end

	-- remove any '..' from the path
	path = path:gsub("%.%.", "")

	return sendFile(res, path)
end)