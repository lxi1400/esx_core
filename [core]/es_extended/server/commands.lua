ESX.RegisterCommand('setcoords', 'admin', function(xPlayer, args, _)
	xPlayer.setCoords({x = args.x, y = args.y, z = args.z})
	if Config.AdminLogging then
		ESX.DiscordLogFields("UserActions", "Set Coordinates /setcoords Triggered!", "pink", {
			{name = "Player", value = xPlayer.name, inline = true},
			{name = "ID", value = xPlayer.source, inline = true},
			{name = "X Coord", value = args.x, inline = true},
			{name = "Y Coord", value = args.y, inline = true},
			{name = "Z Coord", value = args.z, inline = true},
		})
	end
end, false, {help = TranslateCap('command_setcoords'), validate = true, arguments = {
	{name = 'x', help = TranslateCap('command_setcoords_x'), type = 'number'},
	{name = 'y', help = TranslateCap('command_setcoords_y'), type = 'number'},
	{name = 'z', help = TranslateCap('command_setcoords_z'), type = 'number'}
}})

ESX.RegisterCommand('setjob', 'admin', function(xPlayer, args, showError)
	if not ESX.DoesJobExist(args.job, args.grade) then
		return showError(TranslateCap('command_setjob_invalid'))
	end

	args.playerId.setJob(args.job, args.grade)
	if Config.AdminLogging then
		ESX.DiscordLogFields("UserActions", "Set Job /setjob Triggered!", "pink", {
			{name = "Player", value = xPlayer.name, inline = true},
			{name = "ID", value = xPlayer.source, inline = true},
			{name = "Target", value = args.playerId.name, inline = true},
			{name = "Job", value = args.playerId, inline = true},
			{name = "Grade", value = args.playerId, inline = true},
		})
	end
end, true, {help = TranslateCap('command_setjob'), validate = true, arguments = {
	{name = 'playerId', help = TranslateCap('commandgeneric_playerid'), type = 'player'},
	{name = 'job', help = TranslateCap('command_setjob_job'), type = 'string'},
	{name = 'grade', help = TranslateCap('command_setjob_grade'), type = 'number'}
}})

local upgrades = Config.SpawnVehMaxUpgrades and
    {
        plate = "ADMINCAR",
        modEngine = 3,
        modBrakes = 2,
        modTransmission = 2,
        modSuspension = 3,
        modArmor = true,
        windowTint = 1
    } or {}

ESX.RegisterCommand('car', 'admin', function(xPlayer, args, showError)
	if not xPlayer then
		return showError('[^1ERROR^7] The xPlayer value is nil')
	end
	
	local playerPed = GetPlayerPed(xPlayer.source)
	local playerCoords = GetEntityCoords(playerPed)
	local playerHeading = GetEntityHeading(playerPed)
	local playerVehicle = GetVehiclePedIsIn(playerPed)

	if not args.car or type(args.car) ~= 'string' then
		args.car = 'adder'
	end

	if playerVehicle then
		DeleteEntity(playerVehicle)
	end

	if Config.AdminLogging then
		ESX.DiscordLogFields("UserActions", "Spawn Car /car Triggered!", "pink", {
			{name = "Player", value = xPlayer.name, inline = true},
			{name = "ID", value = xPlayer.source, inline = true},
			{name = "Vehicle", value = args.car, inline = true}
		})
	end

	ESX.OneSync.SpawnVehicle(args.car, playerCoords, playerHeading, upgrades, function(networkId)
		if networkId then
			local vehicle = NetworkGetEntityFromNetworkId(networkId)
			for i = 1, 20 do
				Wait(0)
				SetPedIntoVehicle(playerPed, vehicle, -1)
		
				if GetVehiclePedIsIn(playerPed, false) == vehicle then
					break
				end
			end
			if GetVehiclePedIsIn(playerPed, false) ~= vehicle then
				showError('[^1ERROR^7] The player could not be seated in the vehicle')
			end
		end
	end)
end, false, {help = TranslateCap('command_car'), validate = false, arguments = {
	{name = 'car',validate = false, help = TranslateCap('command_car_car'), type = 'string'}
}})

