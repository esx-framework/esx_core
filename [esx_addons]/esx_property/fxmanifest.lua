--[[
    ESX Property - Properties Made Right!
    Copyright (C) 2022 ESX-Framework

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
]] 
fx_version 'adamant'

game 'gta5'
lua54 'yes'

author 'ESX-Framework'
description 'Official ESX-Legacy Property System'
version '1.9.0'

shared_scripts {'@es_extended/imports.lua', '@es_extended/locale.lua', 'locales/*.lua'}
file "client/html/copy.html"
ui_page "client/html/copy.html"

server_scripts {
	'@oxmysql/lib/MySQL.lua',
	'config.lua',
	'server/*.lua'
}

client_scripts {
	'config.lua',
	'client/cctv.lua',
	'client/main.lua',
	'client/furniture.lua'
}

dependencies {
	'es_extended'
}
