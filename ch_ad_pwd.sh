#!/bin/bash

####################################################################
# Change AD password via linux or Windows 10 Bash. Author: nkapashikov
# To use with Windows 10 Linux Shell:
# 1st install smbclient: apt-get install smbclient
# 2nd edit /etc/samba/smb.conf and add interfaces = <your_ip>/32 Example: interfaces = 10.129.9.55/32
# The second step is needed because the below ERROR message when running smblcient:
# ERROR: Could not determine network interfaces, you must use a interfaces config line
# Possibly related to: https://github.com/Microsoft/BashOnWindows/issues/602
####################################################################


#Ask for the user name
echo "Please enter user name without the domain part. Example: nkapashikov: "
read USER
#Ask for the domain name
echo "Please enter the domain name in FQDN format. Example: contoso.com: "
read DOMAIN

##Find all PDC and present them in a list to pick from
RESULT=$(dig -t SRV +short _ldap._tcp.dc._msdcs.$DOMAIN | egrep -o "([a-z0-9]+(-[a-z0-9]+)*\.)+[a-z]{2,}")
arraryResult=($RESULT)
listNum=0
for x in $RESULT; do 
	listNum=$((listNum+1))
	echo $listNum $x; 
done

echo "Please select the number of Domain Controller that is closer to you. Example: 2 :"
read chosenPDC
chosenPDC=$((chosenPDC-1))
#We have all data needed. Use smbpasswd to change the password.
echo "Changing password via PDC" ${arraryResult[chosenPDC]}
smbpasswd -U $USER -r ${arraryResult[chosenPDC]}