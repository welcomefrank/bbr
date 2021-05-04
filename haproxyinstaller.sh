sudo su
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

addrule(){
read -p "请输入新增线路的名称：" rulename
read -p "请输入新增线路的前端口：" rulefrontendport
read -p "请输入新增线路的后端IP地址：" rulebackendip
read -p "请输入新增线路的后端口：" rulebackendport
cat >> /root/test.conf << "EOF"
frontend $rulename-in
        bind *:$rulefrontendport
        default_backend $rulename-out

backend $rulename-out
        server server1 $rulebackendip:$rulebackendport maxconn 20480
EOF
service haproxy restart
}
