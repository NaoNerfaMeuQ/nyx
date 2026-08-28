--[[
    Nyx.lua
    Versão: 2.0.0 - Advanced Hub

    MENU:
      F9        = abrir / fechar
      ↑ / ↓     = navegar
      ← / →     = alterar valores
      Enter     = selecionar
      Backspace = voltar

    MODS:
      Y = Agachar / levantar
      H = Mãos para cima / abaixar
]]

------------------------------------------------------------
-- NATIVES
------------------------------------------------------------

pcall(function()

    if natives
        and natives.load_natives
    then

        natives.load_natives()

    end

end)

------------------------------------------------------------
-- CONFIG
------------------------------------------------------------

local MENU_NAME = "Nyx"
local MENU_VERSION = "2.0.0"

local UI = {

    x = 0.035,
    y = 0.125,

    width = 0.225,

    headerHeight = 0.070,
    titleHeight = 0.032,
    rowHeight = 0.032,
    footerHeight = 0.030,

    textX = 0.048,

    purpleR = 125,
    purpleG = 45,
    purpleB = 190,

    backgroundAlpha = 215,

    maxVisibleRows = 12

}

------------------------------------------------------------
-- CONTROLES
------------------------------------------------------------

local CONTROLS = {
    F9 = 56,
    UP = 172,
    DOWN = 173,
    LEFT = 174,
    RIGHT = 175,
    ACCEPT = 176,
    CANCEL = 177,
    FRONTEND_ACCEPT = 201,
    FRONTEND_CANCEL = 202,
    HANDS_UP = 74,
    CROUCH = 246
}

------------------------------------------------------------
-- MENU
------------------------------------------------------------

local menu = {

    open = false,

    selected = 1,

    stack = {},

    title = MENU_NAME,

    id = "main",

    items = {}

}

------------------------------------------------------------
-- PLAYER HELPERS
------------------------------------------------------------

local function getLocalPed()

    local ped = 0

    pcall(function()

        if PLAYER
            and PLAYER.PLAYER_PED_ID
        then

            ped =
                PLAYER.PLAYER_PED_ID()

        end

    end)

    return ped or 0

end

local function getLocalPid()

    local pid = 0

    pcall(function()

        if PLAYER
            and PLAYER.PLAYER_ID
        then

            pid =
                PLAYER.PLAYER_ID()

        end

    end)

    return pid or 0

end

local function isValidEntity(ent)

    if not ent
        or ent == 0
    then

        return false

    end

    local valid = false

    pcall(function()

        valid =
            ENTITY.DOES_ENTITY_EXIST(
                ent
            )

    end)

    return valid

end

local function isValidPed(ped)

    return isValidEntity(ped)

end

local function isPedInVehicle(ped)

    local result = false

    if not isValidEntity(ped) then
        return false
    end

    pcall(function()

        result =
            PED.IS_PED_IN_ANY_VEHICLE(
                ped,
                false
            )

    end)

    return result

end

local function getPlayerPed(pid)

    local ped = 0

    pcall(function()

        if PLAYER.GET_PLAYER_PED_SCRIPT_INDEX then

            ped =
                PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(
                    pid
                )

        elseif PLAYER.GET_PLAYER_PED then

            ped =
                PLAYER.GET_PLAYER_PED(
                    pid
                )

        end

    end)

    return ped or 0

end

local function getPlayerName(pid)

    local name = nil

    pcall(function()

        if PLAYER
            and PLAYER.GET_PLAYER_NAME
        then

            local n =
                PLAYER.GET_PLAYER_NAME(
                    pid
                )

            if n
                and n ~= ""
                and n ~= "**Invalid**"
            then

                name = n

            end

        end

        if not name
            and players
            and players.get_name
        then

            name =
                players.get_name(
                    pid
                )

        end

    end)

    return name
        or
        (
            "Player_"
            ..
            tostring(pid)
        )

end

local function isPlayerActive(pid)

    local active = false

    pcall(function()

        if NETWORK
            and NETWORK.NETWORK_IS_PLAYER_ACTIVE
        then

            active =
                NETWORK.NETWORK_IS_PLAYER_ACTIVE(
                    pid
                )

        elseif PLAYER
            and PLAYER.GET_PLAYER_NAME
        then

            local n =
                PLAYER.GET_PLAYER_NAME(
                    pid
                )

            active =
                n ~= nil
                and n ~= ""
                and n ~= "**Invalid**"

        end

    end)

    return active

end

------------------------------------------------------------
-- GAME TIMER
------------------------------------------------------------

local function gameTimer()

    local value = 0

    pcall(function()

        if MISC
            and MISC.GET_GAME_TIMER
        then

            value =
                MISC.GET_GAME_TIMER()

        end

    end)

    return tonumber(value) or 0

end

------------------------------------------------------------
-- HASH
------------------------------------------------------------

local function getHash(name)

    local hash = 0

    pcall(function()

        if MISC
            and MISC.GET_HASH_KEY
        then

            hash =
                MISC.GET_HASH_KEY(
                    name
                )

        end

    end)

    return hash or 0

end

------------------------------------------------------------
-- NOTIFICAÇÕES
------------------------------------------------------------

local startupStep = 0

local function showFeedNotification(text)

    if not HUD then
        return false
    end

    local success = false

    pcall(function()

        HUD.BEGIN_TEXT_COMMAND_THEFEED_POST(
            "STRING"
        )

        HUD.ADD_TEXT_COMPONENT_SUBSTRING_PLAYER_NAME(
            tostring(text)
        )

        HUD.END_TEXT_COMMAND_THEFEED_POST_TICKER(
            false,
            false
        )

        success = true

    end)

    return success

end

local function handleStartupNotifications()

    if startupStep == 0 then

        pcall(function()
            if AUDIO and AUDIO.PLAY_SOUND_FRONTEND then
                AUDIO.PLAY_SOUND_FRONTEND(-1, "CHECKPOINT_PERFECT", "HUD_MINI_GAME_SOUNDSET", true)
            end
            if GRAPHICS and GRAPHICS.ANIMPOSTFX_PLAY then
                GRAPHICS.ANIMPOSTFX_PLAY("CamPushInNeutral", 800, false)
            end
        end)

        showFeedNotification(
            "~r~Nyx Hub~s~ by ~g~@euangelzzk & Marcos~s~"
        )

        startupStep = 1

        return

    end

    if startupStep == 1 then

        showFeedNotification(
            "Click ~y~F9~s~ to open menu"
        )

        startupStep = 2

    end

end

------------------------------------------------------------
-- DRAW
------------------------------------------------------------

local function drawRect(
    x,
    y,
    width,
    height,
    r,
    g,
    b,
    a
)

    pcall(function()

        GRAPHICS.DRAW_RECT(

            x,
            y,

            width,
            height,

            r,
            g,
            b,
            a,

            false

        )

    end)

end

local function drawText(
    text,
    x,
    y,
    scale,
    r,
    g,
    b,
    a,
    centered
)

    pcall(function()

        HUD.SET_TEXT_FONT(
            0
        )

        HUD.SET_TEXT_SCALE(
            0.0,
            scale
        )

        HUD.SET_TEXT_PROPORTIONAL(
            true
        )

        HUD.SET_TEXT_COLOUR(

            r or 255,
            g or 255,
            b or 255,
            a or 255

        )

        HUD.SET_TEXT_CENTRE(
            centered == true
        )

        HUD.BEGIN_TEXT_COMMAND_DISPLAY_TEXT(
            "STRING"
        )

        HUD.ADD_TEXT_COMPONENT_SUBSTRING_PLAYER_NAME(
            tostring(text)
        )

        HUD.END_TEXT_COMMAND_DISPLAY_TEXT(
            x,
            y,
            0
        )

    end)

end

------------------------------------------------------------
-- INPUT
------------------------------------------------------------

local function pressed(control)

    local result = false

    pcall(function()

        if PAD.IS_DISABLED_CONTROL_JUST_PRESSED(
            0,
            control
        )
        then

            result = true
            return

        end

        if PAD.IS_CONTROL_JUST_PRESSED(
            0,
            control
        )
        then

            result = true

        end

    end)

    return result

end

local function disableControl(control)

    pcall(function()

        PAD.DISABLE_CONTROL_ACTION(
            0,
            control,
            true
        )

    end)

end

------------------------------------------------------------
-- ANIMATION SYSTEM
------------------------------------------------------------

local pendingAnimation = nil

local function clearLocalTasks()

    local ped =
        getLocalPed()

    if not isValidEntity(ped) then
        return
    end

    pcall(function()

        TASK.CLEAR_PED_TASKS(
            ped
        )

    end)

end

local function stopAnimation()

    pendingAnimation = nil

    clearLocalTasks()

end

local function playAnimation(data)

    local ped =
        getLocalPed()

    if not isValidEntity(ped) then
        return
    end

    if data.stop then

        stopAnimation()
        return

    end

    if data.scenario then

        pendingAnimation = nil

        pcall(function()

            TASK.CLEAR_PED_TASKS(
                ped
            )

            TASK.TASK_START_SCENARIO_IN_PLACE(

                ped,

                data.scenario,

                0,

                true

            )

        end)

        return

    end

    if data.dict
        and data.anim
    then

        pendingAnimation = {

            ped = ped,

            data = data,

            requested = false

        }

    end

end

local function processPendingAnimation()

    if not pendingAnimation then
        return
    end

    local data =
        pendingAnimation.data

    if not pendingAnimation.requested then

        pcall(function()

            STREAMING.REQUEST_ANIM_DICT(
                data.dict
            )

        end)

        pendingAnimation.requested = true

        return

    end

    local loaded = false

    pcall(function()

        loaded =
            STREAMING.HAS_ANIM_DICT_LOADED(
                data.dict
            )

    end)

    if not loaded then

        pcall(function()

            STREAMING.REQUEST_ANIM_DICT(
                data.dict
            )

        end)

        return

    end

    pcall(function()

        TASK.CLEAR_PED_TASKS(
            pendingAnimation.ped
        )

        TASK.TASK_PLAY_ANIM(

            pendingAnimation.ped,

            data.dict,
            data.anim,

            8.0,
            -8.0,

            data.duration or -1,

            data.flags or 49,

            0.0,

            false,
            false,
            false

        )

    end)

    pendingAnimation = nil

end

------------------------------------------------------------
-- ANIMAÇÕES
------------------------------------------------------------

local AnimLists = {}

AnimLists.police = {

    {
        name = "Rádio policial",
        dict = "random@arrests",
        anim = "generic_radio_chatter",
        flags = 49
    },

    {
        name = "Rádio policial - entrar",
        dict = "random@arrests",
        anim = "generic_radio_enter",
        flags = 49
    },

    {
        name = "Mãos para cima",
        dict = "random@arrests",
        anim = "idle_2_hands_up",
        flags = 49
    },

    {
        name = "Investigar",
        dict =
            "amb@code_human_police_investigate@idle_b",
        anim = "idle_f",
        flags = 49
    },

    {
        name = "Postura policial",
        scenario =
            "WORLD_HUMAN_COP_IDLES"
    },

    {
        name = "Posição de guarda",
        scenario =
            "WORLD_HUMAN_GUARD_STAND"
    },

    {
        name = "Controlar trânsito",
        scenario =
            "WORLD_HUMAN_CAR_PARK_ATTENDANT"
    },

    {
        name = "Binóculos",
        scenario =
            "WORLD_HUMAN_BINOCULARS"
    },

    {
        name = "Prancheta",
        scenario =
            "WORLD_HUMAN_CLIPBOARD"
    }

}

AnimLists.social = {

    {
        name = "Acenar",
        dict =
            "friends@frj@ig_1",
        anim =
            "wave_a",
        flags = 49
    },

    {
        name = "Cruzar braços",
        dict =
            "amb@world_human_hang_out_street@female_arms_crossed@base",
        anim =
            "base",
        flags = 49
    },

    {
        name = "Comemorar",
        scenario =
            "WORLD_HUMAN_CHEERING"
    },

    {
        name = "Encostar",
        scenario =
            "WORLD_HUMAN_LEANING"
    },

    {
        name = "Esperar",
        scenario =
            "WORLD_HUMAN_STAND_IMPATIENT"
    },

    {
        name = "Conversando",
        scenario =
            "WORLD_HUMAN_HANG_OUT_STREET"
    },

    {
        name = "Olhar mapa",
        scenario =
            "WORLD_HUMAN_TOURIST_MAP"
    }

}

AnimLists.gesture = {

    {
        name = "Continência",
        dict =
            "anim@mp_player_intincarsalutestd@ds@",
        anim =
            "idle_a",
        flags = 49
    },

    {
        name = "Positivo",
        dict =
            "anim@mp_player_intincarthumbs_upbodhi@ds@",
        anim =
            "idle_a",
        flags = 49
    },

    {
        name = "Facepalm",
        dict =
            "anim@mp_player_intcelebrationmale@face_palm",
        anim =
            "face_palm",
        flags = 49
    },

    {
        name = "Calma",
        dict =
            "gestures@m@standing@casual",
        anim =
            "gesture_easy_now",
        flags = 49
    },

    {
        name = "Apontar para mim",
        dict =
            "gestures@m@standing@casual",
        anim =
            "gesture_me",
        flags = 49
    },

    {
        name = "Não",
        dict =
            "gestures@m@standing@casual",
        anim =
            "gesture_no_way",
        flags = 49
    },

    {
        name = "Explicar",
        dict =
            "gestures@m@standing@casual",
        anim =
            "gesture_hand_down",
        flags = 49
    }

}

