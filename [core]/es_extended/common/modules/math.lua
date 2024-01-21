ESX.Math = {}

function ESX.Math.Round(value, numDecimalPlaces)
	if numDecimalPlaces then
		local power = 10 ^ numDecimalPlaces
		return math.floor((value * power) + 0.5) / (power)
	else
		return math.floor(value + 0.5)
	end
end

-- credit http://richard.warburton.it
function ESX.Math.GroupDigits(value)
	local left, num, right = string.match(value, '^([^%d]*%d)(%d*)(.-)$')

	return left .. (num:reverse():gsub('(%d%d%d)', '%1' .. TranslateCap('locale_digit_grouping_symbol')):reverse()) .. right
end

function ESX.Math.Trim(value)
	if value then
		return (string.gsub(value, "^%s*(.-)%s*$", "%1"))
	else
		return nil
	end
end
