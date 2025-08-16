ESX.Scaleform = {}
ESX.Scaleform.Utils = {}

function ESX.Scaleform.ShowFreemodeMessage(title, msg, sec)
    local scaleform = ESX.Scaleform.Utils.RunMethod("MP_BIG_MESSAGE_FREEMODE", "SHOW_SHARD_WASTED_MP_MESSAGE", false, title, msg)
    
    local endTime = GetGameTimer() + (sec * 1000)
    while GetGameTimer() < endTime do
        Wait(0)
        DrawScaleformMovieFullscreen(scaleform, 255, 255, 255, 255, 0)
    end

    SetScaleformMovieAsNoLongerNeeded(scaleform)
end

function ESX.Scaleform.ShowBreakingNews(title, msg, bottom, sec)
    local scaleform = ESX.Scaleform.Utils.RunMethod("BREAKING_NEWS", "SET_TEXT", false, msg, bottom)
    ESX.Scaleform.Utils.RunMethod(scaleform, "SET_SCROLL_TEXT", false, 0, 0, title)
    ESX.Scaleform.Utils.RunMethod(scaleform, "DISPLAY_SCROLL_TEXT", false, 0, 0)

    local endTime = GetGameTimer() + (sec * 1000)
    while GetGameTimer() < endTime do
        Wait(0)
        DrawScaleformMovieFullscreen(scaleform, 255, 255, 255, 255, 0)
    end

    SetScaleformMovieAsNoLongerNeeded(scaleform)
end

function ESX.Scaleform.ShowPopupWarning(title, msg, bottom, sec)
    local scaleform = ESX.Scaleform.Utils.RunMethod("POPUP_WARNING", "SHOW_POPUP_WARNING", false, 500.0, title, msg, bottom, true)

    local endTime = GetGameTimer() + (sec * 1000)
    while GetGameTimer() < endTime do
        Wait(0)
        DrawScaleformMovieFullscreen(scaleform, 255, 255, 255, 255, 0)
    end

    SetScaleformMovieAsNoLongerNeeded(scaleform)
end

function ESX.Scaleform.ShowTrafficMovie(sec)
    local scaleform = ESX.Scaleform.Utils.RunMethod("TRAFFIC_CAM", "PLAY_CAM_MOVIE", false)

    local endTime = GetGameTimer() + (sec * 1000)
    while GetGameTimer() < endTime do
        Wait(0)
        DrawScaleformMovieFullscreen(scaleform, 255, 255, 255, 255, 0)
    end

    SetScaleformMovieAsNoLongerNeeded(scaleform)
end

function ESX.Scaleform.Utils.RequestScaleformMovie(movie)
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
function ESX.Scaleform.Utils.RunMethod(scaleform, methodName, returnValue, ...)
    scaleform = type(scaleform) == "number" and scaleform or ESX.Scaleform.Utils.RequestScaleformMovie(scaleform)
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
