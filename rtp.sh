#!/bin/bash

if [ "$#" -eq 2 ];then

if [ "$1" -gt "$2" ];then
   echo "Wrong parameter! $2";
   exit;
fi

for i in $(seq $1 $2)
do
   /etc/rtphotpot.pl $i &
done

else
   echo "usage: rtp.sh start_port_number end_port_number";
fi
