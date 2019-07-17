# Upgrading from Legacy Server

## A note about EssentialMode

This library does not provide api compatibility with EssentialMode. The reason is that old API was not logic due to the
 way on how mysql work which was inducing bad behavior, like executing multiple queries instead of one, or using only one 
 connection for all players (which was the main source of bug, having sync is not a problem as long as you know what you
 are doing).
 
Then if you come from legacy server and still using essential mod API, you should update by using this path:

 * Use the 1.0 of this library and read the UPGRADING.md file of it to use the new API
 * Then you can Update to fxserver and use the 2.X version of this lib
 * Then read the following advices on how to update your existing codebase for the 2.0 version
 
## Require

The `require` keyword does not exist anymore and will throw an error on fxserver. You should remove all references to 
require, there is no replacement as this is no longer useful.

However you will have to add this line to your resource file `__resource.lua` in order to have access to the mysql async:

```lua
server_script '@mysql-async/lib/MySQL.lua'
```

## Configuration

There is no more configuration file in this lib, instead it use directly a `conv_var` which is basically a variable set
in the configuration file of your fxserver `server.cfg`

So you can remove the config file that you were having and add this line into your `server.cfg` file :

```
set mysql_connection_string "server=mariadb;database=fivem;userid=root;password=fivem"
```

It is highly recommended to set those variable **before** starting modules so they will be available directly on startup
(even if we provide some safety check for someone defining this var after...)

## Startup code with queries

You may have some sql queries at the start of your module, however due to the new way of loading modules in fxserver 
(which is somehow async): Your library can be loaded before mysql-async even if you start it after.

To handle this use case, this library provide a special event `onMySQLReady` that is emitted once it's loaded, so you can do:

```lua
AddEventHandler('onMySQLReady', function ()
    -- Startup code using mysql
end)
```



