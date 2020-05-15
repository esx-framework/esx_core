local voice = {default = 5.0, shout = 12.0, whisper = 1.0, current = 0, level = nil}

function drawLevel(r, g, b, a)
	SetTextFont(4)
	SetTextScale(0.5, 0.5)
	SetTextColour(r, g, b, a)
	SetTextDropshadow(0, 0, 0, 0, 255)
	SetTextDropShadow()
	SetTextOutline()

	BeginTextCommandDisplayText('STRING')
	AddTextComponentSubstringPlayerName(_U('voice', voice.level))
	EndTextCommandDisplayText(0.175, 0.92)
end

AddEventHandler('onClientMapStart', function()
	if voice.current == 0 then
		NetworkSetTalkerProximity(voice.default)
	elseif voice.current == 1 then
		NetworkSetTalkerProximity(voice.shout)
	elseif voice.current == 2 then
		NetworkSetTalkerProximity(voice.whisper)
	end
end)

AddEventHandler('esx:loadingScreenOff', function()
	Citizen.CreateThread(function()
		while true do
			Citizen.Wait(1)

			if IsControlJustPressed(1, 74) and IsControlPressed(1, 21) then
				voice.current = (voice.current + 1) % 3
				if voice.current == 0 then
					NetworkSetTalkerProximity(voice.default)
					voice.level = _U('normal')
				elseif voice.current == 1 then
					NetworkSetTalkerProximity(voice.shout)
					voice.level = _U('shout')
				elseif voice.current == 2 then
					NetworkSetTalkerProximity(voice.whisper)
					voice.level = _U('whisper')
				end
			end

			if voice.current == 0 then
				voice.level = _U('normal')
			elseif voice.current == 1 then
				voice.level = _U('shout')
			elseif voice.current == 2 then
				voice.level = _U('whisper')
			end

			if NetworkIsPlayerTalking(PlayerId()) then
				drawLevel(41, 128, 185, 255)
			else
				drawLevel(185, 185, 185, 255)
			end
		end
	end)
end)
