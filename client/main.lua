-- Client
-- Script fait de A à Z par Amnesia

-- Déclaration des variables globales 
ESX               			  = nil
xPlayer 		  			  = nil

local Blips 				  = {}
local pedConfig				  = {}
local HasAlreadyEnteredMarker = false
local LastZone                = nil
local CurrentAction           = nil
local CurrentActionMsg        = ''
local CurrentActionData       = {}
local generalLoaded 		  = false
local PlayingAnim 			  = false
local xPlayer 				  = nil

local Keys = {
  ["ESC"] = 322, ["F1"] = 288, ["F2"] = 289, ["F3"] = 170, ["F5"] = 166, ["F6"] = 167, ["F7"] = 168, ["F8"] = 169, ["F9"] = 56, ["F10"] = 57,
  ["~"] = 243, ["1"] = 157, ["2"] = 158, ["3"] = 160, ["4"] = 164, ["5"] = 165, ["6"] = 159, ["7"] = 161, ["8"] = 162, ["9"] = 163, ["-"] = 84, ["="] = 83, ["BACKSPACE"] = 177,
  ["TAB"] = 37, ["Q"] = 44, ["W"] = 32, ["E"] = 38, ["R"] = 45, ["T"] = 245, ["Y"] = 246, ["U"] = 303, ["P"] = 199, ["["] = 39, ["]"] = 40, ["ENTER"] = 18,
  ["CAPS"] = 137, ["A"] = 34, ["S"] = 8, ["D"] = 9, ["F"] = 23, ["G"] = 47, ["H"] = 74, ["K"] = 311, ["L"] = 182,
  ["LEFTSHIFT"] = 21, ["Z"] = 20, ["X"] = 73, ["C"] = 26, ["V"] = 0, ["B"] = 29, ["N"] = 249, ["M"] = 244, [","] = 82, ["."] = 81,
  ["LEFTCTRL"] = 36, ["LEFTALT"] = 19, ["SPACE"] = 22, ["RIGHTCTRL"] = 70,
  ["HOME"] = 213, ["PAGEUP"] = 10, ["PAGEDOWN"] = 11, ["DELETE"] = 178,
  ["LEFT"] = 174, ["RIGHT"] = 175, ["TOP"] = 27, ["DOWN"] = 173,
  ["NENTER"] = 201, ["N4"] = 108, ["N5"] = 60, ["N6"] = 107, ["N+"] = 96, ["N-"] = 97, ["N7"] = 117, ["N8"] = 61, ["N9"] = 118
}

Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end
end)

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(_xPlayer)
	xPlayer = _xPlayer
	CreateBlips()
end)

function CreateBlips()	
	for k,v in pairs(Config.Locksmiths) do
		if v.blip == true then 
			Blips[k] = AddBlipForCoord(v.Pos.x, v.Pos.y, v.Pos.z)
			SetBlipSprite (Blips[k], 255)
			SetBlipDisplay(Blips[k], 2)
			SetBlipScale  (Blips[k], 1.0)
			SetBlipAsShortRange(Blips[k], true)

			BeginTextCommandSetBlipName("STRING")
			--AddTextComponentSubstringPlayerName('Serrurier')
			EndTextCommandSetBlipName('Serrurier')	
		end	
	end
end

-- Display markers
Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)

		local coords = GetEntityCoords(PlayerPedId())

		for k,v in pairs(Config.Locksmiths) do
			if(v.Type ~= -1 and GetDistanceBetweenCoords(coords, v.Pos.x, v.Pos.y, v.Pos.z, true) < Config.DrawDistance) then
				DrawMarker(v.Type, v.Pos.x, v.Pos.y, v.Pos.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, v.Size.x, v.Size.y, v.Size.z, Config.MarkerColor.r, Config.MarkerColor.g, Config.MarkerColor.b, 100, false, true, 2, false, false, false, false)
			end
		end
	end
end)