AnimLists.work = {

    {
        name = "Prancheta",
        scenario =
            "WORLD_HUMAN_CLIPBOARD"
    },

    {
        name = "Fotógrafo",
        scenario =
            "WORLD_HUMAN_PAPARAZZI"
    },

    {
        name = "Segurança",
        scenario =
            "WORLD_HUMAN_GUARD_STAND"
    },

    {
        name = "Mecânico",
        dict =
            "mini@repair",
        anim =
            "fixing_a_ped",
        flags = 49
    },

    {
        name = "Jardineiro",
        scenario =
            "WORLD_HUMAN_GARDENER_PLANT"
    },

    {
        name = "Paramédico",
        scenario =
            "CODE_HUMAN_MEDIC_KNEEL"
    },

    {
        name = "Faxineiro",
        scenario =
            "WORLD_HUMAN_JANITOR"
    }

}

AnimLists.relaxing = {

    {
        name = "Café",
        scenario =
            "WORLD_HUMAN_AA_COFFEE"
    },

    {
        name = "Sentar no chão",
        scenario =
            "WORLD_HUMAN_PICNIC"
    },

    {
        name = "Encostar",
        scenario =
            "WORLD_HUMAN_LEANING"
    },

    {
        name = "Curtir música",
        scenario =
            "WORLD_HUMAN_MUSICIAN"
    },

    {
        name = "Observar",
        scenario =
            "WORLD_HUMAN_STAND_IMPATIENT"
    }

}

AnimLists.sitting = {

    {
        name = "Sentar",
        scenario =
            "WORLD_HUMAN_PICNIC"
    },

    {
        name = "Sentar em degrau",
        scenario =
            "WORLD_HUMAN_SEAT_STEPS"
    },

    {
        name = "Sentar em mureta",
        scenario =
            "WORLD_HUMAN_SEAT_LEDGE"
    },

    {
        name = "Relaxar de costas",
        scenario =
            "WORLD_HUMAN_SUNBATHE_BACK"
    },

    {
        name = "Relaxar de frente",
        scenario =
            "WORLD_HUMAN_SUNBATHE"
    }

}

AnimLists.dance = {

    {
        name = "Dança 1",
        dict =
            "anim@amb@nightclub@mini@dance@dance_solo@male@var_b@",
        anim =
            "high_center",
        flags = 49
    },

    {
        name = "Dança 2",
        dict =
            "anim@amb@nightclub@mini@dance@dance_solo@female@var_a@",
        anim =
            "high_center",
        flags = 49
    },

    {
        name = "Dança leve",
        dict =
            "anim@amb@nightclub@mini@dance@dance_solo@male@var_a@",
        anim =
            "low_center",
        flags = 49
    },

    {
        name = "Dança clube",
        dict =
            "anim@amb@nightclub@mini@dance@dance_solo@female@var_b@",
        anim =
            "med_center",
        flags = 49
    }

}

AnimLists.phone = {

    {
        name = "Usar celular",
        scenario =
            "WORLD_HUMAN_STAND_MOBILE"
    },

    {
        name = "Ligação",
        dict =
            "cellphone@",
        anim =
            "cellphone_call_listen_base",
        flags = 49
    },

    {
        name = "Ler celular",
        dict =
            "cellphone@",
        anim =
            "cellphone_text_read_base",
        flags = 49
    }

}

AnimLists.exercise = {

    {
        name = "Yoga",
        scenario =
            "WORLD_HUMAN_YOGA"
    },

    {
        name = "Alongar",
        scenario =
            "WORLD_HUMAN_MUSCLE_FLEX"
    },

    {
        name = "Flexões",
        scenario =
            "WORLD_HUMAN_PUSH_UPS"
    },

    {
        name = "Abdominais",
        scenario =
            "WORLD_HUMAN_SIT_UPS"
    }

}

------------------------------------------------------------
-- MOVIMENTO
------------------------------------------------------------

local movements = {

    {
        name = "Normal",
        reset = true
    },

    {
        name = "Lester",
        clip =
            "move_heist_lester"
    },

    {
        name = "Lester com bengala",
        clip =
            "move_lester_CaneUp"
    },

    {
        name = "Ferido",
        clip =
            "move_injured_generic"
    },

    {
        name = "Corajoso",
        clip =
            "move_m@brave"
    },

    {
        name = "Casual",
        clip =
            "move_m@casual@d"
    },

    {
        name = "Cambaleando 1",
        clip =
            "MOVE_M@DRUNK@SLIGHTLYDRUNK"
    },

    {
        name = "Cambaleando 2",
        clip =
            "MOVE_M@DRUNK@MODERATEDRUNK"
    },

    {
        name = "Cambaleando 3",
        clip =
            "MOVE_M@DRUNK@VERYDRUNK"
    },

    {
        name = "Gangster",
        clip =
            "MOVE_M@GANGSTER@NG"
    },

    {
        name = "Elegante",
        clip =
            "MOVE_M@POSH@"
    },

    {
        name = "Durão",
        clip =
            "MOVE_M@TOUGH_GUY@"
    },

    {
        name = "Agachado",
        clip =
            "move_ped_crouched"
    }

}

local pendingMovement = nil

local function resetMovement()

    pendingMovement = nil

    local ped =
        getLocalPed()

    if not isValidEntity(ped) then
        return
    end

    pcall(function()

        PED.RESET_PED_MOVEMENT_CLIPSET(
            ped,
            0.25
        )

    end)

    pcall(function()

        if PED.RESET_PED_STRAFE_CLIPSET then

            PED.RESET_PED_STRAFE_CLIPSET(
                ped
            )

        end

    end)

end

local function applyMovement(data)

    local ped =
        getLocalPed()

    if not isValidEntity(ped) then
        return
    end

    if data.reset then

        resetMovement()

        return

    end

    pendingMovement = {

        ped = ped,

        clip = data.clip,

        requested = false

    }

end

local function processPendingMovement()

    if not pendingMovement then
        return
    end

    if not pendingMovement.requested then

        pcall(function()

            STREAMING.REQUEST_ANIM_SET(
                pendingMovement.clip
            )

        end)

        pendingMovement.requested = true

        return

    end

    local loaded = false

    pcall(function()

        loaded =
            STREAMING.HAS_ANIM_SET_LOADED(
                pendingMovement.clip
            )

    end)

    if not loaded then
        return
    end

    pcall(function()

        PED.SET_PED_MOVEMENT_CLIPSET(

            pendingMovement.ped,

            pendingMovement.clip,

            0.25

        )

    end)

    pendingMovement = nil

end

------------------------------------------------------------
-- MOD STATE
------------------------------------------------------------

local Hotkeys = {
    crouchEnabled = false,
    crouched = false,
    handsUpEnabled = false,
    handsUp = false
}

------------------------------------------------------------
-- AGACHAR
------------------------------------------------------------

local function setCrouchedState(state)

    Hotkeys.crouched =
        state == true

    if Hotkeys.crouched then

        applyMovement({

            clip =
                "move_ped_crouched"

        })

    else

        resetMovement()

    end

end

local function toggleCrouchedState()

    setCrouchedState(
        not Hotkeys.crouched
    )

end

local function toggleCrouchHotkey()

    Hotkeys.crouchEnabled =
        not Hotkeys.crouchEnabled

    if not Hotkeys.crouchEnabled
        and Hotkeys.crouched
    then

        setCrouchedState(
            false
        )

    end

    showFeedNotification(

        Hotkeys.crouchEnabled

        and
        "~g~Agachar por Y: ON"

        or
        "~r~Agachar por Y: OFF"

    )

end

------------------------------------------------------------
-- MÃOS PRA CIMA
------------------------------------------------------------

local HANDS_UP_DICT =
    "random@arrests"

local HANDS_UP_ANIM =
    "idle_2_hands_up"

local function stopHandsUpAnimation()

    local ped =
        getLocalPed()

    if not isValidEntity(ped) then
        return
    end

    pcall(function()

        TASK.STOP_ANIM_TASK(

            ped,

            HANDS_UP_DICT,

            HANDS_UP_ANIM,

            2.0

        )

    end)

end

local function lowerHands()

    Hotkeys.handsUp = false

    stopHandsUpAnimation()

end

local function raiseHands()

    local ped =
        getLocalPed()

    if not isValidEntity(ped)
        or isPedInVehicle(ped)
    then

        return

    end

    Hotkeys.handsUp = true

end

local function toggleHands()

    if Hotkeys.handsUp then

        lowerHands()

    else

        raiseHands()

    end

end

local function toggleHandsHotkey()

    Hotkeys.handsUpEnabled =
        not Hotkeys.handsUpEnabled

    if not Hotkeys.handsUpEnabled then

        lowerHands()

    end

    showFeedNotification(

        Hotkeys.handsUpEnabled

        and
        "~g~Mãos para cima por H: ON"

        or
        "~r~Mãos para cima por H: OFF"

    )

end

local function disableHandsUpCombat()

    disableControl(24)
    disableControl(257)

    disableControl(25)

    disableControl(45)

    disableControl(140)
    disableControl(141)
    disableControl(142)
    disableControl(143)

    disableControl(263)
    disableControl(264)

    pcall(function()

        if PLAYER
            and PLAYER.DISABLE_PLAYER_FIRING
        then

            PLAYER.DISABLE_PLAYER_FIRING(
                getLocalPid(),
                true
            )

        end

    end)

end

local function processHandsUp()

    if not Hotkeys.handsUp then
        return
    end

    local ped =
        getLocalPed()

    if not isValidEntity(ped) then
        return
    end

    if isPedInVehicle(ped) then

        lowerHands()
        return

    end

    local loaded = false

    pcall(function()

        loaded =
            STREAMING.HAS_ANIM_DICT_LOADED(
                HANDS_UP_DICT
            )

    end)

    if not loaded then

        pcall(function()

            STREAMING.REQUEST_ANIM_DICT(
                HANDS_UP_DICT
            )

        end)

        disableHandsUpCombat()

        return

    end

    local playing = false

    pcall(function()

        playing =
            ENTITY.IS_ENTITY_PLAYING_ANIM(

                ped,

                HANDS_UP_DICT,

                HANDS_UP_ANIM,

                3

            )

    end)

    if not playing then

        pcall(function()

            TASK.TASK_PLAY_ANIM(

                ped,

                HANDS_UP_DICT,

                HANDS_UP_ANIM,

                8.0,
                -8.0,

                -1,

                49,

                0.0,

                false,
                false,
                false

            )

        end)

    end

    disableHandsUpCombat()

end

------------------------------------------------------------
-- DESMAIAR
------------------------------------------------------------

local function faintPlayer()

    local ped =
        getLocalPed()

    if not isValidEntity(ped)
        or isPedInVehicle(ped)
    then

        return

    end

    if Hotkeys.handsUp then

        lowerHands()

    end

    pendingAnimation = nil

    pcall(function()

        PED.SET_PED_TO_RAGDOLL(

            ped,

            3500,
            3500,

            0,

            false,
            false,
            false

        )

    end)

end

------------------------------------------------------------
-- HOTKEYS
------------------------------------------------------------

local function processPlayerHotkeys()

    local ped =
        getLocalPed()

    if not isValidEntity(ped) then
        return
    end

    if Hotkeys.crouchEnabled
        and not isPedInVehicle(ped)
    then

        if pressed(
            CONTROLS.CROUCH
        )
        then

            toggleCrouchedState()

        end

    end

    if Hotkeys.handsUpEnabled
        and not isPedInVehicle(ped)
    then

        if pressed(
            CONTROLS.HANDS_UP
        )
        then

            toggleHands()

        end

    elseif Hotkeys.handsUp
        and isPedInVehicle(ped)
    then

        lowerHands()

    end

    processHandsUp()

end

------------------------------------------------------------
-- ITENS NAS COSTAS
------------------------------------------------------------

local backItemObject = 0
local backItemData = nil
local backItemPed = 0

local pendingBackItem = nil

local backItems = {

    {
        name = "Pé de cabra",

        model = "w_me_crowbar",

        bone = 24818,

        x = 0.12,
        y = -0.18,
        z = 0.02,

        rx = 0.0,
        ry = 90.0,
        rz = 175.0
    },

    {
        name = "Taco de baseball",

        model = "w_me_bat",

        bone = 24818,

        x = 0.10,
        y = -0.18,
        z = -0.02,

        rx = 0.0,
        ry = 90.0,
        rz = 175.0
    },

    {
        name = "Violão",

        model = "prop_acc_guitar_01",

        bone = 24818,

        -- mais para o lado esquerdo do tronco
        x = -0.18,

        -- encostado nas costas
        y = -0.16,

        -- centralizado verticalmente no osso da coluna
        z = 0.02,

        -- inclinação estilo survival:
        -- braço do violão sobe para o ombro direito
        -- corpo desce para o quadril esquerdo
        rx = 5.0,
        ry = 105.0,
        rz = 35.0
    }

}

------------------------------------------------------------
-- REMOVER ITEM DAS COSTAS
------------------------------------------------------------

local function removeBackItem()

    pendingBackItem = nil

    backItemData = nil

    backItemPed = 0

    if backItemObject
        and backItemObject ~= 0
        and isValidEntity(backItemObject)
    then

        pcall(function()

            ENTITY.DETACH_ENTITY(

                backItemObject,

                true,
                true

            )

        end)

        pcall(function()

            ENTITY.DELETE_ENTITY(
                backItemObject
            )

        end)

    end

    backItemObject = 0

end

------------------------------------------------------------
-- PREPARAR ITEM
------------------------------------------------------------

