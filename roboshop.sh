#!/bin/bash

### Functions to use in Services

########################### All other functions Log file ########################

log_functions=/tmp/functions.log
rm -f $log_functions

####################### To Display Installation Message on Screen ###############
Print () {
  echo -e "\t\t\t\e[5;1;4;34m$1\e[0m"
}

################ To Notify that user must select a component to install################
USAGE() {
  echo -e "Usage\t\t\t : $0 \e[1;4;30m<Choose a Component from the below list to install>\e[0m"
  echo -e "Components\t\t : \e[32mfrontend \e[33mmongodb \e[34mredis \e[35mmysql \e[36mrabbitmq \e[34mcart \e[32mcatalogue \e[33mshipping \e[34mpayment \e[35muser\e[0m"
  echo -e "For all components use\t : all"
  exit 2
}

################## Verifying the User is the Root User or a Sudo User, If not notify the requirement###############
USER_ID=$(id -u)     ## id -u is linux command to get UID number. Root or Sudo is always 0.
case $USER_ID in
  0)
    true
    ;;
  *)
    echo -e "\t\t\e[1;4;31mScript Must Be Run as Root or Sudo User\e[0m"
    USAGE
    ;;
esac

##################### Function to verify and notify the command was executed successfully or not, and exit if failed ########
Stat() {
  case $1 in
  0)
    echo -e "$2 - \e[32mSUCCESS\e[0m"
    ;;
  *)
    echo -e "$2 - \e[31mFAILED\e[0m"
    exit 1
    ;;
  esac
}

########### Function to verify the operation is successful or not only, but continue to next step.
Stat_CONT() {
  case $1 in
  0)
    echo -e "$2 - \e[32mSUCCESS\e[0m"
    ;;
  *)
    echo -e "$2 - \e[31mFAILED\e[0m"
    ;;
  esac
}

###################### NodeJS Install Function ################################

Node_JS() {
  Print "Installing NodeJS"
  yum install nodejs make gcc-c++ -y &>> $log_functions
  Stat $? "NodeJS Install"
}

##################### Roboshop User Verification ############################
Roboshop_ID() {
  id roboshop &>> $log_functions
  case $1 in
  0)
    echo -e "\e[31mUser Roboshop Exist \e[0m"
    ;;
  *)
    Print "Adding Roboshop User"
    useradd roboshop
    Stat $? "Roboshop User Adding"
    ;;
  esac

}




#### Functions for Services

######################### FRONT-END ####################

frontend () {
  Print "Installing Frontend Service"
  log_file=/tmp/frontend.log         # Creating a log file
  rm -f $log_file

  yum install nginx -y &>> $log_file
  Stat $? "Nginx Install\t\t\t\t"

  curl -s -L -o /tmp/frontend.zip "https://dev.azure.com/DevOps-Batches/ce99914a-0f7d-4c46-9ccc-e4d025115ea9/_apis/git/repositories/db389ddc-b576-4fd9-be14-b373d943d6ee/items?path=%2F&versionDescriptor%5BversionOptions%5D=0&versionDescriptor%5BversionType%5D=0&versionDescriptor%5Bversion%5D=master&resolveLfs=true&%24format=zip&api-version=5.0&download=true" &>> log_file
  Stat $? "Downloading Frontend Schema\t\t"

  cd /usr/share/nginx/html
  rm -rf *
  unzip -o /tmp/frontend.zip &>> $log_file
  Stat $? "Extracting Frontend Schema \t\t"
  mv static/* .
  rm -rf static README.md
  mv localhost.conf /etc/nginx/nginx.conf
  Print "Starting Nginx"
  systemctl enable nginx
  systemctl start nginx
  ps -ef | grep nginx >> $log_file
  Stat $? "Nginx Start \t\t\t"
}

###################### MONGO-DB ############################

mongodb () {
  Print "Installing mongodb"
  log_file=/tmp/mongodb.log
  rm -f $log_file
  echo '[mongodb-org-4.2]
name=MongoDB Repository
baseurl=https://repo.mongodb.org/yum/redhat/$releasever/mongodb-org/4.2/x86_64/
gpgcheck=1
enabled=1
gpgkey=https://www.mongodb.org/static/pgp/server-4.2.asc' >/etc/yum.repos.d/mongodb.repo

yum install mongodb-org -y &>> log_file
Stat $? "MongoDB Installation \t\t\t"

Print "Updating MongoDB Configuration"
sed -i 's/127.0.0.1/0.0.0.0/' /etc/mongod.conf
Stat $? "IP Address Change"

Print "Starting MongoDB Service"
systemctl enable mongod
systemctl start mongod
Stat $? "MongoDB Start"

Print "Downloading Schema"
curl -s -L -o /tmp/mongodb.zip "https://dev.azure.com/DevOps-Batches/ce99914a-0f7d-4c46-9ccc-e4d025115ea9/_apis/git/repositories/e9218aed-a297-4945-9ddc-94156bd81427/items?path=%2F&versionDescriptor%5BversionOptions%5D=0&versionDescriptor%5BversionType%5D=0&versionDescriptor%5Bversion%5D=master&resolveLfs=true&%24format=zip&api-version=5.0&download=true"
Stat $? "Download Schema"

cd /tmp
Print "Extracting MongoDB Schema"
unzip -o mongodb.zip &>> $log_file
Stat $? "MongoDB Schema Extraction"

Print "Loading Catalogue & User Schema"
mongo < catalogue.js &>> $log_file
Stat $? "Catalogue Schema Loading"
mongo < users.js &>> $log_file
Stat $? "Users Schema Loading"

}

###################### CATALOGUE ############################

catalogue () {

  log_file=/tmp/catalogue.log
  rm -f $log_file
  Node_JS
  Roboshop_ID

}



###################### MONGO-DB ############################

redis () {
   Print "Installing Redis"
}


###################### USER ############################

user () {
   Print "Installing User Service"
}



###################### CART ############################

cart () {
   Print "Installing Cart Service"
}

###################### MySQL ############################

mysql () {
   Print "Installing MySQL"
}

###################### SHIPPING ############################

shipping () {
   Print "Installing Shipping Service"
}

###################### RabbitMQ ############################

rabbitmq () {
   Print "Installing RabbitMQ"
}

###################### PAYMENT ############################

payment () {
   Print "Installing Payment Service"
}



# Main Program

case $1 in
  frontend)
    frontend
    ;;
  mongodb)
    mongodb
    ;;
  catalogue)
    catalogue
    ;;
  redis)
    redis
    ;;
  user)
    user
    ;;
  cart)
    cart
    ;;
  mysql)
    mysql
    ;;
  shipping)
    shipping
    ;;
  rabbitmq)
    rabbitmq
    ;;
  payment)
    payment
    ;;
  all)
    frontend
    mongodb
    catalogue
    redis
    user
    cart
    mysql
    shipping
    rabbitmq
    payment
    ;;
  *)
    USAGE
    ;;
esac