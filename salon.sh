#!/bin/bash

PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~~~ MY SALON ~~~~~\n"
echo -e "\nWelcome to My Salon, how can I help you?\n"

MAIN_MENU() {
  # handle error message
  if [[ $1 ]]
    then
    echo -e "\n$1\n"
  fi
  # display numbered service list
  SERVICES=$($PSQL "SELECT service_id, name FROM services")
  echo "$SERVICES" | while read SERVICE_ID BAR SERVICE
    do
    echo "$SERVICE_ID) $SERVICE"
  done
  
  APPOINTMENT
}

APPOINTMENT() {
  # get user input
  read SERVICE_ID_SELECTED
  # validate input
  SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED")
  if [[ -z $SERVICE_NAME ]]
    then
    # request for another input if invalid
    MAIN_MENU "I could not find that service. What would you like today?"
  else
    # ask for customer phone number
    echo -e "\nWhat's your phone number?"
    read CUSTOMER_PHONE
    NAME_RESULT=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE'")
    # if no customer has such number
    if [[ -z $NAME_RESULT ]]
      then  
      # request for name
      echo -e "\nI don't have a record for that phone number, what's your name?"
      read CUSTOMER_NAME
      NEW_CUSTOMER=$($PSQL "INSERT INTO customers(phone,name) VALUES ('$CUSTOMER_PHONE','$CUSTOMER_NAME')")
      else
      CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE'")
    fi
    # request for appointment time
    echo -e "\nWhat time would you like your$SERVICE_NAME, $CUSTOMER_NAME?"
    read SERVICE_TIME
    # insert data
    CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")
    APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments(customer_id,service_id,time) VALUES($CUSTOMER_ID,$SERVICE_ID_SELECTED,'$SERVICE_TIME')")
    echo -e "\nI have put you down for a$SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
  fi
  
}

MAIN_MENU