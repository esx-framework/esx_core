-- lib/MySQL.lua provides complete compatibility for resources designed for mysql-async
-- As of v2.0.0 this is the preferred method of interacting with oxmysql
-- * You can use mysql-async syntax or oxmysql syntax (refer to issue #77 or line 118)
-- * Using this lib provides minor improvements to performance and helps debug poor queries
-- * If using mysql-async syntax, a resource is not explicity bound to using oxmysql

-- todo: new annotations; need to see if I can get it working with metatables, otherwise it'll need stubs

local Store = {}

local function addStore(query, cb)
	assert(type(query) == 'string', 'The SQL Query must be a string')
	local store = #Store+1
	Store[store] = query
	if cb then cb(store) else return store end
end

local MySQL = {
	Sync = { store = addStore },
	Async = { store = addStore },

	ready = function(cb)
		CreateThread(function()
			repeat
				Wait(50)
			until GetResourceState('oxmysql') == 'started'
			cb()
		end)
	end
}

local type = type

local function safeArgs(query, parameters, cb, transaction)
	if type(query) == 'number' then query = Store[query] end

	if transaction then
		if type(query) ~= 'table' then
			error(("First argument expected table, received '%s'"):format(query))
		end
	else
		if type(query) ~= 'string' then
			error(("First argument expected string, received '%s'"):format(query))
		end
	end

	if parameters then
		local type = type(parameters)
		if type ~= 'table' and type ~= 'function' then
			error(("Second argument expected table or function, received '%s'"):format(parameters))
		end
	end

	if cb then
		local type = type(cb)
		if type ~= 'function' and (type == 'table' and not cb.__cfx_functionReference) then
			error(("Third argument expected function, received '%s'"):format(cb))
		end
	end

	return query, parameters, cb
end

local promise = promise
local oxmysql = exports.oxmysql
local Await = Citizen.Await
local GetCurrentResourceName = GetCurrentResourceName()

local function await(fn, query, parameters)
	local p = promise.new()
	fn(nil, query, parameters, function(result, error)
		if error then
			return p:reject(error)
		end

		p:resolve(result)
	end, GetCurrentResourceName, true)
	return Await(p)
end

setmetatable(MySQL, {
	__index = function(self, method)
		local state = GetResourceState('oxmysql')
		if state == 'started' or state == 'starting' then
			self[method] = setmetatable({}, {

				__call = function(_, query, parameters, cb)
					query, parameters, cb = safeArgs(query, parameters, cb, method == 'transaction')
					return oxmysql[method](nil, query, parameters, cb, GetCurrentResourceName, false)
				end,

				__index = function(_, index)
					assert(index == 'await', ('unable to index MySQL.%s.%s, expected .await'):format(method, index))
					self[method].await = function(query, parameters)
						return await(oxmysql[method], safeArgs(query, parameters, nil, method == 'transaction'))
					end
					return self[method].await
				end
			})

			return self[method]
		else
			error(('^1oxmysql resource state is %s - unable to trigger exports.oxmysql:%s^0'):format(state, method), 0)
		end
	end
})

local alias = {
	fetchAll = 'query',
	fetchScalar = 'scalar',
	fetchSingle = 'single',
	insert = 'insert',
	execute = 'update',
	transaction = 'transaction',
	prepare = 'prepare'
}

local alias_mt = {
	__index = function(self, key)
		if alias[key] then
			MySQL.Async[key] = MySQL[alias[key]]
			MySQL.Sync[key] = MySQL[alias[key]].await
			alias[key] = nil
			return self[key]
		end
	end
}

setmetatable(MySQL.Async, alias_mt)
setmetatable(MySQL.Sync, alias_mt)

_ENV.MySQL = MySQL

--[[
exports.oxmysql:query (previously exports.oxmysql:execute)
MySQL.Async.fetchAll = MySQL.query
MySQL.Sync.fetchAll = MySQL.query.await


exports.oxmysql:scalar
MySQL.Async.fetchScalar = MySQL.scalar
MySQL.Sync.fetchScalar = MySQL.scalar.await


exports.oxmysql:single
MySQL.Async.fetchSingle = MySQL.single
MySQL.Sync.fetchSingle = MySQL.single.await


exports.oxmysql:insert
MySQL.Async.insert = MySQL.insert
MySQL.Sync.insert = MySQL.insert.await


exports.oxmysql:update
MySQL.Async.execute = MySQL.update
MySQL.Sync.execute = MySQL.update.await


exports.oxmysql:transaction
MySQL.Async.transaction = MySQL.transaction
MySQL.Sync.transaction = MySQL.transaction.await


exports.oxmysql:prepare
MySQL.Async.prepare = MySQL.prepare
MySQL.Sync.prepare = MySQL.prepare.await
--]]
