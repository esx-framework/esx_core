<<<<<<< HEAD
# esx-legacy
Consolidated esx-legacy files into one repo for easy download since we will not support it
=======
# async
Async utilities for FXServer

## Installation
Set it as a dependency in you fxmanifest.lua
```
server_script '@async/async.lua'
```

## Usage
```
local tasks = {}

for i = 1, 100, 1 do
	local task = function(cb)
		SetTimeout(1000, function()
			local result = math.random(1, 50000)

			cb(result)
		end)
	end

	table.insert(tasks, task)
end

Async.parallel(tasks, function(results)
	print(json.encode(results))
end)

Async.parallelLimit(tasks, 2, function(results)
	print(json.encode(results))
end)

Async.series(tasks, function(results)
	print(json.encode(results))
end)
```
>>>>>>> async/master
