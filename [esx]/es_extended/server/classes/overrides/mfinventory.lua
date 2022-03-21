local Inventory = exports['mf-inventory']

Core.PlayerFunctionOverrides.MfInventory = {  
  setInventory = function(self)
    return function(inv)
      self.inventory = inv
    end
  end,
  
  getInventoryItem = function(self)
    return function(...)
      return Inventory:getInventoryItem(self.identifier,...)
    end
  end,
  
  addInventoryItem = function(self)
    return function(name,count,...)
      return Inventory:addInventoryItem(self.identifier,name,count,self.source,...)
    end
  end,
  
  removeInventoryItem = function(self)
    return function(name,count,...)
      return Inventory:removeInventoryItem(self.identifier,name,count,self.source,...)
    end
  end,
  
  addWeapon = function(self)
    return function(weaponName, ammo, metadata, ignoreInventory)
      if not self.hasWeapon(weaponName) then
        local weaponLabel = ESX.GetWeaponLabel(weaponName)

        table.insert(self.loadout, {
          name = weaponName,
          ammo = ammo,
          label = weaponLabel,
          components = {},
          tintIndex = 0
        })

        self.triggerEvent('esx:addWeapon', weaponName, ammo)
        self.triggerEvent('esx:addInventoryItem', weaponLabel, false, true)

        if not ignoreInventory then
          Inventory:addInventoryItem(self.identifier,weaponName,1,self.source,100,metadata)
        end
      end
    end
  end,
  
  removeWeapon = function(self)
    return function(weaponName, ammo, ignoreInventory)
      local weaponLabel

      for k,v in ipairs(self.loadout) do
        if v.name == weaponName then
          weaponLabel = v.label

          for k2,v2 in ipairs(v.components) do
            self.removeWeaponComponent(weaponName, v2)
          end

          table.remove(self.loadout, k)
          break
        end
      end

      if weaponLabel then
        self.triggerEvent('esx:removeWeapon', weaponName, ammo)
        self.triggerEvent('esx:removeInventoryItem', weaponLabel, false, true)

        if not ignoreInventory then
          Inventory:removeInventoryItem(self.identifier,weaponName,1,self.source)
        end
      end
    end
  end,
  
  setAccountMoney = function(self)
    return function(accountName, money)
      if money >= 0 then
        local account = self.getAccount(accountName)

        if account then
          local prevMoney = account.money
          local newMoney = ESX.Math.Round(money)

          account.money = newMoney

          self.triggerEvent('esx:setAccountMoney', account)

          Inventory:setAccountMoney(self.source,self.identifier,accountName,account.money)
        end
      end
    end
  end,
  
  addAccountMoney = function(self)
    return function(accountName, money, ignoreInventory)
      if money > 0 then
        local account = self.getAccount(accountName)

        if account then
          local newMoney = account.money + ESX.Math.Round(money)
          account.money = newMoney

          self.triggerEvent('esx:setAccountMoney', account)

          if not ignoreInventory then
            Inventory:setAccountMoney(self.source,self.identifier,accountName,account.money)
          end
        end
      end
    end
  end,
  
  removeAccountMoney = function(self)
    return function(accountName, money, ignoreInventory)
      if money > 0 then
        local account = self.getAccount(accountName)

        if account then
          local newMoney = account.money - ESX.Math.Round(money)
          account.money = newMoney

          self.triggerEvent('esx:setAccountMoney', account)

          if not ignoreInventory then
            Inventory:setAccountMoney(self.source,self.identifier,accountName,account.money)
          end
        end
      end
    end
  end,
  
  canCarryItem = function(self)
    return function(...)
      return Inventory:canCarry(self.identifier,...)
    end
  end,
  
  canSwapItem = function(self)
    return function(...)
      return Inventory:canSwap(self.identifier,...)
    end
  end,
}