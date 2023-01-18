local isDead = false

function ShowBillsMenu()
	ESX.TriggerServerCallback('esx_billing:getBills', function(bills)
		if #bills > 0 then
			local elements = {
				{unselectable = true, icon = "fas fa-scroll", title = TranslateCap('invoices')}
			}

			for k,v in ipairs(bills) do
				elements[#elements+1] = {
					icon = "fas fa-scroll",
					title = ('%s - <span style="color:red;">%s</span>'):format(v.label, TranslateCap('invoices_item', ESX.Math.GroupDigits(v.amount))),
					billId = v.id
				}
			end

			ESX.OpenContext("right", elements, function(menu,element)
				ESX.TriggerServerCallback('esx_billing:payBill', function()
					ShowBillsMenu()
				end, element.billId)
			end)
		else
			ESX.ShowNotification(TranslateCap('no_invoices'))
		end
	end)
end

RegisterCommand('showbills', function()
	if not isDead then
		ShowBillsMenu()
	end
end, false)

RegisterKeyMapping('showbills', TranslateCap('keymap_showbills'), 'keyboard', 'F7')

AddEventHandler('esx:onPlayerDeath', function() isDead = true end)
AddEventHandler('esx:onPlayerSpawn', function(spawn) isDead = false end)
