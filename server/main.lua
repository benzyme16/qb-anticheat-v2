local QBCore = exports['qb-core']:GetCoreObject()

QBCore.Functions.CreateCallback('qb-anticheat:server:GetPermissions', function(source, cb)
    local group = QBCore.Functions.GetPermission(source)
    cb(group)
end)

-- Execute ban --

RegisterServerEvent("qb:resourcestop")
AddEventHandler("qb:resourcestop", function(res)
    local src = source
    DropPlayer(src, "qb2: You have been kicked for stopping the resource: "..res)
end)

RegisterNetEvent('qb-anticheat:server:banPlayer', function(reason)
    local src = source
    TriggerEvent("qb-log:server:CreateLog", "anticheat", "Anti-Cheat", "white", GetPlayerName(src).." has been banned for "..reason, false)
    exports.oxmysql:insert('INSERT INTO bans (name, license, discord, ip, reason, expire, bannedby) VALUES (?, ?, ?, ?, ?, ?, ?)', {
        GetPlayerName(src),
        QBCore.Functions.GetIdentifier(src, 'license'),
        QBCore.Functions.GetIdentifier(src, 'discord'),
        QBCore.Functions.GetIdentifier(src, 'ip'),
        reason,
        2145913200,
        'Anti-Cheat'
    })
    DropPlayer(src, "You have been banned for cheating. Check our Discord for more information: " .. QBCore.Config.Server.discord)
end)

-- Fake events --
function NonRegisteredEventCalled(CalledEvent, source)
    TriggerClientEvent("qb-anticheat:client:NonRegisteredEventCalled", source, "Cheating", CalledEvent)
end

for x, v in pairs(Config.BlacklistedEvents) do
    RegisterServerEvent(v)
    AddEventHandler(v, function(source)
        NonRegisteredEventCalled(v, source)
    end)
end

RegisterServerEvent('cocaLeaf:Pickup')
AddEventHandler('cocaLeaf:Pickup', function(source)
    NonRegisteredEventCalled('cocaLeaf:Pickup', source)
end)

RegisterServerEvent('npheist:reward')
AddEventHandler('npheist:reward', function(source)
    TriggerClientEvent("qba:screenshot", -1)
    NonRegisteredEventCalled('npheist:reward', source)
end)

QBCore.Functions.CreateCallback('qb-anticheat:server:HasWeaponInInventory', function(source, cb, WeaponInfo)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local PlayerInventory = Player.PlayerData.items
    local retval = false

    for k, v in pairs(PlayerInventory) do
        if v.name == WeaponInfo["name"] then
            retval = true
        end
    end
    cb(retval)
end)

if Config.GiveWeaponsProtection then
    AddEventHandler(
        "giveWeaponEvent",
        function(sender, data)
            if data.givenAsPickup == false then
                TriggerClientEvent("qba:screenshot", -1)
                TriggerEvent("qb-anticheat:server:banPlayer", "QB2, Tried to give weapons from mod menu")
                Citizen.Wait(50)
                DropPlayer(source, "qb2: You have been kicked from this server due to cheating.")
                CancelEvent()
            end
        end
    )
end

AddEventHandler(
    "explosionEvent",
    function(sender, ev)
        if ev.damageScale ~= 0.0 then
            if ev.explosionType == 29 then
                TriggerClientEvent("qba:screenshot", -1)
                TriggerEvent("qb-anticheat:server:banPlayer", "QB2, Blacklisted explosion detected")
                Citizen.Wait(10)
                DropPlayer(source, "QB2, Explosion detected")
                CancelEvent()
            end
        end
    end
)
