if Config.CustomInventory ~= "tgianninventory" then return end
local inventory = exports["tgiann-inventory"]

MySQL.ready(function()
    TriggerEvent("__cfx_export_tgiann-inventory_Items", function(ref)
        if not ref then return end
        ESX.Items = ref()
    end)

    AddEventHandler("tgiann-inventory:itemList", function(items)
        ESX.Items = items
    end)
end)

---@diagnostic disable-next-line: duplicate-set-field
ESX.GetItemLabel = function(item)
    item = inventory:Items(item)
    if item then return item.label end
    return nil
end

---@diagnostic disable-next-line: duplicate-set-field
function ESX.UseItem(_, itemName, ...)
    local itemData = Core.UsableItemsCallbacks[itemName]

    if itemData then
        local callback = type(itemData) == 'table' and
            (rawget(itemData, '__cfx_functionReference') and itemData or itemData.cb or itemData.callback) or
            type(itemData) == 'function' and itemData
        if not callback then return end
        callback(...)
    end
end
