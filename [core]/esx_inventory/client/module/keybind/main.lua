-- SPDX-License-Identifier: GPL-3.0-only
-- Copyright (C) 2022-2026 ESX Framework

local Inventory = ESXInventory

xLib.addKeybind({
    name = 'showinv',
    description = TranslateCap('keymap_showinventory'),
    defaultMapper = 'keyboard',
    defaultKey = 'F2',
    onPressed = function()
        if Inventory.isOpen then
            Inventory.close(false)
        else
            Inventory.open()
        end
    end,
})

for i = 1, Config.HotbarSlots do
    xLib.addKeybind({
        name = ('hotbar%s'):format(i),
        description = TranslateCap('keymap_hotbar', i),
        defaultMapper = 'keyboard',
        defaultKey = tostring(i),
        onPressed = function()
            if Inventory.isOpen then
                return
            end

            if not ESX.PlayerLoaded or ESX.PlayerData.dead then
                return
            end

            local targetSlot = i - 1
            local item = Inventory.getItemInSlot(targetSlot)

            if item then
                Inventory.useItem(item.type, item.name)
            end
        end,
    })
end
