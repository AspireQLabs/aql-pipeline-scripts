#!/bin/bash

# Run with:
# ./install.sh [module1 module2 ...]
# Supports env vars like:
#   MAVEN_OPTS="-Dopen.api.key=$OPEN_API_KEY -Danother.prop=value" ./install.sh ai-service gateway

set -e

MODULES="$@"
CMD="./mvnw clean install"

if [ -n "$MODULES" ]; then
  MODULE_LIST=$(echo "$MODULES" | tr ' ' ',')
  CMD="$CMD -pl $MODULE_LIST -am"
  echo "Installing selected modules: $MODULE_LIST"
else
  echo "Installing all modules"
fi

echo "Running: $CMD $MAVEN_OPTS"
$CMD $MAVEN_OPTS