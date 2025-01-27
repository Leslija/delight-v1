local Keys = {
    ["ESC"] = 322, ["F1"] = 288, ["F2"] = 289, ["F3"] = 170, ["F5"] = 166, ["F6"] = 167, ["F7"] = 168, ["F8"] = 169, ["F9"] = 56, ["F10"] = 57,
    ["~"] = 243, ["1"] = 157, ["2"] = 158, ["3"] = 160, ["4"] = 164, ["5"] = 165, ["6"] = 159, ["7"] = 161, ["8"] = 162, ["9"] = 163, ["-"] = 84, ["="] = 83, ["BACKSPACE"] = 177,
    ["TAB"] = 37, ["Q"] = 44, ["W"] = 32, ["E"] = 38, ["R"] = 45, ["T"] = 245, ["Y"] = 246, ["U"] = 303, ["P"] = 199, ["["] = 39, ["]"] = 40, ["ENTER"] = 18,
    ["CAPS"] = 137, ["A"] = 34, ["S"] = 8, ["D"] = 9, ["F"] = 23, ["G"] = 47, ["H"] = 74, ["K"] = 311, ["L"] = 182,
    ["LEFTSHIFT"] = 21, ["Z"] = 20, ["X"] = 73, ["C"] = 26, ["V"] = 0, ["B"] = 29, ["N"] = 249, ["M"] = 244, [","] = 82, ["."] = 81,
    ["LEFTCTRL"] = 36, ["LEFTALT"] = 19, ["SPACE"] = 22, ["RIGHTCTRL"] = 70,
    ["HOME"] = 213, ["PAGEUP"] = 10, ["PAGEDOWN"] = 11, ["DELETE"] = 178,
    ["LEFT"] = 174, ["RIGHT"] = 175, ["TOP"] = 27, ["DOWN"] = 173,
}

local QBCore = exports['qb-core']:GetCoreObject()

local HasKey = false
local LastVehicle = nil
local IsHotwiring = false
local IsRobbing = false
local isLoggedIn = true
local requiredItemsShowed = false
local once = false



function HasVehicleKey(plate)
	QBCore.Functions.TriggerCallback('vehiclekeys:CheckHasKey', function(result)
		if result then
			HasVehicleKey = true
		else
			HasVehicleKey = false
		end
	end, plate)
	return HasVehicleKey
end
exports('HasVehicleKey', HasVehicleKey)

