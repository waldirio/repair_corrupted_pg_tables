#!/bin/bash

LOG="/tmp/pg_cleanup.log"
CURR_DATE=$(date +"%m-%d-%Y %H:%M")

while read line
do
  offset=$(echo $line | cut -d, -f1)
  table=$(echo $line | cut -d, -f2)
  echo "Off: $offset, Table: $table"

  pkg_id=$(echo "select package_id from $table limit 1 offset $offset" | spacewalk-sql -i | grep -v -E '(---|package_id|\()'|awk '{print $1}')
  echo "$CURR_DATE - removing the offset: $offset, package_id: $pkg_id from table: $table" | tee -a $LOG
  echo "echo \"delete from $table where package_id=$pkg_id\" | spacewalk-sql -i"
  echo "delete from $table where package_id=$pkg_id" | spacewalk-sql -i | tee -a $LOG
done < /tmp/pg_check.log
