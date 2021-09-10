#!/bin/sh
set -x

db=api01
filename=api01

#is32bit=`file ${CUBRID}/bin/cubrid | grep "32-bit" | wc -l`

cp $CUBRID/conf/cubrid.conf $CUBRID/conf/cubrid.conf_ori
#sed -i 's/data_/#data_/g' $CUBRID/conf/cubrid.conf

#echo "data_buffer_size=512M" >>$CUBRID/conf/cubrid.conf
#echo "[@$db2]" >>$CUBRID/conf/cubrid.conf
#echo "data_buffer_size=768M" >>$CUBRID/conf/cubrid.conf

cubrid createdb $db en_US --db-volume-size=128M --log-volume-size=128M
#cubrid_createdb $db2 

cubrid server start $db 
#cubrid paramdump $db |grep data |grep -v data_file_os_advise >bug_5188.result
gcc -g -o ${filename} -I$CUBRID/include -L$CUBRID/lib -lcubridcs ${filename}.c

./${filename} localhost 1523 $db > api01.result

if [ `grep "FAIL" api01.result |wc -l` -eq 0 ]
then
	echo 'PASS api01' >> $CDC_TEST/result
else
	echo 'FAIL api01' >> $CDC_TEST/result
fi

cubrid server stop $db 

cubrid deletedb $db 

rm $CUBRID/conf/cubrid.conf
mv $CUBRID/conf/cubrid.conf_ori $CUBRID/conf/cubrid.conf

rm -rf lob/

rm core*
rm $filename
rm ${filename}.result
