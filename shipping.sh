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

yum install maven -y &>> $LOGFILE
VALIDATE $? "Installing Maven"

useradd roboshop $LOGFILE
mkdir /app $LOGFILE

curl -L -o /tmp/shipping.zip https://roboshop-builds.s3.amazonaws.com/shipping.zip &>> $LOGFILE
VALIDATE $? "Downloading Shipping artifacts"

cd /app
unzip /tmp/shipping.zip &>> $LOGFILE
VALIDATE $? "Unzipping artifacts of shipping"

cd /app
VALIDATE $? "Moving to app directory"
mvn clean package &>> $LOGFILE
VALIDATE $? "Packaging shipping app"
mv target/shipping-1.0.jar shipping.jar &>> $LOGFILE
VALIDATE $? "Renaming shipping.jar"

cp /home/centos/ProjectByShell/shipping.service /etc/systemd/system/shipping.service &>> $LOGFILE
VALIDATE $? "Copying shipping service"
systemctl daemon-reload &>> $LOGFILE
VALIDATE $? "Daemon reload"

systemctl enable shipping 
VALIDATE $? "Enabling shipping"
systemctl start shipping
VALIDATE $? "Starting shipping"
yum install mysql -y &>> $LOGFILE
VALIDATE $? "Installing MYSQL Client"
mysql -h <MYSQL-SERVER-IPADDRESS> -uroot -pRoboShop@1 < /app/schema/shipping.sql &>> $LOGFILE
VALIDATE $? "Loaded countries and cities info"
systemctl restart shipping
VALIDATE $? "Restarting shipping"