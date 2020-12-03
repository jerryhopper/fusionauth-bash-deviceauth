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

bash ./deviceauth.sh poll once

#AUTHORIZE



JSON="$(<$HOME/.oauth2/.tokenrequest.json)"
#echo $JSON
USERCODE=$(echo $JSON|jq -r .user_code)
echo "GET http://localhost:9011/oauth2/device/validate?client_id=$CLIENT_ID&user_code=$USERCODE"
curl -i "http://localhost:9011/oauth2/device/validate?client_id=$CLIENT_ID&user_code=$USERCODE"



#echo $JSON
echo "Manually Authorizing the device."
echo "POST http://localhost:9011/oauth2/token  (grant_type=password + user_code=$USERCODE)"
--data-urlencode 'scope=offline_access' \
curl -s --location --request POST 'http://localhost:9011/oauth2/token' \
      --header 'Content-Type: application/x-www-form-urlencoded' \
      --data-urlencode 'grant_type=password' \
      --data-urlencode "client_id=$CLIENT_ID|jq -r .application.oauthConfiguration.clientId)" \
      --data-urlencode "client_secret=$CLIENT_SECRET|jq -r .application.oauthConfiguration.clientSecret)" \
      --data-urlencode 'username=user@local.nu' \
      --data-urlencode 'password=userpassword' \
      --data-urlencode "user_code=$USERCODE"





#deviceauth.sh poll once

#deviceauth.sh renew
