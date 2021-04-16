#!/bin/sh

# you may want upgrade netifd first


# override shadowsocks server config
METHOD=xchacha20-ietf-poly1305
HOST=
PORT=
KEY=



# add openwrt dist repo
for a in $(opkg print-architecture | awk '{print $2}'); do
  case "$a" in
    all|noarch)
      ;;
    aarch64_armv8-a|arm_arm1176jzf-s_vfp|arm_arm926ej-s|arm_cortex-a15_neon-vfpv4|arm_cortex-a5|arm_cortex-a53_neon-vfpv4|arm_cortex-a7_neon-vfpv4|arm_cortex-a8_vfpv3|arm_cortex-a9|arm_cortex-a9_neon|arm_cortex-a9_vfpv3|arm_fa526|arm_mpcore|arm_mpcore_vfp|arm_xscale|armeb_xscale|i386_pentium|i386_pentium4|mips_24kc|mips_mips32|mips64_octeon|mipsel_24kc|mipsel_74kc|mipsel_mips32|powerpc_464fp|powerpc_8540|x86_64)
      ARCH=${a}
      ;;
    *)
      echo "Architectures not support."
      exit 0
      ;;
  esac
done

echo -e "\nTarget Arch:\033[32m $ARCH \033[0m\n"

if !(grep -q "openwrt_dist" /etc/opkg/customfeeds.conf); then
  wget http://openwrt-dist.sourceforge.net/openwrt-dist.pub
  opkg-key add openwrt-dist.pub
  echo "src/gz openwrt_dist http://openwrt-dist.sourceforge.net/packages/base/$ARCH" >> /etc/opkg/customfeeds.conf
  echo "src/gz openwrt_dist_luci http://openwrt-dist.sourceforge.net/packages/luci" >> /etc/opkg/customfeeds.conf
  rm openwrt-dist.pub
fi

opkg update

# bypass china
opkg install luci-app-chinadns luci-app-dns-forwarder luci-app-shadowsocks shadowsocks-libev iptables-mod-tproxy


# install https wget
opkg install ca-certificates ca-bundle wget


# apps
opkg install luci-app-adblock luci-app-sqm luci-app-statistics luci-app-upnp collectd-mod-ping collectd-mod-dns


# create util scripts
cat > /usr/bin/ss-watchdog << 'EOF'
#!/bin/sh
LOGTIME=$(date "+%Y-%m-%d %H:%M:%S")
TIMEOUT=3
TRIES=3
RATING_URL=https://www.google.com/
REFERENCE_URL=https://www.baidu.com/
network_probe () {
  wget --spider --quiet --tries=$TRIES --timeout=$TIMEOUT $1
  echo $?
}
if [ `network_probe $RATING_URL` = 0 ]; then
  echo [$LOGTIME] No Problem
  exit 0
elif [ `network_probe $REFERENCE_URL` = 0 ]; then
  echo [$LOGTIME] Problem decteted. Restarting shadowsocks
  /etc/init.d/shadowsocks restart > /dev/null
else
  echo [$LOGTIME] Network problem. Do nothing
fi
EOF

cat > /usr/bin/update-chnroute << 'EOF'
#!/bin/sh
wget -O- 'http://ftp.apnic.net/apnic/stats/apnic/delegated-apnic-latest' | awk -F\| '/CN\|ipv4/ { printf("%s/%d\n", $4, 32-log($5)/log(2)) }' > /etc/chinadns_chnroute.txt
EOF

chmod +x /usr/bin/ss-watchdog
chmod +x /usr/bin/update-chnroute
update-chnroute
mkdir -p /root/adblock

echo new software installed

# upgrade
opkg list-upgradable | cut -f 1 -d ' ' | xargs opkg upgrade --force-maintainer

echo applying config

# config shadowsocks
SERVER=`uci add shadowsocks servers`
uci set shadowsocks.$SERVER.encrypt_method=$METHOD
uci set shadowsocks.$SERVER.fast_open=1
uci set shadowsocks.$SERVER.no_delay=1
uci set shadowsocks.$SERVER.password=$KEY
uci set shadowsocks.$SERVER.server=$HOST
uci set shadowsocks.$SERVER.server_port=$PORT
uci set shadowsocks.@transparent_proxy[0].main_server=$SERVER
uci set shadowsocks.@transparent_proxy[0].udp_relay_server=same
uci set shadowsocks.@access_control[0].wan_bp_list=/etc/chinadns_chnroute.txt
uci set shadowsocks.@access_control[0].ipt_ext="-m multiport --dports 53,80,443"


# dns
uci set chinadns.@chinadns[0].enable=1
uci set chinadns.@chinadns[0].server=119.29.29.29,127.0.0.1#5300
uci set dns-forwarder.@dns-forwarder[0].enable=1
uci set dhcp.@dnsmasq[0].noresolv=1
uci set dhcp.@dnsmasq[0].cachesize=10000
uci add_list dhcp.@dnsmasq[0].server=127.0.0.1#5353


# config upnp
uci set upnpd.config.enabled=1


# config adblock
uci set adblock.global.adb_enabled=1
uci set adblock.global.adb_fetchutil=wget
uci set adblock.global.adb_trigger=timed
uci set adblock.global.adb_dns=dnsmasq
uci set adblock.extra.adb_triggerdelay=60
uci set adblock.extra.adb_backup=1
uci set adblock.extra.adb_backupdir=/root/adblock
uci set adblock.extra.adb_nice=10
uci set adblock.extra.adb_dnsflush=1
uci set adblock.reg_cn.enabled=1


# config cron
crontab - << 'EOF'
# beware UTC
# update chnroute at sunday 3:30am
30 19 * * 0 update-chnroute
# Reboot at 4:30am every monday
# Note: To avoid infinite reboot loop, wait 70 seconds
# and touch a file in /etc so clock will be set
# properly to 4:31 on reboot before cron starts.
30 20 * * 1 sleep 70 && touch /etc/banner && reboot
# shadowsocks watchdog, check every 5 min
*/5 * * * * ss-watchdog >> /var/log/ss-watchdog.log 2>&1
# clean log every monday
0 1 * * 1 echo "" > /var/log/ss-watchdog.log
EOF

# apply changes
uci commit
luci-reload
rm /etc/resolv.conf
