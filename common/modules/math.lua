ESX.Math = {}

ESX.Math.Round = function(value, numDecimalPlaces)
	local mult = 10^(numDecimalPlaces or 0)
	return math.floor(value * mult + 0.5) / mult
end

-- credit http://richard.warburton.it
ESX.Math.GroupDigits = function(value)
	local left,num,right = string.match(value,'^([^%d]*%d)(%d*)(.-)$')

	return left..(num:reverse():gsub('(%d%d%d)','%1' .. _U('locale_digit_grouping_symbol')):reverse())..right
end

ESX.Math.Trim = function(value)
	if value then
		return (string.gsub(value, "^%s*(.-)%s*$", "%1"))
	else
		return nil
	end
end