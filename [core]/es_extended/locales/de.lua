Locales['de'] = {
    -- Inventory
    ['inventory'] = 'Inventar %s / %s',
    ['use'] = 'benutzen',
    ['give'] = 'geben',
    ['remove'] = 'entfernen',
    ['return'] = 'zurück',
    ['give_to'] = 'geben an',
    ['amount'] = 'Betrag',
    ['giveammo'] = 'Munition geben',
    ['amountammo'] = 'Anzahl der Munition',
    ['noammo'] = 'du hast keine Munition!',
    ['gave_item'] = 'du gibst %sx %s an %s',
    ['received_item'] = 'du empfängst %sx %s von %s',
    ['gave_weapon'] = 'du gibst %s an %s',
    ['gave_weapon_ammo'] = 'du gibst ~o~%sx %s von %s an %s',
    ['gave_weapon_withammo'] = 'du gibst %s mit ~o~%sx %s an %s',
    ['gave_weapon_hasalready'] = '%s hat bereits eine(n) %s',
    ['gave_weapon_noweapon'] = '%s hat diese Waffe nicht',
    ['received_weapon'] = 'du erhälst %s von %s',
    ['received_weapon_ammo'] = 'du erhälst %sx %s für dein %s von %s',
    ['received_weapon_withammo'] = 'du erhälst %s mit %sx %s von %s',
    ['received_weapon_hasalready'] = '%s hat versucht dir eine(n) %s zu geben, aber du hast bereits eine(n)',
    ['received_weapon_noweapon'] = '%s hat versucht dir Munition für eine(n) %s, aber du besitzt diese Waffe nicht',
    ['gave_account_money'] = 'du gibst $%s (%s) an %s',
    ['received_account_money'] = 'du empfängst $%s (%s) von %s',
    ['amount_invalid'] = 'ungültiger Betrag',
    ['players_nearby'] = 'keine Spieler in der Nähe',
    ['ex_inv_lim'] = 'Aktion nicht möglich, Inventarlimit überschritten für %s',
    ['imp_invalid_quantity'] = 'Aktion nicht möglich, ungültige Anzahl',
    ['imp_invalid_amount'] = 'Aktion nicht möglich, ungültiger Betrag',
    ['threw_standard'] = 'du wirfst %sx %s',
    ['threw_account'] = 'du wirfst $%s %s weg',
    ['threw_weapon'] = 'du wirfst %s weg',
    ['threw_weapon_ammo'] = 'du wirfst %s mit %sx %s weg',
    ['threw_weapon_already'] = 'Du hast bereits diese Waffe',
    ['threw_cannot_pickup'] = 'Du kannst das nicht aufheben, da dein Inventar voll ist',
    ['threw_pickup_prompt'] = 'drücke E um aufzuheben',

    -- Key mapping
    ['keymap_showinventory'] = 'Inventar anzeigen',

    -- Salary related
    ['received_salary'] = 'du hast dein Gehalt erhalten: $%s',
    ['received_help'] = 'du hast deine Sozialhilfe erhalten: $%s',
    ['company_nomoney'] = 'die Firma in der du angestellt bist, ist zu arm um dir dein Gehalt zu zahlen',
    ['received_paycheck'] = 'erhaltener Gehaltsscheck',
    ['bank'] = 'Bank',
    ['account_bank'] = 'Bank',
    ['account_black_money'] = 'Schwarzgeld',
    ['account_money'] = 'Geld',

    ['act_imp'] = 'Aktion nicht möglich',
    ['in_vehicle'] = 'du kannst keine Items in einem Fahrzeug weitergeben',

    -- Commands
    ['command_car'] = 'Fahrzeug spawnen',
    ['command_car_car'] = 'Fahrzeug spawnname oder hash',
    ['command_cardel'] = 'Fahrzeuge in der nähe löschen',
    ['command_cardel_radius'] = 'Optional, jedes Fahrzeug innerhalb des angegebenen Radius löschen',
    ['command_clear'] = 'Chat leeren',
    ['command_clearall'] = 'Chat leeren für alle spieler',
    ['command_clearinventory'] = 'Spielerinventar leeren',
    ['command_clearloadout'] = 'Spielerausstattung löschen',
    ['command_giveaccountmoney'] = 'Geld aufs Konto laden',
    ['command_giveaccountmoney_account'] = 'gültiger Kontoname',
    ['command_giveaccountmoney_amount'] = 'Anzahl zum hinzufügen',
    ['command_giveaccountmoney_invalid'] = 'Ungültiger Kontoname',
    ['command_giveitem'] = 'Item an Spieler geben',
    ['command_giveitem_item'] = 'Itemname',
    ['command_giveitem_count'] = 'item Anzahl',
    ['command_giveweapon'] = 'Spieler eine Waffe geben',
    ['command_giveweapon_weapon'] = 'Waffenname',
    ['command_giveweapon_ammo'] = 'Munitionsanzahl',
    ['command_giveweapon_hasalready'] = 'Spieler bereits im Besitz dieser Waffe',
    ['command_giveweaponcomponent'] = 'Spieler Waffenaufsatz geben',
    ['command_giveweaponcomponent_component'] = 'Waffenaufsatz Name',
    ['command_giveweaponcomponent_invalid'] = 'ungültiger Waffenaufsatz',
    ['command_giveweaponcomponent_hasalready'] = 'Spieler hat bereits diesen Waffenaufsatz',
    ['command_giveweaponcomponent_missingweapon'] = 'Der Spieler besitzt diese Waffe nicht',
    ['command_save'] = 'Spieler in der Datenbank sichern',
    ['command_saveall'] = 'Sichern von allen Spielern auf der Datenbank',
    ['command_setaccountmoney'] = 'Kontosumme des Spielers setzen',
    ['command_setaccountmoney_amount'] = 'Summe',
    ['command_setcoords'] = 'Zu den Koordinaten Teleportieren',
    ['command_setcoords_x'] = 'x Position',
    ['command_setcoords_y'] = 'y Position',
    ['command_setcoords_z'] = 'z Position',
    ['command_setjob'] = 'Dem Spieler einen Job setzen',
    ['command_setjob_job'] = 'Name des Jobs',
    ['command_setjob_grade'] = 'Rang des Jobs',
    ['command_setjob_invalid'] = 'Der Rang oder der Job ist nicht gültigt.',
    ['command_setgroup'] = 'Spielergruppe setzen',
    ['command_setgroup_group'] = 'Gruppenname',
    ['commanderror_argumentmismatch'] = 'Die Anzahl der Argumente stimmen nicht überein (übergeben %s, gesucht %s)',
    ['commanderror_argumentmismatch_number'] = 'argument #%s typ stimmt nicht überein (übergeben string, gewünscht zahl)',
    ['commanderror_invaliditem'] = 'falscher Itemname',
    ['commanderror_invalidweapon'] = 'ungültige Waffe',
    ['commanderror_console'] = 'Der Befehl kann nicht in der Konsole genutzt werden',
    ['commanderror_invalidcommand'] = '/%s ist kein verfügbarer Befehl!',
    ['commanderror_invalidplayerid'] = 'Kein Spieler mit dieser ID scheint online zu sein',
    ['commandgeneric_playerid'] = 'Spieler ID',
    ['command_giveammo_noweapon_found'] = '%s besitzt diese Waffe nicht',
    ['command_giveammo_weapon'] = 'Waffenname',
    ['command_giveammo_ammo'] = 'Munitionsanzahl',

    -- Locale settings
    ['locale_digit_grouping_symbol'] = ' ',
    ['locale_currency'] = '$%s',

    -- Weapons
    ['weapon_knife'] = 'Messer',
    ['weapon_nightstick'] = 'Schlagstock',
    ['weapon_hammer'] = 'Hammer',
    ['weapon_bat'] = 'Schläger',
    ['weapon_golfclub'] = 'Golfschläger',
    ['weapon_crowbar'] = 'Brecheisen',
    ['weapon_pistol'] = 'Pistole',
    ['weapon_combatpistol'] = 'Kampfpistole',
    ['weapon_appistol'] = 'AP Pistole',
    ['weapon_pistol50'] = 'Pistole .50',
    ['weapon_microsmg'] = 'Mikro SMG',
    ['weapon_smg'] = 'SMG',
    ['weapon_assaultsmg'] = 'Kampf SMG',
    ['weapon_assaultrifle'] = 'Kampfgewehr',
    ['weapon_carbinerifle'] = 'Karabinergewehr',
    ['weapon_advancedrifle'] = 'Advancedgewehr',
    ['weapon_mg'] = 'MG',
    ['weapon_combatmg'] = 'Kampf MG',
    ['weapon_pumpshotgun'] = 'Pumpgun',
    ['weapon_sawnoffshotgun'] = 'Abgesägte Schrotflinte',
    ['weapon_assaultshotgun'] = 'Kampf Schrotflinte',
    ['weapon_bullpupshotgun'] = 'Bullpup Schrotflinte',
    ['weapon_stungun'] = 'Tazer',
    ['weapon_sniperrifle'] = 'Scharfschützengewehr',
    ['weapon_heavysniper'] = 'Schweres Sniper',
    ['weapon_grenadelauncher'] = 'Granatwerfer',
    ['weapon_rpg'] = 'RPG',
    ['weapon_minigun'] = 'Minigun',
    ['weapon_grenade'] = 'Granate',
    ['weapon_stickybomb'] = 'Haftbombe',
    ['weapon_smokegrenade'] = 'Rauchgranate',
    ['weapon_bzgas'] = 'BZ Gas',
    ['weapon_molotov'] = 'Molotov Cocktail',
    ['weapon_fireextinguisher'] = 'Feuerlöscher',
    ['weapon_petrolcan'] = 'Benzinkanister',
    ['weapon_ball'] = 'Ball',
    ['weapon_snspistol'] = 'SNS Pistole',
    ['weapon_bottle'] = 'Flasche',
    ['weapon_gusenberg'] = 'Gusenberg',
    ['weapon_specialcarbine'] = 'Spezialkarabiner',
    ['weapon_heavypistol'] = 'Schwere Pistole',
    ['weapon_bullpuprifle'] = 'Bullpupgewehr',
    ['weapon_dagger'] = 'Dolch',
    ['weapon_vintagepistol'] = 'Vintage Pistole',
    ['weapon_firework'] = 'Feuerwerk',
    ['weapon_musket'] = 'Muskete',
    ['weapon_heavyshotgun'] = 'Schwere Schrotflinte',
    ['weapon_marksmanrifle'] = 'Marksmangewehr',
    ['weapon_hominglauncher'] = 'Homing Launcher',
    ['weapon_proxmine'] = 'Annäherungsmine',
    ['weapon_snowball'] = 'Schneeball',
    ['weapon_flaregun'] = 'Leuchtpistole',
    ['weapon_combatpdw'] = 'Kampf PDW',
    ['weapon_marksmanpistol'] = 'Marksman Pistole',
    ['weapon_knuckle'] = 'Schlagring',
    ['weapon_hatchet'] = 'Axt',
    ['weapon_railgun'] = 'Railgun',
    ['weapon_machete'] = 'Machete',
    ['weapon_machinepistol'] = 'Maschinenpistole',
    ['weapon_switchblade'] = 'Klappmesser',
    ['weapon_revolver'] = 'Schwerer Revolver',
    ['weapon_dbshotgun'] = 'Doppelläufige Schrotflinte',
    ['weapon_compactrifle'] = 'Kampfgewehr',
    ['weapon_autoshotgun'] = 'Auto Schrotflinte',
    ['weapon_battleaxe'] = 'Kampfaxt',
    ['weapon_compactlauncher'] = 'Kompakt Granatwerfer',
    ['weapon_minismg'] = 'Mini SMG',
    ['weapon_pipebomb'] = 'Rohrbombe',
    ['weapon_poolcue'] = 'Billiard-Kö',
    ['weapon_wrench'] = 'Rohrzange',
    ['weapon_flashlight'] = 'Taschenlampe',
    ['gadget_parachute'] = 'Fallschirm',
    ['weapon_flare'] = 'Leuchtpistole',
    ['weapon_doubleaction'] = 'double-Action Revolver',

    -- Weapon Components
    ['component_clip_default'] = 'standart Magazin',
    ['component_clip_extended'] = 'erweiterters Magazin',
    ['component_clip_drum'] = 'Trommelmagazin',
    ['component_clip_box'] = 'Kastenmagazin',
    ['component_flashlight'] = 'Taschenlampe',
    ['component_scope'] = 'Zielfernrohr',
    ['component_scope_advanced'] = 'erweitertes Zielfernrohr',
    ['component_suppressor'] = 'Schalldämpfer',
    ['component_grip'] = 'Griff',
    ['component_luxary_finish'] = 'luxus Waffendesign',

    -- Weapon Ammo
    ['ammo_rounds'] = 'Kugel(n)',
    ['ammo_shells'] = 'Schrotpatrone(n)',
    ['ammo_charge'] = 'Ladung',
    ['ammo_petrol'] = 'Benzinkanister',
    ['ammo_firework'] = 'Feuerwerksrakete(n)',
    ['ammo_rockets'] = 'Rakete(n)',
    ['ammo_grenadelauncher'] = 'Granate(n)',
    ['ammo_grenade'] = 'Granate(n)',
    ['ammo_stickybomb'] = 'C4(s)',
    ['ammo_pipebomb'] = 'Rohrbombe(n)',
    ['ammo_smokebomb'] = 'Rauchgranate(n)',
    ['ammo_molotov'] = 'Molotovcocktail(s)',
    ['ammo_proxmine'] = 'Annäherungsmine(n)',
    ['ammo_bzgas'] = 'Bzgas',
    ['ammo_ball'] = 'Ball',
    ['ammo_snowball'] = 'Schneebälle',
    ['ammo_flare'] = 'Signalfackel(n)',
    ['ammo_flaregun'] = 'Signalfackeln(munition)',

    -- Weapon Tints
    ['tint_default'] = 'standard',
    ['tint_green'] = 'grün',
    ['tint_gold'] = 'gold',
    ['tint_pink'] = 'pink',
    ['tint_army'] = 'camouflage',
    ['tint_lspd'] = 'blau',
    ['tint_orange'] = 'orange',
    ['tint_platinum'] = 'platin',
}
