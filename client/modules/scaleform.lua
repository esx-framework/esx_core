ESX.Scaleform.ShowFreemodeMessage = function(title, msg, sec)
	local scaleform = ESX.Scaleform.Utils.RequestScaleformMovie('MP_BIG_MESSAGE_FREEMODE')

	PushScaleformMovieFunction(scaleform, 'SHOW_SHARD_WASTED_MP_MESSAGE')
	PushScaleformMovieFunctionParameterString(title)
	PushScaleformMovieFunctionParameterString(msg)
	PopScaleformMovieFunctionVoid()

	while sec > 0 do
		Citizen.Wait(1)
		sec = sec - 0.01

		DrawScaleformMovieFullscreen(scaleform, 255, 255, 255, 255)
	end

	SetScaleformMovieAsNoLongerNeeded(scaleform)
end

ESX.Scaleform.ShowBreakingNews = function(title, msg, bottom, sec)
	local scaleform = ESX.Scaleform.Utils.RequestScaleformMovie('BREAKING_NEWS')

	PushScaleformMovieFunction(scaleform, 'SET_TEXT')
	PushScaleformMovieFunctionParameterString(msg)
	PushScaleformMovieFunctionParameterString(bottom)
	PopScaleformMovieFunctionVoid()

	PushScaleformMovieFunction(scaleform, 'SET_SCROLL_TEXT')
	PushScaleformMovieFunctionParameterInt(0) -- top ticker
	PushScaleformMovieFunctionParameterInt(0) -- Since this is the first string, start at 0
	PushScaleformMovieFunctionParameterString(title)
	PopScaleformMovieFunctionVoid()

	PushScaleformMovieFunction(scaleform, 'DISPLAY_SCROLL_TEXT')
	PushScaleformMovieFunctionParameterInt(0) -- Top ticker
	PushScaleformMovieFunctionParameterInt(0) -- Index of string
	PopScaleformMovieFunctionVoid()

	while sec > 0 do
		Citizen.Wait(1)
		sec = sec - 0.01

		DrawScaleformMovieFullscreen(scaleform, 255, 255, 255, 255)
	end

	SetScaleformMovieAsNoLongerNeeded(scaleform)
end

ESX.Scaleform.ShowPopupWarning = function(title, msg, bottom, sec)
	local scaleform = ESX.Scaleform.Utils.RequestScaleformMovie('POPUP_WARNING')

	PushScaleformMovieFunction(scaleform, 'SHOW_POPUP_WARNING')
	PushScaleformMovieFunctionParameterFloat(500.0) -- black background
	PushScaleformMovieFunctionParameterString(title)
	PushScaleformMovieFunctionParameterString(msg)
	PushScaleformMovieFunctionParameterString(bottom)
	PushScaleformMovieFunctionParameterBool(true)
	PopScaleformMovieFunctionVoid()

	while sec > 0 do
		Citizen.Wait(1)
		sec = sec - 0.01

		DrawScaleformMovieFullscreen(scaleform, 255, 255, 255, 255)
	end

	SetScaleformMovieAsNoLongerNeeded(scaleform)
end

ESX.Scaleform.ShowTrafficMovie = function(sec)
	local scaleform = ESX.Scaleform.Utils.RequestScaleformMovie('TRAFFIC_CAM')

	PushScaleformMovieFunction(scaleform, 'PLAY_CAM_MOVIE')
	PopScaleformMovieFunctionVoid()

	while sec > 0 do
		Citizen.Wait(1)
		sec = sec - 0.01

		DrawScaleformMovieFullscreen(scaleform, 255, 255, 255, 255)
	end

	SetScaleformMovieAsNoLongerNeeded(scaleform)
end

ESX.Scaleform.Utils.RequestScaleformMovie = function(movie)
	local scaleform = RequestScaleformMovie(movie)

	while not HasScaleformMovieLoaded(scaleform) do
		Citizen.Wait(0)
	end

	return scaleform
end