local function createBackItem(data)

    if not data then
        return
    end

    pendingBackItem = nil

    if backItemObject
        and backItemObject ~= 0
        and isValidEntity(backItemObject)
    then

        pcall(function()

            ENTITY.DETACH_ENTITY(
                backItemObject,
                true,
                true
            )

        end)

        pcall(function()

            ENTITY.DELETE_ENTITY(
                backItemObject
            )

        end)

    end

    backItemObject = 0

    local ped =
        getLocalPed()

    if not isValidEntity(ped) then
        return
    end

    local hash =
        getHash(
            data.model
        )

    if not hash
        or hash == 0
    then

        showFeedNotification(

            "~r~Modelo inválido: ~w~"
            ..
            tostring(data.model)

        )

        return

    end

    backItemData =
        data

    backItemPed =
        ped

    pendingBackItem = {

        data = data,

        ped = ped,

        hash = hash,

        requested = false

    }

end

------------------------------------------------------------
-- NETWORK
------------------------------------------------------------

local function setupBackItemNetwork(object)

    if not isValidEntity(object) then
        return
    end

    pcall(function()

        if NETWORK
            and NETWORK.NETWORK_GET_NETWORK_ID_FROM_ENTITY
        then

            local netId =
                NETWORK.NETWORK_GET_NETWORK_ID_FROM_ENTITY(
                    object
                )

            if netId
                and netId ~= 0
            then

                if NETWORK.SET_NETWORK_ID_EXISTS_ON_ALL_MACHINES then

                    NETWORK.SET_NETWORK_ID_EXISTS_ON_ALL_MACHINES(

                        netId,

                        true

                    )

                end

                if NETWORK.SET_NETWORK_ID_CAN_MIGRATE then

                    NETWORK.SET_NETWORK_ID_CAN_MIGRATE(

                        netId,

                        true

                    )

                end

            end

        end

    end)

end

------------------------------------------------------------
-- PROCESSAR ITEM
------------------------------------------------------------

local function processPendingBackItem()

    if not pendingBackItem then
        return
    end

    local currentPed =
        getLocalPed()

    if not isValidEntity(currentPed) then
        return
    end

    if currentPed
        ~= pendingBackItem.ped
    then

        pendingBackItem.ped =
            currentPed

    end

    if not pendingBackItem.requested then

        pcall(function()

            STREAMING.REQUEST_MODEL(
                pendingBackItem.hash
            )

        end)

        pendingBackItem.requested = true

        return

    end

    local loaded = false

    pcall(function()

        loaded =
            STREAMING.HAS_MODEL_LOADED(
                pendingBackItem.hash
            )

    end)

    if not loaded then
        return
    end

    local ped =
        pendingBackItem.ped

    local data =
        pendingBackItem.data

    if not isValidEntity(ped) then
        return
    end

    local pos = nil

    pcall(function()

        pos =
            ENTITY.GET_ENTITY_COORDS(
                ped,
                true
            )

    end)

    if not pos then
        return
    end

    local object = 0

    pcall(function()

        object =
            OBJECT.CREATE_OBJECT(

                pendingBackItem.hash,

                pos.x,
                pos.y,
                pos.z,

                true,
                true,
                false

            )

    end)

    if not isValidEntity(object) then

        showFeedNotification(
            "~r~Não foi possível criar o item."
        )

        pendingBackItem = nil

        return

    end

    setupBackItemNetwork(
        object
    )

    local boneIndex = 0

    pcall(function()

        boneIndex =
            PED.GET_PED_BONE_INDEX(

                ped,

                data.bone or 24818

            )

    end)

    pcall(function()

        ENTITY.ATTACH_ENTITY_TO_ENTITY(

            object,

            ped,

            boneIndex,

            data.x or 0.0,
            data.y or -0.18,
            data.z or 0.0,

            data.rx or 0.0,
            data.ry or 0.0,
            data.rz or 0.0,

            false,
            false,
            false,
            false,

            2,

            true,

            0

        )

    end)

    backItemObject =
        object

    backItemData =
        data

    backItemPed =
        ped

    pcall(function()

        STREAMING.SET_MODEL_AS_NO_LONGER_NEEDED(
            pendingBackItem.hash
        )

    end)

    pendingBackItem = nil

    showFeedNotification(

        "~g~Costas: ~w~"
        ..
        data.name

    )

end

local function processBackItem()

    processPendingBackItem()

    if not backItemData then
        return
    end

    if pendingBackItem then
        return
    end

    local ped =
        getLocalPed()

    if not isValidEntity(ped) then
        return
    end

    if ped ~= backItemPed then

        local saved =
            backItemData

        if backItemObject
            and backItemObject ~= 0
            and isValidEntity(backItemObject)
        then

            pcall(function()

                ENTITY.DELETE_ENTITY(
                    backItemObject
                )

            end)

        end

        backItemObject = 0
        backItemPed = 0

        createBackItem(
            saved
        )

        return

    end

    if not isValidEntity(
        backItemObject
    )
    then

        local saved =
            backItemData

        backItemObject = 0

        createBackItem(
            saved
        )

    end

end

------------------------------------------------------------
-- SPECTATE
------------------------------------------------------------

local spectating = false

local function stopSpectating()

    if not spectating then
        return
    end

    pcall(function()

        NETWORK.NETWORK_SET_IN_SPECTATOR_MODE(

            false,

            getLocalPed()

        )

    end)

    spectating = false

end

local function spectatePlayer(pid)

    local targetPed =
        getPlayerPed(
            pid
        )

    if not isValidEntity(targetPed) then
        return
    end

    pcall(function()

        NETWORK.NETWORK_SET_IN_SPECTATOR_MODE(

            true,

            targetPed

        )

    end)

    spectating = true

end

------------------------------------------------------------
-- WARDROBE
------------------------------------------------------------

local wardrobeComponents = {

    { name = "Rosto", component = 0 },
    { name = "Máscara", component = 1 },
    { name = "Cabelo", component = 2 },
    { name = "Torso / Braços", component = 3 },
    { name = "Calça", component = 4 },
    { name = "Bolsa / Mochila", component = 5 },
    { name = "Sapatos", component = 6 },
    { name = "Acessórios", component = 7 },
    { name = "Blusa debaixo", component = 8 },
    { name = "Colete", component = 9 },
    { name = "Decalques", component = 10 },
    { name = "Blusa", component = 11 }

}

local wardrobeProps = {

    { name = "Chapéu", prop = 0 },
    { name = "Óculos", prop = 1 },
    { name = "Orelhas", prop = 2 },
    { name = "Relógio", prop = 6 },
    { name = "Pulseira", prop = 7 }

}

local WardrobeState = {
    values = {},
    textures = {},
    props = {},
    facePaint = 0
}

local function getComponentDrawable(
    ped,
    component
)

    local value = 0

    pcall(function()

        value =
            PED.GET_PED_DRAWABLE_VARIATION(
                ped,
                component
            )

    end)

    return tonumber(value) or 0

end

local function getComponentTexture(
    ped,
    component
)

    local value = 0

    pcall(function()

        value =
            PED.GET_PED_TEXTURE_VARIATION(
                ped,
                component
            )

    end)

    return tonumber(value) or 0

end

local function getComponentMax(
    ped,
    component
)

    local count = 1

    pcall(function()

        count =
            PED.GET_NUMBER_OF_PED_DRAWABLE_VARIATIONS(
                ped,
                component
            )

    end)

    return math.max(
        0,
        (tonumber(count) or 1) - 1
    )

end

local function getTextureMax(
    ped,
    component,
    drawable
)

    local count = 1

    pcall(function()

        count =
            PED.GET_NUMBER_OF_PED_TEXTURE_VARIATIONS(

                ped,
                component,
                drawable

            )

    end)

    return math.max(
        0,
        (tonumber(count) or 1) - 1
    )

end

local function applyComponent(data)

    local ped =
        getLocalPed()

    local drawable =
        WardrobeState.values[
            data.component
        ]

    if drawable == nil then

        drawable =
            getComponentDrawable(
                ped,
                data.component
            )

    end

    local texture =
        WardrobeState.textures[
            data.component
        ]
        or 0

    local maxTexture =
        getTextureMax(

            ped,
            data.component,
            drawable

        )

    if texture > maxTexture then
        texture = 0
    end

    WardrobeState.textures[
        data.component
    ] = texture

    pcall(function()

        PED.SET_PED_COMPONENT_VARIATION(

            ped,
            data.component,
            drawable,
            texture,
            0

        )

    end)

end

local function changeComponent(
    data,
    direction
)

    local ped =
        getLocalPed()

    local current =
        WardrobeState.values[
            data.component
        ]

    if current == nil then

        current =
            getComponentDrawable(
                ped,
                data.component
            )

    end

    local max =
        getComponentMax(
            ped,
            data.component
        )

    current =
        current + direction

    if current < 0 then
        current = max

    elseif current > max then
        current = 0
    end

    WardrobeState.values[
        data.component
    ] = current

    WardrobeState.textures[
        data.component
    ] = 0

    applyComponent(
        data
    )

end

local function changeTexture(
    data,
    direction
)

    local ped =
        getLocalPed()

    local drawable =
        WardrobeState.values[
            data.component
        ]

    if drawable == nil then

        drawable =
            getComponentDrawable(
                ped,
                data.component
            )

    end

    local current =
        WardrobeState.textures[
            data.component
        ]

    if current == nil then

        current =
            getComponentTexture(
                ped,
                data.component
            )

    end

    local max =
        getTextureMax(

            ped,
            data.component,
            drawable

        )

    current =
        current + direction

    if current < 0 then
        current = max

    elseif current > max then
        current = 0
    end

    WardrobeState.textures[
        data.component
    ] = current

    applyComponent(
        data
    )

end

local function getPropDrawable(
    ped,
    prop
)

    local value = -1

    pcall(function()

        value =
            PED.GET_PED_PROP_INDEX(
                ped,
                prop,
                true
            )

    end)

    return tonumber(value) or -1

end

local function getPropMax(
    ped,
    prop
)

    local count = 0

    pcall(function()

        count =
            PED.GET_NUMBER_OF_PED_PROP_DRAWABLE_VARIATIONS(
                ped,
                prop
            )

    end)

    return math.max(
        -1,
        (tonumber(count) or 0) - 1
    )

end

local function changeProp(
    data,
    direction
)

    local ped =
        getLocalPed()

    local current =
        WardrobeState.props[
            data.prop
        ]

    if current == nil then

        current =
            getPropDrawable(
                ped,
                data.prop
            )

    end

    local max =
        getPropMax(
            ped,
            data.prop
        )

    current =
        current + direction

    if current < -1 then
        current = max

    elseif current > max then
        current = -1
    end

    WardrobeState.props[
        data.prop
    ] = current

    if current == -1 then

        pcall(function()

            PED.CLEAR_PED_PROP(
                ped,
                data.prop
            )

        end)

    else

        pcall(function()

            PED.SET_PED_PROP_INDEX(

                ped,
                data.prop,
                current,
                0,
                true,
                true

            )

        end)

    end

end

local function changeFacePaint(direction)

    local ped =
        getLocalPed()

    local overlay = 4
    local max = 74

    pcall(function()

        if PED.GET_PED_HEAD_OVERLAY_NUM then

            local count =
                PED.GET_PED_HEAD_OVERLAY_NUM(
                    overlay
                )

            if count
                and count > 0
            then

                max =
                    count - 1

            end

        end

    end)

    WardrobeState.facePaint =
        WardrobeState.facePaint + direction

    if WardrobeState.facePaint < 0 then
        WardrobeState.facePaint = max

    elseif WardrobeState.facePaint > max then
        WardrobeState.facePaint = 0
    end

    pcall(function()

        PED.SET_PED_HEAD_OVERLAY(

            ped,
            overlay,
            WardrobeState.facePaint,
            1.0

        )

    end)

end

------------------------------------------------------------
-- PRISÃO VISUAL
------------------------------------------------------------

local arrestScene = {

    active = false,

    targetPid = -1,

    targetPed = 0,

    stage = 0,

    stageStarted = 0,

    cuffsObject = nil,

    animRequested = false,

    modelRequested = false

}

local ARREST_DICT =
    "mp_arresting"

local CUFF_MODEL =
    "p_cs_cuffs_02_s"

local function targetInVehicle(ped)

    return isPedInVehicle(
        ped
    )

end

local function removeArrestCuffs()

    local obj =
        arrestScene.cuffsObject

    if obj
        and isValidEntity(obj)
    then

        pcall(function()

            ENTITY.DETACH_ENTITY(
                obj,
                true,
                true
            )

        end)

        pcall(function()

            ENTITY.DELETE_ENTITY(
                obj
            )

        end)

    end

    arrestScene.cuffsObject = nil

end

local function cancelArrestScene()

    removeArrestCuffs()

    local ped =
        getLocalPed()

    if isValidEntity(ped) then

        pcall(function()

            TASK.CLEAR_PED_TASKS(
                ped
            )

        end)

    end

    arrestScene.active = false
    arrestScene.targetPid = -1
    arrestScene.targetPed = 0
    arrestScene.stage = 0
    arrestScene.stageStarted = 0
    arrestScene.animRequested = false
    arrestScene.modelRequested = false

end

local function startArrestScene(pid)

    if arrestScene.active then
        cancelArrestScene()
    end

    local target =
        getPlayerPed(pid)

    if not isValidEntity(target) then

        showFeedNotification(
            "~r~Jogador não encontrado."
        )

        return

    end

    if targetInVehicle(target) then

        showFeedNotification(
            "~r~O jogador está dentro de um veículo."
        )

        return

    end

    arrestScene.active = true
    arrestScene.targetPid = pid
    arrestScene.targetPed = target
    arrestScene.stage = 0
    arrestScene.stageStarted = gameTimer()

    showFeedNotification(

        "~b~Abordando ~w~"
        ..
        getPlayerName(pid)

    )

end