Citizen.CreateThread(function() 
    while true do
        Citizen.Wait(10)
        if QBCore == nil then
            TriggerEvent("QBCore:GetObject", function(obj) QBCore = obj end)    
            Citizen.Wait(200)
        end
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(5)
        if IsPedInAnyVehicle(PlayerPedId(), false) and GetPedInVehicleSeat(GetVehiclePedIsIn(PlayerPedId(), true), -1) == PlayerPedId() and QBCore ~= nil then
            local plate = GetVehicleNumberPlateText(GetVehiclePedIsIn(PlayerPedId(), true))
            if LastVehicle ~= GetVehiclePedIsIn(PlayerPedId(), false) then
                QBCore.Functions.TriggerCallback('vehiclekeys:CheckHasKey', function(result)
                    if result then
                        HasKey = true
                        SetVehicleEngineOn(veh, true, false, true)
                    else
                        HasKey = false
                        SetVehicleEngineOn(veh, false, false, true)
                    end
                    LastVehicle = GetVehiclePedIsIn(PlayerPedId(), false)
                end, plate)
            end
        end

        if not HasKey and IsPedInAnyVehicle(PlayerPedId(), false) and GetPedInVehicleSeat(GetVehiclePedIsIn(PlayerPedId(), false), -1) == PlayerPedId() and QBCore ~= nil and not IsHotwiring then
            local veh = GetVehiclePedIsIn(PlayerPedId(), false)
            SetVehicleEngineOn(veh, false, false, true)
            local requiredItems = {
                --[1] = {name = QBCore.Shared.Items["lockpick"]["name"], image = QBCore.Shared.Items["lockpick"]["image"]},                     << required items to lock pick if wanted to set to a item
                --[2] = {name = QBCore.Shared.Items["advancedlockpick"]["name"], image = QBCore.Shared.Items["advancedlockpick"]["image"]},     << required items to lock pick if wanted to set to a item
            }

            local veh = GetVehiclePedIsIn(PlayerPedId(), false)
            local vehpos = GetOffsetFromEntityInWorldCoords(veh, 0, 0, 0)
            QBCore.Functions.DrawText3D(vehpos.x, vehpos.y, vehpos.z, "~g~H~w~ - Hotwire / ~g~G~w~ - Search")
            SetVehicleEngineOn(veh, false, false, true)

            if IsControlJustPressed(0, Keys["H"]) then
                Hotwire()
            
            elseif IsControlJustPressed(0, Keys["G"]) then
                Search()
            
        
            end
            if not requiredItemsShowed then
                requiredItemsShowed = true
                TriggerEvent('inventory:client:requiredItems', requiredItems, true)
            end
        else
            Citizen.Wait(10)
            if requiredItemsShowed then
                requiredItemsShowed = false
                TriggerEvent('inventory:client:requiredItems', requiredItems, false)
            end
        end

        if IsControlJustPressed(1, Keys["L"]) then
            LockVehicle()
        end
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(7)
        if not IsRobbing and isLoggedIn and QBCore ~= nil then
            if GetVehiclePedIsTryingToEnter(PlayerPedId()) ~= nil and GetVehiclePedIsTryingToEnter(PlayerPedId()) ~= 0 then
                local vehicle = GetVehiclePedIsTryingToEnter(PlayerPedId())
                local driver = GetPedInVehicleSeat(vehicle, -1)
                if driver ~= 0 and not IsPedAPlayer(driver) then
                    if IsEntityDead(driver) then
                        IsRobbing = true
                        QBCore.Functions.Progressbar("rob_keys", "Taking keys.", 2000, false, true, {}, {}, {}, {}, function() -- Done
                            TriggerEvent("vehiclekeys:client:SetOwner", GetVehicleNumberPlateText(vehicle))
                            HasKey = true
                            IsRobbing = false
                        end)
                    end
                end
            end

            --[[if QBCore.Functions.GetPlayerData().job.name ~= "police" then
                local aiming, target = GetEntityPlayerIsFreeAimingAt(PlayerId())
                if aiming and (target ~= nil and target ~= 0) then
                    if DoesEntityExist(target) and not IsPedAPlayer(target) then
                        if IsPedInAnyVehicle(target, false) and not IsPedInAnyVehicle(PlayerPedId(), false ) then
                            if not IsBlacklistedWeapon() then
                                local pos = GetEntityCoords(PlayerPedId(), true)
                                local targetpos = GetEntityCoords(target, true)
                                local vehicle = GetVehiclePedIsIn(target, true)
                                if GetDistanceBetweenCoords(pos.x, pos.y, pos.z, targetpos.x, targetpos.y, targetpos.z, true) < 13.0 then
                                    RobVehicle(target)
                                end
                            end
                        end
                    end
                end
            end]]--
        end
    end
end)

RegisterNetEvent('QBCore:Client:OnPlayerLoaded')
AddEventHandler('QBCore:Client:OnPlayerLoaded', function()
    isLoggedIn = true
end)

RegisterNetEvent('QBCore:Client:OnPlayerUnload')
AddEventHandler('QBCore:Client:OnPlayerUnload', function()
    isLoggedIn = false
end)

RegisterNetEvent('vehiclekeys:client:SetOwner')
AddEventHandler('vehiclekeys:client:SetOwner', function(plate)
    local VehPlate = plate
    if VehPlate == nil then
        VehPlate = GetVehicleNumberPlateText(GetVehiclePedIsIn(PlayerPedId(), true))
    end
    TriggerServerEvent('vehiclekeys:server:SetVehicleOwner', VehPlate)
    if IsPedInAnyVehicle(PlayerPedId()) and plate == GetVehicleNumberPlateText(GetVehiclePedIsIn(PlayerPedId(), true)) then
        SetVehicleEngineOn(GetVehiclePedIsIn(PlayerPedId(), true), true, false, true)
    end
    HasKey = true
    --QBCore.Functions.Notify('You picked the keys of the vehicle', 'success', 3500)
end)

