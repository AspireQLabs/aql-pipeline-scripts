#!/bin/bash

set -e

# === CONFIGURATION ===
DOCKER_REGISTRY="${DOCKER_REGISTRY:-docker.io}"
DOCKER_USER="${DOCKER_USER:?DOCKER_USER is not set}"
DOCKER_PASS="${DOCKER_PASS:?DOCKER_PASS is not set}"
IMAGE_BASE="${IMAGE_BASE:-my-docker-org/my-app}"
IMAGE_TAG="${IMAGE_TAG:-latest}"
MODULES=()


# === USAGE ===
usage() {
  echo "Usage: $0 --modules service1,service2,... [--image-base name] [--tag tag]"
  echo "Env vars required: DOCKER_USER, DOCKER_PASS"
  echo
  echo "Example:"
  echo '  DOCKER_USER=user DOCKER_PASS=pass IMAGE_BASE=myorg/app ./push-docker-images.sh --modules auth,user'
  exit 1
}

# === PARSE ARGS ===
while [[ $# -gt 0 ]]; do
  case "$1" in
    --modules)
      IFS=',' read -r -a MODULES <<< "$2"
      shift 2
      ;;
    --image-base)
      IMAGE_BASE="$2"
      shift 2
      ;;
    --tag)
      IMAGE_TAG="$2"
      shift 2
      ;;
    -h|--help)
      usage
      ;;
    *)
      echo "Unknown option: $1"
      usage
      ;;
  esac
done

if [ ${#MODULES[@]} -eq 0 ]; then
  echo "❌ No modules provided. Use --modules to specify which images to push."
  usage
fi

# === LOGIN ===
echo "Logging into Docker registry: $DOCKER_REGISTRY"
echo "$DOCKER_PASS" | docker login "$DOCKER_REGISTRY" -u "$DOCKER_USER" --password-stdin

# === PUSH EACH IMAGE ===
for module in "${MODULES[@]}"; do
  image="${IMAGE_BASE}-${module}:${IMAGE_TAG}"
  echo "Pushing image: $image"
  docker push "$image"
done

# === LOGOUT ===
docker logout "$DOCKER_REGISTRY"
echo "All images pushed successfully."
