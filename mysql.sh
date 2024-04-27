#!/bin/bash

USERID=$(id -u)
TIMESTAMP=$(date +%F-%H-%M-%S)
SCRIPT_NAME=$(echo $0 |cut -d "." -f1)
LOGFILE=/tmp/$SCRIPT_NAME-$TIMESTAMP.log
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

echo "Please enter DB password: "
read -s MYSQL_ROOT_PASSWORD

if [ $USERID -ne 0 ]
then 
    echo "Please run this script with root access."
    exit 1
else 
    echo "you are a super user."
fi

VALIDATE(){
    if [ $1 -ne 0 ]
    then
        echo -e "$2....$R FAILURE $N"
        exit 1
    else 
        echo -e "$2....$G SUCCESS $N"
    fi
}

dnf install mysql-server -y &>>$LOGFILE
VALIDATE $? "Installing MySQL Server"

systemctl enable mysqld &>>$LOGFILE
VALIDATE $? "Enabling MySQL Server"

systemctl start mysqld &>>$LOGFILE
VALIDATE $? "Starting MySQL Server"

mysql -h 172.31.28.88 -uroot -p${MYSQL_ROOT_PASSWORD} -e 'show databases;' &>>$LOGFILE
if [ $? -ne 0 ]
then 
    mysql_secure_installation --set-root-pass ${MYSQL_ROOT_PASSWORD} &>>$LOGFILE
    VALIDATE $? "MySQL Root password setup"
else
    echo -e "Already mysql root password is set...$Y SKIPPING $N"
fi

#mysql_secure_installation --set-root-pass ExpenseApp@1 &>>$LOGFILE
#VALIDATE $? "Setting up root password"