RegisterNetEvent('vehiclekeys:client:GiveKeys')
AddEventHandler('vehiclekeys:client:GiveKeys', function(target)
    local plate = GetVehicleNumberPlateText(GetVehiclePedIsIn(PlayerPedId(), true))
    TriggerServerEvent('vehiclekeys:server:GiveVehicleKeys', plate, target)
end)

RegisterNetEvent('vehiclekeys:client:ToggleEngine')
AddEventHandler('vehiclekeys:client:ToggleEngine', function()
    local EngineOn = IsVehicleEngineOn(GetVehiclePedIsIn(PlayerPedId()))
    local veh = GetVehiclePedIsIn(PlayerPedId(), true)
    if HasKey then
        if EngineOn then
            SetVehicleEngineOn(veh, false, false, true)
        else
            SetVehicleEngineOn(veh, true, false, true)
        end
    end
end)

RegisterNetEvent('lockpicks:UseLockpick')
AddEventHandler('lockpicks:UseLockpick', function(isAdvanced)
    if (IsPedInAnyVehicle(PlayerPedId())) then
        if not HasKey then
            LockpickIgnition(isAdvanced)
        end
    else
        LockpickDoor(isAdvanced)
    end
end)

function RobVehicle(target)
    IsRobbing = true
    Citizen.CreateThread(function()
        while IsRobbing do
            local RandWait = math.random(4000, 6000)
            loadAnimDict("random@mugging3")

            TaskLeaveVehicle(target, GetVehiclePedIsIn(target, true), 256)
            Citizen.Wait(1000)
            ClearPedTasksImmediately(target)

            TaskStandStill(target, RandWait)
            TaskHandsUp(target, RandWait, PlayerPedId(), 0, false)

            Citizen.Wait(RandWait)

            --TaskReactAndFleePed(target, PlayerPedId())
            IsRobbing = false
        end
    end)
end

function LockVehicle()
    local veh = QBCore.Functions.GetClosestVehicle()
    local coordA = GetEntityCoords(PlayerPedId(), true)
    local coordB = GetOffsetFromEntityInWorldCoords(PlayerPedId(), 0.0, 255.0, 0.0)
    local veh = GetClosestVehicleInDirection(coordA, coordB)
    local pos = GetEntityCoords(PlayerPedId(), true)
    if IsPedInAnyVehicle(PlayerPedId()) then
        veh = GetVehiclePedIsIn(PlayerPedId())
    end
    local plate = GetVehicleNumberPlateText(veh)
    local vehpos = GetEntityCoords(veh, false)
    if veh ~= nil and GetDistanceBetweenCoords(pos.x, pos.y, pos.z, vehpos.x, vehpos.y, vehpos.z, true) < 7.5 then
        QBCore.Functions.TriggerCallback('vehiclekeys:CheckHasKey', function(result)
            if result then
                if HasKey then
                    local vehLockStatus = GetVehicleDoorLockStatus(veh)
                    loadAnimDict("anim@mp_player_intmenu@key_fob@")
                    TaskPlayAnim(PlayerPedId(), 'anim@mp_player_intmenu@key_fob@', 'fob_click' ,3.0, 3.0, -1, 49, 0, false, false, false)
        
                    if vehLockStatus == 1 then
                        Citizen.Wait(750)
                        ClearPedTasks(PlayerPedId())
                        TriggerServerEvent("InteractSound_SV:PlayWithinDistance", 8, "lock", 0.3)
                        SetVehicleDoorsLocked(veh, 2)
                        if(GetVehicleDoorLockStatus(veh) == 2)then
                            QBCore.Functions.Notify("Vehicle locked!")
                        else
                            QBCore.Functions.Notify("Something went wrong whit the locking system!")
                        end
                    else
                        Citizen.Wait(750)
                        ClearPedTasks(PlayerPedId())
                        TriggerServerEvent("InteractSound_SV:PlayWithinDistance", 8, "unlock", 0.3)
                        SetVehicleDoorsLocked(veh, 1)
                        if(GetVehicleDoorLockStatus(veh) == 1)then
                            QBCore.Functions.Notify("Vehicle unlocked!")
                        else
                            QBCore.Functions.Notify("Something went wrong whit the locking system!")
                        end
                    end
        
                    if not IsPedInAnyVehicle(PlayerPedId()) then
                        SetVehicleInteriorlight(veh, true)
                        SetVehicleIndicatorLights(veh, 0, true)
                        SetVehicleIndicatorLights(veh, 1, true)
                        Citizen.Wait(450)
                        SetVehicleIndicatorLights(veh, 0, false)
                        SetVehicleIndicatorLights(veh, 1, false)
                        Citizen.Wait(450)
                        SetVehicleInteriorlight(veh, true)
                        SetVehicleIndicatorLights(veh, 0, true)
                        SetVehicleIndicatorLights(veh, 1, true)
                        Citizen.Wait(450)
                        SetVehicleInteriorlight(veh, false)
                        SetVehicleIndicatorLights(veh, 0, false)
                        SetVehicleIndicatorLights(veh, 1, false)
                    end
                end
            else
                QBCore.Functions.Notify('You dont have the keys of the vehicle..', 'error')
            end
        end, plate)
    end
