local esx_context = GetResourceState("esx_context") ~= "missing" and true or false

local function throwError()
    print("[^1ERROR^7] ^5esx_context^7 is missing!")
end

function ESX.OpenContext(...)
    if not esx_context then
        throwError()
        return
    end
    exports["esx_context"]:Open(...)
end

function ESX.PreviewContext(...)
    if not esx_context then
        throwError()
        return
    end
    exports["esx_context"]:Preview(...)
end

function ESX.CloseContext(...)
    if not esx_context then
        throwError()
        return
    end
    exports["esx_context"]:Close(...)
end

function ESX.RefreshContext(...)
    if not esx_context then
        throwError()
        return
    end
    exports["esx_context"]:Refresh(...)
end
