#!/bin/bash

SERVICE_NAME=$1

# Exit if no service name is provided
if [ -z "$SERVICE_NAME" ]; then
  echo "Error: No service name provided."
  echo "Usage: $0 <service-name>"
  exit 1
fi

PID_FILE="${SERVICE_NAME}.pid"

if [ -f "$PID_FILE" ]; then
  echo "Stopping $SERVICE_NAME (PID: $(cat $PID_FILE))..."
  kill $(cat "$PID_FILE") || true
  rm "$PID_FILE"
  echo "$SERVICE_NAME stopped."
else
  echo "No PID file found for $SERVICE_NAME. Is it running?"
fi

#example usage sh stop-server.sh config-server