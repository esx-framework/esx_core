ESX.Blip.CreateBlip = function(coords, text, sprite, color, scale, display)
	local blip = AddBlipForCoord( table.unpack(coords) )

	SetBlipSprite(blip, sprite)

	if display then
		SetBlipDisplay(blip, display)
	end

	if scale then
		SetBlipScale(blip, scale)
	end

	if color then
		SetBlipColour(blip, color)
	end

	SetBlipAsShortRange(blip, true)

	BeginTextCommandSetBlipName('STRING')
	AddTextComponentSubstringPlayerName(text)
	EndTextCommandSetBlipName(blip)

	return blip
end