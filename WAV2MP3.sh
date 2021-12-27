#!/bin/bash
#__Author__ Majid Shiraazi
#__Contact__ majid@shiraazi.ir

db_user=root
db_password='123@abc'
db_name=asteriskcdrdb

if [ $1 ]
then
    recorddir="/var/spool/asterisk/monitor/$1"
else
    recorddir="/var/spool/asterisk/monitor/"
fi
for wavfile in `find $recorddir -mtime +1 -name \*.wav`
do
    mp3file="$(echo $wavfile | sed s/".wav"/".mp3"/)"
    echo $wavfile
    nice lame -b 16 -m m -q 9-resample "$wavfile" "$mp3file"
    if [ -f $mp3file ];
    then
        echo "Now removing old WAV file: $wavfile"
        rm -f $wavfile
        mysql -u $db_user -p$db_password $db_name<<<"UPDATE cdr SET recordingfile='$mp3file' WHERE recordingfile = '$wavfile'"

    else
        echo "$wavfile encoding failed"
        exit 1
    fi
done

for outwav in `mysql -u $db_user -p$db_password $db_name<<<"select recordingfile from cdr where recordingfile not like '/var/spool/%' AND calldate < DATE_SUB(CURDATE(), INTERVAL 1 DAY) ORDER BY calldate desc"`
do
    date=$(echo $outwav | cut -d'-' -f4)
    outmp3="$(echo $outwav | sed s/".wav"/".mp3"/)"
    year=${date:0:4}
    month=${date:4:2}
    day=${date:6:2}
    mysql -u $db_user -p$db_password $db_name<<<"UPDATE cdr SET recordingfile='/var/spool/asterisk/monitor/$year/$month/$day/$outmp3' WHERE recordingfile = '$outwav'"

done
