--[[
    SpyreX.lua
    Versao: 2.1.1 - Advanced Ultimate Suite
    Contendo: Jatos 20mm, Ear Rape & Tremor, Spam de Convites, Airdrop Militar,
              Controles de Veiculo & Telecinese, Caos de Area & Sessao (Lightning Lab HDR & Clima),
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
    makeInvincible = true,
    disableRagdoll = false,
    autoClaimScriptHost = false,
    autoScriptHostLoopActive = false,
    isHoldingVehicle = false,
    heldVehicle = nil,
    isCarryingPlayer = false,
    carriedPlayerPed = nil,

    -- XML & Custom Super Vehicles
    spawnedCustomVehicle = nil,
    spawnedCustomAttachments = {},
    customXmlVehiclePath = "SpinePincher.xml",
    isSpawningCustomVeh = false,
    xmlSpawnInAir = false,
    xmlSpawnHeightOffset = 0.0,
    xmlWarpInside = true,
    xmlInvincible = true,
    discoveredXmlFiles = {},
    lastXmlSpawnedName = "",

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

    -- Universal Live Attachment Tuner
    tunerSelectedIdx = 1,
    tunerName = "Cone na Cabeca",
    tunerModel = "prop_mp_cone_01",
    tunerBone = 24818,
    tunerX = 0.420,
    tunerY = 0.030,
    tunerZ = -0.010,
    tunerRotX = 0.0,
    tunerRotY = 90.0,
    tunerRotZ = 0.0,
    tunerObj = nil,

    -- Presets Salvos Oficiais
    katanaRightX = 0.480,
    katanaRightY = -0.170,
    katanaRightZ = -0.160,
    katanaRightRotX = -175.0,
    katanaRightRotY = 242.0,
    katanaRightRotZ = 0.0,

    coneX = 0.420,
    coneY = 0.030,
    coneZ = -0.010,
    coneRotX = 0.0,
    coneRotY = 90.0,
    coneRotZ = 0.0,

    -- Visual FX - Lightning Lab & HDR Storm
    isStrobeRunning = false,
    hdrStormActive = false,
    syncWeatherNetwork = true,
    syncLightningNetwork = true,

    -- Jets (Dogfight)
    activeDogfightJets = {},
    dogfightAttackRunning = false,
    isClearingDogfightJets = false,
    dogfightSessionId = 0,
    selectedDogfightPid = -1,
    lastDogfightTick = 0,

    -- Micro-Drone Tatico Overwatch Guardiao
    overwatchActive = false,
    overwatchLoopActive = false,
    overwatchDroneObj = nil,
    overwatchDroneModel = "m24_2_prop_m42_drone_01a",
    overwatchHeightOffset = 2.2,
    overwatchSideOffset = 0.0,
    overwatchAggressiveMode = true, -- Totalmente Agressivo por padrão (atira em todos no raio)
    overwatchProtectionRadius = 50.0,
    overwatchCooldown = 3.5,
    overwatchLastStrikeTime = 0,
    overwatchTargetPed = nil,
    overwatchLockStartTime = 0,
    overwatchWeaponMode = 1, -- 1: Mísseis Orbitais, 2: Metralhadora Tática, 3: Ambos Juntos (Metralhadora + Mísseis), 4: Kamikaze Suicida
    overwatchLastMissileTime = 0,
    overwatchMgDamage = 50,
    overwatchSoundId = -1,
    overwatchAnonymousKills = true, -- Kills Anônimas (Modo Fantasma): não atribui mortes ao jogador por padrão

    -- Drone Kamikaze Tático (Suicida)
    selectedKamikazePid = -1,
    activeKamikazeDrones = {},
    overwatchIsDiving = false,

    -- Ear Rape
    isTrollAudioActive = false,
    trollAudioLoop = false,
    trollLightning = true,
    trollFlashbang = true,
    muteEarRapeLocal = true,
    earRapeStepIndex = 0,
    selectedEarRapePid = -2,

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
    activeAnimName = nil,

    -- Kung Fu Performance
    kungFuShowRunning = false,
    kungFuElementType = 1, -- 1 = Fogo, 2 = Raios, 3 = Mistico / Espiritual
    kungFuWithDisciples = true,
    kungFuDisciplesCount = 2,
    activeKungFuDisciples = {},
    activeKungFuPtfx = {},
    kungFuLoopActive = false,
    kungFuSessionId = 0,

    -- Security & Account Watchdog (Detector de Reportes & Vote Kick)
    watchdogActive = true,
    watchdogLoopActive = false,
    watchdogKickVoteDetected = false,
    -- Custom Plate
    customPlateText = "SPYREX",
    customPlateStyle = 0,
    watchdogLastKickCheck = 0,
    watchdogBaselineSet = false,
    watchdogReportStats = {},
    watchdogRecentAlerts = {}

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
        { name = "Combat MG Mk2", model = "WEAPON_COMBATMG_MK2" },
        { name = "Heavy Sniper", model = "WEAPON_HEAVYSNIPER" }
    },

    airdropVehicles = {
        { label = "Oppressor Mk II", model = "oppressor2" },
        { label = "Vigilante", model = "vigilante" },
        { label = "Insurgent Custom .50cal", model = "insurgent3" },
        { label = "Tanque Khanjali", model = "khanjali" },
        { label = "Toreador", model = "toreador" },
        { label = "Deluxo", model = "deluxo" }
    },

    weapon_list = {
        ["Weapon Katana Left"] = {
            Prop = 'prop_cs_katana_01',
            PropBone = 24817, -- SKEL_Spine2
            PropPlacement = { 0.500, -0.170, 0.140, 5.0, -122.0, 0.0 },
            Used = {},
            Use = false
        },
        ["Weapon Katana Right"] = {
            Prop = 'prop_cs_katana_01',
            PropBone = 24817, -- SKEL_Spine2
            PropPlacement = { 0.480, -0.170, -0.160, -175.0, 242.0, 0.0 },
            Used = {},
            Use = false
        }
    },

    plushie_list = {
        { label = "Purple Kitty", model = "sum_prop_sum_arcade_plush_01a" },
        { label = "Green Kitty",  model = "sum_prop_sum_arcade_plush_02a" },
        { label = "Blue Kitty",   model = "sum_prop_sum_arcade_plush_03a" },
        { label = "Brown Kitty",  model = "sum_prop_sum_arcade_plush_04a" },
        { label = "Yellow Kitty", model = "sum_prop_sum_arcade_plush_05a" },
        { label = "Red Kitty",    model = "sum_prop_sum_arcade_plush_06a" },
        { label = "Princess",     model = "sum_prop_sum_arcade_plush_07a" },
        { label = "Wasabi Kitty", model = "sum_prop_sum_arcade_plush_08a" },
        { label = "Sensei",       model = "sum_prop_sum_arcade_plush_09a" }
    },

    tuner_objects = {
        { name = "Cone na Cabeca", model = "prop_mp_cone_01", bone = 24818, x = 0.420, y = 0.030, z = -0.010, rx = 0.0, ry = 90.0, rz = 0.0 },
        { name = "Katana Esquerda", model = "prop_cs_katana_01", bone = 24817, x = 0.500, y = -0.170, z = 0.140, rx = 5.0, ry = -122.0, rz = 0.0 },
        { name = "Katana Direita", model = "prop_cs_katana_01", bone = 24817, x = 0.480, y = -0.170, z = -0.160, rx = -175.0, ry = 242.0, rz = 0.0 },
        { name = "Vaso Sanitario (Toilet)", model = "prop_ld_toilet_01", bone = 11816, x = 0.300, y = -0.150, z = -0.000, rx = 176.0, ry = 270.0, rz = 0.0 },
        { name = "Gaiola na Cabeca", model = "prop_feeder1_cr", bone = 11816, x = 0.0, y = 0.0, z = -0.600, rx = 0.0, ry = 90.0, rz = 0.0 },
        { name = "Fogueira (Campfire)", model = "prop_beach_fire", bone = 11816, x = 0.050, y = -0.050, z = -0.000, rx = 0.0, ry = 90.0, rz = 0.0 },
        { name = "Arvore de Natal", model = "prop_mp_xmas_tree_01", bone = 11816, x = 0.0, y = 0.0, z = -0.500, rx = 0.0, ry = 90.0, rz = 0.0 },
        { name = "Roda do Cassino", model = 0x8EB05D67, bone = 24818, x = -0.808, y = -0.255, z = -0.120, rx = 0.0, ry = 270.0, rz = 180.0 },
        { name = "OVNI (Disco Voador)", model = "p_spinning_anus_s", bone = 11816, x = 0.0, y = 0.0, z = 1.500, rx = 0.0, ry = 90.0, rz = 0.0 },
        { name = "Purple Kitty", model = "sum_prop_sum_arcade_plush_01a", bone = 24818, x = 0.270, y = 0.010, z = -0.150, rx = 186.0, ry = 88.0, rz = -10.0 },
        { name = "Green Kitty", model = "sum_prop_sum_arcade_plush_02a", bone = 24818, x = 0.270, y = 0.010, z = -0.150, rx = 186.0, ry = 88.0, rz = -10.0 },
        { name = "Blue Kitty", model = "sum_prop_sum_arcade_plush_03a", bone = 24818, x = 0.270, y = 0.010, z = -0.150, rx = 186.0, ry = 88.0, rz = -10.0 },
        { name = "Brown Kitty", model = "sum_prop_sum_arcade_plush_04a", bone = 24818, x = 0.270, y = 0.010, z = -0.150, rx = 186.0, ry = 88.0, rz = -10.0 },
        { name = "Yellow Kitty", model = "sum_prop_sum_arcade_plush_05a", bone = 24818, x = 0.270, y = 0.010, z = -0.150, rx = 186.0, ry = 88.0, rz = -10.0 },
        { name = "Red Kitty", model = "sum_prop_sum_arcade_plush_06a", bone = 24818, x = 0.270, y = 0.010, z = -0.150, rx = 186.0, ry = 88.0, rz = -10.0 },
        { name = "Princess Kitty", model = "sum_prop_sum_arcade_plush_07a", bone = 24818, x = 0.270, y = 0.010, z = -0.150, rx = 186.0, ry = 88.0, rz = -10.0 },
        { name = "Wasabi Kitty", model = "sum_prop_sum_arcade_plush_08a", bone = 24818, x = 0.270, y = 0.010, z = -0.150, rx = 186.0, ry = 88.0, rz = -10.0 },
        { name = "Sensei Kitty", model = "sum_prop_sum_arcade_plush_09a", bone = 24818, x = 0.270, y = 0.010, z = -0.150, rx = 186.0, ry = 88.0, rz = -10.0 },
        { name = "Modelo Customizado", model = "custom", bone = 24818, x = 0.0, y = 0.0, z = 0.0, rx = 0.0, ry = 90.0, rz = 0.0 }
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
    success = function(title, msg)
        pcall(function()
            if gui and gui.show_message then gui.show_message(title, tostring(msg)) end
            if log and log.info then log.info("[" .. title .. "] " .. tostring(msg)) end
        end)
        showFeedNotification("~g~[" .. tostring(title) .. "] ~s~" .. tostring(msg))
    end,
    info = function(title, msg)
        pcall(function()
            if gui and gui.show_message then gui.show_message(title, tostring(msg)) end
            if log and log.info then log.info("[" .. title .. "] " .. tostring(msg)) end
        end)
        showFeedNotification("~b~[" .. tostring(title) .. "] ~s~" .. tostring(msg))
    end,
    warn = function(title, msg)
        pcall(function()
            if gui and gui.show_message then gui.show_message(title, tostring(msg)) end
            if log and log.warning then log.warning("[" .. title .. "] " .. tostring(msg)) end
        end)
        showFeedNotification("~y~[" .. tostring(title) .. "] ~s~" .. tostring(msg))
    end,
    error = function(title, msg)
        pcall(function()
            if gui and gui.show_message then gui.show_message(title, tostring(msg)) end
            if log and log.error then log.error("[" .. title .. "] " .. tostring(msg)) end
        end)
        showFeedNotification("~r~[" .. tostring(title) .. "] ~s~" .. tostring(msg))
    end
}

local function getControlOfEntity(ent)
    if not isValidEntity(ent) then return false end
    pcall(function()
        if NETWORK and NETWORK.NETWORK_HAS_CONTROL_OF_ENTITY and not NETWORK.NETWORK_HAS_CONTROL_OF_ENTITY(ent) then
            if NETWORK.NETWORK_REQUEST_CONTROL_OF_ENTITY then NETWORK.NETWORK_REQUEST_CONTROL_OF_ENTITY(ent) end
        end
        if ENTITY and ENTITY.SET_ENTITY_AS_MISSION_ENTITY then ENTITY.SET_ENTITY_AS_MISSION_ENTITY(ent, true, true) end
        if ENTITY and ENTITY.SET_ENTITY_DYNAMIC then ENTITY.SET_ENTITY_DYNAMIC(ent, true) end
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
    -- Substituted: Blips are now tracked and removed strictly per entity to avoid corrupting the game's blip list.
end

------------------------------------------------------------
-- ENTITY MANAGEMENT HELPERS
------------------------------------------------------------

local function safeDeleteEntity(ent)
    if not ent or ent == 0 then return end
    pcall(function()
        if ENTITY and ENTITY.DOES_ENTITY_EXIST and ENTITY.DOES_ENTITY_EXIST(ent) then
            removeBlipForEntity(ent)

            if ENTITY.IS_ENTITY_ATTACHED and ENTITY.IS_ENTITY_ATTACHED(ent) then
                if ENTITY.DETACH_ENTITY then
                    pcall(function() ENTITY.DETACH_ENTITY(ent, true, true) end)
                end
            end

            if ENTITY.SET_ENTITY_AS_MISSION_ENTITY then
                pcall(function() ENTITY.SET_ENTITY_AS_MISSION_ENTITY(ent, true, true) end)
            end

            if ENTITY.SET_ENTITY_COLLISION then
                pcall(function() ENTITY.SET_ENTITY_COLLISION(ent, false, false) end)
            end

            if ENTITY.IS_ENTITY_A_PED and ENTITY.IS_ENTITY_A_PED(ent) then
                pcall(function()
                    if TASK and TASK.CLEAR_PED_TASKS_IMMEDIATELY then
                        TASK.CLEAR_PED_TASKS_IMMEDIATELY(ent)
                    end
                    if PED and PED.SET_BLOCKING_OF_NON_TEMPORARY_EVENTS then
                        PED.SET_BLOCKING_OF_NON_TEMPORARY_EVENTS(ent, false)
                    end
                    if PED and PED.SET_PED_KEEP_TASK then
                        PED.SET_PED_KEEP_TASK(ent, false)
                    end
                end)
                if PED and PED.DELETE_PED then
                    pcall(function() PED.DELETE_PED(ent) end)
                end
                if ENTITY.DOES_ENTITY_EXIST and ENTITY.DOES_ENTITY_EXIST(ent) and PED and PED.SET_PED_AS_NO_LONGER_NEEDED then
                    pcall(function() PED.SET_PED_AS_NO_LONGER_NEEDED(ent) end)
                end
            elseif ENTITY.IS_ENTITY_A_VEHICLE and ENTITY.IS_ENTITY_A_VEHICLE(ent) then
                pcall(function()
                    if VEHICLE and VEHICLE.GET_PED_IN_VEHICLE_SEAT then
                        for seat = -1, 4 do
                            local occ = VEHICLE.GET_PED_IN_VEHICLE_SEAT(ent, seat, false)
                            if occ and occ ~= 0 and ENTITY.DOES_ENTITY_EXIST(occ) then
                                if TASK and TASK.CLEAR_PED_TASKS_IMMEDIATELY then
                                    TASK.CLEAR_PED_TASKS_IMMEDIATELY(occ)
                                end
                                if PED and PED.DELETE_PED then
                                    pcall(function() PED.DELETE_PED(occ) end)
                                end
                            end
                        end
                    end
                end)
                if VEHICLE and VEHICLE.DELETE_VEHICLE then
                    pcall(function() VEHICLE.DELETE_VEHICLE(ent) end)
                end
                if ENTITY.DOES_ENTITY_EXIST and ENTITY.DOES_ENTITY_EXIST(ent) and VEHICLE and VEHICLE.SET_VEHICLE_AS_NO_LONGER_NEEDED then
                    pcall(function() VEHICLE.SET_VEHICLE_AS_NO_LONGER_NEEDED(ent) end)
                end
            elseif ENTITY.IS_ENTITY_AN_OBJECT and ENTITY.IS_ENTITY_AN_OBJECT(ent) then
                if OBJECT and OBJECT.DELETE_OBJECT then
                    pcall(function() OBJECT.DELETE_OBJECT(ent) end)
                end
                if ENTITY.DOES_ENTITY_EXIST and ENTITY.DOES_ENTITY_EXIST(ent) and OBJECT and OBJECT.SET_OBJECT_AS_NO_LONGER_NEEDED then
                    pcall(function() OBJECT.SET_OBJECT_AS_NO_LONGER_NEEDED(ent) end)
                end
            elseif ENTITY.DELETE_ENTITY then
                pcall(function() ENTITY.DELETE_ENTITY(ent) end)
            end

            if ENTITY.DOES_ENTITY_EXIST and ENTITY.DOES_ENTITY_EXIST(ent) then
                pcall(function()
                    if ENTITY.SET_ENTITY_AS_NO_LONGER_NEEDED then
                        ENTITY.SET_ENTITY_AS_NO_LONGER_NEEDED(ent)
                    end
                end)
            end
        end
    end)
end

local function requestAndLoadModel(modelHash, maxWaitTicks)
    if not modelHash or modelHash == 0 then return false end
    if STREAMING and STREAMING.HAS_MODEL_LOADED and STREAMING.HAS_MODEL_LOADED(modelHash) then return true end
    local maxTicks = maxWaitTicks or 250
    for i = 1, maxTicks do
        pcall(function() if STREAMING and STREAMING.REQUEST_MODEL then STREAMING.REQUEST_MODEL(modelHash) end end)
        if STREAMING and STREAMING.HAS_MODEL_LOADED and STREAMING.HAS_MODEL_LOADED(modelHash) then return true end
        script.yield(10)
    end
    return (STREAMING and STREAMING.HAS_MODEL_LOADED and STREAMING.HAS_MODEL_LOADED(modelHash)) or false
end

local function safeSetInvincible(entity, state)
    if not isValidEntity(entity) then return end
    local s = (state == true)
    pcall(function()
        if ENTITY and ENTITY.SET_ENTITY_INVINCIBLE then
            local ok = pcall(ENTITY.SET_ENTITY_INVINCIBLE, entity, s, false)
            if not ok then
                pcall(ENTITY.SET_ENTITY_INVINCIBLE, entity, s)
            end
        end
        if VEHICLE and VEHICLE.SET_VEHICLE_CAN_BE_VISIBLY_DAMAGED then
            VEHICLE.SET_VEHICLE_CAN_BE_VISIBLY_DAMAGED(entity, not s)
        end
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
        if VEHICLE and VEHICLE.SET_VEHICLE_HANDBRAKE then VEHICLE.SET_VEHICLE_HANDBRAKE(veh, false) end
        if VEHICLE and VEHICLE.SET_VEHICLE_ON_GROUND_PROPERLY then VEHICLE.SET_VEHICLE_ON_GROUND_PROPERLY(veh) end
    end)
end

local function getTargetVehicle(maxDist)
    maxDist = maxDist or 20.0
    local ped = getLocalPed()
    if not isValidEntity(ped) then return nil end
    local pCoords = ENTITY.GET_ENTITY_COORDS(ped, true)
    local myVeh = 0
    if PED and PED.IS_PED_IN_ANY_VEHICLE and PED.IS_PED_IN_ANY_VEHICLE(ped, false) then
        myVeh = PED.GET_VEHICLE_PED_IS_IN(ped, false)
    end
    local bestVeh = nil
    local bestDist = maxDist

    -- 1. Scan via entities handle pool (fastest & most reliable)
    if entities and entities.get_all_vehicles_as_handles then
        pcall(function()
            local allVehs = entities.get_all_vehicles_as_handles()
            if allVehs then
                for _, v in ipairs(allVehs) do
                    if isValidEntity(v) and (myVeh == 0 or v ~= myVeh) then
                        local vc = ENTITY.GET_ENTITY_COORDS(v, true)
                        local dx = pCoords.x - vc.x
                        local dy = pCoords.y - vc.y
                        local dz = pCoords.z - vc.z
                        local dist = math.sqrt(dx*dx + dy*dy + dz*dz)
                        if dist < bestDist then
                            bestDist = dist
                            bestVeh = v
                        end
                    end
                end
            end
        end)
    end

    if isValidEntity(bestVeh) then return bestVeh end

    -- 2. Raycast in camera direction
    pcall(function()
        local forward = getCameraDirection()
        local rayEnd = { x = pCoords.x + forward.x * maxDist, y = pCoords.y + forward.y * maxDist, z = pCoords.z + forward.z * maxDist }
        if SHAPETEST and SHAPETEST.START_EXPENSIVE_SYNCHRONOUS_SHAPE_TEST_LOS_PROBE then
            local handle = SHAPETEST.START_EXPENSIVE_SYNCHRONOUS_SHAPE_TEST_LOS_PROBE(pCoords.x, pCoords.y, pCoords.z + 0.5, rayEnd.x, rayEnd.y, rayEnd.z, 2, ped, 7)
            local _, hit, _, _, entityHit = SHAPETEST.GET_SHAPE_TEST_RESULT(handle)
            if hit and entityHit and entityHit ~= 0 and (myVeh == 0 or entityHit ~= myVeh) and ENTITY.IS_ENTITY_A_VEHICLE(entityHit) then
                bestVeh = entityHit
            end
        end
    end)

    if isValidEntity(bestVeh) then return bestVeh end

    -- 3. Native fallbacks with permissive flags (flag 0 first to include personal/last-driven vehicles)
    pcall(function()
        local v = VEHICLE.GET_CLOSEST_VEHICLE(pCoords.x, pCoords.y, pCoords.z, maxDist, 0, 0)
        if not isValidEntity(v) then v = VEHICLE.GET_CLOSEST_VEHICLE(pCoords.x, pCoords.y, pCoords.z, maxDist, 0, 70) end
        if isValidEntity(v) and (myVeh == 0 or v ~= myVeh) then bestVeh = v end
    end)

    return bestVeh
end

local function getAllNearbyVehicles(radius)
    radius = radius or 90.0
    local foundVehicles = {}
    local addedMap = {}
    local ped = getLocalPed()
    if not isValidEntity(ped) then return foundVehicles end
    local pCoords = ENTITY.GET_ENTITY_COORDS(ped, true)
    local myVeh = 0
    if PED and PED.IS_PED_IN_ANY_VEHICLE and PED.IS_PED_IN_ANY_VEHICLE(ped, false) then
        myVeh = PED.GET_VEHICLE_PED_IS_IN(ped, false)
    end

    pcall(function()
        if entities and entities.get_all_vehicles_as_handles then
            local allVehs = entities.get_all_vehicles_as_handles()
            if allVehs then
                for _, v in ipairs(allVehs) do
                    if isValidEntity(v) and (myVeh == 0 or v ~= myVeh) then
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
                local veh = VEHICLE.GET_CLOSEST_VEHICLE(sx, sy, pCoords.z, 16.0, 0, 0)
                if not isValidEntity(veh) then veh = VEHICLE.GET_CLOSEST_VEHICLE(sx, sy, pCoords.z, 16.0, 0, 70) end
                if isValidEntity(veh) and (myVeh == 0 or veh ~= myVeh) and not addedMap[veh] then
                    addedMap[veh] = true
                    table.insert(foundVehicles, veh)
                end
            end
        end
    end
    return foundVehicles
end

local function getAllNearbyPeds(radius)
    radius = radius or 60.0
    local foundPeds = {}
    local addedMap = {}
    local myPed = getLocalPed()
    if not isValidEntity(myPed) then return foundPeds end
    local pCoords = ENTITY.GET_ENTITY_COORDS(myPed, true)

    pcall(function()
        if entities and entities.get_all_peds_as_handles then
            local allPeds = entities.get_all_peds_as_handles()
            if allPeds then
                for _, p in ipairs(allPeds) do
                    if isValidEntity(p) and p ~= myPed and not PED.IS_PED_INJURED(p) then
                        local pos = ENTITY.GET_ENTITY_COORDS(p, true)
                        local dx = pCoords.x - pos.x
                        local dy = pCoords.y - pos.y
                        local dz = pCoords.z - pos.z
                        if math.sqrt(dx*dx + dy*dy + dz*dz) <= radius and not addedMap[p] then
                            addedMap[p] = true
                            table.insert(foundPeds, p)
                        end
                    end
                end
            end
        elseif entities and entities.get_all_peds then
            local allPeds = entities.get_all_peds()
            if allPeds then
                for _, p in ipairs(allPeds) do
                    if isValidEntity(p) and p ~= myPed and not PED.IS_PED_INJURED(p) then
                        local pos = ENTITY.GET_ENTITY_COORDS(p, true)
                        local dx = pCoords.x - pos.x
                        local dy = pCoords.y - pos.y
                        local dz = pCoords.z - pos.z
                        if math.sqrt(dx*dx + dy*dy + dz*dz) <= radius and not addedMap[p] then
                            addedMap[p] = true
                            table.insert(foundPeds, p)
                        end
                    end
                end
            end
        end
    end)

    pcall(function()
        local players = getActivePlayersList()
        for _, pid in ipairs(players) do
            if pid ~= getLocalPid() then
                local pped = getPlayerPed(pid)
                if isValidEntity(pped) and pped ~= myPed and not PED.IS_PED_INJURED(pped) and not addedMap[pped] then
                    local pos = ENTITY.GET_ENTITY_COORDS(pped, true)
                    local dx = pCoords.x - pos.x
                    local dy = pCoords.y - pos.y
                    local dz = pCoords.z - pos.z
                    if math.sqrt(dx*dx + dy*dy + dz*dz) <= radius then
                        addedMap[pped] = true
                        table.insert(foundPeds, pped)
                    end
                end
            end
        end
    end)

    return foundPeds
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
        if ENTITY.SET_ENTITY_DYNAMIC then ENTITY.SET_ENTITY_DYNAMIC(veh, true) end
        if VEHICLE and VEHICLE.SET_VEHICLE_HANDBRAKE then VEHICLE.SET_VEHICLE_HANDBRAKE(veh, false) end
        local curVel = ENTITY.GET_ENTITY_VELOCITY(veh)
        ENTITY.SET_ENTITY_VELOCITY(veh, curVel.x, curVel.y, height * 1.5)
        if ENTITY.APPLY_FORCE_TO_ENTITY then
            ENTITY.APPLY_FORCE_TO_ENTITY(veh, 1, 0.0, 0.0, height * 1.5, 0.0, 0.0, 0.0, 0, false, true, true, false, true)
        end
    end)
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
        if VEHICLE and VEHICLE.SET_VEHICLE_HANDBRAKE then VEHICLE.SET_VEHICLE_HANDBRAKE(veh, false) end

        local camDir = getCameraDirection()
        local actualForce = force or S.launchForce or 150.0
        local vx = camDir.x * actualForce
        local vy = camDir.y * actualForce
        local vz = camDir.z * actualForce + 15.0

        ENTITY.SET_ENTITY_VELOCITY(veh, vx, vy, vz)
        ENTITY.SET_ENTITY_ANGULAR_VELOCITY(veh, 10.0, 5.0, 0.0)
        if ENTITY.APPLY_FORCE_TO_ENTITY then
            ENTITY.APPLY_FORCE_TO_ENTITY(veh, 1, vx, vy, vz, 0.0, 0.0, 0.0, 0, false, true, true, false, true)
        end
    end)
end

local function SlamVehicle(veh)
    if not isValidEntity(veh) then return end
    getControlOfEntity(veh)
    pcall(function()
        detachVehicle(veh)
        ENTITY.SET_ENTITY_COLLISION(veh, true, true)
        if ENTITY.SET_ENTITY_DYNAMIC then ENTITY.SET_ENTITY_DYNAMIC(veh, true) end
        if VEHICLE and VEHICLE.SET_VEHICLE_HANDBRAKE then VEHICLE.SET_VEHICLE_HANDBRAKE(veh, false) end
        ENTITY.SET_ENTITY_VELOCITY(veh, 0.0, 0.0, -150.0)
        if ENTITY.APPLY_FORCE_TO_ENTITY then
            ENTITY.APPLY_FORCE_TO_ENTITY(veh, 1, 0.0, 0.0, -150.0, 0.0, 0.0, 0.0, 0, false, true, true, false, true)
        end
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
        return
    end

    if not isValidEntity(veh) then veh = getTargetVehicle(25.0) end
    if not isValidEntity(veh) then
        return
    end

    S.isHoldingVehicle = true
    S.heldVehicle = veh

    script.run_in_callback(function()
        playCarryAnim()
        getControlOfEntity(S.heldVehicle)
        local ped = getLocalPed()

        pcall(function()
            ENTITY.SET_ENTITY_COLLISION(S.heldVehicle, true, true)
            if ENTITY.SET_ENTITY_DYNAMIC then ENTITY.SET_ENTITY_DYNAMIC(S.heldVehicle, true) end
            if VEHICLE and VEHICLE.SET_VEHICLE_HANDBRAKE then VEHICLE.SET_VEHICLE_HANDBRAKE(S.heldVehicle, false) end
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
                -- thisFrameOnly = true keeps collision active against ped once dropped/released
                if ENTITY.SET_ENTITY_NO_COLLISION_ENTITY then
                    ENTITY.SET_ENTITY_NO_COLLISION_ENTITY(S.heldVehicle, ped, true)
                end
            end)

            pcall(function()
                if S.activeAnimDict and S.activeAnimName and not PED.IS_ENTITY_PLAYING_ANIM(ped, S.activeAnimDict, S.activeAnimName, 3) then
                    safePlayAnim(ped, S.activeAnimDict, S.activeAnimName, 49)
                end
                if PAD then
                    PAD.DISABLE_CONTROL_ACTION(0, 22, true)
                    PAD.DISABLE_CONTROL_ACTION(0, 38, true)
                    PAD.DISABLE_CONTROL_ACTION(0, 51, true)
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
                break
            end

            if pressRelease then
                local target = S.heldVehicle
                S.isHoldingVehicle = false
                S.heldVehicle = nil
                detachVehicle(target)
                safeSetInvincible(target, false)
                break
            end

            script.yield(0)
        end

        S.isHoldingVehicle = false
        if isValidEntity(S.heldVehicle) then
            detachVehicle(S.heldVehicle)
            safeSetInvincible(S.heldVehicle, false)
        end
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
    notify.info("Telekinesis", "Player released from carry.")
end

local function startCarryingPlayer(targetPed)
    if S.isCarryingPlayer then stopCarryingPlayer() return end
    if not isValidEntity(targetPed) then targetPed = getTargetPlayerPed(15.0) end
    if not isValidEntity(targetPed) then
        notify.warn("Telekinesis", "No nearby player found to carry.")
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
        notify.success("Telekinesis", "Carrying player in arms! Press [E] to drop.")

        while S.isCarryingPlayer and isValidEntity(S.carriedPlayerPed) do
            myPed = getLocalPed()

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
-- XML & CUSTOM VEHICLE SPOONER (SPINETHETIC & MENYOO LOADER)
------------------------------------------------------------

local function parseVehiclePropertiesSection(block)
    local p = {}
    if not block or block == "" then return p end

    local colours = block:match("<Colours.->(.-)</Colours>")
    if colours then
        local prim = colours:match("<Primary>%s*([%-%d]+)%s*</Primary>")
        local sec = colours:match("<Secondary>%s*([%-%d]+)%s*</Secondary>")
        local pearl = colours:match("<Pearl>%s*([%-%d]+)%s*</Pearl>")
        local rim = colours:match("<Rim>%s*([%-%d]+)%s*</Rim>")
        if prim then p.primaryCol = tonumber(prim) end
        if sec then p.secondaryCol = tonumber(sec) end
        if pearl then p.pearlCol = tonumber(pearl) end
        if rim then p.rimCol = tonumber(rim) end

        local isCust1 = colours:match("<IsPrimaryColourCustom>%s*(.-)%s*</IsPrimaryColourCustom>")
        if isCust1 == "true" then
            local r = tonumber(colours:match("<Cust1_R>%s*(%d+)%s*</Cust1_R>")) or 0
            local g = tonumber(colours:match("<Cust1_G>%s*(%d+)%s*</Cust1_G>")) or 0
            local b = tonumber(colours:match("<Cust1_B>%s*(%d+)%s*</Cust1_B>")) or 0
            p.customPrimary = { r = r, g = g, b = b }
        end

        local isCust2 = colours:match("<IsSecondaryColourCustom>%s*(.-)%s*</IsSecondaryColourCustom>")
        if isCust2 == "true" then
            local r = tonumber(colours:match("<Cust2_R>%s*(%d+)%s*</Cust2_R>")) or 0
            local g = tonumber(colours:match("<Cust2_G>%s*(%d+)%s*</Cust2_G>")) or 0
            local b = tonumber(colours:match("<Cust2_B>%s*(%d+)%s*</Cust2_B>")) or 0
            p.customSecondary = { r = r, g = g, b = b }
        end

        local interior = colours:match("<LrInterior>%s*([%-%d]+)%s*</LrInterior>")
        local dash = colours:match("<LrDashboard>%s*([%-%d]+)%s*</LrDashboard>")
        local xenon = colours:match("<LrXenonHeadlights>%s*([%-%d]+)%s*</LrXenonHeadlights>")
        if interior then p.interiorCol = tonumber(interior) end
        if dash then p.dashboardCol = tonumber(dash) end
        if xenon then p.xenonCol = tonumber(xenon) end
    end

    local livery = block:match("<Livery>%s*([%-%d]+)%s*</Livery>")
    if livery then p.livery = tonumber(livery) end

    local plateText = block:match("<NumberPlateText>%s*(.-)%s*</NumberPlateText>")
    local plateIdx = block:match("<NumberPlateIndex>%s*(%d+)%s*</NumberPlateIndex>")
    if plateText then p.plateText = plateText end
    if plateIdx then p.plateIndex = tonumber(plateIdx) end

    local wheelType = block:match("<WheelType>%s*(%d+)%s*</WheelType>")
    if wheelType then p.wheelType = tonumber(wheelType) end

    local bpTyres = block:match("<BulletProofTyres>%s*(.-)%s*</BulletProofTyres>")
    if bpTyres then p.bulletProofTyres = (bpTyres == "true") end

    local windowTint = block:match("<WindowTint>%s*([%-%d]+)%s*</WindowTint>")
    if windowTint then p.windowTint = tonumber(windowTint) end

    local neons = block:match("<Neons.->(.-)</Neons>")
    if neons then
        local l = neons:match("<Left>%s*(.-)%s*</Left>")
        local r = neons:match("<Right>%s*(.-)%s*</Right>")
        local f = neons:match("<Front>%s*(.-)%s*</Front>")
        local b = neons:match("<Back>%s*(.-)%s*</Back>")
        local nr = tonumber(neons:match("<R>%s*(%d+)%s*</R>")) or 255
        local ng = tonumber(neons:match("<G>%s*(%d+)%s*</G>")) or 255
        local nb = tonumber(neons:match("<B>%s*(%d+)%s*</B>")) or 255
        p.neons = {
            left = (l == "true"),
            right = (r == "true"),
            front = (f == "true"),
            back = (b == "true"),
            r = nr, g = ng, b = nb
        }
    end

    local mods = block:match("<Mods.->(.-)</Mods>")
    if mods then
        p.mods = {}
        for modIdStr, valStr in mods:gmatch("<_([%d]+)>%s*(.-)%s*</_[%d]+>") do
            local modId = tonumber(modIdStr)
            if modId then
                if valStr == "true" or valStr == "false" then
                    p.mods[modId] = { enabled = (valStr == "true") }
                else
                    local comma = valStr:find(",")
                    if comma then
                        local mIdx = tonumber(valStr:sub(1, comma - 1)) or -1
                        local mVar = tonumber(valStr:sub(comma + 1)) or 0
                        p.mods[modId] = { index = mIdx, customVariation = (mVar ~= 0) }
                    else
                        p.mods[modId] = { index = tonumber(valStr) or -1, customVariation = false }
                    end
                end
            end
        end
    end

    local extras = block:match("<ModExtras.->(.-)</ModExtras>")
    if extras then
        p.extras = {}
        for extraIdStr, valStr in extras:gmatch("<_([%d]+)>%s*(.-)%s*</_[%d]+>") do
            local exId = tonumber(extraIdStr)
            if exId then
                p.extras[exId] = (valStr == "true")
            end
        end
    end

    return p
end

local function parseSingleAttachmentBlock(block)
    local att = {
        modelHash = 0,
        type = 3,
        initialHandle = 0,
        attachedTo = 0,
        boneIndex = 0,
        x = 0.0, y = 0.0, z = 0.0,
        pitch = 0.0, roll = 0.0, yaw = 0.0,
        dynamic = false,
        frozenPos = false,
        hasCollision = false,
        opacityLevel = 255,
        isVisible = true,
        vehicleProps = nil
    }

    local hStr = block:match("<ModelHash>%s*(.-)%s*</ModelHash>")
    if hStr then
        if hStr:sub(1, 2):lower() == "0x" then
            att.modelHash = tonumber(hStr) or 0
        else
            att.modelHash = tonumber(hStr) or getHash(hStr)
        end
    end
    if att.modelHash == 0 then
        local nameStr = block:match("<HashName>%s*(.-)%s*</HashName>") or block:match("<ModelName>%s*(.-)%s*</ModelName>")
        if nameStr and nameStr ~= "" then
            att.modelHash = getHash(nameStr)
        end
    end

    local t = block:match("<Type>%s*(%d+)%s*</Type>")
    if t then att.type = tonumber(t) or 3 end

    local initH = block:match("<InitialHandle>%s*(%d+)%s*</InitialHandle>")
    if initH then att.initialHandle = tonumber(initH) or 0 end

    local dyn = block:match("<Dynamic>%s*(.-)%s*</Dynamic>")
    if dyn then att.dynamic = (dyn == "true") end
    local froz = block:match("<FrozenPos>%s*(.-)%s*</FrozenPos>")
    if froz then att.frozenPos = (froz == "true") end
    local col = block:match("<HasCollision>%s*(.-)%s*</HasCollision>")
    if col then att.hasCollision = (col == "true") end
    local op = block:match("<OpacityLevel>%s*(%d+)%s*</OpacityLevel>")
    if op then att.opacityLevel = tonumber(op) or 255 end
    local vis = block:match("<IsVisible>%s*(.-)%s*</IsVisible>")
    if vis then att.isVisible = (vis ~= "false") end

    local innerSection = block:match("<Attachment[^>]*>(.-)$") or block
    local attTo = innerSection:match("<AttachedTo>%s*(%d+)%s*</AttachedTo>")
    if attTo then att.attachedTo = tonumber(attTo) or 0 end

    local bone = innerSection:match("<BoneIndex>%s*(%d+)%s*</BoneIndex>")
    if bone then att.boneIndex = tonumber(bone) or 0 end

    local x = innerSection:match("<X>%s*([%-%d%.eE]+)%s*</X>")
    local y = innerSection:match("<Y>%s*([%-%d%.eE]+)%s*</Y>")
    local z = innerSection:match("<Z>%s*([%-%d%.eE]+)%s*</Z>")
    local pitch = innerSection:match("<Pitch>%s*([%-%d%.eE]+)%s*</Pitch>")
    local roll  = innerSection:match("<Roll>%s*([%-%d%.eE]+)%s*</Roll>")
    local yaw   = innerSection:match("<Yaw>%s*([%-%d%.eE]+)%s*</Yaw>")

    if x then att.x = tonumber(x) or 0.0 end
    if y then att.y = tonumber(y) or 0.0 end
    if z then att.z = tonumber(z) or 0.0 end
    if pitch then att.pitch = tonumber(pitch) or 0.0 end
    if roll then att.roll = tonumber(roll) or 0.0 end
    if yaw then att.yaw = tonumber(yaw) or 0.0 end

    if att.type == 2 and block:find("<VehicleProperties") then
        att.vehicleProps = parseVehiclePropertiesSection(block)
    end

    return att
end

local function parseMenyooXml(xmlStr)
    local data = {
        modelHash = 0,
        initialHandle = 0,
        vehicleProps = {},
        attachments = {}
    }
    if not xmlStr or type(xmlStr) ~= "string" or xmlStr == "" then return data end

    local rootSection = xmlStr:match("<Vehicle.->(.-)<SpoonerAttachments") or xmlStr
    local rootHashStr = rootSection:match("<ModelHash>%s*(.-)%s*</ModelHash>")
    if rootHashStr then
        if rootHashStr:sub(1, 2):lower() == "0x" then
            data.modelHash = tonumber(rootHashStr) or 0
        else
            data.modelHash = tonumber(rootHashStr) or getHash(rootHashStr)
        end
    end
    if data.modelHash == 0 then
        local nameStr = rootSection:match("<HashName>%s*(.-)%s*</HashName>") or rootSection:match("<ModelName>%s*(.-)%s*</ModelName>")
        if nameStr and nameStr ~= "" then
            data.modelHash = getHash(nameStr)
        end
    end

    local initH = rootSection:match("<InitialHandle>%s*(%d+)%s*</InitialHandle>")
    if initH then data.initialHandle = tonumber(initH) or 0 end

    data.vehicleProps = parseVehiclePropertiesSection(rootSection)

    local attachSection = xmlStr:match("<SpoonerAttachments.->(.-)</SpoonerAttachments>") or ""
    local cursor = 1
    while true do
        local startTag, afterStart = attachSection:find("<Attachment[^>]*>", cursor)
        if not startTag then break end

        local depth = 1
        local searchPos = afterStart + 1
        local blockEnd = nil

        while depth > 0 and searchPos <= #attachSection do
            local nextOpen, openAfter = attachSection:find("<Attachment[^>]*>", searchPos)
            local nextClose, closeAfter = attachSection:find("</Attachment>", searchPos)

            if not nextClose then
                blockEnd = #attachSection
                break
            end

            if nextOpen and nextOpen < nextClose then
                depth = depth + 1
                searchPos = openAfter + 1
            else
                depth = depth - 1
                if depth == 0 then
                    blockEnd = nextClose - 1
                    cursor = closeAfter + 1
                else
                    searchPos = closeAfter + 1
                end
            end
        end

        if blockEnd then
            local block = attachSection:sub(afterStart + 1, blockEnd)
            local att = parseSingleAttachmentBlock(block)
            if att and att.modelHash ~= 0 then
                table.insert(data.attachments, att)
            end
        else
            break
        end
    end

    return data
end

local function applyVehicleCustomizations(veh, p)
    if not isValidEntity(veh) or not p then return end
    pcall(function()
        if VEHICLE and VEHICLE.SET_VEHICLE_MOD_KIT then
            VEHICLE.SET_VEHICLE_MOD_KIT(veh, 0)
        end

        if p.primaryCol or p.secondaryCol then
            if VEHICLE and VEHICLE.SET_VEHICLE_COLOURS then
                VEHICLE.SET_VEHICLE_COLOURS(veh, p.primaryCol or 0, p.secondaryCol or 0)
            end
        end

        if (p.pearlCol or p.rimCol) and VEHICLE and VEHICLE.SET_VEHICLE_EXTRA_COLOURS then
            VEHICLE.SET_VEHICLE_EXTRA_COLOURS(veh, p.pearlCol or 0, p.rimCol or 0)
        end

        if p.customPrimary and VEHICLE and VEHICLE.SET_VEHICLE_CUSTOM_PRIMARY_COLOUR then
            VEHICLE.SET_VEHICLE_CUSTOM_PRIMARY_COLOUR(veh, p.customPrimary.r, p.customPrimary.g, p.customPrimary.b)
        end

        if p.customSecondary and VEHICLE and VEHICLE.SET_VEHICLE_CUSTOM_SECONDARY_COLOUR then
            VEHICLE.SET_VEHICLE_CUSTOM_SECONDARY_COLOUR(veh, p.customSecondary.r, p.customSecondary.g, p.customSecondary.b)
        end

        if p.interiorCol and VEHICLE and VEHICLE.SET_VEHICLE_INTERIOR_COLOUR then
            VEHICLE.SET_VEHICLE_INTERIOR_COLOUR(veh, p.interiorCol)
        end
        if p.dashboardCol and VEHICLE and VEHICLE.SET_VEHICLE_DASHBOARD_COLOUR then
            VEHICLE.SET_VEHICLE_DASHBOARD_COLOUR(veh, p.dashboardCol)
        end

        if p.xenonCol and VEHICLE and VEHICLE.SET_VEHICLE_XENON_LIGHT_COLOR_INDEX then
            if VEHICLE.TOGGLE_VEHICLE_MOD then VEHICLE.TOGGLE_VEHICLE_MOD(veh, 22, true) end
            VEHICLE.SET_VEHICLE_XENON_LIGHT_COLOR_INDEX(veh, p.xenonCol)
        end

        if p.wheelType and VEHICLE and VEHICLE.SET_VEHICLE_WHEEL_TYPE then
            VEHICLE.SET_VEHICLE_WHEEL_TYPE(veh, p.wheelType)
        end
        if p.bulletProofTyres ~= nil and VEHICLE and VEHICLE.SET_VEHICLE_TYRES_CAN_BURST then
            VEHICLE.SET_VEHICLE_TYRES_CAN_BURST(veh, not p.bulletProofTyres)
        end

        if p.windowTint and VEHICLE and VEHICLE.SET_VEHICLE_WINDOW_TINT then
            VEHICLE.SET_VEHICLE_WINDOW_TINT(veh, p.windowTint)
        end

        if p.plateText and VEHICLE and VEHICLE.SET_VEHICLE_NUMBER_PLATE_TEXT then
            VEHICLE.SET_VEHICLE_NUMBER_PLATE_TEXT(veh, tostring(p.plateText):gsub('^%s*(.-)%s*$', '%1'))
        end
        if p.plateIndex and VEHICLE and VEHICLE.SET_VEHICLE_NUMBER_PLATE_TEXT_INDEX then
            VEHICLE.SET_VEHICLE_NUMBER_PLATE_TEXT_INDEX(veh, p.plateIndex)
        end

        if p.livery and p.livery >= 0 and VEHICLE and VEHICLE.SET_VEHICLE_LIVERY then
            VEHICLE.SET_VEHICLE_LIVERY(veh, p.livery)
        end

        if p.neons then
            if VEHICLE and VEHICLE.SET_VEHICLE_NEON_LIGHT_ENABLED then
                VEHICLE.SET_VEHICLE_NEON_LIGHT_ENABLED(veh, 0, p.neons.left or false)
                VEHICLE.SET_VEHICLE_NEON_LIGHT_ENABLED(veh, 1, p.neons.right or false)
                VEHICLE.SET_VEHICLE_NEON_LIGHT_ENABLED(veh, 2, p.neons.front or false)
                VEHICLE.SET_VEHICLE_NEON_LIGHT_ENABLED(veh, 3, p.neons.back or false)
            end
            if p.neons.r and VEHICLE and VEHICLE.SET_VEHICLE_NEON_COLOUR then
                VEHICLE.SET_VEHICLE_NEON_COLOUR(veh, p.neons.r, p.neons.g, p.neons.b)
            end
        end

        if p.mods and VEHICLE and VEHICLE.SET_VEHICLE_MOD then
            for modType, modData in pairs(p.mods) do
                if modType >= 17 and modType <= 22 then
                    if VEHICLE.TOGGLE_VEHICLE_MOD then
                        VEHICLE.TOGGLE_VEHICLE_MOD(veh, modType, modData.enabled or false)
                    end
                else
                    VEHICLE.SET_VEHICLE_MOD(veh, modType, modData.index or -1, modData.customVariation or false)
                end
            end
        end

        if p.extras and VEHICLE and VEHICLE.SET_VEHICLE_EXTRA then
            for extraId, extraState in pairs(p.extras) do
                VEHICLE.SET_VEHICLE_EXTRA(veh, extraId, not extraState)
            end
        end
    end)
end

local function cleanCustomVehicle(notifyUser)
    script.run_in_callback(function()
        local count = 0
        local pPed = getLocalPed()

        if isValidEntity(pPed) and isValidEntity(S.spawnedCustomVehicle) then
            pcall(function()
                if PED and PED.IS_PED_IN_VEHICLE and PED.IS_PED_IN_VEHICLE(pPed, S.spawnedCustomVehicle, false) then
                    if TASK and TASK.CLEAR_PED_TASKS_IMMEDIATELY then
                        TASK.CLEAR_PED_TASKS_IMMEDIATELY(pPed)
                    end
                end
            end)
        end

        local atts = S.spawnedCustomAttachments or {}
        S.spawnedCustomAttachments = {}

        if #atts > 0 then
            for _, ent in ipairs(atts) do
                if isValidEntity(ent) then
                    safeDeleteEntity(ent)
                    count = count + 1
                    script.yield(15)
                end
            end
        end

        if isValidEntity(S.spawnedCustomVehicle) then
            safeDeleteEntity(S.spawnedCustomVehicle)
            S.spawnedCustomVehicle = nil
            count = count + 1
        end

        if notifyUser then
            notify.info("Vehicle", "Veiculo customizado limpo (" .. count .. " entidades deletadas).")
        end
    end)
end

local function unfreezeCustomVehicle()
    pcall(function()
        local veh = S.spawnedCustomVehicle
        local ped = getLocalPed()
        if not isValidEntity(veh) and isValidEntity(ped) then
            if PED and PED.IS_PED_IN_ANY_VEHICLE and PED.IS_PED_IN_ANY_VEHICLE(ped, false) then
                veh = PED.GET_VEHICLE_PED_IS_IN(ped, false)
            end
        end

        if isValidEntity(veh) then
            ENTITY.FREEZE_ENTITY_POSITION(veh, false)
            ENTITY.SET_ENTITY_COLLISION(veh, true, true)
            if ENTITY.SET_ENTITY_DYNAMIC then ENTITY.SET_ENTITY_DYNAMIC(veh, true) end
            if VEHICLE and VEHICLE.SET_VEHICLE_ENGINE_ON then VEHICLE.SET_VEHICLE_ENGINE_ON(veh, true, true, false) end

            if S.spawnedCustomAttachments and #S.spawnedCustomAttachments > 0 then
                for _, att in ipairs(S.spawnedCustomAttachments) do
                    if isValidEntity(att) then
                        ENTITY.FREEZE_ENTITY_POSITION(att, false)
                        ENTITY.SET_ENTITY_COLLISION(att, false, false)
                        if ENTITY.SET_ENTITY_HAS_GRAVITY then ENTITY.SET_ENTITY_HAS_GRAVITY(att, false) end
                        if ENTITY.SET_ENTITY_NO_COLLISION_ENTITY then
                            ENTITY.SET_ENTITY_NO_COLLISION_ENTITY(att, veh, true)
                            ENTITY.SET_ENTITY_NO_COLLISION_ENTITY(veh, att, true)
                        end
                    end
                end
            end
            notify.success("Vehicle", "Veiculo destravado com sucesso! Fisica e motor liberados.")
        else
            notify.warn("Vehicle", "Nenhum veiculo XML ativo encontrado.")
        end
    end)
end

local function warpPlayerIntoVehicle(veh)
    if not isValidEntity(veh) then return false end
    local ped = getLocalPed()
    if not isValidEntity(ped) then return false end

    pcall(function()
        if PED and PED.IS_PED_IN_ANY_VEHICLE and PED.IS_PED_IN_ANY_VEHICLE(ped, false) then
            if TASK and TASK.CLEAR_PED_TASKS_IMMEDIATELY then
                TASK.CLEAR_PED_TASKS_IMMEDIATELY(ped)
            end
        end

        local vCoords = ENTITY.GET_ENTITY_COORDS(veh, true)
        ENTITY.SET_ENTITY_COORDS_NO_OFFSET(ped, vCoords.x, vCoords.y, vCoords.z, false, false, false)

        if TASK and TASK.TASK_WARP_PED_INTO_VEHICLE then
            TASK.TASK_WARP_PED_INTO_VEHICLE(ped, veh, -1)
        end
        if PED and PED.SET_PED_INTO_VEHICLE then
            PED.SET_PED_INTO_VEHICLE(ped, veh, -1)
        end
        if VEHICLE and VEHICLE.SET_VEHICLE_ENGINE_ON then
            VEHICLE.SET_VEHICLE_ENGINE_ON(veh, true, true, false)
        end
    end)
    return true
end

local function createCustomAttachmentEntity(attType, hash, x, y, z, heading)
    local ent = 0
    if attType == 2 then -- Vehicle
        if entities and entities.create_vehicle then
            pcall(function() ent = entities.create_vehicle(hash, { x = x, y = y, z = z }, heading or 0.0) end)
        end
        if not isValidEntity(ent) and VEHICLE and VEHICLE.CREATE_VEHICLE then
            pcall(function() ent = VEHICLE.CREATE_VEHICLE(hash, x, y, z, heading or 0.0, true, false, false) end)
        end
    elseif attType == 1 then -- Ped
        if entities and entities.create_ped then
            pcall(function() ent = entities.create_ped(hash, { x = x, y = y, z = z }, heading or 0.0) end)
        end
        if not isValidEntity(ent) and PED and PED.CREATE_PED then
            pcall(function() ent = PED.CREATE_PED(26, hash, x, y, z, heading or 0.0, true, false) end)
        end
    else -- Object / Prop (Type 3)
        if entities and entities.create_object then
            pcall(function() ent = entities.create_object(hash, { x = x, y = y, z = z }) end)
        end
        if not isValidEntity(ent) and OBJECT and OBJECT.CREATE_OBJECT_NO_OFFSET then
            pcall(function() ent = OBJECT.CREATE_OBJECT_NO_OFFSET(hash, x, y, z, true, false, false) end)
        end
        if not isValidEntity(ent) and OBJECT and OBJECT.CREATE_OBJECT then
            pcall(function() ent = OBJECT.CREATE_OBJECT(hash, x, y, z, true, false, false) end)
        end
    end
    if not isValidEntity(ent) then
        ent = safeCreateStuntProp(hash, x, y, z, false)
    end
    return ent
end

local function spawnXmlVehicleData(data, name)
    if S.isSpawningCustomVeh then
        notify.warn("Vehicle", "Spawning vehicle already in progress, please wait...")
        return
    end
    S.isSpawningCustomVeh = true

    script.run_in_callback(function()
        pcall(function()
            cleanCustomVehicle(false)

            local pPed = getLocalPed()
            if not isValidEntity(pPed) then
                notify.warn("Vehicle", "Local player ped not found!")
                S.isSpawningCustomVeh = false
                return
            end

            local pCoords = ENTITY.GET_ENTITY_COORDS(pPed, true)
            local heading = ENTITY.GET_ENTITY_HEADING(pPed)
            local rad  = math.rad(heading)
            local fwdX = -math.sin(rad)
            local fwdY =  math.cos(rad)

            local rootHash = data.modelHash
            if not rootHash or rootHash == 0 then rootHash = 0x39d6e83f end

            if not requestAndLoadModel(rootHash, 250) then
                notify.error("Vehicle", "Falha ao carregar modelo do veiculo base (Hash: " .. tostring(rootHash) .. ")!")
                S.isSpawningCustomVeh = false
                return
            end

            -- Dynamic Clearance Calculation:
            -- Computes minZ and maximum horizontal reach of attachments so ANY vehicle
            -- spawns safely without colliding with the ground or exploding physics
            local minZ = 0.0
            local maxExt = 3.0
            if data.attachments and #data.attachments > 0 then
                for _, att in ipairs(data.attachments) do
                    if att.z and att.z < minZ then minZ = att.z end
                    local dist = math.sqrt((att.x or 0.0)^2 + (att.y or 0.0)^2)
                    if dist > maxExt then maxExt = dist end
                end
            end

            local heightOffset = 1.2 + (S.xmlSpawnHeightOffset or 0.0)
            if minZ < -0.5 then
                heightOffset = math.abs(minZ) + 2.5 + (S.xmlSpawnHeightOffset or 0.0)
            elseif S.xmlSpawnInAir then
                heightOffset = heightOffset + 15.0
            end

            local distOffset = math.max(4.0, math.min(maxExt * 0.7, 18.0))
            local spawnX = pCoords.x + fwdX * distOffset
            local spawnY = pCoords.y + fwdY * distOffset
            local spawnZ = pCoords.z + heightOffset

            local rootVeh = 0
            if entities and entities.create_vehicle then
                pcall(function()
                    rootVeh = entities.create_vehicle(rootHash, { x = spawnX, y = spawnY, z = spawnZ }, heading)
                end)
            end
            if not isValidEntity(rootVeh) and VEHICLE and VEHICLE.CREATE_VEHICLE then
                pcall(function()
                    rootVeh = VEHICLE.CREATE_VEHICLE(rootHash, spawnX, spawnY, spawnZ, heading, true, false, false)
                end)
            end

            if not isValidEntity(rootVeh) then
                notify.error("Vehicle", "Failed to create root vehicle!")
                S.isSpawningCustomVeh = false
                return
            end

            S.spawnedCustomVehicle = rootVeh
            ENTITY.SET_ENTITY_AS_MISSION_ENTITY(rootVeh, true, true)
            safeSetInvincible(rootVeh, S.xmlInvincible ~= false)
            ENTITY.SET_ENTITY_HEADING(rootVeh, heading)

            -- Freeze root vehicle and temporarily disable collision during assembly to prevent physics fling/explosion
            ENTITY.FREEZE_ENTITY_POSITION(rootVeh, true)
            ENTITY.SET_ENTITY_COLLISION(rootVeh, false, true)

            -- Apply complete tuning & visual modifications to base vehicle
            if data.vehicleProps and next(data.vehicleProps) ~= nil then
                applyVehicleCustomizations(rootVeh, data.vehicleProps)
            else
                pcall(function()
                    VEHICLE.SET_VEHICLE_ENGINE_ON(rootVeh, true, true, false)
                    if data.primaryCol and VEHICLE.SET_VEHICLE_COLOURS then
                        VEHICLE.SET_VEHICLE_COLOURS(rootVeh, data.primaryCol or 0, data.secondaryCol or 0)
                    end
                end)
            end

            local isPincher = (rootHash == 0x39d6e83f or rootHash == 970385471)
            if isPincher and VEHICLE and VEHICLE.SET_VEHICLE_FLIGHT_NOZZLE_POSITION then
                pcall(function() VEHICLE.SET_VEHICLE_FLIGHT_NOZZLE_POSITION(rootVeh, 1.0) end)
            end

            -- ─────────────────────────────────────────────────────────────
            -- HIERARCHICAL MULTI-PASS ATTACHMENT PIPELINE
            -- ─────────────────────────────────────────────────────────────
            local attachedCount = 0
            if data.attachments and #data.attachments > 0 then

                -- 1. Preload models
                local uniqueHashes = {}
                for _, att in ipairs(data.attachments) do
                    if att.modelHash and att.modelHash ~= 0 then
                        uniqueHashes[att.modelHash] = true
                    end
                end
                for hash in pairs(uniqueHashes) do requestAndLoadModel(hash, 200) end

                -- 2. Entity Map for Hierarchical Attachments
                local entityMap = {}
                local rootInitHandle = data.initialHandle or 0
                entityMap[rootInitHandle] = rootVeh
                entityMap[0] = rootVeh

                local pending = {}
                for _, att in ipairs(data.attachments) do table.insert(pending, att) end

                local maxPasses = 4
                local currentPass = 0

                while #pending > 0 and currentPass < maxPasses do
                    currentPass = currentPass + 1
                    local stillPending = {}

                    for _, att in ipairs(pending) do
                        local pHandle = att.attachedTo or 0
                        local canAttachNow = (pHandle == 0) or (pHandle == rootInitHandle) or (entityMap[pHandle] ~= nil) or (currentPass == maxPasses)

                        if canAttachNow then
                            local parentEnt = (pHandle ~= 0 and entityMap[pHandle]) or rootVeh
                            if not isValidEntity(parentEnt) then parentEnt = rootVeh end

                            local attHash = att.modelHash
                            if attHash and attHash ~= 0 and requestAndLoadModel(attHash, 120) then
                                local attEnt = createCustomAttachmentEntity(att.type, attHash, spawnX, spawnY, spawnZ, heading)

                                if isValidEntity(attEnt) then
                                    pcall(function()
                                        ENTITY.SET_ENTITY_AS_MISSION_ENTITY(attEnt, true, true)
                                        safeSetInvincible(attEnt, true)

                                        -- Anti-collision and weightless
                                        ENTITY.SET_ENTITY_COLLISION(attEnt, false, false)
                                        if ENTITY.SET_ENTITY_HAS_GRAVITY then ENTITY.SET_ENTITY_HAS_GRAVITY(attEnt, false) end
                                        if ENTITY.SET_ENTITY_NO_COLLISION_ENTITY then
                                            ENTITY.SET_ENTITY_NO_COLLISION_ENTITY(attEnt, rootVeh, true)
                                            ENTITY.SET_ENTITY_NO_COLLISION_ENTITY(rootVeh, attEnt, true)
                                            if parentEnt ~= rootVeh then
                                                ENTITY.SET_ENTITY_NO_COLLISION_ENTITY(attEnt, parentEnt, true)
                                                ENTITY.SET_ENTITY_NO_COLLISION_ENTITY(parentEnt, attEnt, true)
                                            end
                                        end

                                        -- Vehicle attachment specifics
                                        if att.type == 2 then
                                            if VEHICLE.SET_VEHICLE_DOORS_LOCKED then VEHICLE.SET_VEHICLE_DOORS_LOCKED(attEnt, 4) end
                                            if VEHICLE.SET_VEHICLE_ENGINE_ON then VEHICLE.SET_VEHICLE_ENGINE_ON(attEnt, false, true, false) end
                                            if ENTITY.SET_ENTITY_DYNAMIC then ENTITY.SET_ENTITY_DYNAMIC(attEnt, false) end
                                            if att.vehicleProps then
                                                applyVehicleCustomizations(attEnt, att.vehicleProps)
                                            end
                                        elseif att.type == 1 then -- Ped
                                            if PED.SET_BLOCKING_OF_NON_TEMPORARY_EVENTS then
                                                PED.SET_BLOCKING_OF_NON_TEMPORARY_EVENTS(attEnt, true)
                                            end
                                            if PED.SET_PED_CAN_RAGDOLL then
                                                PED.SET_PED_CAN_RAGDOLL(attEnt, false)
                                            end
                                        end

                                        -- Opacity and Visibility
                                        if att.opacityLevel and att.opacityLevel < 255 and ENTITY.SET_ENTITY_ALPHA then
                                            ENTITY.SET_ENTITY_ALPHA(attEnt, att.opacityLevel, false)
                                        end
                                        if att.isVisible == false and ENTITY.SET_ENTITY_VISIBLE then
                                            ENTITY.SET_ENTITY_VISIBLE(attEnt, false, 0)
                                        end

                                        -- Attach to Parent Entity
                                        local attached = false
                                        pcall(function()
                                            ENTITY.ATTACH_ENTITY_TO_ENTITY(
                                                attEnt, parentEnt, att.boneIndex or 0,
                                                att.x or 0.0, att.y or 0.0, att.z or 0.0,
                                                att.pitch or 0.0, att.roll or 0.0, att.yaw or 0.0,
                                                false, false, false, false, 2, true
                                            )
                                            if ENTITY.IS_ENTITY_ATTACHED and ENTITY.IS_ENTITY_ATTACHED(attEnt) then
                                                attached = true
                                            end
                                        end)
                                        if not attached then
                                            pcall(function()
                                                ENTITY.ATTACH_ENTITY_TO_ENTITY(
                                                    attEnt, parentEnt, att.boneIndex or 0,
                                                    att.x or 0.0, att.y or 0.0, att.z or 0.0,
                                                    att.pitch or 0.0, att.roll or 0.0, att.yaw or 0.0,
                                                    true, false, false, false, 2, true
                                                )
                                            end)
                                        end

                                        ENTITY.FREEZE_ENTITY_POSITION(attEnt, false)
                                        if ENTITY.SET_ENTITY_DYNAMIC then
                                            ENTITY.SET_ENTITY_DYNAMIC(attEnt, att.dynamic == true)
                                        end
                                        if ENTITY.SET_ENTITY_PROOFS then
                                            ENTITY.SET_ENTITY_PROOFS(attEnt, true, true, true, true, true, true, true, true)
                                        end
                                        if ENTITY.SET_ENTITY_CAN_BE_DAMAGED then
                                            ENTITY.SET_ENTITY_CAN_BE_DAMAGED(attEnt, false)
                                        end
                                    end)

                                    if att.initialHandle and att.initialHandle ~= 0 then
                                        entityMap[att.initialHandle] = attEnt
                                    end

                                    table.insert(S.spawnedCustomAttachments, attEnt)
                                    attachedCount = attachedCount + 1

                                    if (attachedCount % 10) == 0 then
                                        script.yield(10)
                                    end
                                end
                            end
                        else
                            table.insert(stillPending, att)
                        end
                    end

                    pending = stillPending
                    script.yield(5)
                end

                -- Release preloaded models
                for hash in pairs(uniqueHashes) do
                    pcall(function()
                        if STREAMING and STREAMING.SET_MODEL_AS_NO_LONGER_NEEDED then
                            STREAMING.SET_MODEL_AS_NO_LONGER_NEEDED(hash)
                        end
                    end)
                end
            end

            -- Allow physical attachments to settle
            script.yield(50)

            -- Restore base vehicle collision and unfreeze smoothly
            ENTITY.SET_ENTITY_COLLISION(rootVeh, true, true)
            ENTITY.FREEZE_ENTITY_POSITION(rootVeh, false)
            if ENTITY.SET_ENTITY_DYNAMIC then ENTITY.SET_ENTITY_DYNAMIC(rootVeh, true) end
            if VEHICLE and VEHICLE.SET_VEHICLE_ENGINE_ON then
                VEHICLE.SET_VEHICLE_ENGINE_ON(rootVeh, true, true, false)
            end

            -- Warp player into vehicle if enabled
            if S.xmlWarpInside ~= false then
                warpPlayerIntoVehicle(rootVeh)
            end

            S.lastXmlSpawnedName = name or "Custom Vehicle"

            pcall(function()
                if AUDIO and AUDIO.PLAY_SOUND_FRONTEND then
                    AUDIO.PLAY_SOUND_FRONTEND(-1, "BASE_JUMP_PASSED", "HUD_AWARDS", true)
                end
            end)

            notify.success("SpyreX", (name or "Custom Vehicle") ..
                " pronto! (" .. attachedCount .. "/" ..
                tostring(data.attachments and #data.attachments or 0) .. " pecas montadas)")
        end)
        S.isSpawningCustomVeh = false
    end)
end

local Preset_SpinePincher = {
    modelHash = 0x39d6e83f,
    primaryCol = 0,
    secondaryCol = 0,
    attachments = {
        { modelHash = 0x3d6aaa9b, type = 2, boneIndex = 0, x = -1.0000, y = -2.0000, z = 0.0000, pitch = 0.0000, roll = -90.0000, yaw = 0.0000, frozenPos = false, dynamic = true, hasCollision = true },
        { modelHash = 0x3d6aaa9b, type = 2, boneIndex = 0, x = 1.0000, y = -2.0000, z = 0.0000, pitch = 0.0000, roll = 90.0000, yaw = 0.0000, frozenPos = false, dynamic = true, hasCollision = false },
        { modelHash = 0x9dae1398, type = 2, boneIndex = 0, x = 2.0000, y = 2.0000, z = 0.0000, pitch = 0.0000, roll = 90.0000, yaw = 0.0000, frozenPos = false, dynamic = true, hasCollision = true },
        { modelHash = 0x9dae1398, type = 2, boneIndex = 0, x = -2.0000, y = 2.0000, z = 0.0000, pitch = 0.0000, roll = -90.0000, yaw = 0.0000, frozenPos = false, dynamic = true, hasCollision = true },
        { modelHash = 0xd9621159, type = 3, boneIndex = 0, x = 0.0000, y = 3.2400, z = -0.1900, pitch = 90.0000, roll = 0.0000, yaw = 0.0000, frozenPos = true, dynamic = false, hasCollision = true },
        { modelHash = 0x9dae1398, type = 2, boneIndex = 0, x = -4.0000, y = -2.0000, z = 0.0000, pitch = 0.0000, roll = -90.0000, yaw = 0.0000, frozenPos = false, dynamic = true, hasCollision = true },
        { modelHash = 0x9dae1398, type = 2, boneIndex = 0, x = 4.0000, y = -2.0000, z = 0.0000, pitch = 0.0000, roll = 90.0000, yaw = 0.0000, frozenPos = false, dynamic = true, hasCollision = true },
        { modelHash = 0x3defce4d, type = 3, boneIndex = 0, x = 0.0000, y = 7.1000, z = -0.2200, pitch = -90.0000, roll = 0.0000, yaw = 0.0000, frozenPos = true, dynamic = false, hasCollision = true },
        { modelHash = 0x82abcd14, type = 3, boneIndex = 0, x = 4.4000, y = -2.0000, z = -1.5000, pitch = -15.0000, roll = -90.0000, yaw = -150.0000, frozenPos = true, dynamic = false, hasCollision = true },
        { modelHash = 0x82abcd14, type = 3, boneIndex = 0, x = -4.4000, y = -2.0000, z = -1.5000, pitch = -15.0000, roll = 80.0000, yaw = 150.0000, frozenPos = true, dynamic = false, hasCollision = true },
        { modelHash = 0x82abcd14, type = 3, boneIndex = 0, x = 4.4000, y = -2.0000, z = 1.5000, pitch = 15.0000, roll = -90.0000, yaw = -150.0000, frozenPos = true, dynamic = false, hasCollision = true },
        { modelHash = 0x82abcd14, type = 3, boneIndex = 0, x = -4.4000, y = -2.0000, z = 1.5000, pitch = 15.0000, roll = 90.0000, yaw = 150.0000, frozenPos = true, dynamic = false, hasCollision = true },
        { modelHash = 0x708d300f, type = 3, boneIndex = 0, x = -5.0000, y = -13.0000, z = 1.6000, pitch = 13.0000, roll = 78.0000, yaw = 135.0000, frozenPos = true, dynamic = false, hasCollision = true },
        { modelHash = 0x708d300f, type = 3, boneIndex = 0, x = 4.0000, y = -13.0000, z = 1.6000, pitch = 13.0000, roll = -78.0000, yaw = -135.0000, frozenPos = true, dynamic = false, hasCollision = true },
        { modelHash = 0x708d300f, type = 3, boneIndex = 0, x = 5.0000, y = -13.0000, z = -4.6000, pitch = -13.0000, roll = -78.0000, yaw = -135.0000, frozenPos = true, dynamic = false, hasCollision = true },
        { modelHash = 0x708d300f, type = 3, boneIndex = 0, x = -5.0000, y = -13.0000, z = -4.6000, pitch = -9.0000, roll = 75.0000, yaw = 135.0000, frozenPos = true, dynamic = false, hasCollision = true },
        { modelHash = 0x134f68e5, type = 3, boneIndex = 0, x = 0.0000, y = -9.0000, z = 0.1730, pitch = 0.0000, roll = 90.0000, yaw = 0.0000, frozenPos = true, dynamic = false, hasCollision = true },
        { modelHash = 0x134f68e5, type = 3, boneIndex = 0, x = 0.0000, y = -9.0000, z = 0.2000, pitch = 0.0000, roll = -90.0000, yaw = 0.0000, frozenPos = true, dynamic = false, hasCollision = true },
        { modelHash = 0x70b0e25a, type = 3, boneIndex = 0, x = 3.7000, y = -7.0000, z = 0.0000, pitch = 90.0000, roll = -0.0000, yaw = 91.0000, frozenPos = true, dynamic = false, hasCollision = true },
        { modelHash = 0x70b0e25a, type = 3, boneIndex = 0, x = -3.6000, y = -7.0000, z = 0.0000, pitch = -90.0000, roll = 0.0000, yaw = 90.0000, frozenPos = true, dynamic = false, hasCollision = true },
        { modelHash = 0x592c8b76, type = 3, boneIndex = 0, x = 0.0000, y = -0.5000, z = -2.1000, pitch = -180.0000, roll = 0.0000, yaw = -90.0000, frozenPos = true, dynamic = false, hasCollision = true },
        { modelHash = 0x592c8b76, type = 3, boneIndex = 0, x = 0.0000, y = -8.6000, z = -2.1000, pitch = 180.0000, roll = 0.0000, yaw = -90.0000, frozenPos = true, dynamic = false, hasCollision = true },
        { modelHash = 0xffd7d47d, type = 3, boneIndex = 0, x = -20.0000, y = -6.5000, z = 6.3000, pitch = 60.0000, roll = 180.0000, yaw = -89.0000, frozenPos = true, dynamic = false, hasCollision = true },
        { modelHash = 0xffd7d47d, type = 3, boneIndex = 0, x = 20.0000, y = -6.5000, z = 6.3000, pitch = -120.0000, roll = -0.0000, yaw = 90.0000, frozenPos = true, dynamic = false, hasCollision = true },
        { modelHash = 0xffd7d47d, type = 3, boneIndex = 0, x = 20.0000, y = -6.4000, z = -7.3000, pitch = -60.0000, roll = 0.0000, yaw = 90.0000, frozenPos = true, dynamic = false, hasCollision = true },
        { modelHash = 0xffd7d47d, type = 3, boneIndex = 0, x = -20.0000, y = -6.4000, z = -7.3000, pitch = 120.0000, roll = -180.0000, yaw = -90.0000, frozenPos = true, dynamic = false, hasCollision = true },
        { modelHash = 0x177606a2, type = 3, boneIndex = 0, x = -20.0000, y = -6.9000, z = 8.0000, pitch = -90.0000, roll = -0.0000, yaw = -0.0000, frozenPos = true, dynamic = false, hasCollision = true },
        { modelHash = 0x177606a2, type = 3, boneIndex = 0, x = -21.5000, y = -6.9000, z = 5.4000, pitch = -90.0000, roll = 0.0000, yaw = 0.0000, frozenPos = true, dynamic = false, hasCollision = true },
        { modelHash = 0x177606a2, type = 3, boneIndex = 0, x = 20.0000, y = -6.9000, z = 8.0000, pitch = -90.0000, roll = 0.0000, yaw = 0.0000, frozenPos = true, dynamic = false, hasCollision = true },
        { modelHash = 0x177606a2, type = 3, boneIndex = 0, x = 21.5000, y = -6.9000, z = 5.4000, pitch = -90.0000, roll = 0.0000, yaw = 0.0000, frozenPos = true, dynamic = false, hasCollision = true },
        { modelHash = 0x177606a2, type = 3, boneIndex = 0, x = -20.0000, y = -6.8000, z = -9.0000, pitch = -90.0000, roll = 0.0000, yaw = 0.0000, frozenPos = true, dynamic = false, hasCollision = true },
        { modelHash = 0x177606a2, type = 3, boneIndex = 0, x = -21.4000, y = -6.8000, z = -6.4000, pitch = -90.0000, roll = 0.0000, yaw = 0.0000, frozenPos = true, dynamic = false, hasCollision = true },
        { modelHash = 0x177606a2, type = 3, boneIndex = 0, x = 19.9000, y = -6.8000, z = -9.0000, pitch = -90.0000, roll = 0.0000, yaw = 0.0000, frozenPos = true, dynamic = false, hasCollision = true },
        { modelHash = 0x177606a2, type = 3, boneIndex = 0, x = 21.3000, y = -6.8000, z = -6.3000, pitch = -90.0000, roll = 0.0000, yaw = 0.0000, frozenPos = true, dynamic = false, hasCollision = true },
        { modelHash = 0x3794acc9, type = 3, boneIndex = 0, x = -20.0000, y = 0.8000, z = 8.0000, pitch = 0.0000, roll = 0.0000, yaw = 0.0000, frozenPos = true, dynamic = false, hasCollision = true },
        { modelHash = 0x3794acc9, type = 3, boneIndex = 0, x = -21.5000, y = 0.8000, z = 5.4000, pitch = 0.0000, roll = 0.0000, yaw = 0.0000, frozenPos = true, dynamic = false, hasCollision = true },
        { modelHash = 0x3794acc9, type = 3, boneIndex = 0, x = 20.0000, y = 0.8000, z = 8.0000, pitch = 0.0000, roll = 0.0000, yaw = 0.0000, frozenPos = true, dynamic = false, hasCollision = true },
        { modelHash = 0x3794acc9, type = 3, boneIndex = 0, x = 21.5000, y = 0.8000, z = 5.4000, pitch = 0.0000, roll = 0.0000, yaw = 0.0000, frozenPos = true, dynamic = false, hasCollision = true },
        { modelHash = 0x3794acc9, type = 3, boneIndex = 0, x = -20.0000, y = 0.9000, z = -9.0000, pitch = 0.0000, roll = 0.0000, yaw = 0.0000, frozenPos = true, dynamic = false, hasCollision = true },
        { modelHash = 0x3794acc9, type = 3, boneIndex = 0, x = -21.4000, y = 0.9000, z = -6.4000, pitch = 0.0000, roll = 0.0000, yaw = 0.0000, frozenPos = true, dynamic = false, hasCollision = true },
        { modelHash = 0x3794acc9, type = 3, boneIndex = 0, x = 19.9000, y = 0.9000, z = -9.0000, pitch = 0.0000, roll = 0.0000, yaw = 0.0000, frozenPos = true, dynamic = false, hasCollision = true },
        { modelHash = 0x3794acc9, type = 3, boneIndex = 0, x = 21.3000, y = 0.9000, z = -6.3000, pitch = 0.0000, roll = 0.0000, yaw = 0.0000, frozenPos = true, dynamic = false, hasCollision = true },
        { modelHash = 0x3d6aaa9b, type = 2, boneIndex = 0, x = -16.8000, y = -12.7000, z = -0.6000, pitch = 0.0000, roll = -90.0000, yaw = 90.0000, frozenPos = false, dynamic = true, hasCollision = true },
        { modelHash = 0x3d6aaa9b, type = 2, boneIndex = 0, x = 17.0000, y = -12.7000, z = -0.6000, pitch = 0.0000, roll = 90.0000, yaw = -90.0000, frozenPos = false, dynamic = true, hasCollision = true },
        { modelHash = 0x79454d60, type = 3, boneIndex = 0, x = -16.1000, y = -11.4200, z = -0.5600, pitch = 90.0000, roll = 0.0000, yaw = 0.0000, frozenPos = true, dynamic = false, hasCollision = true },
        { modelHash = 0x79454d60, type = 3, boneIndex = 0, x = 16.0500, y = -11.5100, z = -0.4900, pitch = 90.0000, roll = 0.0000, yaw = 0.0000, frozenPos = true, dynamic = false, hasCollision = true },
        { modelHash = 0x3d6aaa9b, type = 2, boneIndex = 0, x = -8.5000, y = -12.7000, z = -0.6000, pitch = 0.0000, roll = -90.0000, yaw = 90.0000, frozenPos = false, dynamic = true, hasCollision = true },
        { modelHash = 0x3d6aaa9b, type = 2, boneIndex = 0, x = 8.7000, y = -12.7000, z = -0.6000, pitch = 0.0000, roll = 90.0000, yaw = -90.0000, frozenPos = false, dynamic = true, hasCollision = true },
        { modelHash = 0x592c8b76, type = 3, boneIndex = 0, x = -17.7000, y = -13.1000, z = 0.4000, pitch = 178.0000, roll = -15.0000, yaw = 0.0000, frozenPos = true, dynamic = false, hasCollision = true },
        { modelHash = 0x592c8b76, type = 3, boneIndex = 0, x = -17.6000, y = -12.8000, z = -1.7000, pitch = 0.0000, roll = -15.0000, yaw = 0.0000, frozenPos = true, dynamic = false, hasCollision = true },
        { modelHash = 0x592c8b76, type = 3, boneIndex = 0, x = 17.7000, y = -12.9000, z = 0.6000, pitch = -180.0000, roll = 15.0000, yaw = 0.0000, frozenPos = true, dynamic = false, hasCollision = true },
        { modelHash = 0x592c8b76, type = 3, boneIndex = 0, x = 17.4000, y = -12.7000, z = -2.2000, pitch = 0.0000, roll = 15.0000, yaw = 0.0000, frozenPos = true, dynamic = false, hasCollision = true },
        { modelHash = 0x82abcd14, type = 3, boneIndex = 0, x = -1.0000, y = -19.4000, z = 0.0000, pitch = 0.0000, roll = 45.0000, yaw = 180.0000, frozenPos = true, dynamic = false, hasCollision = true },
        { modelHash = 0x82abcd14, type = 3, boneIndex = 0, x = 1.0000, y = -19.4000, z = 0.0000, pitch = 0.0000, roll = -45.0000, yaw = 180.0000, frozenPos = true, dynamic = false, hasCollision = true },
        { modelHash = 0x82abcd14, type = 3, boneIndex = 0, x = 1.0000, y = -19.4000, z = -2.0000, pitch = 0.0000, roll = -135.0000, yaw = 180.0000, frozenPos = true, dynamic = false, hasCollision = true },
        { modelHash = 0x82abcd14, type = 3, boneIndex = 0, x = -0.9000, y = -19.4000, z = -2.0000, pitch = 0.0000, roll = 135.0000, yaw = 180.0000, frozenPos = true, dynamic = false, hasCollision = true },
        { modelHash = 0x82abcd14, type = 3, boneIndex = 0, x = -3.0000, y = -20.0000, z = -0.8000, pitch = 0.0000, roll = 90.0000, yaw = 162.0000, frozenPos = true, dynamic = false, hasCollision = true },
        { modelHash = 0x82abcd14, type = 3, boneIndex = 0, x = 2.3000, y = -20.0000, z = -0.8000, pitch = 0.0000, roll = -90.0000, yaw = -162.0000, frozenPos = true, dynamic = false, hasCollision = true },
        { modelHash = 0x9e4d88ca, type = 3, boneIndex = 0, x = -6.7000, y = -24.0000, z = -0.8000, pitch = 90.0000, roll = 0.0000, yaw = 0.0000, frozenPos = true, dynamic = false, hasCollision = true },
        { modelHash = 0x9e4d88ca, type = 3, boneIndex = 0, x = -2.9000, y = -24.4001, z = 1.9000, pitch = 90.0000, roll = 0.0000, yaw = 0.0000, frozenPos = true, dynamic = false, hasCollision = true },
        { modelHash = 0x9e4d88ca, type = 3, boneIndex = 0, x = 2.9000, y = -24.4000, z = 1.9000, pitch = 90.0000, roll = 0.0000, yaw = 0.0000, frozenPos = true, dynamic = false, hasCollision = true },
        { modelHash = 0x9e4d88ca, type = 3, boneIndex = 0, x = 6.0000, y = -24.0000, z = -0.8000, pitch = 90.0000, roll = 0.0000, yaw = 0.0000, frozenPos = true, dynamic = false, hasCollision = true },
        { modelHash = 0x9e4d88ca, type = 3, boneIndex = 0, x = -2.7000, y = -24.4000, z = -3.9000, pitch = 90.0000, roll = 0.0000, yaw = -0.0000, frozenPos = true, dynamic = false, hasCollision = true },
        { modelHash = 0x9e4d88ca, type = 3, boneIndex = 0, x = 3.1000, y = -24.4000, z = -3.9000, pitch = 90.0000, roll = 0.0000, yaw = -0.0000, frozenPos = true, dynamic = false, hasCollision = true },
        { modelHash = 0x5b7e4520, type = 3, boneIndex = 0, x = 0.0000, y = -16.6300, z = -1.0000, pitch = 90.0000, roll = 0.0000, yaw = 0.0000, frozenPos = true, dynamic = false, hasCollision = true },
        { modelHash = 0x79454d60, type = 3, boneIndex = 0, x = -15.8800, y = -16.0100, z = -0.5900, pitch = -90.0000, roll = 0.0000, yaw = 0.0000, frozenPos = true, dynamic = false, hasCollision = true },
        { modelHash = 0x79454d60, type = 3, boneIndex = 0, x = 16.1101, y = -16.0100, z = -0.6000, pitch = -90.0000, roll = 0.0000, yaw = 0.0000, frozenPos = true, dynamic = false, hasCollision = true },
        { modelHash = 0x79454d60, type = 3, boneIndex = 0, x = 19.7000, y = -15.3100, z = 6.3500, pitch = -30.0000, roll = 90.0000, yaw = 90.0000, frozenPos = true, dynamic = false, hasCollision = true },
        { modelHash = 0x79454d60, type = 3, boneIndex = 0, x = -19.8000, y = -15.3000, z = -7.4000, pitch = -30.0000, roll = 90.0000, yaw = 90.0000, frozenPos = true, dynamic = false, hasCollision = true },
        { modelHash = 0x79454d60, type = 3, boneIndex = 0, x = -19.6000, y = -15.3400, z = 6.3880, pitch = -30.3000, roll = -90.8000, yaw = -90.0000, frozenPos = true, dynamic = false, hasCollision = true },
        { modelHash = 0x79454d60, type = 3, boneIndex = 0, x = 19.8000, y = -15.2100, z = -7.4000, pitch = 150.0000, roll = -90.0000, yaw = -90.0000, frozenPos = true, dynamic = false, hasCollision = true },
        { modelHash = 0xd9621159, type = 3, boneIndex = 0, x = 0.0000, y = -18.8100, z = -1.0000, pitch = -90.0000, roll = 0.0000, yaw = 0.0000, frozenPos = true, dynamic = false, hasCollision = true },
        { modelHash = 0xb467c540, type = 3, boneIndex = 0, x = 0.0000, y = -28.0000, z = -3.0000, pitch = 45.0000, roll = 0.0000, yaw = 0.0000, frozenPos = true, dynamic = false, hasCollision = true },
        { modelHash = 0xb467c540, type = 3, boneIndex = 0, x = -21.0000, y = -4.0000, z = 0.0000, pitch = 0.0000, roll = -65.0000, yaw = 0.0000, frozenPos = true, dynamic = false, hasCollision = true },
        { modelHash = 0xb467c540, type = 3, boneIndex = 0, x = 21.0000, y = -3.0000, z = 0.0000, pitch = 0.0000, roll = 65.0000, yaw = 0.0000, frozenPos = true, dynamic = false, hasCollision = true },
        { modelHash = 0xb467c540, type = 3, boneIndex = 0, x = 0.0000, y = 17.0000, z = -1.0000, pitch = -45.0000, roll = 0.0000, yaw = 0.0000, frozenPos = true, dynamic = false, hasCollision = true },
        { modelHash = 0xb467c540, type = 3, boneIndex = 0, x = 0.0000, y = -6.0000, z = 15.0000, pitch = 0.0000, roll = 0.0000, yaw = 0.0000, frozenPos = true, dynamic = false, hasCollision = true },
        { modelHash = 0xf697c81b, type = 3, boneIndex = 0, x = 0.0000, y = 0.7000, z = 1.2000, pitch = 180.0000, roll = 0.0000, yaw = 90.0000, frozenPos = true, dynamic = false, hasCollision = true },
        { modelHash = 0xf697c81b, type = 3, boneIndex = 0, x = 0.0000, y = -9.3000, z = 2.6000, pitch = 180.0000, roll = 0.0000, yaw = 90.0000, frozenPos = true, dynamic = false, hasCollision = true },
        { modelHash = 0xf697c81b, type = 3, boneIndex = 0, x = -22.5000, y = -8.1500, z = 1.7000, pitch = -149.5999, roll = -124.6000, yaw = 90.0000, frozenPos = true, dynamic = false, hasCollision = true },
        { modelHash = 0xf697c81b, type = 3, boneIndex = 0, x = -17.2000, y = -7.9900, z = -11.7200, pitch = 150.4001, roll = -124.0000, yaw = 90.0000, frozenPos = true, dynamic = false, hasCollision = true },
        { modelHash = 0xf697c81b, type = 3, boneIndex = 0, x = -22.4000, y = -7.9100, z = -2.8000, pitch = 152.0000, roll = -54.8200, yaw = 87.7999, frozenPos = true, dynamic = false, hasCollision = true },
        { modelHash = 0xf697c81b, type = 3, boneIndex = 0, x = -17.2100, y = -8.0900, z = 10.7800, pitch = -31.6001, roll = 124.1000, yaw = -90.0000, frozenPos = true, dynamic = false, hasCollision = true },
        { modelHash = 0xf697c81b, type = 3, boneIndex = 0, x = 17.2000, y = -8.0000, z = -11.7300, pitch = -149.0000, roll = -124.1000, yaw = 91.5000, frozenPos = true, dynamic = false, hasCollision = true },
        { modelHash = 0xf697c81b, type = 3, boneIndex = 0, x = 22.4600, y = -8.0200, z = -2.5700, pitch = -151.0000, roll = -56.0000, yaw = 89.6000, frozenPos = true, dynamic = false, hasCollision = true },
        { modelHash = 0xf697c81b, type = 3, boneIndex = 0, x = 22.5200, y = -8.1100, z = 1.6500, pitch = -148.6615, roll = 124.6998, yaw = -91.1503, frozenPos = true, dynamic = false, hasCollision = true },
        { modelHash = 0xf697c81b, type = 3, boneIndex = 0, x = 17.1800, y = -8.0900, z = 10.7400, pitch = 157.7001, roll = -50.5100, yaw = 79.8603, frozenPos = true, dynamic = false, hasCollision = true },
        { modelHash = 0xd43979f7, type = 3, boneIndex = 0, x = 0.0000, y = -0.7300, z = -2.3900, pitch = 0.0000, roll = 180.0000, yaw = 0.0000, frozenPos = true, dynamic = false, hasCollision = true },
        { modelHash = 0xd43979f7, type = 3, boneIndex = 0, x = 0.0000, y = -8.8400, z = -2.3900, pitch = 0.0000, roll = 180.0000, yaw = 0.0000, frozenPos = true, dynamic = false, hasCollision = true },
    }
}

local Preset_FuckT2Blimp = {
    modelHash = 0xf7004c86,
    primaryCol = 0,
    secondaryCol = 0,
    attachments = {
        { modelHash = 0xc54c0cd2, type = 3, boneIndex = 0, x = -7.3000, y = 2.7000, z = 5.2000, pitch = 0.0000, roll = 0.0000, yaw = -90.0000, frozenPos = true, dynamic = false, hasCollision = true },
        { modelHash = 0xc54c0cd2, type = 3, boneIndex = 0, x = -7.3000, y = -8.4000, z = 5.2000, pitch = 0.0000, roll = 0.0000, yaw = -90.0000, frozenPos = true, dynamic = false, hasCollision = true },
        { modelHash = 0x2f9f084d, type = 3, boneIndex = 0, x = -7.4000, y = 5.8000, z = 6.9000, pitch = 0.0000, roll = -0.0000, yaw = 90.0000, frozenPos = true, dynamic = true, hasCollision = true },
        { modelHash = 0x2f9f084d, type = 3, boneIndex = 0, x = -7.4000, y = 6.5700, z = 6.5000, pitch = 0.0000, roll = 90.0000, yaw = 90.0000, frozenPos = true, dynamic = true, hasCollision = true },
        { modelHash = 0x2f9f084d, type = 3, boneIndex = 0, x = -7.4000, y = 6.5700, z = 5.3400, pitch = 0.0000, roll = 90.0000, yaw = 90.0000, frozenPos = true, dynamic = true, hasCollision = true },
        { modelHash = 0x2f9f084d, type = 3, boneIndex = 0, x = -7.4000, y = 6.1700, z = 5.9300, pitch = 0.0000, roll = -0.0000, yaw = 90.0000, frozenPos = true, dynamic = true, hasCollision = true },
        { modelHash = 0x2f9f084d, type = 3, boneIndex = 0, x = -7.4000, y = 4.7000, z = 6.5000, pitch = 0.0000, roll = 90.0000, yaw = 90.0000, frozenPos = true, dynamic = true, hasCollision = true },
        { modelHash = 0x2f9f084d, type = 3, boneIndex = 0, x = -7.4000, y = 4.7000, z = 5.3400, pitch = 0.0000, roll = 90.0000, yaw = 90.0000, frozenPos = true, dynamic = true, hasCollision = true },
        { modelHash = 0x2f9f084d, type = 3, boneIndex = 0, x = -7.4000, y = 3.9300, z = 4.9499, pitch = 0.0000, roll = -0.0000, yaw = 90.0000, frozenPos = true, dynamic = true, hasCollision = true },
        { modelHash = 0x2f9f084d, type = 3, boneIndex = 0, x = -7.4000, y = 3.1699, z = 5.3400, pitch = 0.0000, roll = 90.0000, yaw = 90.0000, frozenPos = true, dynamic = true, hasCollision = true },
        { modelHash = 0x2f9f084d, type = 3, boneIndex = 0, x = -7.4000, y = 3.1699, z = 6.5000, pitch = 0.0000, roll = 90.0000, yaw = 90.0000, frozenPos = true, dynamic = true, hasCollision = true },
        { modelHash = 0x2f9f084d, type = 3, boneIndex = 0, x = -7.4000, y = 2.4099, z = 6.5000, pitch = 0.0000, roll = 90.0000, yaw = 90.0000, frozenPos = true, dynamic = true, hasCollision = true },
        { modelHash = 0x2f9f084d, type = 3, boneIndex = 0, x = -7.4000, y = 2.4099, z = 5.3500, pitch = 0.0000, roll = 90.0000, yaw = 90.0000, frozenPos = true, dynamic = true, hasCollision = true },
        { modelHash = 0x2f9f084d, type = 3, boneIndex = 0, x = -7.4000, y = 1.6499, z = 4.9599, pitch = 0.0000, roll = -0.0000, yaw = 90.0000, frozenPos = true, dynamic = true, hasCollision = true },
        { modelHash = 0x2f9f084d, type = 3, boneIndex = 0, x = -7.4000, y = 1.6499, z = 6.9000, pitch = 0.0000, roll = -0.0000, yaw = 90.0000, frozenPos = true, dynamic = true, hasCollision = true },
        { modelHash = 0x2f9f084d, type = 3, boneIndex = 0, x = -7.4000, y = 0.6399, z = 6.5000, pitch = 0.0000, roll = 90.0000, yaw = 90.0000, frozenPos = true, dynamic = true, hasCollision = true },
        { modelHash = 0x2f9f084d, type = 3, boneIndex = 0, x = -7.4000, y = 0.6399, z = 5.3700, pitch = 0.0000, roll = 90.0000, yaw = 90.0000, frozenPos = true, dynamic = true, hasCollision = true },
        { modelHash = 0x2f9f084d, type = 3, boneIndex = 0, x = -7.4000, y = 0.1399, z = 6.2700, pitch = 0.0000, roll = 37.0008, yaw = 90.0000, frozenPos = true, dynamic = true, hasCollision = true },
        { modelHash = 0x2f9f084d, type = 3, boneIndex = 0, x = -7.4000, y = -0.2601, z = 6.5800, pitch = 0.0000, roll = 37.0008, yaw = 90.0000, frozenPos = true, dynamic = true, hasCollision = true },
        { modelHash = 0x2f9f084d, type = 3, boneIndex = 0, x = -7.4000, y = 0.0399, z = 5.4800, pitch = 0.0000, roll = -37.0992, yaw = 90.0000, frozenPos = true, dynamic = true, hasCollision = true },
        { modelHash = 0x2f9f084d, type = 3, boneIndex = 0, x = -7.4000, y = -0.2501, z = 5.2700, pitch = 0.0000, roll = -37.0992, yaw = 90.0000, frozenPos = true, dynamic = true, hasCollision = true },
        { modelHash = 0x2f9f084d, type = 3, boneIndex = 0, x = -7.4000, y = -6.7300, z = 6.5000, pitch = 0.0000, roll = 90.0000, yaw = 90.0000, frozenPos = true, dynamic = true, hasCollision = true },
        { modelHash = 0x2f9f084d, type = 3, boneIndex = 0, x = -7.4000, y = -6.7300, z = 5.4000, pitch = 0.0000, roll = 90.0000, yaw = 90.0000, frozenPos = true, dynamic = true, hasCollision = true },
        { modelHash = 0x2f9f084d, type = 3, boneIndex = 0, x = -7.4000, y = -5.9700, z = 6.8900, pitch = 0.0000, roll = -0.0000, yaw = 90.0000, frozenPos = true, dynamic = true, hasCollision = true },
        { modelHash = 0x2f9f084d, type = 3, boneIndex = 0, x = -7.4000, y = -7.4800, z = 6.8900, pitch = 0.0000, roll = -0.0000, yaw = 90.0000, frozenPos = true, dynamic = true, hasCollision = true },
        { modelHash = 0x2f9f084d, type = 3, boneIndex = 0, x = -7.4000, y = -8.8500, z = 6.8900, pitch = 0.0000, roll = -0.0000, yaw = 90.0000, frozenPos = true, dynamic = true, hasCollision = true },
        { modelHash = 0x2f9f084d, type = 3, boneIndex = 0, x = -7.4000, y = -10.0001, z = 6.8900, pitch = 0.0000, roll = -0.0000, yaw = 90.0000, frozenPos = true, dynamic = true, hasCollision = true },
        { modelHash = 0x2f9f084d, type = 3, boneIndex = 0, x = -7.4000, y = -10.3901, z = 6.5000, pitch = 0.0000, roll = 90.0000, yaw = 90.0000, frozenPos = true, dynamic = true, hasCollision = true },
        { modelHash = 0x2f9f084d, type = 3, boneIndex = 0, x = -7.4000, y = -10.0001, z = 5.7500, pitch = 0.0000, roll = -0.0000, yaw = 90.0000, frozenPos = true, dynamic = true, hasCollision = true },
        { modelHash = 0x2f9f084d, type = 3, boneIndex = 0, x = -7.4000, y = -8.8400, z = 5.7500, pitch = 0.0000, roll = -0.0000, yaw = 90.0000, frozenPos = true, dynamic = true, hasCollision = true },
        { modelHash = 0x2f9f084d, type = 3, boneIndex = 0, x = -7.4000, y = -8.4500, z = 5.3600, pitch = 0.0000, roll = 90.0000, yaw = 90.0000, frozenPos = true, dynamic = true, hasCollision = true },
        { modelHash = 0x2f9f084d, type = 3, boneIndex = 0, x = -7.4000, y = -8.8400, z = 4.9699, pitch = 0.0000, roll = -0.0000, yaw = 90.0000, frozenPos = true, dynamic = true, hasCollision = true },
        { modelHash = 0x2f9f084d, type = 3, boneIndex = 0, x = -7.4000, y = -10.0001, z = 4.9699, pitch = 0.0000, roll = -0.0000, yaw = 90.0000, frozenPos = true, dynamic = true, hasCollision = true },
    }
}

local Preset_HamburgersRevenge = {
    modelHash = 0x2f03547b,
    primaryCol = 0,
    secondaryCol = 0,
    attachments = {
        { modelHash = 0x65dc08fd, type = 3, boneIndex = 0, x = 0.0000, y = 0.0000, z = 0.0000, pitch = 0.0000, roll = 0.0000, yaw = 0.0000, frozenPos = true, dynamic = true, hasCollision = true },
    }
}

local Preset_XmasSleighBoat = {
    modelHash = 0xa52f6866,
    primaryCol = 0,
    secondaryCol = 0,
    attachments = {
        { modelHash = 0x107f392c, type = 2, boneIndex = 0, x = 0.0000, y = -0.3000, z = -0.8000, pitch = 0.0000, roll = 0.0000, yaw = 0.0000, frozenPos = false, dynamic = true, hasCollision = true },
        { modelHash = 0x2fea25bf, type = 3, boneIndex = 0, x = -1.1900, y = 0.1200, z = -0.3000, pitch = -30.0000, roll = -56.0000, yaw = 30.0000, frozenPos = true, dynamic = true, hasCollision = true },
        { modelHash = 0x2fea25bf, type = 3, boneIndex = 0, x = 1.1900, y = 0.1200, z = -0.3000, pitch = 38.0000, roll = 57.0000, yaw = 20.0000, frozenPos = false, dynamic = true, hasCollision = true },
        { modelHash = 0xaf7f4400, type = 3, boneIndex = 0, x = 0.0000, y = -2.2000, z = -0.3000, pitch = 0.0000, roll = 0.0000, yaw = 0.0000, frozenPos = false, dynamic = true, hasCollision = true },
        { modelHash = 0x3794acc9, type = 3, boneIndex = 0, x = -0.3700, y = -3.7000, z = -0.0100, pitch = 0.0000, roll = 0.0000, yaw = 0.0000, frozenPos = true, dynamic = true, hasCollision = true },
        { modelHash = 0x3794acc9, type = 3, boneIndex = 0, x = 0.3700, y = -3.7000, z = -0.0100, pitch = 0.0000, roll = 0.0000, yaw = 0.0000, frozenPos = false, dynamic = true, hasCollision = true },
        { modelHash = 0xf3b38b02, type = 3, boneIndex = 0, x = -0.2900, y = 1.0500, z = -0.1600, pitch = 0.0000, roll = 0.0000, yaw = 0.0000, frozenPos = false, dynamic = true, hasCollision = true },
        { modelHash = 0xd4f8beab, type = 3, boneIndex = 0, x = 0.4400, y = 1.1100, z = -0.5000, pitch = 0.0000, roll = 0.0000, yaw = 0.0000, frozenPos = false, dynamic = true, hasCollision = true },
        { modelHash = 0x11a7c451, type = 3, boneIndex = 0, x = 0.5100, y = 1.7900, z = -0.3000, pitch = 0.0000, roll = 0.0000, yaw = -75.0000, frozenPos = false, dynamic = true, hasCollision = true },
        { modelHash = 0x1625b91e, type = 3, boneIndex = 0, x = -0.2700, y = 2.1000, z = -0.0600, pitch = 0.0000, roll = 0.0000, yaw = 72.0000, frozenPos = false, dynamic = true, hasCollision = true },
        { modelHash = 0x1bd00672, type = 3, boneIndex = 0, x = 0.0000, y = 2.8600, z = 0.0000, pitch = -80.0000, roll = 0.0000, yaw = 0.0000, frozenPos = true, dynamic = true, hasCollision = true },
        { modelHash = 0x1bd00672, type = 3, boneIndex = 0, x = -0.1900, y = 2.8600, z = 0.0000, pitch = -80.0000, roll = 0.0000, yaw = 0.0000, frozenPos = true, dynamic = true, hasCollision = true },
        { modelHash = 0x1bd00672, type = 3, boneIndex = 0, x = 0.1900, y = 2.8600, z = 0.0000, pitch = -80.0000, roll = 0.0000, yaw = 0.0000, frozenPos = false, dynamic = true, hasCollision = true },
        { modelHash = 0xd86b5a95, type = 1, boneIndex = 0, x = 0.6000, y = 5.0000, z = 0.0000, pitch = 0.0000, roll = 0.0000, yaw = 0.0000, frozenPos = true, dynamic = true, hasCollision = true },
        { modelHash = 0xd86b5a95, type = 1, boneIndex = 0, x = -0.6000, y = 5.0000, z = 0.0000, pitch = 0.0000, roll = 0.0000, yaw = 0.0000, frozenPos = true, dynamic = true, hasCollision = true },
        { modelHash = 0xd86b5a95, type = 1, boneIndex = 0, x = 0.6000, y = 8.0000, z = 0.0000, pitch = 0.0000, roll = 0.0000, yaw = 0.0000, frozenPos = true, dynamic = true, hasCollision = true },
        { modelHash = 0xd86b5a95, type = 1, boneIndex = 0, x = -0.6000, y = 8.0000, z = 0.0000, pitch = 0.0000, roll = 0.0000, yaw = 0.0000, frozenPos = true, dynamic = true, hasCollision = true },
        { modelHash = 0xd86b5a95, type = 1, boneIndex = 0, x = -0.6000, y = 11.0000, z = 0.0000, pitch = 0.0000, roll = 0.0000, yaw = 0.0000, frozenPos = true, dynamic = true, hasCollision = true },
        { modelHash = 0xd86b5a95, type = 1, boneIndex = 0, x = 0.6000, y = 11.0000, z = 0.0000, pitch = 0.0000, roll = 0.0000, yaw = 0.0000, frozenPos = true, dynamic = true, hasCollision = true },
        { modelHash = 0xd86b5a95, type = 1, boneIndex = 0, x = 0.6000, y = 14.0000, z = 0.0000, pitch = 0.0000, roll = 0.0000, yaw = 0.0000, frozenPos = true, dynamic = true, hasCollision = true },
        { modelHash = 0xd86b5a95, type = 1, boneIndex = 0, x = -0.6000, y = 14.0000, z = 0.0000, pitch = 0.0000, roll = 0.0000, yaw = 0.0000, frozenPos = false, dynamic = true, hasCollision = true },
        { modelHash = 0xb7ffff45, type = 3, boneIndex = 0, x = 0.0000, y = 3.6700, z = 0.0000, pitch = -90.0000, roll = -0.0000, yaw = 0.0000, frozenPos = true, dynamic = true, hasCollision = true },
        { modelHash = 0xb7ffff45, type = 3, boneIndex = 0, x = 0.0000, y = 7.5101, z = 0.0000, pitch = -90.0000, roll = -0.0000, yaw = 0.0000, frozenPos = false, dynamic = true, hasCollision = true },
        { modelHash = 0xb63f6584, type = 3, boneIndex = 0, x = -0.5600, y = 5.7500, z = 0.2300, pitch = 0.0000, roll = 67.0000, yaw = 90.0000, frozenPos = true, dynamic = true, hasCollision = true },
        { modelHash = 0xb63f6584, type = 3, boneIndex = 0, x = -0.5600, y = 8.7601, z = 0.2300, pitch = 0.0000, roll = 67.0000, yaw = 90.0000, frozenPos = true, dynamic = true, hasCollision = true },
        { modelHash = 0xb63f6584, type = 3, boneIndex = 0, x = -0.5600, y = 11.7601, z = 0.2300, pitch = 0.0000, roll = 67.0000, yaw = 90.0000, frozenPos = true, dynamic = true, hasCollision = true },
        { modelHash = 0xb63f6584, type = 3, boneIndex = 0, x = -0.5600, y = 14.7602, z = 0.2300, pitch = 0.0000, roll = 67.0000, yaw = 90.0000, frozenPos = true, dynamic = true, hasCollision = true },
        { modelHash = 0xb63f6584, type = 3, boneIndex = 0, x = 0.6100, y = 14.7602, z = 0.2300, pitch = 0.0000, roll = 67.0000, yaw = 90.0000, frozenPos = true, dynamic = true, hasCollision = true },
        { modelHash = 0xb63f6584, type = 3, boneIndex = 0, x = 0.6100, y = 11.7401, z = 0.2300, pitch = 0.0000, roll = 67.0000, yaw = 90.0000, frozenPos = true, dynamic = true, hasCollision = true },
        { modelHash = 0xb63f6584, type = 3, boneIndex = 0, x = 0.6100, y = 8.7401, z = 0.2300, pitch = 0.0000, roll = 67.0000, yaw = 90.0000, frozenPos = true, dynamic = true, hasCollision = true },
        { modelHash = 0xb63f6584, type = 3, boneIndex = 0, x = 0.6100, y = 5.7300, z = 0.2300, pitch = 0.0000, roll = 67.0000, yaw = 90.0000, frozenPos = false, dynamic = true, hasCollision = true },
        { modelHash = 0x5d20643d, type = 3, boneIndex = 0, x = 0.0000, y = 5.9000, z = 0.0000, pitch = 0.0000, roll = 0.0000, yaw = 0.0000, frozenPos = true, dynamic = true, hasCollision = true },
        { modelHash = 0x5d20643d, type = 3, boneIndex = 0, x = 0.0000, y = 9.0000, z = 0.0000, pitch = 0.0000, roll = 0.0000, yaw = 0.0000, frozenPos = true, dynamic = true, hasCollision = true },
        { modelHash = 0x5d20643d, type = 3, boneIndex = 0, x = 0.0000, y = 11.9000, z = 0.0000, pitch = 0.0000, roll = 0.0000, yaw = 0.0000, frozenPos = true, dynamic = true, hasCollision = true },
        { modelHash = 0x5d20643d, type = 3, boneIndex = 0, x = 0.0000, y = 14.9000, z = 0.0000, pitch = 0.0000, roll = 0.0000, yaw = 0.0000, frozenPos = false, dynamic = true, hasCollision = true },
        { modelHash = 0xb467c540, type = 3, boneIndex = 0, x = 0.0000, y = 0.0000, z = 0.0000, pitch = -109.0000, roll = 0.0000, yaw = 0.0000, frozenPos = false, dynamic = true, hasCollision = true },
    }
}

local Preset_ZombieSabreGT = {
    modelHash = 0x9b909c94,
    primaryCol = 0,
    secondaryCol = 0,
    attachments = {
        { modelHash = 0xc89630b8, type = 3, boneIndex = 0, x = 0.8800, y = 0.8100, z = 0.5000, pitch = 0.0000, roll = 0.0000, yaw = 90.0000, frozenPos = true, dynamic = true, hasCollision = true },
        { modelHash = 0xc89630b8, type = 3, boneIndex = 0, x = -0.8800, y = 0.8100, z = 0.5000, pitch = 0.0000, roll = 0.0000, yaw = 90.0000, frozenPos = false, dynamic = true, hasCollision = true },
        { modelHash = 0x7e1240ea, type = 3, boneIndex = 0, x = 0.0000, y = 1.9500, z = -0.0700, pitch = 180.0000, roll = 0.0000, yaw = -90.0000, frozenPos = true, dynamic = true, hasCollision = true },
        { modelHash = 0x7e1240ea, type = 3, boneIndex = 0, x = -0.7400, y = 1.8000, z = -0.0700, pitch = 180.0000, roll = 0.0000, yaw = -90.0000, frozenPos = true, dynamic = true, hasCollision = true },
        { modelHash = 0x7e1240ea, type = 3, boneIndex = 0, x = 0.7400, y = 1.8000, z = -0.0700, pitch = 180.0000, roll = 0.0000, yaw = -90.0000, frozenPos = true, dynamic = true, hasCollision = true },
        { modelHash = 0x7e1240ea, type = 3, boneIndex = 0, x = 0.3400, y = 1.8800, z = -0.0700, pitch = 180.0000, roll = 0.0000, yaw = -90.0000, frozenPos = true, dynamic = true, hasCollision = true },
        { modelHash = 0x7e1240ea, type = 3, boneIndex = 0, x = -0.3400, y = 1.8800, z = -0.0700, pitch = 180.0000, roll = 0.0000, yaw = -90.0000, frozenPos = false, dynamic = true, hasCollision = true },
        { modelHash = 0x7fd34040, type = 3, boneIndex = 49, x = -0.0100, y = 2.2300, z = 0.3200, pitch = 87.5478, roll = 45.0000, yaw = 0.0000, frozenPos = false, dynamic = true, hasCollision = true },
        { modelHash = 0x0f8c9ecb, type = 3, boneIndex = 0, x = -0.6600, y = 1.6140, z = 0.4140, pitch = -99.8000, roll = 45.0000, yaw = 0.0000, frozenPos = false, dynamic = true, hasCollision = true },
        { modelHash = 0xccdc8715, type = 3, boneIndex = 0, x = 0.0000, y = -1.4800, z = 0.2800, pitch = 0.0000, roll = 0.0000, yaw = 0.0000, frozenPos = false, dynamic = true, hasCollision = true },
        { modelHash = 0x25c5af13, type = 2, boneIndex = 0, x = 0.0000, y = 0.0000, z = 0.0700, pitch = 0.0000, roll = 0.0000, yaw = 0.0000, frozenPos = false, dynamic = true, hasCollision = true },
        { modelHash = 0xde657a3f, type = 3, boneIndex = 0, x = 0.0000, y = -0.3300, z = 0.4600, pitch = 0.0000, roll = 0.0000, yaw = 0.0000, frozenPos = false, dynamic = true, hasCollision = true },
        { modelHash = 0x00e11661, type = 3, boneIndex = 0, x = 0.0000, y = -0.5600, z = 0.8100, pitch = -90.0000, roll = 0.0000, yaw = -0.0000, frozenPos = false, dynamic = true, hasCollision = true },
        { modelHash = 0xfca454b2, type = 3, boneIndex = 0, x = 0.0000, y = 2.2000, z = 0.0000, pitch = 0.0000, roll = 0.0000, yaw = 0.0000, frozenPos = false, dynamic = true, hasCollision = true },
        { modelHash = 0xe2174d98, type = 3, boneIndex = 0, x = 0.0000, y = -2.4700, z = 0.4900, pitch = 0.0000, roll = 0.0000, yaw = 0.0000, frozenPos = false, dynamic = true, hasCollision = true },
        { modelHash = 0xf2f47da7, type = 3, boneIndex = 0, x = -0.1700, y = -2.6100, z = 0.2600, pitch = 23.4001, roll = 0.0000, yaw = 180.0000, frozenPos = false, dynamic = true, hasCollision = true },
        { modelHash = 0x0a22cea2, type = 3, boneIndex = 0, x = -0.8840, y = 0.5650, z = 0.5400, pitch = 0.0000, roll = 0.0000, yaw = 90.0000, frozenPos = true, dynamic = true, hasCollision = true },
        { modelHash = 0x0a22cea2, type = 3, boneIndex = 0, x = 0.8840, y = 0.5650, z = 0.5400, pitch = 0.0000, roll = 0.0000, yaw = 90.0000, frozenPos = false, dynamic = true, hasCollision = true },
        { modelHash = 0x7f2b2371, type = 3, boneIndex = 0, x = -0.4300, y = -0.7600, z = 0.8130, pitch = -90.0000, roll = 0.0000, yaw = 0.0000, frozenPos = true, dynamic = true, hasCollision = true },
        { modelHash = 0x7f2b2371, type = 3, boneIndex = 0, x = 0.4300, y = -0.7600, z = 0.8130, pitch = 90.0000, roll = 180.0000, yaw = 0.0000, frozenPos = false, dynamic = true, hasCollision = true },
        { modelHash = 0xf4115c33, type = 3, boneIndex = 0, x = 0.1700, y = 2.3400, z = -0.1000, pitch = -16.0000, roll = -0.0000, yaw = 180.0000, frozenPos = true, dynamic = true, hasCollision = true },
        { modelHash = 0xf4115c33, type = 3, boneIndex = 0, x = -0.1700, y = 2.3400, z = -0.1000, pitch = -16.0000, roll = -0.0000, yaw = 180.0000, frozenPos = false, dynamic = true, hasCollision = true },
        { modelHash = 0x9970602c, type = 3, boneIndex = 0, x = -0.8760, y = 0.0100, z = -0.1800, pitch = 0.0000, roll = 0.0000, yaw = -91.0000, frozenPos = true, dynamic = true, hasCollision = true },
        { modelHash = 0x9970602c, type = 3, boneIndex = 0, x = 0.8760, y = 0.0100, z = -0.1800, pitch = 0.0000, roll = 0.0000, yaw = 91.0000, frozenPos = false, dynamic = true, hasCollision = true },
    }
}

local function spawnSpinePincher()
    spawnXmlVehicleData(Preset_SpinePincher, "The Spine Pincher")
end

local function spawnFuckT2Blimp()
    spawnXmlVehicleData(Preset_FuckT2Blimp, "FuckT2 Blimp")
end

local function spawnHamburgersRevenge()
    spawnXmlVehicleData(Preset_HamburgersRevenge, "Hamburger's Revenge")
end

local function spawnXmasSleighBoat()
    spawnXmlVehicleData(Preset_XmasSleighBoat, "Xmas Sleigh Boat")
end

local function spawnZombieSabreGT()
    spawnXmlVehicleData(Preset_ZombieSabreGT, "Zombie Sabre GT")
end

local function refreshDiscoveredXmlFiles()
    local files = {}
    local seen = {}
    local function addFile(name)
        if name and name ~= "" and not seen[name:lower()] then
            seen[name:lower()] = true
            table.insert(files, name)
        end
    end

    addFile("SpinePincher.xml")
    addFile("Spinethetic-FuckT2Blimp.xml")
    addFile("Spinethetic-HamburgersRevenge.xml")
    addFile("Spinethetic-XmasSleighBoat.xml")
    addFile("Spinethetic-ZombieSabreGT.xml")

    pcall(function()
        if io and io.popen then
            local dirsToScan = {
                "c:\\Users\\Marcos\\Downloads\\business_manager",
                "C:\\Users\\Marcos\\AppData\\Roaming\\NewWay\\GTAV Enhanced\\scripts",
                "scripts"
            }
            for _, d in ipairs(dirsToScan) do
                local pipe = io.popen('dir /b "' .. d .. '\\*.xml" 2>nul')
                if pipe then
                    for line in pipe:lines() do
                        line = line:gsub("[\r\n]", "")
                        if line:lower():find("%.xml$") and not line:lower():find("mpstatssetup") then
                            addFile(line)
                        end
                    end
                    pipe:close()
                end
            end
        end
    end)

    S.discoveredXmlFiles = files
    return files
end

local function loadAndSpawnXmlVehicle(filePath)
    local targetPath = tostring(filePath or S.customXmlVehiclePath or "SpinePincher.xml"):gsub('^%s*(.-)%s*$', '%1')
    if targetPath == "" then targetPath = "SpinePincher.xml" end

    local xmlContent = nil
    pcall(function()
        if io and io.open then
            local pathsToTry = {
                targetPath,
                "c:\\Users\\Marcos\\Downloads\\business_manager\\" .. targetPath,
                "C:\\Users\\Marcos\\AppData\\Roaming\\NewWay\\GTAV Enhanced\\scripts\\" .. targetPath,
                "scripts/" .. targetPath
            }
            for _, p in ipairs(pathsToTry) do
                local f = io.open(p, "r")
                if f then
                    xmlContent = f:read("*a")
                    f:close()
                    if xmlContent and xmlContent ~= "" then break end
                end
            end
        end
    end)

    if xmlContent and xmlContent ~= "" then
        local data = parseMenyooXml(xmlContent)
        if data and (data.modelHash ~= 0 or (data.attachments and #data.attachments > 0)) then
            spawnXmlVehicleData(data, targetPath)
            return
        end
    end

    local lower = targetPath:lower()
    if lower:find("pincher") then
        spawnSpinePincher()
        return
    elseif lower:find("blimp") or lower:find("fuckt2") then
        spawnFuckT2Blimp()
        return
    elseif lower:find("burger") or lower:find("hamburger") then
        spawnHamburgersRevenge()
        return
    elseif lower:find("sleigh") or lower:find("xmas") then
        spawnXmasSleighBoat()
        return
    elseif lower:find("sabre") or lower:find("zombie") then
        spawnZombieSabreGT()
        return
    end

    notify.warn("Vehicle", "Preset ou arquivo XML nao encontrado: '" .. targetPath .. "'")
end

------------------------------------------------------------
-- CONTINUOUS CHAOS LOOPS
------------------------------------------------------------

local function startSpinPlayerVehLoop()
    if S.spinPlayerVehLoopActive then return end
    S.spinPlayerVehLoopActive = true

    script.run_in_callback(function()
        notify.info("SpyreX", "Player Vehicle Beyblade ENABLED!")
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
        notify.info("SpyreX", "Player Vehicle Beyblade DISABLED.")
    end)
end

local function startSpinAreaVehsLoop()
    if S.spinAreaVehsLoopActive then return end
    S.spinAreaVehsLoopActive = true

    script.run_in_callback(function()
        notify.info("SpyreX", "Area Vehicle Beyblade ENABLED!")
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
        notify.info("SpyreX", "Area Vehicle Beyblade DISABLED.")
    end)
end

local function startInfiniteLevitateLoop()
    if S.infiniteLevitateLoopActive then return end
    S.infiniteLevitateLoopActive = true

    script.run_in_callback(function()
        notify.info("SpyreX", "Area Bounce Mode ENABLED!")
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
        notify.info("SpyreX", "Area Bounce Mode DISABLED.")
    end)
end

local function startVortexLoop()
    if S.vortexLoopActive then return end
    S.vortexLoopActive = true

    script.run_in_callback(function()
        notify.info("SpyreX", "Gravitational Vortex ENABLED!")
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
        notify.info("SpyreX", "Gravitational Vortex DISABLED.")
    end)
end

local function startUfoDiscoLoop()
    if S.ufoDiscoLoopActive then return end
    S.ufoDiscoLoopActive = true

    script.run_in_callback(function()
        notify.info("SpyreX", "UFO Party Mode ENABLED!")
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
        notify.info("SpyreX", "UFO Party Mode DISABLED.")
    end)
end

local function startPushRepulsorLoop()
    if S.pushRepulsorLoopActive then return end
    S.pushRepulsorLoopActive = true

    script.run_in_callback(function()
        notify.info("SpyreX", "Shockwave / Repulsor ENABLED!")
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
        notify.info("SpyreX", "Repulsor DISABLED.")
    end)
end

local function startVehicleRainLoop()
    if S.vehicleRainLoopActive then return end
    S.vehicleRainLoopActive = true

    script.run_in_callback(function()
        notify.info("SpyreX", "Vehicle Rain from Sky ENABLED!")
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
        notify.info("SpyreX", "Vehicle Rain DISABLED.")
    end)
end

local function startVehicleShieldLoop()
    if S.vehicleShieldLoopActive then return end
    S.vehicleShieldLoopActive = true

    script.run_in_callback(function()
        notify.info("SpyreX", "Orbital Supercar Shield ENABLED!")
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
                safeSetInvincible(v, true)
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
        notify.info("SpyreX", "Orbital Supercar Shield DISABLED.")
    end)
end

local spawnedBowlingPins = {}
local bowlingPanto = nil

local function clearBusBowling()
    pcall(function()
        for _, b in ipairs(spawnedBowlingPins) do
            if isValidEntity(b) then safeDeleteEntity(b) end
        end
        spawnedBowlingPins = {}
        if isValidEntity(bowlingPanto) then
            safeDeleteEntity(bowlingPanto)
            bowlingPanto = nil
        end
    end)
end

local function setupBusBowling()
    script.run_in_callback(function()
        clearBusBowling()
        notify.info("SpyreX", "Setting up Bus Bowling (10 Pins)...")

        local ped = getLocalPed()
        local pCoords = ENTITY.GET_ENTITY_COORDS(ped, true)
        local heading = ENTITY.GET_ENTITY_HEADING(ped)
        local rad = math.rad(heading)
        local fwdX = -math.sin(rad)
        local fwdY = math.cos(rad)
        local rightX = fwdY
        local rightY = -fwdX

        local busHash = getHash("bus")
        local pantoHash = getHash("panto")

        STREAMING.REQUEST_MODEL(busHash)
        STREAMING.REQUEST_MODEL(pantoHash)
        local timeout = 0
        while (not STREAMING.HAS_MODEL_LOADED(busHash) or not STREAMING.HAS_MODEL_LOADED(pantoHash)) and timeout < 40 do
            script.yield(10)
            timeout = timeout + 1
        end

        -- 10-pin triangle formation (vertical buses)
        local pinOffsets = {
            { fwd = 25.0, side = 0.0 },
            { fwd = 30.0, side = -3.5 }, { fwd = 30.0, side = 3.5 },
            { fwd = 35.0, side = -7.0 }, { fwd = 35.0, side = 0.0 }, { fwd = 35.0, side = 7.0 },
            { fwd = 40.0, side = -10.5 }, { fwd = 40.0, side = -3.5 }, { fwd = 40.0, side = 3.5 }, { fwd = 40.0, side = 10.5 }
        }

        for _, pos in ipairs(pinOffsets) do
            local bx = pCoords.x + fwdX * pos.fwd + rightX * pos.side
            local by = pCoords.y + fwdY * pos.fwd + rightY * pos.side
            local bz = pCoords.z + 5.0

            local bus = VEHICLE.CREATE_VEHICLE(busHash, bx, by, bz, heading, true, false, false)
            if isValidEntity(bus) then
                pcall(function()
                    ENTITY.SET_ENTITY_AS_MISSION_ENTITY(bus, true, true)
                    ENTITY.SET_ENTITY_ROTATION(bus, 90.0, 0.0, heading, 2, true)
                    ENTITY.SET_ENTITY_VELOCITY(bus, 0.0, 0.0, 0.0)
                    safeSetInvincible(bus, false)
                end)
                table.insert(spawnedBowlingPins, bus)
            end
        end

        -- Spawn Panto and float in front with telekinesis to aim!
        local px = pCoords.x + fwdX * 3.0
        local py = pCoords.y + fwdY * 3.0
        local pz = pCoords.z + 2.5
        local panto = VEHICLE.CREATE_VEHICLE(pantoHash, px, py, pz, heading, true, false, false)
        if isValidEntity(panto) then
            pcall(function()
                ENTITY.SET_ENTITY_AS_MISSION_ENTITY(panto, true, true)
            end)
            bowlingPanto = panto
            HoldVehicleLoop(panto)
        end

        notify.success("SpyreX", "Bowling Alley Setup! Aim and press [SPACE] or click 'Launch Bowling Panto'!")
    end)
end

local function launchBowlingPanto()
    if isValidEntity(S.heldVehicle) then
        LaunchVehicle(S.heldVehicle, 350.0)
        notify.success("SpyreX", "Strike! Panto launched at bowling pins!")
    elseif isValidEntity(bowlingPanto) then
        LaunchVehicle(bowlingPanto, 350.0)
        notify.success("SpyreX", "Strike! Panto launched at bowling pins!")
    else
        notify.warn("SpyreX", "Setup Bowling Alley first!")
    end
end

local function triggerBusFortressWall()
    script.run_in_callback(function()
        notify.info("SpyreX", "Building Bus Fortress Wall...")
        local pCoords = ENTITY.GET_ENTITY_COORDS(getLocalPed(), true)
        local busHash = getHash("bus")
        STREAMING.REQUEST_MODEL(busHash)
        local timeout = 0
        while not STREAMING.HAS_MODEL_LOADED(busHash) and timeout < 25 do script.yield(10); timeout = timeout + 1 end

        for i = -4, 4 do
            local bVeh = VEHICLE.CREATE_VEHICLE(busHash, pCoords.x + (i * 3.8), pCoords.y + 12.0, pCoords.z + 0.5, 0.0, true, false, false)
            if isValidEntity(bVeh) then ENTITY.FREEZE_ENTITY_POSITION(bVeh, true) end
        end
        notify.success("SpyreX", "Bus Fortress Wall Complete!")
    end)
end

local function startVehicleSnakeLoop()
    if S.vehicleSnakeLoopActive then return end
    S.vehicleSnakeLoopActive = true

    script.run_in_callback(function()
        notify.info("SpyreX", "Follow the Leader (Vehicle Snake) ENABLED!")
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
        notify.info("SpyreX", "Follow the Leader DISABLED.")
    end)
end

local function startZombiePedOutbreakLoop()
    if S.zombiePedOutbreakLoopActive then return end
    S.zombiePedOutbreakLoopActive = true

    script.run_in_callback(function()
        notify.warn("Zombie Apocalypse", "Invasao Zombie iniciada! Eles estao surgindo nos arredores...")
        showFeedNotification("~r~[APOCALIPSE ZOMBIE] ~w~Horda de mortos-vivos surgindo na regiao!")

        local zHash = getHash("u_m_y_zombie_01")
        if not requestAndLoadModel(zHash, 150) then
            notify.error("Zombie", "Nao foi possivel carregar o modelo de zombie.")
            S.zombiePedOutbreakLoopActive = false
            S.zombiePedOutbreakActive = false
            return
        end

        local zWeapons = { "WEAPON_BATTLEAXE", "WEAPON_MACHETE", "WEAPON_HATCHET", "WEAPON_KNIFE", "WEAPON_CROWBAR", "WEAPON_DAGGER" }
        local activeZombies = {}
        local maxZombies = 16

        local function spawnSingleZombie(playerPed, playerCoords)
            if not isValidEntity(playerPed) then return nil end

            -- Espalha longe do jogador (entre 48m e 85m) em ângulo circular aleatório
            -- para parecer que surgiram do nada, fora do campo de visão imediato
            local angle = math.random() * (math.pi * 2)
            local dist = math.random(48, 85)
            local sX = playerCoords.x + (math.cos(angle) * dist)
            local sY = playerCoords.y + (math.sin(angle) * dist)
            local sZ = playerCoords.z + 1.0

            pcall(function()
                if MISC and MISC.GET_GROUND_Z_FOR_3D_COORD then
                    local ok, gZ = MISC.GET_GROUND_Z_FOR_3D_COORD(sX, sY, sZ + 40.0, false, false)
                    if ok and gZ and type(gZ) == "number" and gZ > 0 then
                        sZ = gZ
                    end
                end
            end)

            local zPed = 0
            pcall(function()
                zPed = PED.CREATE_PED(26, zHash, sX, sY, sZ, math.random(0, 359) + 0.0, true, false)
            end)

            if isValidEntity(zPed) then
                getControlOfEntity(zPed)
                pcall(function()
                    ENTITY.SET_ENTITY_AS_MISSION_ENTITY(zPed, true, true)
                    ENTITY.PLACE_ENTITY_ON_GROUND_PROPERLY(zPed)
                    TASK.CLEAR_PED_TASKS_IMMEDIATELY(zPed)
                    PED.SET_BLOCKING_OF_NON_TEMPORARY_EVENTS(zPed, true)
                    PED.SET_PED_CAN_RAGDOLL(zPed, true)
                    PED.SET_PED_COMBAT_ABILITY(zPed, 2)
                    PED.SET_PED_COMBAT_RANGE(zPed, 2)
                    PED.SET_PED_COMBAT_MOVEMENT(zPed, 3)
                    ENTITY.SET_ENTITY_HEALTH(zPed, 250)
                    PED.SET_PED_MAX_HEALTH(zPed, 250)

                    -- Configura relacionamento agressivo contra o jogador
                    local playerGroup = PED.GET_PED_RELATIONSHIP_GROUP_HASH(playerPed)
                    local zGroup = getHash("HATES_PLAYER")
                    PED.SET_PED_RELATIONSHIP_GROUP_HASH(zPed, zGroup)
                    PED.SET_RELATIONSHIP_BETWEEN_GROUPS(5, zGroup, playerGroup)
                    PED.SET_RELATIONSHIP_BETWEEN_GROUPS(5, playerGroup, zGroup)

                    -- Arma corpo-a-corpo sanguinária
                    local wName = zWeapons[math.random(#zWeapons)]
                    local wHash = getHash(wName)
                    WEAPON.GIVE_DELAYED_WEAPON_TO_PED(zPed, wHash, 100, true)
                    WEAPON.SET_CURRENT_PED_WEAPON(zPed, wHash, true)

                    -- Persegue e ataca agressivamente o jogador
                    TASK.TASK_COMBAT_PED(zPed, playerPed, 0, 16)
                end)
                table.insert(activeZombies, zPed)
                return zPed
            end
            return nil
        end

        -- Spawn inicial da horda espalhada longe do player
        local myPed = getLocalPed()
        if isValidEntity(myPed) then
            local pPos = ENTITY.GET_ENTITY_COORDS(myPed, true)
            for i = 1, 10 do
                spawnSingleZombie(myPed, pPos)
                script.yield(30)
            end
        end

        -- Loop de manutenção enquanto o apocalipse estiver ativo
        while S.zombiePedOutbreakActive do
            script.yield(1500)
            local curPed = getLocalPed()
            if isValidEntity(curPed) and not PED.IS_PED_INJURED(curPed) then
                local curCoords = ENTITY.GET_ENTITY_COORDS(curPed, true)

                -- Limpa zumbis mortos ou que ficaram muito distantes (> 140m)
                local aliveList = {}
                for _, z in ipairs(activeZombies) do
                    if isValidEntity(z) then
                        local isDead = PED.IS_PED_INJURED(z)
                        local zPos = ENTITY.GET_ENTITY_COORDS(z, true)
                        local dX = zPos.x - curCoords.x
                        local dY = zPos.y - curCoords.y
                        local dist = math.sqrt(dX * dX + dY * dY)

                        if isDead or dist > 140.0 then
                            safeDeleteEntity(z)
                        else
                            table.insert(aliveList, z)
                            -- Reafirma ordem de perseguição se tiver parado
                            pcall(function()
                                if not PED.IS_PED_IN_COMBAT(z, curPed) then
                                    TASK.TASK_COMBAT_PED(z, curPed, 0, 16)
                                end
                            end)
                        end
                    end
                end
                activeZombies = aliveList

                -- Reabastece a horda mantendo até 16 zumbis ativos espalhados nos arredores
                while #activeZombies < maxZombies and S.zombiePedOutbreakActive do
                    spawnSingleZombie(curPed, curCoords)
                    script.yield(60)
                end
            end
        end

        -- Limpeza segura ao desativar a checkbox
        for _, z in ipairs(activeZombies) do
            if isValidEntity(z) then
                safeDeleteEntity(z)
                script.yield(15)
            end
        end
        activeZombies = {}
        STREAMING.SET_MODEL_AS_NO_LONGER_NEEDED(zHash)

        S.zombiePedOutbreakLoopActive = false
        S.zombiePedOutbreakActive = false
        notify.info("Zombie Apocalypse", "Apocalipse Zombie desativado e area limpa.")
        showFeedNotification("~g~[ZOMBIE] ~w~Apocalipse Zombie finalizado.")
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
                        cachedTargetVeh = getTargetVehicle(12.0)
                    end

                    if isValidEntity(cachedTargetVeh) then
                        local pCoords = ENTITY.GET_ENTITY_COORDS(ped, true)
                        local vCoords = ENTITY.GET_ENTITY_COORDS(cachedTargetVeh, true)
                        local dx = pCoords.x - vCoords.x
                        local dy = pCoords.y - vCoords.y
                        local dz = pCoords.z - vCoords.z
                        local dist = math.sqrt(dx*dx + dy*dy + dz*dz)

                        if dist <= 14.0 then
                            pcall(function()
                                if PAD then
                                    PAD.DISABLE_CONTROL_ACTION(0, 38, true)
                                    PAD.DISABLE_CONTROL_ACTION(0, 51, true)
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
                        else
                            cachedTargetVeh = nil
                        end
                    end
                end

                if S.disableRagdoll then updateRagdollState() end
            end)
            script.yield(0)
        end
        S.hotkeyLoopActive = false
    end)
end

------------------------------------------------------------
-- SECURITY WATCHDOG: DETECTOR DE VOTE KICK & REPORTES
------------------------------------------------------------

local reportTrackedStats = {
    { key = "griefing",     stat = "MPPLY_GRIEFING",           label = "Griefing (Atrapalhar Jogo)" },
    { key = "exploits",     stat = "MPPLY_EXPLOITS",           label = "Uso de Exploits/Hacks" },
    { key = "gameExploits", stat = "MPPLY_GAME_EXPLOITS",      label = "Game Exploits" },
    { key = "language",     stat = "MPPLY_OFFENSIVE_LANGUAGE", label = "Linguagem Ofensiva" },
    { key = "vcHate",       stat = "MPPLY_VC_HATE",            label = "Discurso de Odio (Voz)" },
    { key = "tcHate",       stat = "MPPLY_TC_HATE",            label = "Discurso de Odio (Texto)" },
    { key = "ugc",          stat = "MPPLY_OFFENSIVE_UGC",      label = "Conteudo UGC Ofensivo" },
    { key = "badCrew",      stat = "MPPLY_BAD_CREW_NAME",      label = "Nome de Comando Ofensivo" }
}

local function getStatIntSafe(statName)
    local val = 0
    local found = false
    pcall(function()
        if stats and stats.get_int then
            local v = stats.get_int(statName)
            if v ~= nil then
                val = v
                found = true
            end
        end
    end)
    if found then return tonumber(val) or 0 end

    pcall(function()
        if STATS and STATS.STAT_GET_INT then
            local h = getHash(statName)
            if h ~= 0 then
                local r1, r2 = STATS.STAT_GET_INT(h, -1)
                if type(r1) == "number" then
                    val = r1
                elseif type(r2) == "number" then
                    val = r2
                end
            end
        end
    end)
    return tonumber(val) or 0
end

local function refreshReportBaseline()
    for _, item in ipairs(reportTrackedStats) do
        local cur = getStatIntSafe(item.stat)
        S.watchdogReportStats[item.key] = cur
    end
    S.watchdogBaselineSet = true
end

local function isLocalPlayerVoteKicked()
    local isVoted = false
    local myPid = getLocalPid()
    pcall(function()
        if NETWORK and NETWORK.NETWORK_SESSION_GET_KICK_VOTE then
            local res = NETWORK.NETWORK_SESSION_GET_KICK_VOTE(myPid)
            if res == true or res == 1 then
                isVoted = true
            end
        end
    end)
    return isVoted
end

local function addSecurityAlert(text)
    local ts = os.date and os.date("%H:%M:%S") or "Alerta"
    table.insert(S.watchdogRecentAlerts, 1, { time = ts, text = text })
    while #S.watchdogRecentAlerts > 15 do
        table.remove(S.watchdogRecentAlerts)
    end
end

local function startSecurityWatchdogLoop()
    if S.watchdogLoopActive then return end
    if not (script and script.run_in_callback) then return end

    S.watchdogLoopActive = true
    script.run_in_callback(function()
        refreshReportBaseline()

        while S.watchdogActive do
            pcall(function()
                -- 1. Verificacao de Vote Kick (a cada 1s)
                local currentlyKicked = isLocalPlayerVoteKicked()
                if currentlyKicked and not S.watchdogKickVoteDetected then
                    S.watchdogKickVoteDetected = true
                    pcall(function()
                        if AUDIO and AUDIO.PLAY_SOUND_FRONTEND then
                            AUDIO.PLAY_SOUND_FRONTEND(-1, "ScreenFlash", "WastedSounds", true)
                            AUDIO.PLAY_SOUND_FRONTEND(-1, "Air_Defences_Activated", "DLC_sum20_Business_Hub_Ent_Sounds", true)
                        end
                    end)
                    notify.warn("SEGURANCA", "ALERTA: Um jogador votou para te expulsar da sessao (Vote Kick)!")
                    showFeedNotification("~r~[VOTE KICK DETECTADO] ~w~Alguem votou para te expulsar da sessao!")
                    addSecurityAlert("Voto de expulsao (Vote Kick) iniciado contra voce!")
                elseif not currentlyKicked and S.watchdogKickVoteDetected then
                    S.watchdogKickVoteDetected = false
                end

                -- 2. Verificacao de Estatisticas de Reportes da Conta
                for _, item in ipairs(reportTrackedStats) do
                    local curVal = getStatIntSafe(item.stat)
                    local oldVal = S.watchdogReportStats[item.key]

                    if oldVal ~= nil and curVal > oldVal then
                        local diff = curVal - oldVal
                        pcall(function()
                            if AUDIO and AUDIO.PLAY_SOUND_FRONTEND then
                                AUDIO.PLAY_SOUND_FRONTEND(-1, "ScreenFlash", "WastedSounds", true)
                                AUDIO.PLAY_SOUND_FRONTEND(-1, "BASE_JUMP_PASSED", "HUD_AWARDS", true)
                            end
                        end)
                        local msg = string.format("Sua conta foi reportada por: %s (+%d)", item.label, diff)
                        notify.error("REPORTE DETECTADO", msg)
                        showFeedNotification(string.format("~r~[REPORTE DA CONTA] ~w~Novo reporte: ~y~%s ~s~(+%d)", item.label, diff))
                        addSecurityAlert(msg)
                        S.watchdogReportStats[item.key] = curVal
                    elseif oldVal == nil or curVal ~= oldVal then
                        S.watchdogReportStats[item.key] = curVal
                    end
                end
            end)

            script.yield(1000)
        end
        S.watchdogLoopActive = false
    end)
end

local function startAutoScriptHostLoop()
    if S.autoScriptHostLoopActive then return end
    if not (script and script.run_in_callback) then return end

    S.autoScriptHostLoopActive = true
    script.run_in_callback(function()
        while S.autoClaimScriptHost do
            pcall(function()
                local localPid = getLocalPid()
                local scHostPid = -1
                if NETWORK and NETWORK.NETWORK_GET_HOST_OF_SCRIPT then
                    scHostPid = NETWORK.NETWORK_GET_HOST_OF_SCRIPT("freemode")
                end
                if scHostPid ~= localPid and NETWORK and NETWORK.NETWORK_REQUEST_TO_BE_HOST_OF_THIS_SCRIPT then
                    NETWORK.NETWORK_REQUEST_TO_BE_HOST_OF_THIS_SCRIPT()
                end
            end)
            script.yield(3000)
        end
        S.autoScriptHostLoopActive = false
    end)
end

startHotkeyLoop()
startSecurityWatchdogLoop()

------------------------------------------------------------
-- INCEPTION STUNT TRACKS & ARENA PROPS STATE & LOGIC
------------------------------------------------------------

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

            -- Requisita colisão da malha 3D nas coordenadas para solidez imediata
            if STREAMING and STREAMING.REQUEST_COLLISION_AT_COORD then
                STREAMING.REQUEST_COLLISION_AT_COORD(x, y, z)
            end

            if not isDyn then
                ENTITY.FREEZE_ENTITY_POSITION(obj, true)
                if ENTITY.SET_ENTITY_DYNAMIC then ENTITY.SET_ENTITY_DYNAMIC(obj, false) end
                ENTITY.SET_ENTITY_COLLISION(obj, true, true)
                if ENTITY.SET_ENTITY_CAN_BE_DAMAGED then ENTITY.SET_ENTITY_CAN_BE_DAMAGED(obj, false) end
                safeSetInvincible(obj, true)
                if ENTITY.SET_ENTITY_SHOULD_FREEZE_WAITING_ON_COLLISION then
                    ENTITY.SET_ENTITY_SHOULD_FREEZE_WAITING_ON_COLLISION(obj, true)
                end
            else
                ENTITY.FREEZE_ENTITY_POSITION(obj, false)
                if ENTITY.SET_ENTITY_DYNAMIC then ENTITY.SET_ENTITY_DYNAMIC(obj, true) end
                ENTITY.SET_ENTITY_COLLISION(obj, true, true)
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
    script.run_in_callback(function()
        local count = 0
        local oldList = S.spawned_stunt_objects or {}
        S.spawned_stunt_objects = {}
        for _, obj in ipairs(oldList) do
            if isValidEntity(obj) then
                safeDeleteEntity(obj)
                count = count + 1
                script.yield(15)
            end
        end
        notify.info("Structures", string.format("All %d structures have been removed!", count))
    end)
end

local function undoLastStuntObject()
    script.run_in_callback(function()
        if S.spawned_stunt_objects and #S.spawned_stunt_objects > 0 then
            local lastObj = table.remove(S.spawned_stunt_objects)
            if isValidEntity(lastObj) then
                safeDeleteEntity(lastObj)
                notify.info("Structures", "Last object removed successfully!")
                return
            end
        end
        notify.warn("Structures", "No recent object to undo.")
    end)
end

local function spawnStuntTrack(presetList, presetName)
    if S.is_spawning_stunt then notify.warn("Structures", "Track construction already in progress...") return end
    S.is_spawning_stunt = true

    script.run_in_callback(function()
        local my_ped = getLocalPed()
        local my_pos = ENTITY.GET_ENTITY_COORDS(my_ped, true)
        local center_z = my_pos.z + S.stunt_altitude
        notify.info("Structures", "Building " .. presetName .. " at " .. math.floor(S.stunt_altitude) .. "m in the sky...")
        local count = 0

        for _, item in ipairs(presetList) do
            local h = getHash(item.model)
            if h ~= 0 then
                STREAMING.REQUEST_MODEL(h)
                local t = 0
                while not STREAMING.HAS_MODEL_LOADED(h) and t < 100 do script.yield(10); t = t + 1 end
                if STREAMING.HAS_MODEL_LOADED(h) then
                    local obj = safeCreateStuntProp(h, my_pos.x + item.rel_x, my_pos.y + item.rel_y, center_z + item.rel_z, false)
                    if isValidEntity(obj) then
                        pcall(function()
                            ENTITY.SET_ENTITY_ROTATION(obj, 180.0, 0.0, item.yaw, 2, true)
                            ENTITY.FREEZE_ENTITY_POSITION(obj, true)
                            ENTITY.SET_ENTITY_COLLISION(obj, true, true)
                            if ENTITY.SET_ENTITY_SHOULD_FREEZE_WAITING_ON_COLLISION then
                                ENTITY.SET_ENTITY_SHOULD_FREEZE_WAITING_ON_COLLISION(obj, true)
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
        notify.success("Structures", string.format("%s built successfully! (%d Objects)", presetName, count))
    end)
end

local function spawnTotalSupremeChaos()
    if S.is_spawning_stunt then notify.warn("Structures", "Track construction already in progress...") return end
    S.is_spawning_stunt = true

    script.run_in_callback(function()
        local ped = getLocalPed()
        local pCoords = ENTITY.GET_ENTITY_COORDS(ped, true)
        local baseHeading = ENTITY.GET_ENTITY_HEADING(ped)
        local rad = math.rad(baseHeading)
        local cosH = math.cos(rad)
        local sinH = math.sin(rad)
        local skyZ = pCoords.z + S.stunt_altitude

        notify.info("Structures", "GENERATING TOTAL SUPREME CHAOS (SKY + GROUND)...")
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
                    local obj = safeCreateStuntProp(h, piece.x, piece.y, piece.z, false)
                    if isValidEntity(obj) then
                        pcall(function()
                            ENTITY.SET_ENTITY_ROTATION(obj, piece.pitch or 0.0, piece.roll or 0.0, piece.yaw or 0.0, 2, true)
                            ENTITY.FREEZE_ENTITY_POSITION(obj, true)
                            ENTITY.SET_ENTITY_COLLISION(obj, true, true)
                            if ENTITY.SET_ENTITY_SHOULD_FREEZE_WAITING_ON_COLLISION then
                                ENTITY.SET_ENTITY_SHOULD_FREEZE_WAITING_ON_COLLISION(obj, true)
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
        notify.success("Structures", string.format("TOTAL SUPREME CHAOS SPAWNED! (%d Structures on Sky and Ground)", count))
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
            local obj = safeCreateStuntProp(h, rx, ry, my_pos.z - 0.2, false)
            if isValidEntity(obj) then
                pcall(function()
                    ENTITY.SET_ENTITY_ROTATION(obj, 0.0, 0.0, heading, 2, true)
                    ENTITY.FREEZE_ENTITY_POSITION(obj, true)
                    ENTITY.SET_ENTITY_COLLISION(obj, true, true)
                    if ENTITY.SET_ENTITY_SHOULD_FREEZE_WAITING_ON_COLLISION then
                        ENTITY.SET_ENTITY_SHOULD_FREEZE_WAITING_ON_COLLISION(obj, true)
                    end
                end)
                table.insert(S.spawned_stunt_objects, obj)
                STREAMING.SET_MODEL_AS_NO_LONGER_NEEDED(h)
                notify.success("Structures", "Acrobatic ramp spawned in front of you!")
            end
        end
    end)
end

local function spawnSinglePropAtPlayer(modelNameOrHash, customDist, customZ, customYaw, freeze, targetPid)
    script.run_in_callback(function()
        local myLocalPid = getLocalPid()
        local actualPid = (targetPid == nil or targetPid == -1) and myLocalPid or targetPid
        local ped = getPlayerPed(actualPid)
        if not isValidEntity(ped) then notify.warn("Props", "Target player not found!"); return end
        
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
        if not h or h == 0 then notify.warn("Props", "Invalid model: " .. tostring(modelNameOrHash)) return end

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
                local pName = (actualPid == myLocalPid) and "in front of you" or ("in front of " .. getPlayerName(actualPid))
                notify.success("Props", string.format("Object [%s] spawned %s!", tostring(modelNameOrHash), pName))
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
                notify.success("UFO", "UFO spawned at fixed coordinates [-75.015, -818.215, 326.176]!")
            end
        end
    end)
end

local function removeFixedCoordsUfo()
    if isValidEntity(S.fixedUfoObject) then
        pcall(function() ENTITY.SET_ENTITY_AS_MISSION_ENTITY(S.fixedUfoObject, true, true); ENTITY.DELETE_ENTITY(S.fixedUfoObject) end)
        S.fixedUfoObject = nil
        notify.info("UFO", "Fixed Point UFO removed!")
    end
end

local function spawnMazeBankProject()
    script.run_in_callback(function()
        for _, b in ipairs(S.spawned_mazebank_objects) do
            if isValidEntity(b) then pcall(function() ENTITY.SET_ENTITY_AS_MISSION_ENTITY(b, true, true); ENTITY.DELETE_ENTITY(b) end) end
        end
        S.spawned_mazebank_objects = {}
        notify.info("Maze Bank", "Building Maze Bank Project...")

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
        notify.success("Maze Bank", string.format("Maze Bank Project [%d objects] spawned successfully!", #S.spawned_mazebank_objects))
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
    notify.info("Maze Bank", string.format("Maze Bank Project (%d objects) removed from map!", count))
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
        notify.success("Maze Bank", string.format("You and %d players teleported to the top of Maze Bank!", count))
    end)
end

------------------------------------------------------------
-- PLAYER PROP ATTACHMENT SUITE
------------------------------------------------------------

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
    pcall(function()
        ENTITY.ATTACH_ENTITY_TO_ENTITY(
            obj, ped, boneIndex,
            offX or 0.0, offY or 0.0, offZ or 0.0,
            rotX or 0.0, rotY or 0.0, rotZ or 0.0,
            true, false, false, false, 2, true
        )
        attached = true
    end)

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
        if not isValidEntity(ped) then notify.warn("Attachments", "Player not found!"); return end

        local hash = getHash(modelName)
        if not hash or hash == 0 then notify.warn("Attachments", "Invalid model!"); return end

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
        if not STREAMING.HAS_MODEL_LOADED(hash) then notify.warn("Attachments", "Failed to load model: " .. tostring(modelName)); return end

        local coords = getTargetCoordsSafe(actualPid, ped)

        local obj = safeCreateStuntProp(hash, coords.x, coords.y, coords.z, false)
        STREAMING.SET_MODEL_AS_NO_LONGER_NEEDED(hash)
        if not isValidEntity(obj) then notify.error("Attachments", "Failed to instantiate object in world."); return end

        configureStuntEntity(obj, actualPid)
        attachEntityDirect(obj, ped, boneId or 24818, offX, offY, offZ, rotX, rotY, rotZ)

        if not S.attached_player_props[actualPid] then S.attached_player_props[actualPid] = {} end

        local isConeProp = (modelName == "prop_mp_cone_01" or modelName == "prop_roadcone02a")
        table.insert(S.attached_player_props[actualPid], {
            obj = obj, hash = hash, modelName = modelName, boneId = boneId or 24818,
            offX = offX or 0.0, offY = offY or 0.0, offZ = offZ or 0.0,
            rotX = rotX or 0.0, rotY = rotY or 0.0, rotZ = rotZ or 0.0,
            isCone = isConeProp
        })

        startAttachmentKeeperLoop()
        local pName = (actualPid == myLocalPid) and "You" or getPlayerName(actualPid)
        notify.success("Attachments", string.format("Object [%s] attached to %s!", tostring(modelName), pName))
    end)
end

local function attachDualKatanas(targetPid)
    script.run_in_callback(function()
        local myLocalPid = getLocalPid()
        local actualPid = (targetPid == nil or targetPid == -1) and myLocalPid or targetPid
        local ped = getPlayerPed(actualPid)
        if not isValidEntity(ped) then notify.warn("Attachments", "Player not found!"); return end

        local leftEntry = Presets.weapon_list["Weapon Katana Left"]
        local rightEntry = Presets.weapon_list["Weapon Katana Right"]
        if not leftEntry or not rightEntry then return end

        local hash = getHash(leftEntry.Prop)
        STREAMING.REQUEST_MODEL(hash)
        local t = 0
        while not STREAMING.HAS_MODEL_LOADED(hash) and t < 80 do script.yield(10); t = t + 1 end
        if not STREAMING.HAS_MODEL_LOADED(hash) then
            notify.warn("Attachments", "Failed to load Katana model!")
            return
        end

        local coords = getTargetCoordsSafe(actualPid, ped)

        -- 1. Attach Katana Left
        local pL = leftEntry.PropPlacement
        local objLeft = safeCreateStuntProp(hash, coords.x, coords.y, coords.z, false)
        if isValidEntity(objLeft) then
            configureStuntEntity(objLeft, actualPid)
            attachEntityDirect(objLeft, ped, leftEntry.PropBone or 24817, pL[1], pL[2], pL[3], pL[4], pL[5], pL[6])
            if not S.attached_player_props[actualPid] then S.attached_player_props[actualPid] = {} end
            table.insert(S.attached_player_props[actualPid], {
                obj = objLeft, hash = hash, modelName = leftEntry.Prop, boneId = leftEntry.PropBone or 24817,
                offX = pL[1], offY = pL[2], offZ = pL[3], rotX = pL[4], rotY = pL[5], rotZ = pL[6],
                isLeftKatana = true
            })
        end

        script.yield(50)

        -- 2. Attach Katana Right
        local pR = rightEntry.PropPlacement
        local objRight = safeCreateStuntProp(hash, coords.x, coords.y, coords.z, false)
        if isValidEntity(objRight) then
            configureStuntEntity(objRight, actualPid)
            attachEntityDirect(objRight, ped, rightEntry.PropBone or 24817, pR[1], pR[2], pR[3], pR[4], pR[5], pR[6])
            table.insert(S.attached_player_props[actualPid], {
                obj = objRight, hash = hash, modelName = rightEntry.Prop, boneId = rightEntry.PropBone or 24817,
                offX = pR[1], offY = pR[2], offZ = pR[3], rotX = pR[4], rotY = pR[5], rotZ = pR[6],
                isRightKatana = true
            })
        end

        STREAMING.SET_MODEL_AS_NO_LONGER_NEEDED(hash)
        startAttachmentKeeperLoop()

        local pName = (actualPid == myLocalPid) and "You" or getPlayerName(actualPid)
        notify.success("Attachments", "Dual Katanas anexadas com sucesso em " .. pName .. "!")
    end)
end

local function removeUniversalTunerObject()
    script.run_in_callback(function()
        if S.tunerObj and isValidEntity(S.tunerObj) then
            pcall(function()
                ENTITY.DETACH_ENTITY(S.tunerObj, true, true)
                safeDeleteEntity(S.tunerObj)
            end)
            S.tunerObj = nil
        end
    end)
end

local removeTunerAttachment = removeUniversalTunerObject

local function selectTunerObject(idx)
    S.tunerSelectedIdx = idx
    local preset = Presets.tuner_objects[idx]
    if preset then
        S.tunerName = preset.name
        S.tunerModel = preset.model
        S.tunerBone = preset.bone
        S.tunerX = preset.x
        S.tunerY = preset.y
        S.tunerZ = preset.z
        S.tunerRotX = preset.rx
        S.tunerRotY = preset.ry
        S.tunerRotZ = preset.rz
    end
end

local function updateUniversalTunerTransform()
    local ped = getLocalPed()
    if isValidEntity(S.tunerObj) and isValidEntity(ped) then
        attachEntityDirect(S.tunerObj, ped, S.tunerBone or 24818, S.tunerX, S.tunerY, S.tunerZ, S.tunerRotX, S.tunerRotY, S.tunerRotZ)
    end
end

local function spawnUniversalTunerObject()
    script.run_in_callback(function()
        removeUniversalTunerObject()
        script.yield(30)

        local ped = getLocalPed()
        if not isValidEntity(ped) then return end

        local modelToSpawn = S.tunerModel
        if modelToSpawn == "custom" then
            modelToSpawn = S.customAttachModelInput or "prop_mp_cone_01"
        end

        local hash = getHash(modelToSpawn)
        if not hash or hash == 0 then notify.warn("Tuner", "Modelo invalido!"); return end

        STREAMING.REQUEST_MODEL(hash)
        local t = 0
        while not STREAMING.HAS_MODEL_LOADED(hash) and t < 80 do script.yield(10); t = t + 1 end
        if not STREAMING.HAS_MODEL_LOADED(hash) then notify.warn("Tuner", "Falha ao carregar modelo: " .. tostring(modelToSpawn)); return end

        local coords = ENTITY.GET_ENTITY_COORDS(ped, true)
        local obj = safeCreateStuntProp(hash, coords.x, coords.y, coords.z, false)
        STREAMING.SET_MODEL_AS_NO_LONGER_NEEDED(hash)

        if not isValidEntity(obj) then notify.error("Tuner", "Erro ao criar objeto no mundo!"); return end

        configureStuntEntity(obj, getLocalPid())
        attachEntityDirect(obj, ped, S.tunerBone or 24818, S.tunerX, S.tunerY, S.tunerZ, S.tunerRotX, S.tunerRotY, S.tunerRotZ)

        S.tunerObj = obj
        notify.success("Tuner", string.format("Objeto [%s] spawnado para ajuste ao vivo!", tostring(S.tunerName)))
    end)
end

local function removePlayerAttachedProps(targetPid)
    script.run_in_callback(function()
        local actualPid = (targetPid == -1 or targetPid == nil) and getLocalPid() or targetPid
        local list = S.attached_player_props[actualPid]
        S.attached_player_props[actualPid] = nil
        local count = 0
        if list then
            for _, item in ipairs(list) do
                local obj = type(item) == "table" and item.obj or item
                if isValidEntity(obj) then
                    pcall(function()
                        ENTITY.DETACH_ENTITY(obj, true, true)
                        safeDeleteEntity(obj)
                    end)
                    count = count + 1
                    script.yield(10)
                end
            end
        end
        if actualPid == getLocalPid() and S.tunerObj and isValidEntity(S.tunerObj) then
            safeDeleteEntity(S.tunerObj)
            S.tunerObj = nil
        end
        notify.info("Attachments", string.format("%d objects removed from player!", count))
    end)
end

local function removeAllAttachedProps()
    script.run_in_callback(function()
        local count = 0
        local oldProps = S.attached_player_props or {}
        S.attached_player_props = {}
        for targetPid, list in pairs(oldProps) do
            if list then
                for _, item in ipairs(list) do
                    local obj = type(item) == "table" and item.obj or item
                    if isValidEntity(obj) then
                        pcall(function()
                            ENTITY.DETACH_ENTITY(obj, true, true)
                            safeDeleteEntity(obj)
                        end)
                        count = count + 1
                        script.yield(10)
                    end
                end
            end
        end
        if S.tunerObj and isValidEntity(S.tunerObj) then
            safeDeleteEntity(S.tunerObj)
            S.tunerObj = nil
        end
        notify.info("Attachments", string.format("All %d attached objects removed!", count))
    end)
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
        if not isValidEntity(ped) then notify.warn("Cages", "Player not found!"); return end

        local cageHash = cageType
        if not cageHash or cageHash == 0 or cageHash == "random" then
            cageHash = STAND_CAGE_MODELS[math.random(#STAND_CAGE_MODELS)]
        elseif type(cageHash) == "string" then
            cageHash = getHash(cageHash)
        end

        local coords = getTargetCoordsSafe(actualPid, ped)
        local pHeading = ENTITY.GET_ENTITY_HEADING(ped)

        if cageHash == getHash("prop_gold_cont_01") then
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

        local pName = (actualPid == myLocalPid) and "You" or getPlayerName(actualPid)
        notify.success("Cages", string.format("Stand Cage applied to %s!", pName))
    end)
end

local function spawnApeCrateCageOnPlayer(targetPid)
    spawnAdvancedCageOnPlayer(targetPid, "v_med_apecrate")
end

------------------------------------------------------------
-- VISUAL FX - LIGHTNING LAB & HDR STORM (ATMOSPHERE & NETWORK SYNC)
------------------------------------------------------------

local function isLocalScriptHost()
    local isSh = false
    pcall(function()
        if NETWORK and NETWORK.NETWORK_GET_HOST_OF_SCRIPT then
            local shPid = NETWORK.NETWORK_GET_HOST_OF_SCRIPT("freemode")
            if shPid ~= nil and shPid ~= -1 and getLocalPid then
                isSh = (shPid == getLocalPid())
            end
        end
    end)
    return isSh
end

local function setScriptGlobalInt(globalIdx, val)
    pcall(function()
        if ScriptGlobal then
            ScriptGlobal(globalIdx):set_int(val)
        elseif script and script.get_global then
            script.get_global(globalIdx):set_int(val)
        end
    end)
end

local function broadcastAreaLightning()
    pcall(function()
        local myPed = getLocalPed()
        if not myPed or not isValidEntity(myPed) then return end
        local myPos = getEntityCoords(myPed)
        if not myPos then return end

        -- 1. Relampago nas coordenadas celestes acima do jogador local
        if MISC and MISC.FORCE_LIGHTNING_FLASH_AT_COORDS then
            MISC.FORCE_LIGHTNING_FLASH_AT_COORDS(myPos.x, myPos.y, myPos.z + 20.0, 5.0)
        end

        -- 2. Impacto de tremor e som sônico no mundo (Tipo 70 = Shockwave sônico sem dano físico)
        if FIRE and FIRE.ADD_EXPLOSION then
            FIRE.ADD_EXPLOSION(myPos.x, myPos.y, myPos.z + 25.0, 70, 0.0, true, false, 3.5, false)
        end

        -- 3. Projeta clarão acima dos outros jogadores da sessão
        if players and players.get_all then
            local allP = players.get_all()
            for _, p in ipairs(allP) do
                if p and p:is_valid() and not p:is_local() then
                    local pPed = p:get_ped()
                    if pPed and isValidEntity(pPed) then
                        local pPos = getEntityCoords(pPed)
                        if pPos and MISC and MISC.FORCE_LIGHTNING_FLASH_AT_COORDS then
                            MISC.FORCE_LIGHTNING_FLASH_AT_COORDS(pPos.x, pPos.y, pPos.z + 25.0, 4.0)
                        end
                    end
                end
            end
        end
    end)
end

local function triggerSingleFlash()
    script.run_in_callback(function()
        pcall(function()
            if MISC and MISC.FORCE_LIGHTNING_FLASH then
                MISC.FORCE_LIGHTNING_FLASH()
            end
        end)
        if S.syncLightningNetwork then
            broadcastAreaLightning()
        end
    end)
end

local function triggerStrobeBurst(flashCount, delayMs)
    if S.isStrobeRunning then return end
    S.isStrobeRunning = true

    flashCount = flashCount or 4
    delayMs = delayMs or 85

    script.run_in_callback(function()
        -- Som de trovao local
        pcall(function()
            if AUDIO and AUDIO.REQUEST_SCRIPT_AUDIO_BANK then
                AUDIO.REQUEST_SCRIPT_AUDIO_BANK("DLC_HALLOWEEN_FV_Sounds", false, -1)
            end
            if AUDIO and AUDIO.PLAY_SOUND_FRONTEND then
                AUDIO.PLAY_SOUND_FRONTEND(-1, "Thunder", "DLC_HALLOWEEN_FV_Sounds", true)
            end
        end)

        -- Rajada de relampagos estroboscopicos
        for i = 1, flashCount do
            pcall(function()
                if MISC and MISC.FORCE_LIGHTNING_FLASH then
                    MISC.FORCE_LIGHTNING_FLASH()
                end
            end)
            if S.syncLightningNetwork then
                broadcastAreaLightning()
            end
            script.yield(delayMs)
        end

        S.isStrobeRunning = false
    end)
end

local function setupFullNightStorm()
    script.run_in_callback(function()
        S.hdrStormActive = true
        local isSh = isLocalScriptHost()

        pcall(function()
            -- 1. Horario: Meia-noite (para maximizar contraste HDR)
            if CLOCK and CLOCK.SET_CLOCK_TIME then
                CLOCK.SET_CLOCK_TIME(0, 0, 0)
            end
            if isSh and S.syncWeatherNetwork and NETWORK then
                if NETWORK.NETWORK_OVERRIDE_CLOCK_TIME then NETWORK.NETWORK_OVERRIDE_CLOCK_TIME(0, 0, 0) end
                if NETWORK.NETWORK_SYNC_CLOCK_TIME_OVERRIDE then NETWORK.NETWORK_SYNC_CLOCK_TIME_OVERRIDE() end
            end

            -- 2. Clima: Tempestade de Raios
            if MISC then
                if MISC.SET_WEATHER_TYPE_NOW_PERSIST then MISC.SET_WEATHER_TYPE_NOW_PERSIST("THUNDER") end
                if MISC.SET_WEATHER_TYPE_PERSIST then MISC.SET_WEATHER_TYPE_PERSIST("THUNDER") end
                if MISC.SET_OVERRIDE_WEATHER then MISC.SET_OVERRIDE_WEATHER("THUNDER") end
            end

            -- 3. Tremor de camera local
            if CAM and CAM.SHAKE_GAMEPLAY_CAM then
                CAM.SHAKE_GAMEPLAY_CAM("LARGE_EXPLOSION_SHAKE", 1.2)
            end
        end)

        -- Tunables de evento oficial em rede
        if S.syncWeatherNetwork and isSh then
            setScriptGlobalInt(262145 + 32158, 1) -- Halloween/Thunder atmosphere
            setScriptGlobalInt(262145 + 4413, 0)
        end

        -- Aguarda adaptacao de exposicao
        script.yield(200)

        -- 4. Dispara rajada de relampagos
        triggerStrobeBurst(5, 75)

        if isSh and S.syncWeatherNetwork then
            notify.success("Lightning FX", "Tempestade Noturna HDR SINCRONIZADA com a Sessao (Script Host)!")
        else
            notify.success("Lightning FX", "Tempestade Noturna HDR ativada (Local)!")
        end
    end)
end

local function restoreNormalWeather()
    script.run_in_callback(function()
        S.hdrStormActive = false
        local isSh = isLocalScriptHost()

        pcall(function()
            if MISC and MISC.CLEAR_OVERRIDE_WEATHER then
                MISC.CLEAR_OVERRIDE_WEATHER()
            end
            if MISC and MISC.SET_WEATHER_TYPE_NOW_PERSIST then
                MISC.SET_WEATHER_TYPE_NOW_PERSIST("EXTRASUNNY")
            end
            if MISC and MISC.SET_WEATHER_TYPE_PERSIST then
                MISC.SET_WEATHER_TYPE_PERSIST("EXTRASUNNY")
            end
            if CAM and CAM.STOP_GAMEPLAY_CAM_SHAKING then
                CAM.STOP_GAMEPLAY_CAM_SHAKING(true)
            end
            if isSh and S.syncWeatherNetwork and NETWORK and NETWORK.NETWORK_CLEAR_CLOCK_TIME_OVERRIDE then
                NETWORK.NETWORK_CLEAR_CLOCK_TIME_OVERRIDE()
            end
        end)

        if isSh and S.syncWeatherNetwork then
            setScriptGlobalInt(262145 + 4413, 0)
            setScriptGlobalInt(262145 + 32158, 0)
            notify.info("Lightning FX", "Clima normal restaurado na Sessao!")
        else
            notify.info("Lightning FX", "Clima normal restaurado localmente.")
        end
    end)
end

local function setSessionWeather(weatherName, setMidnight)
    script.run_in_callback(function()
        local wName = string.upper(weatherName or "CLEAR")
        local isSh = isLocalScriptHost()

        pcall(function()
            if MISC then
                if MISC.SET_WEATHER_TYPE_NOW_PERSIST then MISC.SET_WEATHER_TYPE_NOW_PERSIST(wName) end
                if MISC.SET_WEATHER_TYPE_NOW then MISC.SET_WEATHER_TYPE_NOW(wName) end
                if MISC.SET_WEATHER_TYPE_PERSIST then MISC.SET_WEATHER_TYPE_PERSIST(wName) end
                if MISC.SET_WEATHER_TYPE_OVERTIME_PERSIST then MISC.SET_WEATHER_TYPE_OVERTIME_PERSIST(wName, 1.0) end
                if MISC.SET_OVERRIDE_WEATHER then MISC.SET_OVERRIDE_WEATHER(wName) end
            end
        end)

        -- Sincronizacao de Horario em rede se for Script Host
        if setMidnight then
            pcall(function()
                if CLOCK and CLOCK.SET_CLOCK_TIME then CLOCK.SET_CLOCK_TIME(0, 0, 0) end
                if isSh and S.syncWeatherNetwork and NETWORK then
                    if NETWORK.NETWORK_OVERRIDE_CLOCK_TIME then NETWORK.NETWORK_OVERRIDE_CLOCK_TIME(0, 0, 0) end
                    if NETWORK.NETWORK_SYNC_CLOCK_TIME_OVERRIDE then NETWORK.NETWORK_SYNC_CLOCK_TIME_OVERRIDE() end
                end
            end)
        end

        -- Injeção de Tunables Oficiais de Evento na Sessão
        if S.syncWeatherNetwork and isSh then
            if wName == "XMAS" then
                setScriptGlobalInt(262145 + 4413, 1) -- Snow tunable
                setScriptGlobalInt(262145 + 32158, 0)
            elseif wName == "HALLOWEEN" or wName == "THUNDER" then
                setScriptGlobalInt(262145 + 32158, (wName == "HALLOWEEN" and 1 or 0))
                setScriptGlobalInt(262145 + 4413, 0)
            else
                setScriptGlobalInt(262145 + 4413, 0)
                setScriptGlobalInt(262145 + 32158, 0)
            end
        end

        if isSh and S.syncWeatherNetwork then
            notify.success("Weather Sync", string.format("Clima [%s] SINCRONIZADO com a Sessao (Script Host)!", wName))
        else
            notify.info("Weather", string.format("Clima [%s] aplicado localmente.", wName))
        end
    end)
end

------------------------------------------------------------
-- APRESENTACAO DE KUNG FU & MESTRE DO CHI
------------------------------------------------------------

local function requestPtfxAsset(assetName)
    if not assetName or assetName == "" then return false end
    pcall(function()
        if STREAMING and STREAMING.REQUEST_NAMED_PTFX_ASSET then
            STREAMING.REQUEST_NAMED_PTFX_ASSET(assetName)
        end
    end)
    local timeout = 0
    while STREAMING and STREAMING.HAS_NAMED_PTFX_ASSET_LOADED and not STREAMING.HAS_NAMED_PTFX_ASSET_LOADED(assetName) and timeout < 30 do
        script.yield(10)
        timeout = timeout + 1
    end
    return true
end

local function stopAllKungFuPtfx()
    pcall(function()
        for _, fx in ipairs(S.activeKungFuPtfx) do
            if fx and GRAPHICS and GRAPHICS.DOES_PARTICLE_FX_LOOPED_EXIST and GRAPHICS.DOES_PARTICLE_FX_LOOPED_EXIST(fx) then
                if GRAPHICS.STOP_PARTICLE_FX_LOOPED then GRAPHICS.STOP_PARTICLE_FX_LOOPED(fx, false) end
                if GRAPHICS.REMOVE_PARTICLE_FX then GRAPHICS.REMOVE_PARTICLE_FX(fx, false) end
            end
        end
        S.activeKungFuPtfx = {}
    end)
end

local function attachPtfxToPedBone(ped, assetName, effectName, boneId, offX, offY, offZ, rotX, rotY, rotZ, scale)
    if not isValidEntity(ped) then return nil end
    local fxHandle = nil
    pcall(function()
        requestPtfxAsset(assetName)
        if GRAPHICS and GRAPHICS.USE_PARTICLE_FX_ASSET then
            GRAPHICS.USE_PARTICLE_FX_ASSET(assetName)
        end
        if GRAPHICS and GRAPHICS.START_NETWORKED_PARTICLE_FX_LOOPED_ON_ENTITY_BONE then
            fxHandle = GRAPHICS.START_NETWORKED_PARTICLE_FX_LOOPED_ON_ENTITY_BONE(
                effectName, ped,
                offX or 0.0, offY or 0.0, offZ or 0.0,
                rotX or 0.0, rotY or 0.0, rotZ or 0.0,
                boneId or 0, scale or 0.8,
                false, false, false, 0, 0, 0, 0
            )
        elseif GRAPHICS and GRAPHICS.START_PARTICLE_FX_LOOPED_ON_ENTITY_BONE then
            fxHandle = GRAPHICS.START_PARTICLE_FX_LOOPED_ON_ENTITY_BONE(
                effectName, ped,
                offX or 0.0, offY or 0.0, offZ or 0.0,
                rotX or 0.0, rotY or 0.0, rotZ or 0.0,
                boneId or 0, scale or 0.8,
                false, false, false
            )
        end
        if fxHandle and fxHandle ~= 0 then
            table.insert(S.activeKungFuPtfx, fxHandle)
        end
    end)
    return fxHandle
end

local function triggerPtfxAtCoord(assetName, effectName, x, y, z, scale)
    pcall(function()
        requestPtfxAsset(assetName)
        if GRAPHICS and GRAPHICS.USE_PARTICLE_FX_ASSET then
            GRAPHICS.USE_PARTICLE_FX_ASSET(assetName)
        end
        if GRAPHICS and GRAPHICS.START_NETWORKED_PARTICLE_FX_NON_LOOPED_AT_COORD then
            GRAPHICS.START_NETWORKED_PARTICLE_FX_NON_LOOPED_AT_COORD(
                effectName, x, y, z, 0.0, 0.0, 0.0, scale or 1.5, false, false, false, false
            )
        elseif GRAPHICS and GRAPHICS.START_PARTICLE_FX_NON_LOOPED_AT_COORD then
            GRAPHICS.START_PARTICLE_FX_NON_LOOPED_AT_COORD(
                effectName, x, y, z, 0.0, 0.0, 0.0, scale or 1.5, false, false, false
            )
        end
    end)
end

local function cleanupKungFuDisciples()
    pcall(function()
        for _, d in ipairs(S.activeKungFuDisciples) do
            if isValidEntity(d) then
                safeDeleteEntity(d)
            end
        end
        S.activeKungFuDisciples = {}
    end)
end

local function spawnKungFuDisciples(pCoords, heading)
    cleanupKungFuDisciples()
    local disciples = {}
    local rad = math.rad(heading)
    local fwdX = -math.sin(rad)
    local fwdY = math.cos(rad)
    local rightX = fwdY
    local rightY = -fwdX

    -- Modelos de Mestres / Monges / Lutadores Orientais
    local discipleModels = { "g_m_m_chigoon_01", "g_m_m_chigoon_02", "mp_m_freemode_01" }
    local hash = getHash(discipleModels[math.random(#discipleModels)])
    STREAMING.REQUEST_MODEL(hash)
    local timeout = 0
    while not STREAMING.HAS_MODEL_LOADED(hash) and timeout < 30 do script.yield(10); timeout = timeout + 1 end

    local offsets = {
        { fwd = -2.2, side = -2.0 },
        { fwd = -2.2, side = 2.0 },
        { fwd = -4.0, side = -3.8 },
        { fwd = -4.0, side = 3.8 }
    }

    local maxCount = S.kungFuDisciplesCount or 2
    for i = 1, math.min(maxCount, #offsets) do
        local pos = offsets[i]
        local dx = pCoords.x + fwdX * pos.fwd + rightX * pos.side
        local dy = pCoords.y + fwdY * pos.fwd + rightY * pos.side
        local dz = pCoords.z

        local ped = nil
        pcall(function()
            ped = PED.CREATE_PED(26, hash, dx, dy, dz, heading, true, false)
        end)

        if isValidEntity(ped) then
            pcall(function()
                ENTITY.SET_ENTITY_AS_MISSION_ENTITY(ped, true, true)
                safeSetInvincible(ped, true)
                if ENTITY.SET_ENTITY_PROOFS then
                    ENTITY.SET_ENTITY_PROOFS(ped, true, true, true, true, true, true, true, true)
                end
                PED.SET_PED_CAN_RAGDOLL(ped, false)
                if PED.SET_PED_CAN_RAGDOLL_FROM_PLAYER_IMPACT then
                    PED.SET_PED_CAN_RAGDOLL_FROM_PLAYER_IMPACT(ped, false)
                end
                if PED.SET_PED_CONFIG_FLAG then
                    PED.SET_PED_CONFIG_FLAG(ped, 281, true) -- no ragdoll from fire
                    PED.SET_PED_CONFIG_FLAG(ped, 430, true) -- no fire reactions
                    PED.SET_PED_CONFIG_FLAG(ped, 208, true) -- no pain reactions
                    PED.SET_PED_CONFIG_FLAG(ped, 118, true) -- no panic
                end
                if FIRE and FIRE.STOP_ENTITY_FIRE then
                    FIRE.STOP_ENTITY_FIRE(ped)
                end
                PED.SET_BLOCKING_OF_NON_TEMPORARY_EVENTS(ped, true)
                PED.SET_PED_COMBAT_ATTRIBUTES(ped, 46, true)
                PED.SET_PED_CAN_BE_TARGETTED(ped, false)
                ENTITY.SET_ENTITY_COLLISION(ped, true, true)
            end)
            table.insert(disciples, ped)
            table.insert(S.activeKungFuDisciples, ped)
        end
    end
    return disciples
end

local function applyKungFuAnimToAll(dict, anim, flag, disciples)
    pcall(function()
        local myPed = getLocalPed()
        safePlayAnim(myPed, dict, anim, flag or 1)
        if disciples then
            for _, d in ipairs(disciples) do
                if isValidEntity(d) then
                    safePlayAnim(d, dict, anim, flag or 1)
                end
            end
        end
    end)
end

local function triggerChiGroundMandala(centerCoords, radius, elemType)
    local asset = "core"
    local fxName = "ent_sht_flame"
    local scale = 1.0

    if elemType == 1 then -- Fogo
        asset = "core"
        fxName = "ent_sht_flame"
        scale = 0.8
    elseif elemType == 2 then -- Raios
        asset = "core"
        fxName = "ent_amb_sparking_wires"
        scale = 1.1
    elseif elemType == 3 then -- Místico
        asset = "scr_rcbarry2"
        fxName = "scr_clown_appears"
        scale = 0.5
    end

    local pts = 8
    for i = 0, pts - 1 do
        local angle = (i / pts) * (math.pi * 2)
        local ox = centerCoords.x + math.cos(angle) * radius
        local oy = centerCoords.y + math.sin(angle) * radius
        local oz = centerCoords.z - 0.4
        triggerPtfxAtCoord(asset, fxName, ox, oy, oz, scale)
    end
end

local function triggerOrbitalChiRing(centerCoords, radius, currentZ, ringAngle, elemType)
    local asset = "core"
    local fxName = "ent_sht_flame"
    local scale = 0.9

    if elemType == 1 then -- Fogo
        asset = "core"
        fxName = "ent_sht_flame"
        scale = 0.75
    elseif elemType == 2 then -- Raios
        asset = "core"
        fxName = "ent_amb_sparking_wires"
        scale = 1.0
    elseif elemType == 3 then -- Místico
        asset = "scr_alien"
        fxName = "scr_alien_teleport"
        scale = 0.85
    end

    local pts = 6
    for i = 0, pts - 1 do
        local angle = ringAngle + (i / pts) * (math.pi * 2)
        local ox = centerCoords.x + math.cos(angle) * radius
        local oy = centerCoords.y + math.sin(angle) * radius
        triggerPtfxAtCoord(asset, fxName, ox, oy, currentZ, scale)
    end
end

local function triggerChiVFormation(centerCoords, heading, currentZ, elemType, scale)
    local asset = (elemType == 3) and "scr_rcbarry2" or "core"
    local fxName = (elemType == 3) and "scr_clown_appears" or ((elemType == 1) and "ent_sht_flame" or "ent_amb_sparking_wires")
    scale = scale or 1.0

    local rad = math.rad(heading)
    local fwdX = -math.sin(rad)
    local fwdY = math.cos(rad)
    local rightX = fwdY
    local rightY = -fwdX

    -- Pontos em V abrindo a partir do centro para trás (formato de asas / V flamejante)
    local vOffsets = {
        { fwd = 0.0, side = 0.0 },
        { fwd = -1.2, side = -1.1 }, { fwd = -1.2, side = 1.1 },
        { fwd = -2.4, side = -2.2 }, { fwd = -2.4, side = 2.2 },
        { fwd = -3.6, side = -3.3 }, { fwd = -3.6, side = 3.3 }
    }

    for _, v in ipairs(vOffsets) do
        local vx = centerCoords.x + fwdX * v.fwd + rightX * v.side
        local vy = centerCoords.y + fwdY * v.fwd + rightY * v.side
        triggerPtfxAtCoord(asset, fxName, vx, vy, currentZ, scale)
    end
end

local function attachChiAuraToAll(disciples, elemType)
    elemType = elemType or S.kungFuElementType or 1
    local myPed = getLocalPed()
    local allPeds = { myPed }
    if disciples then
        for _, d in ipairs(disciples) do
            if isValidEntity(d) then table.insert(allPeds, d) end
        end
    end

    local asset = "core"
    local fxHand = "ent_sht_flame"
    local fxWing = "ent_sht_flame"
    local scale = 0.75

    if elemType == 1 then -- Fogo / Chamas
        asset = "core"
        fxHand = "ent_sht_flame"
        fxWing = "ent_sht_flame"
        scale = 0.8
    elseif elemType == 2 then -- Raios / Eletricidade
        asset = "core"
        fxHand = "ent_amb_sparking_wires"
        fxWing = "ent_amb_sparking_wires"
        scale = 0.95
    elseif elemType == 3 then -- Místico / Alien / Espiritual
        asset = "scr_rcbarry2"
        fxHand = "scr_clown_appears"
        fxWing = "scr_clown_death"
        scale = 0.5
    end

    for _, p in ipairs(allPeds) do
        -- Protege contra chamas e fogo
        pcall(function()
            if FIRE and FIRE.STOP_ENTITY_FIRE then FIRE.STOP_ENTITY_FIRE(p) end
            if ENTITY.SET_ENTITY_PROOFS then ENTITY.SET_ENTITY_PROOFS(p, true, true, true, true, true, true, true, true) end
        end)

        -- ASAS / FORMATO DE "V" EM CHAMAS NAS COSTAS E OMBROS (Em vez de chama vertical no topo)
        -- Haste Esquerda do V (Inclinada 45 graus para esquerda e cima)
        attachPtfxToPedBone(p, asset, fxWing, 24818, -0.28, -0.18, 0.15, -20.0, -40.0, -35.0, scale * 1.15)
        attachPtfxToPedBone(p, asset, fxWing, 64729, 0.15, -0.05, 0.1, -15.0, -45.0, -25.0, scale * 0.9)

        -- Haste Direita do V (Inclinada 45 graus para direita e cima)
        attachPtfxToPedBone(p, asset, fxWing, 24818, 0.28, -0.18, 0.15, -20.0, 40.0, 35.0, scale * 1.15)
        attachPtfxToPedBone(p, asset, fxWing, 10706, -0.15, -0.05, 0.1, -15.0, 45.0, 25.0, scale * 0.9)

        -- Mãos (SKEL_L_Hand: 18905, SKEL_R_Hand: 57005)
        attachPtfxToPedBone(p, asset, fxHand, 18905, 0.05, 0.0, 0.0, 0.0, 0.0, 0.0, scale * 0.9)
        attachPtfxToPedBone(p, asset, fxHand, 57005, 0.05, 0.0, 0.0, 0.0, 0.0, 0.0, scale * 0.9)

        -- Pés (SKEL_L_Foot: 14201, SKEL_R_Foot: 52397)
        attachPtfxToPedBone(p, asset, fxHand, 14201, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, scale * 0.8)
        attachPtfxToPedBone(p, asset, fxHand, 52397, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, scale * 0.8)
    end
end

local function stopKungFuShow()
    S.kungFuShowRunning = false
    S.kungFuLoopActive = false
    S.kungFuSessionId = S.kungFuSessionId + 1

    stopAllKungFuPtfx()
    cleanupKungFuDisciples()
    pcall(function()
        local ped = getLocalPed()
        if isValidEntity(ped) then
            ENTITY.FREEZE_ENTITY_POSITION(ped, false)
            if FIRE and FIRE.STOP_ENTITY_FIRE then FIRE.STOP_ENTITY_FIRE(ped) end
            TASK.CLEAR_PED_TASKS(ped)
            PED.SET_PED_CAN_RAGDOLL(ped, not S.disableRagdoll)
        end
    end)
end

local function triggerKungFuImpact(x, y, z, elementType)
    script.run_in_callback(function()
        -- 1. Flash branco no ponto de impacto
        pcall(function()
            if GRAPHICS and GRAPHICS.SET_FLASH then
                GRAPHICS.SET_FLASH(0, 0, 0.15, 200, 100)
            end
        end)

        -- 2. Particle de impacto baseado no elemento
        local ptfxDict, ptfxName
        if elementType == 1 then
            ptfxDict, ptfxName = "core", "ent_sht_flame"
        elseif elementType == 2 then
            ptfxDict, ptfxName = "core", "ent_amb_sparks_electrical_cracker"
        else
            ptfxDict, ptfxName = "scr_alien", "scr_alien_teleport"
        end

        requestPtfxAsset(ptfxDict)
        if GRAPHICS and GRAPHICS.USE_PARTICLE_FX_ASSET then GRAPHICS.USE_PARTICLE_FX_ASSET(ptfxDict) end
        pcall(function()
            if GRAPHICS and GRAPHICS.START_PARTICLE_FX_NON_LOOPED_AT_COORD then
                GRAPHICS.START_PARTICLE_FX_NON_LOOPED_AT_COORD(ptfxName, x, y, z, 0.0, 0.0, 0.0, 2.5, false, false, false)
            end
        end)

        -- 3. Onda de choque circular expandindo no chao (3 aneis em 180ms)
        requestPtfxAsset("scr_arena_war")
        if GRAPHICS and GRAPHICS.USE_PARTICLE_FX_ASSET then GRAPHICS.USE_PARTICLE_FX_ASSET("scr_arena_war") end
        for wave = 1, 3 do
            pcall(function()
                if GRAPHICS and GRAPHICS.START_PARTICLE_FX_NON_LOOPED_AT_COORD then
                    GRAPHICS.START_PARTICLE_FX_NON_LOOPED_AT_COORD(
                        "scr_ar_ground_pound", x, y, z - 0.3,
                        0.0, 0.0, 0.0,
                        0.4 + wave * 0.5,
                        false, false, false
                    )
                end
            end)
            script.yield(60)
        end
    end)
end

local function startKungFuShow()
    if S.kungFuShowRunning then
        notify.info("Kung Fu", "Uma apresentacao ja esta em andamento!")
        return
    end

    S.kungFuShowRunning = true
    S.kungFuLoopActive = false
    S.kungFuSessionId = S.kungFuSessionId + 1
    local currentSession = S.kungFuSessionId

    script.run_in_callback(function()
        local ped = getLocalPed()
        if not isValidEntity(ped) then S.kungFuShowRunning = false; return end

        local pCoords = ENTITY.GET_ENTITY_COORDS(ped, true)
        local heading = ENTITY.GET_ENTITY_HEADING(ped)

        notify.success("Kung Fu", "Apresentacao do Mestre de Kung Fu iniciada!")

        -- Imunidade total ao jogador local
        pcall(function()
            safeSetInvincible(ped, true)
            if ENTITY.SET_ENTITY_PROOFS then
                ENTITY.SET_ENTITY_PROOFS(ped, true, true, true, true, true, true, true, true)
            end
            PED.SET_PED_CAN_RAGDOLL(ped, false)
            if FIRE and FIRE.STOP_ENTITY_FIRE then FIRE.STOP_ENTITY_FIRE(ped) end
        end)

        -- Spawn dos discípulos sincronizados se ativado
        local disciples = {}
        if S.kungFuWithDisciples then
            disciples = spawnKungFuDisciples(pCoords, heading)
        end

        local allPeds = { ped }
        for _, d in ipairs(disciples) do table.insert(allPeds, d) end

        local function checkContinue()
            return S.kungFuShowRunning and S.kungFuSessionId == currentSession and isValidEntity(getLocalPed())
        end

        -- ============================================================
        -- FASE 1: DESPERTAR DA MANDALA SAGRADA & SAUDACAO FORMAL
        -- ============================================================
        if checkContinue() then
            -- Círculo / Mandala sagrada de 8 pontos no chão ao redor do jogador
            triggerChiGroundMandala(pCoords, 4.0, S.kungFuElementType)
            triggerChiVFormation(pCoords, heading, pCoords.z - 0.4, S.kungFuElementType, 1.2)
            triggerPtfxAtCoord("scr_rcbarry2", "scr_clown_appears", pCoords.x, pCoords.y, pCoords.z - 0.5, 2.4)
            triggerPtfxAtCoord("scr_alien", "scr_alien_teleport", pCoords.x, pCoords.y, pCoords.z - 0.5, 1.8)

            -- Saudação formal Bruce Lee
            applyKungFuAnimToAll("anim@mp_player_intcelebrationmale@bruce_lee", "bruce_lee", 0, disciples)
            script.yield(800)

            -- Cortes de palma marciais rápidos no solo
            if checkContinue() then
                applyKungFuAnimToAll("anim@mp_player_intcelebrationmale@karate_chops", "karate_chops", 0, disciples)
                script.yield(800)
            end

            -- Ativação da aura de Chi em formato de V
            if checkContinue() then
                attachChiAuraToAll(disciples, S.kungFuElementType)
                script.yield(600)
            end
        end

        -- ============================================================
        -- FASE 2: DECOLAGEM EXPLOSIVA RAPIDA & VORTICE EM V SUBINDO
        -- ============================================================
        local liftHeight = 5.5
        local ringAngle = 0.0

        if checkContinue() then
            applyKungFuAnimToAll("rcmme_amanda1", "stand_loop_amanda", 1, disciples)

            -- Explosão de decolagem no solo
            triggerPtfxAtCoord("scr_arena_war", "scr_ar_ground_pound", pCoords.x, pCoords.y, pCoords.z - 0.5, 2.5)
            triggerPtfxAtCoord("scr_rcbarry2", "scr_clown_death", pCoords.x, pCoords.y, pCoords.z - 0.5, 2.0)
            triggerChiGroundMandala(pCoords, 4.2, S.kungFuElementType)

            -- Subida rápida e potente até 5.5m no ar com fogo em V
            local liftTicks = 14
            for step = 1, liftTicks do
                if not checkContinue() then break end
                local progress = step / liftTicks
                local smoothFactor = progress * progress * (3.0 - 2.0 * progress)
                local curOffset = smoothFactor * liftHeight

                for _, p in ipairs(allPeds) do
                    if isValidEntity(p) then
                        local curC = ENTITY.GET_ENTITY_COORDS(p, true)
                        ENTITY.FREEZE_ENTITY_POSITION(p, true)
                        ENTITY.SET_ENTITY_COORDS_NO_OFFSET(p, curC.x, curC.y, (pCoords.z + curOffset), false, false, false)
                    end
                end

                ringAngle = ringAngle + 0.45
                triggerOrbitalChiRing(pCoords, 3.2, pCoords.z + curOffset, ringAngle, S.kungFuElementType)
                triggerChiVFormation(pCoords, heading, pCoords.z + curOffset, S.kungFuElementType, 1.1)
                script.yield(25)
            end
        end

        -- ============================================================
        -- FASE 3: KATA FLUIDO COM ANEL DE CHI GIRATORIO EM ORBITA (DINAMICO)
        -- ============================================================
        if checkContinue() then
            local floatTicks = 0
            while floatTicks < 22 and checkContinue() do
                script.yield(50)
                floatTicks = floatTicks + 1
                ringAngle = ringAngle + 0.4
                -- Anel girando ao redor do jogador no ar
                triggerOrbitalChiRing(pCoords, 3.5, pCoords.z + liftHeight, ringAngle, S.kungFuElementType)

                if floatTicks % 6 == 0 then
                    -- Pulsos da mandala no chão diretamente abaixo
                    triggerChiGroundMandala(pCoords, 4.0, S.kungFuElementType)
                    local curLocal = ENTITY.GET_ENTITY_COORDS(getLocalPed(), true)
                    triggerPtfxAtCoord(S.kungFuElementType == 1 and "core" or "scr_alien", S.kungFuElementType == 1 and "ent_sht_flame" or "scr_alien_teleport", curLocal.x, curLocal.y, curLocal.z - 0.2, 1.3)
                end
            end
        end

        -- ============================================================
        -- FASE 4: COMBO MARCIAL COMPLETO COM IMPACTOS 20MM SINCRONIZADOS
        -- ============================================================
        if checkContinue() then
            -- 1. Rajada de socos ferozes com impactos nos punhos
            applyKungFuAnimToAll("anim@mp_player_intcelebrationmale@shadow_boxing", "shadow_boxing", 1, disciples)

            local punchTicks = 0
            while punchTicks < 24 and checkContinue() do
                script.yield(45)
                punchTicks = punchTicks + 1
                ringAngle = ringAngle + 0.45
                triggerOrbitalChiRing(pCoords, 3.2, pCoords.z + liftHeight, ringAngle, S.kungFuElementType)

                -- Flash + onda de choque a cada sequencia de socos
                if punchTicks % 5 == 0 then
                    local fwdX = -math.sin(math.rad(heading))
                    local fwdY = math.cos(math.rad(heading))
                    local hitX = pCoords.x + fwdX * 2.5 + (math.random(-5, 5) / 10.0)
                    local hitY = pCoords.y + fwdY * 2.5 + (math.random(-5, 5) / 10.0)
                    local hitZ = pCoords.z + liftHeight + 0.3
                    triggerKungFuImpact(hitX, hitY, hitZ, S.kungFuElementType)
                end
            end

            if checkContinue() then
                -- 2. Chute acrobático giratório 360 no ar
                applyKungFuAnimToAll("anim@arena@celeb@flat@solo@no_props@", "kick_flip_a", 0, disciples)
                triggerOrbitalChiRing(pCoords, 3.8, pCoords.z + liftHeight, ringAngle + 1.2, S.kungFuElementType)
                script.yield(900)
            end

            if checkContinue() then
                -- 3. Movimento de chute acrobático estilo capoeira no ar
                applyKungFuAnimToAll("anim@arena@celeb@flat@solo@no_props@", "capoeira", 0, disciples)
                triggerOrbitalChiRing(pCoords, 3.8, pCoords.z + liftHeight, ringAngle + 2.0, S.kungFuElementType)
                script.yield(950)
            end

            if checkContinue() then
                -- 4. Golpe final cortante de karatê com explosões nos lados
                applyKungFuAnimToAll("anim@mp_player_intcelebrationmale@karate_chops", "karate_chops", 0, disciples)
                triggerOrbitalChiRing(pCoords, 3.5, pCoords.z + liftHeight, ringAngle + 2.8, S.kungFuElementType)

                pcall(function()
                    local fwdX = -math.sin(math.rad(heading))
                    local fwdY = math.cos(math.rad(heading))
                    local rX = fwdY
                    local rY = -fwdX
                    if FIRE and FIRE.ADD_EXPLOSION then
                        FIRE.ADD_EXPLOSION(pCoords.x + fwdX * 2.0 + rX * 1.5, pCoords.y + fwdY * 2.0 + rY * 1.5, pCoords.z + liftHeight, 38, 0.0, false, false, 0.0)
                        FIRE.ADD_EXPLOSION(pCoords.x + fwdX * 2.0 - rX * 1.5, pCoords.y + fwdY * 2.0 - rY * 1.5, pCoords.z + liftHeight, 38, 0.0, false, false, 0.0)
                    end
                end)
                script.yield(900)
            end
        end

        -- ============================================================
        -- FASE 5: DESCIDA SUAVE E POUSO DE GRÃO-MESTRE
        -- ============================================================
        if checkContinue() then
            applyKungFuAnimToAll("rcmme_amanda1", "stand_loop_amanda", 1, disciples)

            -- Descida suave de volta ao solo (rápida e precisa)
            local descendTicks = 22
            for step = 1, descendTicks do
                if not checkContinue() then break end
                local progress = step / descendTicks
                local smoothFactor = (1.0 - progress) * (1.0 - progress) * (3.0 - 2.0 * (1.0 - progress))
                local curOffset = smoothFactor * liftHeight

                for _, p in ipairs(allPeds) do
                    if isValidEntity(p) then
                        local curC = ENTITY.GET_ENTITY_COORDS(p, true)
                        ENTITY.SET_ENTITY_COORDS_NO_OFFSET(p, curC.x, curC.y, (pCoords.z + curOffset), false, false, false)
                    end
                end

                ringAngle = ringAngle + 0.35
                -- O anel vai se contraindo em direção ao centro conforme o jogador desce (implosão)
                local currentRadius = 1.0 + smoothFactor * 2.5
                triggerOrbitalChiRing(pCoords, currentRadius, pCoords.z + curOffset, ringAngle, S.kungFuElementType)
                script.yield(25)
            end

            -- Descongela a posição para física natural no solo
            for _, p in ipairs(allPeds) do
                if isValidEntity(p) then
                    ENTITY.FREEZE_ENTITY_POSITION(p, false)
                    if PED and PED.SET_PED_TO_RAGDOLL then PED.SET_PED_CAN_RAGDOLL(p, false) end
                end
            end

            -- Grande onda de choque e pulso da mandala ao pousar
            triggerChiGroundMandala(pCoords, 4.5, S.kungFuElementType)
            triggerPtfxAtCoord("scr_alien", "scr_alien_teleport", pCoords.x, pCoords.y, pCoords.z - 0.4, 2.2)
            triggerPtfxAtCoord("scr_rcbarry2", "scr_clown_appears", pCoords.x, pCoords.y, pCoords.z - 0.4, 2.0)
            triggerPtfxAtCoord("scr_arena_war", "scr_ar_ground_pound", pCoords.x, pCoords.y, pCoords.z - 0.4, 2.2)

            -- Reverência final de respeito
            stopAllKungFuPtfx()
            applyKungFuAnimToAll("anim@mp_player_intcelebrationmale@ninja", "ninja", 0, disciples)
            script.yield(1600)
        end

        stopKungFuShow()
        notify.success("Kung Fu", "Apresentacao concluida com honra e perfeicao!")
    end)
end

local function playIndividualKungFuMove(moveType)
    script.run_in_callback(function()
        local ped = getLocalPed()
        if not isValidEntity(ped) then return end
        stopAllKungFuPtfx()
        attachChiAuraToAll(nil, S.kungFuElementType)

        if moveType == 1 then -- Tai Chi
            safePlayAnim(ped, "rcmme_amanda1", "stand_loop_amanda", 1)
        elseif moveType == 2 then -- Shadow Boxing
            safePlayAnim(ped, "anim@mp_player_intcelebrationmale@shadow_boxing", "shadow_boxing", 1)
            script.yield(400)
            local pCoords2 = ENTITY.GET_ENTITY_COORDS(ped, true)
            local fwdX2 = -math.sin(math.rad(ENTITY.GET_ENTITY_HEADING(ped)))
            local fwdY2 = math.cos(math.rad(ENTITY.GET_ENTITY_HEADING(ped)))
            triggerKungFuImpact(pCoords2.x + fwdX2 * 2.0, pCoords2.y + fwdY2 * 2.0, pCoords2.z + 0.5, S.kungFuElementType)
        elseif moveType == 3 then -- Kick Flip 360
            safePlayAnim(ped, "anim@arena@celeb@flat@solo@no_props@", "kick_flip_a", 0)
            script.yield(350)
            local pCoords3 = ENTITY.GET_ENTITY_COORDS(ped, true)
            triggerKungFuImpact(pCoords3.x, pCoords3.y, pCoords3.z, S.kungFuElementType)
        elseif moveType == 4 then -- Bruce Lee Pose
            safePlayAnim(ped, "anim@mp_player_intcelebrationmale@bruce_lee", "bruce_lee", 0)
        elseif moveType == 5 then -- Levitação Solo (5.5m + Mandala)
            local pCoords = ENTITY.GET_ENTITY_COORDS(ped, true)
            safePlayAnim(ped, "rcmme_amanda1", "stand_loop_amanda", 1)
            triggerChiGroundMandala(pCoords, 4.0, S.kungFuElementType)
            triggerPtfxAtCoord("scr_arena_war", "scr_ar_ground_pound", pCoords.x, pCoords.y, pCoords.z - 0.5, 2.2)

            -- Subida rápida 5.5m
            for step = 1, 16 do
                local curC = ENTITY.GET_ENTITY_COORDS(ped, true)
                ENTITY.FREEZE_ENTITY_POSITION(ped, true)
                ENTITY.SET_ENTITY_COORDS_NO_OFFSET(ped, curC.x, curC.y, pCoords.z + (step / 16 * 5.5), false, false, false)
                triggerOrbitalChiRing(pCoords, 3.2, pCoords.z + (step / 16 * 5.5), step * 0.4, S.kungFuElementType)
                script.yield(25)
            end
            script.yield(1800)
            -- Descida suave
            for step = 25, 1, -1 do
                local curC = ENTITY.GET_ENTITY_COORDS(ped, true)
                ENTITY.SET_ENTITY_COORDS_NO_OFFSET(ped, curC.x, curC.y, pCoords.z + (step / 25 * 5.5), false, false, false)
                triggerOrbitalChiRing(pCoords, (step / 25 * 3.0), pCoords.z + (step / 25 * 5.5), step * 0.3, S.kungFuElementType)
                script.yield(25)
            end
            ENTITY.FREEZE_ENTITY_POSITION(ped, false)
            triggerChiGroundMandala(pCoords, 4.2, S.kungFuElementType)
            triggerPtfxAtCoord("scr_rcbarry2", "scr_clown_appears", pCoords.x, pCoords.y, pCoords.z - 0.5, 1.8)
        elseif moveType == 6 then -- Combo Aéreo Completo Solo
            local pCoords = ENTITY.GET_ENTITY_COORDS(ped, true)
            safePlayAnim(ped, "anim@arena@celeb@flat@solo@no_props@", "kick_flip_a", 0)
            script.yield(350)
            triggerKungFuImpact(pCoords.x, pCoords.y, pCoords.z, S.kungFuElementType)
            triggerPtfxAtCoord("core", "ent_sht_flame", pCoords.x, pCoords.y, pCoords.z, 2.0)
            script.yield(550)
            safePlayAnim(ped, "anim@arena@celeb@flat@solo@no_props@", "capoeira", 0)
            script.yield(300)
            triggerKungFuImpact(pCoords.x, pCoords.y, pCoords.z, S.kungFuElementType)
            triggerPtfxAtCoord("core", "ent_amb_sparking_wires", pCoords.x, pCoords.y, pCoords.z, 2.0)
            script.yield(600)
            safePlayAnim(ped, "anim@mp_player_intcelebrationmale@karate_chops", "karate_chops", 0)
            script.yield(200)
            triggerKungFuImpact(pCoords.x, pCoords.y, pCoords.z, S.kungFuElementType)
        end
    end)
end

local function renderTabKungFuMaster()
    if not imgui.begin_tab_item("Kung Fu Master") then return end
    imgui.spacing()
    imgui.text("Martial Arts Performance & Chi Master (Kung Fu Show)")
    imgui.separator()
    imgui.spacing()

    if imgui.button("START FULL KUNG FU SHOW (5 ACTS)##start_kf_btn") then
        startKungFuShow()
    end

    imgui.spacing(); imgui.separator(); imgui.spacing()
    imgui.text("Chi Energy Element:")
    if imgui.button((S.kungFuElementType == 1 and "[X] Fire / Flames" or "Fire / Flames") .. "##kf_el_1") then S.kungFuElementType = 1 end
    imgui.same_line()
    if imgui.button((S.kungFuElementType == 2 and "[X] Lightning / Electricity" or "Lightning / Electricity") .. "##kf_el_2") then S.kungFuElementType = 2 end
    imgui.same_line()
    if imgui.button((S.kungFuElementType == 3 and "[X] Mystic / Spiritual" or "Mystic / Spiritual") .. "##kf_el_3") then S.kungFuElementType = 3 end

    imgui.spacing(); imgui.separator(); imgui.spacing()
    imgui.text("Group Performance (Disciples / Dojo):")
    local cDisc, vDisc = imgui.checkbox("Enable Synchronized Disciples in Formation##kf_disc_chk", S.kungFuWithDisciples)
    if cDisc then S.kungFuWithDisciples = vDisc end

    if S.kungFuWithDisciples then
        imgui.same_line()
        imgui.text("Quantity:")
        imgui.same_line()
        if imgui.button((S.kungFuDisciplesCount == 2 and "[X] 2 Disciples" or "2 Disciples") .. "##kf_cnt_2") then S.kungFuDisciplesCount = 2 end
        imgui.same_line()
        if imgui.button((S.kungFuDisciplesCount == 4 and "[X] 4 Disciples" or "4 Disciples") .. "##kf_cnt_4") then S.kungFuDisciplesCount = 4 end
    end

    imgui.spacing(); imgui.separator(); imgui.spacing()
    imgui.text("Individual Moves & Stances:")
    if imgui.button("Tai Chi Kata (Crane Stance)##kf_m1") then playIndividualKungFuMove(1) end
    imgui.same_line()
    if imgui.button("Lightning Punches (Shadow Boxing)##kf_m2") then playIndividualKungFuMove(2) end

    if imgui.button("360 Kick Flip (Acrobatic)##kf_m3") then playIndividualKungFuMove(3) end
    imgui.same_line()
    if imgui.button("Bruce Lee Stance (Guard)##kf_m4") then playIndividualKungFuMove(4) end
    imgui.same_line()
    if imgui.button("Floating Chi Levitation##kf_m5") then playIndividualKungFuMove(5) end

    imgui.spacing()
    if imgui.button("Full Martial Combo (Kicks & Chops)##kf_m6") then playIndividualKungFuMove(6) end

    imgui.end_tab_item()
end

------------------------------------------------------------
-- JATOS (DOGFIGHT 5 CACAS 20MM) & LIMPEZA BLINDADA ANTI-CRASH
------------------------------------------------------------

local isEnemyJetsSpawning = false

local function cleanDogfightJetEntry(item)
    if not item or item.cleaned then return end
    item.cleaned = true -- Trava atomica: impede execucao concorrente ou dupla delecao

    pcall(function()
        -- 1. Remove blip do caca de forma segura e direta
        if item.blip and HUD and HUD.DOES_BLIP_EXIST and HUD.DOES_BLIP_EXIST(item.blip) then
            pcall(function()
                if HUD.SET_BLIP_DISPLAY then HUD.SET_BLIP_DISPLAY(item.blip, 0) end
                if HUD.REMOVE_BLIP then HUD.REMOVE_BLIP(item.blip) end
            end)
        end
        item.blip = nil

        -- 2. Limpa tarefas de voo da IA (CTaskPlaneMission) e remove piloto PRIMEIRO
        local pilot = item.pilot
        item.pilot = nil
        if isValidEntity(pilot) then
            pcall(function()
                if TASK and TASK.CLEAR_PED_TASKS_IMMEDIATELY then
                    TASK.CLEAR_PED_TASKS_IMMEDIATELY(pilot)
                end
                if PED and PED.SET_BLOCKING_OF_NON_TEMPORARY_EVENTS then
                    PED.SET_BLOCKING_OF_NON_TEMPORARY_EVENTS(pilot, false)
                end
                if PED and PED.SET_PED_KEEP_TASK then
                    PED.SET_PED_KEEP_TASK(pilot, false)
                end
                if TASK and TASK.CLEAR_ALL_PED_PROPS then
                    TASK.CLEAR_ALL_PED_PROPS(pilot)
                end
            end)
            safeDeleteEntity(pilot)
        end

        -- 3. Limpa o veiculo do caca e qualquer assento ocupado
        local jet = item.jet
        item.jet = nil
        if isValidEntity(jet) then
            pcall(function()
                if VEHICLE and VEHICLE.GET_PED_IN_VEHICLE_SEAT then
                    for seat = -1, 4 do
                        local occ = VEHICLE.GET_PED_IN_VEHICLE_SEAT(jet, seat, false)
                        if isValidEntity(occ) then
                            pcall(function()
                                if TASK and TASK.CLEAR_PED_TASKS_IMMEDIATELY then
                                    TASK.CLEAR_PED_TASKS_IMMEDIATELY(occ)
                                end
                                safeDeleteEntity(occ)
                            end)
                        end
                    end
                end
            end)
            safeDeleteEntity(jet)
        end
    end)
end

local function purgeActiveDogfightJetsSync()
    S.dogfightAttackRunning = false
    isEnemyJetsSpawning = false
    S.dogfightSessionId = (S.dogfightSessionId or 0) + 1

    local list = S.activeDogfightJets or {}
    S.activeDogfightJets = {}

    for _, item in ipairs(list) do
        cleanDogfightJetEntry(item)
        script.yield(20)
    end

    -- Varredura preventiva segura de cacas Lazer da esquadrilha que possam ter ficado orfaos
    if entities and entities.get_all_vehicles_as_handles then
        pcall(function()
            local allVehs = entities.get_all_vehicles_as_handles()
            if allVehs then
                local lazerHash = getHash("lazer")
                local pilotHash = getHash("s_m_y_blackops_01")
                for _, v in ipairs(allVehs) do
                    if isValidEntity(v) and ENTITY.GET_ENTITY_MODEL(v) == lazerHash then
                        local driver = VEHICLE.GET_PED_IN_VEHICLE_SEAT(v, -1, false)
                        if isValidEntity(driver) then
                            if not PED.IS_PED_A_PLAYER(driver) and (ENTITY.GET_ENTITY_MODEL(driver) == pilotHash or PED.IS_PED_INJURED(driver)) then
                                safeDeleteEntity(driver)
                                safeDeleteEntity(v)
                            end
                        else
                            if ENTITY.IS_ENTITY_A_MISSION_ENTITY(v) and VEHICLE.IS_VEHICLE_SEAT_FREE(v, -1) then
                                safeDeleteEntity(v)
                            end
                        end
                    end
                end
            end
        end)
    end
end

local function clearActiveDogfightJets()
    if S.isClearingDogfightJets then
        notify.warn("Jets", "Limpeza de cacas ja em andamento. Aguarde...")
        return
    end

    script.run_in_callback(function()
        S.isClearingDogfightJets = true
        purgeActiveDogfightJetsSync()
        S.isClearingDogfightJets = false
        notify.info("Jets", "Todos os cacas e pilotos foram removidos do mapa com seguranca.")
    end)
end

local function triggerDogfightAttack(targetPid, count)
    if isEnemyJetsSpawning then
        notify.warn("Jets", "Aguarde, cacas anteriores ainda estao sendo criados!")
        return
    end

    local myLocalPid = getLocalPid()
    local actualPid = (targetPid == nil or targetPid == -1) and myLocalPid or targetPid
    local targetPed = getPlayerPed(actualPid)
    local targetCoords = getTargetCoordsSafe(actualPid, targetPed)
    local targetName = (actualPid == myLocalPid) and "Voce" or getPlayerName(actualPid)
    local jetCount = 5

    isEnemyJetsSpawning = true

    script.run_in_callback(function()
        pcall(function()
            if not isValidEntity(targetPed) then
                targetPed = getLocalPed()
            end

            if #S.activeDogfightJets > 0 then
                purgeActiveDogfightJetsSync()
                script.yield(50)
            end

            local jetHash = getHash("lazer")
            local pilotHash = getHash("s_m_y_blackops_01")

            pcall(function()
                STREAMING.REQUEST_MODEL(jetHash)
                STREAMING.REQUEST_MODEL(pilotHash)
            end)

            local timeout = 0
            while (not STREAMING.HAS_MODEL_LOADED(jetHash) or not STREAMING.HAS_MODEL_LOADED(pilotHash)) and timeout < 80 do
                if not isEnemyJetsSpawning then return end
                script.yield(10)
                timeout = timeout + 1
            end

            if not STREAMING.HAS_MODEL_LOADED(jetHash) or not STREAMING.HAS_MODEL_LOADED(pilotHash) then
                notify.error("Jets", "Falha ao carregar modelos dos cacas.")
                isEnemyJetsSpawning = false
                return
            end

            notify.warn("Jets", string.format("Enviando esquadrao de %d cacas contra %s!", jetCount, targetName))
            S.dogfightAttackRunning = true
            local currentSession = S.dogfightSessionId

            for i = 1, jetCount do
                if not S.dogfightAttackRunning or not isEnemyJetsSpawning or S.dogfightSessionId ~= currentSession then break end

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
                                HUD.ADD_TEXT_COMPONENT_SUBSTRING_PLAYER_NAME("Enemy Jet")
                                HUD.END_TEXT_COMMAND_SET_BLIP_NAME(blip)
                            end
                        end
                    end)

                    local jetEntry = { jet = jet, pilot = pilot, blip = blip, cleaned = false }
                    table.insert(S.activeDogfightJets, jetEntry)

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

                        while S.dogfightAttackRunning and S.dogfightSessionId == currentSession and not jetEntry.cleaned and isValidEntity(jetEntry.jet) and isValidEntity(jetEntry.pilot) and not PED.IS_PED_INJURED(jetEntry.pilot) do
                            local curPed = getPlayerPed(actualPid)

                            if isValidEntity(curPed) and curPed ~= lastAssignedPed and not PED.IS_PED_INJURED(curPed) then
                                lastAssignedPed = curPed
                                pcall(function()
                                    if jetEntry.cleaned or not isValidEntity(jetEntry.pilot) or not isValidEntity(jetEntry.jet) then return end
                                    local pGroup = PED.GET_PED_RELATIONSHIP_GROUP_HASH(curPed)
                                    local eGroup = getHash("HATES_PLAYER")
                                    PED.SET_RELATIONSHIP_BETWEEN_GROUPS(5, eGroup, pGroup)
                                    PED.SET_RELATIONSHIP_BETWEEN_GROUPS(5, pGroup, eGroup)
                                    TASK.TASK_COMBAT_PED(jetEntry.pilot, curPed, 0, 16)
                                    if TASK.TASK_PLANE_MISSION then
                                        TASK.TASK_PLANE_MISSION(jetEntry.pilot, jetEntry.jet, 0, curPed, 0.0, 0.0, 0.0, 6, 110.0, 0.0, 90.0, 0, 100.0)
                                    elseif TASK.TASK_PLANE_CHASE then
                                        TASK.TASK_PLANE_CHASE(jetEntry.pilot, curPed, 0.0, 0.0, 50.0)
                                    end
                                end)
                            end

                            shootCooldown = shootCooldown + 1
                            if shootCooldown >= 3 and isValidEntity(curPed) and not jetEntry.cleaned and isValidEntity(jetEntry.jet) and isValidEntity(jetEntry.pilot) then
                                pcall(function()
                                    if jetEntry.cleaned or not isValidEntity(jetEntry.pilot) or not isValidEntity(jetEntry.jet) then return end
                                    local jCoords = ENTITY.GET_ENTITY_COORDS(jetEntry.jet, true)
                                    local pCoords = ENTITY.GET_ENTITY_COORDS(curPed, true)
                                    local dx = pCoords.x - jCoords.x
                                    local dy = pCoords.y - jCoords.y
                                    local dz = pCoords.z - jCoords.z
                                    local dist = math.sqrt(dx * dx + dy * dy + dz * dz)

                                    if dist < 480.0 and dist > 12.0 then
                                        local fwd = ENTITY.GET_ENTITY_FORWARD_VECTOR(jetEntry.jet)
                                        local toX, toY, toZ = dx / dist, dy / dist, dz / dist
                                        local dot = fwd.x * toX + fwd.y * toY + fwd.z * toZ

                                        if dot > 0.65 and not jetEntry.cleaned and isValidEntity(jetEntry.pilot) and isValidEntity(jetEntry.jet) then
                                            local leftMuzzle = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(jetEntry.jet, -1.8, 4.0, -0.2)
                                            local rightMuzzle = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(jetEntry.jet, 1.8, 4.0, -0.2)
                                            local laserHash = getHash("VEHICLE_WEAPON_PLAYER_LAZER")
                                            if laserHash == 0 then laserHash = getHash("WEAPON_EXPLOSION") end

                                            MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS(leftMuzzle.x, leftMuzzle.y, leftMuzzle.z, pCoords.x, pCoords.y, pCoords.z + 0.4, 250, true, laserHash, jetEntry.pilot, true, false, 950.0)
                                            MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS(rightMuzzle.x, rightMuzzle.y, rightMuzzle.z, pCoords.x, pCoords.y, pCoords.z + 0.4, 250, true, laserHash, jetEntry.pilot, true, false, 950.0)
                                            shootCooldown = 0
                                        end
                                    end
                                end)
                            end
                            script.yield(150)
                        end

                        cleanDogfightJetEntry(jetEntry)
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
        notify.warn("Jets", "Aguarde, cacas anteriores ainda estao sendo criados!")
        return
    end

    local players = getActivePlayersList()
    if #players == 0 then
        notify.warn("Jets", "Nenhum jogador encontrado na sessao.")
        return
    end

    isEnemyJetsSpawning = true
    notify.warn("Jets", string.format("Ataque Global! Enviando 2 cacas para cada um dos %d jogadores...", #players))

    script.run_in_callback(function()
        pcall(function()
            if #S.activeDogfightJets > 0 then
                purgeActiveDogfightJetsSync()
                script.yield(50)
            end

            local jetHash = getHash("lazer")
            local pilotHash = getHash("s_m_y_blackops_01")

            pcall(function()
                STREAMING.REQUEST_MODEL(jetHash)
                STREAMING.REQUEST_MODEL(pilotHash)
            end)

            local timeout = 0
            while (not STREAMING.HAS_MODEL_LOADED(jetHash) or not STREAMING.HAS_MODEL_LOADED(pilotHash)) and timeout < 80 do
                if not isEnemyJetsSpawning then return end
                script.yield(10)
                timeout = timeout + 1
            end

            if not STREAMING.HAS_MODEL_LOADED(jetHash) or not STREAMING.HAS_MODEL_LOADED(pilotHash) then
                notify.error("Jets", "Falha ao carregar modelos dos cacas.")
                isEnemyJetsSpawning = false
                return
            end

            S.dogfightAttackRunning = true
            local currentSession = S.dogfightSessionId

            for _, targetPid in ipairs(players) do
                if not S.dogfightAttackRunning or not isEnemyJetsSpawning or S.dogfightSessionId ~= currentSession then break end

                local targetPed = getPlayerPed(targetPid)
                local targetCoords = getTargetCoordsSafe(targetPid, targetPed)

                for i = 1, 2 do
                    if not S.dogfightAttackRunning or not isEnemyJetsSpawning or S.dogfightSessionId ~= currentSession then break end

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
                                    HUD.ADD_TEXT_COMPONENT_SUBSTRING_PLAYER_NAME("Enemy Jet")
                                    HUD.END_TEXT_COMMAND_SET_BLIP_NAME(blip)
                                end
                            end
                        end)

                        local jetEntry = { jet = jet, pilot = pilot, blip = blip, cleaned = false }
                        table.insert(S.activeDogfightJets, jetEntry)

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

                            while S.dogfightAttackRunning and S.dogfightSessionId == currentSession and not jetEntry.cleaned and isValidEntity(jetEntry.jet) and isValidEntity(jetEntry.pilot) and not PED.IS_PED_INJURED(jetEntry.pilot) do
                                local curPed = getPlayerPed(targetPid)

                                if isValidEntity(curPed) and curPed ~= lastAssignedPed and not PED.IS_PED_INJURED(curPed) then
                                    lastAssignedPed = curPed
                                    pcall(function()
                                        if jetEntry.cleaned or not isValidEntity(jetEntry.pilot) or not isValidEntity(jetEntry.jet) then return end
                                        local pGroup = PED.GET_PED_RELATIONSHIP_GROUP_HASH(curPed)
                                        local eGroup = getHash("HATES_PLAYER")
                                        PED.SET_RELATIONSHIP_BETWEEN_GROUPS(5, eGroup, pGroup)
                                        PED.SET_RELATIONSHIP_BETWEEN_GROUPS(5, pGroup, eGroup)
                                        TASK.TASK_COMBAT_PED(jetEntry.pilot, curPed, 0, 16)
                                        if TASK.TASK_PLANE_MISSION then
                                            TASK.TASK_PLANE_MISSION(jetEntry.pilot, jetEntry.jet, 0, curPed, 0.0, 0.0, 0.0, 6, 110.0, 0.0, 90.0, 0, 100.0)
                                        elseif TASK.TASK_PLANE_CHASE then
                                            TASK.TASK_PLANE_CHASE(jetEntry.pilot, curPed, 0.0, 0.0, 50.0)
                                        end
                                    end)
                                end

                                shootCooldown = shootCooldown + 1
                                if shootCooldown >= 3 and isValidEntity(curPed) and not jetEntry.cleaned and isValidEntity(jetEntry.jet) and isValidEntity(jetEntry.pilot) then
                                    pcall(function()
                                        if jetEntry.cleaned or not isValidEntity(jetEntry.pilot) or not isValidEntity(jetEntry.jet) then return end
                                        local jCoords = ENTITY.GET_ENTITY_COORDS(jetEntry.jet, true)
                                        local pCoords = ENTITY.GET_ENTITY_COORDS(curPed, true)
                                        local dx = pCoords.x - jCoords.x
                                        local dy = pCoords.y - jCoords.y
                                        local dz = pCoords.z - jCoords.z
                                        local dist = math.sqrt(dx * dx + dy * dy + dz * dz)

                                        if dist < 480.0 and dist > 12.0 then
                                            local fwd = ENTITY.GET_ENTITY_FORWARD_VECTOR(jetEntry.jet)
                                            local toX, toY, toZ = dx / dist, dy / dist, dz / dist
                                            local dot = fwd.x * toX + fwd.y * toY + fwd.z * toZ

                                            if dot > 0.65 and not jetEntry.cleaned and isValidEntity(jetEntry.pilot) and isValidEntity(jetEntry.jet) then
                                                local leftMuzzle = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(jetEntry.jet, -1.8, 4.0, -0.2)
                                                local rightMuzzle = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(jetEntry.jet, 1.8, 4.0, -0.2)
                                                local laserHash = getHash("VEHICLE_WEAPON_PLAYER_LAZER")
                                                if laserHash == 0 then laserHash = getHash("WEAPON_EXPLOSION") end

                                                MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS(leftMuzzle.x, leftMuzzle.y, leftMuzzle.z, pCoords.x, pCoords.y, pCoords.z + 0.4, 250, true, laserHash, jetEntry.pilot, true, false, 950.0)
                                                MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS(rightMuzzle.x, rightMuzzle.y, rightMuzzle.z, pCoords.x, pCoords.y, pCoords.z + 0.4, 250, true, laserHash, jetEntry.pilot, true, false, 950.0)
                                                shootCooldown = 0
                                            end
                                        end
                                    end)
                                end
                                script.yield(150)
                            end

                            cleanDogfightJetEntry(jetEntry)
                        end)
                    end
                    script.yield(40)
                end
            end

            STREAMING.SET_MODEL_AS_NO_LONGER_NEEDED(jetHash)
            STREAMING.SET_MODEL_AS_NO_LONGER_NEEDED(pilotHash)
            isEnemyJetsSpawning = false
            notify.success("Jets", "Esquadrao global da sessao enviado com sucesso!")
        end)
    end)
end
------------------------------------------------------------
-- EAR RAPE & AUDIO / VISUAL TROLL
------------------------------------------------------------

local function stopTrollAudioHarassment()
    S.isTrollAudioActive = false
    S.trollAudioLoop = false
    pcall(function()
        if GRAPHICS and GRAPHICS.ANIMPOSTFX_STOP then GRAPHICS.ANIMPOSTFX_STOP("DrugsMichaelAliensFight") end
        if GRAPHICS and GRAPHICS.ANIMPOSTFX_STOP_ALL then GRAPHICS.ANIMPOSTFX_STOP_ALL() end
        if CAM and CAM.STOP_GAMEPLAY_CAM_SHAKING then CAM.STOP_GAMEPLAY_CAM_SHAKING(true) end
    end)
    notify.info("Ear Rape", "Ear Rape and Earthquake disabled.")
end

local function runSingleEarRapeStep(targetPid)
    local myLocalPid = getLocalPid()
    local actualPid = (targetPid == -1 or targetPid == myLocalPid) and myLocalPid or targetPid
    local isLocal = (actualPid == myLocalPid)
    local targetPed = getPlayerPed(actualPid)
    local coords = getTargetCoordsSafe(actualPid, targetPed)
    local shooterPed = (isValidEntity(targetPed) and targetPed or 0)
    S.earRapeStepIndex = S.earRapeStepIndex + 1

    -- 1. LOCAL & UI SOUNDS (FRONTEND + 3D)
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

    -- 2. DIVERSE NETWORKED SOUNDS (1 SAFE BULLET IN AIR PER TICK)
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

    -- 3. VISUAL & SOUND NETWORKED EFFECTS ON TARGET SCREEN
    pcall(function()
        if FIRE and FIRE.ADD_EXPLOSION then
            local expType = 70
            local modStep = S.earRapeStepIndex % 4
            if modStep == 0 then
                expType = 59 -- Orbital Cannon Beam
            elseif modStep == 1 then
                expType = 67 -- EMP Blast
            elseif modStep == 2 then
                expType = 13 -- High Pressure Water Geyser
            elseif modStep == 3 then
                expType = 70 -- Camera Tremor & Invisible Sound Impact
            end

            FIRE.ADD_EXPLOSION(coords.x, coords.y, coords.z - 0.5, expType, 0.0, true, false, 4.5, false)
        end

        -- 4. LIGHTNING EVERY 4 TICKS
        if S.trollLightning and (S.earRapeStepIndex % 4 == 0) and MISC and MISC.FORCE_LIGHTNING_FLASH_AT_COORDS then
            MISC.FORCE_LIGHTNING_FLASH_AT_COORDS(coords.x, coords.y, coords.z, 4.5)
        end

        -- 5. LOCAL SHAKE & FLASHBANG
        if isLocal and not S.muteEarRapeLocal then
            if CAM and CAM.SHAKE_GAMEPLAY_CAM then CAM.SHAKE_GAMEPLAY_CAM("LARGE_EXPLOSION_SHAKE", 4.5) end
            if S.trollFlashbang and GRAPHICS and GRAPHICS.ANIMPOSTFX_PLAY then GRAPHICS.ANIMPOSTFX_PLAY("DrugsMichaelAliensFight", 0, true) end
        end
    end)
end

local function triggerEarRapeTremor(targetPid, burstSecs)
    local isAll = (targetPid == -2)
    local actualPid = (targetPid == -1 or targetPid == getLocalPid()) and getLocalPid() or targetPid
    local pName = isAll and "ALL Players in Session" or ((actualPid == getLocalPid()) and "You" or getPlayerName(actualPid))

    if burstSecs and burstSecs > 0 then
        notify.warn("Ear Rape", string.format("Triggering Stable Ear Rape (%ds) on %s!", burstSecs, pName))
    else
        notify.warn("Ear Rape", "Stable Continuous Ear Rape ENABLED on " .. pName .. "!")
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
            notify.info("Ear Rape", "Ear Rape burst finished on " .. pName .. ".")
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
-- MILITARY AIRDROP
------------------------------------------------------------

local function getGroundZSafe(x, y, z)
    local groundZ = z
    pcall(function()
        if MISC and MISC.GET_GROUND_Z_FOR_3D_COORD then
            local ok, val = MISC.GET_GROUND_Z_FOR_3D_COORD(x, y, z + 50.0, false, false)
            if ok and val and type(val) == "number" and val ~= 0 then
                groundZ = val
            end
        end
    end)
    return groundZ
end

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
        if not silent then notify.info("Airdrop", "Airdrop cancelled and removed.") end
    end
end

local function triggerAirdropDrop(dropType, targetPid, locMode)
    cancelActiveAirdrop(true)
    local mySessionId = S.airdropSessionId

    local isLocalTarget = (locMode == 1 or targetPid == -1 or targetPid == getLocalPid())
    local pName = isLocalTarget and "You" or getPlayerName(targetPid)
    local dropX, dropY, dropZ = 0, 0, 0

    if isLocalTarget then
        local pCoords = ENTITY.GET_ENTITY_COORDS(getLocalPed(), true)
        local forward = getCameraDirection()
        dropX = pCoords.x + forward.x * 15.0
        dropY = pCoords.y + forward.y * 15.0
        dropZ = getGroundZSafe(dropX, dropY, pCoords.z)
    else
        local targetPed = getPlayerPed(targetPid)
        if isValidEntity(targetPed) then
            local tCoords = ENTITY.GET_ENTITY_COORDS(targetPed, true)
            dropX = tCoords.x
            dropY = tCoords.y
            dropZ = getGroundZSafe(dropX, dropY, tCoords.z)
        else
            notify.error("Airdrop", "Target player not found.")
            return
        end
    end

    local chosenType = tonumber(dropType) or S.airdropDropType or 1
    local chosenVehModel = S.airdropVehicleModel or "oppressor2"
    local chosenVehName = S.airdropVehicleName or "Oppressor Mk II"
    notify.info("Airdrop", "Flare deployed! Airdrop en route to " .. pName .. "...")

    script.run_in_callback(function()
        if S.airdropSessionId ~= mySessionId then return end

        -- Tactical beep countdown
        local beepDelays = { 320, 260, 200, 150, 110, 80 }
        for _, delay in ipairs(beepDelays) do
            if S.airdropSessionId ~= mySessionId then return end
            pcall(function()
                if AUDIO and AUDIO.PLAY_SOUND_FRONTEND then
                    AUDIO.PLAY_SOUND_FRONTEND(-1, "Beep_Red", "DLC_HEIST_HACKING_SNAKE_SOUNDS", true)
                end
            end)
            script.yield(delay)
        end

        local crateHash = getHash("prop_box_wood05a")
        if not requestAndLoadModel(crateHash, 60) then
            crateHash = getHash("prop_box_ammo04a")
            if not requestAndLoadModel(crateHash, 60) then
                crateHash = getHash("prop_crate_01a")
                requestAndLoadModel(crateHash, 60)
            end
        end
        if S.airdropSessionId ~= mySessionId then return end

        local startZ = dropZ + 55.0
        local crate = safeCreateStuntProp(crateHash, dropX, dropY, startZ, false)
        if not isValidEntity(crate) then
            pcall(function()
                if OBJECT and OBJECT.CREATE_OBJECT_NO_OFFSET then
                    crate = OBJECT.CREATE_OBJECT_NO_OFFSET(crateHash, dropX, dropY, startZ, true, false, false)
                elseif OBJECT and OBJECT.CREATE_OBJECT then
                    crate = OBJECT.CREATE_OBJECT(crateHash, dropX, dropY, startZ, true, false, false)
                end
            end)
        end
        if not isValidEntity(crate) then
            pcall(function()
                if entities and entities.create_object then
                    crate = entities.create_object(crateHash, { x = dropX, y = dropY, z = startZ })
                end
            end)
        end

        if not isValidEntity(crate) then
            notify.error("Airdrop", "Failed to create crate entity.")
            return
        end

        pcall(function()
            ENTITY.SET_ENTITY_AS_MISSION_ENTITY(crate, true, true)
            safeSetInvincible(crate, true)
            ENTITY.SET_ENTITY_COLLISION(crate, true, true)
            if ENTITY.FREEZE_ENTITY_POSITION then ENTITY.FREEZE_ENTITY_POSITION(crate, false) end
        end)

        S.ActiveAirdrop = { crate = crate, ptfx = nil }

        -- Smooth rapid descent
        local curZ = startZ
        local fallSpeed = 38.0
        while isValidEntity(crate) and curZ > (dropZ + 0.3) do
            if S.airdropSessionId ~= mySessionId then
                safeDeleteEntity(crate)
                S.ActiveAirdrop = nil
                return
            end
            curZ = curZ - (fallSpeed * 0.035)
            pcall(function()
                ENTITY.SET_ENTITY_COORDS(crate, dropX, dropY, curZ, false, false, false, true)
                ENTITY.SET_ENTITY_VELOCITY(crate, 0.0, 0.0, -fallSpeed)
            end)
            script.yield(30)
        end

        if not isValidEntity(crate) or S.airdropSessionId ~= mySessionId then return end
        pcall(function()
            ENTITY.PLACE_ENTITY_ON_GROUND_PROPERLY(crate)
            safeSetInvincible(crate, false)
            if AUDIO and AUDIO.PLAY_SOUND_FRONTEND then
                AUDIO.PLAY_SOUND_FRONTEND(-1, "Airhorn", "DLC_TG_Running_Back_Sounds", true)
            end
        end)

        -- Red smoke / flare on crate
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

        notify.success("Airdrop", "Airdrop landed! Follow the red smoke to claim.")

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
                            local openerName = (pid == getLocalPid()) and "You" or getPlayerName(pid)

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
                                    for _, wName in ipairs({ "WEAPON_MINIGUN", "WEAPON_RAILGUN", "WEAPON_HOMINGLAUNCHER", "WEAPON_RPG", "WEAPON_SPECIALCARBINE_MK2", "WEAPON_HEAVYSNIPER_MK2" }) do
                                        WEAPON.GIVE_WEAPON_TO_PED(pPed, getHash(wName), 9999, false, true)
                                    end
                                    if AUDIO and AUDIO.PLAY_SOUND_FRONTEND then
                                        AUDIO.PLAY_SOUND_FRONTEND(-1, "PICK_UP_WEAPON", "HUD_FRONTEND_DEFAULT_SOUNDSET", true)
                                    end
                                end)
                                notify.success("Airdrop", openerName .. " claimed the Tactical Supply!")
                            elseif chosenType == 2 then
                                local vHash = getHash(chosenVehModel)
                                if requestAndLoadModel(vHash, 100) then
                                    local pHeading = ENTITY.GET_ENTITY_HEADING(pPed)
                                    local veh = 0
                                    pcall(function()
                                        if VEHICLE and VEHICLE.CREATE_VEHICLE then
                                            veh = VEHICLE.CREATE_VEHICLE(vHash, cPos.x, cPos.y, cPos.z + 0.3, pHeading, true, false, false)
                                        end
                                    end)
                                    if not isValidEntity(veh) then
                                        pcall(function()
                                            if entities and entities.create_vehicle then
                                                veh = entities.create_vehicle(vHash, { x = cPos.x, y = cPos.y, z = cPos.z + 0.3 }, pHeading)
                                            end
                                        end)
                                    end
                                    if isValidEntity(veh) then
                                        ENTITY.SET_ENTITY_AS_MISSION_ENTITY(veh, true, true)
                                        safeSetInvincible(veh, true)
                                        pcall(function()
                                            VEHICLE.SET_VEHICLE_ON_GROUND_PROPERLY(veh)
                                            VEHICLE.SET_VEHICLE_ENGINE_ON(veh, true, true, false)
                                        end)

                                        notify.success("Airdrop", chosenVehName .. " delivered successfully at airdrop location!")
                                    end
                                    STREAMING.SET_MODEL_AS_NO_LONGER_NEEDED(vHash)
                                end
                            elseif chosenType == 3 then
                                pcall(function() FIRE.ADD_EXPLOSION(cPos.x, cPos.y, cPos.z, 29, 25.0, true, false, 2.5, false) end)
                                notify.warn("Airdrop", "Airdrop trap detonated!")
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
-- IMGUI TARGET SELECTOR (SESSION PLAYERS)
------------------------------------------------------------

local function renderPlayerTargetSelector(currentSelectedPid, onSelectCallback, idTag, allowAll)
    local localPid = getLocalPid()
    local isAll = (currentSelectedPid == -2)
    local isSelf = (currentSelectedPid == -1 or currentSelectedPid == localPid)
    local curTargetName = isAll and "ALL PLAYERS (Entire Session)" or (getPlayerName(currentSelectedPid) .. " [PID: " .. tostring(currentSelectedPid) .. "]")
    if not isAll and isSelf then curTargetName = "YOU (Local Player) [PID: " .. tostring(localPid) .. "]" end

    imgui.text("Target: " .. curTargetName)
    if allowAll then
        if imgui.button((isAll and "[X] ALL PLAYERS (Broadcast)" or "ALL PLAYERS (Broadcast)") .. "##all_" .. idTag) then
            onSelectCallback(-2)
        end
        imgui.same_line()
    end

    local players = getActivePlayersList()
    if #players == 0 then
        if imgui.button((isSelf and "[X] Local Player (You)" or "Local Player (You)") .. "##self_" .. idTag) then
            onSelectCallback(-1)
        end
    else
        imgui.text("Session Players:")
        local sHostPid = -1
        local scHostPid = -1
        pcall(function()
            if NETWORK then
                if NETWORK.NETWORK_GET_HOST_PLAYER_INDEX then sHostPid = NETWORK.NETWORK_GET_HOST_PLAYER_INDEX() end
                if NETWORK.NETWORK_GET_HOST_OF_SCRIPT then scHostPid = NETWORK.NETWORK_GET_HOST_OF_SCRIPT("freemode") end
            end
        end)

        for i, pid in ipairs(players) do
            if (i - 1) % 2 ~= 0 then imgui.same_line() end
            local isSel = (currentSelectedPid == pid)
            local pName = getPlayerName(pid)
            local isLocal = (pid == localPid)
            local hostTag = ""
            if pid == sHostPid and pid == scHostPid then
                hostTag = " [HOST|SH]"
            elseif pid == sHostPid then
                hostTag = " [HOST]"
            elseif pid == scHostPid then
                hostTag = " [SH]"
            end
            local label = string.format("%s[%02d] %s%s%s##p_%s_%d", isSel and "[X] " or "", pid, pName, isLocal and " (You)" or "", hostTag, idTag, pid)
            if imgui.button(label) then
                onSelectCallback(pid)
            end
        end
    end
end

------------------------------------------------------------
-- MICRO-DRONE TATICO OVERWATCH GUARDIÃO
------------------------------------------------------------

local function loadDroneAudioBank()
    pcall(function()
        if AUDIO and AUDIO.REQUEST_SCRIPT_AUDIO_BANK then
            AUDIO.REQUEST_SCRIPT_AUDIO_BANK("DLC_BATTLE_DRONE_SOUNDS", false, -1)
        end
        if AUDIO and AUDIO.REQUEST_AMBIENT_AUDIO_BANK then
            AUDIO.REQUEST_AMBIENT_AUDIO_BANK("DLC_BATTLE_DRONE_SOUNDS", false, -1)
        end
    end)
end

local function stopOverwatchFlightSound()
    pcall(function()
        if S.overwatchSoundId and S.overwatchSoundId ~= -1 and AUDIO then
            if AUDIO.STOP_SOUND then AUDIO.STOP_SOUND(S.overwatchSoundId) end
            if AUDIO.RELEASE_SOUND_ID then AUDIO.RELEASE_SOUND_ID(S.overwatchSoundId) end
            S.overwatchSoundId = -1
        end
    end)
end

local function startOverwatchFlightSound(drone)
    if not isValidEntity(drone) then return end
    pcall(function()
        stopOverwatchFlightSound()
        loadDroneAudioBank()
        if AUDIO and AUDIO.PLAY_SOUND_FROM_ENTITY then
            local sId = -1
            if AUDIO.GET_SOUND_ID then
                sId = AUDIO.GET_SOUND_ID()
            end
            AUDIO.PLAY_SOUND_FROM_ENTITY(sId, "Flight_Loop", drone, "DLC_BATTLE_DRONE_SOUNDS", false, 0)
            S.overwatchSoundId = sId
        end
    end)
end

local function deleteOverwatchDrone()
    script.run_in_callback(function()
        stopOverwatchFlightSound()
        S.overwatchIsDiving = false
        local drone = S.overwatchDroneObj
        S.overwatchDroneObj = nil
        S.overwatchTargetPed = nil
        S.overwatchLockStartTime = 0
        if drone and isValidEntity(drone) then
            safeDeleteEntity(drone)
        end
    end)
end

local function spawnOverwatchDrone()
    if S.overwatchDroneObj and isValidEntity(S.overwatchDroneObj) then
        return S.overwatchDroneObj
    end

    local myPed = getLocalPed()
    if not isValidEntity(myPed) then return nil end

    local pCoords = ENTITY.GET_ENTITY_COORDS(myPed, true)
    local droneModel = S.overwatchDroneModel or "m24_2_prop_m42_drone_01a"
    local chosenHash = getHash(droneModel)

    if not requestAndLoadModel(chosenHash, 300) then
        chosenHash = getHash("ba_prop_battle_drone_quad")
        if not requestAndLoadModel(chosenHash, 200) then
            chosenHash = getHash("ch_prop_casino_drone_01a")
            if not requestAndLoadModel(chosenHash, 150) then
                chosenHash = getHash("prop_drone_01")
                requestAndLoadModel(chosenHash, 150)
            end
        end
    end

    local hOff = S.overwatchHeightOffset or 2.2
    local sOff = S.overwatchSideOffset or 0.0
    -- Criação estática (dynamic = false) para impedir qualquer queda pela física do motor
    local drone = safeCreateStuntProp(chosenHash, pCoords.x + sOff, pCoords.y - 0.1, pCoords.z + hOff, false)

    if isValidEntity(drone) then
        pcall(function()
            getControlOfEntity(drone)
            safeSetInvincible(drone, true)
            ENTITY.SET_ENTITY_COLLISION(drone, false, false)
            if ENTITY.SET_ENTITY_NO_COLLISION_ENTITY then
                ENTITY.SET_ENTITY_NO_COLLISION_ENTITY(drone, myPed, false)
            end
            ENTITY.FREEZE_ENTITY_POSITION(drone, true)
            if ENTITY.SET_ENTITY_HAS_GRAVITY then
                ENTITY.SET_ENTITY_HAS_GRAVITY(drone, false)
            end
            if ENTITY.SET_ENTITY_DYNAMIC then
                ENTITY.SET_ENTITY_DYNAMIC(drone, false)
            end
            ENTITY.SET_ENTITY_VELOCITY(drone, 0.0, 0.0, 0.0)
            ENTITY.SET_ENTITY_ANGULAR_VELOCITY(drone, 0.0, 0.0, 0.0)
            ENTITY.SET_ENTITY_VISIBLE(drone, true, false)
            if ENTITY.SET_ENTITY_LOCALLY_VISIBLE then
                ENTITY.SET_ENTITY_LOCALLY_VISIBLE(drone)
            end
        end)
        S.overwatchDroneObj = drone
        startOverwatchFlightSound(drone)
        notify.success("Overwatch", "Drone Tatico M42 ativo e escoltando voce!")
        return drone
    else
        notify.warn("Overwatch", "Nao foi possivel carregar o modelo do drone.")
    end
    return nil
end

local function isPedOfferingThreat(candidate, myPed)
    if not isValidEntity(candidate) or not isValidEntity(myPed) then return false end
    if candidate == myPed or PED.IS_PED_INJURED(candidate) then return false end

    local myCoords = ENTITY.GET_ENTITY_COORDS(myPed, true)
    local cCoords = ENTITY.GET_ENTITY_COORDS(candidate, true)
    local toX = myCoords.x - cCoords.x
    local toY = myCoords.y - cCoords.y
    local toZ = myCoords.z - cCoords.z
    local dist3D = math.sqrt(toX * toX + toY * toY + toZ * toZ)
    if dist3D < 0.05 then return false end

    -- 1. Identificar se é outro jogador na sessão
    local isPlayer = false
    local playerPid = -1
    pcall(function()
        if NETWORK and NETWORK.NETWORK_GET_PLAYER_INDEX_FROM_PED then
            playerPid = NETWORK.NETWORK_GET_PLAYER_INDEX_FROM_PED(candidate)
            if playerPid and playerPid ~= -1 and playerPid ~= getLocalPid() then
                isPlayer = true
            end
        end
    end)
    if not isPlayer and getActivePlayersList then
        pcall(function()
            for _, pid in ipairs(getActivePlayersList()) do
                if pid ~= getLocalPid() and getPlayerPed(pid) == candidate then
                    isPlayer = true
                    playerPid = pid
                    break
                end
            end
        end)
    end

    -- 2. Cálculo do ângulo/cone em que o ped/player está voltado (Facing Cone)
    local isFacingMe = false
    local isLookingDirectlyAtMe = false
    pcall(function()
        local dot = 0.0
        if ENTITY and ENTITY.GET_ENTITY_FORWARD_VECTOR then
            local fwd = ENTITY.GET_ENTITY_FORWARD_VECTOR(candidate)
            dot = (fwd.x * (toX / dist3D) + fwd.y * (toY / dist3D) + fwd.z * (toZ / dist3D))
        else
            local hRad = math.rad(ENTITY.GET_ENTITY_HEADING(candidate))
            local fwdX = -math.sin(hRad)
            local fwdY =  math.cos(hRad)
            local dist2D = math.sqrt(toX * toX + toY * toY)
            if dist2D > 0.05 then
                dot = (fwdX * (toX / dist2D) + fwdY * (toY / dist2D))
            end
        end

        if dot > 0.45 then -- Dentro de ~63 graus da nossa posição
            isFacingMe = true
        end
        if dot > 0.72 then -- Olhando quase diretamente para nós (~44 graus)
            isLookingDirectlyAtMe = true
        end
    end)

    -- 3. Verificação de Armamento
    local isArmed = false
    pcall(function()
        if WEAPON and WEAPON.IS_PED_ARMED then
            isArmed = WEAPON.IS_PED_ARMED(candidate, 7) or WEAPON.IS_PED_ARMED(candidate, 4)
        end
        if not isArmed and WEAPON and WEAPON.GET_SELECTED_PED_WEAPON then
            local w = WEAPON.GET_SELECTED_PED_WEAPON(candidate)
            if w ~= 0 and w ~= getHash("WEAPON_UNARMED") then
                isArmed = true
            end
        end
    end)

    -- 4. Verificação de Mira / Disparo em Rede
    local isAiming = false
    local isShooting = false
    pcall(function()
        -- Config flag 78 = CPED_CONFIG_FLAG_IsAiming (sincronizado em rede no GTA Online!)
        if PED and PED.GET_PED_CONFIG_FLAG then
            if PED.GET_PED_CONFIG_FLAG(candidate, 78, true) then
                isAiming = true
            end
            if PED.GET_PED_CONFIG_FLAG(candidate, 186, true) then
                isShooting = true
            end
            if PED.GET_PED_CONFIG_FLAG(candidate, 423, true) then
                isAiming = true
            end
        end
        if PED and PED.IS_PED_SHOOTING and PED.IS_PED_SHOOTING(candidate) then
            isShooting = true
        end
        if PED and PED.IS_PED_DOING_DRIVEBY and PED.IS_PED_DOING_DRIVEBY(candidate) then
            isAiming = true
        end
        if PLAYER and isPlayer and playerPid ~= -1 then
            if PLAYER.IS_PLAYER_FREE_AIMING and PLAYER.IS_PLAYER_FREE_AIMING(playerPid) then
                isAiming = true
            end
            if PLAYER.IS_PLAYER_TARGETTING_ANYTHING and PLAYER.IS_PLAYER_TARGETTING_ANYTHING(playerPid) then
                isAiming = true
            end
            if PLAYER.IS_PLAYER_FREE_AIMING_AT_ENTITY and PLAYER.IS_PLAYER_FREE_AIMING_AT_ENTITY(playerPid, myPed) then
                isAiming = true
            end
        end
    end)

    -- 5. Se o alvo for um Jogador:
    if isPlayer then
        -- A) Mirando voltado para a nossa direção = AMEAÇA IMEDIATA
        if isAiming and isFacingMe then
            return true
        end
        -- B) Atirando voltado para nós = AMEAÇA MÁXIMA
        if isShooting and isFacingMe then
            return true
        end
        -- C) Mirando a menos de 35m mesmo com desvio de interpolação
        if isAiming and dist3D <= 35.0 then
            return true
        end
        -- D) Olhando diretamente para nós com arma em punho a menos de 50m
        if isArmed and isLookingDirectlyAtMe and dist3D <= 50.0 then
            return true
        end
        -- E) Com arma sacada muito perto (menos de 15m) voltado para nós
        if isArmed and isFacingMe and dist3D <= 15.0 then
            return true
        end
        -- F) Causou dano recente
        local damaged = false
        pcall(function()
            if ENTITY and ENTITY.HAS_ENTITY_BEEN_DAMAGED_BY_ENTITY then
                damaged = ENTITY.HAS_ENTITY_BEEN_DAMAGED_BY_ENTITY(myPed, candidate, true)
            end
        end)
        if damaged then return true end
    end

    -- 6. Se o alvo for NPC / Ped do mundo:
    local isNpcThreat = false
    pcall(function()
        if PED and PED.IS_PED_IN_COMBAT and PED.IS_PED_IN_COMBAT(candidate, myPed) then
            isNpcThreat = true
        elseif PED and PED.GET_PED_TARGET_FROM_COMBAT_PED and PED.GET_PED_TARGET_FROM_COMBAT_PED(candidate) == myPed then
            isNpcThreat = true
        elseif isShooting and isFacingMe then
            isNpcThreat = true
        elseif isAiming and isFacingMe then
            isNpcThreat = true
        elseif isArmed and isFacingMe and dist3D <= 20.0 then
            isNpcThreat = true
        elseif ENTITY and ENTITY.HAS_ENTITY_BEEN_DAMAGED_BY_ENTITY and ENTITY.HAS_ENTITY_BEEN_DAMAGED_BY_ENTITY(myPed, candidate, true) then
            isNpcThreat = true
        end
    end)

    return isNpcThreat
end

local function triggerOverwatchMissileStrike(targetPed)
    if not isValidEntity(targetPed) then return end
    local myPed = getLocalPed()
    if not isValidEntity(myPed) then return end

    local tCoords = ENTITY.GET_ENTITY_COORDS(targetPed, true)

    pcall(function()
        if AUDIO and AUDIO.PLAY_SOUND_FRONTEND then
            AUDIO.PLAY_SOUND_FRONTEND(-1, "Airhorn", "DLC_TG_Running_Back_Sounds", true)
            AUDIO.PLAY_SOUND_FRONTEND(-1, "Bomb_Disarmed", "GTAO_Speed_Convoy_Soundset", true)
            AUDIO.PLAY_SOUND_FRONTEND(-1, "ScreenFlash", "WastedSounds", true)
        end
    end)

    local skyX = tCoords.x + (math.random(-10, 10) * 0.1)
    local skyY = tCoords.y + (math.random(-10, 10) * 0.1)
    local skyZ = tCoords.z + 180.0

    local rocketHash = getHash("VEHICLE_WEAPON_SPACE_ROCKET")
    if rocketHash == 0 then rocketHash = getHash("WEAPON_EXPLOSION") end

    -- 1. Projétil orbital pesado com dano fulminante (10.000 de dano)
    local shooterPed = (S.overwatchAnonymousKills ~= false) and 0 or myPed
    pcall(function()
        MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS(
            skyX, skyY, skyZ,
            tCoords.x, tCoords.y, tCoords.z,
            10000,
            true,
            rocketHash,
            shooterPed,
            true,
            false,
            950.0
        )
    end)

    -- 2. Explosão Orbital Devastadora (Tag 29 = Orbital Cannon) no ponto exato
    pcall(function()
        if FIRE and FIRE.ADD_EXPLOSION then
            FIRE.ADD_EXPLOSION(tCoords.x, tCoords.y, tCoords.z, 29, 10.0, true, false, 1.5)
            FIRE.ADD_EXPLOSION(tCoords.x, tCoords.y, tCoords.z, 2, 5.0, true, false, 1.0)
        end
    end)

    -- 3. Destruição do veículo inimigo caso o alvo esteja dentro de um
    pcall(function()
        if PED and PED.IS_PED_IN_ANY_VEHICLE and PED.IS_PED_IN_ANY_VEHICLE(targetPed, false) then
            local tVeh = PED.GET_VEHICLE_PED_IS_IN(targetPed, false)
            if isValidEntity(tVeh) then
                getControlOfEntity(tVeh)
                if VEHICLE and VEHICLE.EXPLODE_VEHICLE then
                    VEHICLE.EXPLODE_VEHICLE(tVeh, true, false)
                end
                ENTITY.SET_ENTITY_HEALTH(tVeh, 0)
            end
        end
    end)

    -- 4. Dano letal garantido no ped (eliminação 100% imediata)
    pcall(function()
        if isValidEntity(targetPed) and not PED.IS_PED_INJURED(targetPed) then
            getControlOfEntity(targetPed)
            if PED and PED.APPLY_DAMAGE_TO_PED then
                PED.APPLY_DAMAGE_TO_PED(targetPed, 10000, false)
            end
            ENTITY.SET_ENTITY_HEALTH(targetPed, 0)
        end
    end)
end

local function triggerOverwatchMachineGunBurst(targetPed, droneCoords)
    if not isValidEntity(targetPed) then return end
    local myPed = getLocalPed()
    if not isValidEntity(myPed) then return end

    -- Munição pura de metralhadora balística real (SEM NENHUMA EXPLOSÃO)
    local bulletHash = getHash("WEAPON_COMBATMG_MK2")
    if bulletHash == 0 then bulletHash = 2634544996 end

    pcall(function()
        if WEAPON then
            if WEAPON.REQUEST_WEAPON_ASSET then
                WEAPON.REQUEST_WEAPON_ASSET(bulletHash, 31, 0)
            end
            if WEAPON.HAS_PED_GOT_WEAPON and not WEAPON.HAS_PED_GOT_WEAPON(myPed, bulletHash, false) then
                WEAPON.GIVE_WEAPON_TO_PED(myPed, bulletHash, 9999, false, false)
            end
        end
    end)

    local bulletDmg = 45

    local curDronePos = droneCoords
    if S.overwatchDroneObj and isValidEntity(S.overwatchDroneObj) then
        curDronePos = ENTITY.GET_ENTITY_COORDS(S.overwatchDroneObj, true)
    end

    local tCoords = ENTITY.GET_ENTITY_COORDS(targetPed, true)

    local dirX = tCoords.x - curDronePos.x
    local dirY = tCoords.y - curDronePos.y
    local dirZ = (tCoords.z + 0.35) - curDronePos.z
    local len = math.sqrt(dirX * dirX + dirY * dirY + dirZ * dirZ)
    if len > 0.001 then
        dirX = dirX / len
        dirY = dirY / len
        dirZ = dirZ / len
    else
        dirX, dirY, dirZ = 0, 0, -1
    end

    -- Vetor lateral para canos duplos
    local rightX = -dirY
    local rightY = dirX

    -- Áudio oficial de disparo do Battle Drone
    loadDroneAudioBank()
    pcall(function()
        if AUDIO and AUDIO.PLAY_SOUND_FROM_COORD then
            AUDIO.PLAY_SOUND_FROM_COORD(-1, "Laser_Shoot", curDronePos.x, curDronePos.y, curDronePos.z, "DLC_BATTLE_DRONE_SOUNDS", false, 0, false)
        elseif AUDIO and AUDIO.PLAY_SOUND_FRONTEND then
            AUDIO.PLAY_SOUND_FRONTEND(-1, "Laser_Shoot", "DLC_BATTLE_DRONE_SOUNDS", true)
        end
    end)

    -- Execução 100% não-bloqueante (SEM YIELD) para preservar o voo fluido a 60 FPS
    for _, side in ipairs({ -0.20, 0.20 }) do
        local muzzleX = curDronePos.x + (dirX * 0.90) + (rightX * side)
        local muzzleY = curDronePos.y + (dirY * 0.90) + (rightY * side)
        local muzzleZ = curDronePos.z - 0.05 + (dirZ * 0.10)

        local spreadX = (math.random(-2, 2) * 0.01)
        local spreadY = (math.random(-2, 2) * 0.01)
        local spreadZ = (math.random(-2, 2) * 0.01)

        local destX = tCoords.x + spreadX
        local destY = tCoords.y + spreadY
        local destZ = tCoords.z + 0.35 + spreadZ

        -- Traçante luminoso visível (linha incandescente dourada da metralhadora)
        if GRAPHICS and GRAPHICS.DRAW_LINE then
            GRAPHICS.DRAW_LINE(muzzleX, muzzleY, muzzleZ, destX, destY, destZ, 255, 220, 60, 240)
        end

        local shooterPed = (S.overwatchAnonymousKills ~= false) and 0 or myPed
        pcall(function()
            if MISC and MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS then
                MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS(
                    muzzleX, muzzleY, muzzleZ,
                    destX, destY, destZ,
                    bulletDmg,
                    true,
                    bulletHash,
                    shooterPed,
                    true,
                    false,
                    3500.0
                )
            end
        end)
    end

    -- Dano balístico direto ao alvo (sem explosão)
    pcall(function()
        if PED and PED.APPLY_DAMAGE_TO_PED and isValidEntity(targetPed) then
            PED.APPLY_DAMAGE_TO_PED(targetPed, bulletDmg, false)
        end
    end)
end

local function startOverwatchLoop()
    if S.overwatchLoopActive then return end
    S.overwatchLoopActive = true

    script.run_in_callback(function()
        notify.info("Overwatch", "Drone Tático Ativado!")
        showFeedNotification("~g~[OVERWATCH] ~w~Drone Tático voando e escoltando.")

        local bestThreat = nil
        local lastScanTime = 0

        while S.overwatchActive do
            if S.overwatchIsDiving then
                script.yield(100)
            else
            pcall(function()
                local myPed = getLocalPed()
                if not isValidEntity(myPed) or PED.IS_PED_INJURED(myPed) then
                    deleteOverwatchDrone()
                    script.yield(500)
                    return
                end

                -- Se o drone foi despachado para mergulho kamikaze e ainda está em voo

                local drone = S.overwatchDroneObj
                if not isValidEntity(drone) then
                    drone = spawnOverwatchDrone()
                end

                if not isValidEntity(drone) then
                    script.yield(100)
                    return
                end

                if not S.overwatchSoundId or S.overwatchSoundId == -1 then
                    startOverwatchFlightSound(drone)
                end

                local now = gameTimer()

                -- Determina entidade pai (se o jogador estiver em veículo, acompanha o teto do veículo)
                local parentEnt = myPed
                if PED and PED.IS_PED_IN_ANY_VEHICLE and PED.IS_PED_IN_ANY_VEHICLE(myPed, false) then
                    local veh = PED.GET_VEHICLE_PED_IS_IN(myPed, false)
                    if isValidEntity(veh) then
                        parentEnt = veh
                        if ENTITY.SET_ENTITY_NO_COLLISION_ENTITY then
                            ENTITY.SET_ENTITY_NO_COLLISION_ENTITY(drone, veh, false)
                        end
                    end
                end

                local pCoords = ENTITY.GET_ENTITY_COORDS(parentEnt, true)
                local pHeading = ENTITY.GET_ENTITY_HEADING(parentEnt)
                local rad = math.rad(pHeading)
                local fwdX = -math.sin(rad)
                local fwdY =  math.cos(rad)
                local rightX =  math.cos(rad)
                local rightY =  math.sin(rad)

                local offX = S.overwatchSideOffset or 0.0
                local offY = -0.10
                local baseHeight = S.overwatchHeightOffset or 2.2
                local offZ = (parentEnt == myPed) and baseHeight or (baseHeight + 1.0)

                -- Flutuação orgânica dupla (micro-correntes de ar de sustentação)
                local hoverBob = (math.sin(now / 380.0) * 0.04) + (math.cos(now / 720.0) * 0.015)
                local targetX = pCoords.x + (rightX * offX) + (fwdX * offY)
                local targetY = pCoords.y + (rightY * offX) + (fwdY * offY)
                local targetZ = pCoords.z + offZ + hoverBob

                -- Movimento Suave com Interpolação Amortecida (Lerp Fluido)
                local curCoords = ENTITY.GET_ENTITY_COORDS(drone, true)
                local dx = targetX - curCoords.x
                local dy = targetY - curCoords.y
                local dz = targetZ - curCoords.z
                local distToTarget = math.sqrt(dx*dx + dy*dy + dz*dz)

                local followRate = 0.16
                if distToTarget > 12.0 then
                    followRate = 1.0
                elseif distToTarget > 3.0 then
                    followRate = 0.35
                end

                local nextX = curCoords.x + (dx * followRate)
                local nextY = curCoords.y + (dy * followRate)
                local nextZ = curCoords.z + (dz * followRate)

                -- Heartbeat de audio posicional: re-dispara som de voo a cada ~3s na posicao do drone
                if not S._lastDroneAudioRefresh then S._lastDroneAudioRefresh = 0 end
                if (now - S._lastDroneAudioRefresh) >= 3000 then
                    S._lastDroneAudioRefresh = now
                    pcall(function()
                        loadDroneAudioBank()
                        if AUDIO and AUDIO.PLAY_SOUND_FROM_COORD then
                            AUDIO.PLAY_SOUND_FROM_COORD(-1, "Flight_Loop", nextX, nextY, nextZ, "DLC_BATTLE_DRONE_SOUNDS", false, 15, false)
                        end
                    end)
                end

                -- Inclinação dinâmica de voo (Pitch e Roll baseados na velocidade de deslocamento)
                local velX = (nextX - curCoords.x) * 30.0
                local velY = (nextY - curCoords.y) * 30.0
                local forwardDot = (velX * fwdX + velY * fwdY)
                local rightDot   = (velX * rightX + velY * rightY)

                local targetPitch = math.max(-12.0, math.min(12.0, forwardDot * -3.5))
                local targetRoll  = math.max(-15.0, math.min(15.0, rightDot * -4.5))

                -- Varredura de ameaças a cada 100ms para alta sensibilidade
                if (now - lastScanTime) >= 100 then
                    lastScanTime = now
                    local bestDist = S.overwatchProtectionRadius or 50.0
                    local minFireDist = (S.overwatchWeaponMode == 2 or S.overwatchWeaponMode == 3) and 1.0 or ((S.overwatchWeaponMode == 4) and 0.5 or 5.0)

                    -- Se já tivermos uma ameaça válida travada, mantém foco nela para não perder o alvo
                    local keepThreat = false
                    if isValidEntity(bestThreat) and not PED.IS_PED_INJURED(bestThreat) then
                        local cCoords = ENTITY.GET_ENTITY_COORDS(bestThreat, true)
                        local cdx = cCoords.x - pCoords.x
                        local cdy = cCoords.y - pCoords.y
                        local cdz = cCoords.z - pCoords.z
                        local dist = math.sqrt(cdx*cdx + cdy*cdy + cdz*cdz)
                        if dist >= minFireDist and dist <= (bestDist * 1.25) then
                            if S.overwatchAggressiveMode or isPedOfferingThreat(bestThreat, myPed) then
                                keepThreat = true
                            end
                        end
                    end

                    if not keepThreat then
                        local allPeds = getAllNearbyPeds(bestDist)
                        local candidateThreat = nil
                        local candidateDist = bestDist + 1.0

                        for _, candidate in ipairs(allPeds) do
                            if isValidEntity(candidate) and candidate ~= myPed and not PED.IS_PED_INJURED(candidate) then
                                local cCoords = ENTITY.GET_ENTITY_COORDS(candidate, true)
                                local cdx = cCoords.x - pCoords.x
                                local cdy = cCoords.y - pCoords.y
                                local cdz = cCoords.z - pCoords.z
                                local dist = math.sqrt(cdx*cdx + cdy*cdy + cdz*cdz)

                                if dist >= minFireDist and dist <= bestDist then
                                    local isThreat = false
                                    if S.overwatchAggressiveMode then
                                        -- Modo Totalmente Agressivo: Alveja TODOS no raio
                                        isThreat = true
                                    else
                                        -- Modo Defensivo: Apontando arma para o jogador ou oferecendo perigo
                                        isThreat = isPedOfferingThreat(candidate, myPed)
                                    end

                                    if isThreat and dist < candidateDist then
                                        candidateDist = dist
                                        candidateThreat = candidate
                                    end
                                end
                            end
                        end
                        bestThreat = candidateThreat
                    end
                end

                -- Se a ameaça foi eliminada
                if bestThreat and (not isValidEntity(bestThreat) or PED.IS_PED_INJURED(bestThreat)) then
                    bestThreat = nil
                    S.overwatchTargetPed = nil
                    S.overwatchLockStartTime = 0
                end

                local isMgOnly = (S.overwatchWeaponMode == 2)
                local isHybrid = (S.overwatchWeaponMode == 3)
                local effectiveCooldown = S.overwatchCooldown or 3.0
                if isMgOnly or isHybrid then
                    effectiveCooldown = 0.10 -- 100ms entre rajadas para a metralhadora
                end
                local canShoot = (now - S.overwatchLastStrikeTime) >= (effectiveCooldown * 1000)

                -- Rotação angular suave com atan2 matematicamente correto no espaço GTA V
                local desiredHeading = pHeading
                if isValidEntity(bestThreat) then
                    local tCoords = ENTITY.GET_ENTITY_COORDS(bestThreat, true)
                    local atanFunc = math.atan2 or math.atan
                    desiredHeading = (math.deg(atanFunc(-(tCoords.x - nextX), tCoords.y - nextY)) + 360.0) % 360.0

                    -- Mira vertical dinâmica (aponta o nariz do drone para o tórax do alvo)
                    local tdz = (tCoords.z + 0.35) - nextZ
                    local dist2D = math.sqrt((tCoords.x - nextX)^2 + (tCoords.y - nextY)^2)
                    if dist2D > 0.5 then
                        local aimPitch = math.deg(atanFunc(tdz, dist2D))
                        targetPitch = math.max(-28.0, math.min(22.0, aimPitch))
                    end
                    targetRoll = targetRoll * 0.25
                end

                local curHeading = ENTITY.GET_ENTITY_HEADING(drone)
                local hDiff = (desiredHeading - curHeading + 180.0) % 360.0 - 180.0
                local nextHeading = (curHeading + hDiff * 0.28) % 360.0

                ENTITY.FREEZE_ENTITY_POSITION(drone, true)
                if ENTITY.SET_ENTITY_HAS_GRAVITY then
                    ENTITY.SET_ENTITY_HAS_GRAVITY(drone, false)
                end
                ENTITY.SET_ENTITY_COLLISION(drone, false, false)
                ENTITY.SET_ENTITY_COORDS_NO_OFFSET(drone, nextX, nextY, nextZ, false, false, false)
                ENTITY.SET_ENTITY_VELOCITY(drone, 0.0, 0.0, 0.0)
                ENTITY.SET_ENTITY_ANGULAR_VELOCITY(drone, 0.0, 0.0, 0.0)

                pcall(function()
                    if ENTITY.SET_ENTITY_ROTATION then
                        ENTITY.SET_ENTITY_ROTATION(drone, targetPitch, targetRoll, nextHeading, 2, true)
                    else
                        ENTITY.SET_ENTITY_HEADING(drone, nextHeading)
                    end
                end)

                if isValidEntity(bestThreat) then
                    local tCoords = ENTITY.GET_ENTITY_COORDS(bestThreat, true)

                    -- Trava laser vermelho vivo contínuo no peito do alvo
                    if GRAPHICS and GRAPHICS.DRAW_LINE then
                        GRAPHICS.DRAW_LINE(nextX, nextY, nextZ, tCoords.x, tCoords.y, tCoords.z + 0.25, 255, 0, 0, 245)
                    end

                    -- Notifica e toca alarme sonoro quando o drone se sente ameaçado (ao travar na ameaça)
                    if S.overwatchTargetPed ~= bestThreat then
                        S.overwatchTargetPed = bestThreat
                        S.overwatchLockStartTime = now
                        showFeedNotification("~r~[OVERWATCH] ~w~Ameaça detectada! Mirando no alvo...")
                        pcall(function()
                            if AUDIO and AUDIO.PLAY_SOUND_FRONTEND then
                                AUDIO.PLAY_SOUND_FRONTEND(-1, "Blip_Alert", "DLC_BATTLE_DRONE_SOUNDS", true)
                                AUDIO.PLAY_SOUND_FRONTEND(-1, "Scan_Loop", "DLC_BATTLE_DRONE_SOUNDS", true)
                            end
                        end)
                    end

                    local lockDelay = (isMgOnly or isHybrid) and 60 or (S.overwatchWeaponMode == 4 and 180 or 500)
                    if (now - S.overwatchLockStartTime) >= lockDelay and canShoot then
                        local dCoords = { x = nextX, y = nextY, z = nextZ }
                        if S.overwatchWeaponMode == 1 then
                            -- Apenas Mísseis Orbitais (com explosão pesada)
                            triggerOverwatchMissileStrike(bestThreat)
                            S.overwatchLastStrikeTime = gameTimer()
                        elseif S.overwatchWeaponMode == 2 then
                            -- Apenas Metralhadora Tática (apenas balas balísticas, SEM explosão)
                            triggerOverwatchMachineGunBurst(bestThreat, dCoords)
                            S.overwatchLastStrikeTime = gameTimer()
                        elseif S.overwatchWeaponMode == 3 then
                            -- Ambos Juntos (Metralhadora contínua + Míssil Orbital simultâneo)
                            triggerOverwatchMachineGunBurst(bestThreat, dCoords)
                            if (now - (S.overwatchLastMissileTime or 0)) >= ((S.overwatchCooldown or 3.0) * 1000) then
                                triggerOverwatchMissileStrike(bestThreat)
                                S.overwatchLastMissileTime = gameTimer()
                            end
                            S.overwatchLastStrikeTime = gameTimer()
                        elseif S.overwatchWeaponMode == 4 then
                            local tPid = (NETWORK and NETWORK.NETWORK_GET_PLAYER_INDEX_FROM_PED) and NETWORK.NETWORK_GET_PLAYER_INDEX_FROM_PED(bestThreat) or -1
                            local tName = (tPid ~= -1 and tPid ~= nil) and getPlayerName(tPid) or "Ameaca Armada"
                            local cDrone = drone
                            S.overwatchDroneObj = nil
                            S.overwatchIsDiving = true
                            triggerKamikazeFlight(cDrone, bestThreat, tCoords, tName, true)
                            S.overwatchLastStrikeTime = gameTimer()
                        end

                        if PED.IS_PED_INJURED(bestThreat) then
                            bestThreat = nil
                            S.overwatchTargetPed = nil
                            S.overwatchLockStartTime = 0
                        end
                    end
                else
                    S.overwatchTargetPed = nil
                    S.overwatchLockStartTime = 0
                end
            end)
            script.yield(0)
        end
            end

        deleteOverwatchDrone()
        S.overwatchLoopActive = false
        notify.info("Overwatch", "Micro-Drone Guardiao Desativado.")
        showFeedNotification("~y~[OVERWATCH] ~w~Micro-Drone recolhido.")
    end)
end

------------------------------------------------------------
-- DRONE KAMIKAZE TÁTICO (SUICIDA / FPV)
------------------------------------------------------------

local function clearActiveKamikazeDrones()
    script.run_in_callback(function()
        if S.activeKamikazeDrones then
            local list = S.activeKamikazeDrones
            S.activeKamikazeDrones = {}
            for _, drone in ipairs(list) do
                if isValidEntity(drone) then
                    safeDeleteEntity(drone)
                    script.yield(15)
                end
            end
        end
        notify.info("Kamikaze", "Drones kamikaze limpos e abortados.")
    end)
end

local function triggerKamikazeFlight(drone, targetPed, targetCoords, targetName, isCompanionDrone)
    if not isValidEntity(drone) then return end

    local myPed = getLocalPed()

    pcall(function()
        safeSetInvincible(drone, true)
        ENTITY.SET_ENTITY_COLLISION(drone, true, true)
        if isValidEntity(myPed) and ENTITY.SET_ENTITY_NO_COLLISION_ENTITY then
            ENTITY.SET_ENTITY_NO_COLLISION_ENTITY(drone, myPed, false)
        end
        ENTITY.FREEZE_ENTITY_POSITION(drone, true)
        if ENTITY.SET_ENTITY_HAS_GRAVITY then ENTITY.SET_ENTITY_HAS_GRAVITY(drone, false) end
        if ENTITY.SET_ENTITY_DYNAMIC then ENTITY.SET_ENTITY_DYNAMIC(drone, false) end
        ENTITY.SET_ENTITY_VISIBLE(drone, true, false)
        if ENTITY.SET_ENTITY_LOCALLY_VISIBLE then ENTITY.SET_ENTITY_LOCALLY_VISIBLE(drone) end
    end)

    table.insert(S.activeKamikazeDrones, drone)

    notify.warn("Kamikaze", "Drone Suicida FPV lançado em rota de colisao contra: " .. (targetName or "Alvo"))
    showFeedNotification("~r~[KAMIKAZE] ~w~Drone Suicida FPV em mergulho contra ~y~" .. (targetName or "Alvo"))

    -- Inicia zumbido contínuo de voo e alarme de lançamento
    local kamiSoundId = -1
    loadDroneAudioBank()
    pcall(function()
        if AUDIO and AUDIO.PLAY_SOUND_FRONTEND then
            AUDIO.PLAY_SOUND_FRONTEND(-1, "Blip_Alert", "DLC_BATTLE_DRONE_SOUNDS", true)
        end
        if AUDIO and AUDIO.GET_SOUND_ID and AUDIO.PLAY_SOUND_FROM_ENTITY then
            kamiSoundId = AUDIO.GET_SOUND_ID()
            if kamiSoundId ~= -1 then
                AUDIO.PLAY_SOUND_FROM_ENTITY(kamiSoundId, "Flight_Loop", drone, "DLC_BATTLE_DRONE_SOUNDS", false, 0)
            end
        end
    end)

    script.run_in_callback(function()
        local startTime = gameTimer()
        local lastBeepTime = 0
        local droneCurCoords = ENTITY.GET_ENTITY_COORDS(drone, true)
        local dronePos = { x = droneCurCoords.x, y = droneCurCoords.y, z = droneCurCoords.z }

        local myInitialPos = isValidEntity(myPed) and ENTITY.GET_ENTITY_COORDS(myPed, true) or dronePos
        local maxDuration = 25000 -- 25s timeout
        local frameDelta = 0.02
        local lastDist = 9999.0

        while true do
            script.yield(20)
            if not isValidEntity(drone) then break end

            local now = gameTimer()
            local elapsed = (now - startTime)
            if elapsed > maxDuration then break end

            -- Atualiza coordenadas em tempo real do alvo e verifica veículo
            if isValidEntity(targetPed) then
                targetCoords = ENTITY.GET_ENTITY_COORDS(targetPed, true)
            end

            if not targetCoords then break end

            local aimZ = targetCoords.z + 0.35
            if isValidEntity(targetPed) and PED.IS_PED_IN_ANY_VEHICLE and PED.IS_PED_IN_ANY_VEHICLE(targetPed, false) then
                local veh = PED.GET_VEHICLE_PED_IS_IN(targetPed, false)
                if isValidEntity(veh) then
                    local vCoords = ENTITY.GET_ENTITY_COORDS(veh, true)
                    targetCoords = vCoords
                    aimZ = vCoords.z + 0.6
                end
            end

            local dx = targetCoords.x - dronePos.x
            local dy = targetCoords.y - dronePos.y
            local dz = aimZ - dronePos.z
            local dist = math.sqrt(dx * dx + dy * dy + dz * dz)

            -- Linha de telemetria laser vermelho vivo super visível conectando ao alvo
            if GRAPHICS and GRAPHICS.DRAW_LINE then
                GRAPHICS.DRAW_LINE(dronePos.x, dronePos.y, dronePos.z, targetCoords.x, targetCoords.y, aimZ, 255, 15, 15, 255)
            end

            -- Beep de aproximação cada vez mais rápido
            local beepInterval = math.max(60, math.min(450, dist * 12))
            if (now - lastBeepTime) >= beepInterval then
                lastBeepTime = now
                pcall(function()
                    if AUDIO and AUDIO.PLAY_SOUND_FRONTEND then
                        AUDIO.PLAY_SOUND_FRONTEND(-1, "Blip_Alert", "DLC_BATTLE_DRONE_SOUNDS", true)
                    end
                end)
            end

            -- Distância do jogador local para proteção contra suicídio acidental
            local currentMyPos = isValidEntity(myPed) and ENTITY.GET_ENTITY_COORDS(myPed, true) or myInitialPos
            local distFromLocalPlayer = math.sqrt((dronePos.x - currentMyPos.x)^2 + (dronePos.y - currentMyPos.y)^2 + (dronePos.z - currentMyPos.z)^2)

            -- Verificação física se tocou diretamente no alvo
            local isTouchingTarget = false
            pcall(function()
                if isValidEntity(targetPed) and ENTITY and ENTITY.IS_ENTITY_TOUCHING_ENTITY then
                    if ENTITY.IS_ENTITY_TOUCHING_ENTITY(drone, targetPed) then
                        isTouchingTarget = true
                    end
                    if PED and PED.IS_PED_IN_ANY_VEHICLE and PED.IS_PED_IN_ANY_VEHICLE(targetPed, false) then
                        local veh = PED.GET_VEHICLE_PED_IS_IN(targetPed, false)
                        if isValidEntity(veh) and ENTITY.IS_ENTITY_TOUCHING_ENTITY(drone, veh) then
                            isTouchingTarget = true
                        end
                    end
                end
            end)

            -- Verificação de colisão com qualquer obstáculo do cenário após 120ms
            local hasCollidedWorld = false
            if elapsed > 120 and distFromLocalPlayer > 2.0 then
                pcall(function()
                    if ENTITY and ENTITY.HAS_ENTITY_COLLIDED_WITH_ANYTHING and ENTITY.HAS_ENTITY_COLLIDED_WITH_ANYTHING(drone) then
                        hasCollidedWorld = true
                    end
                end)
            end

            -- DETECÇÃO DA BATIDA / IMPACTO
            -- 1. Tocou na entidade alvo
            -- 2. Distância menor que 1.4 metro (contato físico direto)
            -- 3. Próximo passo atravessaria o alvo
            -- 4. Passou pelo ponto de maior aproximação (ultrapassou)
            -- 5. Bateu em parede/veículo/chão
            -- 6. Alvo ferido/abatido próximo
            local hasHit = isTouchingTarget
                or (dist <= 1.4)
                or (hasCollidedWorld)
                or (lastDist < 3.0 and dist > (lastDist + 0.15))
                or (isValidEntity(targetPed) and PED.IS_PED_INJURED(targetPed) and dist <= 3.5)

            if hasHit then
                local boomX = dronePos.x
                local boomY = dronePos.y
                local boomZ = dronePos.z
                if dist <= 2.5 and targetCoords then
                    boomX = targetCoords.x
                    boomY = targetCoords.y
                    boomZ = aimZ
                end

                -- Protege o jogador local caso esteja dentro do raio de blast
                if distFromLocalPlayer < 8.0 and isValidEntity(myPed) then
                    safeSetInvincible(myPed, true)
                end

                pcall(function()
                    -- Para o loop de áudio contínuo do motor
                    if kamiSoundId ~= -1 and AUDIO then
                        if AUDIO.STOP_SOUND then AUDIO.STOP_SOUND(kamiSoundId) end
                        if AUDIO.RELEASE_SOUND_ID then AUDIO.RELEASE_SOUND_ID(kamiSoundId) end
                        kamiSoundId = -1
                    end

                    -- Som de Destruição / Crash oficial do Battle Drone
                    if AUDIO then
                        if AUDIO.PLAY_SOUND_FROM_COORD then
                            AUDIO.PLAY_SOUND_FROM_COORD(-1, "Crash", boomX, boomY, boomZ, "DLC_BATTLE_DRONE_SOUNDS", false, 0, false)
                        end
                        if AUDIO.PLAY_SOUND_FRONTEND then
                            AUDIO.PLAY_SOUND_FRONTEND(-1, "Crash", "DLC_BATTLE_DRONE_SOUNDS", true)
                            AUDIO.PLAY_SOUND_FRONTEND(-1, "ScreenFlash", "WastedSounds", true)
                        end
                    end

                    -- 1. Disparo de Foguete Explosivo no ponto exato da batida (explosão visual massiva com fogo, fumaça e destroços)
                    local expHash = getHash("VEHICLE_WEAPON_SPACE_ROCKET")
                    if expHash == 0 then expHash = getHash("WEAPON_EXPLOSION") end
                    local shooterPed = (S.overwatchAnonymousKills ~= false) and 0 or myPed
                    if MISC and MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS then
                        MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS(
                            dronePos.x, dronePos.y, dronePos.z + 0.3,
                            boomX, boomY, boomZ,
                            10000,
                            true,
                            expHash,
                            shooterPed,
                            true,
                            false,
                            1200.0
                        )
                    end

                    -- 2. Múltiplas Explosões Nativas Devastadoras (Foguete RPG Tag 4, C4 Tag 2 e Canhão Orbital Tag 29)
                    if FIRE and FIRE.ADD_EXPLOSION then
                        FIRE.ADD_EXPLOSION(boomX, boomY, boomZ, 4, 10.0, true, false, 2.0)
                        FIRE.ADD_EXPLOSION(boomX, boomY, boomZ, 2, 10.0, true, false, 1.5)
                        FIRE.ADD_EXPLOSION(boomX, boomY, boomZ, 29, 10.0, true, false, 2.0)
                    end

                    -- 3. Destruição do veículo inimigo caso o alvo esteja dentro de um
                    if isValidEntity(targetPed) then
                        if PED.IS_PED_IN_ANY_VEHICLE and PED.IS_PED_IN_ANY_VEHICLE(targetPed, false) then
                            local veh = PED.GET_VEHICLE_PED_IS_IN(targetPed, false)
                            if isValidEntity(veh) then
                                getControlOfEntity(veh)
                                if VEHICLE and VEHICLE.EXPLODE_VEHICLE then
                                    VEHICLE.EXPLODE_VEHICLE(veh, true, false)
                                end
                                ENTITY.SET_ENTITY_HEALTH(veh, 0)
                            end
                        end
                        getControlOfEntity(targetPed)
                        if PED and PED.APPLY_DAMAGE_TO_PED then
                            PED.APPLY_DAMAGE_TO_PED(targetPed, 10000, false)
                        end
                        ENTITY.SET_ENTITY_HEALTH(targetPed, 0)
                    end

                    -- O drone é desintegrado e desmaterializado instantaneamente no momento da batida
                    ENTITY.SET_ENTITY_VISIBLE(drone, false, false)
                end)

                showFeedNotification("~r~[KAMIKAZE] ~w~Drone Suicida EXPLODIU ao bater no alvo!")
                notify.success("Kamikaze", "Drone kamikaze colidiu e explodiu o alvo com sucesso!")
                break
            end

            lastDist = dist

            -- Rampa de velocidade progressiva (acelera rapidamente até velocidade terminal de impacto)
            local curSpeed = 44.0
            if dist < 22.0 and elapsed < 350 then
                curSpeed = 18.0 + (elapsed / 350.0) * 26.0
            end

            local step = math.min(curSpeed * frameDelta, dist)
            local normX = dx / math.max(0.001, dist)
            local normY = dy / math.max(0.001, dist)
            local normZ = dz / math.max(0.001, dist)

            -- Nos primeiros 200ms após sair da cabeça, ganha um leve arco de projeção para a frente
            local arcZ = 0.0
            if elapsed < 200 and dist < 25.0 then
                arcZ = 0.025
            end

            dronePos.x = dronePos.x + (normX * step)
            dronePos.y = dronePos.y + (normY * step)
            dronePos.z = dronePos.z + (normZ * step) + arcZ

            -- Rotação e inclinação apontando diretamente para o alvo
            local targetHeading = (math.deg(math.atan(dy, dx)) - 90.0 + 360.0) % 360.0
            local pitchAngle = math.deg(math.atan(dz, math.sqrt(dx*dx + dy*dy)))

            ENTITY.SET_ENTITY_COORDS_NO_OFFSET(drone, dronePos.x, dronePos.y, dronePos.z, false, false, false)
            pcall(function()
                if ENTITY.SET_ENTITY_ROTATION then
                    ENTITY.SET_ENTITY_ROTATION(drone, -pitchAngle, 0.0, targetHeading, 2, true)
                else
                    ENTITY.SET_ENTITY_HEADING(drone, targetHeading)
                end
            end)
        end

        pcall(function()
            if kamiSoundId ~= -1 and AUDIO then
                if AUDIO.STOP_SOUND then AUDIO.STOP_SOUND(kamiSoundId) end
                if AUDIO.RELEASE_SOUND_ID then AUDIO.RELEASE_SOUND_ID(kamiSoundId) end
                kamiSoundId = -1
            end
        end)

        if isValidEntity(drone) then
            safeDeleteEntity(drone)
        end

        for idx, d in ipairs(S.activeKamikazeDrones) do
            if d == drone then
                table.remove(S.activeKamikazeDrones, idx)
                break
            end
        end

        -- O drone kamikaze SE AUTO-DESTRÓI no processo (NÃO ressuscita e desativa o Overwatch)
        if isCompanionDrone then
            S.overwatchIsDiving = false
            deleteOverwatchDrone()
            showFeedNotification("~r~[OVERWATCH] ~w~Drone Guardiao explodiu no alvo Kamikaze!")
            notify.success("Overwatch", "Alvo neutralizado com o Drone Kamikaze!")
            -- Reconstrói automaticamente o drone tático após 3.5 segundos para continuar escoltando
            script.yield(3500)
            if S.overwatchActive and not S.overwatchDroneObj then
                local newDrone = spawnOverwatchDrone()
                if newDrone and isValidEntity(newDrone) then
                    showFeedNotification("~g~[OVERWATCH] ~w~Novo Micro-Drone Guardiao reconstruido!")
                    notify.info("Overwatch", "Novo drone tatico reconstruido e escoltando voce!")
                end
            end
        end
    end)
end

local function triggerKamikazeDrone(targetPid)
    if targetPid == -2 then
        if triggerKamikazeAllSession then
            triggerKamikazeAllSession()
        end
        return
    end

    local myLocalPid = getLocalPid()
    local actualPid = (targetPid == nil or targetPid == -1) and myLocalPid or targetPid
    local targetPed = getPlayerPed(actualPid)
    local targetName = (actualPid == myLocalPid) and "Você" or getPlayerName(actualPid)
    local targetCoords = getTargetCoordsSafe(actualPid, targetPed)

    if not targetCoords or (targetCoords.x == 0 and targetCoords.y == 0 and targetCoords.z == 0) then
        notify.warn("Kamikaze", "Alvo inválido ou não encontrado no mapa.")
        return
    end

    script.run_in_callback(function()
        local drone = nil
        local isCompanion = false

        -- Se o drone companheiro sobre a cabeça estiver ativo, USA ELE DIRETAMENTE!
        if S.overwatchActive and S.overwatchDroneObj and isValidEntity(S.overwatchDroneObj) then
            drone = S.overwatchDroneObj
            S.overwatchDroneObj = nil -- Desanexa do loop da cabeça para não congelar as coordenadas
            S.overwatchIsDiving = true
            isCompanion = true
        else
            -- Spawna um novo drone tático acima da cabeça do jogador
            local droneHash = getHash("ba_prop_battle_drone_quad")
            if not requestAndLoadModel(droneHash, 200) then
                droneHash = getHash("m24_2_prop_m42_drone_01a")
                if not requestAndLoadModel(droneHash, 200) then
                    droneHash = getHash("ch_prop_casino_drone_01a")
                    requestAndLoadModel(droneHash, 200)
                end
            end

            local myPed = getLocalPed()
            local myCoords = isValidEntity(myPed) and ENTITY.GET_ENTITY_COORDS(myPed, true) or targetCoords
            local hOff = S.overwatchHeightOffset or 2.2
            local spawnX = myCoords.x
            local spawnY = myCoords.y
            local spawnZ = myCoords.z + hOff

            drone = safeCreateStuntProp(droneHash, spawnX, spawnY, spawnZ, false)
        end

        if not isValidEntity(drone) then
            notify.error("Kamikaze", "Não foi possível preparar o drone kamikaze.")
            return
        end

        triggerKamikazeFlight(drone, targetPed, targetCoords, targetName, isCompanion)
    end)
end

local function triggerKamikazeAllSession()
    local players = getActivePlayersList()
    if #players == 0 then
        notify.warn("Kamikaze", "Nenhum jogador encontrado na sessao.")
        return
    end

    notify.warn("Kamikaze", string.format("Ataque Global! Despachando Drones Kamikaze para os %d jogadores...", #players))
    showFeedNotification("~r~[KAMIKAZE GLOBAL] ~w~Enxame de Drones Suicidas despachado para toda a sessao!")

    script.run_in_callback(function()
        for _, pid in ipairs(players) do
            triggerKamikazeDrone(pid)
            script.yield(200)
        end
    end)
end



------------------------------------------------------------
-- FREIO DE EMERGENCIA & PLACA PERSONALIZADA
------------------------------------------------------------

local function triggerEmergencyBrake()
    local ped = getLocalPed()
    if not PED.IS_PED_IN_ANY_VEHICLE(ped, false) then
        notify.warn("Veiculo", "Voce precisa estar dentro de um veiculo!")
        return
    end
    local veh = PED.GET_VEHICLE_PED_IS_IN(ped, false)
    if not isValidEntity(veh) then return end

    pcall(function()
        if VEHICLE and VEHICLE.BRING_VEHICLE_TO_HALT then
            VEHICLE.BRING_VEHICLE_TO_HALT(veh, 0.0, 1, false)
        end
        ENTITY.SET_ENTITY_VELOCITY(veh, 0.0, 0.0, 0.0)
        if VEHICLE and VEHICLE.SET_VEHICLE_FORWARD_SPEED then
            VEHICLE.SET_VEHICLE_FORWARD_SPEED(veh, 0.0)
        end
        AUDIO.PLAY_SOUND_FRONTEND(-1, "Airhorn", "DLC_TG_Running_Defenders_Sounds", true)
    end)
    notify.success("Veiculo", "Freio de emergencia acionado! Parada instantanea.")
end

local function applyCustomPlate(text, plateIndex)
    local ped = getLocalPed()
    if not PED.IS_PED_IN_ANY_VEHICLE(ped, false) then
        notify.warn("Placa", "Voce precisa estar dentro de um veiculo!")
        return
    end
    local veh = PED.GET_VEHICLE_PED_IS_IN(ped, false)
    if not isValidEntity(veh) then return end

    pcall(function()
        if VEHICLE and VEHICLE.SET_VEHICLE_NUMBER_PLATE_TEXT then
            VEHICLE.SET_VEHICLE_NUMBER_PLATE_TEXT(veh, tostring(text or "SPYREX"))
        end
        if plateIndex and VEHICLE and VEHICLE.SET_VEHICLE_NUMBER_PLATE_TEXT_INDEX then
            VEHICLE.SET_VEHICLE_NUMBER_PLATE_TEXT_INDEX(veh, plateIndex)
        end
        AUDIO.PLAY_SOUND_FRONTEND(-1, "SELECT", "HUD_FRONTEND_DEFAULT_SOUNDSET", true)
    end)
    notify.success("Placa", "Placa atualizada com sucesso para: " .. tostring(text or "SPYREX"))
end

------------------------------------------------------------
-- EMP REMOTO & SPACE LAUNCH (TROLLING SUITE)
------------------------------------------------------------

local function triggerRemoteEmp(targetPid)
    local ped = getPlayerPed(targetPid)
    if not isValidEntity(ped) then
        notify.warn("EMP", "Jogador alvo invalido ou fora de alcance!")
        return
    end
    local veh = 0
    if PED.IS_PED_IN_ANY_VEHICLE(ped, false) then
        veh = PED.GET_VEHICLE_PED_IS_IN(ped, false)
    end
    if not isValidEntity(veh) or veh == 0 then
        notify.warn("EMP", "O jogador alvo nao esta dentro de um veiculo no momento!")
        return
    end

    script.run_in_callback(function()
        local pos = ENTITY.GET_ENTITY_COORDS(veh, true)
        pcall(function()
            if AUDIO and AUDIO.PLAY_SOUND_FROM_COORD then
                AUDIO.PLAY_SOUND_FROM_COORD(-1, "Crash", pos.x, pos.y, pos.z, "DLC_BATTLE_DRONE_SOUNDS", false, 0, false)
            end
        end)

        STREAMING.REQUEST_NAMED_PTFX_ASSET("core")
        local w = 0
        while not STREAMING.HAS_NAMED_PTFX_ASSET_LOADED("core") and w < 20 do
            script.yield(10)
            w = w + 1
        end
        pcall(function()
            if GRAPHICS and GRAPHICS.USE_PARTICLE_FX_ASSET then
                GRAPHICS.USE_PARTICLE_FX_ASSET("core")
            end
            if GRAPHICS and GRAPHICS.START_NETWORKED_PARTICLE_FX_NON_LOOPED_AT_COORD then
                GRAPHICS.START_NETWORKED_PARTICLE_FX_NON_LOOPED_AT_COORD(
                    "sp_electric_arc", pos.x, pos.y, pos.z + 0.5,
                    0.0, 0.0, 0.0, 3.0, false, false, false, false
                )
            elseif GRAPHICS and GRAPHICS.START_PARTICLE_FX_NON_LOOPED_AT_COORD then
                GRAPHICS.START_PARTICLE_FX_NON_LOOPED_AT_COORD(
                    "sp_electric_arc", pos.x, pos.y, pos.z + 0.5,
                    0.0, 0.0, 0.0, 3.0, false, false, false
                )
            end
        end)

        pcall(function()
            VEHICLE.SET_VEHICLE_ENGINE_ON(veh, false, true, true)
            VEHICLE.SET_VEHICLE_UNDRIVEABLE(veh, true)
            VEHICLE.SET_VEHICLE_ENGINE_HEALTH(veh, -4000.0)
            ENTITY.SET_ENTITY_VELOCITY(veh, 0.0, 0.0, 0.0)
            VEHICLE.SET_VEHICLE_FORWARD_SPEED(veh, 0.0)
        end)
        notify.success("EMP", "EMP Remoto detonado com sucesso! Veiculo do alvo completamente neutralizado.")
    end)
end

local function triggerSpaceLaunch(targetPid)
    local ped = getPlayerPed(targetPid)
    if not isValidEntity(ped) then
        notify.warn("Space Launch", "Jogador alvo invalido ou fora de alcance!")
        return
    end

    local targetEnt = ped
    local isVeh = false
    if PED.IS_PED_IN_ANY_VEHICLE(ped, false) then
        targetEnt = PED.GET_VEHICLE_PED_IS_IN(ped, false)
        isVeh = true
    end

    script.run_in_callback(function()
        local pos = ENTITY.GET_ENTITY_COORDS(targetEnt, true)
        STREAMING.REQUEST_NAMED_PTFX_ASSET("scr_agency3b")
        local w = 0
        while not STREAMING.HAS_NAMED_PTFX_ASSET_LOADED("scr_agency3b") and w < 20 do
            script.yield(10)
            w = w + 1
        end
        pcall(function()
            if GRAPHICS and GRAPHICS.USE_PARTICLE_FX_ASSET then
                GRAPHICS.USE_PARTICLE_FX_ASSET("scr_agency3b")
            end
            if GRAPHICS and GRAPHICS.START_NETWORKED_PARTICLE_FX_NON_LOOPED_AT_COORD then
                GRAPHICS.START_NETWORKED_PARTICLE_FX_NON_LOOPED_AT_COORD(
                    "scr_agency3b_heli_dust", pos.x, pos.y, pos.z,
                    0.0, 0.0, 0.0, 4.0, false, false, false, false
                )
            elseif GRAPHICS and GRAPHICS.START_PARTICLE_FX_NON_LOOPED_AT_COORD then
                GRAPHICS.START_PARTICLE_FX_NON_LOOPED_AT_COORD(
                    "scr_agency3b_heli_dust", pos.x, pos.y, pos.z,
                    0.0, 0.0, 0.0, 4.0, false, false, false
                )
            end
        end)
        pcall(function()
            if AUDIO and AUDIO.PLAY_SOUND_FROM_COORD then
                AUDIO.PLAY_SOUND_FROM_COORD(-1, "ScreenFlash", pos.x, pos.y, pos.z, "WastedSounds", false, 0, false)
            end
        end)

        pcall(function()
            ENTITY.APPLY_FORCE_TO_ENTITY(targetEnt, 1, 0.0, 0.0, 800.0, 0.0, 0.0, 0.0, 0, false, true, true, false, true)
            ENTITY.SET_ENTITY_VELOCITY(targetEnt, 0.0, 0.0, 200.0)

            if isVeh then
                VEHICLE.SET_VEHICLE_OUT_OF_CONTROL(targetEnt, false, true)
                VEHICLE.SET_VEHICLE_FORWARD_SPEED(targetEnt, 200.0)
            else
                PED.SET_PED_TO_RAGDOLL(ped, 6000, 6000, 0, false, false, false)
            end
        end)
        notify.success("Space Launch", "SPACE LAUNCH ATIVADO! Alvo arremessado para a estratosfera!")
    end)
end

------------------------------------------------------------
-- IMGUI TAB RENDERERS (ENGLISH)
------------------------------------------------------------

local function renderTabJets()
    if not imgui.begin_tab_item("Fighter Jets") then return end
    imgui.text("=== 20MM FIGHTER JETS SQUADRON (DOGFIGHT) ===")
    imgui.text("Standard Squad: 5 Military Jets (Lazer 20mm)")
    imgui.spacing()
    imgui.text("Select Target for Single Attack:")
    renderPlayerTargetSelector(S.selectedDogfightPid, function(pid) S.selectedDogfightPid = pid end, "dogfight")
    imgui.spacing()
    if imgui.button("Launch Squadron (5 Jets) at Target##launch_jets_btn") then triggerDogfightAttack(S.selectedDogfightPid, 5) end
    imgui.same_line()
    if imgui.button("Attack Entire Session (2 Jets per Player)##launch_jets_all_btn") then triggerDogfightAttackAllSession() end
    imgui.same_line()
    if imgui.button("Clear / Purge Jets from Map##clear_jets_btn") then clearActiveDogfightJets() end
    imgui.end_tab_item()
end


local function renderTabOverwatchDrone()
    if not imgui.begin_tab_item("Drone Overwatch") then return end
    imgui.spacing()
    imgui.text("=== MICRO-DRONE TATICO OVERWATCH GUARDIÃO ===")
    imgui.text("Defesa aerea pessoal autonoma com trava laser e missil orbital.")
    imgui.separator()
    imgui.spacing()

    local c1, v1 = imgui.checkbox("Ativar Micro-Drone Guardiao##ow_active_chk", S.overwatchActive)
    if c1 then
        S.overwatchActive = v1
        if S.overwatchActive then
            startOverwatchLoop()
        else
            script.run_in_callback(function()
                deleteOverwatchDrone()
            end)
        end
    end

    imgui.spacing()
    imgui.text("Modo de Comportamento:")
    local c2, v2 = imgui.checkbox("Modo Exterminio Total (Atira em TODOS no raio!)##ow_aggr_chk", S.overwatchAggressiveMode)
    if c2 then
        S.overwatchAggressiveMode = v2
        notify.info("Overwatch", S.overwatchAggressiveMode and "Modo: Exterminio Total (Atira em TODOS no raio!)" or "Modo: Defensivo (Apenas Atacantes)")
    end
    local cAnon, vAnon = imgui.checkbox("Kills Anonimas / Modo Fantasma (Nao colocar mortes no meu nome)##ow_anon_chk", S.overwatchAnonymousKills ~= false)
    if cAnon then
        S.overwatchAnonymousKills = vAnon
        notify.info("Overwatch", S.overwatchAnonymousKills and "Modo Fantasma ATIVADO: Mortes anonimas (sem seu nome no feed)" or "Modo Normal: Mortes registradas no seu nome")
    end
    if not S.overwatchAggressiveMode then
        imgui.text("Status: Modo Defensivo (Dispara apenas quando atacado)")
    else
        imgui.text("Status: TOTALMENTE AGRESSIVO! (Atira e elimina TODOS os peds no raio)")
    end

    imgui.spacing()
    imgui.separator()
    imgui.spacing()

    imgui.text("Armamento do Drone (Selecione o Tipo de Tiro):")
    if imgui.button((S.overwatchWeaponMode == 1 and "[X] Misseis Orbitais" or "Misseis Orbitais") .. "##ow_wpn_1") then
        S.overwatchWeaponMode = 1
        notify.info("Overwatch", "Armamento: Misseis Orbitais (Apenas Misseis com Explosao)")
    end
    imgui.same_line()
    if imgui.button((S.overwatchWeaponMode == 2 and "[X] Metralhadora Tatica" or "Metralhadora Tatica") .. "##ow_wpn_2") then
        S.overwatchWeaponMode = 2
        notify.info("Overwatch", "Armamento: Metralhadora Tatica (Apenas Balas, SEM Explosao)")
    end
    imgui.same_line()
    if imgui.button((S.overwatchWeaponMode == 3 and "[X] Ambos Juntos" or "Ambos Juntos") .. "##ow_wpn_3") then
        S.overwatchWeaponMode = 3
        notify.info("Overwatch", "Armamento: Ambos Juntos (Metralhadora + Misseis)")
    end
    imgui.same_line()
    if imgui.button((S.overwatchWeaponMode == 4 and "[X] Kamikaze Suicida" or "Kamikaze Suicida") .. "##ow_wpn_4") then
        S.overwatchWeaponMode = 4
        notify.info("Overwatch", "Armamento: Drone Kamikaze (Sai da sua cabeca e mergulha no alvo!)")
    end

    if S.overwatchWeaponMode == 1 then
        imgui.text("Modo Ativo: Misseis Orbitais (Apenas Misseis com impacto e explosao pesada)")
    elseif S.overwatchWeaponMode == 2 then
        imgui.text("Modo Ativo: Metralhadora Tatica (Apenas Balas balisticas continuas com tracantes, SEM explosao)")
    elseif S.overwatchWeaponMode == 3 then
        imgui.text("Modo Ativo: Ambos Juntos (Rajadas continuas de metralhadora + Misseis simultaneos)")
    elseif S.overwatchWeaponMode == 4 then
        imgui.text("Modo Ativo: Drone Kamikaze Suicida! (O drone sai da sua cabeca, mergulha no inimigo e explode ao bater)")
    end

    imgui.spacing()
    imgui.separator()
    imgui.spacing()

    imgui.text("Raio de Protecao: " .. math.floor(S.overwatchProtectionRadius) .. "m")
    if imgui.button("25m##ow_rad25") then S.overwatchProtectionRadius = 25.0 end
    imgui.same_line()
    if imgui.button("50m##ow_rad50") then S.overwatchProtectionRadius = 50.0 end
    imgui.same_line()
    if imgui.button("75m##ow_rad75") then S.overwatchProtectionRadius = 75.0 end
    imgui.same_line()
    if imgui.button("100m##ow_rad100") then S.overwatchProtectionRadius = 100.0 end

    imgui.spacing()
    imgui.text("Intervalo entre Disparos: " .. string.format("%.1f", S.overwatchCooldown) .. "s")
    if imgui.button("2.0s##ow_cd2") then S.overwatchCooldown = 2.0 end
    imgui.same_line()
    if imgui.button("3.5s##ow_cd35") then S.overwatchCooldown = 3.5 end
    imgui.same_line()
    if imgui.button("5.0s##ow_cd5") then S.overwatchCooldown = 5.0 end
    imgui.same_line()
    if imgui.button("8.0s##ow_cd8") then S.overwatchCooldown = 8.0 end

    imgui.spacing()
    imgui.text("Trava de Seguranca: Misseis bloqueados se alvo < 8m do jogador.")
    imgui.spacing()
    imgui.separator()
    imgui.spacing()

    imgui.text("Posicionamento e Altura do Drone:")
    imgui.text("Altura Acima da Cabeca (Z): " .. string.format("%.1f", S.overwatchHeightOffset) .. "m")
    if imgui.button("1.8m##ow_h18") then S.overwatchHeightOffset = 1.8 end
    imgui.same_line()
    if imgui.button("2.2m (Padrao Cabeca)##ow_h22") then S.overwatchHeightOffset = 2.2 end
    imgui.same_line()
    if imgui.button("2.8m (Alto)##ow_h28") then S.overwatchHeightOffset = 2.8 end
    imgui.same_line()
    if imgui.button("3.5m (Topo)##ow_h35") then S.overwatchHeightOffset = 3.5 end

    imgui.spacing()
    imgui.text("Alinhamento Horizontal:")
    if imgui.button("Centralizado Acima da Cabeca (Padrao)##ow_pos_center") then S.overwatchSideOffset = 0.0 end
    imgui.same_line()
    if imgui.button("Ombro Direito##ow_pos_right") then S.overwatchSideOffset = 0.8 end
    imgui.same_line()
    if imgui.button("Ombro Esquerdo##ow_pos_left") then S.overwatchSideOffset = -0.8 end

    imgui.spacing()
    imgui.separator()
    imgui.spacing()

    if imgui.button("Disparar Ataque Orbital no Ponto da Mira##ow_aim_strike_btn") then
        script.run_in_callback(function()
            local ped = getLocalPed()
            if not isValidEntity(ped) then return end
            local camDir = getCameraDirection()
            local pCoords = ENTITY.GET_ENTITY_COORDS(ped, true)
            local targetX = pCoords.x + camDir.x * 35.0
            local targetY = pCoords.y + camDir.y * 35.0
            local targetZ = pCoords.z + camDir.z * 35.0

            local skyZ = targetZ + 180.0
            local rocketHash = getHash("VEHICLE_WEAPON_SPACE_ROCKET")
            if rocketHash == 0 then rocketHash = getHash("WEAPON_EXPLOSION") end

            local shooterPed = (S.overwatchAnonymousKills ~= false) and 0 or ped
            MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS(
                targetX, targetY, skyZ,
                targetX, targetY, targetZ,
                10000, true, rocketHash, shooterPed, true, false, 950.0
            )
            pcall(function()
                if FIRE and FIRE.ADD_EXPLOSION then
                    FIRE.ADD_EXPLOSION(targetX, targetY, targetZ, 29, 10.0, true, false, 1.5)
                    FIRE.ADD_EXPLOSION(targetX, targetY, targetZ, 2, 5.0, true, false, 1.0)
                end
                if AUDIO and AUDIO.PLAY_SOUND_FRONTEND then
                    AUDIO.PLAY_SOUND_FRONTEND(-1, "Airhorn", "DLC_TG_Running_Back_Sounds", true)
                    AUDIO.PLAY_SOUND_FRONTEND(-1, "ScreenFlash", "WastedSounds", true)
                end
            end)
            showFeedNotification("~r~[OVERWATCH] ~w~Ataque orbital manual devastador executado!")
        end)
    end

    imgui.spacing()
    imgui.separator()
    imgui.spacing()
    imgui.text("=== DRONE KAMIKAZE TÁTICO (SUICIDA / FPV) ===")
    imgui.text("Despache um drone suicida teleguiado de alta velocidade contra outro jogador.")
    imgui.spacing()

    imgui.text("Selecione o Jogador Alvo:")
    renderPlayerTargetSelector(S.selectedKamikazePid, function(pid) S.selectedKamikazePid = pid end, "kamikaze_drone", true)
    imgui.spacing()

    if imgui.button("Lancar Drone Kamikaze no Alvo Selecionado##launch_kamikaze_single") then
        triggerKamikazeDrone(S.selectedKamikazePid)
    end
    imgui.same_line()
    if imgui.button("Lancar Enxame Kamikaze na Sessao Inteira (Caos Global)##launch_kamikaze_all") then
        triggerKamikazeAllSession()
    end
    imgui.same_line()
    if imgui.button("Abortar / Limpar Drones Kamikaze##clear_kamikaze_btn") then
        clearActiveKamikazeDrones()
        notify.info("Kamikaze", "Drones kamikaze ativos cancelados e removidos.")
    end

    imgui.end_tab_item()
end

local function renderTabEarRape()
    if not imgui.begin_tab_item("Ear Rape & Troll") then return end
    imgui.text("=== HEAVY TROLL (EAR RAPE & EARTHQUAKE) ===")
    imgui.text("Select Target (All Players or Individual):")
    renderPlayerTargetSelector(S.selectedEarRapePid, function(pid) S.selectedEarRapePid = pid end, "earrape", true)
    imgui.spacing()
    local cL, vL = imgui.checkbox("Include Lightning & Thunder##troll_lightning", S.trollLightning)
    if cL then S.trollLightning = vL end
    imgui.same_line()
    local cF, vF = imgui.checkbox("Include Psychedelic Flashbang##troll_flashbang", S.trollFlashbang)
    if cF then S.trollFlashbang = vF end
    imgui.same_line()
    local cM, vM = imgui.checkbox("Local Mute Mode (Protects your ears during attack)##troll_mute_local", S.muteEarRapeLocal)
    if cM then S.muteEarRapeLocal = vM end
    imgui.spacing()
    if imgui.button("Quick Burst (5s)##troll_5s_btn") then triggerEarRapeTremor(S.selectedEarRapePid, 5) end
    imgui.same_line()
    if imgui.button("Long Burst (10s)##troll_10s_btn") then triggerEarRapeTremor(S.selectedEarRapePid, 10) end
    imgui.same_line()
    if not S.trollAudioLoop then
        if imgui.button("START INFINITE LOOP##troll_loop_start_btn") then triggerEarRapeTremor(S.selectedEarRapePid, 0) end
    else
        if imgui.button("STOP TROLL LOOP##troll_loop_stop_btn") then stopTrollAudioHarassment() end
    end
    imgui.same_line()
    if imgui.button("Stop All Troll Effects##troll_stop_all_btn") then stopTrollAudioHarassment() end
    imgui.spacing()
    imgui.separator()
    imgui.spacing()
    imgui.text("Trolling Avancado & Ataques Remotos ao Alvo Selecionado:")
    if imgui.button("Detonar EMP Remoto no Veiculo do Alvo##emp_btn") then
        script.run_in_callback(function() triggerRemoteEmp(S.selectedEarRapePid) end)
    end
    imgui.same_line()
    if imgui.button("Space Launch (Arremessar Alvo ao Espaco)##space_launch_btn") then
        script.run_in_callback(function() triggerSpaceLaunch(S.selectedEarRapePid) end)
    end
    imgui.end_tab_item()
end

local function renderTabAirdrop()
    if not imgui.begin_tab_item("Military Airdrop") then return end
    imgui.text("=== MILITARY AIRDROP CONFIGURATION ===")
    imgui.text("Drop Location:")
    if imgui.button((S.airdropLocationMode == 1 and "[X] In Front (15m)" or "In Front (15m)") .. "##loc_front") then S.airdropLocationMode = 1; S.selectedAirdropPid = -1 end
    imgui.same_line()
    if imgui.button((S.airdropLocationMode == 2 and "[X] Target Player" or "Target Player") .. "##loc_player") then S.airdropLocationMode = 2 end

    if S.airdropLocationMode == 2 then
        imgui.spacing()
        imgui.text("Select Recipient Player:")
        renderPlayerTargetSelector(S.selectedAirdropPid, function(pid) S.selectedAirdropPid = pid end, "airdrop_target")
    end

    imgui.spacing(); imgui.separator(); imgui.spacing()
    imgui.text("Cargo Type:")
    if imgui.button((S.airdropDropType == 1 and "[X] 1. Tactical Supply (Weapons + 100% Armor)" or "1. Tactical Supply (Weapons + 100% Armor)") .. "##type_tactical") then S.airdropDropType = 1 end
    if imgui.button((S.airdropDropType == 2 and "[X] 2. Special Vehicle" or "2. Special Vehicle") .. "##type_veh") then S.airdropDropType = 2 end
    if imgui.button((S.airdropDropType == 3 and "[X] 3. Explosive Trap Crate" or "3. Explosive Trap Crate") .. "##type_trap") then S.airdropDropType = 3 end

    if S.airdropDropType == 2 then
        imgui.spacing()
        imgui.text("Select Airdrop Vehicle:")
        for _, v in ipairs(Presets.airdropVehicles) do
            local isSel = (S.airdropVehicleModel == v.model)
            if imgui.button((isSel and "[X] " or "") .. v.label .. "##veh_preset_" .. v.model) then
                S.airdropVehicleModel = v.model
                S.airdropVehicleName = v.label
            end
            imgui.same_line()
        end
        imgui.spacing()
    end

    imgui.spacing(); imgui.separator(); imgui.spacing()
    if imgui.button("Request Airdrop Now##request_airdrop_btn") then triggerAirdropDrop(S.airdropDropType, S.selectedAirdropPid, S.airdropLocationMode) end
    imgui.same_line()
    if imgui.button("Cancel / Clear Active Airdrop##cancel_airdrop_btn") then cancelActiveAirdrop(false) end
    imgui.end_tab_item()
end

local function renderTabVehicleControls()
    if not imgui.begin_tab_item("Vehicle Controls") then return end
    imgui.spacing()
    if imgui.button("Freio de Emergencia (Parada Imediata)##veh_emerg_brake") then
        script.run_in_callback(triggerEmergencyBrake)
    end
    imgui.spacing()
    imgui.separator()
    imgui.spacing()
    imgui.text("Placa Personalizada do Veiculo:")
    local cPl, vPl = imgui.input_text("Texto da Placa##cust_plate_inp", "Texto da placa...", S.customPlateText)
    if cPl then S.customPlateText = vPl end
    imgui.same_line()
    if imgui.button("Aplicar Placa##apply_plate_btn") then
        script.run_in_callback(function() applyCustomPlate(S.customPlateText, S.customPlateStyle) end)
    end
    imgui.spacing()
    imgui.text("Estilo / Fundo da Placa:")
    if imgui.button("SA Amarela/Preta##pl_style_0") then S.customPlateStyle = 0; script.run_in_callback(function() applyCustomPlate(S.customPlateText, 0) end) end
    imgui.same_line()
    if imgui.button("Azul/Branca##pl_style_1") then S.customPlateStyle = 1; script.run_in_callback(function() applyCustomPlate(S.customPlateText, 1) end) end
    imgui.same_line()
    if imgui.button("North Yankton (Neve)##pl_style_5") then S.customPlateStyle = 5; script.run_in_callback(function() applyCustomPlate(S.customPlateText, 5) end) end
    imgui.spacing()
    imgui.separator()
    imgui.spacing()
    imgui.text("Crosshair / Nearby Vehicle Actions:")
    imgui.separator()
    imgui.spacing()

    if imgui.button("Lift Vehicle (+ " .. math.floor(S.liftHeight) .. "m)##lift_btn") then
        script.run_in_callback(function()
            local veh = getTargetVehicle()
            if veh then LiftVehicle(veh, S.liftHeight); notify.success("Vehicle", "Vehicle lifted in air!")
            else notify.warn("Vehicle", "No nearby vehicle found!") end
        end)
    end
    imgui.same_line()
    if imgui.button(S.isHoldingVehicle and "Release Vehicle##hold_btn" or "Hold in Air (Telekinesis)##hold_btn") then
        HoldVehicleLoop(getTargetVehicle())
    end

    imgui.spacing()
    if imgui.button("Launch Vehicle (Throw)##launch_btn") then
        script.run_in_callback(function()
            local veh = S.isHoldingVehicle and S.heldVehicle or getTargetVehicle()
            if veh then
                S.isHoldingVehicle = false
                LaunchVehicle(veh, S.launchForce)
                notify.success("Vehicle", "Vehicle launched!")
            end
        end)
    end
    imgui.same_line()
    if imgui.button("Slam on Ground (Slam)##slam_btn") then
        script.run_in_callback(function()
            local veh = S.isHoldingVehicle and S.heldVehicle or getTargetVehicle()
            if veh then S.isHoldingVehicle = false; SlamVehicle(veh); notify.success("Vehicle", "Vehicle slammed!") end
        end)
    end

    local cSpinPlayer, vSpinPlayer = imgui.checkbox("Beyblade: Spin Player Vehicle on Ground##spin_my_veh", S.spinPlayerVehActive)
    if cSpinPlayer then S.spinPlayerVehActive = vSpinPlayer; if S.spinPlayerVehActive then startSpinPlayerVehLoop() end end

    imgui.spacing(); imgui.separator(); imgui.spacing()
    imgui.text("Lift Height (Meters):")
    if imgui.button("5m##h5") then S.liftHeight = 5.0 end
    imgui.same_line()
    if imgui.button("10m##h10") then S.liftHeight = 10.0 end
    imgui.same_line()
    if imgui.button("25m##h25") then S.liftHeight = 25.0 end
    imgui.same_line()
    if imgui.button("50m##h50") then S.liftHeight = 50.0 end

    imgui.spacing()
    imgui.text("Launch Force / Speed:")
    if imgui.button("Soft (50)##f50") then S.launchForce = 50.0 end
    imgui.same_line()
    if imgui.button("Medium (150)##f150") then S.launchForce = 150.0 end
    imgui.same_line()
    if imgui.button("Heavy (300)##f300") then S.launchForce = 300.0 end
    imgui.same_line()
    if imgui.button("SUPER LAUNCH (600)##f600") then S.launchForce = 600.0 end

    imgui.spacing(); imgui.separator(); imgui.spacing()
    imgui.text("Player Actions (Carry in Arms):")
    if imgui.button(S.isCarryingPlayer and "Release Carried Player##carry_ply_btn" or "Carry Player in Arms##carry_ply_btn") then
        startCarryingPlayer(getTargetPlayerPed())
    end
    imgui.end_tab_item()
end

local function renderTabXmlVehicles()
    if not imgui.begin_tab_item("XML Vehicles") then return end
    imgui.spacing()
    imgui.text("Spinethetic Custom XML Vehicles (Menyoo / Stand Advanced Loader):")
    imgui.separator()
    imgui.spacing()

    -- Quick Spawn Presets
    if imgui.button(">> SPAWN THE SPINE PINCHER <<##tab_pincher_btn") then
        loadAndSpawnXmlVehicle("SpinePincher.xml")
    end
    imgui.same_line()
    if imgui.button(">> SPAWN FUCKT2 BLIMP <<##tab_blimp_btn") then
        loadAndSpawnXmlVehicle("Spinethetic-FuckT2Blimp.xml")
    end
    imgui.same_line()
    if imgui.button("Limpar Veiculo##tab_clean_veh_btn") then
        cleanCustomVehicle(true)
    end
    imgui.same_line()
    if imgui.button("Descongelar / Destravar##tab_unfreeze_btn") then
        unfreezeCustomVehicle()
    end

    imgui.spacing()
    if imgui.button("Hamburger's Revenge##tab_burger_btn") then
        loadAndSpawnXmlVehicle("Spinethetic-HamburgersRevenge.xml")
    end
    imgui.same_line()
    if imgui.button("Xmas Sleigh Boat##tab_sleigh_btn") then
        loadAndSpawnXmlVehicle("Spinethetic-XmasSleighBoat.xml")
    end
    imgui.same_line()
    if imgui.button("Zombie Sabre GT##tab_zombie_btn") then
        loadAndSpawnXmlVehicle("Spinethetic-ZombieSabreGT.xml")
    end

    imgui.spacing(); imgui.separator(); imgui.spacing()
    imgui.text("Opcoes de Spawn:")
    local cWarp, vWarp = imgui.checkbox("Entrar no banco do motorista automaticamente##xml_warp_chk", S.xmlWarpInside ~= false)
    if cWarp then S.xmlWarpInside = vWarp end
    imgui.same_line()
    local cGod, vGod = imgui.checkbox("Invencivel (Godmode)##xml_god_chk", S.xmlInvincible ~= false)
    if cGod then S.xmlInvincible = vGod end
    imgui.same_line()
    local cAir, vAir = imgui.checkbox("Spawnar no Ar (+15m)##xml_air_chk", S.xmlSpawnInAir or false)
    if cAir then S.xmlSpawnInAir = vAir end

    imgui.spacing(); imgui.separator(); imgui.spacing()
    imgui.text("Arquivos XML Detectados na Pasta:")
    if imgui.button("Escanear / Atualizar Lista de XMLs##xml_scan_btn") or not S.discoveredXmlFiles or #S.discoveredXmlFiles == 0 then
        refreshDiscoveredXmlFiles()
    end

    if S.discoveredXmlFiles and #S.discoveredXmlFiles > 0 then
        for i, xmlFile in ipairs(S.discoveredXmlFiles) do
            if imgui.button("Spawn##xml_spawn_btn_" .. tostring(i)) then
                S.customXmlVehiclePath = xmlFile
                loadAndSpawnXmlVehicle(xmlFile)
            end
            imgui.same_line()
            imgui.text(xmlFile)
        end
    end

    imgui.spacing(); imgui.separator(); imgui.spacing()
    imgui.text("Arquivo XML Manual (Nome ou Caminho Completo):")
    local cPath, vPath = imgui.input_text("Arquivo XML##tab_xml_input", S.customXmlVehiclePath or "SpinePincher.xml")
    if cPath then S.customXmlVehiclePath = vPath end
    if imgui.button("Carregar & Spawnar Arquivo XML##tab_spawn_file_btn") then
        loadAndSpawnXmlVehicle(S.customXmlVehiclePath)
    end

    if S.lastXmlSpawnedName and S.lastXmlSpawnedName ~= "" then
        imgui.same_line()
        imgui.text("[OK: " .. S.lastXmlSpawnedName .. "]")
    end

    imgui.end_tab_item()
end

local function renderTabAreaChaos()
    if not imgui.begin_tab_item("Area & Session Chaos") then return end
    imgui.spacing()
    imgui.text("Mass Vehicle Chaos & World Powers:")
    imgui.separator()
    imgui.spacing()

    if imgui.button("Lift ALL Nearby Vehicles##area_lift") then
        script.run_in_callback(function()
            local count = 0
            for _, veh in ipairs(getAllNearbyVehicles(100.0)) do LiftVehicle(veh, S.liftHeight); count = count + 1 end
            notify.success("Chaos", "Lifted " .. count .. " nearby vehicles!")
        end)
    end
    imgui.same_line()
    if imgui.button("Launch ALL into the Sky##area_yeet") then
        script.run_in_callback(function()
            local count = 0
            for _, veh in ipairs(getAllNearbyVehicles(100.0)) do LaunchVehicle(veh, S.launchForce); count = count + 1 end
            notify.success("Chaos", "Launched " .. count .. " vehicles into orbit!")
        end)
    end

    imgui.spacing()
    local cSpinArea, vSpinArea = imgui.checkbox("Continuous Area Beyblade (100m)##area_spin_chk", S.spinAreaVehsActive)
    if cSpinArea then S.spinAreaVehsActive = vSpinArea; if S.spinAreaVehsActive then startSpinAreaVehsLoop() end end

    local cLev, vLev = imgui.checkbox("Continuous Area Vehicle Bounce##area_lev_chk", S.infiniteLevitateActive)
    if cLev then S.infiniteLevitateActive = vLev; if S.infiniteLevitateActive then startInfiniteLevitateLoop() end end

    local cVort, vVort = imgui.checkbox("Gravitational Vortex (Car Tornado)##vort_chk", S.vortexActive)
    if cVort then S.vortexActive = vVort; if S.vortexActive then startVortexLoop() end end

    local cUfo, vUfo = imgui.checkbox("UFO Party Mode (Lights, RGB Neon & Sirens)##ufo_chk", S.ufoDiscoActive)
    if cUfo then S.ufoDiscoActive = vUfo; if S.ufoDiscoActive then startUfoDiscoLoop() end end

    local cPush, vPush = imgui.checkbox("Vehicle Repulsor (Shockwave)##rep_chk", S.pushRepulsorActive)
    if cPush then S.pushRepulsorActive = vPush; if S.pushRepulsorActive then startPushRepulsorLoop() end end

    local cRain, vRain = imgui.checkbox("Vehicle Meteor Rain##rain_chk", S.vehicleRainActive)
    if cRain then S.vehicleRainActive = vRain; if S.vehicleRainActive then startVehicleRainLoop() end end

    local cShield, vShield = imgui.checkbox("Orbital Supercar Shield##shd_chk", S.vehicleShieldActive)
    if cShield then S.vehicleShieldActive = vShield; if S.vehicleShieldActive then startVehicleShieldLoop() end end

    imgui.spacing()
    if imgui.button("Setup Vertical Bus Bowling (10 Pins)##bus_bowl_btn") then setupBusBowling() end
    imgui.same_line()
    if imgui.button("Launch Bowling Panto (Strike!)##launch_bowl_btn") then launchBowlingPanto() end
    imgui.same_line()
    if imgui.button("Bus Fortress Wall##fort_btn") then triggerBusFortressWall() end

    imgui.spacing()
    local cSnake, vSnake = imgui.checkbox("Follow the Leader (Vehicle Snake)##follow_leader_chk", S.vehicleSnakeActive)
    if cSnake then S.vehicleSnakeActive = vSnake; if S.vehicleSnakeActive then startVehicleSnakeLoop() end end

    local cZomb, vZomb = imgui.checkbox("Aggressive Zombie Apocalypse##zomb_ped_chk", S.zombiePedOutbreakActive)
    if cZomb then S.zombiePedOutbreakActive = vZomb; if S.zombiePedOutbreakActive then startZombiePedOutbreakLoop() end end

    imgui.spacing(); imgui.separator(); imgui.spacing()
    if imgui.text_colored then
        imgui.text_colored(0.2, 0.8, 1.0, 1.0, "[ SpyreX Visual FX - Lightning Lab & HDR Storm ]")
    else
        imgui.text("[ SpyreX Visual FX - Lightning Lab & HDR Storm ]")
    end
    imgui.separator()
    imgui.spacing()

    -- Status de Script Host e Sincronizacao em Rede
    local isSh = isLocalScriptHost()
    if isSh then
        imgui.text("[OK] Script Host: ATIVO (Clima sincronizado com todos na sessao)")
    else
        imgui.text("[!] Script Host: INATIVO (Clima apenas local)")
        imgui.same_line()
        if imgui.button("Requisitar Script Host##req_sh_weather") then
            pcall(function()
                if NETWORK and NETWORK.NETWORK_REQUEST_TO_BE_HOST_OF_THIS_SCRIPT then
                    NETWORK.NETWORK_REQUEST_TO_BE_HOST_OF_THIS_SCRIPT()
                end
            end)
            if startAutoScriptHostLoop then
                S.autoClaimScriptHost = true
                startAutoScriptHostLoop()
            end
            notify.success("Host", "Requisicao de Script Host enviada para sincronizacao global!")
        end
    end

    local cNetW, vNetW = imgui.checkbox("Sincronizar Clima na Sessao via Script Host##sync_w_net", S.syncWeatherNetwork)
    if cNetW then S.syncWeatherNetwork = vNetW end
    imgui.same_line()
    local cNetL, vNetL = imgui.checkbox("Relampagos em Rede (Area / Outros Players)##sync_l_net", S.syncLightningNetwork)
    if cNetL then S.syncLightningNetwork = vNetL end

    imgui.spacing()
    if imgui.button("1. Relampago Individual (Single Flash)##fx_flash") then
        triggerSingleFlash()
    end
    imgui.same_line()
    if imgui.button("2. Rajada Estroboscopica (Strobe Storm - 4x)##fx_strobe") then
        triggerStrobeBurst(4, 90)
    end

    imgui.spacing()
    imgui.text("Modo Apocaliptico Completo (Contraste HDR Maximo):")
    if imgui.button("3. Ativar Tempestade Noturna HDR##fx_storm") then
        setupFullNightStorm()
    end
    imgui.same_line()
    if imgui.button("4. Restaurar Clima Normal##fx_restore") then
        restoreNormalWeather()
    end

    imgui.spacing(); imgui.separator(); imgui.spacing()
    imgui.text("Pre-definicoes Rapidas de Clima:")
    if imgui.button("Neve (XMAS)##w_xmas") then setSessionWeather("XMAS", false) end
    imgui.same_line()
    if imgui.button("Tempestade (THUNDER)##w_thun") then setSessionWeather("THUNDER", false) end
    imgui.same_line()
    if imgui.button("Neblina (FOGGY)##w_fog") then setSessionWeather("FOGGY", false) end
    imgui.same_line()
    if imgui.button("Ensolarado (EXTRASUNNY)##w_sun") then setSessionWeather("EXTRASUNNY", false) end
    imgui.same_line()
    if imgui.button("Chuva (RAIN)##w_rain") then setSessionWeather("RAIN", false) end

    imgui.end_tab_item()
end

local function renderTabStuntTracks()
    if not imgui.begin_tab_item("Stunt Tracks & Ramps") then return end
    imgui.spacing()
    imgui.text("Mega Track Chaos & Acrobatic Structures (Inception)")
    imgui.separator()
    imgui.spacing()

    if imgui.button("SPAWN TOTAL SUPREME CHAOS (SKY + GROUND)##gen_all_chaos_btn") then spawnTotalSupremeChaos() end
    imgui.spacing()

    if imgui.button("Cyber Arena Tube Highway (Sky)##gen_cyber_tube_btn") then spawnStuntTrack(Presets.cyber_arena_highway, "Cyber Arena Tube Highway") end
    imgui.same_line()
    if imgui.button("Arena Neon Speed Circuit (Sky)##gen_neon_speed_btn") then spawnStuntTrack(Presets.arena_neon_speed, "Arena Neon Speed Circuit") end

    if imgui.button("Mega Arena Jump & Loop (Sky)##gen_mega_jump_btn") then spawnStuntTrack(Presets.mega_arena_jump, "Mega Arena Jump & Loop") end
    imgui.same_line()
    if imgui.button("Mega Acrobatic Highway (Sky)##gen_highway_btn") then spawnStuntTrack(Presets.stunt_highway, "Mega Acrobatic Highway") end

    imgui.spacing(); imgui.separator(); imgui.spacing()
    imgui.text("Instant Frontal Ramps (In Front of Player):")
    if imgui.button("Mega Jump Ramp (Large)##ramp_l") then spawnInstantFrontRamp("stt_prop_stunt_jump_l") end
    imgui.same_line()
    if imgui.button("Medium Ramp##ramp_m") then spawnInstantFrontRamp("stt_prop_stunt_jump_m") end
    imgui.same_line()
    if imgui.button("360 Front Loop##ramp_loop") then spawnInstantFrontRamp("stt_prop_stunt_track_dloop") end
    imgui.same_line()
    if imgui.button("Speed Boost Tube##ramp_tube") then spawnInstantFrontRamp("stt_prop_stunt_tube_l") end

    imgui.spacing(); imgui.separator(); imgui.spacing()
    imgui.text("Sky Track Altitude (Z): " .. math.floor(S.stunt_altitude) .. " meters")
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
    if not imgui.begin_tab_item("Arena & Stand Props") then return end
    imgui.spacing()
    imgui.text("Individual Prop Catalog - Arena War, Yacht & Heists (Stand Export)")
    imgui.separator()
    imgui.spacing()

    imgui.text("Spawn Target:")
    renderPlayerTargetSelector(S.selectedPropSpawnPid, function(pid) S.selectedPropSpawnPid = pid end, "prop_sp_target")
    imgui.spacing()

    imgui.text("Distance: " .. string.format("%.1f m", S.customSpawnDistance) .. " | Height: " .. string.format("%.1f m", S.customSpawnHeight))
    if imgui.button("5m##sp_d5") then S.customSpawnDistance = 5.0 end
    imgui.same_line()
    if imgui.button("15m##sp_d15") then S.customSpawnDistance = 15.0 end
    imgui.same_line()
    if imgui.button("25m##sp_d25") then S.customSpawnDistance = 25.0 end
    imgui.same_line()
    if imgui.button("Ground (-1m)##sp_z_neg1") then S.customSpawnHeight = -1.0 end
    imgui.same_line()
    if imgui.button("Level (0m)##sp_z_0") then S.customSpawnHeight = 0.0 end

    imgui.spacing(); imgui.separator(); imgui.spacing()
    imgui.text("Custom Fixed Point (UFO / p_spinning_anus_s):")
    if imgui.button("SPAWN UFO AT FIXED COORDINATES##sp_fixed_ufo") then spawnFixedCoordsUfo() end

    imgui.spacing(); imgui.separator(); imgui.spacing()
    imgui.text("MAZE BANK PROJECT (4x Neon 8X Portals + UFO Core)")
    if imgui.button("SPAWN MAZE BANK PROJECT##sp_mazebank_btn") then spawnMazeBankProject() end
    imgui.same_line()
    if imgui.button("TELEPORT ALL PLAYERS TO MAZE BANK TOP##tp_all_to_mazebank_btn") then teleportAllPlayersToMazeBank() end

    imgui.spacing(); imgui.separator(); imgui.spacing()
    imgui.text("Popular Props (Spawn at Target):")
    if imgui.button("Tube 4X Speed##sp_t4xsp") then spawnSinglePropAtPlayer("ar_prop_ar_tube_4x_speed", S.customSpawnDistance, S.customSpawnHeight, S.customSpawnYaw, S.customSpawnFreeze, S.selectedPropSpawnPid) end
    imgui.same_line()
    if imgui.button("Neon Gate 8X##sp_ng8_1") then spawnSinglePropAtPlayer("ar_prop_ar_neon_gate8x_01a", S.customSpawnDistance, S.customSpawnHeight, S.customSpawnYaw, S.customSpawnFreeze, S.selectedPropSpawnPid) end
    imgui.same_line()
    if imgui.button("Speed Ring##sp_ring") then spawnSinglePropAtPlayer("ar_prop_ar_speed_ring", S.customSpawnDistance, S.customSpawnHeight, S.customSpawnYaw, S.customSpawnFreeze, S.selectedPropSpawnPid) end
    imgui.same_line()
    if imgui.button("Mega Loop##sp_loop") then spawnSinglePropAtPlayer("ar_prop_ar_jump_loop", S.customSpawnDistance, S.customSpawnHeight, S.customSpawnYaw, S.customSpawnFreeze, S.selectedPropSpawnPid) end

    imgui.spacing(); imgui.separator(); imgui.spacing()
    if imgui.button("Undo Last Spawned Prop##undo_prop_btn") then undoLastStuntObject() end
    imgui.same_line()
    if imgui.button("Clear All Spawned Props & Structures##clear_all_stunt_btn") then clearAllStuntObjects() end
    imgui.end_tab_item()
end

local function renderTabPlayerAttachments()
    if not imgui.begin_tab_item("Player Attachments") then return end
    imgui.spacing()
    imgui.text("Attach Objects, Props & Inescapable Cages to Players")
    imgui.separator()
    imgui.spacing()

    local localPid = getLocalPid()
    local currentTargetName = (S.selectedAttachmentPid == -1 or S.selectedAttachmentPid == localPid) and "YOU" or getPlayerName(S.selectedAttachmentPid)

    local isPresetAll = S.attachPresetModeAll or false
    if imgui.button((not isPresetAll and "[X] Individual (Specific Player)" or "Individual (Specific Player)") .. "##mode_indiv") then S.attachPresetModeAll = false end
    imgui.same_line()
    if imgui.button((isPresetAll and "[X] Collective (ALL in Session)" or "Collective (ALL in Session)") .. "##mode_all") then S.attachPresetModeAll = true end

    if not S.attachPresetModeAll then
        imgui.spacing()
        imgui.text("Individual Target: " .. currentTargetName)
        renderPlayerTargetSelector(S.selectedAttachmentPid, function(pid) S.selectedAttachmentPid = pid end, "att_target")
    else
        imgui.spacing()
        imgui.text("COLLECTIVE MODE ACTIVE: Objects and cages will be applied to ALL players!")
    end

    --[[
    imgui.spacing(); imgui.separator(); imgui.spacing()
    imgui.text("INESCAPABLE CAGES (STAND C++ ENGINE)")
    
    local function applyCage(cageHashOrName)
        if S.attachPresetModeAll then
            for _, pid in ipairs(getActivePlayersList()) do spawnAdvancedCageOnPlayer(pid, cageHashOrName) end
            notify.success("Cages", "Cages applied to ALL players!")
        else
            spawnAdvancedCageOnPlayer(S.selectedAttachmentPid, cageHashOrName)
        end
    end

    if imgui.button("Closed Gold Container##cage_gold") then applyCage("prop_gold_cont_01") end
    imgui.same_line()
    if imgui.button("90° Vertical Stunt Tube##cage_tube") then applyCage("stt_prop_stunt_tube_s") end
    imgui.same_line()
    if imgui.button("Crossed 90° Cages##cage_cross") then applyCage("prop_rub_cage01a") end

    if imgui.button("4 Wire Fence Box##cage_fences") then applyCage("prop_fnclink_03e") end
    imgui.same_line()
    if imgui.button("Ape Cage##cage_ape") then applyCage("v_med_apecrate") end
    imgui.same_line()
    if imgui.button("Random Inescapable Cage##cage_rand") then applyCage("random") end
    ]]

    imgui.spacing(); imgui.separator(); imgui.spacing()
    imgui.text("Attach Props to Player Body:")
    local function applyProp(modelOrHash, boneId, offX, offY, offZ, rotX, rotY, rotZ)
        if S.attachPresetModeAll then
            for _, pid in ipairs(getActivePlayersList()) do attachPropToPlayer(pid, modelOrHash, boneId, offX, offY, offZ, rotX, rotY, rotZ) end
            notify.success("Attachments", "Object attached to ALL players!")
        else
            attachPropToPlayer(S.selectedAttachmentPid, modelOrHash, boneId, offX, offY, offZ, rotX, rotY, rotZ)
        end
    end

    if imgui.button("Cone on Head##att_cone") then applyProp("prop_mp_cone_01", 24818, S.coneX, S.coneY, S.coneZ, S.coneRotX, S.coneRotY, S.coneRotZ) end
    imgui.same_line()
    if imgui.button("Toilet##att_toilet") then applyProp("prop_ld_toilet_01", 11816, 0.300, -0.150, 0.0, 176.0, 270.0, 0.0) end
    imgui.same_line()
    if imgui.button("Head Cage##att_cage") then applyProp("prop_feeder1_cr", 11816, 0.0, 0.0, -0.6, 0.0, 90.0, 0.0) end

    if imgui.button("Campfire Flame##att_fire") then applyProp("prop_beach_fire", 11816, 0.050, -0.050, 0.0, 0.0, 90.0, 0.0) end
    imgui.same_line()
    if imgui.button("Christmas Tree##att_xmas") then applyProp("prop_mp_xmas_tree_01", 11816, 0.0, 0.0, -0.5, 0.0, 90.0, 0.0) end
    imgui.same_line()
    if imgui.button("Casino Wheel##att_cwheel") then applyProp(0x8EB05D67, 24818, -0.808, -0.255, -0.120, 0.0, 270.0, 180.0) end
    imgui.same_line()
    if imgui.button("Flying Saucer UFO##att_ufo") then applyProp("p_spinning_anus_s", 11816, 0.0, 0.0, 1.5, 0.0, 90.0, 0.0) end

    imgui.spacing(); imgui.separator(); imgui.spacing()
    imgui.text("Attach Plushies Arcade (Pelúcias):")
    for i, plush in ipairs(Presets.plushie_list) do
        if (i - 1) % 3 ~= 0 then imgui.same_line() end
        if imgui.button(plush.label .. "##att_plush_" .. tostring(i)) then
            applyProp(plush.model, 24818, 0.270, 0.010, -0.150, 186.0, 88.0, -10.0)
        end
    end

    imgui.spacing(); imgui.separator(); imgui.spacing()
    imgui.text("Attach Weapon Props (Katanas on Back / Costas):")

    local function applyWeaponProp(propEntry)
        if not propEntry then return end
        local p = propEntry.PropPlacement
        applyProp(propEntry.Prop, propEntry.PropBone, p[1], p[2], p[3], p[4], p[5], p[6])
    end

    if imgui.button("Weapon Katana Left (Costas)##att_katana_left") then
        applyWeaponProp(Presets.weapon_list["Weapon Katana Left"])
    end
    imgui.same_line()
    if imgui.button("Weapon Katana Right (Costas)##att_katana_right") then
        applyWeaponProp(Presets.weapon_list["Weapon Katana Right"])
    end
    imgui.same_line()
    if imgui.button("Dual Katanas (Left + Right)##att_katana_dual") then
        attachDualKatanas(S.selectedAttachmentPid)
    end

    imgui.spacing(); imgui.separator(); imgui.spacing()
    if not S.attachPresetModeAll then
        if imgui.button("Remove Objects from " .. currentTargetName .. "##rem_sel_props") then removePlayerAttachedProps(S.selectedAttachmentPid) end
        imgui.same_line()
    end
    if imgui.button("Remove from ALL Players##rem_all_props") then removeAllAttachedProps() end
    imgui.end_tab_item()
end

local function renderTabOptionsAndHotkeys()
    if not imgui.begin_tab_item("Options & Hotkeys") then return end
    imgui.spacing()
    imgui.text("Settings & Behavior:")
    imgui.separator()
    imgui.spacing()

    local c2, v2 = imgui.checkbox("Make Vehicles Invincible during Telekinesis##inv_chk", S.makeInvincible)
    if c2 then S.makeInvincible = v2 end

    local c4, v4 = imgui.checkbox("Disable Player Ragdoll (No falling)##rag_chk", S.disableRagdoll)
    if c4 then S.disableRagdoll = v4; updateRagdollState(); notify.info("Options", S.disableRagdoll and "Ragdoll DISABLED" or "Ragdoll ENABLED") end

    imgui.spacing(); imgui.separator(); imgui.spacing()
    local c3, v3 = imgui.checkbox("Enable Telekinesis Hotkeys (SPACE = Launch | E = Grab/Hold)##hk_chk", S.hotkeysEnabled)
    if c3 then S.hotkeysEnabled = v3; if S.hotkeysEnabled then startHotkeyLoop() end end

    imgui.spacing(); imgui.separator(); imgui.spacing()
    imgui.text("Gerenciador de Sessao & Host:")
    imgui.separator()
    imgui.spacing()

    local localPid = getLocalPid()
    local sHostPid = -1
    local scHostPid = -1
    pcall(function()
        if NETWORK then
            if NETWORK.NETWORK_GET_HOST_PLAYER_INDEX then sHostPid = NETWORK.NETWORK_GET_HOST_PLAYER_INDEX() end
            if NETWORK.NETWORK_GET_HOST_OF_SCRIPT then scHostPid = NETWORK.NETWORK_GET_HOST_OF_SCRIPT("freemode") end
        end
    end)

    local isSessionHost = (localPid == sHostPid and sHostPid ~= -1)
    local isScriptHost = (localPid == scHostPid and scHostPid ~= -1)

    local sHostName = (sHostPid ~= -1 and sHostPid ~= nil) and (getPlayerName(sHostPid) .. " [" .. tostring(sHostPid) .. "]") or "Desconhecido"
    local scHostName = (scHostPid ~= -1 and scHostPid ~= nil) and (getPlayerName(scHostPid) .. " [" .. tostring(scHostPid) .. "]") or "Desconhecido"

    imgui.text("Session Host: " .. sHostName .. (isSessionHost and " (VOCE)" or ""))
    imgui.text("Script Host (Freemode): " .. scHostName .. (isScriptHost and " (VOCE)" or ""))

    if isSessionHost and isScriptHost then
        imgui.text("[OK] Status: AUTORIDADE TOTAL (Session + Script Host nesta sala)")
    elseif isSessionHost then
        imgui.text("[OK] Status: Session Host Ativo (Imunidade a Kicks / Dono da sala)")
    elseif isScriptHost then
        imgui.text("[OK] Status: Script Host Ativo (Controle total de Trafego e NPCs)")
    else
        imgui.text("[i] Status: Jogador Padrao (Sem privilegios de Host nesta sala)")
    end

    imgui.spacing()
    local cAsh, vAsh = imgui.checkbox("Forcar / Manter Script Host Ativo##auto_req_sh", S.autoClaimScriptHost or false)
    if cAsh then
        S.autoClaimScriptHost = vAsh
        if S.autoClaimScriptHost then
            pcall(function()
                if NETWORK and NETWORK.NETWORK_REQUEST_TO_BE_HOST_OF_THIS_SCRIPT then
                    NETWORK.NETWORK_REQUEST_TO_BE_HOST_OF_THIS_SCRIPT()
                end
            end)
            startAutoScriptHostLoop()
            notify.success("Host", "Requisicao enviada e monitor de Script Host ATIVADO!")
        else
            notify.info("Host", "Monitor de Script Host PAUSADO.")
        end
    end

    imgui.spacing(); imgui.separator(); imgui.spacing()
    imgui.text("Seguranca & Detector de Reportes / Vote Kick:")
    imgui.separator()
    imgui.spacing()

    local cW, vW = imgui.checkbox("Ativar Vigilante de Seguranca (Auto-Detectar Kick & Report)##wd_chk", S.watchdogActive)
    if cW then
        S.watchdogActive = vW
        if S.watchdogActive then
            startSecurityWatchdogLoop()
            notify.info("Seguranca", "Vigilante de Seguranca ATIVADO")
        else
            notify.warn("Seguranca", "Vigilante de Seguranca PAUSADO")
        end
    end

    imgui.spacing()
    if S.watchdogKickVoteDetected then
        if imgui.text_colored then
            imgui.text_colored(1.0, 0.2, 0.2, 1.0, "[!] ALERTA CRITICO: Voto de Expulsao (Vote Kick) ATIVO contra voce!")
        else
            imgui.text("[!] ALERTA CRITICO: Voto de Expulsao (Vote Kick) ATIVO contra voce!")
        end
    else
        if imgui.text_colored then
            imgui.text_colored(0.2, 1.0, 0.2, 1.0, "[OK] Status de Expulsao: Seguro (Nenhum voto de kick detectado)")
        else
            imgui.text("[OK] Status de Expulsao: Seguro (Nenhum voto de kick detectado)")
        end
    end

    imgui.spacing()
    imgui.text("Metricas de Reportes da Conta (Perfil Rockstar):")
    for _, item in ipairs(reportTrackedStats) do
        local count = S.watchdogReportStats[item.key] or 0
        imgui.text(string.format(" - %s: %d", item.label, count))
    end

    imgui.spacing()
    if imgui.button("Recarregar / Calibrar Metricas da Conta##wd_refresh") then
        refreshReportBaseline()
        notify.info("Seguranca", "Metricas de reportes atualizadas com sucesso!")
    end

    if #S.watchdogRecentAlerts > 0 then
        imgui.spacing()
        imgui.separator()
        imgui.text("Ultimos Alertas Registrados:")
        local maxShow = math.min(#S.watchdogRecentAlerts, 5)
        for i = 1, maxShow do
            local al = S.watchdogRecentAlerts[i]
            imgui.text(string.format("[%s] %s", al.time or "--:--", al.text or ""))
        end
    end

    imgui.end_tab_item()
end

------------------------------------------------------------
-- IMGUI ROOT GUI
------------------------------------------------------------

local function renderGUI()
    if not imgui.begin_tab_bar("SpyreX_Main_Tabs") then return end
    renderTabJets()
    renderTabOverwatchDrone()
    renderTabEarRape()
    renderTabAirdrop()
    renderTabVehicleControls()
    renderTabXmlVehicles()
    renderTabAreaChaos()
    renderTabKungFuMaster()
    renderTabStuntTracks()
    renderTabArenaObjectSpawner()
    renderTabPlayerAttachments()
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

if event and event.register_handler and menu_event and menu_event.Unload then
    event.register_handler(menu_event.Unload, function()
        pcall(function()
            cleanCustomVehicle(false)
            deleteOverwatchDrone()
            clearActiveKamikazeDrones()
            removeTunerAttachment()
            if GRAPHICS and GRAPHICS.ANIMPOSTFX_STOP_ALL then
                GRAPHICS.ANIMPOSTFX_STOP_ALL()
            end
        end)
    end)
end

------------------------------------------------------------
-- INICIALIZACAO & MENSAGEM NA TELA COM CORES GRADIENTES
------------------------------------------------------------

local NyxColorThemes = {
    cyberpunk = {
        title = "~p~N~q~y~b~x",
        subtitle = "~w~A ~b~NewWay ~s~Script",
        shardCol = 0
    },
    rainbow = {
        title = "~r~N~y~y~g~x",
        subtitle = "~w~A ~b~NewWay ~s~Script",
        shardCol = 0
    },
    electric_blue = {
        title = "~b~N~c~y~p~x",
        subtitle = "~w~A ~b~NewWay ~s~Script",
        shardCol = 0
    },
    sunset_fire = {
        title = "~y~N~o~y~r~x",
        subtitle = "~w~A ~b~NewWay ~s~Script",
        shardCol = 0
    },
    matrix_green = {
        title = "~g~N~g~y~w~x",
        subtitle = "~w~A ~b~NewWay ~s~Script",
        shardCol = 0
    },
    gold_luxury = {
        title = "~HUD_COLOUR_GOLD~N~y~y~w~x",
        subtitle = "~w~A ~b~NewWay ~s~Script",
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
        subtitleFormatted = subtitle or "~w~A ~b~NewWay ~s~Script"
    else
        theme = NyxColorThemes.cyberpunk
        titleFormatted = theme.title
        subtitleFormatted = theme.subtitle
    end

    durationMs = durationMs or 4000

    -- 1. Notificacao NewWay UI Toast
    notify.info("Nyx", "A NewWay Script")

    -- 2. GTA V Feed Post Notification (Acima do mini-mapa)
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

    -- 3. Legenda na HUD do GTA (Inferior central)
    pcall(function()
        if HUD and HUD.BEGIN_TEXT_COMMAND_PRINT then
            HUD.BEGIN_TEXT_COMMAND_PRINT("STRING")
            HUD.ADD_TEXT_COMPONENT_SUBSTRING_PLAYER_NAME(tostring(titleFormatted) .. " ~s~- " .. tostring(subtitleFormatted))
            HUD.END_TEXT_COMMAND_PRINT(durationMs, true)
        end
    end)

    -- 4. Shard Banner Gigante no Centro da Tela (Scaleform MP_BIG_MESSAGE_FREEMODE)
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

    -- 5. Limpeza de Efeitos Antigos & Disparo de Efeito Psicodélico Temporário
    pcall(function()
        if GRAPHICS and GRAPHICS.ANIMPOSTFX_STOP_ALL then
            GRAPHICS.ANIMPOSTFX_STOP_ALL()
        end
    end)

    -- Som Marcante & Impactante (Sub-bass cinematográfico + Fanfarra Synth de Conquista)
    pcall(function()
        if AUDIO and AUDIO.PLAY_SOUND_FRONTEND then
            AUDIO.PLAY_SOUND_FRONTEND(-1, "ScreenFlash", "WastedSounds", true)
            AUDIO.PLAY_SOUND_FRONTEND(-1, "BASE_JUMP_PASSED", "HUD_AWARDS", true)
        end
    end)

    -- Efeito Psicodélico Suave Neon (Sem clarão branco/brilho excessivo)
    if script and script.run_in_callback then
        script.run_in_callback(function()
            pcall(function()
                local fxName = "InchPurple"
                if GRAPHICS and GRAPHICS.ANIMPOSTFX_PLAY then
                    GRAPHICS.ANIMPOSTFX_PLAY(fxName, 1400, false)
                end
                script.yield(1400)
                if GRAPHICS and GRAPHICS.ANIMPOSTFX_STOP then
                    GRAPHICS.ANIMPOSTFX_STOP(fxName)
                end
                if GRAPHICS and GRAPHICS.ANIMPOSTFX_STOP_ALL then
                    GRAPHICS.ANIMPOSTFX_STOP_ALL()
                end
            end)
        end)
    end
end

showNyxWelcomeMessage("cyberpunk", nil, 4000)

if log and log.info then
    log.info("SpyreX.lua loaded successfully! Enjoy.")
end