ESX.RegisterCommand({'cardel', 'dv'}, 'admin', function(xPlayer, args, _)
	local PedVehicle = GetVehiclePedIsIn(GetPlayerPed(xPlayer.source), false)
	if DoesEntityExist(PedVehicle) then
		DeleteEntity(PedVehicle)
	end
	local Vehicles = ESX.OneSync.GetVehiclesInArea(GetEntityCoords(GetPlayerPed(xPlayer.source)), tonumber(args.radius) or 5.0)
	for i = 1, #Vehicles do
		local Vehicle = NetworkGetEntityFromNetworkId(Vehicles[i])
		if DoesEntityExist(Vehicle) then
			DeleteEntity(Vehicle)
		end
	end
	if Config.AdminLogging then
		ESX.DiscordLogFields("UserActions", "Delete Vehicle /dv Triggered!", "pink", {
			{name = "Player", value = xPlayer.name, inline = true},
			{name = "ID", value = xPlayer.source, inline = true},
		})
	end
end, false, {help = TranslateCap('command_cardel'), validate = false, arguments = {
	{name = 'radius',validate = false, help = TranslateCap('command_cardel_radius'), type = 'number'}
}})

ESX.RegisterCommand('setaccountmoney', 'admin', function(xPlayer, args, showError)
	if not args.playerId.getAccount(args.account) then
		return showError(TranslateCap('command_giveaccountmoney_invalid'))
	end
	args.playerId.setAccountMoney(args.account, args.amount, "Government Grant")
	if Config.AdminLogging then
		ESX.DiscordLogFields("UserActions", "Set Account Money /setaccountmoney Triggered!", "pink", {
			{name = "Player", value = xPlayer.name, inline = true},
			{name = "ID", value = xPlayer.source, inline = true},
			{name = "Target", value = args.playerId.name, inline = true},
			{name = "Account", value = args.account, inline = true},
			{name = "Amount", value = args.amount, inline = true},
		})
	end
end, true, {help = TranslateCap('command_setaccountmoney'), validate = true, arguments = {
	{name = 'playerId', help = TranslateCap('commandgeneric_playerid'), type = 'player'},
	{name = 'account', help = TranslateCap('command_giveaccountmoney_account'), type = 'string'},
	{name = 'amount', help = TranslateCap('command_setaccountmoney_amount'), type = 'number'}
}})

ESX.RegisterCommand('giveaccountmoney', 'admin', function(xPlayer, args, showError)
	if not args.playerId.getAccount(args.account) then
		return showError(TranslateCap('command_giveaccountmoney_invalid'))
	end
	args.playerId.addAccountMoney(args.account, args.amount, "Government Grant")
	if Config.AdminLogging then
		ESX.DiscordLogFields("UserActions", "Give Account Money /giveaccountmoney Triggered!", "pink", {
			{name = "Player", value = xPlayer.name, inline = true},
			{name = "ID", value = xPlayer.source, inline = true},
			{name = "Target", value = args.playerId.name, inline = true},
			{name = "Account", value = args.account, inline = true},
			{name = "Amount", value = args.amount, inline = true},
		})
	end
end, true, {help = TranslateCap('command_giveaccountmoney'), validate = true, arguments = {
	{name = 'playerId', help = TranslateCap('commandgeneric_playerid'), type = 'player'},
	{name = 'account', help = TranslateCap('command_giveaccountmoney_account'), type = 'string'},
	{name = 'amount', help = TranslateCap('command_giveaccountmoney_amount'), type = 'number'}
}})

