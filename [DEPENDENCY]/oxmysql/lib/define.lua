--- EmmyLua Annotations / VSCode Lua Language Server
--- https://marketplace.visualstudio.com/items?itemName=sumneko.lua


---@param query string
---@param parameters? table|function
---@param cb? function
---@return number affectedRows
function MySQL.update(query, parameters, cb) end
MySQL.Async.execute = MySQL.update

---@param query string
---@param parameters? table
---@return number affectedRows
function MySQL.update.await(query, parameters) end
MySQL.Sync.execute = MySQL.update.await

---@param query string
---@param parameters? table|function
---@param cb? function
---@return table<unknown, unknown> | nil result
function MySQL.query(query, parameters, cb) end
MySQL.Async.fetchAll = MySQL.query

---@param query string
---@param parameters? table
---@return table<unknown, unknown> | nil result
function MySQL.query.await(query, parameters) end
MySQL.Sync.fetchAll = MySQL.query.await

---@param query string
---@param parameters? table|function
---@param cb? function
---@return any column
function MySQL.scalar(query, parameters, cb) end
MySQL.Async.fetchScalar = MySQL.scalar

---@param query string
---@param parameters? table
---@return any column
function MySQL.scalar.await(query, parameters) end
MySQL.Sync.fetchScalar = MySQL.scalar.await

---@param query string
---@param parameters? table|function
---@param cb? function
---@return table<string, any> row
function MySQL.single(query, parameters, cb) end
MySQL.Async.fetchSingle = MySQL.single

---@param query string
---@param parameters? table
---@return table<string, any> row
function MySQL.single.await(query, parameters) end
MySQL.Sync.fetchSingle = MySQL.single.await

---@param query string
---@param parameters? table|function
---@param cb? function
---@return number insertId
function MySQL.insert(query, parameters, cb) end
MySQL.Async.insert = MySQL.insert

---@param query string
---@param parameters? table
---@return number insertId
function MySQL.insert.async(query, parameters) end
MySQL.Sync.insert = MySQL.insert.await

---@param queries table
---@param parameters? table|function
---@param cb? function
---@return boolean success
function MySQL.transaction(queries, parameters, cb) end
MySQL.Async.transaction = MySQL.transaction

---@param queries table
---@param parameters? table
---@return boolean success
function MySQL.transaction.await(queries, parameters) end
MySQL.Sync.transaction = MySQL.transaction.await

---@param query string
---@param parameters table
---@param cb? function
---@return unknown result
function MySQL.prepare(query, parameters, cb) end
MySQL.Async.prepare = MySQL.prepare

---@param query string
---@param parameters table
---@return unknown result
function MySQL.prepare.await(query, parameters) end
MySQL.Sync.prepare = MySQL.prepare.await