end

local openingDoor = false
function LockpickDoor(isAdvanced)
    local vehicle = QBCore.Functions.GetClosestVehicle()
    if vehicle ~= nil and vehicle ~= 0 then
        local vehpos = GetEntityCoords(vehicle)
        local pos = GetEntityCoords(PlayerPedId())
        if GetDistanceBetweenCoords(pos.x, pos.y, pos.z, vehpos.x, vehpos.y, vehpos.z, true) < 1.5 then
            local vehLockStatus = GetVehicleDoorLockStatus(vehicle)
            if (vehLockStatus > 1) then
                local lockpickTime = math.random(4000, 8000)
                if isAdvanced then
                    lockpickTime = math.ceil(lockpickTime*0.5)
                end
                LockpickDoorAnim(lockpickTime)
                PoliceCall()
                IsHotwiring = true
                SetVehicleAlarm(vehicle, true)
                SetVehicleAlarmTimeLeft(vehicle, lockpickTime)
                QBCore.Functions.Progressbar("lockpick_vehicledoor", "breaking the door open.", lockpickTime, false, true, {
                    disableMovement = true,
                    disableCarMovement = true,
                    disableMouse = false,
                    disableCombat = true,
                }, {}, {}, {}, function() -- Done
                    openingDoor = false
                    StopAnimTask(PlayerPedId(), "veh@break_in@0h@p_m_one@", "low_force_entry_ds", 1.0)
                    IsHotwiring = false
                    if math.random(1, 100) <= 90 then
                        QBCore.Functions.Notify("Door open!")
                        TriggerServerEvent("InteractSound_SV:PlayWithinDistance", 5, "unlock", 0.3)
                        SetVehicleDoorsLocked(vehicle, 0)
                        SetVehicleDoorsLockedForAllPlayers(vehicle, false)
                    else
                        QBCore.Functions.Notify("Failed!", "error")
                    end
                end, function() -- Cancel
                    openingDoor = false
                    StopAnimTask(PlayerPedId(), "veh@break_in@0h@p_m_one@", "low_force_entry_ds", 1.0)
                    QBCore.Functions.Notify("Failed!", "error")
                    IsHotwiring = false
                end)
            end
        end
    end
end

function LockpickDoorAnim(time)
    time = time / 1000
    loadAnimDict("veh@break_in@0h@p_m_one@")
    TaskPlayAnim(PlayerPedId(), "veh@break_in@0h@p_m_one@", "low_force_entry_ds" ,3.0, 3.0, -1, 16, 0, false, false, false)
    openingDoor = true
    Citizen.CreateThread(function()
        while openingDoor do
            TaskPlayAnim(PlayerPedId(), "veh@break_in@0h@p_m_one@", "low_force_entry_ds", 3.0, 3.0, -1, 16, 0, 0, 0, 0)
            Citizen.Wait(1000)
            time = time - 1
            if time <= 0 then
                openingDoor = false
                StopAnimTask(PlayerPedId(), "veh@break_in@0h@p_m_one@", "low_force_entry_ds", 1.0)
            end
        end
    end)
end

