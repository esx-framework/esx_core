function ESX.Progressbar(message, length, Options)
    if GetResourceState("esx_progressbar") ~= "missing" then
        return exports["esx_progressbar"]:Progressbar(message, length, Options)
    end

    print("[^1ERROR^7] ^5ESX Progressbar^7 is Missing!")
end