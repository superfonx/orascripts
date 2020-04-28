
#define exclus="'APPQOSSYS','DBSNMP','EXFSYS','FLOWS_FILES','ORACLE_OCM','MDSYS','ORDSYS','ORDDATA','ORDPLUGINS','CTXSYS','SI_INFORMTN_SCHEMA','OUTLN','PUBLIC','SYS','SYSTEM','WMSYS','XDB','TSMSYS','SYSMAN','XDB','GSMADMIN_INTERNAL','GSMCATUSER','SYSBACKUP','DIP','SYSDG','XS$NULL','SYSKM','GSMUSER','AUDSYS','ANONYMOUS'"

define mon_db_link=CONCPROD

col object_name for A30
col owner for A30
set pages 500
set lines 500
set echo off
set show off
set verify off

prompt objects dans cible et pas dans source

select owner,object_name,object_type from dba_objects@&&mon_db_link where
(owner,object_name,object_type)
not in ( select owner,object_name,object_type from dba_objects )
and owner not in (select username from dba_users where oracle_maintained='Y')
and object_type not in ('LOB')
and object_name not like 'SYS_%';

prompt objets dans source et pas dans cible 

select owner,object_name,object_type from dba_objects where
(owner,object_name,object_type)
not in ( select owner,object_name,object_type from dba_objects@&&mon_db_link )
and owner not in (select username from dba_users where oracle_maintained='Y')
and object_type not in ('LOB')
and object_name not like 'SYS_%';

prompt synonyms dans cible et pas dans source

select decode( owner , 'PUBLIC' , 'create public synonym ' , 'create synonym '||OWNER||'.')||synonym_name||' for '||TABLE_OWNER||'.'||TABLE_NAME||decode(DB_LINK,null,'','@'||DB_LINK)||';'  from dba_synonyms@&&mon_db_link where
(owner,synonym_name,table_owner,table_name)
not in ( select owner,synonym_name,table_owner,table_name from dba_synonyms)
and owner not in (select username from dba_users where oracle_maintained='Y') and owner not like 'APEX%' ;

prompt synonyms dans source et pas dans cible 

select count(1) from dba_synonyms where
(owner,synonym_name,table_owner,table_name)
not in ( select owner,synonym_name,table_owner,table_name from dba_synonyms@&&mon_db_link)
and owner not in (select username from dba_users where oracle_maintained='Y') and owner not like 'APEX%' ;

prompt tab privs dans cible et pas dans source

select count(1) from dba_tab_privs@&&mon_db_link where
(owner,grantee,table_name,privilege)
not in ( select owner,grantee,table_name,privilege from dba_tab_privs )
and owner not in (select username from dba_users where oracle_maintained='Y') and owner not like 'APEX%' 
and grantee not in (select username from dba_users where oracle_maintained='Y') and grantee not like 'APEX%'
and table_name not like 'BIN$%'; --pas de tables en corbeille

prompt drill down : tab privs dans cible et pas dans source

select owner,grantee,table_name,privilege from dba_tab_privs@&&mon_db_link where
(owner,grantee,table_name,privilege)
not in ( select owner,grantee,table_name,privilege from dba_tab_privs )
and owner not in (select username from dba_users where oracle_maintained='Y') and owner not like 'APEX%' 
and grantee not in (select username from dba_users where oracle_maintained='Y') and grantee not like 'APEX%' 
and table_name not like 'BIN$%'; --pas de tables en corbeille
order by owner,grantee,table_name,privilege;


prompt tab privs dans source et pas dans cible 

select count(1) from dba_tab_privs where
(owner,grantee,table_name,privilege)
not in ( select owner,grantee,table_name,privilege from dba_tab_privs@&&mon_db_link )
and owner not in (select username from dba_users where oracle_maintained='Y') and owner not like 'APEX%' 
and grantee not in (select username from dba_users where oracle_maintained='Y') and grantee not like 'APEX%' ;

prompt sys privs dans cible et pas dans source

select count(1) from dba_sys_privs@&&mon_db_link where
(grantee,privilege)
not in ( select grantee,privilege from dba_sys_privs )
and grantee not in (select username from dba_users where oracle_maintained='Y') and grantee not like 'APEX%' ;

prompt drill down : sys privs dans cible et pas dans source 

select grantee,privilege from dba_sys_privs@&&mon_db_link where
(grantee,privilege)
not in ( select grantee,privilege from dba_sys_privs )
and grantee not in (select username from dba_users where oracle_maintained='Y') and grantee not like 'APEX%' 
order by grantee,privilege;

