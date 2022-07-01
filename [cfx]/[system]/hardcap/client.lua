Citizen.CreateThread(function()
	while true do
		Wait(0)

		if NetworkIsSessionStarted() then
			TriggerServerEvent('hardcap:playerActivated')

			return
		end
	end
end)