ESX.RegisterCommand('removeaccountmoney', 'admin', function(xPlayer, args, showError)
	if not args.playerId.getAccount(args.account) then
		return showError(TranslateCap('command_removeaccountmoney_invalid'))
	end
	args.playerId.removeAccountMoney(args.account, args.amount, "Government Tax")
	if Config.AdminLogging then
		ESX.DiscordLogFields("UserActions", "Remove Account Money /removeaccountmoney Triggered!", "pink", {
			{name = "Player", value = xPlayer.name, inline = true},
			{name = "ID", value = xPlayer.source, inline = true},
			{name = "Target", value = args.playerId.name, inline = true},
			{name = "Account", value = args.account, inline = true},
			{name = "Amount", value = args.amount, inline = true},
		})
	end
end, true, {help = TranslateCap('command_removeaccountmoney'), validate = true, arguments = {
	{name = 'playerId', help = TranslateCap('commandgeneric_playerid'), type = 'player'},
	{name = 'account', help = TranslateCap('command_removeaccountmoney_account'), type = 'string'},
	{name = 'amount', help = TranslateCap('command_removeaccountmoney_amount'), type = 'number'}
}})

if not Config.OxInventory then
	ESX.RegisterCommand('giveitem', 'admin', function(xPlayer, args, _)
		args.playerId.addInventoryItem(args.item, args.count)
		if Config.AdminLogging then
			ESX.DiscordLogFields("UserActions", "Give Item /giveitem Triggered!", "pink", {
				{name = "Player", value = xPlayer.name, inline = true},
				{name = "ID", value = xPlayer.source, inline = true},
				{name = "Target", value = args.playerId.name, inline = true},
				{name = "Item", value = args.item, inline = true},
				{name = "Quantity", value = args.count, inline = true},
			})
		end
	end, true, {help = TranslateCap('command_giveitem'), validate = true, arguments = {
		{name = 'playerId', help = TranslateCap('commandgeneric_playerid'), type = 'player'},
		{name = 'item', help = TranslateCap('command_giveitem_item'), type = 'item'},
		{name = 'count', help = TranslateCap('command_giveitem_count'), type = 'number'}
	}})

	ESX.RegisterCommand('giveweapon', 'admin', function(xPlayer, args, showError)
		if args.playerId.hasWeapon(args.weapon) then
			return showError(TranslateCap('command_giveweapon_hasalready'))
		end
		args.playerId.addWeapon(args.weapon, args.ammo)
		if Config.AdminLogging then
			ESX.DiscordLogFields("UserActions", "Give Weapon /giveweapon Triggered!", "pink", {
				{name = "Player", value = xPlayer.name, inline = true},
				{name = "ID", value = xPlayer.source, inline = true},
				{name = "Target", value = args.playerId.name, inline = true},
				{name = "Weapon", value = args.weapon, inline = true},
				{name = "Ammo", value = args.ammo, inline = true},
			})
		end
	end, true, {help = TranslateCap('command_giveweapon'), validate = true, arguments = {
		{name = 'playerId', help = TranslateCap('commandgeneric_playerid'), type = 'player'},
		{name = 'weapon', help = TranslateCap('command_giveweapon_weapon'), type = 'weapon'},
		{name = 'ammo', help = TranslateCap('command_giveweapon_ammo'), type = 'number'}
	}})

	ESX.RegisterCommand('giveammo', 'admin', function(xPlayer, args, showError)
		if not args.playerId.hasWeapon(args.weapon) then
			return showError(TranslateCap("command_giveammo_noweapon_found"))
		end
		args.playerId.addWeaponAmmo(args.weapon, args.ammo)
		if Config.AdminLogging then
			ESX.DiscordLogFields("UserActions", "Give Ammunition /giveammo Triggered!", "pink", {
				{name = "Player", value = xPlayer.name, inline = true},
				{name = "ID", value = xPlayer.source, inline = true},
				{name = "Target", value = args.playerId.name, inline = true},
				{name = "Weapon", value = args.weapon, inline = true},
				{name = "Ammo", value = args.ammo, inline = true},
			})
		end
	end, true, {help = TranslateCap('command_giveweapon'), validate = false, arguments = {
		{name = 'playerId', help = TranslateCap('commandgeneric_playerid'), type = 'player'},
		{name = 'weapon', help = TranslateCap('command_giveammo_weapon'), type = 'weapon'},
		{name = 'ammo', help = TranslateCap('command_giveammo_ammo'), type = 'number'}
	}})

	ESX.RegisterCommand('giveweaponcomponent', 'admin', function(xPlayer, args, showError)
		if args.playerId.hasWeapon(args.weaponName) then
			local component = ESX.GetWeaponComponent(args.weaponName, args.componentName)

			if component then
				if args.playerId.hasWeaponComponent(args.weaponName, args.componentName) then
					showError(TranslateCap('command_giveweaponcomponent_hasalready'))
				else
					args.playerId.addWeaponComponent(args.weaponName, args.componentName)
					if Config.AdminLogging then
						ESX.DiscordLogFields("UserActions", "Give Weapon Component /giveweaponcomponent Triggered!", "pink", {
							{name = "Player", value = xPlayer.name, inline = true},
							{name = "ID", value = xPlayer.source, inline = true},
							{name = "Target", value = args.playerId.name, inline = true},
							{name = "Weapon", value = args.weaponName, inline = true},
							{name = "Component", value = args.componentName, inline = true},
						})
					end
				end
			else
				showError(TranslateCap('command_giveweaponcomponent_invalid'))
			end
		else
			showError(TranslateCap('command_giveweaponcomponent_missingweapon'))
		end
	end, true, {help = TranslateCap('command_giveweaponcomponent'), validate = true, arguments = {
		{name = 'playerId', help = TranslateCap('commandgeneric_playerid'), type = 'player'},
		{name = 'weaponName', help = TranslateCap('command_giveweapon_weapon'), type = 'weapon'},
		{name = 'componentName', help = TranslateCap('command_giveweaponcomponent_component'), type = 'string'}
	}})
