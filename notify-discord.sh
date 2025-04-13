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

PAYLOAD=$(jq -n --arg content "$MESSAGE" '{content: $content}')

RESPONSE=$(curl -s -w "%{http_code}" -o /dev/null -H "Content-Type: application/json" -X POST -d "$PAYLOAD" $WEBHOOK)
echo $WEBHOOK
echo $PAYLOAD
echo $RESPONSE

if [ "$RESPONSE" -ne 204 ]; then
  echo "Failed to send message to Discord (HTTP $RESPONSE)"
  exit 1
else
  echo "Message sent to Discord successfully."
fi
