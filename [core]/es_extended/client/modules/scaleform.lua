ESX.Scaleform = {}
ESX.Scaleform.Utils = {}

function ESX.Scaleform.ShowFreemodeMessage(title, msg, sec)
    local scaleform = ESX.Scaleform.Utils.RunScaleformMovieMethod("MP_BIG_MESSAGE_FREEMODE", "SHOW_SHARD_WASTED_MP_MESSAGE", false, title, msg)

    while sec > 0 do
        Wait(0)
        sec = sec - 0.01

        DrawScaleformMovieFullscreen(scaleform, 255, 255, 255, 255, 0)
    end

    SetScaleformMovieAsNoLongerNeeded(scaleform)
end

function ESX.Scaleform.ShowBreakingNews(title, msg, bottom, sec)
    local scaleform = ESX.Scaleform.Utils.RunScaleformMovieMethod("BREAKING_NEWS", "SET_TEXT", false, msg, bottom)
    ESX.Scaleform.Utils.RunScaleformMovieMethod(scaleform, "SET_SCROLL_TEXT", false, 0, 0, title)
    ESX.Scaleform.Utils.RunScaleformMovieMethod(scaleform, "DISPLAY_SCROLL_TEXT", false, 0, 0)

    while sec > 0 do
        Wait(0)
        sec = sec - 0.01

        DrawScaleformMovieFullscreen(scaleform, 255, 255, 255, 255, 0)
    end

    SetScaleformMovieAsNoLongerNeeded(scaleform)
end

function ESX.Scaleform.ShowPopupWarning(title, msg, bottom, sec)
    local scaleform = ESX.Scaleform.Utils.RequestScaleformMovie("POPUP_WARNING")

    BeginScaleformMovieMethod(scaleform, "SHOW_POPUP_WARNING")

    ScaleformMovieMethodAddParamFloat(500.0) -- black background
    ScaleformMovieMethodAddParamTextureNameString(title)
    ScaleformMovieMethodAddParamTextureNameString(msg)
    ScaleformMovieMethodAddParamTextureNameString(bottom)
    ScaleformMovieMethodAddParamBool(true)

    EndScaleformMovieMethod()

    while sec > 0 do
        Wait(0)
        sec = sec - 0.01

        DrawScaleformMovieFullscreen(scaleform, 255, 255, 255, 255, 0)
    end

    SetScaleformMovieAsNoLongerNeeded(scaleform)
end

function ESX.Scaleform.ShowTrafficMovie(sec)
    local scaleform = ESX.Scaleform.Utils.RequestScaleformMovie("TRAFFIC_CAM")

    BeginScaleformMovieMethod(scaleform, "PLAY_CAM_MOVIE")

    EndScaleformMovieMethod()

    while sec > 0 do
        Wait(0)
        sec = sec - 0.01

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
function ESX.Scaleform.Utils.RunScaleformMovieMethod(scaleform, methodName, returnValue, ...)
    scaleform = type(scaleform) == "number" and scaleform or ESX.Scaleform.Utils.RequestScaleformMovie(scaleform)
    BeginScaleformMovieMethod(scaleform, methodName)

    local args = { ... }
    for i, arg in ipairs(args) do
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
