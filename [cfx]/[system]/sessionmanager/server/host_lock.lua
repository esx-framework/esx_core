-- whitelist c2s events
RegisterServerEvent('hostingSession')
RegisterServerEvent('hostedSession')

-- event handler for pre-session 'acquire'
local currentHosting
local hostReleaseCallbacks = {}

-- TODO: add a timeout for the hosting lock to be held
-- TODO: add checks for 'fraudulent' conflict cases of hosting attempts (typically whenever the host can not be reached)
AddEventHandler('hostingSession', function()
    -- if the lock is currently held, tell the client to await further instruction
    if currentHosting then
        TriggerClientEvent('sessionHostResult', source, 'wait')

        -- register a callback for when the lock is freed
        table.insert(hostReleaseCallbacks, function()
            TriggerClientEvent('sessionHostResult', source, 'free')
        end)

        return
    end

    -- if the current host was last contacted less than a second ago
    if GetHostId() then
        if GetPlayerLastMsg(GetHostId()) < 1000 then
            TriggerClientEvent('sessionHostResult', source, 'conflict')

            return
        end
    end

    hostReleaseCallbacks = {}

    currentHosting = source

    TriggerClientEvent('sessionHostResult', source, 'go')

    -- set a timeout of 5 seconds
    SetTimeout(5000, function()
        if not currentHosting then
            return
        end

        currentHosting = nil

        for _, cb in ipairs(hostReleaseCallbacks) do
            cb()
        end
    end)
end)

AddEventHandler('hostedSession', function()
    -- check if the client is the original locker
    if currentHosting ~= source then
        -- TODO: drop client as they're clearly lying
        print(currentHosting, '~=', source)
        return
    end

    -- free the host lock (call callbacks and remove the lock value)
    for _, cb in ipairs(hostReleaseCallbacks) do
        cb()
    end

    currentHosting = nil
end)

EnableEnhancedHostSupport(true)