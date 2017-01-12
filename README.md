

# Shell Scripts

A drop off location for various shell scripts. Additional information and description for each shell script can be found below.

## **Contents:**

------

### ch_ad_pwd.sh

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

### **db_count_monitor.sh**

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

------

