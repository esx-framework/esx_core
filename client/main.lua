ESX = nil

local base64MoneyIcon = 'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAFoAAABaCAMAAAAPdrEwAAAAIGNIUk0AAHolAACAgwAA+f8AAIDpAAB1MAAA6mAAADqYAAAXb5JfxUYAAAMAUExURQAAACmvPCmwPCuwPiywPi2wPy6xQC6xQS+yQTCxQTCyQTCyQjGyQzKyRDOzRTSzRTSzRjW0RjW0Rza0SDe0STi0STm1Sjq1Szq2Szu2TDy2TDy2TT22Tj63Tz+3UEC4UEG4UUG4UkK4U0O5VES5VEW6VUa6Vke6V0i7WEm7WUu8Wku8W0y8W028XE29XU++XlC9X1C+X1G+YFK+YVO/YlW/ZFXAZFfAZVfAZljBZlnBZ1rBaVvCaVvCalzDal7CbF/DbV/EbWHEbmLEb2LEcGTFcWfGdGjHdWrHd2vId2vIeGzIeW3JenHKfXLKfnPLf3TLgHXLgXXMgHXMgXbMgnjNg3nMhHrNhnrOhnzOiH7PiYLQjYPRjoTRjoTRj4XRkIXSkIfSkojSk4rUlYzUlo7VmJDWmpHWm5LXnJTXnZTXnpXYnpbYn5nZopzapJ3bpZ7bpp7bp6DcqKLcqqPcq6Tcq6TdrKberqjfr6jfsKnfsavgs6zgs6zgtK7hta/htrDit7LiuLLiubPjurTjurXju7bkvLbkvbnlv7rlwLrmwLzmwr3nw77nxMDnxcLox8PpyMTpycXpysXqysbqy8fqzMnrzcrrz8vsz8vs0Mzs0c3t0tHu1dHu1tPv19Tv2NXv2dXw2dbw2tfw29jw3Nnx3drx3t7z4d/z4uD04+H05OP15eP15uT15uT15+X16OX26Of26en36+r37Ov37er47Ov47ez47e347u347+758PD58fD68fD68vL69PT79fX79vb79/b89vb89/f8+Pj9+fn9+vr9+/v++/v+/Pz+/P3+/f3+/v7//wAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAALfZHJgAAAEAdFJOU////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////wBT9wclAAAACXBIWXMAAA7DAAAOwwHHb6hkAAAAGHRFWHRTb2Z0d2FyZQBwYWludC5uZXQgNC4xLjb9TgnoAAAGdUlEQVRoQ7WZ93sURRiAFZO76O1eklt215OgBwqJgmgCRhAhRrAAiogBK4gBJEFEgWAEYiGIYEGp1kjXQECkiF0OWyjJ/k34zcy3db7Zu8fHe3/KTXnzPbPT56orRTEYAhMLUFgNKkeiGH8BNaV1KWSPVXveU9s3LW9pvhdoblm+afspTHZi5Wo1BnzpaOfcnFmWSBv29YBtpBNlZm5u59FLPDsmdJUaxQeXNugZw5IwMnrD0oO8iFKuUHNx/+bGZLWNMgm7Otm4uZ/LsVIEUs3F+Y5a3USNAlOv7cgr5ZSamQffyOnKgH1sPdfFi2PVILKaReEcmKwVIWbY2uQDvApW95HULIb+Ng0rFoXWxppcCjyqZuZjk4oNWWBrk44R7oiamXdkC3w9GTO7Q3aH1cy8OkWFnHtitstM4j/bqdWSO6Rm5nYdS4e5FbKQwxlMC6G3Q1bIHVQz8+IKLBphJLdydlRjWpiKxZAXdAfUPOak4gOO4FZOdxWmhbGTkbh9NTOvoVsDuGmAaxkdlZgWRV8Dub7bV0PyzhQWkqk5z7WMdjpqILUTslEXUEPQJ7Lq7pz9WXiBZ4iZUGBnTwTCdtVgvjgxpj+b3vTvTEteq5KbEy/6blcNVZapR3cmdc9Z4QV6Pnxzdr1GF9aWQQFUohqCPqQc3ZV17X3C6tP31kyL+Jy2dsgLW6jBPDgVc6OkR3XxCV/i9IqRRFedylxc6qk30L3DNF7ikz1Jft0oLOaT2hBSg/l8jmwOo24/amimYzkfOwfdlLtdNT1YjIaf0EFzgGhuNnB8teNcqCWDvs3vzSSLqC9Ze0F0EqaGoDeSQWt7UaHgXA0WDKFvFGEzNRS6mxot6VZhUNJNdm7zbsgSagj6UAKTQ5hnhEHJffRISIi+LdRLyNn9cTSoOExP3FZmiat2nIF66t9Xb0GFz8Df+AenVTEF2vUwAzM1BN1LfsTkcVS4bJs+fnRj84z3joqf+eFYUELvZWFzdSfZHjeeEwqXl6/myWaZ0bSVDf3uJP9NkOn01HPISXIMTJAB/hiB6WBPN+xxBpvxl4wxR6ihll8pSL1QupwLLhR22YL9ysVGrKRcfZJeAu4QSo+1yWA3rla2NGCeZGpoj13lmBJm1F/odDm+fv68phorU0l+miDlu6BFmLqbHDCWdhqVQQb/zPesW1inqxdoRqIb1SvSmBJG+wR1BF+/NkmLWUnTK1DdQq+i5gvoIbn85QPqtdRoQfU0TIgy4h/UKOi+gZ5DgGmonqIoob2CDhXHblE0ij2lgNo2YMcSy7fkhF2E2rIm/IoOFV/Q+78i1JkJheJ+jOzjnlr1GRk18swa4iC9t3U/o6LzCVLTP4dlVM14LBfC63yKIYOYeuMqcRoneZFqEW/IKAY6Q8xumla3YP2+PNnNt1Jqb6Arpifg5kXuHjNTaVi1s5/eJs0r+6gFUkxP6kkV2mKBs8UMZSYMdmAJcpxqTTGpqpcCEO1znCMTwlPFNbuF0uUs1UVwKYAWoRcwGDHsbNS/algwu+J1bvToI9TuAgZqetm1roPVk/FDazbhjaryr0SiSw/R1oFll94sWNnfsLrzS1eTkawyjKrE6HcwyeVtIix3s6Dc4ljzsTbnx74P1na83+uf8ZBn5cb0tjgsbHJjlvoMa8dxWT4XBDZmoCa3k7eH9yE0u4l9jr+dZN2P2ASnVorK8TwoVwxsglnYxNY9852oHMseogMEt+4QtnzgGDoTa8eRH4ulA4QOHCxs6ZhUBdNAIS7NIjp1+JgEaulwZzwsnXCjDDxPzB+Rwx1zS0fSoVZb/Mp4/lFqQxk5kjI1cZDWa179HTUEe8eRW9XoQZq5qeN/5fCFigWmd14VNRXLx3/et8lLC7N8XNtH0VP6mXfvV+z4iEsLFrbqqkXXho2Z8dynwgo8NdZK0SXpqxbmjrsgquhCsXrhgOYgL4h4k8Rca5VvFV7gTkySUVxrsbBjLuOGfMy1jCZFa6gv47hbeYU4ZA/XMmbRy13MFaJwqy4+Ez1cy3iSVsddfGLcdJvo33Ato5VcSeOva4WbvmQ2v+daxkrqfqXQJbNwk1fj9kOPuNwlZxdxNS7c5IW+MdRFMhd3oS/cpXmG4EOnRI8nAAt8sKsETz4AK1yahyqAy0vxvAaU7lEQcJ8yj9BPmUf+81MmR8iB//kBllOyZ2NOqR67XUAVABNjuXLlX2rCcoFjOcGoAAAAAElFTkSuQmCC'

Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end

	while ESX.GetPlayerData().job == nil do
		Citizen.Wait(10)
	end

	ESX.PlayerData = ESX.GetPlayerData()

	RefreshBussHUD()
