# fxserver-cron
FXServer CRON

# fxserver-esx_addonaccount
ESX AddonAccount

[INSTALLATION]

1) CD in your resources folder
2) Clone the repository
```
git clone https://github.com/FXServer-ESX/fxserver-cron cron
```
3) Add this in your server.cfg :

```
start cron
```

[USAGE]

```

-- Execute task every 5:10
function CronTask(d, h, m)
  print('Task done')
end

TriggerEvent('cron:runAt', 5, 10, CronTask)

-- Execute task every monday at 18:30
function CronTask(d, h, m)
  if d == 1 then
    print('Task done')
  end
end

TriggerEvent('cron:runAt', 18, 30, CronTask)

```
