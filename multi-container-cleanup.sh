#!/bin/bash

# Exit if no container names are provided
if [ "$#" -eq 0 ]; then
  echo "Error: No container names provided."
  exit 1
fi

# Check if any containers exist at all
ALL_CONTAINERS=$(docker container ls -a -q)
if [ -z "$ALL_CONTAINERS" ]; then
  echo "No containers exist on the system. Skipping cleanup."
  exit 0
fi

# Iterate over all container names provided as arguments
for CONTAINER_NAME in "$@"; do
  echo "Processing container: $CONTAINER_NAME"

  # Stop if running
  if [ "$(docker ps -q -f name=$CONTAINER_NAME)" ]; then
    echo "Stopping running container: $CONTAINER_NAME"
    docker stop $CONTAINER_NAME
  fi

  # Remove if exists
  if [ "$(docker ps -a -q -f name=$CONTAINER_NAME)" ]; then
    echo "Removing container: $CONTAINER_NAME"
    docker rm $CONTAINER_NAME
  fi

  echo "Cleanup complete for container: $CONTAINER_NAME"
done

exit 0
