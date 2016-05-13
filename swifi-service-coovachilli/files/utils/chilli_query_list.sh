# sh /etc/chilli/utils/chilli_query_list.sh #

NAME=chilli
RUN_PATH=/usr/sbin

#Check chilli running
if [ $(ps -w | grep -v grep | grep $RUN_PATH/$NAME | wc -l) -lt 1 ]
then
        echo "Chilli Not Running"
        exit
fi

# Get AP model.
model=$(cat /tmp/sysinfo/model | sed -e 's/\s\+/_/g')

. /lib/functions/network.sh; network_get_physdev if_wan wan;
#echo $if_wan

#Get AP MAC separator by '-' instead of ':'
mac=$(ifconfig $if_wan | awk '/HWaddr/ { print $5 }'|tr ':' '-')

#Set filename to save
file_name=$model"_"$mac".log"

# Remove file
rm $file_name

# Create file echo "" >> $file_name
touch $file_name


# Get list user on hotspot
chilli_query list|
    while read -r line
    do
        echo "$line" >> $file_name
    done

#print content file
cat $file_name

# upload file to server
curl --form "file=@"$file_name http://nms.s-wifi.vn/aptracker/writelog.php
