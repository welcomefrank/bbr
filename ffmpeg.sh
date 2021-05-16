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
read -p "请输入要压缩视频后的后缀" videotype

for fullfile in `find $videodirectory -type f -name *.$videotype`;
do
fullname="${fullfile##*/}"
dir="${fullfile%/*}"
extension="${fullname##*.}"
filename="${fullname%.*}"
echo -e "$dir, $fullname,$filename, $extension"
done
}

ffmpeg_resize
