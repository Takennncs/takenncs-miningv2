local cfg = {}
local currentlyMining = false
local startedMiningAt = nil
local boxZones = {}
local spawnedRocks = {}
local ped = PlayerPedId()

local function loadModel(model)
    if type(model) == "string" then model = joaat(model) end
    RequestModel(model)
    while not HasModelLoaded(model) do Wait(0) end
    return model
end

local function hasValidTool()
    for toolName, _ in pairs(cfg.tools or {}) do
        local count = exports.ox_inventory:Search('count', toolName)
        if count and count > 0 then return toolName end
    end
    return nil
end

local function refreshZones()
    for _, zone in ipairs(boxZones) do exports.ox_target:removeZone(zone) end
    boxZones = {}

    if not cfg.locations then return end
    for i, loc in ipairs(cfg.locations) do
        local zone = exports.ox_target:addBoxZone({
            coords = loc.target.coords,
            size = loc.target.size,
            rotation = loc.target.rotation,
            debug = false,
            options = {{
                icon = 'fa-solid fa-gem',
                label = "Lõhu kivi",
                distance = 1.5,
                onSelect = function()
                    local now = GetCloudTimeAsInt()
                    local left = (loc.max_loots or 5) - (loc.loots or 0)
                    if loc.nextAvailable and loc.nextAvailable > now then
                        local secs = loc.nextAvailable - now
                        local min = math.floor(secs / 60)
                        local sec = secs % 60
                        TriggerEvent('TAKENNCS.UI.ShowNotification', 'error', cfg.texts.timer:format(min, sec))
                        return
                    end
                    if left <= 0 then
                        TriggerEvent('TAKENNCS.UI.ShowNotification', 'info', cfg.texts.cooldown)
                        return
                    end
                    if not hasValidTool() then
                        TriggerEvent('TAKENNCS.UI.ShowNotification', 'error', cfg.texts.noTool)
                        return
                    end
                    startMining(i)
                end,
                canInteract = function()
                    local now = GetCloudTimeAsInt()
                    local left = (loc.max_loots or 5) - (loc.loots or 0)
                    return not currentlyMining and not cache.vehicle and hasValidTool()
                        and (not loc.nextAvailable or loc.nextAvailable <= now) and left > 0
                end
            }}
        })
        table.insert(boxZones, zone)
    end
end

function startMining(index)
    currentlyMining = index
    local ped = PlayerPedId()
    local coords = cfg.locations[index].target.coords

    TaskTurnPedToFaceCoord(ped, coords, 1000)
    Wait(1000)

    lib.requestAnimDict('melee@large_wpn@streamed_core')
    TaskPlayAnim(ped, 'melee@large_wpn@streamed_core', 'plyr_weapon_attack', 8.0, 8.0, -1, 49, 0, 0, 0, 0)

    startedMiningAt = GetEntityCoords(ped)
    positionCheckLoop()
    miningLoop()
end

function miningLoop()
    CreateThread(function()
        local index = currentlyMining
        local loc = cfg.locations[index]
        
        lib.requestAnimDict('melee@large_wpn@streamed_core')
        TaskPlayAnim(ped, 'melee@large_wpn@streamed_core', 'ground_attack_on_spot', 8.0, 8.0, -1, 49, 0, 0, 0, 0)

        local success = lib.progressBar({
            duration = 3600,
            label = cfg.texts.mining,
            useWhileDead = false,
            canCancel = true,
            disable = {car=true, move=true, combat=true},
            anim = {dict='melee@large_wpn@streamed_core', clip='ground_attack_on_spot'}
        })
        if not success then 
            stopMining() 
            return 
        end

        local found = lib.callback.await('takenncs-miningv2:foundOre', false, index)
        if found then
            -- TriggerEvent('TAKENNCS.UI.ShowNotification', 'success', "Sa said midagi väärtuslikku!")
        else
            TriggerEvent('TAKENNCS.UI.ShowNotification', 'error', "Harjutamine teeb meistriks.")
        end

        loc.loots = (loc.loots or 0) + 1

        if loc.loots < (loc.max_loots or 5) then
            TriggerEvent('TAKENNCS.UI.ShowNotification', 'info', ("Kivi osa lõhutud: %d/%d"):format(loc.loots, loc.max_loots or 5))
            miningLoop() 
        else
            loc.nextAvailable = GetCloudTimeAsInt() + (loc.cooldown or 211) 
            TriggerEvent('TAKENNCS.UI.ShowNotification', 'info', cfg.texts.cooldown)
            loc.loots = 0 
            stopMining()
        end
    end)
end


function stopMining()
    ClearPedTasks(ped)
    currentlyMining = false
    startedMiningAt = nil
end

