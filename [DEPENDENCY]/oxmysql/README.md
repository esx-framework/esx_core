<h1 align='center'><a href='https://overextended.github.io/docs/oxmysql/'>Documentation</a></h2>

### Introduction

Oxmysql is an alternative to the unmaintained mysql-async/ghmattimysql resources, utilising [node-mysql2](https://github.com/sidorares/node-mysql2) rather than [mysqljs](https://github.com/mysqljs/mysql).

As of v1.9.0 the preferred method of utilising oxmysql is via lib/MySQL, which can be loaded by adding `@oxmysql/lib/MySQL.lua` to your resource manifests. This resource should be 100% backwards compatible with mysql-async functionality on top of providing newer export wrappers and functionality.

Refer to [issue #77](https://github.com/overextended/oxmysql/issues/77) for information on replacing your queries from older versions of oxmysql or ghmattimysql.

### Features

- Support for URI connection strings and semicolon separated values
- Asynchronous queries utilising mysql2/promises connection pool
- Javascript async_retval exports supports promises across resources and runtimes
- Support for placeholder values (named and unnamed) to improve query speed and increase security against SQL injection
- Improved error checking when placeholders and parameters do not match
- Lua promises in `lib/MySQL.lua` files for improved performance when awaiting a response
- Support mysql-async syntax while providing newer (more accurate) names

### Usage

```lua
-- Lua
MySQL.query('SELECT * from users WHERE identifier = ?', {identifier}, function(result)
    -- callback response
    -- same as MySQL.Async.fetchAll
end)
CreateThread(function()
    local result = MySQL.query.await('SELECT * from users WHERE identifier = ?', {identifier})
    -- await a promise to resolve
    -- same as MySQL.Sync.fetchAll
end)
```

```js
// JS
exports.oxmysql.query('SELECT * from users WHERE identifier = ?', [identifier], (result) => {
  // callback response
})(async () => {
  const result = await exports.oxmysql.query_async('SELECT * from users WHERE identifier = ?', [identifier]);
  // await a promise to resolve
})();
exports.oxmysql.query_async('SELECT * from users WHERE identifier = ?', [identifier]).then((result) => {
  // utilise .then to resolve a promise like a callback
});
```

For more information regarding the use of queries, refer to the documentation linked above.

### Placeholders

This allows queries to be properly prepared and escaped; the following lines are equivalent.

```
"SELECT group FROM users WHERE identifier = ?", {identifier}
"SELECT group FROM users WHERE identifier = :identifier", {identifier = identifier}
"SELECT group FROM users WHERE identifier = @identifier", {['@identifier'] = identifier}
```

Named placeholders are deprecated and should be avoided as much as possible.

<br><br><br><br><br>

<hr>
<p align='center'><a href='https://discord.gg/overextended'>Discord</a></p>
<hr>
