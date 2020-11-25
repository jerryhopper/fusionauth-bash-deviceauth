#!/bin/bash


CLIENT_ID="FUSIONAUTH_CLIENT_ID"
TOKEN_URL="https://FUSIONAUTH/oauth2/token"

EXPIRES=1800
INTERVAL=5

end=$((SECONDS+EXPIRES))

while [  $SECONDS -lt  $end ] ;  do
		sleep $INTERVAL
		AJSON=$(curl -s -X POST -F "client_id=${CLIENT_ID}" -F "device_code=${DEVICE_CODE}" -F "grant_type=urn:ietf:params:oauth:grant-type:device_code" ${TOKEN_URL})
    HAS_ERROR="$(echo $AJSON|jq -r .error)"
    if [ -z "$HAS_ERROR" ]; then
          end=$((SECONDS))
    else
          if [ "$HAS_ERROR" != "authorization_pending" ]; then
            echo "$AJSON"
            exit 1
          fi
    fi
done

echo "$AJSON"

ACCESS_TOKEN="$(echo $AJSON|jq -r .access_token)"
EXPIRES_IN="$(echo $AJSON|jq -r .expires_in)"
TOKEN_TYPE="$(echo $AJSON|jq -r .token_type)"
USER_ID="$(echo $AJSON|jq -r .userId)"


exit 0