function positionCheckLoop()
    CreateThread(function()
        while currentlyMining do
            Wait(2000)
            local pos = GetEntityCoords(ped)
            if not startedMiningAt then
                stopMining()
                break
            elseif #(pos - startedMiningAt) > 1.5 then
                TriggerEvent('TAKENNCS.UI.ShowNotification', 'error', "Sa liigud liiga kaugele!")
            elseif not hasValidTool() then
                TriggerEvent('TAKENNCS.UI.ShowNotification', 'error', cfg.texts.noTool)
                stopMining()
                break
            end
        end
    end)
end

function DrawText3D(x, y, z, text, size, r, g, b, a)
    local onScreen, _x, _y = World3dToScreen2d(x, y, z)
    local px, py, pz = table.unpack(GetGameplayCamCoord())
    local dist = #(vec3(px, py, pz) - vec3(x, y, z))
    local scale = (size or 1.0) / (dist * 0.7)
    scale = math.min(math.max(scale,0.25),1.5)
    if onScreen then
        SetTextScale(0.0, scale)
        SetTextFont(0)
        SetTextProportional(1)
        SetTextColour(r or 255, g or 255, b or 255, a or 215)
        SetTextOutline()
        SetTextEntry("STRING")
        AddTextComponentString(text)
        DrawText(_x, _y)
    end
end

local function spawnRocks()
    for _, obj in pairs(spawnedRocks) do if DoesEntityExist(obj) then DeleteEntity(obj) end end
    spawnedRocks = {}
    for i, loc in ipairs(cfg.locations or {}) do
        local model = loadModel('prop_rock_4_d')
        local obj = CreateObject(model, loc.target.coords.x, loc.target.coords.y, loc.target.coords.z-1.0, false, false, false)
        SetEntityHeading(obj, loc.target.rotation or 0.0)
        FreezeEntityPosition(obj, true)
        PlaceObjectOnGroundProperly(obj)
        spawnedRocks[i] = obj
    end
end

RegisterNetEvent('takenncs-miningv2:client:locationRefresh', function(locations)
    cfg.locations = locations
    refreshZones()
    spawnRocks()
end)

CreateThread(function()
    cfg = lib.callback.await('takenncs-miningv2:receiveData', false)
    spawnRocks()
    refreshZones()
    local blip = AddBlipForCoord(cfg.blip.coords.x, cfg.blip.coords.y, cfg.blip.coords.z)
    SetBlipSprite(blip, cfg.blip.sprite)
    SetBlipDisplay(blip, 4)
    SetBlipScale(blip, cfg.blip.scale)
    SetBlipColour(blip, cfg.blip.colour)
    SetBlipAsShortRange(blip, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString(cfg.texts.blipName)
    EndTextCommandSetBlipName(blip)

    TriggerServerEvent('takenncs-miningv2:server:syncLocations')
end)

local function DrawText3D(x, y, z, text, scale, r, g, b, a)
    local onScreen, _x, _y = World3dToScreen2d(x, y, z)
    local px, py, pz = table.unpack(GetGameplayCamCoord())
    local dist = #(vec3(px, py, pz) - vec3(x, y, z))
    scale = (scale or 1.0) / (dist * 0.7)
    if scale < 0.25 then scale = 0.25 end
    if scale > 1.5 then scale = 1.5 end
    if onScreen then
        SetTextScale(0.0, scale)
        SetTextFont(0)
        SetTextProportional(1)
        SetTextColour(r or 255, g or 255, b or 255, a or 215)
        SetTextDropshadow(0, 0, 0, 0, 255)
        SetTextEdge(2, 0, 0, 0, 150)
        SetTextOutline()
        SetTextEntry("STRING")
        AddTextComponentString(text)
        DrawText(_x, _y)
    end
end

CreateThread(function()
    while true do
        Wait(0)
        if cfg and cfg.locations then
            local myPos = GetEntityCoords(PlayerPedId())
            for i, loc in ipairs(cfg.locations) do
                local pos = loc.target.coords
                local size = loc.target.size
                local dist = #(myPos - pos)
                if dist < 3.0 then
                    local now = GetCloudTimeAsInt()
                    local r, g, b = 0, 255, 0
                    local txt
                    if loc.nextAvailable and loc.nextAvailable > now then
                        r, g, b = 200, 80, 80
                        local secs = loc.nextAvailable - now
                        local min = math.floor(secs / 60)
                        local sec = secs % 60
                        txt = ("%02d:%02d"):format(min, sec)
                    else
                        local left = (loc.max_loots or 5) - (loc.loots or 0)
                        txt = ("%d/%d"):format(left, loc.max_loots or 5)
                    end
                    DrawText3D(pos.x, pos.y, pos.z + (size.z / 2) + 0.4, txt, 3.2, r, g, b, 215)
                end
            end
        end
    end
end)
