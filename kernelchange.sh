#fonts color
Green="\033[32m"
Red="\033[31m"
Yellow="\033[33m"
GreenBG="\033[42;37m"
RedBG="\033[41;37m"
Font="\033[0m"

cd /root

kernelchange(){
hostnamectl
read -p "请确认本机架构是kvm/xen? 按n回车表示否并退出 按其它任意键继续" structurestatus 
if [ $structurestatus = "n" ];then
exit 0
else 
echo -e "本机架构是kvm/xen 可以继续"
fi
yum install wget kernel-firmware grubby dracut-kernel -y
echo -e "本机目前内核如下:"
uname -a
cat /etc/redhat-release
read -p "请确认本机Centos版本? 如7.2 需要保留1位小数" centosversion

linkbroken(){
if [ $? -eq 0 ];then
echo -e "新内核已经下载完毕"
kernelfile=${kernellink##*/}
else
read -p "下载链接已坏 请重新提供新的下载链接" kernellinknew
wget -P /root $kernellinknew
kernelfile=${kernellinknew##*/}
fi
}
if [ $centosversion = 6.7 ];then
kernellink='http://github.itzmx.com/1265578519/kernel/master/6.5/kernel-2.6.32-504.el6.x86_64.rpm'
wget -P /root $kernellink
linkbroken
elif [ $centosversion = 6.8 ];then
kernellink='http://ftp.scientificlinux.org/linux/scientific/6.6/x86_64/updates/security/kernel-2.6.32-504.3.3.el6.x86_64.rpm'
wget -P /root $kernellink
linkbroken
elif [ $centosversion = 6.9 ];then
kernellink='http://vault.centos.org/6.6/cr/x86_64/Packages/kernel-2.6.32-573.1.1.el6.x86_64.rpm'
wget -P /root $kernellink
linkbroken
elif [ $centosversion = 7.0 ];then
kernellink='https://buildlogs.centos.org/c7.01.u/kernel/20150327030147/3.10.0-229.1.2.el7.x86_64/kernel-3.10.0-229.1.2.el7.x86_64.rpm'
wget -P /root $kernellink
linkbroken
elif [ $centosversion = 7.1 ];then
kernellink='http://ftp.scientificlinux.org/linux/scientific/7.1/x86_64/updates/security/kernel-3.10.0-229.1.2.el7.x86_64.rpm'
wget -P /root $kernellink
linkbroken
elif [ $centosversion = 7.2 ];then
kernellink='http://ftp.scientificlinux.org/linux/scientific/7.1/x86_64/updates/security/kernel-3.10.0-229.1.2.el7.x86_64.rpm'
wget -P /root $kernellink
linkbroken
elif [ $centosversion = 7.3 ];then
kernellink='https://buildlogs.centos.org/c7.01.u/kernel/20150327030147/3.10.0-229.1.2.el7.x86_64/kernel-3.10.0-229.1.2.el7.x86_64.rpm'
wget -P /root $kernellink
linkbroken
elif [ $centosversion = 7.4 ];then
kernellink='https://buildlogs.centos.org/c7.01.u/kernel/20150327030147/3.10.0-229.1.2.el7.x86_64/kernel-3.10.0-229.1.2.el7.x86_64.rpm'
wget -P /root $kernellink
linkbroken
elif [ $centosversion = 7.5 ];then
kernellink='https://buildlogs.centos.org/c7.01.u/kernel/20150327030147/3.10.0-229.1.2.el7.x86_64/kernel-3.10.0-229.1.2.el7.x86_64.rpm'
wget -P /root $kernellink
linkbroken
elif [ $centosversion = 7.6 ];then
kernellink='https://buildlogs.centos.org/c7.01.u/kernel/20150327030147/3.10.0-229.1.2.el7.x86_64/kernel-3.10.0-229.1.2.el7.x86_64.rpm'
wget -P /root $kernellink
linkbroken
elif [ $centosversion = 7.7 ];then
kernellink='https://buildlogs.centos.org/c7.1511.00/kernel/20151119220809/3.10.0-327.el7.x86_64/kernel-3.10.0-327.el7.x86_64.rpm'
wget -P /root $kernellink
linkbroken
else
read -p "暂时没有合适的 请根据本机内核填入合适的下载链接" kerneloklink
wget -P /root $kerneloklink
kernelfile=${kerneloklink##*/}
fi
read -p "将在本机安装新内核 按任意键确认 按n回车表示放弃并退出" confirmkernel 
if [ $confirmkernel = "n" ];then
exit 0 
else
echo -e "确认将在本机安装新内核$kernelfile"
fi
rpm -ivh /root/$kernelfile --force 2>&1 | tee logkernel.txt
if [ $? -eq 0 ]; then
echo -e "安装新内核成功"
else
echo -e "安装新内核失败"
fi
rm -rf /root/$kernelfile
rm -rf /root/logkernel.txt
echo -e "本机默认启动的内核 按顺序排列如下:"
grub2-editenv list
read -p "将重启机器使新安装内核生效 按任意键确认 按n回车表示放弃并退出" rebootvps 
if [ $rebootvps = "n" ];then
exit 0
else
echo -e "正在重启本机使新内核生效"
reboot
fi
}

Install_ServerSpeeder(){
	[[ -e ${Server_Speeder_file} ]] && echo -e "${Error} 锐速(Server Speeder) 已安装 !" && exit 1
	cd /root
	wget -N --no-check-certificate https://raw.githubusercontent.com/welcomefrank/scripts/main/serverspeeder.sh
	[[ ! -e "serverspeeder.sh" ]] && echo -e "${Error} 锐速安装脚本下载失败 !" && exit 1
	bash serverspeeder.sh
	sleep 2s
	PID=`ps -ef |grep -v grep |grep "serverspeeder" |awk '{print $2}'`
	if [[ ! -z ${PID} ]]; then
		rm -rf /root/serverspeeder.sh
		rm -rf /root/91yunserverspeeder
		rm -rf /root/91yunserverspeeder.tar.gz
		echo -e "${Info} 锐速(Server Speeder) 安装完成 !" && exit 1
	else
		echo -e "${Error} 锐速(Server Speeder) 安装失败 !" && exit 1
	fi
ln -s /serverspeeder/bin/serverSpeeder.sh /etc/init.d/serverspeeder
if [ $? -eq 0 ]; then
   echo -e "${GreenBG}已经将serverspeeder加入开机自动运行${Font}"
   else
   rm /etc/init.d/serverspeeder
   ln -s /serverspeeder/bin/serverSpeeder.sh /etc/init.d/serverspeeder
fi
chkconfig --add /etc/init.d/serverspeeder
service serverspeeder status
menu
}

menu(){
    echo -e "${Red}更换本机内核 + 锐速安装${Font}"
    echo -e "${Green}1.${Font} 半自动更新本机内核"
    echo -e "${Green}2.${Font} 安装锐速Serverspeeder 并 设置开机自动启动"
    echo -e "${Green}3.${Font} 查看本机锐速运行状态"
    echo -e "${Green}4.${Font}  退出 \n"
    read -p "请输入数字：" menu_num
    case $menu_num in
        1)
          kernelchange
        ;;
        2)
          Install_ServerSpeeder
        ;;
        3)
          service serverspeeder status
          menu
        ;;
        4)
          exit 0
          ;;
        *)
          echo -e "${RedBG}请输入正确的数字${Font}"
          ;;
    esac
}

menu
