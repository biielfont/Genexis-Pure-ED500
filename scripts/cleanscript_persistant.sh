# juci-ice-client
rm -f /mnt/usr/libexec/rpcd/juci.ice
rm -f /mnt/usr/share/rpcd/acl.d/juci-ice-client.json
rm -f /mnt/www/js/juci-ice-client.js.gz

# ice-client
rm -f /mnt/usr/lib/libwsice.so
rm -f /mnt/bin/ice
rm -f /mnt/usr/lib/networkService.so.1.0.1
rm -f /mnt/etc/iopsys/certificates/cert_server_ca.pem
rm -f /mnt/etc/iopsys/server.ini
rm -f /mnt/usr/lib/systemService.so.1.0.1
rm -f /mnt/etc/iopsys/defaults.ini
rm -f /mnt/usr/lib/texecService.so.1.0.1
rm -f /mnt/usr/lib/libconfStore.so.1
rm -f /mnt/bin/ifs/iperf/execute/scheduleiperf.sh
rm -f /mnt/etc/uci-defaults/35-ice-client
rm -f /mnt/usr/lib/packageService.so.1.0.1
rm -f /mnt/bin/ubusevent
rm -f /mnt/etc/iopsys/modify.ini
rm -f /mnt/usr/lib/iperfService.so.1.0.1
rm -f /mnt/usr/lib/monitorService.so.1.0.1
rm -f /mnt/etc/iopsys/certificates/inteno_root_ca.pem
rm -f /mnt/usr/lib/webaccessService.so.1.0.1
rm -f /mnt/etc/config/ice
rm -f /mnt/usr/lib/logService.so.1.0.1
rm -f /mnt/etc/init.d/ice-client

# juci-icwmp
rm -f /mnt/usr/share/rpcd/acl.d/juci-icwmp.json
rm -f /mnt/www/js/juci-icwmp.js.gz

# icwmp_stun
rm -f /mnt/usr/sbin/icwmp_stund
rm -f /mnt/etc/init.d/icwmp_stund
rm -f /mnt/etc/config/cwmp_stun

# icwmp-curl
rm -f /mnt/etc/init.d/icwmpd
rm -f /mnt/usr/share/icwmp/functions/serverselection_launch
rm -f /mnt/usr/share/icwmp/functions/download_launch
rm -f /mnt/etc/uci-defaults/90-icwmp-set-dhcp-reqopts
rm -f /mnt/usr/sbin/icwmp
rm -f /mnt/usr/share/icwmp/functions/udpecho_launch
rm -f /mnt/usr/share/icwmp/functions/traceroute_launch
rm -f /mnt/etc/uci-defaults/90-cwmpfirewall
rm -f /mnt/etc/firewall.cwmp
rm -f /mnt/usr/share/icwmp/functions/ipping_launch
rm -f /mnt/usr/share/icwmp/defaults
rm -f /mnt/usr/share/icwmp/functions/upload_launch
rm -f /mnt/etc/config/cwmp
rm -f /mnt/usr/share/icwmp/functions/conf_backup
rm -f /mnt/usr/share/icwmp/functions/common
rm -f /mnt/usr/share/icwmp/functions/nslookup_launch
rm -f /mnt/etc/icwmpd/dmmap
rm -f /mnt/etc/hotplug.d/iface/90-icwmp
rm -f /mnt/usr/sbin/icwmpd

# juci-iup
rm -f /mnt/usr/share/rpcd/acl.d/juci-iup.json
rm -f /mnt/www/js/juci-iup.js.gz
rm -f /mnt/usr/libexec/rpcd/juci.iup

# iup
rm -f /mnt/etc/uci-defaults/85-iup-set-dhcp-reqopts
rm -f /mnt/etc/config/provisioning
rm -f /mnt/sbin/iup
rm -f /mnt/etc/init.d/iup
rm -f /mnt/lib/functions/dhcp_option_relay.sh

# operator-config
rm -f /mnt/etc/hotplug.d/iface/91-operator-config
rm -f /mnt/usr/sbin/operator-config
rm -f /mnt/etc/uci-defaults/run-operator-config


sed -i '/^Package: juci-ice-client$/,/^$/d' /mnt/usr/lib/opkg/status
sed -i '/^Package: ice-client$/,/^$/d' /mnt/usr/lib/opkg/status
sed -i '/^Package: juci-icwmp$/,/^$/d' /mnt/usr/lib/opkg/status
sed -i '/^Package: icwmp_stun$/,/^$/d' /mnt/usr/lib/opkg/status
sed -i '/^Package: icwmp-curl$/,/^$/d' /mnt/usr/lib/opkg/status
sed -i '/^Package: juci-iup$/,/^$/d' /mnt/usr/lib/opkg/status
sed -i '/^Package: iup$/,/^$/d' /mnt/usr/lib/opkg/status
sed -i '/^Package: operator-config$/,/^$/d' /mnt/usr/lib/opkg/status

# juci-ice-client
rm -f /mnt/usr/lib/opkg/info/juci-ice-client.*
# ice-client
rm -f /mnt/usr/lib/opkg/info/ice-client.*
# juci-icwmp
rm -f /mnt/usr/lib/opkg/info/juci-icwmp.*
# icwmp_stun
rm -f /mnt/usr/lib/opkg/info/icwmp_stun.*
# icwmp-curl
rm -f /mnt/usr/lib/opkg/info/icwmp-curl.*
# juci-iup
rm -f /mnt/usr/lib/opkg/info/juci-iup.*
# iup
rm -f /mnt/usr/lib/opkg/info/iup.*
# operator-config
rm -f /mnt/usr/lib/opkg/info/operator-config.*
