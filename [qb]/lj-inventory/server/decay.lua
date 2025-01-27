local QBCore = exports['qb-core']:GetCoreObject()

local TimeAllowed = 60 * 60 * 24 * 1 -- Maths for 1 day dont touch its very important and could break everything
function ConvertQuality(item)
	local StartDate = item.created
    local DecayRate = QBCore.Shared.Items[item.name:lower()]["decay"] ~= nil and QBCore.Shared.Items[item.name:lower()]["decay"] or 0.0
    if DecayRate == nil then
        DecayRate = 0
    end
    local TimeExtra = math.ceil((TimeAllowed * DecayRate))
    local percentDone = 100 - math.ceil((((os.time() - StartDate) / TimeExtra) * 100))
    if DecayRate == 0 then
        percentDone = 100
    end
    if percentDone < 0 then
        percentDone = 0
    end
    return percentDone
end

RegisterNetEvent('inventory:server:removeQuality', function(source, item)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local data = item
    if QBCore.Shared.Items[item.name:lower()]["created"] ~= nil and QBCore.Shared.Items[item.name:lower()]["created"] == "use" then
        local quality_use = 100
        if Player.PlayerData.items[data.slot].info ~= nil and Player.PlayerData.items[data.slot].info == "" and Player.PlayerData.items[data.slot].info.quality == nil then
            -- Player.PlayerData.items[data.slot].info.quality = 100 - (100/QBCore.Shared.Items[item.name:lower()]["decay"])
        else
            quality_use= Player.PlayerData.items[data.slot].info.quality - (100/QBCore.Shared.Items[item.name:lower()]["decay"])            
        end
        Player.PlayerData.items[data.slot].info = {quality = quality_use}
        Player.Functions.SetInventory(Player.PlayerData.items)
    end
end)

QBCore.Functions.CreateCallback('inventory:server:ConvertQuality', function(source, cb, inventory, other)
    local src = source
    local data = {}
    local Player = QBCore.Functions.GetPlayer(src)
    for k, item in pairs(inventory) do
        if item.created then
            if QBCore.Shared.Items[item.name:lower()]["decay"] ~= nil or QBCore.Shared.Items[item.name:lower()]["decay"] ~= 0 then
                if item.info then
		            if type(item.info) == "string" then
                        item.info = {}
                    end
                    if item.info.quality == nil then
                        item.info.quality = 100
                    end
                else
                    local info = {quality = 100}
                    item.info = info
                end
                local quality = ConvertQuality(item)
                if item.info.quality then
                    if quality < item.info.quality then
                        item.info.quality = quality
                    end
                else
                    item.info = {quality = quality}
                end
            else
                if item.info then 
                    item.info.quality = 100
                else
                    local info = {quality = 100}
                    item.info = info 
                end
            end
        end
    end
    if other then
        for k, item in pairs(other["inventory"]) do
            if item.created then
                if QBCore.Shared.Items[item.name:lower()]["decay"] ~= nil or QBCore.Shared.Items[item.name:lower()]["decay"] ~= 0 then
                    if item.info then 
                        if item.info.quality == nil then
                            item.info.quality = 100
                        end
                    else
                        local info = {quality = 100}
                        item.info = info
                    end
                    local quality = ConvertQuality(item)
                    if item.info.quality then
                        if quality < item.info.quality then
                            item.info.quality = quality
                        end
                    else
                        item.info = {quality = quality}
                    end
                else
                    if item.info then 
                        item.info.quality = 100
                    else
                        local info = {quality = 100}
                        item.info = info 
                    end
                end
            end
        end
    end
    Player.Functions.SetInventory(inventory)
    TriggerClientEvent("inventory:client:UpdatePlayerInventory", Player.PlayerData.source, false)
    data.inventory = inventory
    data.other = other
    cb(data)
end)
