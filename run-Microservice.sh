#!/bin/bash

# Define the microservice name
MICROSERVICE_NAME=""

# Define the path to the microservice executable
MICROSERVICE_PATH="/home/david/Tep/"
# select the microservice
echo "Select the microservice:"
echo "1. carrier-api"
echo "2. order-api"
echo "3. shipment-api"
echo "4. tms-core-api"

# read the selected option
read selected_option

# set the microservice path
case $selected_option in
  1)
    MICROSERVICE_NAME="carrier-api"
    ;;
  2)
    MICROSERVICE_NAME="order-api"
    ;;
  3)
    MICROSERVICE_NAME="shipment-api"
    ;;
  4)
    MICROSERVICE_NAME="tms-core-api"
    ;;
  *)
    echo "Invalid option."
    exit 1
    ;;
esac

# set the microservice path
MICROSERVICE_PATH="$MICROSERVICE_PATH$MICROSERVICE_NAME"

# check if the path exists
if [ ! -d "$MICROSERVICE_PATH" ]; then
  echo "The path $MICROSERVICE_PATH does not exist. Verify the directory."
  exit 1
fi

# change to the microservice path
cd $MICROSERVICE_PATH
echo "You are in the directory: $MICROSERVICE_PATH"

# get actual branch
current_branch=$(git branch --show-current)

# display the current branch
echo "The current branch is: $current_branch"

# count and display 3 seconds
for i in {1..3}; do
  echo "$i"
  sleep 1
done

# start the microservice
npm start serve