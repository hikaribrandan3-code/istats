========================================
ENGLISH
========================================

iStats — First-Time Setup
---------------------------

iStats doesn't have a paid Apple Developer certificate yet, so the first
time you open it, macOS will likely refuse with a message like:

    "iStats.app is damaged and can't be opened. You should move it to
    the Trash."

This is NOT damage — it's macOS being cautious about an app that isn't from
a registered Apple developer. iStats is 100% safe; it only reads system
stats (CPU, RAM, network, disk) locally and never sends anything anywhere.

You only need to do this once, right after installing:

OPTION A — no Terminal required
  1. In Finder, go to Applications.
  2. Right-click (or Control-click) on iStats, then choose "Open" from
     the menu (do NOT just double-click).
  3. A dialog will appear — click "Open" (or "Open Anyway").
  4. If it still won't open, go to System Settings > Privacy & Security,
     scroll down, and click "Open Anyway" next to the iStats message.

OPTION B — one Terminal command
  1. Open Terminal (Applications > Utilities > Terminal).
  2. Paste this exact line and press Return:

     xattr -cr /Applications/iStats.app

  3. Open iStats normally from Applications.

After either option, iStats will open normally every time from then on.

Need help? hikaribrandan3@gmail.com


========================================
ESPAÑOL
========================================

iStats — Configuración inicial
--------------------------------

iStats todavía no tiene un certificado de desarrollador de Apple pago, así
que la primera vez que lo abras, macOS probablemente lo rechace con un
mensaje como:

    "iStats.app está dañado y no se puede abrir. Debes moverlo a la
    papelera."

Esto NO significa que esté dañado — es macOS siendo cauteloso con una app
que no viene de un desarrollador registrado de Apple. iStats es 100%
seguro; solo lee estadísticas del sistema (CPU, RAM, red, disco) de forma
local y nunca envía nada a ningún lado.

Solo necesitás hacer esto una vez, justo después de instalarlo:

OPCIÓN A — sin Terminal
  1. En Finder, andá a Aplicaciones.
  2. Hacé clic derecho (o Control-clic) sobre iStats y elegí "Abrir" en
     el menú (NO hagas doble clic directamente).
  3. Va a aparecer un cuadro de diálogo — hacé clic en "Abrir" (o "Abrir
     de todos modos").
  4. Si todavía no abre, andá a Configuración del Sistema > Privacidad y
     Seguridad, desplazate hacia abajo y hacé clic en "Abrir de todos
     modos" junto al mensaje de iStats.

OPCIÓN B — un comando de Terminal
  1. Abrí Terminal (Aplicaciones > Utilidades > Terminal).
  2. Pegá esta línea exacta y presioná Enter:

     xattr -cr /Applications/iStats.app

  3. Abrí iStats normalmente desde Aplicaciones.

Después de cualquiera de las dos opciones, iStats se abrirá normalmente
de ahí en adelante.

¿Necesitás ayuda? hikaribrandan3@gmail.com


========================================
PORTUGUÊS
========================================

iStats — Configuração inicial
--------------------------------

O iStats ainda não tem um certificado de desenvolvedor Apple pago, então
na primeira vez que você abrir, o macOS provavelmente vai recusar com uma
mensagem parecida com:

    "iStats.app está danificado e não pode ser aberto. Você deve movê-lo
    para o Lixo."

Isso NÃO significa dano — é o macOS sendo cauteloso com um app que não vem
de um desenvolvedor Apple registrado. O iStats é 100% seguro; ele apenas
lê estatísticas do sistema (CPU, RAM, rede, disco) localmente e nunca
envia nada para lugar nenhum.

Você só precisa fazer isso uma vez, logo após instalar:

OPÇÃO A — sem precisar do Terminal
  1. No Finder, vá em Aplicativos.
  2. Clique com o botão direito (ou Control-clique) em iStats e escolha
     "Abrir" no menu (NÃO dê duplo clique diretamente).
  3. Vai aparecer uma caixa de diálogo — clique em "Abrir" (ou "Abrir
     Mesmo Assim").
  4. Se ainda não abrir, vá em Ajustes do Sistema > Privacidade e
     Segurança, role para baixo e clique em "Abrir Mesmo Assim" ao lado
     da mensagem do iStats.

OPÇÃO B — um comando no Terminal
  1. Abra o Terminal (Aplicativos > Utilitários > Terminal).
  2. Cole esta linha exata e aperte Enter:

     xattr -cr /Applications/iStats.app

  3. Abra o iStats normalmente pelos Aplicativos.

Depois de qualquer uma das opções, o iStats vai abrir normalmente a partir
daí.

Precisa de ajuda? hikaribrandan3@gmail.com
