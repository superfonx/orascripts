prompt Action ("enable" ou "disable") 
accept action default disable
prompt Owner des tables meres ET filles
accept owner
prompt Navette de filtrage des noms de table ( default TOUTES )
accept navtable default TOUTES
prompt Nom du fichier de script temporaire
accept fic default temp.sql
prompt Chaine de fin d'ordre (EXCEPTIONS INTO exceptions par exemple)
accept finordre

prompt Fabrication d'un script de modification de toutes les tables du schema &owner
prompt correspondant a la navette &navtable



Prompt 1 : Creation du fichier script de disable/enable
set heading off;
set feedback off;
set pagesize 3000; 
set lines 500
set verify off;
spool &fic
prompt spool &fic..log

select 'prompt '||owner||'.'||table_name||':'||constraint_name||chr(10)||'alter table '||owner||'.'||table_name||' &action constraint '||constraint_name||' &finordre;' from
(
select owner,table_name , constraint_name , constraint_type
  from dba_constraints fille 
  where owner=upper('&owner') and
  ( (fille.table_name like upper('&navtable') ) or ( '&navtable' = 'TOUTES' ) )
union
select owner,table_name , constraint_name , constraint_type
  from dba_constraints mere
  where owner=upper('&owner') and
  ( (mere.table_name like upper('&navtable') ) or ( '&navtable' = 'TOUTES' ) )
)
  order by table_name,decode (constraint_type, 'C',2 , 'P' , 1 , 'U', 3 , 'R' , 4 );

prompt spool off
spool off
set heading on;
set feedback on;
set verify on;

host vi &fic

Prompt 3 : Lancez le fichier script manuellement ( @&fic )

