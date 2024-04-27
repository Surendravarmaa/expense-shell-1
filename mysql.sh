#!/bin/bash

source ./common.sh

checkout

dnf install mysql-server -y &>>$LOGFILE
#VALIDATE $? "Installing MySQL Server"

systemctl enable mysqld &>>$LOGFILE
#VALIDATE $? "Enabling MySQL Server"

systemctl start mysqld &>>$LOGFILE
#VALIDATE $? "Starting MySQL Server"

mysql -h 172.31.67.129 -uroot -p${MYSQL_ROOT_PASSWORD} -e 'show databases;' &>>$LOGFILE
if [ $? -ne 0 ]
then 
    mysql_secure_installation --set-root-pass ${MYSQL_ROOT_PASSWORD} &>>$LOGFILE
    #VALIDATE $? "MySQL Root password setup"
else
    echo -e "Already mysql root password is set...$Y SKIPPING $N"
fi

#mysql_secure_installation --set-root-pass ExpenseApp@1 &>>$LOGFILE
#VALIDATE $? "Setting up root password"
