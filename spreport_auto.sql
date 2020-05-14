--  spreport_auto.sql: 
--  This script is creating a script that generates several statspack reports
--  
--  The target use is to generate a report for each day, between to specified hours 

--
--   Mettre à jour le fichier $ORACLE_HOME/rdbms/admin/spreport.sql
--   remplacer
--   select d.dbid  dbid  ,
--   d.name db_name
--   par
--   select decode( '&&dbid_force','',d.dbid,'&&dbid_force')  dbid,
--    , decode( '&&dbname_force','',d.name,'&&dbname_force') db_name 



define HH24_START_SNAP='''07'''
define HH24_END_SNAP='''19'''
define num_days=10

set feedback off
set echo off
set verify off
set timing off

-- Set SPREP_FORMAT to "text" or "html"
define SPREP_FORMAT = 'text'
define DEFAULT_OUTPUT_FILENAME = 'spreport-generate.sql'
define NO_ADDM = 0


define snapshosts_table_name = 'STATS$SNAPSHOT';

-- Get values for dbid and inst_num before calling TODO @@sprepins

set echo off heading on
column inst_num  heading "Inst Num"  new_value inst_num  format 99999;
column inst_name heading "Instance"  new_value inst_name format a12;
column db_name   heading "DB Name"   new_value db_name   format a12;
column dbid      heading "DB Id"     new_value dbid      format 9999999999 just c;

prompt
prompt Current Instance
prompt ~~~~~~~~~~~~~~~~

select d.dbid            dbid
     , d.name            db_name
     , i.instance_number inst_num
     , i.instance_name   inst_name
  from v$database d,
       v$instance i;


-- Ask the user for the name of the output script
prompt
prompt Specify output script name
prompt ~~~~~~~~~~~~~~~~~~~~~~~~~~
prompt This script produces output in the form of another SQL script
prompt The output script contains the commands to generate the statspack Reports
prompt
prompt The default output file name is &DEFAULT_OUTPUT_FILENAME
prompt To accept this name, press <return> to continue, otherwise enter an alternative
prompt
accept outfile_name char prompt '--- (Valeur par défaut &DEFAULT_OUTPUT_FILENAME ) -> ' default &DEFAULT_OUTPUT_FILENAME

prompt nomfichier : &&outfile_name

set heading off


--column outfile_name new_value outfile_name noprint;
--select 'Using the output file name ' || nvl('&&outfile__name','&DEFAULT_OUTPUT_FILENAME')
--     , nvl('&&outfile__name','&DEFAULT_OUTPUT_FILENAME') outfile_name
--  from sys.dual;

set linesize 300
set serverout on
set termout off

-- spool to outputfile
spool &outfile_name

-- write script header comments
prompt REM Temporary script created is named spreport_auto
prompt REM Used to create multiple statspack reports between two snapshots
prompt REM Start one is taken around &&HH24_START_SNAP and end one around &&HH24_END_SNAP
prompt REM Period is the last &&num_days days
select 'REM Created by user '||user||' on '||sys_context('userenv', 'host')||' at '||to_char(sysdate, 'DD-MON-YYYY HH24:MI') from dual;

set heading on
  
-- Begin iterating through snapshots and generating reports
DECLARE

  c_report_type    CONSTANT CHAR(4):= '&&SPREP_FORMAT';
  v_sp_reportname VARCHAR2(100);
  v_report_suffix  CHAR(5);

  CURSOR c_snapshots IS
  select 
           s.dbid,
           s.instance_number inst_num,
		   s.snap_id as start_snap_id , s.snap_time heure_debut, 
           e.snap_id as end_snap_id , e.snap_time heure_fin
      from &&snapshosts_table_name s , &&snapshosts_table_name e
     where 
       to_char(s.snap_time,'HH24')=  &&HH24_START_SNAP
       and to_char(e.snap_time,'HH24')= &&HH24_END_SNAP
	   and trunc(s.snap_time,'DD')=trunc(e.snap_time,'DD')
       and e.snap_id is not null
	   and s.snap_time > (sysdate - &&num_days )
  order by start_snap_id;

BEGIN

  dbms_output.put_line('');
  dbms_output.put_line('prompt Beginning statspack generation...');

  dbms_output.put_line('set heading off feedback off lines 800 pages 5000 trimspool on trimout on');

  -- Determine report type (html or text)
  IF c_report_type = 'html' THEN
    v_report_suffix := '.html';
  ELSE
    v_report_suffix := '.txt';
  END IF;

  -- Iterate through snapshots
  FOR cr_snapshot in c_snapshots
  LOOP
    -- Construct filename for statspack report
    v_sp_reportname := 'spreport_'||cr_snapshot.dbid||'_'||cr_snapshot.inst_num||'_'||cr_snapshot.start_snap_id||'_'||cr_snapshot.end_snap_id||v_report_suffix;

    dbms_output.put_line('------------------------------------------------------------------------------------------------------');
    dbms_output.put_line('prompt Creating statspack report '||v_sp_reportname
        ||' for instance number '||cr_snapshot.inst_num||' snapshots '||cr_snapshot.start_snap_id||' to '||cr_snapshot.end_snap_id);
    dbms_output.put_line('------------------------------------------------------------------------------------------------------');
    dbms_output.put_line('prompt');

    -- Disable terminal output to stop AWR text appearing on screen
    dbms_output.put_line('set termout off');

    dbms_output.put_line('prompt Creation du statspack '||v_sp_reportname);

    dbms_output.put_line('define num_days = 0;');
    dbms_output.put_line('define begin_snap='''||cr_snapshot.start_snap_id||''';');
    dbms_output.put_line('define end_snap='''||cr_snapshot.end_snap_id||''';');
    dbms_output.put_line('define report_name='''||v_sp_reportname||''';');

    -- Enable these lines if you want to use another dbid than the current database one
    --dbms_output.put_line('define dbid_force=''3861353112''');
	dbms_output.put_line('define dbid_force='''||cr_snapshot.dbid||'''');
	--dbms_output.put_line('define dbid_force='''||cr_snapshot.dbid||'''');

    --dbms_output.put_line('define dbname_force=''DBSWP''');

    dbms_output.put_line('@?/rdbms/admin/spreport.sql');

    dbms_output.put_line('set termout on');

  END LOOP;

  dbms_output.put_line('set heading on feedback 6 lines 100 pages 45');

    dbms_output.put_line('prompt End of creating statspack reports ');
    dbms_output.put_line('prompt');

-- EXCEPTION HANDLER?

END;
/

spool off

set termout on

prompt
prompt Script written to &outfile_name - check and run in order to generate statspack reports...
prompt

--clear columns sql
undefine outfile_name
undefine SPREP_FORMAT
undefine DEFAULT_OUTPUT_FILENAME
undefine NO_ADDM
undefine OUTFILE_NAME

set feedback 6 verify on lines 100 pages 45

exit

