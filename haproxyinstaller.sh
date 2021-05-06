#!/bin/bash

#fonts color
Green="\033[32m"
Red="\033[31m"
Yellow="\033[33m"
GreenBG="\033[42;37m"
RedBG="\033[41;37m"
Font="\033[0m"

returntobase(){
read -p "是否要返回主菜单? (默认按任意键返回主菜单/按n退出)" backtobase
if [ $backtobase = "n" ];then
exit 0
else 
menu
fi
}

haproxyinstaller(){
yum install wget dmidecode net-tools psmisc haproxy -y
echo "NETWORKING=yes" >/etc/sysconfig/network
sysctl -w net.ipv4.ip_forward=1
sed -in-place -e "/net.ipv4.ip_forward/ d"
echo -e "net.ipv4.ip_forward=1" >> /etc/sysctl.conf
sysctl -p
haproxy -f /etc/haproxy/haproxy.cfg
service haproxy restart
chkconfig haproxy on
chmod +x /etc/rc.d/rc.local
echo -e "/usr/local/haproxy/sbin/haproxy -f /usr/local/haproxy/haproxy.cfg" >> /etc/rc.d/rc.local
returntobase
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
echo -e "#The following rule for $rulefrontendport added on `date +20%y-%m-%d' '%H:%M:%S`" >> /root/haproxydata.txt  
echo -e "$rulename $rulefrontendport $rulebackendip $rulebackendport" >> /root/haproxydata.txt
cat >> /etc/haproxy/haproxy.cfg << EOF
frontend $rulename-in
        bind *:$rulefrontendport
        default_backend $rulename-out

backend $rulename-out
        server server1 $rulebackendip:$rulebackendport maxconn 20480

EOF
service haproxy restart
service haproxy status
cat /etc/haproxy/haproxy.cfg
returntobase
}

displayhaproxyrules(){
echo -e "${Red}目前Haproxy的运行状态如下:${Font}"
service haproxy status
echo -e "${Red}目前所有TCP中转线路如下:${Font}"
cat /root/haproxydata.txt
returntobase
}

deleterule(){
cat /root/haproxydata.txt
read -p "请输入想要删除线路的前端口:" deleteport
sed -in-place -e "/$deleteport/ d" /root/haproxydata.txt 
sed -i "N;/\n.*$deleteport/!P;D" /etc/haproxy/haproxy.cfg
sed -in-place -e "/$deleteport/,+5d" /etc/haproxy/haproxy.cfg 
cat /etc/haproxy/haproxy.cfg
service haproxy restart
service haproxy status
returntobase
}

firewalld_iptables(){
systemctl stop firewalld
systemctl disable firewalld
systemctl status firewalld
returntobase
}

addtcpport(){
yum install iptables-services -y
read -p "请输入新增的开放TCP端口：" newport
iptables -I INPUT -p tcp --dport $newport -j ACCEPT
service iptables save
service iptables restart
chkconfig iptables on
iptables -L -n
returntobase
}

addudprule(){
read -p "请输入本服务器的UDP前端口：" sourcepport
read -p "请输入终端服务器的IP：" destinationip
read -p "请输入终端服务器的端口：" destinationport
iptables -t nat -A PREROUTING -p udp --dport $sourcepport -j DNAT --to-destination $destinationip:$destinationport
iptables -t nat -A POSTROUTING -p udp -d $destinationip --dport $destinationport -j MASQUERADE
service iptables save
service iptables restart
returntobase
}

displayudprules(){
yum install tcpdump -y
iptables -t nat -xnvL PREROUTING
read -p "查看指定UDP前端口的中转状态：" udpporttraffic
tcpdump udp port $udpporttraffic -n
returntobase
}

deleteudprule(){
iptables -t nat -xnvL PREROUTING
read -p "请输入需要删除的UDP规则顺序号(第一条/第二条...)：" udpnumber
iptables -t nat -D PREROUTING $udpnumber
service iptables save
service iptables restart
echo -e "修改后的全部UDP中转规则如下:"
iptables -t nat -xnvL PREROUTING
returntobase
}

menu(){
    echo -e "${Red}中转服务器操作${Font}"
    echo -e "${Green}1.${Font} 仅安装Haproxy并设置开机自动启动"
    echo -e "${Green}2.${Font} 安装iptables-service并开放指定TCP端口"
    echo -e "${Green}3.${Font} 关闭firewalld服务"
    echo -e "${Green}4.${Font} 新增Haproxy TCP中转线路"
    echo -e "${Green}5.${Font} 显示Haproxy运行状态 及 所有TCP中转线路"
    echo -e "${Green}6.${Font} 删除指定Haproxy TCP中转线路"
    echo -e "${Green}7.${Font} 清空所有TCP/UDP防火墙规则"
    echo -e "${Green}8.${Font} 新增UDP中转规则"
    echo -e "${Green}9.${Font} 显示所有UDP中转规则 及 指定前端口的中转状态"
    echo -e "${Green}10.${Font} 删除指定UDP中转规则"
    echo -e "${Green}11.${Font} 重启使所有规则生效"
    echo -e "${Green}12.${Font}  退出 \n"
    read -p "请输入数字：" menu_num
    case $menu_num in
        1)
          haproxyinstaller
        ;;
        2)
          addtcpport   
          ;; 
        3)
          firewalld_iptables
        ;;
        4)
          addrule
          ;;
        5)
          displayhaproxyrules
          ;;         
        6)
          deleterule
          ;; 
        7)
          iptables -F
          echo -e "${Green}所有防火墙规则已经清空${Font}"
          ;; 
        8)
          addudprule
          ;;
        9)
          displayudprules
          ;;
        10)
          deleteudprule
          ;; 
        11)
          reboot
          ;; 
        12)
          exit 0
          ;;
        *)
          echo -e "${RedBG}请输入正确的数字${Font}"
          ;;
    esac
}

menu
