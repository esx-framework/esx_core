Config = {}

---@class MedalClipOptions
---@field duration integer
---@field captureDelayMs integer
---@field alertType 'Default'|'Disabled'|'SoundOnly'|'OverlayOnly'

---@class MedalConfig
---@field enabled boolean
---@field publicKey string
---@field eventName string
---@field clipOptions MedalClipOptions

---@type MedalConfig
Config.Medal = {
	enabled = true,
	publicKey = 'pub_82qkpMKV77AkpqLSgWsxLlDyfzpPI7Vw',
	eventName = 'Death',
	clipOptions = {
		duration = 30,
		captureDelayMs = 0,
		alertType = 'Default'
	}
}