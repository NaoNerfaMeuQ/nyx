--[[
    SpyreX.lua
    Versao: 2.1.1 - Advanced Ultimate Suite
    Contendo: Jatos 20mm, Ear Rape & Tremor, Spam de Convites, Airdrop Militar,
              Controles de Veiculo & Telecinese, Caos de Area & Sessao (Halloween & Timelapse),
              Pistas & Rampas Acrobaticas (Inception), Spawn de Props Arena & Stand,
              Projeto Maze Bank, Anexar Objetos nos Players, Angel Floatie, Cutscenes Online
]]

pcall(function()
    if natives and natives.load_natives then
        natives.load_natives()
    end
end)

------------------------------------------------------------
-- GLOBAL MODULE STATE & PRESETS
------------------------------------------------------------

local S = {
    -- Telekinesis & Physics
    liftHeight = 10.0,
    launchForce = 150.0,
    holdDistance = 12.0,
    igniteOnLaunch = false,
    makeInvincible = true,
    disableRagdoll = false,
    isHoldingVehicle = false,
    heldVehicle = nil,
    isCarryingPlayer = false,
    carriedPlayerPed = nil,

    -- Chaos Loops
    spinPlayerVehActive = false,
    spinPlayerVehLoopActive = false,
    spinPlayerTargetVeh = nil,
    spinAreaVehsActive = false,
    spinAreaVehsLoopActive = false,
    infiniteLevitateActive = false,
    infiniteLevitateLoopActive = false,
    vortexActive = false,
    vortexLoopActive = false,
    ufoDiscoActive = false,
    ufoDiscoLoopActive = false,
    pushRepulsorActive = false,
    pushRepulsorLoopActive = false,
    vehicleRainActive = false,
    vehicleRainLoopActive = false,
    vehicleShieldActive = false,
    vehicleShieldLoopActive = false,
    vehicleSnakeActive = false,
    vehicleSnakeLoopActive = false,
    zombiePedOutbreakActive = false,
    zombiePedOutbreakLoopActive = false,
    hotkeysEnabled = true,
    hotkeyLoopActive = false,

    -- Stunt Tracks & Props
    stunt_altitude = 100.0,
    customSpawnDistance = 15.0,
    customSpawnHeight = 0.0,
    customSpawnYaw = 0.0,
    customSpawnFreeze = true,
    selectedPropSpawnPid = -1,
    is_spawning_stunt = false,
    spawned_stunt_objects = {},
    fixedUfoObject = nil,
    spawned_mazebank_objects = {},

    -- Player Attachments
    attached_player_props = {},
    selectedAttachmentPid = -1,
    customAttachModelInput = "prop_mp_cone_01",
    customAttachBoneId = 24818,
    attachPresetModeAll = false,
    isAttachmentKeeperRunning = false,
    angelFloatieObject = nil,
    angelFloatieActive = false,

    -- Weather & Time
    halloweenModeActive = false,
    halloweenLoopRunning = false,
    fastTimeActive = false,
    fastTimeLoopRunning = false,
    fastTimeSpeed = 15,

    -- Cutscenes
    customCutsceneName = "MP_INTRO_LAMAR_DRIVE_SCENE",
    selectedCutscenePid = -1,

    -- Jets (Dogfight)
    activeDogfightJets = {},
    dogfightAttackRunning = false,
    dogfightSessionId = 0,
    selectedDogfightPid = -1,
    lastDogfightTick = 0,

    -- Ear Rape
    isTrollAudioActive = false,
    trollAudioLoop = false,
    trollLightning = true,
    trollFlashbang = true,
    muteEarRapeLocal = true,
    earRapeStepIndex = 0,
    selectedEarRapePid = -2,

    -- Contact Invites
    contactSelectedPid = -1,
    contactSubject = "Convite para atividade",
    contactActivity = "Penthouse",
    contactIconType = 7,
    contactDelayMs = 450,
    contactIsSpamming = false,

    -- Airdrop
    airdropLocationMode = 1,
    airdropDropType = 1,
    selectedAirdropPid = -1,
    airdropVehicleModel = "oppressor2",
    airdropVehicleName = "Oppressor Mk II",
    airdropSessionId = 0,
    ActiveAirdrop = nil,

    -- Carry anim state
    activeAnimDict = nil,
    activeAnimName = nil
}

local Presets = {
    stunt_highway = {
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
    },

    cyber_arena_highway = {
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
    },

    arena_neon_speed = {
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
    },

    mega_arena_jump = {
        { model = "stt_prop_stunt_track_straight", rel_x = 0.0, rel_y = -250.0, rel_z = 0.0, yaw = 0.0 },
        { model = "ar_prop_ar_tube_4x_speed", rel_x = 0.0, rel_y = -180.0, rel_z = 0.0, yaw = 0.0 },
        { model = "ar_prop_ar_neon_gate8x_01a", rel_x = 0.0, rel_y = -120.0, rel_z = 0.0, yaw = 0.0 },
        { model = "stt_prop_stunt_jump_l", rel_x = 0.0, rel_y = -60.0, rel_z = 0.0, yaw = 0.0 },
        { model = "ar_prop_ar_speed_ring", rel_x = 0.0, rel_y = 0.0, rel_z = 15.0, yaw = 0.0 },
        { model = "ar_prop_ar_jump_loop", rel_x = 0.0, rel_y = 80.0, rel_z = 25.0, yaw = 0.0 },
        { model = "ar_prop_ar_hoop_med_01", rel_x = 0.0, rel_y = 160.0, rel_z = 20.0, yaw = 0.0 },
        { model = "ar_prop_ar_tube_4x_l", rel_x = 0.0, rel_y = 240.0, rel_z = 5.0, yaw = 0.0 },
        { model = "ar_prop_ar_bblock_huge_01", rel_x = 0.0, rel_y = 320.0, rel_z = 0.0, yaw = 0.0 }
    },

    mazeBankProps = {
        { model = "ar_prop_ar_neon_gate8x_01a", x = -72.35743, y = -807.41730, z = 70.98969,  rx = 0.0, ry = 90.0, rz = 0.0 },
        { model = "ar_prop_ar_neon_gate8x_01a", x = -72.35743, y = -807.41730, z = 145.84317, rx = 0.0, ry = 90.0, rz = 0.0 },
        { model = "ar_prop_ar_neon_gate8x_01a", x = -72.35743, y = -807.41730, z = 219.16479, rx = 0.0, ry = 90.0, rz = 0.0 },
        { model = "ar_prop_ar_neon_gate8x_01a", x = -72.35743, y = -807.41730, z = 292.91010, rx = 0.0, ry = 90.0, rz = 0.0 },
        { model = "sum_prop_dufocore_01a",      x = -76.78993, y = -818.66071, z = 404.13724, rx = 0.0, ry = 0.0,  rz = 0.0 },
    },

    earRapeSounds = {
        { sound = "Airhorn", set = "DLC_TG_Running_Back_Sounds" },
        { sound = "Yacht_Defences_Alarm", set = "DLC_SUM20_YACHT_SOUNDS" },
        { sound = "Beep_Red", set = "DLC_HEIST_HACKING_SNAKE_SOUNDS" },
        { sound = "HACKING_CLICK_BAD", set = "DLC_HEIST_HACKING_SNAKE_SOUNDS" },
        { sound = "GARAGE_DOOR_SCRIPTED_CLOSE", set = "GTAO_SCRIPTED_DOOR_SOUNDS" },
        { sound = "LOS_SANTOS_HORNS_TRUCK_HORN", set = "DLC_SUM20_YACHT_SOUNDS" },
        { sound = "MP_Flash", set = "WastedSounds" },
        { sound = "Alarm_Loop", set = "DLC_H4_Prep_FC_Sounds" },
        { sound = "Bomb_Disarmed", set = "GTAO_Speed_Convoy_Soundset" },
        { sound = "10_SEC_WARNING", set = "HUD_MINI_GAME_SOUNDSET" },
        { sound = "Wasted", set = "POWER_PLAY_General_Soundset" },
        { sound = "CHECKPOINT_PERFECT", set = "HUD_MINI_GAME_SOUNDSET" }
    },

    networkedEarRapeWeapons = {
        { name = "Railgun Sci-Fi", model = "WEAPON_RAILGUN" },
        { name = "Canhao Caca 20mm", model = "VEHICLE_WEAPON_PLAYER_LAZER" },
        { name = "Sniper Explosiva Mk2", model = "WEAPON_HEAVYSNIPER_MK2" },
        { name = "Canhao de Tanque Rhino", model = "VEHICLE_WEAPON_TANK" },
        { name = "Taser Eletrico Choque", model = "WEAPON_STUNGUN" },
        { name = "Minigun Alienigena", model = "WEAPON_RAYMINIGUN" },
        { name = "Pistola Gravitacional", model = "WEAPON_RAYPISTOL" },
        { name = "Lanca Granadas Pesado", model = "WEAPON_GRENADELAUNCHER" },
        { name = "Lanca Misseis Guiados", model = "WEAPON_HOMINGLAUNCHER" }
    },

    contacts = {
        { name = "Abigail", txd = "CHAR_ABIGAIL" },
        { name = "Amanda", txd = "CHAR_AMANDA" },
        { name = "Ammu-Nation", txd = "CHAR_AMMUNATION" },
        { name = "Andreas", txd = "CHAR_ANDREAS" },
        { name = "Antonia", txd = "CHAR_ANTONIA" },
        { name = "Arthur", txd = "CHAR_ARTHUR" },
        { name = "Ashley", txd = "CHAR_ASHLEY" },
        { name = "Fleeca Bank", txd = "CHAR_BANK_FLEECA" },
        { name = "Maze Bank", txd = "CHAR_BANK_MAZE" },
        { name = "Barry", txd = "CHAR_BARRY" },
        { name = "Beverly", txd = "CHAR_BEVERLY" },
        { name = "Chef", txd = "CHAR_CHEF" },
        { name = "Cheng", txd = "CHAR_CHENG" },
        { name = "Dave", txd = "CHAR_DAVE" },
        { name = "Denise", txd = "CHAR_DENISE" },
        { name = "Franklin", txd = "CHAR_FRANKLIN" },
        { name = "Hao", txd = "CHAR_HAO" },
        { name = "Jimmy", txd = "CHAR_JIMMY" },
        { name = "Lamar", txd = "CHAR_LAMAR" },
        { name = "Lazlow", txd = "CHAR_LAZLOW" },
        { name = "Lester", txd = "CHAR_LESTER" },
        { name = "Martin Madrazo", txd = "CHAR_MARTIN" },
        { name = "Michael", txd = "CHAR_MICHAEL" },
        { name = "Pegasus", txd = "CHAR_PEGASUS_DELIVERY" },
        { name = "Ron", txd = "CHAR_RON" },
        { name = "Simeon", txd = "CHAR_SIMEON" },
        { name = "Trevor", txd = "CHAR_TREVOR" }
    },

    airdropVehicles = {
        { label = "Oppressor Mk II", model = "oppressor2" },
        { label = "Vigilante", model = "vigilante" },
        { label = "Insurgent Custom .50cal", model = "insurgent3" },
        { label = "Tanque Khanjali", model = "khanjali" },
        { label = "Toreador", model = "toreador" },
        { label = "Deluxo", model = "deluxo" }
    }
}

------------------------------------------------------------
-- CORE HELPERS
------------------------------------------------------------

local function getLocalPed()
    local ped = 0
    pcall(function()
        if PLAYER and PLAYER.PLAYER_PED_ID then ped = PLAYER.PLAYER_PED_ID() end
    end)
    return ped or 0
end

local function getLocalPid()
    local pid = 0
    pcall(function()
        if PLAYER and PLAYER.PLAYER_ID then pid = PLAYER.PLAYER_ID() end
    end)
    return pid or 0
end

local function isValidEntity(ent)
    if not ent or type(ent) ~= "number" or ent <= 0 then return false end
    local valid = false
    pcall(function()
        if ENTITY and ENTITY.DOES_ENTITY_EXIST then valid = ENTITY.DOES_ENTITY_EXIST(ent) end
    end)
    return valid
end

local function getPlayerPed(pid)
    local myLocalPid = getLocalPid()
    if pid == nil or pid == -1 or pid == myLocalPid then return getLocalPed() end
    local ped = 0
    pcall(function()
        if PLAYER and PLAYER.GET_PLAYER_PED_SCRIPT_INDEX then ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid) end
        if (not ped or ped == 0 or not isValidEntity(ped)) and PLAYER and PLAYER.GET_PLAYER_PED then ped = PLAYER.GET_PLAYER_PED(pid) end
        if (not ped or ped == 0 or not isValidEntity(ped)) and player and player.get_player_ped then ped = player.get_player_ped(pid) end
        if (not ped or ped == 0 or not isValidEntity(ped)) and players and players.get_ped then ped = players.get_ped(pid) end
    end)
    return ped or 0
end

local function getPlayerName(pid)
    if pid == nil or pid < 0 then return "Nenhum" end
    local name = nil
    pcall(function()
        if PLAYER and PLAYER.GET_PLAYER_NAME then
            local n = PLAYER.GET_PLAYER_NAME(pid)
            if n and n ~= "" and n ~= "**Invalid**" then name = n end
        end
        if not name and players and players.get_name then name = players.get_name(pid) end
    end)
    return name or ("Player_" .. tostring(pid))
end

local function isPlayerActive(pid)
    local active = false
    pcall(function()
        if NETWORK and NETWORK.NETWORK_IS_PLAYER_ACTIVE then active = NETWORK.NETWORK_IS_PLAYER_ACTIVE(pid)
        elseif PLAYER and PLAYER.IS_PLAYER_PLAYING then active = PLAYER.IS_PLAYER_PLAYING(pid) end
    end)
    return active
end

local function getActivePlayersList()
    local list = {}
    for i = 0, 31 do
        local active = false
        pcall(function()
            if PLAYER and PLAYER.IS_PLAYER_PLAYING and PLAYER.IS_PLAYER_PLAYING(i) then active = true
            elseif NETWORK and NETWORK.NETWORK_IS_PLAYER_CONNECTED and NETWORK.NETWORK_IS_PLAYER_CONNECTED(i) then active = true end
        end)
        if active then table.insert(list, i) end
    end
    return list
end

local function getTargetCoordsSafe(pid, ped)
    local coords = nil
    pcall(function()
        if ped and ped ~= 0 and isValidEntity(ped) then
            local c = ENTITY.GET_ENTITY_COORDS(ped, true)
            if c and (c.x ~= 0 or c.y ~= 0 or c.z ~= 0) then coords = c end
        end
    end)
    if not coords and pid and pid >= 0 then
        pcall(function()
            if player and player.get_player_coords then coords = player.get_player_coords(pid)
            elseif players and players.get_position then coords = players.get_position(pid) end
        end)
    end
    if not coords or (coords.x == 0 and coords.y == 0 and coords.z == 0) then
        coords = ENTITY.GET_ENTITY_COORDS(getLocalPed(), true)
    end
    return coords
end

local function gameTimer()
    local value = 0
    pcall(function()
        if MISC and MISC.GET_GAME_TIMER then value = MISC.GET_GAME_TIMER()
        elseif util and util.current_time_millis then value = util.current_time_millis()
        else value = math.floor(os.clock() * 1000) end
    end)
    local num = tonumber(value) or 0
    if num == 0 then num = math.floor(os.clock() * 1000) end
    return num
end

local function getHash(name)
    if type(name) == "number" then return name end
    local hash = 0
    pcall(function()
        if joaat then hash = joaat(name)
        elseif util and util.joaat then hash = util.joaat(tostring(name))
        elseif MISC and MISC.GET_HASH_KEY then hash = MISC.GET_HASH_KEY(tostring(name)) end
    end)
    return hash or 0
end

local function showFeedNotification(text)
    if not HUD then return false end
    local success = false
    pcall(function()
        HUD.BEGIN_TEXT_COMMAND_THEFEED_POST("STRING")
        HUD.ADD_TEXT_COMPONENT_SUBSTRING_PLAYER_NAME(tostring(text))
        HUD.END_TEXT_COMMAND_THEFEED_POST_TICKER(false, false)
        success = true
    end)
    return success
end

local notify = {
    success = function(title, msg) showFeedNotification("~g~[" .. tostring(title) .. "] ~s~" .. tostring(msg)) end,
    info = function(title, msg) showFeedNotification("~b~[" .. tostring(title) .. "] ~s~" .. tostring(msg)) end,
    warn = function(title, msg) showFeedNotification("~y~[" .. tostring(title) .. "] ~s~" .. tostring(msg)) end,
    error = function(title, msg) showFeedNotification("~r~[" .. tostring(title) .. "] ~s~" .. tostring(msg)) end
}

local function getControlOfEntity(ent)
    if not isValidEntity(ent) then return false end
    pcall(function()
        if NETWORK and NETWORK.NETWORK_HAS_CONTROL_OF_ENTITY and not NETWORK.NETWORK_HAS_CONTROL_OF_ENTITY(ent) then
            if NETWORK.NETWORK_REQUEST_CONTROL_OF_ENTITY then NETWORK.NETWORK_REQUEST_CONTROL_OF_ENTITY(ent) end
        end
        if ENTITY and ENTITY.SET_ENTITY_AS_MISSION_ENTITY then ENTITY.SET_ENTITY_AS_MISSION_ENTITY(ent, true, true) end
    end)
    return true
end

local function safeRemoveBlip(blip)
    if not blip or blip == 0 then return end
    pcall(function()
        if HUD then
            if HUD.DOES_BLIP_EXIST and HUD.DOES_BLIP_EXIST(blip) then
                if HUD.SET_BLIP_DISPLAY then HUD.SET_BLIP_DISPLAY(blip, 0) end
                if HUD.REMOVE_BLIP then HUD.REMOVE_BLIP(blip) end
            end
        end
    end)
end

local function removeBlipForEntity(ent)
    if not ent or ent == 0 then return end
    pcall(function()
        if HUD and HUD.GET_BLIP_FROM_ENTITY then
            local b = HUD.GET_BLIP_FROM_ENTITY(ent)
            if b and b ~= 0 then safeRemoveBlip(b) end
        end
    end)
end

local function purgeAllJetBlips()
    pcall(function()
        if HUD and HUD.GET_FIRST_BLIP_INFO_ID and HUD.GET_NEXT_BLIP_INFO_ID then
            local blip = HUD.GET_FIRST_BLIP_INFO_ID(16)
            local limit = 0
            while blip and blip ~= 0 and HUD.DOES_BLIP_EXIST and HUD.DOES_BLIP_EXIST(blip) and limit < 64 do
                local nextBlip = HUD.GET_NEXT_BLIP_INFO_ID(16)
                if HUD.SET_BLIP_DISPLAY then HUD.SET_BLIP_DISPLAY(blip, 0) end
                if HUD.REMOVE_BLIP then HUD.REMOVE_BLIP(blip) end
                blip = nextBlip
                limit = limit + 1
            end
        end
    end)
end

local function safeDeleteEntity(ent)
    if not ent or ent == 0 then return end
    pcall(function()
        if ENTITY and ENTITY.DOES_ENTITY_EXIST and ENTITY.DOES_ENTITY_EXIST(ent) then
            removeBlipForEntity(ent)
            getControlOfEntity(ent)
            if entities and entities.delete_by_handle then pcall(function() entities.delete_by_handle(ent) end)
            elseif entities and entities.delete then pcall(function() entities.delete(ent) end) end

            if ENTITY.DOES_ENTITY_EXIST(ent) then
                if VEHICLE and VEHICLE.DELETE_VEHICLE and ENTITY.IS_ENTITY_A_VEHICLE and ENTITY.IS_ENTITY_A_VEHICLE(ent) then
                    pcall(function() VEHICLE.DELETE_VEHICLE(ent) end)
                elseif PED and PED.DELETE_PED and ENTITY.IS_ENTITY_A_PED and ENTITY.IS_ENTITY_A_PED(ent) then
                    pcall(function() PED.DELETE_PED(ent) end)
                elseif OBJECT and OBJECT.DELETE_OBJECT and ENTITY.IS_ENTITY_AN_OBJECT and ENTITY.IS_ENTITY_AN_OBJECT(ent) then
                    pcall(function() OBJECT.DELETE_OBJECT(ent) end)
                elseif ENTITY.DELETE_ENTITY then
                    pcall(function() ENTITY.DELETE_ENTITY(ent) end)
                end
            end

            if ENTITY.DOES_ENTITY_EXIST(ent) then
                pcall(function() ENTITY.SET_ENTITY_COORDS(ent, 0.0, 0.0, -500.0, false, false, false, false) end)
                pcall(function() ENTITY.SET_ENTITY_AS_NO_LONGER_NEEDED(ent) end)
            end
        end
    end)
end

local function requestAndLoadModel(modelHash, maxWaitTicks)
    if not modelHash or modelHash == 0 then return false end
    if STREAMING and STREAMING.HAS_MODEL_LOADED and STREAMING.HAS_MODEL_LOADED(modelHash) then return true end
    local maxTicks = maxWaitTicks or 100
    for i = 1, maxTicks do
        pcall(function() if STREAMING and STREAMING.REQUEST_MODEL then STREAMING.REQUEST_MODEL(modelHash) end end)
        if STREAMING and STREAMING.HAS_MODEL_LOADED and STREAMING.HAS_MODEL_LOADED(modelHash) then return true end
        script.yield(10)
    end
    return (STREAMING and STREAMING.HAS_MODEL_LOADED and STREAMING.HAS_MODEL_LOADED(modelHash)) or false
end

local function safeSetInvincible(entity, state)
    if not isValidEntity(entity) then return end
    pcall(function()
        ENTITY.SET_ENTITY_INVINCIBLE(entity, state)
        if VEHICLE and VEHICLE.SET_VEHICLE_CAN_BE_VISIBLY_DAMAGED then VEHICLE.SET_VEHICLE_CAN_BE_VISIBLY_DAMAGED(entity, not state) end
    end)
end

local function getCameraDirection()
    local rot = { x = 0.0, y = 0.0, z = 0.0 }
    pcall(function()
        if CAM and CAM.GET_GAMEPLAY_CAM_ROT then rot = CAM.GET_GAMEPLAY_CAM_ROT(2) end
    end)
    local cz = math.rad(rot.z)
    local cx = math.rad(rot.x)
    local num = math.abs(math.cos(cx))
    return { x = -math.sin(cz) * num, y = math.cos(cz) * num, z = math.sin(cx) }
