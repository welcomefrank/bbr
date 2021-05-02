hostnamectl
read -p "请确认本机架构是kvm/xen? 按n回车表示否并退出 按其它任意键继续" structurestatus 
if [ $structurestatus != "n" ];then
echo -e "本机架构是kvm/xen 可以继续"
else 
exit 0
fi
yum install wget kernel-firmware grubby dracut-kernel -y
echo -e "本机目前内核如下:"
uname -a
cat /etc/redhat-release
read -p "请确认本机Centos版本? 如7.2 需要保留1位小数" centosversion
if [ $centosversion = 6.7 ];then
wget http://github.itzmx.com/1265578519/kernel/master/6.5/kernel-2.6.32-504.el6.x86_64.rpm
kernelfile='kernel-2.6.32-504.el6.x86_64.rpm'
elif [ $centosversion = 6.8 ];then
wget http://ftp.scientificlinux.org/linux/scientific/6.6/x86_64/updates/security/kernel-2.6.32-504.3.3.el6.x86_64.rpm
kernelfile='kernel-2.6.32-504.3.3.el6.x86_64.rpm'
elif [ $centosversion = 6.9 ];then
wget http://vault.centos.org/6.6/cr/x86_64/Packages/kernel-2.6.32-573.1.1.el6.x86_64.rpm
kernelfile='kernel-2.6.32-573.1.1.el6.x86_64.rpm'
elif [ $centosversion = 7.0 ];then
wget https://buildlogs.centos.org/c7.01.u/kernel/20150327030147/3.10.0-229.1.2.el7.x86_64/kernel-3.10.0-229.1.2.el7.x86_64.rpm
kernelfile='kernel-3.10.0-229.1.2.el7.x86_64.rpm'
elif [ $centosversion = 7.1 ];then
wget http://ftp.scientificlinux.org/linux/scientific/7.1/x86_64/updates/security/kernel-3.10.0-229.1.2.el7.x86_64.rpm
kernelfile='kernel-3.10.0-229.1.2.el7.x86_64.rpm'
elif [ $centosversion = 7.2 ];then
wget http://ftp.scientificlinux.org/linux/scientific/7.1/x86_64/updates/security/kernel-3.10.0-229.1.2.el7.x86_64.rpm
kernelfile='kernel-3.10.0-229.1.2.el7.x86_64.rpm'
elif [ $centosversion = 7.3 ];then
wget https://buildlogs.centos.org/c7.01.u/kernel/20150327030147/3.10.0-229.1.2.el7.x86_64/kernel-3.10.0-229.1.2.el7.x86_64.rpm
kernelfile='kernel-3.10.0-229.1.2.el7.x86_64.rpm'
elif [ $centosversion = 7.4 ];then
wget https://buildlogs.centos.org/c7.01.u/kernel/20150327030147/3.10.0-229.1.2.el7.x86_64/kernel-3.10.0-229.1.2.el7.x86_64.rpm
kernelfile='kernel-3.10.0-229.1.2.el7.x86_64.rpm'
elif [ $centosversion = 7.5 ];then
wget https://buildlogs.centos.org/c7.01.u/kernel/20150327030147/3.10.0-229.1.2.el7.x86_64/kernel-3.10.0-229.1.2.el7.x86_64.rpm
kernelfile='kernel-3.10.0-229.1.2.el7.x86_64.rpm'
elif [ $centosversion = 7.6 ];then
wget https://buildlogs.centos.org/c7.01.u/kernel/20150327030147/3.10.0-229.1.2.el7.x86_64/kernel-3.10.0-229.1.2.el7.x86_64.rpm
kernelfile='kernel-3.10.0-229.1.2.el7.x86_64.rpm'
elif [ $centosversion = 7.7 ];then
wget https://buildlogs.centos.org/c7.1511.00/kernel/20151119220809/3.10.0-327.el7.x86_64/kernel-3.10.0-327.el7.x86_64.rpm
kernelfile='kernel-3.10.0-229.1.2.el7.x86_64.rpm'
else
read -p "暂时没有合适的 请根据本机内核填入合适的下载链接" kernellink
wget $kernellink
kernelfile=${kernellink##*/}
fi
read -p "将在本机安装内核$kernelfile 按任意键确认 按n回车表示放弃并退出" confirmkernel 
if [ $confirmkernel != "n" ];then
echo -e "确认将在本机安装内核$kernelfile"
else
exit 0
fi
rpm -ivh $kernelfile --force
echo -e "本机默认启动的内核 按顺序排列如下:"
grub2-editenv list
read -p "将重启机器使新安装内核生效 按任意键确认 按n回车表示放弃并退出" rebootvps 
if [ $rebootvps != "n" ];then
echo -e "正在重启本机使新内核生效"
reboot
else
exit 0
fi
