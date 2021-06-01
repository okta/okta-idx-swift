#!/bin/bash

if [[ -z $OKTA_API_KEY ]]; then
    echo "No OKTA API key"
    exit 1
fi

if [[ -z $OKTA_DOMAIN ]]; then
    echo "No OKTA Domain"
    exit 1
fi

# Delete user if it exists to not fail the script
existing_user=$(oktamate users -k $OKTA_API_KEY -d $OKTA_DOMAIN | grep $PASSCODE_USERNAME)
if [[ -n $existing_user ]]; then
    oktamate users -k $OKTA_API_KEY -d $OKTA_DOMAIN $PASSCODE_USERNAME
fi
