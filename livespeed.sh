#!/bin/bash

ethn=$1

while true
do
  RX_pre=$(cat /proc/net/dev | grep $ethn | sed 's/:/ /g' | awk '{print $2}')
  TX_pre=$(cat /proc/net/dev | grep $ethn | sed 's/:/ /g' | awk '{print $10}')
  sleep 1
  RX_next=$(cat /proc/net/dev | grep $ethn | sed 's/:/ /g' | awk '{print $2}')
  TX_next=$(cat /proc/net/dev | grep $ethn | sed 's/:/ /g' | awk '{print $10}')

  clear
  echo -e "\t \033[32m 接收RX \033[0m 当前时间`date +%k:%M:%S` \033[31m 发送TX \033[0m"

  RX=$((${RX_next}-${RX_pre}))
  TX=$((${TX_next}-${TX_pre}))

  if [[ $RX -lt 1024 ]];then
#    RX="${RX}B/s" 
    RX=$(printf "%.1f" `echo "scale=1; $RX/1024" | bc`)
    RX="${RX}KB/s"        
  elif [[ $RX -gt 1048576 ]];then
#    RX=$(echo $RX | awk '{print $1/1048576 "MB/s"}')
    RX=$(printf "%.1f" `echo "scale=1; $RX/1048576" | bc`)
    RX="${RX}MB/s"
  else
#    RX=$(echo $RX | awk '{print $1/1024 "KB/s"}')
    RX=$(printf "%.1f" `echo "scale=1; $RX/1024" | bc`)
    RX="${RX}KB/s"  
  fi

  if [[ $TX -lt 1024 ]];then
#    TX="${TX}B/s"
    TX=$(printf "%.1f" `echo "scale=1; $TX/1024" | bc`)
    TX="${TX}KB/s"
  elif [[ $TX -gt 1048576 ]];then
#    TX=$(echo $TX | awk '{print $1/1048576 "MB/s"}')
    TX=$(printf "%.1f" `echo "scale=1; $TX/1048576" | bc`)
    TX="${TX}MB/s"
  else
#    TX=$(echo $TX | awk '{print $1/1024 "KB/s"}')
    TX=$(printf "%.1f" `echo "scale=1; $TX/1024" | bc`)
    TX="${TX}KB/s"
  fi

  echo -e "$ethn \t $RX   $TX "

done 
