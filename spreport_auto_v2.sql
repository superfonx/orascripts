--  spreport_auto_v2.sql: 
--
--  This script is creating a script that generates several statspack reports
--  
--  The target use is to generate a report for each day, between to specified hours 
--
--  ***********************************************************************************
--  Check README before use
--  ***********************************************************************************

define HH24_START_SNAP='''07'''
define HH24_END_SNAP='''19'''
define num_days_back=10
define num_days=9
define SPREP_FORMAT = 'text'
define DEFAULT_OUTPUT_FILENAME = 'spreport-generate.sql'


set feedback off
set echo off
set verify off
set timing off

define snapshosts_table_name = 'STATS$SNAPSHOT';

-- Get values for dbid and inst_num for later use

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
accept outfile_name char prompt '---> ' default &DEFAULT_OUTPUT_FILENAME

prompt nomfichier : &&outfile_name

set heading off

set linesize 300
set serverout on
set termout off

-- spool to outputfile
spool &outfile_name

-- write script header comments
prompt REM Temporary script created is named spreport_auto
prompt REM Used to create multiple statspack reports between two snapshots
prompt REM Start one is taken around &&HH24_START_SNAP and end one around &&HH24_END_SNAP
prompt REM Period is from the last &&num_days_back days for &&num_days
select 'REM Created by user '||user||' on '||sys_context('userenv', 'host')||' at '||to_char(sysdate, 'DD-MON-YYYY HH24:MI') from dual;

set heading on
  
-- Begin iterating through snapshots and generating reports
DECLARE

  c_report_type    CONSTANT CHAR(4):= '&&SPREP_FORMAT';
  v_sp_reportname VARCHAR2(100);
  v_report_suffix  CHAR(5);

  vdbid number(20);
  vinst_num number(2);
  vstart_snap_id number(10);
  vend_snap_id number(10);

  cursor c_days is 
  select distinct trunc(snap_time) snap_day,dbid,instance_number inst_num from STATS$SNAPSHOT
		where snap_time between (sysdate - &&num_days_back ) and (sysdate - &&num_days_back + &&num_days );
  
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
  FOR cr_days in c_days
  LOOP
  
	begin 
		select 
			   s.dbid,
			   s.instance_number inst_num,
			   s.snap_id as start_snap_id 
	    into vdbid,vinst_num,vstart_snap_id
		from STATS$SNAPSHOT s 
		where 
		   to_char(s.snap_time,'HH24')=  &&HH24_START_SNAP
		   and trunc(snap_time) = cr_days.snap_day
		   and dbid=cr_days.dbid
		   and instance_number=cr_days.inst_num
		   and rownum=1;
    exception
        when no_data_found then
		  vdbid:=cr_days.dbid;
		  vinst_num:=cr_days.inst_num;
		  vstart_snap_id:=0;
	end;

	begin 
		select 
			   s.dbid,
			   s.instance_number inst_num,
			   s.snap_id as end_snap_id 
		into vdbid,vinst_num,vend_snap_id
		from STATS$SNAPSHOT s 
		where 
		   to_char(s.snap_time,'HH24')=  &&HH24_END_SNAP
		   and trunc(snap_time) = cr_days.snap_day
		   and dbid=cr_days.dbid
		   and instance_number=cr_days.inst_num
		   and rownum=1;
    exception
        when no_data_found then
		  vdbid:=cr_days.dbid;
		  vinst_num:=cr_days.inst_num;
		  vend_snap_id:=0;
	end;

		-- Construct filename for statspack report
		v_sp_reportname := 'spreport_'||vdbid||'_'||vinst_num||'_'||vstart_snap_id||'_'||vend_snap_id||v_report_suffix;

		dbms_output.put_line('------------------------------------------------------------------------------------------------------');
		dbms_output.put_line('prompt Creating statspack report '||v_sp_reportname
			||' for instance number '||vinst_num||' snapshots '||vstart_snap_id||' to '||vend_snap_id);
		dbms_output.put_line('------------------------------------------------------------------------------------------------------');
		dbms_output.put_line('prompt');
  
    if ( vstart_snap_id <> 0) and ( vend_snap_id <> 0) 
	then
	

		-- Disable terminal output to stop Statspack text appearing on screen
		--dbms_output.put_line('set termout off');

		dbms_output.put_line('prompt Creation du statspack '||v_sp_reportname);

		dbms_output.put_line('define num_days = 0;');
		dbms_output.put_line('define begin_snap='''||vstart_snap_id||''';');
		dbms_output.put_line('define end_snap='''||vend_snap_id||''';');
		dbms_output.put_line('define report_name='''||v_sp_reportname||''';');

		-- Have to force dbid in case of statspack repo containing several db data. Without that current one is used
		dbms_output.put_line('define dbid_force='''||vdbid||'''');

		--dbms_output.put_line('define dbname_force=''DBSWP''');

		dbms_output.put_line('@?/rdbms/admin/spreport_param.sql');

		dbms_output.put_line('set termout on');
    else
        dbms_output.put_line(' Report cannot be generated because of missing data :');
		dbms_output.put_line(' vdbid : '||vdbid);
		dbms_output.put_line(' vinst_num : '||vinst_num);	
		dbms_output.put_line(' vstart_snap_id : '||vstart_snap_id);	
		dbms_output.put_line(' vend_snap_id : '||vend_snap_id);	  
    end if;

  END LOOP;

  dbms_output.put_line('set heading on feedback 6 lines 100 pages 45');

    dbms_output.put_line('prompt End of creating statspack reports ');
    dbms_output.put_line('prompt');

    dbms_output.put_line('exit');
    dbms_output.put_line('prompt');

-- EXCEPTION HANDLER?

END;
/

spool off

set termout on

prompt
prompt Script written to &outfile_name - check and run in order to generate statspack reports...
prompt
prompt NB : Check file for missing days searching for string "missing"
prompt

--clear columns sql
undefine outfile_name
undefine SPREP_FORMAT
undefine DEFAULT_OUTPUT_FILENAME
undefine NO_ADDM
undefine OUTFILE_NAME

set feedback 6 verify on lines 100 pages 45

exit