function LockpickIgnition(isAdvanced)
    if not HasKey then 
        local vehicle = GetVehiclePedIsIn(PlayerPedId(), true)
        IsHotwiring = false
        PoliceCall()
        local lockpickTime = math.random(6000, 9000)
        if isAdvanced then
            lockpickTime = math.ceil(lockpickTime*0.5)
        end
        QBCore.Functions.Progressbar("lockpick_ignition", "Lockicking..", lockpickTime, false, true, {
            disableMovement = true,
            disableCarMovement = true,
            disableMouse = false,
            disableCombat = true,
        }, {
            animDict = "anim@amb@clubhouse@tutorial@bkr_tut_ig3@",
            anim = "machinic_loop_mechandplayer",
            flags = 16,
        }, {}, {}, function() -- Done
            StopAnimTask(PlayerPedId(), "anim@amb@clubhouse@tutorial@bkr_tut_ig3@", "machinic_loop_mechandplayer", 1.0)
            IsHotwiring = false
            gay = true
            if gay then
                local time = math.random(8,10)
                local circles = math.random(2,4)
                local success = exports['qb-lock']:StartLockPickCircle(circles, time, success)
                print(success)
                if success then
                    TriggerEvent("vehiclekeys:client:SetOwner", GetVehicleNumberPlateText(vehicle))
                else
                    QBCore.Functions.Notify("Lockpick failed!", "error")
                end
            end
        end, function() -- Cancel
            StopAnimTask(PlayerPedId(), "anim@amb@clubhouse@tutorial@bkr_tut_ig3@", "machinic_loop_mechandplayer", 1.0)
            HasKey = false
            SetVehicleEngineOn(veh, false, false, true)
            QBCore.Functions.Notify("Lockpick Canceled!", "error")
            IsHotwiring = false
        end)
    end
end

RegisterNetEvent('qb-lock:pick')
AddEventHandler('qb-lock:pick', function(target)
    local vehicle = GetVehiclePedIsIn(PlayerPedId(), true)
    local hotwireTime = math.random(5000, 9000)
    local veh = GetVehiclePedIsIn(PlayerPedId(), false)
    local mashin = QBCore.Functions.GetClosestVehicle()
if IsPedInAnyVehicle(PlayerPedId()) then

    local time = math.random(8,10)
	local circles = math.random(2,4)
	local success = exports['qb-lock']:StartLockPickCircle(circles, time, success)
    
	print(success)
	if IsPedInAnyVehicle(PlayerPedId()) and success and not HasKey then
        HasKey = true
        QBCore.Functions.Notify("lockpick succeeded!")
        TriggerEvent("vehiclekeys:client:SetOwner", GetVehicleNumberPlateText(veh))

        SetVehicleEngineOn(veh, true, false, true)
    else

        SetVehicleAlarm(vehicle, true)
        SetVehicleAlarmTimeLeft(vehicle, hotwireTime)
        local chance = math.random(1,10)
        
        QBCore.Functions.Notify("lockpick failed!", "error")
        HasKey = false
        if chance == 2 then
            QBCore.Functions.Notify("bads luck your lockpick got fucked", "error")
           TriggerServerEvent("remove:lockpick")

        end
    end
else
    local vehicle2 = QBCore.Functions.GetClosestVehicle()
    if vehicle2 ~= nil and vehicle2 ~= 0 then
        local vehpos = GetEntityCoords(vehicle2)
        local pos = GetEntityCoords(PlayerPedId())
        if GetDistanceBetweenCoords(pos.x, pos.y, pos.z, vehpos.x, vehpos.y, vehpos.z, true) < 1.5 then
            

                local hotwireTime = math.random(5000, 9000)
                 SetVehicleAlarm(vehicle, true)
                SetVehicleAlarmTimeLeft(vehicle, hotwireTime)
                local checkPlayer = IsPedInAnyVehicle(PlayerPedId())
                local time = math.random(8,10)
	            local circles = math.random(2,4)
	            local success = exports['qb-lock']:StartLockPickCircle(circles, time, success)
                if success then
                    
                    QBCore.Functions.Notify("lockpick succeeded!")
                    SetVehicleDoorsLocked(vehicle2, 0)
                    
                else
                    local chance = math.random(1,10)
                    
                    QBCore.Functions.Notify("lockpick failed!", "error")
                    HasKey = false
                    if chance == 2 then
                        QBCore.Functions.Notify("bads luck your lockpick got fucked", "error")
                       TriggerServerEvent("remove:lockpick")
            
                    end
                    
                end
        end
    end
end

end)

