< Special thanks to the author: https://github.com/moieric11 >
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
