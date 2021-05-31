#!/bin/bash

if [[ -z $OKTA_API_KEY ]]; then
    echo "No OKTA API key"
    exit 1
fi

if [[ -z $OKTA_DOMAIN ]]; then
    echo "No OKTA Domain"
    exit 1
fi

./oktamate users delete -k $OKTA_API_KEY -d $OKTA_DOMAIN $PASSCODE_USERNAME
