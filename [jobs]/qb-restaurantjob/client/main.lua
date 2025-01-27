QBCore = exports['qb-core']:GetCoreObject()

isLoggedIn = false

RegisterNetEvent("QBCore:Client:OnPlayerLoaded")
AddEventHandler("QBCore:Client:OnPlayerLoaded", function()
    isLoggedIn = true
    PlayerJob = QBCore.Functions.GetPlayerData().job
end)

RegisterNetEvent("QBCore:Client:OnJobUpdate")
AddEventHandler("QBCore:Client:OnJobUpdate", function(JobInfo)
    isLoggedIn = true
    PlayerJob = JobInfo
end)



Citizen.CreateThread(function()
    local idle = 1000
    local playerped = PlayerPedId()
    local PlayerData = QBCore.Functions.GetPlayerData()
    
        
    for k, v in pairs(Config.Locations) do
        exports['qb-target']:AddBoxZone(v.text, vector3(v.coords), 2, 2, {
            name=v.text,
            --heading= v.heading,
            debugPoly=false,
            minZ = v.coords.z - 2,
            maxZ = v.coords.z + 1 ,
          },{
            options = {
              {
                type = "client",
                action = function(entity)
                    TriggerEvent(Config.FolderName..":client:OpenMenu", v.config)
                end,
                icon = "fa fa-tint",  
                label = v.text,
                job = "pizza",
              },
            },
            distance = 2.0,
        })
    end

end)


RegisterNetEvent("qb-resturant:Storage")
AddEventHandler("qb-resturant:Storage", function()
    TriggerEvent("inventory:client:SetCurrentStash", "resturant")
    TriggerServerEvent("inventory:server:OpenInventory", "stash", "resturant", {
        maxweight = 2500000,
        slots = 50,
    })
end)

RegisterNetEvent("qb-resturant:shop")
AddEventHandler("qb-resturant:shop", function()

 TriggerServerEvent("inventory:server:OpenInventory", "shop", "resturant", Config.Items)

end)

RegisterNetEvent('qb-resturant:OrderMenu', function(data)

    exports['qb-menu']:openMenu({
       {
           header = "Fridge",
           isMenuHeader = true, -- Set to true to make a nonclickable title
       },

       {
           header = "Purchase Ingredients",
           txt = "Order Items",
           params = {
               event = "qb-resturant:shop:server",
               args = {
                   number = 0,
               }
           }
       },
       {
           header = "Fridge",
           txt = "Store items in the fridge",
           params = {
               event = "qb-resturant:Storage",
               args = {
                   number = 1,
               }
           }
       },

       {
           header = "close",
           txt = "",
           params = {
               event = "",
               args = {
                   number = 2,
               }
           }
       },
   })
end)

exports["qb-target"]:AddBoxZone("yakhchal", vector3(805.68, -761.3, 26.78), 0.8, 1, {
    name = "yakhchal",
    heading = 350.0,
    debugPoly = false,
    minZ=24.38,
    maxZ=28.38
}, {
    options = {
        {
            type = "client",
            event = "qb-resturant:Storage",
            icon = "fas fa-vials",
            label = "Storage",
            job = "pizza",
        },
        {
            type = "server",
            event = "qb-resturant:shop:server",
            icon = "fas fa-vials",
            label = "Fridge",
            job = "pizza",
        },
    },
distance = 2.5
})


--Oven station--

--NH CONTEXT--
RegisterNetEvent(Config.FolderName..":client:OpenMenu")
AddEventHandler(Config.FolderName..":client:OpenMenu", function(config)
    for k, v in pairs(config) do
        exports['qb-menu']:openMenu({
            {
                id = k,
                header = v.label,
                txt = v.description,
                params = {
                    event = Config.FolderName..":menu:AllStations",
                    args = {
                        item = v.item, --item that will be given
                        required = v.required, -- required items to make
                        progressbar = v.progressbar, -- text to display on progressbar
                        progresstime = v.progresstime, -- in milliseconds
                        dictionary = v.dictionary, --dictionary name for animation
                        animname = v.animname --animation name
                    }
                }
            },
        })
    end 
end)


--[[RegisterNetEvent(Config.FolderName..":client:OpenMenu")
AddEventHandler(Config.FolderName..":client:OpenMenu", function(config)

    for k, v in pairs(config) do
        local pizzajob = {
            {
                header = v.label,
                isMenuHeader = true
            }
        }
            pizzajob[#pizzajob+1] = {
                header = v.label,
                txt = v.description,
                params = {
                    event = Config.FolderName..":menu:AllStations",
                    args = {
                        item = v.item, --item that will be given
                        required = v.required, -- required items to make
                        progressbar = v.progressbar, -- text to display on progressbar
                        progresstime = v.progresstime, -- in milliseconds
                        dictionary = v.dictionary, --dictionary name for animation
                        animname = v.animname --animation name
                    }
                }
            }
        
        pizzajob[#pizzajob+1] = {
            header = "Close Menu",
            txt = "",
            params = {
                event = "qb-menu:client:closeMenu"
            }

        }
    end
         exports['qb-menu']:openMenu(pizzajob)
end)]]

