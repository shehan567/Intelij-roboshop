#!/bin/bash

### Functions to use in Services

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

############### Out Put Redirectors#####################
log_frontend=/tmp/frontend.log
rm -f $log_frontend


#### Functions for Services

######################### FRONT-END ####################

frontend () {
  Print "Installing Frontend Service"
  yum install nginx -y &>> log_frontend
  Stat$? "Nginx Install\t\t\t\t"

}

###################### MONGO-DB ############################

mongodb () {
  Print "Installing mongodb"
}

###################### CATALOGUE ############################

catalogue () {
  Print "Installing Catalogue Service"
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

#frontend
#mongodb
#catalogue
#redis
#user
#cart
#mysql
#shipping
#rabbitmq
#payment