#!/bin/sh

#bootlocal.sh

#############################################################################
# Author: nkapashikov
# Configuring boot2docker / Tiny Core Linux network interfaces with static ip_addr.
# To use the script set the ip address for each interface that needs to have 
# an ip address. Place the below code in /var/lib/boot2docker/bootlocal.sh.
#
# More Information: https://github.com/boot2docker/boot2docker/issues/129
#
# For example to set eth0 and eth1 with static ip addresses:
#
# 1) set ETH0 variable to the desired ip address, 2) do the same for ETH1
# 2) change the regex to match only digits from 0 to 1 -  egrep -o "[0-1]"
# 3) adjust the NETMASK and 5) place the script in /var/lib/boot2docker/bootlocal.sh
#############################################################################

ETH1="10.129.56.196"
ETH2="10.129.56.197"
ETH3="10.129.56.198"
ETH4="10.129.56.199"
ETH5="10.129.56.200"

NETMASK="255.255.248.0"

for int_number in `ls /var/run/udhcpc.eth*.pid | egrep -o "[1-5]"`; do 
	kill `cat /var/run/udhcpc.eth${int_number}.pid`
	eval thisIP="\$ETH$int_number"
	ifconfig eth$int_number $thisIP netmask $NETMASK
done