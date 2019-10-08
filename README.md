# repair_corrupted_pg_tables

Hello,

This script intend to identify the corrupt row and delete it. For sure the data will be lost and the best approach should be restoring any valid snapshot or backup. If you don't have any available, then this script can be a great way to move forward.

Here, we can see the issue
```
rhnschema=# select * from rhnpackagerepodata;
ERROR:  missing chunk number 0 for toast value 236162 in pg_toast_38779
rhnschema=# 
```

Basically, one script will analyze the complete table (row per row) searching for corrupt information and the output will be registered on the `/tmp/pg_check` log file.

The start point
```
# mkdir script
# cd script
# wget https://raw.githubusercontent.com/waldirio/repair_corrupted_pg_tables/master/check_pg.sh
# wget https://raw.githubusercontent.com/waldirio/repair_corrupted_pg_tables/master/cleanup_pg.sh
# chmod +x check_pg.sh
# chmod +x cleanup_pg.sh
# ./check_pg.sh 
Please provide the table name
exiting .....
```
Note. Mandatory inform the table name.

```
# ./check_pg.sh rhnpackagerepodata 
Number of rows: 211013
<< wait for a while ... >>
#
```
The script will be executed, if the table is ok, nothing will appear, if something is wrong, the output should be like below
```
# ./check_pg.sh rhnpackagerepodata 
Number of rows: 211013
...
ERROR:  missing chunk number 0 for toast value 279570 in pg_toast_38779
112304,rhnpackagerepodata
...
#
```

Now, we can see the information on the log `/tmp/pg_check.log`
```
# cat /tmp/pg_check.log
112304,rhnpackagerepodata
```
Above we have the offset and table name.

The next step will be to cleanup the info on the table, in order to proceed
```
# ./cleanup_pg.sh
Off: 112304, Table: rhnpackagerepodata
10-08-2019 18:36 - removing the offset: 112304, package_id: 112369 from table: rhnpackagerepodata
echo "delete from rhnpackagerepodata where package_id=112369" | spacewalk-sql -i
DELETE 1
```

And the corrupted row will be removed from the table. After that, you can rerun the full query and check if everything is ok.
```
rhnschema=# select * from rhnpackagerepodata;
<< all the info here >>
rhnschema=#
```

After that, I REALLY RECOMMEND you to run vacuum manually.
```
# su - postgres
$ psql rhnschema
rhnschema=# VACUUM FULL VERBOSE ANALYZE;
```
Your control files will be shrinked and everything will be great (at least, will not be failing).

Again, snapshot or valid backup is the best way EVER to fix DB data issues.

Enjoy it.