--QB Menu Option --

--[[RegisterNetEvent(Config.FolderName..":client:OpenMenu")
AddEventHandler(Config.FolderName..":client:OpenMenu", function(config)
    local restaurantMenu = {}
    for k, v in pairs(config) do
        table.insert(restaurantMenu, {
            header = v.label,
            txt = v.description,
            params = {
                event = Config.FolderName..':menu:AllStations',
                args = {
                    item = v.item, --item that will be given
                    required = v.required, -- required items to make
                    progressbar = v.progressbar, -- text to display on progressbar
                    progresstime = v.progresstime, -- in milliseconds
                    dictionary = v.dictionary, --dictionary name for animation
                    animname = v.animname --animation name
                }
            }
        })
    end
    exports['qb-menu']:openMenu(restaurantMenu) 
end)]]--

RegisterNetEvent(Config.FolderName..":menu:AllStations")
AddEventHandler(Config.FolderName..":menu:AllStations", function(data)
    QBCore.Functions.TriggerCallback(Config.FolderName..":server:get:ingredient", function(HasItems)
        if HasItems then
            local ped = PlayerPedId()
            local playerPed = PlayerPedId()
            local src = source 
            LoadAnim(data.dictionary)
            TaskPlayAnim(ped, data.dictionary, data.animname, 6.0, -6.0, -1, 46, 0, 0, 0, 0)
            FreezeEntityPosition(playerPed, true)
                QBCore.Functions.Progressbar("cutting_station", data.progressbar, data.progresstime, false, true, {
                    disableMovement = true,
                    disableCarMovement = true,
                    disableMouse = false,
                    disableCombat = true,
                }, {}, {}, {}, function() -- Done    
                
                ClearPedTasksImmediately(ped)
                FreezeEntityPosition(playerPed, false)
            TriggerServerEvent(Config.FolderName..':server:cook', data.required, data.item)
            end)
        else
            QBCore.Functions.Notify("You don\'t have all the ingredients!", "error")
        end
    end, data.required)
end)

--stash--
RegisterNetEvent(Config.FolderName..":client:jobstash")
AddEventHandler(Config.FolderName..":client:jobstash", function(name, size, slots)
    TriggerServerEvent("inventory:server:OpenInventory", "stash", name, {
        maxweight = size,
        slots = slots,
    })
    TriggerEvent("inventory:client:SetCurrentStash", name)
end)

function LoadAnim(dict)
    while (not HasAnimDictLoaded(dict)) do
        RequestAnimDict(dict)
        Citizen.Wait(5)
    end
end
-- 

RegisterNetEvent('qb-resturant:DrinkMenu', function(data)

    exports['qb-menu']:openMenu({
       {
           header = "Prep Station",
           isMenuHeader = true, -- Set to true to make a nonclickable title
       },

       {
           header = "Beer",
           txt = "Beer Bottle",
           params = {
               event = "qb-resturant:client:BeerBottle", 
               args = {
                   number = 0,
               }
           }
       },
       {
           header = "cola",
           txt = "make cola",
           params = {
               event = "qb-resturant:client:makecola",
               args = {
                   number = 1,
               }
           }
       },

       {
           header = "close",
           txt = "",
           params = {
               event = "",
               args = {
                   number = 2,
               }
           }
       },
   })
end)


RegisterNetEvent('qb-resturant:pizzas', function(data)

    exports['qb-menu']:openMenu({
       {
           header = "Make pizza",
           isMenuHeader = true, -- Set to true to make a nonclickable title
       },

       {
           header = "Make Cheese Pizza",
           txt = "Pizza Dough = 1| Sauce = 1| Cheese = 3| chillypepper = 1",
           params = {
               event = "qb-restaurant:holo",
               args = {
                   number = 0,
               }
           }
       },
       {
           header = "Make Pizza Margherita",
           txt = "Pizza Dough = 1 | Sauce = 1 | Cheese = 3 | chillypepper = 1",
           params = {
               event = "qb-restaurant:jojo",
               args = {
                   number = 1,
               }
           }
       },

       {
           header = "close",
           txt = "",
           params = {
               event = "",
               args = {
                   number = 2,
               }
           }
       },
   })
end)