end)

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
	ESX.PlayerData.job = job
	RefreshBussHUD()
end)

function RefreshBussHUD()
	DisableSocietyMoneyHUDElement()

	if ESX.PlayerData.job.grade_name == 'boss' then
		EnableSocietyMoneyHUDElement()

		ESX.TriggerServerCallback('esx_society:getSocietyMoney', function(money)
			UpdateSocietyMoneyHUDElement(money)
		end, ESX.PlayerData.job.name)
	end
end

RegisterNetEvent('esx_addonaccount:setMoney')
AddEventHandler('esx_addonaccount:setMoney', function(society, money)
	if ESX.PlayerData.job and ESX.PlayerData.job.grade_name == 'boss' and 'society_' .. ESX.PlayerData.job.name == society then
		UpdateSocietyMoneyHUDElement(money)
	end
end)

function EnableSocietyMoneyHUDElement()
	local societyMoneyHUDElementTpl = '<div><img src="' .. base64MoneyIcon .. '" style="width:20px; height:20px; vertical-align:middle;">&nbsp;{{money}}</div>'

	if ESX.GetConfig().EnableHud then
		ESX.UI.HUD.RegisterElement('society_money', 3, 0, societyMoneyHUDElementTpl, {
			money = 0
		})
	end

	TriggerEvent('esx_society:toggleSocietyHud', true)