function Hotwire()
    if not HasKey then 
        local vehicle = GetVehiclePedIsIn(PlayerPedId(), true)
        IsHotwiring = true
        local hotwireTime = math.random(17000, 20000)
        SetVehicleAlarm(vehicle, true)
        SetVehicleAlarmTimeLeft(vehicle, hotwireTime)
        exports['ps-dispatch']:VehicleTheft()
        QBCore.Functions.Progressbar("hotwire_vehicle", "Engaging the ignition switch", hotwireTime, false, true, {
            disableMovement = true,
            disableCarMovement = true,
            disableMouse = false,
            disableCombat = true,
        }, {
            animDict = "anim@amb@clubhouse@tutorial@bkr_tut_ig3@",
            anim = "machinic_loop_mechandplayer",
            flags = 16,
        }, {}, {}, function() -- Done
            StopAnimTask(PlayerPedId(), "anim@amb@clubhouse@tutorial@bkr_tut_ig3@", "machinic_loop_mechandplayer", 1.0)
            if (math.random(0, 100) < 30) then
                HasKey = true
                local veh = GetVehiclePedIsIn(PlayerPedId(), false)
                SetVehicleEngineOn(veh, true, false, true)
                QBCore.Functions.Notify("Hotwire succeeded!")
            else
                HasKey = false
                SetVehicleEngineOn(veh, false, false, true)
                QBCore.Functions.Notify("Hotwire Canceled!", "error")
            end
            IsHotwiring = false
        end, function() -- Cancel
            StopAnimTask(PlayerPedId(), "anim@amb@clubhouse@tutorial@bkr_tut_ig3@", "machinic_loop_mechandplayer", 1.0)
            HasKey = false
            SetVehicleEngineOn(veh, false, false, true)
            QBCore.Functions.Notify("Hotwire Canceled!", "error")
            IsHotwiring = false
        end)
    end
end

function Search()
    if not HasKey then 
        local vehicle = GetVehiclePedIsIn(PlayerPedId(), true)
        IsHotwiring = true
        local hotwireTime = math.random(5000, 9000)
        -- SetVehicleAlarm(vehicle, true)
        -- SetVehicleAlarmTimeLeft(vehicle, hotwireTime)
        QBCore.Functions.Progressbar("search_vehicle", "searching for keys...", hotwireTime, false, true, {
            disableMovement = true,
            disableCarMovement = true,
            disableMouse = false,
            disableCombat = true,
        }, {
            animDict = "anim@amb@clubhouse@tutorial@bkr_tut_ig3@",
            anim = "machinic_loop_mechandplayer",
            flags = 16,
        }, {}, {}, function() -- Done
            StopAnimTask(PlayerPedId(), "anim@amb@clubhouse@tutorial@bkr_tut_ig3@", "machinic_loop_mechandplayer", 1.0)
            if (math.random(1, 5) == 1) then
                HasKey = true
                local veh = GetVehiclePedIsIn(PlayerPedId(), true)
                SetVehicleEngineOn(veh, true, false, true)
                TriggerEvent("vehiclekeys:client:SetOwner", GetVehicleNumberPlateText(veh))
                QBCore.Functions.Notify("keys found good!", "success")
            else
                HasKey = false
                SetVehicleEngineOn(veh, false, false, true)
                QBCore.Functions.Notify("keys not found!", "error")
            end
            IsHotwiring = false
        end, function() -- Cancel
            StopAnimTask(PlayerPedId(), "anim@amb@clubhouse@tutorial@bkr_tut_ig3@", "machinic_loop_mechandplayer", 1.0)
            HasKey = false
            SetVehicleEngineOn(veh, false, false, true)
            QBCore.Functions.Notify("keys not found !", "error")
            IsHotwiring = false
        end)
    end
end


