# 🌙 Nyx - GTA V Lua Script

**Nyx** é um script completo e avançado para menus de GTA V (NewWay, Stand, etc.).

---

## 🚀 Principais Recursos:

* 🎯 **Lock Múltiplo de Mísseis Avançado (AcjokerScript Vulkan Engine)**:
  - Mira periscópio holográfica em até 10 alvos simultâneos (`mpsubmarine_periscope`);
  - Sons autênticos de trava Vulkan (`VULKAN_LOCK_ON_AMBER` locking -> `VULKAN_LOCK_ON_RED` locked);
  - Disparo de mísseis teleguiados em alta velocidade com perseguição dinâmica de trajetória;
  - Alternância de pods de disparo (esquerdo e direito) e indicador de recarga HUD;
  - Filtro inteligente de alvos: Jogadores, Veículos Ocupados, Polícia/Exército, Inimigos e **Ignorar Amigos**.

* 🤝 **Módulo de Amigos & Proteção Mútua (Social Club & Stand Friends)**:
  - Reconhecimento automático de amigos da Social Club/Rockstar e lista do menu;
  - **Pacto Geral de Proteção**: Impede ataques acidentais de Jatos Lazer (Dogfight), Drones e Trolling contra amigos;
  - **Ferramentas de Suporte Amigável**:
    - **Max Protect**: Restauração total de vida, colete, remoção de nível de procurado e godmode veicular;
    - **Fogos de Artifício**: Show pirotécnico disparado no céu sobre a posição do amigo;
    - **Chuva de Dinheiro**: Efeito visual de rede com chuva de cédulas;
    - **Serviço Veicular**: Reparo instantâneo, lavagem, upgrade de performance e turbo.

* 🔄 **Auto-Updater Automático do GitHub**:
  - Integração com `stand-lua-auto-updater` para manter o script sempre na versão mais recente direto do repositório `NaoNerfaMeuQ/nyx`;
  - Instalação e atualização transparente e assíncrona sem travar a execução do jogo.

* 🧲 **Telecinese & Física**:
  - Segurar veículos e jogadores com a força da mira;
  - Arremessar veículos a alta velocidade (150 m/s);
  - Controle dinâmico de distância e arremesso vetorial.

* 🌪️ **Caos no Mundo & Gravidade**:
  - **Vórtice Gravitacional**: Atrai todos os veículos da sessão em espiral;
  - **Escudo Orbital**: 6 superesportivos girando ao seu redor como barreira;
  - **Chuva de Carros**: Veículos despencando em velocidade terminal;
  - **Onda de Choque Repulsora**: Lança qualquer carro para longe a 90 m/s;
  - **Apocalipse Zumbi**: Hordas agressivas armadas.

* 🛩️ **Combate Aéreo (Dogfight)**:
  - Esquadrão de caças Lazer armados com canhões explosivos de 20mm perseguindo o alvo selecionado (com filtro protetor de amigos).

* 🔊 **Troll Pesado**:
  - Ear Rape com buzinas e alarmes rápidos;
  - Terremoto na tela e vibração física de controle via ondas de choque;
  - Relâmpagos cegantes e flashbang psicodélico.

* 📦 **Airdrop Militar Tático**:
  - Lançamento de sinalizador com fumaça vermelha realista;
  - Opções: Saúde & Colete 100%, Insurgent Custom .50cal ou Caixa Armadilha (Trap);
  - Escolha de local: Na sua frente (15m) ou direto em outro jogador.

* 🌙 **Aperto de Mão P2P (Rede Nativa)**:
  - Reconhecimento automático entre usuários do Nyx na mesma sessão;
  - Badge exclusiva `[🌙 NYX USER]` na lista de jogadores;
  - Pacto de não-agressão com aviso de confirmação antes de qualquer ataque a membros.

---

## 🧪 Script Isolado para Teste Rápido:
- **`test_homing_missiles.lua`**: Script leve e autocontido criado especificamente para testar o sistema de mísseis com lock sonoro/visual, filtros de amigos e spawns de alvos sem precisar carregar toda a suíte principal.
