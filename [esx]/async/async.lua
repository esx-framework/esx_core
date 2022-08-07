Async = {}

function Async.parallel(tasks, cb)
	if #tasks == 0 then
		cb({})
		return
	end

	local remaining = #tasks
	local results = {}

	for i = 1, #tasks, 1 do
		CreateThread(function()
			tasks[i](function(result)
				results[#results+ 1] = result
				
				remaining = remaining - 1;

				if remaining == 0 then
					cb(results)
				end
			end)
		end)
	end
end

function Async.parallelLimit(tasks, limit, cb)
	if #tasks == 0 then
		cb({})
		return
	end

	local remaining = #tasks
	local running = 0
	local queue, results = {}, {}

	for i=1, #tasks, 1 do
		queue[#queue + 1] = tasks[i]
	end

	local function processQueue()
		if #queue == 0 then
			return
		end

		while running < limit and #queue > 0 do
			local task = table.remove(queue, 1)
			
			running = running + 1

			task(function(result)
				results[#results+ 1] = result
				
				remaining = remaining - 1;
				running = running - 1

				if remaining == 0 then
					cb(results)
				end
			end)
		end

		CreateThread(processQueue)
	end

	processQueue()
end

function Async.series(tasks, cb)
	Async.parallelLimit(tasks, 1, cb)
end
