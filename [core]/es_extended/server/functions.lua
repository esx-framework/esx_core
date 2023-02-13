function ESX.RegisterServerCallback(name, cb)
  Core.ServerCallbacks[name] = cb
end

function ESX.TriggerServerCallback(name, requestId, source, Invoke, cb, ...)
  if Core.ServerCallbacks[name] then
    Core.ServerCallbacks[name](source, cb, ...)
  else
    print(('[^1ERROR^7] Server callback ^5"%s"^0 does not exist. Please Check ^5%s^7 for Errors!'):format(name, Invoke))
  end
end

function ESX.DiscordLog(name, title, color, message)
  local webHook = Config.DiscordLogs.Webhooks[name] or Config.DiscordLogs.Webhooks.default
  local embedData = { {
    ['title'] = title,
    ['color'] = Config.DiscordLogs.Colors[color] or Config.DiscordLogs.Colors.default,
    ['footer'] = {
      ['text'] = "| ESX Logs | " .. os.date(),
      ['icon_url'] = "https://cdn.discordapp.com/attachments/944789399852417096/1020099828266586193/blanc-800x800.png"
    },
    ['description'] = message,
    ['author'] = {
      ['name'] = "ESX Framework",
      ['icon_url'] = "https://cdn.discordapp.com/emojis/939245183621558362.webp?size=128&quality=lossless"
    }
  } }
  PerformHttpRequest(webHook, nil, 'POST', json.encode({
    username = 'Logs',
    embeds = embedData
  }), {
    ['Content-Type'] = 'application/json'
  })
end

function ESX.DiscordLogFields(name, title, color, fields)
  local webHook = Config.DiscordLogs.Webhooks[name] or Config.DiscordLogs.Webhooks.default
  local embedData = { {
    ['title'] = title,
    ['color'] = Config.DiscordLogs.Colors[color] or Config.DiscordLogs.Colors.default,
    ['footer'] = {
      ['text'] = "| ESX Logs | " .. os.date(),
      ['icon_url'] = "https://cdn.discordapp.com/attachments/944789399852417096/1020099828266586193/blanc-800x800.png"
    },
    ['fields'] = fields,
    ['description'] = "",
    ['author'] = {
      ['name'] = "ESX Framework",
      ['icon_url'] = "https://cdn.discordapp.com/emojis/939245183621558362.webp?size=128&quality=lossless"
    }
  } }
  PerformHttpRequest(webHook, nil, 'POST', json.encode({
    username = 'Logs',
    embeds = embedData
  }), {
    ['Content-Type'] = 'application/json'
  })
end