ESX.Scaleform.ShowFreemodeMessage = function(title, msg, sec)
	local scaleform = ESX.Scaleform.Utils.RequestScaleformMovie('MP_BIG_MESSAGE_FREEMODE')

	BeginScaleformMovieMethod(scaleform, 'SHOW_SHARD_WASTED_MP_MESSAGE')
	PushScaleformMovieMethodParameterString(title)
	PushScaleformMovieMethodParameterString(msg)
	EndScaleformMovieMethod()

	while sec > 0 do
		Wait(1)
		sec = sec - 0.01

		DrawScaleformMovieFullscreen(scaleform, 255, 255, 255, 255)
	end

	SetScaleformMovieAsNoLongerNeeded(scaleform)
end

ESX.Scaleform.ShowBreakingNews = function(title, msg, bottom, sec)
	local scaleform = ESX.Scaleform.Utils.RequestScaleformMovie('BREAKING_NEWS')

	BeginScaleformMovieMethod(scaleform, 'SET_TEXT')
	PushScaleformMovieMethodParameterString(msg)
	PushScaleformMovieMethodParameterString(bottom)
	EndScaleformMovieMethod()

	BeginScaleformMovieMethod(scaleform, 'SET_SCROLL_TEXT')
	PushScaleformMovieMethodParameterInt(0) -- top ticker
	PushScaleformMovieMethodParameterInt(0) -- Since this is the first string, start at 0
	PushScaleformMovieMethodParameterString(title)

	EndScaleformMovieMethod()

	BeginScaleformMovieMethod(scaleform, 'DISPLAY_SCROLL_TEXT')
	PushScaleformMovieMethodParameterInt(0) -- Top ticker
	PushScaleformMovieMethodParameterInt(0) -- Index of string

	EndScaleformMovieMethod()

	while sec > 0 do
		Wait(1)
		sec = sec - 0.01

		DrawScaleformMovieFullscreen(scaleform, 255, 255, 255, 255)
	end

	SetScaleformMovieAsNoLongerNeeded(scaleform)
end

ESX.Scaleform.ShowPopupWarning = function(title, msg, bottom, sec)
	local scaleform = ESX.Scaleform.Utils.RequestScaleformMovie('POPUP_WARNING')

	BeginScaleformMovieMethod(scaleform, 'SHOW_POPUP_WARNING')

	PushScaleformMovieMethodParameterFloat(500.0) -- black background
	PushScaleformMovieMethodParameterString(title)
	PushScaleformMovieMethodParameterString(msg)
	PushScaleformMovieMethodParameterString(bottom)
	PushScaleformMovieMethodParameterBool(true)

	EndScaleformMovieMethod()

	while sec > 0 do
		Wait(1)
		sec = sec - 0.01

		DrawScaleformMovieFullscreen(scaleform, 255, 255, 255, 255)
	end

	SetScaleformMovieAsNoLongerNeeded(scaleform)
end

ESX.Scaleform.ShowTrafficMovie = function(sec)
	local scaleform = ESX.Scaleform.Utils.RequestScaleformMovie('TRAFFIC_CAM')

	BeginScaleformMovieMethod(scaleform, 'PLAY_CAM_MOVIE')

	EndScaleformMovieMethod()

	while sec > 0 do
		Wait(1)
		sec = sec - 0.01

		DrawScaleformMovieFullscreen(scaleform, 255, 255, 255, 255)
	end

	SetScaleformMovieAsNoLongerNeeded(scaleform)
end

ESX.Scaleform.Utils.RequestScaleformMovie = function(movie)
	local scaleform = RequestScaleformMovie(movie)

	while not HasScaleformMovieLoaded(scaleform) do
		Wait(0)
	end

	return scaleform
end
