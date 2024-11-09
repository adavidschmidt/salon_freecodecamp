#!/bin/bash

PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~~~ MY SALON ~~~~~\n"

SERVICE_MENU() {
  if [[ $1 ]]
  then
    echo -e "\n$1"
    SERVICES_TO_PROVIDE
  else
    echo -e "\nWelcome to my salon. What service would you like to schedule:"
    SERVICES_TO_PROVIDE
  fi
}

SERVICES_TO_PROVIDE() {
  # get available services
  AVAILABLE_SERVICES=$($PSQL "select service_id, name from services")
  echo "$AVAILABLE_SERVICES" | while read SERVICE_ID BAR NAME
  do
    echo "$SERVICE_ID) $NAME"
  done
  echo -e "\nWhich service would you like?"
  read SERVICE_ID_SELECTED
  # if not a number
  if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]
  then
    SERVICE_MENU "Please provide the number for the service you would like:"
  else
    SERVICE_NAME=$($PSQL "select name from services where service_id=$SERVICE_ID_SELECTED")
    # if service is not available
    if [[ -z $SERVICE_NAME ]]
    then
      SERVICE_MENU "That is not an available service, please confirm your selection is listed."
    else
      echo -e "\nPlease provide your phone number:"
      read CUSTOMER_PHONE
      CUSTOMER_ID=$($PSQL "select customer_id from customers where phone='$CUSTOMER_PHONE'")
      # if customer's number is not in the database
      if [[ -z $CUSTOMER_ID ]]
      then
        echo -e "\nPlease provide your name:"
        read CUSTOMER_NAME
        # insert new customer
        INSERT_CUSTOMER_RESULT=$($PSQL "insert into customers(name, phone) values('$CUSTOMER_NAME', '$CUSTOMER_PHONE')")
      fi
      # get appointment time
      echo -e "\nPlease indicate the time you would like to schedule:"
      read SERVICE_TIME
      CUSTOMER_ID=$($PSQL "select customer_id from customers where phone='$CUSTOMER_PHONE'")
      # add appointment to appointments
      INSERT_APPOINTMENT_RESULT=$($PSQL "insert into appointments(customer_id, service_id, time) values($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")
      echo -e "\nI have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
    fi
  fi
}

SERVICE_MENU