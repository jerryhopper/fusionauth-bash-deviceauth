#!/bin/bash


ls -latr

ls -latr ./..


bash ./../deviceauth.sh setDiscovery https://fusionauth:9011/.well-known/openid-configuration


bash ./../deviceauth.sh setClientid 30663132-6464-6665-3032-32646


#deviceauth.sh authorize

#deviceauth.sh poll once

#AUTHORIZE

#deviceauth.sh poll once

#deviceauth.sh renew
