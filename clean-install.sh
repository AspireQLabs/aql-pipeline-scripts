#!/bin/bash

# Example usage:
# ./clean-install.sh -Dai-service.openAi-api-key=xxx service1 service2 ...

MVN_ARGS=()
MODULES=()

# Separate -D args from module names
for arg in "$@"; do
  if [[ "$arg" == -D* ]]; then
    MVN_ARGS+=("$arg")
  else
    MODULES+=("$arg")
  fi
done

if [ ${#MODULES[@]} -eq 0 ]; then
  echo "No modules specified."
  exit 1
fi

for module in "${MODULES[@]}"; do
  echo "Building module: $module"
  (
    cd "$module" || { echo "❌ Module $module not found"; exit 1; }
    ./mvnw clean install "${MVN_ARGS[@]}"
  ) || exit 1
done

echo "All modules built successfully."
