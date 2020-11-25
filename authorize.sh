#!/bin/bash

# Requires Curl & jq


CLIENT_ID="FUSIONAUTH_CLIENTID"
AUTH_URL="https://FUSIONAUTH/oauth2/device_authorize"


JSON=$(curl -s -X POST -F "client_id=${CLIENT_ID}" -F "scope=offline" ${AUTH_URL})

echo $JSON


VERIFICATION_CODE=$(echo $JSON|jq -r .user_code)
VERIFICATION_URL=$(echo $JSON|jq -r .verification_uri)
VERIFICATION_URL_COMPLETE=$(echo $JSON|jq -r .verification_uri_complete)
DEVICE_CODE=$(echo $JSON|jq -r .device_code)
EXPIRES=$(echo $JSON|jq -r .expires_in)
INTERVAL=$(echo $JSON|jq -r .interval)
