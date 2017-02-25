

# Shell Scripts

A drop off location for various bash scripts. Additional information and description for each bash/sh script can be found below.

## **Contents:**

------

## **ch_ad_pwd.sh**

Change your Microsoft Active Directory password with SAMBA and some DNS queries. In case you want to use this in Windows 10 bash note the below prerequisites:

1. Install smbclient

   ```
   #apt-get install smbclient
   ```

2. Edit /etc/samba/smb.conf and add interfaces = <your_ip>/32 Example: interfaces = 10.129.9.55/32

The second step is needed because the below ERROR message when running smblcient:

> ERROR: Could not determine network interfaces, you must use a interfaces config line

This is possibly related to https://github.com/Microsoft/BashOnWindows/issues/602

------

## **db_count_monitor.sh**

Count the number of rows in MySQL table using SELECT COUNT(*) FROM table query. If the count is above a threshold allow a predefined grace period. Send an alert if the row count is not below the threshold after the grace period has ended.

As this will be run with a scheduler such as cron every x minutes, the script implements a check whether another instance is running. The lock is done by using the **mkdir** command. Stale lock files are cleared by trapping all signal that can be trapped and deleting the directory recursively.

```
	if mkdir ${WHEREAMI}/${LOCKDIR}; then
		echo $$ > ${WHEREAMI}/${LOCKDIR}/PID
		# Clean up after the script is done or stopped. Note signal 9 cannot be trapped.
		# ref http://www.shelldorado.com/goodcoding/tempfiles.html
		trap 'rm -rf "$WHEREAMI/$LOCKDIR" >/dev/null 2>&1' 0
		trap "exit 2" 1 2 3 15
	else
		echo `date +"%e-%b-%Y %R:%S %Z"` "Another instance of the script is still running. Quitting..." \
		>> ${WHEREAMI}/${LOGFILE}
		exit 1
	fi
```

 All operations arerecorded in a log file. 

*Example use case - checking if events stored in a database table are not pilling up.*

## **rest_clean_http_sessions.sh**

Query REST API for connected clients to MFT server and disconnect the ones that have a session older than "$pastHours". 

*Example Response Body Element:*

```
{
  "session" : [ {
    "id" : "...",
    "userName" : "...",
    "host" : "...",
    "protocol" : "...",
    "userClass" : "...",
    "currentTransferBandwith" : "...",
    "command" : "...",
    "sessionCreationTime" : "...",
    "metadata" : {
      "links" : {
      }
    }
  }, ... ]
}
```

If "*sessionCreationTime*" is older than "$*pastHours*" , a second DELETE request is send with the   session id so the server to terminate the client connection.

The script uses utilities for parsing the JSON that are commonly installed on most Linux distros and Ubuntu Bash on windows/ Git Bash -  curl, GNU date and egrep.  JQ (sed for JSON) or anything similar to it are not used to keep the prerequisites to a minimum.

## **set_ip.sh**

A *bootlocal.sh* script for boot2docker / Tiny Core Linux. 

Configures defined network interfaces with static ip by first killing the dhcp client pid associated with the intrface and then using ifconfig  to set the desired ip address. Suitable in cases where configuring several network interfaces is needed. 

To use the script set the ip address for each interface that needs to have an ip address. Place the below code in /var/lib/boot2docker/bootlocal.sh.

For example to set eth0 and eth1 with static ip addresses:

1. set ETH0 variable to the desired ip address,  do the same for ETH1
2. change the regex to match only digits from 0 to 1 -  egrep -o "[0-1]"
3. adjust the NETMASK
4. place the script in /var/lib/boot2docker/bootlocal.sh

More Information: https://github.com/boot2docker/boot2docker/issues/129

------

