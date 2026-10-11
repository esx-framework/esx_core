-- SPDX-License-Identifier: GPL-3.0-only
-- Copyright (C) 2022-2026 ESX Framework

Core.PlayerClass = Core.PlayerClass or {}

function Core.PlayerClass.AttachWeapons(self)
    function self.getLoadout(minimal)
        if not minimal then
            return self.loadout
        end
        local minimalLoadout = {}

        for _, v in ipairs(self.loadout) do
            minimalLoadout[v.name] = { ammo = v.ammo }
            if v.tintIndex > 0 then
                minimalLoadout[v.name].tintIndex = v.tintIndex
            end

            if #v.components > 0 then
                local components = {}

                for _, component in ipairs(v.components) do
                    if component ~= "clip_default" then
                        components[#components + 1] = component
                    end
                end

                if #components > 0 then
                    minimalLoadout[v.name].components = components
                end
            end
        end

        return minimalLoadout
    end

    function self.addWeapon(weaponName, ammo)
        if not self.hasWeapon(weaponName) then
            local weaponLabel <const> = ESX.GetWeaponLabel(weaponName)

            table.insert(self.loadout, {
                name = weaponName,
                ammo = ammo,
                label = weaponLabel,
                components = {},
                tintIndex = 0,
            })

            GiveWeaponToPed(GetPlayerPed(self.source), joaat(weaponName), ammo, false, false)
            self.triggerEvent("esx:showInventoryItemNotification", true, weaponLabel, 1)
            self.triggerEvent("esx:addLoadoutItem", weaponName, weaponLabel, ammo)
            return true
        end

        return false
    end

    function self.addWeaponComponent(weaponName, weaponComponent)
        local loadoutNum <const>, weapon <const> = self.getWeapon(weaponName)

        if weapon then
            local component = ESX.GetWeaponComponent(weaponName, weaponComponent)

            if component then
                if not self.hasWeaponComponent(weaponName, weaponComponent) then
                    self.loadout[loadoutNum].components[#self.loadout[loadoutNum].components + 1] = weaponComponent
                    local componentHash = ESX.GetWeaponComponent(weaponName, weaponComponent).hash
                    GiveWeaponComponentToPed(GetPlayerPed(self.source), joaat(weaponName), componentHash)
                    self.triggerEvent("esx:showInventoryItemNotification", true, component.label, 1)
                    return true
                end
            end
        end

        return false
    end

    function self.addWeaponAmmo(weaponName, ammoCount)
        local _, weapon = self.getWeapon(weaponName)

        if weapon then
            weapon.ammo = weapon.ammo + ammoCount
            SetPedAmmo(GetPlayerPed(self.source), joaat(weaponName), weapon.ammo)
            self.triggerEvent("esx:updateWeaponAmmo", weaponName, weapon.ammo)
            return true
        end

        return false
    end

    function self.updateWeaponAmmo(weaponName, ammoCount)
        local _, weapon = self.getWeapon(weaponName)

        if not weapon then
            return false
        end

        weapon.ammo = ammoCount
        self.triggerEvent("esx:updateWeaponAmmo", weaponName, weapon.ammo)

        if weapon.ammo <= 0 then
            local _, weaponConfig = ESX.GetWeapon(weaponName)
            if weaponConfig.throwable then
                self.removeWeapon(weaponName)
            end
        end

        return true
    end

    function self.setWeaponTint(weaponName, weaponTintIndex)
        local loadoutNum <const>, weapon <const> = self.getWeapon(weaponName)

        if weapon then
            local _, weaponObject <const> = ESX.GetWeapon(weaponName)

            if weaponObject.tints and weaponObject.tints[weaponTintIndex] then
                self.loadout[loadoutNum].tintIndex = weaponTintIndex
                self.triggerEvent("esx:setWeaponTint", weaponName, weaponTintIndex)
                self.triggerEvent("esx:showInventoryItemNotification", true, weaponObject.tints[weaponTintIndex], 1)
                return true
            end
        end

        return false
    end

    function self.getWeaponTint(weaponName)
        local _, weapon <const> = self.getWeapon(weaponName)

        if weapon then
            return weapon.tintIndex
        end

        return 0
    end

    function self.removeWeapon(weaponName)
        local weaponLabel, playerPed <const> = nil, GetPlayerPed(self.source)

        if not playerPed then
            error("xPlayer.removeWeapon ^5invalid^1 player ped!")
        end

        for k, v in ipairs(self.loadout) do
            if v.name == weaponName then
                weaponLabel = v.label

                for _, v2 in ipairs(v.components) do
                    self.removeWeaponComponent(weaponName, v2)
                end

                local weaponHash = joaat(v.name)
                RemoveWeaponFromPed(playerPed, weaponHash)
                SetPedAmmo(playerPed, weaponHash, 0)

                table.remove(self.loadout, k)
                break
            end
        end

        if weaponLabel then
            self.triggerEvent("esx:showInventoryItemNotification", false, weaponLabel, 1)
            self.triggerEvent("esx:removeLoadoutItem", weaponName, weaponLabel)
            return true
        end

        return false
    end

    function self.removeWeaponComponent(weaponName, weaponComponent)
        local loadoutNum <const>, weapon <const> = self.getWeapon(weaponName)

        if weapon then
            local component <const> = ESX.GetWeaponComponent(weaponName, weaponComponent)

            if component then
                if self.hasWeaponComponent(weaponName, weaponComponent) then
                    for k, v in ipairs(self.loadout[loadoutNum].components) do
                        if v == weaponComponent then
                            table.remove(self.loadout[loadoutNum].components, k)
                            break
                        end
                    end

                    self.triggerEvent("esx:removeWeaponComponent", weaponName, weaponComponent)
                    self.triggerEvent("esx:showInventoryItemNotification", false, component.label, 1)
                    return true
                end
            end
        end

        return false
    end

    function self.removeWeaponAmmo(weaponName, ammoCount)
        local _, weapon = self.getWeapon(weaponName)

        if weapon then
            weapon.ammo = weapon.ammo - ammoCount
            SetPedAmmo(GetPlayerPed(self.source), joaat(weaponName), weapon.ammo)
            self.triggerEvent("esx:updateWeaponAmmo", weaponName, weapon.ammo)
            return true
        end

        return false
    end

    function self.hasWeaponComponent(weaponName, weaponComponent)
        local _, weapon <const> = self.getWeapon(weaponName)

        if weapon then
            for _, v in ipairs(weapon.components) do
                if v == weaponComponent then
                    return true
                end
            end

            return false
        end

        return false
    end

    function self.hasWeapon(weaponName)
        for _, v in ipairs(self.loadout) do
            if v.name == weaponName then
                return true
            end
        end

        return false
    end

    function self.getWeapon(weaponName)
        for k, v in ipairs(self.loadout) do
            if v.name == weaponName then
                return k, v
            end
        end

        return nil, nil
    end

end
