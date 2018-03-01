#!/bin/sh


ip=$(cat /var/etc/dnsmasq.conf  | grep dhcp-range | awk -F ',' '{print $2}')

limit=`uci get dhcp.lan.limit`
up=`uci get tz-qos.tzqos.up`
down=`uci get tz-qos.tzqos.down`

flag=`uci get tz-qos.tzqos.enable`
echo $ip
echo $limit
echo $down
echo $up
echo $flag

 if [ $flag == 1 ];then

  tz-qos -p $ip -l $limit -d $down -u $up
else

tz-qos -c
fi
