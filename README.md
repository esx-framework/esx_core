# skinchanger

## Download & Installation

### Using [fvm](https://github.com/qlaffont/fvm-installer)
```
fvm install --save esx-org/skinchanger
```

### Using Git
```
cd resources
git clone https://github.com/ESX-Org/skinchanger skinchanger
```

### Manually
- Download https://github.com/ESX-Org/skinchanger/archive/master.zip

## Installation
- Add this to your `server.cfg`:

```
start skinchanger
```

### Usage

```lua
local isMale = true

local skin = {
	sex          = 1,
	face         = 0,
	skin         = 0,
	beard_1      = 0,
	beard_2      = 0,
	beard_3      = 0,
	beard_4      = 0,
	hair_1       = 0,
	hair_2       = 0,
	hair_color_1 = 0,
	hair_color_2 = 0,
	tshirt_1     = 0,
	tshirt_2     = 0,
	torso_1      = 0,
	torso_2      = 0,
	decals_1     = 0,
	decals_2     = 0,
	arms         = 0,
	pants_1      = 0,
	pants_2      = 0,
	shoes_1      = 0,
	shoes_2      = 0,
	mask_1       = 0,
	mask_2       = 0,
	bproof_1     = 0,
	bproof_2     = 0,
	chain_1      = 0,
	chain_2      = 0,
	helmet_1     = 0,
	helmet_2     = 0,
	glasses_1    = 0,
	glasses_2    = 0,
}

-- Load freemode model
TriggerEvent('skinchanger:loadDefaultModel', isMale)

-- Load skin
TriggerEvent('skinchanger:loadSkin', skin)

-- you can also load only some components :
TriggerEvent('skinchanger:loadSkin', {
	sex          = 0,
	beard_1      = 0,
	beard_2      = 0,
})

-- Get list of components and maxVals
TriggerEvent('skinchanger:getData', function(components, maxVals)
	print('Components => ' .. json.encode(components))
	print('MaxVals => ' .. json.encode(maxVals))
end)

-- Get current skin
TriggerEvent('skinchanger:getSkin', function(skin)
	print(json.encode(skin))
end)
```

# Legal
### License
skinchanger - make your own skin!

Copyright (C) 2015-2018 Jérémie N'gadi

This program Is free software: you can redistribute it And/Or modify it under the terms Of the GNU General Public License As published by the Free Software Foundation, either version 3 Of the License, Or (at your option) any later version.

This program Is distributed In the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty Of MERCHANTABILITY Or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License For more details.

You should have received a copy Of the GNU General Public License along with this program. If Not, see http://www.gnu.org/licenses/.
