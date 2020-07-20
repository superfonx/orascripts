echo "Collecte des évènements d attente " > collecte_events_session.txt
echo "---------------------------------------------------------" >> collecte_events_session.txt
echo "-" >> collecte_events_session.txt
 
while (true) 
do

#echo "---------------------------------------------------------" >> collecte_events_session.txt
#echo "----" `date` >> collecte_events_session.txt
#echo "---------------------------------------------------------" >> collecte_events_session.txt

sqlplus -s perfstat/perfstat<<EOF >> collecte_events_session.txt
set lines 500
set pages 500
set heading off
set newpage none
select to_char(sysdate,'DD/MM/YYYY HH24_MI_SS') snapdate,SID,SERIAL#,EVENT,SECONDS_IN_WAIT from v\$session
where WAIT_CLASS not in ('Idle');
EOF
sleep 4
done