end

local function drawText3D(x, y, z, text)
    pcall(function()
        if GRAPHICS and GRAPHICS.SET_DRAW_ORIGIN then GRAPHICS.SET_DRAW_ORIGIN(x, y, z, 0) end
        HUD.SET_TEXT_SCALE(0.38, 0.38)
        HUD.SET_TEXT_FONT(0)
        HUD.SET_TEXT_PROPORTIONAL(true)
        HUD.SET_TEXT_COLOUR(255, 255, 255, 255)
        HUD.SET_TEXT_DROPSHADOW(0, 0, 0, 0, 255)
        HUD.SET_TEXT_EDGE(2, 0, 0, 0, 150)
        HUD.SET_TEXT_DROP_SHADOW()
        HUD.SET_TEXT_OUTLINE()
        HUD.SET_TEXT_CENTRE(true)
        if HUD.BEGIN_TEXT_COMMAND_DISPLAY_TEXT then
            HUD.BEGIN_TEXT_COMMAND_DISPLAY_TEXT("STRING")
            HUD.ADD_TEXT_COMPONENT_SUBSTRING_PLAYER_NAME(text)
            HUD.END_TEXT_COMMAND_DISPLAY_TEXT(0.0, 0.0)
        end
        if GRAPHICS and GRAPHICS.CLEAR_DRAW_ORIGIN then GRAPHICS.CLEAR_DRAW_ORIGIN() end
    end)
end

local function updateRagdollState()
    pcall(function()
        local ped = getLocalPed()
        if PED and PED.SET_PED_CAN_RAGDOLL then PED.SET_PED_CAN_RAGDOLL(ped, not S.disableRagdoll) end
    end)
end

local function safePlayAnim(ped, dict, anim, flag)
    pcall(function() STREAMING.REQUEST_ANIM_DICT(dict) end)
    local timeout = 0
    while not STREAMING.HAS_ANIM_DICT_LOADED(dict) and timeout < 20 do
        script.yield(10)
        timeout = timeout + 1
    end
    pcall(function()
        TASK.TASK_PLAY_ANIM(ped, dict, anim, 8.0, -8.0, -1, flag or 49, 0, false, false, false)
        S.activeAnimDict = dict
        S.activeAnimName = anim
    end)
end

local function playCarryAnim()
    pcall(function() safePlayAnim(getLocalPed(), "random@arrests", "idle_2_hands_up", 49) end)
end

local function stopCarryAnim()
    pcall(function()
        local ped = getLocalPed()
        if S.activeAnimDict and S.activeAnimName then TASK.STOP_ANIM_TASK(ped, S.activeAnimDict, S.activeAnimName, 3.0) end
        S.activeAnimDict = nil
        S.activeAnimName = nil
    end)
end

local function detachVehicle(veh)
    if not isValidEntity(veh) then return end
    pcall(function()
        if ENTITY.IS_ENTITY_ATTACHED(veh) then ENTITY.DETACH_ENTITY(veh, true, true) end
        ENTITY.SET_ENTITY_COLLISION(veh, true, true)
        if ENTITY.SET_ENTITY_DYNAMIC then ENTITY.SET_ENTITY_DYNAMIC(veh, true) end
        if VEHICLE and VEHICLE.SET_VEHICLE_ON_GROUND_PROPERLY then VEHICLE.SET_VEHICLE_ON_GROUND_PROPERLY(veh) end
    end)
end

local function getTargetVehicle(maxDist)
    maxDist = maxDist or 25.0
    local ped = getLocalPed()
    if not isValidEntity(ped) then return nil end
    local pCoords = ENTITY.GET_ENTITY_COORDS(ped, true)
    local myVeh = PED.GET_VEHICLE_PED_IS_IN(ped, false)

    local veh = VEHICLE.GET_CLOSEST_VEHICLE(pCoords.x, pCoords.y, pCoords.z, maxDist, 0, 70)
    if isValidEntity(veh) and veh ~= myVeh then return veh end

    local heading = ENTITY.GET_ENTITY_HEADING(ped)
    local rad = math.rad(heading)
    local fwdX = -math.sin(rad)
    local fwdY = math.cos(rad)

    for i = 1, 6 do
        local cx = pCoords.x + fwdX * (i * 4.0)
        local cy = pCoords.y + fwdY * (i * 4.0)
        local fVeh = VEHICLE.GET_CLOSEST_VEHICLE(cx, cy, pCoords.z, 8.0, 0, 70)
        if not isValidEntity(fVeh) then fVeh = VEHICLE.GET_CLOSEST_VEHICLE(cx, cy, pCoords.z, 8.0, 0, 0) end
        if isValidEntity(fVeh) and fVeh ~= myVeh then return fVeh end
    end

    local forward = getCameraDirection()
    local rayEnd = { x = pCoords.x + forward.x * maxDist, y = pCoords.y + forward.y * maxDist, z = pCoords.z + forward.z * maxDist }
    local handle = SHAPETEST.START_EXPENSIVE_SYNCHRONOUS_SHAPE_TEST_LOS_PROBE(pCoords.x, pCoords.y, pCoords.z + 0.5, rayEnd.x, rayEnd.y, rayEnd.z, 2, ped, 7)
    local _, hit, endCoords, surfaceNorm, entityHit = SHAPETEST.GET_SHAPE_TEST_RESULT(handle)
    if hit and entityHit and entityHit ~= 0 and entityHit ~= myVeh and ENTITY.IS_ENTITY_A_VEHICLE(entityHit) then
        return entityHit
    end
    return nil
end

local function getAllNearbyVehicles(radius)
    radius = radius or 90.0
    local foundVehicles = {}
    local addedMap = {}
    local ped = getLocalPed()
    if not isValidEntity(ped) then return foundVehicles end
    local pCoords = ENTITY.GET_ENTITY_COORDS(ped, true)
    local myVeh = PED.GET_VEHICLE_PED_IS_IN(ped, false)

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
                        if math.sqrt(dx*dx + dy*dy + dz*dz) <= radius and not addedMap[v] then
                            addedMap[v] = true
                            table.insert(foundVehicles, v)
                        end
                    end
                end
            end
        end
    end)

    if #foundVehicles == 0 then
        local radii = { 8.0, 20.0, 40.0, 65.0, radius }
        for _, r in ipairs(radii) do
            local steps = math.max(8, math.floor(r / 3.5))
            for a = 0, steps - 1 do
                local angle = (a / steps) * (math.pi * 2)
                local sx = pCoords.x + math.cos(angle) * r
                local sy = pCoords.y + math.sin(angle) * r
                local veh = VEHICLE.GET_CLOSEST_VEHICLE(sx, sy, pCoords.z, 16.0, 0, 71)
                if not isValidEntity(veh) then veh = VEHICLE.GET_CLOSEST_VEHICLE(sx, sy, pCoords.z, 16.0, 0, 0) end
                if isValidEntity(veh) and veh ~= myVeh and not addedMap[veh] then
                    addedMap[veh] = true
                    table.insert(foundVehicles, veh)
                end
            end
        end
    end
    return foundVehicles
end

------------------------------------------------------------
-- TELEKINESIS & VEHICLE CONTROL ACTIONS
------------------------------------------------------------

local function LiftVehicle(veh, height)
    if not isValidEntity(veh) then return end
    height = height or S.liftHeight
    getControlOfEntity(veh)
    if S.makeInvincible then safeSetInvincible(veh, true) end
    pcall(function()
        ENTITY.SET_ENTITY_COLLISION(veh, true, true)
        local curVel = ENTITY.GET_ENTITY_VELOCITY(veh)
        ENTITY.SET_ENTITY_VELOCITY(veh, curVel.x, curVel.y, height * 1.5)
    end)
end

local function LaunchVehicle(veh, force)
    if not isValidEntity(veh) then return end
    getControlOfEntity(veh)
    pcall(function()
        detachVehicle(veh)
        safeSetInvincible(veh, false)
        ENTITY.SET_ENTITY_COLLISION(veh, true, true)
        if ENTITY.SET_ENTITY_DYNAMIC then ENTITY.SET_ENTITY_DYNAMIC(veh, true) end

        local camDir = getCameraDirection()
        local vx = camDir.x * (force or S.launchForce)
        local vy = camDir.y * (force or S.launchForce)
        local vz = camDir.z * (force or S.launchForce) + 15.0

        if S.igniteOnLaunch then
            local vCoords = ENTITY.GET_ENTITY_COORDS(veh, true)
            FIRE.ADD_EXPLOSION(vCoords.x, vCoords.y, vCoords.z, 3, 1.0, true, false, 0.0, false)
        end

        ENTITY.SET_ENTITY_VELOCITY(veh, vx, vy, vz)
        ENTITY.SET_ENTITY_ANGULAR_VELOCITY(veh, 10.0, 5.0, 0.0)
    end)
end

local function SlamVehicle(veh)
    if not isValidEntity(veh) then return end
    getControlOfEntity(veh)
    pcall(function()
        ENTITY.SET_ENTITY_COLLISION(veh, true, true)
        if ENTITY.SET_ENTITY_DYNAMIC then ENTITY.SET_ENTITY_DYNAMIC(veh, true) end
        ENTITY.SET_ENTITY_VELOCITY(veh, 0.0, 0.0, -150.0)
    end)
end

local function HoldVehicleLoop(veh)
    if S.isHoldingVehicle then
        S.isHoldingVehicle = false
        if isValidEntity(S.heldVehicle) then
            detachVehicle(S.heldVehicle)
            safeSetInvincible(S.heldVehicle, false)
            pcall(function() ENTITY.SET_ENTITY_VELOCITY(S.heldVehicle, 0.0, 0.0, -2.0) end)
        end
        S.heldVehicle = nil
        stopCarryAnim()
        notify.info("Telecinese", "Veiculo solto.")
        return
    end

    if not isValidEntity(veh) then veh = getTargetVehicle(30.0) end
    if not isValidEntity(veh) then
        notify.warn("Telecinese", "Nenhum veiculo proximo encontrado para segurar!")
        return
    end

    S.isHoldingVehicle = true
    S.heldVehicle = veh
    notify.success("Telecinese", "Veiculo pego acima da cabeca! [ESPACO] Lancar | [E] Soltar.")

    script.run_in_callback(function()
        playCarryAnim()
        getControlOfEntity(S.heldVehicle)
        local ped = getLocalPed()

        pcall(function()
            ENTITY.SET_ENTITY_COLLISION(S.heldVehicle, true, true)
            if ENTITY.SET_ENTITY_NO_COLLISION_ENTITY then ENTITY.SET_ENTITY_NO_COLLISION_ENTITY(S.heldVehicle, ped, false) end
        end)

        if S.makeInvincible then safeSetInvincible(S.heldVehicle, true) end

        while S.isHoldingVehicle and isValidEntity(S.heldVehicle) do
            getControlOfEntity(S.heldVehicle)
            local pCoords = ENTITY.GET_ENTITY_COORDS(ped, true)
            local pHeading = ENTITY.GET_ENTITY_HEADING(ped)
            local rad = math.rad(pHeading)
            local dirX = -math.sin(rad)
            local dirY =  math.cos(rad)
            local targetX = pCoords.x + (dirX * 0.1)
            local targetY = pCoords.y + (dirY * 0.1)
            local targetZ = pCoords.z + 1.25

            pcall(function()
                ENTITY.SET_ENTITY_COORDS_NO_OFFSET(S.heldVehicle, targetX, targetY, targetZ, true, true, true)
                ENTITY.SET_ENTITY_HEADING(S.heldVehicle, pHeading)
                ENTITY.SET_ENTITY_VELOCITY(S.heldVehicle, 0.0, 0.0, 0.0)
                ENTITY.SET_ENTITY_ANGULAR_VELOCITY(S.heldVehicle, 0.0, 0.0, 0.0)
            end)

            drawText3D(pCoords.x, pCoords.y, targetZ + 1.15, "~g~[SPACE]~w~ Lancar  |  ~r~[E]~w~ Soltar")

            pcall(function()
                if S.activeAnimDict and S.activeAnimName and not PED.IS_ENTITY_PLAYING_ANIM(ped, S.activeAnimDict, S.activeAnimName, 3) then
                    safePlayAnim(ped, S.activeAnimDict, S.activeAnimName, 49)
                end
                if PAD then
                    PAD.DISABLE_CONTROL_ACTION(0, 22, true)
                    PAD.DISABLE_CONTROL_ACTION(0, 38, true)
                    PAD.DISABLE_CONTROL_ACTION(0, 51, true)
                    PAD.DISABLE_CONTROL_ACTION(0, 86, true)
                end
            end)

            local pressLaunch = false
            local pressRelease = false

            pcall(function()
                if PAD then
                    if (PAD.IS_DISABLED_CONTROL_JUST_PRESSED and PAD.IS_DISABLED_CONTROL_JUST_PRESSED(0, 22)) or
                       (PAD.IS_CONTROL_JUST_PRESSED and PAD.IS_CONTROL_JUST_PRESSED(0, 22)) then
                        pressLaunch = true
                    end
                    if (PAD.IS_DISABLED_CONTROL_JUST_PRESSED and (PAD.IS_DISABLED_CONTROL_JUST_PRESSED(0, 38) or PAD.IS_DISABLED_CONTROL_JUST_PRESSED(0, 51))) or
                       (PAD.IS_CONTROL_JUST_PRESSED and (PAD.IS_CONTROL_JUST_PRESSED(0, 38) or PAD.IS_CONTROL_JUST_PRESSED(0, 51))) then
                        pressRelease = true
                    end
                end
            end)

            if pressLaunch then
                local target = S.heldVehicle
                S.isHoldingVehicle = false
                S.heldVehicle = nil
                LaunchVehicle(target, S.launchForce)
                notify.success("Telecinese", "Veiculo LANCADO!")
                break
            end

            if pressRelease then
                local target = S.heldVehicle
                S.isHoldingVehicle = false
                S.heldVehicle = nil
                detachVehicle(target)
                safeSetInvincible(target, false)
                notify.info("Telecinese", "Veiculo solto.")
                break
            end

            script.yield(0)
        end

        S.isHoldingVehicle = false
        S.heldVehicle = nil
        stopCarryAnim()
    end)
end

local function getTargetPlayerPed(maxDist)
    maxDist = maxDist or 20.0
    local ped = getLocalPed()
    if not isValidEntity(ped) then return nil end
    local pCoords = ENTITY.GET_ENTITY_COORDS(ped, true)
    local bestPed = nil
    local bestDist = maxDist

    for _, pid in ipairs(getActivePlayersList()) do
        if pid ~= getLocalPid() then
            local tPed = getPlayerPed(pid)
            if isValidEntity(tPed) then
                local tc = ENTITY.GET_ENTITY_COORDS(tPed, true)
                local dx, dy, dz = pCoords.x - tc.x, pCoords.y - tc.y, pCoords.z - tc.z
                local dist = math.sqrt(dx*dx + dy*dy + dz*dz)
                if dist < bestDist then
                    bestDist = dist
                    bestPed = tPed
                end
            end
        end
    end
    return bestPed
end

local function stopCarryingPlayer()
    S.isCarryingPlayer = false
    if isValidEntity(S.carriedPlayerPed) then
        pcall(function()
            if ENTITY.IS_ENTITY_ATTACHED(S.carriedPlayerPed) then ENTITY.DETACH_ENTITY(S.carriedPlayerPed, true, true) end
            ENTITY.SET_ENTITY_COLLISION(S.carriedPlayerPed, true, true)
            TASK.CLEAR_PED_TASKS(S.carriedPlayerPed)
        end)
    end
    S.carriedPlayerPed = nil
    pcall(function() TASK.CLEAR_PED_TASKS(getLocalPed()) end)
    notify.info("Telecinese", "Jogador solto do colo.")
end

local function startCarryingPlayer(targetPed)
    if S.isCarryingPlayer then stopCarryingPlayer() return end
    if not isValidEntity(targetPed) then targetPed = getTargetPlayerPed(15.0) end
    if not isValidEntity(targetPed) then
        notify.warn("Telecinese", "Nenhum jogador proximo para carregar no colo.")
        return
    end

    S.carriedPlayerPed = targetPed
    S.isCarryingPlayer = true
    getControlOfEntity(S.carriedPlayerPed)

    script.run_in_callback(function()
        local myPed = getLocalPed()
        pcall(function()
            ENTITY.ATTACH_ENTITY_TO_ENTITY(S.carriedPlayerPed, myPed, 0, 0.0, 0.55, 0.35, 0.0, 0.0, 0.0, false, false, false, false, 2, true)
        end)
        notify.success("Telecinese", "Carregando jogador no colo! Pressione [E] para Soltar.")

        while S.isCarryingPlayer and isValidEntity(S.carriedPlayerPed) do
            myPed = getLocalPed()
            local myPos = ENTITY.GET_ENTITY_COORDS(myPed, true)
            drawText3D(myPos.x, myPos.y, myPos.z + 1.15, "~r~[E]~w~ Soltar Jogador do Colo")

            pcall(function()
                if PAD then
                    PAD.DISABLE_CONTROL_ACTION(0, 38, true)
                    PAD.DISABLE_CONTROL_ACTION(0, 51, true)
                end
            end)

            local pressDrop = false
            pcall(function()
                if PAD then
                    if (PAD.IS_DISABLED_CONTROL_JUST_PRESSED and (PAD.IS_DISABLED_CONTROL_JUST_PRESSED(0, 38) or PAD.IS_DISABLED_CONTROL_JUST_PRESSED(0, 51))) or
                       (PAD.IS_CONTROL_JUST_PRESSED and (PAD.IS_CONTROL_JUST_PRESSED(0, 38) or PAD.IS_CONTROL_JUST_PRESSED(0, 51))) then
                        pressDrop = true
                    end
                end
            end)

            if pressDrop then stopCarryingPlayer() break end
            script.yield(0)
        end
        stopCarryingPlayer()
    end)
end

------------------------------------------------------------
-- CONTINUOUS CHAOS LOOPS
------------------------------------------------------------

local function startSpinPlayerVehLoop()
    if S.spinPlayerVehLoopActive then return end
    S.spinPlayerVehLoopActive = true

    script.run_in_callback(function()
        notify.info("SpyreX", "Player Vehicle Beyblade ATIVADO!")
        local initialPed = getLocalPed()
        local initialVeh = PED.GET_VEHICLE_PED_IS_IN(initialPed, false)
        if isValidEntity(initialVeh) then S.spinPlayerTargetVeh = initialVeh end

        while S.spinPlayerVehActive do
            pcall(function()
                local playerPed = getLocalPed()
                if not isValidEntity(S.spinPlayerTargetVeh) then
                    local veh = PED.GET_VEHICLE_PED_IS_IN(playerPed, false)
                    if isValidEntity(veh) then S.spinPlayerTargetVeh = veh end
                end

                if isValidEntity(S.spinPlayerTargetVeh) then
                    getControlOfEntity(S.spinPlayerTargetVeh)
                    safeSetInvincible(S.spinPlayerTargetVeh, true)
                    ENTITY.SET_ENTITY_COLLISION(S.spinPlayerTargetVeh, true, true)
                    local vel = ENTITY.GET_ENTITY_VELOCITY(S.spinPlayerTargetVeh)
                    local vz = (vel.z > 1.5) and (vel.z * 0.5) or 0.0
                    ENTITY.SET_ENTITY_VELOCITY(S.spinPlayerTargetVeh, vel.x * 0.85, vel.y * 0.85, vz)
                    ENTITY.SET_ENTITY_ANGULAR_VELOCITY(S.spinPlayerTargetVeh, 0.0, 0.0, 55.0)
                end
            end)
            script.yield(10)
        end

        if isValidEntity(S.spinPlayerTargetVeh) then
            safeSetInvincible(S.spinPlayerTargetVeh, false)
            pcall(function() ENTITY.SET_ENTITY_ANGULAR_VELOCITY(S.spinPlayerTargetVeh, 0.0, 0.0, 0.0) end)
        end
        S.spinPlayerTargetVeh = nil
        S.spinPlayerVehLoopActive = false
        S.spinPlayerVehActive = false
        notify.info("SpyreX", "Player Vehicle Beyblade DESATIVADO.")
    end)
end

local function startSpinAreaVehsLoop()
    if S.spinAreaVehsLoopActive then return end
    S.spinAreaVehsLoopActive = true

    script.run_in_callback(function()
        notify.info("SpyreX", "Area Vehicle Beyblade ATIVADO!")
        while S.spinAreaVehsActive do
            pcall(function()
                local myVeh = PED.GET_VEHICLE_PED_IS_IN(getLocalPed(), false)
                for _, veh in ipairs(getAllNearbyVehicles(100.0)) do
                    if isValidEntity(veh) and veh ~= myVeh then
                        getControlOfEntity(veh)
                        safeSetInvincible(veh, true)
                        ENTITY.SET_ENTITY_COLLISION(veh, true, true)
                        local vel = ENTITY.GET_ENTITY_VELOCITY(veh)
                        local vz = (vel.z > 2.0) and (vel.z * 0.5) or 0.0
                        ENTITY.SET_ENTITY_VELOCITY(veh, vel.x * 0.85, vel.y * 0.85, vz)
                        ENTITY.SET_ENTITY_ANGULAR_VELOCITY(veh, 0.0, 0.0, 50.0)
                    end
                end
            end)
            script.yield(15)
        end
        S.spinAreaVehsLoopActive = false
        S.spinAreaVehsActive = false
        notify.info("SpyreX", "Area Vehicle Beyblade DESATIVADO.")
    end)
end

local function startInfiniteLevitateLoop()
    if S.infiniteLevitateLoopActive then return end
    S.infiniteLevitateLoopActive = true

    script.run_in_callback(function()
        notify.info("SpyreX", "Area Bounce Mode ATIVADO!")
        local bounceUp = true
        local tick = 0

        while S.infiniteLevitateActive do
            tick = tick + 1
            if tick % 25 == 0 then bounceUp = not bounceUp end
            pcall(function()
                local myVeh = PED.GET_VEHICLE_PED_IS_IN(getLocalPed(), false)
                for _, veh in ipairs(getAllNearbyVehicles(100.0)) do
                    if isValidEntity(veh) and veh ~= myVeh then
                        getControlOfEntity(veh)
                        safeSetInvincible(veh, true)
                        ENTITY.SET_ENTITY_VELOCITY(veh, 0.0, 0.0, bounceUp and 12.0 or -8.0)
                    end
                end
            end)
            script.yield(20)
        end
        S.infiniteLevitateLoopActive = false
        S.infiniteLevitateActive = false
        notify.info("SpyreX", "Area Bounce Mode DESATIVADO.")
    end)
