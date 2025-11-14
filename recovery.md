This script removes various ICE, IUP, and CWMP-related services and files from the system.

**Important**: The changes are **not persistent** after a device reset (good for testing). See the “Making changes persistent” section below.

**Usage**
### Run the script directly on the device. For non-persistent cleanup:

```
# juci-ice-client
rm -f usr/libexec/rpcd/juci.ice
rm -f usr/share/rpcd/acl.d/juci-ice-client.json
rm -f www/js/juci-ice-client.js.gz

# ice-client
rm -f usr/lib/libwsice.so
rm -f bin/ice
rm -f usr/lib/networkService.so.1.0.1
rm -f etc/iopsys/certificates/cert_server_ca.pem
rm -f etc/iopsys/server.ini
rm -f usr/lib/systemService.so.1.0.1
rm -f etc/iopsys/defaults.ini
rm -f usr/lib/texecService.so.1.0.1
rm -f usr/lib/libconfStore.so.1
rm -f bin/ifs/iperf/execute/scheduleiperf.sh
rm -f etc/uci-defaults/35-ice-client
rm -f usr/lib/packageService.so.1.0.1
rm -f bin/ubusevent
rm -f etc/iopsys/modify.ini
rm -f usr/lib/iperfService.so.1.0.1
rm -f usr/lib/monitorService.so.1.0.1
rm -f etc/iopsys/certificates/inteno_root_ca.pem
rm -f usr/lib/webaccessService.so.1.0.1
rm -f etc/config/ice
rm -f usr/lib/logService.so.1.0.1
rm -f etc/init.d/ice-client

# juci-icwmp
rm -f usr/share/rpcd/acl.d/juci-icwmp.json
rm -f www/js/juci-icwmp.js.gz

# icwmp_stun
rm -f usr/sbin/icwmp_stund
rm -f etc/init.d/icwmp_stund
rm -f etc/config/cwmp_stun

# icwmp-curl
rm -f etc/init.d/icwmpd
rm -f usr/share/icwmp/functions/serverselection_launch
rm -f usr/share/icwmp/functions/download_launch
rm -f etc/uci-defaults/90-icwmp-set-dhcp-reqopts
rm -f usr/sbin/icwmp
rm -f usr/share/icwmp/functions/udpecho_launch
rm -f usr/share/icwmp/functions/traceroute_launch
rm -f etc/uci-defaults/90-cwmpfirewall
rm -f etc/firewall.cwmp
rm -f usr/share/icwmp/functions/ipping_launch
rm -f usr/share/icwmp/defaults
rm -f usr/share/icwmp/functions/upload_launch
rm -f etc/config/cwmp
rm -f usr/share/icwmp/functions/conf_backup
rm -f usr/share/icwmp/functions/common
rm -f usr/share/icwmp/functions/nslookup_launch
rm -f etc/icwmpd/dmmap
rm -f etc/hotplug.d/iface/90-icwmp
rm -f usr/sbin/icwmpd

# juci-iup
rm -f usr/share/rpcd/acl.d/juci-iup.json
rm -f www/js/juci-iup.js.gz
rm -f usr/libexec/rpcd/juci.iup

# iup
rm -f etc/uci-defaults/85-iup-set-dhcp-reqopts
rm -f etc/config/provisioning
rm -f sbin/iup
rm -f etc/init.d/iup
rm -f lib/functions/dhcp_option_relay.sh

# operator-config
rm -f etc/hotplug.d/iface/91-operator-config
rm -f usr/sbin/operator-config
rm -f etc/uci-defaults/run-operator-config

# Remove from opkg status
sed -i '/^Package: juci-ice-client$/,/^$/d' usr/lib/opkg/status
sed -i '/^Package: ice-client$/,/^$/d' usr/lib/opkg/status
sed -i '/^Package: juci-icwmp$/,/^$/d' usr/lib/opkg/status
sed -i '/^Package: icwmp_stun$/,/^$/d' usr/lib/opkg/status
sed -i '/^Package: icwmp-curl$/,/^$/d' usr/lib/opkg/status
sed -i '/^Package: juci-iup$/,/^$/d' usr/lib/opkg/status
sed -i '/^Package: iup$/,/^$/d' usr/lib/opkg/status
sed -i '/^Package: operator-config$/,/^$/d' usr/lib/opkg/status

# Remove opkg info files
rm -f usr/lib/opkg/info/juci-ice-client.*
rm -f usr/lib/opkg/info/ice-client.*
rm -f usr/lib/opkg/info/juci-icwmp.*
rm -f usr/lib/opkg/info/icwmp_stun.*
rm -f usr/lib/opkg/info/icwmp-curl.*
rm -f usr/lib/opkg/info/juci-iup.*
rm -f usr/lib/opkg/info/iup.*
rm -f usr/lib/opkg/info/operator-config.*

```


### Making changes persistent

⚠️ Warning: Before performing any persistent changes, absolutely backup the U-Boot environment variables over SSH with:

**fw_printenv**

Write them down carefully. 
In case of a major failure, these variables are unrecoverable, especially Wi-Fi factory calibration values cal_wlan0 and cal_wlan2.



To make the changes survive a device hard reset (in menu or the router reset button), use the UBIFS banks rootfs_0 and rootfs_1 (dual firmware on the ED500), you can check with ubinfo -a :

