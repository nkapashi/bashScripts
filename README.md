

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

As this will be run with a scheduler such as cron every x minutes, the script implements a check whether another instance is running. All operations arerecorded in a log file. 

*Example use case - checking if events stored in a database table are not pilling up.*

------

