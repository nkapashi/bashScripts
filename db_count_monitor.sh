#! /bin/bash
#################################################################################################
# Count the number of rows in MySQL table using SELECT COUNT(*) FROM table query. 
# If the count is above a threshold allow a predefined grace period. Send an alert
# if the row count is not below the threshold after the grace period has ended.
# As this will be run with a scheduler such as cron every x minutes, the script 
# implements a check whether another instance is running. All operations are
# recorded in a log file. 
# Example use case - checking if events stored in a database table are not pilling up.
# Author: nkapashikov
#################################################################################################

MYSQLHOME=/opt/mysql
MYSQLBINARY=$MYSQLHOME/bin/mysql
# Adjust the username, password and database name.
MYSQLCONF="--defaults-file=${MYSQLHOME}/conf/mysql.conf -uuser_name -psecret db_name"
# Adjust the SQL query.
MYSQLQUERY="SELECT COUNT(id) FROM EventQueue"
WHEREAMI="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
LOCKDIR=QLOCK
QTRESHOLD=1
GRACEPERIOD=60
NOCONN_ALERT_MSG="Cannot establish a connection to the dabase!"
QUEUE_ALERT_MSG="Event Queue is above the threshold!"
LOGFILE=QCHECK.LOG


check_set_lock(){
	# Check if there is a lock directory. Create one if such does not exist.
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
}


send_alert(){
	# This is just a demo. Put your alerting mechanism below:
	echo "$@"
}

get_qcount(){
	local qcount=`$MYSQLBINARY $MYSQLCONF -s -e "$MYSQLQUERY"`
	echo $qcount
}

check_status(){
	qcount=`get_qcount`
	if ! [[ "$qcount" =~ ^[0-9]+$ ]];then
		echo `date +"%e-%b-%Y %R:%S %Z"` "Cannot connect to the DB! Quitting..." \
		>> ${WHEREAMI}/${LOGFILE}
		send_alert $NOCONN_ALERT_MSG
		exit 1
	fi	
	if [[ "$qcount" > $QTRESHOLD ]];then
		echo `date +"%e-%b-%Y %R:%S %Z"` "Count is above threshold. Following up to check if recovered" \
		>> ${WHEREAMI}/${LOGFILE}
		sleep $GRACEPERIOD
		qcount=`get_qcount`
		if [[ "$qcount" > $QTRESHOLD ]];then
			echo `date +"%e-%b-%Y %R:%S %Z"` "Count has not recovered. Will send an alert!" \
			>> ${WHEREAMI}/${LOGFILE}
			send_alert $QUEUE_ALERT_MSG
		else
			echo `date +"%e-%b-%Y %R:%S %Z"` "Count has recovered. Will not send an alert!" \
			>> ${WHEREAMI}/${LOGFILE}
		fi
	else
		echo `date +"%e-%b-%Y %R:%S %Z"` "Count is Normal" \
		>> ${WHEREAMI}/${LOGFILE}
	fi
}


#RDY-JET-GO
check_set_lock
check_status