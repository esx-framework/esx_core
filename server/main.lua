WhiteList = {}

function loadWhiteList ()
  MySQL.Async.fetchAll(
    'SELECT * FROM whitelist',
    {},
    function (identifiers)
      Whitelist = {}

      for i=1, #identifiers, 1 do
        table.insert(WhiteList, tostring(identifiers[i].identifier))
      end
    end
  )
end

MySQL.ready(function ()
  loadWhiteList()
end)

AddEventHandler('playerConnecting', function (playerName, setKickReason)
  if (WhiteList == {}) then
    Citizen.Wait(1000)
  end

  local whitelisted = false
  local steamID = GetPlayerIdentifiers(source)[1] or false

  if steamID == false then
    setKickReason(_U('steamid_error'))
    CancelEvent()
  end

  for i = 1, #WhiteList, 1 do
    if (tostring(WhiteList[i]) == tostring(steamID)) then
      whitelisted = true
      break
    end
  end

  if whitelisted == false then
    setKickReason(_U('not_whitelisted'))
    CancelEvent()
  end
end)
