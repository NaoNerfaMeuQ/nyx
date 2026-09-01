---@diagnostic disable: undefined-global, lowercase-global, undefined-field

-- ============================================================
--  MAC_Fun_Script v2.1.0 - NewWay Enhanced
--  Stunt Tracks, Mega Arenas, Player Attachments, Online Cutscenes,
--  Session Weather & Halloween, Fast Timelapse, Area Chaos & Kamikaze Enemy Jets
-- ============================================================

natives.load_natives()

-- -- Notification Helper ---------------------------------------

local notify = {
    success = function(title, msg)
        pcall(function()
            if gui and gui.show_message then gui.show_message(title, tostring(msg)) end
            if log and log.info then log.info("[" .. title .. "] " .. tostring(msg)) end
            print("[" .. title .. "] " .. tostring(msg))
        end)
    end,
    info = function(title, msg)
        pcall(function()
            if gui and gui.show_message then gui.show_message(title, tostring(msg)) end
            if log and log.info then log.info("[" .. title .. "] " .. tostring(msg)) end
            print("[" .. title .. "] " .. tostring(msg))
        end)
    end,
    warn = function(title, msg)
        pcall(function()
            if gui and gui.show_message then gui.show_message(title, tostring(msg)) end
            if log and log.warning then log.warning("[" .. title .. "] " .. tostring(msg))
            elseif log and log.info then log.info("[WARN][" .. title .. "] " .. tostring(msg)) end
            print("[WARN][" .. title .. "] " .. tostring(msg))
        end)
    end,
    error = function(title, msg)
        pcall(function()
            if gui and gui.show_message then gui.show_message(title, tostring(msg)) end
            if log and log.error then log.error("[" .. title .. "] " .. tostring(msg))
            elseif log and log.warning then log.warning("[ERROR][" .. title .. "] " .. tostring(msg))
            elseif log and log.info then log.info("[ERROR][" .. title .. "] " .. tostring(msg)) end
            print("[ERROR][" .. title .. "] " .. tostring(msg))
        end)
    end
}

-- -- Configuration & State -------------------------------------

local state = {
    status = "Script loaded",
    player_name = "-",
    player_rank = 0,
    wanted_level = 0,
    position = "-"
}

local liftHeight = 10.0      -- Meters to lift
local launchForce = 150.0    -- Speed/Force for launching (m/s)
local holdDistance = 12.0    -- Distance in front of camera in hold mode
local igniteOnLaunch = false -- Ignite vehicle when thrown
local makeInvincible = true  -- Keep vehicle invulnerable while manipulating
local disableRagdoll = false -- Disable player ped ragdoll

local isHoldingVehicle = false
local heldVehicle = nil

local isCarryingPlayer = false
local carriedPlayerPed = nil
local carryLoopActive = false

local spinPlayerVehActive = false
local spinPlayerVehLoopActive = false
local spinPlayerTargetVeh = nil

local spinAreaVehsActive = false
local spinAreaVehsLoopActive = false

local vortexActive = false
local vortexLoopActive = false

local ufoDiscoActive = false
local ufoDiscoLoopActive = false

local pushRepulsorActive = false
local pushRepulsorLoopActive = false
local pushForce = 85.0

local vehicleRainActive = false
local vehicleRainLoopActive = false

local vehicleShieldActive = false
local vehicleShieldLoopActive = false

local vehicleSnakeActive = false
local vehicleSnakeLoopActive = false

local zombiePedOutbreakActive = false
local zombiePedOutbreakLoopActive = false

local infiniteLevitateActive = false
local infiniteLevitateLoopActive = false
local levitatingVehicle = nil

local hotkeysEnabled = true
local hotkeyLoopActive = false

-- -- Inception Stunt Tracks & Ramps State ------------------------
local spawned_stunt_objects = {}
local is_spawning_stunt = false
local stunt_altitude = 100.0
local customSpawnDistance = 15.0
local customSpawnHeight = 0.0
local customSpawnYaw = 0.0
local customSpawnFreeze = true

-- -- Player Prop Attachment Suite Mechanics -------------------
local attached_player_props = {}
local selectedAttachmentPid = -1
local customAttachModelInput = "prop_mp_cone_01"
local customAttachBoneId = 24818
local attachPresetModeAll = false -- -1 = próprio jogador local

-- -- Kamikaze Enemy Jets State ---------------------------------
local selectedKamikazePid = -1
local kamikazeJetCount = 3

-- -- Airdrop Supply System State -------------------------------
local airdropLocationMode = 1 -- 1 = Você Mesmo, 2 = Na Frente (15m), 3 = No Waypoint, 4 = Jogador da Sessão
local selectedAirdropPid = -1
local airdropCrateType = 1 -- 1 = Suprimentos Táticos, 2 = Veículo Especial, 3 = Caixa Armadilha
local airdropCrateModelIdx = 1
local airdropCustomVehicleInput = "insurgent3"
local airdropVehicleIdx = 1

-- -- Ear Rape & Tremor de Tela State (Troll Sonoro e Terremoto) -
local selectedTrollAudioPid = -1
local isTrollAudioLoopActive = false
local trollAudioIntensity = 2 -- 1 = Médio, 2 = Intenso, 3 = Apocalíptico
local trollAudioWithLightning = true
local trollAudioWithFlashbang = true

-- -- Nyx P2P Peer Discovery & Non-Aggression Pact ---------------
local nyx_detected_users = {}
local nyx_confirmed_attack_pid = -1



local function get_local_pid()
    local pid = 0
    pcall(function()
        if PLAYER and PLAYER.PLAYER_ID then
            pid = PLAYER.PLAYER_ID()
        end
    end)
    return pid
end

local function get_player_name(pid)
    if pid == nil or pid < 0 then return "Nenhum" end
    local name = nil
    pcall(function()
        if PLAYER and PLAYER.GET_PLAYER_NAME then
            local n = PLAYER.GET_PLAYER_NAME(pid)
            if n and n ~= "" and n ~= "**Invalid**" then
                name = n
            end
        end
        if not name and players and players.get_name then
            name = players.get_name(pid)
        end
    end)
    return name or ("Player_" .. tostring(pid))
end

local function get_active_session_players()
    local list = {}
    for i = 0, 31 do
        local active = false
        pcall(function()
            if PLAYER and PLAYER.IS_PLAYER_PLAYING and PLAYER.IS_PLAYER_PLAYING(i) then
                active = true
            elseif NETWORK and NETWORK.NETWORK_IS_PLAYER_CONNECTED and NETWORK.NETWORK_IS_PLAYER_CONNECTED(i) then
                active = true
            end
        end)
        if active then
            table.insert(list, i)
        end
    end
    return list
end

local function refreshPlayerInfo()
    pcall(function()
        if players and players.get_local then
            local player = players.get_local()
            if player and player:is_valid() then
                state.player_name = player:get_name() or "-"
                state.player_rank = player:get_rank() or 0
                state.wanted_level = player:get_wanted_level() or 0
                local ped = player:get_ped()
                if ped and ENTITY and ENTITY.DOES_ENTITY_EXIST and ENTITY.DOES_ENTITY_EXIST(ped) then
                    local pos = ENTITY.GET_ENTITY_COORDS(ped, true)
                    state.position = string.format("%.1f, %.1f, %.1f", pos.x, pos.y, pos.z)
                end
            end
        end
    end)
end


-- -- Vector & Physics Helpers ----------------------------------

local function isValidEntity(entity)
    if not entity or type(entity) ~= "number" or entity <= 0 then return false end
    local ok, res = pcall(function() return ENTITY.DOES_ENTITY_EXIST(entity) end)
    return ok and res
end

local function getModelHash(modelName)
    if type(modelName) == "number" then return modelName end
    local hash = 0
    pcall(function()
        if joaat then hash = joaat(modelName)
        elseif util and util.joaat then hash = util.joaat(modelName)
        elseif MISC and MISC.GET_HASH_KEY then hash = MISC.GET_HASH_KEY(modelName)
        end
    end)
    return hash
end

local function safeCreateVehicle(modelName, x, y, z, heading)
    local hash = getModelHash(modelName)
    if hash == 0 then return nil end

    pcall(function() STREAMING.REQUEST_MODEL(hash) end)
    local timeout = 0
    while not STREAMING.HAS_MODEL_LOADED(hash) and timeout < 100 do
        script.yield(10)
        timeout = timeout + 1
    end

    local veh = nil
    pcall(function()
        veh = VEHICLE.CREATE_VEHICLE(hash, x, y, z, heading or 0.0, true, false, false)
    end)

    if isValidEntity(veh) then
        pcall(function()
            STREAMING.SET_MODEL_AS_NO_LONGER_NEEDED(hash)
            ENTITY.SET_ENTITY_AS_MISSION_ENTITY(veh, true, true)
        end)
        return veh
    end
    return nil
end

local function safeCreatePed(modelName, x, y, z, heading)
    local hash = getModelHash(modelName)
    if hash == 0 then return nil end

    pcall(function() STREAMING.REQUEST_MODEL(hash) end)
    local timeout = 0
    while not STREAMING.HAS_MODEL_LOADED(hash) and timeout < 100 do
        script.yield(10)
        timeout = timeout + 1
    end

    local pedEntity = nil
    pcall(function()
        pedEntity = PED.CREATE_PED(26, hash, x, y, z, heading or 0.0, true, false)
    end)

    if isValidEntity(pedEntity) then
        pcall(function()
            STREAMING.SET_MODEL_AS_NO_LONGER_NEEDED(hash)
            ENTITY.SET_ENTITY_AS_MISSION_ENTITY(pedEntity, true, true)
        end)
        return pedEntity
    end
    return nil
end

local function getControlOfEntity(entity)
    if not isValidEntity(entity) then return false end
    pcall(function()
        if NETWORK and NETWORK.NETWORK_HAS_CONTROL_OF_ENTITY then
            if not NETWORK.NETWORK_HAS_CONTROL_OF_ENTITY(entity) then
                if NETWORK.NETWORK_REQUEST_CONTROL_OF_ENTITY then
                    NETWORK.NETWORK_REQUEST_CONTROL_OF_ENTITY(entity)
                end
            end
        end
    end)
    return true
end

