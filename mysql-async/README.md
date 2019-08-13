# mysql-async Library for FiveM

This library intends to provide function to connect to a MySQL library in a Sync and Async way.

## Table of Contents
* [Installation](#installation)
* [Configuration](#configuration)
  * [keepAlive](#keepalive)
  * [ConVars](#convars)
* [GUI](#gui)
* [Usage](#usage)
* [Features](#features)


## Installation

Install the content of this repository in the `resources/mysql-async` folder. **Name of the folder** matters,
do not use a different name (otherwise you must have knowledge on how this works and make the appropriate changes)

Once installed, you will need to add this line of code in the resource file of each mod needing a MySQL client:

```
server_script '@mysql-async/lib/MySQL.lua'
```

## Configuration

Add this convar to your server configuration and change the values according to your MySQL installation:

`set mysql_connection_string "server=localhost;uid=mysqluser;password=password;database=fivem"`

Alternatively an url-like connection string can be used:

`set mysql_connection_string "mysql://username:password@host/database"`

Further options can be found under https://github.com/mysqljs/mysql#connection-options for the mysql.js connection string, they can be added on both: the semicolon seperated string or the url-like string.

### keepAlive

For people, having issues with the connection being interrupted for usually a bad network configuration, but have no way of figuring out what is wrong, there is an option to enable keep alive queries. This will execute a query on the given interval. To enable those keep alive queries, append e.g. `keepAlive=60` to your connection string, seperated with a semicolon, to ensure that a keep alive query is fired every 60s.

### ConVars

The following ConVars are available in the `server.cfg` which you execute. These have also to be set before `start mysql-async`
* `set mysql_debug 1`: Prints out the actual consumed query.
* `set mysql_debug_output "console"`: Select where to output the log, accepts `console`, `file`, and `both`. In case of `both` and `file` a file named `mysql-async.log` in your main server folder will be created.
* `set mysql_slow_query_warning 200`: Sets a limit in ms, queries slower than this limit will be displayed with a warning at the specified location of `mysql_debug_output`, see above.

## GUI

Since the newest version, anyone with ace admin rights can open the GUI by typing `mysql` in the F8 console. This opens a profiling view of the data collected by this middleware, that might help you optimize resources and queries. You can disable the viewing of certain data by clicking on the respective entry in the legends, and can browse a table of the 21 slowest performing queries.

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

 * Async / Sync.
 * It uses the https://github.com/mysqljs/mysql library to provide a connection to your mysql server.
 * Create and close a connection for each query, the underlying library use a connection pool so only the
mysql auth is done each time, old tcp connections are keeped in memory for performance reasons.
