local Jobs = {}
local LastTime = nil

function RunAt(h, m, cb)
	Jobs[#Jobs + 1] = {
		h = h,
		m = m,
		cb = cb
	}
end

function GetUnixTimestamp()
	return os.time()
end

function OnTime(h, m)
	local currentTimestamp = GetUnixTimestamp()

	for i = 1, #Jobs, 1 do
		local scheduledTimestamp = os.time({
			hour = Jobs[i].h,
			minute = Jobs[i].m,
			second = 0, -- Assuming tasks run at the start of the minute
			day = os.date('%d', currentTimestamp),
			month = os.date('%m', currentTimestamp),
			year = os.date('%Y', currentTimestamp)
		})

		if currentTimestamp >= scheduledTimestamp and (not LastTime or LastTime < scheduledTimestamp) then
			Jobs[i].cb(Jobs[i].h, Jobs[i].m)
		end
	end
end

function Tick()
	local time = GetUnixTimestamp()

	if not LastTime or os.date('%M', time) ~= os.date('%M', LastTime) then
		OnTime(os.date('%H', time), os.date('%M', time))
		LastTime = time
	end

	SetTimeout(60000, Tick)
end

LastTime = GetUnixTimestamp()

Tick()

AddEventHandler('cron:runAt', function(h, m, cb)
	RunAt(h, m, cb)
end)
