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
clear
echo -e "刚刚输入的信息如下:\n新增线路的名称:$rulename\n新增线路的前端口:$rulefrontendport\n新增线路的后端IP地址:$rulebackendip\n新增线路的后端口:$rulebackendport"
read -p "按任意键确认 按n回车表示放弃并退出" confirmrule
if [ $confirmrule = "n" ];then
exit 0 
else
echo -e "已经确认新增线路信息 继续..."
fi
touch /root/haproxydata.txt
sed -in-place -e '$a $rulename $rulefrontendport $rulebackendip $rulebackendport' /root/haproxydata.txt
cat /root/haproxydata.txt
touch /root/test.conf
cat >> /root/test.conf << EOF
frontend $rulename-in
        bind *:$rulefrontendport
        default_backend $rulename-out

backend $rulename-out
        server server1 $rulebackendip:$rulebackendport maxconn 20480

EOF
service haproxy restart
service haproxy status
cat /root/test.conf
}

deleterule(){
read -p "请输入想要删除线路的前端口" deleteport
sed -in-place -e "/$deleteport/ d" /root/haproxydata.txt
sed -in-place -e /root/test.conf

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
