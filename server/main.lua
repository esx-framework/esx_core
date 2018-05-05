ESX                       = nil
local DisptachRequestId   = 0
local PhoneNumbers        = {}

TriggerEvent('esx:getSharedObject', function(obj)
  ESX = obj
end)

function GenerateUniquePhoneNumber()

  local foundNumber = false
  local phoneNumber = nil

  while not foundNumber do

    phoneNumber = math.random(10000, 99999)

    local result = MySQL.Sync.fetchAll(
      'SELECT COUNT(*) as count FROM users WHERE phone_number = @phoneNumber',
      {
        ['@phoneNumber'] = phoneNumber
      }
    )

    local count  = tonumber(result[1].count)

    if count == 0 then
      foundNumber = true
    end

  end

  return phoneNumber
end

function GetDistpatchRequestId()

  local requestId = DisptachRequestId

  if DisptachRequestId < 65535 then
    DisptachRequestId = DisptachRequestId + 1
  else
    DisptachRequestId = 0
  end

  return requestId

end

AddEventHandler('esx_phone:getDistpatchRequestId', function(cb)
  cb(GetDistpatchRequestId())
end)

AddEventHandler('esx:playerLoaded', function(source)

  local xPlayer = ESX.GetPlayerFromId(source)

  for num,v in pairs(PhoneNumbers) do
    if tonumber(num) == num then -- If phonenumber is a player phone number
      for src,_ in pairs(v.sources) do
        TriggerClientEvent('esx_phone:setPhoneNumberSource', source, num, tonumber(src))
      end
    end
  end

  MySQL.Async.fetchAll(
    'SELECT * FROM users WHERE identifier = @identifier',
    {
      ['@identifier'] = xPlayer.identifier
    },
    function(result)

      local phoneNumber = result[1].phone_number

      if phoneNumber == nil then

        phoneNumber = GenerateUniquePhoneNumber()

        MySQL.Async.execute(
          'UPDATE users SET phone_number = @phone_number WHERE identifier = @identifier',
          {
            ['@identifier']   = xPlayer.identifier,
            ['@phone_number'] = phoneNumber
          }
        )
      end

      TriggerClientEvent('esx_phone:setPhoneNumberSource', -1, phoneNumber, source)

      PhoneNumbers[phoneNumber] = {
        type          = 'player',
        hashDispatch  = false,
        sharePos      = false,
        hideNumber    = false,
        hidePosIfAnon = false,
        sources       = {[source] = true}
      }

      xPlayer.set('phoneNumber', phoneNumber)

      if PhoneNumbers[xPlayer.job.name] ~= nil then
        TriggerEvent('esx_phone:addSource', xPlayer.job.name, source)
      end

      local contacts = {}

      MySQL.Async.fetchAll(
        'SELECT * FROM user_contacts WHERE identifier = @identifier ORDER BY name ASC',
        {
          ['@identifier'] = xPlayer.identifier
        },
        function(result2)

          for i=1, #result2, 1 do

            table.insert(contacts, {
              name   = result2[i].name,
              number = result2[i].number,
            })
          end

          xPlayer.set('contacts', contacts)

          TriggerClientEvent('esx_phone:loaded', source, phoneNumber, contacts)

        end
      )

    end
  )

end)

AddEventHandler('esx:playerDropped', function(source)

  local xPlayer = ESX.GetPlayerFromId(source)

  TriggerClientEvent('esx_phone:setPhoneNumberSource', -1, xPlayer.get('phoneNumber'), -1)

  PhoneNumbers[xPlayer.get('phoneNumber')] = nil

  if PhoneNumbers[xPlayer.job.name] ~= nil then
    TriggerEvent('esx_phone:removeSource', xPlayer.job.name, source)
  end

end)

AddEventHandler('esx:setJob', function(source, job, lastJob)

  if PhoneNumbers[lastJob.name] ~= nil then
    TriggerEvent('esx_phone:removeSource', lastJob.name, source)
  end

  if PhoneNumbers[job.name] ~= nil then
    TriggerEvent('esx_phone:addSource', job.name, source)
  end

end)

RegisterServerEvent('esx_phone:reload')
AddEventHandler('esx_phone:reload', function(phoneNumber)

  local _source  = source
  local xPlayer  = ESX.GetPlayerFromId(_source)
  local contacts = xPlayer.get('contacts')

  TriggerClientEvent('esx_phone:loaded', _source, phoneNumber, contacts)

end)

