#!/bin/bash


# ls -latr

echo "bash ./deviceauth.sh setDiscovery http://localhost:9011/.well-known/openid-configuration"
bash ./deviceauth.sh setDiscovery http://localhost:9011/.well-known/openid-configuration

echo "bash ./deviceauth.sh setClientid 30663132-6464-6665-3032-32646"
bash ./deviceauth.sh setClientid 30663132-6464-6665-3032-32646

echo "bash ./deviceauth.sh authorize"
bash ./deviceauth.sh authorize

#deviceauth.sh poll once

#AUTHORIZE

#deviceauth.sh poll once

#deviceauth.sh renew
