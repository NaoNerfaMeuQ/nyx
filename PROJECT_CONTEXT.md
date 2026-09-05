# 🚀 PROJECT_CONTEXT.md - Nyx Suite & NewWay Lua API
*Single Source of Truth (SSoT) para Desenvolvimento e Continuidade da Suíte Nyx / SpyreX*

---

## 📌 1. Visão Geral e Repositório
* **Repositório GitHub:** [`https://github.com/NaoNerfaMeuQ/nyx.git`](https://github.com/NaoNerfaMeuQ/nyx.git) (Branch: `main`)
* **Arquivos Principais Ativos:**
  * **`SpyreX.lua`** & **`Nyx.lua`** (8.750 linhas): Código-fonte integral, monolítico, 100% espelhado e traduzido para inglês.
  * **`Nyx V1.0.lua`** (1.3 MB): Versão oficial de produção ofuscada e virtualizada pelo motor `obfuscator.py` (Engine v2.1).
  * **`obfuscator.py`**: Engine de virtualização militar com criptografia de chaves rotativas, checksum anti-tamper e desempacotador acelerado em blocos de 1024 bytes.
  * **`test_homing_missiles.lua`**: Script de teste isolado contendo o motor Vulkan de mísseis múltiplos com mira holográfica e o módulo de amigos/proteção mútua.
* **Caminho de Deploy Local do NewWay:**
  * Script ativo: `%APPDATA%\NewWay\GTAV Enhanced\scripts\SpyreX.lua`, `Nyx.lua` e `Nyx V1.0.lua`
  * Backups automáticos: `%APPDATA%\NewWay\GTAV Enhanced\scripts\backup\`

---

## 📜 2. Histórico Consolidado de Tudo Realizado na Sessão de Hoje

### 💥 A. Canhão Orbital Anti-Blindagem & Spawn Trap (Modo História & Online)
* **Problema Original:** O disparo orbital padrão ou por foguete não causava dano letal em veículos pesadamente blindados (ex: Nightshark, Insurgent, Tanque Rhino) e falhava no modo história.
* **Solução Implementada:**
  * Implementação da matriz de dispersão de explosões padrão Rockstar `blimptest.ysc` com `damageScale = 5000.0`.
  * Cluster com 13 explosões com offsets tridimensionais (Orbital Tag 59, Kosatka Tag 81, Avião Tag 8 e Tanque Tag 31).
  * Finalização letal direta via `PED.APPLY_DAMAGE_TO_PED(ped, 1000000, true)` e `ENTITY.SET_ENTITY_HEALTH(ped, 0)`.
  * **Spawn Trap Infinito:** Loop automático que detecta a morte e aguarda o respawn do alvo para explodi-lo 2 segundos após renascer.
  * **Ghost Mode (Modo Fantasma):** Disparos e explosões anônimos (sem atribuir a morte ao jogador no feed de mortes).

### 🔊 B. Ear Rape & Harassment Sincronizado em Rede
* Adição de efeitos de perturbação audiovisual que todos na sessão ouvem e veem:
  * Rójões e fogos assobiadores (`WEAPON_FIREWORK`);
  * Chuva de sinalizadores cegantes (`WEAPON_FLAREGUN`);
  * Alarme de carro infinito (buzinas repetitivas e piscar de faróis);
  * Rajadas eletrostáticas Up-n-Atomizer e EMP alienígena;
  * Geiser de hidrante sob alta pressão.
* Proteção auditiva local (`Local Mute Mode`) para preservar os ouvidos do usuário enquanto ataca os outros.
* Ações remotas: Detonação remota de EMP no carro do alvo e **Space Launch** (arremesso do veículo à estratosfera).

### 🛡️ C. Vigilante de Segurança (Watchdog) & Host Manager
* **Detector de Vote Kick:** Monitora em tempo real no script freemode tentativas de expulsão contra o jogador local, emitindo alertas críticos na tela e feed.
* **Monitor de Reportes Rockstar:** Monitora baseline e deltas das métricas de perfil (`MPPLY_EXPLOITS`, `MPPLY_VC_HATE`, `MPPLY_TC_HATE`, `MPPLY_BAD_CREW_NAME`).
* **Gerenciador de Host:** Monitora se o jogador é Session Host ou Script Host (Freemode) e permite auto-requisitar Script Host contínuo para controle de clima e NPCs.

### 🌐 D. Tradução Integral da Interface para Inglês (Padrão Stand / 2Take1)
* Todos os 12 menus/abas, botões, checkboxes, inputs, textos de status, popups do feed (`showFeedNotification`) e mensagens de alerta (`notify.*`) foram convertidos para inglês fluente.
* Verificação rigorosa: Todas as 173 funções do código já estavam e permanecem em inglês.
* Comentários internos do código mantidos em português.

### 🎨 E. Padronizações de UI e Limpeza Visual
* **Títulos Limpos:** Removidos todos os marcadores `===` de cabeçalhos.
* **Drone Overwatch:** Raio de proteção padronizado para 100m (botões manuais de 25m a 100m removidos da UI).
* **Ear Rape:** Todos os efeitos ativados por padrão; botão de loop transformado em checkbox reativa.
* **Vehicle Controls:** Removidos da tela os botões de telecinese (lift, hold, launch, slam, carry player in arms), deixando a aba limpa para freio de emergência, placa customizada e estilos (funções backend continuam no código).
* **XML Vehicles:** Aba removida da interface principal para não poluir o menu.
* **Area Chaos:** Removida toda a seção de clima (Lightning Lab / HDR Storm) da aba de caos veicular.
* **Arena Props:** Renomeada de "Arena & Stand Props" para "Arena Props"; seleção de player comentada para spawn rápido no jogador local.
* **Airdrop:** Removido o botão instável de cancelar airdrop (o airdrop agora se auto-gerencia e limpa com segurança no game thread).

### 🔒 F. Virtualização Militar e Ofuscação (Nyx V1.0.lua)
* Criado o motor `obfuscator.py` (v2.1) com desempacotador em blocos de 1024 bytes (`table.unpack` / `string.char`).
* Reduziu o número de alocações de strings de 415.000 para ~400, eliminando travamentos ou freezes no GTA V ao carregar.
* Arquivo `Nyx V1.0.lua` gerado, testado com 100% de integridade reversa e deploy realizado.
* Código fonte e versão ofuscada sincronizados no GitHub.

---

## 🧭 3. Próximo Passo Pendente: Proteção a Amigos (`Friend Protection`)
O usuário confirmou que **ainda não** integrou a proteção a amigos no script principal. O código base já foi testado no arquivo `test_homing_missiles.lua` e deve ser aproveitado na próxima etapa:

### 📋 Checklist de Integração Futura:
1. **Helper de Amigo Social Club / Rockstar:**
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
2. **Pacto de Proteção em Ataques Globais:**
   - No **Canhão Orbital Global** (`targetPid == -2`): Pular jogadores onde `isPlayerFriend(pid) == true`.
   - No **Kamikaze Global** (`triggerKamikazeAllSession`): Não despachar drones suicidas para amigos.
   - Nos **Caças Lazer 20mm** (`triggerDogfightAttackAllSession`): Ignorar amigos ao enviar esquadrões de caças.
   - No **Ear Rape Global**: Não aplicar efeitos nos amigos.
3. **Indicador Visual na Seleção de Alvos (`renderPlayerTargetSelector`):**
   - Adicionar tag `[FRIEND]` em verde ao lado do nome do amigo na lista de botões.
4. **Módulo Amigável (Friendly Features):**
   - Trazer os botões de cura completa (`friendMaxProtect`), espetáculo de fogos (`friendFireworks`), chuva de dinheiro visual (`friendMoneyRain`) e reparo veicular (`friendServiceVehicle`).

---

## 🛡️ 4. Regras Anti-Crash & Arquitetura NewWay (Gotchas Obrigatórios)
1. **Nunca invocar nativas do jogo da thread do ImGui sem callback:**
   Sempre usar `script.run_in_callback(function() ... end)` ao clicar em botões que tocam em entidades, partículas, áudio ou peds.
2. **Nunca usar `GRAPHICS.GET_SCREEN_COORD_FROM_WORLD_COORD`:** Provoca crash C++ instantâneo (0xC0000005). Usar `SHAPETEST.START_EXPENSIVE_SYNCHRONOUS_SHAPE_TEST_LOS_PROBE` para miras ópticas.
3. **Nunca usar `WEAPON.GET_PED_LAST_WEAPON_IMPACT_COORD`:** Incompatível com o invoker de userdata do NewWay.
4. **Tipagem estrita em áudio (`AUDIO.PLAY_SOUND_*`):** O argumento do soundset (`audioRef`) deve ser obrigatoriamente string (`"DLC_BATTLE_DRONE_SOUNDS"` ou `""`), nunca número `0`.
5. **Nativas de PTFX:** `START_NETWORKED_PARTICLE_FX_NON_LOOPED_AT_COORD` possui exatamente 12 parâmetros; o último deve ser explicitamente `false`.
6. **Desempacotamento de código ofuscado:** Nunca iterar byte-a-byte com `string.char` em scripts grandes (> 200 KB). Sempre usar blocos (`table.unpack` em lotes de 1024).
7. **Deploy Seguro:** Sempre gerar backup com timestamp em `%APPDATA%\NewWay\GTAV Enhanced\scripts\backup\` antes de sobrescrever arquivos de produção.
