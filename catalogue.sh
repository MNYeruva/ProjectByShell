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

curl -o /tmp/catalogue.zip https://roboshop-builds.s3.amazonaws.com/catalogue.zip &>>LOGFILE
VALIDATE $? "Downloaded catalogue artifacts"
cd /app 
VALIDATE $? "Moving into app dir"
unzip /tmp/catalogue.zip &>>LOGFILE
VALIDATE $? "Unzpping catalogue"

cd /app 
VALIDATE $? "Moving into app dir"
npm install &>>LOGFILE  
VALIDATE $? "Installing Dependencies"

#Give full path of catalogue.service ,we are inside /app
cp /home/centos/ProjectByShell/catalogue.service /etc/systemd/system/catalogue.service &>>LOGFILE
VALIDATE $? "Copying catalogue.service"

systemctl daemon-reload &>>LOGFILE
VALIDATE $? "daemon-reload"
systemctl enable catalogue &>>LOGFILE
VALIDATE $? "enable catalogue"
systemctl start catalogue &>>LOGFILE
VALIDATE $? "start catalogue"

cp /home/centos/ProjectByShell/mongo.repo /etc/yum.repos.d/mongo.repo &>>LOGFILE
VALIDATE $? "Copying mongo.repo"

yum install mongodb-org-shell -y &>>LOGFILE
VALIDATE $? "Installing Mongo Client"
mongo --host mongodb.mnyeruca.online </app/schema/catalogue.js &>>LOGFILE
VALIDATE $? "Loading catalogue data into mongodb"