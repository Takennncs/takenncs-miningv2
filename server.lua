local cfg = require 'config'

local DISCORD_WEBHOOK = cfg.webhookURL 

local function sendToDiscord(title, message, color)
    local embed = {
        {
            ["title"] = title,
            ["description"] = message,
            ["type"] = "rich",
            ["color"] = color or 3447003,
            ["footer"] = {
                ["text"] = "BSF - takenncs Logs",
            },
            ["timestamp"] = os.date("!%Y-%m-%dT%H:%M:%SZ")
        }
    }

    PerformHttpRequest(DISCORD_WEBHOOK, function(err, text, headers) end, 'POST', json.encode({
        username = "Server Log",
        embeds = embed
    }), { ['Content-Type'] = 'application/json' })
end

lib.callback.register('takenncs-miningv2:receiveData', function(source)
    return cfg
end)

RegisterNetEvent('takenncs-miningv2:server:syncLocations', function()
    TriggerClientEvent('takenncs-miningv2:client:locationRefresh', -1, cfg.locations)
end)

lib.callback.register('takenncs-miningv2:foundOre', function(source, index)
    local loc = cfg.locations[index]
    if not loc then return false end

    loc.loots = (loc.loots or 0) + 1
    if loc.loots >= (loc.max_loots or 5) then
        loc.nextAvailable = GetCloudTimeAsInt() + 211
        loc.loots = 0
    end

    local item = cfg.ores[math.random(#cfg.ores)]
    exports.ox_inventory:AddItem(source, item, 1)
    TriggerClientEvent('takenncs-miningv2:client:locationRefresh', -1, cfg.locations)

    local playerName = GetPlayerName(source)
    local message = string.format("%s kaevandas itemi: **%s**\nKoordinaadid: x=%.2f, y=%.2f, z=%.2f", 
                                  playerName, item, loc.target.coords.x, loc.target.coords.y, loc.target.coords.z)
    sendToDiscord("takenncs-miningv2 Mining Event", message, 16776960) 

    return true
end)

RegisterNetEvent('takenncs-miningv2:server:sellOre', function(data) sellItem(data, source) end)
RegisterNetEvent('takenncs-miningv2:server:sellPanning', function(data) sellItem(data, source) end)
RegisterNetEvent('takenncs-miningv2:server:sellMining', function(data) sellItem(data, source) end)
