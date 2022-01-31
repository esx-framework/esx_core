function AddLicense(target, type, cb)
	local xPlayer = ESX.GetPlayerFromId(target)

	if xPlayer then
		MySQL.insert('INSERT INTO user_licenses (type, owner) VALUES (?, ?)', {type, xPlayer.identifier},
		function(rowsChanged)
			if cb then
				cb()
			end
		end)
	else
		if cb then
			cb()
		end
	end
end

function RemoveLicense(target, type, cb)
	local xPlayer = ESX.GetPlayerFromId(target)

	if xPlayer then
		MySQL.update('DELETE FROM user_licenses WHERE type = ? AND owner = ?', {type, xPlayer.identifier},
		function(rowsChanged)
			if cb then
				cb()
			end
		end)
	else
		if cb then
			cb()
		end
	end
end

function GetLicense(type, cb)
	MySQL.scalar('SELECT label FROM licenses WHERE type = ?', {type},
	function(result)
		cb({type = type, label = result})
	end)
end

function GetLicenses(target, cb)
	local xPlayer = ESX.GetPlayerFromId(target)

	MySQL.query('SELECT user_licenses.type, licenses.label FROM user_licenses LEFT JOIN licenses ON user_licenses.type = licenses.type WHERE owner = ?', {xPlayer.identifier},
	function(result)
		cb(result)
	end)
end

function CheckLicense(target, type, cb)
	local xPlayer = ESX.GetPlayerFromId(target)

	if xPlayer then
		MySQL.scalar('SELECT type FROM user_licenses WHERE type = ? AND owner = ?', {type, xPlayer.identifier},
		function(result)
			if result then
				cb(true)
			else
				cb(false)
			end
		end)
	else
		cb(false)
	end
end

function GetLicensesList(cb)
	MySQL.query('SELECT type, label FROM licenses',
	function(result)
		cb(result)
	end)
end

RegisterNetEvent('esx_license:addLicense')
AddEventHandler('esx_license:addLicense', function(target, type, cb)
	AddLicense(target, type, cb)
end)

RegisterNetEvent('esx_license:removeLicense')
AddEventHandler('esx_license:removeLicense', function(target, type, cb)
	RemoveLicense(target, type, cb)
end)

AddEventHandler('esx_license:getLicense', function(type, cb)
	GetLicense(type, cb)
end)

AddEventHandler('esx_license:getLicenses', function(target, cb)
	GetLicenses(target, cb)
end)

AddEventHandler('esx_license:checkLicense', function(target, type, cb)
	CheckLicense(target, type, cb)
end)

AddEventHandler('esx_license:getLicensesList', function(cb)
	GetLicensesList(cb)
end)

ESX.RegisterServerCallback('esx_license:getLicense', function(source, cb, type)
	GetLicense(type, cb)
end)

ESX.RegisterServerCallback('esx_license:getLicenses', function(source, cb, target)
	GetLicenses(target, cb)
end)

ESX.RegisterServerCallback('esx_license:checkLicense', function(source, cb, target, type)
	CheckLicense(target, type, cb)
end)

ESX.RegisterServerCallback('esx_license:getLicensesList', function(source, cb)
	GetLicensesList(cb)
end)