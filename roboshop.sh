#!/bin/bash

### Functions to use in Services
Print () {
  echo -e "\t\t\t\e[5;1;4;34m$1\e[0m"
}

USAGE() {
  echo -e "Usage\t\t\t : $0 \e[1;4;30m<Choose a Component from the below list to install>\e[0m"
}

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
