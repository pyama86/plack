#!/bin/bash -e

function require_command() {
  which $1 > /dev/null || (echo "curl command is required" && exit 1)
}

function set_status_name() {
  curl -s -XPOST -d "token=$SLACK_API_TOKEN" -d "profile={ \"display_name\": \"$1\" }" "https://slack.com/api/users.profile.set" > /dev/null
}
if [ -z "$SLACK_API_TOKEN" ]; then
  echo '$SLACK_API_TOKEN is required'
  exit 1
  fi

require_command jq
require_command curl
before_name=`curl -s -XPOST -d "token=$SLACK_API_TOKEN" "https://slack.com/api/users.profile.get" | jq -r '.profile.display_name'`
after_name="${before_name} `date -v+25M +"%H時%M分"`までポモドーロしてます"

set_status_name "$after_name"
trap 'set_status_name "$before_name"' 1 2 3 15
echo "pomodoro timer start"
sleep 1500
osascript -e 'display notification "ポモドーロが終了しました" with title "おつぽよー"'
set_status_name "$before_name"
