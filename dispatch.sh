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

yum install golang -y &<<$LOGFILE
VALIDATE $? "Installing Golang"

useradd roboshop &<<$LOGFILE
VALIDATE $? " roboshop user creating"

mkdir /app &<<$LOGFILE
VALIDATE $? "app directory creating"

curl -L -o /tmp/dispatch.zip https://roboshop-builds.s3.amazonaws.com/dispatch.zip &<<$LOGFILE
VALIDATE $? "Downloading dispatch artifacts"
cd /app &<<$LOGFILE
VALIDATE $? "Moving to app directory"
unzip /tmp/dispatch.zip &<<$LOGFILE
VALIDATE $? "Unzipping the artifacts"

cd /app 
go mod init dispatch &<<$LOGFILE
go get 
go build &<<$LOGFILE

cp /home/centos/ProjectByShell/dispatch.servic /etc/systemd/system/dispatch.servic &<<$LOGFILE
VALIDATE $? "Copyimg dispatch service"
systemctl daemon-reload &<<$LOGFILE
VALIDATE $? "Daemon Reloading"

systemctl enable dispatch &<<$LOGFILE
VALIDATE $? "Enabling dispatch"
systemctl start dispatch &<<$LOGFILE
VALIDATE $? "Starting dispatch"