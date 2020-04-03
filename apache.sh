status=`systemctl status httpd | grep Active:| awk '{print $2}'`
echo $status
if [ $status == "inactive" ]
then
    echo "Not running"
    sleep 1
    systemctl start httpd
    echo "Httpd Started"
else
   echo "Httpd Running"
fi
exit	