end

function DisableSocietyMoneyHUDElement()
	if ESX.GetConfig().EnableHud then
		ESX.UI.HUD.RemoveElement('society_money')
	end

	TriggerEvent('esx_society:toggleSocietyHud', false)
end

function UpdateSocietyMoneyHUDElement(money)
	if ESX.GetConfig().EnableHud then
		ESX.UI.HUD.UpdateElement('society_money', {
			money = ESX.Math.GroupDigits(money)
		})
	end

	TriggerEvent('esx_society:setSocietyMoney', money)
end

function OpenBossMenu(society, close, options)
	local isBoss = nil
	local options  = options or {}
	local elements = {}

	ESX.TriggerServerCallback('esx_society:isBoss', function(result)
		isBoss = result
	end, society)

	while isBoss == nil do
		Citizen.Wait(100)
	end

	if not isBoss then
		return
	end

	local defaultOptions = {
		withdraw  = true,
		deposit   = true,
		wash      = true,
		employees = true,
		grades    = true
	}

	for k,v in pairs(defaultOptions) do
		if options[k] == nil then
			options[k] = v
		end
	end

	if options.withdraw then
		table.insert(elements, {label = _U('withdraw_society_money'), value = 'withdraw_society_money'})
	end

	if options.deposit then
		table.insert(elements, {label = _U('deposit_society_money'), value = 'deposit_money'})
	end

	if options.wash then
		table.insert(elements, {label = _U('wash_money'), value = 'wash_money'})
	end

	if options.employees then
		table.insert(elements, {label = _U('employee_management'), value = 'manage_employees'})
	end

	if options.grades then
		table.insert(elements, {label = _U('salary_management'), value = 'manage_grades'})
	end

	ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'boss_actions_' .. society, {
		title    = _U('boss_menu'),
		align    = 'top-left',
		elements = elements
	}, function(data, menu)

		if data.current.value == 'withdraw_society_money' then

			ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'withdraw_society_money_amount_' .. society, {
				title = _U('withdraw_amount')
			}, function(data, menu)

				local amount = tonumber(data.value)

				if amount == nil then
					ESX.ShowNotification(_U('invalid_amount'))
				else
					menu.close()
					TriggerServerEvent('esx_society:withdrawMoney', society, amount)
				end

			end, function(data, menu)
				menu.close()
			end)

		elseif data.current.value == 'deposit_money' then

			ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'deposit_money_amount_' .. society, {
				title = _U('deposit_amount')
			}, function(data, menu)

				local amount = tonumber(data.value)

				if amount == nil then
					ESX.ShowNotification(_U('invalid_amount'))
				else
					menu.close()
					TriggerServerEvent('esx_society:depositMoney', society, amount)
				end

			end, function(data, menu)
				menu.close()
			end)

		elseif data.current.value == 'wash_money' then

			ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'wash_money_amount_' .. society, {
				title = _U('wash_money_amount')
			}, function(data, menu)

				local amount = tonumber(data.value)

				if amount == nil then
					ESX.ShowNotification(_U('invalid_amount'))
				else
					menu.close()
					TriggerServerEvent('esx_society:washMoney', society, amount)
				end

			end, function(data, menu)
				menu.close()
			end)

		elseif data.current.value == 'manage_employees' then
			OpenManageEmployeesMenu(society)
		elseif data.current.value == 'manage_grades' then
			OpenManageGradesMenu(society)
		end

	end, function(data, menu)
		if close then
			close(data, menu)
		end
	end)

end

function OpenManageEmployeesMenu(society)

	ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'manage_employees_' .. society, {
		title    = _U('employee_management'),
		align    = 'top-left',
		elements = {
			{label = _U('employee_list'), value = 'employee_list'},
			{label = _U('recruit'),       value = 'recruit'}
		}
	}, function(data, menu)

		if data.current.value == 'employee_list' then
			OpenEmployeeList(society)
		end

		if data.current.value == 'recruit' then
			OpenRecruitMenu(society)
		end

	end, function(data, menu)
		menu.close()
	end)
end

