local Jobs = {}
local LastTime = nil

---@param h number Hour (0-23)
---@param m number Minute (0-59)
---@param cb function Callback to execute
function RunAt(h, m, cb)
    if type(h) ~= "number" or type(m) ~= "number" or type(cb) ~= "function" then
        print("[cron] Invalid arguments to RunAt. Expected (number, number, function).")
        return
    end

    Jobs[#Jobs + 1] = {
        h = h,
        m = m,
        cb = cb,
    }
end

---@return number Current timestamp
function GetUnixTimestamp()
    return os.time()
end

---@param time number The current Unix timestamp
function OnTime(time)
    local currentDay = os.date("*t", time).day
    local currentMonth = os.date("*t", time).month
    local currentYear = os.date("*t", time).year

    for i = 1, #Jobs, 1 do
        local scheduledTimestamp = os.time({
            hour = Jobs[i].h,
            min = Jobs[i].m,
            sec = 0, -- Assuming tasks run at the start of the minute
            year = currentYear,
            month = currentMonth,
            day = currentDay
        })

        if time >= scheduledTimestamp and (not LastTime or LastTime < scheduledTimestamp) then
            local d = os.date('*t', scheduledTimestamp).wday
            Jobs[i].cb(d, Jobs[i].h, Jobs[i].m)
        end
    end
end

function Tick()
    local currentTime = GetUnixTimestamp()

    if not LastTime or os.date("%M", currentTime) ~= os.date("%M", LastTime) then
        OnTime(currentTime)
        LastTime = currentTime
    end

    SetTimeout(60000, Tick)
end

LastTime = GetUnixTimestamp()
Tick()

AddEventHandler("cron:runAt", function(h, m, cb)
    RunAt(h, m, cb)
end)