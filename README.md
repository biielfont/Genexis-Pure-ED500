# Genexis-Pure-ED500
Copia de mi publicación en el foro de Bandaancha: -> [POST](https://bandaancha.eu/foros/tutorial-acceso-root-completo-pure-ed500-1757239) <br />
Enlace archivado en Wayback Machine -> [Wayback](https://web.archive.org/web/20250917144511/https://bandaancha.eu/foros/tutorial-acceso-root-completo-pure-ed500-1757239)

Este proyecto documenta el proceso de obtención de acceso root completo en el router Genexis Pure ED500 (Adamo), basado en OpenWrt modificado por Iopsys con interfaz JUCI. 
A través de UART y modificaciones en el arranque (/etc/preinit), se logra persistencia de credenciales, acceso administrativo y eliminación total del "backdoor" TR-069 (icwmp, icwmpd, icwmp_stund). Se incluye análisis detallado de la gestión de contraseñas vía UCI y estructura interna de usuarios.

# Introducción

El router Genexis Pure ED500, distribuido por Adamo, ejecuta una variante de OpenWrt modificada por Iopsys, con la interfaz web JUCI.

El firmware es cerrado y carece de documentación oficial, pero tras un análisis exhaustivo del dispositivo fue posible obtener acceso root completo, habilitar privilegios de administrador en la interfaz web y desactivar por completo el “backdoor” utilizado por Adamo para la gestión remota del router.  

Con el usuario **admin** de JUCI es posible acceder a la configuración SIP (para quienes aún utilizan telefonía fija), así como habilitar servicios avanzados como **OpenVPN** y otras funciones adicionales. En definitiva, aunque el sistema viene bastante limitado de fábrica, una vez desbloqueado ofrece un nivel de control y personalización mucho más interesante de lo que cabría esperar.


# Fotos

![adamo](https://bandaancha.eu/s/2pea/176/captura-pantalla-2025-07-17-213838.avif)

![adamo](https://bandaancha.eu/s/2pdp/176/captura-pantalla-2025-07-17-001745.avif)

![adamo](https://bandaancha.eu/s/2pec/176/captura-pantalla-2025-07-17-220933.avif)

![adamo](https://bandaancha.eu/s/2pee/176/captura-pantalla-2025-07-17-221013.avif)

![adamo](https://bandaancha.eu/s/2peg/176/captura-pantalla-2025-07-17-221059.avif)

# Acceso root inicial

Con acceso UART, se puede interrumpir U-Boot y modificar la variable bootargs para obtener una shell root antes de que arranque el sistema por completo:

`setenv bootargs 'console=ttyLTQ0,115200 root=ubi0:rootfs_0 ubi.mtd=ubi,0,30 rootfstype=ubifs mtdparts=17c00000.nand-parts:1m(uboot),-(ubi) init=/bin/sh mem=224M@512M'`

Esto carga un entorno mínimo, sin montar del todo el sistema, pero útil si sabes lo que haces.

Esto efectivamente me dejó en una shell como root.

Ah, muy importante: el sistema está en modo lectura, así que hay que montarlo como escritura.

`
mount -t proc proc /proc
mount -o remount,rw /
`

Después, accedí a `/etc/shadow` y `/etc/passwd`, y cambié las contraseñas *root* y *admin* con `passwd`.

Todo parecía correcto: los hashes se actualizaban y el sistema aceptaba los nuevos passwords.

Sin embargo, cambiar la contraseña de root o admin en este punto no tenía efecto sobre JUCI, porque el problema no estaba en los scripts de sincronización de contraseñas, sino en la partición que se estaba modificando.

El router trabaja con dos bancos de sistema:
- `/rom` → contiene los valores de fábrica (solo lectura).
- `/` → raíz activa que realmente usa el sistema.

Cuando accedía con `/bin/sh` antes de que se montase overlayfs, las contraseñas se cambiaban en `/rom`, pero esa partición no es la que utiliza JUCI. Por eso, aunque los hashes se actualizaban en ese banco, no tenían ningún efecto sobre la autenticación web. Para que las contraseñas persistan y funcionen en JUCI, es necesario modificarlas en la raíz activa (`/`) una vez que el sistema haya terminado de montar overlayfs.


# La joya de la corona: Hook `post-/etc/preinit`

JUCI usa las credenciales del sistema Linux. Para que las contraseñas que modifiques funcionen tanto en el sistema como en la web (JUCI), necesitas que el sistema se inicie completamente, pero manteniendo acceso a una shell en (`/`) en vez de (`/rom`).

Aquí es donde entra el script que vimos antes en los bootargs por defecto. Editamos `/etc/preinit` y añadimos al final:

`exec /bin/sh`. *IMPORTANTE* hacer `sync` después y volver a poner los BootArgs que vienen por defecto.

De esta manera, se ejecutará todo el proceso de arranque completo, incluyendo `/sbin/init`, servicios y sincronización de usuarios, y al final te dejará en una shell interactiva con todo cargado.

# Cambio de contraseñas

Ahora viene la parte fácil y divertida, desde dentro de esa shell:

`passwd root`
`passwd admin`
`passwd support`


Los usuarios que usa Adamo para conectarse remotamente son *admin* y *support*, creo que es bastante self explanatory cuál se usa para cada cosa y quién los usa.

# Estructura de usuarios y autenticación

En `/etc/config/users` están definidos los roles lógicos (**user**, **support**, **admin**). La gestión efectiva de contraseñas no se basa en UCI como fuente de verdad, sino en los hashes de `/etc/shadow`.

### Comportamiento real de sincronización

- **Cambios vía terminal o web:**  
  Tanto `passwd admin` ejecutado desde terminal como el cambio de contraseña desde JUCI (que invoca `passwd` en segundo plano) actualizan `/etc/shadow` y permanecen tras reiniciar. No se revierten a una “original” mientras exista un hash válido en la raíz activa.

- **Script `/etc/init.d/passwords`:**  
  Su función práctica es inicializar credenciales si faltan.  
  Si no hay contraseña definida para **user**, **support** o **admin** en `/etc/shadow`, el script toma el hash correspondiente de `/rom/etc/shadow` y lo copia a `/etc/shadow`.  
  No sobrescribe contraseñas ya existentes ni fuerza valores de UCI sobre `/etc/shadow`.

### Implicación

- **No hay restauración automática desde UCI:**  
  Cambiar la contraseña de `admin` y reiniciar no revierte el cambio, porque JUCI y el sistema usan el mismo backend (shadow).  
  La restauración desde `/rom` solo ocurre cuando el hash en la raíz activa está ausente o vacío.


# Eliminación del "backdoor" (TR-069)

Cito de la Wikipedia:

> TR-069, también conocido como CWMP (CPE WAN Management Protocol), es un protocolo de comunicación estándar que permite la gestión remota de equipos en las instalaciones del cliente (CPE) conectados a una red IP

Este router mantiene una serie de servicios remotos activos como _icwmp, icwmp_stund y icwmpd_ en la ruta `/usr/sbin/`

- *icwmp:* Script Bash de arranque y control del cliente TR-069. Lanza y gestiona icwmpd y icwmp_stund.
- *icwmpd:* Binario Cliente TR-069 real. Se comunica con el servidor ACS de Adamo.
- *icwmp_stund:* Binario Daemon STUN. Permite al ACS alcanzar el router a través de NAT.

Adjunto un par de fotos.

![adamo](https://bandaancha.eu/s/2peh/dl/captura-pantalla-2025-07-17-231012.avif)

![adamo](https://bandaancha.eu/s/2pej/d5/captura-pantalla-2025-07-17-231715.avif)

![adamo](https://bandaancha.eu/s/2pek/cz/captura-pantalla-2025-07-17-231847.avif)

Para desactivar por completo el acceso remoto es tan fácil como borrarlos (o cambiar el nombre, como en mi caso):

`mv icwmp icwmp.bak` `mv icwmp_stund icwmp_stund.bak` `mv icwmpd icwmpd.bak`

De forma adicional, también es posible realizar la desactivación desde la propia interfaz web del router. Accediendo como **admin**, se puede deshabilitar la opción *ACS discover por DHCP* y eliminar tanto los dominios como los usuarios de Adamo configurados en el cliente TR-069. Esta medida complementa la eliminación manual de binarios y asegura que el dispositivo no intente establecer comunicación con el servidor ACS de la operadora.

También aparecen referencias al dominio *acs.adamo.es* (ACS: Auto Configuration Server), que apunta a ser el portal de administración utilizado por la operadora para conectarse a nuestros “adorados” routers. En otras palabras: la puerta de entrada oficial para que puedan curiosear en nuestros equipos, monitorizarnos y aplicar esa gestión remota tan “entrañable” que tanto gusta a las ISPs

# Conclusión

Actualmente estoy analizando las contraseñas por defecto que aparecen en */etc/shadow*, con el objetivo de comprobar si es posible descifrarlas y facilitar así el acceso directo por SSH sin necesidad de realizar modificaciones adicionales.

Durante la revisión se ha identificado que los routers de Adamo incluyen un usuario de soporte preconfigurado con credenciales estáticas:  
**support : "Adamo support rockz!"**  
Este acceso representa una vulnerabilidad, ya que en caso de que algún dispositivo quede expuesto a Internet, podría ser utilizado para entrar de forma remota con el usuario *support*.

El servicio SSH se encuentra habilitado por defecto en el puerto **22666**. El único acceso válido corresponde al usuario **root**. Los usuarios impresos en la etiqueta del dispositivo no disponen de directorio *home* ni de una *shell* asignada, lo que impide su utilización para sesiones SSH.



