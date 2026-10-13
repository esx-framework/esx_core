---Yields the current thread until the callback returns a non-nil value.
---@generic T
---@param cb fun(): T?
---@param errMessage? string
---@param timeout? number | false Error out after `~x` ms if the callback hasn't resolved. Defaults to 1000, unless set to `false`.
---@param interval? integer Polling interval in ms. Defaults to 0. A value above `timeout` overshoots it by one cycle.
---@return T
---@async
function xLib.waitFor(cb, errMessage, timeout, interval)
    xLib.verify(cb, 'function', true)

    if interval then
        xLib.verify(interval, 'int', true)
    end

    local value = cb()

    if value ~= nil then
        return value
    end

    if timeout ~= false and type(timeout) ~= 'number' then
        timeout = 5000
    end

    local start = timeout and GetGameTimer()

    while value == nil do
        Wait(interval or 0)

        value = cb()

        if value == nil and timeout then
            local elapsed = GetGameTimer() - start

            if elapsed > timeout then
                return error(('%s (waited %.1fms)'):format(errMessage or 'failed to resolve callback', elapsed), 2)
            end
        end
    end

    return value
end

return xLib.waitFor
