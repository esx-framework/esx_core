local licenses = {}

MySQL.ready(function()
	local p = promise.new()
	MySQL.query('SELECT type, label FROM licenses', function(result)
		licenses = result
		p:resolve(true)
	end)
	Citizen.Await(p)
	ESX.Trace('[esx_license] : ' .. #licenses .. ' Loaded.')
end)

---@param identifier target identifier
---@param licenseType license type
---@param cb callback function
local function AddLicense(identifier, licenseType, cb)
	MySQL.insert('INSERT INTO user_licenses (type, owner) VALUES (?, ?)', {licenseType, identifier}, function(rowsChanged)
		if cb then
			cb(rowsChanged)
		end
	end)
end

---@param identifier target identifier
---@param licenseType license type
---@param cb callback function
local function RemoveLicense(identifier, licenseType, cb)
	MySQL.update('DELETE FROM user_licenses WHERE type = ? AND owner = ?', {licenseType, identifier}, function(rowsChanged)
		if cb then
			cb(rowsChanged)
		end
	end)
end

---@param licenseType license type
---@param cb callback function
local function GetLicense(licenseType, cb)
	MySQL.scalar('SELECT label FROM licenses WHERE type = ?', {licenseType}, function(result)
		if cb then
			cb({type = licenseType, label = result})
		end
	end)
end

---@param identifier target identifier
---@param cb callback function
local function GetLicenses(identifier, cb)
	MySQL.query('SELECT user_licenses.type, licenses.label FROM user_licenses LEFT JOIN licenses ON user_licenses.type = licenses.type WHERE owner = ?', {identifier},
	function(result)
		if cb then
			cb(result)
		end
	end)
end

---@param identifier target identifier
---@param licenseType license type
---@param cb callback function
local function CheckLicense(identifier, licenseType, cb)
	MySQL.scalar('SELECT type FROM user_licenses WHERE type = ? AND owner = ?', {licenseType, identifier}, function(result)
		if cb then
			if result then
				cb(true)
			else
				cb(false)
			end
		end
	end)
end

local function GetLicensesList(cb)
	cb(licenses)
end

local function isValidLicense(licenseType)
	local flag = false
	for i=1,#licenses do
		if licenses[i].type == licenseType then
			flag = true
			break
		end
	end
	return flag
end

AddEventHandler('esx_license:addLicense', function(target, licenseType, cb)
	local xPlayer = ESX.GetPlayerFromId(target)
	if xPlayer then
		if isValidLicense(licenseType) then
			AddLicense(xPlayer.getIdentifier(), licenseType, cb)
		else
			print('[esx_license] : missing license type in db ' .. licenseType .. ' or someone try to use lua executor id : ' .. target)
		end
	end
end)

RegisterNetEvent('esx_license:removeLicense')
AddEventHandler('esx_license:removeLicense', function(target, licenseType, cb)
	local xPlayer = ESX.GetPlayerFromId(source)
	if xPlayer then 
		if Config.allowedJobs[xPlayer.getJob().name] then
			local xTarget = ESX.GetPlayerFromId(target)
			if xTarget then
				RemoveLicense(xTarget.getIdentifier(), licenseType, cb)
			end
		else
			xPlayer.showNotification('Your job is not allowed to remove the license', 'error', 3000)
		end
	end
end)

AddEventHandler('esx_license:getLicense', function(licenseType, cb)
	GetLicense(licenseType, cb)
end)

AddEventHandler('esx_license:getLicenses', function(target, cb)
	local xPlayer = ESX.GetPlayerFromId(target)
	if xPlayer then
		GetLicenses(xPlayer.getIdentifier(), cb)
	end
end)

AddEventHandler('esx_license:checkLicense', function(target, licenseType, cb)
	local xPlayer = ESX.GetPlayerFromId(target)
	if xPlayer then
		CheckLicense(xPlayer.getIdentifier(), licenseType, cb)
	end
end)

AddEventHandler('esx_license:getLicensesList', function(cb)
	GetLicensesList(cb)
end)

ESX.RegisterServerCallback('esx_license:getLicense', function(source, cb, licenseType)
	local xPlayer = ESX.GetPlayerFromId(source)
	if xPlayer then
		GetLicense(licenseType, cb)
	end
end)

ESX.RegisterServerCallback('esx_license:getLicenses', function(source, cb, target)
	local xPlayer = ESX.GetPlayerFromId(target)
	if xPlayer then
		GetLicenses(xPlayer.getIdentifier(), cb)
	end
end)

ESX.RegisterServerCallback('esx_license:checkLicense', function(source, cb, target, licenseType)
	local xPlayer = ESX.GetPlayerFromId(target)
	if xPlayer then
		CheckLicense(xPlayer.getIdentifier(), licenseType, cb)
	end
end)

ESX.RegisterServerCallback('esx_license:getLicensesList', function(source, cb)
	GetLicensesList(cb)
end)