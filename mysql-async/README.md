# MySQL Async Library for FiveM

This library intends to provide function to connect to a MySQL library in a Sync and Async Way.

## Disclaimer

This mod does not replace EssentialMode, it offers instead a way of connecting to MySQL from lua-scripts, but
it will never contain any gameplay logic. It will remain a simple wrapper around MySQL functions.

All feedback is appreciated in order to deliver a stable release.

## Installation

Install the content of this repository in the `resources/mysql-async` folder. **Name of the folder** matters,
do not use a different name (otherwise you must have knowledge on how this works and make the appropriate changes)

Once installed, you will need to add this line of code in the resource file of each mod needing a MySQL client:

```
server_script '@mysql-async/lib/MySQL.lua'
```

### Warning

On Linux servers, users need to stick with the old mysql-async 2.x at least for the moment, due to some issues the linux server has with v8/javascript.

It can be downloaded from https://github.com/brouznouf/fivem-mysql-async/tree/2.0 or the release section. Note that the connection_string is different for 3.0.0 and 2.x.

## Configuration

Add this convar to your server configuration and change the values according to your MySQL installation:

`set mysql_connection_string "mysql://username:password@host/database?dateStrings=true"`

Further options can be found under https://github.com/mysqljs/mysql#connection-options

## Usage

### Waiting for MySQL to be ready

You need to encapsulate your code into `MySQL.ready` to be sure that the mod will be available and initialized
before your first request.

```lua
MySQL.ready(function ()
    print(MySQL.Sync.fetchScalar('SELECT @parameters', {
        ['@parameters'] =  'string'
    }))
end)
```

### Async

#### MySQL.Async.execute(string query, array params, function callback)

Works like `MySQL.Sync.execute` but will return immediatly instead of waiting for the execution of the query.
To exploit the result of an async method you must use a callback function:

```lua
MySQL.Async.execute('SELECT SLEEP(10)', {}, function(rowsChanged)
    print(rowsChanged)
end)
```

#### MySQL.Async.fetchAll(string query, array params, function callback)

Works like `MySQL.Sync.fetchAll` and provide callback like the `MySQL.Async.execute` method:

```lua
MySQL.Async.fetchAll('SELECT * FROM player', {}, function(players)
    print(players[1].name)
end)
```

#### MySQL.Async.fetchScalar(string query, array params, function callback)

Same as before for the fetchScalar method.

```lua
MySQL.Async.fetchScalar("SELECT COUNT(1) FROM players", function(countPlayer)
    print(countPlayer)
end
```

### Sync

> Sync functions can block the main thread, always prefer the Async version if possible, there is very rare
> use case for you to use this.

#### MySQL.Sync.execute(string query, array params) : int

Execute a mysql query which should not send any result (like a Insert / Delete / Update), and will return the
number of affected rows.

```lua
MySQL.Sync.execute("UPDATE player SET name=@name WHERE id=@id", {['@id'] = 10, ['@name'] = 'foo'})
```

#### MySQL.Sync.fetchAll(string query, array params) : object[]

Fetch results from MySQL and returns them in the form of an Array of Objects:

```lua
local players = MySQL.Sync.fetchAll('SELECT id, name FROM player')
print(players[1].id)
```

#### MySQL.Sync.fetchScalar(string query, array params) : mixed

Fetch the first field of the first row in a query:

```lua
local countPlayer = MySQL.Sync.fetchScalar("SELECT COUNT(1) FROM players")
```

## Features

 * Async / Sync
 * It uses the https://github.com/mysqljs/mysql library to provide a connection to your mysql server.
 * Create and close a connection for each query, the underlying library use a connection pool so only the
mysql auth is done each time, old tcp connections are keeped in memory for performance reasons

## Credits

Some parts of this library, and also my understanding were directly inspired by "Essential Mode", thanks to
them to have begin to work on this, which allows guy like me to not start from scratch every time...
