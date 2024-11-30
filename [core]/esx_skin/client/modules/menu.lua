Menu = {}
Menu._index = Menu

function Menu:ESXMenu()
    ESX.UI.Menu.Open("default", GetCurrentResourceName(), "skin", {
        title = TranslateCap("skin_menu"),
        align = "bottom-left",
        elements = self.elements,
    }, function(data, menu)
        self:Submit(data, menu)
    end, function(data, menu)
        self:Cancel(data, menu)
    end, function(data, menu)
        self:Change(data, menu)
    end, function()
        self:Close()
    end)
end

function Menu:Restrict()
    local _components = {}
    for i = 1, #self.components, 1 do
        local found = false

        for j = 1, #self.restricted, 1 do
            if self.components[i].name == self.restricted[j] then
                found = true
            end
        end

        if found then
            _components[#_components + 1] = self.components[i]
        end
    end
    return _components
end

function Menu:InsertElements()
    local playerPed = PlayerPedId()

    for i = 1, #self.components, 1 do
        local value = self.components[i].value
        local componentId = self.components[i].componentId

        if componentId == 0 then
            value = GetPedPropIndex(playerPed, self.components[i].componentId)
        end

        local data = table.clone(self.components[i])
        data.value = value
        data.type = "slider"
        data.max = self.maxValues[self.components[i].name]

        if not self.elements then
            self.elements = {}
        end
        self.elements[#self.elements + 1] = data
    end
end

function Menu:Submit(data, menu)
    Skin.last = exports["skinchanger"]:GetSkin()
    self.submitCb(data, menu)
    Camera:Destroy()
end

function Menu:Cancel(data, menu)
    menu.close()
    Camera:Destroy()
    TriggerEvent("skinchanger:loadSkin", Skin.last)

    if self.cancelCb then
        self.cancelCb(data, menu)
    end
end

function Menu:Change(data, menu)
    local skin = exports["skinchanger"]:GetSkin()

    Skin.zoomOffset = data.current.zoomOffset
    Skin.camOffset = data.current.camOffset

    if skin[data.current.name] == data.current.value then
        return
    end

    -- Change skin element
    exports["skinchanger"]:Change(data.current.name, data.current.value)
    skin[data.current.name] = data.current.value

    -- Texture variation changed. We don't have to update anything.
    if data.current.textureof then
        return
    end

    -- Texture changed. Update variation max value.
    for i = 1, #self.elements, 1 do
        local element = self.elements[i]

        if element.textureof == data.current.name then
            local component = self.components[i]

            if ESX.IsFunctionReference(component.max) then
                self.elements[i].max = component.max(PlayerPedId(), skin)
            end
            self.elements[i].value = 0

            -- Change skin element
            exports["skinchanger"]:Change(element.name, 0)
            skin[element.name] = data.current.value

            menu.update({ name = self.elements[i].name }, self.elements[i])
            menu.refresh()
            break
        end
    end
end

---@diagnostic disable-next-line: duplicate-set-field
function Menu:Close()
    Camera:Destroy()
end

function Menu:Open(submit, cancel, restrict)
    self.submitCb = submit
    self.cancelCb = cancel
    self.restricted = restrict
    Skin.last = exports["skinchanger"]:GetSkin()

    self.components, self.maxValues = exports["skinchanger"]:GetData()
    if restrict then
        self.components = self:Restrict()
    end

    self:InsertElements()

    self.zoomOffset = self.components[1].zoomOffset
    self.camOffset = self.components[1].camOffset
    Camera:Create()

    self:ESXMenu()
end

function Menu:Saveable(submitCb, cancelCb, restrict)
    Skin.last = exports["skinchanger"]:GetSkin()

    self:Open(function(data, menu)
        menu.close()
        Camera:Destroy()

        local skin = exports["skinchanger"]:GetSkin()
        TriggerServerEvent("esx_skin:save", skin)

        if submitCb ~= nil then
            submitCb(data, menu)
        end
    end, cancelCb, restrict)
end
