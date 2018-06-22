function CreateExtendedPlayer(player, accounts, inventory, job, loadout, name, lastPosition)

  local self = {}

  self.player       = player
  self.accounts     = accounts
  self.inventory    = inventory
  self.job          = job
  self.loadout      = loadout
  self.name         = name
  self.lastPosition = lastPosition

  self.source     = self.player.get('source')
  self.identifier = self.player.get('identifier')

  self.setMoney = function(m)
    if m >= 0 then
      self.player.setMoney(m)
    else
      print('es_extended: ' .. self.name .. ' (' .. self.identifier .. ') attempted exploiting! (reason: player tried setting -1 cash balance)')
    end
  end

  self.getMoney = function()
    return self.player.get('money')
  end

  self.setBankBalance = function(m)
    if m >= 0 then
      self.player.setBankBalance(m)
    else
      print('es_extended: ' .. self.name .. ' (' .. self.identifier .. ') attempted exploiting! (reason: player tried setting -1 bank balance)')
    end
  end

  self.getBank = function()
    return self.player.get('bank')
  end

  self.getCoords = function()
    return self.player.get('coords')
  end

  self.setCoords = function(x, y, z)
    self.player.coords = {x = x, y = y, z = z}
  end

  self.kick = function(r)
    self.player.kick(r)
  end

  self.addMoney = function(m)
    if m >= 0 then
      self.player.addMoney(m)
    else
      print('es_extended: ' .. self.name .. ' (' .. self.identifier .. ') attempted exploiting! (reason: player tried adding -1 cash balance)')
    end
  end

  self.removeMoney = function(m)
    if m >= 0 then
      self.player.removeMoney(m)
    else
      print('es_extended: ' .. self.name .. ' (' .. self.identifier .. ') attempted exploiting! (reason: player tried removing -1 cash balance)')
    end
  end

  self.addBank = function(m)
    if m >= 0 then
      self.player.addBank(m)
    else
      print('es_extended: ' .. self.name .. ' (' .. self.identifier .. ') attempted exploiting! (reason: player tried adding -1 bank balance)')
    end
  end

  self.removeBank = function(m)
    if m >= 0 then
      self.player.removeBank(m)
    else
      print('es_extended: ' .. self.name .. ' (' .. self.identifier .. ') attempted exploiting! (reason: player tried removing -1 bank balance)')
    end
  end

  self.displayMoney = function(m)
    self.player.displayMoney(m)
  end

  self.displayBank = function(m)
    self.player.displayBank(m)
  end

  self.setSessionVar = function(key, value)
    self.player.setSessionVar(key, value)
  end

  self.getSessionVar = function(k)
    return self.player.getSessionVar(k)
  end

  self.getPermissions = function()
    return self.player.getPermissions()
  end

  self.setPermissions = function(p)
    self.player.setPermissions(p)
  end

  self.getIdentifier = function()
    return self.player.getIdentifier()
  end

  self.getGroup = function()
    return self.player.getGroup()
  end

  self.set = function(k, v)
    self.player.set(k, v)
  end

  self.get = function(k)
    return self.player.get(k)
  end

  self.getPlayer = function()
    return self.player
  end

  self.getAccounts = function()

    local accounts = {}

    for i=1, #Config.Accounts, 1 do

      if Config.Accounts[i] == 'bank' then

        table.insert(accounts, {
          name  = 'bank',
          money = self.get('bank'),
          label = Config.AccountLabels['bank']
        })

      else

        for j=1, #self.accounts, 1 do
          if self.accounts[j].name == Config.Accounts[i] then
            table.insert(accounts, self.accounts[j])
          end
        end

      end
    end

    return accounts

  end

  self.getAccount = function(a)

    if a == 'bank' then

      return {
        name  = 'bank',
        money = self.get('bank'),
        label = Config.AccountLabels['bank']
      }

    end

    for i=1, #self.accounts, 1 do
      if self.accounts[i].name == a then
        return self.accounts[i]
      end
    end
  end

  self.getInventory = function()
    return self.inventory
  end

  self.getJob = function()
    return self.job
  end

  self.getLoadout = function()
    return self.loadout
  end

  self.getName = function()
    return self.name
  end

  self.getLastPosition = function()
    return self.lastPosition
  end

  self.getMissingAccounts = function(cb)

    MySQL.Async.fetchAll(
      'SELECT * FROM `user_accounts` WHERE `identifier` = @identifier',
      {
        ['@identifier'] = self.getIdentifier()
      },
      function(result)

        local missingAccounts = {};

        for i=1, #Config.Accounts, 1 do

          if Config.Accounts[i] ~= 'bank' then

            local found = false

            for j=1, #result, 1 do
              if Config.Accounts[i] == result[j].name then
                found = true
              end
            end

            if not found then
              table.insert(missingAccounts, Config.Accounts[i])
            end

          end

        end

        cb(missingAccounts)

      end
    )

  end

  self.createAccounts = function(missingAccounts, cb)

    for i=1, #missingAccounts, 1 do
      MySQL.Async.execute(
        'INSERT INTO `user_accounts` (identifier, name) VALUES (@identifier, @name)',
        {
          ['@identifier'] = self.getIdentifier(),
          ['@name']       = missingAccounts[i]
        },
        function(rowsChanged)
          if cb ~= nil then
            cb()
          end
        end
      )
    end

  end

  self.setAccountMoney = function(a, m)
    if m < 0 then
      print('es_extended: ' .. self.name .. ' (' .. self.identifier .. ') attempted exploiting! (reason: player tried setting -1 account balance)')
      return
    end

    local account   = self.getAccount(a)
    local prevMoney = account.money
    local newMoney  = m

    account.money = newMoney

    if a == 'bank' then
      self.set('bank', newMoney)
    end

    TriggerClientEvent('esx:setAccountMoney', self.source, account)
  end

  self.addAccountMoney = function(a, m)
    if m < 0 then
      print('es_extended: ' .. self.name .. ' (' .. self.identifier .. ') attempted exploiting! (reason: player tried adding -1 account balance)')
      return
    end

    local account  = self.getAccount(a)
    local newMoney = account.money + m

    account.money = newMoney

    if a == 'bank' then
      self.set('bank', newMoney)
    end

    TriggerClientEvent('esx:setAccountMoney', self.source, account)
  end

  self.removeAccountMoney = function(a, m)
    if m < 0 then
      print('es_extended: ' .. self.name .. ' (' .. self.identifier .. ') attempted exploiting! (reason: player tried removing -1 account balance)')
      return
    end

    local account  = self.getAccount(a)
    local newMoney = account.money - m

    account.money = newMoney

    if a == 'bank' then
      self.set('bank', newMoney)
    end

    TriggerClientEvent('esx:setAccountMoney', self.source, account)
  end

  self.getInventoryItem = function(name)

    for i=1, #self.inventory, 1 do
      if self.inventory[i].name == name then
        return self.inventory[i]
      end
    end

  end

  self.addInventoryItem = function(name, count)

    local item     = self.getInventoryItem(name)
    local newCount = item.count + count
    item.count     = newCount

    TriggerEvent("esx:onAddInventoryItem", self.source, item, count)
    TriggerClientEvent("esx:addInventoryItem", self.source, item, count)

  end

  self.removeInventoryItem = function(name, count)

    local item     = self.getInventoryItem(name)
    local newCount = item.count - count
    item.count     = newCount

    TriggerEvent("esx:onRemoveInventoryItem", self.source, item, count)
    TriggerClientEvent("esx:removeInventoryItem", self.source, item, count)

  end

  self.setInventoryItem = function(name, count)

    local item     = self.getInventoryItem(name)
    local oldCount = item.count
    item.count     = count

    if oldCount > item.count  then
      TriggerEvent("esx:onRemoveInventoryItem", self.source, item, oldCount - item.count )
      TriggerClientEvent("esx:removeInventoryItem", self.source, item, oldCount - item.count )
    else
      TriggerEvent("esx:onAddInventoryItem", self.source, item, item.count  - oldCount)
      TriggerClientEvent("esx:addInventoryItem", self.source, item, item.count  - oldCount)
    end

  end

  self.setJob = function(name, grade)

    local lastJob = json.decode(json.encode(self.job))

    MySQL.Async.fetchAll(
      'SELECT * FROM `jobs` WHERE `name` = @name',
      {
        ['@name'] = name
      },
      function(result)

        self.job['id']    = result[1].id
        self.job['name']  = result[1].name
        self.job['label'] = result[1].label

        MySQL.Async.fetchAll(
          'SELECT * FROM `job_grades` WHERE `job_name` = @job_name AND `grade` = @grade',
          {
            ['@job_name'] = name,
            ['@grade']    = grade
          },
          function(result)

            self.job['grade']        = grade
            self.job['grade_name']   = result[1].name
            self.job['grade_label']  = result[1].label
            self.job['grade_salary'] = result[1].salary

            self.job['skin_male']    = nil
            self.job['skin_female']  = nil

            if result[1].skin_male ~= nil then
              self.job['skin_male'] = json.decode(result[1].skin_male)
            end

            if result[1].skin_female ~= nil then
              self.job['skin_female'] = json.decode(result[1].skin_female)
            end

            TriggerEvent("esx:setJob", self.source, self.job, lastJob)
            TriggerClientEvent("esx:setJob", self.source, self.job)

          end
        )

      end
    )

  end

  self.addWeapon = function(weaponName, ammo)

    local weaponLabel = weaponName

    for i=1, #Config.Weapons, 1 do
      if Config.Weapons[i].name == weaponName then
        weaponLabel = Config.Weapons[i].label
        break
      end
    end

    local foundWeapon = false

    for i=1, #self.loadout, 1 do
      if self.loadout[i].name == weaponName then
        foundWeapon = true
      end
    end

    if not foundWeapon then
      table.insert(self.loadout, {
        name  = weaponName,
        ammo  = ammo,
        label = weaponLabel
      })
    end
    TriggerClientEvent('esx:addWeapon', self.source, weaponName, ammo)
    TriggerClientEvent('esx:addInventoryItem', self.source, {label = weaponLabel}, 1)
  end

  self.removeWeapon = function(weaponName, ammo)

    local weaponLabel = weaponName

    for i=1, #Config.Weapons, 1 do
      if Config.Weapons[i].name == weaponName then
        weaponLabel = Config.Weapons[i].label
        break
      end
    end

    local foundWeapon = false

    for i=1, #self.loadout, 1 do
      if self.loadout[i].name == weaponName then
        table.remove(self.loadout, i)
        break
      end
    end

    TriggerClientEvent('esx:removeWeapon', self.source, weaponName, ammo)
    TriggerClientEvent('esx:removeInventoryItem', self.source, {label = weaponLabel}, 1)
  end

  return self

end
