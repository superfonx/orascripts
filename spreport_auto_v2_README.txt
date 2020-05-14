******************************************************************************************
script : spreport_auto_v2

Fonction : Générer un rapport statpack par jour entre 
			> deux dates au choix 
			> une heure de début et une heure de fin
			
Auteur : Sylvain FAUVEL / sylvain.fauvel@gmail.com

*******************************************************************************************

Concept :
*******************************************************************************************

spreport_auto_v2 generates a script that will then be used to create statspack reports.

Installation : 
*******************************************************************************************

1) Copy the script in the folder where you want to generate your statspack reports
2) copy the file spreport_param.sql to $OH/rdbms/admin/
3) open spreport_auto.sql and edit parameters as you wish

define HH24_START_SNAP='''07'''
=> start "hour" : the first snap taken between 07:00 and 08:00 will be used as start snapshot

define HH24_END_SNAP='''19'''
=> end "hour" : the first snap taken between 19:00 and 20:00 will be used as start snapshot

define num_days_back=10
=> number of days of history (start day)

define num_days=9
=> number of days generated from start day (start day). 
In this sample we rewind 10 days and generate 9 reports

define SPREP_FORMAT = 'text'
=> standard formats for statspack reports (text/html)

define DEFAULT_OUTPUT_FILENAME = 'spreport-generate.sql'
=> Name of staging scripts used to generate reports. You will thave to chek and run it.

>>>>>>>>>>>>>>>>>>>>>>>>>> WARNING <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
NB : If there are no snapshots matching HH24_START_SNAP or HH24_END_SNAP parameters, no report will be generated.
So choose these values according to your snapshot schedule
>>>>>>>>>>>>>>>>>>>>>>>>>> WARNING <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

Use 
*******************************************************************************************

1) run spreport_auto_v2.sql

2) check generated script (default name spreport-generate.sql)

3) Run generated it and get your reports in current folder.

Sample  
*******************************************************************************************

[oracle@localhost sf_orascripts]$ sqlplus perfstat/perfstat @/media/sf_orascripts/spreport_auto_v2.sql

[oracle@localhost sf_orascripts]$ spauto

SQL*Plus: Release 11.2.0.4.0 Production on Thu May 14 14:39:53 2020

Copyright (c) 1982, 2013, Oracle.  All rights reserved.


Connected to:
Oracle Database 11g Enterprise Edition Release 11.2.0.4.0 - 64bit Production
With the Partitioning and OLAP options


Current Instance
~~~~~~~~~~~~~~~~

   DB Id    DB Name      Inst Num Instance
----------- ------------ -------- ------------
 1539144224 ORCL                1 orcl

Specify output script name
~~~~~~~~~~~~~~~~~~~~~~~~~~
This script produces output in the form of another SQL script
The output script contains the commands to generate the statspack Reports

The default output file name is spreport-generate.sql
To accept this name, press <return> to continue, otherwise enter an alternative
--->
nomfichier : spreport-generate.sql

Script written to spreport-generate.sql - check and run in order to generate statspack reports...

NB : Check file for missing days searching for string "missing"

[oracle@localhost sf_orascripts]$ vi spreport-generate.sql
...
...

[oracle@localhost sf_orascripts]$ sqlplus perfstat/perfstat @/media/sf_orascripts/spreport-generate.sql
...
...

[oracle@localhost sf_orascripts]$ ls -ltr
-rwxrwx---. 1 root vboxsf      0 May 14 14:21 spreport_auto_v2_README.txt
-rwxrwx---. 1 root vboxsf   7396 May 14 14:26 spreport_auto_v2.sql
-rwxrwx---. 1 root vboxsf  40556 May 14 14:35 spreport-generate.sql
-rwxrwx---. 1 root vboxsf 193704 May 14 14:36 spreport_3861353112_1_95_101.txt
-rwxrwx---. 1 root vboxsf 188584 May 14 14:36 spreport_3861353112_1_131_137.txt
-rwxrwx---. 1 root vboxsf 192894 May 14 14:36 spreport_3861353112_1_143_149.txt
-rwxrwx---. 1 root vboxsf 173397 May 14 14:36 spreport_1539144224_1_182_324.txt
-rwxrwx---. 1 root vboxsf 207571 May 14 14:36 spreport_3861353112_1_167_173.txt
-rwxrwx---. 1 root vboxsf 194420 May 14 14:36 spreport_3861353112_1_107_113.txt
-rwxrwx---. 1 root vboxsf 203028 May 14 14:36 spreport_3861353112_1_83_89.txt
-rwxrwx---. 1 root vboxsf 191792 May 14 14:36 spreport_3861353112_1_119_125.txt
-rwxrwx---. 1 root vboxsf 201868 May 14 14:36 spreport_3861353112_1_155_161.txt

