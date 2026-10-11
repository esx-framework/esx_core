-- SPDX-License-Identifier: GPL-3.0-only
-- Copyright (C) 2022-2026 ESX Framework

local Inventory = ESXInventory

local activeWeaponControls = {}
local suppressingWeaponControls = false
local weaponControls = {
    ['1'] = 157,
    ['2'] = 158,
    ['3'] = 160,
    ['4'] = 164,
    ['5'] = 165,
    ['6'] = 159,
    ['7'] = 161,
    ['8'] = 162,
    ['9'] = 163,
}

local function suppressWeaponShortcut(keybind)
    local control = weaponControls[keybind.currentKey]

    if not control then
        return
    end

    activeWeaponControls[keybind] = control
    DisableControlAction(0, control, true)

    if suppressingWeaponControls then
        return
    end

    suppressingWeaponControls = true
    CreateThread(function()
        while next(activeWeaponControls) do
            for binding, weaponControl in pairs(activeWeaponControls) do
                DisableControlAction(0, weaponControl, true)

                if not binding:isControlPressed()
                    or binding.disabled
                    or not ESX.PlayerLoaded
                    or ESX.PlayerData.dead
                    or Inventory.isOpen
                    or IsPauseMenuActive()
                then
                    activeWeaponControls[binding] = nil
                end
            end

            Wait(0)
        end

        suppressingWeaponControls = false
    end)
end

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
        onPressed = function(self)
            if Inventory.isOpen then
                return
            end

            if not ESX.PlayerLoaded or ESX.PlayerData.dead then
                return
            end

            suppressWeaponShortcut(self)

            local targetSlot = i - 1
            local item = Inventory.getItemInSlot(targetSlot)

            if item then
                Inventory.useItem(item.type, item.name)
            end
        end,
        onReleased = function(self)
            local control = activeWeaponControls[self]

            if control then
                DisableControlAction(0, control, true)
            end
        end,
    })
end
