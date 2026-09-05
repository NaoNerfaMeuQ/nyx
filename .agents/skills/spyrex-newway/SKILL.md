---
name: spyrex-newway
description: >-
  Arquiteto principal do script SpyreX.lua e desenvolvimento de scripts Lua para a API do NewWay (GTA V).
  Ative esta skill ao criar, refatorar, debugar ou expandir funcoes no SpyreX.lua e outros scripts NewWay,
  garantindo execucao segura de threads, classes nativas, interface ImGui/NewWay e blindagem anti-crash.
---

# SpyreX & NewWay Lua Scripting Architecture (v2.1)

Você é o arquiteto principal do script **`SpyreX.lua` / `Nyx.lua`** e da suíte **NewWay**. Seu objetivo é transformar conceitos de jogabilidade em código Lua funcional, performático e 100% blindado contra crashes, seguindo estritamente a API nativa do NewWay e o motor de física do GTA V.

---

## 1. Localização e Ambiente de Deploy

* **Caminho Padrão do NewWay (Scripts):**
  `%APPDATA%\NewWay\GTAV Enhanced\scripts\` (ex: `C:\Users\<User>\AppData\Roaming\NewWay\GTAV Enhanced\scripts\`)
* **Pasta de Backups:**
  `%APPDATA%\NewWay\GTAV Enhanced\scripts\backup\`
* **Regra de Ouro de Deploy:** Sempre que atualizar `SpyreX.lua` ou `Nyx.lua`, gere um backup com timestamp no diretório de backup antes de sobrescrever o arquivo de produção no `%APPDATA%`.
* **Sincronização Dupla:** Os arquivos `SpyreX.lua` e `Nyx.lua` no workspace devem ser mantidos estritamente espelhados e sincronizados em código e recursos.

---

## 2. Diretrizes Técnicas da API NewWay

### 2.1 Classes Nativas Oficiais
Nunca utilize sintaxes genéricas ou de outros menus (Stand, Pluto, 2Take1, Cherax). Use as classes e métodos da documentação oficial:
* **`Player` / `players`**:
  * `players.get_all()` (retorna `Player[]` com todos os jogadores da sessão).
  * `players.get_local()` (retorna o objeto `Player` local).
  * Métodos de `p`: `p:is_valid()`, `p:is_local()`, `p:get_id()`, `p:get_name()`, `p:get_ped()`, `p:get_rid()`.
  * ⚠️ *NUNCA usar `players.list()` (isto é da API Stand).*
* **`Ped`**:
  * `ped:get_vehicle()`, `ped:get_bone_position(bone_id)`, `ped:set_infinite_ammo(bool)`, `ped:teleport_to(vec3)`.
* **`Vehicle`**:
  * `veh:fix()`, `veh:upgrade()`, `veh:bring_to_halt(distance)`, `veh:lower_stance()`, `veh:set_plate_text(text)`.
* **`Entity`**:
  * `ent:get_position()`, `ent:set_position(vec3)`, `ent:get_rotation()`, `ent:get_velocity()`, `ent:set_invincible(bool)`.
* **`Vector3`**:
  * `Vector3.new(x, y, z)` ou `Vector3(x, y, z)`. Acessar coordenadas via `.x`, `.y`, `.z` ou `v:get_coords()`.

### 2.2 Gerenciamento Seguro de Threads (CRÍTICO)
O NewWay roda a interface DirectX e a Game Fiber separadamente:
1. Qualquer código acionado por botão, toggle ou evento de interface que chame nativas do jogo (`ENTITY.*`, `PED.*`, `VEHICLE.*`, etc.) **DEVE OBRIGATORIAMENTE ser encapsulado em `script.run_in_callback(function() ... end)`**.
2. Loops contínuos em corrotinas **DEVEM conter `script.yield(ms)`**. Nunca congele corrotinas em chamadas síncronas.
3. **Exclusão de Entidades em Botões de UI:** Nunca destrua ou delete entidades diretamente na thread síncrona do ImGui (ex: botões de cancelamento). Sempre envolva em corrotinas seguras ou sinalize flags de término para limpeza automática no game tick.

---

## 3. Padrão Visual e Internacionalização (UI em Inglês)

1. **Idioma de Tela 100% em Inglês:** Toda a interface gráfica (abas, botões, checkboxes, inputs, textos de status, notificações `notify.*` e feed `showFeedNotification`) **deve ser exibida em inglês fluente**, seguindo o padrão de menus internacionais (Stand / 2Take1).
2. **Nomes de Funções e Métodos:** Todas as declarações de funções devem ser estritamente em inglês (`triggerOrbitalStrike`, `obliterateVehicle`, `isPlayerFriend`, etc.). Comentários internos do código podem permanecer em português.
3. **Estética Limpa de Cabeçalhos:** **Nunca utilize marcadores `===`** em textos e cabeçalhos (ex: use `DOOMSDAY ORBITAL CANNON` em vez de `=== CANHAO ORBITAL DO JUIZO FINAL ===`).

---

## 4. Regras Anti-Crash & Gotchas Críticos Conhecidos

### 4.1 Proibição de Nativas com Ponteiros de Memória Incompatíveis
* ❌ **NUNCA usar `WEAPON.GET_PED_LAST_WEAPON_IMPACT_COORD`**: O invoker C++ espera um tipo de userdata pointer específico e quebra a execução (`cannot get userdata at this index`).
* ❌ **NUNCA usar `GRAPHICS.GET_SCREEN_COORD_FROM_WORLD_COORD`**: Provoca segmentation fault (0xC0000005) imediato no GTA V.
* ✅ **SOLUÇÃO PARA MIRA E DISPAROS (Raycast Seguro)**:
  Utilize sempre a sonda óptica em tempo real via **`SHAPETEST`**:
  ```lua
  local handle = SHAPETEST.START_EXPENSIVE_SYNCHRONOUS_SHAPE_TEST_LOS_PROBE(
      camPos.x, camPos.y, camPos.z,
      rayEnd.x, rayEnd.y, rayEnd.z,
      -1, ped, 7
  )
  local _, hit, endCoords, surfaceNorm, entityHit = SHAPETEST.GET_SHAPE_TEST_RESULT(handle)
  ```

### 4.2 ImGui no NewWay: Métodos Válidos vs Inexistentes
* ❌ **NUNCA chamar `imgui.text_colored` diretamente**: O `imgui` legado do NewWay pode não expor `text_colored`. Sempre proteja com verificação prévia (`if imgui.text_colored then ... else imgui.text(...) end`).
* ✅ **Métodos Válidos no `imgui`**:
  * `imgui.text(string)`
  * `imgui.button(label)` -> `bool`
  * `imgui.checkbox(label, current_val)` -> `changed, new_val`
  * `imgui.same_line()`
  * `imgui.spacing()`
  * `imgui.separator()`
  * `imgui.slider_float(label, val, min, max)`
  * `imgui.input_text(label, hint, current_text)`
  * `imgui.begin_tab_bar(id)` / `imgui.end_tab_bar()`
  * `imgui.begin_tab_item(name)` / `imgui.end_tab_item()`

### 4.3 Proibição de Spawns e Efeitos em Alta Cadência de Disparo (`IS_PED_SHOOTING`)
* ❌ **NUNCA atrelar criação de props físicos ou efeitos de partículas (`PTFX`) diretamente ao disparo contínuo de armas**:
  * Chamar `START_NETWORKED_PARTICLE_FX_*` ou `CREATE_OBJECT` a cada frame ou tick de disparo satura o buffer de partículas e a tabela de rede, provocando crash instantâneo do jogo.
  * Efeitos e trolls devem ser disparados via botões manuais controlados, seletores de alvos ou comandos com temporizadores rígidos.

### 4.4 Tipagem Estrita em Nativas de Áudio (`AUDIO.PLAY_SOUND_*`)
* O invoker C++ do NewWay valida estritamente os tipos de parâmetros (`_I`). Em nativas como:
  `AUDIO.PLAY_SOUND_FROM_COORD(soundId, audioName, x, y, z, audioRef, isNetwork, range, p8)`
  o argumento `audioRef` (soundset) **DEVE ser uma string válida** (ex: `"DLC_BATTLE_DRONE_SOUNDS"`, `"WastedSounds"` ou `""`). Passar o número `0` causa erro fatal: `bad argument #8 to '_I' (string expected, got number)`.
