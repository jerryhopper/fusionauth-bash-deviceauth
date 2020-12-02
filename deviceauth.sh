#!/bin/bash

# is_command function
is_command() {
    # Checks for existence of string passed in as only function argument.
    # Exit value of 0 when exists, 1 if not exists. Value is the result
    # of the `command` shell built-in call.
    local check_command="$1"
    command -v "${check_command}" >/dev/null 2>&1
}


if ! is_command "jq" ;then
  echo "This script uses 'jq' which is missing."
  echo "try: apt install jq"
  exit 1
fi


if [[ -z "${OAUTH_CONFIGDIR_ENV}" ]]; then
  OAUTH_CONFIGDIR="$HOME/.oauth2"
else
  OAUTH_CONFIGDIR="${OAUTH_CONFIGDIR_ENV}"
fi




CLIENT_ID_FILE="${OAUTH_CONFIGDIR}/.client_id"

if [ -f CLIENT_ID_FILE ];then
  CLIENT_ID="$(<$CLIENT_ID_FILE)"
fi


OAUTH_OPENID_CONFIGURL_FILE="${OAUTH_CONFIGDIR}/.openid-configuration.url"
OAUTH_OPENID_CONFIG_FILE="${OAUTH_CONFIGDIR}/.openid-configuration.json"

OAUTH_OPENID_TOKEN_FILE="${OAUTH_CONFIGDIR}/.authorization"

OAUTH_OPENID_TOKEN_REQUEST_FILE="${OAUTH_CONFIGDIR}/.tokenrequest.json"
OAUTH_OPENID_REFRESHTOKEN_REQUEST_FILE="/etc/osbox/refreshtokenrequest.json"


discover(){
  # $1 represents OAUTH_OPENID_CONFIG_FILE
  # $2 represents OAUTH_OPENID_CONFIGURL
  http_response=$(curl -L -m 3 -s -o $2 -X GET -w "%{http_code}" -H "Content-type: application/json" $1 )
  if [ $http_response == "000"  ]; then
      # handle error
      #echo "{\"error\":\"Unknown error\",\"error_description\":\"curl returned: 000 $1\"}"
      echo "error"
      rm -f $2
      exit 1
  elif [ $http_response != "200" ]; then
      # handle error
      #echo "{\"error\":\"Error\",\"error_description\":\"curl returned: ${http_response} $1\"}"
      echo "error (${http_response})"
      rm -f $2
      exit 1
  elif [ $http_response == "200" ]; then
      JSON="$(cat $2)"
      #echo $JSON
      #exit 0
  else
      JSON="$(cat $2)"
      echo "error (${http_response})"
      #echo $JSON
      rm -f $2
      exit 1
  fi
}

authorize(){
  # $1 $OAUTH_OPENID_TOKEN_REQUEST_FILE
  # $2 $CLIENT_ID
  # $3 $AUTH_URL
  #authorize $OAUTH_OPENID_TOKEN_REQUEST_FILE $CLIENT_ID $AUTH_URL
  http_response=$(curl -m 3 -s -o $1 -X POST -F "client_id=$2" -F "scope=offline_access" -w "%{http_code}" $3)
  if [ $http_response == "000"  ]; then
      # handle error
      echo "{\"error\":\"unknown error\",\"error_description\":\"curl returded: 000 $3 \"}"
      rm $1
      exit 1
  elif [ $http_response == "404" ]; then
      echo "{\"error\":\"unknown error\",\"error_description\":\"curl returded: 404 $3 \"}"
      rm $1
      exit 1
  elif [ $http_response != "200" ]; then
      # handle error
      echo "$(cat $1)"
      rm $1
      exit 1
  elif [ $http_response == "200" ]; then
      echo "$(cat $1)"
      exit 0
  else
      JSON="$(cat $1)"
      rm $1
  fi
  echo $JSON

}









