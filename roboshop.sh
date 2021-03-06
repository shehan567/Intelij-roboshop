#!/bin/bash

### Functions to use in Services

########################### All other functions Log file ########################

log_functions=/tmp/functions.log
rm -f $log_functions

########################## Domain Name Translation ########################$$$$$

DNS_DOMAIN_NAME="devopstrainingsolutions.com"

####################### To Display Installation Message on Screen ###############
Print () {
  echo -e "\t\t\t\e[5;1;4;34m$1\e[0m"
}

################ To Notify that user must select a component to install################
USAGE() {
  echo -e "Usage\t\t\t : $0 \e[1;4;30m<Choose a Component from the below list to install>\e[0m"
  echo -e "Components\t\t : \e[32mfrontend \e[33mmongodb \e[34mredis \e[35mMYSQL \e[36mrabbitmq \e[34mcart \e[32mcatalogue \e[33mshipping \e[34mpayment \e[35muser\e[0m"
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

######################################### Status_Check#########################################

Status_Check() {
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
  log_nodejs=/tmp/nodejs.log
  rm -f $log_nodejs
  yum install nodejs make gcc-c++ -y &>> $log_nodejs
  Stat $? "NodeJS Install"
  Roboshop_ID
  Print "Downloading Catalogue Application"
  curl -s -L -o /tmp/$1.zip "$2"
  Stat $? "Catalogue Application Download"
  Print "Extracting Application Archive"
  mkdir -p /home/roboshop/$1
  cd /home/roboshop/$1
  unzip -o /tmp/$1.zip &>> $log_nodejs
  Stat $? "Application Archives Extraction"
  Print "Install NodeJS Dependencies"
  npm --unsafe-perm install &>> log_nodejs
  Stat $? "NodeJS Dependencies Install"
  chown roboshop:roboshop /home/roboshop -R
  Stat $? "Roboshop User Permissions"
  Print "Setup $1 Service"
  mv /home/roboshop/$1/systemd.service /etc/systemd/system/$1.service
  sed -i -e "s/MONGO_ENDPOINT/mongodb.${DNS_DOMAIN_NAME}/" /etc/systemd/system/$1.service
  Stat $? "Mongo Update"
  sed -i -e "s/REDIS_ENDPOINT/redis.${DNS_DOMAIN_NAME}/" /etc/systemd/system/$1.service
  Stat $? REDIS UPDATE
  sed -i -e "s/CATALOGUE_ENDPOINT/catalogue.${DNS_DOMAIN_NAME}/" /etc/systemd/system/$1.service
  Stat $? "Catalogue Update"
  Print "Start $1 Service"
  systemctl daemon-reload
  systemctl enable $1
  systemctl start $1
  Stat $? "Starting $1 Service"
}

##################### Roboshop User Verification ############################
Roboshop_ID() {
  id roboshop &>> $log_functions
  case $? in
  0)
    echo -e "\t\t\t\e[1;4;31mRoboshop User Exist\e[0m"
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
  mv template.conf /etc/nginx/nginx.conf

  Print "Update DNS_DOMAINS in .conf file"

 export CATALOGUE=catalogue.${DNS_DOMAIN_NAME}
 export CART=cart.${DNS_DOMAIN_NAME}
 export USER=user.${DNS_DOMAIN_NAME}
 export SHIPPING=shipping.${DNS_DOMAIN_NAME}
 export PAYMENT=payment.${DNS_DOMAIN_NAME}

#  sed -i -e "s/CATALOGUE/${CATALOGUE}/" -e "s/CART/${CART}/" -e "s/USER/${USER}/" -e "s/SHIPPING/${SHIPPING}/" -e "s/PAYMENT/${PAYMENT}/" /etc/nginx/nginx.conf
#
#  Stat_CONT $? "Update DNS"
  sed -i "s/CATALOGUE/${CATALOGUE}/" /etc/nginx/nginx.conf
  Stat $? "Catalogue"
  sed -i "s/CART/${CART}/" /etc/nginx/nginx.conf
  Stat $? "Cart"
  sed -i "s/USER/${USER}/" /etc/nginx/nginx.conf
  Stat $? "User"
  sed -i "s/SHIPPING/${SHIPPING}/" /etc/nginx/nginx.conf
  Stat $? "Shipping"
  sed -i "s/PAYMENT/${PAYMENT}/" /etc/nginx/nginx.conf
  Stat $? "Payment"


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
  Node_JS "catalogue" "https://dev.azure.com/DevOps-Batches/ce99914a-0f7d-4c46-9ccc-e4d025115ea9/_apis/git/repositories/558568c8-174a-4076-af6c-51bf129e93bb/items?path=%2F&versionDescriptor%5BversionOptions%5D=0&versionDescriptor%5BversionType%5D=0&versionDescriptor%5Bversion%5D=master&resolveLfs=true&%24format=zip&api-version=5.0&download=true"

}

