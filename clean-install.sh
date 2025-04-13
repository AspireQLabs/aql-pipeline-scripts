#!/bin/bash
# Example: ./clean-install.sh [maven-args] <modules>

MVN_ARGS=()
MODULES=()

for arg in "$@"; do
  if [[ "$arg" == -D* ]]; then
    MVN_ARGS+=("$arg")
  else
    MODULES+=("$arg")
  fi
done

for module in "${MODULES[@]}"; do
  echo "Building module: $module"
  (cd "$module" && mvn clean install "${MVN_ARGS[@]}")
done