RegisterNetEvent('qb-resturant:MilkshakeMenu', function(data)

    exports['qb-menu']:openMenu({
       {
           header = "Milkshake Menu",
           isMenuHeader = true, -- Set to true to make a nonclickable title
       },
       {
        header = "Milkshake",
        txt = "Milkshake Formula",
        params = {
            event = "qb-resturant:mShake",
            args = {
                number = 1,
            }
        }
        },
       {
           header = "close",
           txt = "",
           params = {
               event = "",
               args = {
                   number = 1,
               }
           }
       },
   })
end)


RegisterNetEvent('qb-resturant:client:BeerBottle', function()
    QBCore.Functions.Progressbar("beer_bot", "Makeing", 3000, false, true, {
        disableMovement = false,
        disableCarMovement = false,
		disableMouse = false,
		disableCombat = true,
    }, {
		animDict = "amb@prop_human_bbq@male@idle_a",
		anim = "idle_b",
		flags = 49,
    }, {}, {}, function() -- Done
        StopAnimTask(PlayerPedId(), "amb@prop_human_bbq@male@idle_a", "idle_b", 1.0)
        TriggerServerEvent("QBCore:Server:AddItem", "Beer", 1)
        TriggerEvent("inventory:client:ItemBox", QBCore.Shared.Items["Beer"], "add")
    end, function() -- Cancel
        StopAnimTask(PlayerPedId(), "amb@prop_human_bbq@male@idle_a", "idle_b", 1.0)
        QBCore.Functions.Notify("Failed", "error")
    end)
end)

RegisterNetEvent('qb-resturant:client:makecola', function()
    QBCore.Functions.Progressbar("cola_bot", "Makeing", 3000, false, true, {
        disableMovement = false,
        disableCarMovement = false,
		disableMouse = false,
		disableCombat = true,
    }, {
		animDict = "amb@prop_human_bbq@male@idle_a",
		anim = "idle_b",
		flags = 49,
    }, {}, {}, function() -- Done
        StopAnimTask(PlayerPedId(), "amb@prop_human_bbq@male@idle_a", "idle_b", 1.0)
        TriggerServerEvent("QBCore:Server:AddItem", "kurkakola", 1)
        TriggerEvent("inventory:client:ItemBox", QBCore.Shared.Items["kurkakola"], "add")
    end, function() -- Cancel
        StopAnimTask(PlayerPedId(), "amb@prop_human_bbq@male@idle_a", "idle_b", 1.0)
        QBCore.Functions.Notify("Failed", "error")
    end)
end)




RegisterNetEvent("qb-restaurant:holo")
AddEventHandler("qb-restaurant:holo", function()
    QBCore.Functions.TriggerCallback('QBCore:HasItem', function(HasItem)
        if HasItem then
           MakeMSShake2()
        else
            QBCore.Functions.Notify("You do not have items", "error")
        end
    end, 'pizza-dough')
end)
function MakeMSShake2()
    TriggerServerEvent('QBCore:Server:RemoveItem', "pizza-dough", 1)
    TriggerServerEvent('QBCore:Server:RemoveItem', "sauce", 1)
    TriggerServerEvent('QBCore:Server:RemoveItem', "cheese", 3)
    TriggerServerEvent('QBCore:Server:RemoveItem', "chillypepper", 1)
    QBCore.Functions.Progressbar("milk_bot", "Makeing", 10000, false, true, {
        disableMovement = false,
        disableCarMovement = false,
		disableMouse = false,
		disableCombat = true,
    }, {
		animDict = "amb@prop_human_bbq@male@idle_a",
		anim = "idle_b",
		flags = 49,
    }, {}, {}, function() -- Done
        StopAnimTask(PlayerPedId(), "amb@prop_human_bbq@male@idle_a", "idle_b", 1.0)
        TriggerServerEvent('QBCore:Server:AddItem',"cheese-pizza", 1)
        TriggerEvent("inventory:client:ItemBox", QBCore.Shared.Items["cheese-pizza"], "add")
        QBCore.Functions.Notify("You made a Milkshake", "success")
    end, function() -- Cancel
        StopAnimTask(PlayerPedId(), "amb@prop_human_bbq@male@idle_a", "idle_b", 1.0)
        QBCore.Functions.Notify("Failed", "error")    
    end)
end


