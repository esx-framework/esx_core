local runners = {}

function runners.lua(arg)
	local code, err = load('return ' .. arg, '@runcode')

	-- if failed, try without return
	if err then
		code, err = load(arg, '@runcode')
	end

	if err then
		print(err)
		return nil, err
	end

	local status, result = pcall(code)
	print(result)

	if status then
		return result
	end

	return nil, result
end

function runners.js(arg)
	return table.unpack(exports[GetCurrentResourceName()]:runJS(arg))
end

function RunCode(lang, str)
	return runners[lang](str)
end