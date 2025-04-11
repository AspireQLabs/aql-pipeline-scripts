#!/bin/bash

SERVICE_NAME=$1

# Exit if no service name is provided
if [ -z "$SERVICE_NAME" ]; then
  echo "Error: No service name provided."
  echo "Usage: $0 <service-directory>"
  exit 1
fi

# Start the service in background and save its PID
echo "Starting service: $SERVICE_NAME"
nohup ./mvnw spring-boot:run -f $SERVICE_NAME/pom.xml > ${SERVICE_NAME}.log 2>&1 &
echo $! > ${SERVICE_NAME}.pid

# Give the service some time to initialize
sleep 20
echo "$SERVICE_NAME started with PID $(cat ${SERVICE_NAME}.pid)"