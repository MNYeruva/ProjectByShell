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

yum install python36 gcc python3-devel -y &>> $LOGFILE
VALIDATE $? "Installing Python3" 

useradd roboshop &>> $LOGFILE
VALIDATE $? "creating user roboshop"

mkdir /app &>> $LOGFILE
VALIDATE $? "Creating app directory"

curl -L -o /tmp/payment.zip https://roboshop-builds.s3.amazonaws.com/payment.zip &>> $LOGFILE
VALIDATE $? "Downloading payment artifacts"

cd /app 
VALIDATE $? "Moving app directory"
unzip /tmp/payment.zip &>> $LOGFILE
VALIDATE $? "Unzipping payment app"

cd /app 
pip3.6 install -r requirements.txt &>> $LOGFILE
VALIDATE $? "Installing dependencies"

cp /home/centos/ProjectByShell/payment.service /etc/systemd/system/payment.service &>> $LOGFILE
VALIDATE $? "Copying payment service"

systemctl daemon-reload &>> $LOGFILE
VALIDATE $? "Daemon reload"
systemctl enable payment &>> $LOGFILE
VALIDATE $? "Enabling payment"
systemctl start payment &>> $LOGFILE
VALIDATE $? "Starting payment"