
variable jobno number;
variable instno number;
begin
  select instance_number into :instno from v$instance;
  dbms_job.submit(:jobno, 'statspack.snap(i_snap_level => 7, i_modify_parameter => ''true'');', trunc(sysdate+1/24,'HH'), 'trunc(SYSDATE+1/24,''HH'')', TRUE, :instno);
  commit;
end;
/

variable jobno number;
variable instno number;
begin
  select instance_number into :instno from v$instance;
  dbms_job.submit(:jobno, 'statspack.snap(i_snap_level => 7, i_modify_parameter => ''true'');', trunc(sysdate+1/24/12,'HH'), 'SYSDATE+1/24/12', TRUE, :instno);
  commit;
end;
/


   interval => 'TRUNC(SYSDATE + 1) + 7/24'

begin

for i in 1..100 
loop
  dbms_stats.gather_database_stats;
end loop;

end;
/
