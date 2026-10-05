-- SPDX-License-Identifier: GPL-3.0-only
-- Copyright (C) 2022-2026 ESX Framework

Core.PlayerClass = Core.PlayerClass or {}

function Core.PlayerClass.AttachAccounts(self)
    local pendingOperations = 0
    local closing = false

    function self.beginAccountOperation()
        if closing then
            return false
        end

        pendingOperations = pendingOperations + 1
        return true
    end

    function self.beginAccountShutdown()
        closing = true
    end

    function self.endAccountOperation()
        pendingOperations = math.max(0, pendingOperations - 1)
    end

    function self.getPendingAccountOperations()
        return pendingOperations
    end

    local function validMoney(value)
        return type(value) == 'number' and value == value and math.abs(value) <= 9007199254740991
    end

    function self.setMoney(money)
        assert(type(money) == 'number', 'money should be number!')
        money = ESX.Math.Round(money)
        return self.setAccountMoney('money', money)
    end

    function self.getMoney()
        local account = self.getAccount('money')
        return account and account.money or 0
    end

    function self.addMoney(money, reason)
        money = ESX.Math.Round(money)
        return self.addAccountMoney('money', money, reason)
    end

    function self.removeMoney(money, reason)
        money = ESX.Math.Round(money)
        return self.removeAccountMoney('money', money, reason)
    end

    function self.getAccounts(minimal)
        if not minimal then
            return self.accounts
        end

        local minimalAccounts = {}

        for i = 1, #self.accounts do
            minimalAccounts[self.accounts[i].name] = self.accounts[i].money
        end

        return minimalAccounts
    end

    function self.getAccount(account)
        if type(account) ~= 'string' then
            return nil
        end

        account = string.lower(account)
        for i = 1, #self.accounts do
            local accountName = string.lower(self.accounts[i].name)
            if accountName == account then
                return self.accounts[i]
            end
        end
        return nil
    end

    function self.setAccountMoney(accountName, money, reason)
        reason = reason or 'unknown'

        if not validMoney(money) then
            error(
                ('Tried To Set Account ^5%s^1 For Player ^5%s^1 To An Invalid Number -> ^5%s^1'):format(
                    accountName,
                    self.playerId,
                    money
                )
            )
            return
        end

        if money >= 0 then
            local account = self.getAccount(accountName)

            if account then
                money = account.round and ESX.Math.Round(money) or money
                self.accounts[account.index].money = money

                self.triggerEvent('esx:setAccountMoney', account)
                TriggerEvent('esx:setAccountMoney', self.source, accountName, money, reason)
                return true
            else
                error(
                    ('Tried To Set Invalid Account ^5%s^1 For Player ^5%s^1!'):format(
                        accountName,
                        self.playerId
                    )
                )
            end
        else
            error(
                ('Tried To Set Account ^5%s^1 For Player ^5%s^1 To An Invalid Number -> ^5%s^1'):format(
                    accountName,
                    self.playerId,
                    money
                )
            )
        end
    end

    function self.addAccountMoney(accountName, money, reason)
        reason = reason or 'Unknown'

        if not validMoney(money) then
            error(
                ('Tried To Set Account ^5%s^1 For Player ^5%s^1 To An Invalid Number -> ^5%s^1'):format(
                    accountName,
                    self.playerId,
                    money
                )
            )
            return
        end

        if money > 0 then
            local account = self.getAccount(accountName)
            if account then
                money = account.round and ESX.Math.Round(money) or money
                local balance = self.accounts[account.index].money + money

                if not validMoney(balance) or balance < self.accounts[account.index].money then
                    return false
                end

                self.accounts[account.index].money = self.accounts[account.index].money + money

                self.triggerEvent('esx:setAccountMoney', account)
                TriggerEvent('esx:addAccountMoney', self.source, accountName, money, reason)
                return true
            else
                error(
                    ('Tried To Set Add To Invalid Account ^5%s^1 For Player ^5%s^1!'):format(
                        accountName,
                        self.playerId
                    )
                )
            end
        else
            error(
                ('Tried To Set Account ^5%s^1 For Player ^5%s^1 To An Invalid Number -> ^5%s^1'):format(
                    accountName,
                    self.playerId,
                    money
                )
            )
        end
    end

    function self.removeAccountMoney(accountName, money, reason)
        reason = reason or 'Unknown'

        if not validMoney(money) then
            error(
                ('Tried To Set Account ^5%s^1 For Player ^5%s^1 To An Invalid Number -> ^5%s^1'):format(
                    accountName,
                    self.playerId,
                    money
                )
            )
            return
        end

        if money > 0 then
            local account = self.getAccount(accountName)

            if account then
                money = account.round and ESX.Math.Round(money) or money

                if money <= 0 or self.accounts[account.index].money < money then
                    return false
                end

                if
                    self.accounts[account.index].money - money > self.accounts[account.index].money
                then
                    error(
                        ('Tried To Underflow Account ^5%s^1 For Player ^5%s^1!'):format(
                            accountName,
                            self.playerId
                        )
                    )
                    return
                end
                self.accounts[account.index].money = self.accounts[account.index].money - money

                self.triggerEvent('esx:setAccountMoney', account)
                TriggerEvent('esx:removeAccountMoney', self.source, accountName, money, reason)
                return true
            else
                error(
                    ('Tried To Set Add To Invalid Account ^5%s^1 For Player ^5%s^1!'):format(
                        accountName,
                        self.playerId
                    )
                )
            end
        else
            error(
                ('Tried To Set Account ^5%s^1 For Player ^5%s^1 To An Invalid Number -> ^5%s^1'):format(
                    accountName,
                    self.playerId,
                    money
                )
            )
        end
    end

end
