#!/bin/bash

# Usage:
# ./notify-discord.sh "Your message here" [webhook-url]

MESSAGE="$1"
WEBHOOK="${2:-$DISCORD_WEBHOOK}"

if [ -z "$MESSAGE" ]; then
  echo "Error: No message provided."
  echo "Usage: $0 \"Your message\" [webhook-url]"
  exit 1
fi

if [ -z "$WEBHOOK" ]; then
  echo "Error: No webhook URL provided or set via DISCORD_WEBHOOK environment variable."
  exit 1
fi

curl -H "Content-Type: application/json" \
     -X POST \
     -d "{\"content\