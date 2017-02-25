#!/bin/bash
# ########################################################################################
# Author: nkapashikov
# Script to kill HTTP session to SecureTransport server that are older than "$pastHours"
# Requires curl, GNU date, egrep with --only-matching option and bash.
# Works on RHEL, SuSe, Windows 10 bash or cywgin and possibly others.
# ########################################################################################

# Sessions older that "pastHours" will be terminated.
pastHours=6
# ST details #############
stHost='172.17.0.2:444'
credentials='admin_user:pass'
# END of ST Details ######

offsetGMT=`date +%z`
data=`curl -k -u $credentials "https://${stHost}/api/v1.1/sessions" | egrep -o "id.*|sessionCreationTime.*" | egrep -o "HTTP:[0-9a-z]*|.{26}${offsetGMT}" | while read line1; do read line2; echo "$line1 $line2"; done`

QTRESHOLD=$((`date +%s`-(pastHours*3600)))


diconnect_client(){
	echo "Diconnecting session with id " $1
	curl -k -X DELETE -u $credentials "https://${stHost}/api/v1.1/sessions/$1"
}

theMain(){
	IFS=$'\n'
	for entries in $data; do
		id=`echo $entries | egrep -o "HTTP:[0-9a-z]*"`
		theDate=`echo $entries | egrep -o ".{26}${offsetGMT}"`
		# Convert the time to unix time stamp		
		epochTime=`date --date=$theDate +"%s"`
		if [[ $epochTime < $QTRESHOLD ]];then
			diconnect_client $id
		else
			echo "Session" $id "is not old enough to be dropped"
		fi
	done
}

#RDY-JET-GO
theMain