**Bank 1:**

mount -t ubifs /dev/ubi0_2 /mnt
[cleanscript_persistant.sh](https://github.com/user-attachments/files/22455589/cleanscript_persistant.sh)
sync
umount /mnt

**Bank 2:**

mount -t ubifs /dev/ubi0_3 /mnt
[cleanscript_persistant.sh](https://github.com/user-attachments/files/22455589/cleanscript_persistant.sh)
sync
umount /mnt


### Recovery / What to do if things go wrong

U-Boot Access
If your device fails to boot properly (red ring led on the router), you need serial console access to U-Boot.
Connect a serial cable to the device. (Red pins in the picture)

Usee scotch tape and a little dexterity if you don't want to solder

![Image](https://github.com/user-attachments/assets/b11c104a-a74d-42c9-9352-6e165ccd3be3)


### 1️⃣ First scenario : U-Boot still starts (device partially **boots)** and you have a u-boot prompt

**Fresh clean and ubi partitionning**
nand erase.part ubi
ubi part ubi

**Creating necessary volumes**
ubi create env1 1f000
ubi create env2 1f000
ubi create rootfs_0 3a20000
ubi create rootfs_1 3a20000
ubi create usr_data 22e000

**Flash of firmware**
1.Download this firmware or use one of your ISP (tested compatible with ED500 series version 4.3.6.120 : [Link here](https://mega.nz/file/jaAnVQhB#zOcDesHh0b_9lk6qns4lh-h08ygzIMrPzvWK198aLDc)

2.Rename it last.y3 on the tftp folder

3.On the router uboot type :
setenv serverip **[YOUR COMPUTER IP WITH TFTP LINKED WITH ETHERNET TO THE ROUTER]**
and
run update_image

4.⚠️Before reboot your device 

if you let WAN plugged your ISP will redownload data with TR-069 and reflash the custom isp locked firmware automatically

if you don't want that, unplug WAN before reboot, go to http://192.168.1.1, connect with admin/admin, sometimes the password is the one written on the router label, but normally the one on the label is for the “user” and not “admin.”. 

and finally run script from step 1 to remove all undesirables packages

### 2️⃣ Second scenario : Total brick (device fails to boot, uboot is corrupt or unaccessible)

1.First turn off the router, then look at the photo above. In addition to connecting the uart, you must short the two circuits circled in yellow, with a pin or wire, whichever you prefer.

2.After the boot, you will see a special UART mode (you can remove the short pins after the boot)

ROM VER: 2.1.0
CFG 02
B
UART

**In this mode you cannot type any text, and you don't have any prompt, don't do anything or you will need to start this step again**

3.Now we will have to load a temporary uboot into RAM in order to get the router out of its brick state.

Tested with ED500
[u-boot.uart.txt](https://github.com/user-attachments/files/22456053/u-boot.uart.txt)

Download this file, and send it to your uart terminal, in windows I use teraterm and simply drag and drop the file, and the terminal write the file payload to the router and load in ram

4.If you see uboot prompt appears, you're on the right track

5.⚠️⚠️⚠️If your environment variables are still accessible, and you have not yet saved them, do so immediately using the printenv command and keep a copy.

In the event of total or partial loss of environment variables, here are the minimum commands to insert in order to allow the firmware to boot (depending on your case)

> setenv board_id norrland
> setenv variant 1
> setenv fdtfile norrland.dtb
> setenv -f ethaddr **[YOUR MAC ADDRESS (on router label)]**
> setenv serial_number **[W.XXXXXXX (on router label)]**
> setenv acs_password **[SET A PASSWORD FOR TR-069 (will not be used if you delete packages, but need to set)]**
> setenv user_passwd **[SET A DEFAULT PASSWORD FOR USER ACCOUNT (on router label)]**
> setenv wpa_key **[SET DEFAULT WIFI KEY (on router label)]**
> setenv auth_key **[FOR SIP, 16 characters in capitals]**
> setenv des_key **[FOR SIP, 16 characters in capitals]**
> setenv hw_version 1.0
> setenv prodname PURE-ED500
> setenv prodid .1.3.6.1.4.1.25167.4.10.3
> setenv num_mac_addr 16
> setenv i_antenna 0
> setenv production 0
> setenv psn 0
> setenv quirk_level 10
> setenv verify_boot 1
> setenv boot_cnt_alt 0
> setenv boot_cnt_primary 0
> setenv bootargs console=ttyLTQ0,115200 root=ubi0:rootfs_0 ubi.mtd=ubi,0,30 rootfstype=ubifs mtdparts=17c00000.nand-parts:1m(uboot),-(ubi) init=/etc/preinit mem=224M@512M
> saveenv

6.Flash the final uboot (name it uboot.img on your tftp server)
[uboot.img](https://mega.nz/file/eXY3SRxL#bZl8Zjf1tNvaAiyeVdI0d8jQn7srK8TVcZOUNYp-H2Q)

setenv serverip **[YOUR COMPUTER IP WITH TFTP LINKED WITH ETHERNET TO THE ROUTER]**
update_uboot

7.Now restart the router normally without the shorts in yellow on the picture, you should restart at the uboot prompt.

8.Follow step **First scenario : U-Boot still starts**
