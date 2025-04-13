#!/bin/bash

set -e

MODULE=$1
MODE=$2  # Options: "since-main" or "since-last-commit"
BASE_BRANCH=origin/main

if [ -z "$MODULE" ]; then
  echo "Usage: $0 <module> <since-main|since-last-commit>"
  exit 2
fi

# Default to "since-main" if not provided
if [ -z "$MODE" ]; then
  MODE="since-main"
fi

# Ensure we're up to date with origin
git fetch origin $BASE_BRANCH > /dev/null 2>&1

echo "🔍 Checking changes in '$MODULE' with mode: $MODE"

case "$MODE" in
  since-main)
    if git diff --quiet "$BASE_BRANCH" -- "$MODULE"; then
      echo "No changes in $MODULE compared to $BASE_BRANCH"
      exit 0
    else
      echo "Changes detected in $MODULE compared to $BASE_BRANCH"
      exit 1
    fi
    ;;
  since-last-commit)
    if git diff --quiet HEAD~1 -- "$MODULE"; then
      echo "No changes in $MODULE since last commit"
      exit 0
    else
      echo "Changes detected in $MODULE since last commit"
      exit 1
    fi
    ;;
  *)
    echo "Invalid mode: $MODE. Use 'since-main' or 'since-last-commit'"
    exit 2
    ;;
esac
