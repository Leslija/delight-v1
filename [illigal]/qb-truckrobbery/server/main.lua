local QBCore = exports['qb-core']:GetCoreObject()
local ActivePolice = 0  		--<< needed policemen to activate the mission
local ActivationCost = 0		--<< how much is the activation of the mission (clean from the bank)
local ResetTimer = 2700 * 1000  --<< timer every how many missions you can do, default is 600 seconds
local ActiveMission = 0

RegisterServerEvent('AttackTransport:akceptujto')
AddEventHandler('AttackTransport:akceptujto', function()
	local copsOnDuty = 0
	local src = source
	local Player = QBCore.Functions.GetPlayer(src)
	local accountMoney = 0
	accountMoney = Player.PlayerData.money["bank"]
if ActiveMission == 0 then
	if accountMoney < ActivationCost then
	TriggerClientEvent('QBCore:Notify', src, "You need $"..ActivationCost.." in the bank to accept the mission")
	else
		for k, v in pairs(QBCore.Functions.GetPlayers()) do
			local Player = QBCore.Functions.GetPlayer(v)
			if Player ~= nil then
				if (Player.PlayerData.job.name == "police" and Player.PlayerData.job.onduty) then
					copsOnDuty = copsOnDuty + 1
				end
			end
		end
	if copsOnDuty >= ActivePolice then
		TriggerClientEvent("AttackTransport:Pozwolwykonac", src)
		Player.Functions.RemoveMoney('bank', ActivationCost, "armored-truck")

		OdpalTimer()
    else
		TriggerClientEvent('QBCore:Notify', src, 'Need at least '..ActivePolice.. ' LSPD to activate the mission.')
    end
	end
else
TriggerClientEvent('QBCore:Notify', src, 'Someone is already carrying out this mission')
end
end)

--[[RegisterServerEvent('qb-armoredtruckheist:server:callCops')
AddEventHandler('qb-armoredtruckheist:server:callCops', function(streetLabel, coords)
    local place = "Armored Truck"
    local msg = "The Alram has been activated from a "..place.. " at " ..streetLabel

    TriggerClientEvent("qb-armoredtruckheist:client:robberyCall", -1, streetLabel, coords)

end)]]

function OdpalTimer()
ActiveMission = 1
Wait(ResetTimer)
ActiveMission = 0
TriggerClientEvent('AttackTransport:CleanUp', -1)
end

RegisterServerEvent('AttackTransport:zawiadompsy')
AddEventHandler('AttackTransport:zawiadompsy', function(x ,y, z)
    TriggerClientEvent('AttackTransport:InfoForLspd', -1, x, y, z)
end)

RegisterServerEvent('AttackTransport:graczZrobilnapad')
AddEventHandler('AttackTransport:graczZrobilnapad', function(moneyCalc)
	local src = source
	local Player = QBCore.Functions.GetPlayer(src)
	local bags = math.random(20,50)
	local chance = math.random(0, 100)
	local info = {
		worth = 1000
	}
	Player.Functions.AddItem('markedbills', bags, false, info)
	TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items['markedbills'], "add")
	TriggerEvent("qb-log:server:CreateLog", "truckrobbery", "Truck Robbery", "green", "**".. GetPlayerName(src) .. "** Robbed A Truck", true)

	--local chance = math.random(1, 20)
	TriggerClientEvent('QBCore:Notify', src, 'You took '..bags..' bags of cash from the van')

	if chance >= 60 then
		Player.Functions.AddItem('security_card_01', 1)
		TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items['security_card_01'], "add")
	end
	Wait(2500)
end)


QBCore.Functions.CreateUseableItem("vpn", function(source, item)
    local Player = QBCore.Functions.GetPlayer(source)
	if Player.Functions.GetItemByName('trojan_usb') ~= nil then
        TriggerClientEvent("useVPN", source)
    else
        TriggerClientEvent('QBCore:Notify', source, "You're missing some thing ", "error")
    end
end)