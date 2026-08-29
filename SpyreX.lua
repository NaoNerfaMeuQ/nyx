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
        if MISC and MISC.GET_GAME_TIMER then
            value = MISC.GET_GAME_TIMER()
        elseif util and util.current_time_millis then
            value = util.current_time_millis()
        else
            value = math.floor(os.clock() * 1000)
        end
    end)
    local num = tonumber(value) or 0
    if num == 0 then
        num = math.floor(os.clock() * 1000)
    end
    return num
end

------------------------------------------------------------
-- HASH
------------------------------------------------------------

local function getHash(name)
    if type(name) == "number" then return name end
    local hash = 0
    pcall(function()
        if util and util.joaat then
            hash = util.joaat(tostring(name))
        elseif MISC and MISC.GET_HASH_KEY then
            hash = MISC.GET_HASH_KEY(tostring(name))
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
-- DEBUG LOGGER
------------------------------------------------------------

local logFileTargets = {
    "C:\\Users\\Marcos\\AppData\\Roaming\\NewWay\\GTAV Enhanced\\scripts\\SpyreX_debug.log",
    "C:\\Users\\Marcos\\Downloads\\business_manager\\SpyreX_debug.log"
}
pcall(function()
    if filesystem and filesystem.scripts_dir then
        table.insert(logFileTargets, 1, filesystem.scripts_dir() .. "\\SpyreX_debug.log")
        table.insert(logFileTargets, 1, filesystem.scripts_dir() .. "/SpyreX_debug.log")
    end
end)

local function logDebug(tag, msg)
    local tagStr = tostring(tag or "INFO")
    local msgStr = tostring(msg or "")
    local fullMsg = "[" .. tagStr .. "] " .. msgStr

    -- Log no console/arquivo principal do NewWay
    pcall(function()
        if util and util.log then
            util.log("[SpyreX]" .. fullMsg)
        end
    end)

    -- Grava no arquivo dedicado SpyreX_debug.log
    pcall(function()
        local timeStr = "00:00:00"
        pcall(function()
            if os and os.date then
                timeStr = os.date("%H:%M:%S")
            end
        end)
        local line = "[" .. timeStr .. "]" .. fullMsg .. "\n"

        for _, path in ipairs(logFileTargets) do
            local f = io.open(path, "a")
            if f then
                f:write(line)
                f:close()
                break
            end
        end
    end)
end

-- Grava linha inicial na hora do carregamento do script
logDebug("INIT", "=== SpyreX Script Carregado com Sucesso ===")

------------------------------------------------------------
-- INPUT
------------------------------------------------------------

local keyHeld = {}

local function pressed(control)
    local isDown = false
    pcall(function()
        if PAD.IS_DISABLED_CONTROL_PRESSED(0, control) or PAD.IS_CONTROL_PRESSED(0, control) then
            isDown = true
        end
    end)

    if isDown then
        if not keyHeld[control] then
            keyHeld[control] = true
            return true
        end
        return false
    else
        keyHeld[control] = false
        return false
    end
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
    airdropVehicleModel = "oppressor2",
    airdropVehicleName = "Oppressor Mk II",
    dogfightJetCount = 2,
    selectedDogfightPid = -1,
    selectedEarRapePid = -1,
    trollLightning = true,
    trollFlashbang = true,
    activeDogfightJets = {},
    isDogfightSpawning = false,
    dogfightAttackRunning = false,
    lastDogfightSpawnTime = 0,
    activeAirdropCrate = nil,
    isAirdropDropping = false,
    airdropSessionId = 0,
    dogfightSessionId = 0
}

local cancelActiveAirdrop = nil

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
            logDebug("DELETE", string.format("Deleting entity %s", tostring(ent)))
            -- Remove blip anexado se existir
            if HUD and HUD.GET_BLIP_FROM_ENTITY then
                local b = HUD.GET_BLIP_FROM_ENTITY(ent)
                if b and b ~= 0 and HUD.DOES_BLIP_EXIST and HUD.DOES_BLIP_EXIST(b) then
                    HUD.REMOVE_BLIP(b)
                end
            end

            if NETWORK and NETWORK.NETWORK_REQUEST_CONTROL_OF_ENTITY then
                pcall(function() NETWORK.NETWORK_REQUEST_CONTROL_OF_ENTITY(ent) end)
            end
            if ENTITY.SET_ENTITY_AS_MISSION_ENTITY then
                pcall(function() ENTITY.SET_ENTITY_AS_MISSION_ENTITY(ent, true, true) end)
            end

            if entities and entities.delete_by_handle then
                pcall(function() entities.delete_by_handle(ent) end)
            elseif entities and entities.delete then
                pcall(function() entities.delete(ent) end)
            end

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
                if ENTITY.SET_ENTITY_COORDS then
                    pcall(function() ENTITY.SET_ENTITY_COORDS(ent, 0.0, 0.0, -500.0, false, false, false, false) end)
                end
                if ENTITY.SET_ENTITY_AS_NO_LONGER_NEEDED then
                    pcall(function() ENTITY.SET_ENTITY_AS_NO_LONGER_NEEDED(ent) end)
                end
            end
        end
    end)
end

local function purgeAllMapJets()
    local count = 0
    pcall(function()
        local hashes = {
            getHash("lazer"),
            getHash("besra"),
            getHash("hydra"),
            getHash("pyro"),
            getHash("raiju"),
            getHash("strikeforce")
        }
        local pilotHash = getHash("s_m_y_blackops_01")
        local myPed = getLocalPed()

        -- Remove todos os blips de caças (Sprite 16)
        if HUD and HUD.GET_FIRST_BLIP_INFO_ID and HUD.GET_NEXT_BLIP_INFO_ID and HUD.DOES_BLIP_EXIST and HUD.REMOVE_BLIP then
            local b = HUD.GET_FIRST_BLIP_INFO_ID(16)
            while b and b ~= 0 and HUD.DOES_BLIP_EXIST(b) do
                local nextB = HUD.GET_NEXT_BLIP_INFO_ID(16)
                HUD.REMOVE_BLIP(b)
                b = nextB
            end
        end

        -- Varre veículos caças no mapa
        if entities and entities.get_all_vehicles_as_handles then
            local vehs = entities.get_all_vehicles_as_handles()
            for _, v in ipairs(vehs) do
                if isValidEntity(v) then
                    local isPlayerInside = (PED and PED.IS_PED_IN_VEHICLE and PED.IS_PED_IN_VEHICLE(myPed, v, false))
                    if not isPlayerInside then
                        local model = ENTITY.GET_ENTITY_MODEL(v)
                        local match = false
                        for _, h in ipairs(hashes) do
                            if model == h then match = true; break end
                        end
                        if match then
                            if HUD and HUD.GET_BLIP_FROM_ENTITY then
                                local b = HUD.GET_BLIP_FROM_ENTITY(v)
                                if b and b ~= 0 and HUD.DOES_BLIP_EXIST and HUD.DOES_BLIP_EXIST(b) then
                                    HUD.REMOVE_BLIP(b)
                                end
                            end
                            safeDeleteEntity(v)
                            count = count + 1
                        end
                    end
                end
            end
        end

        -- Varre pilotos NPCs de caça no mapa
        if entities and entities.get_all_peds_as_handles then
            local peds = entities.get_all_peds_as_handles()
            for _, p in ipairs(peds) do
                if isValidEntity(p) and not PED.IS_PED_A_PLAYER(p) then
                    local model = ENTITY.GET_ENTITY_MODEL(p)
                    if model == pilotHash then
                        if HUD and HUD.GET_BLIP_FROM_ENTITY then
                            local b = HUD.GET_BLIP_FROM_ENTITY(p)
                            if b and b ~= 0 and HUD.DOES_BLIP_EXIST and HUD.DOES_BLIP_EXIST(b) then
                                HUD.REMOVE_BLIP(b)
                            end
                        end
                        safeDeleteEntity(p)
                        count = count + 1
                    end
                end
            end
        end
    end)
    return count
end

local function clearActiveDogfightJets()
    ChaosState.dogfightAttackRunning = false
    ChaosState.isDogfightSpawning = false
    -- Invalida qualquer callback de spawn pendente
    ChaosState.dogfightSessionId = (ChaosState.dogfightSessionId or 0) + 1

    if ChaosState.activeDogfightJets then
        for _, item in ipairs(ChaosState.activeDogfightJets) do
            pcall(function()
                if item.blip and HUD and HUD.DOES_BLIP_EXIST and HUD.DOES_BLIP_EXIST(item.blip) then
                    HUD.REMOVE_BLIP(item.blip)
                end
                if isValidEntity(item.pilot) then
                    TASK.CLEAR_PED_TASKS(item.pilot)
                    safeDeleteEntity(item.pilot)
                end
                if isValidEntity(item.jet) then
                    safeDeleteEntity(item.jet)
                end
            end)
        end
    end
    ChaosState.activeDogfightJets = {}

    -- Varre e purga todos os caças e blips do mapa
    local purged = purgeAllMapJets()
    showFeedNotification("~y~Todos os cacas e blips foram removidos (" .. tostring(purged) .. " no mapa).")
