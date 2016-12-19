# Shell Scripts

A drop off location for various shell scripts.

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