###################### REDIS ############################

redis () {
   Print "Installing Redis"

    log_file=/tmp/redis.log
    rm -f $log_file

      yum install epel-release yum-utils -y &>> $log_file
      Stat $? "Install YUM Utils"
      yum install http://rpms.remirepo.net/enterprise/remi-release-7.rpm -y &>> $log_file
      Stat_CONT $? "Download Remi Repos"
      yum-config-manager --enable remi &>> $log_file
      Stat $? "Enabling Remi Repos"
      yum install redis -y &>> $log_file
      Stat $? "Installing Redis"

    Print "Updating Redis Configuration"
      sed -i 's/127.0.0.1/0.0.0.0/' /etc/redis.conf
      Stat $? "BindIP Address Change"

    Print "Starting Redis"
    systemctl enable redis
    systemctl start redis
    Stat $? "Starting Redis"

}

###################### USER ############################

user () {
   Print "Installing User Service"
    log_file=/tmp/user.log
    rm -f $log_file
    Node_JS "user" "https://dev.azure.com/DevOps-Batches/ce99914a-0f7d-4c46-9ccc-e4d025115ea9/_apis/git/repositories/e911c2cd-340f-4dc6-a688-5368e654397c/items?path=%2F&versionDescriptor%5BversionOptions%5D=0&versionDescriptor%5BversionType%5D=0&versionDescriptor%5Bversion%5D=master&resolveLfs=true&%24format=zip&api-version=5.0&download=true"
}

###################### CART ############################

cart () {
   Print "Installing Cart Service"
    log_file=/tmp/cart.log
    rm -f $log_file
    Node_JS "cart" "https://dev.azure.com/DevOps-Batches/ce99914a-0f7d-4c46-9ccc-e4d025115ea9/_apis/git/repositories/ac4e5cc0-c297-4230-956c-ba8ebb00ce2d/items?path=%2F&versionDescriptor%5BversionOptions%5D=0&versionDescriptor%5BversionType%5D=0&versionDescriptor%5Bversion%5D=master&resolveLfs=true&%24format=zip&api-version=5.0&download=true"
}

###################### MySQL ############################