local function teleportBehindTarget()

    local myPed =
        getLocalPed()

    local target =
        arrestScene.targetPed

    if not isValidEntity(myPed)
        or not isValidEntity(target)
    then

        return false

    end

    local pos = nil
    local heading = 0.0

    pcall(function()

        pos =
            ENTITY.GET_ENTITY_COORDS(
                target,
                true
            )

        heading =
            ENTITY.GET_ENTITY_HEADING(
                target
            )

    end)

    if not pos then
        return false
    end

    local rad =
        math.rad(
            heading
        )

    local x =
        pos.x
        -
        math.sin(rad)
        *
        1.05

    local y =
        pos.y
        +
        math.cos(rad)
        *
        1.05

    pcall(function()

        ENTITY.SET_ENTITY_COORDS_NO_OFFSET(

            myPed,

            x,
            y,
            pos.z,

            false,
            false,
            false

        )

        ENTITY.SET_ENTITY_HEADING(
            myPed,
            heading
        )

    end)

    return true

end

local function spawnVisualCuffsOnTarget()

    removeArrestCuffs()

    local target =
        arrestScene.targetPed

    local model =
        getHash(
            CUFF_MODEL
        )

    if model == 0
        or not isValidEntity(target)
    then

        return

    end

    local pos = nil

    pcall(function()

        pos =
            ENTITY.GET_ENTITY_COORDS(
                target,
                true
            )

    end)

    if not pos then
        return
    end

    local obj = 0

    pcall(function()

        obj =
            OBJECT.CREATE_OBJECT(

                model,

                pos.x,
                pos.y,
                pos.z,

                false,
                false,
                false

            )

    end)

    if not isValidEntity(obj) then
        return
    end

    local bone = 0

    pcall(function()

        bone =
            PED.GET_PED_BONE_INDEX(
                target,
                57005
            )

    end)

    pcall(function()

        ENTITY.ATTACH_ENTITY_TO_ENTITY(

            obj,
            target,
            bone,

            0.02,
            0.04,
            -0.02,

            -75.0,
            0.0,
            15.0,

            false,
            false,
            false,
            false,

            2,
            true,
            0

        )

    end)

    arrestScene.cuffsObject =
        obj

end

local function processArrestScene()

    if not arrestScene.active then
        return
    end

    local target =
        arrestScene.targetPed

    local myPed =
        getLocalPed()

    if not isValidEntity(target)
        or not isValidEntity(myPed)
        or not isPlayerActive(
            arrestScene.targetPid
        )
    then

        cancelArrestScene()
        return

    end

    if targetInVehicle(target) then

        showFeedNotification(
            "~r~Cena cancelada: jogador entrou em veículo."
        )

        cancelArrestScene()
        return

    end

    local now =
        gameTimer()

    if arrestScene.stage == 0 then

        if not arrestScene.animRequested then

            pcall(function()

                STREAMING.REQUEST_ANIM_DICT(
                    ARREST_DICT
                )

            end)

            arrestScene.animRequested = true

        end

        if not arrestScene.modelRequested then

            pcall(function()

                STREAMING.REQUEST_MODEL(
                    getHash(CUFF_MODEL)
                )

            end)

            arrestScene.modelRequested = true

        end

        local animLoaded = false
        local modelLoaded = false

        pcall(function()

            animLoaded =
                STREAMING.HAS_ANIM_DICT_LOADED(
                    ARREST_DICT
                )

            modelLoaded =
                STREAMING.HAS_MODEL_LOADED(
                    getHash(CUFF_MODEL)
                )

        end)

        if not animLoaded
            or not modelLoaded
        then

            return

        end

        arrestScene.stage = 1
        arrestScene.stageStarted = now

        return

    end

    if arrestScene.stage == 1 then

        teleportBehindTarget()

        arrestScene.stage = 2
        arrestScene.stageStarted = now

        return

    end

    if arrestScene.stage == 2 then

        pcall(function()

            TASK.CLEAR_PED_TASKS(
                myPed
            )

            TASK.TASK_PLAY_ANIM(

                myPed,

                ARREST_DICT,

                "a_uncuff",

                8.0,
                -8.0,

                3000,

                48,

                0.0,

                false,
                false,
                false

            )

        end)

        spawnVisualCuffsOnTarget()

        arrestScene.stage = 3
        arrestScene.stageStarted = now

        return

    end

    if arrestScene.stage == 3 then

        if now
            -
            arrestScene.stageStarted
            <
            3000
        then

            return

        end

        removeArrestCuffs()

        pcall(function()

            TASK.CLEAR_PED_TASKS(
                myPed
            )

        end)

        showFeedNotification(
            "~g~Cena concluída."
        )

        arrestScene.active = false
        arrestScene.stage = 0

    end

end

------------------------------------------------------------
-- ITEM HELPERS
------------------------------------------------------------

local function actionItem(
    name,
    action
)

    return {

        name = name,

        type = "action",

        action = action

    }

end

local function toggleItem(
    name,
    getState,
    action
)

    return {

        name = name,

        type = "toggle",

        getState = getState,

        action = action

    }

end

local function submenuItem(
    name,
    builder
)

    return {

        name = name,

        type = "submenu",

        builder = builder

    }

end

------------------------------------------------------------
-- BUILDERS
------------------------------------------------------------

local Builders = {}

------------------------------------------------------------
-- ANIMATION LIST
------------------------------------------------------------

local function buildAnimationList(list)

    local items = {}

    for _, animation
        in ipairs(list)
    do

        local saved =
            animation

        table.insert(

            items,

            actionItem(

                saved.name,

                function()

                    playAnimation(
                        saved
                    )

                end

            )

        )

    end

    return items

end

------------------------------------------------------------
-- ANIMATION BUILDERS
------------------------------------------------------------

local function buildPoliceAnimations()
    return buildAnimationList(AnimLists.police)
end

local function buildSocialAnimations()
    return buildAnimationList(AnimLists.social)
end

local function buildGestureAnimations()
    return buildAnimationList(AnimLists.gesture)
end

local function buildWorkAnimations()
    return buildAnimationList(AnimLists.work)
end

local function buildRelaxAnimations()
    return buildAnimationList(AnimLists.relaxing)
end

local function buildSittingAnimations()
    return buildAnimationList(AnimLists.sitting)
end

local function buildDanceAnimations()
    return buildAnimationList(AnimLists.dance)
end

local function buildPhoneAnimations()
    return buildAnimationList(AnimLists.phone)
end

local function buildExerciseAnimations()
    return buildAnimationList(AnimLists.exercise)
end

------------------------------------------------------------
-- ANIMAÇÕES MENU
------------------------------------------------------------

Builders.buildAnimationsMenu = function()

    return {

        actionItem(

            "Parar animação atual",

            function()

                if Hotkeys.handsUp then
                    lowerHands()
                end

                stopAnimation()

            end

        ),

        submenuItem(
            "Polícia",
            buildPoliceAnimations
        ),

        submenuItem(
            "Social",
            buildSocialAnimations
        ),

        submenuItem(
            "Gestos",
            buildGestureAnimations
        ),

        submenuItem(
            "Trabalho",
            buildWorkAnimations
        ),

        submenuItem(
            "Relaxar",
            buildRelaxAnimations
        ),

        submenuItem(
            "Sentado / Deitado",
            buildSittingAnimations
        ),

        submenuItem(
            "Danças",
            buildDanceAnimations
        ),

        submenuItem(
            "Celular",
            buildPhoneAnimations
        ),

        submenuItem(
            "Exercícios",
            buildExerciseAnimations
        )

    }

end

------------------------------------------------------------
-- GUARDA-ROUPA MENU
------------------------------------------------------------

Builders.buildWardrobeMenu = function()

    local items = {}

    table.insert(

        items,

        {

            name =
                "Pintura facial",

            type =
                "facepaint"

        }

    )

    for _, data
        in ipairs(
            wardrobeComponents
        )
    do

        local saved =
            data

        table.insert(

            items,

            {

                name =
                    saved.name,

                type =
                    "component",

                data =
                    saved

            }

        )

        table.insert(

            items,

            {

                name =
                    saved.name
                    ..
                    " textura",

                type =
                    "texture",

                data =
                    saved

            }

        )

    end

    for _, data
        in ipairs(
            wardrobeProps
        )
    do

        local saved =
            data

        table.insert(

            items,

            {

                name =
                    saved.name,

                type =
                    "prop",

                data =
                    saved

            }

        )

    end

    return items

end

------------------------------------------------------------
-- SPECTATE MENU
------------------------------------------------------------

Builders.buildSpectateMenu = function()

    local items = {}

    if spectating then

        table.insert(

            items,

            actionItem(

                "Parar de assistir",

                function()

                    stopSpectating()

                end

            )

        )

    end

    local me =
        getLocalPid()

    for pid = 0, 31 do

        if pid ~= me
            and isPlayerActive(pid)
        then

            local savedPid =
                pid

            table.insert(

                items,

                actionItem(

                    getPlayerName(
                        savedPid
                    ),

                    function()

                        spectatePlayer(
                            savedPid
                        )

                    end

                )

            )

        end

    end

    if #items == 0 then

        table.insert(

            items,

            {

                name =
                    "Nenhum jogador encontrado",

                type =
                    "label"

            }

        )

    end

    return items

end

------------------------------------------------------------
-- MOVIMENTO MENU
------------------------------------------------------------

Builders.buildMovementMenu = function()

    local items = {}

    for _, move
        in ipairs(movements)
    do

        local saved =
            move

        table.insert(

            items,

            actionItem(

                saved.name,

                function()

                    applyMovement(
                        saved
                    )

                end

            )

        )

    end

    return items

end

------------------------------------------------------------
-- MODS MENU
------------------------------------------------------------

Builders.buildModsMenu = function()

    return {

        actionItem(

            Hotkeys.crouchEnabled
            and "Agachar por Y: ON"
            or "Agachar por Y: OFF",

            function()

                toggleCrouchHotkey()

                menu.items =
                    Builders.buildModsMenu()

            end

        ),

        actionItem(

            Hotkeys.handsUpEnabled
            and "Mãos para cima por H: ON"
            or "Mãos para cima por H: OFF",

            function()

                toggleHandsHotkey()

                menu.items =
                    Builders.buildModsMenu()

            end

        ),

        actionItem(

            Hotkeys.crouched
            and "Levantar"
            or "Agachar agora",

            function()

                toggleCrouchedState()

                menu.items =
                    Builders.buildModsMenu()

            end

        ),

        actionItem(

            Hotkeys.handsUp
            and "Abaixar mãos"
            or "Mãos para cima agora",

            function()

                toggleHands()

                menu.items =
                    Builders.buildModsMenu()

            end

        ),

        actionItem(

            "Desmaiar",

            function()

                faintPlayer()

            end

        ),

        actionItem(

            "Parar animação",

            function()

                if Hotkeys.handsUp then
                    lowerHands()
                end

                stopAnimation()

            end

        ),

        actionItem(

            "Resetar movimento",

            function()

                Hotkeys.crouched = false

                resetMovement()

            end

        )

    }

end

------------------------------------------------------------
-- COSTAS MENU
------------------------------------------------------------

Builders.buildBackMenu = function()

    local items = {}

    table.insert(

        items,

        actionItem(

            "Remover item",

            function()

                removeBackItem()

                showFeedNotification(
                    "~y~Item das costas removido."
                )

            end

        )

    )

    for _, item
        in ipairs(backItems)
    do

        local savedItem =
            item

        table.insert(

            items,

            actionItem(

                savedItem.name,

                function()

                    createBackItem(
                        savedItem
                    )

                end

            )

        )

    end

    return items

end

------------------------------------------------------------
-- NYX ADVANCED CHAOS, TELEKINESIS, COMBAT & AIRDROP
------------------------------------------------------------

local ChaosState = {
    isHoldingVehicle = false,
    heldVehicle = nil,
    holdDistance = 12.0,
    launchForce = 150.0,
    isCarryingPlayer = false,
    carriedPlayerPed = nil,
    vortexActive = false,
    vehicleShieldActive = false,
    vehicleRainActive = false,
    pushRepulsorActive = false,
    zombiePedOutbreakActive = false,
    isTrollAudioActive = false,
    trollAudioLoop = false,
    airdropDropType = 1,
    airdropLocationMode = 1,
    selectedAirdropPid = -1,
    dogfightJetCount = 2,
    selectedDogfightPid = -1,
    selectedEarRapePid = -1,
    trollLightning = true,
    trollFlashbang = true,
    activeDogfightJets = {},
    isDogfightSpawning = false,
    dogfightAttackRunning = false,
    lastDogfightSpawnTime = 0
}

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
    maxDist = maxDist or 30.0
    local ped = getLocalPed()
    if not isValidPed(ped) then return nil end
    local pCoords = ENTITY.GET_ENTITY_COORDS(ped, true)
    local forward = getCameraDirection()
    local rayEnd = {
        x = pCoords.x + forward.x * maxDist,
        y = pCoords.y + forward.y * maxDist,
        z = pCoords.z + forward.z * maxDist
    }
    local handle = SHAPETEST.START_EXPENSIVE_SYNCHRONOUS_SHAPE_TEST_LOS_PROBE(
        pCoords.x, pCoords.y, pCoords.z + 0.5,
        rayEnd.x, rayEnd.y, rayEnd.z,
        2, ped, 7
    )
    local _, hit, endCoords, surfaceNorm, entityHit = SHAPETEST.GET_SHAPE_TEST_RESULT(handle)
    if hit and entityHit and entityHit ~= 0 then
        if ENTITY.IS_ENTITY_A_VEHICLE(entityHit) then
            return entityHit
        end
    end
    if VEHICLE and VEHICLE.GET_CLOSEST_VEHICLE then
        local closeVeh = VEHICLE.GET_CLOSEST_VEHICLE(pCoords.x, pCoords.y, pCoords.z, maxDist, 0, 70)
        if isValidPed(closeVeh) then return closeVeh end
    end
    return nil
end