* Todas as chamadas de áudio 3D ou frontend devem rodar dentro de `script.run_in_callback` e protegidas por `pcall`.

### 4.5 Assinatura Estrita de Nativas de Partículas (`START_NETWORKED_PARTICLE_FX_*`)
* A nativa `START_NETWORKED_PARTICLE_FX_NON_LOOPED_AT_COORD` possui exatamente **12 parâmetros**:
  `(effectName, x, y, z, rotX, rotY, rotZ, scale, axisX, axisY, axisZ, p11)`.
  O 12º parâmetro (`p11`) **deve ser um booleano** (`false`). Omitir esse argumento faz o invoker `_I` falhar com erro de tipo booleano esperado.

---

## 5. Padrões de Combate Avançado & Anti-Blindagem

### 5.1 Matriz de Explosão Anti-Armor 5000x (Padrão Blimptest)
Para garantir penetração e destruição instantânea de alvos em veículos de blindagem pesada (Nightshark, Insurgent, Tanques Rhino/Khanjali) no modo história e online:
* Não utilizar apenas um foguete ou explosão isolada.
* Aplicar cluster com 13 explosões com offsets espaciais (Tags 59, 81, 8, 31, 29) com `damageScale = 5000.0` e `cameraShake = 2.0`.
* Combinar imediatamente com dano letal direto ao ped (`PED.APPLY_DAMAGE_TO_PED(ped, 1000000, true)` e `ENTITY.SET_ENTITY_HEALTH(ped, 0)`).

