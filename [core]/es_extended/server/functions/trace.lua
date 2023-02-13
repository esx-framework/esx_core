function ESX.Trace(msg)
    if Config.EnableDebug then
        print(('[^2TRACE^7] %s^7'):format(msg))
    end
end