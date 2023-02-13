--#TODO: Modul importálni coreba külső resourceből

---@param message string
---@param type string
function ESX.TextUI(message, type)
    if GetResourceState("esx_textui") ~= "missing" then
        return exports["esx_textui"]:TextUI(message, type)
    end

    print("[^1ERROR^7] ^5ESX TextUI^7 is Missing!")
end

function ESX.HideUI()
    if GetResourceState("esx_textui") ~= "missing" then
        return exports["esx_textui"]:HideUI()
    end

    print("[^1ERROR^7] ^5ESX TextUI^7 is Missing!")
end