local function makePedAggressive(targetPed, targetEnemy)
    pcall(function()
        if not isValidEntity(targetPed) or not isValidEntity(targetEnemy) then return end
        getControlOfEntity(targetPed)

        pcall(function() TASK.CLEAR_PED_TASKS_IMMEDIATELY(targetPed) end)
        pcall(function() PED.SET_BLOCKING_OF_NON_TEMPORARY_EVENTS(targetPed, true) end)
        pcall(function() PED.SET_PED_CAN_RAGDOLL(targetPed, true) end)
        pcall(function() PED.SET_PED_KEEP_TASK(targetPed, true) end)

        pcall(function() PED.SET_PED_COMBAT_ABILITY(targetPed, 2) end)
        pcall(function() PED.SET_PED_COMBAT_RANGE(targetPed, 2) end)
        pcall(function() PED.SET_PED_COMBAT_MOVEMENT(targetPed, 3) end)
        pcall(function() PED.SET_PED_ALERTNESS(targetPed, 3) end)
        pcall(function() PED.SET_PED_HEARING_RANGE(targetPed, 100.0) end)
        pcall(function() PED.SET_PED_SEEING_RANGE(targetPed, 100.0) end)

        pcall(function() PED.SET_PED_COMBAT_ATTRIBUTES(targetPed, 46, true) end)
        pcall(function() PED.SET_PED_COMBAT_ATTRIBUTES(targetPed, 5, true) end)
        pcall(function() PED.SET_PED_COMBAT_ATTRIBUTES(targetPed, 0, false) end)
        pcall(function() PED.SET_PED_COMBAT_ATTRIBUTES(targetPed, 140, true) end)

        pcall(function()
            local playerGroup = PED.GET_PED_RELATIONSHIP_GROUP_HASH(targetEnemy)
            local zombieGroup = getModelHash("HATES_PLAYER")
            PED.SET_PED_RELATIONSHIP_GROUP_HASH(targetPed, zombieGroup)
            PED.SET_RELATIONSHIP_BETWEEN_GROUPS(5, zombieGroup, playerGroup)
            PED.SET_RELATIONSHIP_BETWEEN_GROUPS(5, playerGroup, zombieGroup)
        end)

        pcall(function()
            local zombieWeapons = { "WEAPON_NIGHTSTICK", "WEAPON_HATCHET", "WEAPON_BATTLEAXE", "WEAPON_KNIFE", "WEAPON_BAT" }
            local wName = zombieWeapons[math.random(#zombieWeapons)]
            local wHash = getModelHash(wName)
            WEAPON.GIVE_DELAYED_WEAPON_TO_PED(targetPed, wHash, 100, true)
            WEAPON.SET_CURRENT_PED_WEAPON(targetPed, wHash, true)
        end)

        pcall(function() TASK.TASK_COMBAT_PED(targetPed, targetEnemy, 0, 16) end)
    end)
end

local function updateRagdollState()
    pcall(function()
        local ped = PLAYER.PLAYER_PED_ID()
        if PED and PED.SET_PED_CAN_RAGDOLL then
            PED.SET_PED_CAN_RAGDOLL(ped, not disableRagdoll)
        end
    end)
end

local function safeSetInvincible(entity, state)
    if not isValidEntity(entity) then return end
    pcall(function()
        ENTITY.SET_ENTITY_INVINCIBLE(entity, state)
        if VEHICLE and VEHICLE.SET_VEHICLE_CAN_BE_VISIBLY_DAMAGED then
            VEHICLE.SET_VEHICLE_CAN_BE_VISIBLY_DAMAGED(entity, not state)
        end
    end)
end

local activeAnimDict = nil
local activeAnimName = nil

local function safePlayAnim(ped, dict, anim, flag)
    pcall(function()
        STREAMING.REQUEST_ANIM_DICT(dict)
    end)
    local timeout = 0
    while not STREAMING.HAS_ANIM_DICT_LOADED(dict) and timeout < 20 do
        script.yield(10)
        timeout = timeout + 1
    end
    pcall(function()
        TASK.TASK_PLAY_ANIM(ped, dict, anim, 8.0, -8.0, -1, flag or 49, 0, false, false, false)
        activeAnimDict = dict
        activeAnimName = anim
    end)
end

local function playCarryAnim()
    pcall(function()
        local ped = PLAYER.PLAYER_PED_ID()
        -- Hands up surrender animation
        safePlayAnim(ped, "random@arrests", "idle_2_hands_up", 49)
    end)
end

local function stopCarryAnim()
    pcall(function()
        local ped = PLAYER.PLAYER_PED_ID()
        if activeAnimDict and activeAnimName then
            TASK.STOP_ANIM_TASK(ped, activeAnimDict, activeAnimName, 3.0)
        end
        activeAnimDict = nil
        activeAnimName = nil
    end)
end

local function drawText3D(x, y, z, text)
    pcall(function()
        if GRAPHICS and GRAPHICS.SET_DRAW_ORIGIN then
            GRAPHICS.SET_DRAW_ORIGIN(x, y, z, 0)
        end
        HUD.SET_TEXT_SCALE(0.38, 0.38)
        HUD.SET_TEXT_FONT(0)
        HUD.SET_TEXT_PROPORTIONAL(true)
        HUD.SET_TEXT_COLOUR(255, 255, 255, 255)
        HUD.SET_TEXT_DROPSHADOW(0, 0, 0, 0, 255)
        HUD.SET_TEXT_EDGE(2, 0, 0, 0, 150)
        HUD.SET_TEXT_DROP_SHADOW()
        HUD.SET_TEXT_OUTLINE()
        HUD.SET_TEXT_CENTRE(true)
        
        pcall(function()
            if HUD.BEGIN_TEXT_COMMAND_DISPLAY_TEXT then
                HUD.BEGIN_TEXT_COMMAND_DISPLAY_TEXT("STRING")
                HUD.ADD_TEXT_COMPONENT_SUBSTRING_PLAYER_NAME(text)
                HUD.END_TEXT_COMMAND_DISPLAY_TEXT(0.0, 0.0)
            end
        end)

        if GRAPHICS and GRAPHICS.CLEAR_DRAW_ORIGIN then
            GRAPHICS.CLEAR_DRAW_ORIGIN()
        end
    end)
end

local function getCameraDirection()
    local rot = { x = 0.0, y = 0.0, z = 0.0 }
    pcall(function()
        if CAM and CAM.GET_GAMEPLAY_CAM_ROT then
            rot = CAM.GET_GAMEPLAY_CAM_ROT(2)
        end
    end)

    local cz = math.rad(rot.z)
    local cx = math.rad(rot.x)
    local num = math.abs(math.cos(cx))

    return {
        x = -math.sin(cz) * num,
        y = math.cos(cz) * num,
        z = math.sin(cx)
    }
end

local function getTargetVehicle(maxDist)
    maxDist = maxDist or 25.0
    local ped = PLAYER.PLAYER_PED_ID()
    if not isValidEntity(ped) then return nil end

    local pCoords = ENTITY.GET_ENTITY_COORDS(ped, true)
    local myVeh = PED.GET_VEHICLE_PED_IS_IN(ped, false)

    -- Primary: find closest vehicle in radius around player
    local veh = VEHICLE.GET_CLOSEST_VEHICLE(pCoords.x, pCoords.y, pCoords.z, maxDist, 0, 70)
    if isValidEntity(veh) and veh ~= myVeh then
        return veh
    end

    -- Secondary: ray search along player heading direction
    local heading = ENTITY.GET_ENTITY_HEADING(ped)
    local rad = math.rad(heading)
    local fwdX = -math.sin(rad)
    local fwdY = math.cos(rad)

    for i = 1, 5 do
        local cx = pCoords.x + fwdX * (i * 4.0)
        local cy = pCoords.y + fwdY * (i * 4.0)
        local fVeh = VEHICLE.GET_CLOSEST_VEHICLE(cx, cy, pCoords.z, 8.0, 0, 70)
        if isValidEntity(fVeh) and fVeh ~= myVeh then
            return fVeh
        end
    end

    return nil
end

local function getAllNearbyVehicles(radius)
    radius = radius or 90.0
    local foundVehicles = {}
    local addedMap = {}
    local ped = PLAYER.PLAYER_PED_ID()
    if not isValidEntity(ped) then return foundVehicles end
    local pCoords = ENTITY.GET_ENTITY_COORDS(ped, true)
    local myVeh = PED.GET_VEHICLE_PED_IS_IN(ped, false)

    -- 1. Pool nativa do NewWay / Framework
    pcall(function()
        if entities and entities.get_all_vehicles_as_handles then
            local allVehs = entities.get_all_vehicles_as_handles()
            if allVehs then
                for _, v in ipairs(allVehs) do
                    if isValidEntity(v) and v ~= myVeh then
                        local vPos = ENTITY.GET_ENTITY_COORDS(v, true)
                        local dx = pCoords.x - vPos.x
                        local dy = pCoords.y - vPos.y
                        local dz = pCoords.z - vPos.z
                        local dist = math.sqrt(dx * dx + dy * dy + dz * dz)
                        if dist <= radius and not addedMap[v] then
                            addedMap[v] = true
                            table.insert(foundVehicles, v)
                        end
                    end
                end
            end
        end
    end)

    -- 2. Varredura circular densa com flags completas (0 e 71)
    if #foundVehicles == 0 then
        local radii = { 8.0, 20.0, 40.0, 65.0, radius }
        for _, r in ipairs(radii) do
            local steps = math.max(8, math.floor(r / 3.5))
            for a = 0, steps - 1 do
                local angle = (a / steps) * (math.pi * 2)
                local sx = pCoords.x + math.cos(angle) * r
                local sy = pCoords.y + math.sin(angle) * r

                local veh = VEHICLE.GET_CLOSEST_VEHICLE(sx, sy, pCoords.z, 16.0, 0, 71)
                if not isValidEntity(veh) then
                    veh = VEHICLE.GET_CLOSEST_VEHICLE(sx, sy, pCoords.z, 16.0, 0, 0)
                end

                if isValidEntity(veh) and veh ~= myVeh and not addedMap[veh] then
                    addedMap[veh] = true
                    table.insert(foundVehicles, veh)
                end
            end
        end
    end

    return foundVehicles
end

local function detachVehicle(veh)
    if not isValidEntity(veh) then return end
    pcall(function()
        if ENTITY.IS_ENTITY_ATTACHED(veh) then
            ENTITY.DETACH_ENTITY(veh, true, true)
        end
        ENTITY.SET_ENTITY_COLLISION(veh, true, true)
        if ENTITY.SET_ENTITY_DYNAMIC then
            ENTITY.SET_ENTITY_DYNAMIC(veh, true)
        end
        pcall(function()
            if VEHICLE and VEHICLE.SET_VEHICLE_ON_GROUND_PROPERLY then
                VEHICLE.SET_VEHICLE_ON_GROUND_PROPERLY(veh)
            end
        end)
    end)
end

-- -- Telekinesis Loops & Modes --------------------------------

local function startSpinPlayerVehLoop()
    if spinPlayerVehLoopActive then return end
    spinPlayerVehLoopActive = true

    script.run_in_callback(function()
        notify.info("MAC_Fun_Script", "Player Vehicle Beyblade ENABLED! (Press F to Exit)")

        local initialPed = PLAYER.PLAYER_PED_ID()
        local initialVeh = PED.GET_VEHICLE_PED_IS_IN(initialPed, false)
        if isValidEntity(initialVeh) then
            spinPlayerTargetVeh = initialVeh
        end

        while spinPlayerVehActive do
            pcall(function()
                local playerPed = PLAYER.PLAYER_PED_ID()

                if not isValidEntity(spinPlayerTargetVeh) then
                    local veh = PED.GET_VEHICLE_PED_IS_IN(playerPed, false)
                    if isValidEntity(veh) then
                        spinPlayerTargetVeh = veh
                    end
                end

                if isValidEntity(spinPlayerTargetVeh) then
                    -- Check if player is inside the spinning vehicle and presses F (INPUT_VEH_EXIT = 75 / 23)
                    if PED.IS_PED_IN_VEHICLE(playerPed, spinPlayerTargetVeh, false) then
                        pcall(function()
                            PAD.DISABLE_CONTROL_ACTION(0, 75, true)
                            PAD.DISABLE_CONTROL_ACTION(0, 23, true)

                            if PAD.IS_DISABLED_CONTROL_JUST_PRESSED(0, 75) or PAD.IS_CONTROL_JUST_PRESSED(0, 75) or
                               PAD.IS_DISABLED_CONTROL_JUST_PRESSED(0, 23) or PAD.IS_CONTROL_JUST_PRESSED(0, 23) then
                                
                                -- Eject player cleanly beside the driver door
                                local pCoords = ENTITY.GET_ENTITY_COORDS(playerPed, true)
                                local heading = ENTITY.GET_ENTITY_HEADING(playerPed)
                                local rad = math.rad(heading + 90.0)
                                local ex = pCoords.x + math.cos(rad) * 2.5
                                local ey = pCoords.y + math.sin(rad) * 2.5

                                TASK.CLEAR_PED_TASKS_IMMEDIATELY(playerPed)
                                ENTITY.SET_ENTITY_COORDS_NO_OFFSET(playerPed, ex, ey, pCoords.z + 0.2, true, true, true)
                            end
                        end)
                    end

                    getControlOfEntity(spinPlayerTargetVeh)
                    safeSetInvincible(spinPlayerTargetVeh, true)

                    pcall(function()
                        ENTITY.SET_ENTITY_COLLISION(spinPlayerTargetVeh, true, true)
                        local vel = ENTITY.GET_ENTITY_VELOCITY(spinPlayerTargetVeh)
                        -- Mantém girando no chão sem afundar
                        local vz = 0.0
                        if vel.z > 1.5 then vz = vel.z * 0.5 end
                        ENTITY.SET_ENTITY_VELOCITY(spinPlayerTargetVeh, vel.x * 0.85, vel.y * 0.85, vz)
                        ENTITY.SET_ENTITY_ANGULAR_VELOCITY(spinPlayerTargetVeh, 0.0, 0.0, 55.0)
                    end)
                end
            end)

            script.yield(10)
        end

        if isValidEntity(spinPlayerTargetVeh) then
            safeSetInvincible(spinPlayerTargetVeh, false)
            pcall(function()
                ENTITY.SET_ENTITY_ANGULAR_VELOCITY(spinPlayerTargetVeh, 0.0, 0.0, 0.0)
            end)
        end
        spinPlayerTargetVeh = nil

        spinPlayerVehLoopActive = false
        spinPlayerVehActive = false
        notify.info("MAC_Fun_Script", "Player Vehicle Beyblade DISABLED!")
    end)
end

local function startSpinAreaVehsLoop()
    if spinAreaVehsLoopActive then return end
    spinAreaVehsLoopActive = true

    script.run_in_callback(function()
        notify.info("MAC_Fun_Script", "Area Vehicle Beyblade ENABLED!")

        while spinAreaVehsActive do
            pcall(function()
                local ped = PLAYER.PLAYER_PED_ID()
                local myVeh = PED.GET_VEHICLE_PED_IS_IN(ped, false)
                local vehicles = getAllNearbyVehicles(100.0)

                for _, veh in ipairs(vehicles) do
                    if isValidEntity(veh) and veh ~= myVeh then
                        getControlOfEntity(veh)
                        safeSetInvincible(veh, true)

                        pcall(function()
                            ENTITY.SET_ENTITY_COLLISION(veh, true, true)
                            local vel = ENTITY.GET_ENTITY_VELOCITY(veh)

                            -- Evita afundamento no chão: zero Z velocity em vez de força negativa
                            local vz = 0.0
                            if vel.z > 2.0 then
                                vz = vel.z * 0.5
                            end

                            -- Mantém o carro nivelado caso comece a capotar ou afundar
                            if VEHICLE and VEHICLE.IS_VEHICLE_ON_ALL_WHEELS and not VEHICLE.IS_VEHICLE_ON_ALL_WHEELS(veh) then
                                local rot = ENTITY.GET_ENTITY_ROTATION(veh, 2)
                                ENTITY.SET_ENTITY_ROTATION(veh, 0.0, 0.0, rot.z, 2, true)
                            end

                            ENTITY.SET_ENTITY_VELOCITY(veh, vel.x * 0.85, vel.y * 0.85, vz)
                            ENTITY.SET_ENTITY_ANGULAR_VELOCITY(veh, 0.0, 0.0, 50.0)
                        end)
                    end
                end
            end)

            script.yield(15)
        end

        spinAreaVehsLoopActive = false
        spinAreaVehsActive = false
        notify.info("MAC_Fun_Script", "Area Vehicle Beyblade DISABLED!")
    end)
end

local function startVortexLoop()
    if vortexLoopActive then return end
    vortexLoopActive = true

    script.run_in_callback(function()
        notify.info("MAC_Fun_Script", "Vehicle Vortex ENABLED!")
        local angleOffset = 0.0

        while vortexActive do
            pcall(function()
                local ped = PLAYER.PLAYER_PED_ID()
                local pCoords = ENTITY.GET_ENTITY_COORDS(ped, true)
                local myVeh = PED.GET_VEHICLE_PED_IS_IN(ped, false)

                angleOffset = angleOffset + 0.08
                if angleOffset > math.pi * 2 then angleOffset = 0.0 end

                for i = 0, 150 do
                    local rx = (i % 13) * 8.0 - 50.0
                    local ry = math.floor(i / 13) * 8.0 - 50.0
                    local veh = VEHICLE.GET_CLOSEST_VEHICLE(pCoords.x + rx, pCoords.y + ry, pCoords.z, 25.0, 0, 70)

                    if isValidEntity(veh) and veh ~= myVeh then
                        getControlOfEntity(veh)
                        safeSetInvincible(veh, true)

                        pcall(function()
                            local vCoords = ENTITY.GET_ENTITY_COORDS(veh, true)
                            local dx = vCoords.x - pCoords.x
                            local dy = vCoords.y - pCoords.y
                            local dist = math.sqrt(dx * dx + dy * dy)
                            if dist < 1.0 then dist = 1.0 end

                            local targetAngle = math.atan2(dy, dx) + 0.25
                            local targetRadius = math.min(dist + 0.3, 18.0)
                            local targetX = pCoords.x + math.cos(targetAngle) * targetRadius
                            local targetY = pCoords.y + math.sin(targetAngle) * targetRadius

                            local vx = (targetX - vCoords.x) * 6.0
                            local vy = (targetY - vCoords.y) * 6.0
                            local vz = 8.0 + math.sin(angleOffset + dist) * 4.0

                            ENTITY.SET_ENTITY_VELOCITY(veh, vx, vy, vz)
                            ENTITY.SET_ENTITY_ANGULAR_VELOCITY(veh, 5.0, 5.0, 20.0)
                        end)
                    end
                end
            end)

            script.yield(15)
        end

        vortexLoopActive = false
        vortexActive = false
        notify.info("MAC_Fun_Script", "Vehicle Vortex DISABLED!")
    end)
end

local function startUfoDiscoLoop()
    if ufoDiscoLoopActive then return end
    ufoDiscoLoopActive = true

    script.run_in_callback(function()
        notify.info("MAC_Fun_Script", "UFO Party Mode ENABLED!")

        while ufoDiscoActive do
            pcall(function()
                local ped = PLAYER.PLAYER_PED_ID()
                if not isValidEntity(ped) then return end
                local pCoords = ENTITY.GET_ENTITY_COORDS(ped, true)
                local myVeh = PED.GET_VEHICLE_PED_IS_IN(ped, false)

                for i = 0, 80 do
                    local rx = (i % 9) * 10.0 - 40.0
                    local ry = math.floor(i / 9) * 10.0 - 40.0
                    local veh = VEHICLE.GET_CLOSEST_VEHICLE(pCoords.x + rx, pCoords.y + ry, pCoords.z, 15.0, 0, 70)

                    if isValidEntity(veh) and veh ~= myVeh then
                        getControlOfEntity(veh)
                        safeSetInvincible(veh, true)

                        pcall(function()
                            local vCoords = ENTITY.GET_ENTITY_COORDS(veh, true)

                            -- Lift vehicle up under UFO tractor beam (z + 12m)
                            if (vCoords.z - pCoords.z) < 10.0 then
                                ENTITY.SET_ENTITY_VELOCITY(veh, 0.0, 0.0, 6.0)
                            else
                                ENTITY.SET_ENTITY_VELOCITY(veh, 0.0, 0.0, 0.5)
                            end

                            -- Spin vehicle like a flying saucer
                            ENTITY.SET_ENTITY_ANGULAR_VELOCITY(veh, 0.0, 0.0, 25.0)

                            -- UFO Disco Lights & Sirens
                            VEHICLE.SET_VEHICLE_SIREN(veh, true)
                            VEHICLE.SET_VEHICLE_LIGHTS(veh, 3)

                            -- Change Primary and Secondary Vehicle RGB Paint Colors
                            local r, g, b = math.random(0, 255), math.random(0, 255), math.random(0, 255)
                            pcall(function()
                                if VEHICLE.SET_VEHICLE_CUSTOM_PRIMARY_COLOUR then
                                    VEHICLE.SET_VEHICLE_CUSTOM_PRIMARY_COLOUR(veh, r, g, b)
                                end
                                if VEHICLE.SET_VEHICLE_CUSTOM_SECONDARY_COLOUR then
                                    VEHICLE.SET_VEHICLE_CUSTOM_SECONDARY_COLOUR(veh, 255 - r, 255 - g, 255 - b)
                                end
                            end)

                            -- Neon Disco Lights
                            if VEHICLE.SET_VEHICLE_NEON_ENABLED then
                                VEHICLE.SET_VEHICLE_NEON_ENABLED(veh, 0, true)
                                VEHICLE.SET_VEHICLE_NEON_ENABLED(veh, 1, true)
                                VEHICLE.SET_VEHICLE_NEON_ENABLED(veh, 2, true)
                                VEHICLE.SET_VEHICLE_NEON_ENABLED(veh, 3, true)
                                if VEHICLE.SET_VEHICLE_NEON_COLOUR then
                                    VEHICLE.SET_VEHICLE_NEON_COLOUR(veh, r, g, b)
                                end
                            end

                            -- Sound Horn Blast
                            pcall(function()
                                if AUDIO and AUDIO.START_VEHICLE_HORN then
                                    AUDIO.START_VEHICLE_HORN(veh, 300, 0, false)
                                end
                            end)
                        end)
                    end
                end
            end)

            script.yield(150)
        end

        ufoDiscoLoopActive = false
        ufoDiscoActive = false
        notify.info("MAC_Fun_Script", "UFO Party Mode DISABLED!")
    end)
end

local function startPushRepulsorLoop()
    if pushRepulsorLoopActive then return end
    pushRepulsorLoopActive = true

    script.run_in_callback(function()
        notify.info("MAC_Fun_Script", "Vehicle Repulsor ENABLED!")

        while pushRepulsorActive do
            pcall(function()
                local ped = PLAYER.PLAYER_PED_ID()
                if not isValidEntity(ped) then return end
                local pCoords = ENTITY.GET_ENTITY_COORDS(ped, true)
                local myVeh = PED.GET_VEHICLE_PED_IS_IN(ped, false)

                for i = 0, 80 do
                    local angle = (i / 80.0) * (math.pi * 2)
                    local distCheck = 5.0 + ((i % 5) * 6.0)
                    local cx = pCoords.x + math.cos(angle) * distCheck
                    local cy = pCoords.y + math.sin(angle) * distCheck

                    local veh = VEHICLE.GET_CLOSEST_VEHICLE(cx, cy, pCoords.z, 8.0, 0, 70)
                    if isValidEntity(veh) and veh ~= myVeh then
                        getControlOfEntity(veh)
                        local vc = ENTITY.GET_ENTITY_COORDS(veh, true)
                        local dx = vc.x - pCoords.x
                        local dy = vc.y - pCoords.y
                        local dist = math.sqrt(dx * dx + dy * dy)
                        if dist < 0.1 then dist = 0.1 end

                        if dist < 35.0 then
                            local force = (1.0 - (dist / 35.0)) * pushForce
                            pcall(function()
                                ENTITY.SET_ENTITY_VELOCITY(veh, (dx / dist) * force, (dy / dist) * force, 15.0)
                            end)
                        end
                    end
                end
            end)

            script.yield(50)
        end

        pushRepulsorLoopActive = false
        pushRepulsorActive = false
        notify.info("MAC_Fun_Script", "Vehicle Repulsor DISABLED!")
    end)
end

local function startVehicleRainLoop()
    if vehicleRainLoopActive then return end
    vehicleRainLoopActive = true

    script.run_in_callback(function()
        notify.info("MAC_Fun_Script", "Vehicle Rain ENABLED!")

        local rainModels = { "adder", "zentorno", "t20", "turismor", "osiris", "rhino", "bus", "panto" }

        while vehicleRainActive do
            pcall(function()
                local ped = PLAYER.PLAYER_PED_ID()
                local pCoords = ENTITY.GET_ENTITY_COORDS(ped, true)

                local rx = (math.random() * 60.0) - 30.0
                local ry = (math.random() * 60.0) - 30.0
                local rz = pCoords.z + 45.0

                local model = rainModels[math.random(#rainModels)]
                local veh = safeCreateVehicle(model, pCoords.x + rx, pCoords.y + ry, rz, math.random() * 360.0)

                if isValidEntity(veh) then
                    pcall(function()
                        safeSetInvincible(veh, true)
                        if igniteOnLaunch then
                            FIRE.ADD_EXPLOSION(pCoords.x + rx, pCoords.y + ry, rz, 3, 1.0, true, false, 0.0, false)
                        end
                        ENTITY.SET_ENTITY_VELOCITY(veh, 0.0, 0.0, -80.0)
                    end)
                end
            end)

            script.yield(300)
        end

        vehicleRainLoopActive = false
        vehicleRainActive = false
        notify.info("MAC_Fun_Script", "Vehicle Rain DISABLED!")
    end)
end

local function startVehicleShieldLoop()
    if vehicleShieldLoopActive then return end
    vehicleShieldLoopActive = true

    script.run_in_callback(function()
        notify.info("MAC_Fun_Script", "Orbital Vehicle Shield ENABLED!")

        local ped = PLAYER.PLAYER_PED_ID()
        local pCoords = ENTITY.GET_ENTITY_COORDS(ped, true)
        local shieldVehicles = {}

        for i = 1, 3 do
            local angle = (i - 1) * ((2 * math.pi) / 3)
            local sx = pCoords.x + math.cos(angle) * 7.5
            local sy = pCoords.y + math.sin(angle) * 7.5
            local sz = pCoords.z + 3.8

            local veh = safeCreateVehicle("rhino", sx, sy, sz, 0.0)
            if isValidEntity(veh) then
                table.insert(shieldVehicles, veh)
                safeSetInvincible(veh, true)
            end
        end

        local angle = 0.0
        while vehicleShieldActive do
            local p = PLAYER.PLAYER_PED_ID()
            local pc = ENTITY.GET_ENTITY_COORDS(p, true)
            angle = angle + 0.05

            local count = #shieldVehicles
            for idx, veh in ipairs(shieldVehicles) do
                if isValidEntity(veh) then
                    getControlOfEntity(veh)
                    safeSetInvincible(veh, true)

                    local vehAngle = angle + ((idx - 1) * ((2 * math.pi) / math.max(count, 1)))
                    local radius = 7.5
                    local targetX = pc.x + math.cos(vehAngle) * radius
                    local targetY = pc.y + math.sin(vehAngle) * radius
                    local targetZ = pc.z + 3.8

                    local vCoords = ENTITY.GET_ENTITY_COORDS(veh, true)
                    local vx = (targetX - vCoords.x) * 8.0
                    local vy = (targetY - vCoords.y) * 8.0
                    local vz = (targetZ - vCoords.z) * 8.0

                    pcall(function()
                        ENTITY.SET_ENTITY_VELOCITY(veh, vx, vy, vz)
                        ENTITY.SET_ENTITY_ANGULAR_VELOCITY(veh, 0.0, 0.0, 30.0)
                    end)
                end
            end

            script.yield(10)
        end

        for _, veh in ipairs(shieldVehicles) do
            if isValidEntity(veh) then
                pcall(function()
                    ENTITY.SET_ENTITY_AS_MISSION_ENTITY(veh, true, true)
                    ENTITY.DELETE_ENTITY(veh)
                end)
            end
        end

        vehicleShieldLoopActive = false
        vehicleShieldActive = false
        notify.info("MAC_Fun_Script", "Orbital Vehicle Shield DISABLED!")
    end)
end

local function setupBusBowling()
    script.run_in_callback(function()
        pcall(function()
            local ped = PLAYER.PLAYER_PED_ID()
            local pCoords = ENTITY.GET_ENTITY_COORDS(ped, true)
            local heading = ENTITY.GET_ENTITY_HEADING(ped)
            local rad = math.rad(heading)
            local fwdX = -math.sin(rad)
            local fwdY = math.cos(rad)
            local rightX = fwdY
            local rightY = -fwdX

            local busHash = getModelHash("bus")
            local pantoHash = getModelHash("panto")

            pcall(function() STREAMING.REQUEST_MODEL(busHash) end)
            pcall(function() STREAMING.REQUEST_MODEL(pantoHash) end)

            local timeout = 0
            while not STREAMING.HAS_MODEL_LOADED(busHash) and timeout < 50 do
                script.yield(10)
                timeout = timeout + 1
            end

            local busPositions = {
                { fwd = 35.0, side = 0.0 },
                { fwd = 42.0, side = -4.0 },
                { fwd = 42.0, side = 4.0 },
                { fwd = 49.0, side = -8.0 },
                { fwd = 49.0, side = 0.0 },
                { fwd = 49.0, side = 8.0 }
            }

            for _, pos in ipairs(busPositions) do
                local bx = pCoords.x + fwdX * pos.fwd + rightX * pos.side
                local by = pCoords.y + fwdY * pos.fwd + rightY * pos.side
                local bz = pCoords.z + 4.5

                local bus = nil
                pcall(function()
                    bus = VEHICLE.CREATE_VEHICLE(busHash, bx, by, bz, heading, true, false, false)
                end)

                if isValidEntity(bus) then
                    pcall(function()
                        ENTITY.SET_ENTITY_AS_MISSION_ENTITY(bus, true, true)
                        ENTITY.SET_ENTITY_ROTATION(bus, 90.0, 0.0, heading, 2, true)
                        ENTITY.SET_ENTITY_VELOCITY(bus, 0.0, 0.0, 0.0)
                    end)
                end
            end

            local px = pCoords.x + fwdX * 3.0
            local py = pCoords.y + fwdY * 3.0
            local pz = pCoords.z + 2.5

            local panto = nil
            pcall(function()
                panto = VEHICLE.CREATE_VEHICLE(pantoHash, px, py, pz, heading, true, false, false)
            end)

            if isValidEntity(panto) then
                pcall(function()
                    ENTITY.SET_ENTITY_AS_MISSION_ENTITY(panto, true, true)
                end)
                HoldVehicleLoop(panto)
            end

            notify.success("MAC_Fun_Script", "Vertical Bus Bowling Setup Complete! Launch Panto with SPACE.")
        end)
    end)
end

local function triggerBusFortressWall()
    script.run_in_callback(function()
        pcall(function()
            local ped = PLAYER.PLAYER_PED_ID()
            local pCoords = ENTITY.GET_ENTITY_COORDS(ped, true)
            local heading = ENTITY.GET_ENTITY_HEADING(ped)
            local rad = math.rad(heading)
            local fwdX = -math.sin(rad)
            local fwdY = math.cos(rad)
            local rightX = fwdY
            local rightY = -fwdX

            notify.info("MAC_Fun_Script", "Building organized bus fortress wall...")

            local busHash = getModelHash("bus")
            pcall(function() STREAMING.REQUEST_MODEL(busHash) end)

            local timeout = 0
            while not STREAMING.HAS_MODEL_LOADED(busHash) and timeout < 50 do
                script.yield(10)
                timeout = timeout + 1
            end

            local wallSpacing = 4.2
            local wallDist = 12.0
            local busHeading = heading + 90.0

            local columns = { -2.0, -1.0, 0.0, 1.0, 2.0 }

            for _, col in ipairs(columns) do
                local bx = pCoords.x + fwdX * wallDist + rightX * (col * wallSpacing)
                local by = pCoords.y + fwdY * wallDist + rightY * (col * wallSpacing)
                local bz = pCoords.z + 0.3

                local bus = nil
                pcall(function()
                    bus = VEHICLE.CREATE_VEHICLE(busHash, bx, by, bz, busHeading, true, false, false)
                end)

                if isValidEntity(bus) then
                    pcall(function()
                        ENTITY.SET_ENTITY_AS_MISSION_ENTITY(bus, true, true)
                        ENTITY.SET_ENTITY_HEADING(bus, busHeading)
                        VEHICLE.SET_VEHICLE_ON_GROUND_PROPERLY(bus)
                        safeSetInvincible(bus, true)
                    end)
                end
                script.yield(80)
            end

            notify.success("MAC_Fun_Script", "5-Bus Fortress Wall Built Successfully!")
        end)
    end)
end

local function startVehicleSnakeLoop()
    if vehicleSnakeLoopActive then return end
    vehicleSnakeLoopActive = true

    script.run_in_callback(function()
        local snakeVehicles = {}
        notify.info("MAC_Fun_Script", "Connecting vehicles to Follow the Leader...")

        while vehicleSnakeActive do
            local ped = PLAYER.PLAYER_PED_ID()
            local pCoords = ENTITY.GET_ENTITY_COORDS(ped, true)
            local myVeh = PED.GET_VEHICLE_PED_IS_IN(ped, false)

            local validCount = 0
            for _, v in ipairs(snakeVehicles) do
                if isValidEntity(v) then validCount = validCount + 1 end
            end

            if validCount < 5 then
                for i = 0, 100 do
                    local rx = (i % 11) * 6.0 - 30.0
                    local ry = math.floor(i / 11) * 6.0 - 30.0
                    local vCandidate = VEHICLE.GET_CLOSEST_VEHICLE(pCoords.x + rx, pCoords.y + ry, pCoords.z, 20.0, 0, 70)

                    if isValidEntity(vCandidate) and vCandidate ~= myVeh then
                        local alreadyIn = false
                        for _, existing in ipairs(snakeVehicles) do
                            if existing == vCandidate then alreadyIn = true break end
                        end
                        if not alreadyIn then
                            table.insert(snakeVehicles, vCandidate)
                            if #snakeVehicles >= 5 then break end
                        end
                    end
                end
            end

            for idx, veh in ipairs(snakeVehicles) do
                if isValidEntity(veh) then
                    getControlOfEntity(veh)
                    safeSetInvincible(veh, true)

                    local targetX = pCoords.x - (idx * 5.0)
                    local targetY = pCoords.y
                    local targetZ = pCoords.z + 2.5

                    local vCoords = ENTITY.GET_ENTITY_COORDS(veh, true)
                    local vx = (targetX - vCoords.x) * 4.0
                    local vy = (targetY - vCoords.y) * 4.0
                    local vz = (targetZ - vCoords.z) * 4.0

                    pcall(function()
                        ENTITY.SET_ENTITY_VELOCITY(veh, vx, vy, vz)
                    end)
                end
            end

            script.yield(15)
        end

        vehicleSnakeLoopActive = false
        vehicleSnakeActive = false
        notify.info("MAC_Fun_Script", "Follow the Leader DISABLED!")
    end)
end

local function startZombiePedOutbreakLoop()
    if zombiePedOutbreakLoopActive then return end
    zombiePedOutbreakLoopActive = true

    script.run_in_callback(function()
        notify.success("MAC_Fun_Script", "Zombie Outbreak ENABLED! Spawning 15 aggressive zombies!")

        local zombieHash = getModelHash("u_m_y_zombie_01")
        pcall(function() STREAMING.REQUEST_MODEL(zombieHash) end)

        local timeout = 0
        while not STREAMING.HAS_MODEL_LOADED(zombieHash) and timeout < 50 do
            script.yield(10)
            timeout = timeout + 1
        end

        local spawnedZombies = {}
        local targetZombieCount = 15

        while zombiePedOutbreakActive do
            pcall(function()
                local playerPed = PLAYER.PLAYER_PED_ID()
                local pCoords = ENTITY.GET_ENTITY_COORDS(playerPed, true)

                local validZombies = {}
                for _, zPed in ipairs(spawnedZombies) do
                    if isValidEntity(zPed) and not PED.IS_PED_INJURED(zPed) then
                        table.insert(validZombies, zPed)
                    else
                        if isValidEntity(zPed) then
                            pcall(function()
                                ENTITY.SET_ENTITY_AS_MISSION_ENTITY(zPed, true, true)
                                ENTITY.DELETE_ENTITY(zPed)
                            end)
                        end
                    end
                end
                spawnedZombies = validZombies

                while #spawnedZombies < targetZombieCount and zombiePedOutbreakActive do
                    local angle = (#spawnedZombies * (2 * math.pi / targetZombieCount)) + (math.random() * 0.5)
                    local dist = 10.0 + (math.random() * 8.0)
                    local zx = pCoords.x + math.cos(angle) * dist
                    local zy = pCoords.y + math.sin(angle) * dist
                    local zz = pCoords.z + 1.0

                    local zPed = safeCreatePed("u_m_y_zombie_01", zx, zy, zz, 0.0)
                    if isValidEntity(zPed) then
                        table.insert(spawnedZombies, zPed)
                        makePedAggressive(zPed, playerPed)
                    end
                    script.yield(10)
                end

                for _, zPed in ipairs(spawnedZombies) do
                    if isValidEntity(zPed) and not PED.IS_PED_INJURED(zPed) then
                        pcall(function()
                            getControlOfEntity(zPed)
                            local zc = ENTITY.GET_ENTITY_COORDS(zPed, true)
                            local pc = ENTITY.GET_ENTITY_COORDS(playerPed, true)
                            local dist = math.sqrt((zc.x - pc.x)^2 + (zc.y - pc.y)^2 + (zc.z - pc.z)^2)

                            if dist > 2.5 then
                                TASK.TASK_GO_TO_ENTITY(zPed, playerPed, -1, 1.0, 4.0, 1073741824, 0)
                            else
                                TASK.TASK_COMBAT_PED(zPed, playerPed, 0, 16)
                            end
                        end)
                    end
                end
            end)

            script.yield(300)
        end

        for _, zPed in ipairs(spawnedZombies) do
            if isValidEntity(zPed) then
                pcall(function()
                    ENTITY.SET_ENTITY_AS_MISSION_ENTITY(zPed, true, true)
                    ENTITY.DELETE_ENTITY(zPed)
                end)
            end
        end

        zombiePedOutbreakLoopActive = false
        zombiePedOutbreakActive = false
        notify.info("MAC_Fun_Script", "Zombie Outbreak DISABLED!")
    end)
end

local function startInfiniteLevitateLoop()
    if infiniteLevitateLoopActive then return end
    infiniteLevitateLoopActive = true

    script.run_in_callback(function()
        notify.info("MAC_Fun_Script", "Area Bounce Mode ENABLED!")
        local direction = 1
        local currentHeight = 0.0

        while infiniteLevitateActive do
            pcall(function()
                local ped = PLAYER.PLAYER_PED_ID()
                local pCoords = ENTITY.GET_ENTITY_COORDS(ped, true)
                local myVeh = PED.GET_VEHICLE_PED_IS_IN(ped, false)

                currentHeight = currentHeight + (0.5 * direction)
                if currentHeight > 15.0 then
                    direction = -1
                elseif currentHeight < 0.5 then
                    direction = 1
                end

                for i = 0, 150 do
                    local rx = (i % 13) * 8.0 - 50.0
                    local ry = math.floor(i / 13) * 8.0 - 50.0

                    local veh = VEHICLE.GET_CLOSEST_VEHICLE(pCoords.x + rx, pCoords.y + ry, pCoords.z, 25.0, 0, 70)
                    if isValidEntity(veh) and veh ~= myVeh then
                        getControlOfEntity(veh)
                        safeSetInvincible(veh, true)

                        pcall(function()
                            local vCoords = ENTITY.GET_ENTITY_COORDS(veh, true)
                            local targetZ = pCoords.z + currentHeight + 2.0
                            local vz = (targetZ - vCoords.z) * 3.0
                            ENTITY.SET_ENTITY_VELOCITY(veh, 0.0, 0.0, vz)
                        end)
                    end
                end
            end)

            script.yield(20)
        end

        infiniteLevitateLoopActive = false
        infiniteLevitateActive = false
        notify.info("MAC_Fun_Script", "Infinite Bounce Mode DISABLED!")
    end)
end

local function LiftVehicle(veh, height)
    if not isValidEntity(veh) then return end
    getControlOfEntity(veh)
    if makeInvincible then safeSetInvincible(veh, true) end

    pcall(function()
        local vCoords = ENTITY.GET_ENTITY_COORDS(veh, true)
        ENTITY.SET_ENTITY_VELOCITY(veh, 0.0, 0.0, 18.0)
    end)
    state.status = "Vehicle lifted (" .. tostring(math.floor(height or 18)) .. "m)"
end

local function LaunchVehicle(veh, force)
    if not isValidEntity(veh) then return end
    getControlOfEntity(veh)

    pcall(function()
        detachVehicle(veh)
        safeSetInvincible(veh, false)
        ENTITY.SET_ENTITY_COLLISION(veh, true, true)
        if ENTITY.SET_ENTITY_DYNAMIC then
            ENTITY.SET_ENTITY_DYNAMIC(veh, true)
        end

        local camDir = getCameraDirection()
        local vx = camDir.x * force
        local vy = camDir.y * force
        local vz = camDir.z * force + 15.0

        if igniteOnLaunch then
            local vCoords = ENTITY.GET_ENTITY_COORDS(veh, true)
            FIRE.ADD_EXPLOSION(vCoords.x, vCoords.y, vCoords.z, 3, 1.0, true, false, 0.0, false)
        end

        ENTITY.SET_ENTITY_VELOCITY(veh, vx, vy, vz)
        ENTITY.SET_ENTITY_ANGULAR_VELOCITY(veh, 10.0, 5.0, 0.0)
    end)
    state.status = "Vehicle launched"
end

local function SlamVehicle(veh)
    if not isValidEntity(veh) then return end
    getControlOfEntity(veh)
    pcall(function()
        ENTITY.SET_ENTITY_COLLISION(veh, true, true)
        if ENTITY.SET_ENTITY_DYNAMIC then
            ENTITY.SET_ENTITY_DYNAMIC(veh, true)
        end
        ENTITY.SET_ENTITY_VELOCITY(veh, 0.0, 0.0, -150.0)
    end)
    state.status = "Vehicle slammed down"
end

local function SpinVehicle(veh)
    if not isValidEntity(veh) then return end
    getControlOfEntity(veh)
    pcall(function() ENTITY.SET_ENTITY_ANGULAR_VELOCITY(veh, 0.0, 0.0, 25.0) end)
    state.status = "Vehicle spinning"
end

local function HoldVehicleLoop(veh)
    if isHoldingVehicle then
        isHoldingVehicle = false
        if isValidEntity(heldVehicle) then
            detachVehicle(heldVehicle)
            safeSetInvincible(heldVehicle, false)
            pcall(function() ENTITY.SET_ENTITY_VELOCITY(heldVehicle, 0.0, 0.0, -2.0) end)
        end
        heldVehicle = nil
        state.status = "Vehicle released"
        notify.info("MAC_Fun_Script", "Vehicle released.")
        return
    end

    if not isValidEntity(veh) then
        state.status = "No target vehicle found"
        notify.warn("MAC_Fun_Script", "No nearby target vehicle found!")
        return
    end

    isHoldingVehicle = true
    heldVehicle = veh
    state.status = "Holding vehicle above head"
    notify.success("MAC_Fun_Script", "Vehicle held above head! Press SPACE to launch or E to release.")

    script.run_in_callback(function()
        playCarryAnim()
        getControlOfEntity(heldVehicle)

        local ped = PLAYER.PLAYER_PED_ID()

        -- Enable full entity collision world-wide while ignoring collision specifically with player ped
        pcall(function()
            ENTITY.SET_ENTITY_COLLISION(heldVehicle, true, true)
            if ENTITY.SET_ENTITY_NO_COLLISION_ENTITY then
                ENTITY.SET_ENTITY_NO_COLLISION_ENTITY(heldVehicle, ped, false)
            end
        end)

        if makeInvincible then
            safeSetInvincible(heldVehicle, true)
        end

        while isHoldingVehicle and isValidEntity(heldVehicle) do
            getControlOfEntity(heldVehicle)

            local pCoords = ENTITY.GET_ENTITY_COORDS(ped, true)
            local pHeading = ENTITY.GET_ENTITY_HEADING(ped)

            local rad = math.rad(pHeading)
            local dirX = -math.sin(rad)
            local dirY =  math.cos(rad)

            local targetX = pCoords.x + (dirX * 0.1)
            local targetY = pCoords.y + (dirY * 0.1)
            local targetZ = pCoords.z + 1.25

            pcall(function() ENTITY.SET_ENTITY_COORDS_NO_OFFSET(heldVehicle, targetX, targetY, targetZ, true, true, true) end)
            pcall(function() ENTITY.SET_ENTITY_HEADING(heldVehicle, pHeading) end)
            pcall(function() ENTITY.SET_ENTITY_VELOCITY(heldVehicle, 0.0, 0.0, 0.0) end)
            pcall(function() ENTITY.SET_ENTITY_ANGULAR_VELOCITY(heldVehicle, 0.0, 0.0, 0.0) end)

            drawText3D(pCoords.x, pCoords.y, targetZ + 1.15, "~g~[SPACE]~w~ Launch  |  ~r~[E]~w~ Release")

            pcall(function()
                if activeAnimDict and activeAnimName then
                    if not PED.IS_ENTITY_PLAYING_ANIM(ped, activeAnimDict, activeAnimName, 3) then
                        safePlayAnim(ped, activeAnimDict, activeAnimName, 49)
                    end
                end
            end)

            pcall(function()
                PAD.DISABLE_CONTROL_ACTION(0, 22, true)
                PAD.DISABLE_CONTROL_ACTION(0, 38, true)
                PAD.DISABLE_CONTROL_ACTION(0, 51, true)
            end)

            if PAD and (PAD.IS_DISABLED_CONTROL_JUST_PRESSED(0, 22) or PAD.IS_CONTROL_JUST_PRESSED(0, 22)) then
                local target = heldVehicle
                isHoldingVehicle = false
                heldVehicle = nil
                LaunchVehicle(target, launchForce)
                notify.success("MAC_Fun_Script", "Vehicle LAUNCHED!")
                break
            end

            if PAD and (
                PAD.IS_DISABLED_CONTROL_JUST_PRESSED(0, 38) or PAD.IS_CONTROL_JUST_PRESSED(0, 38) or
                PAD.IS_DISABLED_CONTROL_JUST_PRESSED(0, 51) or PAD.IS_CONTROL_JUST_PRESSED(0, 51)
            ) then
                local target = heldVehicle
                isHoldingVehicle = false
                heldVehicle = nil
                detachVehicle(target)
                safeSetInvincible(target, false)
                state.status = "Vehicle released"
                notify.info("MAC_Fun_Script", "Vehicle released.")
                break
            end

            script.yield(0)
        end

        isHoldingVehicle = false
        heldVehicle = nil
        stopCarryAnim()
    end)
end

-- -- Player Carry In Arms (Carregar no Colo) -------------------

local function getTargetPlayerPed(maxDist)
    maxDist = maxDist or 70.0
    local localPed = PLAYER.PLAYER_PED_ID()
    local localPid = get_local_pid()

    -- 1. Se estiver mirando livremente em alguém
    local aimedPed = nil
    pcall(function()
        if PLAYER and PLAYER.GET_ENTITY_PLAYER_IS_FREE_AIMING_AT then
            local res, ent = PLAYER.GET_ENTITY_PLAYER_IS_FREE_AIMING_AT(localPid)
            if res and isValidEntity(ent) and ENTITY.IS_ENTITY_A_PED(ent) then
                aimedPed = ent
            end
        end
    end)
    if isValidEntity(aimedPed) and aimedPed ~= localPed then
        return aimedPed
    end

    -- 2. Jogador selecionado na lista
    if selectedAttachmentPid and selectedAttachmentPid ~= -1 and selectedAttachmentPid ~= localPid then
        local pPed = 0
        pcall(function()
            if PLAYER and PLAYER.GET_PLAYER_PED_SCRIPT_INDEX then
                pPed = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(selectedAttachmentPid)
            elseif PLAYER and PLAYER.GET_PLAYER_PED then
                pPed = PLAYER.GET_PLAYER_PED(selectedAttachmentPid)
            end
        end)
        if isValidEntity(pPed) and pPed ~= localPed then
            return pPed
        end
    end

    -- 3. Jogador mais próximo na frente da câmera
    local pCoords = ENTITY.GET_ENTITY_COORDS(localPed, true)
    local camDir = getCameraDirection()
    local bestPed = nil
    local bestScore = 9999.0

    for i = 0, 31 do
        if i ~= localPid then
            local tPed = 0
            pcall(function()
                if PLAYER and PLAYER.GET_PLAYER_PED_SCRIPT_INDEX then
                    tPed = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(i)
                elseif PLAYER and PLAYER.GET_PLAYER_PED then
                    tPed = PLAYER.GET_PLAYER_PED(i)
                end
            end)
            if isValidEntity(tPed) and not PED.IS_PED_DEAD_OR_DYING(tPed, true) then
                local tCoords = ENTITY.GET_ENTITY_COORDS(tPed, true)
                local dx = tCoords.x - pCoords.x
                local dy = tCoords.y - pCoords.y
                local dz = tCoords.z - pCoords.z
                local dist = math.sqrt(dx*dx + dy*dy + dz*dz)
                if dist <= maxDist then
                    local dot = (dx/dist)*camDir.x + (dy/dist)*camDir.y + (dz/dist)*camDir.z
                    if dot > 0.35 then
                        local score = dist * (2.0 - dot)
                        if score < bestScore then
                            bestScore = score
                            bestPed = tPed
                        end
                    end
                end
            end
        end
    end

    return bestPed
end

local function stopCarryingPlayer()
    if not isCarryingPlayer and not carryLoopActive then return end
    isCarryingPlayer = false
    carryLoopActive = false

    local myPed = PLAYER.PLAYER_PED_ID()

    if isValidEntity(carriedPlayerPed) then
        pcall(function()
            getControlOfEntity(carriedPlayerPed)
            if ENTITY.IS_ENTITY_ATTACHED_TO_ENTITY(carriedPlayerPed, myPed) then
                ENTITY.DETACH_ENTITY(carriedPlayerPed, true, true)
            end
            PED.SET_BLOCKING_OF_NON_TEMPORARY_EVENTS(carriedPlayerPed, false)
            PED.SET_PED_CAN_RAGDOLL(carriedPlayerPed, true)
            TASK.CLEAR_PED_TASKS_IMMEDIATELY(carriedPlayerPed)
            ENTITY.SET_ENTITY_COLLISION(carriedPlayerPed, true, true)
            PED.SET_PED_TO_RAGDOLL(carriedPlayerPed, 1000, 1000, 0, false, false, false)
        end)
    end

    pcall(function()
        TASK.CLEAR_PED_TASKS(myPed)
    end)

    carriedPlayerPed = nil
    state.status = "Player released"
    notify.info("MAC_Fun_Script", "Jogador solto do colo.")
end

local function startCarryingPlayer(targetPed)
    if isCarryingPlayer then
        stopCarryingPlayer()
        return
    end

    if not isValidEntity(targetPed) then
        targetPed = getTargetPlayerPed()
    end

    if not isValidEntity(targetPed) then
        notify.warn("MAC_Fun_Script", "Nenhum jogador encontrado na mira ou selecionado!")
        return
    end

    isCarryingPlayer = true
    carriedPlayerPed = targetPed
    carryLoopActive = true
    notify.success("MAC_Fun_Script", "Carregando jogador no colo! Pressione E para soltar.")

    script.run_in_callback(function()
        local myPed = PLAYER.PLAYER_PED_ID()

        local carrierDict = "anim@heists@box_carry@"
        local carrierAnim = "idle"
        pcall(function() STREAMING.REQUEST_ANIM_DICT(carrierDict) end)

        local carriedDict = "dead"
        local carriedAnim = "dead_d"
        pcall(function() STREAMING.REQUEST_ANIM_DICT(carriedDict) end)

        local t = 0
        while (not STREAMING.HAS_ANIM_DICT_LOADED(carrierDict) or not STREAMING.HAS_ANIM_DICT_LOADED(carriedDict)) and t < 40 do
            script.yield(10)
            t = t + 1
        end

        pcall(function()
            TASK.TASK_PLAY_ANIM(myPed, carrierDict, carrierAnim, 8.0, -8.0, -1, 49, 0, false, false, false)
        end)

        pcall(function()
            getControlOfEntity(carriedPlayerPed)
            ENTITY.SET_ENTITY_COLLISION(carriedPlayerPed, false, false)
            PED.SET_PED_CAN_RAGDOLL(carriedPlayerPed, false)
            PED.SET_BLOCKING_OF_NON_TEMPORARY_EVENTS(carriedPlayerPed, true)
            PED.SET_PED_KEEP_TASK(carriedPlayerPed, true)
            TASK.CLEAR_PED_TASKS_IMMEDIATELY(carriedPlayerPed)
            TASK.TASK_PLAY_ANIM(carriedPlayerPed, carriedDict, carriedAnim, 8.0, -8.0, -1, 33, 0, false, false, false)

            local spineBone = getPedBoneIndexSafe(myPed, 24818)
            local attOk = false
            pcall(function()
                ENTITY.ATTACH_ENTITY_TO_ENTITY(
                    carriedPlayerPed,
                    myPed,
                    spineBone,
                    0.25, 0.40, -0.10,
                    0.0, 90.0, 90.0,
                    false, false, false, true, 2, true
                )
                attOk = true
            end)
            if not attOk then
                pcall(function()
                    ENTITY.ATTACH_ENTITY_TO_ENTITY(
                        carriedPlayerPed,
                        myPed,
                        spineBone,
                        0.25, 0.40, -0.10,
                        0.0, 90.0, 90.0,
                        false, false, false, true, 0, true, 0
                    )
                end)
            end
        end)

        while isCarryingPlayer and isValidEntity(carriedPlayerPed) do
            myPed = PLAYER.PLAYER_PED_ID()

            pcall(function()
                if not PED.IS_ENTITY_PLAYING_ANIM(myPed, carrierDict, carrierAnim, 3) then
                    TASK.TASK_PLAY_ANIM(myPed, carrierDict, carrierAnim, 8.0, -8.0, -1, 49, 0, false, false, false)
                end
                if not PED.IS_ENTITY_PLAYING_ANIM(carriedPlayerPed, carriedDict, carriedAnim, 3) then
                    TASK.TASK_PLAY_ANIM(carriedPlayerPed, carriedDict, carriedAnim, 8.0, -8.0, -1, 33, 0, false, false, false)
                end
            end)

            local myPos = ENTITY.GET_ENTITY_COORDS(myPed, true)
            drawText3D(myPos.x, myPos.y, myPos.z + 1.15, "~r~[E]~w~ Soltar Jogador do Colo")

            pcall(function()
                PAD.DISABLE_CONTROL_ACTION(0, 38, true)
                PAD.DISABLE_CONTROL_ACTION(0, 51, true)
            end)

            if PAD and (
                PAD.IS_DISABLED_CONTROL_JUST_PRESSED(0, 38) or PAD.IS_CONTROL_JUST_PRESSED(0, 38) or
                PAD.IS_DISABLED_CONTROL_JUST_PRESSED(0, 51) or PAD.IS_CONTROL_JUST_PRESSED(0, 51)
            ) then
                stopCarryingPlayer()
                break
            end

            script.yield(0)
        end

        stopCarryingPlayer()
    end)
end

-- -- Hotkey & 3D Prompt Background Worker -------------------------

local function startHotkeyLoop()
    if hotkeyLoopActive then return end
    hotkeyLoopActive = true

    script.run_in_callback(function()
        local cachedTargetVeh = nil
        local lastSearchTime = 0

        while hotkeysEnabled do
            pcall(function()
                local ped = PLAYER.PLAYER_PED_ID()

                if not isHoldingVehicle and isValidEntity(ped) and not PED.IS_PED_IN_ANY_VEHICLE(ped, false) then
                    local now = MISC.GET_GAME_TIMER()
                    if (now - lastSearchTime) > 100 then
                        lastSearchTime = now
                        cachedTargetVeh = getTargetVehicle(25.0)
                    end

                    if isValidEntity(cachedTargetVeh) then
                        local pCoords = ENTITY.GET_ENTITY_COORDS(ped, true)
                        drawText3D(pCoords.x, pCoords.y, pCoords.z + 1.15, "Press ~g~[E]~w~ to grab vehicle")

                        pcall(function()
                            PAD.DISABLE_CONTROL_ACTION(0, 38, true)
                            PAD.DISABLE_CONTROL_ACTION(0, 51, true)
                        end)

                        if PAD and (
                            PAD.IS_DISABLED_CONTROL_JUST_PRESSED(0, 38) or PAD.IS_CONTROL_JUST_PRESSED(0, 38) or
                            PAD.IS_DISABLED_CONTROL_JUST_PRESSED(0, 51) or PAD.IS_CONTROL_JUST_PRESSED(0, 51)
                        ) then
                            local targetToHold = cachedTargetVeh
                            cachedTargetVeh = nil
                            HoldVehicleLoop(targetToHold)
                        end
                    end
                end

                if disableRagdoll then
                    updateRagdollState()
                end
            end)

            script.yield(10)
        end
        hotkeyLoopActive = false
    end)
end

-- -- Inception Stunt Tracks & Stand Model Mechanics -------------

local stand_models_db = {
    -- Arena 4X Mega Tubos
    { name = "ar_prop_ar_tube_4x_l", hash = 0x5BC89B48, label = "Tubo 4X Longo" },
    { name = "ar_prop_ar_tube_4x_m", hash = 0xEBE4BDD6, label = "Tubo 4X Médio" },
    { name = "ar_prop_ar_tube_4x_s", hash = 0xC7F5B6FB, label = "Tubo 4X Curto" },
    { name = "ar_prop_ar_tube_4x_speed", hash = 0x3CA2D305, label = "Tubo 4X Speed Boost" },
    { name = "ar_prop_ar_tube_4x_crn", hash = 0xAA6E8DE3, label = "Tubo 4X Curva 90°" },
    { name = "ar_prop_ar_tube_4x_crn_30d", hash = 0xE8B76378, label = "Tubo 4X Curva 30°" },
    { name = "ar_prop_ar_tube_4x_gap_02", hash = 0x93309605, label = "Tubo 4X Gap Aberto" },
    -- Arena 2X Tubos
    { name = "ar_prop_ar_tube_2x_l", hash = 0x4B3A8B17, label = "Tubo 2X Longo" },
    { name = "ar_prop_ar_tube_2x_m", hash = 0x90B3B5B8, label = "Tubo 2X Médio" },
    { name = "ar_prop_ar_tube_2x_speed", hash = 0x309C874C, label = "Tubo 2X Speed Boost" },
    { name = "ar_prop_ar_tube_2x_crn", hash = 0x62955EEF, label = "Tubo 2X Curva 90°" },
    { name = "ar_prop_ar_tube_2x_gap_02", hash = 0x8DFB26BE, label = "Tubo 2X Gap Aberto" },
    -- Arena Tubos Standard & Especiais
    { name = "ar_prop_ar_tube_l", hash = 0x9B25007D, label = "Tubo Standard Longo" },
    { name = "ar_prop_ar_tube_speed", hash = 0xCA10FD05, label = "Tubo Standard Speed" },
    { name = "ar_prop_ar_tube_cross", hash = 0x5D52DCFF, label = "Tubo Cruzamento (+)" },
    { name = "ar_prop_ar_tube_fork", hash = 0xB71CEEEF, label = "Tubo Bifurcação (Y)" },
    { name = "ar_prop_ar_tube_jmp", hash = 0xA474F821, label = "Tubo Rampa de Salto" },
    -- Portais Neon & Luzes (8X, 4X & Padrão)
    { name = "ar_prop_ar_neon_gate8x_01a", hash = 0x815A2BE4, label = "Portal Neon 8X (Estilo 1)" },
    { name = "ar_prop_ar_neon_gate8x_02a", hash = 0x826D46F0, label = "Portal Neon 8X (Estilo 2)" },
    { name = "ar_prop_ar_neon_gate8x_03a", hash = 0x0E1D1F65, label = "Portal Neon 8X (Estilo 3)" },
    { name = "ar_prop_ar_neon_gate4x_01a", hash = 0x24AEAC73, label = "Portal Neon 4X (Estilo 1)" },
    { name = "ar_prop_ar_neon_gate4x_02a", hash = 0x48D8FE6A, label = "Portal Neon 4X (Estilo 2)" },
    { name = "ar_prop_ar_neon_gate_01a",   hash = 0x2DEB36D2, label = "Portal Neon Standard (1)" },
    { name = "ar_prop_ar_neon_gate_02a",   hash = 0xF593C174, label = "Portal Neon Standard (2)" },
    -- Anéis de Velocidade, Loops & Checkpoints
    { name = "ar_prop_ar_speed_ring", hash = 0x2E6FA41A, label = "Anel de Velocidade (Speed Ring)" },
    { name = "ar_prop_ar_jump_loop", hash = 0x1F22315E, label = "Mega Loop Acrobático" },
    { name = "ar_prop_ar_hoop_med_01", hash = 0xF940428B, label = "Aro / Hoop Médio" },
    { name = "ar_prop_ar_cp_tower8x_01a", hash = 0x6DAA1727, label = "Mega Torre 8X Checkpoint" },
    { name = "ar_prop_ar_cp_tower4x_01a", hash = 0xAA6E8D01, label = "Torre 4X Checkpoint" },
    { name = "ar_prop_ar_start_01a", hash = 0xC88CF19E, label = "Pórtico de Largada (Start)" },
    { name = "ar_prop_ar_checkpoint_l", hash = 0x644B29BE, label = "Checkpoint Grande" },
    -- Setas de Neon, Sinais & Rampas
    { name = "ar_prop_ar_arrow_wide_xl", hash = 0x446CEFF9, label = "Seta Neon Larga XL" },
    { name = "ar_prop_ar_arrow_thin_xl", hash = 0x315C5E6D, label = "Seta Neon Fina XL" },
    { name = "ar_prop_ar_ammu_sign", hash = 0xE2FFAB8E, label = "Placa Neon Ammu-Nation" },
    { name = "ar_prop_ar_jetski_ramp_01_dev", hash = 0xC6EB66C8, label = "Rampa Jetski Arena" },
    { name = "ar_prop_ar_bblock_huge_01", hash = 0x8C090CD0, label = "Mega Bloco Arena 01" },
    { name = "ar_prop_ar_bblock_huge_02", hash = 0xC263CA2D, label = "Mega Bloco Arena 02" },
    { name = "ar_prop_ar_stunt_block_01a", hash = 0xAE193798, label = "Bloco Stunt Arena" },
    -- Iate & Portas Especiais
    { name = "apa_prop_yacht_float_1a", hash = 0x51D2A887, label = "Bóia Flutuante Iate 1A" },
    { name = "apa_prop_yacht_float_1b", hash = 0xA10846F1, label = "Bóia Flutuante Iate 1B" },
    { name = "apa_prop_yacht_glass_01", hash = 0x36DB7E63, label = "Vidro do Iate 01" },
    { name = "apa_v_ilev_fh_heistdoor1", hash = 0x1E5E6A49, label = "Porta Cofre Heist 1" },
    { name = "apa_v_ilev_fh_heistdoor2", hash = 0x38261DDC, label = "Porta Cofre Heist 2" },
    { name = "apa_v_ilev_ss_door2", hash = 0x99773EC2, label = "Porta Submarino 2" }
}

local stunt_highway_preset = {
    { model = "stt_prop_stunt_track_straight", rel_x = 0.0,    rel_y = -300.0, rel_z = 0.0, yaw = 0.0 },
    { model = "stt_prop_stunt_track_straight", rel_x = 0.0,    rel_y = -150.0, rel_z = 0.0, yaw = 0.0 },
    { model = "stt_prop_stunt_track_straight", rel_x = 0.0,    rel_y = 0.0,    rel_z = 0.0, yaw = 0.0 },
    { model = "stt_prop_stunt_track_straight", rel_x = 0.0,    rel_y = 150.0,  rel_z = 0.0, yaw = 0.0 },
    { model = "stt_prop_stunt_track_straight", rel_x = 0.0,    rel_y = 300.0,  rel_z = 0.0, yaw = 0.0 },
    { model = "stt_prop_stunt_track_dloop",    rel_x = 0.0,    rel_y = 450.0,  rel_z = 20.0, yaw = 0.0 },
    { model = "stt_prop_stunt_track_dwuturn",  rel_x = 150.0,  rel_y = 450.0,  rel_z = 0.0, yaw = 90.0 },
    { model = "stt_prop_stunt_tube_l",         rel_x = -150.0, rel_y = 0.0,    rel_z = 10.0, yaw = 0.0 },
    { model = "stt_prop_stunt_jump_l",         rel_x = 0.0,    rel_y = -400.0, rel_z = -5.0, yaw = 180.0 },
    { model = "stt_prop_stunt_track_straight", rel_x = 150.0,  rel_y = 150.0,  rel_z = 0.0, yaw = 90.0 },
    { model = "stt_prop_stunt_track_straight", rel_x = -150.0, rel_y = 150.0,  rel_z = 0.0, yaw = 90.0 }
}

local cyber_arena_highway_preset = {
    { model = "ar_prop_ar_start_01a", rel_x = 0.0, rel_y = -360.0, rel_z = 0.0, yaw = 0.0 },
    { model = "ar_prop_ar_tube_4x_l", rel_x = 0.0, rel_y = -300.0, rel_z = 0.0, yaw = 0.0 },
    { model = "ar_prop_ar_neon_gate8x_01a", rel_x = 0.0, rel_y = -220.0, rel_z = 0.0, yaw = 0.0 },
    { model = "ar_prop_ar_tube_4x_speed", rel_x = 0.0, rel_y = -150.0, rel_z = 0.0, yaw = 0.0 },
    { model = "ar_prop_ar_speed_ring", rel_x = 0.0, rel_y = -80.0, rel_z = 0.0, yaw = 0.0 },
    { model = "ar_prop_ar_tube_4x_l", rel_x = 0.0, rel_y = 0.0, rel_z = 0.0, yaw = 0.0 },
    { model = "ar_prop_ar_neon_gate8x_02a", rel_x = 0.0, rel_y = 80.0, rel_z = 0.0, yaw = 0.0 },
    { model = "ar_prop_ar_tube_4x_speed", rel_x = 0.0, rel_y = 150.0, rel_z = 0.0, yaw = 0.0 },
    { model = "ar_prop_ar_speed_ring", rel_x = 0.0, rel_y = 220.0, rel_z = 0.0, yaw = 0.0 },
    { model = "ar_prop_ar_tube_4x_crn", rel_x = 0.0, rel_y = 300.0, rel_z = 0.0, yaw = 0.0 },
    { model = "ar_prop_ar_tube_4x_l", rel_x = 80.0, rel_y = 380.0, rel_z = 0.0, yaw = 90.0 },
    { model = "ar_prop_ar_neon_gate8x_03a", rel_x = 160.0, rel_y = 380.0, rel_z = 0.0, yaw = 90.0 },
    { model = "ar_prop_ar_tube_4x_crn", rel_x = 240.0, rel_y = 380.0, rel_z = 0.0, yaw = 90.0 },
    { model = "ar_prop_ar_tube_4x_l", rel_x = 240.0, rel_y = 300.0, rel_z = 0.0, yaw = 180.0 },
    { model = "ar_prop_ar_jump_loop", rel_x = 240.0, rel_y = 150.0, rel_z = 10.0, yaw = 180.0 },
    { model = "ar_prop_ar_hoop_med_01", rel_x = 240.0, rel_y = 50.0, rel_z = 15.0, yaw = 180.0 }
}

local arena_neon_speed_preset = {
    { model = "ar_prop_ar_start_01a", rel_x = 0.0, rel_y = -200.0, rel_z = 0.0, yaw = 0.0 },
    { model = "ar_prop_ar_neon_gate8x_01a", rel_x = 0.0, rel_y = -150.0, rel_z = 0.0, yaw = 0.0 },
    { model = "ar_prop_ar_speed_ring", rel_x = 0.0, rel_y = -100.0, rel_z = 0.0, yaw = 0.0 },
    { model = "ar_prop_ar_tube_2x_speed", rel_x = 0.0, rel_y = -50.0, rel_z = 0.0, yaw = 0.0 },
    { model = "ar_prop_ar_neon_gate8x_02a", rel_x = 0.0, rel_y = 0.0, rel_z = 0.0, yaw = 0.0 },
    { model = "ar_prop_ar_speed_ring", rel_x = 0.0, rel_y = 50.0, rel_z = 0.0, yaw = 0.0 },
    { model = "ar_prop_ar_tube_2x_speed", rel_x = 0.0, rel_y = 100.0, rel_z = 0.0, yaw = 0.0 },
    { model = "ar_prop_ar_neon_gate8x_03a", rel_x = 0.0, rel_y = 150.0, rel_z = 0.0, yaw = 0.0 },
    { model = "ar_prop_ar_speed_ring", rel_x = 0.0, rel_y = 200.0, rel_z = 0.0, yaw = 0.0 },
    { model = "ar_prop_ar_cp_tower8x_01a", rel_x = 0.0, rel_y = 260.0, rel_z = -10.0, yaw = 0.0 }
}

local mega_arena_jump_preset = {
    { model = "stt_prop_stunt_track_straight", rel_x = 0.0, rel_y = -250.0, rel_z = 0.0, yaw = 0.0 },
    { model = "ar_prop_ar_tube_4x_speed", rel_x = 0.0, rel_y = -180.0, rel_z = 0.0, yaw = 0.0 },
    { model = "ar_prop_ar_neon_gate8x_01a", rel_x = 0.0, rel_y = -120.0, rel_z = 0.0, yaw = 0.0 },
    { model = "stt_prop_stunt_jump_l", rel_x = 0.0, rel_y = -60.0, rel_z = 0.0, yaw = 0.0 },
    { model = "ar_prop_ar_speed_ring", rel_x = 0.0, rel_y = 0.0, rel_z = 15.0, yaw = 0.0 },
    { model = "ar_prop_ar_jump_loop", rel_x = 0.0, rel_y = 80.0, rel_z = 25.0, yaw = 0.0 },
    { model = "ar_prop_ar_hoop_med_01", rel_x = 0.0, rel_y = 160.0, rel_z = 20.0, yaw = 0.0 },
    { model = "ar_prop_ar_tube_4x_l", rel_x = 0.0, rel_y = 240.0, rel_z = 5.0, yaw = 0.0 },
    { model = "ar_prop_ar_bblock_huge_01", rel_x = 0.0, rel_y = 320.0, rel_z = 0.0, yaw = 0.0 }
}

local function safeCreateStuntProp(hash, x, y, z, dynamic)
    local isDyn = (dynamic == nil) and false or (dynamic == true)
    local obj = 0

    -- 1. Criação via nativo oficial GTA Online (isNetwork = true, bScriptHostObj = false, dynamic = isDyn)
    pcall(function()
        if OBJECT and OBJECT.CREATE_OBJECT_NO_OFFSET then
            obj = OBJECT.CREATE_OBJECT_NO_OFFSET(hash, x, y, z, true, false, isDyn)
        end
    end)

    -- 2. Tenta CREATE_OBJECT nativo com bScriptHostObj = false
    if not obj or obj == 0 or not isValidEntity(obj) then
        pcall(function()
            if OBJECT and OBJECT.CREATE_OBJECT then
                obj = OBJECT.CREATE_OBJECT(hash, x, y, z, true, false, isDyn)
            end
        end)
    end

    -- 3. Tenta CREATE_OBJECT_NO_OFFSET com bScriptHostObj = true
    if not obj or obj == 0 or not isValidEntity(obj) then
        pcall(function()
            if OBJECT and OBJECT.CREATE_OBJECT_NO_OFFSET then
                obj = OBJECT.CREATE_OBJECT_NO_OFFSET(hash, x, y, z, true, true, isDyn)
            end
        end)
    end

    -- 4. Fallback entities.create_object se nativos falharem
    if not obj or obj == 0 or not isValidEntity(obj) then
        pcall(function()
            if entities and entities.create_object then
                obj = entities.create_object(hash, { x = x, y = y, z = z })
            end
        end)
    end

    -- 5. Registro de Rede Imediato para Todos os Clientes da Sessão
    if isValidEntity(obj) then
        pcall(function()
            ENTITY.SET_ENTITY_AS_MISSION_ENTITY(obj, true, true)
            ENTITY.SET_ENTITY_VISIBLE(obj, true, false)
            if ENTITY.SET_ENTITY_LOCALLY_VISIBLE then
                ENTITY.SET_ENTITY_LOCALLY_VISIBLE(obj)
            end
            if ENTITY.SET_ENTITY_LOD_DIST then
                ENTITY.SET_ENTITY_LOD_DIST(obj, 0xFFFF)
            end
            if NETWORK then
                if NETWORK.NETWORK_REGISTER_ENTITY_AS_NETWORKED then
                    NETWORK.NETWORK_REGISTER_ENTITY_AS_NETWORKED(obj)
                end
                if NETWORK.OBJ_TO_NET then
                    local netId = NETWORK.OBJ_TO_NET(obj)
                    if netId and netId ~= 0 then
                        if NETWORK.SET_NETWORK_ID_EXISTS_ON_ALL_MACHINES then
                            NETWORK.SET_NETWORK_ID_EXISTS_ON_ALL_MACHINES(netId, true)
                        end
                        if NETWORK.SET_NETWORK_ID_CAN_MIGRATE then
                            NETWORK.SET_NETWORK_ID_CAN_MIGRATE(netId, true)
                        end
                        if NETWORK.SET_NETWORK_ID_ALWAYS_EXISTS_FOR_PLAYER then
                            NETWORK.SET_NETWORK_ID_ALWAYS_EXISTS_FOR_PLAYER(netId, -1, true)
                        end
                    end
                end
            end
        end)
    end

    return obj
end

local function clearAllStuntObjects()
    local count = 0
    for _, obj in ipairs(spawned_stunt_objects) do
        if isValidEntity(obj) then
            pcall(function()
                ENTITY.SET_ENTITY_AS_MISSION_ENTITY(obj, true, true)
                ENTITY.DELETE_ENTITY(obj)
            end)
            count = count + 1
        end
    end
    spawned_stunt_objects = {}
    notify.info("MAC_Fun_Script", string.format("Todas as %d estruturas foram removidas!", count))
end

local function undoLastStuntObject()
    if #spawned_stunt_objects > 0 then
        local lastObj = table.remove(spawned_stunt_objects)
        if isValidEntity(lastObj) then
            pcall(function()
                ENTITY.SET_ENTITY_AS_MISSION_ENTITY(lastObj, true, true)
                ENTITY.DELETE_ENTITY(lastObj)
            end)
            notify.info("MAC_Fun_Script", "Último objeto removido com sucesso!")
            return
        end
    end
    notify.warn("MAC_Fun_Script", "Nenhum objeto recente para remover.")
end

local function spawnStuntTrack(presetList, presetName)
    if is_spawning_stunt then
        notify.warn("MAC_Fun_Script", "Construção de pista já em andamento...")
        return
    end
    is_spawning_stunt = true

    script.run_in_callback(function()
        local my_ped = PLAYER.PLAYER_PED_ID()
        local my_pos = ENTITY.GET_ENTITY_COORDS(my_ped, true)
        local center_z = my_pos.z + stunt_altitude

        notify.info("MAC_Fun_Script", "Construindo " .. presetName .. " a " .. math.floor(stunt_altitude) .. "m no céu...")

        local count = 0
        for _, item in ipairs(presetList) do
            local h = getModelHash(item.model)
            if h ~= 0 then
                pcall(function()
                    STREAMING.REQUEST_MODEL(h)
                    local t = 0
                    while not STREAMING.HAS_MODEL_LOADED(h) and t < 100 do
                        script.yield(10)
                        t = t + 1
                    end
                end)

                if STREAMING.HAS_MODEL_LOADED(h) then
                    local spawn_x = my_pos.x + item.rel_x
                    local spawn_y = my_pos.y + item.rel_y
                    local spawn_z = center_z + item.rel_z

                    local obj = safeCreateStuntProp(h, spawn_x, spawn_y, spawn_z)
                    if isValidEntity(obj) then
                        pcall(function()
                            ENTITY.SET_ENTITY_AS_MISSION_ENTITY(obj, true, true)
                            ENTITY.SET_ENTITY_ROTATION(obj, 180.0, 0.0, item.yaw, 2, true)
                            ENTITY.FREEZE_ENTITY_POSITION(obj, true)
                            ENTITY.SET_ENTITY_VISIBLE(obj, true, false)
                            ENTITY.SET_ENTITY_COLLISION(obj, true, true)
                            if ENTITY.SET_ENTITY_LOD_DIST then
                                ENTITY.SET_ENTITY_LOD_DIST(obj, 0xFFFF)
                            end
                        end)
                        table.insert(spawned_stunt_objects, obj)
                        count = count + 1
                    end
                    STREAMING.SET_MODEL_AS_NO_LONGER_NEEDED(h)
                end
            end
            script.yield(20)
        end

        is_spawning_stunt = false
        state.status = presetName .. " gerada (" .. count .. " estruturas)"
        notify.success("MAC_Fun_Script", string.format("%s construída com sucesso! (%d Estruturas)", presetName, count))
    end)
end

local function spawnTotalSupremeChaos()
    if is_spawning_stunt then
        notify.warn("MAC_Fun_Script", "Construção de pistas já em andamento...")
        return
    end
    is_spawning_stunt = true

    script.run_in_callback(function()
        local ped = PLAYER.PLAYER_PED_ID()
        local pCoords = ENTITY.GET_ENTITY_COORDS(ped, true)
        local baseHeading = ENTITY.GET_ENTITY_HEADING(ped)
        local rad = math.rad(baseHeading)
        local cosH = math.cos(rad)
        local sinH = math.sin(rad)
        local skyZ = pCoords.z + stunt_altitude

        notify.info("MAC_Fun_Script", "GERANDO CAOS TOTAL (TUDO: ASFALTO + CEU)...")

        local allPieces = {}

        -- 1. ESTRUTURAS TERRESTRES / ASFALTO (Rampas, Portais, Tubos Speed, Anéis)
        local groundSpots = {
            -- Avenidas Principais (Frente e Trás)
            { x = 0.0,   y = 20.0,   z = -0.2, yaw = baseHeading,         model = "ar_prop_ar_neon_gate8x_01a" },
            { x = 0.0,   y = 45.0,   z = -0.2, yaw = baseHeading,         model = "stt_prop_stunt_jump_l" },
            { x = 0.0,   y = 75.0,   z = 1.0,  yaw = baseHeading,         model = "ar_prop_ar_speed_ring" },
            { x = 0.0,   y = 110.0,  z = -0.2, yaw = baseHeading,         model = "ar_prop_ar_tube_4x_speed" },
            { x = 0.0,   y = 160.0,  z = 0.0,  yaw = baseHeading,         model = "stt_prop_stunt_track_dloop" },
            { x = 0.0,   y = 210.0,  z = 2.0,  yaw = baseHeading,         model = "ar_prop_ar_jump_loop" },
            { x = 0.0,   y = 270.0,  z = -0.2, yaw = baseHeading,         model = "ar_prop_ar_cp_tower8x_01a" },

            -- Retaguarda (Avenidas Atrás)
            { x = 0.0,   y = -25.0,  z = -0.2, yaw = baseHeading + 180.0, model = "ar_prop_ar_neon_gate8x_02a" },
            { x = 0.0,   y = -50.0,  z = -0.2, yaw = baseHeading + 180.0, model = "stt_prop_stunt_jump_l" },
            { x = 0.0,   y = -85.0,  z = 1.0,  yaw = baseHeading + 180.0, model = "ar_prop_ar_speed_ring" },
            { x = 0.0,   y = -125.0, z = -0.2, yaw = baseHeading + 180.0, model = "ar_prop_ar_tube_4x_l" },
            { x = 0.0,   y = -175.0, z = -0.2, yaw = baseHeading + 180.0, model = "stt_prop_stunt_jump_m" },
            { x = 0.0,   y = -230.0, z = -0.2, yaw = baseHeading + 180.0, model = "ar_prop_ar_start_01a" },

            -- Laterais Direita (Cruzamentos e Ruas Paralelas)
            { x = 35.0,  y = 0.0,    z = -0.2, yaw = baseHeading + 90.0,  model = "ar_prop_ar_neon_gate4x_01a" },
            { x = 60.0,  y = 0.0,    z = -0.2, yaw = baseHeading + 90.0,  model = "stt_prop_stunt_jump_l" },
            { x = 95.0,  y = 0.0,    z = 1.0,  yaw = baseHeading + 90.0,  model = "ar_prop_ar_speed_ring" },
            { x = 135.0, y = 30.0,   z = -0.2, yaw = baseHeading + 45.0,  model = "stt_prop_stunt_track_dwuturn" },
            { x = 160.0, y = 0.0,    z = 0.0,  yaw = baseHeading + 90.0,  model = "ar_prop_ar_jump_loop" },

            -- Laterais Esquerda (Cruzamentos e Ruas Paralelas)
            { x = -35.0, y = 0.0,    z = -0.2, yaw = baseHeading - 90.0,  model = "ar_prop_ar_neon_gate4x_02a" },
            { x = -60.0, y = 0.0,    z = -0.2, yaw = baseHeading - 90.0,  model = "stt_prop_stunt_jump_l" },
            { x = -95.0, y = 0.0,    z = 1.0,  yaw = baseHeading - 90.0,  model = "ar_prop_ar_speed_ring" },
            { x = -135.0,y = 30.0,   z = -0.2, yaw = baseHeading - 45.0,  model = "stt_prop_stunt_track_dwuturn" },
            { x = -160.0,y = 0.0,    z = 0.0,  yaw = baseHeading - 90.0,  model = "ar_prop_ar_jump_loop" },

            -- Diagonais & Setas Neon
            { x = 50.0,  y = -50.0,  z = -0.2, yaw = baseHeading + 135.0, model = "ar_prop_ar_arrow_wide_xl" },
            { x = -50.0, y = -50.0,  z = -0.2, yaw = baseHeading - 135.0, model = "ar_prop_ar_arrow_wide_xl" },
            { x = 80.0,  y = 80.0,   z = -0.2, yaw = baseHeading + 45.0,  model = "ar_prop_ar_jetski_ramp_01_dev" },
            { x = -80.0, y = 80.0,   z = -0.2, yaw = baseHeading - 45.0,  model = "ar_prop_ar_jetski_ramp_01_dev" }
        }

        for _, spot in ipairs(groundSpots) do
            local wx = pCoords.x + (-sinH * spot.y + cosH * spot.x)
            local wy = pCoords.y + (cosH * spot.y + sinH * spot.x)
            local wz = pCoords.z + spot.z
            table.insert(allPieces, { model = spot.model, x = wx, y = wy, z = wz, pitch = 0.0, roll = 0.0, yaw = spot.yaw })
        end

        -- 2. ESTRUTURAS AÉREAS NO CÉU (Mega Rodovia, Mega Tubos 4X, Speed Rings, Loops)
        local skyPieces = {
            { model = "ar_prop_ar_start_01a",        rel_x = 0.0,    rel_y = -350.0, rel_z = 0.0,  yaw = 0.0 },
            { model = "ar_prop_ar_tube_4x_l",        rel_x = 0.0,    rel_y = -280.0, rel_z = 0.0,  yaw = 0.0 },
            { model = "ar_prop_ar_neon_gate8x_01a",  rel_x = 0.0,    rel_y = -200.0, rel_z = 0.0,  yaw = 0.0 },
            { model = "ar_prop_ar_tube_4x_speed",    rel_x = 0.0,    rel_y = -130.0, rel_z = 0.0,  yaw = 0.0 },
            { model = "ar_prop_ar_speed_ring",       rel_x = 0.0,    rel_y = -60.0,  rel_z = 0.0,  yaw = 0.0 },
            { model = "stt_prop_stunt_track_straight",rel_x = 0.0,   rel_y = 0.0,    rel_z = 0.0,  yaw = 0.0 },
            { model = "ar_prop_ar_neon_gate8x_02a",  rel_x = 0.0,    rel_y = 70.0,   rel_z = 0.0,  yaw = 0.0 },
            { model = "ar_prop_ar_tube_4x_speed",    rel_x = 0.0,    rel_y = 140.0,  rel_z = 0.0,  yaw = 0.0 },
            { model = "ar_prop_ar_speed_ring",       rel_x = 0.0,    rel_y = 200.0,  rel_z = 0.0,  yaw = 0.0 },
            { model = "ar_prop_ar_tube_4x_crn",      rel_x = 0.0,    rel_y = 270.0,  rel_z = 0.0,  yaw = 0.0 },
            { model = "ar_prop_ar_tube_4x_l",        rel_x = 75.0,   rel_y = 345.0,  rel_z = 0.0,  yaw = 90.0 },
            { model = "ar_prop_ar_neon_gate8x_03a",  rel_x = 150.0,  rel_y = 345.0,  rel_z = 0.0,  yaw = 90.0 },
            { model = "ar_prop_ar_tube_4x_crn",      rel_x = 225.0,  rel_y = 345.0,  rel_z = 0.0,  yaw = 90.0 },
            { model = "ar_prop_ar_tube_4x_l",        rel_x = 225.0,  rel_y = 270.0,  rel_z = 0.0,  yaw = 180.0 },
            { model = "ar_prop_ar_jump_loop",        rel_x = 225.0,  rel_y = 130.0,  rel_z = 10.0, yaw = 180.0 },
            { model = "ar_prop_ar_hoop_med_01",      rel_x = 225.0,  rel_y = 40.0,   rel_z = 15.0, yaw = 180.0 },
            { model = "stt_prop_stunt_track_straight",rel_x = 225.0, rel_y = -60.0,  rel_z = 0.0,  yaw = 180.0 },
            { model = "stt_prop_stunt_track_dloop",   rel_x = 225.0, rel_y = -180.0, rel_z = 20.0, yaw = 180.0 },
            { model = "stt_prop_stunt_jump_l",       rel_x = 225.0,  rel_y = -300.0, rel_z = -5.0, yaw = 0.0 }
        }

        for _, item in ipairs(skyPieces) do
            local sx = pCoords.x + item.rel_x
            local sy = pCoords.y + item.rel_y
            local sz = skyZ + item.rel_z
            table.insert(allPieces, { model = item.model, x = sx, y = sy, z = sz, pitch = 180.0, roll = 0.0, yaw = item.yaw })
        end

        local count = 0
        for _, piece in ipairs(allPieces) do
            local h = getModelHash(piece.model)
            if h ~= 0 then
                pcall(function()
                    STREAMING.REQUEST_MODEL(h)
                    local t = 0
                    while not STREAMING.HAS_MODEL_LOADED(h) and t < 40 do
                        script.yield(5)
                        t = t + 1
                    end
                end)

                if STREAMING.HAS_MODEL_LOADED(h) then
                    local obj = safeCreateStuntProp(h, piece.x, piece.y, piece.z)
                    if isValidEntity(obj) then
                        pcall(function()
                            ENTITY.SET_ENTITY_AS_MISSION_ENTITY(obj, true, true)
                            ENTITY.SET_ENTITY_ROTATION(obj, piece.pitch or 0.0, piece.roll or 0.0, piece.yaw or 0.0, 2, true)
                            ENTITY.FREEZE_ENTITY_POSITION(obj, true)
                            ENTITY.SET_ENTITY_VISIBLE(obj, true, false)
                            ENTITY.SET_ENTITY_COLLISION(obj, true, true)
                            if ENTITY.SET_ENTITY_LOD_DIST then
                                ENTITY.SET_ENTITY_LOD_DIST(obj, 0xFFFF)
                            end
                        end)
                        table.insert(spawned_stunt_objects, obj)
                        count = count + 1
                    end
                    STREAMING.SET_MODEL_AS_NO_LONGER_NEEDED(h)
                end
            end
            script.yield(10)
        end

        is_spawning_stunt = false
        state.status = "MEGA CAOS TOTAL GERADO (" .. count .. " estruturas)"
        notify.success("MAC_Fun_Script", string.format("MEGA CAOS TOTAL ATIVADO! (%d Estruturas no Céu e Asfalto)", count))
    end)
end

local function spawnAllGroundTracks()
    if is_spawning_stunt then
        notify.warn("MAC_Fun_Script", "Construção de pistas já em andamento...")
        return
    end
    is_spawning_stunt = true

    script.run_in_callback(function()
        local ped = PLAYER.PLAYER_PED_ID()
        local pCoords = ENTITY.GET_ENTITY_COORDS(ped, true)
        local baseHeading = ENTITY.GET_ENTITY_HEADING(ped)
        local rad = math.rad(baseHeading)
        local cosH = math.cos(rad)
        local sinH = math.sin(rad)

        notify.info("MAC_Fun_Script", "Gerando TODAS as Rampas e Portais do Asfalto...")

        local groundSpots = {
            -- Avenidas Principais
            { x = 0.0,   y = 20.0,   z = -0.2, yaw = baseHeading,         model = "ar_prop_ar_neon_gate8x_01a" },
            { x = 0.0,   y = 45.0,   z = -0.2, yaw = baseHeading,         model = "stt_prop_stunt_jump_l" },
            { x = 0.0,   y = 75.0,   z = 1.0,  yaw = baseHeading,         model = "ar_prop_ar_speed_ring" },
            { x = 0.0,   y = 110.0,  z = -0.2, yaw = baseHeading,         model = "ar_prop_ar_tube_4x_speed" },
            { x = 0.0,   y = 160.0,  z = 0.0,  yaw = baseHeading,         model = "stt_prop_stunt_track_dloop" },
            { x = 0.0,   y = 210.0,  z = 2.0,  yaw = baseHeading,         model = "ar_prop_ar_jump_loop" },
            { x = 0.0,   y = 270.0,  z = -0.2, yaw = baseHeading,         model = "ar_prop_ar_cp_tower8x_01a" },

            -- Retaguarda
            { x = 0.0,   y = -25.0,  z = -0.2, yaw = baseHeading + 180.0, model = "ar_prop_ar_neon_gate8x_02a" },
            { x = 0.0,   y = -50.0,  z = -0.2, yaw = baseHeading + 180.0, model = "stt_prop_stunt_jump_l" },
            { x = 0.0,   y = -85.0,  z = 1.0,  yaw = baseHeading + 180.0, model = "ar_prop_ar_speed_ring" },
            { x = 0.0,   y = -125.0, z = -0.2, yaw = baseHeading + 180.0, model = "ar_prop_ar_tube_4x_l" },
            { x = 0.0,   y = -175.0, z = -0.2, yaw = baseHeading + 180.0, model = "stt_prop_stunt_jump_m" },
            { x = 0.0,   y = -230.0, z = -0.2, yaw = baseHeading + 180.0, model = "ar_prop_ar_start_01a" },

            -- Laterais Direita
            { x = 35.0,  y = 0.0,    z = -0.2, yaw = baseHeading + 90.0,  model = "ar_prop_ar_neon_gate4x_01a" },
            { x = 60.0,  y = 0.0,    z = -0.2, yaw = baseHeading + 90.0,  model = "stt_prop_stunt_jump_l" },
            { x = 95.0,  y = 0.0,    z = 1.0,  yaw = baseHeading + 90.0,  model = "ar_prop_ar_speed_ring" },
            { x = 135.0, y = 30.0,   z = -0.2, yaw = baseHeading + 45.0,  model = "stt_prop_stunt_track_dwuturn" },
            { x = 160.0, y = 0.0,    z = 0.0,  yaw = baseHeading + 90.0,  model = "ar_prop_ar_jump_loop" },

            -- Laterais Esquerda
            { x = -35.0, y = 0.0,    z = -0.2, yaw = baseHeading - 90.0,  model = "ar_prop_ar_neon_gate4x_02a" },
            { x = -60.0, y = 0.0,    z = -0.2, yaw = baseHeading - 90.0,  model = "stt_prop_stunt_jump_l" },
            { x = -95.0, y = 0.0,    z = 1.0,  yaw = baseHeading - 90.0,  model = "ar_prop_ar_speed_ring" },
            { x = -135.0,y = 30.0,   z = -0.2, yaw = baseHeading - 45.0,  model = "stt_prop_stunt_track_dwuturn" },
            { x = -160.0,y = 0.0,    z = 0.0,  yaw = baseHeading - 90.0,  model = "ar_prop_ar_jump_loop" },

            -- Diagonais
            { x = 50.0,  y = -50.0,  z = -0.2, yaw = baseHeading + 135.0, model = "ar_prop_ar_arrow_wide_xl" },
            { x = -50.0, y = -50.0,  z = -0.2, yaw = baseHeading - 135.0, model = "ar_prop_ar_arrow_wide_xl" },
            { x = 80.0,  y = 80.0,   z = -0.2, yaw = baseHeading + 45.0,  model = "ar_prop_ar_jetski_ramp_01_dev" },
            { x = -80.0, y = 80.0,   z = -0.2, yaw = baseHeading - 45.0,  model = "ar_prop_ar_jetski_ramp_01_dev" }
        }

        local count = 0
        for _, spot in ipairs(groundSpots) do
            local wx = pCoords.x + (-sinH * spot.y + cosH * spot.x)
            local wy = pCoords.y + (cosH * spot.y + sinH * spot.x)
            local wz = pCoords.z + spot.z

            local h = getModelHash(spot.model)
            if h ~= 0 then
                pcall(function()
                    STREAMING.REQUEST_MODEL(h)
                    local t = 0
                    while not STREAMING.HAS_MODEL_LOADED(h) and t < 40 do
                        script.yield(5)
                        t = t + 1
                    end
                end)

                if STREAMING.HAS_MODEL_LOADED(h) then
                    local obj = safeCreateStuntProp(h, wx, wy, wz)
                    if isValidEntity(obj) then
                        pcall(function()
                            ENTITY.SET_ENTITY_AS_MISSION_ENTITY(obj, true, true)
                            ENTITY.SET_ENTITY_ROTATION(obj, 0.0, 0.0, spot.yaw, 2, true)
                            ENTITY.FREEZE_ENTITY_POSITION(obj, true)
                            ENTITY.SET_ENTITY_COLLISION(obj, true, true)
                            if ENTITY.SET_ENTITY_LOD_DIST then
                                ENTITY.SET_ENTITY_LOD_DIST(obj, 0xFFFF)
                            end
                        end)
                        table.insert(spawned_stunt_objects, obj)
                        count = count + 1
                    end
                    STREAMING.SET_MODEL_AS_NO_LONGER_NEEDED(h)
                end
            end
            script.yield(10)
        end

        is_spawning_stunt = false
        state.status = "TODAS AS RAMPAS DO ASFALTO GERADAS (" .. count .. " estruturas)"
        notify.success("MAC_Fun_Script", "Todas as Rampas & Portais do Asfalto geradas! (" .. count .. " Estruturas)")
    end)
end

local function spawnAllSkyTracks()
    if is_spawning_stunt then
        notify.warn("MAC_Fun_Script", "Construção de pistas já em andamento...")
        return
    end
    is_spawning_stunt = true

    script.run_in_callback(function()
        local ped = PLAYER.PLAYER_PED_ID()
        local pCoords = ENTITY.GET_ENTITY_COORDS(ped, true)
        local skyZ = pCoords.z + stunt_altitude

        notify.info("MAC_Fun_Script", "Gerando TODAS as Mega Pistas e Tubos no Céu...")

        local skyPieces = {
            { model = "ar_prop_ar_start_01a",        rel_x = 0.0,    rel_y = -350.0, rel_z = 0.0,  yaw = 0.0 },
            { model = "ar_prop_ar_tube_4x_l",        rel_x = 0.0,    rel_y = -280.0, rel_z = 0.0,  yaw = 0.0 },
            { model = "ar_prop_ar_neon_gate8x_01a",  rel_x = 0.0,    rel_y = -200.0, rel_z = 0.0,  yaw = 0.0 },
            { model = "ar_prop_ar_tube_4x_speed",    rel_x = 0.0,    rel_y = -130.0, rel_z = 0.0,  yaw = 0.0 },
            { model = "ar_prop_ar_speed_ring",       rel_x = 0.0,    rel_y = -60.0,  rel_z = 0.0,  yaw = 0.0 },
            { model = "stt_prop_stunt_track_straight",rel_x = 0.0,   rel_y = 0.0,    rel_z = 0.0,  yaw = 0.0 },
            { model = "ar_prop_ar_neon_gate8x_02a",  rel_x = 0.0,    rel_y = 70.0,   rel_z = 0.0,  yaw = 0.0 },
            { model = "ar_prop_ar_tube_4x_speed",    rel_x = 0.0,    rel_y = 140.0,  rel_z = 0.0,  yaw = 0.0 },
            { model = "ar_prop_ar_speed_ring",       rel_x = 0.0,    rel_y = 200.0,  rel_z = 0.0,  yaw = 0.0 },
            { model = "ar_prop_ar_tube_4x_crn",      rel_x = 0.0,    rel_y = 270.0,  rel_z = 0.0,  yaw = 0.0 },
            { model = "ar_prop_ar_tube_4x_l",        rel_x = 75.0,   rel_y = 345.0,  rel_z = 0.0,  yaw = 90.0 },
            { model = "ar_prop_ar_neon_gate8x_03a",  rel_x = 150.0,  rel_y = 345.0,  rel_z = 0.0,  yaw = 90.0 },
            { model = "ar_prop_ar_tube_4x_crn",      rel_x = 225.0,  rel_y = 345.0,  rel_z = 0.0,  yaw = 90.0 },
            { model = "ar_prop_ar_tube_4x_l",        rel_x = 225.0,  rel_y = 270.0,  rel_z = 0.0,  yaw = 180.0 },
            { model = "ar_prop_ar_jump_loop",        rel_x = 225.0,  rel_y = 130.0,  rel_z = 10.0, yaw = 180.0 },
            { model = "ar_prop_ar_hoop_med_01",      rel_x = 225.0,  rel_y = 40.0,   rel_z = 15.0, yaw = 180.0 },
            { model = "stt_prop_stunt_track_straight",rel_x = 225.0, rel_y = -60.0,  rel_z = 0.0,  yaw = 180.0 },
            { model = "stt_prop_stunt_track_dloop",   rel_x = 225.0, rel_y = -180.0, rel_z = 20.0, yaw = 180.0 },
            { model = "stt_prop_stunt_jump_l",       rel_x = 225.0,  rel_y = -300.0, rel_z = -5.0, yaw = 0.0 }
        }

        local count = 0
        for _, item in ipairs(skyPieces) do
            local sx = pCoords.x + item.rel_x
            local sy = pCoords.y + item.rel_y
            local sz = skyZ + item.rel_z

            local h = getModelHash(item.model)
            if h ~= 0 then
                pcall(function()
                    STREAMING.REQUEST_MODEL(h)
                    local t = 0
                    while not STREAMING.HAS_MODEL_LOADED(h) and t < 40 do
                        script.yield(5)
                        t = t + 1
                    end
                end)

                if STREAMING.HAS_MODEL_LOADED(h) then
                    local obj = safeCreateStuntProp(h, sx, sy, sz)
                    if isValidEntity(obj) then
                        pcall(function()
                            ENTITY.SET_ENTITY_AS_MISSION_ENTITY(obj, true, true)
                            ENTITY.SET_ENTITY_ROTATION(obj, 180.0, 0.0, item.yaw, 2, true)
                            ENTITY.FREEZE_ENTITY_POSITION(obj, true)
                            ENTITY.SET_ENTITY_VISIBLE(obj, true, false)
                            ENTITY.SET_ENTITY_COLLISION(obj, true, true)
                            if ENTITY.SET_ENTITY_LOD_DIST then
                                ENTITY.SET_ENTITY_LOD_DIST(obj, 0xFFFF)
                            end
                        end)
                        table.insert(spawned_stunt_objects, obj)
                        count = count + 1
                    end
                    STREAMING.SET_MODEL_AS_NO_LONGER_NEEDED(h)
                end
            end
            script.yield(10)
        end

        is_spawning_stunt = false
        state.status = "TODAS AS PISTAS NO CÉU GERADAS (" .. count .. " estruturas)"
        notify.success("MAC_Fun_Script", string.format("Pistas do Céu ativadas! (%d Estruturas)", count))
    end)
end

local function spawnChaoticUrbanRamps()
    if is_spawning_stunt then
        notify.warn("MAC_Fun_Script", "Construção de rampas já em andamento...")
        return
    end
    is_spawning_stunt = true

    script.run_in_callback(function()
        local ped = PLAYER.PLAYER_PED_ID()
        local pCoords = ENTITY.GET_ENTITY_COORDS(ped, true)
        local baseHeading = ENTITY.GET_ENTITY_HEADING(ped)

        notify.info("MAC_Fun_Script", "Espalhando Caos de Rampas no Mapa...")

        local spawnOffsets = {
            -- Frente e trás (Avenidas principais)
            { x = 0.0,   y = 25.0,   yaw = baseHeading,        model = "stt_prop_stunt_jump_l" },
            { x = 0.0,   y = 70.0,   yaw = baseHeading,        model = "stt_prop_stunt_track_dloop" },
            { x = 0.0,   y = -35.0,  yaw = baseHeading + 180.0,model = "stt_prop_stunt_jump_l" },
            { x = 0.0,   y = -80.0,  yaw = baseHeading + 180.0,model = "stt_prop_stunt_jump_m" },
            -- Laterais (Cruzamentos e Ruas Paralelas)
            { x = 35.0,  y = 0.0,    yaw = baseHeading + 90.0, model = "stt_prop_stunt_jump_l" },
            { x = 70.0,  y = 35.0,   yaw = baseHeading + 45.0, model = "stt_prop_stunt_track_dwuturn" },
            { x = -35.0, y = 0.0,    yaw = baseHeading - 90.0, model = "stt_prop_stunt_jump_l" },
            { x = -70.0, y = 35.0,   yaw = baseHeading - 45.0, model = "stt_prop_stunt_track_dwuturn" },
            -- Diagonais e Perímetro
            { x = 50.0,  y = -50.0,  yaw = baseHeading + 135.0,model = "stt_prop_stunt_jump_m" },
            { x = -50.0, y = -50.0,  yaw = baseHeading - 135.0,model = "stt_prop_stunt_jump_m" },
            { x = 90.0,  y = 0.0,    yaw = baseHeading + 90.0, model = "stt_prop_stunt_track_dloop" },
            { x = -90.0, y = 0.0,    yaw = baseHeading - 90.0, model = "stt_prop_stunt_track_dloop" },
            { x = 0.0,   y = 120.0,  yaw = baseHeading,        model = "stt_prop_stunt_tube_l" },
            { x = 0.0,   y = -120.0, yaw = baseHeading + 180.0,model = "stt_prop_stunt_tube_l" }
        }

        local count = 0
        for _, spot in ipairs(spawnOffsets) do
            local rad = math.rad(baseHeading)
            local cosH = math.cos(rad)
            local sinH = math.sin(rad)
            local wx = pCoords.x + (-sinH * spot.y + cosH * spot.x)
            local wy = pCoords.y + (cosH * spot.y + sinH * spot.x)
            local wz = pCoords.z - 0.2

            local h = getModelHash(spot.model)
            if h ~= 0 then
                pcall(function()
                    STREAMING.REQUEST_MODEL(h)
                    local t = 0
                    while not STREAMING.HAS_MODEL_LOADED(h) and t < 60 do
                        script.yield(10)
                        t = t + 1
                    end
                end)

                if STREAMING.HAS_MODEL_LOADED(h) then
                    local obj = safeCreateStuntProp(h, wx, wy, wz)
                    if isValidEntity(obj) then
                        pcall(function()
                            ENTITY.SET_ENTITY_AS_MISSION_ENTITY(obj, true, true)
                            ENTITY.SET_ENTITY_ROTATION(obj, 0.0, 0.0, spot.yaw, 2, true)
                            ENTITY.FREEZE_ENTITY_POSITION(obj, true)
                            ENTITY.SET_ENTITY_COLLISION(obj, true, true)
                            if ENTITY.SET_ENTITY_LOD_DIST then
                                ENTITY.SET_ENTITY_LOD_DIST(obj, 0xFFFF)
                            end
                        end)
                        table.insert(spawned_stunt_objects, obj)
                        count = count + 1
                    end
                    STREAMING.SET_MODEL_AS_NO_LONGER_NEEDED(h)
                end
            end
            script.yield(20)
        end

        is_spawning_stunt = false
        state.status = "Caos de Rampas gerado (" .. count .. " estruturas)"
        notify.success("MAC_Fun_Script", "Caos de Rampas Urbanas gerado! (" .. count .. " Rampas)")
    end)
end

local function spawnArenaUrbanNeonChaos()
    if is_spawning_stunt then
        notify.warn("MAC_Fun_Script", "Construção de pistas já em andamento...")
        return
    end
    is_spawning_stunt = true

    script.run_in_callback(function()
        local ped = PLAYER.PLAYER_PED_ID()
        local pCoords = ENTITY.GET_ENTITY_COORDS(ped, true)
        local baseHeading = ENTITY.GET_ENTITY_HEADING(ped)

        notify.info("MAC_Fun_Script", "Gerando Caos Urbano de Neon Arena War...")

        local spawnOffsets = {
            { x = 0.0,   y = 25.0,   yaw = baseHeading,         model = "ar_prop_ar_neon_gate8x_01a" },
            { x = 0.0,   y = 60.0,   yaw = baseHeading,         model = "ar_prop_ar_speed_ring" },
            { x = 0.0,   y = 100.0,  yaw = baseHeading,         model = "ar_prop_ar_tube_4x_speed" },
            { x = 0.0,   y = -30.0,  yaw = baseHeading + 180.0, model = "ar_prop_ar_neon_gate8x_02a" },
            { x = 0.0,   y = -70.0,  yaw = baseHeading + 180.0, model = "ar_prop_ar_speed_ring" },
            { x = 0.0,   y = -110.0, yaw = baseHeading + 180.0, model = "ar_prop_ar_tube_4x_l" },
            { x = 35.0,  y = 0.0,    yaw = baseHeading + 90.0,  model = "ar_prop_ar_neon_gate4x_01a" },
            { x = 70.0,  y = 30.0,   yaw = baseHeading + 45.0,  model = "ar_prop_ar_speed_ring" },
            { x = 100.0, y = 0.0,    yaw = baseHeading + 90.0,  model = "ar_prop_ar_jump_loop" },
            { x = -35.0, y = 0.0,    yaw = baseHeading - 90.0,  model = "ar_prop_ar_neon_gate4x_02a" },
            { x = -70.0, y = 30.0,   yaw = baseHeading - 45.0,  model = "ar_prop_ar_speed_ring" },
            { x = -100.0,y = 0.0,    yaw = baseHeading - 90.0,  model = "ar_prop_ar_jump_loop" },
            { x = 50.0,  y = -50.0,  yaw = baseHeading + 135.0, model = "ar_prop_ar_arrow_wide_xl" },
            { x = -50.0, y = -50.0,  yaw = baseHeading - 135.0, model = "ar_prop_ar_arrow_wide_xl" },
            { x = 0.0,   y = 150.0,  yaw = baseHeading,         model = "ar_prop_ar_cp_tower8x_01a" },
            { x = 0.0,   y = -150.0, yaw = baseHeading + 180.0, model = "ar_prop_ar_start_01a" }
        }

        local count = 0
        for _, spot in ipairs(spawnOffsets) do
            local rad = math.rad(baseHeading)
            local cosH = math.cos(rad)
            local sinH = math.sin(rad)
            local wx = pCoords.x + (-sinH * spot.y + cosH * spot.x)
            local wy = pCoords.y + (cosH * spot.y + sinH * spot.x)
            local wz = pCoords.z - 0.2

            local h = getModelHash(spot.model)
            if h ~= 0 then
                pcall(function()
                    STREAMING.REQUEST_MODEL(h)
                    local t = 0
                    while not STREAMING.HAS_MODEL_LOADED(h) and t < 60 do
                        script.yield(10)
                        t = t + 1
                    end
                end)

                if STREAMING.HAS_MODEL_LOADED(h) then
                    local obj = safeCreateStuntProp(h, wx, wy, wz)
                    if isValidEntity(obj) then
                        pcall(function()
                            ENTITY.SET_ENTITY_AS_MISSION_ENTITY(obj, true, true)
                            ENTITY.SET_ENTITY_ROTATION(obj, 0.0, 0.0, spot.yaw, 2, true)
                            ENTITY.FREEZE_ENTITY_POSITION(obj, true)
                            ENTITY.SET_ENTITY_COLLISION(obj, true, true)
                            if ENTITY.SET_ENTITY_LOD_DIST then
                                ENTITY.SET_ENTITY_LOD_DIST(obj, 0xFFFF)
                            end
                        end)
                        table.insert(spawned_stunt_objects, obj)
                        count = count + 1
                    end
                    STREAMING.SET_MODEL_AS_NO_LONGER_NEEDED(h)
                end
            end
            script.yield(20)
        end

        is_spawning_stunt = false
        state.status = "Caos Neon de Arena gerado (" .. count .. " estruturas)"
        notify.success("MAC_Fun_Script", "Caos Urbano Neon gerado! (" .. count .. " Estruturas)")
    end)
end

local function spawnCascadeRunway()
    if is_spawning_stunt then
        notify.warn("MAC_Fun_Script", "Construção de pista já em andamento...")
        return
    end
    is_spawning_stunt = true

    script.run_in_callback(function()
        local ped = PLAYER.PLAYER_PED_ID()
        local my_pos = ENTITY.GET_ENTITY_COORDS(ped, true)
        local heading = ENTITY.GET_ENTITY_HEADING(ped)
        local rad = math.rad(heading)
        local fwdX = -math.sin(rad)
        local fwdY = math.cos(rad)

        notify.info("MAC_Fun_Script", "Construindo Pista de Saltos em Cascata...")

        local steps = {
            { dist = 20.0,  model = "stt_prop_stunt_jump_s",     z_off = -0.2 },
            { dist = 60.0,  model = "stt_prop_stunt_jump_m",     z_off = -0.2 },
            { dist = 110.0, model = "stt_prop_stunt_jump_l",     z_off = -0.2 },
            { dist = 170.0, model = "stt_prop_stunt_track_dloop",z_off = 0.0 },
            { dist = 240.0, model = "stt_prop_stunt_tube_l",    z_off = 0.0 }
        }

        local count = 0
        for _, step in ipairs(steps) do
            local rx = my_pos.x + fwdX * step.dist
            local ry = my_pos.y + fwdY * step.dist
            local rz = my_pos.z + step.z_off

            local h = getModelHash(step.model)
            if h ~= 0 then
                pcall(function()
                    STREAMING.REQUEST_MODEL(h)
                    local t = 0
                    while not STREAMING.HAS_MODEL_LOADED(h) and t < 60 do
                        script.yield(10)
                        t = t + 1
                    end
                end)

                if STREAMING.HAS_MODEL_LOADED(h) then
                    local obj = safeCreateStuntProp(h, rx, ry, rz)
                    if isValidEntity(obj) then
                        pcall(function()
                            ENTITY.SET_ENTITY_AS_MISSION_ENTITY(obj, true, true)
                            ENTITY.SET_ENTITY_ROTATION(obj, 0.0, 0.0, heading, 2, true)
                            ENTITY.FREEZE_ENTITY_POSITION(obj, true)
                            ENTITY.SET_ENTITY_COLLISION(obj, true, true)
                            if ENTITY.SET_ENTITY_LOD_DIST then
                                ENTITY.SET_ENTITY_LOD_DIST(obj, 0xFFFF)
                            end
                        end)
                        table.insert(spawned_stunt_objects, obj)
                        count = count + 1
                    end
                    STREAMING.SET_MODEL_AS_NO_LONGER_NEEDED(h)
                end
            end
            script.yield(20)
        end

        is_spawning_stunt = false
        state.status = "Pista em Cascata gerada (" .. count .. " estruturas)"
        notify.success("MAC_Fun_Script", "Pista de Saltos em Cascata gerada com sucesso!")
    end)
end

local function spawnInstantFrontRamp(rampModel)
    script.run_in_callback(function()
        local ped = PLAYER.PLAYER_PED_ID()
        local my_pos = ENTITY.GET_ENTITY_COORDS(ped, true)
        local heading = ENTITY.GET_ENTITY_HEADING(ped)
        local rad = math.rad(heading)
        local fwdX = -math.sin(rad)
        local fwdY = math.cos(rad)

        local spawnDist = 15.0
        local rx = my_pos.x + fwdX * spawnDist
        local ry = my_pos.y + fwdY * spawnDist
        local rz = my_pos.z - 0.2

        local h = getModelHash(rampModel or "stt_prop_stunt_jump_l")
        pcall(function()
            STREAMING.REQUEST_MODEL(h)
            local t = 0
            while not STREAMING.HAS_MODEL_LOADED(h) and t < 60 do
                script.yield(10)
                t = t + 1
            end
        end)

        if STREAMING.HAS_MODEL_LOADED(h) then
            local obj = safeCreateStuntProp(h, rx, ry, rz)
            if isValidEntity(obj) then
                pcall(function()
                    ENTITY.SET_ENTITY_AS_MISSION_ENTITY(obj, true, true)
                    ENTITY.SET_ENTITY_ROTATION(obj, 0.0, 0.0, heading, 2, true)
                    ENTITY.FREEZE_ENTITY_POSITION(obj, true)
                    ENTITY.SET_ENTITY_COLLISION(obj, true, true)
                    if ENTITY.SET_ENTITY_LOD_DIST then
                        ENTITY.SET_ENTITY_LOD_DIST(obj, 0xFFFF)
                    end
                end)
                table.insert(spawned_stunt_objects, obj)
                STREAMING.SET_MODEL_AS_NO_LONGER_NEEDED(h)
                notify.success("MAC_Fun_Script", "Rampa acrobática gerada à sua frente!")
            end
        end
    end)
end

local function spawnSinglePropAtPlayer(modelNameOrHash, customDist, customZ, customYaw, freeze)
    script.run_in_callback(function()
        local ped = PLAYER.PLAYER_PED_ID()
        if not isValidEntity(ped) then return end

        local my_pos = ENTITY.GET_ENTITY_COORDS(ped, true)
        local heading = ENTITY.GET_ENTITY_HEADING(ped)
        local rad = math.rad(heading)
        local fwdX = -math.sin(rad)
        local fwdY = math.cos(rad)

        local dist = customDist or customSpawnDistance or 15.0
        local zOffset = customZ or customSpawnHeight or 0.0
        local yawOffset = customYaw or customSpawnYaw or 0.0
        local isFrozen = (freeze ~= nil) and freeze or customSpawnFreeze

        local rx = my_pos.x + fwdX * dist
        local ry = my_pos.y + fwdY * dist
        local rz = my_pos.z + zOffset

        local h = getModelHash(modelNameOrHash)
        if not h or h == 0 then
            notify.warn("MAC_Fun_Script", "Modelo inválido: " .. tostring(modelNameOrHash))
            return
        end

        pcall(function()
            STREAMING.REQUEST_MODEL(h)
            local t = 0
            while not STREAMING.HAS_MODEL_LOADED(h) and t < 60 do
                script.yield(10)
                t = t + 1
            end
        end)

        if STREAMING.HAS_MODEL_LOADED(h) then
            local obj = safeCreateStuntProp(h, rx, ry, rz)
            if isValidEntity(obj) then
                pcall(function()
                    ENTITY.SET_ENTITY_AS_MISSION_ENTITY(obj, true, true)
                    ENTITY.SET_ENTITY_ROTATION(obj, 0.0, 0.0, heading + yawOffset, 2, true)
                    if isFrozen then
                        ENTITY.FREEZE_ENTITY_POSITION(obj, true)
                    end
                    ENTITY.SET_ENTITY_COLLISION(obj, true, true)
                    if ENTITY.SET_ENTITY_LOD_DIST then
                        ENTITY.SET_ENTITY_LOD_DIST(obj, 0xFFFF)
                    end
                end)
                table.insert(spawned_stunt_objects, obj)
                STREAMING.SET_MODEL_AS_NO_LONGER_NEEDED(h)
                notify.success("MAC_Fun_Script", "Objeto [" .. tostring(modelNameOrHash) .. "] gerado à sua frente!")
            else
                notify.error("MAC_Fun_Script", "Falha ao criar o objeto (handle inválido).")
            end
        else
            notify.error("MAC_Fun_Script", "Falha ao carregar modelo: " .. tostring(modelNameOrHash))
        end
    end)
end

local fixedUfoObject = nil

local function spawnFixedCoordsUfo()
    script.run_in_callback(function()
        local x = -75.015
        local y = -818.215
        local z = 326.176
        local modelName = "p_spinning_anus_s"
        local h = getModelHash(modelName)

        if isValidEntity(fixedUfoObject) then
            pcall(function()
                ENTITY.SET_ENTITY_AS_MISSION_ENTITY(fixedUfoObject, true, true)
                ENTITY.DELETE_ENTITY(fixedUfoObject)
            end)
            fixedUfoObject = nil
        end

        pcall(function()
            STREAMING.REQUEST_MODEL(h)
            local t = 0
            while not STREAMING.HAS_MODEL_LOADED(h) and t < 80 do
                script.yield(10)
                t = t + 1
            end
        end)

        if STREAMING.HAS_MODEL_LOADED(h) then
            local obj = safeCreateStuntProp(h, x, y, z, false)
            if isValidEntity(obj) then
                configureStuntEntity(obj, -1)
                pcall(function()
                    ENTITY.FREEZE_ENTITY_POSITION(obj, true)
                    ENTITY.SET_ENTITY_COLLISION(obj, true, true)
                    ENTITY.SET_ENTITY_COORDS_NO_OFFSET(obj, x, y, z, false, false, false)
                    if ENTITY.SET_ENTITY_LOD_DIST then
                        ENTITY.SET_ENTITY_LOD_DIST(obj, 0xFFFF)
                    end
                end)
                fixedUfoObject = obj
                table.insert(spawned_stunt_objects, obj)
                STREAMING.SET_MODEL_AS_NO_LONGER_NEEDED(h)
                notify.success("MAC_Fun_Script", "OVNI (p_spinning_anus_s) gerado nas coordenadas [-75.015, -818.215, 326.176]!")
            else
                notify.error("MAC_Fun_Script", "Falha ao instanciar OVNI nas coordenadas.")
            end
        else
            notify.error("MAC_Fun_Script", "Falha ao carregar modelo p_spinning_anus_s.")
        end
    end)
end

local function removeFixedCoordsUfo()
    if isValidEntity(fixedUfoObject) then
        pcall(function()
            ENTITY.SET_ENTITY_AS_MISSION_ENTITY(fixedUfoObject, true, true)
            ENTITY.DELETE_ENTITY(fixedUfoObject)
        end)
        fixedUfoObject = nil
        notify.info("MAC_Fun_Script", "OVNI do Ponto Fixo removido!")
    end
end

-- ════════════════════════════════════════════════════════════════════
-- JAULA DO MACACO COM FÍSICA (v_med_apecrate Trap)
-- ════════════════════════════════════════════════════════════════════
local function spawnApeCrateCageOnPlayer(targetPid)
    script.run_in_callback(function()
        local ok, err = pcall(function()
            local myLocalPid = get_local_pid()
            local actualPid = (targetPid == nil or targetPid == -1) and myLocalPid or targetPid
            local ped = getPlayerPedSafe(actualPid)

            if not isValidEntity(ped) then
                notify.warn("MAC_Fun_Script", "Jogador alvo não encontrado ou fora do alcance!")
                return
            end

            local modelName = "v_med_apecrate"
            local hash = getModelHash(modelName)
            if not hash or hash == 0 then
                pcall(function()
                    if MISC and MISC.GET_HASH_KEY then
                        hash = MISC.GET_HASH_KEY(modelName)
                    end
                end)
            end

            notify.info("MAC_Fun_Script", "Carregando Jaula do Macaco: " .. modelName)

            pcall(function() STREAMING.REQUEST_MODEL(hash) end)
            local t = 0
            while not STREAMING.HAS_MODEL_LOADED(hash) and t < 100 do
                script.yield(10)
                t = t + 1
            end

            if not STREAMING.HAS_MODEL_LOADED(hash) then
                notify.error("MAC_Fun_Script", "Falha ao carregar modelo da jaula: " .. modelName)
                return
            end

            local coords = getTargetCoordsSafe(actualPid, ped)
            local heading = ENTITY.GET_ENTITY_HEADING(ped)
            local zFloor = coords.z - 0.95

            -- Cria a jaula no chão ao redor do jogador com física ativada
            local obj = safeCreateStuntProp(hash, coords.x, coords.y, zFloor, true)
            STREAMING.SET_MODEL_AS_NO_LONGER_NEEDED(hash)

            if isValidEntity(obj) then
                configureStuntEntity(obj, actualPid)
                pcall(function()
                    ENTITY.SET_ENTITY_COLLISION(obj, true, true)
                    ENTITY.SET_ENTITY_HEADING(obj, heading)
                    ENTITY.SET_ENTITY_COORDS_NO_OFFSET(obj, coords.x, coords.y, zFloor, false, false, false)
                    ENTITY.FREEZE_ENTITY_POSITION(obj, false)
                    if ENTITY.SET_ENTITY_LOD_DIST then
                        ENTITY.SET_ENTITY_LOD_DIST(obj, 0xFFFF)
                    end
                end)
                table.insert(spawned_stunt_objects, obj)

                local pName = (actualPid == myLocalPid) and "Você" or get_player_name(actualPid)
                notify.success("MAC_Fun_Script", string.format("Jaula (v_med_apecrate) gerada em %s com física!", pName))
            else
                notify.error("MAC_Fun_Script", "Falha ao instanciar Jaula no mundo.")
            end
        end)

        if not ok then
            notify.error("MAC_Fun_Script", "Erro ao prender na jaula: " .. tostring(err))
        end
    end)
end

-- ════════════════════════════════════════════════════════════════════
-- TESTE DE OBJETO: 26_1_p26_01_additions_sm15lod
-- ════════════════════════════════════════════════════════════════════
local function spawnTestModel26()
    script.run_in_callback(function()
        local ok, err = pcall(function()
            local modelName = "26_1_p26_01_additions_sm15lod"
            local hash = getModelHash(modelName)
            if not hash or hash == 0 then
                pcall(function()
                    if MISC and MISC.GET_HASH_KEY then
                        hash = MISC.GET_HASH_KEY(modelName)
                    end
                end)
            end

            notify.info("MAC_Fun_Script", "Carregando modelo de teste: " .. modelName)

            pcall(function() STREAMING.REQUEST_MODEL(hash) end)
            local t = 0
            while not STREAMING.HAS_MODEL_LOADED(hash) and t < 100 do
                script.yield(10)
                t = t + 1
            end

            if not STREAMING.HAS_MODEL_LOADED(hash) then
                notify.error("MAC_Fun_Script", "Falha ao carregar modelo: " .. modelName)
                return
            end

            local myPed = PLAYER.PLAYER_PED_ID()
            local pos = ENTITY.GET_ENTITY_COORDS(myPed, true)
            local heading = ENTITY.GET_ENTITY_HEADING(myPed)
            local rad = math.rad(heading + 90.0)
            local fwdX = math.cos(rad)
            local fwdY = math.sin(rad)
            local sx = pos.x + fwdX * 8.0
            local sy = pos.y + fwdY * 8.0
            local sz = pos.z

            local obj = safeCreateStuntProp(hash, sx, sy, sz, false)
            STREAMING.SET_MODEL_AS_NO_LONGER_NEEDED(hash)

            if isValidEntity(obj) then
                pcall(function()
                    ENTITY.FREEZE_ENTITY_POSITION(obj, true)
                    ENTITY.SET_ENTITY_COLLISION(obj, true, true)
                    ENTITY.SET_ENTITY_COORDS_NO_OFFSET(obj, sx, sy, sz, false, false, false)
                end)
                table.insert(spawned_stunt_objects, obj)
                notify.success("MAC_Fun_Script", "Objeto de teste [" .. modelName .. "] criado com sucesso!")
            else
                notify.error("MAC_Fun_Script", "Falha ao instanciar objeto de teste.")
            end
        end)

        if not ok then
            notify.error("MAC_Fun_Script", "Erro no teste: " .. tostring(err))
        end
    end)
end

-- ════════════════════════════════════════════════════════════════════
-- PROJETO MAZE BANK (Portais Neon 8X + Núcleo OVNI no Topo)
-- ════════════════════════════════════════════════════════════════════
local spawned_mazebank_objects = {}
local mazeBankSummitCoords = { x = -76.78993, y = -818.6607, z = 408.0 }

local mazeBankPropList = {
    { model = "ar_prop_ar_neon_gate8x_01a", x = -72.35743, y = -807.41730, z = 70.98969,  rx = 0.0, ry = 90.0, rz = 0.0 },
    { model = "ar_prop_ar_neon_gate8x_01a", x = -72.35743, y = -807.41730, z = 145.84317, rx = 0.0, ry = 90.0, rz = 0.0 },
    { model = "ar_prop_ar_neon_gate8x_01a", x = -72.35743, y = -807.41730, z = 219.16479, rx = 0.0, ry = 90.0, rz = 0.0 },
    { model = "ar_prop_ar_neon_gate8x_01a", x = -72.35743, y = -807.41730, z = 292.91010, rx = 0.0, ry = 90.0, rz = 0.0 },
    { model = "sum_prop_dufocore_01a",      x = -76.78993, y = -818.66071, z = 404.13724, rx = 0.0, ry = 0.0,  rz = 0.0 },
}

local function clearMazeBankProject()
    local count = 0
    for _, b in ipairs(spawned_mazebank_objects) do
        if isValidEntity(b) then
            pcall(function()
                ENTITY.SET_ENTITY_AS_MISSION_ENTITY(b, true, true)
                ENTITY.DELETE_ENTITY(b)
            end)
            count = count + 1
        end
    end
    spawned_mazebank_objects = {}
    notify.info("MAC_Fun_Script", string.format("Projeto Maze Bank (%d objetos) removido do mapa!", count))
end

local function spawnMazeBankProject()
    script.run_in_callback(function()
        local ok, err = pcall(function()
            -- Limpa estrutura anterior
            for _, b in ipairs(spawned_mazebank_objects) do
                if isValidEntity(b) then
                    pcall(function()
                        ENTITY.SET_ENTITY_AS_MISSION_ENTITY(b, true, true)
                        ENTITY.DELETE_ENTITY(b)
                    end)
                end
            end
            spawned_mazebank_objects = {}

            notify.info("MAC_Fun_Script", "Construindo Projeto Maze Bank...")

            for idx, item in ipairs(mazeBankPropList) do
                local hash = getModelHash(item.model)
                if not hash or hash == 0 then
                    pcall(function()
                        if MISC and MISC.GET_HASH_KEY then
                            hash = MISC.GET_HASH_KEY(item.model)
                        end
                    end)
                end

                pcall(function() STREAMING.REQUEST_MODEL(hash) end)
                local t = 0
                while not STREAMING.HAS_MODEL_LOADED(hash) and t < 80 do
                    script.yield(15)
                    t = t + 1
                end

                if STREAMING.HAS_MODEL_LOADED(hash) then
                    local obj = safeCreateStuntProp(hash, item.x, item.y, item.z, false)
                    STREAMING.SET_MODEL_AS_NO_LONGER_NEEDED(hash)

                    if isValidEntity(obj) then
                        pcall(function()
                            ENTITY.FREEZE_ENTITY_POSITION(obj, true)
                            ENTITY.SET_ENTITY_COLLISION(obj, true, true)
                            ENTITY.SET_ENTITY_COORDS_NO_OFFSET(obj, item.x, item.y, item.z, false, false, false)
                            if item.rx or item.ry or item.rz then
                                ENTITY.SET_ENTITY_ROTATION(obj, item.rx or 0.0, item.ry or 0.0, item.rz or 0.0, 2, true)
                            end
                            if ENTITY.SET_ENTITY_LOD_DIST then
                                ENTITY.SET_ENTITY_LOD_DIST(obj, 0xFFFF)
                            end
                        end)
                        table.insert(spawned_mazebank_objects, obj)
                        table.insert(spawned_stunt_objects, obj)
                    end
                else
                    notify.warn("MAC_Fun_Script", "Falha ao carregar modelo: " .. item.model)
                end
                script.yield(20)
            end

            notify.success("MAC_Fun_Script", string.format("Projeto Maze Bank [%d objetos] gerado com sucesso!", #spawned_mazebank_objects))
        end)

        if not ok then
            notify.error("MAC_Fun_Script", "Erro ao gerar Projeto Maze Bank: " .. tostring(err))
        end
    end)
end

local function teleportAllPlayersToMazeBank()
    script.run_in_callback(function()
        local ok, err = pcall(function()
            local tx = mazeBankSummitCoords.x
            local ty = mazeBankSummitCoords.y
            local tz = mazeBankSummitCoords.z

            -- 1. Teleporta você mesmo para o topo do Maze Bank
            pcall(function()
                local myPed = PLAYER.PLAYER_PED_ID()
                if isValidEntity(myPed) then
                    local myVeh = PED.GET_VEHICLE_PED_IS_IN(myPed, false)
                    if isValidEntity(myVeh) then
                        ENTITY.SET_ENTITY_COORDS(myVeh, tx, ty, tz + 1.0, false, false, false, true)
                    else
                        ENTITY.SET_ENTITY_COORDS(myPed, tx, ty, tz, false, false, false, true)
                    end
                end
            end)

            -- 2. Teleporta todos os outros jogadores da sessão
            local activePlayers = get_active_session_players()
            local count = 0
            for _, pid in ipairs(activePlayers) do
                pcall(function()
                    local ped = getPlayerPedSafe(pid)
                    if isValidEntity(ped) and ped ~= PLAYER.PLAYER_PED_ID() then
                        local px = tx + (math.random() * 12.0 - 6.0)
                        local py = ty + (math.random() * 12.0 - 6.0)
                        local pz = tz + 0.5

                        local veh = PED.GET_VEHICLE_PED_IS_IN(ped, false)
                        if isValidEntity(veh) then
                            pcall(function()
                                if NETWORK.NETWORK_REQUEST_CONTROL_OF_ENTITY then
                                    NETWORK.NETWORK_REQUEST_CONTROL_OF_ENTITY(veh)
                                end
                                ENTITY.SET_ENTITY_COORDS_NO_OFFSET(veh, px, py, pz, false, false, false)
                                ENTITY.SET_ENTITY_VELOCITY(veh, 0.0, 0.0, 0.0)
                            end)
                        else
                            pcall(function()
                                if NETWORK.NETWORK_REQUEST_CONTROL_OF_ENTITY then
                                    NETWORK.NETWORK_REQUEST_CONTROL_OF_ENTITY(ped)
                                end
                                ENTITY.SET_ENTITY_COORDS_NO_OFFSET(ped, px, py, pz, false, false, false)
                                ENTITY.SET_ENTITY_COORDS(ped, px, py, pz, false, false, false, true)
                                ENTITY.SET_ENTITY_VELOCITY(ped, 0.0, 0.0, 0.0)
                            end)
                        end
                        count = count + 1
                    end
                end)
            end

            notify.success("MAC_Fun_Script", string.format("Você e %d jogadores teleportados para o topo do Maze Bank!", count))
        end)

        if not ok then
            notify.error("MAC_Fun_Script", "Erro ao teleportar para Maze Bank: " .. tostring(err))
        end
    end)
end

-- -- Player Prop Attachment Suite Mechanics -------------------

local function getControlOfEntity(ent)
    if not isValidEntity(ent) then return end
    pcall(function()
        if NETWORK and NETWORK.NETWORK_HAS_CONTROL_OF_ENTITY and not NETWORK.NETWORK_HAS_CONTROL_OF_ENTITY(ent) then
            if NETWORK.NETWORK_REQUEST_CONTROL_OF_ENTITY then
                NETWORK.NETWORK_REQUEST_CONTROL_OF_ENTITY(ent)
            end
        end
        if ENTITY and ENTITY.SET_ENTITY_AS_MISSION_ENTITY then
            ENTITY.SET_ENTITY_AS_MISSION_ENTITY(ent, true, true)
        end
    end)
end

local function getPedBoneIndexSafe(ped, boneId)
    local idx = 0
    pcall(function()
        if PED and PED.GET_PED_BONE_INDEX then
            idx = PED.GET_PED_BONE_INDEX(ped, boneId or 31086)
        end
    end)
    if not idx or idx < 0 then idx = 0 end
    return idx
end

local function getPlayerPedSafe(pid)
    local myLocalPid = get_local_pid()
    if pid == nil or pid == -1 or pid == myLocalPid then
        return PLAYER.PLAYER_PED_ID()
    end
    local ped = 0
    pcall(function()
        if PLAYER and PLAYER.GET_PLAYER_PED_SCRIPT_INDEX then
            ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
        end
        if (not ped or ped == 0 or not ENTITY.DOES_ENTITY_EXIST(ped)) and PLAYER and PLAYER.GET_PLAYER_PED then
            ped = PLAYER.GET_PLAYER_PED(pid)
        end
        if (not ped or ped == 0 or not ENTITY.DOES_ENTITY_EXIST(ped)) and player and player.get_player_ped then
            ped = player.get_player_ped(pid)
        end
        if (not ped or ped == 0 or not ENTITY.DOES_ENTITY_EXIST(ped)) and players and players.get_ped then
            ped = players.get_ped(pid)
        end
    end)
    return ped
end

local function getTargetCoordsSafe(pid, ped)
    local coords = nil
    pcall(function()
        if ped and ped ~= 0 and ENTITY.DOES_ENTITY_EXIST(ped) then
            local c = ENTITY.GET_ENTITY_COORDS(ped, true)
            if c and (c.x ~= 0 or c.y ~= 0 or c.z ~= 0) then
                coords = c
            end
        end
    end)
    if not coords and pid and pid >= 0 then
        pcall(function()
            if player and player.get_player_coords then
                coords = player.get_player_coords(pid)
            elseif players and players.get_position then
                coords = players.get_position(pid)
            end
        end)
    end
    if not coords or (coords.x == 0 and coords.y == 0 and coords.z == 0) then
        local localPed = PLAYER.PLAYER_PED_ID()
        coords = ENTITY.GET_ENTITY_COORDS(localPed, true)
    end
    return coords
end

-- Configuração idêntica à das rampas e loops com suporte a sincronização de rede para todos
local function configureStuntEntity(obj, targetPid)
    if not isValidEntity(obj) then return end
    pcall(function()
        ENTITY.SET_ENTITY_AS_MISSION_ENTITY(obj, true, true)
        ENTITY.SET_ENTITY_VISIBLE(obj, true, false)
        ENTITY.SET_ENTITY_COLLISION(obj, false, false)
        if ENTITY.SET_ENTITY_LOCALLY_VISIBLE then
            ENTITY.SET_ENTITY_LOCALLY_VISIBLE(obj)
        end
        if ENTITY.SET_ENTITY_LOD_DIST then
            ENTITY.SET_ENTITY_LOD_DIST(obj, 0xFFFF)
        end
        if NETWORK then
            if NETWORK.NETWORK_REGISTER_ENTITY_AS_NETWORKED then
                NETWORK.NETWORK_REGISTER_ENTITY_AS_NETWORKED(obj)
            end
            if NETWORK.OBJ_TO_NET then
                local netId = NETWORK.OBJ_TO_NET(obj)
                if netId and netId ~= 0 then
                    if NETWORK.SET_NETWORK_ID_EXISTS_ON_ALL_MACHINES then
                        NETWORK.SET_NETWORK_ID_EXISTS_ON_ALL_MACHINES(netId, true)
                    end
                    if NETWORK.SET_NETWORK_ID_CAN_MIGRATE then
                        NETWORK.SET_NETWORK_ID_CAN_MIGRATE(netId, true)
                    end
                    if NETWORK.SET_NETWORK_ID_ALWAYS_EXISTS_FOR_PLAYER and targetPid and targetPid >= 0 then
                        NETWORK.SET_NETWORK_ID_ALWAYS_EXISTS_FOR_PLAYER(netId, targetPid, true)
                    end
                end
            end
        end
    end)
end

local function attachEntityDirect(obj, ped, boneId, offX, offY, offZ, rotX, rotY, rotZ)
    if not isValidEntity(obj) or not isValidEntity(ped) then return false end
    
    local boneIndex = getPedBoneIndexSafe(ped, boneId)
    local attached = false

    pcall(function()
        if ENTITY.SET_ENTITY_NO_COLLISION_ENTITY then
            ENTITY.SET_ENTITY_NO_COLLISION_ENTITY(obj, ped, false)
        end
    end)

    -- 1. Padrão nativo do GTA V (p9 = true para atualização imediata na árvore de sync)
    pcall(function()
        ENTITY.ATTACH_ENTITY_TO_ENTITY(
            obj, ped, boneIndex,
            offX or 0.0, offY or 0.0, offZ or 0.0,
            rotX or 0.0, rotY or 0.0, rotZ or 0.0,
            true, false, false, false, 2, true
        )
        attached = true
    end)

    -- 2. Fallback com p9 = false
    if not attached then
        pcall(function()
            ENTITY.ATTACH_ENTITY_TO_ENTITY(
                obj, ped, boneIndex,
                offX or 0.0, offY or 0.0, offZ or 0.0,
                rotX or 0.0, rotY or 0.0, rotZ or 0.0,
                false, false, false, false, 2, true
            )
            attached = true
        end)
    end

    -- 3. Fallback com 16 parâmetros (p15 = 1)
    if not attached then
        pcall(function()
            ENTITY.ATTACH_ENTITY_TO_ENTITY(
                obj, ped, boneIndex,
                offX or 0.0, offY or 0.0, offZ or 0.0,
                rotX or 0.0, rotY or 0.0, rotZ or 0.0,
                true, false, false, false, 2, true, 1
            )
            attached = true
        end)
    end

    -- 4. Fallback básico (vertexIndex = 0)
    if not attached then
        pcall(function()
            ENTITY.ATTACH_ENTITY_TO_ENTITY(
                obj, ped, boneIndex,
                offX or 0.0, offY or 0.0, offZ or 0.0,
                rotX or 0.0, rotY or 0.0, rotZ or 0.0,
                false, false, false, false, 0, true, 0
            )
            attached = true
        end)
    end

    return attached
end

local isAttachmentKeeperRunning = false
local function startAttachmentKeeperLoop()
    if isAttachmentKeeperRunning then return end
    isAttachmentKeeperRunning = true

    script.run_in_callback(function()
        while true do
            local hasAny = false
            local myLocalPid = get_local_pid()

            for actualPid, list in pairs(attached_player_props) do
                local ped = getPlayerPedSafe(actualPid)

                if isValidEntity(ped) then
                    for _, item in ipairs(list) do
                        hasAny = true
                        pcall(function()
                            -- Verifica se o objeto ainda está preso
                            local isAttached = false
                            if isValidEntity(item.obj) then
                                if ENTITY.IS_ENTITY_ATTACHED_TO_ENTITY then
                                    isAttached = ENTITY.IS_ENTITY_ATTACHED_TO_ENTITY(item.obj, ped)
                                elseif ENTITY.IS_ENTITY_ATTACHED then
                                    isAttached = ENTITY.IS_ENTITY_ATTACHED(item.obj)
                                end
                            end

                            -- Se o player respawnou ou o objeto sumiu, recria com a mesma lógica das rampas/loops
                            if not isAttached and not PLAYER.IS_PLAYER_DEAD(ped) then
                                if isValidEntity(item.obj) then
                                    pcall(function()
                                        ENTITY.DETACH_ENTITY(item.obj, true, true)
                                        ENTITY.SET_ENTITY_AS_MISSION_ENTITY(item.obj, true, true)
                                        ENTITY.DELETE_ENTITY(item.obj)
                                    end)
                                end

                                local hash = item.hash or getModelHash(item.modelName)
                                if hash and hash ~= 0 then
                                    STREAMING.REQUEST_MODEL(hash)
                                    if STREAMING.HAS_MODEL_LOADED(hash) then
                                        local coords = getTargetCoordsSafe(actualPid, ped)
                                        local newObj = safeCreateStuntProp(hash, coords.x, coords.y, coords.z, true)
                                        if isValidEntity(newObj) then
                                            configureStuntEntity(newObj, actualPid)
                                            attachEntityDirect(newObj, ped, item.boneId or 31086, item.offX, item.offY, item.offZ, item.rotX, item.rotY, item.rotZ)
                                            item.obj = newObj
                                            STREAMING.SET_MODEL_AS_NO_LONGER_NEEDED(hash)
                                        end
                                    end
                                end
                            end
                        end)
                    end
                end
            end

            -- Monitoramento do Angel Floatie (Persistência pós-morte)
            if angelFloatieActive then
                hasAny = true
                pcall(function()
                    local myPed = PLAYER.PLAYER_PED_ID()
                    if isValidEntity(myPed) and not PLAYER.IS_PLAYER_DEAD(myPed) then
                        local isAttached = false
                        if isValidEntity(angelFloatieObject) then
                            if ENTITY.IS_ENTITY_ATTACHED_TO_ENTITY then
                                isAttached = ENTITY.IS_ENTITY_ATTACHED_TO_ENTITY(angelFloatieObject, myPed)
                            elseif ENTITY.IS_ENTITY_ATTACHED then
                                isAttached = ENTITY.IS_ENTITY_ATTACHED(angelFloatieObject)
                            end
                        end

                        if not isAttached then
                            createAngelFloatie()
                        end
                    end
                end)
            end

            if not hasAny then
                isAttachmentKeeperRunning = false
                break
            end
            script.yield(250)
        end
    end)
end

local function attachPropToPlayer(targetPid, modelName, boneId, offX, offY, offZ, rotX, rotY, rotZ)
    script.run_in_callback(function()
        local ok, err = pcall(function()
            local myLocalPid = get_local_pid()
            local actualPid = (targetPid == nil or targetPid == -1) and myLocalPid or targetPid
            local ped = getPlayerPedSafe(actualPid)

            if not isValidEntity(ped) then
                notify.warn("MAC_Fun_Script", "Jogador não encontrado ou fora do alcance da sessão!")
                return
            end

            local hash = getModelHash(modelName)
            if not hash or hash == 0 then
                notify.warn("MAC_Fun_Script", "Modelo de objeto inválido: " .. tostring(modelName))
                return
            end

            pcall(function() STREAMING.REQUEST_MODEL(hash) end)
            local t = 0
            while not STREAMING.HAS_MODEL_LOADED(hash) and t < 80 do
                script.yield(10)
                t = t + 1
            end

            if not STREAMING.HAS_MODEL_LOADED(hash) then
                if modelName == "prop_mp_cone_01" then
                    hash = getModelHash("prop_roadcone02a")
                    pcall(function() STREAMING.REQUEST_MODEL(hash) end)
                    t = 0
                    while not STREAMING.HAS_MODEL_LOADED(hash) and t < 60 do
                        script.yield(10)
                        t = t + 1
                    end
                end
            end

            if not STREAMING.HAS_MODEL_LOADED(hash) then
                notify.warn("MAC_Fun_Script", "Falha ao carregar modelo: " .. tostring(modelName))
                return
            end

            local coords = getTargetCoordsSafe(actualPid, ped)

            -- 1. Cria o objeto no mundo networked (visível para todos como rampas)
            local obj = safeCreateStuntProp(hash, coords.x, coords.y, coords.z, false)
            STREAMING.SET_MODEL_AS_NO_LONGER_NEEDED(hash)

            if not isValidEntity(obj) then
                notify.error("MAC_Fun_Script", "Falha ao instanciar o objeto no mundo.")
                return
            end

            -- 2. Configura a entidade com suporte a rede
            configureStuntEntity(obj, actualPid)

            -- 3. Anexa diretamente ao osso do Ped
            attachEntityDirect(obj, ped, boneId or 24818, offX, offY, offZ, rotX, rotY, rotZ)

            if not attached_player_props[actualPid] then
                attached_player_props[actualPid] = {}
            end

            table.insert(attached_player_props[actualPid], {
                obj = obj,
                hash = hash,
                modelName = modelName,
                boneId = boneId or 24818,
                offX = offX or 0.0,
                offY = offY or 0.0,
                offZ = offZ or 0.0,
                rotX = rotX or 0.0,
                rotY = rotY or 0.0,
                rotZ = rotZ or 0.0
            })

            startAttachmentKeeperLoop()

            local pName = (actualPid == myLocalPid) and "Você" or get_player_name(actualPid)
            notify.success("MAC_Fun_Script", string.format("Objeto [%s] fixado em %s!", tostring(modelName), pName))
        end)

        if not ok then
            notify.error("MAC_Fun_Script", "Erro ao fixar objeto: " .. tostring(err))
        end
    end)
end

local function removePlayerAttachedProps(targetPid)
    local actualPid = (targetPid == -1) and get_local_pid() or targetPid
    local list = attached_player_props[actualPid]
    local count = 0
    if list then
        for _, item in ipairs(list) do
            local obj = type(item) == "table" and item.obj or item
            if isValidEntity(obj) then
                pcall(function()
                    ENTITY.DETACH_ENTITY(obj, true, true)
                    ENTITY.SET_ENTITY_AS_MISSION_ENTITY(obj, true, true)
                    ENTITY.DELETE_ENTITY(obj)
                end)
                count = count + 1
            end
        end
        attached_player_props[actualPid] = nil
    end
    notify.info("MAC_Fun_Script", string.format("%d objetos removidos do jogador!", count))
end

local function removeAllAttachedProps()
    local count = 0
    for targetPid, list in pairs(attached_player_props) do
        for _, item in ipairs(list) do
            local obj = type(item) == "table" and item.obj or item
            if isValidEntity(obj) then
                pcall(function()
                    ENTITY.DETACH_ENTITY(obj, true, true)
                    ENTITY.SET_ENTITY_AS_MISSION_ENTITY(obj, true, true)
                    ENTITY.DELETE_ENTITY(obj)
                end)
                count = count + 1
            end
        end
    end
    attached_player_props = {}
    notify.info("MAC_Fun_Script", string.format("Todos os %d objetos anexados foram removidos!", count))
end

-- -- Angel Self Floatie State & Mechanics ------------------------
local angelFloatieObject = nil
local angelFloatieActive = false

local function removeAngelFloatie(silent)
    angelFloatieActive = false
    if isValidEntity(angelFloatieObject) then
        pcall(function()
            if ENTITY.IS_ENTITY_ATTACHED and ENTITY.IS_ENTITY_ATTACHED(angelFloatieObject) then
                ENTITY.DETACH_ENTITY(angelFloatieObject, true, true)
            end
            ENTITY.SET_ENTITY_AS_MISSION_ENTITY(angelFloatieObject, true, true)
            OBJECT.DELETE_OBJECT(angelFloatieObject)
        end)
    end
    angelFloatieObject = nil
    if not silent then
        notify.info("Angel Floatie", "Boia removida.")
    end
end

local function createAngelFloatie()
    if angelFloatieActive and isValidEntity(angelFloatieObject) then
        return true
    end

    if angelFloatieObject and not isValidEntity(angelFloatieObject) then
        angelFloatieObject = nil
        angelFloatieActive = false
    end

    local ped = PLAYER.PLAYER_PED_ID()
    if not isValidEntity(ped) then
        notify.error("Angel Floatie", "Não foi possível obter o seu ped.")
        return false
    end

    local modelHash = getModelHash("prop_beach_ring_01")
    if modelHash == 0 then return false end

    pcall(function() STREAMING.REQUEST_MODEL(modelHash) end)
    local t = 0
    while not STREAMING.HAS_MODEL_LOADED(modelHash) and t < 100 do
        script.yield(10)
        t = t + 1
    end

    if not STREAMING.HAS_MODEL_LOADED(modelHash) then
        notify.error("Angel Floatie", "Não foi possível carregar o modelo da boia.")
        return false
    end

    local coords = ENTITY.GET_ENTITY_COORDS(ped, true)
    local obj = safeCreateStuntProp(modelHash, coords.x, coords.y, coords.z, false)
    STREAMING.SET_MODEL_AS_NO_LONGER_NEEDED(modelHash)

    if not isValidEntity(obj) then
        notify.error("Angel Floatie", "Falha ao criar o objeto da boia.")
        return false
    end

    angelFloatieObject = obj
    configureStuntEntity(obj)

    local attached = attachEntityDirect(obj, ped, 11816, 0.0, 0.0, 0.0, 0.0, 90.0, 0.0)

    if not attached then
        removeAngelFloatie(true)
        notify.error("Angel Floatie", "Falha no attach da boia.")
        return false
    end

    angelFloatieActive = true
    startAttachmentKeeperLoop()
    notify.success("Angel Floatie", "Boia anexada à sua cintura!")
    return true
end

local function toggleAngelFloatie()
    if angelFloatieActive and isValidEntity(angelFloatieObject) then
        removeAngelFloatie(false)
        return
    end
    createAngelFloatie()
end

-- ════════════════════════════════════════════════════════════════════
-- SISTEMA DE CLIMA E ATMOSFERA GLOBAL / HALLOWEEN
-- ════════════════════════════════════════════════════════════════════
local halloweenModeActive = false
local halloweenLoopRunning = false

local function setSessionWeather(weatherName, setMidnight)
    script.run_in_callback(function()
        local ok, err = pcall(function()
            local wName = string.upper(weatherName or "CLEAR")

            if MISC then
                if MISC.SET_WEATHER_TYPE_NOW_PERSIST then
                    MISC.SET_WEATHER_TYPE_NOW_PERSIST(wName)
                end
                if MISC.SET_WEATHER_TYPE_NOW then
                    MISC.SET_WEATHER_TYPE_NOW(wName)
                end
                if MISC.SET_WEATHER_TYPE_OVERTIME_PERSIST then
                    MISC.SET_WEATHER_TYPE_OVERTIME_PERSIST(wName, 1.0)
                end
                if MISC.SET_OVERRIDE_WEATHER then
                    MISC.SET_OVERRIDE_WEATHER(wName)
                end
            end

            if setMidnight and CLOCK and CLOCK.SET_CLOCK_TIME then
                CLOCK.SET_CLOCK_TIME(0, 0, 0)
            end

            -- Dispara comando nativo do Stand/Menu se disponível
            pcall(function()
                if menu and menu.trigger_commands then
                    menu.trigger_commands("weather " .. string.lower(wName))
                end
            end)

            notify.success("MAC_Fun_Script", string.format("Clima [%s] aplicado!", wName))
        end)
        if not ok then
            notify.error("MAC_Fun_Script", "Erro ao alterar clima: " .. tostring(err))
        end
    end)
end

local function toggleHalloweenWeather()
    halloweenModeActive = not halloweenModeActive

    if halloweenModeActive then
        setSessionWeather("HALLOWEEN", true)
        notify.success("MAC_Fun_Script", "Modo Halloween ATIVADO: Céu verde/laranja, relâmpagos e névoa!")

        if not halloweenLoopRunning then
            halloweenLoopRunning = true
            script.run_in_callback(function()
                while halloweenModeActive do
                    pcall(function()
                        if MISC and MISC.FORCE_LIGHTNING_FLASH then
                            MISC.FORCE_LIGHTNING_FLASH()
                        end
                        if CLOCK and CLOCK.SET_CLOCK_TIME then
                            CLOCK.SET_CLOCK_TIME(0, 0, 0)
                        end
                    end)
                    script.yield(math.random(3000, 6000))
                end
                halloweenLoopRunning = false
            end)
        end
    else
        pcall(function()
            if MISC and MISC.CLEAR_OVERRIDE_WEATHER then
                MISC.CLEAR_OVERRIDE_WEATHER()
            end
        end)
        setSessionWeather("EXTRASUNNY", false)
        notify.info("MAC_Fun_Script", "Modo Halloween DESATIVADO.")
    end
end

-- ════════════════════════════════════════════════════════════════════
-- SISTEMA DE CICLO RÁPIDO DE HORAS (TIMELAPSE DIA & NOITE)
-- ════════════════════════════════════════════════════════════════════
local fastTimeActive = false
local fastTimeLoopRunning = false
local fastTimeSpeed = 15 -- minutos de avanço por pulso (1 a 60)

local function startFastTimeLoop()
    if fastTimeLoopRunning then return end
    fastTimeLoopRunning = true

    script.run_in_callback(function()
        local currentMinutes = 0
        pcall(function()
            if CLOCK and CLOCK.GET_CLOCK_HOURS and CLOCK.GET_CLOCK_MINUTES then
                currentMinutes = CLOCK.GET_CLOCK_HOURS() * 60 + CLOCK.GET_CLOCK_MINUTES()
            end
        end)

        while fastTimeActive do
            currentMinutes = (currentMinutes + fastTimeSpeed) % 1440
            local h = math.floor(currentMinutes / 60)
            local m = math.floor(currentMinutes % 60)

            pcall(function()
                if CLOCK and CLOCK.SET_CLOCK_TIME then
                    CLOCK.SET_CLOCK_TIME(h, m, 0)
                end
                if NETWORK and NETWORK.NETWORK_OVERRIDE_CLOCK_TIME then
                    NETWORK.NETWORK_OVERRIDE_CLOCK_TIME(h, m, 0)
                end
            end)

            script.yield(40) -- ~25 atualizações por segundo para transição suave de sol/lua
        end

        fastTimeLoopRunning = false
    end)
end

local function toggleFastTimeCycle()
    fastTimeActive = not fastTimeActive
    if fastTimeActive then
        startFastTimeLoop()
        notify.success("MAC_Fun_Script", "Ciclo Rápido de Horas (Timelapse) ATIVADO!")
    else
        notify.info("MAC_Fun_Script", "Ciclo Rápido de Horas DESATIVADO.")
    end
end

-- -- NewWay ImGui Interface Modular Tabs -----------------------

local function renderTabVehicleControls()
    if not imgui.begin_tab_item("Vehicle Controls") then return end
    imgui.spacing()
    imgui.text("Target Vehicle Actions:")
    imgui.separator()
    imgui.spacing()

    if imgui.button("Lift Vehicle Up (+ " .. math.floor(liftHeight) .. "m)##lift_btn") then
        script.run_in_callback(function()
            local veh = getTargetVehicle()
            if veh then
                LiftVehicle(veh, liftHeight)
                notify.success("MAC_Fun_Script", "Vehicle lifted!")
            else
                notify.warn("MAC_Fun_Script", "No target vehicle found!")
            end
        end)
    end

    imgui.same_line()

    if imgui.button(isHoldingVehicle and "Release Vehicle##hold_btn" or "Hold in Air (Telekinesis)##hold_btn") then
        local veh = getTargetVehicle()
        HoldVehicleLoop(veh)
    end

    imgui.spacing()

    if imgui.button("Launch Vehicle (Throw)##launch_btn") then
        script.run_in_callback(function()
            if isHoldingVehicle and heldVehicle then
                local target = heldVehicle
                isHoldingVehicle = false
                LaunchVehicle(target, launchForce)
                notify.success("MAC_Fun_Script", "Vehicle LAUNCHED!")
            else
                local veh = getTargetVehicle()
                if veh then
                    LaunchVehicle(veh, launchForce)
                    notify.success("MAC_Fun_Script", "Vehicle LAUNCHED!")
                else
                    notify.warn("MAC_Fun_Script", "No target vehicle found!")
                end
            end
        end)
    end

    imgui.same_line()

    if imgui.button("Slam Vehicle to Ground##slam_btn") then
        script.run_in_callback(function()
            local veh = isHoldingVehicle and heldVehicle or getTargetVehicle()
            if veh then
                isHoldingVehicle = false
                SlamVehicle(veh)
                notify.success("MAC_Fun_Script", "Slammed vehicle down!")
            end
        end)
    end

    local cSpinPlayer, vSpinPlayer = imgui.checkbox("Beyblade: Player Vehicle (Spin on Ground)##spin_my_veh", spinPlayerVehActive)
    if cSpinPlayer then
        spinPlayerVehActive = vSpinPlayer
        if spinPlayerVehActive then
            startSpinPlayerVehLoop()
            state.status = "Player Vehicle Beyblade ENABLED"
            notify.success("MAC_Fun_Script", "Player Vehicle Beyblade ENABLED!")
        else
            state.status = "Player Vehicle Beyblade DISABLED"
            notify.info("MAC_Fun_Script", "Player Vehicle Beyblade DISABLED!")
        end
    end

    imgui.spacing()
    imgui.separator()
    imgui.spacing()

    imgui.text("Lift Height (Meters):")
    imgui.same_line()
    if imgui.button("5m##h5") then liftHeight = 5.0 end
    imgui.same_line()
    if imgui.button("10m##h10") then liftHeight = 10.0 end
    imgui.same_line()
    if imgui.button("25m##h25") then liftHeight = 25.0 end
    imgui.same_line()
    if imgui.button("50m##h50") then liftHeight = 50.0 end

    imgui.spacing()

    imgui.text("Launch Speed (Force):")
    imgui.same_line()
    if imgui.button("Soft (50)##f50") then launchForce = 50.0 end
    imgui.same_line()
    if imgui.button("Medium (150)##f150") then launchForce = 150.0 end
    imgui.same_line()
    if imgui.button("Heavy (300)##f300") then launchForce = 300.0 end
    imgui.same_line()
    if imgui.button("SUPER LAUNCH (600)##f600") then launchForce = 600.0 end

    imgui.spacing()
    imgui.separator()
    imgui.spacing()

    imgui.text("Acoes com Jogadores (Carregar no Colo):")

    local btnCarryText = isCarryingPlayer and "Soltar Jogador do Colo (Drop Player)##carry_ply_btn" or "Carregar Jogador no Colo (Carry in Arms)##carry_ply_btn"
    if imgui.button(btnCarryText) then
        local pPed = getTargetPlayerPed()
        startCarryingPlayer(pPed)
    end

    imgui.end_tab_item()
end

local function renderTabAreaChaos()
    if not imgui.begin_tab_item("Area Chaos") then return end
    imgui.spacing()
    imgui.text("Mass Vehicle & Chaos Actions:")
    imgui.separator()
    imgui.spacing()

    if imgui.button("Lift ALL Nearby Vehicles##area_lift") then
        script.run_in_callback(function()
            local vehicles = getAllNearbyVehicles(100.0)
            local count = 0
            for _, veh in ipairs(vehicles) do
                LiftVehicle(veh, liftHeight)
                count = count + 1
            end
            state.status = "Lifted " .. count .. " nearby vehicles"
            notify.success("MAC_Fun_Script", "Lifted " .. count .. " nearby vehicles!")
        end)
    end

    imgui.same_line()

    if imgui.button("Launch ALL Nearby Vehicles Into Sky##area_yeet") then
        script.run_in_callback(function()
            local vehicles = getAllNearbyVehicles(100.0)
            local count = 0
            for _, veh in ipairs(vehicles) do
                LaunchVehicle(veh, launchForce)
                count = count + 1
            end
            state.status = "Launched " .. count .. " nearby vehicles into orbit"
            notify.success("MAC_Fun_Script", "Launched " .. count .. " nearby vehicles into orbit!")
        end)
    end

    imgui.spacing()

    local cSpinArea2, vSpinArea2 = imgui.checkbox("Continuous Area Beyblade (All Vehicles Spin on Ground 100m)##area_spin_chk", spinAreaVehsActive)
    if cSpinArea2 then
        spinAreaVehsActive = vSpinArea2
        if cSpinArea2 then
            startSpinAreaVehsLoop()
            state.status = "Area Vehicle Beyblade ENABLED"
            notify.success("MAC_Fun_Script", "Area Vehicle Beyblade ENABLED!")
        else
            state.status = "Area Vehicle Beyblade DISABLED"
            notify.info("MAC_Fun_Script", "Area Vehicle Beyblade DISABLED!")
        end
    end

    imgui.spacing()

    local cLev2, vLev2 = imgui.checkbox("Continuous Area Bounce (All Vehicles Up & Down)##area_lev_chk", infiniteLevitateActive)
    if cLev2 then
        infiniteLevitateActive = vLev2
        if infiniteLevitateActive then
            startInfiniteLevitateLoop()
            state.status = "Area Bounce Mode ENABLED"
            notify.success("MAC_Fun_Script", "Area Bounce Mode ENABLED!")
        else
            state.status = "Area Bounce Mode DISABLED"
            notify.info("MAC_Fun_Script", "Infinite Bounce Mode DISABLED!")
        end
    end

    imgui.spacing()

    local cVort, vVort = imgui.checkbox("Vehicle Vortex (Tornado / Hurricane)##vort_chk", vortexActive)
    if cVort then
        vortexActive = vVort
        if vortexActive then
            startVortexLoop()
            state.status = "Vehicle Vortex ENABLED"
            notify.success("MAC_Fun_Script", "Vehicle Vortex ENABLED!")
        else
            state.status = "Vehicle Vortex DISABLED"
            notify.info("MAC_Fun_Script", "Vehicle Vortex DISABLED!")
        end
    end

    imgui.spacing()

    local cUfo, vUfo = imgui.checkbox("UFO Party Mode (Lights, Neon & Horn)##ufo_chk", ufoDiscoActive)
    if cUfo then
        ufoDiscoActive = vUfo
        if ufoDiscoActive then
            startUfoDiscoLoop()
            state.status = "UFO Party Mode ENABLED"
            notify.success("MAC_Fun_Script", "UFO Party Mode ENABLED!")
        else
            state.status = "UFO Party Mode DISABLED"
            notify.info("MAC_Fun_Script", "UFO Party Mode DISABLED!")
        end
    end

    imgui.spacing()

    local cPush, vPush = imgui.checkbox("Vehicle Repulsor (Push Nearby Vehicles & Peds)##rep_chk", pushRepulsorActive)
    if cPush then
        pushRepulsorActive = vPush
        if pushRepulsorActive then
            startPushRepulsorLoop()
            state.status = "Vehicle Repulsor ENABLED"
            notify.success("MAC_Fun_Script", "Vehicle Repulsor ENABLED!")
        else
            state.status = "Vehicle Repulsor DISABLED"
            notify.info("MAC_Fun_Script", "Vehicle Repulsor DISABLED!")
        end
    end

    imgui.spacing()

    local cRain, vRain = imgui.checkbox("Meteor Vehicle Rain##rain_chk", vehicleRainActive)
    if cRain then
        vehicleRainActive = vRain
        if vehicleRainActive then
            startVehicleRainLoop()
            state.status = "Vehicle Rain ENABLED"
            notify.success("MAC_Fun_Script", "Vehicle Rain ENABLED!")
        else
            state.status = "Vehicle Rain DISABLED"
            notify.info("MAC_Fun_Script", "Vehicle Rain DISABLED!")
        end
    end

    imgui.spacing()

    local cShield, vShield = imgui.checkbox("Orbital Vehicle Shield (Kinetic Tanks)##shd_chk", vehicleShieldActive)
    if cShield then
        vehicleShieldActive = vShield
        if vehicleShieldActive then
            startVehicleShieldLoop()
            state.status = "Orbital Vehicle Shield ENABLED"
            notify.success("MAC_Fun_Script", "Orbital Vehicle Shield ENABLED!")
        else
            state.status = "Orbital Vehicle Shield DISABLED"
            notify.info("MAC_Fun_Script", "Orbital Vehicle Shield DISABLED!")
        end
    end

    imgui.spacing()

    if imgui.button("Vertical Bus Bowling (Panto Launcher)##bus_bowl_btn") then
        setupBusBowling()
        state.status = "Vertical Bus Bowling Setup Complete"
    end

    imgui.same_line()

    if imgui.button("Build Bus Fortress Wall##fort_btn") then
        triggerBusFortressWall()
        state.status = "Bus Fortress Wall Built"
    end

    imgui.spacing()

    local cSnake, vSnake = imgui.checkbox("Follow the Leader (Vehicle Trail Behind Player)##follow_leader_chk", vehicleSnakeActive)
    if cSnake then
        vehicleSnakeActive = vSnake
        if vehicleSnakeActive then
            startVehicleSnakeLoop()
            state.status = "Follow the Leader ENABLED"
            notify.success("MAC_Fun_Script", "Follow the Leader ENABLED!")
        else
            state.status = "Follow the Leader DISABLED"
            notify.info("MAC_Fun_Script", "Follow the Leader DISABLED!")
        end
    end

    imgui.spacing()

    local cZombP, vZombP = imgui.checkbox("Zombie Outbreak##zomb_ped_chk", zombiePedOutbreakActive)
    if cZombP then
        zombiePedOutbreakActive = vZombP
        if zombiePedOutbreakActive then
            startZombiePedOutbreakLoop()
            state.status = "Zombie Outbreak ENABLED"
            notify.success("MAC_Fun_Script", "Zombie Outbreak ENABLED! Spawning 15 aggressive zombies!")
        else
            state.status = "Zombie Outbreak DISABLED"
            notify.info("MAC_Fun_Script", "Zombie Outbreak DISABLED!")
        end
    end

    imgui.spacing()
    imgui.separator()
    imgui.spacing()

    -- ════════════════════════════════════════════════════════════
    -- CLIMA E ATMOSFERA GLOBAL DA SESSÃO (HALLOWEEN)
    -- ════════════════════════════════════════════════════════════
    imgui.text("Clima e Atmosfera da Sessão (Halloween & Climas Globais):")

    local hwBtnText = halloweenModeActive and ">> DESATIVAR MODO HALLOWEEN <<##hw_btn" or ">> ATIVAR MODO HALLOWEEN TERROR (Ceu Laranja + Trovoes) <<##hw_btn"
    if imgui.button(hwBtnText) then
        toggleHalloweenWeather()
    end

    imgui.spacing()
    imgui.text("Outros Climas Rápidos para a Sessão:")

    if imgui.button("Neve de Natal (XMAS)##w_xmas") then
        setSessionWeather("XMAS", false)
    end
    imgui.same_line()
    if imgui.button("Tempestade Severa (THUNDER)##w_thun") then
        setSessionWeather("THUNDER", false)
    end
    imgui.same_line()
    if imgui.button("Neblina Densa (FOGGY)##w_fog") then
        setSessionWeather("FOGGY", false)
    end

    if imgui.button("Dia Ensolarado (EXTRASUNNY)##w_sun") then
        setSessionWeather("EXTRASUNNY", false)
    end
    imgui.same_line()
    if imgui.button("Chuva com Raios (RAIN)##w_rain") then
        setSessionWeather("RAIN", false)
    end
    imgui.same_line()
    if imgui.button("Meia-Noite Sombria (00:00)##w_midn") then
        pcall(function()
            if CLOCK and CLOCK.SET_CLOCK_TIME then
                CLOCK.SET_CLOCK_TIME(0, 0, 0)
            end
            notify.success("MAC_Fun_Script", "Horário definido para 00:00 (Meia-Noite)!")
        end)
    end

    imgui.spacing()
    imgui.separator()
    imgui.spacing()

    -- ════════════════════════════════════════════════════════════
    -- CICLO RÁPIDO DE HORAS (TIMELAPSE DIA & NOITE)
    -- ════════════════════════════════════════════════════════════
    imgui.text("Ciclo Rápido de Horas do Dia (Timelapse Dia & Noite):")

    local timeBtnText = fastTimeActive and ">> DESATIVAR CICLO RAPIDO DE HORAS <<##ft_btn" or ">> ATIVAR CICLO RAPIDO DE HORAS (TIMELAPSE) <<##ft_btn"
    if imgui.button(timeBtnText) then
        toggleFastTimeCycle()
    end

    imgui.spacing()
    imgui.text("Velocidade do Timelapse (Avanço por frame):")
    if imgui.button("5x (Suave)##spd_5") then
        fastTimeSpeed = 5
        notify.info("MAC_Fun_Script", "Velocidade do Timelapse: 5x")
    end
    imgui.same_line()
    if imgui.button("15x (Padrão)##spd_15") then
        fastTimeSpeed = 15
        notify.info("MAC_Fun_Script", "Velocidade do Timelapse: 15x")
    end
    imgui.same_line()
    if imgui.button("30x (Rápido)##spd_30") then
        fastTimeSpeed = 30
        notify.info("MAC_Fun_Script", "Velocidade do Timelapse: 30x")
    end
    imgui.same_line()
    if imgui.button("60x (Insano)##spd_60") then
        fastTimeSpeed = 60
        notify.info("MAC_Fun_Script", "Velocidade do Timelapse: 60x (Insano)")
    end

    imgui.end_tab_item()
end

local function renderTabOptionsAndHotkeys()
    if not imgui.begin_tab_item("Options & Hotkeys") then return end
    imgui.spacing()
    imgui.text("Settings:")
    imgui.separator()
    imgui.spacing()

    local c1, v1 = imgui.checkbox("Ignite / Explode Vehicles on Launch##ign_chk", igniteOnLaunch)
    if c1 then igniteOnLaunch = v1 end

    local c2, v2 = imgui.checkbox("Make Vehicle Invincible While Lifting##inv_chk", makeInvincible)
    if c2 then makeInvincible = v2 end

    local c4, v4 = imgui.checkbox("Disable Player Ragdoll (No Fall / No Knockdown)##rag_chk", disableRagdoll)
    if c4 then
        disableRagdoll = v4
        updateRagdollState()
        notify.info("MAC_Fun_Script", disableRagdoll and "Ragdoll DISABLED (No falls)" or "Ragdoll ENABLED")
    end

    imgui.spacing()
    imgui.separator()
    imgui.spacing()

    local c3, v3 = imgui.checkbox("Enable Telekinesis Hotkeys & 3D Prompts (SPACE = Launch | E = Lift/Hold)##hk_chk", hotkeysEnabled)
    if c3 then
        hotkeysEnabled = v3
        if hotkeysEnabled then
            startHotkeyLoop()
        end
    end

    imgui.end_tab_item()
end

local function renderTabStuntTracks()
    if not imgui.begin_tab_item("Stunt Tracks & Ramps") then return end
    imgui.spacing()
    imgui.text("Mega Caos de Pistas & Estruturas Acrobaticas")
    imgui.separator()
    imgui.spacing()

    imgui.text("Aparecer Tudo / Mega Caos Integrado:")
    if imgui.button(">> GERAR MEGA CAOS TOTAL (APARECER TUDO: CEU + ASFALTO) <<##gen_all_chaos_btn") then
        spawnTotalSupremeChaos()
    end

    imgui.spacing()

    if imgui.button(">> APARECER TUDO NO ASFALTO (Todas as Rampas & Portais Neon da Cidade) <<##gen_all_ground_btn") then
        spawnAllGroundTracks()
    end

    imgui.spacing()

    if imgui.button(">> APARECER TUDO NO CEU (Mega Rodovias + Tubos 4X + Loops Orbitais) <<##gen_all_sky_btn") then
        spawnAllSkyTracks()
    end

    imgui.spacing()
    imgui.separator()
    imgui.spacing()

    imgui.text("Pistas Individuais Especificas:")
    if imgui.button("Cyber Arena Tube Highway (Ceu)##gen_cyber_tube_btn") then
        spawnStuntTrack(cyber_arena_highway_preset, "Cyber Arena Tube Highway")
    end
    imgui.same_line()
    if imgui.button("Arena Neon Speed Circuit (Ceu)##gen_neon_speed_btn") then
        spawnStuntTrack(arena_neon_speed_preset, "Arena Neon Speed Circuit")
    end

    if imgui.button("Mega Arena Jump & Loop (Ceu)##gen_mega_jump_btn") then
        spawnStuntTrack(mega_arena_jump_preset, "Mega Arena Jump & Loop")
    end
    imgui.same_line()
    if imgui.button("Mega Rodovia Acrobatica (Stunt Ceu)##gen_highway_btn") then
        spawnStuntTrack(stunt_highway_preset, "Mega Rodovia Acrobatica")
    end

    if imgui.button("Caos Urbano de Neon (Asfalto)##chaos_neon_urban_btn") then
        spawnArenaUrbanNeonChaos()
    end
    imgui.same_line()
    if imgui.button("Caos de Rampas Urbanas (Asfalto)##chaos_urban_btn") then
        spawnChaoticUrbanRamps()
    end
    imgui.same_line()
    if imgui.button("Pista de Saltos em Cascata##cascade_btn") then
        spawnCascadeRunway()
    end

    imgui.spacing()
    imgui.separator()
    imgui.spacing()

    imgui.text("Rampas Frontais Instantaneas (A sua frente):")
    if imgui.button("Rampa Mega Salto (Grande)##ramp_l") then
        spawnInstantFrontRamp("stt_prop_stunt_jump_l")
    end
    imgui.same_line()
    if imgui.button("Rampa Media##ramp_m") then
        spawnInstantFrontRamp("stt_prop_stunt_jump_m")
    end
    imgui.same_line()
    if imgui.button("Looping 360 Frontal##ramp_loop") then
        spawnInstantFrontRamp("stt_prop_stunt_track_dloop")
    end

    if imgui.button("Tubo Acelerador Frontal##ramp_tube") then
        spawnInstantFrontRamp("stt_prop_stunt_tube_l")
    end
    imgui.same_line()
    if imgui.button("Wallride Lateral 90 Graus##ramp_wall") then
        spawnInstantFrontRamp("stt_prop_stunt_track_dwuturn")
    end
    imgui.same_line()
    if imgui.button("Anel Speed Ring Frontal##ramp_speedring") then
        spawnSinglePropAtPlayer("ar_prop_ar_speed_ring", 15.0, 2.0, 0.0, true)
    end

    imgui.spacing()
    imgui.separator()
    imgui.spacing()

    imgui.text("Gerenciamento de Objetos Spawados:")
    if imgui.button("Desfazer Ultimo Objeto Criado##undo_stunt_btn") then
        undoLastStuntObject()
    end
    imgui.same_line()
    if imgui.button("Limpar Todas as Rampas e Pistas Criadas##clear_stunts_btn") then
        clearAllStuntObjects()
    end

    imgui.spacing()
    imgui.separator()
    imgui.spacing()

    imgui.text("Altura das Pistas Aereas no Ceu (Z): " .. math.floor(stunt_altitude) .. " metros")
    if imgui.button("50m (Baixo)##alt50") then stunt_altitude = 50.0 end
    imgui.same_line()
    if imgui.button("100m (Padrao)##alt100") then stunt_altitude = 100.0 end
    imgui.same_line()
    if imgui.button("160m (Alto)##alt160") then stunt_altitude = 160.0 end
    imgui.same_line()
    if imgui.button("250m (Orbital)##alt250") then stunt_altitude = 250.0 end

    imgui.end_tab_item()
end

local function renderTabArenaObjectSpawner()
    if not imgui.begin_tab_item("Arena & Stand Props") then return end
    imgui.spacing()
    imgui.text("Catalogo de Spawn Avulso - Arena War, Iate & Heists (Stand Export)")
    imgui.separator()
    imgui.spacing()

    imgui.text("Configuracoes de Posicionamento:")
    imgui.text("Distancia a Frente: " .. string.format("%.1f m", customSpawnDistance))
    imgui.same_line()
    if imgui.button("5m##sp_d5") then customSpawnDistance = 5.0 end
    imgui.same_line()
    if imgui.button("10m##sp_d10") then customSpawnDistance = 10.0 end
    imgui.same_line()
    if imgui.button("15m##sp_d15") then customSpawnDistance = 15.0 end
    imgui.same_line()
    if imgui.button("25m##sp_d25") then customSpawnDistance = 25.0 end
    imgui.same_line()
    if imgui.button("40m##sp_d40") then customSpawnDistance = 40.0 end

    imgui.text("Altura Z (Offset): " .. string.format("%.1f m", customSpawnHeight))
    imgui.same_line()
    if imgui.button("-1.0m (Chao)##sp_z_neg1") then customSpawnHeight = -1.0 end
    imgui.same_line()
    if imgui.button("0.0m (Nivel)##sp_z_0") then customSpawnHeight = 0.0 end
    imgui.same_line()
    if imgui.button("+2.0m##sp_z_2") then customSpawnHeight = 2.0 end
    imgui.same_line()
    if imgui.button("+5.0m##sp_z_5") then customSpawnHeight = 5.0 end
    imgui.same_line()
    if imgui.button("+15.0m##sp_z_15") then customSpawnHeight = 15.0 end

    imgui.text("Rotacao Yaw: " .. string.format("%.0f°", customSpawnYaw))
    imgui.same_line()
    if imgui.button("0° (Frente)##sp_y0") then customSpawnYaw = 0.0 end
    imgui.same_line()
    if imgui.button("45°##sp_y45") then customSpawnYaw = 45.0 end
    imgui.same_line()
    if imgui.button("90° (Lateral)##sp_y90") then customSpawnYaw = 90.0 end
    imgui.same_line()
    if imgui.button("180° (Costas)##sp_y180") then customSpawnYaw = 180.0 end

    local cFrz, vFrz = imgui.checkbox("Congelar Posicao / Fisica (Freeze Position)##sp_frz", customSpawnFreeze)
    if cFrz then customSpawnFreeze = vFrz end

    imgui.spacing()
    imgui.separator()
    imgui.spacing()

    -- Ponto Fixo Customizado (UFO / Disco Voador)
    imgui.text("Ponto Fixo Customizado (OVNI / p_spinning_anus_s):")
    imgui.text("Coords: X = -75.015, Y = -818.215, Z = 326.176")
    
    if imgui.button(">> SPAWNAR OVNI NO PONTO FIXO <<##sp_fixed_ufo") then
        spawnFixedCoordsUfo()
    end
    imgui.same_line()
    if imgui.button("Teleportar ao OVNI##tp_fixed_ufo") then
        script.run_in_callback(function()
            pcall(function()
                local myPed = PLAYER.PLAYER_PED_ID()
                if isValidEntity(myPed) then
                    ENTITY.SET_ENTITY_COORDS(myPed, -75.015, -818.215, 328.0, false, false, false, true)
                end
            end)
        end)
    end
    imgui.same_line()
    if imgui.button("Remover OVNI Fixo##rem_fixed_ufo") then
        removeFixedCoordsUfo()
    end

    imgui.spacing()
    imgui.separator()
    imgui.spacing()

    -- ════════════════════════════════════════════════════════════
    -- PROJETO MAZE BANK (Portais Neon 8X + Núcleo OVNI no Topo)
    -- ════════════════════════════════════════════════════════════
    imgui.text(">>> PROJETO MAZE BANK (4x Portais Neon 8X + Núcleo OVNI) <<<")
    imgui.text("Torre ascendente de 4 Portais Neon gigantes até o topo + Núcleo OVNI (Z = 404m)")

    if imgui.button(">> SPAWNAR PROJETO MAZE BANK <<##sp_mazebank_btn") then
        spawnMazeBankProject()
    end
    imgui.same_line()
    if imgui.button(">> TELEPORTAR TODOS AO TOPO DO MAZE BANK <<##tp_all_to_mazebank_btn") then
        teleportAllPlayersToMazeBank()
    end

    if imgui.button("Remover Projeto Maze Bank##rem_mazebank_btn") then
        clearMazeBankProject()
    end
    imgui.same_line()
    if imgui.button("[TESTE] Spawnar 26_1_p26_01_additions_sm15lod##sp_test_26") then
        spawnTestModel26()
    end

    imgui.spacing()
    imgui.separator()
    imgui.spacing()

    -- 1. Mega Tubos 4X
    imgui.text("1. Mega Tubos Arena War 4X (Gigantes):")
    if imgui.button("Tubo 4X Longo##sp_t4xl") then spawnSinglePropAtPlayer("ar_prop_ar_tube_4x_l") end
    imgui.same_line()
    if imgui.button("Tubo 4X Medio##sp_t4xm") then spawnSinglePropAtPlayer("ar_prop_ar_tube_4x_m") end
    imgui.same_line()
    if imgui.button("Tubo 4X Curto##sp_t4xs") then spawnSinglePropAtPlayer("ar_prop_ar_tube_4x_s") end
    imgui.same_line()
    if imgui.button("Tubo 4X Speed##sp_t4xsp") then spawnSinglePropAtPlayer("ar_prop_ar_tube_4x_speed") end
    
    if imgui.button("Tubo 4X Curva 90°##sp_t4xcrn") then spawnSinglePropAtPlayer("ar_prop_ar_tube_4x_crn") end
    imgui.same_line()
    if imgui.button("Tubo 4X Curva 30°##sp_t4xcrn30") then spawnSinglePropAtPlayer("ar_prop_ar_tube_4x_crn_30d") end
    imgui.same_line()
    if imgui.button("Tubo 4X Gap Aberto##sp_t4xgap") then spawnSinglePropAtPlayer("ar_prop_ar_tube_4x_gap_02") end

    imgui.spacing()

    -- 2. Tubos 2X & Especiais
    imgui.text("2. Tubos Arena War 2X & Especiais:")
    if imgui.button("Tubo 2X Longo##sp_t2xl") then spawnSinglePropAtPlayer("ar_prop_ar_tube_2x_l") end
    imgui.same_line()
    if imgui.button("Tubo 2X Speed##sp_t2xsp") then spawnSinglePropAtPlayer("ar_prop_ar_tube_2x_speed") end
    imgui.same_line()
    if imgui.button("Tubo 2X Curva 90°##sp_t2xcrn") then spawnSinglePropAtPlayer("ar_prop_ar_tube_2x_crn") end
    imgui.same_line()
    if imgui.button("Tubo Cruzamento (+)##sp_tcross") then spawnSinglePropAtPlayer("ar_prop_ar_tube_cross") end

    if imgui.button("Tubo Bifurcacao (Y)##sp_tfork") then spawnSinglePropAtPlayer("ar_prop_ar_tube_fork") end
    imgui.same_line()
    if imgui.button("Tubo Rampa Salto##sp_tjmp") then spawnSinglePropAtPlayer("ar_prop_ar_tube_jmp") end
    imgui.same_line()
    if imgui.button("Tubo Standard Longo##sp_tstdl") then spawnSinglePropAtPlayer("ar_prop_ar_tube_l") end
    imgui.same_line()
    if imgui.button("Tubo Standard Speed##sp_tstdsp") then spawnSinglePropAtPlayer("ar_prop_ar_tube_speed") end

    imgui.spacing()

    -- 3. Portais & Gates de Neon
    imgui.text("3. Portais Luminosos & Gates de Neon:")
    if imgui.button("Portal Neon 8X (1)##sp_ng8_1") then spawnSinglePropAtPlayer("ar_prop_ar_neon_gate8x_01a") end
    imgui.same_line()
    if imgui.button("Portal Neon 8X (2)##sp_ng8_2") then spawnSinglePropAtPlayer("ar_prop_ar_neon_gate8x_02a") end
    imgui.same_line()
    if imgui.button("Portal Neon 8X (3)##sp_ng8_3") then spawnSinglePropAtPlayer("ar_prop_ar_neon_gate8x_03a") end
    imgui.same_line()
    if imgui.button("Portal Neon 4X (1)##sp_ng4_1") then spawnSinglePropAtPlayer("ar_prop_ar_neon_gate4x_01a") end

    if imgui.button("Portal Neon 4X (2)##sp_ng4_2") then spawnSinglePropAtPlayer("ar_prop_ar_neon_gate4x_02a") end
    imgui.same_line()
    if imgui.button("Portal Neon Std (1)##sp_ng1_1") then spawnSinglePropAtPlayer("ar_prop_ar_neon_gate_01a") end
    imgui.same_line()
    if imgui.button("Portal Neon Std (2)##sp_ng1_2") then spawnSinglePropAtPlayer("ar_prop_ar_neon_gate_02a") end

    imgui.spacing()

    -- 4. Aneis, Loops & Checkpoints
    imgui.text("4. Aneis de Velocidade, Loops & Checkpoints:")
    if imgui.button("Anel Speed Ring (Impulso)##sp_ring") then spawnSinglePropAtPlayer("ar_prop_ar_speed_ring") end
    imgui.same_line()
    if imgui.button("Mega Loop Acrobatico##sp_loop") then spawnSinglePropAtPlayer("ar_prop_ar_jump_loop") end
    imgui.same_line()
    if imgui.button("Aro / Hoop Medio##sp_hoop") then spawnSinglePropAtPlayer("ar_prop_ar_hoop_med_01") end
    imgui.same_line()
    if imgui.button("Portico Start (Largada)##sp_start") then spawnSinglePropAtPlayer("ar_prop_ar_start_01a") end

    if imgui.button("Mega Torre 8X Checkpoint##sp_tow8") then spawnSinglePropAtPlayer("ar_prop_ar_cp_tower8x_01a") end
    imgui.same_line()
    if imgui.button("Torre 4X Checkpoint##sp_tow4") then spawnSinglePropAtPlayer("ar_prop_ar_cp_tower4x_01a") end
    imgui.same_line()
    if imgui.button("Checkpoint Grande L##sp_cpl") then spawnSinglePropAtPlayer("ar_prop_ar_checkpoint_l") end

    imgui.spacing()

    -- 5. Setas, Sinais & Rampas
    imgui.text("5. Setas de Neon, Sinais & Rampas:")
    if imgui.button("Seta Neon Larga XL##sp_ar_wxl") then spawnSinglePropAtPlayer("ar_prop_ar_arrow_wide_xl") end
    imgui.same_line()
    if imgui.button("Seta Neon Fina XL##sp_ar_txl") then spawnSinglePropAtPlayer("ar_prop_ar_arrow_thin_xl") end
    imgui.same_line()
    if imgui.button("Placa Neon Ammu-Nation##sp_ammu") then spawnSinglePropAtPlayer("ar_prop_ar_ammu_sign") end
    imgui.same_line()
    if imgui.button("Rampa Jetski Arena##sp_jetski") then spawnSinglePropAtPlayer("ar_prop_ar_jetski_ramp_01_dev") end

    if imgui.button("Mega Bloco Arena 01##sp_mb1") then spawnSinglePropAtPlayer("ar_prop_ar_bblock_huge_01") end
    imgui.same_line()
    if imgui.button("Mega Bloco Arena 02##sp_mb2") then spawnSinglePropAtPlayer("ar_prop_ar_bblock_huge_02") end
    imgui.same_line()
    if imgui.button("Bloco Stunt Arena##sp_stb1") then spawnSinglePropAtPlayer("ar_prop_ar_stunt_block_01a") end

    imgui.spacing()

    -- 6. Iate & Portas Especiais
    imgui.text("6. Props de Iate & Portas de Heist:")
    if imgui.button("Boia Flutuante Iate 1A##sp_yf1a") then spawnSinglePropAtPlayer("apa_prop_yacht_float_1a") end
    imgui.same_line()
    if imgui.button("Boia Flutuante Iate 1B##sp_yf1b") then spawnSinglePropAtPlayer("apa_prop_yacht_float_1b") end
    imgui.same_line()
    if imgui.button("Vidro do Iate 01##sp_yglass1") then spawnSinglePropAtPlayer("apa_prop_yacht_glass_01") end
    
    if imgui.button("Porta Cofre Heist 1##sp_hdoor1") then spawnSinglePropAtPlayer("apa_v_ilev_fh_heistdoor1") end
    imgui.same_line()
    if imgui.button("Porta Cofre Heist 2##sp_hdoor2") then spawnSinglePropAtPlayer("apa_v_ilev_fh_heistdoor2") end
    imgui.same_line()
    if imgui.button("Porta Submarino 2##sp_subdoor2") then spawnSinglePropAtPlayer("apa_v_ilev_ss_door2") end

    imgui.spacing()
    imgui.separator()
    imgui.spacing()

    if imgui.button("Desfazer Ultimo Objeto##undo_obj_spawner") then
        undoLastStuntObject()
    end
    imgui.same_line()
    if imgui.button("Limpar Todos os Objetos Criados##clear_all_obj_spawner") then
        clearAllStuntObjects()
    end

    imgui.end_tab_item()
end

local function renderTabPlayerAttachments()
    if not imgui.begin_tab_item("Player Attachments") then return end
    imgui.spacing()
    imgui.text("Anexar Objetos, Adereços e Armadilhas nos Jogadores")
    imgui.separator()
    imgui.spacing()

    local localPid = get_local_pid()
    local activePlayers = get_active_session_players()
    local currentTargetName = (selectedAttachmentPid == -1 or selectedAttachmentPid == localPid) and "VOCE MESMO" or get_player_name(selectedAttachmentPid)

    -- ════════════════════════════════════════════════════════════
    -- 1. DESTINO: INDIVIDUAL OU COLETIVO
    -- ════════════════════════════════════════════════════════════
    imgui.text("1. Escolha Quem Vai Receber o Objeto:")

    local isPresetAll = attachPresetModeAll or false
    if imgui.button((not isPresetAll and "[X] Individual (Jogador Especifico)" or "[  ] Individual (Jogador Especifico)") .. "##mode_indiv") then
        attachPresetModeAll = false
    end
    imgui.same_line()
    if imgui.button((isPresetAll and "[X] Coletivo (TODOS da Sessao)" or "[  ] Coletivo (TODOS da Sessao)") .. "##mode_all") then
        attachPresetModeAll = true
    end

    if not attachPresetModeAll then
        imgui.spacing()
        imgui.text("Alvo Individual Selecionado: ")
        imgui.same_line()
        if imgui.text_colored then
            pcall(imgui.text_colored, 0.3, 0.8, 1.0, 1.0, currentTargetName .. " (PID: " .. tostring(selectedAttachmentPid) .. ")")
        else
            imgui.text(currentTargetName .. " (PID: " .. tostring(selectedAttachmentPid) .. ")")
        end

        -- Botão para Você Mesmo
        local isSelf = (selectedAttachmentPid == -1 or selectedAttachmentPid == localPid)
        if imgui.button((isSelf and "[X] VOCE MESMO (Local)" or "[  ] VOCE MESMO (Local)") .. "##sel_self_att") then
            selectedAttachmentPid = -1
        end

        -- Lista de Players da Sessão em 2 colunas
        local pCount = 0
        for _, pid in ipairs(activePlayers) do
            if pid ~= localPid then
                if pCount % 2 ~= 0 then
                    imgui.same_line()
                end
                pCount = pCount + 1
                local isSel = (selectedAttachmentPid == pid)
                local pName = get_player_name(pid)
                local prefix = isSel and "[X] " or "[  ] "
                local label = string.format("%s[%02d] %s##sel_p_%d", prefix, pid, pName, pid)
                if imgui.button(label) then
                    selectedAttachmentPid = pid
                end
            end
        end
    else
        imgui.spacing()
        if imgui.text_colored then
            pcall(imgui.text_colored, 1.0, 0.8, 0.2, 1.0, ">> MODO COLETIVO ATIVO: Os objetos serao aplicados em TODOS os jogadores da sessao! <<")
        else
            imgui.text(">> MODO COLETIVO ATIVO: Os objetos serao aplicados em TODOS os jogadores da sessao! <<")
        end
    end

    imgui.spacing()
    imgui.separator()
    imgui.spacing()

    -- ════════════════════════════════════════════════════════════
    -- 2. ESCOLHA DO OBJETO PRÉ-DEFINIDO (1 CLIQUE)
    -- ════════════════════════════════════════════════════════════
    imgui.text("2. Escolha Qual Objeto Anexar (Posicionamento Automatico):")

    local function applyProp(modelOrHash, boneId, offX, offY, offZ, rotX, rotY, rotZ)
        if attachPresetModeAll then
            local pids = get_active_session_players()
            for _, pid in ipairs(pids) do
                attachPropToPlayer(pid, modelOrHash, boneId, offX, offY, offZ, rotX, rotY, rotZ)
            end
            notify.success("MAC_Fun_Script", string.format("Objeto [%s] anexado em TODOS os jogadores!", tostring(modelOrHash)))
        else
            attachPropToPlayer(selectedAttachmentPid, modelOrHash, boneId, offX, offY, offZ, rotX, rotY, rotZ)
        end
    end

    -- Armadilhas & Especiais
    if imgui.button("Jaula de Macaco (v_med_apecrate)##att_apecrate_btn") then
        if attachPresetModeAll then
            local pids = get_active_session_players()
            for _, pid in ipairs(pids) do spawnApeCrateCageOnPlayer(pid) end
            notify.success("MAC_Fun_Script", "Jaula aplicada em TODOS os jogadores!")
        else
            spawnApeCrateCageOnPlayer(selectedAttachmentPid)
        end
    end
    imgui.same_line()
    if imgui.button("Cone na Cabeca##att_cone") then
        applyProp("prop_mp_cone_01", 24818, 0.0, 0.0, 0.70, 0.0, 90.0, 0.0)
    end
    imgui.same_line()
    if imgui.button("Vaso Sanitario (Privada)##att_toilet") then
        applyProp("prop_ld_toilet_01", 11816, 0.0, 0.0, -0.25, 0.0, 90.0, 0.0)
    end

    if imgui.button("Gaiola de Prisao##att_cage") then
        applyProp("prop_feeder1_cr", 11816, 0.0, 0.0, -0.6, 0.0, 90.0, 0.0)
    end
    imgui.same_line()
    if imgui.button("Fogueira Ardente no Corpo##att_fire") then
        applyProp("prop_beach_fire", 11816, 0.0, 0.0, -0.3, 0.0, 90.0, 0.0)
    end
    imgui.same_line()
    if imgui.button("Arvore de Natal##att_xmas") then
        applyProp("prop_mp_xmas_tree_01", 11816, 0.0, 0.0, -0.5, 0.0, 90.0, 0.0)
    end

    if imgui.button("Ovo Alienigena na Cabeca##att_alien") then
        applyProp("prop_alien_egg_01", 24818, 0.0, 0.0, 0.75, 0.0, 90.0, 0.0)
    end
    imgui.same_line()
    if imgui.button("Mochila de Dinheiro (Heist)##att_bag") then
        applyProp("p_ld_heist_bag_s_pro_o", 24818, 0.0, -0.2, 0.0, 0.0, 90.0, 0.0)
    end
    imgui.same_line()
    if imgui.button("Guitarra nas Costas##att_guitar") then
        applyProp("prop_acc_guitar_01", 24818, 0.0, -0.15, 0.0, 0.0, 90.0, 180.0)
    end

    if imgui.button("Roda do Cassino (Lucky Wheel)##att_cwheel") then
        applyProp(0x8EB05D67, 24818, -0.808, -0.255, -0.120, 0.0, 270.0, 180.0)
    end
    imgui.same_line()
    if imgui.button("4x Rodas Shield 360°##att_4cwheels") then
        local angles = { 0.0, 90.0, 180.0, 270.0 }
        for _, ang in ipairs(angles) do
            applyProp(0x8EB05D67, 24818, -0.808, -0.255, -0.120, 0.0, ang, 180.0)
        end
    end
    imgui.same_line()
    if imgui.button("Roda Gigante Troll##att_wheel") then
        applyProp("prop_ld_ferris_wheel", 11816, 0.0, 0.0, -1.0, 0.0, 90.0, 0.0)
    end

    if imgui.button("Moinho Eolico Gigante##att_windmill") then
        applyProp("prop_windmill_01", 24818, 0.0, 0.0, 0.70, 0.0, 90.0, 0.0)
    end
    imgui.same_line()
    if imgui.button("Disco Voador (OVNI / UFO)##att_ufo") then
        applyProp("p_spinning_anus_s", 11816, 0.0, 0.0, 1.5, 0.0, 90.0, 0.0)
    end
    imgui.same_line()
    if imgui.button("Boia de Praia (Pelvis)##att_ring") then
        applyProp("prop_beach_ring_01", 11816, 0.0, 0.0, 0.0, 0.0, 90.0, 0.0)
    end

    if imgui.button("Anel Speed Ring Neon##att_sring") then
        applyProp("ar_prop_ar_speed_ring", 11816, 0.0, 0.0, 0.0, 0.0, 90.0, 0.0)
    end
    imgui.same_line()
    if imgui.button("Asas Neon Gate 8X##att_wings") then
        applyProp("ar_prop_ar_neon_gate8x_01a", 24818, 0.0, -0.35, 0.4, 0.0, 90.0, 180.0)
    end
    imgui.same_line()
    if imgui.button("Boia de Luxo Iate##att_yacht_float") then
        applyProp("apa_prop_yacht_float_1a", 11816, 0.0, 0.0, 0.0, 0.0, 90.0, 0.0)
    end

    if imgui.button("Escudo Porta Cofre Heist##att_vaultdoor") then
        applyProp("apa_v_ilev_fh_heistdoor1", 24818, 0.0, -0.25, 0.0, 0.0, 90.0, 180.0)
    end
    imgui.same_line()
    if imgui.button("Placa Ammu-Nation Neon##att_ammu_sign") then
        applyProp("ar_prop_ar_ammu_sign", 24818, 0.0, -0.2, 0.3, 0.0, 90.0, 180.0)
    end

    imgui.spacing()
    imgui.separator()
    imgui.spacing()

    -- Campo para Objeto Personalizado
    imgui.text("Outro Objeto Personalizado:")
    local cModel, vModel = imgui.input_text("Nome do Modelo##cust_att_model", customAttachModelInput or "prop_mp_cone_01")
    if cModel then customAttachModelInput = vModel end
    imgui.same_line()
    if imgui.button("Anexar Objeto Digitado##att_custom_btn") then
        applyProp(customAttachModelInput or "prop_mp_cone_01", 24818, 0.0, 0.0, 0.0, 0.0, 90.0, 0.0)
    end

    imgui.spacing()
    imgui.separator()
    imgui.spacing()

    -- ════════════════════════════════════════════════════════════
    -- 3. REMOÇÃO E LIMPEZA
    -- ════════════════════════════════════════════════════════════
    imgui.text("3. Gerenciamento e Limpeza:")

    if not attachPresetModeAll then
        local targetActualPid = (selectedAttachmentPid == -1) and localPid or selectedAttachmentPid
        local currentList = attached_player_props[targetActualPid] or {}
        imgui.text(string.format("Objetos Ativos em %s: %d", currentTargetName, #currentList))
        if imgui.button("Remover Objetos de " .. currentTargetName .. "##rem_sel_props") then
            removePlayerAttachedProps(selectedAttachmentPid)
        end
        imgui.same_line()
    end

    if imgui.button("Remover de TODOS os Jogadores da Sessao (Limpar Tudo)##rem_all_props") then
        removeAllAttachedProps()
    end

    imgui.end_tab_item()
end

local function renderTabAngelFloatie()
    if not imgui.begin_tab_item("Angel Self Floatie") then return end
    imgui.spacing()
    imgui.text("Self Floatie - Boia de Cintura Sincronizada em Rede")
    imgui.separator()
    imgui.spacing()

    imgui.text("Boia anexada à cintura do jogador com replicação de rede total e persistência pós-respawn.")
    imgui.spacing()

    local buttonText = (angelFloatieActive and isValidEntity(angelFloatieObject)) and "Remover Boia (Angel Floatie)##rem_angel_fl" or "Anexar Boia (Angel Floatie)##att_angel_fl"
    if imgui.button(buttonText) then
        script.run_in_callback(function()
            toggleAngelFloatie()
        end)
    end

    imgui.spacing()
    if angelFloatieActive and isValidEntity(angelFloatieObject) then
        imgui.text("Status: ANEXADO (REDE SINCRONIZADA)")
    else
        imgui.text("Status: DESLIGADO (OFF)")
    end

    imgui.spacing()
    imgui.separator()
    imgui.spacing()

    imgui.text("Modelo: prop_beach_ring_01")
    imgui.text("Osso: SKEL_Pelvis (0x2E28 / 11816)")
    imgui.text("Sincronizacao: Todos os jogadores da sessao conseguem ver")

    imgui.end_tab_item()
end

local customCutsceneName = "MP_INTRO_LAMAR_DRIVE_SCENE"
local selectedCutscenePid = -1

local function playOnlineCutscene(cutsceneName, targetPid)
    script.run_in_callback(function()
        pcall(function()
            if not cutsceneName or cutsceneName == "" then
                notify.warn("MAC_Fun_Script", "Nome da cutscene inválido.")
                return
            end

            local myLocalPid = get_local_pid()
            local actualPid = (targetPid == nil or targetPid == -1) and myLocalPid or targetPid
            local isLocal = (actualPid == myLocalPid)
            local pName = isLocal and "Você" or get_player_name(actualPid)

            notify.info("MAC_Fun_Script", string.format("Carregando cutscene [%s] para %s...", cutsceneName, pName))

            -- 1. Se for jogador remoto, tenta disparar Script Events e registrar o Ped do alvo
            if not isLocal then
                local targetPed = getPlayerPedSafe(actualPid)
                if isValidEntity(targetPed) then
                    pcall(function()
                        -- Posiciona a cutscene no local do jogador alvo se aplicável
                        local tc = ENTITY.GET_ENTITY_COORDS(targetPed, true)
                        if tc and CUTSCENE and CUTSCENE.SET_CUTSCENE_ORIGIN then
                            CUTSCENE.SET_CUTSCENE_ORIGIN(tc.x, tc.y, tc.z, 0.0, 0)
                        end
                    end)
                end

                -- Tenta enviar Network Script Events conhecidos de Cutscene / Tutorial se a API suportar
                pcall(function()
                    if NETWORK and NETWORK.TRIGGER_SCRIPT_EVENT then
                        local playerBit = math.floor(2 ^ actualPid)
                        NETWORK.TRIGGER_SCRIPT_EVENT(1, { 0x3AC33CE8, myLocalPid, actualPid }, 3, playerBit)
                    end
                end)
            end

            -- 2. Carregamento e Execução da Cutscene
            if CUTSCENE and CUTSCENE.REQUEST_CUTSCENE then
                CUTSCENE.REQUEST_CUTSCENE(cutsceneName, 8)
            end

            local timeout = 0
            while CUTSCENE and not CUTSCENE.HAS_CUTSCENE_LOADED() and timeout < 300 do
                script.yield(10)
                timeout = timeout + 1
            end

            if CUTSCENE and not CUTSCENE.HAS_CUTSCENE_LOADED() then
                notify.error("MAC_Fun_Script", "A cutscene não carregou: " .. cutsceneName)
                return
            end

            -- Se alvo for remoto e existir ped, registra o ped na cutscene
            if not isLocal then
                local targetPed = getPlayerPedSafe(actualPid)
                if isValidEntity(targetPed) and CUTSCENE and CUTSCENE.REGISTER_ENTITY_FOR_CUTSCENE then
                    pcall(function()
                        CUTSCENE.REGISTER_ENTITY_FOR_CUTSCENE(targetPed, "MP_1", 0, 0, 64)
                    end)
                end
            end

            notify.success("MAC_Fun_Script", string.format("Cutscene [%s] iniciada para %s!", cutsceneName, pName))

            if CUTSCENE and CUTSCENE.START_CUTSCENE then
                CUTSCENE.START_CUTSCENE(0)
            end

            while CUTSCENE and CUTSCENE.IS_CUTSCENE_PLAYING and CUTSCENE.IS_CUTSCENE_PLAYING() do
                script.yield(0)
            end

            pcall(function()
                if CUTSCENE and CUTSCENE.REMOVE_CUTSCENE then
                    CUTSCENE.REMOVE_CUTSCENE()
                end
            end)

            notify.info("MAC_Fun_Script", string.format("Cutscene finalizada para %s.", pName))
        end)
    end)
end

local function stopCurrentCutscene()
    script.run_in_callback(function()
        pcall(function()
            if CUTSCENE then
                if CUTSCENE.STOP_CUTSCENE_IMMEDIATELY then
                    CUTSCENE.STOP_CUTSCENE_IMMEDIATELY()
                elseif CUTSCENE.STOP_CUTSCENE then
                    CUTSCENE.STOP_CUTSCENE(true)
                end
                if CUTSCENE.REMOVE_CUTSCENE then
                    CUTSCENE.REMOVE_CUTSCENE()
                end
            end
            notify.info("MAC_Fun_Script", "Cutscene interrompida.")
        end)
    end)
end

local function renderTabCutscenes()
    if not imgui.begin_tab_item("Cutscenes") then return end
    imgui.spacing()
    imgui.text("Reproduzir Cutscenes Online no Jogador Selecionado")
    imgui.separator()
    imgui.spacing()

    local localPid = get_local_pid()
    local activePlayers = get_active_session_players()
    local currentTargetName = (selectedCutscenePid == -1 or selectedCutscenePid == localPid) and "VOCE MESMO" or get_player_name(selectedCutscenePid)

    imgui.text("Alvo da Cutscene: ")
    imgui.same_line()
    if imgui.text_colored then
        pcall(imgui.text_colored, 0.3, 0.8, 1.0, 1.0, currentTargetName .. " (PID: " .. tostring(selectedCutscenePid) .. ")")
    else
        imgui.text(currentTargetName .. " (PID: " .. tostring(selectedCutscenePid) .. ")")
    end

    imgui.spacing()
    imgui.text("Selecione o Jogador Alvo:")

    -- Botão para Você Mesmo
    local isSelf = (selectedCutscenePid == -1 or selectedCutscenePid == localPid)
    if imgui.button((isSelf and "[X] VOCE MESMO (Local)" or "[  ] VOCE MESMO (Local)") .. "##sel_self_cs") then
        selectedCutscenePid = -1
    end

    -- Lista de Players da Sessão em 2 colunas organizadas
    local pCount = 0
    for _, pid in ipairs(activePlayers) do
        if pid ~= localPid then
            if pCount % 2 ~= 0 then
                imgui.same_line()
            end
            pCount = pCount + 1
            local isSel = (selectedCutscenePid == pid)
            local pName = get_player_name(pid)
            local prefix = isSel and "[X] " or "[  ] "
            local label = string.format("%s[%02d] %s##sel_p_cs_%d", prefix, pid, pName, pid)
            if imgui.button(label) then
                selectedCutscenePid = pid
            end
        end
    end

    imgui.spacing()
    imgui.separator()
    imgui.spacing()

    if imgui.button(">> PARAR CUTSCENE ATUAL <<##stop_cutscene_btn") then
        stopCurrentCutscene()
    end

    imgui.spacing()
    imgui.separator()
    imgui.spacing()

    imgui.text("Cutscenes Populares do GTA Online:")
    imgui.spacing()

    if imgui.button("Lamar Drive Scene (Intro GTA Online)##cs_lamar") then
        playOnlineCutscene("MP_INTRO_LAMAR_DRIVE_SCENE", selectedCutscenePid)
    end
    imgui.same_line()
    if imgui.button("Lamar Airport Arrival##cs_lamar_air") then
        playOnlineCutscene("mp_intro_mcs_1_a1", selectedCutscenePid)
    end

    if imgui.button("Casino Intro Scene##cs_cas_intro") then
        playOnlineCutscene("cas_intro", selectedCutscenePid)
    end
    imgui.same_line()
    if imgui.button("Casino Penthouse Party##cs_cas_pent") then
        playOnlineCutscene("hs3_intro_p1", selectedCutscenePid)
    end

    if imgui.button("Cayo Perico Beach Party Intro##cs_cayo_beach") then
        playOnlineCutscene("h4_intro_beach_party", selectedCutscenePid)
    end
    imgui.same_line()
    if imgui.button("Dr. Dre Studio Session##cs_drdre") then
        playOnlineCutscene("fix_studio_int", selectedCutscenePid)
    end

    if imgui.button("Apartment Heist Planning Board Intro##cs_apt_heist") then
        playOnlineCutscene("apa_heist_int", selectedCutscenePid)
    end
    imgui.same_line()
    if imgui.button("Doomsday Heist Finale Intro##cs_doomsday") then
        playOnlineCutscene("xm_int_outro", selectedCutscenePid)
    end

    if imgui.button("Lowriders Benny Intro##cs_benny") then
        playOnlineCutscene("lr_intro_mcs_1", selectedCutscenePid)
    end
    imgui.same_line()
    if imgui.button("Nightclub VIP Intro##cs_nc_intro") then
        playOnlineCutscene("ba_intro_mcs_1", selectedCutscenePid)
    end

    imgui.spacing()
    imgui.separator()
    imgui.spacing()

    imgui.text("Executar Cutscene Customizada no Alvo:")
    local changed, newText = imgui.input_text("Nome da Cutscene##custom_cs_name", customCutsceneName)
    if changed then
        customCutsceneName = newText
    end

    imgui.same_line()
    if imgui.button("Executar Cutscene##play_custom_cs") then
        playOnlineCutscene(customCutsceneName, selectedCutscenePid)
    end

    imgui.spacing()
    imgui.separator()
    imgui.spacing()

    if imgui.button(">> ENVIAR TODOS OS JOGADORES DA SESSAO PARA CUTSCENE DO LAMAR <<##cs_all_lamar") then
        local pids = get_active_session_players()
        for _, pid in ipairs(pids) do
            playOnlineCutscene("MP_INTRO_LAMAR_DRIVE_SCENE", pid)
        end
        notify.success("MAC_Fun_Script", "Cutscene enviada para todos os jogadores!")
    end

    imgui.end_tab_item()
end

-- ════════════════════════════════════════════════════════════════════
-- CAÇAS INIMIGOS AÉREOS (SPAWN NO CÉU -> PILOTOS INIMIGOS -> COMBATE CONTÍNUO)
-- ════════════════════════════════════════════════════════════════════

local function spawnEnemyJets(targetPid, count)
    script.run_in_callback(function()
        pcall(function()
            local myLocalPid = get_local_pid()
            local actualPid = (targetPid == nil or targetPid == -1) and myLocalPid or targetPid
            local targetPed = getPlayerPedSafe(actualPid)
            local targetCoords = getTargetCoordsSafe(actualPid, targetPed)
            local targetName = (actualPid == myLocalPid) and "Você Mesmo" or get_player_name(actualPid)
            local jetCount = count or kamikazeJetCount or 3

            local jetHash = getModelHash("lazer")
            local pilotHash = getModelHash("s_m_y_blackops_01")

            pcall(function()
                STREAMING.REQUEST_MODEL(jetHash)
                STREAMING.REQUEST_MODEL(pilotHash)
            end)

            local timeout = 0
            while (not STREAMING.HAS_MODEL_LOADED(jetHash) or not STREAMING.HAS_MODEL_LOADED(pilotHash)) and timeout < 80 do
                script.yield(10)
                timeout = timeout + 1
            end

            if not STREAMING.HAS_MODEL_LOADED(jetHash) or not STREAMING.HAS_MODEL_LOADED(pilotHash) then
                notify.error("MAC_Fun_Script", "Falha ao carregar modelos dos caças.")
                return
            end

            notify.warn("MAC_Fun_Script", string.format("Spawando %d caças inimigos no céu atacando %s!", jetCount, targetName))

            for i = 1, jetCount do
                local angle = ((i - 1) / jetCount) * (math.pi * 2) + (math.random() * 0.4)
                local dist = 120.0 + (i * 30.0)
                local sx = targetCoords.x + math.cos(angle) * dist
                local sy = targetCoords.y + math.sin(angle) * dist
                local sz = targetCoords.z + 280.0 + (i * 20.0)
                local heading = math.deg(math.atan2(-(targetCoords.x - sx), targetCoords.y - sy))

                local jet = nil
                pcall(function()
                    jet = VEHICLE.CREATE_VEHICLE(jetHash, sx, sy, sz, heading, true, false, false)
                end)

                if isValidEntity(jet) then
                    local pilot = nil
                    local blip = nil

                    pcall(function()
                        ENTITY.SET_ENTITY_AS_MISSION_ENTITY(jet, true, true)
                        ENTITY.SET_ENTITY_COLLISION(jet, true, true)
                        VEHICLE.SET_VEHICLE_ENGINE_ON(jet, true, true, false)
                        VEHICLE.SET_VEHICLE_FORWARD_SPEED(jet, 85.0)
                        if VEHICLE.CONTROL_LANDING_GEAR then
                            VEHICLE.CONTROL_LANDING_GEAR(jet, 3) -- Recolhe trem de pouso
                        end
                        if VEHICLE.SET_HELI_BLADES_FULL_SPEED then
                            VEHICLE.SET_HELI_BLADES_FULL_SPEED(jet)
                        end
                        
                        -- Cria o piloto militar dentro do caça
                        pilot = PED.CREATE_PED_INSIDE_VEHICLE(jet, 26, pilotHash, -1, true, false)

                        -- Cria Blip Inimigo Vermelho no Mapa
                        if HUD and HUD.ADD_BLIP_FOR_ENTITY then
                            blip = HUD.ADD_BLIP_FOR_ENTITY(jet)
                            if HUD.SET_BLIP_SPRITE then
                                HUD.SET_BLIP_SPRITE(blip, 16) -- Ícone de Caça / Avião
                            end
                            if HUD.SET_BLIP_COLOUR then
                                HUD.SET_BLIP_COLOUR(blip, 1) -- Vermelho Inimigo
                            end
                            if HUD.SET_BLIP_SCALE then
                                HUD.SET_BLIP_SCALE(blip, 1.0)
                            end
                            if HUD.SET_BLIP_AS_SHORT_RANGE then
                                HUD.SET_BLIP_AS_SHORT_RANGE(blip, false)
                            end
                            if HUD.BEGIN_TEXT_COMMAND_SET_BLIP_NAME then
                                HUD.BEGIN_TEXT_COMMAND_SET_BLIP_NAME("STRING")
                                HUD.ADD_TEXT_COMPONENT_SUBSTRING_PLAYER_NAME("Caça Inimigo")
                                HUD.END_TEXT_COMMAND_SET_BLIP_NAME(blip)
                            end
                        end
                    end)

                    if isValidEntity(pilot) then
                        pcall(function()
                            ENTITY.SET_ENTITY_AS_MISSION_ENTITY(pilot, true, true)
                            PED.SET_PED_INTO_VEHICLE(pilot, jet, -1)
                            PED.SET_BLOCKING_OF_NON_TEMPORARY_EVENTS(pilot, true)
                            PED.SET_PED_KEEP_TASK(pilot, true)
                            
                            -- Configura o piloto como inimigo hostil do player
                            local enemyGroup = getModelHash("HATES_PLAYER")
                            local playerGroup = PED.GET_PED_RELATIONSHIP_GROUP_HASH(targetPed)
                            PED.SET_PED_RELATIONSHIP_GROUP_HASH(pilot, enemyGroup)
                            PED.SET_RELATIONSHIP_BETWEEN_GROUPS(5, enemyGroup, playerGroup)
                            PED.SET_RELATIONSHIP_BETWEEN_GROUPS(5, playerGroup, enemyGroup)
                            
                            -- Atributos de combate agressivo e uso total de armas do caça
                            PED.SET_PED_COMBAT_ATTRIBUTES(pilot, 1, true)  -- Can use vehicles
                            PED.SET_PED_COMBAT_ATTRIBUTES(pilot, 2, true)  -- Can do drivebys / vehicle weapons
                            PED.SET_PED_COMBAT_ATTRIBUTES(pilot, 3, false) -- Don't leave vehicle
                            PED.SET_PED_COMBAT_ATTRIBUTES(pilot, 5, true)  -- Always fight
                            PED.SET_PED_COMBAT_ATTRIBUTES(pilot, 13, true) -- Aggressive
                            PED.SET_PED_COMBAT_ATTRIBUTES(pilot, 27, true) -- Perfect accuracy
                            PED.SET_PED_COMBAT_ATTRIBUTES(pilot, 46, true) -- Always fight armed
                            PED.SET_PED_COMBAT_ATTRIBUTES(pilot, 54, true) -- Always equip best weapon
                            PED.SET_PED_COMBAT_ATTRIBUTES(pilot, 58, true) -- Disable flee
                            PED.SET_PED_COMBAT_ATTRIBUTES(pilot, 86, true) -- Allow dogfighting
                            PED.SET_PED_COMBAT_ABILITY(pilot, 2)          -- Professional
                            PED.SET_PED_COMBAT_MOVEMENT(pilot, 3)         -- Aggressive
                            PED.SET_PED_COMBAT_RANGE(pilot, 2)            -- Far range
                            PED.SET_PED_TARGET_LOSS_RESPONSE(pilot, 1)    -- Never lose target
                            PED.SET_PED_ACCURACY(pilot, 100)
                            PED.SET_PED_SHOOT_RATE(pilot, 1000)
                            
                            TASK.TASK_COMBAT_PED(pilot, targetPed, 0, 16)
                            if TASK.TASK_PLANE_MISSION then
                                TASK.TASK_PLANE_MISSION(pilot, jet, 0, targetPed, 0.0, 0.0, 0.0, 6, 110.0, 0.0, 90.0, 0, 100.0)
                            elseif TASK.TASK_PLANE_CHASE then
                                TASK.TASK_PLANE_CHASE(pilot, targetPed, 0.0, 0.0, 50.0)
                            end
                        end)
                    end

                    -- Loop assíncrono em segundo plano: rajadas ativas de canhão explosivo + perseguição contínua pós-morte
                    script.run_in_callback(function()
                        local lastAssignedPed = targetPed
                        local shootCooldown = 0

                        while isValidEntity(jet) and isValidEntity(pilot) and not PED.IS_PED_INJURED(pilot) do
                            local curPed = getPlayerPedSafe(actualPid)

                            -- Se o player morreu e renasceu (novo ped), reatribui o ataque no novo ped vivo!
                            if isValidEntity(curPed) and curPed ~= lastAssignedPed and not PED.IS_PED_INJURED(curPed) then
                                lastAssignedPed = curPed
                                pcall(function()
                                    local pGroup = PED.GET_PED_RELATIONSHIP_GROUP_HASH(curPed)
                                    local eGroup = getModelHash("HATES_PLAYER")
                                    PED.SET_RELATIONSHIP_BETWEEN_GROUPS(5, eGroup, pGroup)
                                    PED.SET_RELATIONSHIP_BETWEEN_GROUPS(5, pGroup, eGroup)
                                    TASK.TASK_COMBAT_PED(pilot, curPed, 0, 16)
                                    if TASK.TASK_PLANE_MISSION then
                                        TASK.TASK_PLANE_MISSION(pilot, jet, 0, curPed, 0.0, 0.0, 0.0, 6, 110.0, 0.0, 90.0, 0, 100.0)
                                    elseif TASK.TASK_PLANE_CHASE then
                                        TASK.TASK_PLANE_CHASE(pilot, curPed, 0.0, 0.0, 50.0)
                                    end
                                end)
                            end

                            -- Disparo de canhões explosivos de 20mm do caça quando alinhado com o player
                            shootCooldown = shootCooldown + 1
                            if shootCooldown >= 3 and isValidEntity(curPed) then
                                pcall(function()
                                    local jCoords = ENTITY.GET_ENTITY_COORDS(jet, true)
                                    local pCoords = ENTITY.GET_ENTITY_COORDS(curPed, true)
                                    local dx = pCoords.x - jCoords.x
                                    local dy = pCoords.y - jCoords.y
                                    local dz = pCoords.z - jCoords.z
                                    local dist = math.sqrt(dx * dx + dy * dy + dz * dz)

                                    if dist < 480.0 and dist > 12.0 then
                                        local fwd = ENTITY.GET_ENTITY_FORWARD_VECTOR(jet)
                                        local toX, toY, toZ = dx / dist, dy / dist, dz / dist
                                        local dot = fwd.x * toX + fwd.y * toY + fwd.z * toZ

                                        -- Se o bico do caça estiver apontado na direção do player
                                        if dot > 0.65 then
                                            local leftMuzzle = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(jet, -1.8, 4.0, -0.2)
                                            local rightMuzzle = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(jet, 1.8, 4.0, -0.2)
                                            local laserHash = getModelHash("VEHICLE_WEAPON_PLAYER_LAZER")
                                            if laserHash == 0 then laserHash = getModelHash("WEAPON_EXPLOSION") end

                                            MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS(leftMuzzle.x, leftMuzzle.y, leftMuzzle.z, pCoords.x, pCoords.y, pCoords.z + 0.4, 250, true, laserHash, pilot, true, false, 950.0)
                                            MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS(rightMuzzle.x, rightMuzzle.y, rightMuzzle.z, pCoords.x, pCoords.y, pCoords.z + 0.4, 250, true, laserHash, pilot, true, false, 950.0)
                                            shootCooldown = 0
                                        end
                                    end
                                end)
                            end

                            script.yield(40)
                        end

                        -- Remove o blip quando o caça for destruído ou o piloto morrer
                        pcall(function()
                            if blip and HUD and HUD.DOES_BLIP_EXIST and HUD.DOES_BLIP_EXIST(blip) then
                                HUD.REMOVE_BLIP(blip)
                            end
                        end)
                    end)
                end
                script.yield(150)
            end

            STREAMING.SET_MODEL_AS_NO_LONGER_NEEDED(jetHash)
            STREAMING.SET_MODEL_AS_NO_LONGER_NEEDED(pilotHash)
        end)
    end)
end

local function renderTabEnemyJets()
    if not imgui.begin_tab_item("Enemy Jets") then return end
    imgui.spacing()
    imgui.text("Caças Inimigos (Spawn Alto -> Pilotagem IA -> Combate Aéreo Contínuo)")
    imgui.separator()
    imgui.spacing()

    local localPid = get_local_pid()
    local activePlayers = get_active_session_players()
    local currentTargetName = (selectedKamikazePid == -1 or selectedKamikazePid == localPid) and "VOCE MESMO" or get_player_name(selectedKamikazePid)

    imgui.text("Alvo do Ataque: ")
    imgui.same_line()
    if imgui.text_colored then
        pcall(imgui.text_colored, 1.0, 0.3, 0.3, 1.0, currentTargetName .. " (PID: " .. tostring(selectedKamikazePid) .. ")")
    else
        imgui.text(currentTargetName .. " (PID: " .. tostring(selectedKamikazePid) .. ")")
    end

    imgui.spacing()
    imgui.text("Selecione o Jogador Alvo:")

    local isSelf = (selectedKamikazePid == -1 or selectedKamikazePid == localPid)
    if imgui.button((isSelf and "[X] VOCE MESMO (Local)" or "[  ] VOCE MESMO (Local)") .. "##sel_self_enemy_jets") then
        selectedKamikazePid = -1
    end

    local pCount = 0
    for _, pid in ipairs(activePlayers) do
        if pid ~= localPid then
            if pCount % 2 ~= 0 then imgui.same_line() end
            pCount = pCount + 1
            local isSel = (selectedKamikazePid == pid)
            local pName = get_player_name(pid)
            local prefix = isSel and "[X] " or "[  ] "
            local label = string.format("%s[%02d] %s##sel_p_ej_%d", prefix, pid, pName, pid)
            if imgui.button(label) then
                selectedKamikazePid = pid
            end
        end
    end

    imgui.spacing()
    imgui.separator()
    imgui.spacing()

    imgui.text("Quantidade de Caças:")
    imgui.same_line()
    if imgui.button((kamikazeJetCount == 1 and "[1 Caça]" or "1 Caça") .. "##ej_cnt_1") then kamikazeJetCount = 1 end
    imgui.same_line()
    if imgui.button((kamikazeJetCount == 3 and "[3 Caças]" or "3 Caças") .. "##ej_cnt_3") then kamikazeJetCount = 3 end
    imgui.same_line()
    if imgui.button((kamikazeJetCount == 5 and "[5 Caças]" or "5 Caças") .. "##ej_cnt_5") then kamikazeJetCount = 5 end

    imgui.spacing()
    imgui.spacing()

    if imgui.button(">> SPAWNAR CAÇAS INIMIGOS NO CÉU <<##spawn_enemy_jets_btn") then
        spawnEnemyJets(selectedKamikazePid, kamikazeJetCount)
    end

    imgui.end_tab_item()
end

-- ════════════════════════════════════════════════════════════════════
-- SISTEMA DE AIRDROP TÁTICO MILITAR (SUPRIMENTOS / VEÍCULOS / ARMADILHA)
-- ════════════════════════════════════════════════════════════════════

local airdropCrateModels = {
    { name = "Caixa Militar de Madeira", model = "prop_box_wood05a" },
    { name = "Caixa de Munição Pesada", model = "prop_box_ammo04a" },
    { name = "Caixa de Carga Militar", model = "prop_mil_crate_01" },
    { name = "Contêiner Blindado", model = "prop_container_05a" }
}

local airdropVehiclePresets = {
    { label = "Insurgent .50 (Teto)", model = "insurgent3" },
    { label = "Oppressor Mk II", model = "oppressor2" },
    { label = "Vigilante", model = "vigilante" },
    { label = "RC Bandito", model = "rcbandito" },
    { label = "Blazer Aqua", model = "blazer5" },
    { label = "Tanque Khanjali", model = "khanjali" }
}

local function safeCreateAirdropProp(modelNameOrHash, x, y, z, dynamic)
    local hash = getModelHash(modelNameOrHash)
    if hash == 0 then return nil end

    pcall(function() STREAMING.REQUEST_MODEL(hash) end)
    local timeout = 0
    while not STREAMING.HAS_MODEL_LOADED(hash) and timeout < 60 do
        script.yield(10)
        timeout = timeout + 1
    end

    if not STREAMING.HAS_MODEL_LOADED(hash) then
        local fbHash = getModelHash("prop_box_ammo04a")
        pcall(function() STREAMING.REQUEST_MODEL(fbHash) end)
        local t2 = 0
        while not STREAMING.HAS_MODEL_LOADED(fbHash) and t2 < 40 do
            script.yield(10)
            t2 = t2 + 1
        end
        if STREAMING.HAS_MODEL_LOADED(fbHash) then hash = fbHash else return nil end
    end

    local isDyn = (dynamic == true)
    local obj = nil

    if safeCreateStuntProp then
        obj = safeCreateStuntProp(hash, x, y, z, isDyn)
    end

    if not isValidEntity(obj) then
        pcall(function()
            if OBJECT and OBJECT.CREATE_OBJECT_NO_OFFSET then
                obj = OBJECT.CREATE_OBJECT_NO_OFFSET(hash, x, y, z, true, false, isDyn)
            end
        end)
    end

    if not isValidEntity(obj) then
        pcall(function()
            if OBJECT and OBJECT.CREATE_OBJECT then
                obj = OBJECT.CREATE_OBJECT(hash, x, y, z, true, false, isDyn)
            end
        end)
    end

    if not isValidEntity(obj) then
        pcall(function()
            if entities and entities.create_object then
                obj = entities.create_object(hash, { x = x, y = y, z = z })
            end
        end)
    end

    if isValidEntity(obj) then
        pcall(function()
            ENTITY.SET_ENTITY_AS_MISSION_ENTITY(obj, true, true)
            ENTITY.SET_ENTITY_VISIBLE(obj, true, false)
            if ENTITY.SET_ENTITY_LOD_DIST then
                ENTITY.SET_ENTITY_LOD_DIST(obj, 0xFFFF)
            end
        end)
    end

    return obj
end

local function safeDeleteAirdropObject(obj)
    if not obj or obj == 0 then return end
    pcall(function()
        if not isValidEntity(obj) then return end
        ENTITY.SET_ENTITY_AS_MISSION_ENTITY(obj, true, true)
        if OBJECT and OBJECT.DELETE_OBJECT then
            OBJECT.DELETE_OBJECT(obj)
        end
        if ENTITY and ENTITY.SET_ENTITY_COORDS then
            ENTITY.SET_ENTITY_COORDS(obj, 0.0, 0.0, -200.0, false, false, false, false)
        end
        if entities and entities.delete_by_handle then
            entities.delete_by_handle(obj)
        end
    end)
end

local function getAirdropTargetCoords()
    local myLocalPid = get_local_pid()
    local localPed = getPlayerPedSafe(myLocalPid)
    if not isValidEntity(localPed) then
        pcall(function()
            if PLAYER and PLAYER.PLAYER_PED_ID then
                localPed = PLAYER.PLAYER_PED_ID()
            end
        end)
    end

    local localCoords = getTargetCoordsSafe(myLocalPid, localPed)
    if not localCoords or (localCoords.x == 0 and localCoords.y == 0 and localCoords.z == 0) then
        pcall(function()
            if isValidEntity(localPed) then
                localCoords = ENTITY.GET_ENTITY_COORDS(localPed, true)
            end
        end)
    end
    if not localCoords then
        localCoords = { x = 0.0, y = 0.0, z = 72.0 }
    end

    if airdropLocationMode == 1 then -- Você mesmo
        return localCoords, "Você Mesmo"
    elseif airdropLocationMode == 2 then -- Na frente (15m)
        local fwd = { x = 0.0, y = 1.0, z = 0.0 }
        pcall(function()
            if isValidEntity(localPed) then
                fwd = ENTITY.GET_ENTITY_FORWARD_VECTOR(localPed)
            end
        end)
        local tx = localCoords.x + fwd.x * 15.0
        local ty = localCoords.y + fwd.y * 15.0
        local tz = localCoords.z
        pcall(function()
            local ok, groundZ = MISC.GET_GROUND_Z_FOR_3D_COORD(tx, ty, localCoords.z + 50.0, false, false)
            if ok and groundZ ~= 0 then tz = groundZ end
        end)
        return { x = tx, y = ty, z = tz }, "Na Sua Frente (15m)"
    elseif airdropLocationMode == 3 then -- No Waypoint
        local wpBlip = 0
        pcall(function()
            if HUD and HUD.GET_FIRST_BLIP_INFO_ID then
                wpBlip = HUD.GET_FIRST_BLIP_INFO_ID(8)
            end
        end)
        if wpBlip ~= 0 and HUD and HUD.DOES_BLIP_EXIST and HUD.DOES_BLIP_EXIST(wpBlip) then
            local c = HUD.GET_BLIP_INFO_ID_COORD(wpBlip)
            if c then
                local tz = 25.0
                pcall(function()
                    local ok, groundZ = MISC.GET_GROUND_Z_FOR_3D_COORD(c.x, c.y, 800.0, false, false)
                    if ok and groundZ ~= 0 then tz = groundZ end
                end)
                return { x = c.x, y = c.y, z = tz }, "No Waypoint do Mapa"
            end
        end
        notify.warn("MAC_Fun_Script", "Nenhum Waypoint no mapa! Usando sua posição.")
        return localCoords, "Você Mesmo (Sem Waypoint)"
    elseif airdropLocationMode == 4 then -- Jogador da sessão
        local actualPid = (selectedAirdropPid == -1 or selectedAirdropPid == myLocalPid) and myLocalPid or selectedAirdropPid
        local tPed = getPlayerPedSafe(actualPid)
        local tCoords = getTargetCoordsSafe(actualPid, tPed)
        local pName = (actualPid == myLocalPid) and "Você Mesmo" or get_player_name(actualPid)
        return tCoords, pName
    end

    return localCoords, "Você Mesmo"
end

local function callAirdropSupply()
    script.run_in_callback(function()
        local ok, err = pcall(function()
            local targetCoords, targetDesc = getAirdropTargetCoords()
            if not targetCoords then
                notify.error("MAC_Fun_Script", "Falha ao obter coordenadas do Airdrop.")
                return
            end

            -- Caixa compacta militar padrão (sem problemas de colisão)
            local crateModel = "prop_box_ammo04a"

            notify.info("MAC_Fun_Script", "Airdrop lançado em " .. targetDesc .. "! Carga a caminho...")

            -- 1. BIP SONORO TÁTICO (8 bips acelerando o ritmo antes do impacto)
            local beepDelays = { 380, 320, 260, 210, 160, 120, 90, 70 }
            for _, delay in ipairs(beepDelays) do
                pcall(function()
                    if AUDIO and AUDIO.PLAY_SOUND_FRONTEND then
                        AUDIO.PLAY_SOUND_FRONTEND(-1, "Beep_Red", "DLC_HEIST_HACKING_SNAKE_SOUNDS", true)
                    end
                end)
                script.yield(delay)
            end

            -- 2. SPAWN DA CAIXA COMPACTA NO ALTO E QUEDA RÁPIDA
            local startZ = targetCoords.z + 65.0
            local crate = safeCreateAirdropProp(crateModel, targetCoords.x, targetCoords.y, startZ, true)
            if not isValidEntity(crate) then
                crate = safeCreateAirdropProp("prop_box_wood05a", targetCoords.x, targetCoords.y, startZ, true)
            end

            if not isValidEntity(crate) then
                notify.error("MAC_Fun_Script", "Erro ao criar entidade da caixa.")
                return
            end

            safeSetInvincible(crate, true)
            ENTITY.SET_ENTITY_COLLISION(crate, true, true)

            -- Queda Rápida
            local curZ = startZ
            local fallSpeed = 36.0
            while isValidEntity(crate) and curZ > (targetCoords.z + 0.4) do
                curZ = curZ - (fallSpeed * 0.035)
                pcall(function()
                    ENTITY.SET_ENTITY_COORDS(crate, targetCoords.x, targetCoords.y, curZ, false, false, false, true)
                    ENTITY.SET_ENTITY_VELOCITY(crate, 0.0, 0.0, -fallSpeed)
                end)
                script.yield(35)
            end

            pcall(function()
                ENTITY.PLACE_ENTITY_ON_GROUND_PROPERLY(crate)
                safeSetInvincible(crate, false)
                if AUDIO and AUDIO.PLAY_SOUND_FRONTEND then
                    AUDIO.PLAY_SOUND_FRONTEND(-1, "Airhorn", "DLC_TG_Running_Back_Sounds", true)
                end
            end)

            -- 3. FUMAÇA CONTÍNUA DE SINALIZADOR ACOPLADA DIRETAMENTE NA CAIXA
            local ptfxLoop = nil
            pcall(function()
                STREAMING.REQUEST_NAMED_PTFX_ASSET("core")
                local ptO = 0
                while not STREAMING.HAS_NAMED_PTFX_ASSET_LOADED("core") and ptO < 30 do
                    script.yield(10)
                    ptO = ptO + 1
                end
                if STREAMING.HAS_NAMED_PTFX_ASSET_LOADED("core") and isValidEntity(crate) then
                    GRAPHICS.USE_PARTICLE_FX_ASSET("core")
                    ptfxLoop = GRAPHICS.START_PARTICLE_FX_LOOPED_ON_ENTITY(
                        "exp_grd_flare", crate, 0.0, 0.0, 0.35, 0.0, 0.0, 0.0, 2.0, false, false, false
                    )
                    if ptfxLoop and ptfxLoop ~= 0 then
                        if GRAPHICS.SET_PARTICLE_FX_LOOPED_COLOUR then
                            GRAPHICS.SET_PARTICLE_FX_LOOPED_COLOUR(ptfxLoop, 1.0, 0.1, 0.1, false)
                        end
                        if GRAPHICS.SET_PARTICLE_FX_LOOPED_EVOLUTION then
                            GRAPHICS.SET_PARTICLE_FX_LOOPED_EVOLUTION(ptfxLoop, "smoke", 1.0, false)
                        end
                    end
                end
            end)

            notify.success("MAC_Fun_Script", "Airdrop pousou! Siga a fumaça para pegar o conteúdo.")

            -- 4. LOOP DE PROXIMIDADE (A CAIXA E A FUMAÇA DESAPARECEM, DEIXANDO O CONTEÚDO)
            local waitTime = 0
            local opened = false

            while isValidEntity(crate) and waitTime < 450 and not opened do
                waitTime = waitTime + 1

                local cPos = ENTITY.GET_ENTITY_COORDS(crate, true)
                local playersList = get_active_session_players()

                for _, pid in ipairs(playersList) do
                    local pPed = getPlayerPedSafe(pid)
                    if isValidEntity(pPed) and not PED.IS_PED_INJURED(pPed) then
                        local pp = ENTITY.GET_ENTITY_COORDS(pPed, true)
                        local dX = pp.x - cPos.x
                        local dY = pp.y - cPos.y
                        local dZ = pp.z - cPos.z
                        local dist = math.sqrt(dX * dX + dY * dY + dZ * dZ)

                        if dist <= 3.8 then
                            opened = true
                            local openerName = (pid == get_local_pid()) and "Você" or get_player_name(pid)

                            -- PARA O EFEITO DE FUMAÇA E DELETA A CAIXA
                            pcall(function()
                                if ptfxLoop and ptfxLoop ~= 0 then
                                    GRAPHICS.STOP_PARTICLE_FX_LOOPED(ptfxLoop, false)
                                    GRAPHICS.REMOVE_PARTICLE_FX(ptfxLoop, false)
                                end
                            end)

                            safeDeleteAirdropObject(crate)

                            -- DEIXA APENAS O CONTEÚDO NO CHÃO:
                            if airdropCrateType == 1 then
                                -- 🛡️ SAÚDE E COLETE: DEIXA O KIT MÉDICO E O COLETE NO CHÃO
                                pcall(function()
                                    -- 1. Cria pickups reais do jogo no chão
                                    if OBJECT and OBJECT.CREATE_AMBIENT_PICKUP then
                                        local hPickupHash = getModelHash("PICKUP_HEALTH_STANDARD")
                                        local aPickupHash = getModelHash("PICKUP_ARMOUR_STANDARD")
                                        OBJECT.CREATE_AMBIENT_PICKUP(hPickupHash, cPos.x - 0.7, cPos.y, cPos.z + 0.2, 0, 100, getModelHash("prop_health_pack_01"), false, true)
                                        OBJECT.CREATE_AMBIENT_PICKUP(aPickupHash, cPos.x + 0.7, cPos.y, cPos.z + 0.2, 0, 100, getModelHash("prop_armour_pickup_01"), false, true)
                                    end

                                    -- 2. Spawna os itens 3D visíveis do Colete Balístico e Kit Médico
                                    safeCreateAirdropProp("prop_armour_pickup_01", cPos.x + 0.7, cPos.y, cPos.z + 0.2, true)
                                    local med = safeCreateAirdropProp("prop_health_pack_01", cPos.x - 0.7, cPos.y, cPos.z + 0.2, true)
                                    if not isValidEntity(med) then
                                        safeCreateAirdropProp("prop_ld_health_pack", cPos.x - 0.7, cPos.y, cPos.z + 0.2, true)
                                    end

                                    -- 3. Aplica Imediatamente Vida 100% + Colete Pesado 100% + Armas e Munição
                                    ENTITY.SET_ENTITY_HEALTH(pPed, ENTITY.GET_ENTITY_MAX_HEALTH(pPed), 0)
                                    PED.SET_PED_ARMOUR(pPed, 100)

                                    local weapons = {
                                        "WEAPON_MINIGUN", "WEAPON_RAILGUN", "WEAPON_HOMINGLAUNCHER",
                                        "WEAPON_RPG", "WEAPON_SPECIALCARBINE_MK2", "WEAPON_HEAVYSNIPER_MK2",
                                        "WEAPON_COMBATMG_MK2", "WEAPON_PIPEBOMB"
                                    }
                                    for _, wName in ipairs(weapons) do
                                        local wHash = getModelHash(wName)
                                        if wHash ~= 0 then
                                            WEAPON.GIVE_WEAPON_TO_PED(pPed, wHash, 9999, false, true)
                                            WEAPON.SET_PED_AMMO(pPed, wHash, 9999)
                                        end
                                    end

                                    -- Efeito sonoro de pickup
                                    if AUDIO and AUDIO.PLAY_SOUND_FRONTEND then
                                        AUDIO.PLAY_SOUND_FRONTEND(-1, "PICK_UP_WEAPON", "HUD_FRONTEND_DEFAULT_SOUNDSET", true)
                                    end
                                end)

                                notify.success("MAC_Fun_Script", openerName .. " pegou o Kit Médico e o Colete do Airdrop!")

                            elseif airdropCrateType == 2 then
                                -- 🚗 CARROS: A CAIXA SOME E O VEÍCULO APARECE PRONTO NO LUGAR
                                pcall(function()
                                    local vehModel = airdropCustomVehicleInput or "insurgent3"
                                    local vHash = getModelHash(vehModel)
                                    STREAMING.REQUEST_MODEL(vHash)
                                    local tO = 0
                                    while not STREAMING.HAS_MODEL_LOADED(vHash) and tO < 60 do
                                        script.yield(10)
                                        tO = tO + 1
                                    end
                                    if STREAMING.HAS_MODEL_LOADED(vHash) then
                                        local veh = VEHICLE.CREATE_VEHICLE(vHash, cPos.x, cPos.y, cPos.z + 0.3, ENTITY.GET_ENTITY_HEADING(pPed), true, false, false)
                                        if isValidEntity(veh) then
                                            ENTITY.SET_ENTITY_AS_MISSION_ENTITY(veh, true, true)
                                            VEHICLE.SET_VEHICLE_ENGINE_ON(veh, true, true, false)
                                            VEHICLE.SET_VEHICLE_ON_GROUND_PROPERLY(veh)
                                        end
                                    end
                                    if AUDIO and AUDIO.PLAY_SOUND_FRONTEND then
                                        AUDIO.PLAY_SOUND_FRONTEND(-1, "GARAGE_DOOR_SCRIPTED_OPEN", "GTAO_SCRIPTED_DOOR_SOUNDS", true)
                                    end
                                end)
                                notify.success("MAC_Fun_Script", openerName .. " abriu o Airdrop e recebeu o veículo!")

                            elseif airdropCrateType == 3 then
                                -- 💣 TROLL: A CAIXA SOME E EXPLODE
                                pcall(function()
                                    FIRE.ADD_EXPLOSION(cPos.x, cPos.y, cPos.z, 29, 25.0, true, false, 2.5, false)
                                    FIRE.ADD_EXPLOSION(cPos.x, cPos.y, cPos.z, 3, 12.0, true, false, 1.5, false)
                                end)
                                notify.warn("MAC_Fun_Script", "BOOM! " .. openerName .. " caiu na armadilha Troll!")
                            end

                            break
                        end
                    end
                end

                script.yield(100)
            end

            -- Limpeza por timeout caso ninguém abra
            pcall(function()
                if ptfxLoop and ptfxLoop ~= 0 then
                    GRAPHICS.STOP_PARTICLE_FX_LOOPED(ptfxLoop, false)
                    GRAPHICS.REMOVE_PARTICLE_FX(ptfxLoop, false)
                end
                safeDeleteAirdropObject(crate)
            end)
        end)

        if not ok and err then
            log.error("MAC_Fun_Script Airdrop Error: " .. tostring(err))
            notify.error("MAC_Fun_Script", "Erro no Airdrop: " .. tostring(err))
        end
    end)
end

local function renderTabAirdrop()
    if not imgui.begin_tab_item("Airdrop") then return end
    imgui.spacing()
    imgui.text("Sistema de Airdrop Militar (Entrega Rápida com Sinalizador no Pouso)")
    imgui.separator()
    imgui.spacing()

    -- 1. SELEÇÃO DO TIPO DE DROP
    imgui.text("Escolha o Tipo de Drop:")
    if imgui.button((airdropCrateType == 1 and "[X] 🛡️ Saude e Colete" or "[  ] 🛡️ Saude e Colete") .. "##ad_t_1") then
        airdropCrateType = 1
    end
    imgui.same_line()
    if imgui.button((airdropCrateType == 2 and "[X] 🚗 Carros / Veiculos" or "[  ] 🚗 Carros / Veiculos") .. "##ad_t_2") then
        airdropCrateType = 2
    end
    imgui.same_line()
    if imgui.button((airdropCrateType == 3 and "[X] 💣 Troll (Armadilha)" or "[  ] 💣 Troll (Armadilha)") .. "##ad_t_3") then
        airdropCrateType = 3
    end

    if airdropCrateType == 2 then
        imgui.spacing()
        imgui.text("Selecione o Veiculo a Entregar:")
        for idx, vp in ipairs(airdropVehiclePresets) do
            if idx > 1 and (idx - 1) % 3 ~= 0 then imgui.same_line() end
            local isSel = (airdropCustomVehicleInput == vp.model)
            if imgui.button((isSel and "[" .. vp.label .. "]" or vp.label) .. "##ad_v_" .. idx) then
                airdropCustomVehicleInput = vp.model
            end
        end
        local cV, vV = imgui.input_text("Modelo Customizado##ad_custom_veh", airdropCustomVehicleInput or "insurgent3")
        if cV then airdropCustomVehicleInput = vV end
    end

    imgui.spacing()
    imgui.separator()
    imgui.spacing()

    -- 2. ONDE CAIR (LOCATION)
    imgui.text("Onde o Airdrop deve Cair:")
    if imgui.button((airdropLocationMode == 1 and "[X] Voce Mesmo" or "[  ] Voce Mesmo") .. "##ad_loc_1") then
        airdropLocationMode = 1
    end
    imgui.same_line()
    if imgui.button((airdropLocationMode == 2 and "[X] Na Sua Frente (15m)" or "[  ] Na Sua Frente (15m)") .. "##ad_loc_2") then
        airdropLocationMode = 2
    end
    imgui.same_line()
    if imgui.button((airdropLocationMode == 3 and "[X] No Waypoint do Mapa" or "[  ] No Waypoint do Mapa") .. "##ad_loc_3") then
        airdropLocationMode = 3
    end
    imgui.same_line()
    if imgui.button((airdropLocationMode == 4 and "[X] Em Outro Jogador" or "[  ] Em Outro Jogador") .. "##ad_loc_4") then
        airdropLocationMode = 4
    end

    if airdropLocationMode == 4 then
        imgui.spacing()
        imgui.text("Selecione o Jogador Alvo para a Entrega:")
        local localPid = get_local_pid()
        local activePlayers = get_active_session_players()
        local pCount = 0
        for _, pid in ipairs(activePlayers) do
            if pid ~= localPid then
                if pCount % 2 ~= 0 then imgui.same_line() end
                pCount = pCount + 1
                local isSel = (selectedAirdropPid == pid)
                local pName = get_player_name(pid)
                local label = string.format("%s[%02d] %s##sel_ad_p_%d", isSel and "[X] " or "[  ] ", pid, pName, pid)
                if imgui.button(label) then
                    selectedAirdropPid = pid
                end
            end
        end
    end

    imgui.spacing()
    imgui.spacing()

    if imgui.button(">> SOLICITAR AIRDROP AGORA <<##call_airdrop_now_btn") then
        callAirdropSupply()
    end

    imgui.end_tab_item()
end

local function renderGUI()
    refreshPlayerInfo()
    imgui.spacing()
    imgui.text("Script Status: " .. state.status)
    imgui.text("Player: " .. state.player_name .. " (Rank " .. tostring(state.player_rank) .. ") | Wanted: " .. tostring(state.wanted_level))
    imgui.text("Position: " .. state.position)
    imgui.same_line()
    if imgui.button("Clear Wanted Level##clear_w_level") then
        pcall(function()
            if players and players.get_local then
                local player = players.get_local()
                if player and player:is_valid() then
                    player:set_wanted_level(0)
                    state.wanted_level = 0
                    state.status = "Wanted level cleared"
                    notify.success("MAC_Fun_Script", state.status)
                end
            end
        end)
    end
    imgui.spacing()

    if not imgui.begin_tab_bar("MAC_Fun_Script_Tabs") then return end

    renderTabVehicleControls()
    renderTabAreaChaos()
    renderTabEnemyJets()
    renderTabAirdrop()
    renderTabEarRapeTroll()
    renderTabOptionsAndHotkeys()
    renderTabStuntTracks()
    renderTabArenaObjectSpawner()
    renderTabPlayerAttachments()
    renderTabAngelFloatie()
    renderTabCutscenes()

    imgui.end_tab_bar()
end

-- ════════════════════════════════════════════════════════════════════
-- TROLL PESADO: EAR RAPE + TERREMOTO E TREMOR DE TELA
-- ════════════════════════════════════════════════════════════════════

local earRapeSounds = {
    { sound = "Airhorn", set = "DLC_TG_Running_Back_Sounds" },
    { sound = "Yacht_Defences_Alarm", set = "DLC_SUM20_YACHT_SOUNDS" },
    { sound = "Beep_Red", set = "DLC_HEIST_HACKING_SNAKE_SOUNDS" },
    { sound = "HACKING_CLICK_BAD", set = "DLC_HEIST_HACKING_SNAKE_SOUNDS" },
    { sound = "GARAGE_DOOR_SCRIPTED_CLOSE", set = "GTAO_SCRIPTED_DOOR_SOUNDS" },
    { sound = "LOS_SANTOS_HORNS_TRUCK_HORN", set = "DLC_SUM20_YACHT_SOUNDS" },
    { sound = "MP_Flash", set = "WastedSounds" }
}

local function stopTrollAudioHarassment()
    isTrollAudioLoopActive = false
    pcall(function()
        if CAM and CAM.STOP_GAMEPLAY_CAM_SHAKING then
            CAM.STOP_GAMEPLAY_CAM_SHAKING(true)
        end
        if GRAPHICS and GRAPHICS.ANIMPOSTFX_STOP_ALL then
            GRAPHICS.ANIMPOSTFX_STOP_ALL()
        end
    end)
    notify.info("MAC_Fun_Script", "Troll Sonoro e Tremor de Tela desativados.")
end

local function runTrollAudioHarassmentStep(targetPid)
    local localPid = get_local_pid()
    local isLocal = (targetPid == -1 or targetPid == localPid)
    local targetPed = getPlayerPedSafe(targetPid == -1 and localPid or targetPid)

    if not isValidEntity(targetPed) then
        return
    end

    local coords = ENTITY.GET_ENTITY_COORDS(targetPed, true)

    -- 1. SONS ENSURDECEDORES (EM LOOP RÁPIDO)
    pcall(function()
        for _, snd in ipairs(earRapeSounds) do
            if isLocal then
                if AUDIO and AUDIO.PLAY_SOUND_FRONTEND then
                    AUDIO.PLAY_SOUND_FRONTEND(-1, snd.sound, snd.set, true)
                end
            end
            if AUDIO and AUDIO.PLAY_SOUND_FROM_COORD then
                AUDIO.PLAY_SOUND_FROM_COORD(-1, snd.sound, coords.x, coords.y, coords.z, snd.set, true, 120, true)
            end
            if AUDIO and AUDIO.PLAY_SOUND_FROM_ENTITY then
                AUDIO.PLAY_SOUND_FROM_ENTITY(-1, snd.sound, targetPed, snd.set, true, 0)
            end
        end
    end)

    -- 2. TREMOR DE TELA E ONDAS DE IMPACTO
    pcall(function()
        local shakeMultiplier = (trollAudioIntensity == 3) and 4.5 or ((trollAudioIntensity == 2) and 2.8 or 1.5)

        -- Para o player local
        if isLocal and CAM and CAM.SHAKE_GAMEPLAY_CAM then
            CAM.SHAKE_GAMEPLAY_CAM("LARGE_EXPLOSION_SHAKE", shakeMultiplier)
        end

        -- Ondas de choque reais nas coordenadas do player (faz a câmera tremer e vibra o controle)
        if FIRE and FIRE.ADD_EXPLOSION then
            FIRE.ADD_EXPLOSION(coords.x, coords.y, coords.z - 2.0, 70, 0.0, true, false, shakeMultiplier, false)
        end

        -- 3. RELÂMPAGO CEGANTE COM TROVÃO
        if trollAudioWithLightning and MISC and MISC.FORCE_LIGHTNING_FLASH_AT_COORDS then
            MISC.FORCE_LIGHTNING_FLASH_AT_COORDS(coords.x, coords.y, coords.z, shakeMultiplier)
        end

        -- 4. FLASHBANG / POSTFX PSICODÉLICO (SE FOR LOCAL)
        if isLocal and trollAudioWithFlashbang and GRAPHICS and GRAPHICS.ANIMPOSTFX_PLAY then
            GRAPHICS.ANIMPOSTFX_PLAY("DrugsMichaelAliensFight", 0, true)
        end
    end)
end

local function triggerTrollAudioHarassment(targetPid, durationSeconds)
    script.run_in_callback(function()
        local pName = (targetPid == -1 or targetPid == get_local_pid()) and "Você Mesmo" or get_player_name(targetPid)
        notify.warn("MAC_Fun_Script", "Disparando Ear Rape e Terremoto em " .. pName .. "!")

        if durationSeconds and durationSeconds > 0 then
            local totalTicks = math.floor((durationSeconds * 1000) / 75)
            for i = 1, totalTicks do
                runTrollAudioHarassmentStep(targetPid)
                script.yield(75)
            end
            stopTrollAudioHarassment()
            notify.info("MAC_Fun_Script", "Burst de Ear Rape finalizado em " .. pName .. ".")
        else
            isTrollAudioLoopActive = true
            while isTrollAudioLoopActive do
                runTrollAudioHarassmentStep(targetPid)
                script.yield(75)
            end
        end
    end)
end

local function startNyxHandshakeLoop()
    script.run_in_callback(function()
        pcall(function()
            if DECORATOR and DECORATOR.DECOR_REGISTER then
                DECORATOR.DECOR_REGISTER("Nyx_Member", 3)
            end
        end)

        while true do
            pcall(function()
                local localPid = get_local_pid()
                local localPed = getPlayerPedSafe(localPid)

                -- 1. Mantém a assinatura de Decorator P2P no ped local
                if isValidEntity(localPed) then
                    if DECORATOR and DECORATOR.DECOR_SET_INT then
                        DECORATOR.DECOR_SET_INT(localPed, "Nyx_Member", 7777)
                    end
                end

                -- 2. Varre jogadores ativos da sessão para identificar outros membros
                local activePlayers = get_active_session_players()
                for _, pid in ipairs(activePlayers) do
                    if pid ~= localPid then
                        local tPed = getPlayerPedSafe(pid)
                        if isValidEntity(tPed) then
                            local isMember = false
                            if DECORATOR and DECORATOR.DECOR_GET_INT then
                                if DECORATOR.DECOR_GET_INT(tPed, "Nyx_Member") == 7777 then
                                    isMember = true
                                end
                            end

                            if isMember then
                                if not nyx_detected_users[pid] then
                                    nyx_detected_users[pid] = true
                                    local pName = get_player_name(pid)
                                    notify.info("Nyx", "[NYX] Membro do Nyx detectado na sessão: " .. pName .. "!")
                                    if AUDIO and AUDIO.PLAY_SOUND_FRONTEND then
                                        AUDIO.PLAY_SOUND_FRONTEND(-1, "CHECKPOINT_PERFECT", "HUD_MINI_GAME_SOUNDSET", true)
                                    end
                                end
                            end
                        end
                    end
                end
            end)

            script.yield(2500)
        end
    end)
end

function renderTabEarRapeTroll()
    if not imgui.begin_tab_item("Troll Pesado") then return end
    imgui.spacing()
    imgui.text("Troll Pesado: Ear Rape Ensurdecedor + Terremoto & Tremor de Tela")
    imgui.separator()
    imgui.spacing()

    -- 1. SELEÇÃO DO ALVO COM BADGE NYX
    imgui.text("Selecione o Jogador Alvo:")
    local localPid = get_local_pid()
    local isLocalSel = (selectedTrollAudioPid == -1 or selectedTrollAudioPid == localPid)
    if imgui.button((isLocalSel and "[X] Voce Mesmo (Testar)" or "[  ] Voce Mesmo (Testar)") .. "##troll_target_self") then
        selectedTrollAudioPid = -1
        nyx_confirmed_attack_pid = -1
    end

    local activePlayers = get_active_session_players()
    local pCount = 0
    for _, pid in ipairs(activePlayers) do
        if pid ~= localPid then
            if pCount % 2 ~= 0 then imgui.same_line() end
            pCount = pCount + 1
            local isSel = (selectedTrollAudioPid == pid)
            local isNyx = (nyx_detected_users[pid] == true)
            local badge = isNyx and " [NYX USER]" or ""
            local pName = get_player_name(pid)
            local label = string.format("%s[%02d]%s %s##troll_p_%d", isSel and "[X] " or "[  ] ", pid, badge, pName, pid)
            if imgui.button(label) then
                selectedTrollAudioPid = pid
                if not isNyx then
                    nyx_confirmed_attack_pid = pid
                end
            end
        end
    end

    imgui.spacing()
    imgui.separator()
    imgui.spacing()

    -- 2. AVISO DO PACTO DE NÃO-AGRESSÃO NYX
    local isTargetNyx = (selectedTrollAudioPid ~= -1 and selectedTrollAudioPid ~= localPid and nyx_detected_users[selectedTrollAudioPid] == true)
    local isConfirmed = (nyx_confirmed_attack_pid == selectedTrollAudioPid or not isTargetNyx)

    if isTargetNyx and not isConfirmed then
        local tName = get_player_name(selectedTrollAudioPid)
        imgui.text_colored("[AVISO] PACTO NYX: " .. tName .. " e um usuario oficial do Nyx!", 1.0, 0.85, 0.2, 1.0)
        imgui.text("Tem certeza absoluta de que deseja disparar o troll contra este membro?")
        if imgui.button(">> SIM, CONFIRMAR ATAQUE AO MEMBRO NYX <<##conf_nyx_troll_btn") then
            nyx_confirmed_attack_pid = selectedTrollAudioPid
            notify.warn("Nyx", "Ataque autorizado contra membro do Nyx!")
        end
        imgui.same_line()
        if imgui.button("Cancelar##cancel_nyx_troll_btn") then
            selectedTrollAudioPid = -1
            nyx_confirmed_attack_pid = -1
        end
        imgui.spacing()
        imgui.separator()
        imgui.spacing()
    end

    -- 3. CONFIGURAÇÕES DA INTENSIDADE
    imgui.text("Intensidade do Terremoto / Sons:")
    if imgui.button((trollAudioIntensity == 1 and "[X] Leve" or "[  ] Leve") .. "##troll_int_1") then
        trollAudioIntensity = 1
    end
    imgui.same_line()
    if imgui.button((trollAudioIntensity == 2 and "[X] Intenso" or "[  ] Intenso") .. "##troll_int_2") then
        trollAudioIntensity = 2
    end
    imgui.same_line()
    if imgui.button((trollAudioIntensity == 3 and "[X] Apocaliptico" or "[  ] Apocaliptico") .. "##troll_int_3") then
        trollAudioIntensity = 3
    end

    imgui.spacing()
    local cL, vL = imgui.checkbox("Incluir Relampagos & Trovoes Cegantes##troll_lightning", trollAudioWithLightning)
    if cL then trollAudioWithLightning = vL end

    local cF, vF = imgui.checkbox("Incluir Flashbang / Efeito Psicodelico##troll_flashbang", trollAudioWithFlashbang)
    if cF then trollAudioWithFlashbang = vF end

    imgui.spacing()
    imgui.separator()
    imgui.spacing()

    -- 4. BOTÕES DE DISPARO
    imgui.text("Controle do Troll:")
    if isTargetNyx and not isConfirmed then
        imgui.text_colored("[AVISO] Confirme a autorizacao acima para liberar o disparo contra o membro Nyx.", 0.9, 0.4, 0.4, 1.0)
    else
        if imgui.button("Disparo Rapido (5 Segundos)##troll_burst_5s") then
            triggerTrollAudioHarassment(selectedTrollAudioPid, 5)
        end
        imgui.same_line()
        if imgui.button("Disparo Longo (10 Segundos)##troll_burst_10s") then
            triggerTrollAudioHarassment(selectedTrollAudioPid, 10)
        end

        imgui.spacing()
        if not isTrollAudioLoopActive then
            if imgui.button("INICIAR LOOP INFINITO (EAR RAPE + TERREMOTO)##start_troll_loop_btn") then
                triggerTrollAudioHarassment(selectedTrollAudioPid, -1)
            end
        else
            if imgui.button("PARAR LOOP / DESATIVAR TROLL##stop_troll_loop_btn") then
                stopTrollAudioHarassment()
            end
        end
    end

    imgui.same_line()
    if imgui.button("Parar Todos os Efeitos Imediatamente##force_stop_troll_all") then
        stopTrollAudioHarassment()
    end

    imgui.end_tab_item()
end


-- -- Menu Integration (Native Tab in NewWay Menu) ----------------

local macTab = nil
pcall(function()
    if gui and gui.add_tab then
        macTab = gui.add_tab("Nyx")
    end
end)

if macTab and macTab.add_imgui then
    macTab:add_imgui(renderGUI)
else
    gui.add_imgui(renderGUI)
end

startHotkeyLoop()
startNyxHandshakeLoop()

if event and event.register_handler and menu_event and menu_event.Unload then
    event.register_handler(menu_event.Unload, function()
        log.info("Nyx unloaded cleanly; interface removed.")
    end)
end

local NyxColorThemes = {
    cyberpunk = {
        title = "~p~N~q~y~b~x",
        subtitle = "~w~A ~p~NewWay ~s~Script",
        shardCol = 0
    },
    rainbow = {
        title = "~r~N~y~y~g~x",
        subtitle = "~y~A ~g~NewWay ~b~Script",
        shardCol = 0
    },
    electric_blue = {
        title = "~b~N~c~y~p~x",
        subtitle = "~w~A ~b~NewWay ~s~Script",
        shardCol = 0
    },
    sunset_fire = {
        title = "~y~N~o~y~r~x",
        subtitle = "~w~A ~o~NewWay ~s~Script",
        shardCol = 0
    },
    matrix_green = {
        title = "~g~N~g~y~w~x",
        subtitle = "~w~A ~g~NewWay ~s~Script",
        shardCol = 0
    },
    gold_luxury = {
        title = "~HUD_COLOUR_GOLD~N~y~y~w~x",
        subtitle = "~w~A ~HUD_COLOUR_GOLD~NewWay ~s~Script",
        shardCol = 0
    }
}

local function showNyxWelcomeMessage(themeNameOrTitle, subtitle, durationMs)
    local theme = nil
    local titleFormatted = nil
    local subtitleFormatted = nil
    local shardCol = 0

    if type(themeNameOrTitle) == "string" and NyxColorThemes[themeNameOrTitle] then
        theme = NyxColorThemes[themeNameOrTitle]
        titleFormatted = theme.title
        subtitleFormatted = theme.subtitle
        shardCol = theme.shardCol or 0
    elseif type(themeNameOrTitle) == "string" and themeNameOrTitle ~= "" then
        titleFormatted = themeNameOrTitle
        subtitleFormatted = subtitle or "~w~A ~p~NewWay ~s~Script"
    else
        theme = NyxColorThemes.cyberpunk
        titleFormatted = theme.title
        subtitleFormatted = theme.subtitle
    end

    durationMs = durationMs or 4000

    -- 1. NewWay UI Notification Toast
    notify.info("Nyx", "A NewWay Script")

    -- 2. GTA V Feed Post Notification (above mini-map)
    pcall(function()
        if HUD and HUD.BEGIN_TEXT_COMMAND_THEFEED_POST then
            HUD.BEGIN_TEXT_COMMAND_THEFEED_POST("STRING")
            HUD.ADD_TEXT_COMPONENT_SUBSTRING_PLAYER_NAME(tostring(subtitleFormatted))
            if HUD.END_TEXT_COMMAND_THEFEED_POST_MESSAGETEXT then
                HUD.END_TEXT_COMMAND_THEFEED_POST_MESSAGETEXT("CHAR_ALL_PLAYERS_CONF", "CHAR_ALL_PLAYERS_CONF", true, 4, tostring(titleFormatted), "~b~Script Loaded")
            elseif HUD.END_TEXT_COMMAND_THEFEED_POST_TICKER then
                HUD.END_TEXT_COMMAND_THEFEED_POST_TICKER(false, true)
            end
        end
    end)

    -- 3. GTA V On-Screen Subtitle Message (bottom center)
    pcall(function()
        if HUD and HUD.BEGIN_TEXT_COMMAND_PRINT then
            HUD.BEGIN_TEXT_COMMAND_PRINT("STRING")
            HUD.ADD_TEXT_COMPONENT_SUBSTRING_PLAYER_NAME(tostring(titleFormatted) .. " ~s~- " .. tostring(subtitleFormatted))
            HUD.END_TEXT_COMMAND_PRINT(durationMs, true)
        end
    end)

    -- 4. GTA Online Big Shard Screen Banner (Scaleform Center Screen)
    if script and script.run_in_callback then
        script.run_in_callback(function()
            pcall(function()
                if not GRAPHICS or not GRAPHICS.REQUEST_SCALEFORM_MOVIE then return end
                local sf = GRAPHICS.REQUEST_SCALEFORM_MOVIE("MP_BIG_MESSAGE_FREEMODE")
                local maxWait = 0
                while not GRAPHICS.HAS_SCALEFORM_MOVIE_LOADED(sf) and maxWait < 80 do
                    script.yield(10)
                    maxWait = maxWait + 1
                end

                if GRAPHICS.HAS_SCALEFORM_MOVIE_LOADED(sf) then
                    GRAPHICS.BEGIN_SCALEFORM_MOVIE_METHOD(sf, "SHOW_SHARD_CENTERED_MP_MESSAGE")
                    GRAPHICS.SCALEFORM_MOVIE_METHOD_ADD_PARAM_PLAYER_NAME_STRING(tostring(titleFormatted))
                    GRAPHICS.SCALEFORM_MOVIE_METHOD_ADD_PARAM_PLAYER_NAME_STRING(tostring(subtitleFormatted))
                    GRAPHICS.SCALEFORM_MOVIE_METHOD_ADD_PARAM_INT(shardCol)
                    GRAPHICS.END_SCALEFORM_MOVIE_METHOD()

                    local start = (MISC and MISC.GET_GAME_TIMER and MISC.GET_GAME_TIMER()) or 0
                    while (((MISC and MISC.GET_GAME_TIMER and MISC.GET_GAME_TIMER()) or 0) - start) < durationMs do
                        GRAPHICS.DRAW_SCALEFORM_MOVIE_FULLSCREEN(sf, 255, 255, 255, 255, 0)
                        script.yield(0)
                    end
                    GRAPHICS.SET_SCALEFORM_MOVIE_AS_NO_LONGER_NEEDED(sf)
                end
            end)
        end)
    end

    -- 5. Sound & Camera Effects
    pcall(function()
        if AUDIO and AUDIO.PLAY_SOUND_FRONTEND then
            AUDIO.PLAY_SOUND_FRONTEND(-1, "CHECKPOINT_PERFECT", "HUD_MINI_GAME_SOUNDSET", true)
        end
        if GRAPHICS and GRAPHICS.ANIMPOSTFX_PLAY then
            GRAPHICS.ANIMPOSTFX_PLAY("CamPushInNeutral", 800, false)
        end
    end)
end

showNyxWelcomeMessage("cyberpunk", nil, 4000)

if log and log.info then
    log.info("Nyx.lua loaded successfully! Enjoy.")
end

