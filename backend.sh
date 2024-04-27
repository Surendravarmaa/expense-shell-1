#!/bin/bash

source ./common.sh

checkout

failure(){
    echo "error at lineno $1 and command $2"
}

trap 'failure ${LINENO} "$BASH_COMMAND"' ERR


dnf module disable nodejs -y &>>$LOGFILE
#VALIDATE $? "Disabling default nodejs"

dnf module enable nodejs:20 -y &>>$LOGFILE
#VALIDATE $? "Enabling nodejs:20 Version"

dnf install nodejs -y &>>$LOGFILE 
#VALIDATE $? "Installing nodejs"

id expense &>>$LOGFILE
if [ $? -ne 0 ]
then 
    useradd expense &>>$LOGFILE
    #VALIDATE $? "Creating user expense"
else 
    echo -e "Expense user already created...$Y SKIPPING $N"
fi

mkdir -p /app &>>$LOGFILE
#VALIDATE $? "Creating app directory"

curl -o /tmp/backend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-backend-v2.zip &>>$LOGFILE
#VALIDATE $? "Downloading backend code"

cd /app
rm -rf /app/*
unzip /tmp/backend.zip
#VALIDATE $? "Extracted backend code"

npm install &>>$LOGFILE
#VALIDATE $? "Installing nodejs dependencies"

cp /home/ec2-user/expense-shell-1/backend.service /etc/systemd/system/backend.service &>>$LOGFILE
#VALIDATE $? "Copied backend service"

systemctl daemon-reload &>>$LOGFILE
#VALIDATE $? "Daemon Reload"

systemctl start backend &>>$LOGFILE
#VALIDATE $? "Starting backend"

systemctl enable backend &>>$LOGFILE
#VALIDATE $? "Enabling backend"

dnf install mysql -y &>>$LOGFILE
#VALIDATE $? "Installing Mysql client"

mysql -h  172.31.28.88 -uroot -p${MYSQL_ROOT_PASSWORD} < /app/schema/backend.sql &>>$LOGFILE
#VALIDATE $? "Schema loading"

systemctl restart backend &>>$LOGFILE
#VALIDATE $? "Restarting backend"