prompt sys privs dans source et pas dans cible 

select count(1) from dba_sys_privs where
(grantee,privilege)
not in ( select grantee,privilege from dba_sys_privs@&&mon_db_link )
and grantee not in (select username from dba_users where oracle_maintained='Y') and grantee not like 'APEX%' ;

prompt role privs dans cible et pas dans source

select count(1) from dba_role_privs@&&mon_db_link where
(grantee,granted_role)
not in ( select grantee,granted_role from dba_role_privs )
and grantee not in (select username from dba_users where oracle_maintained='Y') and grantee not like 'APEX%' ;

prompt role privs dans source et pas dans cible 

select count(1) from dba_role_privs where
(grantee,granted_role)
not in ( select grantee,granted_role from dba_role_privs@&&mon_db_link )
and grantee not in (select username from dba_users where oracle_maintained='Y') and grantee not like 'APEX%' ;

prompt objets invalides dans source et pas dans cible 

select sour.owner,sour.object_name,sour.object_type from 
dba_objects sour inner join dba_objects@&&mon_db_link cib 
on sour.owner=cib.owner 
and sour.object_type = cib.object_type 
and sour.object_name = cib.object_name
where
sour.status <> cib.status
and sour.status='INVALID'
and sour.owner not in (select username from dba_users where oracle_maintained='Y')
and sour.object_type not in ('LOB')
and sour.object_name not like 'SYS_%';

prompt sys privs dans cible et pas dans source

select owner,db_link from dba_db_links@&&mon_db_link where
(owner,db_link)
not in ( select owner,db_link from dba_db_links )
and owner not in (select username from dba_users where oracle_maintained='Y') and owner not like 'APEX%' ;



prompt contraintes dans source et pas dans cible 

select owner,constraint_name,constraint_type from dba_constraints 
where (owner,constraint_name,constraint_type) not in (select owner,constraint_name,constraint_type from dba_constraints@&&mon_db_link)
and owner not in (select username from dba_users where oracle_maintained='Y');

prompt contraintes dans cible et pas dans source

select owner,constraint_name,constraint_type from dba_constraints@&&mon_db_link
where (owner,constraint_name,constraint_type) not in (select owner,constraint_name,constraint_type from dba_constraints)
and owner not in (select username from dba_users where oracle_maintained='Y');

prompt contraintes dans cible et source mais status different

select loc.owner,loc.constraint_name,loc.constraint_type 
from dba_constraints loc inner join dba_constraints@&&mon_db_link dist on 
loc.owner=dist.owner and
loc.constraint_name=dist.constraint_name and
loc.constraint_type=dist.constraint_type
where 
loc.status <> dist.status  
and loc.owner not in (select username from dba_users where oracle_maintained='Y')
and loc.constraint_name not like 'SYS_%';


select 'create or replace synonym '||owner||'.'||synonym_name||' for '||TABLE_OWNER||'.'||TABLE_NAME||';' from dba_synonyms
where  (owner,synonym_name) in (select owner,object_name from dba_objects where status='INVALID')
and db_link is null;


select 'create or replace synonym '||owner||'.'||synonym_name||' for '||TABLE_OWNER||'.'||TABLE_NAME||';' from dba_synonyms
where  (owner,synonym_name) in (select owner,object_name from dba_objects where status='INVALID')
and db_link is null;

-- Correction - tests de db_links


select 
'connect '||lin.owner||'/'||pwdowner.pass||chr(13)||'drop database link '||db_link||';'||chr(13)||'create database link '||db_link||' connect to '||lin.username||' identified by '||pwd.pass||' using '''||host||''';'||chr(13)||'select 1 from dual@'||db_link||';'||chr(10)||chr(13)  as commande
from 
dba_db_links lin inner join export.user_passwords pwd on lin.username=pwd.username
inner join export.user_passwords pwdowner on lin.owner=pwdowner.username
where owner<>'PUBLIC'
and host like '%CONC_2_CONC%';


select 
'prompt test de '||owner||'.'||db_link||chr(13)|| 'connect '||owner||'/'||pwdowner.pass||chr(13)||'select 1 from dual@'||db_link||';'
from 
dba_db_links lin inner join export.user_passwords pwd on lin.username=pwd.username
inner join export.user_passwords pwdowner on lin.owner=pwdowner.username
where owner<>'PUBLIC';


select distinct owner,object_type,object_name from dba_objects where status='INVALID' and object_type <> 'SYNONYM';




