# esx_jobs
### Requirements
- [esx_addonaccount](https://github.com/ESX-Org/esx_addonaccount)
- [esx_skin](https://github.com/ESX-Org/esx_skin)

### Features
- Jobs: slaughterer, miner, fisherman, journalist, fueler, tailor
- Security deposit when renting a job vehicle (given back in case of crash, to the amount of damage the vehicle has already taken)
- Easy system to create jobs (samples in jobs folder)
- Item farming jobs
This addon is an easy way to have farming jobs on your server, there is no player management.

### Installation
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
