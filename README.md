# fusionauth-bash-deviceauth

## What is this? 

This is a repo with example scripts for use with FusionAuth's device authorization grant.

## Why ?

This is a good starting point for a singleboard-computer like raspberry pi, to make authorized requests to a external api.


### Usage

Edit the authorize.sh and authpoll.sh  and provide CLIENT_ID and the location of your Fusionauth instance 


## authorize.sh 

Initiates a authorization request for this device


## authpoll.sh

Polls idp server, waits for a succesful authorization response as initiated by authorize.sh


