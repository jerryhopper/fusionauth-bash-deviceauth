[![Build Status](https://travis-ci.com/jerryhopper/fusionauth-bash-deviceauth.svg?branch=master)](https://travis-ci.com/jerryhopper/fusionauth-bash-deviceauth)

# fusionauth-bash-deviceauth


## What is this? 

This is a repo with example scripts for use with FusionAuth's device authorization grant. 

More info on Fusionauth, or specifically the device grant, checkout the below links.
- https://fusionauth.io/learn/expert-advice/oauth/oauth-device-authorization/   
- https://fusionauth.io/docs/v1/tech/oauth/#example-device-authorization-grant

## Why ?

This is a good starting point for a singleboard-computer like raspberry pi, to make authorized requests to a external api.


### Usage

This script uses the current user's homedir to store information.

You can override this directory with the Environment variable  OAUTH_CONFIGDIR_ENV

```
Usage :
deviceauth.sh setDiscovery <oauth discovery url> - Sets the discovery url. (saved in /root/.oauth2/.openid-configuration.url)
deviceauth.sh discover - Retrieves discovery information. (saved in /root/.oauth2/.openid-configuration.json )
deviceauth.sh setClientid - Sets the clientId. (saved in /root/.oauth2/.client_id )
deviceauth.sh authorize - Authorize this device. ( returns json with authorize url info saved in /root/.oauth2/.tokenrequest.json)
deviceauth.sh poll - Start polling for the authorization token. (on success, returns json from /root/.oauth2/.authorization )
deviceauth.sh renew - Attemt to renew the authorization token. (on success, returns json from /root/.oauth2/.authorization )
deviceauth.sh reset - resets owner info.
deviceauth.sh  - this message
```

## Example usage workflow

First, set the discover-url.
```
deviceauth.sh setDiscovery https://fusionauth:9011/.well-known/openid-configuration
```

Second, set the ClientID
```
deviceauth.sh setClientid 30663132-6464-6665-3032-326466613934
```

Then, issue the device-authorization request
```
deviceauth.sh authorize
```
This will return JSON (see below) present the code & url to the user.


Start polling of the user has entered the code on the url given in the previous step
```
deviceauth.sh poll
```
On success, a token + refresh-token + user is returned in json, this can be used to make authenticated requests....

Renew the token, using the refresh-token.
```
deviceauth.sh renew 
```



### Example responses

## deviceauth.sh authorize 

Initiates a authorization request for this device

Example response :

```
{
  "device_code": "e6f_lF1rG_yroI0DxeQB5OrLDKU18lrDhFXeQqIKAjg",
  "expires_in": 600,
  "interval": 5,
  "user_code": "SFYNPV",
  "verification_uri": "http://localhost:9011/oauth2/device",
  "verification_uri_complete": "http://localhost:9011/oauth2/device?user_code=SFYNPV"
}
```


## deviceauth.sh poll

Polls idp server, waits for a succesful authorization response as initiated by deviceauth.sh authorize

Example response :

```
{
  "access_token" : "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJleHAiOjE0ODUxNDA5ODQsImlhdCI6MTQ4NTEzNzM4NCwiaXNzIjoiYWNtZS5jb20iLCJzdWIiOiIyOWFjMGMxOC0wYjRhLTQyY2YtODJmYy0wM2Q1NzAzMThhMWQiLCJhcHBsaWNhdGlvbklkIjoiNzkxMDM3MzQtOTdhYi00ZDFhLWFmMzctZTAwNmQwNWQyOTUyIiwicm9sZXMiOltdfQ.Mp0Pcwsz5VECK11Kf2ZZNF_SMKu5CgBeLN9ZOP04kZo",
  "expires_in" : 3600,
  "id_token" : "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJleHAiOjE0ODUxNDA5ODQsImlhdCI6MTQ4NTEzNzM4NCwiaXNzIjoiYWNtZS5jb20iLCJzdWIiOiIyOWFjMGMxOC0wYjRhLTQyY2YtODJmYy0wM2Q1NzAzMThhMWQiLCJhcHBsaWNhdGlvbklkIjoiNzkxMDM3MzQtOTdhYi00ZDFhLWFmMzctZTAwNmQwNWQyOTUyIiwicm9sZXMiOltdfQ.Mp0Pcwsz5VECK11Kf2ZZNF_SMKu5CgBeLN9ZOP04kZo",
  "refresh_token": "ze9fi6Y9sMSf3yWp3aaO2w7AMav2MFdiMIi2GObrAi-i3248oo0jTQ",
  "token_type" : "Bearer",
  "userId" : "3b6d2f70-4821-4694-ac89-60333c9c4165"
}
```


### Known issues

Renew token can fail, if you have enabled 'Require authentication' in the fusionauth administration for this application.
This is expected behavior, dont use 'Require authentication' as it requires to have the client-secret to be present on the client.

### RTFM

https://fusionauth.io/docs/v1/tech/oauth/#example-device-authorization-grant

### TODO

lots

