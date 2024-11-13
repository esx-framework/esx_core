local addonResourcesState = {
    ['esx_progressbar'] = GetResourceState('esx_progressbar') ~= 'missing',
    ['esx_notify'] = GetResourceState('esx_notify') ~= 'missing',
    ['esx_textui'] = GetResourceState('esx_textui') ~= 'missing',
    ['esx_context'] = GetResourceState('esx_context') ~= 'missing',
}

local function IsResourceFound(resource)
	return addonResourcesState[resource] or error(('Resource [^5%s^1] is Missing!'):format(resource))
end

---@param message string
---@param length? number Timeout in milliseconds
---@param options? ProgressBarOptions
---@return boolean Success Whether the progress bar was successfully created or not
function ESX.Progressbar(message, length, options)
	return IsResourceFound('esx_progressbar') and exports['esx_progressbar']:Progressbar(message, length, options)
end

function ESX.CancelProgressbar()
    return IsResourceFound('esx_progressbar') and exports['esx_progressbar']:CancelProgressbar()
end

---@param message string The message to show
---@param notifyType? string The type of notification to show
---@param length? number The length of the notification
---@return nil
function ESX.ShowNotification(message, notifyType, length)
	return IsResourceFound('esx_notify') and exports['esx_notify']:Notify(notifyType, length, message)
end

function ESX.TextUI(...)
	return IsResourceFound('esx_textui') and exports['esx_textui']:TextUI(...)
end

---@return nil
function ESX.HideUI()
	return IsResourceFound('esx_textui') and exports['esx_textui']:HideUI()
end

function ESX.OpenContext(...)
    return IsResourceFound('esx_context') and exports['esx_context']:Open(...)
end

function ESX.PreviewContext(...)
    return IsResourceFound('esx_context') and exports['esx_context']:Preview(...)
end

function ESX.CloseContext(...)
    return IsResourceFound('esx_context') and exports['esx_context']:Close(...)
end

function ESX.RefreshContext(...)
    return IsResourceFound('esx_context') and exports['esx_context']:Refresh(...)
end
