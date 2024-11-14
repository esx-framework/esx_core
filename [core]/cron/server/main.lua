---@class CronJob
---@field h number
---@field m number
---@field cb function

---@type CronJob[]
local cronJobs = {}
---@type number|false
local lastTimestamp = false

---@param h number
---@param m number
---@param cb function
function RunAt(h, m, cb)
    cronJobs[#cronJobs + 1] = {
        h = h,
        m = m,
        cb = cb,
    }
end

---@return number
function GetUnixTimestamp()
    return os.time()
end

---@param timestamp number
function OnTime(timestamp)
    for i = 1, #cronJobs, 1 do
        local scheduledTimestamp = os.time({
            hour = cronJobs[i].h,
            min = cronJobs[i].m,
            sec = 0, -- Assuming tasks run at the start of the minute
            day = os.date("%d", timestamp),
            month = os.date("%m", timestamp),
            year = os.date("%Y", timestamp),
        })

        if timestamp >= scheduledTimestamp and (not lastTimestamp or lastTimestamp < scheduledTimestamp) then
            local d = os.date('*t', scheduledTimestamp).wday
            cronJobs[i].cb(d, cronJobs[i].h, cronJobs[i].m)
        end
    end
end

---@return nil
function Tick()
    local timestamp = GetUnixTimestamp()

    if not lastTimestamp or os.date("%M", timestamp) ~= os.date("%M", lastTimestamp) then
        OnTime(timestamp)
        lastTimestamp = timestamp
    end

    SetTimeout(60000, Tick)
end

lastTimestamp = GetUnixTimestamp()
Tick()

AddEventHandler("cron:runAt", function(h, m, cb)
    assert(type(h) == "number", ("Expected number for h, got %s"):format(type(h)))
    assert(type(m) == "number", ("Expected number for m, got %s"):format(type(m)))
    assert(type(cb) == "function", ("Expected function for cb, got %s"):format(type(cb)))

    RunAt(h, m, cb)
end)
