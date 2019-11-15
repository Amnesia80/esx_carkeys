
--- SERVER

ESX               = nil
local cars 		  = {}

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)


ESX.RegisterServerCallback('esx_carkeys:getOwnedVehicles', function (source, cb)
	local xPlayer = ESX.GetPlayerFromId(source)

	MySQL.Async.fetchAll('SELECT * FROM owned_vehicles WHERE owner = @owner', {
		['@owner'] = xPlayer.identifier
	}, function (result)
		cb(result)
	end)
end)


ESX.RegisterServerCallback('esx_carkeys:getKeysByPlate', function (source, cb, plate)

	MySQL.Async.fetchAll('SELECT COUNT(id) AS total FROM owned_keys where plate=@plate', { 
		['@plate'] = plate
	}, function(result)
		cb(result)
	end)
end)


ESX.RegisterServerCallback('esx_carkeys:getKeysByIdentifier', function (source, cb)
	local xPlayer = ESX.GetPlayerFromId(source)
	MySQL.Async.fetchAll('SELECT a.id as id, a.plate as plate, a.owner as owner, b.vehicle as vehicle, count(a.id) as nbKey FROM `owned_keys` as a INNER JOIN `owned_vehicles` as b ON a.plate = b.plate where a.owner=@owner group by a.plate' ,
		{ ['@owner'] = xPlayer.identifier 
	}, function(result)
		cb(result)
	end)
end)

RegisterServerEvent('esx_carkeys:createKeys')
AddEventHandler('esx_carkeys:createKeys', function (plate, count)
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)
	for i = 1, count do
		MySQL.Async.execute('INSERT INTO owned_keys (plate, owner) VALUES (@plate,@owner)',
		{
			['@plate']       = plate,
			['@owner']       = xPlayer.identifier
		})
	end
end)

RegisterServerEvent('esx_carkeys:giveKey')
AddEventHandler('esx_carkeys:giveKey', function (idKey, playerId, plate)
	local _source       = source
	local xPlayer       = ESX.GetPlayerFromId(_source)
	local closestPlayer = ESX.GetPlayerFromId(playerId)
	MySQL.Async.execute('UPDATE `owned_keys` SET `owner`=@newOwner WHERE `id` = @id',
	{
		['@newOwner']       = closestPlayer.identifier,
		['@id']  	        = idKey
	})
	TriggerClientEvent('esx:showNotification', playerId, 'Vous avez reçu une clé de véhicule ~g~ '.. plate ..' !\n')
end)

RegisterServerEvent('esx_carkeys:dropKey')
AddEventHandler('esx_carkeys:dropKey', function (idKey)
	MySQL.Async.execute('DELETE FROM `owned_keys` WHERE `id` = @id',
	{
		['@id']  	        = idKey
	})
end)

ESX.RegisterServerCallback('esx_carkeys:checkKey', function (source, cb, plate)
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)
	MySQL.Async.fetchAll(
		'SELECT * FROM owned_keys WHERE plate = @plate AND owner = @identifier', 
		{
			['@plate'] = plate,
			['@identifier'] = xPlayer.identifier
		},
		function(result)
			local found = false
			if result[1] ~= nil then
				
				if xPlayer.identifier == result[1].owner then 
					found = true
				end
			end
			if found then
				cb(true)
	
			else
				cb(false)
			end
		end)
end)