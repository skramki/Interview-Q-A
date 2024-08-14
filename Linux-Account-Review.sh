# Description:  		Linux Account review
# Verison:              1.0
# Author:               Cloud Team
# Script Source:		s3://AccountReview/Linux-Account-Review.sh
# Log File:             s3://AccountReview/MmmYYYY/<instancename>-<YYYYMMDDHHMMSS>.csv
# Set Variables
dos2unix $0
DATE_TIME=`date +"%y%m%d%H%M%S"`
DATE_MONTH=`date | awk '{print $2,$6}' | sed -e 's/ //g'`
HOSTS=`hostname -s`
LOG_FILE=$HOSTS-$DATE_TIME.csv
S3_BUCKET_URI="s3://AccountReview/$DATE_MONTH/"
ENABLE="Enable"
OS_LINUX_LOCAL_ACC_REV() {
echo "Hostname, Account Name, Password Last Change, Last Login, Password Expiry, Account Login Shell, Enable/Disable, Account Type, Remarks" > $LOG_FILE
for ACC_NAME in `cat /etc/passwd | egrep -v "shutdown|reboot|halt|sync" | egrep "sssd|aoc|admin|bash|^root" | cut -d: -f1`
do
HOSTS=`hostname -s`
LAST_PASSWD_CH=`sudo chage -l $ACC_NAME | egrep "Last password change" | cut -d: -f2 | sed -e 's/,//g' | awk '{print $2$1$3}'`
LAST_USER_LOGIN=`sudo last $ACC_NAME | head -1 | awk '{print $4,$5,$6,$7,$8,$9,$10}'`
PASSWD_EXPIRES_DT=`sudo chage -l $ACC_NAME | egrep "Password expires" | cut -d: -f2 | sed -e 's/,//g' | awk '{print $2$1$3}'`
ACC_LOGIN_SHELL=`cat /etc/passwd | egrep -w ^$ACC_NAME | cut -d: -f7`
if [ $ACC_LOGIN_SHELL == "/sbin/nologin" ]; then ENABLE="Disable"; fi
echo $HOSTS, $ACC_NAME, $LAST_PASSWD_CH, $LAST_USER_LOGIN, $PASSWD_EXPIRES_DT, $ACC_LOGIN_SHELL, $ENABLE
done >> $LOG_FILE
}
OS_LINUX_LOCAL_ACC_REV
## Copy LOG_FILE to S3 respect to Hostname
aws s3 cp $LOG_FILE $S3_BUCKET_URI
## Display Output of LOG_FILE
cat $LOG_FILE
## Cleanup LOG_FILE once uploaded to S3
rm $LOG_FILE 
