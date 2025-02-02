#!/bin/bash

# Start the client application
echo "Starting the client application..."
# Add your client application start command here
# Example: ./client_app

cd /home/david/Tep/tms-client

echo "Estas en el directorio: /home/david/Tep/tms-client"
# Find the current branch
current_branch=$(git branch --show-current)
echo "La rama actual es: $current_branch"

# Count and display 3 seconds
for i in {1..3}; do
  echo "$i"
  sleep 1
done

# Start the Angular development server
ng serve