local function toggleHoldVehicle()
    if ChaosState.isHoldingVehicle then
        if isValidPed(ChaosState.heldVehicle) then
            pcall(function()
                ENTITY.FREEZE_ENTITY_POSITION(ChaosState.heldVehicle, false)
                ENTITY.SET_ENTITY_COLLISION(ChaosState.heldVehicle, true, true)
            end)
        end
        ChaosState.isHoldingVehicle = false
        ChaosState.heldVehicle = nil
        showFeedNotification("~y~Telecinese: Veiculo solto.")
    else
        local veh = getTargetVehicle(40.0)
        if isValidPed(veh) then
            ChaosState.heldVehicle = veh
            ChaosState.isHoldingVehicle = true
            showFeedNotification("~g~Telecinese: Segurando veiculo! Use Lancar para arremessar.")
        else
            showFeedNotification("~r~Nenhum veiculo na mira ou proximo.")
        end
    end
end

local function launchHeldVehicle()
    if ChaosState.isHoldingVehicle and isValidPed(ChaosState.heldVehicle) then
        local forward = getCameraDirection()
        pcall(function()
            ENTITY.FREEZE_ENTITY_POSITION(ChaosState.heldVehicle, false)
            ENTITY.SET_ENTITY_COLLISION(ChaosState.heldVehicle, true, true)
            ENTITY.SET_ENTITY_VELOCITY(
                ChaosState.heldVehicle,
                forward.x * ChaosState.launchForce,
                forward.y * ChaosState.launchForce,
                forward.z * ChaosState.launchForce + 5.0
            )
        end)
        ChaosState.isHoldingVehicle = false
        ChaosState.heldVehicle = nil
        showFeedNotification("~g~Veiculo arremessado com poder maximo!")
    else
        showFeedNotification("~r~Voce precisa segurar um veiculo primeiro.")
    end
end

local function toggleVortex()
    ChaosState.vortexActive = not ChaosState.vortexActive
    if ChaosState.vortexActive then
        showFeedNotification("~g~Vortice Gravitacional ATIVADO! Carros sendo atraidos...")
        script.run_in_callback(function()
            while ChaosState.vortexActive do
                pcall(function()
                    local ped = getLocalPed()
                    local pCoords = ENTITY.GET_ENTITY_COORDS(ped, true)
                    local vehicles = {}
                    if entities and entities.get_all_vehicles_as_handles then
                        vehicles = entities.get_all_vehicles_as_handles()
                    end
                    for _, veh in ipairs(vehicles) do
                        if isValidPed(veh) then
                            local vCoords = ENTITY.GET_ENTITY_COORDS(veh, true)
                            local dx = pCoords.x - vCoords.x
                            local dy = pCoords.y - vCoords.y
                            local dz = (pCoords.z + 5.0) - vCoords.z
                            local dist = math.sqrt(dx*dx + dy*dy + dz*dz)
                            if dist > 3.0 and dist < 120.0 then
                                local force = 45.0
                                local nx = (dx / dist) * force - (dy / dist) * 15.0
                                local ny = (dy / dist) * force + (dx / dist) * 15.0
                                local nz = (dz / dist) * force + 8.0
                                ENTITY.SET_ENTITY_VELOCITY(veh, nx, ny, nz)
                            end
                        end
                    end
                end)
                script.yield(50)
            end
        end)
    else
        showFeedNotification("~r~Vortice Gravitacional DESATIVADO.")
    end
end

