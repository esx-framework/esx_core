CreateThread(function()
    local MenuType = "list"
    local OpenedMenus = {}

    local function openMenu(namespace, name, data)
        OpenedMenus[namespace .. "_" .. name] = true

        SendNUIMessage({
            action = "openMenu",
            namespace = namespace,
            name = name,
            data = data,
        })
        SetTimeout(200, function()
            SetNuiFocus(true, true)
        end)
    end

    local function closeMenu(namespace, name)
        OpenedMenus[namespace .. "_" .. name] = nil
        local OpenedMenuCount = 0

        SendNUIMessage({
            action = "closeMenu",
            namespace = namespace,
            name = name,
        })

        for _, v in pairs(OpenedMenus) do
            if v then
                OpenedMenuCount = OpenedMenuCount + 1
            end
        end

        if OpenedMenuCount == 0 then
            SetNuiFocus(false)
        end
    end

    ESX.UI.Menu.RegisterType(MenuType, openMenu, closeMenu)

    RegisterNUICallback("menu_submit", function(data, cb)
        local menu = ESX.UI.Menu.GetOpened(MenuType, data._namespace, data._name)
        if menu.submit then
            menu.submit(data, menu)
        end
        cb("OK")
    end)

    RegisterNUICallback("menu_cancel", function(data, cb)
        local menu = ESX.UI.Menu.GetOpened(MenuType, data._namespace, data._name)

        if menu.cancel ~= nil then
            menu.cancel(data, menu)
        end

        cb("OK")
    end)
end)
