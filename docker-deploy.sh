#!/bin/bash

set -e

# === USAGE EXAMPLES ===
# ./docker-deploy.sh gateway auth-service user-service
# ./docker-deploy.sh -f docker-compose-core.yml gateway auth-service
# ./docker-deploy.sh --file docker-compose-app.yml gateway

# === DEFAULT CONFIGURATION ===
COMPOSE_FILE="docker-compose.yml"
CLEAN_SCRIPT="./pipeline-scripts/clean-containers.sh"
SERVICES_TO_CLEAN=()

# === PARSE ARGS ===
while [[ $# -gt 0 ]]; do
  case $1 in
    -f|--file)
      COMPOSE_FILE="$2"
      shift 2
      ;;
    -*)
      echo "Unknown option: $1"
      exit 1
      ;;
    *)
      SERVICES_TO_CLEAN+=("$1")
      shift
      ;;
  esac
done

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
echo "Deploying services with docker-compose using file: $COMPOSE_FILE"
docker compose -f "$COMPOSE_FILE" pull
docker compose -f "$COMPOSE_FILE" up -d --force-recreate "${SERVICES_TO_CLEAN[@]}"

# === STEP 4: DOCKER LOGOUT ===
echo "Logging out of Docker..."
docker logout

echo "Deployment completed."
