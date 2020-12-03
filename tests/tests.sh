#!/bin/bash

echo "FUSIONAUTH_API_KEY=$FUSIONAUTH_API_KEY"

curl -s -o "application.json" -H 'Authorization: $FUSIONAUTH_API_KEY' http://localhost:9011/api/application/89d998a5-aaef-45d0-9765-adf1f3e00c65
#APPLICATIONJSON="$(<application.json)"
CLIENT_ID="$(echo $(<application.json)|jq -r .application.oauthConfiguration.clientId)"
echo "ClientId $CLIENT_ID"
CLIENT_SECRET="$(echo $(<application.json)|jq -r .application.oauthConfiguration.clientSecret)"
echo "ClientSecret $CLIENT_SECRET"


# ls -latr

echo "bash ./deviceauth.sh setDiscovery http://localhost:9011/.well-known/openid-configuration"
bash ./deviceauth.sh setDiscovery http://localhost:9011/.well-known/openid-configuration

echo "bash ./deviceauth.sh setClientid $CLIENT_ID"
bash ./deviceauth.sh setClientid $CLIENT_ID

echo "bash ./deviceauth.sh authorize"
bash ./deviceauth.sh authorize

#deviceauth.sh poll once

#AUTHORIZE

#deviceauth.sh poll once

#deviceauth.sh renew