function PoliceCall()
    local pos = GetEntityCoords(PlayerPedId())
    local chance = 25
    if GetClockHours() >= 1 and GetClockHours() <= 6 then
        chance = 3
    end
    if math.random(1, 100) <= chance then
        local closestPed = GetNearbyPed()
        if closestPed ~= nil then
            local msg = ""
            local s1, s2 = Citizen.InvokeNative(0x2EB41072B4C1E4C0, pos.x, pos.y, pos.z, Citizen.PointerValueInt(), Citizen.PointerValueInt())
            local streetLabel = GetStreetNameFromHashKey(s1)
            local street2 = GetStreetNameFromHashKey(s2)
            if street2 ~= nil and street2 ~= "" then 
                streetLabel = streetLabel .. " " .. street2
            end
            if IsPedInAnyVehicle(PlayerPedId()) then
                local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
                local modelName = GetDisplayNameFromVehicleModel(GetEntityModel(vehicle))
                local modelPlate = GetVehicleNumberPlateText(vehicle)
                msg = "Vehicle theft attempt at " ..streetLabel.. ". Vehicle: " .. modelName .. ", Plate: " .. modelPlate
            else
                local vehicle = QBCore.Functions.GetClosestVehicle()
                local modelName = GetDisplayNameFromVehicleModel(GetEntityModel(vehicle))
                local modelPlate = GetVehicleNumberPlateText(vehicle)
                msg = "Vehicle theft attempt at " ..streetLabel.. ". Vehicle: " .. modelName .. ", Plate: " .. modelPlate
            end
            TriggerServerEvent("police:server:VehicleCall", pos, msg)
        end
    end
end

function GetClosestVehicleInDirection(coordFrom, coordTo)
	local offset = 0
	local rayHandle
	local vehicle

	for i = 0, 100 do
		rayHandle = CastRayPointToPoint(coordFrom.x, coordFrom.y, coordFrom.z, coordTo.x, coordTo.y, coordTo.z + offset, 10, PlayerPedId(), 0)	
		a, b, c, d, vehicle = GetRaycastResult(rayHandle)
		
		offset = offset - 1

		if vehicle ~= 0 then break end
	end
	
	local distance = Vdist2(coordFrom, GetEntityCoords(vehicle))
	
	if distance > 250 then vehicle = nil end

    return vehicle ~= nil and vehicle or 0
end

function GetNearbyPed()
	local retval = nil
	local PlayerPeds = {}
    for _, player in ipairs(GetActivePlayers()) do
        local ped = GetPlayerPed(player)
        table.insert(PlayerPeds, ped)
    end
    local player = PlayerPedId()
    local coords = GetEntityCoords(player)
	local closestPed, closestDistance = QBCore.Functions.GetClosestPed(coords, PlayerPeds)
	if not IsEntityDead(closestPed) and closestDistance < 30.0 then
		retval = closestPed
	end
	return retval
end

function IsBlacklistedWeapon()
    local weapon = GetSelectedPedWeapon(PlayerPedId())
    if weapon ~= nil then
        for _, v in pairs(Config.NoRobWeapons) do
            if weapon == GetHashKey(v) then
                return true
            end
        end
    end
    return false
end

function loadAnimDict( dict )
    while ( not HasAnimDictLoaded( dict ) ) do
        RequestAnimDict( dict )
        Citizen.Wait( 0 )
    end
end


local recentRobs = {}
local LastGive = {}
local LastGiveCash = {}

Citizen.CreateThread(function()
    while true do
        Wait(1)
        aiming, ent = GetEntityPlayerIsFreeAimingAt(PlayerId())
        if aiming then
            local pedCrds = GetEntityCoords(PlayerPedId())
            local entCrds = GetEntityCoords(ent)

            local pedType = GetPedType(ent)
            local animalped = false
            if pedType == 6 or pedType == 27 or pedType == 29 or pedType == 28 then
                animalped = true
            end

            if not animalped and #(pedCrds - entCrds) < 5.0 and not recentRobs["rob"..ent] and not IsPedAPlayer(ent) and not IsEntityDead(ent) and not IsPedDeadOrDying(ent, 1) and IsPedArmed(PlayerPedId(), 6) and not IsPedArmed(ent, 7) and not IsEntityPlayingAnim(ent, "missfbi5ig_22", "hands_up_anxious_scientist", 3) then
                local veh = 0
                if IsPedInAnyVehicle(ent, false) and GetEntitySpeed(veh) < 1.5 then
                    ClearPedTasks(ent)
                    Citizen.Wait(100)
                    veh = GetVehiclePedIsIn(ent,false)
                    TaskLeaveVehicle(ent, veh, 0)
                    Citizen.Wait(1500)
                    TriggerEvent("robEntity", ent, veh)
                    recentRobs["rob"..ent] = true
                    Citizen.Wait(10000)
                end

                if not IsPedInAnyVehicle(ent, false) then
                    TriggerEvent("robEntity",ent,veh)
                    recentRobs["rob"..ent] = true
                    Citizen.Wait(1000)
                end

            end

        else
            Wait(1000)
        end
    end
end)


