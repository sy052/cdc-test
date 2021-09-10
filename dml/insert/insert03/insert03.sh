#!/bin/sh
set -x

db=insert03db
filename=insert03
statement='CREATE TABLE insert03 (id int, c char(1000), v varchar(200))'
statement2="INSERT INTO insert03 values (100, 'ac', 'acc')"
count=100

cp $CUBRID/conf/cubrid.conf $CUBRID/conf/cubrid.conf_ori

echo "supplemental_log=1" >>$CUBRID/conf/cubrid.conf
cubrid createdb $db en_US --db-volume-size=128M --log-volume-size=128M

cubrid server start $db 

gcc -g -o ${filename} -I$CUBRID/include -L$CUBRID/lib -lcubridcs ${filename}.c

csql -u dba $db -c  "$statement"
for((i=0;i<$count;i++))
do
  csql -u dba $db -c  "$statement2" 
done
sleep .5
./${filename} localhost 1523 $db 0 &> ${filename}.result
#./${filename} localhost 1523 $db 0 

if [ `grep "DML SUCCESS" ${filename}.result |wc -l` -eq $count ]
then
	echo 'PASS01 '$filename'' >> $CDC_TEST/result
else
	echo 'FAIL01 '$filename'' >> $CDC_TEST/result
fi

if [ `grep "ERROR" ${filename}.result |wc -l` -eq 0 ]
then
	echo 'PASS03 '$filename'' >> $CDC_TEST/result
else
	echo 'FAIL03 '$filename'' >> $CDC_TEST/result
fi

cubrid server stop $db 
cubrid broker stop 
cubrid deletedb $db 

rm $CUBRID/conf/cubrid.conf
mv $CUBRID/conf/cubrid.conf_ori $CUBRID/conf/cubrid.conf

rm -rf lob/

rm $filename
rm ${filename}.result
rm cubrid_tracelog.err
