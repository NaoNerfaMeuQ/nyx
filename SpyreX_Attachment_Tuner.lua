--[[
    SpyreX_Attachment_Tuner.lua
    Ferramenta Standalone para Calibração de Objetos & Props em Tempo Real
    Compatível: NewWay / Stand (GTAV Enhanced)

    Recursos:
    - Spawn e movimentação instantânea de props no seu Ped em tempo real.
    - Suporte a Modelos Customizados (digite qualquer prop do jogo).
    - Seleção rápida de Bones (Spine2, Spine3, Cabeça, Pelvis, Mãos).
    - Ajustes finos de X, Y, Z, Pitch (RotX), Roll (RotY), Yaw (RotZ).
    - Presets salvos (Katanas, Cone, Toilet, Fogueira, Plushies, etc.).
    - Cópia para Clipboard do Windows e salvamento em arquivo de texto.
]]

pcall(function()
    if natives and natives.load_natives then
        natives.load_natives()
    end
end)

------------------------------------------------------------
-- ESTADO & CONFIGURAÇÃO
------------------------------------------------------------

local Tuner = {
    selectedIdx = 1,
    name = "Cone na Cabeca",
    model = "prop_mp_cone_01",
    bone = 24818,
    x = 0.420,
    y = 0.030,
    z = -0.010,
    rx = 0.0,
    ry = 90.0,
    rz = 0.0,
    obj = nil,

    customModel = "prop_mp_cone_01",
    customBone = 24818
}