end

local function startVortexLoop()
    if S.vortexLoopActive then return end
    S.vortexLoopActive = true

    script.run_in_callback(function()
        notify.info("SpyreX", "Vortice Gravitacional ATIVADO!")
        local angleOffset = 0.0

        while S.vortexActive do
            pcall(function()
                local ped = getLocalPed()
                local pCoords = ENTITY.GET_ENTITY_COORDS(ped, true)
                local myVeh = PED.GET_VEHICLE_PED_IS_IN(ped, false)
                angleOffset = (angleOffset + 0.08) % (math.pi * 2)

                for _, veh in ipairs(getAllNearbyVehicles(120.0)) do
                    if isValidEntity(veh) and veh ~= myVeh then
                        getControlOfEntity(veh)
                        safeSetInvincible(veh, true)
                        local vCoords = ENTITY.GET_ENTITY_COORDS(veh, true)
                        local dx, dy, dz = pCoords.x - vCoords.x, pCoords.y - vCoords.y, (pCoords.z + 6.0) - vCoords.z
                        local dist = math.sqrt(dx*dx + dy*dy + dz*dz)
                        if dist > 2.0 and dist < 120.0 then
                            local force = 45.0
                            local nx = (dx / dist) * force - (dy / dist) * 15.0
                            local ny = (dy / dist) * force + (dx / dist) * 15.0
                            local nz = (dz / dist) * force + 8.0
                            ENTITY.SET_ENTITY_VELOCITY(veh, nx, ny, nz)
                            ENTITY.SET_ENTITY_ANGULAR_VELOCITY(veh, 5.0, 5.0, 20.0)
                        end
                    end
                end
            end)
            script.yield(25)
        end
        S.vortexLoopActive = false
        S.vortexActive = false
        notify.info("SpyreX", "Vortice Gravitacional DESATIVADO.")
    end)
end

local function startUfoDiscoLoop()
    if S.ufoDiscoLoopActive then return end
    S.ufoDiscoLoopActive = true

    script.run_in_callback(function()
        notify.info("SpyreX", "UFO Party Mode ATIVADO!")
        while S.ufoDiscoActive do
            pcall(function()
                local ped = getLocalPed()
                local pCoords = ENTITY.GET_ENTITY_COORDS(ped, true)
                local myVeh = PED.GET_VEHICLE_PED_IS_IN(ped, false)

                for _, veh in ipairs(getAllNearbyVehicles(90.0)) do
                    if isValidEntity(veh) and veh ~= myVeh then
                        getControlOfEntity(veh)
                        safeSetInvincible(veh, true)
                        local vCoords = ENTITY.GET_ENTITY_COORDS(veh, true)
                        if (vCoords.z - pCoords.z) < 10.0 then ENTITY.SET_ENTITY_VELOCITY(veh, 0.0, 0.0, 6.0)
                        else ENTITY.SET_ENTITY_VELOCITY(veh, 0.0, 0.0, 0.5) end
                        ENTITY.SET_ENTITY_ANGULAR_VELOCITY(veh, 0.0, 0.0, 25.0)
                        VEHICLE.SET_VEHICLE_SIREN(veh, true)
                        VEHICLE.SET_VEHICLE_LIGHTS(veh, 3)

                        local r, g, b = math.random(0, 255), math.random(0, 255), math.random(0, 255)
                        if VEHICLE.SET_VEHICLE_CUSTOM_PRIMARY_COLOUR then VEHICLE.SET_VEHICLE_CUSTOM_PRIMARY_COLOUR(veh, r, g, b) end
                        if VEHICLE.SET_VEHICLE_CUSTOM_SECONDARY_COLOUR then VEHICLE.SET_VEHICLE_CUSTOM_SECONDARY_COLOUR(veh, 255 - r, 255 - g, 255 - b) end
                    end
                end
            end)
            script.yield(40)
        end
        S.ufoDiscoLoopActive = false
        S.ufoDiscoActive = false
        notify.info("SpyreX", "UFO Party Mode DESATIVADO.")
    end)
end

local function startPushRepulsorLoop()
    if S.pushRepulsorLoopActive then return end
    S.pushRepulsorLoopActive = true

    script.run_in_callback(function()
        notify.info("SpyreX", "Onda de Choque / Repulsor ATIVADO!")
        while S.pushRepulsorActive do
            pcall(function()
                local pCoords = ENTITY.GET_ENTITY_COORDS(getLocalPed(), true)
                for _, veh in ipairs(getAllNearbyVehicles(30.0)) do
                    if isValidEntity(veh) then
                        local vCoords = ENTITY.GET_ENTITY_COORDS(veh, true)
                        local dx, dy, dz = vCoords.x - pCoords.x, vCoords.y - pCoords.y, vCoords.z - pCoords.z
                        local dist = math.sqrt(dx*dx + dy*dy + dz*dz)
                        if dist < 22.0 and dist > 1.0 then
                            getControlOfEntity(veh)
                            ENTITY.SET_ENTITY_VELOCITY(veh, (dx / dist) * 90.0, (dy / dist) * 90.0, 15.0)
                        end
                    end
                end
            end)
            script.yield(80)
        end
        S.pushRepulsorLoopActive = false
        S.pushRepulsorActive = false
        notify.info("SpyreX", "Repulsor DESATIVADO.")
    end)
end