-- Create NPC Mission
Citizen.CreateThread(function()
	Citizen.Wait(1)
	if (not generalLoaded) and Config.EnablePed then
		for k,v in pairs(Config.Locksmiths) do
			pedConfig = Config.PedData[v.PedDataKey]
			RequestModel(GetHashKey(pedConfig.modelHash))
			while not HasModelLoaded(GetHashKey(pedConfig.modelHash)) do
				Citizen.Wait(10)
			end
			pedConfig.id = CreatePed(28, pedConfig.modelHash, pedConfig.Pos.x, pedConfig.Pos.y, pedConfig.Pos.z, pedConfig.Pos.h, false, false)
			SetPedFleeAttributes(pedConfig.id, 0, 0)
			SetAmbientVoiceName(pedConfig.id, pedConfig.Ambiance)
			SetPedDropsWeaponsWhenDead(pedConfig.id, false)
			SetPedDiesWhenInjured(pedConfig.id, false)
			
			Citizen.Wait(1500)
			SetEntityInvincible(pedConfig.id , true)
			FreezeEntityPosition(pedConfig.id, true)
		end

	end
	generalLoaded = true
end)

-- Enter / Exit marker events
Citizen.CreateThread(function ()
	while true do
		Citizen.Wait(0)

		local coords      = GetEntityCoords(PlayerPedId())
		local isInMarker  = false
		local currentZone = nil
		for k,v in pairs(Config.Locksmiths) do
			if(GetDistanceBetweenCoords(coords, v.Pos.x, v.Pos.y, v.Pos.z, true) < v.Size.x) then
				isInMarker  = true
				currentZone = 'Locksmiths'
			end
		end

		if (isInMarker and not HasAlreadyEnteredMarker) or (isInMarker and LastZone ~= currentZone) then
			HasAlreadyEnteredMarker = true
			LastZone                = currentZone
			TriggerEvent('esx_carkeys:hasEnteredMarker', currentZone)
		end

		if not isInMarker and HasAlreadyEnteredMarker then
			HasAlreadyEnteredMarker = false
			TriggerEvent('esx_carkeys:hasExitedMarker', LastZone)
		end
	end
end)


AddEventHandler('esx_carkeys:hasEnteredMarker', function (zone)
	if zone == 'Locksmiths' then
		CurrentAction     = 'locksmith_menu'
		CurrentActionMsg  = 'Appuyez sur ~INPUT_CONTEXT~ pour parler au serrurier'
		CurrentActionData = {}
	end
end)

AddEventHandler('esx_carkeys:hasExitedMarker', function (zone)
	if not IsInShopMenu then
		ESX.UI.Menu.CloseAll()
	end

	CurrentAction = nil
end)

-- Key control
Citizen.CreateThread(function()
	while true do
		Citizen.Wait(10)

		if CurrentAction == nil then
			Citizen.Wait(500)
		else
			ESX.ShowHelpNotification(CurrentActionMsg)
			if IsControlJustReleased(0, Keys['E']) then
				if CurrentAction == 'locksmith_menu' then
					OpenLocksmithMenu()
				end
				CurrentAction = nil
			end
		end
	end
end)

RegisterNetEvent("esx_carkeys:showOwnedKeys")
AddEventHandler("esx_carkeys:showOwnedKeys", function()
	menuOwnedKeys()
end)

RegisterNetEvent("esx_carkeys:lockUnLockVehicle")
AddEventHandler("esx_carkeys:lockUnLockVehicle", function()
	OpenCloseVehicle()
end)

-- Fonction de création et d'affichage du menu du serrurier
function OpenLocksmithMenu()
	ESX.TriggerServerCallback('esx_carkeys:getOwnedVehicles', function (vehicles)
		local elements = {}
		local plate = nil
		local carKeys = 0
		for i=1, #vehicles, 1 do
			table.insert(elements, {
				label = 'Plaque: ' .. vehicles[i].plate .. ' 500$/clé',
				value = vehicles[i].plate
			})
		end
		
		ESX.UI.Menu.CloseAll()
		
		ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'locksmith_create', {
			title    = 'Créer clé',
			align    = 'top-left',
			elements = elements
		}, 
		function (data, menu)
				_plate = data.current.value
				plate = _plate
				menu.close()
				-- TODO: recuperer le nombre de clé de la plaque pour mettre une limite => carKeys
				ESX.TriggerServerCallback('esx_carkeys:getKeysByPlate', function (totalCarKeys, plate)
					menuCreation(_plate, totalCarKeys[1].total)
				end)
				
		end, 
		function (data, menu)
			menu.close()
		end)
		
	end)
end

