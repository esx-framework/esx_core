ESX.Modules['accessories'] = {}
local self = ESX.Modules['accessories']

-- Locals
local Input    = ESX.Modules['input']
local Interact = ESX.Modules['interact']

-- Properties
self.Config = ESX.EvalFile(GetCurrentResourceName(), 'modules/accessories/data/config.lua', {
  vector3 = vector3
})['Config']


self.Init = function()

	self.RegisterControls()

	local translations = ESX.EvalFile(GetCurrentResourceName(), 'modules/accessories/data/locales/' .. Config.Locale .. '.lua')['Translations']
	LoadLocale('accessories', Config.Locale, translations)

  for k,v in pairs(self.Config.Zones) do
    for i = 1, #v.Pos, 1 do

      local key = 'accessories:' .. k .. ':' .. i

      Interact.Register({
        name      = key,
        type      = 'marker',
        distance  = self.Config.DrawDistance,
        radius    = 2.0,
        pos       = v.Pos[i],
        size      = self.Config.Size.z,
        mtype     = self.Config.Type,
        color     = self.Config.Color,
        rotate    = true,
        accessory = k
      })

      AddEventHandler('esx:interact:enter:' .. key, function(data)

        ESX.ShowHelpNotification(_U('accessories:press_access'))

        self.CurrentAction = function()
          self.OpenShopMenu(data.accessory)
        end

      end)

      AddEventHandler('esx:interact:exit:' .. key, function(data)
        self.CurrentAction = nil
      end)

    end
  end

	for k,v in pairs(self.Config.ShopsBlips) do
		if v.Pos ~= nil then
			for i=1, #v.Pos, 1 do
				local blip = AddBlipForCoord(v.Pos[i])

				SetBlipSprite (blip, v.Blip.sprite)
				SetBlipDisplay(blip, 4)
				SetBlipScale  (blip, 1.0)
				SetBlipColour (blip, v.Blip.color)
				SetBlipAsShortRange(blip, true)

				BeginTextCommandSetBlipName("STRING")
				AddTextComponentString(_U('accessories:shop', _U(string.lower(k))))
				EndTextCommandSetBlipName(blip)
			end
		end
  end

end

self.OpenAccessoryMenu = function()
	ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'set_unset_accessory', {
		title = _U('accessories:set_unset'),
		align = 'top-left',
		elements = {
			{label = _U('accessories:helmet'), value = 'Helmet'},
			{label = _U('accessories:ears'), value = 'Ears'},
			{label = _U('accessories:mask'), value = 'Mask'},
			{label = _U('accessories:glasses'), value = 'Glasses'}
		}}, function(data, menu)
		menu.close()
		self.SetUnsetAccessory(data.current.value)
	end, function(data, menu)
		menu.close()
	end)
end

self.SetUnsetAccessory = function(accessory)
	ESX.TriggerServerCallback('esx_accessories:get', function(hasAccessory, accessorySkin)
		local _accessory = string.lower(accessory)

		if hasAccessory then
			TriggerEvent('skinchanger:getSkin', function(skin)
				local mAccessory = -1
				local mColor = 0

				if _accessory == "mask" then
					mAccessory = 0
				end

				if skin[_accessory .. '_1'] == mAccessory then
					mAccessory = accessorySkin[_accessory .. '_1']
					mColor = accessorySkin[_accessory .. '_2']
				end

				local accessorySkin = {}
				accessorySkin[_accessory .. '_1'] = mAccessory
				accessorySkin[_accessory .. '_2'] = mColor
				TriggerEvent('skinchanger:loadClothes', skin, accessorySkin)
			end)
		else
			ESX.ShowNotification(_U('accessories:no_' .. _accessory))
		end
	end, accessory)
end

self.OpenShopMenu = function(accessory)

  local _accessory = string.lower(accessory)
	local restrict = {}

	restrict = { _accessory .. '_1', _accessory .. '_2' }

	TriggerEvent('esx_skin:openRestrictedMenu', function(data, menu)

		menu.close()

		ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'shop_confirm', {
			title = _U('accessories:valid_purchase'),
			align = 'top-left',
			elements = {
				{label = _U('accessories:no'), value = 'no'},
				{label = _U('accessories:yes', ESX.Math.GroupDigits(self.Config.Price)), value = 'yes'}
			}}, function(data, menu)
			menu.close()
			if data.current.value == 'yes' then
				ESX.TriggerServerCallback('esx_accessories:checkMoney', function(hasEnoughMoney)
					if hasEnoughMoney then
						TriggerServerEvent('esx_accessories:pay')
						TriggerEvent('skinchanger:getSkin', function(skin)
							TriggerServerEvent('esx_accessories:save', skin, accessory)
						end)
					else
						TriggerEvent('esx_skin:getLastSkin', function(skin)
							TriggerEvent('skinchanger:loadSkin', skin)
						end)
						ESX.ShowNotification(_U('accessories:not_enough_money'))
					end
				end)
			end

			if data.current.value == 'no' then
				local player = PlayerPedId()
				TriggerEvent('esx_skin:getLastSkin', function(skin)
					TriggerEvent('skinchanger:loadSkin', skin)
				end)
				if accessory == "Ears" then
					ClearPedProp(player, 2)
				elseif accessory == "Mask" then
					SetPedComponentVariation(player, 1, 0 ,0, 2)
				elseif accessory == "Helmet" then
					ClearPedProp(player, 0)
				elseif accessory == "Glasses" then
					SetPedPropIndex(player, 1, -1, 0, 0)
				end
			end
			self.CurrentAction     = 'shop_menu'
			self.CurrentActionMsg  = _U('accessories:press_access')
			self.CurrentActionData = {}
		end, function(data, menu)
			menu.close()
			self.CurrentAction     = 'shop_menu'
			self.CurrentActionMsg  = _U('accessories:press_access')
			self.CurrentActionData = {}
		end)
	end, function(data, menu)
		menu.close()
		self.CurrentAction     = 'shop_menu'
		self.CurrentActionMsg  = _U('accessories:press_access')
		self.CurrentActionData = {}
	end, restrict)
end

self.RegisterControls = function()
  Input.RegisterControl(Input.Groups.MOVE, Input.Controls.PICKUP)
  Input.RegisterControl(Input.Groups.MOVE, Input.Controls.REPLAY_SHOWHOTKEY)
end