-- 303280717 safe hash
local RobbedRegisters = {}
RegisterNetEvent("robEntity")
AddEventHandler("robEntity", function(entityRobbed,veh)

    local robbingEntity = true
    local startCrds = GetEntityCoords(PlayerPedId())
    local entCrds = GetEntityCoords(PlayerPedId())
    local pedCrds = GetEntityCoords(PlayerPedId())

    TaskLeaveVehicle(entityRobbed, veh, 0)
    SetPedFleeAttributes(entityRobbed, 0, 0)
    SetPedDropsWeaponsWhenDead(entityRobbed,false)
    ClearPedTasks(entityRobbed)
    ClearPedSecondaryTask(entityRobbed)
    TaskTurnPedToFaceEntity(entityRobbed, PlayerPedId(), 3.0)
    TaskSetBlockingOfNonTemporaryEvents(entityRobbed, true)
    SetPedCombatAttributes(entityRobbed, 17, 1)
    SetPedSeeingRange(entityRobbed, 0.0)
    SetPedHearingRange(entityRobbed, 0.0)
    SetPedAlertness(entityRobbed, 0)
    SetPedKeepTask(entityRobbed, true)
    SetVehicleCanBeUsedByFleeingPeds(veh, false)
    ResetPedLastVehicle(entityRobbed)
    Citizen.Wait(10)

    RequestAnimDict("missfbi5ig_22")
    while not HasAnimDictLoaded("missfbi5ig_22") do
        Citizen.Wait(0)
    end

    local storeRobbery = false
    local alerted = false
    local robberySuccessful = true

    while robbingEntity do
        Citizen.Wait(10)
        if not IsEntityPlayingAnim(entityRobbed, "missfbi5ig_22", "hands_up_anxious_scientist", 3) then
            TaskPlayAnim(entityRobbed, "missfbi5ig_22", "hands_up_anxious_scientist", 5.0, 1.0, -1, 1, 0, 0, 0, 0)
            Citizen.Wait(1000)
        end

        pedCrds = GetEntityCoords(PlayerPedId())
        entCrds = GetEntityCoords(entityRobbed)

        if #(pedCrds - entCrds) > 15.0 then
            robbingEntity = false
            robberySuccessful = false
        end
        
        if math.random(1000) < 15 and #(pedCrds - entCrds) < 7.0 then
            --TriggerEvent("traps:luck:ai")

            if veh ~= 0 and LastGive[veh] ~= true then
                TriggerEvent("notification","They handed you the keys!")
                local plate = GetVehicleNumberPlateText(veh, false)
                local ped = PlayerPedId()
                local pos = GetEntityCoords(ped)
                Citizen.Wait(7000)
                QBCore.Functions.Notify( "Person gave you his keys!","success")
                HasKey = true
                TriggerEvent("vehiclekeys:client:SetOwner", plate)
                robbingEntity = false
                LastGive[veh] = true
            end

            if veh ~= 0 and LastGiveCash[veh] ~= true then
            if(robberySuccessful) then

            end
        end
            robbingEntity = false
            RequestAnimDict("mp_common")
            while not HasAnimDictLoaded("mp_common") do
                Citizen.Wait(0)
            end			
            TaskPlayAnim( entityRobbed, "mp_common", "givetake1_a", 1.0, 1.0, -1, 1, 0, 0, 0, 0 )
            Citizen.Wait(2200)
        end
    end
    ClearPedTasks(entityRobbed)
    Citizen.Wait(10)
    TaskReactAndFleePed(entityRobbed, PlayerPedId())
    --TaskWanderStandard(entityRobbed, 10.0, 10)

    Citizen.Wait(math.random(1000,30000))	
    if veh ~= 0 then
        PoliceCall()
    else
        PoliceCall()
    end
    if #recentRobs > 20 then
        recentRobs = {}
    end
end)
