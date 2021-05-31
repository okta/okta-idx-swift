#!/bin/bash

if [[ -z $OKTA_API_KEY ]]; then
    echo "No Org API key"
    exit 1
fi

if [[ -z $OKTA_DOMAIN ]]; then
    echo "No Domain"
    exit 1
fi

alias oktamate=./scripts/oktamate

# Delete user if it exists to not fail the script
existing_user=$(oktamate users -k $OKTA_API_KEY -d $OKTA_DOMAIN | grep $PASSCODE_USERNAME)
if [[ -n $existing_user ]]; then
    oktamate users -k $OKTA_API_KEY -d $OKTA_DOMAIN $PASSCODE_USERNAME
fi

oktamate users create -k $OKTA_API_KEY -d $OKTA_DOMAIN -p $PASSCODE_PASSWORD $PASSCODE_USERNAME -g '00gua62f9B5eLhVBx5d6'
