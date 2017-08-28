# fxserver-esx_jobs
[REQUIRES]
- fxserver-esx_addonaccount: https://github.com/FXServer-ESX/fxserver-esx_addonaccount

[FEATURES]
- Jobs: Slaughterer, Miner, Fisherman, Journalist, etc...
- Security deposit when renting a job vehicle (given back in case of crash, to the amount of damage the vehicle has already taken)
- Easy system to create jobs (samples in jobs folder)
- Item farming jobs
- On Duty system

This addon is an easy way to have farming jobs on your server. 
There is no player management. 
Just take example on the files in the jobs folder.

[INSTALLATION]
1. CD in your resources/[esx] folder
2. Clone the repository
 ```
 git clone https://github.com/FXServer-ESX/fxserver-esx_jobs esx_jobs
 ```
3. Import esx_jobs.sql into your database
4. Add this into your server.cfg
```
start esx_jobs
```