poll(){


    # $1 $OAUTH_OPENID_TOKEN_REQUEST_FILE
    # $2 $CLIENT_ID_FILE
    # $3 $TOKEN_URL
    # $4 $OAUTH_OPENID_TOKEN_FILE
    # $5 $POLLONCE (should contain 'once')

    # check if request file exists.
    if [ ! -f $1 ]; then
      echo "No tokenrequest.json?"
      exit 1
    fi

    CLIENT_ID="$(<$2)"

    # Load the tokenrequest json
    JSON="$(<$1)"


    # Extract variables from json
    DEVICE_CODE=$(echo "$JSON"|jq -r .device_code)
    EXPIRES=$(echo $JSON|jq -r .expires_in)
    INTERVAL=$(echo $JSON|jq -r .interval)

    # Wait untill authorization has been completed
    end=$((SECONDS+EXPIRES))
    while [  $SECONDS -lt  $end ] ;  do
        # Pause for the specified time
        sleep $INTERVAL

        AJSON="$(curl -m 3 -s -X POST -F "client_id=${CLIENT_ID}" -F "device_code=${DEVICE_CODE}" -F "grant_type=urn:ietf:params:oauth:grant-type:device_code" $3)"

        HAS_ERROR="$(echo $AJSON|jq -r .error)"
        ACCESS_TOKEN="$(echo $AJSON|jq -r .access_token)"

        if [ "$ACCESS_TOKEN" != "null" ]; then
          echo "$AJSON">$4
          rm -f $1
          echo "$AJSON"
          exit 0
        fi
        if [ "$5" == "once" ];then
            #echo "Polled one time."
            echo "$AJSON"
            exit 0
        fi
        if [ "$HAS_ERROR" != "authorization_pending" ]; then
          echo "$HAS_ERROR"
          rm -f $1
          exit 1
        fi

    done



}



renew(){
  # $1 = $OAUTH_OPENID_REFRESHTOKEN_REQUEST_FILE
  # $2 = $OAUTH_OPENID_CONFIG_FILE
  # $3 = $OAUTH_OPENID_TOKEN_FILE
  # $4 = $OAUTH_OPENID_REFRESHTOKEN_REQUEST_FILE
  # $5 = $CLIENT_ID_FILE


  if [ ! -f $3 ];then
      echo "No authentication file!?"
      exit 1
  fi

  CLIENT_ID="$(<$CLIENT_ID_FILE)"

  AUTH_JSON="$(<$3)"

  AUTH_TOKEN="$(echo $AUTH_JSON|jq -r .access_token)"
  AUTH_REFRESHTOKEN="$(echo $AUTH_JSON|jq -r .refresh_token)"


  OPENID_CONFIG="$(<$2)"
  TOKEN_ENDPOINT="$(echo $OPENID_CONFIG|jq -r .token_endpoint)"


  # POST /oauth2/token

  http_response=$(curl -m 3 -s -o $OAUTH_OPENID_REFRESHTOKEN_REQUEST_FILE -X POST -F "client_id=${CLIENT_ID}" -F "grant_type=refresh_token" -F "refresh_token=${AUTH_REFRESHTOKEN}" -w "%{http_code}" ${TOKEN_ENDPOINT})
  if [ $http_response == "000"  ]; then
      # handle error
      echo "{\"error\":\"unknown error\",\"error_description\":\"curl returded: 000 $TOKEN_ENDPOINT \"}"
      exit 1
  elif [ $http_response == "404" ]; then
      echo "{\"error\":\"unknown error\",\"error_description\":\"curl returded: 404 $TOKEN_ENDPOINT \"}"
      exit 1
  elif [ $http_response != "200" ]; then
      # handle error
      echo "$(cat $OAUTH_OPENID_REFRESHTOKEN_REQUEST_FILE)"
      rm $FILE
      exit 1
  elif [ $http_response == "200" ]; then
      JSON="$(cat $OAUTH_OPENID_REFRESHTOKEN_REQUEST_FILE)"
      rm -f $OAUTH_OPENID_REFRESHTOKEN_REQUEST_FILE
      echo $JSON>$OAUTH_OPENID_TOKEN_FILE
      echo $JSON
      exit 0
  else
      echo "$(cat $OAUTH_OPENID_REFRESHTOKEN_REQUEST_FILE)"
      exit 1
  fi



}
if [ "$1" == "reset" ]; then

    # check if request file exists.
    if [ -f $OAUTH_OPENID_TOKEN_REQUEST_FILE ]; then
      rm -f $OAUTH_OPENID_TOKEN_REQUEST_FILE
    fi

    if [ -f $OAUTH_OPENID_TOKEN_FILE ]; then
      rm -f $OAUTH_OPENID_TOKEN_FILE
    fi

fi


if [ "$1" == "renew" ]; then
    renew $OAUTH_OPENID_REFRESHTOKEN_REQUEST_FILE $OAUTH_OPENID_CONFIG_FILE $OAUTH_OPENID_TOKEN_FILE $CLIENT_ID_FILE
fi