MYSQL () {
#    yum list installed | grep mysql-community-server
#  if [ $? -ne 0 ]; then
#    Print "Download MySQL"
#    curl -L -o /tmp/mysql-5.7.28-1.el7.x86_64.rpm-bundle.tar https://downloads.mysql.com/archives/get/p/23/file/mysql-5.7.28-1.el7.x86_64.rpm-bundle.tar
#    Status_Check
#    cd /tmp
#    Print "Extract Archive"
#    tar -xf mysql-5.7.28-1.el7.x86_64.rpm-bundle.tar
#    Status_Check
#    yum remove mariadb-libs -y
#    Print "Install MySQL"
#    yum install mysql-community-client-5.7.28-1.el7.x86_64.rpm \
#              mysql-community-common-5.7.28-1.el7.x86_64.rpm \
#              mysql-community-libs-5.7.28-1.el7.x86_64.rpm \
#              mysql-community-server-5.7.28-1.el7.x86_64.rpm -y
#    Status_Check
#  fi
#  systemctl enable mysqld
#  Print "Start MySQL"
#  systemctl start mysqld
#  Status_Check
#  echo 'show databases;' | mysql -uroot -ppassword
#  if [ $? -ne 0 ]; then
#      echo -e "ALTER USER 'root'@'localhost' IDENTIFIED BY 'Password@1';\nuninstall plugin validate_password;\nALTER USER 'root'@'localhost' IDENTIFIED BY 'password';" >/tmp/reset-password.sql
#      ROOT_PASSWORD=$(grep 'A temporary password' /var/log/mysqld.log | awk '{print $NF}')
#      Print "Reset MySQL Password"
#      mysql -uroot -p"${ROOT_PASSWORD}" < /tmp/reset-password.sql
#      Status_Check
#  fi
#  Print "Download Schema"
#  curl -s -L -o /tmp/mysql.zip "https://dev.azure.com/DevOps-Batches/ce99914a-0f7d-4c46-9ccc-e4d025115ea9/_apis/git/repositories/af9ec0c1-9056-4c0e-8ea3-76a83aa36324/items?path=%2F&versionDescriptor%5BversionOptions%5D=0&versionDescriptor%5BversionType%5D=0&versionDescriptor%5Bversion%5D=master&resolveLfs=true&%24format=zip&api-version=5.0&download=true"
#  Status_Check
#  Print "Extract Schema"
#  cd /tmp
#  unzip -o mysql.zip
#  Status_Check
#  Print "Load Schema"
#  mysql -u root -ppassword <shipping.sql
#  Status_Check

log_file=/tmp/mysql.log
rm -f $log_file

yum list installed | grep mysql-community-server   ### Validate MySQL Previously installed
  if [ $? -ne 0 ]; then
    Print "Installing MySQL"
      curl -L -o /tmp/mysql-5.7.28-1.el7.x86_64.rpm-bundle.tar https://downloads.mysql.com/archives/get/p/23/file/mysql-5.7.28-1.el7.x86_64.rpm-bundle.tar &>> $log_file
        Stat $? "Download MySQL"
      cd /tmp
      tar -xf mysql-5.7.28-1.el7.x86_64.rpm-bundle.tar &>> $log_file
        Stat $? "Extract MySQL"
    Print "Installing MySQL"
      yum remove mariadb-libs -y &>> $log_file
        Stat $? "Remove MariaDB"
      yum install mysql-community-client-5.7.28-1.el7.x86_64.rpm \
              mysql-community-common-5.7.28-1.el7.x86_64.rpm \
              mysql-community-libs-5.7.28-1.el7.x86_64.rpm \
              mysql-community-server-5.7.28-1.el7.x86_64.rpm -y &>> log_file
        Stat $? "Install MySQL"
  fi

Print "Starting MySQL"
  systemctl enable mysqld
  systemctl start mysqld
    Stat $? "Start MySQL"

  echo 'show databases;' | mysql -uroot -ppassword
  if [ $? -ne 0 ]; then
      echo -e "ALTER USER 'root'@'localhost' IDENTIFIED BY 'Password@1';\nuninstall plugin validate_password;\nALTER USER 'root'@'localhost' IDENTIFIED BY 'password';" >/tmp/reset-password.sql
      ROOT_PASSWORD=$(grep 'A temporary password' /var/log/mysqld.log | awk '{print $NF}')
      Print "Reset MySQL Password"
      mysql -uroot -p"${ROOT_PASSWORD}" < /tmp/reset-password.sql
      Stat $? "MYSQL Update"
  fi



Print "Downloading Shipping ASchema"

curl -s -L -o /tmp/mysql.zip "https://dev.azure.com/DevOps-Batches/ce99914a-0f7d-4c46-9ccc-e4d025115ea9/_apis/git/repositories/af9ec0c1-9056-4c0e-8ea3-76a83aa36324/items?path=%2F&versionDescriptor%5BversionOptions%5D=0&versionDescriptor%5BversionType%5D=0&versionDescriptor%5Bversion%5D=master&resolveLfs=true&%24format=zip&api-version=5.0&download=true"
Stat $? "Donwload Complete"

cd /tmp
unzip -o mysql.zip
mysql -uroot -ppassword <shipping.sql

Stat $? "Extract Schema"

}

###################### SHIPPING ############################

