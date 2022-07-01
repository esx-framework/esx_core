AddEventHandler('gameEventTriggered', function(eventName, args)
    if eventName == 'CEventNetworkEntityDamage' then
        local victim = args[1]
        local culprit = args[2]
        local isDead = args[4] == 1

        if isDead then
            local origCoords = GetEntityCoords(victim)
            local pickup = CreatePickupRotate(`PICKUP_MONEY_VARIABLE`, origCoords.x, origCoords.y, origCoords.z - 0.7, 0.0, 0.0, 0.0, 512, 0, false, 0)
            local netId = PedToNet(victim)

            local undoStuff = { false }

            CreateThread(function()
                local self = PlayerPedId()

                while not undoStuff[1] do
                    Wait(50)

                    if #(GetEntityCoords(self) - origCoords) < 2.5 and HasPickupBeenCollected(pickup) then
                        TriggerServerEvent('money:tryPickup', netId)

                        RemovePickup(pickup)
                        break
                    end
                end

                undoStuff[1] = true
            end)

            SetTimeout(15000, function()
                if not undoStuff[1] then
                    RemovePickup(pickup)
                    undoStuff[1] = true
                end
            end)

            TriggerServerEvent('money:allowPickupNear', netId)
        end
    end
end)