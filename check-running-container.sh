#!/bin/bash

# Check if at least one argument is passed
if [ "$#" -lt 1 ]; then
  echo "Usage: $0 <container-name> [<container-name> ...]"
  exit 2
fi

all_running=true

for container in "$@"; do
  if ! docker ps --filter "name=${container}" --filter "status=running" --format '{{.Names}}' | grep -q "${container}"; then
    echo "Container '${container}' is NOT running."
    all_running=false
  else
    echo "Container '${container}' is running."
  fi
done

if [ "$all_running" = true ]; then
  exit 0
else
  exit 1
fi