end

ESX.RegisterCommand({'clear', 'cls'}, 'user', function(xPlayer, _, _)
	xPlayer.triggerEvent('chat:clear')
end, false, {help = TranslateCap('command_clear')})

ESX.RegisterCommand({'clearall', 'clsall'}, 'admin', function(xPlayer, _, _)
	TriggerClientEvent('chat:clear', -1)
	if Config.AdminLogging then
		ESX.DiscordLogFields("UserActions", "Clear Chat /clearall Triggered!", "pink", {
			{name = "Player", value = xPlayer.name, inline = true},
			{name = "ID", value = xPlayer.source, inline = true},
		})
	end
end, true, {help = TranslateCap('command_clearall')})

ESX.RegisterCommand("refreshjobs", 'admin', function(xPlayer, _, _)
	ESX.RefreshJobs()
end, true, {help = TranslateCap('command_clearall')})

if not Config.OxInventory then
	ESX.RegisterCommand('clearinventory', 'admin', function(xPlayer, args, _)
		for k, v in ipairs(args.playerId.inventory) do
			if v.count > 0 then
				args.playerId.setInventoryItem(v.name, 0)
			end
		end
		TriggerEvent('esx:playerInventoryCleared',args.playerId)
		if Config.AdminLogging then
			ESX.DiscordLogFields("UserActions", "Clear Inventory /clearinventory Triggered!", "pink", {
				{name = "Player", value = xPlayer.name, inline = true},
				{name = "ID", value = xPlayer.source, inline = true},
				{name = "Target", value = args.playerId.name, inline = true},
			})
		end
	end, true, {help = TranslateCap('command_clearinventory'), validate = true, arguments = {
		{name = 'playerId', help = TranslateCap('commandgeneric_playerid'), type = 'player'}
	}})

	ESX.RegisterCommand('clearloadout', 'admin', function(xPlayer, args, _)
		for i=#args.playerId.loadout, 1, -1 do
			args.playerId.removeWeapon(args.playerId.loadout[i].name)
		end
		TriggerEvent('esx:playerLoadoutCleared',args.playerId)
		if Config.AdminLogging then
			ESX.DiscordLogFields("UserActions", "/clearloadout Triggered!", "pink", {
				{name = "Player", value = xPlayer.name, inline = true},
				{name = "ID", value = xPlayer.source, inline = true},
				{name = "Target", value = args.playerId.name, inline = true},
			})
		end
	end, true, {help = TranslateCap('command_clearloadout'), validate = true, arguments = {
		{name = 'playerId', help = TranslateCap('commandgeneric_playerid'), type = 'player'}
	}})
