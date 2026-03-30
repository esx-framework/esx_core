Modules.Multichar.RegisterHandlers()

ESX.RegisterServerCallback("esx_identity:registerIdentity", function(source, cb, data)
    Modules.Callback.RegisterIdentity(source, cb, data)
end)

Modules.Commands.Register()
Modules.Debugging.Register()