if [ "$1" == "poll" ]; then
    # check if file exists.
    if [ -f $OAUTH_OPENID_TOKEN_FILE ]; then
      echo "Device already authorized"
      exit 1
    fi
    if [ ! -f $CLIENT_ID_FILE ]; then
      echo "No clientid!"
      exit 1
    fi
    if [ ! -f $OAUTH_OPENID_TOKEN_REQUEST_FILE ]; then
      echo "No request file! ($OAUTH_OPENID_TOKEN_REQUEST_FILE)"
      exit 1
    fi

    DISCOVERY_INFO="$(<$OAUTH_OPENID_CONFIG_FILE)"
    TOKEN_URL="$(echo $DISCOVERY_INFO|jq -r .token_endpoint)"

    poll $OAUTH_OPENID_TOKEN_REQUEST_FILE $CLIENT_ID_FILE $TOKEN_URL $OAUTH_OPENID_TOKEN_FILE $2

fi

#$HOME

if [ "$1" == "authorize" ]; then
  # check if file exists.
  if [ -f $OAUTH_OPENID_TOKEN_FILE ]; then
    echo "Device already authorized"
    exit 1
  fi
  if [ ! -f $CLIENT_ID_FILE ]; then
    echo "No clientid!"
    exit 1
  fi

  CLIENT_ID="$(<$CLIENT_ID_FILE)"
  AUTH_URL="$(echo "$(<$OAUTH_OPENID_CONFIG_FILE)"|jq -r .device_authorization_endpoint)"

  #echo "authorize $OAUTH_OPENID_TOKEN_REQUEST_FILE $CLIENT_ID $AUTH_URL"
  authorize $OAUTH_OPENID_TOKEN_REQUEST_FILE $CLIENT_ID $AUTH_URL


fi



if [ "$1" == "setClientid" ]; then
  if [ "$2" != "" ]; then
    if [ ! -d $OAUTH_CONFIGDIR ]; then
      # Make the config directory
      mkdir $OAUTH_CONFIGDIR
    fi
    echo $CLIENT_ID_FILE
    echo "$2">$CLIENT_ID_FILE
  fi
  if [ "$2" == "" ]; then
    echo "Error!  - Missing clientId"
    echo "Usage :";
    echo "deviceauth.sh setClientid <clientid> - Sets the clienId."
  fi
fi








if [ "$1" == "setDiscovery" ]; then

  if [ "$2" != "" ]; then
    if [ ! -d $OAUTH_CONFIGDIR ]; then
      # Make the config directory
      mkdir $OAUTH_CONFIGDIR
    fi
    # Write the discovery url to file.
    echo "$2">$OAUTH_OPENID_CONFIGURL_FILE
    echo "Setting discovery $2"
    # Run discovery with the given url.
    discover $2 $OAUTH_OPENID_CONFIG_FILE

    if [ ! -f $OAUTH_OPENID_CONFIG_FILE ];then
        echo "Error fetching discovery information"
        exit 1
    fi
    exit 0
  fi

  if [ "$2" == "" ]; then
    echo "Error!  - Missing discovery url"
    echo "Usage :";
    echo "deviceauth.sh setDiscovery <oauth discovery url> - Sets the discovery url."
  fi

  exit 1
fi








if [ "$1" == "discover" ]; then
  if [ ! -f $OAUTH_OPENID_CONFIGURL_FILE ];then
      echo "No discovery url specified, run setDiscovery."
      exit 1
  fi
  discover "$(<$OAUTH_OPENID_CONFIGURL_FILE)" $OAUTH_OPENID_CONFIG_FILE

  exit 0
fi

if [ "$1" == "" ]; then
  echo "Usage :";
  echo "deviceauth.sh setDiscovery <oauth discovery url> - Sets the discovery url. (saved in $OAUTH_OPENID_CONFIGURL_FILE) "
  echo "deviceauth.sh discover - Retrieves discovery information. returns JSON (saved in $OAUTH_OPENID_CONFIG_FILE)"
  echo "deviceauth.sh setClientid - Sets the clientId.  returns JSON (saved in $CLIENT_ID_FILE ) "
  echo "deviceauth.sh authorize - Authorize this device. returns JSON (saved in $OAUTH_OPENID_TOKEN_REQUEST_FILE)"
  echo "deviceauth.sh poll - Start polling for the authorization token. (on success, returns json from $OAUTH_OPENID_TOKEN_FILE )"
  echo "deviceauth.sh renew - Attemt to renew the authorization token. (on success, returns json from $OAUTH_OPENID_TOKEN_FILE )"
  echo "deviceauth.sh reset - resets owner info. "

  echo "deviceauth.sh  - this message"
  exit 1
fi