end

ESX.RegisterCommand('setgroup', 'admin', function(xPlayer, args, _)
	if not args.playerId then args.playerId = xPlayer.source end
	if args.group == "superadmin" then args.group = "admin" print("[^3WARNING^7] ^5Superadmin^7 detected, setting group to ^5admin^7") end
	args.playerId.setGroup(args.group)
	if Config.AdminLogging then
		ESX.DiscordLogFields("UserActions", "/setgroup Triggered!", "pink", {
			{name = "Player", value = xPlayer.name, inline = true},
			{name = "ID", value = xPlayer.source, inline = true},
			{name = "Target", value = args.playerId.name, inline = true},
			{name = "Group", value = args.group, inline = true},
		})
	end
end, true, {help = TranslateCap('command_setgroup'), validate = true, arguments = {
	{name = 'playerId', help = TranslateCap('commandgeneric_playerid'), type = 'player'},
	{name = 'group', help = TranslateCap('command_setgroup_group'), type = 'string'},
}})

ESX.RegisterCommand('save', 'admin', function(xPlayer, args, _)
	Core.SavePlayer(args.playerId)
	print("[^2Info^0] Saved Player - ^5".. args.playerId.source .. "^0")
end, true, {help = TranslateCap('command_save'), validate = true, arguments = {
	{name = 'playerId', help = TranslateCap('commandgeneric_playerid'), type = 'player'}
}})

ESX.RegisterCommand('saveall', 'admin', function(xPlayer, args, _)
	Core.SavePlayers()
end, true, {help = TranslateCap('command_saveall')})

ESX.RegisterCommand('group', {"user", "admin"}, function(xPlayer, _, _)
	print(xPlayer.getName()..", You are currently: ^5".. xPlayer.getGroup() .. "^0")
end, true)

ESX.RegisterCommand('job', {"user", "admin"}, function(xPlayer, _, _)
	print(xPlayer.getName()..", You are currently: ^5".. xPlayer.getJob().name.. "^0 - ^5".. xPlayer.getJob().grade_label .. "^0")
end, true)

ESX.RegisterCommand('info', {"user", "admin"}, function(xPlayer, _, _)
	local job = xPlayer.getJob().name
	local jobgrade = xPlayer.getJob().grade_name
	print("^2ID : ^5"..xPlayer.source.." ^0| ^2Name:^5"..xPlayer.getName().." ^0 | ^2Group:^5"..xPlayer.getGroup().."^0 | ^2Job:^5".. job.."^0")
end, true)

ESX.RegisterCommand('coords', "admin", function(xPlayer, _, _)
    local ped = GetPlayerPed(xPlayer.source)
	local coords = GetEntityCoords(ped, false)
	local heading = GetEntityHeading(ped)
	print("Coords - Vector3: ^5".. vector3(coords.x,coords.y,coords.z).. "^0")
	print("Coords - Vector4: ^5".. vector4(coords.x, coords.y, coords.z, heading) .. "^0")
end, true)

ESX.RegisterCommand('tpm', "admin", function(xPlayer, _, _)
	xPlayer.triggerEvent("esx:tpm")
	if Config.AdminLogging then
		ESX.DiscordLogFields("UserActions", "Admin Teleport /tpm Triggered!", "pink", {
			{name = "Player", value = xPlayer.name, inline = true},
			{name = "ID", value = xPlayer.source, inline = true},
		})
	end
end, true)

ESX.RegisterCommand('goto', "admin", function(xPlayer, args, _)
	local targetCoords = args.playerId.getCoords()
	xPlayer.setCoords(targetCoords)
	if Config.AdminLogging then
		ESX.DiscordLogFields("UserActions", "Admin Teleport /goto Triggered!", "pink", {
			{name = "Player", value = xPlayer.name, inline = true},
			{name = "ID", value = xPlayer.source, inline = true},
			{name = "Target", value = args.playerId.name, inline = true},
			{name = "Target Coords", value = targetCoords, inline = true},
		})
	end
end, true, {help = TranslateCap('command_goto'), validate = true, arguments = {
	{name = 'playerId', help = TranslateCap('commandgeneric_playerid'), type = 'player'}
}})

