#!/bin/bash

set -e

# === USAGE EXAMPLE ===
# ./docker-deploy.sh gateway auth-service user-service

# === CONFIGURATION ===
CLEAN_SCRIPT="./pipeline-scripts/clean-containers.sh"
SERVICES_TO_CLEAN=("$@") # Accept services as arguments

# === CHECK ENV VARS ===
if [[ -z "$DOCKER_USER" || -z "$DOCKER_PASS" ]]; then
  echo "DOCKER_USER and DOCKER_PASS must be set as environment variables."
  exit 1
fi

# === STEP 1: CLEAN CONTAINERS ===
echo "Cleaning up existing containers..."
chmod +x "$CLEAN_SCRIPT"
"$CLEAN_SCRIPT" "${SERVICES_TO_CLEAN[@]}"
CLEAN_STATUS=$?

if [ $CLEAN_STATUS -ne 0 ]; then
  echo "Cleanup script failed with exit code $CLEAN_STATUS"
  exit $CLEAN_STATUS
fi

# === STEP 2: DOCKER LOGIN ===
echo "Logging into Docker..."
echo "$DOCKER_PASS" | docker login -u "$DOCKER_USER" --password-stdin

# === STEP 3: DOCKER COMPOSE DEPLOY ===
echo "Deploying services with docker compose..."
docker compose pull
docker compose up -d --force-recreate

# === STEP 4: DOCKER LOGOUT ===
echo "Logging out of Docker..."
docker logout

echo "Deployment completed."