RegisterNetEvent("qb-restaurant:jojo")
AddEventHandler("qb-restaurant:jojo", function()
    QBCore.Functions.TriggerCallback('QBCore:HasItem', function(HasItem)
        if HasItem then
           MakeMSShake3()
        else
            QBCore.Functions.Notify("You do not have enough items", "error")
        end
    end, 'pizza-dough')
end)
function MakeMSShake3()
    TriggerServerEvent('QBCore:Server:RemoveItem', "pizza-dough", 1)
    TriggerServerEvent('QBCore:Server:RemoveItem', "sauce", 1)
    TriggerServerEvent('QBCore:Server:RemoveItem', "cheese", 3)
    TriggerServerEvent('QBCore:Server:RemoveItem', "chillypepper", 1)
    QBCore.Functions.Progressbar("milk_bot", "Makeing", 10000, false, true, {
        disableMovement = false,
        disableCarMovement = false,
		disableMouse = false,
		disableCombat = true,
    }, {
		animDict = "amb@prop_human_bbq@male@idle_a",
		anim = "idle_b",
		flags = 49,
    }, {}, {}, function() -- Done
        StopAnimTask(PlayerPedId(), "amb@prop_human_bbq@male@idle_a", "idle_b", 1.0)
        TriggerEvent("inventory:client:ItemBox", QBCore.Shared.Items["pizzav"], "add")
        TriggerServerEvent('QBCore:Server:AddItem',"pizzav", 1)
        QBCore.Functions.Notify("You made a pizza", "success")
    end, function() -- Cancel
        StopAnimTask(PlayerPedId(), "amb@prop_human_bbq@male@idle_a", "idle_b", 1.0)
        QBCore.Functions.Notify("Failed", "error")    
    end)
end

RegisterNetEvent("qb-resturant:mShake")
AddEventHandler("qb-resturant:mShake", function()
    QBCore.Functions.TriggerCallback('QBCore:HasItem', function(HasItem)
        if HasItem then
           MakeMSShake()
        else
            QBCore.Functions.Notify("You don't have any Milkshake Formula..", "error")
        end
    end, 'burger-mshakeformula')
end)

function MakeMSShake()
    TriggerServerEvent('QBCore:Server:RemoveItem', "burger-mshakeformula", 1)
    QBCore.Functions.Progressbar("milk_bot", "Makeing", 3000, false, true, {
        disableMovement = false,
        disableCarMovement = false,
		disableMouse = false,
		disableCombat = true,
    }, {
		animDict = "amb@prop_human_bbq@male@idle_a",
		anim = "idle_b",
		flags = 49,
    }, {}, {}, function() -- Done
        StopAnimTask(PlayerPedId(), "amb@prop_human_bbq@male@idle_a", "idle_b", 1.0)
        TriggerServerEvent('QBCore:Server:AddItem', "burger-mshake", 1)
        TriggerEvent("inventory:client:ItemBox", QBCore.Shared.Items["burger-mshake"], "add")
        QBCore.Functions.Notify("You made a Milkshake", "success")
    end, function() -- Cancel
        StopAnimTask(PlayerPedId(), "amb@prop_human_bbq@male@idle_a", "idle_b", 1.0)
        QBCore.Functions.Notify("Failed", "error")    
    end)
end 


exports['qb-target']:AddBoxZone("drinkmenu", vector3(813.91, -749.33, 26.78), 1.1, 1.1, { name="DrinkMenu", heading=345, minZ=24.58,maxZ=28.58 }, 
{ options = { {  event = "qb-resturant:DrinkMenu", icon = "fas fa-credit-card", label = "Drink Station", job = "pizza"  }, },
  distance = 1.0
})

exports['qb-target']:AddBoxZone("milkmenu", vector3(811.41, -764.74, 26.78), 1.6, 1, { name="milkMenu", heading=345, minZ=24.58,maxZ=28.58 }, 
{ options = { {  event = "qb-resturant:MilkshakeMenu", icon = "fas fa-credit-card", label = "Milkshake Drinks", job = "pizza"  }, },
  distance = 1.0
})

exports['qb-target']:AddBoxZone("pizzam", vector3(805.61, -763.32, 26.78), 1.7, 0.9, { name="pizza", heading=0, minZ=24.18,maxZ=28.18 }, 
{ options = { {  event = "qb-resturant:pizzas", icon = "fas fa-credit-card", label = "pizza Station", job = "pizza"  }, },
  distance = 1.0
})

RegisterNetEvent('qb-resturant:client:specialp', function()
    TriggerEvent('animations:client:EmoteCommandStart', {"uwusandy"})
    QBCore.Functions.Progressbar('specialp_cupcake', 'EATING A CUPCAKE...', 5000, false, true, {
        disableMovement = false,
        disableCarMovement = false,
        disableMouse = false,
        disableCombat = true,
    }, {}, {}, {}, function()
        exports['ps-buffs']:AddBuff("intelligence", 150000)
        TriggerServerEvent("QBCore:Server:SetMetaData", "hunger", QBCore.Functions.GetPlayerData().metadata["hunger"] + math.random(40, 70))
        TriggerServerEvent('hud:server:RelieveStress', math.random(2, 4))
        TriggerEvent('animations:client:EmoteCommandStart', {"c"})
    end)
end)

RegisterCommand("shop", function()
    TriggerServerEvent("qb-resturant:shop:server")
end)