ESX.RegisterCommand('bring', "admin", function(xPlayer, args, _)
	local playerCoords = xPlayer.getCoords()
	args.playerId.setCoords(playerCoords)
	if Config.AdminLogging then
		ESX.DiscordLogFields("UserActions", "Admin Teleport /bring Triggered!", "pink", {
			{name = "Player", value = xPlayer.name, inline = true},
			{name = "ID", value = xPlayer.source, inline = true},
			{name = "Target", value = args.playerId.name, inline = true},
			{name = "Target Coords", value = targetCoords, inline = true},
		})
	end
end, true, {help = TranslateCap('command_bring'), validate = true, arguments = {
	{name = 'playerId', help = TranslateCap('commandgeneric_playerid'), type = 'player'}
}})

ESX.RegisterCommand('kill', "admin", function(xPlayer, args, _)
	args.playerId.triggerEvent("esx:killPlayer")
	if Config.AdminLogging then
		ESX.DiscordLogFields("UserActions", "Kill Command /kill Triggered!", "pink", {
			{name = "Player", value = xPlayer.name, inline = true},
			{name = "ID", value = xPlayer.source, inline = true},
			{name = "Target", value = args.playerId.name, inline = true},
		})
	end
end, true, {help = TranslateCap('command_kill'), validate = true, arguments = {
	{name = 'playerId', help = TranslateCap('commandgeneric_playerid'), type = 'player'}
}})

ESX.RegisterCommand('freeze', "admin", function(xPlayer, args, _)
	args.playerId.triggerEvent('esx:freezePlayer', "freeze")
	if Config.AdminLogging then
		ESX.DiscordLogFields("UserActions", "Admin Freeze /freeze Triggered!", "pink", {
			{name = "Player", value = xPlayer.name, inline = true},
			{name = "ID", value = xPlayer.source, inline = true},
			{name = "Target", value = args.playerId.name, inline = true},
		})
	end
end, true, {help = TranslateCap('command_freeze'), validate = true, arguments = {
	{name = 'playerId', help = TranslateCap('commandgeneric_playerid'), type = 'player'}
}})

ESX.RegisterCommand('unfreeze', "admin", function(xPlayer, args, _)
	args.playerId.triggerEvent('esx:freezePlayer', "unfreeze")
	if Config.AdminLogging then
		ESX.DiscordLogFields("UserActions", "Admin UnFreeze /unfreeze Triggered!", "pink", {
			{name = "Player", value = xPlayer.name, inline = true},
			{name = "ID", value = xPlayer.source, inline = true},
			{name = "Target", value = args.playerId.name, inline = true},
		})
	end
end, true, {help = TranslateCap('command_unfreeze'), validate = true, arguments = {
	{name = 'playerId', help = TranslateCap('commandgeneric_playerid'), type = 'player'}
}})

ESX.RegisterCommand("noclip", 'admin', function(xPlayer, _, _)
	xPlayer.triggerEvent('esx:noclip')
	if Config.AdminLogging then
		ESX.DiscordLogFields("UserActions", "Admin NoClip /noclip Triggered!", "pink", {
			{name = "Player", value = xPlayer.name, inline = true},
			{name = "ID", value = xPlayer.source, inline = true},
		})
	end
end, false)

ESX.RegisterCommand('players', "admin", function(xPlayer, _, _)
	local xPlayers = ESX.GetExtendedPlayers() -- Returns all xPlayers
	print("^5"..#xPlayers.." ^2online player(s)^0")
	for i = 1, #(xPlayers) do 
		local xPlayer = xPlayers[i]
		print("^1[ ^2ID : ^5"..xPlayer.source.." ^0| ^2Name : ^5"..xPlayer.getName().." ^0 | ^2Group : ^5"..xPlayer.getGroup().." ^0 | ^2Identifier : ^5".. xPlayer.identifier .."^1]^0\n")
	end
end, true)
