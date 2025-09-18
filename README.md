# Genexis-Pure-ED500
Copia de mi publicación en el foro de Bandaancha: -> [POST](https://bandaancha.eu/foros/tutorial-acceso-root-completo-pure-ed500-1757239)
Por si acaso i dado que esta publicación puede ser modificada por mí o por alguien externo en el futuro, dejo también un enlace archivado en Wayback Machine -> [Wayback]([https://bandaancha.eu/foros/tutorial-acceso-root-completo-pure-ed500-1757239](https://web.archive.org/web/20250917144511/https://bandaancha.eu/foros/tutorial-acceso-root-completo-pure-ed500-1757239))

Este proyecto documenta el proceso de obtención de acceso root completo en el router Genexis Pure ED500 (Adamo), basado en OpenWrt modificado por Iopsys con interfaz JUCI. 
A través de UART y modificaciones en el arranque (/etc/preinit), se logra persistencia de credenciales, acceso administrativo y eliminación total del "backdoor" TR-069 (icwmp, icwmpd, icwmp_stund). Se incluye análisis detallado de la gestión de contraseñas vía UCI y estructura interna de usuarios.

# Introducción

El router Genexis Pure ED500, distribuido por Adamo, ejecuta una variante de OpenWrt modificada por Iopsys, con la interfaz web JUCI.

El firmware está cerrado, pero tras liarme a palos con el router y casi partirlo por la mitad, es posible obtener acceso root real, privilegios de administrador en la interfaz web y desactivar completamente el "backdoor" que usa Adamo para acceder remotamente al dispositivo. Con el usuario admin de JUCI podéis obtener vuestra configuración SIP si aún usáis teléfono fijo. Además de configurar OpenVPN y muchas más cosas que vienen, la verdad que no está tan mal.

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

Sin embargo, cambiar la contraseña de root o admin en este punto no tiene efecto sobre JUCI, porque aún no se han ejecutado los scripts que configuran el entorno y sincronizan los credenciales.

1. El sistema no estaba completamente arrancado. Solamente tenía montado el rootfs, pero muchos scripts de inicialización no se ejecutaban.
2. No se ejecutaba `/etc/init.d/passwords`, que es el responsable de aplicar las contraseñas desde UCI al sistema real, sincronizarlas y borrarlas del config.
3. Además, la shell que obtenía con `/bin/sh` era antes de que se montase overlayfs. Es decir: cualquier cambio en */etc* se hacía en RAM o en el sistema squashfs en modo lectura. Al reiniciar, se perdía todo.

# La joya de la corona: Hook `post-/etc/preinit`

JUCI usa las credenciales del sistema Linux. Para que las contraseñas que modifiques funcionen tanto en el sistema como en la web (JUCI), necesitas que el sistema se inicie completamente, pero manteniendo acceso a una shell.

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

En `/etc/config/users`* están definidos los usuarios lógicos (_user, support, admin)_ y en `/etc/config/passwords`* se asignan contraseñas por tipo de usuario.

Pero la *parte clave* está en el script de init `/etc/init.d/passwords`, que en cada arranque:

1. Lee /etc/config/passwords
2. Si encuentra una clave definida, la aplica vía passwd
3. Luego borra esa entrada del UCI (_uci delete passwords.admin.password_), lo que evita que se sobrescriba constantemente.

Por tanto, si cambias la contraseña de admin y reinicias sin eliminar el campo password del UCI, el sistema volverá a poner la que tenía antes.

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

También he visto un par de referencias a este dominio: *acs.adamo.es*, el cual parece ser un portal de administrador que les permite conectarse a nuestros tan queridísimos routers, espiarnos y bueno, todo eso de las ISPs :)

# Conclusión

Cerveza fría y mucho coco.

Dentro de unos días seguramente adjuntaré un link de un repositorio de GitHub con ficheros de configuración y binarios relevantes. Primero quiero revisar todo y asegurarme de que no haya alguna conexión con los datos de mi router.

Ahora mismo estoy intentando ver si puedo desencriptar las contraseñas por defecto que vienen en */etc/shadow*, y así podríais conectaros directamente por SSH, ahorrándoos todo este tinglado.

Que sepáis que viene activado por defecto en el puerto *22666*. El único usuario con el que podéis entrar es root; si intentáis con el usuario por defecto que viene en la pegatina, os vais a comer una hostia con la mano abierta, porque no son usuarios con directorios home, así que no permiten el acceso.

Si tenéis alguna duda, escribid por aquí. Iré actualizando el post.
