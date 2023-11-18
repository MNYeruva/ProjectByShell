#!/bin/bash

DATE=$(date +%F)
LOGSDIR=/tmp
# /home/centos/shellscript-logs/script-name-date.log
SCRIPT_NAME=$0
LOGFILE=$LOGSDIR/$0-$DATE.log
USERID=$(id -u)
R="\e[31m"
G="\e[32m"
N="\e[0m"
Y="\e[33m"

if [ $USERID -ne 0 ];
then
    echo -e "$R ERROR:: Please run this script with root access $N"
    exit 1
fi

VALIDATE(){
    if [ $1 -ne 0 ];
    then
        echo -e "$2 ... $R FAILURE $N"
        exit 1
    else
        echo -e "$2 ... $G SUCCESS $N"
    fi
}

yum module disable mysql -y &>> $LOGFILE
VALIDATE $? "Disabling default version"

cp /home/centos/ProjectByShell/mysql.repo /etc/yum.repos.d/mysql.repo &>> $LOGFILE
VALIDATE $? "Copying MYSQL repo"

yum install mysql-community-server -y &>> $LOGFILE
VALIDATE $? "Installing MYSQL Server"

systemctl enable mysqld &>> $LOGFILE
VALIDATE $? "Enabling mysql"
systemctl start mysqld &>> $LOGFILE
VALIDATE $? "Starting mysql"

mysql_secure_installation --set-root-pass RoboShop@1 &>> $LOGFILE
VALIDATE $? "Setting ROOT password"