function OpenEmployeeList(society)

	ESX.TriggerServerCallback('esx_society:getEmployees', function(employees)

		local elements = {
			head = {_U('employee'), _U('grade'), _U('actions')},
			rows = {}
		}

		for i=1, #employees, 1 do
			local gradeLabel = (employees[i].job.grade_label == '' and employees[i].job.label or employees[i].job.grade_label)

			table.insert(elements.rows, {
				data = employees[i],
				cols = {
					employees[i].name,
					gradeLabel,
					'{{' .. _U('promote') .. '|promote}} {{' .. _U('fire') .. '|fire}}'
				}
			})
		end

		ESX.UI.Menu.Open('list', GetCurrentResourceName(), 'employee_list_' .. society, elements, function(data, menu)
			local employee = data.data

			if data.value == 'promote' then
				menu.close()
				OpenPromoteMenu(society, employee)
			elseif data.value == 'fire' then
				ESX.ShowNotification(_U('you_have_fired', employee.name))

				ESX.TriggerServerCallback('esx_society:setJob', function()
					OpenEmployeeList(society)
				end, employee.identifier, 'unemployed', 0, 'fire')
			end
		end, function(data, menu)
			menu.close()
			OpenManageEmployeesMenu(society)
		end)

	end, society)

end

function OpenRecruitMenu(society)

	ESX.TriggerServerCallback('esx_society:getOnlinePlayers', function(players)

		local elements = {}

		for i=1, #players, 1 do
			if players[i].job.name ~= society then
				table.insert(elements, {
					label = players[i].name,
					value = players[i].source,
					name = players[i].name,
					identifier = players[i].identifier
				})
			end
		end

		ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'recruit_' .. society, {
			title    = _U('recruiting'),
			align    = 'top-left',
			elements = elements
		}, function(data, menu)

			ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'recruit_confirm_' .. society, {
				title    = _U('do_you_want_to_recruit', data.current.name),
				align    = 'top-left',
				elements = {
					{label = _U('no'),  value = 'no'},
					{label = _U('yes'), value = 'yes'}
				}
			}, function(data2, menu2)
				menu2.close()

				if data2.current.value == 'yes' then
					ESX.ShowNotification(_U('you_have_hired', data.current.name))

					ESX.TriggerServerCallback('esx_society:setJob', function()
						OpenRecruitMenu(society)
					end, data.current.identifier, society, 0, 'hire')
				end
			end, function(data2, menu2)
				menu2.close()
			end)

		end, function(data, menu)
			menu.close()
		end)

	end)

end

function OpenPromoteMenu(society, employee)

	ESX.TriggerServerCallback('esx_society:getJob', function(job)

		local elements = {}

		for i=1, #job.grades, 1 do
			local gradeLabel = (job.grades[i].label == '' and job.label or job.grades[i].label)

			table.insert(elements, {
				label = gradeLabel,
				value = job.grades[i].grade,
				selected = (employee.job.grade == job.grades[i].grade)
			})
		end

		ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'promote_employee_' .. society, {
			title    = _U('promote_employee', employee.name),
			align    = 'top-left',
			elements = elements
		}, function(data, menu)
			menu.close()
			ESX.ShowNotification(_U('you_have_promoted', employee.name, data.current.label))

			ESX.TriggerServerCallback('esx_society:setJob', function()
				OpenEmployeeList(society)
			end, employee.identifier, society, data.current.value, 'promote')
		end, function(data, menu)
			menu.close()
			OpenEmployeeList(society)
		end)

	end, society)

end

function OpenManageGradesMenu(society)

	ESX.TriggerServerCallback('esx_society:getJob', function(job)

		local elements = {}

		for i=1, #job.grades, 1 do
			local gradeLabel = (job.grades[i].label == '' and job.label or job.grades[i].label)

			table.insert(elements, {
				label = ('%s - <span style="color:green;">%s</span>'):format(gradeLabel, _U('money_generic', ESX.Math.GroupDigits(job.grades[i].salary))),
				value = job.grades[i].grade
			})
		end

		ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'manage_grades_' .. society, {
			title    = _U('salary_management'),
			align    = 'top-left',
			elements = elements
		}, function(data, menu)

			ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'manage_grades_amount_' .. society, {
				title = _U('salary_amount')
			}, function(data2, menu2)

				local amount = tonumber(data2.value)

				if amount == nil then
					ESX.ShowNotification(_U('invalid_amount'))
				elseif amount > Config.MaxSalary then
					ESX.ShowNotification(_U('invalid_amount_max'))
				else
					menu2.close()

					ESX.TriggerServerCallback('esx_society:setJobSalary', function()
						OpenManageGradesMenu(society)
					end, society, data.current.value, amount)
				end

			end, function(data2, menu2)
				menu2.close()
			end)

		end, function(data, menu)
			menu.close()
		end)

	end, society)

end

AddEventHandler('esx_society:openBossMenu', function(society, close, options)
	OpenBossMenu(society, close, options)
end)
