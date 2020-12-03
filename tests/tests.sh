#!/bin/bash

echo "FUSIONAUTH_API_KEY=$FUSIONAUTH_API_KEY"
echo "APPLICATION_ID=$APPLICATION_ID"

OPENID_CONFIG="$(curl -s "http://localhost:9011/.well-known/openid-configuration")"


#curl -s -o "$HOME/application.json" -H 'Authorization: $FUSIONAUTH_API_KEY' "http://localhost:9011/api/application/$APPLICATION_ID"
APPLICATIONJSON="$(curl -s -H "Authorization: $FUSIONAUTH_API_KEY" "http://localhost:9011/api/application/$APPLICATION_ID" )"
#echo "APPLICATIONJSON=$APPLICATIONJSON"

CLIENT_ID="$(echo $APPLICATIONJSON|jq -r .application.oauthConfiguration.clientId)"
echo "ClientId=$CLIENT_ID"
CLIENT_SECRET="$(echo $APPLICATIONJSON|jq -r .application.oauthConfiguration.clientSecret)"
echo "ClientSecret=$CLIENT_SECRET"


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
