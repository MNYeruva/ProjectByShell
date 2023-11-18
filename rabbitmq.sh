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

curl -s https://packagecloud.io/install/repositories/rabbitmq/erlang/script.rpm.sh | bash &>> $LOGFILE
VALIDATE $? "Configure YUM Repos from the script "

curl -s https://packagecloud.io/install/repositories/rabbitmq/rabbitmq-server/script.rpm.sh | bash &>> $LOGFILE
VALIDATE $? "YUM Repos for RabbitMQ"

yum install rabbitmq-server -y &>> $LOGFILE
VALIDATE $? "Installing RabbitMQ"

systemctl enable rabbitmq-server &>> $LOGFILE
VALIDATE $? "Enabling RabbitMQ"
systemctl start rabbitmq-server &>> $LOGFILE
VALIDATE $? "Starting RabbitMQ"

rabbitmqctl add_user roboshop roboshop123 &>> $LOGFILE
VALIDATE $? "Adding user roboshop"
rabbitmqctl set_permissions -p / roboshop ".*" ".*" ".*" &>> $LOGFILE
VALIDATE $? "Setting permissions to user roboshop"