#!/bin/bash
#__Author__ Majid Shiraazi
#__Contact__ majid@shiraazi.ir

db_user=root
db_password='123@abc'
db_name=asteriskcdrdb


for outwav in `mysql -u $db_user -p$db_password $db_name<<<"select recordingfile from cdr where recordingfile not like '/var/spool/%' AND calldate < DATE_SUB(CURDATE(), INTERVAL 1 DAY) ORDER BY calldate desc"`
do
    date=$(echo $outwav | cut -d'-' -f4)
    outmp3="$(echo $outwav | sed s/".wav"/".mp3"/)"
    year=${date:0:4}
    month=${date:4:2}
    day=${date:6:2}
    mysql -u $db_user -p$db_password $db_name<<<"UPDATE cdr SET recordingfile='/var/spool/asterisk/monitor/$year/$month/$day/$outmp3' WHERE recordingfile = '$outwav'"

done
