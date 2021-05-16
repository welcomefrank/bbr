#!/bin/bash

ffmepg_installer(){
yum install epel-release -y
rpm -v --import http://li.nux.ro/download/nux/RPM-GPG-KEY-nux.ro
rpm -Uvh http://li.nux.ro/download/nux/dextop/el7/x86_64/nux-dextop-release-0-5.el7.nux.noarch.rpm
yum install ffmpeg ffmpeg-devel -y
ffmpeg -version
}

ffmpeg_resize(){
read -p "请输入要压缩视频所在的文件夹地址" videodirectory
read -p "请输入要压缩视频后的" videodirectory

for file in `find . | grep ".mp4$"`;
do
newname=`basename -s .mp4 $file`
newdirname=`dirname $file`
output=$newdirname"/"$newname"_o.mp4"
 
tt=`ffprobe -v error -show_entries stream=width,height -of default=noprint_wrappers=1 $file`
 
echo $tt | awk -F'[ =]+' 
#'{print $2,$4}'
HandBrakeCLI -i $file -o $output -O -e x264 -q 22 -w $2 -l $4 -B 48
#HandBrakeCLI -i $file -o $output -O -e x264 -q 22 -w 1280 -l 720 -B 48
#mv $output $file
————————————————
版权声明：本文为CSDN博主「pipicfan」的原创文章，遵循CC 4.0 BY-SA版权协议，转载请附上原文出处链接及本声明。
原文链接：https://blog.csdn.net/pengfeicfan/article/details/108012383

done
}
