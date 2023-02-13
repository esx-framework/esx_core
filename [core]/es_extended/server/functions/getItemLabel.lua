--- @param item string
--- @return string
function ESX.GetItemLabel(item)
    if Config.OxInventory then
        item = exports.ox_inventory:Items(item)
        if item then
            return item.label
        end
    end

    if ESX.Items[item] then
        return ESX.Items[item].label
    end

    print('[^3WARNING^7] Attemting to get invalid Item -> ^5' .. item .. "^7")
    return ''
end
