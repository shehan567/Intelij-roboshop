#!/bin/bash

### Functions
Print () {
  echo -e "\t\t\t\e[5;1;4;34m$1\e[0m"
}


frontend () {
  Print "Installing Frontend"
}


#mongodb


#catalogue
#redis


#user


#cart


#mysql


#shipping


#rabbitmq


#payment







# Main Program

case $1 in
  frontend)
    frontend
    ;;
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

esac
