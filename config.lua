local cfg = {}

cfg.webhookURL = "https://discord.com/api/webhooks/" -- SINU WEBHOOK LOGIDE JAOKS!

cfg.tools = {
    ['pickaxe'] = true, -- Iitem millega minida - kirka, ox_inventory/data/items.lua
}

cfg.texts = {
    noTool = "Sul on midagi puudu!",
    mining = "Lõhud kivi..",
    cooldown = "Oota varsti saad uuesti süsteeme ajada.",
    timer = "%d:%02d",
    blipName = "Kivide lõhkumine",
}

cfg.blip = {
    coords = vec3(2956.14, 2785.51, 40.5),
    sprite = 273,
    colour = 16,
    scale = 0.9
}

cfg.locations = {
    {
        target = {
            coords = vec3(2923.7239, 2801.6472, 41.7299),
            size = vec3(2.0, 2.0, 2.0),
            rotation = 146.1098,
        },
        max_loots = 5,
        loots = 0,
        nextAvailable = nil,
    },
    {
        target = {
            coords = vec3(2972.0264, 2794.3074, 40.7081),
            size = vec3(2.0, 2.0, 2.0),
            rotation = 233.6774,
        },
        max_loots = 5,
        loots = 0,
        nextAvailable = nil,
    },
    {
        target = {
            coords = vec3(2970.9365, 2783.7534, 39.1756),
            size = vec3(2.0, 2.0, 2.0),
            rotation = 233.7354,
        },
        max_loots = 5,
        loots = 0,
        nextAvailable = nil,
    },
    {
        target = {
            coords = vec3(2947.6328, 2779.4731, 39.4406),
            size = vec3(2.0, 2.0, 2.0),
            rotation = 233.9296,
        },
        max_loots = 5,
        loots = 0,
        nextAvailable = nil,
    },
    {
        target = {
            coords = vec3(2939.1887, 2767.5513, 39.9063),
            size = vec3(2.0, 2.0, 2.0),
            rotation = 233.9422,
        },
        max_loots = 5,
        loots = 0,
        nextAvailable = nil,
    },
    {
        target = {
            coords = vec3(2932.3425, 2787.0271, 39.6306),
            size = vec3(2.0, 2.0, 2.0),
            rotation = 233.9771,
        },
        max_loots = 5,
        loots = 0,
        nextAvailable = nil,
    },
    {
        target = {
            coords = vec3(2926.1494, 2798.1990, 41.1359),
            size = vec3(2.0, 2.0, 2.0),
            rotation = 233.9998,
        },
        max_loots = 5,
        loots = 0,
        nextAvailable = nil,
    },
    {
        target = {
            coords = vec3(2949.4512, 2834.2109, 46.8461),
            size = vec3(2.0, 2.0, 2.0),
            rotation = 306.0814,
        },
        max_loots = 5,
        loots = 0,
        nextAvailable = nil,
    }
}

cfg.ores = { "iron_ore", "copper_ore", "gold_nugget", "silver_nugget" } -- Iitem mida miningust saab, - ox_inventory/data/items.lua

return cfg
