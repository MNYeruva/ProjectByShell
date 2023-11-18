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

curl -sL https://rpm.nodesource.com/setup_lts.x | bash &>>LOGFILE
VALIDATE $? "Setting NPM Source"

yum install nodejs -y &>>LOGFILE
VALIDATE $? "Installing NodeJS"

# 1st time run user created, if you ran this 2nd time it will failed due user is alraedy available
#1st chech the user already exist or not , if not then we will create the user.
useradd roboshop &>>LOGFILE

# Check the directory already exit or not
mkdir /app &>>LOGFILE

curl -o /tmp/cart.zip https://roboshop-builds.s3.amazonaws.com/cart.zip &>>LOGFILE
VALIDATE $? "Downloaded cart artifacts"
cd /app 
VALIDATE $? "Moving into app dir"
unzip /tmp/cart.zip &>>LOGFILE
VALIDATE $? "Unzpping cart"

cd /app 
VALIDATE $? "Moving into app dir"
npm install &>>LOGFILE  
VALIDATE $? "Installing Dependencies"

#Give full path of cart.service ,we are inside /app
cp /home/centos/ProjectByShell/cart.service /etc/systemd/system/cart.service &>>LOGFILE
VALIDATE $? "Copying cart.service"

systemctl daemon-reload &>>LOGFILE
VALIDATE $? "daemon-reload"
systemctl enable cart &>>LOGFILE
VALIDATE $? "enable cart"
systemctl start cart &>>LOGFILE
VALIDATE $? "start cart"

