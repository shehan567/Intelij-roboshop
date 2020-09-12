#!/bin/bash

### Functions to use in Services
Print () {
  echo -e "\t\t\t\e[5;1;4;34m$1\e[0m"
}

USAGE() {
  echo -e "Usage\t\t\t : $0 \e[1;4;30m<Choose a Component from the below list to install>\e[0m"
  echo -e "Components\t\t : \e[32mfrontend \e[33mmongodb \e[34mredis \e[35mmysql \e[36mrabbitmq \e[34mcart \e[32mcatalogue \e[33mshipping \e[34mpayment \e[35muser\e[0m"
  echo -e "For all components use\t : all"
  exit 2
}

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

#### Functions for Services

######################### FRONT-END ####################

frontend () {
  Print "Installing Frontend Service"
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


##################### USAGE #########################







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
