---@class scaleformlib
xLib.scaleform = {}
xLib.scaleform.utils = {}

---@param title string
---@param msg string
---@param sec number
function xLib.scaleform.showFreemodeMessage(title, msg, sec)
    local scaleform = xLib.scaleform.utils.runMethod("MP_BIG_MESSAGE_FREEMODE", "SHOW_SHARD_WASTED_MP_MESSAGE", false, title, msg)

    local endTime = GetGameTimer() + (sec * 1000)
    while GetGameTimer() < endTime do
        Wait(0)
        DrawScaleformMovieFullscreen(scaleform, 255, 255, 255, 255, 0)
    end

    SetScaleformMovieAsNoLongerNeeded(scaleform)
end

---@param title string
---@param msg string
---@param bottom string
---@param sec number
function xLib.scaleform.showBreakingNews(title, msg, bottom, sec)
    local scaleform = xLib.scaleform.utils.runMethod("BREAKING_NEWS", "SET_TEXT", false, msg, bottom)
    xLib.scaleform.utils.runMethod(scaleform, "SET_SCROLL_TEXT", false, 0, 0, title)
    xLib.scaleform.utils.runMethod(scaleform, "DISPLAY_SCROLL_TEXT", false, 0, 0)

    local endTime = GetGameTimer() + (sec * 1000)
    while GetGameTimer() < endTime do
        Wait(0)
        DrawScaleformMovieFullscreen(scaleform, 255, 255, 255, 255, 0)
    end

    SetScaleformMovieAsNoLongerNeeded(scaleform)
end

---@param title string
---@param msg string
---@param bottom string
---@param sec number
function xLib.scaleform.showPopupWarning(title, msg, bottom, sec)
    local scaleform = xLib.scaleform.utils.runMethod("POPUP_WARNING", "SHOW_POPUP_WARNING", false, 500.0, title, msg, bottom, true)

    local endTime = GetGameTimer() + (sec * 1000)
    while GetGameTimer() < endTime do
        Wait(0)
        DrawScaleformMovieFullscreen(scaleform, 255, 255, 255, 255, 0)
    end

    SetScaleformMovieAsNoLongerNeeded(scaleform)
end

---@param sec number
function xLib.scaleform.showTrafficMovie(sec)
    local scaleform = xLib.scaleform.utils.runMethod("TRAFFIC_CAM", "PLAY_CAM_MOVIE", false)

    local endTime = GetGameTimer() + (sec * 1000)
    while GetGameTimer() < endTime do
        Wait(0)
        DrawScaleformMovieFullscreen(scaleform, 255, 255, 255, 255, 0)
    end

    SetScaleformMovieAsNoLongerNeeded(scaleform)
end

---@param movie string
---@return number
function xLib.scaleform.utils.requestScaleformMovie(movie)
    local scaleform = RequestScaleformMovie(movie)

    while not HasScaleformMovieLoaded(scaleform) do
        Wait(0)
    end

    return scaleform
end

--- Executes a method on a scaleform movie with optional arguments and return value.
--- The caller is responsible for disposing of the scaleform using `SetScaleformMovieAsNoLongerNeeded`.
---@param scaleform number|string # Scaleform handle or name to request the scaleform movie
---@param methodName string # The method name to call on the scaleform
---@param returnValue? boolean # Whether to return the value from the method
---@param ... number|string|boolean # Arguments to pass to the method
---@return number, number? # The scaleform handle, and the return value if `returnValue` is true
function xLib.scaleform.utils.runMethod(scaleform, methodName, returnValue, ...)
    if type(scaleform) ~= "number" then
        scaleform = xLib.scaleform.utils.requestScaleformMovie(scaleform)
    end

    BeginScaleformMovieMethod(scaleform, methodName)

    local args = { ... }
    for _, arg in ipairs(args) do
        local typeArg = type(arg)

        if typeArg == "number" then
            if math.type(arg) == "float" then
                ScaleformMovieMethodAddParamFloat(arg)
            else
                ScaleformMovieMethodAddParamInt(arg)
            end
        elseif typeArg == "string" then
            ScaleformMovieMethodAddParamTextureNameString(arg)
        elseif typeArg == "boolean" then
            ScaleformMovieMethodAddParamBool(arg)
        end
    end

    if returnValue then
        return scaleform, EndScaleformMovieMethodReturnValue()
    end

    EndScaleformMovieMethod()

    return scaleform
end

return xLib.scaleform