function menuCreation(plate, carKeys )
	ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'menuDiag',{
			title = ('Nombre de clé à créer ? (' .. Config.maxCreateKeys ..' max)'),
			align    = 'top-left',
	},
	function(data, menu)
		if Config.enableLimitKeys then
			-- Check que la valeur saisie ne soit pas supérieur à la valeur en config
			if (tonumber(data.value) ~= nil and tonumber(data.value) <= Config.maxCreateKeys) then
				-- check si le véhicule na pas déja le nombre max de clés
				if ( carKeys >= Config.maxCreateKeys ) then
					ESX.ShowNotification('Trop de clé')
					menu.close()
				else
					ESX.ShowNotification('Création de ' .. tonumber(data.value) .. ' clés en cours')
					TriggerServerEvent('esx_carkeys:createKeys', plate, tonumber(data.value) )
					menu.close()
				end					
			else
				ESX.ShowNotification('Nombre supérieur à MaxConfig ou format incorrect')
				menu.close()
			end
		else
			ESX.ShowNotification('Création de la clé en cours')
			TriggerServerEvent('esx_carkeys:createKeys', plate, tonumber(data.value) )
			menu.close()
		end
	end,
	function(data, menu)
		menu.close()
		menu_main() -- Permet de retourner au menu principal à l'appuis sur backspace
	end)
end

function OpenCloseVehicle()
	local playerPed = GetPlayerPed(-1)
	local coords    = GetEntityCoords(playerPed, true)

	local vehicle = nil

	if IsPedInAnyVehicle(playerPed,  false) then
		vehicle = GetVehiclePedIsIn(playerPed, false)
	else
		vehicle = GetClosestVehicle(coords.x, coords.y, coords.z, 7.0, 0, 71)
	end

	ESX.TriggerServerCallback('esx_carkeys:checkKey', function(gotkey)

		if gotkey then
			local locked = GetVehicleDoorLockStatus(vehicle)
			if locked == 1 or locked == 0 then -- if unlocked
				SetVehicleDoorsLocked(vehicle, 2)
				PlayVehicleDoorCloseSound(vehicle, 1)
				ESX.ShowNotification("Vous avez ~r~fermé~s~ le véhicule.")
			elseif locked == 2 then -- if locked
				SetVehicleDoorsLocked(vehicle, 1)
				PlayVehicleDoorOpenSound(vehicle, 0)
				ESX.ShowNotification("Vous avez ~g~ouvert~s~ le véhicule.")
			end
		else
			ESX.ShowNotification("~r~Vous n'avez pas les clés de ce véhicule.")
		end
	end, GetVehicleNumberPlateText(vehicle))
end

function split(s, delimiter)
    result = {};
    for match in (s..delimiter):gmatch("(.-)"..delimiter) do
        table.insert(result, match);
    end
    return result;
end

function menuOwnedKeys()
	
	ESX.TriggerServerCallback('esx_carkeys:getKeysByIdentifier', function (keys)
		local elements = {
				head = {('Plaque'),('Nombre de clés'), ('Actions')},
				rows = {}
		}
		for index,keyRow in pairs(keys) do
			table.insert(elements.rows,
			{
				data = "Plaques",
				cols = {
					keyRow.plate, 
					keyRow.nbKey,
					'{{' .. ('Donner') .. '|give-'.. keyRow.plate .. '-'.. keyRow.id ..'}} {{' .. ('Jeter') .. '|drop-'.. keyRow.plate .. '-'.. keyRow.id ..'}}',
				}
			})
		end
			
		ESX.UI.Menu.Open('list', GetCurrentResourceName(), 'menuList', elements, function(data, menu)
		splitingString = split(data.value, "-")
		action = splitingString[1]
		plate = splitingString[2]
		id = splitingString[3]
		
        if action == 'give' then
			local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()
			if closestPlayer == -1 or closestDistance > 3.0 then
				ESX.ShowNotification("Aucun joueur à proximité")
			else
				--TriggerServerEvent('NB:recruterplayer', GetPlayerServerId(closestPlayer), job,grade)
				
				--ESX.ShowNotification('Vous avez donnée une clé à ' .. ..'')
				ESX.ShowNotification('Vous avez donné une clé pour le véhicule ~g~ '.. plate ..' !\n')
				TriggerServerEvent('esx_carkeys:giveKey', id, GetPlayerServerId(closestPlayer), plate )
			end
			menu.close()
        elseif action == 'drop' then
			ESX.ShowNotification('Vous avez jeté une clé pour le véhicule ~r~ '.. plate ..' !\n')
			TriggerServerEvent('esx_carkeys:dropKey', id, GetPlayerServerId(closestPlayer), plate )
			menu.close()
        end
    
    end, function(data, menu)
        menu.close()
    end)
		
	end)
end