end

local lastDogfightExecutionTime = 0

local function triggerDogfightAttack(targetPid, count)
    local now = gameTimer()

    if (now - lastDogfightExecutionTime) < 250 then
        return
    end

    lastDogfightExecutionTime = now
    -- Incrementa session ID: invalida qualquer callback de spawn anterior
    ChaosState.dogfightSessionId = (ChaosState.dogfightSessionId or 0) + 1
    local mySessionId = ChaosState.dogfightSessionId

    -- Limpa esquadrão anterior imediatamente antes de spawnar novo
    if ChaosState.activeDogfightJets and #ChaosState.activeDogfightJets > 0 then
        for _, item in ipairs(ChaosState.activeDogfightJets) do
            pcall(function()
                if item.blip and HUD and HUD.DOES_BLIP_EXIST and HUD.DOES_BLIP_EXIST(item.blip) then
                    HUD.REMOVE_BLIP(item.blip)
                end
                if isValidEntity(item.pilot) then safeDeleteEntity(item.pilot) end
                if isValidEntity(item.jet) then safeDeleteEntity(item.jet) end
            end)
        end
        ChaosState.activeDogfightJets = {}
    end

    local jetCount = math.min(5, math.max(1, count or ChaosState.dogfightJetCount or 5))
    local myLocalPid = getLocalPid()
    local actualPid = (targetPid == nil or targetPid == -1) and myLocalPid or targetPid
    local targetName = (actualPid == myLocalPid) and "Voce Mesmo" or getPlayerName(actualPid)

    showFeedNotification(string.format("~g~Decolando %d caca(s) atacando %s!", jetCount, targetName))

    script.run_in_callback(function()
        -- Aborta se uma nova sessão foi iniciada enquanto aguardava
        if ChaosState.dogfightSessionId ~= mySessionId then return end

        local targetPed = (actualPid == myLocalPid) and getLocalPed() or getPlayerPed(actualPid)
        if not isValidEntity(targetPed) then
            showFeedNotification("~r~Ped do alvo nao encontrado.")
            return
        end

        local jetHash = getHash("lazer")
        local pilotHash = getHash("s_m_y_blackops_01")

        pcall(function()
            STREAMING.REQUEST_MODEL(jetHash)
            STREAMING.REQUEST_MODEL(pilotHash)
        end)

        local t = 0
        while (not STREAMING.HAS_MODEL_LOADED(jetHash) or not STREAMING.HAS_MODEL_LOADED(pilotHash)) and t < 60 do
            script.yield(10)
            t = t + 1
        end

        if not STREAMING.HAS_MODEL_LOADED(jetHash) or not STREAMING.HAS_MODEL_LOADED(pilotHash) then
            showFeedNotification("~r~Falha ao carregar modelos dos cacas.")
            return
        end

        local targetCoords = ENTITY.GET_ENTITY_COORDS(targetPed, true)
        local spawnedSquad = {}

        for i = 1, jetCount do
            local angle = ((i - 1) / jetCount) * (math.pi * 2)
            local dist = 120.0 + (i * 20.0)
            local sx = targetCoords.x + math.cos(angle) * dist
            local sy = targetCoords.y + math.sin(angle) * dist
            local sz = targetCoords.z + 180.0 + (i * 15.0)
            local heading = math.deg(math.atan2(-(targetCoords.x - sx), targetCoords.y - sy))

            local jet = nil
            pcall(function()
                if entities and entities.create_vehicle then
                    jet = entities.create_vehicle(jetHash, { x = sx, y = sy, z = sz }, heading)
                end
                if not isValidEntity(jet) and VEHICLE and VEHICLE.CREATE_VEHICLE then
                    jet = VEHICLE.CREATE_VEHICLE(jetHash, sx, sy, sz, heading, true, false, false)
                end
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
                end)

                pcall(function()
                    pilot = PED.CREATE_PED_INSIDE_VEHICLE(jet, 26, pilotHash, -1, true, false)
                end)

                if not isValidEntity(pilot) then
                    pcall(function()
                        if entities and entities.create_ped then
                            pilot = entities.create_ped(26, pilotHash, { x = sx, y = sy, z = sz }, heading)
                        end
                        if not isValidEntity(pilot) and PED and PED.CREATE_PED then
                            pilot = PED.CREATE_PED(26, pilotHash, sx, sy, sz, heading, true, false)
                        end
                        if isValidEntity(pilot) and PED and PED.SET_PED_INTO_VEHICLE then
                            PED.SET_PED_INTO_VEHICLE(pilot, jet, -1)
                        end
                    end)
                end

                pcall(function()
                    if HUD and HUD.ADD_BLIP_FOR_ENTITY then
                        blip = HUD.ADD_BLIP_FOR_ENTITY(jet)
                        if HUD.SET_BLIP_SPRITE then HUD.SET_BLIP_SPRITE(blip, 16) end
                        if HUD.SET_BLIP_COLOUR then HUD.SET_BLIP_COLOUR(blip, 1) end
                        if HUD.SET_BLIP_SCALE then HUD.SET_BLIP_SCALE(blip, 0.85) end
                    end
                end)

                if isValidEntity(pilot) then
                    pcall(function()
                        ENTITY.SET_ENTITY_AS_MISSION_ENTITY(pilot, true, true)
                        PED.SET_BLOCKING_OF_NON_TEMPORARY_EVENTS(pilot, true)
                        PED.SET_PED_KEEP_TASK(pilot, true)

                        local enemyGroup = getHash("HATES_PLAYER")
                        local playerGroup = PED.GET_PED_RELATIONSHIP_GROUP_HASH(targetPed)
                        PED.SET_PED_RELATIONSHIP_GROUP_HASH(pilot, enemyGroup)
                        PED.SET_RELATIONSHIP_BETWEEN_GROUPS(5, enemyGroup, playerGroup)
                        PED.SET_RELATIONSHIP_BETWEEN_GROUPS(5, playerGroup, enemyGroup)

                        PED.SET_PED_COMBAT_ATTRIBUTES(pilot, 1, true)
                        PED.SET_PED_COMBAT_ATTRIBUTES(pilot, 2, true)
                        PED.SET_PED_COMBAT_ATTRIBUTES(pilot, 5, true)
                        PED.SET_PED_COMBAT_ATTRIBUTES(pilot, 46, true)
                        PED.SET_PED_COMBAT_ABILITY(pilot, 2)
                        PED.SET_PED_COMBAT_MOVEMENT(pilot, 3)
                        PED.SET_PED_COMBAT_RANGE(pilot, 2)
                        PED.SET_PED_ACCURACY(pilot, 100)

                        TASK.TASK_COMBAT_PED(pilot, targetPed, 0, 16)
                        if TASK.TASK_PLANE_MISSION then
                            TASK.TASK_PLANE_MISSION(pilot, jet, 0, targetPed, 0.0, 0.0, 0.0, 6, 110.0, 0.0, 90.0, 0, 100.0)
                        elseif TASK.TASK_PLANE_CHASE then
                            TASK.TASK_PLANE_CHASE(pilot, targetPed, 0.0, 0.0, 50.0)
                        end
                    end)
                end

                table.insert(spawnedSquad, {
                    jet = jet,
                    pilot = pilot,
                    blip = blip,
                    targetPid = actualPid,
                    spawnTime = gameTimer()
                })
            end
        end

        STREAMING.SET_MODEL_AS_NO_LONGER_NEEDED(jetHash)
        STREAMING.SET_MODEL_AS_NO_LONGER_NEEDED(pilotHash)

        -- Só aplica se ainda estamos na mesma sessão
        if ChaosState.dogfightSessionId == mySessionId then
            ChaosState.activeDogfightJets = spawnedSquad
            ChaosState.dogfightAttackRunning = (#spawnedSquad > 0)
        else
            -- Sessão cancelada: limpa jatos que criamos
            for _, item in ipairs(spawnedSquad) do
                pcall(function()
                    if item.blip and HUD and HUD.DOES_BLIP_EXIST and HUD.DOES_BLIP_EXIST(item.blip) then HUD.REMOVE_BLIP(item.blip) end
                    if isValidEntity(item.pilot) then safeDeleteEntity(item.pilot) end
                    if isValidEntity(item.jet) then safeDeleteEntity(item.jet) end
                end)
            end
        end
    end)
end

-- Processador contínuo de caças em mainLoop (não bloqueia nada)
local lastDogfightTick = 0
local function processDogfightJets()
    if not ChaosState.dogfightAttackRunning or not ChaosState.activeDogfightJets or #ChaosState.activeDogfightJets == 0 then
        return
    end

    local now = gameTimer()
    if (now - lastDogfightTick) < 400 then
        return
    end
    lastDogfightTick = now

    pcall(function()
        for k = #ChaosState.activeDogfightJets, 1, -1 do
            local item = ChaosState.activeDogfightJets[k]
            local age = now - (item.spawnTime or 0)
            
            -- Durante os primeiros 5 segundos, não remove por falha transitória
            if age > 5000 then
                local dead = false
                if not isValidEntity(item.jet) then
                    dead = true
                elseif isValidEntity(item.pilot) and PED and PED.IS_PED_INJURED and PED.IS_PED_INJURED(item.pilot) then
                    dead = true
                end

                if dead then
                    if item.blip and HUD and HUD.DOES_BLIP_EXIST and HUD.DOES_BLIP_EXIST(item.blip) then
                        HUD.REMOVE_BLIP(item.blip)
                    end
                    table.remove(ChaosState.activeDogfightJets, k)
                end
            end
        end

        if #ChaosState.activeDogfightJets == 0 then
            ChaosState.dogfightAttackRunning = false
            return
        end

        -- Ataque de Canhão Periódico
        for _, item in ipairs(ChaosState.activeDogfightJets) do
            local tPed = (item.targetPid == getLocalPid()) and getLocalPed() or getPlayerPed(item.targetPid)
            if isValidEntity(tPed) and isValidEntity(item.jet) and isValidEntity(item.pilot) then
                local pCoords = ENTITY.GET_ENTITY_COORDS(tPed, true)
                local jCoords = ENTITY.GET_ENTITY_COORDS(item.jet, true)
                local dx = pCoords.x - jCoords.x
                local dy = pCoords.y - jCoords.y
                local dz = pCoords.z - jCoords.z
                local dist = math.sqrt(dx * dx + dy * dy + dz * dz)

                if dist < 450.0 and dist > 15.0 then
                    local fwd = ENTITY.GET_ENTITY_FORWARD_VECTOR(item.jet)
                    local toX, toY, toZ = dx / dist, dy / dist, dz / dist
                    local dot = fwd.x * toX + fwd.y * toY + fwd.z * toZ

                    if dot > 0.60 then
                        local laserHash = getHash("VEHICLE_WEAPON_PLAYER_LAZER")
                        if laserHash == 0 then laserHash = getHash("WEAPON_EXPLOSION") end
                        local leftMuzzle = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(item.jet, -1.8, 4.0, -0.2)
                        local rightMuzzle = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(item.jet, 1.8, 4.0, -0.2)

                        if MISC and MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS then
                            MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS(leftMuzzle.x, leftMuzzle.y, leftMuzzle.z, pCoords.x, pCoords.y, pCoords.z + 0.4, 250, true, laserHash, item.pilot, true, false, 950.0)
                            MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS(rightMuzzle.x, rightMuzzle.y, rightMuzzle.z, pCoords.x, pCoords.y, pCoords.z + 0.4, 250, true, laserHash, item.pilot, true, false, 950.0)
                        end
                    end
                end
            end
        end
    end)
end

-- ============================================================
-- AIRDROP SYSTEM (NON-BLOCKING)
-- ============================================================

local AirdropVehiclePresets = {
    { label = "Oppressor Mk II", model = "oppressor2" },
    { label = "Vigilante", model = "vigilante" },
    { label = "Insurgent Custom .50cal", model = "insurgent3" },
    { label = "Tanque Khanjali", model = "khanjali" },
    { label = "Toreador", model = "toreador" },
    { label = "Deluxo", model = "deluxo" }
}

local function maxUpgradeVehicle(veh)
    if not isValidEntity(veh) then return end
    pcall(function()
        if VEHICLE and VEHICLE.SET_VEHICLE_MOD_KIT then
            VEHICLE.SET_VEHICLE_MOD_KIT(veh, 0)
        end
        if VEHICLE and VEHICLE.TOGGLE_VEHICLE_MOD then
            VEHICLE.TOGGLE_VEHICLE_MOD(veh, 18, true) -- Turbo
        end
        if VEHICLE and VEHICLE.SET_VEHICLE_MOD then
            VEHICLE.SET_VEHICLE_MOD(veh, 11, 3, false) -- Engine Max
            VEHICLE.SET_VEHICLE_MOD(veh, 12, 2, false) -- Brakes Max
            VEHICLE.SET_VEHICLE_MOD(veh, 13, 2, false) -- Transmission Max
            VEHICLE.SET_VEHICLE_MOD(veh, 15, 3, false) -- Suspension
            VEHICLE.SET_VEHICLE_MOD(veh, 16, 4, false) -- Armor 100%
        end
        if VEHICLE and VEHICLE.GET_NUM_VEHICLE_MODS and VEHICLE.SET_VEHICLE_MOD then
            for slot = 0, 50 do
                local count = VEHICLE.GET_NUM_VEHICLE_MODS(veh, slot)
                if count > 0 then
                    VEHICLE.SET_VEHICLE_MOD(veh, slot, count - 1, false)
                end
            end
        end
        if VEHICLE and VEHICLE.SET_VEHICLE_FIXED then
            VEHICLE.SET_VEHICLE_FIXED(veh)
        end
        if VEHICLE and VEHICLE.SET_VEHICLE_DEFORMATION_FIXED then
            VEHICLE.SET_VEHICLE_DEFORMATION_FIXED(veh)
        end
        if VEHICLE and VEHICLE.SET_VEHICLE_DIRT_LEVEL then
            VEHICLE.SET_VEHICLE_DIRT_LEVEL(veh, 0.0)
        end
        if VEHICLE and VEHICLE.SET_VEHICLE_ENGINE_ON then
            VEHICLE.SET_VEHICLE_ENGINE_ON(veh, true, true, false)
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

local ActiveAirdrop = nil

local AIRDROP_MODELS = { "prop_box_wood05a", "prop_box_ammo04a", "prop_mil_crate_01", "prop_box_wood02a", "prop_box_wood01a" }

cancelActiveAirdrop = function(silent)
    if ActiveAirdrop then
        pcall(function()
            if ActiveAirdrop.modelHash then
                pcall(function() STREAMING.SET_MODEL_AS_NO_LONGER_NEEDED(ActiveAirdrop.modelHash) end)
            end
            if ActiveAirdrop.ptfx and ActiveAirdrop.ptfx ~= 0 and GRAPHICS and GRAPHICS.STOP_PARTICLE_FX_LOOPED then
                GRAPHICS.STOP_PARTICLE_FX_LOOPED(ActiveAirdrop.ptfx, false)
                GRAPHICS.REMOVE_PARTICLE_FX(ActiveAirdrop.ptfx, false)
            end
            if isValidEntity(ActiveAirdrop.crate) then
                safeDeleteEntity(ActiveAirdrop.crate)
            end
        end)
        ActiveAirdrop = nil
        if not silent then
            showFeedNotification("~y~Airdrop cancelado e removido.")
        end
    end
end

local function triggerAirdropDrop(dropType, targetPid, locMode)
    cancelActiveAirdrop(true)

    local isLocalTarget = (locMode == 1 or targetPid == -1 or targetPid == getLocalPid())
    local pName = isLocalTarget and "Voce" or getPlayerName(targetPid)

    local dropX, dropY, dropZ = 0, 0, 0
    local coordsOk = false

    if isLocalTarget then
        local ped = getLocalPed()
        if isValidEntity(ped) then
            local pCoords = ENTITY.GET_ENTITY_COORDS(ped, true)
            local forward = getCameraDirection()
            dropX = pCoords.x + forward.x * 15.0
            dropY = pCoords.y + forward.y * 15.0
            dropZ = getGroundZSafe(dropX, dropY, pCoords.z)
            coordsOk = true
        end
    else
        local targetPed = getPlayerPed(targetPid)
        if isValidEntity(targetPed) then
            local tCoords = ENTITY.GET_ENTITY_COORDS(targetPed, true)
            dropX = tCoords.x
            dropY = tCoords.y
            dropZ = getGroundZSafe(dropX, dropY, tCoords.z)
            coordsOk = true
        end
    end

    if not coordsOk then
        showFeedNotification("~r~Jogador alvo nao encontrado.")
        return
    end

    local chosenType = tonumber(dropType) or ChaosState.airdropDropType or 1
    local chosenVehModel = ChaosState.airdropVehicleModel or "oppressor2"
    local chosenVehName = ChaosState.airdropVehicleName or "Oppressor Mk II"

    showFeedNotification("~g~Sinalizador lancado! Airdrop a caminho de " .. pName .. "...")

    local firstHash = getHash(AIRDROP_MODELS[1])
    pcall(function() STREAMING.REQUEST_MODEL(firstHash) end)

    -- Estado inicial: streaming aguarda modelo carregar (processAirdrop cuida do resto por frame)
    ActiveAirdrop = {
        state          = "streaming",
        modelHash      = firstHash,
        modelIdx       = 1,
        streamStart    = gameTimer(),
        dropX          = dropX,
        dropY          = dropY,
        dropZ          = dropZ,
        curZ           = dropZ + 50.0,
        fallSpeed      = 38.0,
        chosenType     = chosenType,
        chosenVehModel = chosenVehModel,
        chosenVehName  = chosenVehName,
        targetPid      = targetPid,
        ptfx           = nil,
        expireTime     = gameTimer() + 70000,
        lastTick       = gameTimer(),
        crate          = nil,
    }
end

-- Processador por frame do Airdrop (máquina de estados — sem callbacks bloqueantes)
local function processAirdrop()
    if not ActiveAirdrop then return end

    local now = gameTimer()

    -- ── ESTADO: streaming ────────────────────────────────────────────────────
    if ActiveAirdrop.state == "streaming" then
        local hash = ActiveAirdrop.modelHash
        local loaded = false
        pcall(function() loaded = STREAMING.HAS_MODEL_LOADED(hash) end)

        if loaded and not ActiveAirdrop.spawning then
            ActiveAirdrop.spawning = true

            local dropX  = ActiveAirdrop.dropX
            local dropY  = ActiveAirdrop.dropY
            local startZ = ActiveAirdrop.curZ
            local modelH = hash

            script.run_in_callback(function()
                if not ActiveAirdrop or ActiveAirdrop.state ~= "streaming" then return end

                local crate = nil
                pcall(function()
                    if entities and entities.create_object then
                        crate = entities.create_object(modelH, { x = dropX, y = dropY, z = startZ })
                    end
                    if not isValidEntity(crate) and OBJECT and OBJECT.CREATE_OBJECT then
                        crate = OBJECT.CREATE_OBJECT(modelH, dropX, dropY, startZ, true, false, true)
                    end
                    if not isValidEntity(crate) and OBJECT and OBJECT.CREATE_OBJECT_NO_OFFSET then
                        crate = OBJECT.CREATE_OBJECT_NO_OFFSET(modelH, dropX, dropY, startZ, true, false, true)
                    end
                end)

                if not ActiveAirdrop then return end

                if isValidEntity(crate) then
                    pcall(function()
                        ENTITY.SET_ENTITY_AS_MISSION_ENTITY(crate, true, true)
                        ENTITY.SET_ENTITY_INVINCIBLE(crate, true)
                        ENTITY.SET_ENTITY_COLLISION(crate, true, true)
                        if AUDIO and AUDIO.PLAY_SOUND_FRONTEND then
                            AUDIO.PLAY_SOUND_FRONTEND(-1, "Beep_Red", "DLC_HEIST_HACKING_SNAKE_SOUNDS", true)
                        end
                    end)
                    ActiveAirdrop.crate    = crate
                    ActiveAirdrop.lastTick = gameTimer()
                    ActiveAirdrop.state    = "falling"
                else
                    local nextIdx = (ActiveAirdrop.modelIdx or 1) + 1
                    if nextIdx <= #AIRDROP_MODELS then
                        pcall(function() STREAMING.SET_MODEL_AS_NO_LONGER_NEEDED(modelH) end)
                        local nextHash = getHash(AIRDROP_MODELS[nextIdx])
                        pcall(function() STREAMING.REQUEST_MODEL(nextHash) end)
                        ActiveAirdrop.modelIdx    = nextIdx
                        ActiveAirdrop.modelHash   = nextHash
                        ActiveAirdrop.streamStart = gameTimer()
                        ActiveAirdrop.spawning    = false
                    else
                        showFeedNotification("~r~Erro: nenhum modelo de caixa disponivel.")
                        ActiveAirdrop = nil
                    end
                end
            end)
            return
        end

        -- Timeout por modelo (4 segundos): tenta o próximo
        if not ActiveAirdrop.spawning and (now - (ActiveAirdrop.streamStart or 0)) > 4000 then
            local nextIdx = (ActiveAirdrop.modelIdx or 1) + 1
            if nextIdx <= #AIRDROP_MODELS then
                pcall(function() STREAMING.SET_MODEL_AS_NO_LONGER_NEEDED(hash) end)
                local nextHash = getHash(AIRDROP_MODELS[nextIdx])
                pcall(function() STREAMING.REQUEST_MODEL(nextHash) end)
                ActiveAirdrop.modelIdx    = nextIdx
                ActiveAirdrop.modelHash   = nextHash
                ActiveAirdrop.streamStart = now
            else
                showFeedNotification("~r~Timeout ao carregar modelo da caixa.")
                ActiveAirdrop = nil
            end
        end
        return
    end

    -- Para os estados seguintes, a crate deve existir
    if not isValidEntity(ActiveAirdrop.crate) then
        ActiveAirdrop = nil
        return
    end

    local dt = (now - ActiveAirdrop.lastTick) / 1000.0
    ActiveAirdrop.lastTick = now
    if dt <= 0 or dt > 0.5 then dt = 0.016 end

    -- ── ESTADO: falling ──────────────────────────────────────────────────────
    if ActiveAirdrop.state == "falling" then
        ActiveAirdrop.curZ = ActiveAirdrop.curZ - (ActiveAirdrop.fallSpeed * dt)
        if ActiveAirdrop.curZ > (ActiveAirdrop.dropZ + 0.3) then
            pcall(function()
                ENTITY.SET_ENTITY_COORDS(ActiveAirdrop.crate, ActiveAirdrop.dropX, ActiveAirdrop.dropY, ActiveAirdrop.curZ, false, false, false, true)
                ENTITY.SET_ENTITY_VELOCITY(ActiveAirdrop.crate, 0.0, 0.0, -ActiveAirdrop.fallSpeed)
            end)
        else
            ActiveAirdrop.state = "landed"
            pcall(function()
                ENTITY.PLACE_ENTITY_ON_GROUND_PROPERLY(ActiveAirdrop.crate)
                ENTITY.SET_ENTITY_INVINCIBLE(ActiveAirdrop.crate, false)
                if AUDIO and AUDIO.PLAY_SOUND_FRONTEND then
                    AUDIO.PLAY_SOUND_FRONTEND(-1, "Airhorn", "DLC_TG_Running_Back_Sounds", true)
                end
            end)
            pcall(function()
                if STREAMING and STREAMING.HAS_NAMED_PTFX_ASSET_LOADED and STREAMING.HAS_NAMED_PTFX_ASSET_LOADED("core") then
                    GRAPHICS.USE_PARTICLE_FX_ASSET("core")
                    ActiveAirdrop.ptfx = GRAPHICS.START_PARTICLE_FX_LOOPED_ON_ENTITY(
                        "exp_grd_flare", ActiveAirdrop.crate, 0.0, 0.0, 0.35, 0.0, 0.0, 0.0, 2.0, false, false, false
                    )
                    if ActiveAirdrop.ptfx and ActiveAirdrop.ptfx ~= 0 and GRAPHICS.SET_PARTICLE_FX_LOOPED_COLOUR then
                        GRAPHICS.SET_PARTICLE_FX_LOOPED_COLOUR(ActiveAirdrop.ptfx, 1.0, 0.1, 0.1, false)
                    end
                end
            end)
            showFeedNotification("~g~Airdrop pousou! Aproxime-se para abrir.")
        end

    -- ── ESTADO: landed ───────────────────────────────────────────────────────
    elseif ActiveAirdrop.state == "landed" then
        if now > ActiveAirdrop.expireTime then
            cancelActiveAirdrop()
            showFeedNotification("~y~Airdrop expirou e foi removido.")
            return
        end

        local cPos = ENTITY.GET_ENTITY_COORDS(ActiveAirdrop.crate, true)
        for pid = 0, 31 do
            if isPlayerActive(pid) or pid == getLocalPid() then
                local pPed = (pid == getLocalPid()) and getLocalPed() or getPlayerPed(pid)
                if isValidEntity(pPed) and not PED.IS_PED_INJURED(pPed) then
                    local pp = ENTITY.GET_ENTITY_COORDS(pPed, true)
                    local dx = pp.x - cPos.x
                    local dy = pp.y - cPos.y
                    local dz = pp.z - cPos.z
                    local dist2D = math.sqrt(dx * dx + dy * dy)

                    if dist2D <= 5.5 and math.abs(dz) <= 4.5 then
                        local openerName = (pid == getLocalPid()) and "Voce" or getPlayerName(pid)
                        local chosenType     = ActiveAirdrop.chosenType
                        local chosenVehModel = ActiveAirdrop.chosenVehModel
                        local chosenVehName  = ActiveAirdrop.chosenVehName
                        local savedCpos      = cPos
                        local savedPid       = pid

                        -- Limpeza silenciosa da crate (o jogador abriu, não é um cancel)
                        pcall(function()
                            if ActiveAirdrop.ptfx and ActiveAirdrop.ptfx ~= 0 and GRAPHICS and GRAPHICS.STOP_PARTICLE_FX_LOOPED then
                                GRAPHICS.STOP_PARTICLE_FX_LOOPED(ActiveAirdrop.ptfx, false)
                                GRAPHICS.REMOVE_PARTICLE_FX(ActiveAirdrop.ptfx, false)
                            end
                            if isValidEntity(ActiveAirdrop.crate) then
                                safeDeleteEntity(ActiveAirdrop.crate)
                            end
                            if ActiveAirdrop.modelHash then
                                pcall(function() STREAMING.SET_MODEL_AS_NO_LONGER_NEEDED(ActiveAirdrop.modelHash) end)
                            end
                        end)
                        ActiveAirdrop = nil

                        if chosenType == 1 then
                            pcall(function()
                                local hPickupHash = getHash("PICKUP_HEALTH_STANDARD")
                                local aPickupHash = getHash("PICKUP_ARMOUR_STANDARD")
                                if OBJECT and OBJECT.CREATE_AMBIENT_PICKUP then
                                    OBJECT.CREATE_AMBIENT_PICKUP(hPickupHash, savedCpos.x - 0.7, savedCpos.y, savedCpos.z + 0.2, 0, 100, getHash("prop_health_pack_01"), false, true)
                                    OBJECT.CREATE_AMBIENT_PICKUP(aPickupHash, savedCpos.x + 0.7, savedCpos.y, savedCpos.z + 0.2, 0, 100, getHash("prop_armour_pickup_01"), false, true)
                                end
                                local maxHp = (ENTITY and ENTITY.GET_ENTITY_MAX_HEALTH and ENTITY.GET_ENTITY_MAX_HEALTH(pPed)) or 200
                                pcall(function() ENTITY.SET_ENTITY_HEALTH(pPed, maxHp, 0, 0) end)
                                pcall(function() ENTITY.SET_ENTITY_HEALTH(pPed, maxHp, 0) end)
                                pcall(function() ENTITY.SET_ENTITY_HEALTH(pPed, maxHp) end)
                                if PED and PED.SET_PED_ARMOUR then
                                    pcall(function() PED.SET_PED_ARMOUR(pPed, 100) end)
                                end
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

                        elseif chosenType == 2 then
                            script.run_in_callback(function()
                                local vehHash = getHash(chosenVehModel)
                                pcall(function() STREAMING.REQUEST_MODEL(vehHash) end)
                                local vO = 0
                                while not STREAMING.HAS_MODEL_LOADED(vehHash) and vO < 50 do
                                    script.yield(10)
                                    vO = vO + 1
                                end

                                if STREAMING.HAS_MODEL_LOADED(vehHash) then
                                    local tPed = (savedPid == getLocalPid()) and getLocalPed() or getPlayerPed(savedPid)
                                    local heading = isValidEntity(tPed) and ENTITY.GET_ENTITY_HEADING(tPed) or 0.0
                                    local veh = nil
                                    pcall(function()
                                        if entities and entities.create_vehicle then
                                            veh = entities.create_vehicle(vehHash, { x = savedCpos.x, y = savedCpos.y, z = savedCpos.z + 0.5 }, heading)
                                        end
                                        if not isValidEntity(veh) and VEHICLE and VEHICLE.CREATE_VEHICLE then
                                            veh = VEHICLE.CREATE_VEHICLE(vehHash, savedCpos.x, savedCpos.y, savedCpos.z + 0.5, heading, true, false, false)
                                        end
                                    end)
                                    if isValidEntity(veh) then
                                        pcall(function()
                                            ENTITY.SET_ENTITY_AS_MISSION_ENTITY(veh, true, true)
                                            ENTITY.SET_ENTITY_COLLISION(veh, true, true)
                                            VEHICLE.SET_VEHICLE_ON_GROUND_PROPERLY(veh)
                                            maxUpgradeVehicle(veh)
                                            if (savedPid == getLocalPid()) and PED and PED.SET_PED_INTO_VEHICLE then
                                                PED.SET_PED_INTO_VEHICLE(getLocalPed(), veh, -1)
                                            end
                                        end)
                                    end
                                    pcall(function() STREAMING.SET_MODEL_AS_NO_LONGER_NEEDED(vehHash) end)
                                    showFeedNotification("~g~" .. chosenVehName .. " entregue com sucesso!")
                                else
                                    showFeedNotification("~r~Erro ao carregar modelo do veiculo (" .. tostring(chosenVehModel) .. ")")
                                end
                            end)

                        elseif chosenType == 3 then
                            pcall(function()
                                FIRE.ADD_EXPLOSION(savedCpos.x, savedCpos.y, savedCpos.z, 29, 25.0, true, false, 2.5, false)
                                FIRE.ADD_EXPLOSION(savedCpos.x, savedCpos.y, savedCpos.z, 3, 12.0, true, false, 1.5, false)
                            end)
                            showFeedNotification("~r~Armadilha do Airdrop detonada!")
                        end
                        break
                    end
                end
            end
        end
    end
end



local EarRapeSoundList = {
    { name = "Airhorn", set = "DLC_TG_Running_Back_Sounds" },
    { name = "Beep_Red", set = "DLC_HEIST_HACKING_SNAKE_SOUNDS" },
    { name = "FLIGHT_SCHOOL_LESSON_PASSED", set = "HUD_AWARDS" },
    { name = "Alarm_Loop", set = "DLC_H4_Prep_FC_Sounds" },
    { name = "Bomb_Disarmed", set = "GTAO_Speed_Convoy_Soundset" },
    { name = "Enemy_Deliver", set = "HUD_FRONTEND_MP_COLLECTABLE_SOUNDS" },
    { name = "10_SEC_WARNING", set = "HUD_MINI_GAME_SOUNDSET" },
    { name = "RAMP_DOWN", set = "DLC_H4_Submarine_Escape_Handling_Sounds" },
    { name = "Wasted", set = "POWER_PLAY_General_Soundset" },
    { name = "Screen_Flash", set = "CELEBRATION_SOUNDSET" },
    { name = "BASE_JUMP_PASSED", set = "HUD_AWARDS" },
    { name = "CHECKPOINT_PERFECT", set = "HUD_MINI_GAME_SOUNDSET" }
}

local function runSingleEarRapeStep(targetPid)
    local actualPid = (targetPid == -1 or targetPid == getLocalPid()) and getLocalPid() or targetPid
    local isLocal = (actualPid == getLocalPid())
    local targetPed = isLocal and getLocalPed() or getPlayerPed(actualPid)
    if not isValidEntity(targetPed) then return end

    local coords = ENTITY.GET_ENTITY_COORDS(targetPed, true)

    pcall(function()
        if isLocal then
            if AUDIO and AUDIO.PLAY_SOUND_FRONTEND then
                for _, snd in ipairs(EarRapeSoundList) do
                    AUDIO.PLAY_SOUND_FRONTEND(-1, snd.name, snd.set, true)
                end
            end
            if CAM and CAM.SHAKE_GAMEPLAY_CAM then
                CAM.SHAKE_GAMEPLAY_CAM("LARGE_EXPLOSION_SHAKE", 5.0)
            end
            if ChaosState.trollFlashbang and GRAPHICS and GRAPHICS.ANIMPOSTFX_PLAY then
                GRAPHICS.ANIMPOSTFX_PLAY("DrugsMichaelAliensFight", 0, true)
            end
        else
            if AUDIO and AUDIO.PLAY_SOUND_FROM_COORD then
                for _, snd in ipairs(EarRapeSoundList) do
                    AUDIO.PLAY_SOUND_FROM_COORD(-1, snd.name, coords.x, coords.y, coords.z, snd.set, true, 250, false)
                end
            end
        end

        -- Efeitos visuais opcionais sem dano
        if ChaosState.trollLightning and MISC and MISC.FORCE_LIGHTNING_FLASH_AT_COORDS then
            MISC.FORCE_LIGHTNING_FLASH_AT_COORDS(coords.x, coords.y, coords.z, 5.0)
        end
    end)
end

local function stopTrollAudioHarassment()
    ChaosState.isTrollAudioActive = false
    ChaosState.trollAudioLoop = false
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
    local actualPid = (targetPid == -1 or targetPid == getLocalPid()) and getLocalPid() or targetPid
    local pName = (actualPid == getLocalPid()) and "Voce Mesmo" or getPlayerName(actualPid)

    if burstSecs and burstSecs > 0 then
        showFeedNotification(string.format("~r~Disparando Ear Rape (%ds) em %s!", burstSecs, pName))
    else
        showFeedNotification("~r~Modo Continuo de Ear Rape ATIVADO em " .. pName .. "!")
    end

    script.run_in_callback(function()
        if burstSecs and burstSecs > 0 then
            ChaosState.isTrollAudioActive = true
            local totalTicks = math.floor((burstSecs * 1000) / 40)
            for i = 1, totalTicks do
                if not ChaosState.isTrollAudioActive then break end
                runSingleEarRapeStep(actualPid)
                script.yield(40)
            end
            stopTrollAudioHarassment()
            showFeedNotification("~y~Burst de Ear Rape finalizado.")
        else
            ChaosState.isTrollAudioActive = true
            ChaosState.trollAudioLoop = true
            while ChaosState.isTrollAudioActive and ChaosState.trollAudioLoop do
                runSingleEarRapeStep(actualPid)
                script.yield(40)
            end
            stopTrollAudioHarassment()
        end
    end)
end

local function toggleContinuousEarRape(targetPid)
    if ChaosState.trollAudioLoop then
        stopTrollAudioHarassment()
    else
        triggerEarRapeTremor(targetPid, 0)
    end
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

local function buildAirdropPlayersListMenu()
    local items = {}
    local me = getLocalPid()
    for pid = 0, 31 do
        if pid ~= me and isPlayerActive(pid) then
            local isNyx = (nyx_detected_users[pid] == true)
            local name = getPlayerName(pid)
            local label = string.format("[%02d]%s %s", pid, isNyx and " [NYX USER]" or "", name)
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
    if #items == 0 then
        table.insert(items, actionItem("Nenhum outro jogador na sessao", function() end))
    end
    return items
end

local function buildAirdropTargetMenu()
    return {
        toggleItem("Seu player", function()
            return ChaosState.airdropLocationMode == 1
        end, function()
            ChaosState.airdropLocationMode = 1
            ChaosState.selectedAirdropPid = -1
            showFeedNotification("Destinatario: Seu player")
        end),
        submenuItem("Jogadores", buildAirdropPlayersListMenu)
    }
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
        actionItem("> ENVIAR ESQUADRAO (5 CACAS) AGORA", function() triggerDogfightAttack(ChaosState.selectedDogfightPid, 5) end),
        actionItem("* Apagar & Destruir Todos os Jatos e Blips", clearActiveDogfightJets)
    }
end

local function buildEarRapeSubmenu()
    return {
        submenuItem("Escolher Alvo: " .. getTargetPlayerDisplayName(ChaosState.selectedEarRapePid), buildEarRapeTargetMenu),
        toggleItem("Modo Continuo (Loop Infinito)", function() return ChaosState.trollAudioLoop end, function() toggleContinuousEarRape(ChaosState.selectedEarRapePid) end),
        toggleItem("Relampagos & Trovoes Cegantes", function() return ChaosState.trollLightning end, function() ChaosState.trollLightning = not ChaosState.trollLightning end),
        toggleItem("Flashbang & Efeito Psicodelico", function() return ChaosState.trollFlashbang end, function() ChaosState.trollFlashbang = not ChaosState.trollFlashbang end),
        actionItem("> Disparo Rapido (5 Segundos)", function() triggerEarRapeTremor(ChaosState.selectedEarRapePid, 5) end),
        actionItem("> Disparo Longo (10 Segundos)", function() triggerEarRapeTremor(ChaosState.selectedEarRapePid, 10) end),
        actionItem("* Parar Todos os Efeitos", stopTrollAudioHarassment)
    }
end

------------------------------------------------------------
-- CONTATOS - CONVITES DE ATIVIDADE & TROLL
------------------------------------------------------------

local ContactInviteState = {
    selectedPid = -1, -- -1 = local player
    subject = "Convite para atividade",
    activityName = "Penthouse",
    iconType = 7, -- Seta de convite de atividade
    delayMs = 450,
    isSpamming = false
}

local ContactInviteList = {
    { name = "Abigail", txd = "CHAR_ABIGAIL" },
    { name = "Todos os Jogadores", txd = "CHAR_ALL_PLAYERS_CONF" },
    { name = "Amanda", txd = "CHAR_AMANDA" },
    { name = "Ammu-Nation", txd = "CHAR_AMMUNATION" },
    { name = "Andreas", txd = "CHAR_ANDREAS" },
    { name = "Antonia", txd = "CHAR_ANTONIA" },
    { name = "Arthur", txd = "CHAR_ARTHUR" },
    { name = "Ashley", txd = "CHAR_ASHLEY" },
    { name = "Bank Bol", txd = "CHAR_BANK_BOL" },
    { name = "Fleeca Bank", txd = "CHAR_BANK_FLEECA" },
    { name = "Maze Bank", txd = "CHAR_BANK_MAZE" },
    { name = "Barry", txd = "CHAR_BARRY" },
    { name = "Beverly", txd = "CHAR_BEVERLY" },
    { name = "Bikesite", txd = "CHAR_BIKESITE" },
    { name = "Blimp", txd = "CHAR_BLIMP" },
    { name = "Bloqueado", txd = "CHAR_BLOCKED" },
    { name = "Boatsite", txd = "CHAR_BOATSITE" },
    { name = "Broken Down Girl", txd = "CHAR_BROKEN_DOWN_GIRL" },
    { name = "Bugstars", txd = "CHAR_BUGSTARS" },
    { name = "Emergencia 911", txd = "CHAR_CALL911" },
    { name = "Carsite", txd = "CHAR_CARSITE" },
    { name = "Carsite2", txd = "CHAR_CARSITE2" },
    { name = "Castro", txd = "CHAR_CASTRO" },
    { name = "Chamada", txd = "CHAR_CHAT_CALL" },
    { name = "Chef", txd = "CHAR_CHEF" },
    { name = "Cheng", txd = "CHAR_CHENG" },
    { name = "Chengsr", txd = "CHAR_CHENGSR" },
    { name = "Chop", txd = "CHAR_CHOP" },
    { name = "Cris", txd = "CHAR_CRIS" },
    { name = "Dave", txd = "CHAR_DAVE" },
    { name = "Padrao", txd = "CHAR_DEFAULT" },
    { name = "Denise", txd = "CHAR_DENISE" },
    { name = "Detonatebomb", txd = "CHAR_DETONATEBOMB" },
    { name = "Detonatephone", txd = "CHAR_DETONATEPHONE" },
    { name = "Devin", txd = "CHAR_DEVIN" },
    { name = "Submarino", txd = "CHAR_DIAL_A_SUB" },
    { name = "Dom", txd = "CHAR_DOM" },
    { name = "Domestic Girl", txd = "CHAR_DOMESTIC_GIRL" },
    { name = "Dreyfuss", txd = "CHAR_DREYFUSS" },
    { name = "Dr Friedlander", txd = "CHAR_DR_FRIEDLANDER" },
    { name = "Epsilon", txd = "CHAR_EPSILON" },
    { name = "Estate Agent", txd = "CHAR_ESTATE_AGENT" },
    { name = "Lifeinvader / Social", txd = "CHAR_FACEBOOK" },
    { name = "Filmnoir", txd = "CHAR_FILMNOIR" },
    { name = "Floyd", txd = "CHAR_FLOYD" },
    { name = "Franklin", txd = "CHAR_FRANKLIN" },
    { name = "Frank Trev Conf", txd = "CHAR_FRANK_TREV_CONF" },
    { name = "Gaymilitary", txd = "CHAR_GAYMILITARY" },
    { name = "Hao", txd = "CHAR_HAO" },
    { name = "Hitcher Girl", txd = "CHAR_HITCHER_GIRL" },
    { name = "Contato Padrao", txd = "CHAR_HUMANDEFAULT" },
    { name = "Hunter", txd = "CHAR_HUNTER" },
    { name = "Jimmy", txd = "CHAR_JIMMY" },
    { name = "Jimmy Boston", txd = "CHAR_JIMMY_BOSTON" },
    { name = "Joe", txd = "CHAR_JOE" },
    { name = "Josef", txd = "CHAR_JOSEF" },
    { name = "Josh", txd = "CHAR_JOSH" },
    { name = "Lamar", txd = "CHAR_LAMAR" },
    { name = "Lazlow", txd = "CHAR_LAZLOW" },
    { name = "Lester", txd = "CHAR_LESTER" },
    { name = "Lester Deathwish", txd = "CHAR_LESTER_DEATHWISH" },
    { name = "Lest Frank Conf", txd = "CHAR_LEST_FRANK_CONF" },
    { name = "Lest Mike Conf", txd = "CHAR_LEST_MIKE_CONF" },
    { name = "Lifeinvader", txd = "CHAR_LIFEINVADER" },
    { name = "Los Santos Customs", txd = "CHAR_LS_CUSTOMS" },
    { name = "LS Tourist Board", txd = "CHAR_LS_TOURIST_BOARD" },
    { name = "Manuel", txd = "CHAR_MANUEL" },
    { name = "Marnie", txd = "CHAR_MARNIE" },
    { name = "Martin Madrazo", txd = "CHAR_MARTIN" },
    { name = "Mary Ann", txd = "CHAR_MARY_ANN" },
    { name = "Maude", txd = "CHAR_MAUDE" },
    { name = "Mecanico", txd = "CHAR_MECHANIC" },
    { name = "Michael", txd = "CHAR_MICHAEL" },
    { name = "Mike Frank Conf", txd = "CHAR_MIKE_FRANK_CONF" },
    { name = "Mike Trev Conf", txd = "CHAR_MIKE_TREV_CONF" },
    { name = "Milsite", txd = "CHAR_MILSITE" },
    { name = "Minotaur", txd = "CHAR_MINOTAUR" },
    { name = "Molly", txd = "CHAR_MOLLY" },
    { name = "Contato Militar", txd = "CHAR_MP_ARMY_CONTACT" },
    { name = "Chefe Biker", txd = "CHAR_MP_BIKER_BOSS" },
    { name = "Mecanico Biker", txd = "CHAR_MP_BIKER_MECHANIC" },
    { name = "Brucie", txd = "CHAR_MP_BRUCIE" },
    { name = "Fam Boss", txd = "CHAR_MP_FAM_BOSS" },
    { name = "Contato FIB", txd = "CHAR_MP_FIB_CONTACT" },
    { name = "Contato Freemode", txd = "CHAR_MP_FM_CONTACT" },
    { name = "Gerald", txd = "CHAR_MP_GERALD" },
    { name = "Julio", txd = "CHAR_MP_JULIO" },
    { name = "Merryweather", txd = "CHAR_MP_MERRYWEATHER" },
    { name = "Mex Boss", txd = "CHAR_MP_MEX_BOSS" },
    { name = "Mex Docks", txd = "CHAR_MP_MEX_DOCKS" },
    { name = "Mex Lt", txd = "CHAR_MP_MEX_LT" },
    { name = "Mors Mutual", txd = "CHAR_MP_MORS_MUTUAL" },
    { name = "Prof Boss", txd = "CHAR_MP_PROF_BOSS" },
    { name = "Ray Lavoy", txd = "CHAR_MP_RAY_LAVOY" },
    { name = "Roberto", txd = "CHAR_MP_ROBERTO" },
    { name = "Snitch", txd = "CHAR_MP_SNITCH" },
    { name = "Stretch", txd = "CHAR_MP_STRETCH" },
    { name = "Vanilla Unicorn", txd = "CHAR_MP_STRIPCLUB_PR" },
    { name = "Mrs Thornhill", txd = "CHAR_MRS_THORNHILL" },
    { name = "Multiplayer", txd = "CHAR_MULTIPLAYER" },
    { name = "Nigel", txd = "CHAR_NIGEL" },
    { name = "Omega", txd = "CHAR_OMEGA" },
    { name = "Oneil", txd = "CHAR_ONEIL" },
    { name = "Ortega", txd = "CHAR_ORTEGA" },
    { name = "Oscar", txd = "CHAR_OSCAR" },
    { name = "Patricia", txd = "CHAR_PATRICIA" },
    { name = "Pegasus", txd = "CHAR_PEGASUS_DELIVERY" },
    { name = "Planesite", txd = "CHAR_PLANESITE" },
    { name = "Trafico de Armas", txd = "CHAR_PROPERTY_ARMS_TRAFFICKING" },
    { name = "Bar Airport", txd = "CHAR_PROPERTY_BAR_AIRPORT" },
    { name = "Bar Bayview", txd = "CHAR_PROPERTY_BAR_BAYVIEW" },
    { name = "Bar Cafe Rojo", txd = "CHAR_PROPERTY_BAR_CAFE_ROJO" },
    { name = "Bar Cockotoos", txd = "CHAR_PROPERTY_BAR_COCKOTOOS" },
    { name = "Bar Eclipse", txd = "CHAR_PROPERTY_BAR_ECLIPSE" },
    { name = "Bar Fes", txd = "CHAR_PROPERTY_BAR_FES" },
    { name = "Bar Hen House", txd = "CHAR_PROPERTY_BAR_HEN_HOUSE" },
    { name = "Bar Hi Men", txd = "CHAR_PROPERTY_BAR_HI_MEN" },
    { name = "Bar Hookies", txd = "CHAR_PROPERTY_BAR_HOOKIES" },
    { name = "Bar Irish", txd = "CHAR_PROPERTY_BAR_IRISH" },
    { name = "Bar Les Bianco", txd = "CHAR_PROPERTY_BAR_LES_BIANCO" },
    { name = "Bar Mirror Park", txd = "CHAR_PROPERTY_BAR_MIRROR_PARK" },
    { name = "Bar Pitchers", txd = "CHAR_PROPERTY_BAR_PITCHERS" },
    { name = "Bar Singletons", txd = "CHAR_PROPERTY_BAR_SINGLETONS" },
    { name = "Bar Tequilala", txd = "CHAR_PROPERTY_BAR_TEQUILALA" },
    { name = "Bar Unbranded", txd = "CHAR_PROPERTY_BAR_UNBRANDED" },
    { name = "Car Mod Shop", txd = "CHAR_PROPERTY_CAR_MOD_SHOP" },
    { name = "Car Scrap Yard", txd = "CHAR_PROPERTY_CAR_SCRAP_YARD" },
    { name = "Cinema Downtown", txd = "CHAR_PROPERTY_CINEMA_DOWNTOWN" },
    { name = "Cinema Morningwood", txd = "CHAR_PROPERTY_CINEMA_MORNINGWOOD" },
    { name = "Cinema Vinewood", txd = "CHAR_PROPERTY_CINEMA_VINEWOOD" },
    { name = "Golf Club", txd = "CHAR_PROPERTY_GOLF_CLUB" },
    { name = "Plane Scrap Yard", txd = "CHAR_PROPERTY_PLANE_SCRAP_YARD" },
    { name = "Sonar Collections", txd = "CHAR_PROPERTY_SONAR_COLLECTIONS" },
    { name = "Taxi Lot", txd = "CHAR_PROPERTY_TAXI_LOT" },
    { name = "Towing Impound", txd = "CHAR_PROPERTY_TOWING_IMPOUND" },
    { name = "Weed Shop", txd = "CHAR_PROPERTY_WEED_SHOP" },
    { name = "Ron", txd = "CHAR_RON" },
    { name = "Saeeda", txd = "CHAR_SAEEDA" },
    { name = "Sasquatch", txd = "CHAR_SASQUATCH" },
    { name = "Simeon", txd = "CHAR_SIMEON" },
    { name = "Rockstar Games", txd = "CHAR_SOCIAL_CLUB" },
    { name = "Solomon", txd = "CHAR_SOLOMON" },
    { name = "Steve", txd = "CHAR_STEVE" },
    { name = "Steve Mike Conf", txd = "CHAR_STEVE_MIKE_CONF" },
    { name = "Steve Trev Conf", txd = "CHAR_STEVE_TREV_CONF" },
    { name = "Stretch", txd = "CHAR_STRETCH" },
    { name = "Chastity", txd = "CHAR_STRIPPER_CHASTITY" },
    { name = "Cheetah", txd = "CHAR_STRIPPER_CHEETAH" },
    { name = "Fufu", txd = "CHAR_STRIPPER_FUFU" },
    { name = "Infernus", txd = "CHAR_STRIPPER_INFERNUS" },
    { name = "Juliet", txd = "CHAR_STRIPPER_JULIET" },
    { name = "Nikki", txd = "CHAR_STRIPPER_NIKKI" },
    { name = "Peach", txd = "CHAR_STRIPPER_PEACH" },
    { name = "Sapphire", txd = "CHAR_STRIPPER_SAPPHIRE" },
    { name = "Tanisha", txd = "CHAR_TANISHA" },
    { name = "Downtown Cab Co.", txd = "CHAR_TAXI" },
    { name = "Liz", txd = "CHAR_TAXI_LIZ" },
    { name = "Tennis Coach", txd = "CHAR_TENNIS_COACH" },
    { name = "Tonya", txd = "CHAR_TOW_TONYA" },
    { name = "Tracey", txd = "CHAR_TRACEY" },
    { name = "Trevor", txd = "CHAR_TREVOR" },
    { name = "Wade", txd = "CHAR_WADE" },
    { name = "Youtube", txd = "CHAR_YOUTUBE" },
    { name = "Creator", txd = "CHAR_CREATOR_PORTRAITS" }
}

local function postContactInvite(contact, targetPid, silent)
    if not contact then return false end

    local myLocalPid = getLocalPid()
    local actualPid = (targetPid == nil or targetPid == -1) and myLocalPid or targetPid
    local isLocal = (actualPid == myLocalPid)
    local targetName = isLocal and "Voce Mesmo" or getPlayerName(actualPid)

    if isLocal then
        -- Exibe o cartão do contato apenas na nossa tela quando o alvo for o jogador local
        pcall(function()
            if HUD and HUD.BEGIN_TEXT_COMMAND_THEFEED_POST then
                HUD.BEGIN_TEXT_COMMAND_THEFEED_POST("STRING")
                HUD.ADD_TEXT_COMPONENT_SUBSTRING_PLAYER_NAME(
                    "~b~Convite~s~ para " .. tostring(ContactInviteState.activityName)
                )

                if HUD.END_TEXT_COMMAND_THEFEED_POST_MESSAGETEXT then
                    HUD.END_TEXT_COMMAND_THEFEED_POST_MESSAGETEXT(
                        contact.txd,
                        contact.txd,
                        true,
                        ContactInviteState.iconType or 7,
                        contact.name,
                        ContactInviteState.subject
                    )
                elseif HUD.END_TEXT_COMMAND_THEFEED_POST_TICKER then
                    HUD.END_TEXT_COMMAND_THEFEED_POST_TICKER(false, false)
                end
            end
        end)
    else
        -- Envia remotamente via SMS de Celular NATIVO e Script Events de Rede para o outro jogador
        local smsText = string.format("[%s] %s: %s", contact.name, ContactInviteState.subject, ContactInviteState.activityName)

        pcall(function()
            -- 1. Disparo via SMS de Celular Nativo do GTA Online (faz o celular do alvo tocar e receber a mensagem)
            if memory and memory.alloc and NETWORK and NETWORK.NETWORK_HANDLE_FROM_PLAYER and NETWORK.NETWORK_SEND_TEXT_MESSAGE then
                local handle = memory.alloc(104)
                NETWORK.NETWORK_HANDLE_FROM_PLAYER(actualPid, handle, 13)
                NETWORK.NETWORK_SEND_TEXT_MESSAGE(smsText, handle)
                memory.free(handle)
            end

            -- 2. Fallback via API de Players/SMS
            if players and players.send_sms then
                players.send_sms(actualPid, smsText)
            end

            -- 3. Script Events de Rede (Penthouse / Apartment / Activity / VIP Invites)
            local playerBit = (bit and bit.lshift) and bit.lshift(1, actualPid) or math.floor(2 ^ actualPid)
            if SCRIPT and SCRIPT.TRIGGER_SCRIPT_EVENT then
                SCRIPT.TRIGGER_SCRIPT_EVENT(1, { 0x3AC33CE8, myLocalPid, actualPid }, 3, playerBit)
                SCRIPT.TRIGGER_SCRIPT_EVENT(1, { 0x1CE29424, myLocalPid, 1, 0, actualPid }, 5, playerBit)
                SCRIPT.TRIGGER_SCRIPT_EVENT(1, { 0x296C839F, myLocalPid, actualPid }, 3, playerBit)
            elseif util and util.trigger_script_event then
                util.trigger_script_event(playerBit, { 0x3AC33CE8, myLocalPid, actualPid })
                util.trigger_script_event(playerBit, { 0x1CE29424, myLocalPid, 1, 0, actualPid })
                util.trigger_script_event(playerBit, { 0x296C839F, myLocalPid, actualPid })
            end
        end)

        if not silent then
            showFeedNotification(string.format("~g~SMS/Convite de %s enviado para %s!", contact.name, targetName))
        end
    end
    return true
end

local function sendAllContactInvites(targetPid)
    if ContactInviteState.isSpamming then
        showFeedNotification("~y~Envio em massa ja esta em andamento!")
        return
    end

    ContactInviteState.isSpamming = true
    local myLocalPid = getLocalPid()
    local actualPid = (targetPid == nil or targetPid == -1) and myLocalPid or targetPid
    local targetName = (actualPid == myLocalPid) and "Voce Mesmo" or getPlayerName(actualPid)

    showFeedNotification("~g~Disparando todos os convites para " .. targetName .. "...")

    script.run_in_callback(function()
        for i = 1, #ContactInviteList do
            if not ContactInviteState.isSpamming then break end
            postContactInvite(ContactInviteList[i], actualPid, true)
            script.yield(ContactInviteState.delayMs)
        end
        ContactInviteState.isSpamming = false
        showFeedNotification("~g~Envio de convites para " .. targetName .. " finalizado!")
    end)
end

local function stopAllContactInvites()
    ContactInviteState.isSpamming = false
    showFeedNotification("~y~Envio de convites interrompido.")
end

local function buildContactInvitesPlayersListMenu()
    local items = {}
    local me = getLocalPid()

    for pid = 0, 31 do
        if pid ~= me and isPlayerActive(pid) then
            local savedPid = pid
            local isNyx = (nyx_detected_users and nyx_detected_users[savedPid] == true)
            local pName = getPlayerName(savedPid)
            local label = string.format("[%02d]%s %s", savedPid, isNyx and " [NYX USER]" or "", pName)

            table.insert(items, toggleItem(label, function()
                return ContactInviteState.selectedPid == savedPid
            end, function()
                ContactInviteState.selectedPid = savedPid
                showFeedNotification("Destinatario: " .. pName)
            end))
        end
    end

    if #items == 0 then
        table.insert(items, { name = "Nenhum outro jogador encontrado", type = "label" })
    end
    return items
end

local function buildContactInviteTargetMenu()
    return {
        toggleItem("Seu player (Local)", function()
            return ContactInviteState.selectedPid == -1
        end, function()
            ContactInviteState.selectedPid = -1
            showFeedNotification("Destinatario: Seu player")
        end),
        submenuItem("Jogadores da Sessao", buildContactInvitesPlayersListMenu)
    }
end

local function buildContactInviteAllListMenu()
    local items = {}
    for i = 1, #ContactInviteList do
        local contact = ContactInviteList[i]
        table.insert(items, actionItem(contact.name, function()
            postContactInvite(contact, ContactInviteState.selectedPid)
        end))
    end
    return items
end

local function buildContactInvitesMenu()
    local targetDisplayName = (ContactInviteState.selectedPid == -1 or ContactInviteState.selectedPid == getLocalPid()) and "Seu player" or getPlayerName(ContactInviteState.selectedPid)

    return {
        submenuItem("Destinatario: " .. targetDisplayName, buildContactInviteTargetMenu),
        actionItem("> ENVIAR TODOS OS CONTATOS (SPAM)", function()
            sendAllContactInvites(ContactInviteState.selectedPid)
        end),
        actionItem("* Parar Envio em Massa", stopAllContactInvites),
        submenuItem("Lista de Contatos Individuais", buildContactInviteAllListMenu)
    }
end

local function buildSessionAttacksMenu()
    return {
        submenuItem("Esquadrao de Cacas 20mm", buildDogfightSubmenu),
        submenuItem("Troll Pesado (Ear Rape & Terremoto)", buildEarRapeSubmenu),
        submenuItem("Contatos - Spam de Convites", buildContactInvitesMenu)
    }
end

local function buildAirdropVehiclesMenu()
    local items = {}
    for _, v in ipairs(AirdropVehiclePresets) do
        table.insert(items, toggleItem(v.label, function()
            return ChaosState.airdropDropType == 2 and ChaosState.airdropVehicleModel == v.model
        end, function()
            ChaosState.airdropDropType = 2
            ChaosState.airdropVehicleModel = v.model
            ChaosState.airdropVehicleName = v.label
            showFeedNotification("Veiculo do Airdrop: " .. v.label)
        end))
    end
    return items
end

local function buildAirdropConfigSubmenu()
    local destLabel = "Seu player"
    if ChaosState.airdropLocationMode == 2 and ChaosState.selectedAirdropPid ~= -1 then
        destLabel = getPlayerName(ChaosState.selectedAirdropPid)
    end

    local vehLabel = ChaosState.airdropVehicleName or "Oppressor Mk II"

    return {
        submenuItem("Destinatario: " .. destLabel, buildAirdropTargetMenu),
        toggleItem("Saude, Colete & Armas 100%", function() return ChaosState.airdropDropType == 1 end, function() ChaosState.airdropDropType = 1; showFeedNotification("Airdrop: Saude & Armamento Tatico") end),
        submenuItem("Veiculo: " .. vehLabel, buildAirdropVehiclesMenu),
        toggleItem("Caixa Armadilha (Trap)", function() return ChaosState.airdropDropType == 3 end, function() ChaosState.airdropDropType = 3; showFeedNotification("Airdrop: Caixa Armadilha") end),
        actionItem("> SOLICITAR AIRDROP AGORA", function() triggerAirdropDrop(ChaosState.airdropDropType, ChaosState.selectedAirdropPid, ChaosState.airdropLocationMode) end),
        actionItem("* Cancelar / Limpar Airdrop Ativo", cancelActiveAirdrop)
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
        ),

        submenuItem(
            "Contatos - Convites (Atividade)",
            buildContactInvitesMenu
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

    logDebug("MENU", string.format("Selected item '%s' (type: %s) in menu '%s' (index %d/%d)", tostring(item.name), tostring(item.type), tostring(menu.id or menu.title), menu.selected, #menu.items))

    if item.type == "submenu" then
        local subItems = {}
        if type(item.builder) == "function" then
            local ok, res = pcall(item.builder)
            if ok and type(res) == "table" then
                subItems = res
            else
                subItems = { { name = "Erro ao carregar menu", type = "label" } }
            end
        elseif type(item.builder) == "table" then
            subItems = item.builder
        else
            subItems = { { name = "Menu vazio", type = "label" } }
        end

        pushMenu(item.name, item.name, subItems)
        return
    end

    if item.type == "toggle"
        and item.action
    then
        pcall(item.action)
        return
    end

    if item.type == "action"
        and item.action
    then
        pcall(item.action)

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

local lastMenuNavTime = 0

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
        processDogfightJets()
        processAirdrop()

        disableControl(
            CONTROLS.F9
        )

        local nowNav = gameTimer()

        if pressed(
            CONTROLS.F9
        )
        and (nowNav - lastMenuNavTime > 250)
        then
            lastMenuNavTime = nowNav
            toggleMenu()
        end

        if menu.open then

            disableMenuControls()

            if (nowNav - lastMenuNavTime) > 150 then

                if pressed(
                    CONTROLS.UP
                )
                then
                    lastMenuNavTime = nowNav
                    navigateUp()

                elseif pressed(
                    CONTROLS.DOWN
                )
                then
                    lastMenuNavTime = nowNav
                    navigateDown()

                elseif pressed(
                    CONTROLS.LEFT
                )
                then
                    lastMenuNavTime = nowNav
                    alterCurrent(
                        -1
                    )

                elseif pressed(
                    CONTROLS.RIGHT
                )
                then
                    lastMenuNavTime = nowNav
                    alterCurrent(
                        1
                    )

                elseif pressed(
                    CONTROLS.ACCEPT
                )
                or pressed(
                    CONTROLS.FRONTEND_ACCEPT
                )
                then
                    lastMenuNavTime = nowNav
                    selectCurrent()

                elseif pressed(
                    CONTROLS.CANCEL
                )
                or pressed(
                    CONTROLS.FRONTEND_CANCEL
                )
                then
                    lastMenuNavTime = nowNav + 120
                    goBack()

                end

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