local function toggleVehicleShield()
    ChaosState.vehicleShieldActive = not ChaosState.vehicleShieldActive
    if ChaosState.vehicleShieldActive then
        showFeedNotification("~g~Escudo Orbital de Carros ATIVADO!")
        script.run_in_callback(function()
            local ped = getLocalPed()
            local pCoords = ENTITY.GET_ENTITY_COORDS(ped, true)
            local shieldVehs = {}
            local models = { "kuruma", "zentorno", "adder", "nero", "t20", "turismor" }
            for i = 1, 6 do
                local hash = MISC.GET_HASH_KEY(models[i])
                STREAMING.REQUEST_MODEL(hash)
                local timeout = 0
                while not STREAMING.HAS_MODEL_LOADED(hash) and timeout < 20 do
                    script.yield(10)
                    timeout = timeout + 1
                end
                local v = VEHICLE.CREATE_VEHICLE(hash, pCoords.x, pCoords.y, pCoords.z + 10.0, 0.0, true, false, false)
                if isValidPed(v) then
                    ENTITY.SET_ENTITY_INVINCIBLE(v, true)
                    ENTITY.SET_ENTITY_COLLISION(v, true, true)
                    table.insert(shieldVehs, v)
                end
            end
            local angle = 0.0
            while ChaosState.vehicleShieldActive do
                pcall(function()
                    local curCoords = ENTITY.GET_ENTITY_COORDS(getLocalPed(), true)
                    angle = angle + 0.08
                    for idx, v in ipairs(shieldVehs) do
                        if isValidPed(v) then
                            local offsetAngle = angle + (idx * (math.pi * 2 / #shieldVehs))
                            local ox = curCoords.x + math.cos(offsetAngle) * 7.5
                            local oy = curCoords.y + math.sin(offsetAngle) * 7.5
                            local oz = curCoords.z + 1.2
                            ENTITY.SET_ENTITY_COORDS_NO_OFFSET(v, ox, oy, oz, false, false, false)
                            ENTITY.SET_ENTITY_HEADING(v, math.deg(offsetAngle) + 90.0)
                        end
                    end
                end)
                script.yield(15)
            end
            for _, v in ipairs(shieldVehs) do
                if isValidPed(v) then
                    pcall(function() entities.delete(v) end)
                end
            end
        end)
    else
        showFeedNotification("~r~Escudo Orbital DESATIVADO.")
    end
end

local function toggleVehicleRain()
    ChaosState.vehicleRainActive = not ChaosState.vehicleRainActive
    if ChaosState.vehicleRainActive then
        showFeedNotification("~g~Chuva de Carros do Ceu ATIVADA!")
        script.run_in_callback(function()
            local models = { "blista", "futo", "adder", "insurgent", "zentorno", "bus" }
            while ChaosState.vehicleRainActive do
                pcall(function()
                    local ped = getLocalPed()
                    local pCoords = ENTITY.GET_ENTITY_COORDS(ped, true)
                    local rx = pCoords.x + math.random(-45, 45)
                    local ry = pCoords.y + math.random(-45, 45)
                    local rz = pCoords.z + math.random(35, 60)
                    local m = models[math.random(#models)]
                    local hash = MISC.GET_HASH_KEY(m)
                    STREAMING.REQUEST_MODEL(hash)
                    if STREAMING.HAS_MODEL_LOADED(hash) then
                        local v = VEHICLE.CREATE_VEHICLE(hash, rx, ry, rz, math.random(0, 360), true, false, false)
                        if isValidPed(v) then
                            ENTITY.SET_ENTITY_VELOCITY(v, 0.0, 0.0, -35.0)
                        end
                    end
                end)
                script.yield(400)
            end
        end)
    else
        showFeedNotification("~r~Chuva de Carros DESATIVADA.")
    end
end

local function togglePushRepulsor()
    ChaosState.pushRepulsorActive = not ChaosState.pushRepulsorActive
    if ChaosState.pushRepulsorActive then
        showFeedNotification("~g~Onda de Choque / Repulsor ATIVADO!")
        script.run_in_callback(function()
            while ChaosState.pushRepulsorActive do
                pcall(function()
                    local ped = getLocalPed()
                    local pCoords = ENTITY.GET_ENTITY_COORDS(ped, true)
                    local vehicles = {}
                    if entities and entities.get_all_vehicles_as_handles then
                        vehicles = entities.get_all_vehicles_as_handles()
                    end
                    for _, veh in ipairs(vehicles) do
                        if isValidPed(veh) then
                            local vCoords = ENTITY.GET_ENTITY_COORDS(veh, true)
                            local dx = vCoords.x - pCoords.x
                            local dy = vCoords.y - pCoords.y
                            local dz = vCoords.z - pCoords.z
                            local dist = math.sqrt(dx*dx + dy*dy + dz*dz)
                            if dist < 22.0 and dist > 1.0 then
                                local force = 90.0
                                ENTITY.SET_ENTITY_VELOCITY(veh, (dx / dist) * force, (dy / dist) * force, 15.0)
                            end
                        end
                    end
                end)
                script.yield(100)
            end
        end)
    else
        showFeedNotification("~r~Repulsor DESATIVADO.")
    end
end

local function toggleZombiePedOutbreak()
    ChaosState.zombiePedOutbreakActive = not ChaosState.zombiePedOutbreakActive
    if ChaosState.zombiePedOutbreakActive then
        showFeedNotification("~g~Apocalipse Zumbi Iniciado!")
        script.run_in_callback(function()
            local ped = getLocalPed()
            local pCoords = ENTITY.GET_ENTITY_COORDS(ped, true)
            local zModels = { "u_m_y_zombie_01", "s_m_y_clown_01", "a_m_m_hillbilly_01" }
            for i = 1, 8 do
                local hash = MISC.GET_HASH_KEY(zModels[math.random(#zModels)])
                STREAMING.REQUEST_MODEL(hash)
                local timeout = 0
                while not STREAMING.HAS_MODEL_LOADED(hash) and timeout < 20 do
                    script.yield(10)
                    timeout = timeout + 1
                end
                local ox = pCoords.x + math.random(-25, 25)
                local oy = pCoords.y + math.random(-25, 25)
                local zPed = PED.CREATE_PED(26, hash, ox, oy, pCoords.z + 1.0, 0.0, true, false)
                if isValidPed(zPed) then
                    WEAPON.GIVE_DELAYED_WEAPON_TO_PED(zPed, MISC.GET_HASH_KEY("WEAPON_MACHETE"), 100, true)
                    TASK.TASK_COMBAT_PED(zPed, ped, 0, 16)
                end
            end
        end)
    else
        showFeedNotification("~r~Apocalipse Zumbi Finalizado.")
    end
end

-- Menu Builders
-- Attack & Airdrop states managed in ChaosState

local function getTargetPlayerDisplayName(pid)
    if pid == nil or pid == -1 or pid == getLocalPid() then
        return "Voce Mesmo (Testar)"
    end
    local name = getPlayerName(pid)
    local isNyx = (nyx_detected_users[pid] == true)
    return string.format("[%02d]%s %s", pid, isNyx and " [NYX USER]" or "", name)
end



local function safeDeleteEntity(ent)
    if not ent or ent == 0 then return end
    pcall(function()
        if ENTITY and ENTITY.DOES_ENTITY_EXIST and ENTITY.DOES_ENTITY_EXIST(ent) then
            ENTITY.SET_ENTITY_AS_MISSION_ENTITY(ent, true, true)
            if ENTITY.SET_ENTITY_COLLISION then ENTITY.SET_ENTITY_COLLISION(ent, false, false) end
            if PED and PED.DELETE_PED and ENTITY.IS_ENTITY_A_PED and ENTITY.IS_ENTITY_A_PED(ent) then
                PED.DELETE_PED(ent)
            elseif VEHICLE and VEHICLE.DELETE_VEHICLE and ENTITY.IS_ENTITY_A_VEHICLE and ENTITY.IS_ENTITY_A_VEHICLE(ent) then
                VEHICLE.DELETE_VEHICLE(ent)
            elseif OBJECT and OBJECT.DELETE_OBJECT and ENTITY.IS_ENTITY_AN_OBJECT and ENTITY.IS_ENTITY_AN_OBJECT(ent) then
                OBJECT.DELETE_OBJECT(ent)
            end
            if ENTITY.DELETE_ENTITY then ENTITY.DELETE_ENTITY(ent) end
            if ENTITY.DOES_ENTITY_EXIST(ent) then
                ENTITY.SET_ENTITY_COORDS(ent, 0.0, 0.0, -100.0, false, false, false, false)
                ENTITY.SET_ENTITY_AS_NO_LONGER_NEEDED(ent)
            end
        end
    end)
end

local function clearActiveDogfightJets()
    ChaosState.dogfightAttackRunning = false
    local count = #ChaosState.activeDogfightJets

    for _, item in ipairs(ChaosState.activeDogfightJets) do
        pcall(function()
            if item.blip and HUD and HUD.DOES_BLIP_EXIST and HUD.DOES_BLIP_EXIST(item.blip) then
                HUD.REMOVE_BLIP(item.blip)
            end
            if isValidEntity(item.pilot) then
                safeDeleteEntity(item.pilot)
            end
            if isValidEntity(item.jet) then
                safeDeleteEntity(item.jet)
            end
        end)
    end
    ChaosState.activeDogfightJets = {}
    showFeedNotification("~y~Todos os cacas foram removidos.")
end

local function triggerDogfightAttack(targetPid, count)
    if ChaosState.isDogfightSpawning then
        showFeedNotification("~y~Aguarde, cacas anteriores ainda sendo posicionados!")
        return
    end

    local now = gameTimer()
    if (now - ChaosState.lastDogfightSpawnTime) < 3000 then
        showFeedNotification("~y~Aguarde alguns segundos entre os ataques!")
        return
    end
    ChaosState.lastDogfightSpawnTime = now

    local jetCount = math.min(3, math.max(1, tonumber(count) or ChaosState.dogfightJetCount or 1))
    local myLocalPid = getLocalPid()
    local actualPid = (targetPid == nil or targetPid == -1) and myLocalPid or targetPid
    local targetName = (actualPid == myLocalPid) and "Voce Mesmo" or getPlayerName(actualPid)

    ChaosState.isDogfightSpawning = true

    script.run_in_callback(function()
        pcall(function()
            local targetPed = (actualPid == myLocalPid) and getLocalPed() or getPlayerPed(actualPid)
            if not isValidEntity(targetPed) then
                showFeedNotification("~r~Ped do alvo nao encontrado.")
                ChaosState.isDogfightSpawning = false
                return
            end

            -- Remove esquadrão anterior antes de iniciar o novo
            if #ChaosState.activeDogfightJets > 0 then
                clearActiveDogfightJets()
                script.yield(150)
            end

            local targetCoords = ENTITY.GET_ENTITY_COORDS(targetPed, true)
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
                showFeedNotification("~r~Falha ao carregar modelos dos cacas.")
                ChaosState.isDogfightSpawning = false
                return
            end

            showFeedNotification(string.format("~g~Enviando %d caca(s) atacando %s!", jetCount, targetName))
            ChaosState.dogfightAttackRunning = true

            for i = 1, jetCount do
                if not ChaosState.dogfightAttackRunning then break end

                local angle = ((i - 1) / jetCount) * (math.pi * 2) + (math.random() * 0.4)
                local dist = 160.0 + (i * 35.0)
                local sx = targetCoords.x + math.cos(angle) * dist
                local sy = targetCoords.y + math.sin(angle) * dist
                local sz = targetCoords.z + 280.0 + (i * 25.0)
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
                        VEHICLE.SET_VEHICLE_FORWARD_SPEED(jet, 80.0)
                        if VEHICLE.CONTROL_LANDING_GEAR then
                            VEHICLE.CONTROL_LANDING_GEAR(jet, 3)
                        end
                        if VEHICLE.SET_HELI_BLADES_FULL_SPEED then
                            VEHICLE.SET_HELI_BLADES_FULL_SPEED(jet)
                        end
                        
                        pilot = PED.CREATE_PED_INSIDE_VEHICLE(jet, 26, pilotHash, -1, true, false)

                        -- Blip Inimigo Vermelho no Radar
                        if HUD and HUD.ADD_BLIP_FOR_ENTITY then
                            blip = HUD.ADD_BLIP_FOR_ENTITY(jet)
                            if HUD.SET_BLIP_SPRITE then
                                HUD.SET_BLIP_SPRITE(blip, 16)
                            end
                            if HUD.SET_BLIP_COLOUR then
                                HUD.SET_BLIP_COLOUR(blip, 1)
                            end
                            if HUD.SET_BLIP_SCALE then
                                HUD.SET_BLIP_SCALE(blip, 1.0)
                            end
                            if HUD.SET_BLIP_AS_SHORT_RANGE then
                                HUD.SET_BLIP_AS_SHORT_RANGE(blip, false)
                            end
                            if HUD.BEGIN_TEXT_COMMAND_SET_BLIP_NAME then
                                HUD.BEGIN_TEXT_COMMAND_SET_BLIP_NAME("STRING")
                                HUD.ADD_TEXT_COMPONENT_SUBSTRING_PLAYER_NAME("Caca Inimigo")
                                HUD.END_TEXT_COMMAND_SET_BLIP_NAME(blip)
                            end
                        end
                    end)

                    table.insert(ChaosState.activeDogfightJets, { jet = jet, pilot = pilot, blip = blip })

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
                end
                script.yield(350)
            end

            STREAMING.SET_MODEL_AS_NO_LONGER_NEEDED(jetHash)
            STREAMING.SET_MODEL_AS_NO_LONGER_NEEDED(pilotHash)
            ChaosState.isDogfightSpawning = false

            -- Supervisor estável em segundo plano (atualiza alvo vivo e remove blips de caças abatidos)
            script.run_in_callback(function()
                local lastAssignedPed = targetPed
                while ChaosState.dogfightAttackRunning and #ChaosState.activeDogfightJets > 0 do
                    local curPed = (actualPid == myLocalPid) and getLocalPed() or getPlayerPed(actualPid)
                    local aliveCount = 0

                    for idx = #ChaosState.activeDogfightJets, 1, -1 do
                        local item = ChaosState.activeDogfightJets[idx]
                        local jetValid = isValidEntity(item.jet)
                        local pilotValid = isValidEntity(item.pilot) and not PED.IS_PED_INJURED(item.pilot)

                        if not jetValid or not pilotValid then
                            pcall(function()
                                if item.blip and HUD and HUD.DOES_BLIP_EXIST and HUD.DOES_BLIP_EXIST(item.blip) then
                                    HUD.REMOVE_BLIP(item.blip)
                                end
                            end)
                            table.remove(ChaosState.activeDogfightJets, idx)
                        else
                            aliveCount = aliveCount + 1
                            if isValidEntity(curPed) and curPed ~= lastAssignedPed and not PED.IS_PED_INJURED(curPed) then
                                pcall(function()
                                    local pGroup = PED.GET_PED_RELATIONSHIP_GROUP_HASH(curPed)
                                    local eGroup = getHash("HATES_PLAYER")
                                    PED.SET_RELATIONSHIP_BETWEEN_GROUPS(5, eGroup, pGroup)
                                    PED.SET_RELATIONSHIP_BETWEEN_GROUPS(5, pGroup, eGroup)
                                    TASK.TASK_COMBAT_PED(item.pilot, curPed, 0, 16)
                                    if TASK.TASK_PLANE_MISSION then
                                        TASK.TASK_PLANE_MISSION(item.pilot, item.jet, 0, curPed, 0.0, 0.0, 0.0, 6, 110.0, 0.0, 90.0, 0, 100.0)
                                    elseif TASK.TASK_PLANE_CHASE then
                                        TASK.TASK_PLANE_CHASE(item.pilot, curPed, 0.0, 0.0, 50.0)
                                    end
                                end)
                            end
                        end
                    end

                    if isValidEntity(curPed) and curPed ~= lastAssignedPed and not PED.IS_PED_INJURED(curPed) then
                        lastAssignedPed = curPed
                    end

                    if aliveCount == 0 then
                        ChaosState.dogfightAttackRunning = false
                        break
                    end

                    script.yield(500)
                end
            end)
        end)
        ChaosState.isDogfightSpawning = false
    end)
end

local function runSingleEarRapeStep(targetPid)
    local actualPid = (targetPid == -1 or targetPid == getLocalPid()) and getLocalPid() or targetPid
    local isLocal = (actualPid == getLocalPid())
    local targetPed = isLocal and getLocalPed() or getPlayerPed(actualPid)
    if not isValidEntity(targetPed) then return end

    local coords = ENTITY.GET_ENTITY_COORDS(targetPed, true)

    pcall(function()
        if isLocal then
            if AUDIO and AUDIO.PLAY_SOUND_FRONTEND then
                AUDIO.PLAY_SOUND_FRONTEND(-1, "Airhorn", "DLC_TG_Running_Back_Sounds", true)
            end
            if CAM and CAM.SHAKE_GAMEPLAY_CAM then
                CAM.SHAKE_GAMEPLAY_CAM("LARGE_EXPLOSION_SHAKE", 3.0)
            end
            if ChaosState.trollFlashbang and GRAPHICS and GRAPHICS.ANIMPOSTFX_PLAY then
                GRAPHICS.ANIMPOSTFX_PLAY("DrugsMichaelAliensFight", 0, true)
            end
        end

        -- Ondas de choque nas coordenadas do alvo (treme tela e vibra controle)
        if FIRE and FIRE.ADD_EXPLOSION then
            FIRE.ADD_EXPLOSION(coords.x, coords.y, coords.z - 2.0, 70, 0.0, true, false, 3.0, false)
        end

        if ChaosState.trollLightning and MISC and MISC.FORCE_LIGHTNING_FLASH_AT_COORDS then
            MISC.FORCE_LIGHTNING_FLASH_AT_COORDS(coords.x, coords.y, coords.z, 3.0)
        end
    end)
end

local function stopTrollAudioHarassment()
    ChaosState.isTrollAudioActive = false
    pcall(function()
        if GRAPHICS and GRAPHICS.ANIMPOSTFX_STOP then
            GRAPHICS.ANIMPOSTFX_STOP("DrugsMichaelAliensFight")
        end
        if CAM and CAM.STOP_GAMEPLAY_CAM_SHAKING then
            CAM.STOP_GAMEPLAY_CAM_SHAKING(true)
        end
    end)
    showFeedNotification("~y~Ear Rape e Terremoto desativados.")
end

local function triggerEarRapeTremor(targetPid, burstSecs)
    local pName = (targetPid == -1 or targetPid == getLocalPid()) and "Você Mesmo" or getPlayerName(targetPid)
    showFeedNotification("~r~Disparando Ear Rape e Terremoto em " .. pName .. "!")

    script.run_in_callback(function()
        if burstSecs and burstSecs > 0 then
            local totalTicks = math.floor((burstSecs * 1000) / 80)
            for i = 1, totalTicks do
                runSingleEarRapeStep(targetPid)
                script.yield(80)
            end
            stopTrollAudioHarassment()
            showFeedNotification("~y~Burst de Ear Rape finalizado.")
        else
            ChaosState.isTrollAudioActive = true
            while ChaosState.isTrollAudioActive do
                runSingleEarRapeStep(targetPid)
                script.yield(80)
            end
        end
    end)
end

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

local function triggerAirdropDrop(dropType, targetPid, locMode)
    local isLocalTarget = (locMode == 1 or targetPid == -1 or targetPid == getLocalPid())
    local pName = isLocalTarget and "Voce" or getPlayerName(targetPid)
    showFeedNotification("~g~Sinalizador lancado! Airdrop a caminho de " .. pName .. "...")

    script.run_in_callback(function()
        local dropX, dropY, dropZ = 0, 0, 0
        if isLocalTarget then
            local ped = getLocalPed()
            local pCoords = ENTITY.GET_ENTITY_COORDS(ped, true)
            local forward = getCameraDirection()
            dropX = pCoords.x + forward.x * 15.0
            dropY = pCoords.y + forward.y * 15.0
            dropZ = getGroundZSafe(dropX, dropY, pCoords.z)
        else
            local targetPed = getPlayerPed(targetPid)
            if not isValidEntity(targetPed) then
                showFeedNotification("~r~Jogador alvo nao encontrado.")
                return
            end
            local tCoords = ENTITY.GET_ENTITY_COORDS(targetPed, true)
            dropX = tCoords.x
            dropY = tCoords.y
            dropZ = getGroundZSafe(dropX, dropY, tCoords.z)
        end

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

        -- 2. SPAWN DA CAIXA NO ALTO E QUEDA RÁPIDA SUAVE
        local crateModel = getHash("prop_box_ammo04a")
        STREAMING.REQUEST_MODEL(crateModel)
        local tO = 0
        while not STREAMING.HAS_MODEL_LOADED(crateModel) and tO < 50 do
            script.yield(10)
            tO = tO + 1
        end

        local startZ = dropZ + 65.0
        local crate = nil
        pcall(function()
            if OBJECT and OBJECT.CREATE_OBJECT_NO_OFFSET then
                crate = OBJECT.CREATE_OBJECT_NO_OFFSET(crateModel, dropX, dropY, startZ, true, false, true)
            elseif OBJECT and OBJECT.CREATE_OBJECT then
                crate = OBJECT.CREATE_OBJECT(crateModel, dropX, dropY, startZ, true, false, true)
            end
        end)

        if not isValidEntity(crate) then
            showFeedNotification("~r~Erro ao criar entidade da caixa.")
            return
        end

        pcall(function()
            ENTITY.SET_ENTITY_AS_MISSION_ENTITY(crate, true, true)
            ENTITY.SET_ENTITY_INVINCIBLE(crate, true)
            ENTITY.SET_ENTITY_COLLISION(crate, true, true)
        end)

        -- Queda Rápida e Suave
        local curZ = startZ
        local fallSpeed = 36.0
        while isValidEntity(crate) and curZ > (dropZ + 0.3) do
            curZ = curZ - (fallSpeed * 0.035)
            pcall(function()
                ENTITY.SET_ENTITY_COORDS(crate, dropX, dropY, curZ, false, false, false, true)
                ENTITY.SET_ENTITY_VELOCITY(crate, 0.0, 0.0, -fallSpeed)
            end)
            script.yield(35)
        end

        -- Impacto no Solo e Som
        pcall(function()
            ENTITY.PLACE_ENTITY_ON_GROUND_PROPERLY(crate)
            ENTITY.SET_ENTITY_INVINCIBLE(crate, false)
            if AUDIO and AUDIO.PLAY_SOUND_FRONTEND then
                AUDIO.PLAY_SOUND_FRONTEND(-1, "Airhorn", "DLC_TG_Running_Back_Sounds", true)
            end
        end)

        -- 3. FUMAÇA VERMELHA CONTÍNUA ACOPLADA NA CAIXA
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

        showFeedNotification("~g~Airdrop pousou! Aproxime-se para abrir.")

        -- 4. LOOP DE PROXIMIDADE (AO APROXIMAR, A CAIXA SOME E O CONTEÚDO APARECE)
        local waitTicks = 0
        local opened = false

        while isValidEntity(crate) and waitTicks < 500 and not opened do
            waitTicks = waitTicks + 1
            local cPos = ENTITY.GET_ENTITY_COORDS(crate, true)

            for pid = 0, 31 do
                if isPlayerActive(pid) or pid == getLocalPid() then
                    local pPed = (pid == getLocalPid()) and getLocalPed() or getPlayerPed(pid)
                    if isValidEntity(pPed) and not PED.IS_PED_INJURED(pPed) then
                        local pp = ENTITY.GET_ENTITY_COORDS(pPed, true)
                        local dx = pp.x - cPos.x
                        local dy = pp.y - cPos.y
                        local dz = pp.z - cPos.z
                        local dist = math.sqrt(dx * dx + dy * dy + dz * dz)

                        if dist <= 3.8 then
                            opened = true
                            local openerName = (pid == getLocalPid()) and "Voce" or getPlayerName(pid)

                            -- Para a fumaça e remove a caixa
                            pcall(function()
                                if ptfxLoop and ptfxLoop ~= 0 then
                                    GRAPHICS.STOP_PARTICLE_FX_LOOPED(ptfxLoop, false)
                                    GRAPHICS.REMOVE_PARTICLE_FX(ptfxLoop, false)
                                end
                            end)
                            safeDeleteEntity(crate)

                            if dropType == 1 then
                                -- SAÚDE, COLETE, ARMAS E MUNIÇÃO
                                pcall(function()
                                    local hPickupHash = getHash("PICKUP_HEALTH_STANDARD")
                                    local aPickupHash = getHash("PICKUP_ARMOUR_STANDARD")
                                    if OBJECT and OBJECT.CREATE_AMBIENT_PICKUP then
                                        OBJECT.CREATE_AMBIENT_PICKUP(hPickupHash, cPos.x - 0.7, cPos.y, cPos.z + 0.2, 0, 100, getHash("prop_health_pack_01"), false, true)
                                        OBJECT.CREATE_AMBIENT_PICKUP(aPickupHash, cPos.x + 0.7, cPos.y, cPos.z + 0.2, 0, 100, getHash("prop_armour_pickup_01"), false, true)
                                    end

                                    -- Restaura 100% Vida & Colete
                                    local maxHp = (ENTITY and ENTITY.GET_ENTITY_MAX_HEALTH and ENTITY.GET_ENTITY_MAX_HEALTH(pPed)) or 200
                                    if ENTITY and ENTITY.SET_ENTITY_HEALTH then
                                        local ok = pcall(function() ENTITY.SET_ENTITY_HEALTH(pPed, maxHp, 0, 0) end)
                                        if not ok then ok = pcall(function() ENTITY.SET_ENTITY_HEALTH(pPed, maxHp, 0) end) end
                                        if not ok then pcall(function() ENTITY.SET_ENTITY_HEALTH(pPed, maxHp) end) end
                                    end
                                    if PED and PED.SET_PED_ARMOUR then
                                        pcall(function() PED.SET_PED_ARMOUR(pPed, 100) end)
                                    end

                                    -- Entrega Armamento Pesado
                                    local weapons = {
                                        "WEAPON_MINIGUN", "WEAPON_RAILGUN", "WEAPON_HOMINGLAUNCHER",
                                        "WEAPON_RPG", "WEAPON_SPECIALCARBINE_MK2", "WEAPON_HEAVYSNIPER_MK2",
                                        "WEAPON_COMBATMG_MK2", "WEAPON_PIPEBOMB"
                                    }
                                    for _, wName in ipairs(weapons) do
                                        local wHash = getHash(wName)
                                        if wHash ~= 0 then
                                            WEAPON.GIVE_WEAPON_TO_PED(pPed, wHash, 9999, false, true)
                                            WEAPON.SET_PED_AMMO(pPed, wHash, 9999)
                                        end
                                    end

                                    if AUDIO and AUDIO.PLAY_SOUND_FRONTEND then
                                        AUDIO.PLAY_SOUND_FRONTEND(-1, "PICK_UP_WEAPON", "HUD_FRONTEND_DEFAULT_SOUNDSET", true)
                                    end
                                end)
                                showFeedNotification("~g~" .. openerName .. " resgatou o Suprimento Tatico!")

                            elseif dropType == 2 then
                                -- VEÍCULO MILITAR INSURGENT
                                pcall(function()
                                    local vehHash = getHash("insurgent3")
                                    STREAMING.REQUEST_MODEL(vehHash)
                                    local vO = 0
                                    while not STREAMING.HAS_MODEL_LOADED(vehHash) and vO < 50 do
                                        script.yield(10)
                                        vO = vO + 1
                                    end
                                    if STREAMING.HAS_MODEL_LOADED(vehHash) then
                                        local heading = isValidEntity(pPed) and ENTITY.GET_ENTITY_HEADING(pPed) or 0.0
                                        local veh = VEHICLE.CREATE_VEHICLE(vehHash, cPos.x, cPos.y, cPos.z + 0.3, heading, true, false, false)
                                        if isValidEntity(veh) then
                                            ENTITY.SET_ENTITY_AS_MISSION_ENTITY(veh, true, true)
                                            VEHICLE.SET_VEHICLE_ON_GROUND_PROPERLY(veh)
                                        end
                                    end
                                end)
                                showFeedNotification("~g~Insurgent Custom .50cal entregue!")

                            elseif dropType == 3 then
                                -- ARMADILHA EXPLOSIVA
                                pcall(function()
                                    FIRE.ADD_EXPLOSION(cPos.x, cPos.y, cPos.z, 29, 25.0, true, false, 2.5, false)
                                    FIRE.ADD_EXPLOSION(cPos.x, cPos.y, cPos.z, 3, 12.0, true, false, 1.5, false)
                                end)
                                showFeedNotification("~r~Armadilha do Airdrop detonada!")
                            end
                            break
                        end
                    end
                end
            end
            script.yield(40)
        end
    end)
end

-- Telekinesis per-frame processor
local function processTelekinesis()
    if ChaosState.isHoldingVehicle and isValidEntity(ChaosState.heldVehicle) then
        pcall(function()
            local ped = getLocalPed()
            local pCoords = ENTITY.GET_ENTITY_COORDS(ped, true)
            local forward = getCameraDirection()
            local tx = pCoords.x + forward.x * ChaosState.holdDistance
            local ty = pCoords.y + forward.y * ChaosState.holdDistance
            local tz = pCoords.z + forward.z * ChaosState.holdDistance + 1.5
            ENTITY.SET_ENTITY_COORDS_NO_OFFSET(ChaosState.heldVehicle, tx, ty, tz, false, false, false)
            ENTITY.SET_ENTITY_COLLISION(ChaosState.heldVehicle, false, false)
            ENTITY.FREEZE_ENTITY_POSITION(ChaosState.heldVehicle, true)
        end)
    end
end

-- Player Selectors
local function buildDogfightTargetMenu()
    local items = {}
    local me = getLocalPid()
    table.insert(items, toggleItem("Voce Mesmo (Testar)", function()
        return ChaosState.selectedDogfightPid == -1 or ChaosState.selectedDogfightPid == me
    end, function()
        ChaosState.selectedDogfightPid = -1
        showFeedNotification("Alvo: Voce Mesmo")
    end))
    for pid = 0, 31 do
        if pid ~= me and isPlayerActive(pid) then
            local isNyx = (nyx_detected_users[pid] == true)
            local name = getPlayerName(pid)
            local label = string.format("[%02d]%s %s", pid, isNyx and " [NYX USER]" or "", name)
            local savedPid = pid
            table.insert(items, toggleItem(label, function()
                return ChaosState.selectedDogfightPid == savedPid
            end, function()
                ChaosState.selectedDogfightPid = savedPid
                showFeedNotification("Alvo dos Cacas: " .. name)
            end))
        end
    end
    return items
end

local function buildEarRapeTargetMenu()
    local items = {}
    local me = getLocalPid()
    table.insert(items, toggleItem("Voce Mesmo (Testar)", function()
        return ChaosState.selectedEarRapePid == -1 or ChaosState.selectedEarRapePid == me
    end, function()
        ChaosState.selectedEarRapePid = -1
        showFeedNotification("Alvo: Voce Mesmo")
    end))
    for pid = 0, 31 do
        if pid ~= me and isPlayerActive(pid) then
            local isNyx = (nyx_detected_users[pid] == true)
            local name = getPlayerName(pid)
            local label = string.format("[%02d]%s %s", pid, isNyx and " [NYX USER]" or "", name)
            local savedPid = pid
            table.insert(items, toggleItem(label, function()
                return ChaosState.selectedEarRapePid == savedPid
            end, function()
                ChaosState.selectedEarRapePid = savedPid
                showFeedNotification("Alvo do Ear Rape: " .. name)
            end))
        end
    end
    return items
end

local function buildAirdropTargetMenu()
    local items = {}
    local me = getLocalPid()
    table.insert(items, toggleItem("Na Sua Frente (15 metros)", function()
        return ChaosState.airdropLocationMode == 1
    end, function()
        ChaosState.airdropLocationMode = 1
        ChaosState.selectedAirdropPid = -1
        showFeedNotification("Airdrop: Na sua frente")
    end))
    for pid = 0, 31 do
        if pid ~= me and isPlayerActive(pid) then
            local name = getPlayerName(pid)
            local label = string.format("Entregar em: [%02d] %s", pid, name)
            local savedPid = pid
            table.insert(items, toggleItem(label, function()
                return ChaosState.airdropLocationMode == 2 and ChaosState.selectedAirdropPid == savedPid
            end, function()
                ChaosState.airdropLocationMode = 2
                ChaosState.selectedAirdropPid = savedPid
                showFeedNotification("Destinatario do Airdrop: " .. name)
            end))
        end
    end
    return items
end

-- Submenus
local function buildTelekinesisMenu()
    return {
        toggleItem("Segurar Veiculo com a Forca", function() return ChaosState.isHoldingVehicle end, toggleHoldVehicle),
        actionItem("Arremessar Veiculo com Forca (150m/s)", launchHeldVehicle),
        actionItem("Aumentar Distancia (+5m)", function() ChaosState.holdDistance = ChaosState.holdDistance + 5.0; showFeedNotification("Distancia: " .. ChaosState.holdDistance) end),
        actionItem("Diminuir Distancia (-5m)", function() ChaosState.holdDistance = math.max(5.0, ChaosState.holdDistance - 5.0); showFeedNotification("Distancia: " .. ChaosState.holdDistance) end)
    }
end

local function buildWorldChaosMenu()
    return {
        toggleItem("Vortice Gravitacional (Buraco Negro)", function() return ChaosState.vortexActive end, toggleVortex),
        toggleItem("Escudo Orbital de Carros", function() return ChaosState.vehicleShieldActive end, toggleVehicleShield),
        toggleItem("Chuva de Carros do Ceu", function() return ChaosState.vehicleRainActive end, toggleVehicleRain),
        toggleItem("Onda de Choque Repulsora", function() return ChaosState.pushRepulsorActive end, togglePushRepulsor),
        toggleItem("Invasao Apocalipse Zumbi", function() return ChaosState.zombiePedOutbreakActive end, toggleZombiePedOutbreak)
    }
end

local function buildDogfightSubmenu()
    return {
        submenuItem("Escolher Alvo: " .. getTargetPlayerDisplayName(ChaosState.selectedDogfightPid), buildDogfightTargetMenu),
        toggleItem("1 Caca (Ataque Rapido)", function() return ChaosState.dogfightJetCount == 1 end, function() ChaosState.dogfightJetCount = 1; showFeedNotification("1 Caca selecionado") end),
        toggleItem("2 Cacas (Esquadrao)", function() return ChaosState.dogfightJetCount == 2 end, function() ChaosState.dogfightJetCount = 2; showFeedNotification("2 Cacas selecionados") end),
        toggleItem("3 Cacas (Ataque Pesado)", function() return ChaosState.dogfightJetCount == 3 end, function() ChaosState.dogfightJetCount = 3; showFeedNotification("3 Cacas selecionados") end),
        actionItem("> ENVIAR ATAQUE AEREO AGORA", function() triggerDogfightAttack(ChaosState.selectedDogfightPid, ChaosState.dogfightJetCount) end),
        actionItem("* Remover Todos os Cacas", clearActiveDogfightJets)
    }
end

local function buildEarRapeSubmenu()
    return {
        submenuItem("Escolher Alvo: " .. getTargetPlayerDisplayName(ChaosState.selectedEarRapePid), buildEarRapeTargetMenu),
        toggleItem("Relampagos & Trovoes Cegantes", function() return ChaosState.trollLightning end, function() ChaosState.trollLightning = not ChaosState.trollLightning end),
        toggleItem("Flashbang & Efeito Psicodelico", function() return ChaosState.trollFlashbang end, function() ChaosState.trollFlashbang = not ChaosState.trollFlashbang end),
        actionItem("> Disparo Rapido (5 Segundos)", function() triggerEarRapeTremor(ChaosState.selectedEarRapePid, 5) end),
        actionItem("> Disparo Longo (10 Segundos)", function() triggerEarRapeTremor(ChaosState.selectedEarRapePid, 10) end),
        actionItem("* Parar Todos os Efeitos", stopTrollAudioHarassment)
    }
end

local function buildSessionAttacksMenu()
    return {
        submenuItem("Esquadrao de Cacas 20mm", buildDogfightSubmenu),
        submenuItem("Troll Pesado (Ear Rape & Terremoto)", buildEarRapeSubmenu)
    }
end

local function buildAirdropConfigSubmenu()
    return {
        submenuItem("Destinatario / Local: " .. (ChaosState.airdropLocationMode == 1 and "Na Sua Frente (15m)" or getTargetPlayerDisplayName(ChaosState.selectedAirdropPid)), buildAirdropTargetMenu),
        toggleItem("Saude & Colete 100%", function() return ChaosState.airdropDropType == 1 end, function() ChaosState.airdropDropType = 1 end),
        toggleItem("Insurgent Custom .50cal", function() return ChaosState.airdropDropType == 2 end, function() ChaosState.airdropDropType = 2 end),
        toggleItem("Caixa Armadilha (Trap)", function() return ChaosState.airdropDropType == 3 end, function() ChaosState.airdropDropType = 3 end),
        actionItem("> SOLICITAR AIRDROP AGORA", function() triggerAirdropDrop(ChaosState.airdropDropType, ChaosState.selectedAirdropPid, ChaosState.airdropLocationMode) end)
    }
end

local function buildSpawnAirdropMenu()
    return {
        submenuItem("Airdrop Militar Tatico", buildAirdropConfigSubmenu)
    }
end

------------------------------------------------------------
-- PLAYER MENU
------------------------------------------------------------

Builders.buildPlayerMenu = function()

    return {

        submenuItem(
            "Telecinese & Poderes",
            buildTelekinesisMenu
        ),

        submenuItem(
            "Guarda-roupa",
            Builders.buildWardrobeMenu
        ),

        submenuItem(
            "Assistir",
            Builders.buildSpectateMenu
        ),

        submenuItem(
            "Animações",
            Builders.buildAnimationsMenu
        ),

        submenuItem(
            "Movimento",
            Builders.buildMovementMenu
        ),

        submenuItem(
            "Mods",
            Builders.buildModsMenu
        ),

        submenuItem(
            "Costas",
            Builders.buildBackMenu
        )

    }

end

------------------------------------------------------------
-- PLAYER LIST - PRISÃO
------------------------------------------------------------

Builders.buildArrestPlayerMenu = function()

    local items = {}

    if arrestScene.active then

        table.insert(

            items,

            actionItem(

                "Cancelar cena",

                function()

                    cancelArrestScene()

                    showFeedNotification(
                        "~y~Cena cancelada."
                    )

                end

            )

        )

    end

    local me =
        getLocalPid()

    for pid = 0, 31 do

        if pid ~= me
            and isPlayerActive(pid)
        then

            local savedPid =
                pid

            table.insert(

                items,

                actionItem(

                    getPlayerName(
                        savedPid
                    ),

                    function()

                        startArrestScene(
                            savedPid
                        )

                    end

                )

            )

        end

    end

    if #items == 0 then

        table.insert(

            items,

            {

                name =
                    "Nenhum jogador encontrado",

                type =
                    "label"

            }

        )

    end

    return items

end

------------------------------------------------------------
-- SCRIPTS MENU
------------------------------------------------------------

Builders.buildScriptsMenu = function()

    return {

        submenuItem(

            "Prender player",

            Builders.buildArrestPlayerMenu

        )

    }

end

------------------------------------------------------------
-- PLACEHOLDER
------------------------------------------------------------

local function placeholderMenu(name)

    return function()

        return {

            {

                name =
                    name
                    ..
                    " - em desenvolvimento",

                type =
                    "label"

            }

        }

    end

end

------------------------------------------------------------
-- MAIN MENU
------------------------------------------------------------

Builders.buildMainMenu = function()

    return {

        submenuItem(
            "Jogador",
            Builders.buildPlayerMenu
        ),

        submenuItem(
            "Sessão",
            buildSessionAttacksMenu
        ),

        submenuItem(
            "Spawn",
            buildSpawnAirdropMenu
        ),

        submenuItem(
            "Arma",
            placeholderMenu("Arma")
        ),

        submenuItem(
            "Veículo",
            placeholderMenu("Veículo")
        ),

        submenuItem(
            "Teleportes",
            placeholderMenu("Teleportes")
        ),

        submenuItem(
            "Mundo",
            buildWorldChaosMenu
        ),

        submenuItem(
            "Variados",
            placeholderMenu("Variados")
        ),

        submenuItem(
            "Scripts",
            Builders.buildScriptsMenu
        ),

        submenuItem(
            "Configurações",
            placeholderMenu("Configurações")
        )

    }

end

------------------------------------------------------------
-- MENU STACK
------------------------------------------------------------

local function setMenu(
    id,
    title,
    items
)

    menu.id = id

    menu.title = title

    menu.items = items

    menu.selected = 1

end

local function resetMenu()

    menu.stack = {}

    setMenu(
        "main",
        MENU_NAME,
        Builders.buildMainMenu()
    )

end

local function pushMenu(
    id,
    title,
    items
)

    table.insert(

        menu.stack,

        {

            id =
                menu.id,

            title =
                menu.title,

            items =
                menu.items,

            selected =
                menu.selected

        }

    )

    setMenu(
        id,
        title,
        items
    )

end

local function goBack()

    if #menu.stack == 0 then

        menu.open = false

        resetMenu()

        return

    end

    local previous =
        table.remove(
            menu.stack
        )

    menu.id =
        previous.id

    menu.title =
        previous.title

    menu.items =
        previous.items

    menu.selected =
        previous.selected

end

------------------------------------------------------------
-- ITEM DISPLAY
------------------------------------------------------------

local function getItemDisplay(item)

    local ped =
        getLocalPed()

    if item.type == "component" then

        local value =
            WardrobeState.values[
                item.data.component
            ]

        if value == nil then

            value =
                getComponentDrawable(
                    ped,
                    item.data.component
                )

        end

        return
            item.name
            ..
            "   < "
            ..
            tostring(value)
            ..
            " >"

    end

    if item.type == "texture" then

        local value =
            WardrobeState.textures[
                item.data.component
            ]

        if value == nil then

            value =
                getComponentTexture(
                    ped,
                    item.data.component
                )

        end

        return
            item.name
            ..
            "   < "
            ..
            tostring(value)
            ..
            " >"

    end

    if item.type == "prop" then

        local value =
            WardrobeState.props[
                item.data.prop
            ]

        if value == nil then

            value =
                getPropDrawable(
                    ped,
                    item.data.prop
                )

        end

        return
            item.name
            ..
            "   < "
            ..
            tostring(value)
            ..
            " >"

    end

    if item.type == "facepaint" then

        return
            "Pintura facial   < "
            ..
            tostring(WardrobeState.facePaint)
            ..
            " >"

    end

    return item.name

end

------------------------------------------------------------
-- HEADER
------------------------------------------------------------

local function drawHeader()

    local centerX =
        UI.x
        +
        UI.width / 2

    drawRect(

        centerX,

        UI.y
        +
        UI.headerHeight / 2,

        UI.width,

        UI.headerHeight,

        16,
        16,
        18,
        245

    )

    drawRect(

        centerX,

        UI.y + 0.003,

        UI.width,

        0.006,

        UI.purpleR,
        UI.purpleG,
        UI.purpleB,

        255

    )

    drawText(

        MENU_NAME,

        centerX,

        UI.y + 0.020,

        0.55,

        255,
        255,
        255,
        255,

        true

    )

end

------------------------------------------------------------
-- PAGINAÇÃO
------------------------------------------------------------

local function getVisibleRange()

    local total =
        #menu.items

    if total <= UI.maxVisibleRows then
        return 1, total
    end

    local half =
        math.floor(
            UI.maxVisibleRows / 2
        )

    local first =
        menu.selected - half

    if first < 1 then
        first = 1
    end

    local last =
        first
        +
        UI.maxVisibleRows
        -
        1

    if last > total then

        last = total

        first =
            math.max(

                1,

                last
                -
                UI.maxVisibleRows
                +
                1

            )

    end

    return first, last

end

------------------------------------------------------------
-- DRAW MENU
------------------------------------------------------------

local function drawMenu()

    if not menu.open then
        return
    end

    local centerX =
        UI.x
        +
        UI.width / 2

    drawHeader()

    local titleTop =
        UI.y
        +
        UI.headerHeight

    drawRect(

        centerX,

        titleTop
        +
        UI.titleHeight / 2,

        UI.width,

        UI.titleHeight,

        25,
        25,
        28,
        235

    )

    drawText(

        menu.title,

        UI.textX,

        titleTop + 0.005,

        0.32,

        220,
        220,
        225,
        255,

        false

    )

    local rowsStart =
        titleTop
        +
        UI.titleHeight

    local first, last =
        getVisibleRange()

    local visibleIndex = 0

    for i = first, last do

        visibleIndex =
            visibleIndex + 1

        local item =
            menu.items[i]

        local rowTop =
            rowsStart
            +
            (visibleIndex - 1)
            *
            UI.rowHeight

        local rowCenter =
            rowTop
            +
            UI.rowHeight / 2

        local selected =
            i == menu.selected

        if selected then

            drawRect(

                centerX,
                rowCenter,
                UI.width,
                UI.rowHeight,

                UI.purpleR,
                UI.purpleG,
                UI.purpleB,

                245

            )

        else

            drawRect(

                centerX,
                rowCenter,
                UI.width,
                UI.rowHeight,

                15,
                15,
                17,

                UI.backgroundAlpha

            )

        end

        drawText(

            getItemDisplay(
                item
            ),

            UI.textX,

            rowTop + 0.005,

            0.30,

            255,
            255,
            255,
            255,

            false

        )

        if item.type == "submenu" then

            drawText(
                ">",
                UI.x
                +
                UI.width
                -
                0.017,
                rowTop + 0.005,
                0.32,
                255,
                255,
                255,
                255,
                false
            )

        elseif item.type == "toggle" then

            local active = false
            if item.getState then
                pcall(function() active = item.getState() end)
            end

            if active then
                drawText(
                    "ATIVO",
                    UI.x + UI.width - 0.038,
                    rowTop + 0.006,
                    0.26,
                    50,
                    240,
                    50,
                    255,
                    false
                )
            else
                drawText(
                    "DESATIVADO",
                    UI.x + UI.width - 0.056,
                    rowTop + 0.006,
                    0.26,
                    240,
                    60,
                    60,
                    255,
                    false
                )
            end

        end

    end

    local visibleCount =
        math.max(
            0,
            last - first + 1
        )

    local footerTop =
        rowsStart
        +
        visibleCount
        *
        UI.rowHeight

    drawRect(

        centerX,

        footerTop
        +
        UI.footerHeight / 2,

        UI.width,

        UI.footerHeight,

        22,
        22,
        25,
        240

    )

    drawText(

        tostring(menu.selected)
        ..
        " / "
        ..
        tostring(#menu.items),

        UI.textX,

        footerTop + 0.004,

        0.26,

        200,
        200,
        205,
        255,

        false

    )

    drawText(

        "v"
        ..
        MENU_VERSION,

        UI.x
        +
        UI.width
        -
        0.034,

        footerTop + 0.004,

        0.26,

        200,
        200,
        205,
        255,

        false

    )

end

------------------------------------------------------------
-- MENU CONTROLS
------------------------------------------------------------

local function disableMenuControls()

    disableControl(CONTROLS.UP)
    disableControl(CONTROLS.DOWN)
    disableControl(CONTROLS.LEFT)
    disableControl(CONTROLS.RIGHT)

    disableControl(CONTROLS.ACCEPT)
    disableControl(CONTROLS.CANCEL)

    disableControl(CONTROLS.FRONTEND_ACCEPT)
    disableControl(CONTROLS.FRONTEND_CANCEL)

    disableControl(27)

end

------------------------------------------------------------
-- NAVIGATION
------------------------------------------------------------

local function navigateUp()

    if #menu.items == 0 then
        return
    end

    menu.selected =
        menu.selected - 1

    if menu.selected < 1 then
        menu.selected = #menu.items
    end

end

local function navigateDown()

    if #menu.items == 0 then
        return
    end

    menu.selected =
        menu.selected + 1

    if menu.selected > #menu.items then
        menu.selected = 1
    end

end

local function alterCurrent(direction)

    local item =
        menu.items[
            menu.selected
        ]

    if not item then
        return
    end

    if item.type == "component" then

        changeComponent(
            item.data,
            direction
        )

    elseif item.type == "texture" then

        changeTexture(
            item.data,
            direction
        )

    elseif item.type == "prop" then

        changeProp(
            item.data,
            direction
        )

    elseif item.type == "facepaint" then

        changeFacePaint(
            direction
        )

    end

end

------------------------------------------------------------
-- SELECT
------------------------------------------------------------

local function selectCurrent()

    local item =
        menu.items[
            menu.selected
        ]

    if not item then
        return
    end

    if item.type == "submenu" then

        pushMenu(

            item.name,
            item.name,
            item.builder()

        )

        return

    end

    if item.type == "toggle"
        and item.action
    then

        item.action()
        return

    end

    if item.type == "action"
        and item.action
    then

        item.action()

        if menu.id ==
            "Prender player"
        then

            menu.items =
                Builders.buildArrestPlayerMenu()

            if menu.selected
                >
                #menu.items
            then

                menu.selected =
                    #menu.items

            end

        end

    end

end

------------------------------------------------------------
-- TOGGLE
------------------------------------------------------------

local function toggleMenu()

    menu.open =
        not menu.open

    if not menu.open then
        resetMenu()
    end

end

------------------------------------------------------------
-- MAIN LOOP
------------------------------------------------------------

local function mainLoop()

    resetMenu()

    while true do

        if startupStep < 2 then
            handleStartupNotifications()
        end

        processPendingAnimation()
        processPendingMovement()
        processArrestScene()
        processBackItem()
        processPlayerHotkeys()
        processTelekinesis()

        disableControl(
            CONTROLS.F9
        )

        if pressed(
            CONTROLS.F9
        )
        then

            toggleMenu()

        end

        if menu.open then

            disableMenuControls()

            if pressed(
                CONTROLS.UP
            )
            then

                navigateUp()

            end

            if pressed(
                CONTROLS.DOWN
            )
            then

                navigateDown()

            end

            if pressed(
                CONTROLS.LEFT
            )
            then

                alterCurrent(
                    -1
                )

            end

            if pressed(
                CONTROLS.RIGHT
            )
            then

                alterCurrent(
                    1
                )

            end

            if pressed(
                CONTROLS.ACCEPT
            )
            or pressed(
                CONTROLS.FRONTEND_ACCEPT
            )
            then

                selectCurrent()

            end

            if pressed(
                CONTROLS.CANCEL
            )
            or pressed(
                CONTROLS.FRONTEND_CANCEL
            )
            then

                goBack()

            end

            drawMenu()

        end

        script.yield(0)

    end

end

------------------------------------------------------------
-- START
------------------------------------------------------------

if script
    and script.run_in_callback
then

    script.run_in_callback(

        function()

            mainLoop()

        end

    )

end