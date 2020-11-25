# fusionauth-bash-deviceauth

## What is this? 

This is a repo with example scripts for use with FusionAuth's device authorization grant. 

More info on Fusionauth, or specifically the device grant, checkout the below links.
- https://fusionauth.io/learn/expert-advice/oauth/oauth-device-authorization/   
- https://fusionauth.io/docs/v1/tech/oauth/#example-device-authorization-grant

## Why ?

This is a good starting point for a singleboard-computer like raspberry pi, to make authorized requests to a external api.


### Usage

Edit the authorize.sh and authpoll.sh  and provide CLIENT_ID and the location of your Fusionauth instance.

The script will output the raw json response.


## authorize.sh 

Initiates a authorization request for this device

Example response :
'{
  "device_code": "e6f_lF1rG_yroI0DxeQB5OrLDKU18lrDhFXeQqIKAjg",
  "expires_in": 600,
  "interval": 5,
  "user_code": "SFYNPV",
  "verification_uri": "http://localhost:9011/oauth2/device",
  "verification_uri_complete": "http://localhost:9011/oauth2/device?user_code=SFYNPV"
}'


## authpoll.sh

Polls idp server, waits for a succesful authorization response as initiated by authorize.sh

Example response :
'{
  "access_token" : "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJleHAiOjE0ODUxNDA5ODQsImlhdCI6MTQ4NTEzNzM4NCwiaXNzIjoiYWNtZS5jb20iLCJzdWIiOiIyOWFjMGMxOC0wYjRhLTQyY2YtODJmYy0wM2Q1NzAzMThhMWQiLCJhcHBsaWNhdGlvbklkIjoiNzkxMDM3MzQtOTdhYi00ZDFhLWFmMzctZTAwNmQwNWQyOTUyIiwicm9sZXMiOltdfQ.Mp0Pcwsz5VECK11Kf2ZZNF_SMKu5CgBeLN9ZOP04kZo",
  "expires_in" : 3600,
  "id_token" : "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJleHAiOjE0ODUxNDA5ODQsImlhdCI6MTQ4NTEzNzM4NCwiaXNzIjoiYWNtZS5jb20iLCJzdWIiOiIyOWFjMGMxOC0wYjRhLTQyY2YtODJmYy0wM2Q1NzAzMThhMWQiLCJhcHBsaWNhdGlvbklkIjoiNzkxMDM3MzQtOTdhYi00ZDFhLWFmMzctZTAwNmQwNWQyOTUyIiwicm9sZXMiOltdfQ.Mp0Pcwsz5VECK11Kf2ZZNF_SMKu5CgBeLN9ZOP04kZo",
  "refresh_token": "ze9fi6Y9sMSf3yWp3aaO2w7AMav2MFdiMIi2GObrAi-i3248oo0jTQ",
  "token_type" : "Bearer",
  "userId" : "3b6d2f70-4821-4694-ac89-60333c9c4165"
}'



### RTFM

https://fusionauth.io/docs/v1/tech/oauth/#example-device-authorization-grant

### TODO

lots
