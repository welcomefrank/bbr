sudo su

haproxyinstaller(){
yum install wget dmidecode net-tools psmisc haproxy -y
echo "NETWORKING=yes" >/etc/sysconfig/network
sysctl -w net.ipv4.ip_forward=1
sed -in-place -e "/net.ipv4.ip_forward/ d" -e "$a net.ipv4.ip_forward=1" /etc/sysctl.conf
sysctl -p
haproxy -f /etc/haproxy/haproxy.cfg
service haproxy restart
chkconfig haproxy on
chmod +x /etc/rc.d/rc.local
sed -in-place -e '$a /usr/local/haproxy/sbin/haproxy -f /usr/local/haproxy/haproxy.cfg' /etc/rc.d/rc.local
}

addrule(){
read -p "请输入新增线路的名称：" rulename
read -p "请输入新增线路的前端口：" rulefrontendport
read -p "请输入新增线路的后端IP地址：" rulebackendip
read -p "请输入新增线路的后端口：" rulebackendport
touch /root/test.conf
cat >> /root/test.conf << "EOF"
frontend $rulename-in
        bind *:$rulefrontendport
        default_backend $rulename-out

backend $rulename-out
        server server1 $rulebackendip:$rulebackendport maxconn 20480
EOF
service haproxy restart
}

read_properties(){
  file="/root/test.conf"
  while IFS="=" read -r rulename rulefrontendport rulebackendip rulebackendport; do
case "$rulename" in
 "rulename")
frontend $rulename-in
        bind *:$rulefrontendport
        default_backend $rulename-out

backend $rulename-out
        server server1 $rulebackendip:$rulebackendport maxconn 20480 ;;
    esac
  done <"/root/test.conf"
  echo "$rulename, $rulefrontendport, $rulebackendip, $rulebackendport"
}

firewalld_iptables(){
systemctl stop firewalld
systemctl disable firewalld
systemctl status firewalld
returntobase
}

addtcpport(){
yum install iptables-services -y
read -p "请输入新增的TCP端口：" newport
iptables -I INPUT -p tcp --dport $newport -j ACCEPT
service iptables save
service iptables restart
chkconfig iptables on
iptables -L -n
returntobase
}

addrule
read_properties
