#!/bin/bash

#fonts color
Green="\033[32m"
Red="\033[31m"
Yellow="\033[33m"
GreenBG="\033[42;37m"
RedBG="\033[41;37m"
Font="\033[0m"

ssrinstaller(){
yum install git -y
git clone -b manyuser https://github.com/welcomefrank/shadowsocksr.git
cd /root/shadowsocksr
bash initcfg.sh
sed -i "s/API_INTERFACE = 'sspanelv2'/API_INTERFACE = 'mudbjson'/" userapiconfig.py
sed -i "s/SERVER_PUB_ADDR = '127.0.0.1'/SERVER_PUB_ADDR = '$(wget -qO- -t1 -T2 ipinfo.io/ip)'/" userapiconfig.py
menu
}

createaccount(){
cd /root/shadowsocksr
echo -e "${Green}Please specify a name for this new account:${Font}"
read accountname
echo -e "${Green}Please specify a port for this new account:${Font}"
read portnumber
echo -e "${Green}Please specify a password for this new account:${Font}"
read password
echo -e "${Green}Please specify traffic limit number (Gb) for this new account:${Font}"
read trafficlimit
python mujson_mgr.py -a -u $accountname -p $portnumber -k $password -m aes-256-cfb -O auth_chain_a -o tls1.2_ticket_auth -t $trafficlimit
menu
}

startonrun(){
cd /root/shadowsocksr
chmod +x *.sh
chmod +x /etc/rc.d/rc.local
sed -in-place -e '$a /bin/bash /root/shadowsocksr/run.sh' /etc/rc.d/rc.local
touch /etc/systemd/system/ssr.service
cat >> /etc/systemd/system/ssr.service << "EOF"
[Unit]
Description=ssr
After=syslog.target
After=network.target

[Service]
LimitCORE=infinity
LimitNOFILE=512000
LimitNPROC=512000
Type=simple
WorkingDirectory=/root/shadowsocksr
ExecStart=/usr/bin/python /root/shadowsocksr/server.py
ExecReload=/bin/kill -s HUP $MAINPID
ExecStop=/bin/kill -s TERM $MAINPID
Restart=always

[Install]
WantedBy=multi-user.target
EOF
systemctl enable ssr.service
systemctl restart ssr.service
service ssr status
menu
}

firewalld_iptables(){
systemctl stop firewalld
systemctl disable firewalld
systemctl status firewalld
menu
}

addtcpport(){
yum install iptables-services -y
read -p "请输入新增的TCP端口：" newport
iptables -I INPUT -p tcp --dport $newport -j ACCEPT
service iptables save
service iptables restart
chkconfig iptables on
iptables -L -n
menu
}

displayallports(){
cd /root/shadowsocksr/
python mujson_mgr.py -l
menu
}

clearporttraffic(){
cd /root/shadowsocksr/
read -p "将指定端口流量清零：" clearport
python mujson_mgr.py -c -p $clearport
menu
}

menu(){
    echo -e "${Red}系统升级 + 安装ShadowsocksR + 创建帐号 + 设置开机启动${Font}"
    echo -e "${Green}1.${Font} 仅系统升级"
    echo -e "${Green}2.${Font} 仅安装SSR"
    echo -e "${Green}3.${Font} 创建帐号"
    echo -e "${Green}4.${Font} 赋予SH可执行权限 并设置开机启动"
    echo -e "${Green}5.${Font} 关闭firewalld服务"
    echo -e "${Green}6.${Font} 清空所有防火墙规则"
    echo -e "${Green}7.${Font} 安装iptables 并开启指定TCP端口"
    echo -e "${Green}8.${Font} 显示本机全部已有端口"
    echo -e "${Green}9.${Font} 将指定端口流量清零"
    echo -e "${Green}10.${Font} 重启使所有规则生效"
    echo -e "${Green}11.${Font}  退出 \n"
    read -p "请输入数字：" menu_num
    case $menu_num in
        1)
          yum update -y
        ;;
        2)
          ssrinstaller
        ;;
        3)
          createaccount
          ;;
        4)
          startonrun
          ;;         
        5)
          firewalld_iptables
          ;; 
        6)
          iptables -F
          echo -e "${Green}所有防火墙规则已经清空${Font}"
          ;; 
        7)
          addtcpport
          ;; 
        8)
          displayallports
          ;; 
        9)
          clearporttraffic
          ;; 
        10)
          reboot
          ;; 
        11)
          exit 0
          ;;
        *)
          echo -e "${RedBG}请输入正确的数字${Font}"
          ;;
    esac
}

menu
