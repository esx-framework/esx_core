--[[```lua
{
	id?: string
	title?: string
	description: string
	duration?: number
	position?: 'top' | 'top-right' | 'top-left' | 'bottom' | 'bottom-right' | 'bottom-left'
	style?: table
	icon?: string
	iconColor?: string
}
```]]

-- Custom notifications with a lot of allowed styling
---@param data table
function lib.notify(data)
	SendNUIMessage({
		action = 'customNotify',
		data = data
	})
end

-- Default Chakra UI notifications
function lib.defaultNotify(data)
	SendNUIMessage({
		action = 'notify',
		data = data
	})
end

RegisterNetEvent('ox_lib:notify', lib.notify)
RegisterNetEvent('ox_lib:defaultNotify', lib.defaultNotify)
