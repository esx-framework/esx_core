MenuBlip = function()
    local position = "right"

    local eles = {
        {
            unselectable=true,
            title="<img src=https://cdn.discordapp.com/attachments/1024424648760377384/1040041340022575135/Untitled-1.png width=50vh> Blips Creator",
        },
        {
            icon="fas fa-book",
            title= Translate['Blip_Name'],
            input=true,
            inputType="text",
            inputPlaceholder= Translate['Blip_Name_Example'],
            name="Nombre",
        },
        {
            icon="fas fa-image",
            title= Translate['Blip_Logo'],
            input=true,
            inputType="number",
            inputPlaceholder= Translate['Blip_Logo_Example'],
            name="Logo",
        },
        {
            icon="fas fa-paint-brush",
            title= Translate['Blip_Color'],
            input=true,
            inputType="number",
            inputPlaceholder= Translate['Blip_Color_Example'],
            name="Color",
        },
        {
            icon="fas fa-ruler",
            title= Translate['Size_Blip'],
            input=true,
            inputType="text",
            inputPlaceholder= Translate['Size_Blip_Example'],
            name="Tamano",
        },
        {
            icon = "fas fa-check",
            title = Translate['Submit'],
            name = "submit"
        },
        {
            icon = "fa fa-close",
            title = Translate['Cancel'],
            name = "close"
        }
    }

    local function onSelect(menu,ele)

        if ele.name == "close" then
            exports["esx_context"]:Close()
        end

        if ele.name ~= "submit" then
            return
        end

        for _,ele in ipairs(menu.eles) do
            if ele.input then
                if ele.name == 'Tamano' then
                    size = ele.inputValue
                elseif ele.name == 'Nombre' then
                    _Name = ele.inputValue
                elseif ele.name == 'Logo' then
                    Sprite = ele.inputValue
                elseif ele.name == 'Color' then
                    Color = ele.inputValue
                end

            end
            if Sprite and _Name and size and Color then
                local ped = GetPlayerPed(PlayerId())
                local coordenadas = GetEntityCoords(ped)
                local _size = tonumber(size)
                TriggerServerEvent('Esx_Blips:To_Json', _Name, coordenadas, Color, Sprite, _size) -- dialog.Tamano
                Color,Sprite,_Name,size = nil
                break
            end
        end

        exports["esx_context"]:Close()
    end
    
    exports["esx_context"]:Open(position,eles,onSelect,onClose)
end

