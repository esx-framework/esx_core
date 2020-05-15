local self = ESX.Modules['society']

self.Init()

TriggerEvent('cron:runAt', 3, 0, self.WashMoneyCRON)