local TunerPresets = {
    { name = "Cone na Cabeca", model = "prop_mp_cone_01", bone = 24818, x = 0.420, y = 0.030, z = -0.010, rx = 0.0, ry = 90.0, rz = 0.0 },
    { name = "Katana Esquerda", model = "prop_cs_katana_01", bone = 24817, x = 0.500, y = -0.170, z = 0.140, rx = 5.0, ry = -122.0, rz = 0.0 },
    { name = "Katana Direita", model = "prop_cs_katana_01", bone = 24817, x = 0.480, y = -0.170, z = -0.160, rx = -175.0, ry = 242.0, rz = 0.0 },
    { name = "Vaso Sanitario (Toilet)", model = "prop_ld_toilet_01", bone = 11816, x = 0.300, y = -0.150, z = 0.000, rx = 176.0, ry = 270.0, rz = 0.0 },
    { name = "Gaiola na Cabeca", model = "prop_feeder1_cr", bone = 11816, x = 0.0, y = 0.0, z = -0.600, rx = 0.0, ry = 90.0, rz = 0.0 },
    { name = "Fogueira (Campfire)", model = "prop_beach_fire", bone = 11816, x = 0.050, y = -0.050, z = 0.000, rx = 0.0, ry = 90.0, rz = 0.0 },
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

local function isValidEntity(ent)
    if not ent or ent == 0 then return false end
    local valid = false
    pcall(function()
        if ENTITY and ENTITY.DOES_ENTITY_EXIST then
            valid = ENTITY.DOES_ENTITY_EXIST(ent)
        end
    end)
    return valid
end

local function getHash(model)
    if type(model) == "number" then return model end
    if not model or model == "" then return 0 end
    local h = 0
    pcall(function()
        if MISC and MISC.GET_HASH_KEY then
            h = MISC.GET_HASH_KEY(tostring(model))
        end
    end)
    return h
end

local function safeDeleteEntity(ent)
    if not isValidEntity(ent) then return end
    pcall(function()
        if ENTITY and ENTITY.DETACH_ENTITY then
            ENTITY.DETACH_ENTITY(ent, true, true)
        end
        if ENTITY and ENTITY.SET_ENTITY_AS_MISSION_ENTITY then
            ENTITY.SET_ENTITY_AS_MISSION_ENTITY(ent, true, true)
        end
        if OBJECT and OBJECT.DELETE_OBJECT and ENTITY.IS_ENTITY_AN_OBJECT and ENTITY.IS_ENTITY_AN_OBJECT(ent) then
            OBJECT.DELETE_OBJECT(ent)
        elseif ENTITY and ENTITY.DELETE_ENTITY then
            ENTITY.DELETE_ENTITY(ent)
        end
    end)
end

local function safeCreateStuntProp(hash, x, y, z, isDynamic)
    local ent = 0
    pcall(function()
        if OBJECT and OBJECT.CREATE_OBJECT_NO_OFFSET then
            ent = OBJECT.CREATE_OBJECT_NO_OFFSET(hash, x, y, z, true, true, isDynamic or false)
        elseif OBJECT and OBJECT.CREATE_OBJECT then
            ent = OBJECT.CREATE_OBJECT(hash, x, y, z, true, true, isDynamic or false)
        end
    end)
    return ent
end

local function configureStuntEntity(ent)
    if not isValidEntity(ent) then return end
    pcall(function()
        if ENTITY and ENTITY.SET_ENTITY_AS_MISSION_ENTITY then ENTITY.SET_ENTITY_AS_MISSION_ENTITY(ent, true, true) end
        if ENTITY and ENTITY.SET_ENTITY_LOD_DIST then ENTITY.SET_ENTITY_LOD_DIST(ent, 0xFFFF) end
        if ENTITY and ENTITY.SET_ENTITY_COMPLETELY_DISABLE_COLLISION then
            ENTITY.SET_ENTITY_COMPLETELY_DISABLE_COLLISION(ent, false, false)
        end
    end)
end

local function attachEntityDirect(prop, targetPed, boneId, offX, offY, offZ, rotX, rotY, rotZ)
    if not isValidEntity(prop) or not isValidEntity(targetPed) then return end
    pcall(function()
        local boneIdx = -1
        if PED and PED.GET_PED_BONE_INDEX then
            boneIdx = PED.GET_PED_BONE_INDEX(targetPed, boneId)
        end
        if boneIdx == -1 or not boneIdx then boneIdx = 0 end

        if ENTITY and ENTITY.ATTACH_ENTITY_TO_ENTITY then
            ENTITY.ATTACH_ENTITY_TO_ENTITY(
                prop, targetPed, boneIdx,
                offX or 0.0, offY or 0.0, offZ or 0.0,
                rotX or 0.0, rotY or 0.0, rotZ or 0.0,
                false, false, false, false, 2, true
            )
        end
    end)
end

------------------------------------------------------------
-- CONTROLES DO SINTONIZADOR
------------------------------------------------------------

local function removeTestObject()
    script.run_in_callback(function()
        if Tuner.obj and isValidEntity(Tuner.obj) then
            safeDeleteEntity(Tuner.obj)
            Tuner.obj = nil
        end
    end)
end

local function updateTransform()
    local ped = getLocalPed()
    if isValidEntity(Tuner.obj) and isValidEntity(ped) then
        attachEntityDirect(Tuner.obj, ped, Tuner.bone or 24818, Tuner.x, Tuner.y, Tuner.z, Tuner.rx, Tuner.ry, Tuner.rz)
    end
end

local function selectPreset(idx)
    Tuner.selectedIdx = idx
    local p = TunerPresets[idx]
    if p then
        Tuner.name = p.name
        Tuner.model = p.model
        Tuner.bone = p.bone
        Tuner.x = p.x
        Tuner.y = p.y
        Tuner.z = p.z
        Tuner.rx = p.rx
        Tuner.ry = p.ry
        Tuner.rz = p.rz
    end
end

local function spawnTestObject()
    script.run_in_callback(function()
        removeTestObject()
        script.yield(30)

        local ped = getLocalPed()
        if not isValidEntity(ped) then return end

        local modelName = Tuner.model
        if modelName == "custom" then
            modelName = Tuner.customModel or "prop_mp_cone_01"
        end

        local hash = getHash(modelName)
        if not hash or hash == 0 then
            if gui and gui.show_message then gui.show_message("Tuner", "Modelo invalido ou nao encontrado!") end
            return
        end

        STREAMING.REQUEST_MODEL(hash)
        local t = 0
        while not STREAMING.HAS_MODEL_LOADED(hash) and t < 80 do
            script.yield(10)
            t = t + 1
        end

        if not STREAMING.HAS_MODEL_LOADED(hash) then
            if gui and gui.show_message then gui.show_message("Tuner", "Falha ao carregar modelo: " .. tostring(modelName)) end
            return
        end

        local coords = ENTITY.GET_ENTITY_COORDS(ped, true)
        local obj = safeCreateStuntProp(hash, coords.x, coords.y, coords.z, false)
        STREAMING.SET_MODEL_AS_NO_LONGER_NEEDED(hash)

        if not isValidEntity(obj) then
            if gui and gui.show_message then gui.show_message("Tuner", "Erro ao spawnar objeto!") end
            return
        end

        configureStuntEntity(obj)
        attachEntityDirect(obj, ped, Tuner.bone or 24818, Tuner.x, Tuner.y, Tuner.z, Tuner.rx, Tuner.ry, Tuner.rz)

        Tuner.obj = obj
        if gui and gui.show_message then
            gui.show_message("Tuner", "Objeto [" .. tostring(Tuner.name) .. "] spawnado e pronto para ajuste!")
        end
    end)
end

local function copyCoordsToClipboard()
    local text = string.format("[%s] = { %.3f, %.3f, %.3f, %.1f, %.1f, %.1f }",
        Tuner.name, Tuner.x, Tuner.y, Tuner.z, Tuner.rx, Tuner.ry, Tuner.rz)
    pcall(function()
        local p = io.popen("clip", "w")
        if p then
            p:write(text)
            p:close()
        end
    end)
    if gui and gui.show_message then
        gui.show_message("Tuner", "Coordenadas copiadas para a Area de Transferencia!")
    end
end

local function saveCoordsToFile()
    local text = string.format("[%s] Bone: %d = { %.3f, %.3f, %.3f, %.1f, %.1f, %.1f }\n",
        Tuner.name, Tuner.bone, Tuner.x, Tuner.y, Tuner.z, Tuner.rx, Tuner.ry, Tuner.rz)
    pcall(function()
        local f = io.open("coordenadas_tuner.txt", "a")
        if f then
            f:write(text)
            f:close()
        end
    end)
    if gui and gui.show_message then
        gui.show_message("Tuner", "Coordenadas salvas em coordenadas_tuner.txt!")
    end
end

------------------------------------------------------------
-- INTERFACE GRÁFICA (IMGUI)
------------------------------------------------------------

local function renderTunerGUI()
    imgui.spacing()
    imgui.text("=== SPYREX ATTACHMENT TUNER (CALIBRADOR AO VIVO) ===")
    imgui.separator()
    imgui.spacing()

    imgui.text("1. Selecione o Objeto Preset:")
    for idx, item in ipairs(TunerPresets) do
        if (idx - 1) % 3 ~= 0 then imgui.same_line() end
        local isSel = (Tuner.selectedIdx == idx)
        if imgui.button((isSel and "[X] " or "") .. item.name .. "##tun_p_" .. tostring(idx)) then
            selectPreset(idx)
        end
    end

    imgui.spacing(); imgui.separator(); imgui.spacing()
    imgui.text("2. Ou Escolha um Modelo Customizado:")
    
    local cMod, vMod = imgui.input_text("Nome do Prop##cust_mod_str", Tuner.customModel or "prop_mp_cone_01")
    if cMod then
        Tuner.customModel = vMod
        if Tuner.model == "custom" then
            Tuner.name = vMod
        end
    end

    imgui.text("Bone Index Rápido:")
    if imgui.button("Spine3 (24818)##bone_sp3") then Tuner.bone = 24818; updateTransform() end
    imgui.same_line()
    if imgui.button("Spine2 (24817)##bone_sp2") then Tuner.bone = 24817; updateTransform() end
    imgui.same_line()
    if imgui.button("Cabeca / Pelvis (11816)##bone_head") then Tuner.bone = 11816; updateTransform() end
    imgui.same_line()
    if imgui.button("Mao Dir (57005)##bone_rhand") then Tuner.bone = 57005; updateTransform() end

    imgui.spacing(); imgui.separator(); imgui.spacing()
    imgui.text(string.format("Objeto em Teste: %s [Bone: %d]", tostring(Tuner.name), Tuner.bone or 24818))

    if imgui.button("Spawn / Testar no Meu Ped##spawn_test_btn") then
        spawnTestObject()
    end
    imgui.same_line()
    if imgui.button("Remover Objeto do Ped##remove_test_btn") then
        removeTestObject()
    end

    imgui.spacing(); imgui.separator(); imgui.spacing()
    imgui.text("3. Ajuste Fino em Tempo Real (Move no ped instantaneamente):")

    -- X
    imgui.text(string.format("X (Lateral): %.3f", Tuner.x))
    imgui.same_line()
    if imgui.button("-0.05##tun_xm") then Tuner.x = Tuner.x - 0.05; updateTransform() end
    imgui.same_line()
    if imgui.button("+0.05##tun_xp") then Tuner.x = Tuner.x + 0.05; updateTransform() end
    imgui.same_line()
    if imgui.button("-0.01##tun_xsm") then Tuner.x = Tuner.x - 0.01; updateTransform() end
    imgui.same_line()
    if imgui.button("+0.01##tun_xsp") then Tuner.x = Tuner.x + 0.01; updateTransform() end
    imgui.same_line()
    if imgui.button("0##tun_x0") then Tuner.x = 0.0; updateTransform() end

    -- Y
    imgui.text(string.format("Y (Frente/Tras): %.3f", Tuner.y))
    imgui.same_line()
    if imgui.button("-0.05##tun_ym") then Tuner.y = Tuner.y - 0.05; updateTransform() end
    imgui.same_line()
    if imgui.button("+0.05##tun_yp") then Tuner.y = Tuner.y + 0.05; updateTransform() end
    imgui.same_line()
    if imgui.button("-0.01##tun_ysm") then Tuner.y = Tuner.y - 0.01; updateTransform() end
    imgui.same_line()
    if imgui.button("+0.01##tun_ysp") then Tuner.y = Tuner.y + 0.01; updateTransform() end
    imgui.same_line()
    if imgui.button("0##tun_y0") then Tuner.y = 0.0; updateTransform() end

    -- Z
    imgui.text(string.format("Z (Altura): %.3f", Tuner.z))
    imgui.same_line()
    if imgui.button("-0.05##tun_zm") then Tuner.z = Tuner.z - 0.05; updateTransform() end
    imgui.same_line()
    if imgui.button("+0.05##tun_zp") then Tuner.z = Tuner.z + 0.05; updateTransform() end
    imgui.same_line()
    if imgui.button("-0.01##tun_zsm") then Tuner.z = Tuner.z - 0.01; updateTransform() end
    imgui.same_line()
    if imgui.button("+0.01##tun_zsp") then Tuner.z = Tuner.z + 0.01; updateTransform() end
    imgui.same_line()
    if imgui.button("0##tun_z0") then Tuner.z = 0.0; updateTransform() end

    -- RotX
    imgui.text(string.format("RotX (Pitch): %.1f", Tuner.rx))
    imgui.same_line()
    if imgui.button("-10°##tun_rxm10") then Tuner.rx = Tuner.rx - 10.0; updateTransform() end
    imgui.same_line()
    if imgui.button("+10°##tun_rxp10") then Tuner.rx = Tuner.rx + 10.0; updateTransform() end
    imgui.same_line()
    if imgui.button("-2°##tun_rxm2") then Tuner.rx = Tuner.rx - 2.0; updateTransform() end
    imgui.same_line()
    if imgui.button("+2°##tun_rxp2") then Tuner.rx = Tuner.rx + 2.0; updateTransform() end
    imgui.same_line()
    if imgui.button("0°##tun_rx0") then Tuner.rx = 0.0; updateTransform() end

    -- RotY
    imgui.text(string.format("RotY (Roll): %.1f", Tuner.ry))
    imgui.same_line()
    if imgui.button("-10°##tun_rym10") then Tuner.ry = Tuner.ry - 10.0; updateTransform() end
    imgui.same_line()
    if imgui.button("+10°##tun_ryp10") then Tuner.ry = Tuner.ry + 10.0; updateTransform() end
    imgui.same_line()
    if imgui.button("-2°##tun_rym2") then Tuner.ry = Tuner.ry - 2.0; updateTransform() end
    imgui.same_line()
    if imgui.button("+2°##tun_ryp2") then Tuner.ry = Tuner.ry + 2.0; updateTransform() end
    imgui.same_line()
    if imgui.button("0°##tun_ry0") then Tuner.ry = 0.0; updateTransform() end

    -- RotZ
    imgui.text(string.format("RotZ (Yaw): %.1f", Tuner.rz))
    imgui.same_line()
    if imgui.button("-10°##tun_rzm10") then Tuner.rz = Tuner.rz - 10.0; updateTransform() end
    imgui.same_line()
    if imgui.button("+10°##tun_rzp10") then Tuner.rz = Tuner.rz + 10.0; updateTransform() end
    imgui.same_line()
    if imgui.button("-2°##tun_rzm2") then Tuner.rz = Tuner.rz - 2.0; updateTransform() end
    imgui.same_line()
    if imgui.button("+2°##tun_rzp2") then Tuner.rz = Tuner.rz + 2.0; updateTransform() end
    imgui.same_line()
    if imgui.button("0°##tun_rz0") then Tuner.rz = 0.0; updateTransform() end

    imgui.spacing(); imgui.separator(); imgui.spacing()
    local coordsStr = string.format("COPIAR/PRINT: [%s] = { %.3f, %.3f, %.3f, %.1f, %.1f, %.1f }",
        Tuner.name, Tuner.x, Tuner.y, Tuner.z, Tuner.rx, Tuner.ry, Tuner.rz)
    imgui.text(coordsStr)

    if imgui.button("Copiar Coordenadas para Clipboard##btn_copy_clip") then
        copyCoordsToClipboard()
    end
    imgui.same_line()
    if imgui.button("Salvar em coordenadas_tuner.txt##btn_save_file") then
        saveCoordsToFile()
    end
end

------------------------------------------------------------
-- REGISTRO NO MENU
------------------------------------------------------------

local tab = nil
pcall(function()
    if gui and gui.add_tab then
        tab = gui.add_tab("Attachment Tuner")
    end
end)

if tab and tab.add_imgui then
    tab:add_imgui(renderTunerGUI)
else
    gui.add_imgui(renderTunerGUI)
end

if event and event.register_handler and menu_event and menu_event.Unload then
    event.register_handler(menu_event.Unload, function()
        pcall(function()
            removeTestObject()
        end)
    end)
end

if log and log.info then
    log.info("SpyreX_Attachment_Tuner.lua carregado com sucesso!")
end
