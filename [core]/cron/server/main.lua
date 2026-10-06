-- SPDX-License-Identifier: GPL-3.0-only
-- Copyright (C) 2022-2026 ESX Framework

---@class CronJob
---@field h number
---@field m number
---@field cb function|table

---@type CronJob[]
local cronJobs = {}
---@type number|false
local lastTimestamp = false

---@param h number
---@param m number
---@param cb function|table
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
    local function scheduledAt(job, dayOffset)
        local dateTable = os.date("*t", timestamp)
        dateTable.hour = job.h
        dateTable.min = job.m
        dateTable.sec = 0
        dateTable.day = dateTable.day + dayOffset

        return os.time(dateTable)
    end

    for i = 1, #cronJobs, 1 do
        local scheduledTimestamp = scheduledAt(cronJobs[i], 0)

        if scheduledTimestamp > timestamp then
            scheduledTimestamp = scheduledAt(cronJobs[i], -1)
        end

        if not lastTimestamp or lastTimestamp < scheduledTimestamp then
            local d = os.date('*t', scheduledTimestamp).wday

            if not pcall(cronJobs[i].cb, d, cronJobs[i].h, cronJobs[i].m) then
                print(("[^1ERROR^7] cron job at ^5%02d:%02d^7 errored, skipping it"):format(cronJobs[i].h, cronJobs[i].m))
            end
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

    local seconds = tonumber(os.date("%S", timestamp)) or 0
    local msToNextMinute = math.max(1000, (60 - seconds) * 1000)

    SetTimeout(msToNextMinute, Tick)
end

lastTimestamp = GetUnixTimestamp()
Tick()

---@param h number
---@param m number
---@param cb function|table
AddEventHandler("cron:runAt", function(h, m, cb)
    local invokingResource = GetInvokingResource() or "Unknown"
    local typeH = type(h)
    local typeM = type(m)
    local typeCb = type(cb)

    assert(typeH == "number", ("Expected number for h, got %s. Invoking Resource: '%s'"):format(typeH, invokingResource))
    assert(typeM == "number", ("Expected number for m, got %s. Invoking Resource: '%s'"):format(typeM, invokingResource))
    assert(typeCb == "function" or (typeCb == "table" and type(getmetatable(cb)?.__call) == "function"), ("Expected function for cb, got %s. Invoking Resource: '%s'"):format(typeCb, invokingResource))

    RunAt(h, m, cb)
end)
