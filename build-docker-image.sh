#!/bin/bash

set -e

# === DEFAULT CONFIGURATION (can be overridden via ENV or CLI args) ===
IMAGE_BASE="${IMAGE_BASE:-my-docker-org/my-app}"
IMAGE_TAG="${IMAGE_TAG:-latest}"
MODULES=()
BUILD_ARG_KEYS=("OPENAI_KEY" "ANOTHER_ARG") # Override in env or with --build-args

# === HELP ===
usage() {
  echo "Usage: $0 [--modules module1,module2,...] [--image-base name] [--tag tag] [--build-args KEY1,KEY2,...]"
  echo
  echo "Example:"
  echo "  IMAGE_BASE=myorg/project OPENAI_KEY=abc123 ./build-docker-images.sh --modules auth-service,user-service"
  exit 1
}

# === PARSE CLI ARGS ===
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
    --build-args)
      IFS=',' read -r -a BUILD_ARG_KEYS <<< "$2"
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

# === DETECT MODULES IF NONE PROVIDED ===
if [ ${#MODULES[@]} -eq 0 ]; then
  echo "No modules specified. Looking for folders with Dockerfiles..."
  for dir in */ ; do
    if [ -f "${dir}/Dockerfile" ]; then
      MODULES+=("${dir%/}")
    fi
  done
fi

if [ ${#MODULES[@]} -eq 0 ]; then
  echo "No modules found with Dockerfiles."
  exit 1
fi

# === FUNCTION TO BUILD A MODULE ===
build_module() {
  local module="$1"
  local image_name="${IMAGE_BASE}-${module}:${IMAGE_TAG}"

  echo "Building Docker image for: $module -> $image_name"

  # Construct build-arg flags
  local build_args=""
  for key in "${BUILD_ARG_KEYS[@]}"; do
    local value="${!key}"
    if [ -n "$value" ]; then
      build_args+=" --build-arg $key=$value"
    fi
  done

  docker build -f "${module}/Dockerfile" -t "$image_name" $build_args "$module"
}

# === MAIN SCRIPT ===
echo "Starting Docker image builds..."
for module in "${MODULES[@]}"; do
  build_module "$module"
done

echo "All Docker images built successfully."