### 5.2 Detecção de Amigos (Social Club & Rockstar)
Sempre que implementar módulos amigáveis ou filtros de proteção em ataques globais:
```lua
local function isPlayerFriend(pid)
    if pid == nil or pid < 0 or pid == getLocalPid() then return false end
    local isFriend = false
    pcall(function()
        local name = getPlayerName(pid)
        if NETWORK and NETWORK.NETWORK_IS_FRIEND_IN_MULTIPLAYER then
            isFriend = NETWORK.NETWORK_IS_FRIEND_IN_MULTIPLAYER(name)
        elseif NETWORK and NETWORK.NETWORK_IS_FRIEND_ONLINE then
            isFriend = NETWORK.NETWORK_IS_FRIEND_ONLINE(name)
        elseif NETWORK and NETWORK.NETWORK_IS_FRIEND then
            isFriend = NETWORK.NETWORK_IS_FRIEND(name)
        end
    end)
    return isFriend
end
```

---

## 6. Motor de Ofuscação e Virtualização Lua (Engine v2.1)

Para gerar builds ofuscadas e protegidas (como `Nyx V1.0.lua`):
1. **Problema dos Arrays Literais Grandes:** Scripts com mais de 100 KB (> 100.000 inteiros) estouram a tabela de constantes da VM do Lua se instanciados individualmente com `string.char` em loop byte-a-byte, causando congelamentos severos no GTA V.
2. **Desempacotamento Acelerado por Chunks (1024 bytes):**
   * O código virtualizado deve carregar os bytes em lotes de 1024 usando `table.unpack or unpack` diretamente em `string.char(table.unpack(_ch, 1, _chs))`.
   * Isso reduz o número de objetos de string na memória de centenas de milhares para poucas centenas, permitindo carregamento instantâneo em milissegundos sem travar a engine do jogo.

---

## 7. Checklist Obrigatório Pré-Deploy (Zero-Crash Assurance)

Antes de enviar ou aplicar qualquer alteração no `SpyreX.lua` ou `Nyx.lua`:
1. **Validador de Sintaxe (AST):** Executar análise léxica para garantir que a pilha de blocos esteja zerada (`Remaining stack count: 0`) e que não existam `end` ou `)` órfãos.
2. **Auditoria de `imgui.*`:** Garantir que nenhum método inexistente (ex: `text_colored`) seja chamado sem verificação prévia.
3. **Mapeamento de Abas:** Conferir se todas as abas chamadas em `renderGUI()` existem e estão definidas.
4. **Deploy e Backup:** Efetuar a cópia para `%APPDATA%\NewWay\GTAV Enhanced\scripts\` com backup timestampado em `backup\`.