local function startVehicleRainLoop()
    if S.vehicleRainLoopActive then return end
    S.vehicleRainLoopActive = true

    script.run_in_callback(function()
        notify.info("SpyreX", "Chuva de Veiculos do Ceu ATIVADA!")
        local models = { "blista", "futo", "adder", "insurgent", "zentorno", "bus" }

        while S.vehicleRainActive do
            pcall(function()
                local pCoords = ENTITY.GET_ENTITY_COORDS(getLocalPed(), true)
                local rx = pCoords.x + math.random(-45, 45)
                local ry = pCoords.y + math.random(-45, 45)
                local rz = pCoords.z + math.random(35, 60)
                local hash = getHash(models[math.random(#models)])

                STREAMING.REQUEST_MODEL(hash)
                if STREAMING.HAS_MODEL_LOADED(hash) then
                    local v = VEHICLE.CREATE_VEHICLE(hash, rx, ry, rz, math.random(0, 360), true, false, false)
                    if isValidEntity(v) then ENTITY.SET_ENTITY_VELOCITY(v, 0.0, 0.0, -35.0) end
                end
            end)
            script.yield(400)
        end
        S.vehicleRainLoopActive = false
        S.vehicleRainActive = false
        notify.info("SpyreX", "Chuva de Veiculos DESATIVADA.")
    end)
end

local function startVehicleShieldLoop()
    if S.vehicleShieldLoopActive then return end
    S.vehicleShieldLoopActive = true

    script.run_in_callback(function()
        notify.info("SpyreX", "Escudo Orbital de Blindados ATIVADO!")
        local pCoords = ENTITY.GET_ENTITY_COORDS(getLocalPed(), true)
        local shieldVehs = {}
        local models = { "kuruma", "zentorno", "adder", "nero", "t20", "turismor" }

        for i = 1, 6 do
            local hash = getHash(models[i])
            STREAMING.REQUEST_MODEL(hash)
            local timeout = 0
            while not STREAMING.HAS_MODEL_LOADED(hash) and timeout < 20 do script.yield(10); timeout = timeout + 1 end
            local v = VEHICLE.CREATE_VEHICLE(hash, pCoords.x, pCoords.y, pCoords.z + 10.0, 0.0, true, false, false)
            if isValidEntity(v) then
                ENTITY.SET_ENTITY_INVINCIBLE(v, true)
                ENTITY.SET_ENTITY_COLLISION(v, true, true)
                table.insert(shieldVehs, v)
            end
        end

        local angle = 0.0
        while S.vehicleShieldActive do
            pcall(function()
                local curCoords = ENTITY.GET_ENTITY_COORDS(getLocalPed(), true)
                angle = angle + 0.08
                for idx, v in ipairs(shieldVehs) do
                    if isValidEntity(v) then
                        local offsetAngle = angle + (idx * (math.pi * 2 / #shieldVehs))
                        ENTITY.SET_ENTITY_COORDS_NO_OFFSET(v, curCoords.x + math.cos(offsetAngle) * 7.5, curCoords.y + math.sin(offsetAngle) * 7.5, curCoords.z + 1.2, false, false, false)
                        ENTITY.SET_ENTITY_HEADING(v, math.deg(offsetAngle) + 90.0)
                    end
                end
            end)
            script.yield(15)
        end

        for _, v in ipairs(shieldVehs) do if isValidEntity(v) then safeDeleteEntity(v) end end
        S.vehicleShieldLoopActive = false
        S.vehicleShieldActive = false
        notify.info("SpyreX", "Escudo Orbital DESATIVADO.")
    end)
end

local function setupBusBowling()
    script.run_in_callback(function()
        notify.info("SpyreX", "Criando Boliche Vertical de Onibus...")
        local pCoords = ENTITY.GET_ENTITY_COORDS(getLocalPed(), true)
        local fwd = getCameraDirection()
        local busHash, pantoHash = getHash("bus"), getHash("panto")

        STREAMING.REQUEST_MODEL(busHash)
        STREAMING.REQUEST_MODEL(pantoHash)
        local timeout = 0
        while (not STREAMING.HAS_MODEL_LOADED(busHash) or not STREAMING.HAS_MODEL_LOADED(pantoHash)) and timeout < 30 do
            script.yield(10); timeout = timeout + 1
        end

        for i = 1, 6 do
            local bx = pCoords.x + fwd.x * (25.0 + i * 4.0) + (i % 2 == 0 and 2.5 or -2.5)
            local by = pCoords.y + fwd.y * (25.0 + i * 4.0)
            local bVeh = VEHICLE.CREATE_VEHICLE(busHash, bx, by, pCoords.z + 0.5, 0.0, true, false, false)
            if isValidEntity(bVeh) then ENTITY.SET_ENTITY_ROTATION(bVeh, 90.0, 0.0, 0.0, 2, true) end
        end

        local panto = VEHICLE.CREATE_VEHICLE(pantoHash, pCoords.x + fwd.x * 6.0, pCoords.y + fwd.y * 6.0, pCoords.z + 0.5, 0.0, true, false, false)
        if isValidEntity(panto) then
            safeSetInvincible(panto, true)
            ENTITY.SET_ENTITY_VELOCITY(panto, fwd.x * 120.0, fwd.y * 120.0, 5.0)
        end
        notify.success("SpyreX", "Boliche de Onibus Lancado!")
    end)
end

local function triggerBusFortressWall()
    script.run_in_callback(function()
        notify.info("SpyreX", "Construindo Muralha Fortaleza de Onibus...")
        local pCoords = ENTITY.GET_ENTITY_COORDS(getLocalPed(), true)
        local busHash = getHash("bus")
        STREAMING.REQUEST_MODEL(busHash)
        local timeout = 0
        while not STREAMING.HAS_MODEL_LOADED(busHash) and timeout < 25 do script.yield(10); timeout = timeout + 1 end

        for i = -4, 4 do
            local bVeh = VEHICLE.CREATE_VEHICLE(busHash, pCoords.x + (i * 3.8), pCoords.y + 12.0, pCoords.z + 0.5, 0.0, true, false, false)
            if isValidEntity(bVeh) then ENTITY.FREEZE_ENTITY_POSITION(bVeh, true) end
        end
        notify.success("SpyreX", "Fortaleza de Onibus Concluida!")
    end)
end

local function startVehicleSnakeLoop()
    if S.vehicleSnakeLoopActive then return end
    S.vehicleSnakeLoopActive = true

    script.run_in_callback(function()
        notify.info("SpyreX", "Follow the Leader (Cobra de Veiculos) ATIVADO!")
        while S.vehicleSnakeActive do
            pcall(function()
                local pCoords = ENTITY.GET_ENTITY_COORDS(getLocalPed(), true)
                local forward = getCameraDirection()
                for idx, veh in ipairs(getAllNearbyVehicles(70.0)) do
                    if isValidEntity(veh) then
                        getControlOfEntity(veh)
                        local vCoords = ENTITY.GET_ENTITY_COORDS(veh, true)
                        local tx = pCoords.x - forward.x * (idx * 6.0)
                        local ty = pCoords.y - forward.y * (idx * 6.0)
                        local dx, dy = tx - vCoords.x, ty - vCoords.y
                        local dist = math.sqrt(dx*dx + dy*dy)
                        if dist > 1.5 then
                            local speed = math.min(dist * 6.0, 45.0)
                            ENTITY.SET_ENTITY_VELOCITY(veh, (dx/dist) * speed, (dy/dist) * speed, 0.0)
                        end
                    end
                end
            end)
            script.yield(40)
        end
        S.vehicleSnakeLoopActive = false
        S.vehicleSnakeActive = false
        notify.info("SpyreX", "Follow the Leader DESATIVADO.")
    end)
end

local function startZombiePedOutbreakLoop()
    if S.zombiePedOutbreakLoopActive then return end
    S.zombiePedOutbreakLoopActive = true

    script.run_in_callback(function()
        notify.info("SpyreX", "Apocalipse Zumbi Iniciado!")
        local ped = getLocalPed()
        local pCoords = ENTITY.GET_ENTITY_COORDS(ped, true)
        local zModels = { "u_m_y_zombie_01", "s_m_y_clown_01", "a_m_m_hillbilly_01" }

        for i = 1, 10 do
            local hash = getHash(zModels[math.random(#zModels)])
            STREAMING.REQUEST_MODEL(hash)
            local timeout = 0
            while not STREAMING.HAS_MODEL_LOADED(hash) and timeout < 20 do script.yield(10); timeout = timeout + 1 end
            local zPed = PED.CREATE_PED(26, hash, pCoords.x + math.random(-25, 25), pCoords.y + math.random(-25, 25), pCoords.z + 1.0, 0.0, true, false)
            if isValidEntity(zPed) then
                getControlOfEntity(zPed)
                pcall(function()
                    TASK.CLEAR_PED_TASKS_IMMEDIATELY(zPed)
                    PED.SET_BLOCKING_OF_NON_TEMPORARY_EVENTS(zPed, true)
                    PED.SET_PED_CAN_RAGDOLL(zPed, true)
                    PED.SET_PED_COMBAT_ABILITY(zPed, 2)
                    PED.SET_PED_COMBAT_RANGE(zPed, 2)
                    PED.SET_PED_COMBAT_MOVEMENT(zPed, 3)
                    local playerGroup = PED.GET_PED_RELATIONSHIP_GROUP_HASH(ped)
                    local zGroup = getHash("HATES_PLAYER")
                    PED.SET_PED_RELATIONSHIP_GROUP_HASH(zPed, zGroup)
                    PED.SET_RELATIONSHIP_BETWEEN_GROUPS(5, zGroup, playerGroup)
                    PED.SET_RELATIONSHIP_BETWEEN_GROUPS(5, playerGroup, zGroup)
                    local wHash = getHash("WEAPON_BATTLEAXE")
                    WEAPON.GIVE_DELAYED_WEAPON_TO_PED(zPed, wHash, 100, true)
                    WEAPON.SET_CURRENT_PED_WEAPON(zPed, wHash, true)
                    TASK.TASK_COMBAT_PED(zPed, ped, 0, 16)
                end)
            end
        end

        while S.zombiePedOutbreakActive do script.yield(500) end
        S.zombiePedOutbreakLoopActive = false
        S.zombiePedOutbreakActive = false
        notify.info("SpyreX", "Apocalipse Zumbi Finalizado.")
    end)
end

local function startHotkeyLoop()
    if S.hotkeyLoopActive then return end
    S.hotkeyLoopActive = true

    script.run_in_callback(function()
        local cachedTargetVeh = nil
        local lastSearchTime = 0

        while S.hotkeysEnabled do
            pcall(function()
                local ped = getLocalPed()

                if not S.isHoldingVehicle and isValidEntity(ped) and not PED.IS_PED_IN_ANY_VEHICLE(ped, false) then
                    local now = gameTimer()
                    if (now - lastSearchTime) > 100 then
                        lastSearchTime = now
                        cachedTargetVeh = getTargetVehicle(25.0)
                    end

                    if isValidEntity(cachedTargetVeh) then
                        local pCoords = ENTITY.GET_ENTITY_COORDS(ped, true)
                        drawText3D(pCoords.x, pCoords.y, pCoords.z + 1.15, "Pressione ~g~[E]~w~ para Pegar Veiculo")

                        pcall(function()
                            if PAD then
                                PAD.DISABLE_CONTROL_ACTION(0, 38, true)
                                PAD.DISABLE_CONTROL_ACTION(0, 51, true)
                                PAD.DISABLE_CONTROL_ACTION(0, 86, true)
                            end
                        end)

                        local pressedE = false
                        pcall(function()
                            if PAD then
                                if (PAD.IS_DISABLED_CONTROL_JUST_PRESSED and (PAD.IS_DISABLED_CONTROL_JUST_PRESSED(0, 38) or PAD.IS_DISABLED_CONTROL_JUST_PRESSED(0, 51))) or
                                   (PAD.IS_CONTROL_JUST_PRESSED and (PAD.IS_CONTROL_JUST_PRESSED(0, 38) or PAD.IS_CONTROL_JUST_PRESSED(0, 51))) then
                                    pressedE = true
                                end
                            end
                        end)

                        if pressedE then
                            local targetToHold = cachedTargetVeh
                            cachedTargetVeh = nil
                            HoldVehicleLoop(targetToHold)
                        end
                    end
                end

                if S.disableRagdoll then updateRagdollState() end
            end)
            script.yield(10)
        end
        S.hotkeyLoopActive = false
    end)
end

startHotkeyLoop()

------------------------------------------------------------
-- INCEPTION STUNT TRACKS & ARENA PROPS STATE & LOGIC
------------------------------------------------------------

local function safeCreateStuntProp(hash, x, y, z, dynamic)
    local isDyn = (dynamic == true)
    local obj = 0
    pcall(function()
        if OBJECT and OBJECT.CREATE_OBJECT_NO_OFFSET then obj = OBJECT.CREATE_OBJECT_NO_OFFSET(hash, x, y, z, true, true, isDyn) end
    end)
    if not obj or obj == 0 or not isValidEntity(obj) then
        pcall(function()
            if OBJECT and OBJECT.CREATE_OBJECT then obj = OBJECT.CREATE_OBJECT(hash, x, y, z, true, true, isDyn) end
        end)
    end
    if not obj or obj == 0 or not isValidEntity(obj) then
        pcall(function()
            if entities and entities.create_object then obj = entities.create_object(hash, { x = x, y = y, z = z }) end
        end)
    end
    if isValidEntity(obj) then
        pcall(function()
            ENTITY.SET_ENTITY_VISIBLE(obj, true, false)
            if ENTITY.SET_ENTITY_LOD_DIST then ENTITY.SET_ENTITY_LOD_DIST(obj, 0xFFFF) end
            
            -- Requisita colisao da malha 3D nas coordenadas para solidez imediata
            if STREAMING and STREAMING.REQUEST_COLLISION_AT_COORD then
                STREAMING.REQUEST_COLLISION_AT_COORD(x, y, z)
            end

            if not isDyn then
                ENTITY.FREEZE_ENTITY_POSITION(obj, true)
                if ENTITY.SET_ENTITY_DYNAMIC then ENTITY.SET_ENTITY_DYNAMIC(obj, false) end
                ENTITY.SET_ENTITY_COLLISION(obj, true, true)
                if ENTITY.SET_ENTITY_CAN_BE_DAMAGED then ENTITY.SET_ENTITY_CAN_BE_DAMAGED(obj, false) end
                if ENTITY.SET_ENTITY_INVINCIBLE then ENTITY.SET_ENTITY_INVINCIBLE(obj, true) end
                if ENTITY.SET_ENTITY_SHOULD_FREEZE_WAITING_ON_COLLISION then
                    ENTITY.SET_ENTITY_SHOULD_FREEZE_WAITING_ON_COLLISION(obj, true)
                end
            else
                ENTITY.FREEZE_ENTITY_POSITION(obj, false)
                if ENTITY.SET_ENTITY_DYNAMIC then ENTITY.SET_ENTITY_DYNAMIC(obj, true) end
                ENTITY.SET_ENTITY_COLLISION(obj, true, true)
            end

            -- Registro de Rede GTA Online com Migracao de Host/Player Habilitada
            if NETWORK then
                if NETWORK.NETWORK_REGISTER_ENTITY_AS_NETWORKED then NETWORK.NETWORK_REGISTER_ENTITY_AS_NETWORKED(obj) end
                if NETWORK.OBJ_TO_NET then
                    local netId = NETWORK.OBJ_TO_NET(obj)
                    if netId and netId ~= 0 then
                        if NETWORK.SET_NETWORK_ID_EXISTS_ON_ALL_MACHINES then NETWORK.SET_NETWORK_ID_EXISTS_ON_ALL_MACHINES(netId, true) end
                        if NETWORK.SET_NETWORK_ID_CAN_MIGRATE then NETWORK.SET_NETWORK_ID_CAN_MIGRATE(netId, true) end
                        if NETWORK.SET_NETWORK_ID_ALWAYS_EXISTS_FOR_PLAYER then NETWORK.SET_NETWORK_ID_ALWAYS_EXISTS_FOR_PLAYER(netId, -1, true) end
                    end
                end
            end

            -- Permite persistir na sessao mesmo se o criador sair da sala (desassocia do script local)
            if ENTITY.SET_ENTITY_AS_MISSION_ENTITY then
                ENTITY.SET_ENTITY_AS_MISSION_ENTITY(obj, false, true)
            end
            if ENTITY.SET_ENTITY_AS_NO_LONGER_NEEDED then
                ENTITY.SET_ENTITY_AS_NO_LONGER_NEEDED(obj)
            end
        end)
    end
    return obj
end

local function clearAllStuntObjects()
    local count = 0
    for _, obj in ipairs(S.spawned_stunt_objects) do
        if isValidEntity(obj) then
            pcall(function()
                ENTITY.SET_ENTITY_AS_MISSION_ENTITY(obj, true, true)
                ENTITY.DELETE_ENTITY(obj)
            end)
            count = count + 1
        end
    end
    S.spawned_stunt_objects = {}
    notify.info("Estruturas", string.format("Todas as %d estruturas foram removidas!", count))
end

local function undoLastStuntObject()
    if #S.spawned_stunt_objects > 0 then
        local lastObj = table.remove(S.spawned_stunt_objects)
        if isValidEntity(lastObj) then
            pcall(function()
                ENTITY.SET_ENTITY_AS_MISSION_ENTITY(lastObj, true, true)
                ENTITY.DELETE_ENTITY(lastObj)
            end)
            notify.info("Estruturas", "Ultimo objeto removido com sucesso!")
            return
        end
    end
    notify.warn("Estruturas", "Nenhum objeto recente para remover.")
end

local function spawnStuntTrack(presetList, presetName)
    if S.is_spawning_stunt then notify.warn("Estruturas", "Construcao de pista ja em andamento...") return end
    S.is_spawning_stunt = true

    script.run_in_callback(function()
        local my_ped = getLocalPed()
        local my_pos = ENTITY.GET_ENTITY_COORDS(my_ped, true)
        local center_z = my_pos.z + S.stunt_altitude
        notify.info("Estruturas", "Construindo " .. presetName .. " a " .. math.floor(S.stunt_altitude) .. "m no ceu...")
        local count = 0

        for _, item in ipairs(presetList) do
            local h = getHash(item.model)
            if h ~= 0 then
                STREAMING.REQUEST_MODEL(h)
                local t = 0
                while not STREAMING.HAS_MODEL_LOADED(h) and t < 100 do script.yield(10); t = t + 1 end
                if STREAMING.HAS_MODEL_LOADED(h) then
                    local obj = safeCreateStuntProp(h, my_pos.x + item.rel_x, my_pos.y + item.rel_y, center_z + item.rel_z)
                    if isValidEntity(obj) then
                        pcall(function()
                            ENTITY.SET_ENTITY_ROTATION(obj, 180.0, 0.0, item.yaw, 2, true)
                            ENTITY.FREEZE_ENTITY_POSITION(obj, true)
                            ENTITY.SET_ENTITY_COLLISION(obj, true, true)
                            if ENTITY.SET_ENTITY_SHOULD_FREEZE_WAITING_ON_COLLISION then
                                ENTITY.SET_ENTITY_SHOULD_FREEZE_WAITING_ON_COLLISION(obj, true)
                            end
                            if ENTITY.SET_ENTITY_AS_NO_LONGER_NEEDED then
                                ENTITY.SET_ENTITY_AS_NO_LONGER_NEEDED(obj)
                            end
                        end)
                        table.insert(S.spawned_stunt_objects, obj)
                        count = count + 1
                    end
                    STREAMING.SET_MODEL_AS_NO_LONGER_NEEDED(h)
                end
            end
            script.yield(20)
        end
        S.is_spawning_stunt = false
        notify.success("Estruturas", string.format("%s construida com sucesso! (%d Estruturas)", presetName, count))
    end)
end

local function spawnTotalSupremeChaos()
    if S.is_spawning_stunt then notify.warn("Estruturas", "Construcao de pistas ja em andamento...") return end
    S.is_spawning_stunt = true

    script.run_in_callback(function()
        local ped = getLocalPed()
        local pCoords = ENTITY.GET_ENTITY_COORDS(ped, true)
        local baseHeading = ENTITY.GET_ENTITY_HEADING(ped)
        local rad = math.rad(baseHeading)
        local cosH = math.cos(rad)
        local sinH = math.sin(rad)
        local skyZ = pCoords.z + S.stunt_altitude

        notify.info("Estruturas", "GERANDO CAOS TOTAL (TUDO: ASFALTO + CEU)...")
        local allPieces = {}

        local groundSpots = {
            { x = 0.0,   y = 20.0,   z = -0.2, yaw = baseHeading,         model = "ar_prop_ar_neon_gate8x_01a" },
            { x = 0.0,   y = 45.0,   z = -0.2, yaw = baseHeading,         model = "stt_prop_stunt_jump_l" },
            { x = 0.0,   y = 75.0,   z = 1.0,  yaw = baseHeading,         model = "ar_prop_ar_speed_ring" },
            { x = 0.0,   y = 110.0,  z = -0.2, yaw = baseHeading,         model = "ar_prop_ar_tube_4x_speed" },
            { x = 0.0,   y = 160.0,  z = 0.0,  yaw = baseHeading,         model = "stt_prop_stunt_track_dloop" },
            { x = 0.0,   y = 210.0,  z = 2.0,  yaw = baseHeading,         model = "ar_prop_ar_jump_loop" },
            { x = 0.0,   y = 270.0,  z = -0.2, yaw = baseHeading,         model = "ar_prop_ar_cp_tower8x_01a" },
            { x = 0.0,   y = -25.0,  z = -0.2, yaw = baseHeading + 180.0, model = "ar_prop_ar_neon_gate8x_02a" },
            { x = 0.0,   y = -50.0,  z = -0.2, yaw = baseHeading + 180.0, model = "stt_prop_stunt_jump_l" },
            { x = 0.0,   y = -85.0,  z = 1.0,  yaw = baseHeading + 180.0, model = "ar_prop_ar_speed_ring" },
            { x = 0.0,   y = -125.0, z = -0.2, yaw = baseHeading + 180.0, model = "ar_prop_ar_tube_4x_l" },
            { x = 0.0,   y = -175.0, z = -0.2, yaw = baseHeading + 180.0, model = "stt_prop_stunt_jump_m" },
            { x = 0.0,   y = -230.0, z = -0.2, yaw = baseHeading + 180.0, model = "ar_prop_ar_start_01a" },
            { x = 35.0,  y = 0.0,    z = -0.2, yaw = baseHeading + 90.0,  model = "ar_prop_ar_neon_gate4x_01a" },
            { x = 60.0,  y = 0.0,    z = -0.2, yaw = baseHeading + 90.0,  model = "stt_prop_stunt_jump_l" },
            { x = 95.0,  y = 0.0,    z = 1.0,  yaw = baseHeading + 90.0,  model = "ar_prop_ar_speed_ring" },
            { x = 135.0, y = 30.0,   z = -0.2, yaw = baseHeading + 45.0,  model = "stt_prop_stunt_track_dwuturn" },
            { x = 160.0, y = 0.0,    z = 0.0,  yaw = baseHeading + 90.0,  model = "ar_prop_ar_jump_loop" },
            { x = -35.0, y = 0.0,    z = -0.2, yaw = baseHeading - 90.0,  model = "ar_prop_ar_neon_gate4x_02a" },
            { x = -60.0, y = 0.0,    z = -0.2, yaw = baseHeading - 90.0,  model = "stt_prop_stunt_jump_l" },
            { x = -95.0, y = 0.0,    z = 1.0,  yaw = baseHeading - 90.0,  model = "ar_prop_ar_speed_ring" },
            { x = -135.0,y = 30.0,   z = -0.2, yaw = baseHeading - 45.0,  model = "stt_prop_stunt_track_dwuturn" },
            { x = -160.0,y = 0.0,    z = 0.0,  yaw = baseHeading - 90.0,  model = "ar_prop_ar_jump_loop" },
            { x = 50.0,  y = -50.0,  z = -0.2, yaw = baseHeading + 135.0, model = "ar_prop_ar_arrow_wide_xl" },
            { x = -50.0, y = -50.0,  z = -0.2, yaw = baseHeading - 135.0, model = "ar_prop_ar_arrow_wide_xl" },
            { x = 80.0,  y = 80.0,   z = -0.2, yaw = baseHeading + 45.0,  model = "ar_prop_ar_jetski_ramp_01_dev" },
            { x = -80.0, y = 80.0,   z = -0.2, yaw = baseHeading - 45.0,  model = "ar_prop_ar_jetski_ramp_01_dev" }
        }

        for _, spot in ipairs(groundSpots) do
            local wx = pCoords.x + (-sinH * spot.y + cosH * spot.x)
            local wy = pCoords.y + (cosH * spot.y + sinH * spot.x)
            table.insert(allPieces, { model = spot.model, x = wx, y = wy, z = pCoords.z + spot.z, pitch = 0.0, roll = 0.0, yaw = spot.yaw })
        end

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
            table.insert(allPieces, { model = item.model, x = pCoords.x + item.rel_x, y = pCoords.y + item.rel_y, z = skyZ + item.rel_z, pitch = 180.0, roll = 0.0, yaw = item.yaw })
        end

        local count = 0
        for _, piece in ipairs(allPieces) do
            local h = getHash(piece.model)
            if h ~= 0 then
                STREAMING.REQUEST_MODEL(h)
                local t = 0
                while not STREAMING.HAS_MODEL_LOADED(h) and t < 40 do script.yield(5); t = t + 1 end
                if STREAMING.HAS_MODEL_LOADED(h) then
                    local obj = safeCreateStuntProp(h, piece.x, piece.y, piece.z)
                    if isValidEntity(obj) then
                        pcall(function()
                            ENTITY.SET_ENTITY_ROTATION(obj, piece.pitch or 0.0, piece.roll or 0.0, piece.yaw or 0.0, 2, true)
                            ENTITY.FREEZE_ENTITY_POSITION(obj, true)
                            ENTITY.SET_ENTITY_COLLISION(obj, true, true)
                            if ENTITY.SET_ENTITY_SHOULD_FREEZE_WAITING_ON_COLLISION then
                                ENTITY.SET_ENTITY_SHOULD_FREEZE_WAITING_ON_COLLISION(obj, true)
                            end
                            if ENTITY.SET_ENTITY_AS_NO_LONGER_NEEDED then
                                ENTITY.SET_ENTITY_AS_NO_LONGER_NEEDED(obj)
                            end
                        end)
                        table.insert(S.spawned_stunt_objects, obj)
                        count = count + 1
                    end
                    STREAMING.SET_MODEL_AS_NO_LONGER_NEEDED(h)
                end
            end
            script.yield(10)
        end
        S.is_spawning_stunt = false
        notify.success("Estruturas", string.format("MEGA CAOS TOTAL ATIVADO! (%d Estruturas no Ceu e Asfalto)", count))
    end)
end

local function spawnInstantFrontRamp(rampModel)
    script.run_in_callback(function()
        local ped = getLocalPed()
        local my_pos = ENTITY.GET_ENTITY_COORDS(ped, true)
        local heading = ENTITY.GET_ENTITY_HEADING(ped)
        local rad = math.rad(heading)
        local rx = my_pos.x + (-math.sin(rad) * 15.0)
        local ry = my_pos.y + (math.cos(rad) * 15.0)
        local h = getHash(rampModel or "stt_prop_stunt_jump_l")

        STREAMING.REQUEST_MODEL(h)
        local t = 0
        while not STREAMING.HAS_MODEL_LOADED(h) and t < 60 do script.yield(10); t = t + 1 end
        if STREAMING.HAS_MODEL_LOADED(h) then
            local obj = safeCreateStuntProp(h, rx, ry, my_pos.z - 0.2)
            if isValidEntity(obj) then
                pcall(function()
                    ENTITY.SET_ENTITY_ROTATION(obj, 0.0, 0.0, heading, 2, true)
                    ENTITY.FREEZE_ENTITY_POSITION(obj, true)
                    ENTITY.SET_ENTITY_COLLISION(obj, true, true)
                    if ENTITY.SET_ENTITY_SHOULD_FREEZE_WAITING_ON_COLLISION then
                        ENTITY.SET_ENTITY_SHOULD_FREEZE_WAITING_ON_COLLISION(obj, true)
                    end
                    if ENTITY.SET_ENTITY_AS_NO_LONGER_NEEDED then
                        ENTITY.SET_ENTITY_AS_NO_LONGER_NEEDED(obj)
                    end
                end)
                table.insert(S.spawned_stunt_objects, obj)
                STREAMING.SET_MODEL_AS_NO_LONGER_NEEDED(h)
                notify.success("Estruturas", "Rampa acrobatica gerada a sua frente!")
            end
        end
    end)
end

local function spawnSinglePropAtPlayer(modelNameOrHash, customDist, customZ, customYaw, freeze, targetPid)
    script.run_in_callback(function()
        local myLocalPid = getLocalPid()
        local actualPid = (targetPid == nil or targetPid == -1) and myLocalPid or targetPid
        local ped = getPlayerPed(actualPid)
        if not isValidEntity(ped) then notify.warn("Props", "Jogador alvo nao encontrado!"); return end
        
        local my_pos = ENTITY.GET_ENTITY_COORDS(ped, true)
        local heading = ENTITY.GET_ENTITY_HEADING(ped)
        local rad = math.rad(heading)
        local dist = customDist or S.customSpawnDistance or 15.0
        local zOffset = customZ or S.customSpawnHeight or 0.0
        local yawOffset = customYaw or S.customSpawnYaw or 0.0
        local isFrozen = (freeze ~= nil) and freeze or S.customSpawnFreeze

        local rx = my_pos.x + (-math.sin(rad) * dist)
        local ry = my_pos.y + (math.cos(rad) * dist)
        local rz = my_pos.z + zOffset
        local h = getHash(modelNameOrHash)
        if not h or h == 0 then notify.warn("Props", "Modelo invalido: " .. tostring(modelNameOrHash)) return end

        STREAMING.REQUEST_MODEL(h)
        local t = 0
        while not STREAMING.HAS_MODEL_LOADED(h) and t < 60 do script.yield(10); t = t + 1 end
        if STREAMING.HAS_MODEL_LOADED(h) then
            local obj = safeCreateStuntProp(h, rx, ry, rz, not isFrozen)
            if isValidEntity(obj) then
                pcall(function()
                    ENTITY.SET_ENTITY_ROTATION(obj, 0.0, 0.0, heading + yawOffset, 2, true)
                    if isFrozen then
                        ENTITY.FREEZE_ENTITY_POSITION(obj, true)
                        if ENTITY.SET_ENTITY_DYNAMIC then ENTITY.SET_ENTITY_DYNAMIC(obj, false) end
                    end
                end)
                table.insert(S.spawned_stunt_objects, obj)
                STREAMING.SET_MODEL_AS_NO_LONGER_NEEDED(h)
                local pName = (actualPid == myLocalPid) and "a sua frente" or ("na frente de " .. getPlayerName(actualPid))
                notify.success("Props", string.format("Objeto [%s] gerado %s!", tostring(modelNameOrHash), pName))
            end
        end
    end)
end

------------------------------------------------------------
-- PROJETO MAZE BANK & PONTO FIXO OVNI
------------------------------------------------------------

local function spawnFixedCoordsUfo()
    script.run_in_callback(function()
        local x, y, z = -75.015, -818.215, 326.176
        local h = getHash("p_spinning_anus_s")
        if isValidEntity(S.fixedUfoObject) then
            pcall(function() ENTITY.SET_ENTITY_AS_MISSION_ENTITY(S.fixedUfoObject, true, true); ENTITY.DELETE_ENTITY(S.fixedUfoObject) end)
            S.fixedUfoObject = nil
        end
        STREAMING.REQUEST_MODEL(h)
        local t = 0
        while not STREAMING.HAS_MODEL_LOADED(h) and t < 80 do script.yield(10); t = t + 1 end
        if STREAMING.HAS_MODEL_LOADED(h) then
            local obj = safeCreateStuntProp(h, x, y, z, false)
            if isValidEntity(obj) then
                pcall(function()
                    ENTITY.FREEZE_ENTITY_POSITION(obj, true)
                    ENTITY.SET_ENTITY_COLLISION(obj, true, true)
                    ENTITY.SET_ENTITY_COORDS_NO_OFFSET(obj, x, y, z, false, false, false)
                end)
                S.fixedUfoObject = obj
                table.insert(S.spawned_stunt_objects, obj)
                STREAMING.SET_MODEL_AS_NO_LONGER_NEEDED(h)
                notify.success("OVNI", "OVNI gerado nas coordenadas [-75.015, -818.215, 326.176]!")
            end
        end
    end)
end

local function removeFixedCoordsUfo()
    if isValidEntity(S.fixedUfoObject) then
        pcall(function() ENTITY.SET_ENTITY_AS_MISSION_ENTITY(S.fixedUfoObject, true, true); ENTITY.DELETE_ENTITY(S.fixedUfoObject) end)
        S.fixedUfoObject = nil
        notify.info("OVNI", "OVNI do Ponto Fixo removido!")
    end
end

local function spawnMazeBankProject()
    script.run_in_callback(function()
        for _, b in ipairs(S.spawned_mazebank_objects) do
            if isValidEntity(b) then pcall(function() ENTITY.SET_ENTITY_AS_MISSION_ENTITY(b, true, true); ENTITY.DELETE_ENTITY(b) end) end
        end
        S.spawned_mazebank_objects = {}
        notify.info("Maze Bank", "Construindo Projeto Maze Bank...")

        for _, item in ipairs(Presets.mazeBankProps) do
            local hash = getHash(item.model)
            STREAMING.REQUEST_MODEL(hash)
            local t = 0
            while not STREAMING.HAS_MODEL_LOADED(hash) and t < 80 do script.yield(15); t = t + 1 end
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
                    end)
                    table.insert(S.spawned_mazebank_objects, obj)
                    table.insert(S.spawned_stunt_objects, obj)
                end
            end
            script.yield(20)
        end
        notify.success("Maze Bank", string.format("Projeto Maze Bank [%d objetos] gerado com sucesso!", #S.spawned_mazebank_objects))
    end)
end

local function clearMazeBankProject()
    local count = 0
    for _, b in ipairs(S.spawned_mazebank_objects) do
        if isValidEntity(b) then
            pcall(function() ENTITY.SET_ENTITY_AS_MISSION_ENTITY(b, true, true); ENTITY.DELETE_ENTITY(b) end)
            count = count + 1
        end
    end
    S.spawned_mazebank_objects = {}
    notify.info("Maze Bank", string.format("Projeto Maze Bank (%d objetos) removido do mapa!", count))
end

local function teleportAllPlayersToMazeBank()
    script.run_in_callback(function()
        local tx, ty, tz = -76.78993, -818.6607, 408.0
        local myPed = getLocalPed()
        if isValidEntity(myPed) then
            local myVeh = PED.GET_VEHICLE_PED_IS_IN(myPed, false)
            if isValidEntity(myVeh) then ENTITY.SET_ENTITY_COORDS(myVeh, tx, ty, tz + 1.0, false, false, false, true)
            else ENTITY.SET_ENTITY_COORDS(myPed, tx, ty, tz, false, false, false, true) end
        end

        local count = 0
        for _, pid in ipairs(getActivePlayersList()) do
            local ped = getPlayerPed(pid)
            if isValidEntity(ped) and ped ~= getLocalPed() then
                local px, py, pz = tx + (math.random() * 12.0 - 6.0), ty + (math.random() * 12.0 - 6.0), tz + 0.5
                local veh = PED.GET_VEHICLE_PED_IS_IN(ped, false)
                if isValidEntity(veh) then
                    getControlOfEntity(veh)
                    ENTITY.SET_ENTITY_COORDS_NO_OFFSET(veh, px, py, pz, false, false, false)
                else
                    getControlOfEntity(ped)
                    ENTITY.SET_ENTITY_COORDS_NO_OFFSET(ped, px, py, pz, false, false, false)
                    ENTITY.SET_ENTITY_COORDS(ped, px, py, pz, false, false, false, true)
                end
                count = count + 1
            end
        end
        notify.success("Maze Bank", string.format("Voce e %d jogadores teleportados para o topo do Maze Bank!", count))
    end)
end

------------------------------------------------------------
-- PLAYER PROP ATTACHMENT SUITE
------------------------------------------------------------

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
    
    local boneIndex = 0
    pcall(function()
        if PED and PED.GET_PED_BONE_INDEX then
            boneIndex = PED.GET_PED_BONE_INDEX(ped, boneId or 31086)
        end
    end)
    if not boneIndex or boneIndex < 0 then boneIndex = 0 end

    pcall(function()
        if ENTITY.SET_ENTITY_NO_COLLISION_ENTITY then
            ENTITY.SET_ENTITY_NO_COLLISION_ENTITY(obj, ped, false)
        end
    end)

    local attached = false
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

local function startAttachmentKeeperLoop()
    if S.isAttachmentKeeperRunning then return end
    S.isAttachmentKeeperRunning = true

    script.run_in_callback(function()
        while true do
            local hasAny = false
            for actualPid, list in pairs(S.attached_player_props) do
                local ped = getPlayerPed(actualPid)
                if isValidEntity(ped) then
                    for _, item in ipairs(list) do
                        hasAny = true
                        pcall(function()
                            -- Só recria se o objeto foi completamente destruído pelo jogo
                            if not isValidEntity(item.obj) and not PLAYER.IS_PLAYER_DEAD(ped) then
                                local hash = item.hash or getHash(item.modelName)
                                if hash and hash ~= 0 then
                                    STREAMING.REQUEST_MODEL(hash)
                                    if STREAMING.HAS_MODEL_LOADED(hash) then
                                        local coords = getTargetCoordsSafe(actualPid, ped)
                                        local newObj = safeCreateStuntProp(hash, coords.x, coords.y, coords.z, false)
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
            if not hasAny then S.isAttachmentKeeperRunning = false break end
            script.yield(500)
        end
    end)
end

local function attachPropToPlayer(targetPid, modelName, boneId, offX, offY, offZ, rotX, rotY, rotZ)
    script.run_in_callback(function()
        local myLocalPid = getLocalPid()
        local actualPid = (targetPid == nil or targetPid == -1) and myLocalPid or targetPid
        local ped = getPlayerPed(actualPid)
        if not isValidEntity(ped) then notify.warn("Anexar", "Jogador nao encontrado!"); return end

        local hash = getHash(modelName)
        if not hash or hash == 0 then notify.warn("Anexar", "Modelo invalido!"); return end

        STREAMING.REQUEST_MODEL(hash)
        local t = 0
        while not STREAMING.HAS_MODEL_LOADED(hash) and t < 80 do script.yield(10); t = t + 1 end
        if not STREAMING.HAS_MODEL_LOADED(hash) then
            if modelName == "prop_mp_cone_01" then
                hash = getHash("prop_roadcone02a")
                STREAMING.REQUEST_MODEL(hash)
                t = 0
                while not STREAMING.HAS_MODEL_LOADED(hash) and t < 60 do script.yield(10); t = t + 1 end
            end
        end
        if not STREAMING.HAS_MODEL_LOADED(hash) then notify.warn("Anexar", "Falha ao carregar modelo: " .. tostring(modelName)); return end

        local coords = getTargetCoordsSafe(actualPid, ped)

        -- 1. Cria o objeto no mundo networked (exatamente como em MAC_Fun_Script)
        local obj = safeCreateStuntProp(hash, coords.x, coords.y, coords.z, false)
        STREAMING.SET_MODEL_AS_NO_LONGER_NEEDED(hash)
        if not isValidEntity(obj) then notify.error("Anexar", "Falha ao instanciar o objeto no mundo."); return end

        -- 2. Configura a entidade com suporte a rede
        configureStuntEntity(obj, actualPid)

        -- 3. Anexa diretamente ao osso do Ped
        attachEntityDirect(obj, ped, boneId or 24818, offX, offY, offZ, rotX, rotY, rotZ)

        if not S.attached_player_props[actualPid] then S.attached_player_props[actualPid] = {} end

        table.insert(S.attached_player_props[actualPid], {
            obj = obj, hash = hash, modelName = modelName, boneId = boneId or 24818,
            offX = offX or 0.0, offY = offY or 0.0, offZ = offZ or 0.0,
            rotX = rotX or 0.0, rotY = rotY or 0.0, rotZ = rotZ or 0.0
        })

        startAttachmentKeeperLoop()
        local pName = (actualPid == myLocalPid) and "Voce" or getPlayerName(actualPid)
        notify.success("Anexar", string.format("Objeto [%s] fixado em %s!", tostring(modelName), pName))
    end)
end

local function removePlayerAttachedProps(targetPid)
    local actualPid = (targetPid == -1) and getLocalPid() or targetPid
    local list = S.attached_player_props[actualPid]
    local count = 0
    if list then
        for _, item in ipairs(list) do
            local obj = type(item) == "table" and item.obj or item
            if isValidEntity(obj) then
                pcall(function() ENTITY.DETACH_ENTITY(obj, true, true); safeDeleteEntity(obj) end)
                count = count + 1
            end
        end
        S.attached_player_props[actualPid] = nil
    end
    notify.info("Anexar", string.format("%d objetos removidos do jogador!", count))
end

local function removeAllAttachedProps()
    local count = 0
    for targetPid, list in pairs(S.attached_player_props) do
        for _, item in ipairs(list) do
            local obj = type(item) == "table" and item.obj or item
            if isValidEntity(obj) then
                pcall(function() ENTITY.DETACH_ENTITY(obj, true, true); safeDeleteEntity(obj) end)
                count = count + 1
            end
        end
    end
    S.attached_player_props = {}
    notify.info("Anexar", string.format("Todos os %d objetos anexados foram removidos!", count))
end

local STAND_CAGE_MODELS = {
    getHash("prop_gold_cont_01"),     -- Container Dourado Fechado
    getHash("prop_rub_cage01a"),      -- Gaiola Dupla Cruzada
    getHash("prop_fnclink_03e"),      -- Caixa de 4 Cercas
    getHash("stt_prop_stunt_tube_s"), -- Tubo Vertical Stunt
    getHash("v_med_apecrate"),        -- Jaula de Macaco
}

local function spawnAdvancedCageOnPlayer(targetPid, cageType)
    script.run_in_callback(function()
        local myLocalPid = getLocalPid()
        local actualPid = (targetPid == nil or targetPid == -1) and myLocalPid or targetPid
        local ped = getPlayerPed(actualPid)
        if not isValidEntity(ped) then notify.warn("Gaiola", "Jogador nao encontrado!"); return end

        local cageHash = cageType
        if not cageHash or cageHash == 0 or cageHash == "random" then
            cageHash = STAND_CAGE_MODELS[math.random(#STAND_CAGE_MODELS)]
        elseif type(cageHash) == "string" then
            cageHash = getHash(cageHash)
        end

        local coords = getTargetCoordsSafe(actualPid, ped)
        local pHeading = ENTITY.GET_ENTITY_HEADING(ped)

        if cageHash == getHash("prop_gold_cont_01") then
            -- 1. Container de Ouro: Spawna 1 container centrado na coordenada do jogador e congela
            if requestAndLoadModel(cageHash, 80) then
                local obj = safeCreateStuntProp(cageHash, coords.x, coords.y, coords.z, false)
                if isValidEntity(obj) then
                    pcall(function()
                        ENTITY.SET_ENTITY_ROTATION(obj, 0.0, 0.0, pHeading, 2, true)
                    end)
                    table.insert(S.spawned_stunt_objects, obj)
                end
                STREAMING.SET_MODEL_AS_NO_LONGER_NEEDED(cageHash)
            end

        elseif cageHash == getHash("stt_prop_stunt_tube_s") then
            -- 2. Tubo de Duble: Spawna 1 tubo rotacionado em 90 graus no eixo Y (em pe)
            if requestAndLoadModel(cageHash, 80) then
                local obj = safeCreateStuntProp(cageHash, coords.x, coords.y, coords.z, false)
                if isValidEntity(obj) then
                    pcall(function()
                        ENTITY.SET_ENTITY_ROTATION(obj, 0.0, 90.0, pHeading, 2, true)
                    end)
                    table.insert(S.spawned_stunt_objects, obj)
                end
                STREAMING.SET_MODEL_AS_NO_LONGER_NEEDED(cageHash)
            end

        elseif cageHash == getHash("prop_rub_cage01a") then
            -- 3. Gaiola de Metal: Spawna 2 gaiolas cruzadas em 90 graus no eixo Z para fechar o espaco
            if requestAndLoadModel(cageHash, 80) then
                local baseZ = coords.z - 1.0
                local obj1 = safeCreateStuntProp(cageHash, coords.x, coords.y, baseZ, false)
                local obj2 = safeCreateStuntProp(cageHash, coords.x, coords.y, baseZ, false)
                if isValidEntity(obj1) and isValidEntity(obj2) then
                    pcall(function()
                        ENTITY.SET_ENTITY_ROTATION(obj1, 0.0, 0.0, pHeading, 2, true)
                        ENTITY.SET_ENTITY_ROTATION(obj2, 0.0, 0.0, pHeading + 90.0, 2, true)
                    end)
                    table.insert(S.spawned_stunt_objects, obj1)
                    table.insert(S.spawned_stunt_objects, obj2)
                end
                STREAMING.SET_MODEL_AS_NO_LONGER_NEEDED(cageHash)
            end

        elseif cageHash == getHash("prop_fnclink_03e") then
            -- 4. Cerca de Arame: Spawna 4 paineis de cerca formando uma caixa quadrada perfeita (0, 90, 180 e 270 graus)
            if requestAndLoadModel(cageHash, 80) then
                local posX = coords.x - 1.0
                local posY = coords.y - 1.0
                local posZ = coords.z - 1.0

                local obj1 = safeCreateStuntProp(cageHash, posX, posY, posZ, false)
                local obj2 = safeCreateStuntProp(cageHash, posX, posY, posZ, false)

                local posX2 = posX + 2.9
                local posY2 = posY + 2.9

                local obj3 = safeCreateStuntProp(cageHash, posX2, posY2, posZ, false)
                local obj4 = safeCreateStuntProp(cageHash, posX2, posY2, posZ, false)

                if isValidEntity(obj1) and isValidEntity(obj2) and isValidEntity(obj3) and isValidEntity(obj4) then
                    pcall(function()
                        ENTITY.SET_ENTITY_ROTATION(obj1, 0.0, 0.0, 0.0, 2, true)
                        ENTITY.SET_ENTITY_ROTATION(obj2, 0.0, 0.0, 90.0, 2, true)
                        ENTITY.SET_ENTITY_ROTATION(obj3, 0.0, 0.0, 180.0, 2, true)
                        ENTITY.SET_ENTITY_ROTATION(obj4, 0.0, 0.0, 270.0, 2, true)
                    end)
                    table.insert(S.spawned_stunt_objects, obj1)
                    table.insert(S.spawned_stunt_objects, obj2)
                    table.insert(S.spawned_stunt_objects, obj3)
                    table.insert(S.spawned_stunt_objects, obj4)
                end
                STREAMING.SET_MODEL_AS_NO_LONGER_NEEDED(cageHash)
            end

        elseif cageHash == getHash("v_med_apecrate") then
            -- 5. Jaula de Macaco Classica
            if requestAndLoadModel(cageHash, 80) then
                local zFloor = coords.z - 0.95
                local obj = safeCreateStuntProp(cageHash, coords.x, coords.y, zFloor, true)
                if isValidEntity(obj) then
                    pcall(function()
                        ENTITY.SET_ENTITY_HEADING(obj, pHeading)
                    end)
                    table.insert(S.spawned_stunt_objects, obj)
                end
                STREAMING.SET_MODEL_AS_NO_LONGER_NEEDED(cageHash)
            end
        end

        local pName = (actualPid == myLocalPid) and "Voce" or getPlayerName(actualPid)
        notify.success("Gaiola", string.format("Gaiola Stand aplicada em %s!", pName))
    end)
end

local function spawnApeCrateCageOnPlayer(targetPid)
    spawnAdvancedCageOnPlayer(targetPid, "v_med_apecrate")
end


------------------------------------------------------------
-- ANGEL SELF FLOATIE
------------------------------------------------------------

local function removeAngelFloatie(silent)
    S.angelFloatieActive = false
    if isValidEntity(S.angelFloatieObject) then
        pcall(function()
            if ENTITY.IS_ENTITY_ATTACHED and ENTITY.IS_ENTITY_ATTACHED(S.angelFloatieObject) then ENTITY.DETACH_ENTITY(S.angelFloatieObject, true, true) end
            safeDeleteEntity(S.angelFloatieObject)
        end)
    end
    S.angelFloatieObject = nil
    if not silent then notify.info("Angel Floatie", "Boia removida.") end
end

local function toggleAngelFloatie()
    if S.angelFloatieActive and isValidEntity(S.angelFloatieObject) then removeAngelFloatie(false); return end
    local ped = getLocalPed()
    if not isValidEntity(ped) then return end

    local modelHash = getHash("prop_beach_ring_01")
    STREAMING.REQUEST_MODEL(modelHash)
    local t = 0
    while not STREAMING.HAS_MODEL_LOADED(modelHash) and t < 80 do script.yield(10); t = t + 1 end
    if not STREAMING.HAS_MODEL_LOADED(modelHash) then return end

    local coords = ENTITY.GET_ENTITY_COORDS(ped, true)
    local obj = safeCreateStuntProp(modelHash, coords.x, coords.y, coords.z, false)
    STREAMING.SET_MODEL_AS_NO_LONGER_NEEDED(modelHash)
    if not isValidEntity(obj) then return end

    S.angelFloatieObject = obj
    attachEntityDirect(obj, ped, 11816, 0.0, 0.0, 0.0, 0.0, 90.0, 0.0)
    S.angelFloatieActive = true
    notify.success("Angel Floatie", "Boia anexada a sua cintura!")
end

------------------------------------------------------------
-- CLIMA & CICLO RAPIDO DE HORAS (TIMELAPSE)
------------------------------------------------------------

local function setSessionWeather(weatherName, setMidnight)
    script.run_in_callback(function()
        local wName = string.upper(weatherName or "CLEAR")
        if MISC then
            if MISC.SET_WEATHER_TYPE_NOW_PERSIST then MISC.SET_WEATHER_TYPE_NOW_PERSIST(wName) end
            if MISC.SET_WEATHER_TYPE_NOW then MISC.SET_WEATHER_TYPE_NOW(wName) end
            if MISC.SET_WEATHER_TYPE_OVERTIME_PERSIST then MISC.SET_WEATHER_TYPE_OVERTIME_PERSIST(wName, 1.0) end
            if MISC.SET_OVERRIDE_WEATHER then MISC.SET_OVERRIDE_WEATHER(wName) end
        end
        if setMidnight and CLOCK and CLOCK.SET_CLOCK_TIME then CLOCK.SET_CLOCK_TIME(0, 0, 0) end
        notify.success("Clima", string.format("Clima [%s] aplicado!", wName))
    end)
end

local function toggleHalloweenWeather()
    S.halloweenModeActive = not S.halloweenModeActive
    if S.halloweenModeActive then
        setSessionWeather("HALLOWEEN", true)
        notify.success("Clima", "Modo Halloween ATIVADO: Ceu laranja, relampagos e nevoa!")
        if not S.halloweenLoopRunning then
            S.halloweenLoopRunning = true
            script.run_in_callback(function()
                while S.halloweenModeActive do
                    pcall(function()
                        if MISC and MISC.FORCE_LIGHTNING_FLASH then MISC.FORCE_LIGHTNING_FLASH() end
                        if CLOCK and CLOCK.SET_CLOCK_TIME then CLOCK.SET_CLOCK_TIME(0, 0, 0) end
                    end)
                    script.yield(math.random(3000, 6000))
                end
                S.halloweenLoopRunning = false
            end)
        end
    else
        pcall(function() if MISC and MISC.CLEAR_OVERRIDE_WEATHER then MISC.CLEAR_OVERRIDE_WEATHER() end end)
        setSessionWeather("EXTRASUNNY", false)
        notify.info("Clima", "Modo Halloween DESATIVADO.")
    end
end

local function toggleFastTimeCycle()
    S.fastTimeActive = not S.fastTimeActive
    if S.fastTimeActive then
        if not S.fastTimeLoopRunning then
            S.fastTimeLoopRunning = true
            script.run_in_callback(function()
                local currentMinutes = 0
                pcall(function()
                    if CLOCK and CLOCK.GET_CLOCK_HOURS and CLOCK.GET_CLOCK_MINUTES then
                        currentMinutes = CLOCK.GET_CLOCK_HOURS() * 60 + CLOCK.GET_CLOCK_MINUTES()
                    end
                end)
                while S.fastTimeActive do
                    currentMinutes = (currentMinutes + S.fastTimeSpeed) % 1440
                    local h = math.floor(currentMinutes / 60)
                    local m = math.floor(currentMinutes % 60)
                    pcall(function()
                        if CLOCK and CLOCK.SET_CLOCK_TIME then CLOCK.SET_CLOCK_TIME(h, m, 0) end
                    end)
                    script.yield(50)
                end
                S.fastTimeLoopRunning = false
            end)
        end
        notify.success("Timelapse", "Ciclo Rapido de Horas (Timelapse) ATIVADO!")
    else
        notify.info("Timelapse", "Ciclo Rapido de Horas DESATIVADO.")
    end
end

------------------------------------------------------------
-- CUTSCENES ONLINE
------------------------------------------------------------

local function playOnlineCutscene(cutsceneName, targetPid)
    script.run_in_callback(function()
        if not cutsceneName or cutsceneName == "" then return end
        local myLocalPid = getLocalPid()
        local actualPid = (targetPid == nil or targetPid == -1) and myLocalPid or targetPid
        local isLocal = (actualPid == myLocalPid)
        local pName = isLocal and "Voce" or getPlayerName(actualPid)

        notify.info("Cutscenes", string.format("Carregando cutscene [%s] para %s...", cutsceneName, pName))
        if not isLocal then
            local targetPed = getPlayerPed(actualPid)
            if isValidEntity(targetPed) then
                pcall(function()
                    local tc = ENTITY.GET_ENTITY_COORDS(targetPed, true)
                    if tc and CUTSCENE and CUTSCENE.SET_CUTSCENE_ORIGIN then CUTSCENE.SET_CUTSCENE_ORIGIN(tc.x, tc.y, tc.z, 0.0, 0) end
                end)
            end
        end

        if CUTSCENE and CUTSCENE.REQUEST_CUTSCENE then CUTSCENE.REQUEST_CUTSCENE(cutsceneName, 8) end
        local timeout = 0
        while CUTSCENE and not CUTSCENE.HAS_CUTSCENE_LOADED() and timeout < 300 do script.yield(10); timeout = timeout + 1 end
        if CUTSCENE and not CUTSCENE.HAS_CUTSCENE_LOADED() then notify.error("Cutscenes", "A cutscene nao carregou: " .. cutsceneName); return end

        notify.success("Cutscenes", string.format("Cutscene [%s] iniciada para %s!", cutsceneName, pName))
        if CUTSCENE and CUTSCENE.START_CUTSCENE then CUTSCENE.START_CUTSCENE(0) end
        while CUTSCENE and CUTSCENE.IS_CUTSCENE_PLAYING and CUTSCENE.IS_CUTSCENE_PLAYING() do script.yield(0) end
        pcall(function() if CUTSCENE and CUTSCENE.REMOVE_CUTSCENE then CUTSCENE.REMOVE_CUTSCENE() end end)
    end)
end

local function stopCurrentCutscene()
    script.run_in_callback(function()
        pcall(function()
            if CUTSCENE then
                if CUTSCENE.STOP_CUTSCENE_IMMEDIATELY then CUTSCENE.STOP_CUTSCENE_IMMEDIATELY()
                elseif CUTSCENE.STOP_CUTSCENE then CUTSCENE.STOP_CUTSCENE(true) end
                if CUTSCENE.REMOVE_CUTSCENE then CUTSCENE.REMOVE_CUTSCENE() end
            end
            notify.info("Cutscenes", "Cutscene interrompida.")
        end)
    end)
end

------------------------------------------------------------
-- JATOS (DOGFIGHT 5 CACAS 20MM) & LIMPEZA
------------------------------------------------------------

local isEnemyJetsSpawning = false

local function clearActiveDogfightJets()
    S.dogfightAttackRunning = false
    S.dogfightSessionId = S.dogfightSessionId + 1

    for _, item in ipairs(S.activeDogfightJets) do
        pcall(function()
            if item.blip and HUD and HUD.DOES_BLIP_EXIST and HUD.DOES_BLIP_EXIST(item.blip) then
                HUD.SET_BLIP_DISPLAY(item.blip, 0)
                HUD.REMOVE_BLIP(item.blip)
            end
            if isValidEntity(item.pilot) then safeDeleteEntity(item.pilot) end
            if isValidEntity(item.jet) then safeDeleteEntity(item.jet) end
        end)
    end
    S.activeDogfightJets = {}

    purgeAllJetBlips()

    local purged = 0
    pcall(function()
        local hashes = { getHash("lazer"), getHash("besra"), getHash("hydra"), getHash("pyro"), getHash("raiju"), getHash("strikeforce") }
        local pilotHash = getHash("s_m_y_blackops_01")
        local myPed = getLocalPed()

        if entities and entities.get_all_vehicles_as_handles then
            for _, v in ipairs(entities.get_all_vehicles_as_handles()) do
                if isValidEntity(v) and not (PED and PED.IS_PED_IN_VEHICLE and PED.IS_PED_IN_VEHICLE(myPed, v, false)) then
                    local model = ENTITY.GET_ENTITY_MODEL(v)
                    for _, h in ipairs(hashes) do
                        if model == h then
                            removeBlipForEntity(v)
                            safeDeleteEntity(v)
                            purged = purged + 1
                            break
                        end
                    end
                end
            end
        end

        if entities and entities.get_all_peds_as_handles then
            for _, p in ipairs(entities.get_all_peds_as_handles()) do
                if isValidEntity(p) and not PED.IS_PED_A_PLAYER(p) and ENTITY.GET_ENTITY_MODEL(p) == pilotHash then
                    removeBlipForEntity(p)
                    safeDeleteEntity(p)
                    purged = purged + 1
                end
            end
        end
    end)

    purgeAllJetBlips()
    notify.info("Jatos", "Todos os cacas e pilotos foram removidos do mapa.")
end

local function triggerDogfightAttack(targetPid, count)
    if isEnemyJetsSpawning then
        notify.warn("Jatos", "Aguarde, cacas anteriores ainda sendo posicionados!")
        return
    end

    local myLocalPid = getLocalPid()
    local actualPid = (targetPid == nil or targetPid == -1) and myLocalPid or targetPid
    local targetPed = getPlayerPed(actualPid)
    local targetCoords = getTargetCoordsSafe(actualPid, targetPed)
    local targetName = (actualPid == myLocalPid) and "Voce Mesmo" or getPlayerName(actualPid)
    local jetCount = 5

    isEnemyJetsSpawning = true

    script.run_in_callback(function()
        pcall(function()
            if not isValidEntity(targetPed) then
                targetPed = getLocalPed()
            end

            -- Remove esquadrao anterior
            if #S.activeDogfightJets > 0 then
                clearActiveDogfightJets()
                script.yield(100)
            end

            local jetHash = getHash("lazer")
            local pilotHash = getHash("s_m_y_blackops_01")

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
                notify.error("Jatos", "Falha ao carregar modelos dos cacas.")
                isEnemyJetsSpawning = false
                return
            end

            notify.warn("Jatos", string.format("Enviando %d cacas atacando %s!", jetCount, targetName))
            S.dogfightAttackRunning = true

            for i = 1, jetCount do
                local angle = ((i - 1) / jetCount) * (math.pi * 2) + (math.random() * 0.4)
                local dist = 120.0 + (i * 25.0)
                local sx = targetCoords.x + math.cos(angle) * dist
                local sy = targetCoords.y + math.sin(angle) * dist
                local sz = targetCoords.z + 240.0 + (i * 20.0)
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
                            VEHICLE.CONTROL_LANDING_GEAR(jet, 3)
                        end
                        if VEHICLE.SET_HELI_BLADES_FULL_SPEED then
                            VEHICLE.SET_HELI_BLADES_FULL_SPEED(jet)
                        end

                        pilot = PED.CREATE_PED_INSIDE_VEHICLE(jet, 26, pilotHash, -1, true, false)

                        if HUD and HUD.ADD_BLIP_FOR_ENTITY then
                            blip = HUD.ADD_BLIP_FOR_ENTITY(jet)
                            if HUD.SET_BLIP_SPRITE then HUD.SET_BLIP_SPRITE(blip, 16) end
                            if HUD.SET_BLIP_COLOUR then HUD.SET_BLIP_COLOUR(blip, 1) end
                            if HUD.SET_BLIP_SCALE then HUD.SET_BLIP_SCALE(blip, 1.0) end
                            if HUD.SET_BLIP_AS_SHORT_RANGE then HUD.SET_BLIP_AS_SHORT_RANGE(blip, false) end
                            if HUD.BEGIN_TEXT_COMMAND_SET_BLIP_NAME then
                                HUD.BEGIN_TEXT_COMMAND_SET_BLIP_NAME("STRING")
                                HUD.ADD_TEXT_COMPONENT_SUBSTRING_PLAYER_NAME("Caca Inimigo")
                                HUD.END_TEXT_COMMAND_SET_BLIP_NAME(blip)
                            end
                        end
                    end)

                    table.insert(S.activeDogfightJets, { jet = jet, pilot = pilot, blip = blip })

                    if isValidEntity(pilot) then
                        pcall(function()
                            ENTITY.SET_ENTITY_AS_MISSION_ENTITY(pilot, true, true)
                            PED.SET_PED_INTO_VEHICLE(pilot, jet, -1)
                            PED.SET_BLOCKING_OF_NON_TEMPORARY_EVENTS(pilot, true)
                            PED.SET_PED_KEEP_TASK(pilot, true)

                            local enemyGroup = getHash("HATES_PLAYER")
                            local playerGroup = PED.GET_PED_RELATIONSHIP_GROUP_HASH(targetPed)
                            PED.SET_PED_RELATIONSHIP_GROUP_HASH(pilot, enemyGroup)
                            PED.SET_RELATIONSHIP_BETWEEN_GROUPS(5, enemyGroup, playerGroup)
                            PED.SET_RELATIONSHIP_BETWEEN_GROUPS(5, playerGroup, enemyGroup)

                            PED.SET_PED_COMBAT_ATTRIBUTES(pilot, 1, true)
                            PED.SET_PED_COMBAT_ATTRIBUTES(pilot, 2, true)
                            PED.SET_PED_COMBAT_ATTRIBUTES(pilot, 3, false)
                            PED.SET_PED_COMBAT_ATTRIBUTES(pilot, 5, true)
                            PED.SET_PED_COMBAT_ATTRIBUTES(pilot, 13, true)
                            PED.SET_PED_COMBAT_ATTRIBUTES(pilot, 27, true)
                            PED.SET_PED_COMBAT_ATTRIBUTES(pilot, 46, true)
                            PED.SET_PED_COMBAT_ATTRIBUTES(pilot, 54, true)
                            PED.SET_PED_COMBAT_ATTRIBUTES(pilot, 58, true)
                            PED.SET_PED_COMBAT_ATTRIBUTES(pilot, 86, true)
                            PED.SET_PED_COMBAT_ABILITY(pilot, 2)
                            PED.SET_PED_COMBAT_MOVEMENT(pilot, 3)
                            PED.SET_PED_COMBAT_RANGE(pilot, 2)
                            PED.SET_PED_TARGET_LOSS_RESPONSE(pilot, 1)
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

                    -- Loop assincrono dedicado para cada jato
                    script.run_in_callback(function()
                        local lastAssignedPed = targetPed
                        local shootCooldown = 0

                        while isValidEntity(jet) and isValidEntity(pilot) and not PED.IS_PED_INJURED(pilot) and S.dogfightAttackRunning do
                            local curPed = getPlayerPed(actualPid)

                            if isValidEntity(curPed) and curPed ~= lastAssignedPed and not PED.IS_PED_INJURED(curPed) then
                                lastAssignedPed = curPed
                                pcall(function()
                                    local pGroup = PED.GET_PED_RELATIONSHIP_GROUP_HASH(curPed)
                                    local eGroup = getHash("HATES_PLAYER")
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

                                        if dot > 0.65 then
                                            local leftMuzzle = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(jet, -1.8, 4.0, -0.2)
                                            local rightMuzzle = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(jet, 1.8, 4.0, -0.2)
                                            local laserHash = getHash("VEHICLE_WEAPON_PLAYER_LAZER")
                                            if laserHash == 0 then laserHash = getHash("WEAPON_EXPLOSION") end

                                            MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS(leftMuzzle.x, leftMuzzle.y, leftMuzzle.z, pCoords.x, pCoords.y, pCoords.z + 0.4, 250, true, laserHash, pilot, true, false, 950.0)
                                            MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS(rightMuzzle.x, rightMuzzle.y, rightMuzzle.z, pCoords.x, pCoords.y, pCoords.z + 0.4, 250, true, laserHash, pilot, true, false, 950.0)
                                            shootCooldown = 0
                                        end
                                    end
                                end)
                            end
                            script.yield(150)
                        end

                        -- Ao morrer ou explodir, remove seu blip e limpa na hora
                        pcall(function()
                            if blip and HUD and HUD.DOES_BLIP_EXIST and HUD.DOES_BLIP_EXIST(blip) then
                                HUD.SET_BLIP_DISPLAY(blip, 0)
                                HUD.REMOVE_BLIP(blip)
                            end
                            if isValidEntity(pilot) then safeDeleteEntity(pilot) end
                            if isValidEntity(jet) then safeDeleteEntity(jet) end
                        end)
                    end)
                end
                script.yield(50)
            end

            STREAMING.SET_MODEL_AS_NO_LONGER_NEEDED(jetHash)
            STREAMING.SET_MODEL_AS_NO_LONGER_NEEDED(pilotHash)
            isEnemyJetsSpawning = false
        end)
    end)
end

local function triggerDogfightAttackAllSession()
    if isEnemyJetsSpawning then
        notify.warn("Jatos", "Aguarde, cacas anteriores ainda sendo posicionados!")
        return
    end

    local players = getActivePlayersList()
    if #players == 0 then
        notify.warn("Jatos", "Nenhum jogador encontrado na sessao.")
        return
    end

    isEnemyJetsSpawning = true
    notify.warn("Jatos", string.format("Ataque Global! Enviando 2 cacas para cada um dos %d jogadores...", #players))

    script.run_in_callback(function()
        pcall(function()
            if #S.activeDogfightJets > 0 then
                clearActiveDogfightJets()
                script.yield(100)
            end

            local jetHash = getHash("lazer")
            local pilotHash = getHash("s_m_y_blackops_01")

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
                notify.error("Jatos", "Falha ao carregar modelos dos cacas.")
                isEnemyJetsSpawning = false
                return
            end

            S.dogfightAttackRunning = true

            for _, targetPid in ipairs(players) do
                local targetPed = getPlayerPed(targetPid)
                local targetCoords = getTargetCoordsSafe(targetPid, targetPed)

                for i = 1, 2 do
                    local angle = (i * math.pi) + (math.random() * 0.4)
                    local dist = 120.0 + (i * 25.0)
                    local sx = targetCoords.x + math.cos(angle) * dist
                    local sy = targetCoords.y + math.sin(angle) * dist
                    local sz = targetCoords.z + 240.0 + (i * 20.0)
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
                                VEHICLE.CONTROL_LANDING_GEAR(jet, 3)
                            end
                            if VEHICLE.SET_HELI_BLADES_FULL_SPEED then
                                VEHICLE.SET_HELI_BLADES_FULL_SPEED(jet)
                            end

                            pilot = PED.CREATE_PED_INSIDE_VEHICLE(jet, 26, pilotHash, -1, true, false)

                            if HUD and HUD.ADD_BLIP_FOR_ENTITY then
                                blip = HUD.ADD_BLIP_FOR_ENTITY(jet)
                                if HUD.SET_BLIP_SPRITE then HUD.SET_BLIP_SPRITE(blip, 16) end
                                if HUD.SET_BLIP_COLOUR then HUD.SET_BLIP_COLOUR(blip, 1) end
                                if HUD.SET_BLIP_SCALE then HUD.SET_BLIP_SCALE(blip, 1.0) end
                                if HUD.SET_BLIP_AS_SHORT_RANGE then HUD.SET_BLIP_AS_SHORT_RANGE(blip, false) end
                                if HUD.BEGIN_TEXT_COMMAND_SET_BLIP_NAME then
                                    HUD.BEGIN_TEXT_COMMAND_SET_BLIP_NAME("STRING")
                                    HUD.ADD_TEXT_COMPONENT_SUBSTRING_PLAYER_NAME("Caca Inimigo")
                                    HUD.END_TEXT_COMMAND_SET_BLIP_NAME(blip)
                                end
                            end
                        end)

                        table.insert(S.activeDogfightJets, { jet = jet, pilot = pilot, blip = blip })

                        if isValidEntity(pilot) then
                            pcall(function()
                                ENTITY.SET_ENTITY_AS_MISSION_ENTITY(pilot, true, true)
                                PED.SET_PED_INTO_VEHICLE(pilot, jet, -1)
                                PED.SET_BLOCKING_OF_NON_TEMPORARY_EVENTS(pilot, true)
                                PED.SET_PED_KEEP_TASK(pilot, true)

                                local enemyGroup = getHash("HATES_PLAYER")
                                local playerGroup = PED.GET_PED_RELATIONSHIP_GROUP_HASH(targetPed)
                                PED.SET_PED_RELATIONSHIP_GROUP_HASH(pilot, enemyGroup)
                                PED.SET_RELATIONSHIP_BETWEEN_GROUPS(5, enemyGroup, playerGroup)
                                PED.SET_RELATIONSHIP_BETWEEN_GROUPS(5, playerGroup, enemyGroup)

                                PED.SET_PED_COMBAT_ATTRIBUTES(pilot, 1, true)
                                PED.SET_PED_COMBAT_ATTRIBUTES(pilot, 2, true)
                                PED.SET_PED_COMBAT_ATTRIBUTES(pilot, 3, false)
                                PED.SET_PED_COMBAT_ATTRIBUTES(pilot, 5, true)
                                PED.SET_PED_COMBAT_ATTRIBUTES(pilot, 13, true)
                                PED.SET_PED_COMBAT_ATTRIBUTES(pilot, 27, true)
                                PED.SET_PED_COMBAT_ATTRIBUTES(pilot, 46, true)
                                PED.SET_PED_COMBAT_ATTRIBUTES(pilot, 54, true)
                                PED.SET_PED_COMBAT_ATTRIBUTES(pilot, 58, true)
                                PED.SET_PED_COMBAT_ATTRIBUTES(pilot, 86, true)
                                PED.SET_PED_COMBAT_ABILITY(pilot, 2)
                                PED.SET_PED_COMBAT_MOVEMENT(pilot, 3)
                                PED.SET_PED_COMBAT_RANGE(pilot, 2)
                                PED.SET_PED_TARGET_LOSS_RESPONSE(pilot, 1)
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

                        script.run_in_callback(function()
                            local lastAssignedPed = targetPed
                            local shootCooldown = 0

                            while isValidEntity(jet) and isValidEntity(pilot) and not PED.IS_PED_INJURED(pilot) and S.dogfightAttackRunning do
                                local curPed = getPlayerPed(targetPid)

                                if isValidEntity(curPed) and curPed ~= lastAssignedPed and not PED.IS_PED_INJURED(curPed) then
                                    lastAssignedPed = curPed
                                    pcall(function()
                                        local pGroup = PED.GET_PED_RELATIONSHIP_GROUP_HASH(curPed)
                                        local eGroup = getHash("HATES_PLAYER")
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

                                            if dot > 0.65 then
                                                local leftMuzzle = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(jet, -1.8, 4.0, -0.2)
                                                local rightMuzzle = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(jet, 1.8, 4.0, -0.2)
                                                local laserHash = getHash("VEHICLE_WEAPON_PLAYER_LAZER")
                                                if laserHash == 0 then laserHash = getHash("WEAPON_EXPLOSION") end

                                                MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS(leftMuzzle.x, leftMuzzle.y, leftMuzzle.z, pCoords.x, pCoords.y, pCoords.z + 0.4, 250, true, laserHash, pilot, true, false, 950.0)
                                                MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS(rightMuzzle.x, rightMuzzle.y, rightMuzzle.z, pCoords.x, pCoords.y, pCoords.z + 0.4, 250, true, laserHash, pilot, true, false, 950.0)
                                                shootCooldown = 0
                                            end
                                        end
                                    end)
                                end
                                script.yield(150)
                            end

                            pcall(function()
                                if blip and HUD and HUD.DOES_BLIP_EXIST and HUD.DOES_BLIP_EXIST(blip) then
                                    HUD.SET_BLIP_DISPLAY(blip, 0)
                                    HUD.REMOVE_BLIP(blip)
                                end
                                if isValidEntity(pilot) then safeDeleteEntity(pilot) end
                                if isValidEntity(jet) then safeDeleteEntity(jet) end
                            end)
                        end)
                    end
                    script.yield(40)
                end
            end

            STREAMING.SET_MODEL_AS_NO_LONGER_NEEDED(jetHash)
            STREAMING.SET_MODEL_AS_NO_LONGER_NEEDED(pilotHash)
            isEnemyJetsSpawning = false
            notify.success("Jatos", "Esquadrao global da sessao posicionado com sucesso!")
        end)
    end)
end

------------------------------------------------------------
-- EAR RAPE & TROLL SONORO / VISUAL
------------------------------------------------------------

local function stopTrollAudioHarassment()
    S.isTrollAudioActive = false
    S.trollAudioLoop = false
    pcall(function()
        if GRAPHICS and GRAPHICS.ANIMPOSTFX_STOP then GRAPHICS.ANIMPOSTFX_STOP("DrugsMichaelAliensFight") end
        if GRAPHICS and GRAPHICS.ANIMPOSTFX_STOP_ALL then GRAPHICS.ANIMPOSTFX_STOP_ALL() end
        if CAM and CAM.STOP_GAMEPLAY_CAM_SHAKING then CAM.STOP_GAMEPLAY_CAM_SHAKING(true) end
    end)
    notify.info("Ear Rape", "Ear Rape e Terremoto desativados.")
end

local function runSingleEarRapeStep(targetPid)
    local myLocalPid = getLocalPid()
    local actualPid = (targetPid == -1 or targetPid == myLocalPid) and myLocalPid or targetPid
    local isLocal = (actualPid == myLocalPid)
    local targetPed = getPlayerPed(actualPid)
    local coords = getTargetCoordsSafe(actualPid, targetPed)
    local shooterPed = (isValidEntity(targetPed) and targetPed or 0)
    S.earRapeStepIndex = S.earRapeStepIndex + 1

    -- 1. SONS LOCAIS E UI (FRONTEND + 3D)
    pcall(function()
        local sndIdx = (S.earRapeStepIndex % #Presets.earRapeSounds) + 1
        local snd = Presets.earRapeSounds[sndIdx]
        local sName = snd.sound or snd.name
        if isLocal and not S.muteEarRapeLocal then
            if AUDIO and AUDIO.PLAY_SOUND_FRONTEND then
                AUDIO.PLAY_SOUND_FRONTEND(-1, sName, snd.set, true)
            end
        end
        if AUDIO and AUDIO.PLAY_SOUND_FROM_COORD then
            AUDIO.PLAY_SOUND_FROM_COORD(-1, sName, coords.x, coords.y, coords.z, snd.set, true, 180, true)
        end
        if isValidEntity(targetPed) and AUDIO and AUDIO.PLAY_SOUND_FROM_ENTITY then
            AUDIO.PLAY_SOUND_FROM_ENTITY(-1, sName, targetPed, snd.set, true, 0)
        end
    end)

    -- 2. SONS DIVERSIFICADOS EM REDE (1 TIRO SEGURO NO ALTO A CADA TICK)
    pcall(function()
        if MISC and MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS then
            local totalWeapons = #Presets.networkedEarRapeWeapons
            local wIdx = (S.earRapeStepIndex % totalWeapons) + 1
            local wItem = Presets.networkedEarRapeWeapons[wIdx]
            local wHash = getHash(wItem.model or wItem)
            if wHash ~= 0 then
                local ang = (S.earRapeStepIndex * 1.2)
                local fromX = coords.x + math.cos(ang) * 3.5
                local fromY = coords.y + math.sin(ang) * 3.5
                local fromZ = coords.z + 6.0
                local toX = fromX
                local toY = fromY
                local toZ = fromZ + 3.0
                MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS(fromX, fromY, fromZ, toX, toY, toZ, 0, true, wHash, shooterPed, true, false, 800.0)
            end
        end
    end)

    -- 3. EFEITOS VISUAIS E AUDITIVOS CINEMATOGRAFICOS EM REDE NA TELA DO ALVO (SEM SINALIZADORES / FOGOS)
    pcall(function()
        if FIRE and FIRE.ADD_EXPLOSION then
            local expType = 70
            local modStep = S.earRapeStepIndex % 4
            if modStep == 0 then
                expType = 59 -- Raio Vermelho Canhao Orbital do Ceu (Flash sem sinalizador)
            elseif modStep == 1 then
                expType = 67 -- Pulso Eletromagnetico EMP (Azul Eletrico)
            elseif modStep == 2 then
                expType = 13 -- Geyser de Agua de Alta Pressao (Gotas na camera)
            elseif modStep == 3 then
                expType = 70 -- Tremor de Camera e Som de Impacto Invisivel
            end

            FIRE.ADD_EXPLOSION(coords.x, coords.y, coords.z - 0.5, expType, 0.0, true, false, 4.5, false)
        end

        -- 4. RELAMPAGO A CADA 4 TICKS (1x por segundo para nao floodar a rede)
        if S.trollLightning and (S.earRapeStepIndex % 4 == 0) and MISC and MISC.FORCE_LIGHTNING_FLASH_AT_COORDS then
            MISC.FORCE_LIGHTNING_FLASH_AT_COORDS(coords.x, coords.y, coords.z, 4.5)
        end

        -- 5. TREMOR & FLASHBANG LOCAL SE ESTIVER TESTANDO EM SI MESMO
        if isLocal and not S.muteEarRapeLocal then
            if CAM and CAM.SHAKE_GAMEPLAY_CAM then CAM.SHAKE_GAMEPLAY_CAM("LARGE_EXPLOSION_SHAKE", 4.5) end
            if S.trollFlashbang and GRAPHICS and GRAPHICS.ANIMPOSTFX_PLAY then GRAPHICS.ANIMPOSTFX_PLAY("DrugsMichaelAliensFight", 0, true) end
        end
    end)
end

local function triggerEarRapeTremor(targetPid, burstSecs)
    local isAll = (targetPid == -2)
    local actualPid = (targetPid == -1 or targetPid == getLocalPid()) and getLocalPid() or targetPid
    local pName = isAll and "TODOS os Jogadores da Sessao" or ((actualPid == getLocalPid()) and "Voce Mesmo" or getPlayerName(actualPid))

    if burstSecs and burstSecs > 0 then
        notify.warn("Ear Rape", string.format("Disparando Ear Rape Estavel (%ds) em %s!", burstSecs, pName))
    else
        notify.warn("Ear Rape", "Modo Continuo Estavel de Ear Rape ATIVADO em " .. pName .. "!")
    end

    script.run_in_callback(function()
        local intervalMs = 250
        if burstSecs and burstSecs > 0 then
            S.isTrollAudioActive = true
            local totalTicks = math.floor((burstSecs * 1000) / intervalMs)
            for i = 1, totalTicks do
                if not S.isTrollAudioActive then break end
                if isAll then
                    local players = getActivePlayersList()
                    if #players > 0 then
                        local targetIdx = ((i - 1) % #players) + 1
                        runSingleEarRapeStep(players[targetIdx])
                    end
                else
                    runSingleEarRapeStep(actualPid)
                end
                script.yield(intervalMs)
            end
            stopTrollAudioHarassment()
            notify.info("Ear Rape", "Burst de Ear Rape finalizado em " .. pName .. ".")
        else
            S.isTrollAudioActive = true
            S.trollAudioLoop = true
            local stepCount = 0
            while S.isTrollAudioActive and S.trollAudioLoop do
                stepCount = stepCount + 1
                if isAll then
                    local players = getActivePlayersList()
                    if #players > 0 then
                        local targetIdx = ((stepCount - 1) % #players) + 1
                        runSingleEarRapeStep(players[targetIdx])
                    end
                else
                    runSingleEarRapeStep(actualPid)
                end
                script.yield(intervalMs)
            end
            stopTrollAudioHarassment()
        end
    end)
end

------------------------------------------------------------
-- SPAM DE CONVITES DE CONTATOS & SMS
------------------------------------------------------------

local function postContactInvite(contact, targetPid, silent)
    if not contact then return false end
    local myLocalPid = getLocalPid()
    local actualPid = (targetPid == nil or targetPid == -1) and myLocalPid or targetPid
    local isLocal = (actualPid == myLocalPid)

    if isLocal then
        pcall(function()
            if HUD and HUD.BEGIN_TEXT_COMMAND_THEFEED_POST then
                HUD.BEGIN_TEXT_COMMAND_THEFEED_POST("STRING")
                HUD.ADD_TEXT_COMPONENT_SUBSTRING_PLAYER_NAME("~b~Convite~s~ para " .. tostring(S.contactActivity))
                if HUD.END_TEXT_COMMAND_THEFEED_POST_MESSAGETEXT then
                    HUD.END_TEXT_COMMAND_THEFEED_POST_MESSAGETEXT(contact.txd, contact.txd, true, S.contactIconType or 7, contact.name, S.contactSubject)
                end
            end
        end)
    else
        local smsText = string.format("[%s] %s: %s", contact.name, S.contactSubject, S.contactActivity)
        pcall(function()
            if players and players.send_sms then
                players.send_sms(actualPid, smsText)
            end
        end)
    end
    return true
end

local function sendAllContactInvites(targetPid)
    if S.contactIsSpamming then notify.warn("Convites", "Envio em massa ja em andamento!"); return end
    S.contactIsSpamming = true
    local myLocalPid = getLocalPid()
    local actualPid = (targetPid == nil or targetPid == -1) and myLocalPid or targetPid
    local targetName = (actualPid == myLocalPid) and "Voce Mesmo" or getPlayerName(actualPid)

    notify.info("Convites", "Disparando todos os convites para " .. targetName .. "...")
    script.run_in_callback(function()
        for i = 1, #Presets.contacts do
            if not S.contactIsSpamming then break end
            postContactInvite(Presets.contacts[i], actualPid, true)
            script.yield(S.contactDelayMs)
        end
        S.contactIsSpamming = false
        notify.success("Convites", "Envio de convites para " .. targetName .. " finalizado!")
    end)
end

------------------------------------------------------------
-- AIRDROP MILITAR
------------------------------------------------------------

local function cancelActiveAirdrop(silent)
    S.airdropSessionId = S.airdropSessionId + 1
    if S.ActiveAirdrop then
        pcall(function()
            if S.ActiveAirdrop.ptfx and S.ActiveAirdrop.ptfx ~= 0 then
                if GRAPHICS and GRAPHICS.STOP_PARTICLE_FX_LOOPED then GRAPHICS.STOP_PARTICLE_FX_LOOPED(S.ActiveAirdrop.ptfx, false) end
                if GRAPHICS and GRAPHICS.REMOVE_PARTICLE_FX then GRAPHICS.REMOVE_PARTICLE_FX(S.ActiveAirdrop.ptfx, false) end
            end
            if isValidEntity(S.ActiveAirdrop.crate) then safeDeleteEntity(S.ActiveAirdrop.crate) end
        end)
        S.ActiveAirdrop = nil
        if not silent then notify.info("Airdrop", "Airdrop cancelado e removido.") end
    end
end

local function triggerAirdropDrop(dropType, targetPid, locMode)
    cancelActiveAirdrop(true)
    S.airdropSessionId = S.airdropSessionId + 1
    local mySessionId = S.airdropSessionId

    local isLocalTarget = (locMode == 1 or targetPid == -1 or targetPid == getLocalPid())
    local pName = isLocalTarget and "Voce" or getPlayerName(targetPid)
    local dropX, dropY, dropZ = 0, 0, 0

    if isLocalTarget then
        local pCoords = ENTITY.GET_ENTITY_COORDS(getLocalPed(), true)
        local forward = getCameraDirection()
        dropX = pCoords.x + forward.x * 15.0
        dropY = pCoords.y + forward.y * 15.0
        dropZ = pCoords.z
    else
        local targetPed = getPlayerPed(targetPid)
        if isValidEntity(targetPed) then
            local tCoords = ENTITY.GET_ENTITY_COORDS(targetPed, true)
            dropX, dropY, dropZ = tCoords.x, tCoords.y, tCoords.z
        else
            notify.error("Airdrop", "Jogador alvo nao encontrado.")
            return
        end
    end

    local chosenType = tonumber(dropType) or S.airdropDropType or 1
    local chosenVehModel = S.airdropVehicleModel or "oppressor2"
    local chosenVehName = S.airdropVehicleName or "Oppressor Mk II"
    notify.info("Airdrop", "Sinalizador lancado! Airdrop a caminho de " .. pName .. "...")

    script.run_in_callback(function()
        if S.airdropSessionId ~= mySessionId then return end
        local crateHash = getHash("prop_box_wood05a")
        if not requestAndLoadModel(crateHash, 40) then return end
        if S.airdropSessionId ~= mySessionId then return end

        local startZ = dropZ + 50.0
        local crate = safeCreateStuntProp(crateHash, dropX, dropY, startZ, false)
        if not isValidEntity(crate) then return end
        S.ActiveAirdrop = { crate = crate, ptfx = nil }

        local curZ = startZ
        while curZ > (dropZ + 0.3) do
            if S.airdropSessionId ~= mySessionId or not isValidEntity(crate) then
                safeDeleteEntity(crate)
                S.ActiveAirdrop = nil
                return
            end
            curZ = curZ - 0.75
            ENTITY.SET_ENTITY_COORDS(crate, dropX, dropY, curZ, false, false, false, true)
            script.yield(15)
        end

        if not isValidEntity(crate) or S.airdropSessionId ~= mySessionId then return end
        pcall(function() ENTITY.PLACE_ENTITY_ON_GROUND_PROPERLY(crate) end)

        -- Iniciar fumaca / sinalizador vermelho na caixa
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

        if S.ActiveAirdrop then
            S.ActiveAirdrop.ptfx = ptfxLoop
        end

        notify.success("Airdrop", "Airdrop pousou! Siga a fumaca vermelha e aproxime-se para resgatar.")

        local expireTime = gameTimer() + 90000
        while gameTimer() < expireTime and isValidEntity(crate) do
            if S.airdropSessionId ~= mySessionId then
                pcall(function()
                    if ptfxLoop and ptfxLoop ~= 0 then
                        GRAPHICS.STOP_PARTICLE_FX_LOOPED(ptfxLoop, false)
                        GRAPHICS.REMOVE_PARTICLE_FX(ptfxLoop, false)
                    end
                end)
                safeDeleteEntity(crate)
                S.ActiveAirdrop = nil
                return
            end

            local cPos = ENTITY.GET_ENTITY_COORDS(crate, true)

            for pid = 0, 31 do
                if isPlayerActive(pid) or pid == getLocalPid() then
                    local pPed = (pid == getLocalPid()) and getLocalPed() or getPlayerPed(pid)
                    if isValidEntity(pPed) and not PED.IS_PED_INJURED(pPed) then
                        local pp = ENTITY.GET_ENTITY_COORDS(pPed, true)
                        local dx, dy, dz = pp.x - cPos.x, pp.y - cPos.y, pp.z - cPos.z
                        if math.sqrt(dx*dx + dy*dy) <= 4.5 and math.abs(dz) <= 3.5 then
                            local openerName = (pid == getLocalPid()) and "Voce" or getPlayerName(pid)

                            pcall(function()
                                if ptfxLoop and ptfxLoop ~= 0 then
                                    GRAPHICS.STOP_PARTICLE_FX_LOOPED(ptfxLoop, false)
                                    GRAPHICS.REMOVE_PARTICLE_FX(ptfxLoop, false)
                                end
                            end)

                            safeDeleteEntity(crate)
                            STREAMING.SET_MODEL_AS_NO_LONGER_NEEDED(crateHash)
                            S.ActiveAirdrop = nil

                            if chosenType == 1 then
                                pcall(function()
                                    ENTITY.SET_ENTITY_HEALTH(pPed, 200, 0, 0)
                                    PED.SET_PED_ARMOUR(pPed, 100)
                                    for _, wName in ipairs({ "WEAPON_MINIGUN", "WEAPON_RAILGUN", "WEAPON_HOMINGLAUNCHER", "WEAPON_RPG", "WEAPON_SPECIALCARBINE_MK2" }) do
                                        WEAPON.GIVE_WEAPON_TO_PED(pPed, getHash(wName), 9999, false, true)
                                    end
                                end)
                                notify.success("Airdrop", openerName .. " resgatou o Suprimento Tatico!")
                            elseif chosenType == 2 then
                                local vHash = getHash(chosenVehModel)
                                if requestAndLoadModel(vHash, 100) then
                                    local pHeading = ENTITY.GET_ENTITY_HEADING(pPed)
                                    local veh = VEHICLE.CREATE_VEHICLE(vHash, cPos.x, cPos.y, cPos.z + 0.3, pHeading, true, false, false)
                                    if isValidEntity(veh) then
                                        ENTITY.SET_ENTITY_AS_MISSION_ENTITY(veh, true, true)
                                        safeSetInvincible(veh, true)
                                        pcall(function()
                                            VEHICLE.SET_VEHICLE_ON_GROUND_PROPERLY(veh)
                                            VEHICLE.SET_VEHICLE_ENGINE_ON(veh, true, true, false)
                                        end)

                                        notify.success("Airdrop", chosenVehName .. " entregue com sucesso no local do Airdrop!")
                                    end
                                    STREAMING.SET_MODEL_AS_NO_LONGER_NEEDED(vHash)
                                end
                            elseif chosenType == 3 then
                                pcall(function() FIRE.ADD_EXPLOSION(cPos.x, cPos.y, cPos.z, 29, 25.0, true, false, 2.5, false) end)
                                notify.warn("Airdrop", "Armadilha do Airdrop detonada!")
                            end
                            return
                        end
                    end
                end
            end
            script.yield(100)
        end

        pcall(function()
            if ptfxLoop and ptfxLoop ~= 0 then
                GRAPHICS.STOP_PARTICLE_FX_LOOPED(ptfxLoop, false)
                GRAPHICS.REMOVE_PARTICLE_FX(ptfxLoop, false)
            end
        end)
        if isValidEntity(crate) then safeDeleteEntity(crate); STREAMING.SET_MODEL_AS_NO_LONGER_NEEDED(crateHash) end
        S.ActiveAirdrop = nil
    end)
end

------------------------------------------------------------
-- IMGUI TARGET SELECTOR
------------------------------------------------------------

local function renderPlayerTargetSelector(currentSelectedPid, onSelectCallback, idTag, allowAll)
    local localPid = getLocalPid()
    local isAll = (currentSelectedPid == -2)
    local isSelf = (currentSelectedPid == -1 or currentSelectedPid == localPid)
    
    local curTargetName = isAll and "TODOS OS JOGADORES (Sessao Inteira)" or (isSelf and "Voce Mesmo (Local)" or (getPlayerName(currentSelectedPid) .. " [PID: " .. tostring(currentSelectedPid) .. "]"))
    imgui.text("Alvo Selecionado: " .. curTargetName)
    
    if allowAll then
        if imgui.button((isAll and "-> [X] TODOS OS JOGADORES (Sessao)" or "-> [  ] TODOS OS JOGADORES (Sessao)") .. "##all_" .. idTag) then onSelectCallback(-2) end
        imgui.same_line()
    end

    if imgui.button((isSelf and "-> [X] Voce Mesmo (Local)" or "-> [  ] Voce Mesmo (Local)") .. "##self_" .. idTag) then onSelectCallback(-1) end
    
    local players = getActivePlayersList()
    local otherPlayers = {}
    for _, pid in ipairs(players) do if pid ~= localPid then table.insert(otherPlayers, pid) end end

    if #otherPlayers == 0 then
        imgui.text("   (Nenhum outro jogador encontrado na sessao)")
    else
        imgui.text("Jogadores na Sessao:")
        for i, pid in ipairs(otherPlayers) do
            if (i - 1) % 2 ~= 0 then imgui.same_line() end
            local isSel = (currentSelectedPid == pid)
            if imgui.button(string.format("%s[%02d] %s##p_%s_%d", isSel and "[X] " or "[  ] ", pid, getPlayerName(pid), idTag, pid)) then
                onSelectCallback(pid)
            end
        end
    end
end

------------------------------------------------------------
-- IMGUI TAB RENDERERS
------------------------------------------------------------

local function renderTabJets()
    if not imgui.begin_tab_item("Jatos") then return end
    imgui.text("=== ESQUADRAO DE CACAS 20MM (DOGFIGHT) ===")
    imgui.text("Spawn Padrao: 5 Cacas Militares (Lazer 20mm)")
    imgui.spacing()
    imgui.text("Selecione o Alvo do Ataque Individual:")
    renderPlayerTargetSelector(S.selectedDogfightPid, function(pid) S.selectedDogfightPid = pid end, "dogfight")
    imgui.spacing()
    if imgui.button(">> DECOLAR ESQUADRAO (5 CACAS) NO ALVO <<##launch_jets_btn") then triggerDogfightAttack(S.selectedDogfightPid, 5) end
    imgui.same_line()
    if imgui.button(">> ATACAR TODA A SESSAO (2 CACAS POR PLAYER) <<##launch_jets_all_btn") then triggerDogfightAttackAllSession() end
    imgui.same_line()
    if imgui.button("Remover/Purgar Cacas do Mapa##clear_jets_btn") then clearActiveDogfightJets() end
    imgui.end_tab_item()
end

local function renderTabEarRape()
    if not imgui.begin_tab_item("Ear Rape") then return end
    imgui.text("=== TROLL PESADO (EAR RAPE & TERREMOTO) ===")
    imgui.text("Selecione o Alvo (Todos os Jogadores ou Individual):")
    renderPlayerTargetSelector(S.selectedEarRapePid, function(pid) S.selectedEarRapePid = pid end, "earrape", true)
    imgui.spacing()
    local cL, vL = imgui.checkbox("Incluir Relampagos & Trovoes##troll_lightning", S.trollLightning)
    if cL then S.trollLightning = vL end
    imgui.same_line()
    local cF, vF = imgui.checkbox("Incluir Flashbang Psicodelico##troll_flashbang", S.trollFlashbang)
    if cF then S.trollFlashbang = vF end
    imgui.same_line()
    local cM, vM = imgui.checkbox("Modo Mudo Local (Protege seus ouvidos ao atacar)##troll_mute_local", S.muteEarRapeLocal)
    if cM then S.muteEarRapeLocal = vM end
    imgui.spacing()
    if imgui.button("Disparo Rapido (5s)##troll_5s_btn") then triggerEarRapeTremor(S.selectedEarRapePid, 5) end
    imgui.same_line()
    if imgui.button("Disparo Longo (10s)##troll_10s_btn") then triggerEarRapeTremor(S.selectedEarRapePid, 10) end
    imgui.same_line()
    if not S.trollAudioLoop then
        if imgui.button("INICIAR LOOP INFINITO##troll_loop_start_btn") then triggerEarRapeTremor(S.selectedEarRapePid, 0) end
    else
        if imgui.button("PARAR LOOP DO TROLL##troll_loop_stop_btn") then stopTrollAudioHarassment() end
    end
    imgui.same_line()
    if imgui.button("Parar Efeitos##troll_stop_all_btn") then stopTrollAudioHarassment() end
    imgui.end_tab_item()
end

local function renderTabContactInvites()
    if not imgui.begin_tab_item("Envio de Contatos") then return end
    imgui.text("=== SPAM DE CONVITES DE CONTATOS ===")
    imgui.text("Destinatario dos Convites:")
    renderPlayerTargetSelector(S.contactSelectedPid, function(pid) S.contactSelectedPid = pid end, "contacts")
    imgui.spacing()
    imgui.text("Informacoes do Convite:")
    imgui.text("Assunto: Convite para atividade | Atividade: Penthouse")
    imgui.text("Metodo: SMS Nativo + Script Events de Rede")
    imgui.spacing()
    if imgui.button(">> ENVIAR TODOS OS CONTATOS (SPAM EM MASSA) <<##spam_all_contacts_btn") then sendAllContactInvites(S.contactSelectedPid) end
    imgui.same_line()
    if imgui.button("Parar Envio em Massa##stop_spam_contacts_btn") then S.contactIsSpamming = false end
    imgui.end_tab_item()
end

local function renderTabAirdrop()
    if not imgui.begin_tab_item("Airdrop Militar") then return end
    imgui.text("=== CONFIGURACAO DO AIRDROP MILITAR ===")
    imgui.text("Local de Entrega:")
    if imgui.button((S.airdropLocationMode == 1 and "[X] Na Frente (15m)" or "[  ] Na Frente (15m)") .. "##loc_front") then S.airdropLocationMode = 1; S.selectedAirdropPid = -1 end
    imgui.same_line()
    if imgui.button((S.airdropLocationMode == 2 and "[X] No Jogador Alvo" or "[  ] No Jogador Alvo") .. "##loc_player") then S.airdropLocationMode = 2 end

    if S.airdropLocationMode == 2 then
        imgui.spacing()
        imgui.text("Selecione o Jogador Destinatario:")
        renderPlayerTargetSelector(S.selectedAirdropPid, function(pid) S.selectedAirdropPid = pid end, "airdrop_target")
    end

    imgui.spacing(); imgui.separator(); imgui.spacing()
    imgui.text("Tipo de Carga:")
    if imgui.button((S.airdropDropType == 1 and "[X] 1. Suprimento Tatico (Armas + Colete 100%)" or "[  ] 1. Suprimento Tatico (Armas + Colete 100%)") .. "##type_tactical") then S.airdropDropType = 1 end
    if imgui.button((S.airdropDropType == 2 and "[X] 2. Veiculo Especial (Max Upgrade)" or "[  ] 2. Veiculo Especial (Max Upgrade)") .. "##type_veh") then S.airdropDropType = 2 end
    if imgui.button((S.airdropDropType == 3 and "[X] 3. Caixa Armadilha Explosiva (Trap)" or "[  ] 3. Caixa Armadilha Explosiva (Trap)") .. "##type_trap") then S.airdropDropType = 3 end

    if S.airdropDropType == 2 then
        imgui.spacing()
        imgui.text("Selecione o Veiculo do Airdrop:")
        for _, v in ipairs(Presets.airdropVehicles) do
            local isSel = (S.airdropVehicleModel == v.model)
            if imgui.button((isSel and "[X] " or "[  ] ") .. v.label .. "##veh_preset_" .. v.model) then
                S.airdropVehicleModel = v.model
                S.airdropVehicleName = v.label
            end
            imgui.same_line()
        end
        imgui.spacing()
    end

    imgui.spacing(); imgui.separator(); imgui.spacing()
    if imgui.button(">> SOLICITAR AIRDROP AGORA <<##request_airdrop_btn") then triggerAirdropDrop(S.airdropDropType, S.selectedAirdropPid, S.airdropLocationMode) end
    imgui.same_line()
    if imgui.button("Cancelar / Limpar Airdrop Ativo##cancel_airdrop_btn") then cancelActiveAirdrop(false) end
    imgui.end_tab_item()
end

local function renderTabVehicleControls()
    if not imgui.begin_tab_item("Controles de Veiculo") then return end
    imgui.spacing()
    imgui.text("Acoes com Veiculo na Mira / Proximo:")
    imgui.separator()
    imgui.spacing()

    if imgui.button("Levantar Veiculo (+ " .. math.floor(S.liftHeight) .. "m)##lift_btn") then
        script.run_in_callback(function()
            local veh = getTargetVehicle()
            if veh then LiftVehicle(veh, S.liftHeight); notify.success("Veiculo", "Veiculo levantado no ar!")
            else notify.warn("Veiculo", "Nenhum veiculo encontrado!") end
        end)
    end
    imgui.same_line()
    if imgui.button(S.isHoldingVehicle and "Soltar Veiculo##hold_btn" or "Segurar no Ar (Telecinese)##hold_btn") then
        HoldVehicleLoop(getTargetVehicle())
    end

    imgui.spacing()
    if imgui.button("Arremessar Veiculo (Throw)##launch_btn") then
        script.run_in_callback(function()
            local veh = S.isHoldingVehicle and S.heldVehicle or getTargetVehicle()
            if veh then
                S.isHoldingVehicle = false
                LaunchVehicle(veh, S.launchForce)
                notify.success("Veiculo", "Veiculo arremessado!")
            end
        end)
    end
    imgui.same_line()
    if imgui.button("Esmagar no Chao (Slam)##slam_btn") then
        script.run_in_callback(function()
            local veh = S.isHoldingVehicle and S.heldVehicle or getTargetVehicle()
            if veh then S.isHoldingVehicle = false; SlamVehicle(veh); notify.success("Veiculo", "Veiculo esmagado!") end
        end)
    end

    local cSpinPlayer, vSpinPlayer = imgui.checkbox("Beyblade: Veiculo do Player (Girar no Chao)##spin_my_veh", S.spinPlayerVehActive)
    if cSpinPlayer then S.spinPlayerVehActive = vSpinPlayer; if S.spinPlayerVehActive then startSpinPlayerVehLoop() end end

    imgui.spacing(); imgui.separator(); imgui.spacing()
    imgui.text("Altura de Elevacao (Metros):")
    if imgui.button("5m##h5") then S.liftHeight = 5.0 end
    imgui.same_line()
    if imgui.button("10m##h10") then S.liftHeight = 10.0 end
    imgui.same_line()
    if imgui.button("25m##h25") then S.liftHeight = 25.0 end
    imgui.same_line()
    if imgui.button("50m##h50") then S.liftHeight = 50.0 end

    imgui.spacing()
    imgui.text("Velocidade / Forca de Arremesso:")
    if imgui.button("Suave (50)##f50") then S.launchForce = 50.0 end
    imgui.same_line()
    if imgui.button("Media (150)##f150") then S.launchForce = 150.0 end
    imgui.same_line()
    if imgui.button("Pesada (300)##f300") then S.launchForce = 300.0 end
    imgui.same_line()
    if imgui.button("SUPER ARREMESSO (600)##f600") then S.launchForce = 600.0 end

    imgui.spacing(); imgui.separator(); imgui.spacing()
    imgui.text("Acoes com Jogadores (Carregar no Colo):")
    if imgui.button(S.isCarryingPlayer and "Soltar Jogador do Colo##carry_ply_btn" or "Carregar Jogador no Colo (Carry in Arms)##carry_ply_btn") then
        startCarryingPlayer(getTargetPlayerPed())
    end
    imgui.end_tab_item()
end

local function renderTabAreaChaos()
    if not imgui.begin_tab_item("Caos de Area & Sessao") then return end
    imgui.spacing()
    imgui.text("Caos em Massa de Veiculos & Poderes de Mundo:")
    imgui.separator()
    imgui.spacing()

    if imgui.button("Levantar TODOS os Veiculos Proximos##area_lift") then
        script.run_in_callback(function()
            local count = 0
            for _, veh in ipairs(getAllNearbyVehicles(100.0)) do LiftVehicle(veh, S.liftHeight); count = count + 1 end
            notify.success("Caos", "Levantou " .. count .. " veiculos proximos!")
        end)
    end
    imgui.same_line()
    if imgui.button("Arremessar TODOS no Ceu##area_yeet") then
        script.run_in_callback(function()
            local count = 0
            for _, veh in ipairs(getAllNearbyVehicles(100.0)) do LaunchVehicle(veh, S.launchForce); count = count + 1 end
            notify.success("Caos", "Arremessou " .. count .. " veiculos em orbita!")
        end)
    end

    imgui.spacing()
    local cSpinArea, vSpinArea = imgui.checkbox("Beyblade Continuo em Area (100m)##area_spin_chk", S.spinAreaVehsActive)
    if cSpinArea then S.spinAreaVehsActive = vSpinArea; if S.spinAreaVehsActive then startSpinAreaVehsLoop() end end

    local cLev, vLev = imgui.checkbox("Pulo Continuo de Carros (Area Bounce)##area_lev_chk", S.infiniteLevitateActive)
    if cLev then S.infiniteLevitateActive = vLev; if S.infiniteLevitateActive then startInfiniteLevitateLoop() end end

    local cVort, vVort = imgui.checkbox("Vortice Gravitacional (Tornado de Carros)##vort_chk", S.vortexActive)
    if cVort then S.vortexActive = vVort; if S.vortexActive then startVortexLoop() end end

    local cUfo, vUfo = imgui.checkbox("UFO Party Mode (Luzes, Neon RGB & Sirenes)##ufo_chk", S.ufoDiscoActive)
    if cUfo then S.ufoDiscoActive = vUfo; if S.ufoDiscoActive then startUfoDiscoLoop() end end

    local cPush, vPush = imgui.checkbox("Repulsor de Veiculos (Onda de Choque)##rep_chk", S.pushRepulsorActive)
    if cPush then S.pushRepulsorActive = vPush; if S.pushRepulsorActive then startPushRepulsorLoop() end end

    local cRain, vRain = imgui.checkbox("Chuva de Meteoros de Veiculos##rain_chk", S.vehicleRainActive)
    if cRain then S.vehicleRainActive = vRain; if S.vehicleRainActive then startVehicleRainLoop() end end

    local cShield, vShield = imgui.checkbox("Escudo Orbital de Supercarros##shd_chk", S.vehicleShieldActive)
    if cShield then S.vehicleShieldActive = vShield; if S.vehicleShieldActive then startVehicleShieldLoop() end end

    imgui.spacing()
    if imgui.button("Boliche Vertical de Onibus (Panto Launcher)##bus_bowl_btn") then setupBusBowling() end
    imgui.same_line()
    if imgui.button("Muralha Fortaleza de Onibus##fort_btn") then triggerBusFortressWall() end

    imgui.spacing()
    local cSnake, vSnake = imgui.checkbox("Follow the Leader (Cobra de Veiculos)##follow_leader_chk", S.vehicleSnakeActive)
    if cSnake then S.vehicleSnakeActive = vSnake; if S.vehicleSnakeActive then startVehicleSnakeLoop() end end

    local cZomb, vZomb = imgui.checkbox("Apocalipse Zumbi Agressivo##zomb_ped_chk", S.zombiePedOutbreakActive)
    if cZomb then S.zombiePedOutbreakActive = vZomb; if S.zombiePedOutbreakActive then startZombiePedOutbreakLoop() end end

    imgui.spacing(); imgui.separator(); imgui.spacing()
    imgui.text("Clima e Atmosfera da Sessao (Halloween & Globais):")
    if imgui.button(S.halloweenModeActive and ">> DESATIVAR MODO HALLOWEEN <<##hw_btn" or ">> ATIVAR MODO HALLOWEEN TERROR <<##hw_btn") then
        toggleHalloweenWeather()
    end

    imgui.spacing()
    if imgui.button("Neve de Natal (XMAS)##w_xmas") then setSessionWeather("XMAS", false) end
    imgui.same_line()
    if imgui.button("Tempestade Severa (THUNDER)##w_thun") then setSessionWeather("THUNDER", false) end
    imgui.same_line()
    if imgui.button("Neblina Densa (FOGGY)##w_fog") then setSessionWeather("FOGGY", false) end
    if imgui.button("Dia Ensolarado (EXTRASUNNY)##w_sun") then setSessionWeather("EXTRASUNNY", false) end
    imgui.same_line()
    if imgui.button("Chuva com Raios (RAIN)##w_rain") then setSessionWeather("RAIN", false) end

    imgui.spacing(); imgui.separator(); imgui.spacing()
    imgui.text("Ciclo Rapido de Horas do Dia (Timelapse Dia & Noite):")
    if imgui.button(S.fastTimeActive and ">> DESATIVAR CICLO RAPIDO DE HORAS <<##ft_btn" or ">> ATIVAR CICLO RAPIDO DE HORAS (TIMELAPSE) <<##ft_btn") then
        toggleFastTimeCycle()
    end
    imgui.same_line()
    imgui.text("Velocidade: " .. tostring(S.fastTimeSpeed) .. "x")
    if imgui.button("5x##spd_5") then S.fastTimeSpeed = 5 end
    imgui.same_line()
    if imgui.button("15x##spd_15") then S.fastTimeSpeed = 15 end
    imgui.same_line()
    if imgui.button("30x##spd_30") then S.fastTimeSpeed = 30 end
    imgui.same_line()
    if imgui.button("60x##spd_60") then S.fastTimeSpeed = 60 end

    imgui.end_tab_item()
end

local function renderTabStuntTracks()
    if not imgui.begin_tab_item("Pistas & Rampas") then return end
    imgui.spacing()
    imgui.text("Mega Caos de Pistas & Estruturas Acrobaticas (Inception)")
    imgui.separator()
    imgui.spacing()

    if imgui.button(">> GERAR MEGA CAOS TOTAL (APARECER TUDO: CEU + ASFALTO) <<##gen_all_chaos_btn") then spawnTotalSupremeChaos() end
    imgui.spacing()

    if imgui.button("Cyber Arena Tube Highway (Ceu)##gen_cyber_tube_btn") then spawnStuntTrack(Presets.cyber_arena_highway, "Cyber Arena Tube Highway") end
    imgui.same_line()
    if imgui.button("Arena Neon Speed Circuit (Ceu)##gen_neon_speed_btn") then spawnStuntTrack(Presets.arena_neon_speed, "Arena Neon Speed Circuit") end

    if imgui.button("Mega Arena Jump & Loop (Ceu)##gen_mega_jump_btn") then spawnStuntTrack(Presets.mega_arena_jump, "Mega Arena Jump & Loop") end
    imgui.same_line()
    if imgui.button("Mega Rodovia Acrobatica (Stunt Ceu)##gen_highway_btn") then spawnStuntTrack(Presets.stunt_highway, "Mega Rodovia Acrobatica") end

    imgui.spacing(); imgui.separator(); imgui.spacing()
    imgui.text("Rampas Frontais Instantaneas (A sua frente):")
    if imgui.button("Rampa Mega Salto (Grande)##ramp_l") then spawnInstantFrontRamp("stt_prop_stunt_jump_l") end
    imgui.same_line()
    if imgui.button("Rampa Media##ramp_m") then spawnInstantFrontRamp("stt_prop_stunt_jump_m") end
    imgui.same_line()
    if imgui.button("Looping 360 Frontal##ramp_loop") then spawnInstantFrontRamp("stt_prop_stunt_track_dloop") end
    imgui.same_line()
    if imgui.button("Tubo Acelerador##ramp_tube") then spawnInstantFrontRamp("stt_prop_stunt_tube_l") end

    imgui.spacing(); imgui.separator(); imgui.spacing()
    imgui.text("Gerenciamento de Objetos Spawados:")
    if imgui.button("Desfazer Ultimo Objeto Criado##undo_stunt_btn") then undoLastStuntObject() end
    imgui.same_line()
    if imgui.button("Limpar Todas as Rampas e Pistas Criadas##clear_stunts_btn") then clearAllStuntObjects() end

    imgui.spacing(); imgui.separator(); imgui.spacing()
    imgui.text("Altura das Pistas Aereas no Ceu (Z): " .. math.floor(S.stunt_altitude) .. " metros")
    if imgui.button("50m##alt50") then S.stunt_altitude = 50.0 end
    imgui.same_line()
    if imgui.button("100m##alt100") then S.stunt_altitude = 100.0 end
    imgui.same_line()
    if imgui.button("160m##alt160") then S.stunt_altitude = 160.0 end
    imgui.same_line()
    if imgui.button("250m##alt250") then S.stunt_altitude = 250.0 end
    imgui.end_tab_item()
end

local function renderTabArenaObjectSpawner()
    if not imgui.begin_tab_item("Props Arena & Stand") then return end
    imgui.spacing()
    imgui.text("Catalogo de Spawn Avulso - Arena War, Iate & Heists (Stand Export)")
    imgui.separator()
    imgui.spacing()

    imgui.text("Alvo do Spawn:")
    renderPlayerTargetSelector(S.selectedPropSpawnPid, function(pid) S.selectedPropSpawnPid = pid end, "prop_sp_target")
    imgui.spacing()

    imgui.text("Distancia: " .. string.format("%.1f m", S.customSpawnDistance) .. " | Altura: " .. string.format("%.1f m", S.customSpawnHeight))
    if imgui.button("5m##sp_d5") then S.customSpawnDistance = 5.0 end
    imgui.same_line()
    if imgui.button("15m##sp_d15") then S.customSpawnDistance = 15.0 end
    imgui.same_line()
    if imgui.button("25m##sp_d25") then S.customSpawnDistance = 25.0 end
    imgui.same_line()
    if imgui.button("Chao (-1m)##sp_z_neg1") then S.customSpawnHeight = -1.0 end
    imgui.same_line()
    if imgui.button("Nivel (0m)##sp_z_0") then S.customSpawnHeight = 0.0 end

    imgui.spacing(); imgui.separator(); imgui.spacing()
    imgui.text("Ponto Fixo Customizado (OVNI / p_spinning_anus_s):")
    if imgui.button(">> SPAWNAR OVNI NO PONTO FIXO <<##sp_fixed_ufo") then spawnFixedCoordsUfo() end
    imgui.same_line()
    if imgui.button("Remover OVNI Fixo##rem_fixed_ufo") then removeFixedCoordsUfo() end

    imgui.spacing(); imgui.separator(); imgui.spacing()
    imgui.text(">>> PROJETO MAZE BANK (4x Portais Neon 8X + Nucleo OVNI) <<<")
    if imgui.button(">> SPAWNAR PROJETO MAZE BANK <<##sp_mazebank_btn") then spawnMazeBankProject() end
    imgui.same_line()
    if imgui.button(">> TELEPORTAR TODOS AO TOPO DO MAZE BANK <<##tp_all_to_mazebank_btn") then teleportAllPlayersToMazeBank() end
    imgui.same_line()
    if imgui.button("Remover Projeto Maze Bank##rem_mazebank_btn") then clearMazeBankProject() end

    imgui.spacing(); imgui.separator(); imgui.spacing()
    imgui.text("Props Populares (Spawn no Alvo):")
    if imgui.button("Tubo 4X Speed##sp_t4xsp") then spawnSinglePropAtPlayer("ar_prop_ar_tube_4x_speed", S.customSpawnDistance, S.customSpawnHeight, S.customSpawnYaw, S.customSpawnFreeze, S.selectedPropSpawnPid) end
    imgui.same_line()
    if imgui.button("Portal Neon 8X##sp_ng8_1") then spawnSinglePropAtPlayer("ar_prop_ar_neon_gate8x_01a", S.customSpawnDistance, S.customSpawnHeight, S.customSpawnYaw, S.customSpawnFreeze, S.selectedPropSpawnPid) end
    imgui.same_line()
    if imgui.button("Anel Speed Ring##sp_ring") then spawnSinglePropAtPlayer("ar_prop_ar_speed_ring", S.customSpawnDistance, S.customSpawnHeight, S.customSpawnYaw, S.customSpawnFreeze, S.selectedPropSpawnPid) end
    imgui.same_line()
    if imgui.button("Mega Loop##sp_loop") then spawnSinglePropAtPlayer("ar_prop_ar_jump_loop", S.customSpawnDistance, S.customSpawnHeight, S.customSpawnYaw, S.customSpawnFreeze, S.selectedPropSpawnPid) end
    imgui.spacing()
    if imgui.button("Desfazer Ultimo Objeto##undo_obj_spawner") then undoLastStuntObject() end
    imgui.same_line()
    if imgui.button("Limpar Todos os Objetos Criados##clear_all_obj_spawner") then clearAllStuntObjects() end
    imgui.end_tab_item()
end

local function renderTabPlayerAttachments()
    if not imgui.begin_tab_item("Anexar nos Players") then return end
    imgui.spacing()
    imgui.text("Anexar Objetos, Aderecos e Gaiolas Inescapaveis nos Jogadores")
    imgui.separator()
    imgui.spacing()

    local localPid = getLocalPid()
    local currentTargetName = (S.selectedAttachmentPid == -1 or S.selectedAttachmentPid == localPid) and "VOCE MESMO" or getPlayerName(S.selectedAttachmentPid)

    local isPresetAll = S.attachPresetModeAll or false
    if imgui.button((not isPresetAll and "[X] Individual (Jogador Especifico)" or "[  ] Individual (Jogador Especifico)") .. "##mode_indiv") then S.attachPresetModeAll = false end
    imgui.same_line()
    if imgui.button((isPresetAll and "[X] Coletivo (TODOS da Sessao)" or "[  ] Coletivo (TODOS da Sessao)") .. "##mode_all") then S.attachPresetModeAll = true end

    if not S.attachPresetModeAll then
        imgui.spacing()
        imgui.text("Alvo Individual: " .. currentTargetName)
        renderPlayerTargetSelector(S.selectedAttachmentPid, function(pid) S.selectedAttachmentPid = pid end, "att_target")
    else
        imgui.spacing()
        imgui.text(">> MODO COLETIVO ATIVO: Os objetos e gaiolas serao aplicados em TODOS os jogadores! <<")
    end

    imgui.spacing(); imgui.separator(); imgui.spacing()
    imgui.text(">>> GAIOLAS INESCAPAVEIS (STAND C++ ENGINE) <<<")
    
    local function applyCage(cageHashOrName)
        if S.attachPresetModeAll then
            for _, pid in ipairs(getActivePlayersList()) do spawnAdvancedCageOnPlayer(pid, cageHashOrName) end
            notify.success("Gaiolas", "Gaiolas aplicadas em TODOS os jogadores!")
        else
            spawnAdvancedCageOnPlayer(S.selectedAttachmentPid, cageHashOrName)
        end
    end

    if imgui.button("Container Dourado Fechado##cage_gold") then applyCage("prop_gold_cont_01") end
    imgui.same_line()
    if imgui.button("Tubo Vertical Stunt 90 graus##cage_tube") then applyCage("stt_prop_stunt_tube_s") end
    imgui.same_line()
    if imgui.button("Gaiolas Cruzadas 90 graus##cage_cross") then applyCage("prop_rub_cage01a") end

    if imgui.button("Caixa 4 Cercas de Arame##cage_fences") then applyCage("prop_fnclink_03e") end
    imgui.same_line()
    if imgui.button("Jaula de Macaco##cage_ape") then applyCage("v_med_apecrate") end
    imgui.same_line()
    if imgui.button(">> GAIOLA ALEATORIA <<##cage_rand") then applyCage("random") end

    imgui.spacing(); imgui.separator(); imgui.spacing()
    imgui.text("Anexar Aderecos e Props no Corpo do Jogador:")
    local function applyProp(modelOrHash, boneId, offX, offY, offZ, rotX, rotY, rotZ)
        if S.attachPresetModeAll then
            for _, pid in ipairs(getActivePlayersList()) do attachPropToPlayer(pid, modelOrHash, boneId, offX, offY, offZ, rotX, rotY, rotZ) end
            notify.success("Anexar", "Objeto anexado em TODOS os jogadores!")
        else
            attachPropToPlayer(S.selectedAttachmentPid, modelOrHash, boneId, offX, offY, offZ, rotX, rotY, rotZ)
        end
    end

    if imgui.button("Cone na Cabeca##att_cone") then applyProp("prop_mp_cone_01", 24818, 0.0, 0.0, 0.70, 0.0, 90.0, 0.0) end
    imgui.same_line()
    if imgui.button("Privada##att_toilet") then applyProp("prop_ld_toilet_01", 11816, 0.0, 0.0, -0.25, 0.0, 90.0, 0.0) end
    imgui.same_line()
    if imgui.button("Gaiola Cabeça##att_cage") then applyProp("prop_feeder1_cr", 11816, 0.0, 0.0, -0.6, 0.0, 90.0, 0.0) end

    if imgui.button("Fogueira Ardente##att_fire") then applyProp("prop_beach_fire", 11816, 0.0, 0.0, -0.3, 0.0, 90.0, 0.0) end
    imgui.same_line()
    if imgui.button("Arvore de Natal##att_xmas") then applyProp("prop_mp_xmas_tree_01", 11816, 0.0, 0.0, -0.5, 0.0, 90.0, 0.0) end
    imgui.same_line()
    if imgui.button("Roda do Cassino##att_cwheel") then applyProp(0x8EB05D67, 24818, -0.808, -0.255, -0.120, 0.0, 270.0, 180.0) end
    imgui.same_line()
    if imgui.button("Disco Voador OVNI##att_ufo") then applyProp("p_spinning_anus_s", 11816, 0.0, 0.0, 1.5, 0.0, 90.0, 0.0) end

    imgui.spacing(); imgui.separator(); imgui.spacing()
    local cModel, vModel = imgui.input_text("Modelo Custom##cust_att_model", S.customAttachModelInput or "prop_mp_cone_01")
    if cModel then S.customAttachModelInput = vModel end
    imgui.same_line()
    if imgui.button("Anexar Digitado##att_custom_btn") then applyProp(S.customAttachModelInput or "prop_mp_cone_01", 24818, 0.0, 0.0, 0.0, 0.0, 90.0, 0.0) end

    imgui.spacing(); imgui.separator(); imgui.spacing()
    if not S.attachPresetModeAll then
        if imgui.button("Remover Objetos de " .. currentTargetName .. "##rem_sel_props") then removePlayerAttachedProps(S.selectedAttachmentPid) end
        imgui.same_line()
    end
    if imgui.button("Remover de TODOS os Jogadores##rem_all_props") then removeAllAttachedProps() end
    imgui.end_tab_item()
end

local function renderTabAngelFloatie()
    if not imgui.begin_tab_item("Boia Angel Floatie") then return end
    imgui.spacing()
    imgui.text("Self Floatie - Boia de Cintura Sincronizada em Rede")
    imgui.separator()
    imgui.spacing()

    local buttonText = (S.angelFloatieActive and isValidEntity(S.angelFloatieObject)) and "Remover Boia (Angel Floatie)##rem_angel_fl" or "Anexar Boia (Angel Floatie)##att_angel_fl"
    if imgui.button(buttonText) then toggleAngelFloatie() end
    imgui.spacing()
    imgui.text("Status: " .. ((S.angelFloatieActive and isValidEntity(S.angelFloatieObject)) and "ANEXADO (SINCRONIZADO)" or "DESLIGADO"))
    imgui.end_tab_item()
end

local function renderTabCutscenes()
    if not imgui.begin_tab_item("Cutscenes Online") then return end
    imgui.spacing()
    imgui.text("Reproduzir Cutscenes Online no Jogador Selecionado")
    imgui.separator()
    imgui.spacing()

    renderPlayerTargetSelector(S.selectedCutscenePid, function(pid) S.selectedCutscenePid = pid end, "cutscene_target")
    imgui.spacing(); imgui.separator(); imgui.spacing()

    if imgui.button(">> PARAR CUTSCENE ATUAL <<##stop_cutscene_btn") then stopCurrentCutscene() end
    imgui.spacing(); imgui.separator(); imgui.spacing()

    if imgui.button("Lamar Drive Scene (Intro GTA Online)##cs_lamar") then playOnlineCutscene("MP_INTRO_LAMAR_DRIVE_SCENE", S.selectedCutscenePid) end
    imgui.same_line()
    if imgui.button("Casino Penthouse Party##cs_cas_pent") then playOnlineCutscene("hs3_intro_p1", S.selectedCutscenePid) end
    imgui.same_line()
    if imgui.button("Cayo Perico Beach Party##cs_cayo_beach") then playOnlineCutscene("h4_intro_beach_party", S.selectedCutscenePid) end

    imgui.spacing()
    if imgui.button(">> ENVIAR TODOS OS JOGADORES DA SESSAO PARA CUTSCENE DO LAMAR <<##cs_all_lamar") then
        for _, pid in ipairs(getActivePlayersList()) do playOnlineCutscene("MP_INTRO_LAMAR_DRIVE_SCENE", pid) end
        notify.success("Cutscenes", "Cutscene enviada para todos os jogadores!")
    end
    imgui.end_tab_item()
end

local function renderTabOptionsAndHotkeys()
    if not imgui.begin_tab_item("Opcoes & Atalhos") then return end
    imgui.spacing()
    imgui.text("Configuracoes & Comportamento:")
    imgui.separator()
    imgui.spacing()

    local c1, v1 = imgui.checkbox("Explodir / Incendiar Veiculos ao Lancar##ign_chk", S.igniteOnLaunch)
    if c1 then S.igniteOnLaunch = v1 end

    local c2, v2 = imgui.checkbox("Tornar Veiculo Invencivel ao Manipular##inv_chk", S.makeInvincible)
    if c2 then S.makeInvincible = v2 end

    local c4, v4 = imgui.checkbox("Desativar Ragdoll do Player (Sem quedas)##rag_chk", S.disableRagdoll)
    if c4 then S.disableRagdoll = v4; updateRagdollState(); notify.info("Opcoes", S.disableRagdoll and "Ragdoll DESATIVADO" or "Ragdoll ATIVADO") end

    imgui.spacing(); imgui.separator(); imgui.spacing()
    local c3, v3 = imgui.checkbox("Ativar Atalhos de Telecinese (SPACE = Lancar | E = Pegar/Soltar)##hk_chk", S.hotkeysEnabled)
    if c3 then S.hotkeysEnabled = v3; if S.hotkeysEnabled then startHotkeyLoop() end end
    imgui.end_tab_item()
end

------------------------------------------------------------
-- IMGUI ROOT GUI
------------------------------------------------------------

local function renderGUI()
    if not imgui.begin_tab_bar("SpyreX_Main_Tabs") then return end
    renderTabJets()
    renderTabEarRape()
    renderTabContactInvites()
    renderTabAirdrop()
    renderTabVehicleControls()
    renderTabAreaChaos()
    renderTabStuntTracks()
    renderTabArenaObjectSpawner()
    renderTabPlayerAttachments()
    renderTabAngelFloatie()
    renderTabCutscenes()
    renderTabOptionsAndHotkeys()
    imgui.end_tab_bar()
end

------------------------------------------------------------
-- REGISTRO DO MENU NO NEWWAY / STAND
------------------------------------------------------------

local spyreTab = nil
pcall(function()
    if gui and gui.add_tab then spyreTab = gui.add_tab("SpyreX") end
end)

if spyreTab and spyreTab.add_imgui then
    spyreTab:add_imgui(renderGUI)
else
    gui.add_imgui(renderGUI)
end

------------------------------------------------------------
-- INICIALIZACAO
------------------------------------------------------------

showFeedNotification("~p~SpyreX Suite v2.1.1 carregado com sucesso!")