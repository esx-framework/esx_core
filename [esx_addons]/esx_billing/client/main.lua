local isDead = false

function ShowBillsMenu()
	ESX.TriggerServerCallback('esx_billing:getBills', function(bills)
		if #bills > 0 then
			ESX.UI.Menu.CloseAll()
			local elements = {}

			for k,v in ipairs(bills) do
				table.insert(elements, {
					label  = ('%s - <span style="color:red;">%s</span>'):format(v.label, TranslateCap('invoices_item', ESX.Math.GroupDigits(v.amount))),
					billId = v.id
				})
			end

			ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'billing', {
				title    = TranslateCap('invoices'),
				align    = 'bottom-right',
				elements = elements
			}, function(data, menu)
				menu.close()

				ESX.TriggerServerCallback('esx_billing:payBill', function()
					ShowBillsMenu()
				end, data.current.billId)
			end, function(data, menu)
				menu.close()
			end)
		else
			ESX.ShowNotification(TranslateCap('no_invoices'))
		end
	end)
end

RegisterCommand('showbills', function()
	if not isDead and not ESX.UI.Menu.IsOpen('default', GetCurrentResourceName(), 'billing') then
		ShowBillsMenu()
	end
end, false)

RegisterKeyMapping('showbills', TranslateCap('keymap_showbills'), 'keyboard', 'F7')

AddEventHandler('esx:onPlayerDeath', function() isDead = true end)
AddEventHandler('esx:onPlayerSpawn', function(spawn) isDead = false end)
