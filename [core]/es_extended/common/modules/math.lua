ESX.Math = {}

function ESX.Math.Round(value, numDecimalPlaces)
	if not numDecimalPlaces then return math.floor(value + 0.5) end

	local power = 10 ^ numDecimalPlaces
	return math.floor((value * power) + 0.5) / (power)
end

-- credit http://richard.warburton.it
function ESX.Math.GroupDigits(value)
	local left, num, right = string.match(value, '^([^%d]*%d)(%d*)(.-)$')
	return left .. (num:reverse():gsub('(%d%d%d)', '%1' .. TranslateCap('locale_digit_grouping_symbol')):reverse()) .. right
end

function ESX.Math.Trim(value)
	if not value then return nil end
	return (string.gsub(value, "^%s*(.-)%s*$", "%1"))
end