RegisterServerEvent('esx_phone:send')
AddEventHandler('esx_phone:send', function(phoneNumber, message, anon, position)

  local _source = source
  local xPlayer = ESX.GetPlayerFromId(_source)

  print('MESSAGE => ' .. xPlayer.name .. '@' .. phoneNumber .. ' : ' .. message)

  if PhoneNumbers[phoneNumber] ~= nil then

    for k,v in pairs(PhoneNumbers[phoneNumber].sources) do

      local numType          = PhoneNumbers[phoneNumber].type
      local numHasDispatch   = PhoneNumbers[phoneNumber].hasDispatch
      local numHide          = PhoneNumbers[phoneNumber].hideNumber
      local numHidePosIfAnon = PhoneNumbers[phoneNumber].hidePosIfAnon
      local numPosition      = (PhoneNumbers[phoneNumber].sharePos and position or false)
      local numSource        = tonumber(k)

      if numHidePosIfAnon and anon then
        numPosition = false
      end

      if numHasDispatch then
        TriggerClientEvent('esx_phone:onMessage', numSource, xPlayer.get('phoneNumber'), message, numPosition, (numHide and true or anon), numType, GetDistpatchRequestId())
      else
        TriggerClientEvent('esx_phone:onMessage', numSource, xPlayer.get('phoneNumber'), message, numPosition, (numHide and true or anon), numType, false)
      end

    end

  end

end)

AddEventHandler('esx_phone:registerNumber', function(number, type, sharePos, hasDispatch, hideNumber, hidePosIfAnon)
	local hideNumber    = hideNumber    or false
	local hidePosIfAnon = hidePosIfAnon or false

	PhoneNumbers[number] = {
		type          = type,
		sharePos      = sharePos,
		hasDispatch   = (hasDispatch or false),
		hideNumber    = hideNumber,
		hidePosIfAnon = hidePosIfAnon,
		sources       = {}
	}
end)

AddEventHandler('esx_phone:addSource', function(number, source)
	PhoneNumbers[number].sources[tostring(source)] = true
end)

AddEventHandler('esx_phone:removeSource', function(number, source)
	PhoneNumbers[number].sources[tostring(source)] = nil
end)

RegisterServerEvent('esx_phone:addPlayerContact')
AddEventHandler('esx_phone:addPlayerContact', function(phoneNumber, contactName)
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)
	phoneNumber   = tonumber(phoneNumber)
	
	-- is the player trying to enter something else into the database?
	if phoneNumber == nil then
		print('esx_phone: ' .. xPlayer.identifier .. ' attempted to crash the database!')
		return
	end

	MySQL.Async.fetchAll(
	'SELECT phone_number FROM users WHERE phone_number = @number',
	{
		['@number'] = phoneNumber
	}, function(result)
		if result[1] ~= nil then
			if phoneNumber == xPlayer.get('phoneNumber') then
				TriggerClientEvent('esx:showNotification', _source, _U('cannot_add_self'))
			else
				local contacts  = xPlayer.get('contacts')

				for i=1, #contacts, 1 do
					if contacts[i].number == phoneNumber then
						TriggerClientEvent('esx:showNotification', _source, _U('number_in_contacts'))
						return
					end
				end

				table.insert(contacts, {
					name   = contactName,
					number = phoneNumber,
				})

				xPlayer.set('contacts', contacts)

				MySQL.Async.execute(
				'INSERT INTO user_contacts (identifier, name, number) VALUES (@identifier, @name, @number)',
				{
					['@identifier'] = xPlayer.identifier,
					['@name']       = contactName,
					['@number']     = phoneNumber
				}, function(rowsChanged)
					TriggerClientEvent('esx:showNotification', _source, _U('contact_added'))
					TriggerClientEvent('esx_phone:addContact', _source, contactName, phoneNumber)
				end)
			end
		-- there's a bug with mysql-async where some statements will break everything...
		--else
			--TriggerClientEvent('esx:showNotification', _source, _U('number_not_assigned'))
		end
	end)
end)

RegisterServerEvent('esx_phone:removePlayerContact')
AddEventHandler('esx_phone:removePlayerContact', function(phoneNumber, contactName)
  local _source     = source
  local xPlayer     = ESX.GetPlayerFromId(_source)
  local foundNumber = false

  MySQL.Async.fetchAll(
    'SELECT phone_number FROM users WHERE phone_number = @number',
    {
      ['@number'] = phoneNumber
    },
    function(result)

      if result[1] ~= nil then
        foundNumber = true
      end

      if foundNumber then

        local contacts        = xPlayer.get('contacts')

        for key, value in pairs(contacts) do
          if value.name == contactName and value.number == phoneNumber then
            table.remove(contacts,key)
          end
        end

        xPlayer.set('contacts', contacts)

        MySQL.Async.execute(
          'DELETE FROM user_contacts WHERE identifier=@identifier AND name=@name AND number=@number',
          {
            ['@identifier'] = xPlayer.identifier,
            ['@name']       = contactName,
            ['@number']     = phoneNumber
          },
          function(rowsChanged)

            TriggerClientEvent('esx:showNotification', _source, _U('contact_removed'))

            TriggerClientEvent('esx_phone:removeContact', _source, contactName, phoneNumber)
          end
        )
      else
        TriggerClientEvent('esx:showNotification', source, _U('number_not_assigned'))
      end

    end
  )

end)

RegisterServerEvent('esx_phone:stopDispatch')
AddEventHandler('esx_phone:stopDispatch', function(dispatchRequestId)
  TriggerClientEvent('esx_phone:stopDispatch', -1, dispatchRequestId, GetPlayerName(source))
end)
