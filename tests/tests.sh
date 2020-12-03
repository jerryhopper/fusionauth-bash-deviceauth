#!/bin/bash



echo "FUSIONAUTH_API_KEY=$FUSIONAUTH_API_KEY"
echo "APPLICATION_ID=$APPLICATION_ID"
echo "DISCOVERY_URL=$DISCOVERY_URL"



OPENID_CONFIG="$(curl -s $DISCOVERY_URL)"

TOKEN_ENDPOINT=$(echo $OPENID_CONFIG|jq -r .token_endpoint)

#curl -s -o "$HOME/application.json" -H 'Authorization: $FUSIONAUTH_API_KEY' "http://localhost:9011/api/application/$APPLICATION_ID"

APPLICATIONJSON=$(curl -s -H "Authorization: $FUSIONAUTH_API_KEY" http://localhost:9011/api/application/$APPLICATION_ID )


CLIENT_ID="$(echo $APPLICATIONJSON|jq -r .application.oauthConfiguration.clientId)"
echo "ClientId=$CLIENT_ID"
CLIENT_SECRET="$(echo $APPLICATIONJSON|jq -r .application.oauthConfiguration.clientSecret)"
echo "ClientSecret=$CLIENT_SECRET"


# ls -latr
echo " "
echo "bash ./deviceauth.sh setDiscovery $DISCOVERY_URL"
bash ./deviceauth.sh setDiscovery $DISCOVERY_URL

echo " "
echo "bash ./deviceauth.sh setClientid $CLIENT_ID"
bash ./deviceauth.sh setClientid $CLIENT_ID

echo " "
echo "bash ./deviceauth.sh authorize"
bash ./deviceauth.sh authorize

echo " "
echo "bash ./deviceauth.sh poll once"
bash ./deviceauth.sh poll once

#BEGIN AUTHORIZE



JSON="$(<$HOME/.oauth2/.tokenrequest.json)"
#echo $JSON
USERCODE=$(echo $JSON|jq -r .user_code)
echo "GET http://localhost:9011/oauth2/device/validate?client_id=$CLIENT_ID&user_code=$USERCODE"
curl -i "http://localhost:9011/oauth2/device/validate?client_id=$CLIENT_ID&user_code=$USERCODE"
echo "------------------------------------------------------------------------"


#echo $JSON
echo "Manually Authorizing the device."
echo "POST $TOKEN_ENDPOINT (grant_type=password + user_code=$USERCODE + scope=offline_access)"
echo "curl -s --location --request POST '$TOKEN_ENDPOINT'"
echo " "

curl -i -s --location --request POST "$TOKEN_ENDPOINT" \
      --header 'Content-Type: application/x-www-form-urlencoded' \
      --data-urlencode 'grant_type=password' \
      --data-urlencode "client_id=$CLIENT_ID" \
      --data-urlencode "client_secret=$CLIENT_SECRET" \
      --data-urlencode 'username=$APP_USEREMAIL' \
      --data-urlencode 'password=$APP_USERPASSWORD' \
      --data-urlencode 'scope=offline_access' \
      --data-urlencode "user_code=$USERCODE"
echo " "
echo " "

echo "------------------------------------------------------------------------"
#END AUTHORIZE
echo "deviceauth.sh poll"
echo " "
bash ./deviceauth.sh poll once

echo "deviceauth.sh renew"
echo " "
bash ./deviceauth.sh renew
