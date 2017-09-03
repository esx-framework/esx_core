ESX  = nil
Jobs = {}

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

AddEventHandler('onMySQLReady', function()

	local result = MySQL.Sync.fetchAll('SELECT * FROM jobs', {})

	for i=1, #result, 1 do
		Jobs[result[i].name]        = result[i]
		Jobs[result[i].name].grades = {}
	end

	local result2 = MySQL.Sync.fetchAll('SELECT * FROM job_grades', {})

	for i=1, #result2, 1 do
		Jobs[result2[i].job_name].grades[tostring(result2[i].grade)] = result2[i]
	end

end)

RegisterServerEvent('esx_society:withdrawMoney')
AddEventHandler('esx_society:withdrawMoney', function(society, amount)

	local xPlayer = ESX.GetPlayerFromId(source)

	TriggerEvent('esx_addonaccount:getSharedAccount', 'society_' .. society, function(account)

		if amount > 0 and account.money >= amount then

			account.removeMoney(amount)
			xPlayer.addMoney(amount)

			TriggerClientEvent('esx:showNotification', xPlayer.source, _U('have_withdrawn') .. amount)

		else
			TriggerClientEvent('esx:showNotification', xPlayer.source, _U('invalid_amount'))
		end

	end)

end)

RegisterServerEvent('esx_society:depositMoney')
AddEventHandler('esx_society:depositMoney', function(society, amount)

	local xPlayer = ESX.GetPlayerFromId(source)

	if amount > 0 and xPlayer.get('money') >= amount then

		TriggerEvent('esx_addonaccount:getSharedAccount', 'society_' .. society, function(account)
			xPlayer.removeMoney(amount)
			account.addMoney(amount)
		end)

		TriggerClientEvent('esx:showNotification', xPlayer.source, _U('have_deposited') .. amount)

	else
		TriggerClientEvent('esx:showNotification', xPlayer.source, _U('invalid_amount'))
	end

end)

RegisterServerEvent('esx_society:washMoney')
AddEventHandler('esx_society:washMoney', function(society, amount)

	local xPlayer = ESX.GetPlayerFromId(source)
	local account = xPlayer.getAccount('black_money')

	if amount > 0 and account.money >= amount then

		xPlayer.removeAccountMoney('black_money', amount)

			MySQL.Async.execute(
				'INSERT INTO society_moneywash (identifier, society, amount) VALUES (@identifier, @society, @amount)',
				{
					['@identifier'] = xPlayer.identifier,
					['@society']    = society,
					['@amount']     = amount
				},
				function(rowsChanged)
					TriggerClientEvent('esx:showNotification', xPlayer.source, _U('you_have') .. amount .. '~s~ en attente de ~r~blanchiement~s~ (24h)')
				end
			)

	else
		TriggerClientEvent('esx:showNotification', xPlayer.source, _U('invalid_amount'))
	end

end)

ESX.RegisterServerCallback('esx_society:getAccountMoney', function(source, cb, account)
	TriggerEvent('esx_addonaccount:getSharedAccount', account, function(account)
		cb(account.money)
	end)
end)

ESX.RegisterServerCallback('esx_society:getEmployees', function(source, cb, society)

	MySQL.Async.fetchAll(
		'SELECT * FROM users WHERE job = @job ORDER BY job_grade DESC',
		{
			['@job'] = society
		},
		function(result)

			local employees = {}

			for i=1, #result, 1 do

				table.insert(employees, {
					name        = result[i].name,
					identifier  = result[i].identifier,
					job = {
						name        = result[i].job,
						label       = Jobs[result[i].job].label,
						grade       = result[i].job_grade,
						grade_name  = Jobs[result[i].job].grades[tostring(result[i].job_grade)].name,
						grade_label = Jobs[result[i].job].grades[tostring(result[i].job_grade)].label,
					}
				})
			end

			cb(employees)

		end
	)

end)

ESX.RegisterServerCallback('esx_society:getJob', function(source, cb, society)

	local job    = json.decode(json.encode(Jobs[society]))
	local grades = {}

	for k,v in pairs(job.grades) do
		table.insert(grades, v)
	end

	table.sort(grades, function(a, b)
		return a.grade < b.grade
	end)

	job.grades = grades

	cb(job)

end)


ESX.RegisterServerCallback('esx_society:setJob', function(source, cb, identifier, job, grade, type)

	local xPlayer = ESX.GetPlayerFromIdentifier(identifier)

	if type == 'hire' then
  	TriggerClientEvent('esx:showNotification', xPlayer.source, _U('you_have_been_hired', job))
	elseif type == 'promote' then
		TriggerClientEvent('esx:showNotification', xPlayer.source, _U('you_have_been_promoted'))
	elseif type == 'fire' then
		TriggerClientEvent('esx:showNotification', xPlayer.source, _U('you_have_been_fired', xPlayer.getJob().label))
	end

	if xPlayer ~= nil then
		xPlayer.setJob(job, grade)
	end

	MySQL.Async.execute(
		'UPDATE users SET job = @job, job_grade = @job_grade WHERE identifier = @identifier',
		{
			['@job']        = job,
			['@job_grade']  = grade,
			['@identifier'] = identifier
		},
		function(rowsChanged)
			cb()
		end
	)

end)

ESX.RegisterServerCallback('esx_society:setJobSalary', function(source, cb, job, grade, salary)

	MySQL.Async.execute(
		'UPDATE job_grades SET salary = @salary WHERE job_name = @job_name AND grade = @grade',
		{
			['@salary']   = salary,
			['@job_name'] = job,
			['@grade']    = grade
		},
		function(rowsChanged)

			Jobs[job].grades[tostring(grade)].salary = salary

			local xPlayers = ESX.GetPlayers()

			for i=1, #xPlayers, 1 do

				local xPlayer = ESX.GetPlayerFromId(xPlayers[i])

				if xPlayer.job.name == job and xPlayer.job.grade == grade then
					xPlayer.setJob(job, grade)
				end

			end

			cb()
		end
	)

end)

ESX.RegisterServerCallback('esx_society:getOnlinePlayers', function(source, cb)

	local xPlayers = ESX.GetPlayers()
	local players  = {}

	for i=1, #xPlayers, 1 do

		local xPlayer = ESX.GetPlayerFromId(xPlayers[i])

		table.insert(players, {
			source     = xPlayer.source,
			identifier = xPlayer.identifier,
			name       = xPlayer.name,
			job        = xPlayer.job
		})

	end

	cb(players)

end)

function WashMoneyCRON(d, h, m)

	MySQL.Async.fetchAll(
		'SELECT * FROM society_moneywash',
		{},
		function(result)

			local xPlayers = ESX.GetPlayers()

			for i=1, #result, 1 do

				local foundPlayer = false
				local xPlayer     = nil

				for i=1, #xPlayers, 1 do
					local xPlayer2 = ESX.GetPlayerFromId(xPlayers[i])
					if xPlayer2.identifier == result[i].identifier then
						foundPlayer = true
						xPlayer     = xPlayer2
					end
				end

				TriggerEvent('esx_addonaccount:getSharedAccount', 'society_' .. result[i].society, function(account)
					account.addMoney(result[i].amount)
				end)

				if foundPlayer then
					TriggerClientEvent('esx:showNotification', xPlayer.source, _U('you_have_laundered') .. result[i].amount)
				end

				MySQL.Async.execute(
					'DELETE FROM society_moneywash WHERE id = @id',
					{
						['@id'] = result[i].id
					}
				)

			end

		end
	)

end

TriggerEvent('cron:runAt', 3, 0, WashMoneyCRON)