shipping () {

log_file=/tmp/shipping.log
rm -f $log_file

  Print "Installing Shipping Service"
    yum install maven -y &>> $log_file
      Stat $? "Installed Maven"
    Roboshop_ID
    cd /home/roboshop
  Print "Downloading Shipping Data"
    curl -s -L -o /tmp/shipping.zip "https://dev.azure.com/DevOps-Batches/ce99914a-0f7d-4c46-9ccc-e4d025115ea9/_apis/git/repositories/e13afea5-9e0d-4698-b2f9-ed853c78ccc7/items?path=%2F&versionDescriptor%5BversionOptions%5D=0&versionDescriptor%5BversionType%5D=0&versionDescriptor%5Bversion%5D=master&resolveLfs=true&%24format=zip&api-version=5.0&download=true" &>> $log_file
      Stat $? "Shipping Data Download"
    mkdir shipping
    cd shipping
  Print "Extracting Shipping Data"
    unzip -o /tmp/shipping.zip &>> $log_file
      Stat $? "Shipping Data Extraction"
    mvn clean package &>> $log_file
      Stat $? "MVN Clean pkg"
    mv target/*dependencies.jar shipping.jar

  Print "Adding Shipping Service to systemd"
    cp /home/roboshop/shipping/systemd.service /etc/systemd/system/shipping.service &>> $log_file
      Stat $? "Shipping Service Added to Systemd"
  Print "Starting Shipping Service"
    systemctl daemon-reload
    systemctl enable shipping
    systemctl start shipping
      Stat $? "Shipping Service Start"

}

###################### RabbitMQ ############################

rabbitmq () {
log_file=/tmp/rabbitmq.log
rm -f $log_file
yum list installed | grep esl-erlang.x86_64
 if [ $? -ne 0 ]; then
   Print "Installing RabbitMQ"
    yum install https://packages.erlang-solutions.com/erlang/rpm/centos/7/x86_64/esl-erlang_22.2.1-1~centos~7_amd64.rpm -y &>> $log_file
      Stat $? "Install ErLang"
fi
    curl -s https://packagecloud.io/install/repositories/rabbitmq/rabbitmq-server/script.rpm.sh | sudo bash &>> $log_file
      Stat $? "Install RabbitMQ Repos"
    yum install rabbitmq-server -y  &>> $log_file
      Stat $? "RabbitMQ Server Install"

  Print "Starting RabbitMQ Server"
    systemctl enable rabbitmq-server
    systemctl start rabbitmq-server
      Stat $? "RabbitMQ Server Start"

  Print "Create App User in RabbitMQ"
    rabbitmqctl add_user roboshop roboshop123
    rabbitmqctl set_user_tags roboshop administrator
    rabbitmqctl set_permissions -p / roboshop ".*" ".*" ".*"
      Stat $? "App User Creation"
}

###################### PAYMENT ############################

payment () {
log_file=/tmp/payment.log
rm -f $log_file
  Print "Installing Payment Service"
  Roboshop_ID
  Print "Install Python"
  yum install python36 gcc python3-devel -y &>> $log_file
    Stat $? "Install Python"
  Print "Download Application"
  curl -L -s -o /tmp/payment.zip "https://dev.azure.com/DevOps-Batches/ce99914a-0f7d-4c46-9ccc-e4d025115ea9/_apis/git/repositories/02fde8af-1af6-44f3-8bc7-a47c74e95311/items?path=%2F&versionDescriptor%5BversionOptions%5D=0&versionDescriptor%5BversionType%5D=0&versionDescriptor%5Bversion%5D=master&resolveLfs=true&%24format=zip&api-version=5.0&download=true" &>> $log_file
    Stat $? "Download Application"
  cd /home/roboshop
  mkdir payment
  cd payment
  Print "Extract Archive"
  unzip -o /tmp/payment.zip &>> $log_file
    Stat $? "Extraction"
  Print "Install Dependencies"
  pip3 install -r requirements.txt &>> $log_file
    Stat $? "Dependencies Install"
  chown roboshop:roboshop /home/roboshop -R
  mv /home/roboshop/payment/systemd.service /etc/systemd/system/payment.service
  sed -i -e "s/CARTHOST/cart.${DNS_DOMAIN_NAME}/" -e "s/USERHOST/user.${DNS_DOMAIN_NAME}/" -e "s/AMQPHOST/rabbitmq.${DNS_DOMAIN_NAME}/" /etc/systemd/system/payment.service
  systemctl daemon-reload
  systemctl enable payment
  Print "Start Payment Service"
  systemctl start payment
    Stat $? "Start Payment"
}

NGINX(){
  Print "Restarting Nginx"
  systemctl restart nginx
  Stat $? "Nginx Restart"
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
  MYSQL)
    MYSQL
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
  NGINX)
    NGINX
    ;;
  all)
    frontend
    mongodb
    catalogue
    redis
    user
    cart
    MYSQL
    shipping
    rabbitmq
    payment
    NGINX
    ;;
  *)
    USAGE
    ;;
esac