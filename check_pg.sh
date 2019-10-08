#!/bin/bash

if [ "$1" == "" ]; then
  echo "Please provide the table name"
  echo "exiting ....."
  exit 1
fi

LOG="/tmp/pg_check.log"
>$LOG

tablename=$1

count_row=$(echo "select count(*) from $tablename" | spacewalk-sql -i | grep -E -v '( count|----|\(|^$)' | awk '{print $1}')
echo "Number of rows: $count_row"

j=0

while ((j < $count_row))
do
#  echo $j
  echo "select * from $tablename order by package_id limit 1 offset $j" | spacewalk-sql -i >/dev/null || echo "The corrupt is: $j"
  su - postgres -c "psql -d rhnschema -c \"select * from $tablename order by package_id limit 1 offset $j\" >/dev/null || echo \"$j,$tablename\"" | tee -a $LOG
  ((j=j+1))
done
